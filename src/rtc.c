#include "bios.h"

static u8
bios_bcd_pack (u8 value)
{
  return (u8) (((value / 10) << 4) | (value % 10));
}

static u8
bios_rtc_reg_b (void)
{
  return bios_cmos_read (CMOS_REG_B);
}

static void
bios_rtc_set_reg_b (u8 value)
{
  bios_cmos_write (CMOS_REG_B, value);
}

static void
bios_rtc_set_daylight_flag (u8 enabled)
{
  u8 reg_b;

  reg_b = bios_rtc_reg_b ();
  reg_b &= (u8) ~CMOS_REG_B_DAYLIGHT;
  reg_b |= (u8) (enabled & CMOS_REG_B_DAYLIGHT);
  bios_rtc_set_reg_b (reg_b);
}

static void
bios_rtc_set_alarm_enabled (int enabled)
{
  u8 reg_b;

  reg_b = bios_rtc_reg_b ();
  if (enabled)
    reg_b |= CMOS_REG_B_ALARM_IRQ;
  else
    reg_b &= (u8) ~CMOS_REG_B_ALARM_IRQ;
  bios_rtc_set_reg_b (reg_b);
}

void
bios_rtc_init (void)
{
  if (!BIOS_CFG_HAS_BATTERY_BACKED_RTC)
    return;

  bios_cmos_write (CMOS_REG_A, 0x26);
  bios_cmos_write (CMOS_REG_B, CMOS_REG_B_24HOUR);
  bios_cmos_write (CMOS_REG_C, 0x00);
  bios_cmos_write (CMOS_REG_D, CMOS_REG_D_VRT);
  bios_cmos_write (CMOS_FLOPPY_TYPES,
                   (u8) (((BIOS_CFG_FLOPPY_TYPE_A & 0x0F) << 4)
                         | (BIOS_CFG_FLOPPY_TYPE_B & 0x0F)));
  bios_cmos_write (CMOS_EQUIPMENT,
                   (u8) bios_bda_read16 (BDA_EQUIPMENT_WORD));
  bios_cmos_write (CMOS_BASE_MEMORY_LOW,
                   (u8) (BIOS_CFG_BASE_MEMORY_KB & 0x00FF));
  bios_cmos_write (CMOS_BASE_MEMORY_HIGH,
                   (u8) ((BIOS_CFG_BASE_MEMORY_KB >> 8) & 0x00FF));
  bios_cmos_write (CMOS_SECONDS, bios_bcd_pack (BIOS_CFG_RTC_DEFAULT_SECONDS));
  bios_cmos_write (CMOS_MINUTES, bios_bcd_pack (BIOS_CFG_RTC_DEFAULT_MINUTES));
  bios_cmos_write (CMOS_HOURS, bios_bcd_pack (BIOS_CFG_RTC_DEFAULT_HOURS));
  bios_cmos_write (CMOS_DAY_OF_MONTH,
                   bios_bcd_pack (BIOS_CFG_RTC_DEFAULT_DAY_OF_MONTH));
  bios_cmos_write (CMOS_MONTH, bios_bcd_pack (BIOS_CFG_RTC_DEFAULT_MONTH));
  bios_cmos_write (CMOS_YEAR, bios_bcd_pack (BIOS_CFG_RTC_DEFAULT_YEAR));
  bios_cmos_write (CMOS_CENTURY, bios_bcd_pack (BIOS_CFG_RTC_DEFAULT_CENTURY));
  bios_cmos_write (CMOS_ALARM_SECONDS, 0x00);
  bios_cmos_write (CMOS_ALARM_MINUTES, 0x00);
  bios_cmos_write (CMOS_ALARM_HOURS, 0x00);
  bios_work_write8 (WK_RTC_ALARM_STATE, 0x00);
}

int
bios_rtc_battery_ok (void)
{
  if (!BIOS_CFG_HAS_BATTERY_BACKED_RTC)
    return 1;

  return (bios_cmos_read (CMOS_REG_D) & CMOS_REG_D_VRT) != 0;
}

void
bios_service_int1a (bios_regs_t __far *regs)
{
  switch (bios_hi (regs->ax))
    {
    case 0x00:
      regs->cx = (u16) (bios_bda_read32 (BDA_TIMER_TICKS) >> 16);
      regs->dx = (u16) bios_bda_read32 (BDA_TIMER_TICKS);
      bios_set_lo (&regs->ax, bios_bda_read8 (BDA_TIMER_MIDNIGHT));
      bios_bda_write8 (BDA_TIMER_MIDNIGHT, 0);
      bios_clear_cf (regs);
      break;

    case 0x01:
      bios_bda_write32 (BDA_TIMER_TICKS, ((u32) regs->cx << 16) | regs->dx);
      bios_bda_write8 (BDA_TIMER_MIDNIGHT, 0);
      bios_clear_cf (regs);
      break;

    case 0x02:
      bios_set_hi (&regs->cx, bios_cmos_read (CMOS_HOURS));
      bios_set_lo (&regs->cx, bios_cmos_read (CMOS_MINUTES));
      bios_set_hi (&regs->dx, bios_cmos_read (CMOS_SECONDS));
      bios_set_lo (&regs->dx,
                   (u8) (bios_rtc_reg_b () & CMOS_REG_B_DAYLIGHT));
      bios_clear_cf (regs);
      break;

    case 0x03:
      bios_cmos_write (CMOS_HOURS, bios_hi (regs->cx));
      bios_cmos_write (CMOS_MINUTES, bios_lo (regs->cx));
      bios_cmos_write (CMOS_SECONDS, bios_hi (regs->dx));
      bios_rtc_set_daylight_flag (bios_lo (regs->dx));
      bios_clear_cf (regs);
      break;

    case 0x04:
      bios_set_hi (&regs->cx, bios_cmos_read (CMOS_CENTURY));
      bios_set_lo (&regs->cx, bios_cmos_read (CMOS_YEAR));
      bios_set_hi (&regs->dx, bios_cmos_read (CMOS_MONTH));
      bios_set_lo (&regs->dx, bios_cmos_read (CMOS_DAY_OF_MONTH));
      bios_clear_cf (regs);
      break;

    case 0x05:
      bios_cmos_write (CMOS_CENTURY, bios_hi (regs->cx));
      bios_cmos_write (CMOS_YEAR, bios_lo (regs->cx));
      bios_cmos_write (CMOS_MONTH, bios_hi (regs->dx));
      bios_cmos_write (CMOS_DAY_OF_MONTH, bios_lo (regs->dx));
      bios_clear_cf (regs);
      break;

    case 0x06:
      bios_cmos_write (CMOS_ALARM_HOURS, bios_hi (regs->cx));
      bios_cmos_write (CMOS_ALARM_MINUTES, bios_lo (regs->cx));
      bios_cmos_write (CMOS_ALARM_SECONDS, bios_hi (regs->dx));
      bios_rtc_set_alarm_enabled (1);
      bios_work_write8 (WK_RTC_ALARM_STATE, 1);
      bios_clear_cf (regs);
      break;

    case 0x07:
      bios_cmos_write (CMOS_ALARM_SECONDS, 0x00);
      bios_cmos_write (CMOS_ALARM_MINUTES, 0x00);
      bios_cmos_write (CMOS_ALARM_HOURS, 0x00);
      bios_rtc_set_alarm_enabled (0);
      bios_work_write8 (WK_RTC_ALARM_STATE, 0);
      bios_clear_cf (regs);
      break;

    default:
      bios_set_cf (regs);
      break;
    }
}
