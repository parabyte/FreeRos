#include "bios.h"

#define BIOS_OPTION_ROM_SIGNATURE 0xAA55

static const u8 bios_video_crtc_40col[16] = {
  0x38, 0x28, 0x2D, 0x0A, 0x1F, 0x06, 0x19, 0x1C,
  0x02, 0x07, 0x06, 0x07, 0x00, 0x00, 0x00, 0x00
};

static const u8 bios_video_crtc_80col[16] = {
  0x71, 0x50, 0x5A, 0x0A, 0x1F, 0x06, 0x19, 0x1C,
  0x02, 0x07, 0x06, 0x07, 0x00, 0x00, 0x00, 0x00
};

static u8 bios_video_current_mode (void);
static u8 bios_video_current_columns (void);
static u16 bios_video_current_page_size (void);
static int bios_video_mode_supported (u8 mode);
static int bios_video_mode_is_mono (u8 mode);
static int bios_video_pc1640_external_adapter_selected (void);
static u16 bios_video_vector_segment (u8 intno);

static int
bios_video_rom_int10_active (void)
{
  u16 segment;

  segment = bios_video_vector_segment (0x10);
  return segment != 0x0000 && segment != BIOS_ROM_SEGMENT;
}

static u8
bios_video_canonical_mode (u8 mode)
{
  switch (mode)
    {
    case BIOS_CFG_VIDEO_MODE_PC1640_COLOR:
      return VIDEO_MODE_80X25_COLOR;

    case BIOS_CFG_VIDEO_MODE_PC1640_MONO:
      return VIDEO_MODE_80X25_MONO;

    default:
      return mode;
    }
}

static void
bios_video_pc1640_select_engine (u8 mode)
{
  (void) mode;
}

static int
bios_video_option_rom_present (u16 segment)
{
  return bios_abs_read16 (segment, 0x0000) == BIOS_OPTION_ROM_SIGNATURE
         && bios_abs_read8 (segment, 0x0002) != 0x00;
}

static void
bios_video_enter_option_rom (u16 segment)
{
  asm volatile ("push %%bp\n\t"
                "push %%ds\n\t"
                "push %%es\n\t"
                "mov %0, %%dx\n\t"
                "mov %%dx, %%ds\n\t"
                "mov $0x0040, %%ax\n\t"
                "mov %%ax, %%es\n\t"
                "push %%cs\n\t"
                "mov $1f, %%bx\n\t"
                "push %%bx\n\t"
                "push %%dx\n\t"
                "mov $0x0003, %%bx\n\t"
                "push %%bx\n\t"
                "retf\n\t"
                "1:\n\t"
                "pop %%es\n\t"
                "pop %%ds\n\t"
                "pop %%bp"
                :
                : "rm" (segment)
                : "ax", "bx", "cx", "dx", "si", "di", "memory", "cc");
}

static int
bios_video_option_rom_checksum_valid (u16 segment)
{
  u8 blocks;
  u8 sum;
  u16 block;
  u16 offset;

  blocks = bios_abs_read8 (segment, 0x0002);
  if (blocks == 0)
    return 0;

  sum = 0;
  for (block = 0; block < blocks; ++block)
    {
      u16 block_segment;

      block_segment = (u16) (segment + (block << 5));
      for (offset = 0; offset != 0x0200; ++offset)
        sum = (u8) (sum + bios_abs_read8 (block_segment, offset));
    }

  return sum == 0;
}

static int
bios_video_scan_option_roms (void)
{
  u16 segment;
  int option_rom_called;

  segment = BIOS_CFG_VIDEO_OPTION_ROM_SCAN_START;
  option_rom_called = 0;

  while (segment < BIOS_CFG_VIDEO_OPTION_ROM_SCAN_END)
    {
      u16 next_segment;

      next_segment = (u16) (segment + BIOS_CFG_VIDEO_OPTION_ROM_SCAN_STEP);

      if (bios_video_option_rom_present (segment))
        {
          u8 blocks;

          blocks = bios_abs_read8 (segment, 0x0002);
          next_segment = (u16) (segment + ((u16) blocks << 5));

          if (bios_video_option_rom_checksum_valid (segment))
            {
              bios_serial_debug_puts ("VIDEO rom scan ok\n");
              bios_video_enter_option_rom (segment);
              option_rom_called = 1;
            }
          else
            bios_serial_debug_puts ("VIDEO rom checksum bad\n");
        }

      if (next_segment <= segment)
        break;

      segment = next_segment;
    }

  return option_rom_called;
}

static void
bios_video_hw_set_mode (u8 mode)
{
  u16 ax;

  bios_video_pc1640_select_engine (mode);
  ax = mode;
  asm volatile ("push %%bp\n\t"
                "push %%ds\n\t"
                "push %%es\n\t"
                "int $0x10\n\t"
                "pop %%es\n\t"
                "pop %%ds\n\t"
                "pop %%bp"
                :
                : "a" (ax)
                : "bx", "cx", "dx", "si", "di", "memory", "cc");
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
                "pop %%bp"
                :
                : "a" (ax), "b" (bx)
                : "cx", "dx", "si", "di", "memory", "cc");
}

static int
bios_video_hw_get_mode (u8 *mode, u8 *columns, u8 *page)
{
  u16 ax;
  u16 bx;

  if (!BIOS_CFG_VIDEO_QUERY_ROM_STATE
      || bios_video_vector_segment (0x10) == BIOS_ROM_SEGMENT)
    return 0;

  ax = 0x0F00;
  bx = 0x0000;
  asm volatile ("push %%bp\n\t"
                "push %%ds\n\t"
                "push %%es\n\t"
                "int $0x10\n\t"
                "pop %%es\n\t"
                "pop %%ds\n\t"
                "pop %%bp"
                : "+a" (ax), "+b" (bx)
                :
                : "cx", "dx", "si", "di", "memory", "cc");

  *mode = bios_lo (ax);
  *columns = bios_hi (ax);
  *page = bios_hi (bx);
  return bios_video_mode_supported (*mode);
}

static int
bios_video_mode_supported (u8 mode)
{
  switch (bios_video_canonical_mode (mode))
    {
    case VIDEO_MODE_40X25_BW:
    case VIDEO_MODE_40X25_COLOR:
    case VIDEO_MODE_80X25_BW:
    case VIDEO_MODE_80X25_COLOR:
    case VIDEO_MODE_320X200_COLOR:
    case VIDEO_MODE_320X200_BW:
    case VIDEO_MODE_640X200_BW:
    case VIDEO_MODE_80X25_MONO:
      return 1;

    default:
      return 0;
    }
}

static int
bios_video_mode_is_text (u8 mode)
{
  mode = bios_video_canonical_mode (mode);
  return mode <= VIDEO_MODE_80X25_COLOR || mode == VIDEO_MODE_80X25_MONO;
}

static int
bios_video_mode_is_mono (u8 mode)
{
  mode = bios_video_canonical_mode (mode);
  return mode == VIDEO_MODE_80X25_MONO;
}

static u8
bios_video_columns_for_mode (u8 mode)
{
  switch (bios_video_canonical_mode (mode))
    {
    case VIDEO_MODE_40X25_BW:
    case VIDEO_MODE_40X25_COLOR:
    case VIDEO_MODE_320X200_COLOR:
    case VIDEO_MODE_320X200_BW:
      return 40;

    default:
      return 80;
    }
}

static u8
bios_video_page_count_for_mode (u8 mode)
{
  switch (bios_video_canonical_mode (mode))
    {
    case VIDEO_MODE_40X25_BW:
    case VIDEO_MODE_40X25_COLOR:
      return BIOS_CFG_VIDEO_40COL_PAGES;

    case VIDEO_MODE_80X25_BW:
    case VIDEO_MODE_80X25_COLOR:
      return BIOS_CFG_VIDEO_COLOR_PAGES;

    case VIDEO_MODE_80X25_MONO:
      return BIOS_CFG_VIDEO_MONO_PAGES;

    default:
      return 1;
    }
}

static u16
bios_video_page_size_for_mode (u8 mode)
{
  switch (bios_video_canonical_mode (mode))
    {
    case VIDEO_MODE_40X25_BW:
    case VIDEO_MODE_40X25_COLOR:
      return 0x0800;

    case VIDEO_MODE_80X25_BW:
    case VIDEO_MODE_80X25_COLOR:
    case VIDEO_MODE_80X25_MONO:
      return 0x1000;

    default:
      return 0x2000;
    }
}

static u16
bios_video_segment_for_mode (u8 mode)
{
  if (bios_video_mode_is_mono (mode))
    return BIOS_VIDEO_MONO_SEGMENT;

  return BIOS_VIDEO_COLOR_SEGMENT;
}

static u16
bios_video_crtc_port_for_mode (u8 mode)
{
  if (bios_video_mode_is_mono (mode))
    return 0x03B4;

  return BIOS_CFG_VIDEO_CRTC_PORT;
}

static u16
bios_video_mode_control_port_for_mode (u8 mode)
{
  if (bios_video_mode_is_mono (mode))
    return 0x03B8;

  return 0x03D8;
}

static u8
bios_video_mode_control_value (u8 mode)
{
  switch (bios_video_canonical_mode (mode))
    {
    case VIDEO_MODE_40X25_BW:
    case VIDEO_MODE_40X25_COLOR:
      return 0x28;

    case VIDEO_MODE_80X25_MONO:
      return 0x2D;

    default:
      return 0x29;
    }
}

static const u8 *
bios_video_crtc_table_for_mode (u8 mode)
{
  switch (bios_video_canonical_mode (mode))
    {
    case VIDEO_MODE_40X25_BW:
    case VIDEO_MODE_40X25_COLOR:
      return bios_video_crtc_40col;

    default:
      return bios_video_crtc_80col;
    }
}

static u8
bios_video_equipment_bits_for_mode (u8 mode)
{
  switch (bios_video_canonical_mode (mode))
    {
    case VIDEO_MODE_40X25_BW:
    case VIDEO_MODE_40X25_COLOR:
      return BIOS_CFG_VIDEO_EQUIPMENT_40X25_COLOR;

    case VIDEO_MODE_80X25_MONO:
      return BIOS_CFG_VIDEO_EQUIPMENT_MONO;

    case VIDEO_MODE_80X25_BW:
    case VIDEO_MODE_80X25_COLOR:
    case BIOS_CFG_VIDEO_MODE_PC1640_COLOR:
      return BIOS_CFG_VIDEO_EQUIPMENT_80X25_COLOR;

    default:
      return BIOS_CFG_VIDEO_EQUIPMENT;
    }
}

static void
bios_video_update_equipment_word (u8 mode)
{
  u16 equipment;

  equipment = bios_bda_read16 (BDA_EQUIPMENT_WORD);
  equipment &= (u16) ~(0x0003U << 4);
  equipment |= (u16) ((bios_video_equipment_bits_for_mode (mode) & 0x03U) << 4);
  bios_bda_write16 (BDA_EQUIPMENT_WORD, equipment);
}

static void
bios_video_program_crtc (u16 port, const u8 *table)
{
  u8 reg;

  for (reg = 0; reg != 16; ++reg)
    {
      bios_hw_out8 (reg, port);
      bios_hw_out8 (table[reg], (u16) (port + 1));
    }
}

static void
bios_video_program_text_hardware (u8 mode)
{
  u16 crtc_port;
  u16 mode_port;

  if (!BIOS_CFG_VIDEO_DIRECT_TEXT_INIT || !bios_video_mode_is_text (mode))
    return;

  bios_video_pc1640_select_engine (mode);
  crtc_port = bios_video_crtc_port_for_mode (mode);
  mode_port = bios_video_mode_control_port_for_mode (mode);
  bios_video_program_crtc (crtc_port, bios_video_crtc_table_for_mode (mode));
  bios_hw_out8 (bios_video_mode_control_value (mode), mode_port);
  if (!bios_video_mode_is_mono (mode))
    bios_hw_out8 (0x30, (u16) (mode_port + 1));
}

static int
bios_video_text_state_usable (u8 mode)
{
  if (!bios_video_mode_is_text (mode))
    return 0;

  return bios_video_current_columns () != 0
         && bios_video_current_page_size () != 0
         && bios_bda_read16 (BDA_CRTC_PORT) != 0;
}

static void
bios_video_debug_serial_hex16 (u16 value)
{
  bios_serial_debug_put_hex8 (bios_hi (value));
  bios_serial_debug_put_hex8 (bios_lo (value));
}

static void
bios_video_debug_put_hex16 (u16 value)
{
  bios_video_put_hex8 (bios_hi (value));
  bios_video_put_hex8 (bios_lo (value));
}

static u16
bios_video_vector_offset (u8 intno)
{
  return bios_abs_read16 (0x0000, (u16) intno * 4U);
}

static u16
bios_video_vector_segment (u8 intno)
{
  return bios_abs_read16 (0x0000, (u16) intno * 4U + 2U);
}

static u8
bios_video_read_crtc_register (u16 port, u8 reg)
{
  bios_hw_out8 (reg, port);
  return bios_hw_in8 ((u16) (port + 1));
}

static u8
bios_video_current_mode (void)
{
  return bios_bda_read8 (BDA_VIDEO_MODE);
}

static u16
bios_video_current_segment (void)
{
  return bios_video_segment_for_mode (bios_video_current_mode ());
}

static u8
bios_video_current_columns (void)
{
  return (u8) bios_bda_read16 (BDA_VIDEO_COLUMNS);
}

static u16
bios_video_current_page_size (void)
{
  return bios_bda_read16 (BDA_VIDEO_PAGE_SIZE);
}

static u8
bios_video_current_page (void)
{
  return bios_bda_read8 (BDA_ACTIVE_PAGE);
}

static u8
bios_video_rows (void)
{
  return BIOS_CFG_VIDEO_ROWS;
}

static u8
bios_video_page_count (void)
{
  return bios_video_page_count_for_mode (bios_video_current_mode ());
}

static u8
bios_video_sanitize_page (u8 page)
{
  if (page >= bios_video_page_count ())
    return bios_video_current_page ();

  return page;
}

static u16
bios_video_cursor_offset (u8 page)
{
  return (u16) (BDA_CURSOR_POSITIONS + ((u16) page * 2));
}

static u16
bios_video_offset_for_cell (u8 page, u16 row, u16 col)
{
  return (u16) ((u16) page * bios_video_current_page_size ()
                + ((row * bios_video_current_columns ()) + col) * 2);
}

static u8
bios_video_default_attribute (void)
{
  return bios_work_read8 (WK_VIDEO_ATTRIBUTE);
}

static void
bios_video_set_default_attribute (u8 attr)
{
  bios_work_write8 (WK_VIDEO_ATTRIBUTE, attr);
}

static void
bios_video_get_cursor_for_page (u8 page, u8 *row, u8 *col)
{
  u16 pos;

  pos = bios_bda_read16 (bios_video_cursor_offset (page));
  *row = bios_hi (pos);
  *col = bios_lo (pos);
}

static void
bios_video_set_cursor_for_page (u8 page, u8 row, u8 col)
{
  bios_bda_write16 (bios_video_cursor_offset (page),
                    (u16) row << 8 | col);
}

static void
bios_video_program_cursor_for_page (u8 page)
{
  u16 crtc_port;
  u16 address;
  u8 row;
  u8 col;

  if (!bios_video_text_state_usable (bios_video_current_mode ())
      || page != bios_video_current_page ())
    return;

  crtc_port = bios_bda_read16 (BDA_CRTC_PORT);
  bios_video_get_cursor_for_page (page, &row, &col);
  address = (u16) (page * bios_video_current_page_size () / 2
                   + (u16) row * bios_video_current_columns ()
                   + col);

  bios_hw_out8 (0x0E, crtc_port);
  bios_hw_out8 (bios_hi (address), (u16) (crtc_port + 1));
  bios_hw_out8 (0x0F, crtc_port);
  bios_hw_out8 (bios_lo (address), (u16) (crtc_port + 1));
}

static void
bios_video_program_display_start (void)
{
  u16 crtc_port;
  u16 address;

  if (!bios_video_text_state_usable (bios_video_current_mode ()))
    return;

  crtc_port = bios_bda_read16 (BDA_CRTC_PORT);
  address = (u16) (bios_bda_read16 (BDA_VIDEO_PAGE_OFFSET) / 2U);

  bios_hw_out8 (0x0C, crtc_port);
  bios_hw_out8 (bios_hi (address), (u16) (crtc_port + 1));
  bios_hw_out8 (0x0D, crtc_port);
  bios_hw_out8 (bios_lo (address), (u16) (crtc_port + 1));
}

static void
bios_video_get_cursor (u8 *row, u8 *col)
{
  bios_video_get_cursor_for_page (bios_video_current_page (), row, col);
}

static void
bios_video_set_cursor (u8 row, u8 col)
{
  bios_video_set_cursor_for_page (bios_video_current_page (), row, col);
  bios_video_program_cursor_for_page (bios_video_current_page ());
}

static void
bios_video_read_cell (u8 page, u8 row, u8 col, u8 *ch, u8 *attr)
{
  u16 value;

  value = bios_abs_read16 (bios_video_current_segment (),
                           bios_video_offset_for_cell (page, row, col));
  *ch = bios_lo (value);
  *attr = bios_hi (value);
}

static void
bios_video_write_cell (u8 page, u8 row, u8 col, u8 ch, u8 attr)
{
  bios_abs_write16 (bios_video_current_segment (),
                    bios_video_offset_for_cell (page, row, col),
                    (u16) ch | ((u16) attr << 8));
}

static void
bios_video_clear_page (u8 page, u8 attr)
{
  u16 cells;

  cells = (u16) bios_video_current_page_size () / 2;
  bios_mem_fill16 (bios_video_current_segment (),
                   (u16) page * bios_video_current_page_size (),
                   (u16) ' ' | ((u16) attr << 8), cells);
}

static void
bios_video_clear_graphics (u8 mode)
{
  u16 words;

  words = (u16) ((u16) bios_video_page_count_for_mode (mode)
                 * bios_video_page_size_for_mode (mode) / 2);
  bios_mem_fill16 (bios_video_segment_for_mode (mode), 0, 0x0000, words);
}

static void
bios_video_clear_text_pages (u8 mode, u8 attr)
{
  u8 page;

  for (page = 0; page < bios_video_page_count_for_mode (mode); ++page)
    bios_video_clear_page (page, attr);
}

static void
bios_video_select_active_page (u8 page)
{
  page = bios_video_sanitize_page (page);
  bios_bda_write8 (BDA_ACTIVE_PAGE, page);
  bios_bda_write16 (BDA_VIDEO_PAGE_OFFSET,
                    (u16) page * bios_video_current_page_size ());
  bios_video_program_display_start ();
  bios_video_program_cursor_for_page (page);
}

static void
bios_video_normalize_window (u8 *top, u8 *left, u8 *bottom, u8 *right)
{
  if (*bottom >= bios_video_rows ())
    *bottom = (u8) (bios_video_rows () - 1);

  if (*right >= bios_video_current_columns ())
    *right = (u8) (bios_video_current_columns () - 1);
}

static void
bios_video_fill_window (u8 page, u8 top, u8 left, u8 bottom, u8 right, u8 attr)
{
  u16 row;
  u16 col;

  for (row = top; row <= bottom; ++row)
    for (col = left; col <= right; ++col)
      bios_video_write_cell (page, (u8) row, (u8) col, ' ', attr);
}

static void
bios_video_scroll_window (u8 page, u8 top, u8 left, u8 bottom, u8 right,
                          u8 lines, int scroll_up, u8 attr)
{
  int row;
  u16 col;
  u8 ch;
  u8 cell_attr;

  bios_video_normalize_window (&top, &left, &bottom, &right);
  if (top > bottom || left > right)
    return;

  if (lines == 0 || lines > (u8) (bottom - top + 1))
    {
      bios_video_fill_window (page, top, left, bottom, right, attr);
      return;
    }

  if (scroll_up)
    {
      for (row = top; row <= (int) bottom - lines; ++row)
        for (col = left; col <= right; ++col)
          {
            bios_video_read_cell (page, (u8) (row + lines), (u8) col,
                                  &ch, &cell_attr);
            bios_video_write_cell (page, (u8) row, (u8) col, ch, cell_attr);
          }

      for (; row <= bottom; ++row)
        for (col = left; col <= right; ++col)
          bios_video_write_cell (page, (u8) row, (u8) col, ' ', attr);
    }
  else
    {
      for (row = bottom; row >= (int) top + lines; --row)
        for (col = left; col <= right; ++col)
          {
            bios_video_read_cell (page, (u8) (row - lines), (u8) col,
                                  &ch, &cell_attr);
            bios_video_write_cell (page, (u8) row, (u8) col, ch, cell_attr);
          }

      for (row = top; row < (int) top + lines; ++row)
        for (col = left; col <= right; ++col)
          bios_video_write_cell (page, (u8) row, (u8) col, ' ', attr);
    }
}

static void
bios_video_newline_on_page (u8 page)
{
  u8 row;
  u8 col;

  bios_video_get_cursor_for_page (page, &row, &col);
  row++;
  col = 0;
  if (row >= bios_video_rows ())
    {
      bios_video_scroll_window (page, 0, 0,
                                (u8) (bios_video_rows () - 1),
                                (u8) (bios_video_current_columns () - 1),
                                1, 1, bios_video_default_attribute ());
      row = (u8) (bios_video_rows () - 1);
    }

  bios_video_set_cursor_for_page (page, row, col);
}

static void
bios_video_teletype_on_page (u8 page, u8 ch, u8 attr)
{
  u8 row;
  u8 col;

  bios_video_get_cursor_for_page (page, &row, &col);
  if (ch == '\r')
    {
      bios_video_set_cursor_for_page (page, row, 0);
      return;
    }

  if (ch == '\n')
    {
      bios_video_newline_on_page (page);
      bios_video_program_cursor_for_page (page);
      return;
    }

  if (ch == '\b')
    {
      if (col != 0)
        col--;
      bios_video_set_cursor_for_page (page, row, col);
      bios_video_program_cursor_for_page (page);
      return;
    }

  if (ch == '\a')
    {
      bios_beep_ticks (1);
      return;
    }

  bios_video_write_cell (page, row, col, ch, attr);
  col++;
  if (col >= bios_video_current_columns ())
    {
      col = 0;
      row++;
      if (row >= bios_video_rows ())
        {
          bios_video_scroll_window (page, 0, 0,
                                    (u8) (bios_video_rows () - 1),
                                    (u8) (bios_video_current_columns () - 1),
                                    1, 1, attr);
          row = (u8) (bios_video_rows () - 1);
        }
    }

  bios_video_set_cursor_for_page (page, row, col);
  bios_video_program_cursor_for_page (page);
}

static void
bios_video_write_char_repeat (u8 page, u8 ch, u8 attr, u16 count,
                              int write_attribute)
{
  u8 row;
  u8 col;
  u8 old_ch;
  u8 old_attr;
  u16 i;

  bios_video_get_cursor_for_page (page, &row, &col);
  for (i = 0; i < count; ++i)
    {
      if (write_attribute)
        bios_video_write_cell (page, row, col, ch, attr);
      else
        {
          bios_video_read_cell (page, row, col, &old_ch, &old_attr);
          bios_video_write_cell (page, row, col, ch, old_attr);
        }

      col++;
      if (col >= bios_video_current_columns ())
        {
          col = 0;
          row++;
          if (row >= bios_video_rows ())
            {
              bios_video_scroll_window (page, 0, 0,
                                        (u8) (bios_video_rows () - 1),
                                        (u8) (bios_video_current_columns () - 1),
                                        1, 1, attr);
              row = (u8) (bios_video_rows () - 1);
            }
        }
    }
}

static int
bios_video_graphics_address (u8 mode, u16 x, u16 y, u16 *offset, u8 *shift,
                             u8 *mask)
{
  mode = bios_video_canonical_mode (mode);
  if (mode == VIDEO_MODE_320X200_COLOR || mode == VIDEO_MODE_320X200_BW)
    {
      if (x >= 320 || y >= 200)
        return 0;

      *offset = (u16) ((y & 1U) * 0x2000U + (y >> 1) * 80U + (x >> 2));
      *shift = (u8) (6 - ((x & 3U) * 2U));
      *mask = (u8) (0x03U << *shift);
      return 1;
    }

  if (mode == VIDEO_MODE_640X200_BW)
    {
      if (x >= 640 || y >= 200)
        return 0;

      *offset = (u16) ((y & 1U) * 0x2000U + (y >> 1) * 80U + (x >> 3));
      *shift = (u8) (7 - (x & 7U));
      *mask = (u8) (0x01U << *shift);
      return 1;
    }

  return 0;
}

static int
bios_video_write_pixel (u8 mode, u16 x, u16 y, u8 color)
{
  u16 offset;
  u8 shift;
  u8 mask;
  u8 value;
  u8 pixel_bits;

  if (!bios_video_graphics_address (mode, x, y, &offset, &shift, &mask))
    return 0;

  value = bios_abs_read8 (bios_video_current_segment (), offset);
  if (mode == VIDEO_MODE_640X200_BW)
    pixel_bits = (u8) ((color & 0x01) << shift);
  else
    pixel_bits = (u8) ((color & 0x03) << shift);

  if ((color & 0x80) != 0)
    value ^= pixel_bits;
  else
    {
      value &= (u8) ~mask;
      value |= pixel_bits;
    }

  bios_abs_write8 (bios_video_current_segment (), offset, value);
  return 1;
}

static int
bios_video_read_pixel (u8 mode, u16 x, u16 y, u8 *color)
{
  u16 offset;
  u8 shift;
  u8 mask;
  u8 value;

  if (!bios_video_graphics_address (mode, x, y, &offset, &shift, &mask))
    return 0;

  value = bios_abs_read8 (bios_video_current_segment (), offset);
  if (mode == VIDEO_MODE_640X200_BW)
    *color = (u8) ((value & mask) >> shift);
  else
    *color = (u8) ((value & mask) >> shift);

  return 1;
}

static void
bios_video_set_mode (u8 mode)
{
  u8 canonical_mode;
  u8 page;
  u8 attr;

  canonical_mode = bios_video_canonical_mode (mode);
  attr = BIOS_CFG_VIDEO_ATTRIBUTE;
  bios_video_pc1640_select_engine (canonical_mode);
  bios_bda_write8 (BDA_VIDEO_MODE, mode);
  bios_bda_write16 (BDA_VIDEO_COLUMNS, bios_video_columns_for_mode (canonical_mode));
  bios_bda_write16 (BDA_VIDEO_PAGE_SIZE, bios_video_page_size_for_mode (canonical_mode));
  bios_bda_write16 (BDA_VIDEO_PAGE_OFFSET, 0x0000);
  bios_bda_write8 (BDA_ACTIVE_PAGE, 0x00);
  bios_bda_write8 (BDA_VIDEO_MISC,
                   bios_video_mode_is_mono (canonical_mode) ? 0x2D : 0x29);
  bios_bda_write8 (BDA_VIDEO_PALETTE, 0x30);
  bios_bda_write16 (BDA_CRTC_PORT, bios_video_crtc_port_for_mode (canonical_mode));
  bios_bda_write16 (BDA_CURSOR_TYPE, 0x0607);
  bios_video_update_equipment_word (canonical_mode);
  bios_video_set_default_attribute (attr);

  for (page = 0; page < bios_video_page_count_for_mode (canonical_mode); ++page)
    bios_video_set_cursor_for_page (page, 0, 0);

  if (bios_video_mode_is_text (canonical_mode))
    {
      bios_video_program_text_hardware (canonical_mode);
      bios_video_clear_text_pages (canonical_mode, attr);
    }
  else
    bios_video_clear_graphics (canonical_mode);

  bios_bda_write8 (BDA_VIDEO_ROWS_MINUS_ONE, (u8) (bios_video_rows () - 1));
  bios_bda_write16 (BDA_VIDEO_CHAR_HEIGHT, 0x000E);
  bios_bda_write8 (BDA_VIDEO_CONTROL_FLAGS,
                   bios_video_mode_is_mono (canonical_mode) ? 0x66 : 0x64);
  bios_bda_write8 (BDA_VIDEO_SWITCHES, bios_build_video_switches ());
  bios_video_program_cursor_for_page (0);
}

static u8
bios_video_mode_from_equipment_word (void)
{
  switch ((bios_bda_read16 (BDA_EQUIPMENT_WORD) >> 4) & 0x03U)
    {
    case BIOS_CFG_VIDEO_EQUIPMENT_MONO:
      return VIDEO_MODE_80X25_MONO;

    case BIOS_CFG_VIDEO_EQUIPMENT_40X25_COLOR:
      return VIDEO_MODE_40X25_COLOR;

    case BIOS_CFG_VIDEO_EQUIPMENT_80X25_COLOR:
    case BIOS_CFG_VIDEO_EQUIPMENT_EGA_VGA:
    default:
      return VIDEO_MODE_80X25_COLOR;
    }
}

static u8
bios_video_pc1640_switch_control_read (void)
{
  u8 control;

  if (!BIOS_CFG_VIDEO_USE_PC1640_SWITCH_BLOCK)
    return 0;

  (void) bios_hw_in8 (PORT_PC1640_SWITCH_LATCH);
  control = bios_hw_in8 (PORT_LPT1_CONTROL);
  return control;
}

static int
bios_video_pc1640_external_adapter_selected (void)
{
  return (bios_video_pc1640_switch_control_read ()
          & LPT1_CONTROL_SWITCH_SW10) != 0;
}

static u8
bios_video_mode_from_switch_block (void)
{
  if (!BIOS_CFG_VIDEO_FIXUP_FROM_SWITCH_BLOCK)
    return 0xFF;

  return bios_default_text_mode ();
}

static void
bios_video_seed_text_state (u8 mode)
{
  u8 canonical_mode;
  u8 page;
  u8 page_count;

  canonical_mode = bios_video_canonical_mode (mode);
  bios_bda_write8 (BDA_VIDEO_MODE, mode);

  if (bios_bda_read16 (BDA_VIDEO_COLUMNS) == 0)
    bios_bda_write16 (BDA_VIDEO_COLUMNS,
                      bios_video_columns_for_mode (canonical_mode));

  if (bios_bda_read16 (BDA_VIDEO_PAGE_SIZE) == 0)
    bios_bda_write16 (BDA_VIDEO_PAGE_SIZE,
                      bios_video_page_size_for_mode (canonical_mode));

  if (bios_bda_read16 (BDA_CRTC_PORT) == 0)
    bios_bda_write16 (BDA_CRTC_PORT,
                      bios_video_crtc_port_for_mode (canonical_mode));
  else if (bios_video_mode_is_mono (canonical_mode))
    bios_bda_write16 (BDA_CRTC_PORT, 0x03B4);
  else
    bios_bda_write16 (BDA_CRTC_PORT, BIOS_CFG_VIDEO_CRTC_PORT);

  if (bios_bda_read8 (BDA_ACTIVE_PAGE)
      >= bios_video_page_count_for_mode (canonical_mode))
    bios_bda_write8 (BDA_ACTIVE_PAGE, 0x00);

  if (bios_bda_read8 (BDA_VIDEO_MISC) == 0)
    bios_bda_write8 (BDA_VIDEO_MISC,
                     bios_video_mode_is_mono (canonical_mode) ? 0x2D : 0x29);
  else if (bios_video_mode_is_mono (canonical_mode))
    bios_bda_write8 (BDA_VIDEO_MISC, 0x2D);
  else
    bios_bda_write8 (BDA_VIDEO_MISC, 0x29);

  if (bios_bda_read8 (BDA_VIDEO_PALETTE) == 0)
    bios_bda_write8 (BDA_VIDEO_PALETTE, 0x30);

  if (bios_bda_read8 (BDA_VIDEO_ROWS_MINUS_ONE) == 0)
    bios_bda_write8 (BDA_VIDEO_ROWS_MINUS_ONE, (u8) (bios_video_rows () - 1));

  if (bios_bda_read16 (BDA_VIDEO_CHAR_HEIGHT) == 0)
    bios_bda_write16 (BDA_VIDEO_CHAR_HEIGHT, 0x000E);

  if (bios_bda_read8 (BDA_VIDEO_CONTROL_FLAGS) == 0)
    bios_bda_write8 (BDA_VIDEO_CONTROL_FLAGS,
                     bios_video_mode_is_mono (canonical_mode) ? 0x66 : 0x64);

  if (bios_bda_read8 (BDA_VIDEO_SWITCHES) == 0)
    bios_bda_write8 (BDA_VIDEO_SWITCHES, bios_build_video_switches ());

  page_count = bios_video_page_count_for_mode (canonical_mode);
  for (page = 0; page < page_count; ++page)
    {
      u8 row;
      u8 col;

      bios_video_get_cursor_for_page (page, &row, &col);
      if (row >= bios_video_rows ()
          || col >= bios_video_columns_for_mode (canonical_mode))
        bios_video_set_cursor_for_page (page, 0, 0);
    }

  bios_video_select_active_page (bios_bda_read8 (BDA_ACTIVE_PAGE));
}

static void
bios_video_normalize_post_rom_state (void)
{
  u8 mode;
  u8 rom_mode;
  u8 rom_columns;
  u8 rom_page;
  u8 switch_mode;

  mode = bios_video_current_mode ();
  rom_mode = 0;
  rom_columns = 0;
  rom_page = 0;

  if (bios_video_hw_get_mode (&rom_mode, &rom_columns, &rom_page))
    {
      mode = rom_mode;
      if (rom_columns != 0)
        bios_bda_write16 (BDA_VIDEO_COLUMNS, rom_columns);
      bios_bda_write8 (BDA_ACTIVE_PAGE, rom_page);
    }

  switch_mode = bios_video_mode_from_switch_block ();
  if (switch_mode != 0xFF)
    {
      if (!bios_video_mode_supported (mode)
          || (bios_video_mode_is_mono (mode)
              != bios_video_mode_is_mono (switch_mode))
          || (bios_video_columns_for_mode (switch_mode) == 40
              && bios_video_columns_for_mode (mode) != 40))
        mode = switch_mode;
    }

  if (!bios_video_mode_supported (mode)
      || (mode == VIDEO_MODE_40X25_BW
          && bios_bda_read16 (BDA_VIDEO_COLUMNS) == 0))
    mode = bios_video_mode_from_equipment_word ();

  bios_video_seed_text_state (mode);
}

static void
bios_video_debug_dump_serial (const char *tag)
{
  u16 crtc_port;

  crtc_port = bios_bda_read16 (BDA_CRTC_PORT);
  bios_serial_debug_puts ("VIDEO ");
  bios_serial_debug_puts (tag);
  bios_serial_debug_puts ("\n");

  bios_serial_debug_puts (" BDA M=");
  bios_serial_debug_put_hex8 (bios_bda_read8 (BDA_VIDEO_MODE));
  bios_serial_debug_puts (" COLS=");
  bios_video_debug_serial_hex16 (bios_bda_read16 (BDA_VIDEO_COLUMNS));
  bios_serial_debug_puts (" PSZ=");
  bios_video_debug_serial_hex16 (bios_bda_read16 (BDA_VIDEO_PAGE_SIZE));
  bios_serial_debug_puts (" POFS=");
  bios_video_debug_serial_hex16 (bios_bda_read16 (BDA_VIDEO_PAGE_OFFSET));
  bios_serial_debug_puts (" AP=");
  bios_serial_debug_put_hex8 (bios_bda_read8 (BDA_ACTIVE_PAGE));
  bios_serial_debug_puts (" CRTC=");
  bios_video_debug_serial_hex16 (crtc_port);
  bios_serial_debug_puts ("\n");

  bios_serial_debug_puts (" BDA ROWM1=");
  bios_serial_debug_put_hex8 (bios_bda_read8 (BDA_VIDEO_ROWS_MINUS_ONE));
  bios_serial_debug_puts (" CHR=");
  bios_video_debug_serial_hex16 (bios_bda_read16 (BDA_VIDEO_CHAR_HEIGHT));
  bios_serial_debug_puts (" FLG=");
  bios_serial_debug_put_hex8 (bios_bda_read8 (BDA_VIDEO_CONTROL_FLAGS));
  bios_serial_debug_puts (" SWT=");
  bios_serial_debug_put_hex8 (bios_bda_read8 (BDA_VIDEO_SWITCHES));
  bios_serial_debug_puts (" PCL=");
  bios_serial_debug_put_hex8 (bios_video_pc1640_switch_control_read ());
  bios_serial_debug_puts (" MISC=");
  bios_serial_debug_put_hex8 (bios_bda_read8 (BDA_VIDEO_MISC));
  bios_serial_debug_puts (" PAL=");
  bios_serial_debug_put_hex8 (bios_bda_read8 (BDA_VIDEO_PALETTE));
  bios_serial_debug_puts ("\n");

  bios_serial_debug_puts (" IVT10=");
  bios_video_debug_serial_hex16 (bios_video_vector_segment (0x10));
  bios_serial_debug_puts (":");
  bios_video_debug_serial_hex16 (bios_video_vector_offset (0x10));
  bios_serial_debug_puts (" IVT1D=");
  bios_video_debug_serial_hex16 (bios_video_vector_segment (0x1D));
  bios_serial_debug_puts (":");
  bios_video_debug_serial_hex16 (bios_video_vector_offset (0x1D));
  bios_serial_debug_puts (" IVT42=");
  bios_video_debug_serial_hex16 (bios_video_vector_segment (0x42));
  bios_serial_debug_puts (":");
  bios_video_debug_serial_hex16 (bios_video_vector_offset (0x42));
  bios_serial_debug_puts (" IVT43=");
  bios_video_debug_serial_hex16 (bios_video_vector_segment (0x43));
  bios_serial_debug_puts (":");
  bios_video_debug_serial_hex16 (bios_video_vector_offset (0x43));
  bios_serial_debug_puts ("\n");

  if (crtc_port != 0)
    {
      bios_serial_debug_puts (" HW STA=");
      bios_serial_debug_put_hex8 (bios_video_read_crtc_register (crtc_port, 0x0C));
      bios_serial_debug_put_hex8 (bios_video_read_crtc_register (crtc_port, 0x0D));
      bios_serial_debug_puts (" CUR=");
      bios_serial_debug_put_hex8 (bios_video_read_crtc_register (crtc_port, 0x0E));
      bios_serial_debug_put_hex8 (bios_video_read_crtc_register (crtc_port, 0x0F));
      bios_serial_debug_puts ("\n");
    }
}

static void
bios_video_debug_overlay (const char *tag)
{
  if (!BIOS_CFG_DEBUG_VIDEO_OVERLAY
      || (!bios_video_text_state_usable (bios_video_current_mode ())
          && !bios_video_rom_int10_active ()))
    return;

  bios_video_puts ("DBG ");
  bios_video_puts (tag);
  bios_video_puts (" M=");
  bios_video_put_hex8 (bios_bda_read8 (BDA_VIDEO_MODE));
  bios_video_puts (" C=");
  bios_video_debug_put_hex16 (bios_bda_read16 (BDA_VIDEO_COLUMNS));
  bios_video_puts (" P=");
  bios_video_debug_put_hex16 (bios_bda_read16 (BDA_VIDEO_PAGE_OFFSET));
  bios_video_puts (" V10=");
  bios_video_debug_put_hex16 (bios_video_vector_segment (0x10));
  bios_video_puts (":");
  bios_video_debug_put_hex16 (bios_video_vector_offset (0x10));
  bios_video_puts ("\r\n");

  bios_video_puts ("DBG CRTC=");
  bios_video_debug_put_hex16 (bios_bda_read16 (BDA_CRTC_PORT));
  bios_video_puts (" FLG=");
  bios_video_put_hex8 (bios_bda_read8 (BDA_VIDEO_CONTROL_FLAGS));
  bios_video_puts (" SWT=");
  bios_video_put_hex8 (bios_bda_read8 (BDA_VIDEO_SWITCHES));
  bios_video_puts (" PCL=");
  bios_video_put_hex8 (bios_video_pc1640_switch_control_read ());
  bios_video_puts (" 42=");
  bios_video_debug_put_hex16 (bios_video_vector_segment (0x42));
  bios_video_puts (":");
  bios_video_debug_put_hex16 (bios_video_vector_offset (0x42));
  bios_video_puts ("\r\n");
}

static void
bios_video_debug_dump_state (const char *tag)
{
  if (!BIOS_CFG_DEBUG_VIDEO_STATE)
    return;

  bios_video_debug_dump_serial (tag);
  bios_video_debug_overlay (tag);
}

void
bios_video_init (void)
{
  bios_serial_debug_puts ("VIDEO init start\n");

  if (BIOS_CFG_VIDEO_OPTION_ROM_SCAN_ENABLED && bios_video_scan_option_roms ())
    {
      bios_serial_debug_puts ("VIDEO option rom present\n");
      bios_serial_debug_puts ("VIDEO option rom returned\n");
      bios_video_debug_dump_state ("RAW");
      bios_video_set_default_attribute (BIOS_CFG_VIDEO_ATTRIBUTE);
      bios_serial_debug_puts ("VIDEO attr set\n");
      return;
    }

  bios_serial_debug_puts ("VIDEO option rom absent\n");
  bios_io_write (PORT_SYSSTAT1_WR, bios_build_status1 ());
  if (bios_video_mode_from_switch_block () != 0xFF)
    bios_video_set_mode (bios_video_mode_from_switch_block ());
  else
    bios_video_set_mode (BIOS_CFG_VIDEO_FALLBACK_MODE);
  bios_serial_debug_puts ("VIDEO fallback mode set\n");
}

void
bios_video_putc (char ch)
{
  if (bios_video_rom_int10_active ())
    {
      bios_video_hw_teletype ((u8) ch, bios_video_current_page (),
                              bios_video_default_attribute ());
      return;
    }

  if (bios_video_text_state_usable (bios_video_current_mode ()))
    {
      bios_video_teletype_on_page (bios_video_current_page (), (u8) ch,
                                   bios_video_default_attribute ());
      return;
    }

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
bios_service_int10 (bios_regs_t __far *regs)
{
  u8 mode;
  u8 page;
  u8 row;
  u8 col;
  u8 attr;
  u8 ch;
  u8 top;
  u8 left;
  u8 bottom;
  u8 right;

  switch (bios_hi (regs->ax))
    {
    case 0x00:
      mode = bios_lo (regs->ax);
      if (!bios_video_mode_supported (mode))
        {
          bios_set_cf (regs);
          break;
        }

      bios_video_set_mode (mode);
      bios_clear_cf (regs);
      break;

    case 0x01:
      bios_bda_write16 (BDA_CURSOR_TYPE, regs->cx);
      bios_clear_cf (regs);
      break;

    case 0x02:
      page = bios_video_sanitize_page (bios_hi (regs->bx));
      row = bios_hi (regs->dx);
      col = bios_lo (regs->dx);
      if (row >= bios_video_rows ())
        row = (u8) (bios_video_rows () - 1);
      if (col >= bios_video_current_columns ())
        col = (u8) (bios_video_current_columns () - 1);
      bios_video_set_cursor_for_page (page, row, col);
      bios_clear_cf (regs);
      break;

    case 0x03:
      page = bios_video_sanitize_page (bios_hi (regs->bx));
      bios_video_get_cursor_for_page (page, &row, &col);
      regs->cx = bios_bda_read16 (BDA_CURSOR_TYPE);
      regs->dx = (u16) row << 8 | col;
      bios_clear_cf (regs);
      break;

    case 0x04:
      regs->ax = 0;
      regs->bx = 0;
      regs->cx = 0;
      regs->dx = 0;
      bios_clear_cf (regs);
      break;

    case 0x05:
      bios_video_select_active_page (bios_lo (regs->ax));
      bios_clear_cf (regs);
      break;

    case 0x06:
    case 0x07:
      page = bios_video_current_page ();
      attr = bios_hi (regs->bx);
      top = bios_hi (regs->cx);
      left = bios_lo (regs->cx);
      bottom = bios_hi (regs->dx);
      right = bios_lo (regs->dx);
      bios_video_scroll_window (page, top, left, bottom, right,
                                bios_lo (regs->ax),
                                bios_hi (regs->ax) == 0x06, attr);
      bios_clear_cf (regs);
      break;

    case 0x08:
      if (!bios_video_mode_is_text (bios_video_current_mode ()))
        {
          bios_set_cf (regs);
          break;
        }

      page = bios_video_sanitize_page (bios_hi (regs->bx));
      bios_video_get_cursor_for_page (page, &row, &col);
      bios_video_read_cell (page, row, col, &ch, &attr);
      regs->ax = (u16) attr << 8 | ch;
      bios_clear_cf (regs);
      break;

    case 0x09:
      if (!bios_video_mode_is_text (bios_video_current_mode ()))
        {
          bios_set_cf (regs);
          break;
        }

      page = bios_video_sanitize_page (bios_hi (regs->bx));
      attr = bios_lo (regs->bx);
      bios_video_set_default_attribute (attr);
      bios_video_write_char_repeat (page, bios_lo (regs->ax), attr, regs->cx, 1);
      bios_clear_cf (regs);
      break;

    case 0x0A:
      if (!bios_video_mode_is_text (bios_video_current_mode ()))
        {
          bios_set_cf (regs);
          break;
        }

      page = bios_video_sanitize_page (bios_hi (regs->bx));
      bios_video_write_char_repeat (page, bios_lo (regs->ax),
                                    bios_video_default_attribute (),
                                    regs->cx, 0);
      bios_clear_cf (regs);
      break;

    case 0x0B:
      if (bios_hi (regs->bx) == 0x00)
        bios_bda_write8 (BDA_VIDEO_PALETTE,
                         (u8) ((bios_bda_read8 (BDA_VIDEO_PALETTE) & 0xF0)
                               | (bios_lo (regs->bx) & 0x0F)));
      else if (bios_hi (regs->bx) == 0x01)
        bios_bda_write8 (BDA_VIDEO_MISC,
                         (u8) ((bios_bda_read8 (BDA_VIDEO_MISC) & 0xDF)
                               | ((bios_lo (regs->bx) & 0x01) << 5)));
      bios_clear_cf (regs);
      break;

    case 0x0C:
      mode = bios_video_current_mode ();
      if (bios_video_write_pixel (mode, regs->cx, regs->dx, bios_lo (regs->ax)))
        bios_clear_cf (regs);
      else
        bios_set_cf (regs);
      break;

    case 0x0D:
      mode = bios_video_current_mode ();
      if (bios_video_read_pixel (mode, regs->cx, regs->dx, &attr))
        {
          bios_set_lo (&regs->ax, attr);
          bios_clear_cf (regs);
        }
      else
        bios_set_cf (regs);
      break;

    case 0x0E:
      page = bios_video_sanitize_page (bios_hi (regs->bx));
      attr = bios_lo (regs->bx);
      if (attr == 0)
        attr = bios_video_default_attribute ();
      bios_video_teletype_on_page (page, bios_lo (regs->ax), attr);
      bios_clear_cf (regs);
      break;

    case 0x0F:
      bios_set_hi (&regs->ax, bios_video_current_columns ());
      bios_set_lo (&regs->ax, bios_video_current_mode ());
      bios_set_hi (&regs->bx, bios_video_current_page ());
      bios_clear_cf (regs);
      break;

    default:
      bios_set_cf (regs);
      break;
    }
}
