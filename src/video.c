/* ================================================
 * FreeRos BIOS
 * video.c: INT 10h video services and display output
 * ================================================ */

#include "bios.h"
#include "machine.h"

/*
 * Video module.
 *
 * For machines with an external video ROM (e.g. PC1640 PEGA1A at C000h),
 * this provides option ROM scanning to locate and execute it.  Optional
 * in-ROM PEGA builds supply INT 10h and tables from the motherboard ROS.
 */

/* ================================================
 * Video Parameter Tables
 * ================================================ */

/*
 * The PC1640 ROS exposes a motherboard-owned INT 1Dh 6845 table even when
 * the active PEGA BIOS lives at C000h. Keep the same table available for
 * the in-ROM driver and for the external-ROM compatibility path.
 */
#if BIOS_CFG_TARGET_PC1640DD || BIOS_CFG_VIDEO_PEGA_INROM_DRIVER
#if BIOS_CFG_TARGET_PC1640DD && !BIOS_CFG_XTIDE_ENABLED
#define BIOS_PC1640_VIDEO_TABLE_ATTR __attribute__((section(".rodata.compat_video")))
#else
#define BIOS_PC1640_VIDEO_TABLE_ATTR
#endif
const u8 bios_video_parameter_table[64] BIOS_PC1640_VIDEO_TABLE_ATTR = {
  0x38, 0x28, 0x2D, 0x0A, 0x1F, 0x06, 0x19, 0x1C,
  0x02, 0x07, 0x06, 0x07, 0x00, 0x00, 0x00, 0x00,
  0x71, 0x50, 0x5A, 0x0A, 0x1F, 0x06, 0x19, 0x1C,
  0x02, 0x07, 0x06, 0x07, 0x00, 0x00, 0x00, 0x00,
  0x38, 0x28, 0x2D, 0x0A, 0x7F, 0x06, 0x64, 0x70,
  0x02, 0x01, 0x06, 0x07, 0x00, 0x00, 0x00, 0x00,
  0x61, 0x50, 0x52, 0x0F, 0x19, 0x06, 0x19, 0x19,
  0x02, 0x0D, 0x0B, 0x0C, 0x00, 0x00, 0x00, 0x00
};
#undef BIOS_PC1640_VIDEO_TABLE_ATTR
#endif

#if BIOS_CFG_VIDEO_BUILTIN_TEXT
/*
 * Placeholder graphics-character data for INT 1Fh/43h (unused on stock PC1640).
 */
const u8 bios_video_graphics_fallback[8] = {
  0x00, 0x18, 0x24, 0x42, 0x42, 0x24, 0x18, 0x00
};
#endif

/* ================================================
 * Cursor and Display Helper Functions
 * ================================================ */

static void bios_video_write_cell (u8 row, u8 col, u8 ch, u8 attr);
#if BIOS_CFG_VIDEO_BUILTIN_TEXT
static u16 bios_video_builtin_page_size_for_mode (u8 mode);
static void bios_video_service_int10_common (bios_regs_t __far *regs);
#endif
#if !BIOS_CFG_VIDEO_BUILTIN_TEXT
static int bios_video_int10_ready (void);
#endif

static void
bios_video_set_default_attribute (u8 attr)
{
  bios_work_write8 (WK_VIDEO_ATTRIBUTE, attr);
}

static u8
bios_video_default_attribute (void)
{
  return bios_work_read8 (WK_VIDEO_ATTRIBUTE);
}

static u8
bios_video_current_page (void)
{
  return bios_bda_read8 (BDA_ACTIVE_PAGE);
}

static u8
bios_video_columns (void)
{
  u16 columns;

  columns = bios_bda_read16 (BDA_VIDEO_COLUMNS);
  if (columns == 0)
    return BIOS_CFG_VIDEO_COLUMNS;

  return (u8) columns;
}

static u8
bios_video_rows (void)
{
  u8 rows_minus_one;

  rows_minus_one = bios_bda_read8 (BDA_VIDEO_ROWS_MINUS_ONE);
  if (rows_minus_one == 0)
    return BIOS_CFG_VIDEO_ROWS;

  return (u8) (rows_minus_one + 1U);
}

static u16
bios_video_page_size (void)
{
  u16 page_size;

  page_size = bios_bda_read16 (BDA_VIDEO_PAGE_SIZE);
  if (page_size == 0)
    page_size = (u16) bios_video_columns () * bios_video_rows () * 2U;

  return page_size;
}

static u16
bios_video_page_offset (void)
{
  u16 page_offset;

  page_offset = bios_bda_read16 (BDA_VIDEO_PAGE_OFFSET);
  if (page_offset == 0 && bios_video_current_page () != 0)
    page_offset = (u16) (bios_video_page_size () * bios_video_current_page ());

  return page_offset;
}

static u16
bios_video_text_segment (void)
{
  if (bios_bda_read8 (BDA_VIDEO_MODE) == VIDEO_MODE_80X25_MONO
      || bios_bda_read16 (BDA_CRTC_PORT) == PORT_MDA_CRTC_ADDR)
    return BIOS_VIDEO_MONO_SEGMENT;

  return BIOS_VIDEO_COLOR_SEGMENT;
}

static u16
bios_video_cursor_offset (u8 page)
{
  return (u16) (BDA_CURSOR_POSITIONS + ((u16) page << 1));
}

static void
bios_video_set_page_cursor (u8 page, u8 row, u8 col)
{
  bios_bda_write16 (bios_video_cursor_offset (page),
                    (u16) (((u16) row << 8) | col));
}

static void
bios_video_get_page_cursor (u8 page, u8 *row, u8 *col)
{
  u16 cursor;

  cursor = bios_bda_read16 (bios_video_cursor_offset (page));
  *row = bios_hi (cursor);
  *col = bios_lo (cursor);
}

#if BIOS_CFG_VIDEO_BUILTIN_TEXT
static u8
bios_video_builtin_columns_for_mode (u8 mode)
{
  switch (mode)
    {
    case VIDEO_MODE_40X25_BW:
    case VIDEO_MODE_40X25_COLOR:
    case VIDEO_MODE_320X200_COLOR:
    case VIDEO_MODE_320X200_BW:
      return 40;
    case 0x08:
    case 0x09:
      return 40;
    default:
      return 80;
    }
}

static u16
bios_video_builtin_page_size_for_mode (u8 mode)
{
  switch (mode)
    {
    case VIDEO_MODE_40X25_BW:
    case VIDEO_MODE_40X25_COLOR:
      return 0x0800;

    case VIDEO_MODE_80X25_BW:
    case VIDEO_MODE_80X25_COLOR:
      return 0x1000;

    case VIDEO_MODE_320X200_COLOR:
    case VIDEO_MODE_320X200_BW:
    case VIDEO_MODE_640X200_BW:
      return 0x4000;

    default:
      return (u16) bios_video_builtin_columns_for_mode (mode) * 25U * 2U;
    }
}

static u16
bios_video_builtin_crtc_for_mode (u8 mode)
{
  return mode == VIDEO_MODE_80X25_MONO ? PORT_MDA_CRTC_ADDR : PORT_CRTC_ADDR;
}

static void
bios_video_builtin_init_mode (u8 mode, int clear_screen)
{
  u8 columns;
  u8 page;

  columns = bios_video_builtin_columns_for_mode (mode);

  bios_bda_write8 (BDA_VIDEO_MODE, mode);
  bios_bda_write16 (BDA_VIDEO_COLUMNS, columns);
  bios_bda_write16 (BDA_VIDEO_PAGE_SIZE,
                    bios_video_builtin_page_size_for_mode (mode));
  bios_bda_write16 (BDA_VIDEO_PAGE_OFFSET, 0x0000);
  bios_bda_write16 (BDA_CRTC_PORT, bios_video_builtin_crtc_for_mode (mode));
  bios_bda_write8 (BDA_ACTIVE_PAGE, 0x00);
  bios_bda_write8 (BDA_VIDEO_ROWS_MINUS_ONE, 24);
  bios_bda_write8 (BDA_VIDEO_CHAR_POINTS,
                   BIOS_CFG_VIDEO_PEGA_INROM_DRIVER ? 14 : 8);

  for (page = 0; page != 8; ++page)
    bios_video_set_page_cursor (page, 0, 0);

  machine_video_program_mode (mode);

  if (clear_screen)
    bios_video_clear (bios_video_default_attribute ());
}

static u16
bios_video_read_cell (u8 row, u8 col)
{
  u8 columns;
  u8 rows;
  u16 offset;

  columns = bios_video_columns ();
  rows = bios_video_rows ();
  if (row >= rows || col >= columns)
    return (u16) (((u16) bios_video_default_attribute () << 8) | ' ');

  offset = (u16) (bios_video_page_offset ()
                  + (((u16) row * columns) + col) * 2U);
  return bios_abs_read16 (bios_video_text_segment (), offset);
}

static void
bios_video_builtin_scroll_window (u8 up, u8 lines, u8 attr, u8 top_row,
                                  u8 left_col, u8 bottom_row, u8 right_col)
{
  u8 row;
  u8 col;
  u8 width;
  u8 height;

  if (bottom_row < top_row || right_col < left_col)
    return;

  width = (u8) (right_col - left_col + 1U);
  height = (u8) (bottom_row - top_row + 1U);
  if (lines == 0 || lines > height)
    lines = height;

  if (lines == height)
    {
      for (row = top_row; row <= bottom_row; ++row)
        bios_video_fill (row, left_col, width, ' ', attr);
      return;
    }

  if (up)
    {
      for (row = top_row; row <= (u8) (bottom_row - lines); ++row)
        for (col = left_col; col <= right_col; ++col)
          {
            u16 cell;

            cell = bios_video_read_cell ((u8) (row + lines), col);
            bios_video_write_cell (row, col, bios_lo (cell), bios_hi (cell));
          }

      for (row = (u8) (bottom_row - lines + 1U); row <= bottom_row; ++row)
        bios_video_fill (row, left_col, width, ' ', attr);
    }
  else
    {
      int rowi;

      for (rowi = bottom_row; rowi >= (int) top_row + lines; --rowi)
        for (col = left_col; col <= right_col; ++col)
          {
            u16 cell;

            cell = bios_video_read_cell ((u8) (rowi - lines), col);
            bios_video_write_cell ((u8) rowi, col, bios_lo (cell),
                                   bios_hi (cell));
          }

      for (row = top_row; row < (u8) (top_row + lines); ++row)
        bios_video_fill (row, left_col, width, ' ', attr);
    }
}

/* ================================================
 * Text Output Functions
 * ================================================ */

static void
bios_video_builtin_teletype (u8 ch, u8 attr)
{
  u8 row;
  u8 col;
  u8 columns;
  u8 rows;

  columns = bios_video_columns ();
  rows = bios_video_rows ();
  bios_video_get_page_cursor (bios_video_current_page (), &row, &col);

  switch (ch)
    {
    case '\r':
      col = 0;
      break;
    case '\n':
      row++;
      break;
    case '\b':
      if (col != 0)
        col--;
      break;
    case '\a':
      bios_beep_ticks (1);
      break;
    default:
      bios_video_write_cell (row, col, ch, attr);
      col++;
      if (col >= columns)
        {
          col = 0;
          row++;
        }
      break;
    }

  if (row >= rows)
    {
      bios_video_builtin_scroll_window (1, 1, attr, 0, 0,
                                        (u8) (rows - 1U),
                                        (u8) (columns - 1U));
      row = (u8) (rows - 1U);
    }

  bios_video_set_page_cursor (bios_video_current_page (), row, col);
}

#endif

#if !BIOS_CFG_VIDEO_BUILTIN_TEXT
static int
bios_video_int10_ready (void)
{
  u16 off;
  u16 seg;

  off = bios_abs_read16 (0x0000, (u16) 0x10 * 4U);
  seg = bios_abs_read16 (0x0000, (u16) ((0x10 * 4U) + 2U));
  return off != 0x0000 && seg != 0x0000 && seg != BIOS_ROM_SEGMENT;
}
#endif

static void
bios_video_write_cell (u8 row, u8 col, u8 ch, u8 attr)
{
  u8 columns;
  u8 rows;
  u16 offset;

  columns = bios_video_columns ();
  rows = bios_video_rows ();
  if (row >= rows || col >= columns)
    return;

  offset = (u16) (bios_video_page_offset ()
		   + (((u16) row * columns) + col) * 2U);
  bios_abs_write16 (bios_video_text_segment (), offset,
		    (u16) ((u16) attr << 8) | ch);
}

/* ================================================
 * Hardware Abstraction Layer
 * ================================================ */

static void
bios_video_hw_teletype (u8 ch, u8 page, u8 attr)
{
#if BIOS_CFG_VIDEO_BUILTIN_TEXT
  (void) page;
  bios_video_builtin_teletype (ch, attr);
#else
  u16 cursor;
  u8 row;
  u8 col;

  /*
   * PC1640 keeps motherboard text output minimal until the PEGA ROM owns
   * INT 10h. Before that handoff we write directly into text memory using the
   * seed state published by machine_video_init(); afterwards we defer to the
   * adapter BIOS exactly as a real system would.
   */
  if (!bios_video_int10_ready ())
    {
      cursor = bios_bda_read16 (bios_video_cursor_offset (page));
      row = bios_hi (cursor);
      col = bios_lo (cursor);

      switch (ch)
        {
        case '\r':
          col = 0;
          break;
        case '\n':
          if (row < (u8) (bios_video_rows () - 1U))
            row++;
          break;
        default:
          bios_video_write_cell (row, col, ch, attr);
          if (++col >= bios_video_columns ())
            {
              col = 0;
              if (row < (u8) (bios_video_rows () - 1U))
                row++;
            }
          break;
        }

      bios_bda_write16 (bios_video_cursor_offset (page),
                        (u16) (((u16) row << 8) | col));
      return;
    }

  {
    u16 ax;
    u16 bx;

  ax = (u16) 0x0E00 | ch;
  bx = (u16) page << 8 | attr;
  asm volatile ("push %%bp\n\t"
		"push %%ds\n\t"
		"push %%es\n\t"
		"int $0x10\n\t"
		"pop %%es\n\t"
		"pop %%ds\n\t"
		"pop %%bp"::"a" (ax), "b" (bx):"cx", "dx", "si", "di",
		"memory", "cc");
  }
#endif
}

static void
bios_video_hw_set_cursor (u8 row, u8 col, u8 page)
{
#if BIOS_CFG_VIDEO_BUILTIN_TEXT
  bios_video_set_page_cursor (page, row, col);
#else
  if (!bios_video_int10_ready ())
    {
      bios_video_set_page_cursor (page, row, col);
      return;
    }

  {
    u16 ax;
    u16 bx;
    u16 dx;

  ax = 0x0200;
  bx = (u16) page << 8;
  dx = (u16) row << 8 | col;
  asm volatile ("push %%bp\n\t"
		"push %%ds\n\t"
		"push %%es\n\t"
		"int $0x10\n\t"
		"pop %%es\n\t"
		"pop %%ds\n\t"
		"pop %%bp"::"a" (ax), "b" (bx), "d" (dx):"cx", "si", "di",
		"memory", "cc");
  }
#endif
}

static void
bios_video_hw_set_mode (u8 mode)
{
#if BIOS_CFG_VIDEO_BUILTIN_TEXT
  bios_video_builtin_init_mode (mode, 1);
#elif BIOS_CFG_VIDEO_PEGA_INROM_DRIVER
  bios_video_pega_apply_text_mode (mode, 1);
#else
  if (!bios_video_int10_ready ())
    return;

  {
    u16 ax;
  ax = mode;
  asm volatile ("push %%bp\n\t"
		"push %%ds\n\t"
		"push %%es\n\t"
		"int $0x10\n\t"
		"pop %%es\n\t"
		"pop %%ds\n\t"
		"pop %%bp"::"a" (ax):"bx", "cx", "dx", "si", "di", "memory",
		"cc");
  }
#endif
}

static void
bios_video_hw_hide_cursor (void)
{
#if BIOS_CFG_VIDEO_BUILTIN_TEXT
  bios_bda_write16 (BDA_CURSOR_TYPE, 0x2000);
#else
  if (!bios_video_int10_ready ())
    {
      bios_bda_write16 (BDA_CURSOR_TYPE, 0x2000);
      return;
    }

  {
    u16 ax;
    u16 cx;
  ax = 0x0100;
  cx = 0x2000;
  asm volatile ("push %%bp\n\t"
		"push %%ds\n\t"
		"push %%es\n\t"
		"int $0x10\n\t"
		"pop %%es\n\t"
		"pop %%ds\n\t"
		"pop %%bp"::"a" (ax), "c" (cx):"bx", "dx", "si", "di",
		"memory", "cc");
  }
#endif
}

static void
bios_video_hw_write_repeat (u8 ch, u8 page, u8 attr, u16 count)
{
#if BIOS_CFG_VIDEO_BUILTIN_TEXT
  u8 row;
  u8 col;

  bios_video_get_page_cursor (page, &row, &col);
  while (count-- != 0)
    {
      bios_video_write_cell (row, col, ch, attr);
      col++;
      if (col >= bios_video_columns ())
        {
          col = 0;
          row++;
        }
    }
  bios_video_set_page_cursor (page, row, col);
#else
  u8 row;
  u8 col;

  if (!bios_video_int10_ready ())
    {
      bios_video_get_page_cursor (page, &row, &col);
      while (count-- != 0)
        {
          bios_video_write_cell (row, col, ch, attr);
          col++;
          if (col >= bios_video_columns ())
            {
              col = 0;
              row++;
            }
        }
      bios_video_set_page_cursor (page, row, col);
      return;
    }

  {
    u16 ax;
    u16 bx;
  ax = (u16) 0x0900 | ch;
  bx = (u16) page << 8 | attr;
  asm volatile ("push %%bp\n\t"
		"push %%ds\n\t"
		"push %%es\n\t"
		"int $0x10\n\t"
		"pop %%es\n\t"
		"pop %%ds\n\t"
		"pop %%bp"::"a" (ax), "b" (bx), "c" (count):"dx", "si", "di",
		"memory", "cc");
  }
#endif
}

static void
bios_video_hw_scroll_window (u8 lines, u8 attr, u8 top_row, u8 left_col,
			     u8 bottom_row, u8 right_col)
{
#if BIOS_CFG_VIDEO_BUILTIN_TEXT
  bios_video_builtin_scroll_window (1, lines, attr, top_row, left_col,
                                    bottom_row, right_col);
#else
  if (!bios_video_int10_ready ())
    return;

  {
    u16 ax;
    u16 bx;
    u16 cx;
    u16 dx;
  ax = (u16) 0x0600 | lines;
  bx = (u16) attr << 8;
  cx = (u16) top_row << 8 | left_col;
  dx = (u16) bottom_row << 8 | right_col;
  asm volatile ("push %%bp\n\t"
		"push %%ds\n\t"
		"push %%es\n\t"
		"int $0x10\n\t"
		"pop %%es\n\t"
		"pop %%ds\n\t"
		"pop %%bp"::"a" (ax), "b" (bx), "c" (cx), "d" (dx):"si", "di",
		"memory", "cc");
  }
#endif
}

/* ================================================
 * Public API: Init, Output, and Display Control
 * ================================================ */

void
bios_video_init (void)
{
  bios_video_set_default_attribute (BIOS_CFG_VIDEO_ATTRIBUTE);

  /*
   * PC1640 uses machine_video_init() for PEGA; the in-ROM PEGA driver build
   * skips the C000 video BIOS and does not need this scan.
   */
  if (!BIOS_CFG_VIDEO_PEGA_INROM_DRIVER && BIOS_CFG_VIDEO_OPTION_ROM_SCAN_ENABLED)
    bios_option_rom_scan (BIOS_CFG_VIDEO_OPTION_ROM_SCAN_START,
			  BIOS_CFG_VIDEO_OPTION_ROM_SCAN_END,
			  BIOS_CFG_VIDEO_OPTION_ROM_SCAN_STEP);
}

void
__attribute__((section(".htext")))
bios_video_putc (char ch)
{
#if BIOS_CFG_TRACE_VIDEO_COM1
  bios_serial_debug_putc (ch);
#endif
  bios_video_hw_teletype ((u8) ch, bios_video_current_page (),
			  bios_video_default_attribute ());
}

void
__attribute__((section(".htext")))
bios_video_puts (const char *text)
{
  while (*text != '\0')
    {
      bios_video_putc (*text);
      text++;
    }
}

void
bios_video_put_hex8 (u8 value)
{
  bios_video_putc (bios_hex_digits[(value >> 4) & 0x0F]);
  bios_video_putc (bios_hex_digits[value & 0x0F]);
}

void
bios_video_put_hex16 (u16 value)
{
  bios_video_put_hex8 (bios_hi (value));
  bios_video_put_hex8 (bios_lo (value));
}

void
__attribute__((section(".htext")))
bios_video_set_attribute (u8 attr)
{
  bios_video_set_default_attribute (attr);
}

void
bios_video_set_mode (u8 mode)
{
  bios_video_hw_set_mode (mode);
}

void
bios_video_hide_cursor (void)
{
  bios_video_hw_hide_cursor ();
}

void
bios_video_set_cursor (u8 row, u8 col)
{
  bios_video_hw_set_cursor (row, col, bios_video_current_page ());
}

void
bios_video_clear (u8 attr)
{
  u8 rows;
  u8 columns;
  u8 row;

  bios_video_set_default_attribute (attr);
  rows = bios_video_rows ();
  columns = bios_video_columns ();
  for (row = 0; row != rows; ++row)
    bios_video_fill (row, 0, columns, ' ', attr);

  bios_video_set_cursor (0, 0);
}

void
bios_video_fill (u8 row, u8 col, u8 width, char ch, u8 attr)
{
  u8 columns;
  u8 count;
  u8 i;

  columns = bios_video_columns ();
  if (col >= columns || width == 0)
    return;

  count = width;
  if ((u16) col + count > columns)
    count = (u8) (columns - col);

  for (i = 0; i != count; ++i)
    bios_video_write_cell (row, (u8) (col + i), (u8) ch, attr);
}

void
bios_video_puts_at (u8 row, u8 col, u8 attr, const char *text)
{
  u8 columns;

  columns = bios_video_columns ();
  while (*text != '\0' && col < columns)
    {
      bios_video_write_cell (row, col, (u8) *text, attr);
      text++;
      col++;
    }
}

void
bios_video_put_hex8_at (u8 row, u8 col, u8 attr, u8 value)
{
  char text[3];

  text[0] = bios_hex_digits[(value >> 4) & 0x0F];
  text[1] = bios_hex_digits[value & 0x0F];
  text[2] = '\0';
  bios_video_puts_at (row, col, attr, text);
}

void
bios_video_put_hex16_at (u8 row, u8 col, u8 attr, u16 value)
{
  bios_video_put_hex8_at (row, col, attr, bios_hi (value));
  bios_video_put_hex8_at (row, (u8) (col + 2U), attr, bios_lo (value));
}

void
bios_video_put_udec_at (u8 row, u8 col, u8 attr, u16 value)
{
  char digits[6];
  u8 index;

  index = 5;
  digits[index] = '\0';

  do
    {
      index--;
      digits[index] = (char) ('0' + (value % 10U));
      value = (u16) (value / 10U);
    }
  while (value != 0 && index != 0);

  bios_video_puts_at (row, col, attr, &digits[index]);
}

#if BIOS_CFG_DEBUG_VIDEO_STATE
void
bios_video_debug_dump_state (const char *tag)
{
  u16 off;

  #define BIOS_VIDEO_DEBUG_DUMP_VECTOR(intno)                                  \
    do                                                                         \
      {                                                                        \
        off = (u16) (intno) * 4U;                                              \
        bios_serial_debug_put_hex16 (bios_abs_read16 (0x0000,                  \
                                                       (u16) (off + 2U)));     \
        bios_serial_debug_putc (':');                                          \
        bios_serial_debug_put_hex16 (bios_abs_read16 (0x0000, off));           \
      }                                                                        \
    while (0)

  bios_serial_debug_puts ("VID ");
  bios_serial_debug_puts (tag);
  bios_serial_debug_puts (" M=");
  bios_serial_debug_put_hex8 (bios_bda_read8 (BDA_VIDEO_MODE));
  bios_serial_debug_puts (" C=");
  bios_serial_debug_put_hex16 (bios_bda_read16 (BDA_VIDEO_COLUMNS));
  bios_serial_debug_puts (" P=");
  bios_serial_debug_put_hex16 (bios_bda_read16 (BDA_VIDEO_PAGE_SIZE));
  bios_serial_debug_puts (" O=");
  bios_serial_debug_put_hex16 (bios_bda_read16 (BDA_CRTC_PORT));
  bios_serial_debug_puts (" R=");
  bios_serial_debug_put_hex8 (bios_bda_read8 (BDA_VIDEO_ROWS_MINUS_ONE));
  bios_serial_debug_puts (" H=");
  bios_serial_debug_put_hex8 (bios_bda_read8 (BDA_VIDEO_CHAR_POINTS));
  bios_serial_debug_puts (" X7=");
  bios_serial_debug_put_hex8 (bios_abs_read8 (0x0000, 0x0487));
  bios_serial_debug_puts (" X8=");
  bios_serial_debug_put_hex8 (bios_abs_read8 (0x0000, 0x0488));
  bios_serial_debug_puts ("\n");

  bios_serial_debug_puts ("VID vec 10=");
  BIOS_VIDEO_DEBUG_DUMP_VECTOR (0x10);
  bios_serial_debug_puts (" 1D=");
  BIOS_VIDEO_DEBUG_DUMP_VECTOR (0x1D);
  bios_serial_debug_puts (" 1F=");
  BIOS_VIDEO_DEBUG_DUMP_VECTOR (0x1F);
  bios_serial_debug_puts (" 42=");
  BIOS_VIDEO_DEBUG_DUMP_VECTOR (0x42);
  bios_serial_debug_puts (" 43=");
  BIOS_VIDEO_DEBUG_DUMP_VECTOR (0x43);
  bios_serial_debug_puts ("\n");

  #undef BIOS_VIDEO_DEBUG_DUMP_VECTOR
}
#endif

/* ================================================
 * INT 10h Service Dispatch
 * ================================================ */

#if BIOS_CFG_VIDEO_BUILTIN_TEXT
/*
 * INT 10h text service shared by Generic XT and PC1640 in-ROM PEGA builds.
 */
static void
bios_video_service_int10_common (bios_regs_t __far *regs)
{
  u8 ah;

  ah = bios_hi (regs->ax);
  switch (ah)
    {
    case 0x00:
      bios_video_set_mode (bios_lo (regs->ax));
      bios_clear_cf (regs);
      break;

    case 0x01:
      bios_bda_write16 (BDA_CURSOR_TYPE, regs->cx);
      bios_clear_cf (regs);
      break;

    case 0x02:
      bios_video_hw_set_cursor (bios_hi (regs->dx), bios_lo (regs->dx),
                                bios_hi (regs->bx));
      bios_clear_cf (regs);
      break;

    case 0x03:
      regs->cx = bios_bda_read16 (BDA_CURSOR_TYPE);
      regs->dx = bios_bda_read16 (bios_video_cursor_offset (bios_hi (regs->bx)));
      bios_clear_cf (regs);
      break;

    case 0x05:
      bios_bda_write8 (BDA_ACTIVE_PAGE, bios_lo (regs->ax));
      bios_bda_write16 (BDA_VIDEO_PAGE_OFFSET,
                        (u16) bios_bda_read8 (BDA_ACTIVE_PAGE)
                        * bios_bda_read16 (BDA_VIDEO_PAGE_SIZE));
      bios_clear_cf (regs);
      break;

    case 0x06:
      bios_video_builtin_scroll_window (1, bios_lo (regs->ax),
                                        bios_hi (regs->bx),
                                        bios_hi (regs->cx),
                                        bios_lo (regs->cx),
                                        bios_hi (regs->dx),
                                        bios_lo (regs->dx));
      bios_clear_cf (regs);
      break;

    case 0x07:
      bios_video_builtin_scroll_window (0, bios_lo (regs->ax),
                                        bios_hi (regs->bx),
                                        bios_hi (regs->cx),
                                        bios_lo (regs->cx),
                                        bios_hi (regs->dx),
                                        bios_lo (regs->dx));
      bios_clear_cf (regs);
      break;

    case 0x08:
      {
        u8 row;
        u8 col;

        bios_video_get_page_cursor (bios_video_current_page (), &row, &col);
        regs->ax = bios_video_read_cell (row, col);
        bios_clear_cf (regs);
      }
      break;

    case 0x09:
      bios_video_hw_write_repeat (bios_lo (regs->ax), bios_hi (regs->bx),
                                  bios_lo (regs->bx), regs->cx);
      bios_clear_cf (regs);
      break;

    case 0x0A:
      bios_video_hw_write_repeat (bios_lo (regs->ax), bios_hi (regs->bx),
                                  bios_video_default_attribute (), regs->cx);
      bios_clear_cf (regs);
      break;

    case 0x0E:
      bios_video_hw_teletype (bios_lo (regs->ax), bios_hi (regs->bx),
                              bios_video_default_attribute ());
      bios_clear_cf (regs);
      break;

    case 0x0F:
      regs->ax = (u16) bios_bda_read8 (BDA_VIDEO_MODE)
        | ((u16) bios_bda_read16 (BDA_VIDEO_COLUMNS) << 8);
      bios_set_hi (&regs->bx, bios_bda_read8 (BDA_ACTIVE_PAGE));
      bios_clear_cf (regs);
      break;

    default:
      break;
    }
}
#endif

#if BIOS_CFG_VIDEO_BUILTIN_TEXT
void
bios_service_int10 (bios_regs_t __far *regs)
{
  bios_serial_debug_putc ('I');
  bios_video_service_int10_common (regs);
}
#else
void
__attribute__((section(".htext")))
bios_service_int10 (bios_regs_t __far *regs)
{
  /*
   * Stock PC1640: PEGA option ROM owns INT 10h after C000 init.
   */
  bios_clear_cf (regs);
}
#endif
