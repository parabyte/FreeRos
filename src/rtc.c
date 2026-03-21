#include "bios.h"

static u8
bios_bcd_pack (u8 value)
{
  return (u8) (((value / 10) << 4) | (value % 10));
}

static void bios_rtc_wait_ready (void);

static u8
bios_rtc_cmos_read_raw (u8 index)
{
  u8 value;

  index &= 0x3F;
  bios_work_write8 (WK_CMOS_INDEX, index);
  bios_hw_out8 (index, PORT_CMOS_ADDR);
  value = bios_hw_in8 (PORT_CMOS_DATA);
  bios_work_write8 ((u16) (WK_CMOS_SHADOW + index), value);
  return value;
}

static void
bios_rtc_cmos_write_raw (u8 index, u8 value)
{
  index &= 0x3F;
  bios_work_write8 (WK_CMOS_INDEX, index);
  bios_work_write8 ((u16) (WK_CMOS_SHADOW + index), value);
  bios_hw_out8 (index, PORT_CMOS_ADDR);
  bios_hw_out8 (value, PORT_CMOS_DATA);
}

static u8
bios_rtc_nvr_checksum_value (void)
{
  u8 index;
  u8 sum;

  sum = 0;
  for (index = CMOS_NVR_CHECKSUM_START; index != CMOS_NVR_CHECKSUM_END + 1U;
       ++index)
    {
      if (index == CMOS_NVR_CHECKSUM)
	continue;
      sum = (u8) (sum + bios_rtc_cmos_read_raw (index));
    }

  return (u8) (0xAAU - sum);
}

static int
bios_rtc_nvr_checksum_valid (void)
{
  u8 index;
  u8 sum;

  sum = 0;
  for (index = CMOS_NVR_CHECKSUM_START; index != CMOS_NVR_CHECKSUM_END + 1U;
       ++index)
    sum = (u8) (sum + bios_rtc_cmos_read_raw (index));

  return sum == 0xAA;
}

static void
bios_rtc_nvr_refresh_checksum (void)
{
  bios_rtc_cmos_write_raw (CMOS_NVR_CHECKSUM, bios_rtc_nvr_checksum_value ());
}

static u8
bios_rtc_nvr_default_value (u8 index, int *has_default)
{
  *has_default = 1;

  switch (index)
    {
    case CMOS_NVR_LAST_USED_SECONDS:
    case CMOS_NVR_LAST_USED_MINUTES:
    case CMOS_NVR_LAST_USED_HOURS:
    case CMOS_NVR_LAST_USED_DAY:
    case CMOS_NVR_LAST_USED_MONTH:
    case CMOS_NVR_LAST_USED_YEAR:
      *has_default = 0;
      return 0x00;

    case CMOS_NVR_CHECKSUM:
      return 0x00;

    case CMOS_NVR_ENTER_KEY_LO:
      return 0x0D;
    case CMOS_NVR_ENTER_KEY_HI:
      return 0x1C;
    case CMOS_NVR_DELETE_KEY_LO:
      return 0x07;
    case CMOS_NVR_DELETE_KEY_HI:
      return 0x22;
    case CMOS_NVR_JOYSTICK1_LO:
    case CMOS_NVR_JOYSTICK1_HI:
    case CMOS_NVR_JOYSTICK2_LO:
    case CMOS_NVR_JOYSTICK2_HI:
    case CMOS_NVR_MOUSE1_LO:
    case CMOS_NVR_MOUSE1_HI:
    case CMOS_NVR_MOUSE2_LO:
    case CMOS_NVR_MOUSE2_HI:
      return 0xFF;
    case CMOS_NVR_MOUSE_X_SCALE:
    case CMOS_NVR_MOUSE_Y_SCALE:
      return 0x0A;
    case CMOS_NVR_VDU_MODE:
      return bios_build_status1 ();
    case CMOS_NVR_VDU_ATTR:
      return BIOS_CFG_VIDEO_ATTRIBUTE;
    case CMOS_NVR_RAMDISK_SIZE:
      return 0x00;
    case CMOS_NVR_UART_SYSTEM:
    case CMOS_NVR_UART_EXTERNAL:
      return BIOS_CFG_UART_INIT;
    default:
      *has_default = 0;
      return 0x00;
    }
}

static void
bios_rtc_copy_last_used_from_rtc (void)
{
  bios_rtc_wait_ready ();
  bios_rtc_cmos_write_raw (CMOS_NVR_LAST_USED_SECONDS,
			   bios_rtc_cmos_read_raw (CMOS_SECONDS));
  bios_rtc_cmos_write_raw (CMOS_NVR_LAST_USED_MINUTES,
			   bios_rtc_cmos_read_raw (CMOS_MINUTES));
  bios_rtc_cmos_write_raw (CMOS_NVR_LAST_USED_HOURS,
			   bios_rtc_cmos_read_raw (CMOS_HOURS));
  bios_rtc_cmos_write_raw (CMOS_NVR_LAST_USED_DAY,
			   bios_rtc_cmos_read_raw (CMOS_DAY_OF_MONTH));
  bios_rtc_cmos_write_raw (CMOS_NVR_LAST_USED_MONTH,
			   bios_rtc_cmos_read_raw (CMOS_MONTH));
  bios_rtc_cmos_write_raw (CMOS_NVR_LAST_USED_YEAR,
			   bios_rtc_cmos_read_raw (CMOS_YEAR));
  bios_rtc_nvr_refresh_checksum ();
}

static void
bios_rtc_load_default_nvr (void)
{
  u8 index;

  for (index = CMOS_NVR_CHECKSUM_START; index != CMOS_NVR_CHECKSUM_END + 1U;
       ++index)
    {
      int has_default;
      u8 value;

      value = bios_rtc_nvr_default_value (index, &has_default);
      if (has_default)
	bios_rtc_cmos_write_raw (index, value);
    }
}

static void
bios_rtc_refresh_machine_nvr_state (void)
{
  bios_rtc_cmos_write_raw (CMOS_FLOPPY_TYPES,
			   (u8) (((BIOS_CFG_FLOPPY_TYPE_A & 0x0F) << 4)
				 | (BIOS_CFG_FLOPPY_TYPE_B & 0x0F)));
  bios_rtc_cmos_write_raw (CMOS_NVR_VDU_MODE, bios_build_status1 ());
  bios_rtc_cmos_write_raw (CMOS_NVR_VDU_ATTR, BIOS_CFG_VIDEO_ATTRIBUTE);
  bios_rtc_cmos_write_raw (CMOS_NVR_RAMDISK_SIZE, 0x00);
  bios_rtc_cmos_write_raw (CMOS_NVR_UART_SYSTEM, BIOS_CFG_UART_INIT);
  bios_rtc_cmos_write_raw (CMOS_NVR_UART_EXTERNAL, BIOS_CFG_UART_INIT);
}

static u8
bios_rtc_reg_b (void)
{
  return bios_rtc_cmos_read_raw (CMOS_REG_B);
}

static void
bios_rtc_wait_ready (void)
{
  u16 attempts;

  if (!BIOS_CFG_HAS_BATTERY_BACKED_RTC)
    return;

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

void
bios_rtc_init (void)
{
  u8 boot_flags;
  u8 reg_b;
  int battery_bad;
  int nvr_bad;

  if (!BIOS_CFG_HAS_BATTERY_BACKED_RTC)
    return;

  bios_rtc_wait_ready ();
  bios_rtc_cmos_write_raw (CMOS_REG_A, 0x26);
  reg_b = bios_rtc_reg_b ();
  reg_b |= CMOS_REG_B_24HOUR;
  reg_b &= (u8) ~ CMOS_REG_B_DAYLIGHT;
  bios_rtc_cmos_write_raw (CMOS_REG_B, reg_b);
  battery_bad = !bios_rtc_battery_ok ();
  if (battery_bad)
    {
      reg_b = bios_rtc_enter_set_mode ();
      bios_rtc_cmos_write_raw (CMOS_SECONDS,
			       bios_bcd_pack (BIOS_CFG_RTC_DEFAULT_SECONDS));
      bios_rtc_cmos_write_raw (CMOS_MINUTES,
			       bios_bcd_pack (BIOS_CFG_RTC_DEFAULT_MINUTES));
      bios_rtc_cmos_write_raw (CMOS_HOURS,
			       bios_bcd_pack (BIOS_CFG_RTC_DEFAULT_HOURS));
      bios_rtc_cmos_write_raw (CMOS_DAY_OF_MONTH,
			       bios_bcd_pack
			       (BIOS_CFG_RTC_DEFAULT_DAY_OF_MONTH));
      bios_rtc_cmos_write_raw (CMOS_MONTH,
			       bios_bcd_pack (BIOS_CFG_RTC_DEFAULT_MONTH));
      bios_rtc_cmos_write_raw (CMOS_YEAR,
			       bios_bcd_pack (BIOS_CFG_RTC_DEFAULT_YEAR));
      bios_rtc_cmos_write_raw (CMOS_CENTURY,
			       bios_bcd_pack (BIOS_CFG_RTC_DEFAULT_CENTURY));
      bios_rtc_cmos_write_raw (CMOS_ALARM_SECONDS, 0x00);
      bios_rtc_cmos_write_raw (CMOS_ALARM_MINUTES, 0x00);
      bios_rtc_cmos_write_raw (CMOS_ALARM_HOURS, 0x00);
      bios_rtc_leave_set_mode (reg_b);
    }

  nvr_bad = !bios_rtc_nvr_checksum_valid ();
  if (battery_bad || nvr_bad)
    {
      bios_rtc_load_default_nvr ();
      bios_rtc_copy_last_used_from_rtc ();
    }

  bios_rtc_refresh_machine_nvr_state ();
  bios_rtc_nvr_refresh_checksum ();

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
  if (!BIOS_CFG_HAS_BATTERY_BACKED_RTC)
    return 1;

  return (bios_rtc_cmos_read_raw (CMOS_REG_D) & CMOS_REG_D_VRT) != 0;
}

void
bios_rtc_periodic_housekeeping (u32 ticks)
{
  if (!BIOS_CFG_HAS_BATTERY_BACKED_RTC)
    return;

  if ((u8) ticks == 0x00)
    bios_rtc_copy_last_used_from_rtc ();
}

static void
bios_pc1640_int15_mouse_read_reset (bios_regs_t __far *regs)
{
  signed char x;
  signed char y;

  x = (signed char) bios_io_read (PORT_MOUSE_X);
  y = (signed char) bios_io_read (PORT_MOUSE_Y);
  regs->cx = (u16) (int) x;
  regs->dx = (u16) (int) y;
  bios_set_hi (&regs->ax, 0x00);
  bios_clear_cf (regs);
}

static void
bios_pc1640_int15_write_nvr (bios_regs_t __far *regs)
{
  u8 expected;
  u8 index;
  u8 value;

  index = bios_lo (regs->ax);
  value = bios_lo (regs->bx);
  if (index >= 64)
    {
      bios_set_hi (&regs->ax, 0x01);
      bios_clear_cf (regs);
      return;
    }

  bios_rtc_cmos_write_raw (index, value);
  bios_rtc_nvr_refresh_checksum ();
  expected =
    (index == CMOS_NVR_CHECKSUM) ? bios_rtc_cmos_read_raw (index) : value;
  bios_set_hi (&regs->ax,
	       bios_rtc_cmos_read_raw (index) == expected ? 0x00 : 0x02);
  bios_clear_cf (regs);
}

static void
bios_pc1640_int15_read_nvr (bios_regs_t __far *regs)
{
  u8 index;
  u8 value;

  index = bios_lo (regs->ax);
  if (index >= 64)
    {
      bios_set_hi (&regs->ax, 0x01);
      bios_clear_cf (regs);
      return;
    }

  value = bios_rtc_cmos_read_raw (index);
  bios_set_lo (&regs->ax, value);
  bios_set_hi (&regs->ax, bios_rtc_nvr_checksum_valid ()? 0x00 : 0x02);
  bios_clear_cf (regs);
}

void
bios_service_pc1640_int15 (bios_regs_t __far *regs)
{
  switch (bios_hi (regs->ax))
    {
    case 0x00:
      bios_pc1640_int15_mouse_read_reset (regs);
      break;

    case 0x01:
      bios_pc1640_int15_write_nvr (regs);
      break;

    case 0x02:
      bios_pc1640_int15_read_nvr (regs);
      break;

    case 0x03:
    case 0x04:
    case 0x05:
      /*
       * AH=03/04/05: PC1512-specific VDU plane/border functions.
       * On the PC1640 with PEGA1A EGA, these are no-ops; the IGA BIOS
       * handles plane selection and border colour through INT 10h AH=10.
       */
      bios_clear_cf (regs);
      break;

    case 0x06:
      regs->bx = (u16) (BIOS_CFG_ROS_RELEASE << 8) | BIOS_CFG_ROS_ISSUE;
      bios_set_hi (&regs->ax, 0x00);
      bios_clear_cf (regs);
      break;

    default:
      bios_set_cf (regs);
      break;
    }
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
