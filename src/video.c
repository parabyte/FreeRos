#include "bios.h"

/*
 * Minimal video module for the PC1640 BIOS.
 *
 * The Paradise PEGA1A video ROM at C000h provides all INT 10h services,
 * fonts, and video initialization.  This module only provides:
 *   - Option ROM scanning to locate and execute the PEGA ROM
 *   - POST output via INT 10h AH=0Eh (teletype), delegated to PEGA
 *   - An empty INT 10h stub as an IVT placeholder before PEGA takes over
 */

static int
bios_video_scan_option_roms (void)
{
  return bios_option_rom_scan (BIOS_CFG_VIDEO_OPTION_ROM_SCAN_START,
			       BIOS_CFG_VIDEO_OPTION_ROM_SCAN_END,
			       BIOS_CFG_VIDEO_OPTION_ROM_SCAN_STEP);
}

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

static void
bios_video_hw_teletype (u8 ch, u8 page, u8 attr)
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

static void
bios_video_hw_set_cursor (u8 row, u8 col, u8 page)
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

static void
bios_video_hw_set_mode (u8 mode)
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

static void
bios_video_hw_hide_cursor (void)
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

static void
bios_video_hw_write_repeat (u8 ch, u8 page, u8 attr, u16 count)
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

static void
bios_video_hw_scroll_window (u8 lines, u8 attr, u8 top_row, u8 left_col,
			     u8 bottom_row, u8 right_col)
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

static void
bios_video_debug_dump_vector (u8 intno)
{
  u16 off;

  off = (u16) intno * 4U;
  bios_serial_debug_put_hex16 (bios_abs_read16 (0x0000, (u16) (off + 2U)));
  bios_serial_debug_putc (':');
  bios_serial_debug_put_hex16 (bios_abs_read16 (0x0000, off));
}

void
bios_video_init (void)
{
  if (BIOS_CFG_VIDEO_OPTION_ROM_SCAN_ENABLED)
    bios_video_scan_option_roms ();

  bios_video_set_default_attribute (BIOS_CFG_VIDEO_ATTRIBUTE);
}

void
bios_video_putc (char ch)
{
#if BIOS_CFG_TRACE_VIDEO_COM1
  bios_serial_debug_putc (ch);
#endif
  bios_video_hw_teletype ((u8) ch, bios_video_current_page (),
			  bios_video_default_attribute ());
}

void
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
  static const char hex[] = "0123456789ABCDEF";

  bios_video_putc (hex[(value >> 4) & 0x0F]);
  bios_video_putc (hex[value & 0x0F]);
}

void
bios_video_put_hex16 (u16 value)
{
  bios_video_put_hex8 (bios_hi (value));
  bios_video_put_hex8 (bios_lo (value));
}

void
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
  static const char hex[] = "0123456789ABCDEF";
  char text[3];

  text[0] = hex[(value >> 4) & 0x0F];
  text[1] = hex[value & 0x0F];
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

void
bios_video_debug_dump_state (const char *tag)
{
#if BIOS_CFG_DEBUG_VIDEO_STATE
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
  bios_video_debug_dump_vector (0x10);
  bios_serial_debug_puts (" 1D=");
  bios_video_debug_dump_vector (0x1D);
  bios_serial_debug_puts (" 1F=");
  bios_video_debug_dump_vector (0x1F);
  bios_serial_debug_puts (" 42=");
  bios_video_debug_dump_vector (0x42);
  bios_serial_debug_puts (" 43=");
  bios_video_debug_dump_vector (0x43);
  bios_serial_debug_puts ("\n");
#else
  (void) tag;
#endif
}

/*
 * INT 10h stub.  The Paradise PEGA1A video ROM at C000h provides the
 * real INT 10h handler and takes over the vector during its init.
 * This stub is installed into the IVT as a placeholder but is never
 * called at runtime once the PEGA ROM is active.
 */
void
bios_service_int10 (bios_regs_t __far *regs)
{
  (void) regs;
}
