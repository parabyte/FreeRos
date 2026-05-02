/* ================================================
 * FreeRos BIOS
 * io.c: CMOS and status port I/O helpers
 * ================================================ */

#include "bios.h"

/* ================================================
 * Static data
 * ================================================ */

static const u8 bios_cmos_defaults[64] = {
  0x00, 0x00, 0x00, 0x00, 0x12, 0x00, 0x01, 0x01,
  0x01, 0x88, 0x26, 0x02, 0x00, 0x80, 0x00, 0x00,
  ((BIOS_CFG_FLOPPY_TYPE_A & 0x0F) << 4) | (BIOS_CFG_FLOPPY_TYPE_B & 0x0F),
  0x00, 0x00, 0x00,
  0x00,
  (u8) (BIOS_CFG_BASE_MEMORY_KB & 0x00FF),
  (u8) ((BIOS_CFG_BASE_MEMORY_KB >> 8) & 0x00FF),
  0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00,
  0x20,
  0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00
};

/* ================================================
 * Private helpers
 * ================================================ */

static u8
bios_io_lpt1_status_live (void)
{
  u8 raw;
  u8 value;

  raw = bios_hw_in8 (PORT_LPT1_STATUS);
  if (!BIOS_CFG_VIDEO_USE_PC1640_SWITCH_BLOCK)
    value = BIOS_CFG_LPT1_STATUS;
  else
    value = raw;

  bios_work_write8 (WK_LPT1_STATUS, value);
  return value;
}

/* ================================================
 * CMOS access
 * ================================================ */

u8
bios_cmos_read (u8 index)
{
  u16 flags;
  u8 value;

  index &= 0x3F;
  bios_work_write8 (WK_CMOS_INDEX, index);

  flags = bios_hw_irq_save_disable ();
  bios_hw_out8 (index, PORT_CMOS_ADDR);
  value = bios_hw_in8 (PORT_CMOS_DATA);
  bios_hw_irq_restore (flags);

  bios_work_write8 ((u16) (WK_CMOS_SHADOW + index), value);
  return value;
}

void
bios_cmos_write (u8 index, u8 value)
{
  u16 flags;

  index &= 0x3F;
  bios_work_write8 (WK_CMOS_INDEX, index);
  bios_work_write8 ((u16) (WK_CMOS_SHADOW + index), value);

  flags = bios_hw_irq_save_disable ();
  bios_hw_out8 (index, PORT_CMOS_ADDR);
  bios_hw_out8 (value, PORT_CMOS_DATA);
  bios_hw_irq_restore (flags);
}

/* ================================================
 * I/O defaults initialization
 * ================================================ */

void
bios_io_init_defaults (void)
{
  u16 i;

  bios_work_write8 (WK_CMOS_INDEX, 0);
  /* Reset-stage table writes 80h to port 61h before C POST starts. */
  bios_work_write8 (WK_PORT61, 0x80);
  bios_work_write8 (WK_PORT62, 0x20);
  bios_work_write8 (WK_PORT64, bios_build_status1 ());
  bios_work_write8 (WK_PORT65, bios_build_status2 ());
  bios_hw_out8 (bios_work_read8 (WK_PORT64), PORT_SYSSTAT1_WR);
  bios_hw_out8 (bios_work_read8 (WK_PORT65), PORT_SYSSTAT2_WR);
  bios_work_write8 (WK_FDC_STATUS, 0x00);
  bios_work_write8 (WK_SERIAL_STATUS, 0x60);
  bios_work_write8 (WK_PRINTER_STATUS, 0x90);
  bios_work_write8 (WK_LAST_KBD_SCANCODE, 0x00);
  bios_work_write8 (WK_LAST_KBD_ASCII, 0x00);
  bios_work_write8 (WK_LAST_KBD_RAW, 0x00);
  bios_work_write8 (WK_KBD_PREFIX, 0x00);
  bios_work_write8 (WK_KBD_LED_STATE, 0x00);
  bios_work_write8 (WK_VIDEO_ATTRIBUTE, BIOS_CFG_VIDEO_ATTRIBUTE);
  bios_work_write8 (WK_RTC_ALARM_STATE, 0x00);
  bios_work_write8 (WK_NMI_MASK, 0x00);
  bios_work_write8 (WK_FDC_CYLINDER_0, 0xFF);
  bios_work_write8 (WK_FDC_CYLINDER_1, 0xFF);
  bios_work_write8 (WK_LPT1_STATUS, BIOS_CFG_LPT1_STATUS);
  bios_io_lpt1_status_live ();

  for (i = 0; i != 64; ++i)
    bios_work_write8 ((u16) (WK_CMOS_SHADOW + i), bios_cmos_read ((u8) i));
}

/* ================================================
 * Port read/write dispatch
 * ================================================ */

u8
bios_io_read (u16 port)
{
  switch (port)
    {
    case PORT_KBD_DATA:
      if ((bios_work_read8 (WK_PORT61) & PORT61_STATUS_MODE) != 0)
	return (u8) ((bios_work_read8 (WK_PORT64) | 0x0D) & 0x7F);
      return bios_hw_in8 (port);

    case PORT_PPI_PORT_B:
      {
	u8 value;

	value = bios_hw_in8 (port);
	bios_work_write8 (WK_PORT61, value);
	return value;
      }

    case PORT_SYSSTAT2_RD:
      {
	u8 live;
	u8 value;

	live = bios_hw_in8 (PORT_SYSSTAT2_RD);
	if ((bios_work_read8 (WK_PORT61) & PORT61_NVR_LOW_NIBBLE) != 0)
	  value = (u8) (bios_work_read8 (WK_PORT65) & 0x0F);
	else
	  value = (u8) (bios_work_read8 (WK_PORT65) >> 4);
	return (u8) ((live & 0xF0) | (value & 0x0F));
      }

    case PORT_CMOS_ADDR:
      return bios_work_read8 (WK_CMOS_INDEX);

    case PORT_CMOS_DATA:
      return bios_cmos_read (bios_work_read8 (WK_CMOS_INDEX));

    case PORT_MOUSE_X:
      return bios_hw_in8 (port);

    case PORT_MOUSE_Y:
      return bios_hw_in8 (port);

    case PORT_LPT1_STATUS:
      return bios_io_lpt1_status_live ();

    case PORT_NMI_MASK:
      return bios_work_read8 (WK_NMI_MASK);

    default:
      return bios_hw_in8 (port);
    }
}

void
bios_io_write (u16 port, u8 value)
{
  switch (port)
    {
    case PORT_PPI_PORT_B:
      bios_work_write8 (WK_PORT61, value);
      bios_hw_out8 (value, port);
      break;

    case PORT_SYSSTAT1_WR:
      bios_work_write8 (WK_PORT64, value);
      bios_hw_out8 (value, port);
      break;

    case PORT_SYSSTAT2_WR:
      bios_work_write8 (WK_PORT65, value);
      bios_hw_out8 (value, port);
      break;

    case PORT_SOFT_RESET:
      bios_work_write8 (WK_SOFT_RESET_LATCH, value);
      bios_bda_write16 (BDA_WARM_BOOT_FLAG, 0x1234);
      bios_hw_out8 (value, port);
      break;

    case PORT_CMOS_ADDR:
      bios_work_write8 (WK_CMOS_INDEX, (u8) (value & 0x3F));
      bios_hw_out8 ((u8) (value & 0x3F), PORT_CMOS_ADDR);
      break;

    case PORT_CMOS_DATA:
      bios_cmos_write (bios_work_read8 (WK_CMOS_INDEX), value);
      break;

    case PORT_MOUSE_X:
      bios_hw_out8 (value, port);
      break;

    case PORT_MOUSE_Y:
      bios_hw_out8 (value, port);
      break;

    case PORT_NMI_MASK:
      bios_work_write8 (WK_NMI_MASK, value);
      bios_hw_out8 (value, port);
      break;

    case PORT_LPT1_DATA:
    case PORT_LPT1_CONTROL:
      bios_work_write8 (WK_PRINTER_STATUS, value);
      bios_hw_out8 (value, port);
      break;

    default:
      bios_hw_out8 (value, port);
      break;
    }
}
