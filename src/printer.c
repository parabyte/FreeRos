#include "bios.h"

enum
{
  LPT_REG_DATA = 0,
  LPT_REG_STATUS = 1,
  LPT_REG_CONTROL = 2
};

#define LPT_STATUS_BUSY 0x80
#define LPT_STATUS_ACK 0x40
#define LPT_STATUS_ONLINE 0x10
#define LPT_STATUS_ERROR 0x08

#define LPT_CONTROL_STROBE 0x01
#define LPT_CONTROL_INIT 0x04

static int
bios_print_screen_supported_mode (u8 mode)
{
  return mode <= VIDEO_MODE_80X25_COLOR || mode == VIDEO_MODE_80X25_MONO;
}

static int
bios_print_screen_write_char (u8 ch)
{
  bios_regs_t regs;

  regs.ax = ch;
  regs.bx = 0x0000;
  regs.cx = 0x0000;
  regs.dx = 0x0000;
  regs.si = 0x0000;
  regs.di = 0x0000;
  regs.bp = 0x0000;
  regs.ds = 0x0000;
  regs.es = 0x0000;
  regs.flags = 0x0000;
  bios_service_int17 (&regs);
  return (regs.flags & BIOS_FLAG_CF) == 0 && (bios_hi (regs.ax) & 0x01) == 0;
}

static void
bios_print_screen_finish (u8 status)
{
  bios_abs_write8 (0x0000, BIOS_PRINT_SCREEN_STATUS, status);
}

static u8
bios_printer_translate_status (u8 status)
{
  return (u8) ((status & 0xF8) ^ 0x48);
}

static u16
bios_printer_base (u16 index)
{
  if (index == 0)
    return BIOS_CFG_LPT1_BASE;

  if (index == 1)
    return BIOS_CFG_LPT2_BASE;

  return 0;
}

static u8
bios_printer_status (u16 index)
{
  return bios_hw_in8 ((u16) (bios_printer_base (index) + LPT_REG_STATUS));
}

static int
bios_printer_available (u16 index)
{
  return bios_printer_base (index) != 0;
}

void
bios_printer_init (void)
{
  bios_work_write8 (WK_PRINTER_STATUS,
		    (u8) (bios_printer_available (0)
			  ?
			  bios_printer_translate_status (bios_printer_status
							 (0)) : 0x00));
}

void
bios_printer_irq7 (void)
{
  bios_pic_ack_irq (7);
}

void
bios_service_int05 (bios_regs_t __far *regs)
{
  u8 mode;
  u8 active_page;
  u8 rows;
  u16 columns;
  u16 page_size;
  u16 page_offset;
  u16 row;
  u16 column;
  u16 video_seg;

  (void) regs;

  if (bios_abs_read8 (0x0000, BIOS_PRINT_SCREEN_STATUS) == 0x01)
    {
      bios_print_screen_finish (0x01);
      return;
    }

  mode = bios_bda_read8 (BDA_VIDEO_MODE);
  if (!bios_print_screen_supported_mode (mode))
    {
      bios_print_screen_finish (0xFF);
      return;
    }

  columns = bios_bda_read16 (BDA_VIDEO_COLUMNS);
  page_size = bios_bda_read16 (BDA_VIDEO_PAGE_SIZE);
  active_page = bios_bda_read8 (BDA_ACTIVE_PAGE);
  rows = (u8) (bios_bda_read8 (BDA_VIDEO_ROWS_MINUS_ONE) + 1U);
  video_seg = mode == VIDEO_MODE_80X25_MONO ? 0xB000 : 0xB800;
  if (page_size == 0)
    page_size = (u16) (columns * rows * 2U);
  page_offset = (u16) (page_size * active_page);

  if (columns == 0 || rows == 0)
    {
      bios_print_screen_finish (0xFF);
      return;
    }

  bios_print_screen_finish (0x01);
  if (!bios_print_screen_write_char ('\r')
      || !bios_print_screen_write_char ('\n'))
    {
      bios_print_screen_finish (0xFF);
      return;
    }

  for (row = 0; row < rows; ++row)
    {
      u16 row_offset;

      row_offset = (u16) (page_offset + row * columns * 2U);
      for (column = 0; column < columns; ++column)
	{
	  u8 ch;

	  ch = bios_abs_read8 (video_seg, (u16) (row_offset + column * 2U));
	  if (ch == 0x00)
	    ch = ' ';

	  if (!bios_print_screen_write_char (ch))
	    {
	      bios_print_screen_finish (0xFF);
	      return;
	    }
	}

      if (!bios_print_screen_write_char ('\r')
	  || !bios_print_screen_write_char ('\n'))
	{
	  bios_print_screen_finish (0xFF);
	  return;
	}
    }

  bios_print_screen_finish (0x00);
}

void
bios_service_int17 (bios_regs_t __far *regs)
{
  u8 control;
  u8 status;
  u16 port_index;
  u16 base;
  u16 attempts;

  port_index = regs->dx;
  base = bios_printer_base (port_index);
  switch (bios_hi (regs->ax))
    {
    case 0x00:
      if (!bios_printer_available (port_index))
	{
	  bios_set_cf (regs);
	  break;
	}

      bios_hw_out8 (bios_lo (regs->ax), (u16) (base + LPT_REG_DATA));
      control = bios_hw_in8 ((u16) (base + LPT_REG_CONTROL));
      bios_hw_out8 ((u8) (control | LPT_CONTROL_STROBE),
		    (u16) (base + LPT_REG_CONTROL));
      bios_wait_microseconds (5UL);
      bios_hw_out8 ((u8) (control & (u8) ~ LPT_CONTROL_STROBE),
		    (u16) (base + LPT_REG_CONTROL));

      status = bios_printer_status (port_index);
      for (attempts = 0; attempts != 0x8000; ++attempts)
	{
	  if ((status & 0x40) == 0)
	    break;
	  bios_hw_pause ();
	  status = bios_printer_status (port_index);
	}

      status = bios_printer_translate_status (status);
      if (attempts == 0x8000)
	status |= 0x01;
      bios_set_hi (&regs->ax, status);
      bios_work_write8 (WK_PRINTER_STATUS, bios_hi (regs->ax));
      bios_clear_cf (regs);
      break;

    case 0x01:
      if (!bios_printer_available (port_index))
	{
	  bios_set_cf (regs);
	  break;
	}

      control = bios_hw_in8 ((u16) (base + LPT_REG_CONTROL));
      bios_hw_out8 ((u8) (control & (u8) ~ LPT_CONTROL_INIT),
		    (u16) (base + LPT_REG_CONTROL));
      bios_wait_microseconds (4000UL);
      bios_hw_out8 ((u8) (control | LPT_CONTROL_INIT),
		    (u16) (base + LPT_REG_CONTROL));
      bios_set_hi (&regs->ax,
		   bios_printer_translate_status (bios_printer_status
						  (port_index)));
      bios_work_write8 (WK_PRINTER_STATUS, bios_hi (regs->ax));
      bios_clear_cf (regs);
      break;

    case 0x02:
      if (!bios_printer_available (port_index))
	{
	  bios_set_cf (regs);
	  break;
	}

      bios_set_hi (&regs->ax,
		   bios_printer_translate_status (bios_printer_status
						  (port_index)));
      bios_work_write8 (WK_PRINTER_STATUS, bios_hi (regs->ax));
      bios_clear_cf (regs);
      break;

    default:
      bios_set_cf (regs);
      break;
    }
}
