/* ================================================
 * FreeRos BIOS
 * rtc.c: Real-time clock and CMOS battery management
 * ================================================ */

#include "bios.h"
#include "machine.h"

#define BCD_PACK(v) ((u8)(((v) / 10U) << 4 | ((v) % 10U)))

static void bios_rtc_wait_ready (void);

/*
 * Use the shared bios_cmos_read / bios_cmos_write from io.c.
 * Shorter aliases keep the diff small.
 */
#define bios_rtc_cmos_read_raw(idx)       bios_cmos_read (idx)
#define bios_rtc_cmos_write_raw(idx, val) bios_cmos_write ((idx), (val))

static u8
bios_rtc_reg_b (void)
{
  return bios_rtc_cmos_read_raw (CMOS_REG_B);
}

static void
bios_rtc_wait_ready (void)
{
  u16 attempts;

  for (attempts = 0; attempts != 0x4000; ++attempts)
    {
      if ((bios_rtc_cmos_read_raw (CMOS_REG_A)
	   & CMOS_REG_A_UPDATE_IN_PROGRESS) == 0)
	return;
      bios_hw_pause ();
    }
}

static void
bios_rtc_set_reg_b (u8 value)
{
  bios_rtc_cmos_write_raw (CMOS_REG_B, value);
}

static u8
bios_rtc_enter_set_mode (void)
{
  u8 reg_b;

  reg_b = bios_rtc_reg_b ();
  bios_rtc_set_reg_b ((u8) (reg_b | CMOS_REG_B_SET_CLOCK));
  return reg_b;
}

static void
bios_rtc_leave_set_mode (u8 reg_b)
{
  bios_rtc_set_reg_b ((u8) (reg_b & (u8) ~ CMOS_REG_B_SET_CLOCK));
}

static void
bios_rtc_set_daylight_flag (u8 enabled)
{
  u8 reg_b;

  reg_b = bios_rtc_reg_b ();
  reg_b &= (u8) ~ CMOS_REG_B_DAYLIGHT;
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
    reg_b &= (u8) ~ CMOS_REG_B_ALARM_IRQ;
  bios_rtc_set_reg_b (reg_b);
}

/* ================================================
 * Initialization
 * ================================================ */

void
bios_rtc_init (void)
{
  u8 boot_flags;
  u8 reg_b;
  int battery_bad;

  bios_rtc_wait_ready ();
  bios_rtc_cmos_write_raw (CMOS_REG_A, 0x26);
  reg_b = bios_rtc_reg_b ();
  reg_b |= CMOS_REG_B_24HOUR;
  reg_b &= (u8) ~ CMOS_REG_B_DAYLIGHT;
  bios_rtc_cmos_write_raw (CMOS_REG_B, reg_b);
  battery_bad = !bios_rtc_battery_ok ();

  machine_nvr_init ();

  boot_flags = bios_work_read8 (WK_BOOT_FLAGS);
  if (battery_bad)
    boot_flags |= BOOT_FLAG_BATTERY_LOW;
  else
    boot_flags &= (u8) ~ BOOT_FLAG_BATTERY_LOW;
  bios_work_write8 (WK_BOOT_FLAGS, boot_flags);
  bios_work_write8 (WK_RTC_ALARM_STATE, 0x00);
}

int
bios_rtc_battery_ok (void)
{
  return (bios_rtc_cmos_read_raw (CMOS_REG_D) & CMOS_REG_D_VRT) != 0;
}

void
bios_rtc_periodic_housekeeping (u32 ticks)
{
  if ((u8) ticks == 0x00)
    machine_rtc_periodic ();
}

/* ================================================
 * INT 1Ah service dispatch
 * ================================================ */

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
      bios_rtc_wait_ready ();
      bios_set_hi (&regs->cx, bios_rtc_cmos_read_raw (CMOS_HOURS));
      bios_set_lo (&regs->cx, bios_rtc_cmos_read_raw (CMOS_MINUTES));
      bios_set_hi (&regs->dx, bios_rtc_cmos_read_raw (CMOS_SECONDS));
      bios_set_lo (&regs->dx, (u8) (bios_rtc_reg_b () & CMOS_REG_B_DAYLIGHT));
      bios_clear_cf (regs);
      break;

    case 0x03:
      {
	u8 saved_reg_b;

	saved_reg_b = bios_rtc_enter_set_mode ();
	bios_rtc_cmos_write_raw (CMOS_HOURS, bios_hi (regs->cx));
	bios_rtc_cmos_write_raw (CMOS_MINUTES, bios_lo (regs->cx));
	bios_rtc_cmos_write_raw (CMOS_SECONDS, bios_hi (regs->dx));
	bios_rtc_leave_set_mode (saved_reg_b);
      }
      bios_rtc_set_daylight_flag (bios_lo (regs->dx));
      bios_clear_cf (regs);
      break;

    case 0x04:
      bios_rtc_wait_ready ();
      bios_set_hi (&regs->cx, bios_rtc_cmos_read_raw (CMOS_CENTURY));
      bios_set_lo (&regs->cx, bios_rtc_cmos_read_raw (CMOS_YEAR));
      bios_set_hi (&regs->dx, bios_rtc_cmos_read_raw (CMOS_MONTH));
      bios_set_lo (&regs->dx, bios_rtc_cmos_read_raw (CMOS_DAY_OF_MONTH));
      bios_clear_cf (regs);
      break;

    case 0x05:
      {
	u8 saved_reg_b;

	saved_reg_b = bios_rtc_enter_set_mode ();
	bios_rtc_cmos_write_raw (CMOS_CENTURY, bios_hi (regs->cx));
	bios_rtc_cmos_write_raw (CMOS_YEAR, bios_lo (regs->cx));
	bios_rtc_cmos_write_raw (CMOS_MONTH, bios_hi (regs->dx));
	bios_rtc_cmos_write_raw (CMOS_DAY_OF_MONTH, bios_lo (regs->dx));
	bios_rtc_leave_set_mode (saved_reg_b);
      }
      bios_clear_cf (regs);
      break;

    case 0x06:
      bios_rtc_cmos_write_raw (CMOS_ALARM_HOURS, bios_hi (regs->cx));
      bios_rtc_cmos_write_raw (CMOS_ALARM_MINUTES, bios_lo (regs->cx));
      bios_rtc_cmos_write_raw (CMOS_ALARM_SECONDS, bios_hi (regs->dx));
      bios_rtc_set_alarm_enabled (1);
      bios_work_write8 (WK_RTC_ALARM_STATE, 1);
      bios_clear_cf (regs);
      break;

    case 0x07:
      bios_rtc_cmos_write_raw (CMOS_ALARM_SECONDS, 0x00);
      bios_rtc_cmos_write_raw (CMOS_ALARM_MINUTES, 0x00);
      bios_rtc_cmos_write_raw (CMOS_ALARM_HOURS, 0x00);
      bios_rtc_set_alarm_enabled (0);
      bios_work_write8 (WK_RTC_ALARM_STATE, 0);
      bios_clear_cf (regs);
      break;

    default:
      bios_set_cf (regs);
      break;
    }
}
