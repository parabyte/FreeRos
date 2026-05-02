/* ================================================
 * FreeRos BIOS
 * machine_pc1640dd.c: Amstrad PC1640 machine-specific implementation
 * ================================================ */

#include "bios.h"
#include "machine.h"
#include "pc1640_ports.h"

static const u8 pc1640_pega_preserve_vectors[] = {
  0x10, 0x1D, 0x1F, 0x42, 0x43
};

static const u16 pc1640_lpt_probe_ports[] = {
  0x03BC, 0x0378, 0x0278
};

#define PC1640_PEGA_VECTOR_COUNT                                              \
  ((u8) (sizeof (pc1640_pega_preserve_vectors)                                \
         / sizeof (pc1640_pega_preserve_vectors[0])))

#define PC1640_POST_STACK_GUARD_START 0x00006800UL
#define PC1640_POST_TEMP_BOOT_FLAGS_OFF 0x0000
#define PC1640_POST_TEMP_MOUSE_OK_OFF 0x0001
#define PC1640_POST_TEMP_VECTOR_BASE_OFF 0x0002

/* ================================================
 * DIP switch reading
 * ================================================ */

static u8
pc1640_switch_latch_read (u16 latch_port)
{
  u8 control;
  u16 flags;

  flags = bios_hw_irq_save_disable ();
  (void) bios_hw_in8 (latch_port);
  control = bios_hw_in8 (PORT_LPT1_CONTROL);
  bios_hw_irq_restore (flags);
  return control;
}

static u8
pc1640_read_video_switch_block (void)
{
  u8 value;

  asm volatile (
    "pushf\n\t"
    "cli\n\t"
    "movw $0x03c2, %%dx\n\t"
    "movb $0xf0, %%ah\n\t"
    "movb $0x4f, %%al\n\t"
    "outb %%al, %%dx\n\t"
    "inb %%dx, %%al\n\t"
    "testb $0x10, %%al\n\t"
    "jz 1f\n\t"
    "orb $0x01, %%ah\n"
    "1:\n\t"
    "movb $0x4b, %%al\n\t"
    "outb %%al, %%dx\n\t"
    "inb %%dx, %%al\n\t"
    "testb $0x10, %%al\n\t"
    "jz 2f\n\t"
    "orb $0x02, %%ah\n"
    "2:\n\t"
    "movb $0x43, %%al\n\t"
    "outb %%al, %%dx\n\t"
    "inb %%dx, %%al\n\t"
    "testb $0x10, %%al\n\t"
    "jz 3f\n\t"
    "orb $0x08, %%ah\n"
    "3:\n\t"
    "movb $0x47, %%al\n\t"
    "outb %%al, %%dx\n\t"
    "inb %%dx, %%al\n\t"
    "testb $0x10, %%al\n\t"
    "jz 4f\n\t"
    "orb $0x04, %%ah\n"
    "4:\n\t"
    "movb %%ah, %%al\n\t"
    "popf"
    : "=a" (value)
    :
    : "dx", "memory", "cc");

  return value;
}

static void
pc1640_publish_video_switch_block (void)
{
  bios_bda_write8 (BDA_VIDEO_SWITCHES, pc1640_read_video_switch_block ());
}

static u8
pc1640_switch_status_read (void)
{
  return pc1640_switch_latch_read (PORT_PC1640_SW10_LATCH);
}

static int
pc1640_language_rom_enabled (void)
{
  u8 links;

  /* PC1640 language links are inverted on the printer status low bits. */
  links = (u8) (bios_hw_in8 (PORT_LPT1_STATUS) & LPT1_STATUS_LANGUAGE_MASK);
  return links == LPT1_STATUS_DECODE_LANGUAGE (BIOS_LANG_ENGLISH);
}

static int
pc1640_video_int10_ready (void)
{
  u16 off;
  u16 seg;

  off = bios_abs_read16 (0x0000, (u16) 0x10 * 4U);
  seg = bios_abs_read16 (0x0000, (u16) ((0x10 * 4U) + 2U));
  return off != 0x0000 && seg != 0x0000 && seg != BIOS_ROM_SEGMENT;
}

static u8
pc1640_video_columns_for_mode (u8 mode)
{
  return mode == VIDEO_MODE_40X25_COLOR ? 40 : 80;
}

static u16
pc1640_video_page_size_for_mode (u8 mode)
{
  return mode == VIDEO_MODE_40X25_COLOR ? 0x0800 : 0x1000;
}

static u16
pc1640_video_crtc_for_mode (u8 mode)
{
  return mode == VIDEO_MODE_80X25_MONO ? PORT_MDA_CRTC_ADDR : PORT_CRTC_ADDR;
}

static void
pc1640_prepare_direct_text_state (void)
{
  u8 mode;

  /*
   * Before the PEGA ROM owns INT 10h we still need enough state for the plain
   * motherboard POST text path. Seed only the minimum BDA fields required for
   * direct text writes and cursor tracking; leave the richer video state to
   * the adapter ROM once it is alive.
   */
  if (pc1640_video_int10_ready ())
    return;

  mode = machine_default_text_mode ();
  bios_bda_write8 (BDA_VIDEO_MODE, mode);
  bios_bda_write16 (BDA_VIDEO_COLUMNS, pc1640_video_columns_for_mode (mode));
  bios_bda_write16 (BDA_CRTC_PORT, pc1640_video_crtc_for_mode (mode));
  bios_bda_write8 (BDA_ACTIVE_PAGE, 0x00);
  bios_bda_write16 (BDA_CURSOR_POSITIONS, 0x0000);
}

static u8
pc1640_post_temp_read8 (u16 off)
{
  return bios_abs_read8 ((u16) (PC1640_POST_STACK_GUARD_START >> 4),
                         (u16) ((PC1640_POST_STACK_GUARD_START + off)
                                & 0x000FUL));
}

static void
pc1640_post_temp_write8 (u16 off, u8 value)
{
  bios_abs_write8 ((u16) (PC1640_POST_STACK_GUARD_START >> 4),
                   (u16) ((PC1640_POST_STACK_GUARD_START + off) & 0x000FUL),
                   value);
}

static u16
pc1640_post_temp_read16 (u16 off)
{
  return bios_abs_read16 ((u16) (PC1640_POST_STACK_GUARD_START >> 4),
                          (u16) ((PC1640_POST_STACK_GUARD_START + off)
                                 & 0x000FUL));
}

static void
pc1640_post_temp_write16 (u16 off, u16 value)
{
  bios_abs_write16 ((u16) (PC1640_POST_STACK_GUARD_START >> 4),
                    (u16) ((PC1640_POST_STACK_GUARD_START + off) & 0x000FUL),
                    value);
}

static u16
pc1640_post_temp_vector_offset (u8 index)
{
  return (u16) (PC1640_POST_TEMP_VECTOR_BASE_OFF + (u16) index * 4U);
}

static void
pc1640_capture_preserved_vectors (bios_far_vector_t *vectors)
{
  u8 i;

  for (i = 0; i != PC1640_PEGA_VECTOR_COUNT; ++i)
    vectors[i] = bios_ivt_read_vector (pc1640_pega_preserve_vectors[i]);
}

static void
pc1640_restore_preserved_vectors (const bios_far_vector_t *vectors)
{
  u8 i;

  for (i = 0; i != PC1640_PEGA_VECTOR_COUNT; ++i)
    bios_ivt_write_vector (pc1640_pega_preserve_vectors[i], vectors[i]);
}

static void
pc1640_save_preserved_vectors_to_temp (void)
{
  bios_far_vector_t vectors[PC1640_PEGA_VECTOR_COUNT];
  u8 i;

  pc1640_capture_preserved_vectors (vectors);
  for (i = 0; i != PC1640_PEGA_VECTOR_COUNT; ++i)
    {
      u16 temp_off;

      temp_off = pc1640_post_temp_vector_offset (i);
      pc1640_post_temp_write16 (temp_off, vectors[i].off);
      pc1640_post_temp_write16 ((u16) (temp_off + 2U), vectors[i].seg);
    }
}

static void
pc1640_restore_preserved_vectors_from_temp (void)
{
  bios_far_vector_t vectors[PC1640_PEGA_VECTOR_COUNT];
  u8 i;

  for (i = 0; i != PC1640_PEGA_VECTOR_COUNT; ++i)
    {
      u16 temp_off;

      temp_off = pc1640_post_temp_vector_offset (i);
      vectors[i].off = pc1640_post_temp_read16 (temp_off);
      vectors[i].seg = pc1640_post_temp_read16 ((u16) (temp_off + 2U));
    }
  pc1640_restore_preserved_vectors (vectors);
}

static void
pc1640_publish_ros_compat_vectors (void)
{
  /*
   * The stock PC1640 keeps the generic 6845 table in the motherboard ROM and
   * leaves INT 40h unused after the PEGA adapter ROM has initialized.
   * Publish that final DOS-visible layout only after the video ROM has taken
   * any vectors it needs during bring-up.
   */
  BIOS_INSTALL_DATA_VECTOR (0x1D, bios_video_parameter_table);
  bios_abs_write32 (0x0000, (u16) 0x40 * 4U, 0x00000000UL);
}

static int
pc1640_probe_port_byte (u16 port)
{
  bios_hw_out8 (0xAA, port);
  if (bios_hw_in8 (port) != 0xAA)
    return 0;

  bios_hw_out8 (0x55, port);
  return bios_hw_in8 (port) == 0x55;
}

static void
pc1640_publish_detected_io_state (void)
{
  static const u16 lpt_bda_slots[] = {
    BDA_LPT1_BASE, BDA_LPT2_BASE, BDA_LPT3_BASE
  };
  u16 equipment;
  u8 equipment_high;
  u8 i;
  u8 lpt_slot;

  /*
   * Mirror the original PC1640 POST probe at F88DCh:
   * COM1 is fixed at 3F8h, COM2 is optional at 2F8h, printer ports are
   * probed in the motherboard ROM order 3BCh, 378h, 278h, and the game-port
   * present bit comes from port 201h low nibble.
   */
  bios_bda_write16 (BDA_COM1_BASE, 0x03F8);
  bios_bda_write16 (BDA_COM2_BASE, 0x0000);
  bios_bda_write16 (BDA_COM3_BASE, 0x0000);
  bios_bda_write16 (BDA_COM4_BASE, 0x0000);
  bios_bda_write16 (BDA_LPT1_BASE, 0x0000);
  bios_bda_write16 (BDA_LPT2_BASE, 0x0000);
  bios_bda_write16 (BDA_LPT3_BASE, 0x0000);

  equipment_high = 0x42;
  if (pc1640_probe_port_byte (0x02FB))
    {
      bios_bda_write16 (BDA_COM2_BASE, 0x02F8);
      equipment_high = (u8) (equipment_high + 2U);
    }

  equipment_high &= (u8) ~0x40U;
  lpt_slot = 0;
  for (i = 0; i != sizeof (pc1640_lpt_probe_ports) / sizeof (pc1640_lpt_probe_ports[0]);
       ++i)
    {
      if (!pc1640_probe_port_byte (pc1640_lpt_probe_ports[i]))
        continue;

      bios_bda_write16 (lpt_bda_slots[lpt_slot], pc1640_lpt_probe_ports[i]);
      lpt_slot++;
      equipment_high = (u8) (equipment_high + 0x40U);
    }

  if ((bios_hw_in8 (0x0201) & 0x0F) == 0)
    equipment_high |= 0x08;

  equipment = bios_bda_read16 (BDA_EQUIPMENT_WORD);
  bios_bda_write16 (BDA_EQUIPMENT_WORD,
                    (u16) ((equipment & 0x00FFU)
                           | ((u16) equipment_high << 8)));
}

/* ================================================
 * RTC/NVR management
 * ================================================ */

#define PC1640_BCD_PACK(v) ((u8) ((((v) / 10U) << 4) | ((v) % 10U)))

/*
 * Original PC1640 ROS cold-boot default image for CMOS/NVR bytes 00h-3Fh.
 * Bytes 0Ch and 0Dh are left untouched by the firmware reset helper.
 */
static const u8 pc1640_cmos_boot_defaults[64] = {
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01,
  0x01, 0x80, 0x20, 0x02, 0xFE, 0xFE, 0x00, 0x00,
  0x01, 0x01, 0x01, 0x78, 0x00, 0x0D, 0x1C, 0x07,
  0x22, 0xFF, 0xFF, 0xFF, 0xFF, 0x0D, 0x1C, 0x1B,
  0x01, 0x0A, 0x0A, 0x20, 0x07, 0x00, 0xE3, 0xE3,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};

static int
pc1640_bcd_value_valid (u8 value, u8 max_dec)
{
  u8 ones;
  u8 tens;

  ones = (u8) (value & 0x0F);
  tens = (u8) ((value >> 4) & 0x0F);
  if (ones > 9 || tens > 9)
    return 0;

  return (u8) (tens * 10U + ones) <= max_dec;
}

static int
pc1640_rtc_field_valid (u8 index, u8 value)
{
  switch (index)
    {
    case CMOS_SECONDS:
    case CMOS_MINUTES:
      return pc1640_bcd_value_valid (value, 59);

    case CMOS_HOURS:
      return pc1640_bcd_value_valid (value, 23);

    case CMOS_DAY_OF_MONTH:
      return value != 0 && pc1640_bcd_value_valid (value, 31);

    case CMOS_MONTH:
      return value != 0 && pc1640_bcd_value_valid (value, 12);

    case CMOS_YEAR:
    case CMOS_CENTURY:
      return pc1640_bcd_value_valid (value, 99);

    default:
      return 1;
    }
}

static u8
pc1640_rtc_default_value (u8 index)
{
  switch (index)
    {
    case CMOS_SECONDS:
      return PC1640_BCD_PACK (BIOS_CFG_RTC_DEFAULT_SECONDS);
    case CMOS_MINUTES:
      return PC1640_BCD_PACK (BIOS_CFG_RTC_DEFAULT_MINUTES);
    case CMOS_HOURS:
      return PC1640_BCD_PACK (BIOS_CFG_RTC_DEFAULT_HOURS);
    case CMOS_DAY_OF_MONTH:
      return PC1640_BCD_PACK (BIOS_CFG_RTC_DEFAULT_DAY_OF_MONTH);
    case CMOS_MONTH:
      return PC1640_BCD_PACK (BIOS_CFG_RTC_DEFAULT_MONTH);
    case CMOS_YEAR:
      return PC1640_BCD_PACK (BIOS_CFG_RTC_DEFAULT_YEAR);
    case CMOS_CENTURY:
      return PC1640_BCD_PACK (BIOS_CFG_RTC_DEFAULT_CENTURY);
    case CMOS_ALARM_SECONDS:
    case CMOS_ALARM_MINUTES:
    case CMOS_ALARM_HOURS:
      return 0x00;
    default:
      return 0x00;
    }
}

static u8
pc1640_rtc_read_or_default (u8 index)
{
  u8 value;

  value = bios_cmos_read (index);
  if (!pc1640_rtc_field_valid (index, value))
    value = pc1640_rtc_default_value (index);

  return value;
}

static int
pc1640_warm_reset_requested (void)
{
  return bios_abs_read16 (0x0000, BDA_WARM_BOOT_FLAG) == 0x1234;
}

static void
pc1640_rtc_seed_defaults_if_needed (int force_defaults)
{
  static const u8 rtc_init_map[] = {
    CMOS_SECONDS,
    CMOS_MINUTES,
    CMOS_HOURS,
    CMOS_DAY_OF_MONTH,
    CMOS_MONTH,
    CMOS_YEAR,
    CMOS_CENTURY,
    CMOS_ALARM_SECONDS,
    CMOS_ALARM_MINUTES,
    CMOS_ALARM_HOURS
  };
  u8 i;

  for (i = 0; i != sizeof (rtc_init_map) / sizeof (rtc_init_map[0]); ++i)
    {
      u8 index;
      u8 value;

      index = rtc_init_map[i];
      value = bios_cmos_read (index);
      if (force_defaults || !pc1640_rtc_field_valid (index, value))
        bios_cmos_write (index, pc1640_rtc_default_value (index));
    }
}

static void
pc1640_cmos_load_boot_defaults (void)
{
  u8 index;

  for (index = 0; index != 64; ++index)
    {
      u8 value;

      value = pc1640_cmos_boot_defaults[index];
      if (value != 0xFE)
        bios_cmos_write (index, value);
    }
}

/* ================================================
 * NVR checksumming
 * ================================================ */

static u8
pc1640_nvr_sum (int include_checksum)
{
  u8 index;
  u8 sum;

  sum = 0;
  for (index = CMOS_NVR_CHECKSUM_START; index != CMOS_NVR_CHECKSUM_END + 1U;
       ++index)
    {
      if (!include_checksum && index == CMOS_NVR_CHECKSUM)
        continue;
      sum = (u8) (sum + bios_cmos_read (index));
    }
  return sum;
}

static u8
pc1640_nvr_checksum_value (void)
{
  return (u8) (0xAAU - pc1640_nvr_sum (0));
}

static int
pc1640_nvr_checksum_valid (void)
{
  return pc1640_nvr_sum (1) == 0xAA;
}

static void
pc1640_nvr_refresh_checksum (void)
{
  bios_cmos_write (CMOS_NVR_CHECKSUM, pc1640_nvr_checksum_value ());
}

static u8
pc1640_nvr_default_value (u8 index, int *has_default)
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
      return bios_lo (BIOS_CFG_PC1640_NVR_ENTER_TOKEN);
    case CMOS_NVR_ENTER_KEY_HI:
      return bios_hi (BIOS_CFG_PC1640_NVR_ENTER_TOKEN);
    case CMOS_NVR_DELETE_KEY_LO:
      return bios_lo (BIOS_CFG_PC1640_NVR_DELETE_TOKEN);
    case CMOS_NVR_DELETE_KEY_HI:
      return bios_hi (BIOS_CFG_PC1640_NVR_DELETE_TOKEN);
    case CMOS_NVR_JOYSTICK1_LO:
      return bios_lo (BIOS_CFG_PC1640_NVR_JOYSTICK1_TOKEN);
    case CMOS_NVR_JOYSTICK1_HI:
      return bios_hi (BIOS_CFG_PC1640_NVR_JOYSTICK1_TOKEN);
    case CMOS_NVR_JOYSTICK2_LO:
      return bios_lo (BIOS_CFG_PC1640_NVR_JOYSTICK2_TOKEN);
    case CMOS_NVR_JOYSTICK2_HI:
      return bios_hi (BIOS_CFG_PC1640_NVR_JOYSTICK2_TOKEN);
    case CMOS_NVR_MOUSE1_LO:
      return bios_lo (BIOS_CFG_PC1640_NVR_MOUSE1_TOKEN);
    case CMOS_NVR_MOUSE1_HI:
      return bios_hi (BIOS_CFG_PC1640_NVR_MOUSE1_TOKEN);
    case CMOS_NVR_MOUSE2_LO:
      return bios_lo (BIOS_CFG_PC1640_NVR_MOUSE2_TOKEN);
    case CMOS_NVR_MOUSE2_HI:
      return bios_hi (BIOS_CFG_PC1640_NVR_MOUSE2_TOKEN);
    case CMOS_NVR_MOUSE_X_SCALE:
      return (u8) BIOS_CFG_PC1640_NVR_MOUSE_X_SCALE;
    case CMOS_NVR_MOUSE_Y_SCALE:
      return (u8) BIOS_CFG_PC1640_NVR_MOUSE_Y_SCALE;
    case CMOS_NVR_VDU_MODE:
      return machine_build_status1 ();
    case CMOS_NVR_VDU_ATTR:
      return BIOS_CFG_VIDEO_ATTRIBUTE;
    case CMOS_NVR_RAMDISK_SIZE:
      return (u8) BIOS_CFG_PC1640_NVR_RAMDISK_SIZE;
    case CMOS_NVR_UART_SYSTEM:
    case CMOS_NVR_UART_EXTERNAL:
      return BIOS_CFG_UART_INIT;
    case CMOS_NVR_BOOT_STATE:
      return 0x01;
    default:
      if (index >= CMOS_NVR_BOOT_STATE && index <= CMOS_NVR_CHECKSUM_END)
        return 0x00;
      *has_default = 0;
      return 0x00;
    }
}

static void
pc1640_nvr_load_defaults (void)
{
  u8 index;

  for (index = CMOS_NVR_CHECKSUM_START; index != CMOS_NVR_CHECKSUM_END + 1U;
       ++index)
    {
      int has_default;
      u8 value;

      value = pc1640_nvr_default_value (index, &has_default);
      if (has_default)
        bios_cmos_write (index, value);
    }
}

static const u8 pc1640_nvr_last_used_map[][2] = {
  { CMOS_NVR_LAST_USED_SECONDS, CMOS_SECONDS },
  { CMOS_NVR_LAST_USED_MINUTES, CMOS_MINUTES },
  { CMOS_NVR_LAST_USED_HOURS, CMOS_HOURS },
  { CMOS_NVR_LAST_USED_DAY, CMOS_DAY_OF_MONTH },
  { CMOS_NVR_LAST_USED_MONTH, CMOS_MONTH },
  { CMOS_NVR_LAST_USED_YEAR, CMOS_YEAR },
};

static void
pc1640_nvr_copy_last_used_from_rtc (void)
{
  u8 i;

  for (i = 0; i != sizeof (pc1640_nvr_last_used_map)
       / sizeof (pc1640_nvr_last_used_map[0]); ++i)
    bios_cmos_write (pc1640_nvr_last_used_map[i][0],
                     pc1640_rtc_read_or_default (pc1640_nvr_last_used_map[i][1]));
  pc1640_nvr_refresh_checksum ();
}

static void
pc1640_nvr_refresh_machine_state (void)
{
  u8 nvr_mode;

  /*
   * The original ROS only refreshes the live boot-state bytes here: byte 35
   * (current display mode with the user-configured top bits preserved) and
   * byte 40, then it recomputes the NVR checksum.
   */
  nvr_mode = (u8) ((bios_cmos_read (CMOS_NVR_VDU_MODE) & 0xC0)
                   | (machine_build_status1 () & 0x3F));
  bios_cmos_write (CMOS_NVR_VDU_MODE, nvr_mode);
  bios_cmos_write (CMOS_NVR_BOOT_STATE, 0x01);
}

/* ================================================
 * Keyboard/mouse services
 * ================================================ */

static u16
pc1640_keyboard_nvr_token (u8 lo_index)
{
  u16 token;

  token = bios_cmos_read (lo_index);
  token |= (u16) bios_cmos_read ((u8) (lo_index + 1U)) << 8;
  return token;
}

static int
pc1640_queue_nvr_token (u8 lo_index, int released)
{
  if (released)
    return 1;

  bios_keyboard_enqueue_token (pc1640_keyboard_nvr_token (lo_index));
  return 1;
}

/* ================================================
 * INT 15h extensions
 * ================================================ */

static void
pc1640_int15_mouse_read_reset (bios_regs_t __far *regs)
{
  signed char x;
  signed char y;

  x = (signed char) bios_hw_in8 (PORT_MOUSE_X);
  y = (signed char) bios_hw_in8 (PORT_MOUSE_Y);
  bios_hw_out8 (0x00, PORT_MOUSE_X);
  bios_hw_out8 (0x00, PORT_MOUSE_Y);
  regs->cx = (u16) (int) x;
  regs->dx = (u16) (int) y;
  bios_set_hi (&regs->ax, 0x00);
  bios_clear_cf (regs);
}

static void
pc1640_int15_write_nvr (bios_regs_t __far *regs)
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

  bios_cmos_write (index, value);
  pc1640_nvr_refresh_checksum ();
  expected = (index == CMOS_NVR_CHECKSUM) ? bios_cmos_read (index) : value;
  bios_set_hi (&regs->ax,
               bios_cmos_read (index) == expected ? 0x00 : 0x02);
  bios_clear_cf (regs);
}

static void
pc1640_int15_read_nvr (bios_regs_t __far *regs)
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

  value = bios_cmos_read (index);
  bios_set_lo (&regs->ax, value);
  bios_set_hi (&regs->ax, pc1640_nvr_checksum_valid () ? 0x00 : 0x02);
  bios_clear_cf (regs);
}

/* ================================================
 * Machine interface implementation
 * ================================================ */

void
machine_post_early_init (void)
{
  /*
   * The reset entry has already handled the PC1640 battery/checksum/default
   * decision. At this point only refresh the live boot-state bytes that the
   * original ROS republishes before option-ROM initialization.
   */
  pc1640_nvr_refresh_machine_state ();
  pc1640_nvr_refresh_checksum ();
}

void
machine_video_init (void)
{
#if BIOS_CFG_VIDEO_PEGA_INROM_DRIVER
  /*
   * English-only in-ROM driver: optional E000 extension ROM only; no C000
   * Paradise video BIOS required.
   */
  if (pc1640_language_rom_enabled ())
    {
      if (bios_abs_read16 (0xE000, 0x0000) == 0xAA55)
        bios_option_rom_enter (0xE000);
    }
  bios_video_pega_inrom_init ();
#else
  /*
   * The PC1640 ROS does not perform a generic adapter-ROM sweep here.
   * It first consults the switch latch on the printer-status lines and, when
   * the language/video strap requests it, jumps directly to E000:0003 or
   * C000:0003 using the same narrow tests seen in the original firmware.
   */
  if (pc1640_language_rom_enabled ())
    {
      if (bios_abs_read16 (0xE000, 0x0000) == 0xAA55)
        bios_option_rom_enter (0xE000);
      else if (bios_abs_read16 (BIOS_CFG_VIDEO_OPTION_ROM_SEGMENT, 0x0000)
                 == 0xAA55)
        bios_option_rom_enter (BIOS_CFG_VIDEO_OPTION_ROM_SEGMENT);
    }

  pc1640_prepare_direct_text_state ();
#endif
}

int
machine_preserve_low_memory_state (u16 warm_boot_flag)
{
  return warm_boot_flag == 0x1234 || warm_boot_flag == 0x1235;
}

void
machine_post_vectors_fixup (void)
{
  bios_far_vector_t saved[PC1640_PEGA_VECTOR_COUNT];

  pc1640_capture_preserved_vectors (saved);
  bios_install_vectors ();
  pc1640_restore_preserved_vectors (saved);
  pc1640_publish_ros_compat_vectors ();
}

void
machine_post_save_runtime_state (u8 boot_flags, int mouse_ok)
{
  /*
   * The destructive RAM pass reuses low memory, so preserve the motherboard
   * boot flags plus the PEGA-owned vectors in the guard window at 6800h-77FFh.
   * That mirrors the original ROS practice of staging machine state outside
   * the area being scrubbed and tested.
   */
  pc1640_post_temp_write8 (PC1640_POST_TEMP_BOOT_FLAGS_OFF, boot_flags);
  pc1640_post_temp_write8 (PC1640_POST_TEMP_MOUSE_OK_OFF,
                           mouse_ok ? 1U : 0U);
  pc1640_save_preserved_vectors_to_temp ();
}

u8
machine_post_saved_boot_flags (void)
{
  return pc1640_post_temp_read8 (PC1640_POST_TEMP_BOOT_FLAGS_OFF);
}

int
machine_post_saved_mouse_ok (void)
{
  return pc1640_post_temp_read8 (PC1640_POST_TEMP_MOUSE_OK_OFF) != 0;
}

void
machine_post_publish_runtime_state (u16 size_kb, u8 boot_flags,
                                    int destructive_ram_test)
{
  /*
   * Rebuild the motherboard-owned low-memory image after the RAM sweep.
   * This step republishes the BDA, re-probes serial/printer/game state, and
   * restores the PEGA-owned vectors so the system ROM and video ROM divide
   * ownership the same way as the original PC1640 pair of ROMs.
   */
  if (destructive_ram_test)
    {
      bios_mem_fill16 (0x0000, 0x0000, 0x0000, 0x0280);
      bios_abs_write8 (0x0000, BIOS_PRINT_SCREEN_STATUS, 0x00);
      bios_abs_write16 (0x0000, BDA_WARM_BOOT_FLAG, 0x0000);
      bios_io_init_defaults ();
    }

  bios_install_bda_tables ();
  bios_bda_write16 (BDA_MEMORY_SIZE_KB, size_kb);
  bios_bda_write16 (BDA_EXTRA_MEMORY_KB,
                    size_kb > 64 ? (u16) (size_kb - 64) : 0);
  pc1640_publish_video_switch_block ();
  pc1640_publish_detected_io_state ();
  bios_work_write8 (WK_BOOT_FLAGS, boot_flags);

#if BIOS_CFG_SERIAL_INT14_ENABLED || BIOS_CFG_DEBUG_COM1
  if (destructive_ram_test)
    bios_serial_init ();
#endif
  if (destructive_ram_test)
    {
      bios_keyboard_init ();
#if BIOS_CFG_HAS_FLOPPY_CONTROLLER
      bios_floppy_init ();
#endif
#if BIOS_CFG_PRINTER_ENABLED
      bios_printer_init ();
#endif
      bios_install_vectors ();
      pc1640_restore_preserved_vectors_from_temp ();
      pc1640_publish_ros_compat_vectors ();
    }
  else
    machine_post_vectors_fixup ();

  bios_io_write (PORT_SYSSTAT1_WR, bios_build_status1 ());
  bios_io_write (PORT_SYSSTAT2_WR, bios_build_status2 ());
}

u16
machine_equipment_video_bits (void)
{
  u8 control;

  if (!BIOS_CFG_VIDEO_USE_PC1640_SWITCH_BLOCK)
    return BIOS_CFG_VIDEO_EQUIPMENT;

  control = pc1640_switch_status_read ();

  if ((control & LPT1_CONTROL_SWITCH_SW10) == 0)
    return BIOS_CFG_VIDEO_EQUIPMENT_80X25_COLOR;

  if ((control & (LPT1_CONTROL_SWITCH_SW7 | LPT1_CONTROL_SWITCH_SW6)) == 0)
    return BIOS_CFG_VIDEO_EQUIPMENT_80X25_COLOR;

  if ((control & (LPT1_CONTROL_SWITCH_SW7 | LPT1_CONTROL_SWITCH_SW6))
      == LPT1_CONTROL_SWITCH_SW6)
    return BIOS_CFG_VIDEO_EQUIPMENT_40X25_COLOR;

  if ((control & (LPT1_CONTROL_SWITCH_SW7 | LPT1_CONTROL_SWITCH_SW6))
      == LPT1_CONTROL_SWITCH_SW7)
    return BIOS_CFG_VIDEO_EQUIPMENT_80X25_COLOR;

  return BIOS_CFG_VIDEO_EQUIPMENT_MONO;
}

u8
machine_default_text_mode (void)
{
  switch (machine_equipment_video_bits ())
    {
    case BIOS_CFG_VIDEO_EQUIPMENT_40X25_COLOR:
      return VIDEO_MODE_40X25_COLOR;
    case BIOS_CFG_VIDEO_EQUIPMENT_MONO:
      return VIDEO_MODE_80X25_MONO;
    default:
      return VIDEO_MODE_80X25_COLOR;
    }
}

int
machine_int15_extensions (bios_regs_t __far *regs)
{
  switch (bios_hi (regs->ax))
    {
    case 0x00:
      pc1640_int15_mouse_read_reset (regs);
      return 1;
    case 0x01:
      pc1640_int15_write_nvr (regs);
      return 1;
    case 0x02:
      pc1640_int15_read_nvr (regs);
      return 1;
    case 0x03:
    case 0x04:
    case 0x05:
      /*
       * AH=03/04/05: PC1512-specific VDU plane/border functions.
       * On the PC1640 with PEGA1A EGA, these are no-ops; the adapter ROM
       * handles plane selection and border colour through INT 10h AH=10.
       */
      bios_clear_cf (regs);
      return 1;
    case 0x06:
      regs->bx = (u16) (BIOS_CFG_ROS_RELEASE << 8) | BIOS_CFG_ROS_ISSUE;
      bios_set_hi (&regs->ax, 0x00);
      bios_clear_cf (regs);
      return 1;
    default:
      return 0;
    }
}

int
machine_keyboard_special (u8 scancode, int released)
{
  switch (scancode)
    {
    case 0x70:
      return pc1640_queue_nvr_token (CMOS_NVR_DELETE_KEY_LO, released);
    case 0x74:
      return pc1640_queue_nvr_token (CMOS_NVR_ENTER_KEY_LO, released);
    case 0x77:
      return pc1640_queue_nvr_token (CMOS_NVR_JOYSTICK2_LO, released);
    case 0x78:
      return pc1640_queue_nvr_token (CMOS_NVR_JOYSTICK1_LO, released);
    case 0x79:
      if (!released)
        bios_keyboard_enqueue_token (0x4D00);
      return 1;
    case 0x7A:
      if (!released)
        bios_keyboard_enqueue_token (0x4B00);
      return 1;
    case 0x7B:
      if (!released)
        bios_keyboard_enqueue_token (0x5000);
      return 1;
    case 0x7C:
      if (!released)
        bios_keyboard_enqueue_token (0x4800);
      return 1;
    case 0x7D:
      if (!released)
        bios_keyboard_enqueue_token (pc1640_keyboard_nvr_token (CMOS_NVR_MOUSE1_LO));
      return 1;
    case 0x7E:
      if (!released)
        bios_keyboard_enqueue_token (pc1640_keyboard_nvr_token (CMOS_NVR_MOUSE2_LO));
      return 1;
    default:
      return 0;
    }
}

int
machine_mouse_test (void)
{
  bios_io_write (PORT_MOUSE_X, 0x00);
  if ((signed char) bios_io_read (PORT_MOUSE_X) != 0)
    return 0;

  bios_io_write (PORT_MOUSE_Y, 0x00);
  return (signed char) bios_io_read (PORT_MOUSE_Y) == 0;
}

void
machine_nvr_init (void)
{
  int nvr_bad;

  nvr_bad = !pc1640_nvr_checksum_valid ();
  if (nvr_bad)
    pc1640_cmos_load_boot_defaults ();

  pc1640_nvr_refresh_machine_state ();
  pc1640_nvr_refresh_checksum ();
}

u8
machine_build_status1 (void)
{
  u8 value;

  switch (machine_equipment_video_bits ())
    {
    case BIOS_CFG_VIDEO_EQUIPMENT_40X25_COLOR:
      value = 0x10;
      break;
    case BIOS_CFG_VIDEO_EQUIPMENT_80X25_COLOR:
      value = 0x20;
      break;
    case BIOS_CFG_VIDEO_EQUIPMENT_MONO:
      value = 0x30;
      break;
    default:
      value = 0x00;
      break;
    }

  if (BIOS_CFG_FLOPPY_DRIVES > 1)
    value |= 0x40;
  if (BIOS_CFG_HAS_MATH_COPROCESSOR)
    value |= 0x02;
  return value;
}

u8
machine_build_status2 (void)
{
  u16 memory_kb;
  u8 ram_code;

  memory_kb = bios_bda_read16 (BDA_MEMORY_SIZE_KB);
  if (memory_kb < 544)
    ram_code = 0x0E;
  else if (memory_kb < 576)
    ram_code = 0x0F;
  else if (memory_kb < 608)
    ram_code = 0x10;
  else if (memory_kb < 640)
    ram_code = 0x11;
  else
    ram_code = 0x12;

  return (u8) (0x80 | ram_code);
}

u8
machine_build_video_switches (void)
{
  return 0x09;
}

u16
machine_equipment_base_bits (void)
{
  return 0x000C;
}

void
machine_rtc_periodic (void)
{
  pc1640_nvr_copy_last_used_from_rtc ();
}

void
machine_video_program_mode (u8 mode)
{
#if BIOS_CFG_VIDEO_PEGA_INROM_DRIVER
  bios_video_pega_program_hardware (mode);
#else
  (void) mode;
#endif
}

/*
 * INT 06h: Amstrad mouse button service.
 *
 * Called when the keyboard controller delivers a mouse-button scancode
 * (0x7D or 0x7E).  Looks up the NVR token assigned to the button and
 * returns it in AX with CF set so the keyboard ISR can queue it.
 */
void
bios_service_int06 (bios_regs_t __far *regs)
{
  u8 button;
  u8 index;

  button = bios_lo (regs->ax);
  if ((button & 0x80) != 0)
    {
      bios_clear_cf (regs);
      return;
    }

  switch (button)
    {
    case 0:
      index = CMOS_NVR_MOUSE1_LO;
      break;

    case 1:
      index = CMOS_NVR_MOUSE2_LO;
      break;

    default:
      bios_clear_cf (regs);
      return;
    }

  regs->ax = pc1640_keyboard_nvr_token (index);
  bios_set_cf (regs);
}
