/* ================================================
 * PC1640 Paradise PEGA in-ROM driver (English font only).
 * Reverse-engineered bring-up from public register-timing references and
 * the extracted PEGA 8x14 font at C000:2E00 in the video-decompiled tree.
 * ================================================ */

#include "bios.h"
#if !BIOS_CFG_VIDEO_PEGA_STANDALONE_ROM
#include "machine.h"
#endif

#if BIOS_CFG_VIDEO_PEGA_INROM_DRIVER

extern void __far bios_int10_wrapper (void);
extern const u8 bios_video_pega_font_en_8x14[128 * 14];

static void pega_write_cell (u8 row, u8 col, u8 ch, u8 attr);

static void
pega_clear_text_vram (u8 attr)
{
  u8 row;
  u8 col;
  u8 rows;
  u8 columns;

  bios_work_write8 (WK_VIDEO_ATTRIBUTE, attr);
  rows = (u8) (bios_bda_read8 (BDA_VIDEO_ROWS_MINUS_ONE) + 1U);
  columns = (u8) bios_bda_read16 (BDA_VIDEO_COLUMNS);
  if (rows == 0 || columns == 0)
    return;

  for (row = 0; row < rows; ++row)
    for (col = 0; col < columns; ++col)
      pega_write_cell (row, col, ' ', attr);
  bios_bda_write16 (BDA_CURSOR_POSITIONS, 0x0000);
}

static void
pega_attr_write (u16 status_port, u8 index, u8 value)
{
  (void) bios_hw_in8 (status_port);
  bios_hw_out8 (index, PORT_VIDEO_ATTR);
  bios_hw_out8 (value, PORT_VIDEO_ATTR);
}

static void
pega_crtc_write_block (u16 crtc_base, const u8 *regs, u8 count)
{
  u8 i;

  for (i = 0; i < count; i++)
    {
      bios_hw_out8 (i, crtc_base);
      bios_hw_out8 (regs[i], (u16) (crtc_base + 1U));
    }
}

static void
pega_load_font (int mono)
{
  u16 ch;
  u16 row;

  bios_hw_out8 (0x02, PORT_VIDEO_SEQU_ADDR);
  bios_hw_out8 (0x04, PORT_VIDEO_SEQU_DATA);
  bios_hw_out8 (0x04, PORT_VIDEO_SEQU_ADDR);
  bios_hw_out8 (0x06, PORT_VIDEO_SEQU_DATA);
  bios_hw_out8 (0x03, PORT_VIDEO_SEQU_ADDR);
  bios_hw_out8 (0x00, PORT_VIDEO_SEQU_DATA);
  bios_hw_out8 (0x05, PORT_VIDEO_GRDC_ADDR);
  bios_hw_out8 (0x10, PORT_VIDEO_GRDC_DATA);
  bios_hw_out8 (0x06, PORT_VIDEO_GRDC_ADDR);
  bios_hw_out8 (0x04, PORT_VIDEO_GRDC_DATA);
  bios_hw_out8 (0x04, PORT_VIDEO_GRDC_ADDR);
  bios_hw_out8 (0x02, PORT_VIDEO_GRDC_DATA);

  for (ch = 0; ch < 256; ++ch)
    {
      u16 off = (u16) (ch * 32U);
      u16 base = (u16) (ch * 14U);

      if (ch < 128)
	{
	  for (row = 0; row < 14; ++row)
	    bios_abs_write8 (
		0xA000, (u16) (off + row),
		bios_video_pega_font_en_8x14[(u16) (base + row)]);
	}
      else
	{
	  for (row = 0; row < 14; ++row)
	    bios_abs_write8 (0xA000, (u16) (off + row), 0);
	}
      for (row = 14; row < 32; ++row)
	bios_abs_write8 (0xA000, (u16) (off + row), 0);
    }

  bios_hw_out8 (0x04, PORT_VIDEO_GRDC_ADDR);
  bios_hw_out8 (0x00, PORT_VIDEO_GRDC_DATA);
  bios_hw_out8 (0x05, PORT_VIDEO_GRDC_ADDR);
  bios_hw_out8 (0x10, PORT_VIDEO_GRDC_DATA);
  bios_hw_out8 (0x06, PORT_VIDEO_GRDC_ADDR);
  bios_hw_out8 (mono ? (u8) 0x0A : (u8) 0x0E, PORT_VIDEO_GRDC_DATA);
  bios_hw_out8 (0x02, PORT_VIDEO_SEQU_ADDR);
  bios_hw_out8 (0x03, PORT_VIDEO_SEQU_DATA);
  bios_hw_out8 (0x04, PORT_VIDEO_SEQU_ADDR);
  bios_hw_out8 (0x02, PORT_VIDEO_SEQU_DATA);
}

static void
pega_attribute_palette (u16 status_port)
{
  u8 i;

  for (i = 0; i < 0x10; ++i)
    pega_attr_write (status_port, i, i);
  pega_attr_write (status_port, 0x10, 0x0C);
  pega_attr_write (status_port, 0x11, 0x00);
  pega_attr_write (status_port, 0x12, 0x0F);
  pega_attr_write (status_port, 0x13, 0x08);
  pega_attr_write (status_port, 0x14, 0x00);
}

void
bios_video_pega_program_hardware (u8 mode)
{
  int mono;
  u16 crtc;
  u16 status_port;

  static const u8 crtc_80x25_color[25] = {
    0x5F, 0x4F, 0x50, 0x82, 0x55, 0x81, 0xBF, 0x1F, 0x00, 0x4F, 0x0D,
    0x0E, 0x00, 0x00, 0x00, 0x00, 0x9C, 0x8E, 0x8F, 0x28, 0x1F, 0x96,
    0xB9, 0xA3, 0xFF
  };
  static const u8 crtc_80x25_mono[25] = {
    0x61, 0x50, 0x52, 0x0F, 0x19, 0x06, 0x19, 0x19, 0x02, 0x0D, 0x0D,
    0x0C, 0x00, 0x00, 0x00, 0x00, 0x86, 0x85, 0x5D, 0x28, 0x1F, 0x28,
    0x88, 0xA3, 0xFF
  };
  static const u8 crtc_40x25_color[25] = {
    0x2D, 0x27, 0x28, 0x90, 0x2B, 0xBF, 0x1F, 0x00, 0x62, 0x65, 0x40,
    0x40, 0x00, 0x00, 0x00, 0x00, 0x9C, 0x8E, 0x8F, 0x28, 0x1F, 0x96,
    0xB9, 0xA3, 0xFF
  };

  mono = (mode == VIDEO_MODE_80X25_MONO);
  crtc = mono ? PORT_MDA_CRTC_ADDR : PORT_CRTC_ADDR;
  status_port = mono ? PORT_MDA_STATUS : PORT_CGA_STATUS;

  bios_hw_out8 (0x00, PORT_VIDEO_SEQU_ADDR);
  bios_hw_out8 (0x01, PORT_VIDEO_SEQU_DATA);

  bios_hw_out8 (mono ? (u8) PC1640_EGC_CONTROL_MONO_TEXT
                     : (u8) PC1640_EGC_CONTROL_COLOR_TEXT,
                PORT_VIDEO_MISC_OUTPUT);

  bios_hw_out8 (0x01, PORT_VIDEO_SEQU_ADDR);
  bios_hw_out8 (0x00, PORT_VIDEO_SEQU_DATA);
  bios_hw_out8 (0x02, PORT_VIDEO_SEQU_ADDR);
  bios_hw_out8 (0x03, PORT_VIDEO_SEQU_DATA);
  bios_hw_out8 (0x03, PORT_VIDEO_SEQU_ADDR);
  bios_hw_out8 (0x00, PORT_VIDEO_SEQU_DATA);
  bios_hw_out8 (0x04, PORT_VIDEO_SEQU_ADDR);
  bios_hw_out8 (0x02, PORT_VIDEO_SEQU_DATA);
  bios_hw_out8 (0x00, PORT_VIDEO_SEQU_ADDR);
  bios_hw_out8 (0x03, PORT_VIDEO_SEQU_DATA);

  switch (mode)
    {
    case VIDEO_MODE_40X25_BW:
    case VIDEO_MODE_40X25_COLOR:
      pega_crtc_write_block (crtc, crtc_40x25_color, 25);
      break;
    case VIDEO_MODE_80X25_MONO:
      pega_crtc_write_block (crtc, crtc_80x25_mono, 25);
      break;
    default:
      pega_crtc_write_block (crtc, crtc_80x25_color, 25);
      break;
    }

  bios_hw_out8 (0x00, PORT_VIDEO_GRDC_ADDR);
  bios_hw_out8 (0x00, PORT_VIDEO_GRDC_DATA);
  bios_hw_out8 (0x01, PORT_VIDEO_GRDC_ADDR);
  bios_hw_out8 (0x00, PORT_VIDEO_GRDC_DATA);
  bios_hw_out8 (0x02, PORT_VIDEO_GRDC_ADDR);
  bios_hw_out8 (0x00, PORT_VIDEO_GRDC_DATA);
  bios_hw_out8 (0x03, PORT_VIDEO_GRDC_ADDR);
  bios_hw_out8 (0x00, PORT_VIDEO_GRDC_DATA);
  bios_hw_out8 (0x04, PORT_VIDEO_GRDC_ADDR);
  bios_hw_out8 (0x00, PORT_VIDEO_GRDC_DATA);
  bios_hw_out8 (0x05, PORT_VIDEO_GRDC_ADDR);
  bios_hw_out8 (0x10, PORT_VIDEO_GRDC_DATA);
  bios_hw_out8 (0x06, PORT_VIDEO_GRDC_ADDR);
  bios_hw_out8 (mono ? (u8) 0x0A : (u8) 0x0E, PORT_VIDEO_GRDC_DATA);
  bios_hw_out8 (0x07, PORT_VIDEO_GRDC_ADDR);
  bios_hw_out8 (0x00, PORT_VIDEO_GRDC_DATA);
  bios_hw_out8 (0x08, PORT_VIDEO_GRDC_ADDR);
  bios_hw_out8 (0xFF, PORT_VIDEO_GRDC_DATA);

  pega_attribute_palette (status_port);

  if (mono)
    {
      bios_hw_out8 (0x09, (u16) 0x03B8);
      (void) bios_hw_in8 (PORT_MDA_STATUS);
    }
  else
    {
      bios_hw_out8 (0x09, PORT_CGA_MODE);
      (void) bios_hw_in8 (PORT_CGA_STATUS);
    }

  pega_load_font (mono);
}

void
bios_video_pega_apply_text_mode (u8 mode, int clear_screen)
{
  u8 columns;
  u8 page;
  u16 page_size;
  u16 crtc;

  switch (mode)
    {
    case VIDEO_MODE_40X25_BW:
    case VIDEO_MODE_40X25_COLOR:
    case VIDEO_MODE_320X200_COLOR:
    case VIDEO_MODE_320X200_BW:
    case 0x08:
    case 0x09:
      columns = 40;
      page_size = 0x0800;
      break;
    default:
      columns = 80;
      page_size = 0x1000;
      break;
    }

  crtc = mode == VIDEO_MODE_80X25_MONO ? PORT_MDA_CRTC_ADDR : PORT_CRTC_ADDR;

  bios_bda_write8 (BDA_VIDEO_MODE, mode);
  bios_bda_write16 (BDA_VIDEO_COLUMNS, columns);
  bios_bda_write16 (BDA_VIDEO_PAGE_SIZE, page_size);
  bios_bda_write16 (BDA_VIDEO_PAGE_OFFSET, 0x0000);
  bios_bda_write16 (BDA_CRTC_PORT, crtc);
  bios_bda_write8 (BDA_ACTIVE_PAGE, 0x00);
  bios_bda_write8 (BDA_VIDEO_ROWS_MINUS_ONE, 24);
  bios_bda_write8 (BDA_VIDEO_CHAR_POINTS, 14);

  for (page = 0; page != 8; ++page)
    bios_bda_write16 ((u16) (BDA_CURSOR_POSITIONS + ((u16) page << 1)),
		      0x0000);

  bios_video_pega_program_hardware (mode);

  if (clear_screen)
    pega_clear_text_vram (BIOS_CFG_VIDEO_ATTRIBUTE);
}

static u16
pega_read_cell (u8 row, u8 col)
{
  u8 columns;
  u8 rows;
  u16 offset;

  columns = (u8) bios_bda_read16 (BDA_VIDEO_COLUMNS);
  rows = (u8) (bios_bda_read8 (BDA_VIDEO_ROWS_MINUS_ONE) + 1U);
  if (row >= rows || col >= columns)
    return (u16) (((u16) BIOS_CFG_VIDEO_ATTRIBUTE << 8) | ' ');

  offset = (u16) (bios_bda_read16 (BDA_VIDEO_PAGE_OFFSET)
		  + (((u16) row * columns) + col) * 2U);
  if (bios_bda_read8 (BDA_VIDEO_MODE) == VIDEO_MODE_80X25_MONO
      || bios_bda_read16 (BDA_CRTC_PORT) == PORT_MDA_CRTC_ADDR)
    return bios_abs_read16 (BIOS_VIDEO_MONO_SEGMENT, offset);
  return bios_abs_read16 (BIOS_VIDEO_COLOR_SEGMENT, offset);
}

static void
pega_write_cell (u8 row, u8 col, u8 ch, u8 attr)
{
  u8 columns;
  u8 rows;
  u16 offset;
  u16 seg;

  columns = (u8) bios_bda_read16 (BDA_VIDEO_COLUMNS);
  rows = (u8) (bios_bda_read8 (BDA_VIDEO_ROWS_MINUS_ONE) + 1U);
  if (row >= rows || col >= columns)
    return;

  offset = (u16) (bios_bda_read16 (BDA_VIDEO_PAGE_OFFSET)
		  + (((u16) row * columns) + col) * 2U);
  if (bios_bda_read8 (BDA_VIDEO_MODE) == VIDEO_MODE_80X25_MONO
      || bios_bda_read16 (BDA_CRTC_PORT) == PORT_MDA_CRTC_ADDR)
    seg = BIOS_VIDEO_MONO_SEGMENT;
  else
    seg = BIOS_VIDEO_COLOR_SEGMENT;
  bios_abs_write16 (seg, offset, (u16) ((u16) attr << 8) | ch);
}

static void
pega_scroll (int up, u8 lines, u8 attr, u8 top_row, u8 left_col,
		    u8 bottom_row, u8 right_col)
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
	for (col = left_col; col <= right_col; ++col)
	  pega_write_cell (row, col, ' ', attr);
      return;
    }

  if (up)
    {
      for (row = top_row; row <= (u8) (bottom_row - lines); ++row)
	for (col = left_col; col <= right_col; ++col)
	  {
	    u16 cell;

	    cell = pega_read_cell ((u8) (row + lines), col);
	    pega_write_cell (row, col, bios_lo (cell), bios_hi (cell));
	  }
      for (row = (u8) (bottom_row - lines + 1U); row <= bottom_row; ++row)
	for (col = left_col; col <= right_col; ++col)
	  pega_write_cell (row, col, ' ', attr);
    }
  else
    {
      int rowi;

      for (rowi = bottom_row; rowi >= (int) top_row + lines; --rowi)
	for (col = left_col; col <= right_col; ++col)
	  {
	    u16 cell;

	    cell = pega_read_cell ((u8) (rowi - lines), col);
	    pega_write_cell ((u8) rowi, col, bios_lo (cell), bios_hi (cell));
	  }
      for (row = top_row; row < (u8) (top_row + lines); ++row)
	for (col = left_col; col <= right_col; ++col)
	  pega_write_cell (row, col, ' ', attr);
    }
}

void
bios_service_int10 (bios_regs_t __far *regs)
{
  u8 ah;

  ah = bios_hi (regs->ax);
  switch (ah)
    {
    case 0x00:
      bios_video_pega_apply_text_mode (bios_lo (regs->ax), 1);
      bios_clear_cf (regs);
      break;

    case 0x01:
      bios_bda_write16 (BDA_CURSOR_TYPE, regs->cx);
      bios_clear_cf (regs);
      break;

    case 0x02:
      bios_bda_write16 (
	  (u16) (BDA_CURSOR_POSITIONS + ((u16) bios_hi (regs->bx) << 1)),
	  (u16) ((u16) bios_hi (regs->dx) << 8) | bios_lo (regs->dx));
      bios_clear_cf (regs);
      break;

    case 0x03:
      regs->cx = bios_bda_read16 (BDA_CURSOR_TYPE);
      regs->dx =
	bios_bda_read16 ((u16) (BDA_CURSOR_POSITIONS
				+ ((u16) bios_hi (regs->bx) << 1)));
      bios_clear_cf (regs);
      break;

    case 0x05:
      bios_bda_write8 (BDA_ACTIVE_PAGE, bios_lo (regs->ax));
      bios_bda_write16 (
	  BDA_VIDEO_PAGE_OFFSET,
	  (u16) bios_bda_read8 (BDA_ACTIVE_PAGE)
	    * bios_bda_read16 (BDA_VIDEO_PAGE_SIZE));
      bios_clear_cf (regs);
      break;

    case 0x06:
      pega_scroll (1, bios_lo (regs->ax), bios_hi (regs->bx), bios_hi (regs->cx),
		  bios_lo (regs->cx), bios_hi (regs->dx), bios_lo (regs->dx));
      bios_clear_cf (regs);
      break;

    case 0x07:
      pega_scroll (0, bios_lo (regs->ax), bios_hi (regs->bx), bios_hi (regs->cx),
		  bios_lo (regs->cx), bios_hi (regs->dx), bios_lo (regs->dx));
      bios_clear_cf (regs);
      break;

    case 0x08:
      {
	u8 row;
	u8 col;
	u16 cur;

	cur = bios_bda_read16 (
	    (u16) (BDA_CURSOR_POSITIONS
		   + ((u16) bios_hi (regs->bx) << 1)));
	row = bios_hi (cur);
	col = bios_lo (cur);
	regs->ax = pega_read_cell (row, col);
	bios_clear_cf (regs);
      }
      break;

    case 0x09:
      {
	u8 row;
	u8 col;
	u16 i;
	u16 cur;

	cur = bios_bda_read16 (
	    (u16) (BDA_CURSOR_POSITIONS
		   + ((u16) bios_hi (regs->bx) << 1)));
	row = bios_hi (cur);
	col = bios_lo (cur);
	for (i = 0; i < regs->cx; ++i)
	  {
	    pega_write_cell (row, col, bios_lo (regs->ax), bios_lo (regs->bx));
	    ++col;
	    if (col >= (u8) bios_bda_read16 (BDA_VIDEO_COLUMNS))
	      {
		col = 0;
		if (row
		    < (u8) bios_bda_read8 (BDA_VIDEO_ROWS_MINUS_ONE))
		  ++row;
	      }
	  }
	bios_clear_cf (regs);
      }
      break;

    case 0x0A:
      {
	u8 row;
	u8 col;
	u16 i;
	u16 cur;

	cur = bios_bda_read16 (
	    (u16) (BDA_CURSOR_POSITIONS
		   + ((u16) bios_hi (regs->bx) << 1)));
	row = bios_hi (cur);
	col = bios_lo (cur);
	for (i = 0; i < regs->cx; ++i)
	  {
	    pega_write_cell (row, col, bios_lo (regs->ax),
			    BIOS_CFG_VIDEO_ATTRIBUTE);
	    ++col;
	    if (col >= (u8) bios_bda_read16 (BDA_VIDEO_COLUMNS))
	      {
		col = 0;
		if (row
		    < (u8) bios_bda_read8 (BDA_VIDEO_ROWS_MINUS_ONE))
		  ++row;
	      }
	  }
	bios_clear_cf (regs);
      }
      break;

    case 0x0E:
      {
	u8 row;
	u8 col;
	u8 ch;
	u8 columns;
	u8 rows;
	u16 cur;

	ch = bios_lo (regs->ax);
	cur = bios_bda_read16 (
	    (u16) (BDA_CURSOR_POSITIONS
		   + ((u16) bios_hi (regs->bx) << 1)));
	row = bios_hi (cur);
	col = bios_lo (cur);
	columns = (u8) bios_bda_read16 (BDA_VIDEO_COLUMNS);
	rows =
	  (u8) (bios_bda_read8 (BDA_VIDEO_ROWS_MINUS_ONE) + 1U);

	switch (ch)
	  {
	  case '\r':
	    col = 0;
	    break;
	  case '\n':
	    if (row < (u8) (rows - 1U))
	      ++row;
	    break;
	  case '\b':
	    if (col != 0)
	      --col;
	    break;
	  default:
	    pega_write_cell (row, col, ch,
			    bios_work_read8 (WK_VIDEO_ATTRIBUTE));
	    ++col;
	    if (col >= columns)
	      {
		col = 0;
		if (row < (u8) (rows - 1U))
		  ++row;
	      }
	    break;
	  }

	if (row >= rows)
	  {
	    pega_scroll (1, 1, bios_work_read8 (WK_VIDEO_ATTRIBUTE), 0, 0,
			(u8) (rows - 1U), (u8) (columns - 1U));
	    row = (u8) (rows - 1U);
	  }

	bios_bda_write16 (
	    (u16) (BDA_CURSOR_POSITIONS
		   + ((u16) bios_hi (regs->bx) << 1)),
	    (u16) ((u16) row << 8) | col);
	bios_clear_cf (regs);
      }
      break;

    case 0x0F:
      regs->ax =
	(u16) bios_bda_read8 (BDA_VIDEO_MODE)
	| ((u16) bios_bda_read16 (BDA_VIDEO_COLUMNS) << 8);
      bios_set_hi (&regs->bx, bios_bda_read8 (BDA_ACTIVE_PAGE));
      bios_clear_cf (regs);
      break;

    default:
      bios_clear_cf (regs);
      break;
    }
}

#if !BIOS_CFG_VIDEO_PEGA_STANDALONE_ROM
void
bios_video_pega_inrom_init (void)
{
  BIOS_INSTALL_VECTOR (0x10, bios_int10_wrapper);
  BIOS_INSTALL_VECTOR (0x42, bios_int10_wrapper);

  bios_video_pega_apply_text_mode (machine_default_text_mode (), 1);
}
#endif

#else /* !BIOS_CFG_VIDEO_PEGA_INROM_DRIVER */

void
bios_video_pega_inrom_link_stub (void)
{
}

#endif /* BIOS_CFG_VIDEO_PEGA_INROM_DRIVER */
