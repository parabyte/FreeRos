#include "bios.h"

#define BIOS_POST_MIN_BASE_MEMORY_KB 512
#define BIOS_POST_OPTION_BLOCK_KB 32
#define BIOS_POST_OPTION_BLOCK_COUNT 4
#define BIOS_POST_OPTION_BLOCK_START_PHYS 0x00080000UL
#define BIOS_POST_OPTION_BLOCK_SIZE_BYTES 0x00008000UL
#define BIOS_POST_RAM_TEST_START_PHYS 0x00000800UL
#define BIOS_POST_RAM_TEST_END_PHYS 0x00098000UL
#define BIOS_POST_RAM_TEST_SAMPLED_STRIDE_PHYS 0x00001000UL
#define BIOS_POST_ROM_SEGMENT 0xFC00
#define BIOS_POST_ROS_OFFSET 0x0000U
#define BIOS_POST_ROS_SIZE 0x4000U
#define BIOS_POST_STACK_GUARD_START 0x00006800UL
#define BIOS_POST_STACK_GUARD_END 0x00007800UL
#define BIOS_POST_VDU_TEST_WORDS 16
#define BIOS_POST_WARM_BOOT_REQUEST 0x1234
#define BIOS_POST_WARM_BOOT_POSTED 0x1235

#define BIOS_POST_UART_REG_DATA 0
#define BIOS_POST_UART_REG_IER 1
#define BIOS_POST_UART_REG_LCR 3
#define BIOS_POST_UART_REG_MCR 4
#define BIOS_POST_UART_REG_LSR 5

#define BIOS_POST_UART_LSR_DATA_READY 0x01
#define BIOS_POST_UART_LSR_ERROR_MASK 0x1E
#define BIOS_POST_UART_MCR_LOOP 0x10
#define BIOS_POST_UART_MCR_DTR 0x01
#define BIOS_POST_UART_MCR_RTS 0x02

#define BIOS_POST_LPT_REG_DATA 0

#define BIOS_POST_DMA_CH3_ADDR 0x0006
#define BIOS_POST_DMA_CH3_COUNT 0x0007
#define BIOS_POST_PIT_CH1 0x0041
#define BIOS_POST_PIT_GATE_OUT 0x20

#define BIOS_POST_ATTR_SCREEN 0x07
#define BIOS_POST_ATTR_HEADER 0x70
#define BIOS_POST_ATTR_FRAME 0x07
#define BIOS_POST_ATTR_LABEL 0x07
#define BIOS_POST_ATTR_VALUE 0x0F
#define BIOS_POST_ATTR_PENDING 0x08
#define BIOS_POST_ATTR_PASS 0x0A
#define BIOS_POST_ATTR_WARN 0x0E
#define BIOS_POST_ATTR_FAIL 0x0C

#define BIOS_POST_ROW_HEADER 0
#define BIOS_POST_ROW_SUBTITLE 1
#define BIOS_POST_ROW_SUMMARY_RULE 2
#define BIOS_POST_ROW_WEBSITE 3
#define BIOS_POST_ROW_SUMMARY0 4
#define BIOS_POST_ROW_SUMMARY1 5
#define BIOS_POST_ROW_SUMMARY2 6
#define BIOS_POST_ROW_STAGE_RULE 7
#define BIOS_POST_ROW_STAGE_TITLE 8
#define BIOS_POST_ROW_STAGE_ROM 9
#define BIOS_POST_ROW_STAGE_VIDEO 10
#define BIOS_POST_ROW_STAGE_CORE 11
#define BIOS_POST_ROW_STAGE_RAM_DETECT 12
#define BIOS_POST_ROW_STAGE_RAM_TEST 13
#define BIOS_POST_ROW_STAGE_KBD 14
#define BIOS_POST_ROW_STAGE_IO 15
#define BIOS_POST_ROW_STAGE_ROM_SCAN 16
#define BIOS_POST_ROW_STAGE_BOOT 17
#define BIOS_POST_ROW_ALERT_RULE 18
#define BIOS_POST_ROW_ALERT_TITLE 19
#define BIOS_POST_ROW_ALERT_FIRST 20
#define BIOS_POST_ROW_TTY 22
#define BIOS_POST_ALERT_ROWS 2

static const u8 bios_post_status1_patterns[] = { 0x30, 0x31, 0x34, 0x14 };
static const u8 bios_post_status2_pattern = 0xA6;

static const char bios_post_fault_dma[] = "DMA";
static const char bios_post_fault_timer[] = "timer";
static const char bios_post_fault_system_status[] = "system status register";
static const char bios_post_fault_rtc[] = "real time clock";
static const char bios_post_fault_diskette[] = "diskette";
static const char bios_post_fault_serial[] = "serial port";
static const char bios_post_fault_printer[] = "printer port";
static const char bios_post_fault_mouse[] = "mouse";
static const char bios_post_stage_rom[] = "ROM checksum";
static const char bios_post_stage_video[] = "Video memory";
static const char bios_post_stage_core[] = "Core devices";
static const char bios_post_stage_ram_detect[] = "Base RAM detect";
static const char bios_post_stage_ram_test[] = "Base RAM test";
static const char bios_post_stage_kbd[] = "Keyboard / mouse";
static const char bios_post_stage_io[] = "Serial / printer";
static const char bios_post_stage_rom_scan[] = "Option ROM scan";
static const char bios_post_stage_boot[] = "Bootstrap";

static u8 bios_post_alert_count;
static u8 bios_post_alert_overflow;
static u8 bios_post_ui_active;

static u8
bios_post_text_len (const char *text)
{
  u8 len;

  len = 0;
  while (text[len] != '\0')
    len++;

  return len;
}

static u16
bios_post_phys_read16 (u32 phys)
{
  return bios_abs_read16 ((u16) (phys >> 4), (u16) (phys & 0x000FUL));
}

static void
bios_post_phys_write16 (u32 phys, u16 value)
{
  bios_abs_write16 ((u16) (phys >> 4), (u16) (phys & 0x000FUL), value);
}

static int
bios_post_warm_reset_requested (void)
{
  u16 warm_boot_flag;

  warm_boot_flag = bios_bda_read16 (BDA_WARM_BOOT_FLAG);
  return warm_boot_flag == BIOS_POST_WARM_BOOT_REQUEST
    || warm_boot_flag == BIOS_POST_WARM_BOOT_POSTED;
}

static void
bios_post_update_memory_state (u16 size_kb)
{
  bios_bda_write16 (BDA_MEMORY_SIZE_KB, size_kb);
  bios_bda_write16 (BDA_EXTRA_MEMORY_KB, size_kb > 64 ? (u16) (size_kb - 64) : 0);
}

static int
bios_post_ros_checksum_valid (void)
{
  u16 offset;
  u8 checksum;

  checksum = 0;
  for (offset = BIOS_POST_ROS_OFFSET;
       offset != (u16) (BIOS_POST_ROS_OFFSET + BIOS_POST_ROS_SIZE);
       ++offset)
    checksum = (u8) (checksum + bios_abs_read8 (BIOS_POST_ROM_SEGMENT, offset));

  return checksum == 0;
}

static void
bios_post_ui_clear_field (u8 row, u8 col, u8 width)
{
  bios_video_fill (row, col, width, ' ', BIOS_POST_ATTR_SCREEN);
}

static void
bios_post_ui_rule (u8 row, char ch)
{
  bios_video_fill (row, 0, BIOS_CFG_VIDEO_COLUMNS, ch, BIOS_POST_ATTR_FRAME);
}

static void
bios_post_ui_puts_centered (u8 row, u8 attr, const char *text)
{
  u8 len;
  u8 col;

  len = bios_post_text_len (text);
  if (len >= BIOS_CFG_VIDEO_COLUMNS)
    col = 0;
  else
    col = (u8) ((BIOS_CFG_VIDEO_COLUMNS - len) / 2U);

  bios_video_puts_at (row, col, attr, text);
}

static void __attribute__((noreturn))
bios_post_fatal_fault (const char *detail, u8 flag);

static u8
bios_post_serial_port_count (void)
{
  u8 count;

  count = 0;
  if (bios_bda_read16 (BDA_COM1_BASE) != 0)
    count++;
  if (bios_bda_read16 (BDA_COM2_BASE) != 0)
    count++;
  return count;
}

static u8
bios_post_parallel_port_count (void)
{
  u8 count;

  count = 0;
  if (bios_bda_read16 (BDA_LPT1_BASE) != 0)
    count++;
  if (bios_bda_read16 (BDA_LPT2_BASE) != 0)
    count++;
  return count;
}

static u16
bios_post_floppy_capacity_kb (u8 drive)
{
  return bios_floppy_drive_capacity_kb (drive);
}

static int
bios_post_display_is_mono (void)
{
  return bios_bda_read8 (BDA_VIDEO_MODE) == VIDEO_MODE_80X25_MONO
    || bios_bda_read16 (BDA_CRTC_PORT) == PORT_MDA_CRTC_ADDR;
}

static void
bios_post_ui_show_post_code (u8 code)
{
  bios_post_ui_clear_field (BIOS_POST_ROW_SUMMARY0, 73, 2);
  bios_video_put_hex8_at (BIOS_POST_ROW_SUMMARY0, 73, BIOS_POST_ATTR_VALUE,
			  code);
}

static void
bios_post_ui_show_display (void)
{
  u16 columns;
  u8 rows;
  u8 dimension_col;

  columns = bios_bda_read16 (BDA_VIDEO_COLUMNS);
  if (columns == 0)
    columns = BIOS_CFG_VIDEO_COLUMNS;

  rows = bios_bda_read8 (BDA_VIDEO_ROWS_MINUS_ONE);
  if (rows == 0)
    rows = BIOS_CFG_VIDEO_ROWS;
  else
    rows = (u8) (rows + 1U);

  bios_post_ui_clear_field (BIOS_POST_ROW_SUMMARY0, 37, 12);
  if (bios_post_display_is_mono ())
    {
      bios_video_puts_at (BIOS_POST_ROW_SUMMARY0, 37, BIOS_POST_ATTR_VALUE,
			  "MONO ");
      dimension_col = 42;
    }
  else
    {
      bios_video_puts_at (BIOS_POST_ROW_SUMMARY0, 37, BIOS_POST_ATTR_VALUE,
			  "COLOR ");
      dimension_col = 43;
    }

  bios_video_put_udec_at (BIOS_POST_ROW_SUMMARY0, dimension_col,
			  BIOS_POST_ATTR_VALUE, columns);
  bios_video_puts_at (BIOS_POST_ROW_SUMMARY0,
		      (u8) (dimension_col + 2U), BIOS_POST_ATTR_VALUE, "x");
  bios_video_put_udec_at (BIOS_POST_ROW_SUMMARY0,
			  (u8) (dimension_col + 3U), BIOS_POST_ATTR_VALUE,
			  rows);
}

static void
bios_post_ui_show_drives (void)
{
  u16 drive_a_kb;
  u16 drive_b_kb;

  bios_post_ui_clear_field (BIOS_POST_ROW_SUMMARY1, 11, 13);
  if (BIOS_CFG_FLOPPY_DRIVES == 0)
    {
      bios_video_puts_at (BIOS_POST_ROW_SUMMARY1, 11, BIOS_POST_ATTR_VALUE,
			  "NONE");
      return;
    }

  drive_a_kb = bios_post_floppy_capacity_kb (0);
  drive_b_kb = bios_post_floppy_capacity_kb (1);

  if (BIOS_CFG_FLOPPY_DRIVES == 1 || drive_b_kb == 0)
    {
      bios_video_puts_at (BIOS_POST_ROW_SUMMARY1, 11, BIOS_POST_ATTR_VALUE,
			  "A:");
      bios_video_put_udec_at (BIOS_POST_ROW_SUMMARY1, 13, BIOS_POST_ATTR_VALUE,
			      drive_a_kb);
      bios_video_puts_at (BIOS_POST_ROW_SUMMARY1, 16, BIOS_POST_ATTR_VALUE, "K");
      return;
    }

  if (drive_a_kb == drive_b_kb)
    {
      bios_video_put_udec_at (BIOS_POST_ROW_SUMMARY1, 11, BIOS_POST_ATTR_VALUE,
			      BIOS_CFG_FLOPPY_DRIVES);
      bios_video_puts_at (BIOS_POST_ROW_SUMMARY1, 12, BIOS_POST_ATTR_VALUE, " x ");
      bios_video_put_udec_at (BIOS_POST_ROW_SUMMARY1, 15, BIOS_POST_ATTR_VALUE,
			      drive_a_kb);
      bios_video_puts_at (BIOS_POST_ROW_SUMMARY1, 18, BIOS_POST_ATTR_VALUE, "K");
      return;
    }

  bios_video_puts_at (BIOS_POST_ROW_SUMMARY1, 11, BIOS_POST_ATTR_VALUE, "A:");
  bios_video_put_udec_at (BIOS_POST_ROW_SUMMARY1, 13, BIOS_POST_ATTR_VALUE,
			  drive_a_kb);
  bios_video_puts_at (BIOS_POST_ROW_SUMMARY1, 16, BIOS_POST_ATTR_VALUE, " B:");
  bios_video_put_udec_at (BIOS_POST_ROW_SUMMARY1, 19, BIOS_POST_ATTR_VALUE,
			  drive_b_kb);
  bios_video_puts_at (BIOS_POST_ROW_SUMMARY1, 22, BIOS_POST_ATTR_VALUE, "K");
}

static void
bios_post_ui_show_memory_pending (void)
{
  bios_post_ui_clear_field (BIOS_POST_ROW_SUMMARY0, 14, 8);
  bios_video_puts_at (BIOS_POST_ROW_SUMMARY0, 14, BIOS_POST_ATTR_PENDING,
		      "DETECT");
}

static void
bios_post_ui_show_memory_value (u16 memory_kb)
{
  bios_post_ui_clear_field (BIOS_POST_ROW_SUMMARY0, 14, 8);
  bios_video_put_udec_at (BIOS_POST_ROW_SUMMARY0, 14, BIOS_POST_ATTR_VALUE,
			  memory_kb);
  bios_video_puts_at (BIOS_POST_ROW_SUMMARY0, 17, BIOS_POST_ATTR_VALUE, " KB");
}

static void
bios_post_ui_stage (u8 row, const char *label, const char *status, u8 attr)
{
  bios_video_fill (row, 0, BIOS_CFG_VIDEO_COLUMNS, ' ', BIOS_POST_ATTR_SCREEN);
  bios_video_puts_at (row, 3, BIOS_POST_ATTR_LABEL, label);
  bios_video_fill (row, 28, 26, '.', BIOS_POST_ATTR_FRAME);
  bios_video_puts_at (row, 58, attr, status);
  bios_post_ui_clear_field (row, 65, 12);
}

static void
bios_post_ui_stage_ram_kb (u8 row, const char *label, const char *status,
			   u8 attr, u16 memory_kb)
{
  bios_post_ui_stage (row, label, status, attr);
  bios_video_put_udec_at (row, 65, BIOS_POST_ATTR_VALUE, memory_kb);
  bios_video_puts_at (row, 69, BIOS_POST_ATTR_VALUE, " KB");
}

static void
bios_post_ui_add_alert (const char *prefix, const char *detail, u8 attr)
{
  u8 row;

  if (!bios_post_ui_active)
    {
      bios_video_puts (prefix);
      bios_video_puts (": ");
      bios_video_puts (detail);
      bios_video_puts ("\r\n");
      return;
    }

  if (bios_post_alert_count >= BIOS_POST_ALERT_ROWS)
    {
      if (bios_post_alert_overflow == 0)
	{
	  row = (u8) (BIOS_POST_ROW_ALERT_FIRST + BIOS_POST_ALERT_ROWS - 1U);
	  bios_video_fill (row, 0, BIOS_CFG_VIDEO_COLUMNS, ' ',
			   BIOS_POST_ATTR_SCREEN);
	  bios_video_puts_at (row, 2, BIOS_POST_ATTR_WARN,
			      "Additional POST warnings not shown");
	  bios_post_alert_overflow = 1;
	}
      return;
    }

  row = (u8) (BIOS_POST_ROW_ALERT_FIRST + bios_post_alert_count);
  bios_post_alert_count++;
  bios_video_fill (row, 0, BIOS_CFG_VIDEO_COLUMNS, ' ', BIOS_POST_ATTR_SCREEN);
  bios_video_puts_at (row, 2, attr, prefix);
  bios_video_puts_at (row, 10, BIOS_POST_ATTR_VALUE, detail);
}

static void
bios_post_warning (const char *detail)
{
  bios_post_ui_add_alert ("WARNING", detail, BIOS_POST_ATTR_WARN);
}

static void
bios_post_banner (int warm_reset)
{
  u8 text_mode;

  bios_post_alert_count = 0;
  bios_post_alert_overflow = 0;
  bios_post_ui_active = 0;

  text_mode =
    bios_post_display_is_mono () ? VIDEO_MODE_80X25_MONO : VIDEO_MODE_80X25_COLOR;
  bios_video_set_mode (text_mode);
  bios_video_hide_cursor ();
  bios_video_clear (BIOS_POST_ATTR_SCREEN);
  bios_video_set_attribute (BIOS_POST_ATTR_VALUE);

  bios_video_fill (BIOS_POST_ROW_HEADER, 0, BIOS_CFG_VIDEO_COLUMNS, ' ',
		   BIOS_POST_ATTR_HEADER);
  bios_post_ui_puts_centered (BIOS_POST_ROW_HEADER, BIOS_POST_ATTR_HEADER,
			      BIOS_CFG_BIOS_BRAND " SYSTEM BIOS");
  bios_video_fill (BIOS_POST_ROW_SUBTITLE, 0, BIOS_CFG_VIDEO_COLUMNS, ' ',
		   BIOS_POST_ATTR_SCREEN);
  bios_post_ui_rule (BIOS_POST_ROW_SUMMARY_RULE, '=');
  bios_post_ui_puts_centered (BIOS_POST_ROW_WEBSITE, 0x0C,
			      BIOS_CFG_WEBSITE);

  bios_video_puts_at (BIOS_POST_ROW_SUMMARY0, 1, BIOS_POST_ATTR_LABEL,
		      "Base Memory:");
  bios_video_puts_at (BIOS_POST_ROW_SUMMARY0, 28, BIOS_POST_ATTR_LABEL,
		      "Display:");
  bios_video_puts_at (BIOS_POST_ROW_SUMMARY0, 53, BIOS_POST_ATTR_LABEL,
		      "Boot:");
  bios_video_puts_at (BIOS_POST_ROW_SUMMARY0, 66, BIOS_POST_ATTR_LABEL,
		      "POST:");

  bios_video_puts_at (BIOS_POST_ROW_SUMMARY1, 1, BIOS_POST_ATTR_LABEL,
		      "Diskette:");
  bios_video_puts_at (BIOS_POST_ROW_SUMMARY1, 28, BIOS_POST_ATTR_LABEL,
		      "Serial:");
  bios_video_puts_at (BIOS_POST_ROW_SUMMARY1, 46, BIOS_POST_ATTR_LABEL,
		      "Parallel:");
  bios_video_puts_at (BIOS_POST_ROW_SUMMARY1, 64, BIOS_POST_ATTR_LABEL,
		      "RTC:");

  bios_video_puts_at (BIOS_POST_ROW_SUMMARY2, 1, BIOS_POST_ATTR_LABEL,
		      "Firmware:");
  bios_video_puts_at (BIOS_POST_ROW_SUMMARY2, 29, BIOS_POST_ATTR_LABEL,
		      "Mouse:");
  bios_video_puts_at (BIOS_POST_ROW_SUMMARY2, 46, BIOS_POST_ATTR_LABEL,
		      "8087:");

  bios_post_ui_show_memory_pending ();
  bios_post_ui_show_display ();
  bios_post_ui_clear_field (BIOS_POST_ROW_SUMMARY0, 60, 5);
  bios_video_puts_at (BIOS_POST_ROW_SUMMARY0, 60, BIOS_POST_ATTR_VALUE,
		      warm_reset ? "WARM" : "COLD");
  bios_post_ui_show_post_code (warm_reset ? 0x02 : 0x03);

  bios_post_ui_show_drives ();
  bios_post_ui_clear_field (BIOS_POST_ROW_SUMMARY1, 36, 2);
  bios_video_put_udec_at (BIOS_POST_ROW_SUMMARY1, 36, BIOS_POST_ATTR_VALUE,
			  bios_post_serial_port_count ());
  bios_post_ui_clear_field (BIOS_POST_ROW_SUMMARY1, 56, 2);
  bios_video_put_udec_at (BIOS_POST_ROW_SUMMARY1, 56, BIOS_POST_ATTR_VALUE,
			  bios_post_parallel_port_count ());
  bios_post_ui_clear_field (BIOS_POST_ROW_SUMMARY1, 69, 11);
  bios_video_puts_at (BIOS_POST_ROW_SUMMARY1, 69, BIOS_POST_ATTR_VALUE,
		      (bios_work_read8 (WK_BOOT_FLAGS) & BOOT_FLAG_BATTERY_LOW)
		      != 0 ? "BATTERY LOW" : "OK");

  bios_post_ui_clear_field (BIOS_POST_ROW_SUMMARY2, 11, 8);
  bios_video_puts_at (BIOS_POST_ROW_SUMMARY2, 11, BIOS_POST_ATTR_VALUE,
		      "R");
  bios_video_put_udec_at (BIOS_POST_ROW_SUMMARY2, 12, BIOS_POST_ATTR_VALUE,
			  BIOS_CFG_ROS_RELEASE);
  bios_video_puts_at (BIOS_POST_ROW_SUMMARY2, 13, BIOS_POST_ATTR_VALUE, ".");
  bios_video_put_udec_at (BIOS_POST_ROW_SUMMARY2, 14, BIOS_POST_ATTR_VALUE,
			  BIOS_CFG_ROS_ISSUE);
  bios_post_ui_clear_field (BIOS_POST_ROW_SUMMARY2, 36, 8);
  bios_video_puts_at (BIOS_POST_ROW_SUMMARY2, 36, BIOS_POST_ATTR_VALUE,
		      BIOS_CFG_HAS_AMSTRAD_MOUSE ? "YES" : "NO");
  bios_post_ui_clear_field (BIOS_POST_ROW_SUMMARY2, 52, 13);
  bios_video_puts_at (BIOS_POST_ROW_SUMMARY2, 52, BIOS_POST_ATTR_VALUE,
		      BIOS_CFG_HAS_MATH_COPROCESSOR ? "PRESENT" : "NONE");

  bios_post_ui_rule (BIOS_POST_ROW_STAGE_RULE, '-');
  bios_video_puts_at (BIOS_POST_ROW_STAGE_TITLE, 2, BIOS_POST_ATTR_HEADER,
		      "SELF TEST");
  bios_post_ui_stage (BIOS_POST_ROW_STAGE_ROM, bios_post_stage_rom, "PASS",
		      BIOS_POST_ATTR_PASS);
  bios_post_ui_stage (BIOS_POST_ROW_STAGE_VIDEO, bios_post_stage_video,
		      warm_reset ? "SKIP" : "PASS",
		      warm_reset ? BIOS_POST_ATTR_PENDING
		      : BIOS_POST_ATTR_PASS);
  bios_post_ui_stage (BIOS_POST_ROW_STAGE_CORE, bios_post_stage_core,
		      "PENDING", BIOS_POST_ATTR_PENDING);
  bios_post_ui_stage (BIOS_POST_ROW_STAGE_RAM_DETECT,
		      bios_post_stage_ram_detect, "PENDING",
		      BIOS_POST_ATTR_PENDING);
  bios_post_ui_stage (BIOS_POST_ROW_STAGE_RAM_TEST, bios_post_stage_ram_test,
		      "PENDING", BIOS_POST_ATTR_PENDING);
  bios_post_ui_stage (BIOS_POST_ROW_STAGE_KBD, bios_post_stage_kbd, "PENDING",
		      BIOS_POST_ATTR_PENDING);
  bios_post_ui_stage (BIOS_POST_ROW_STAGE_IO, bios_post_stage_io, "PENDING",
		      BIOS_POST_ATTR_PENDING);
  bios_post_ui_stage (BIOS_POST_ROW_STAGE_ROM_SCAN, bios_post_stage_rom_scan,
		      BIOS_CFG_OPTION_ROM_SCAN_ENABLED ? "PENDING" : "SKIP",
		      BIOS_CFG_OPTION_ROM_SCAN_ENABLED ? BIOS_POST_ATTR_PENDING
		      : BIOS_POST_ATTR_PENDING);
  bios_post_ui_stage (BIOS_POST_ROW_STAGE_BOOT, bios_post_stage_boot,
		      "PENDING", BIOS_POST_ATTR_PENDING);

  bios_post_ui_rule (BIOS_POST_ROW_ALERT_RULE, '-');
  bios_video_puts_at (BIOS_POST_ROW_ALERT_TITLE, 2, BIOS_POST_ATTR_HEADER,
		      "MESSAGES");
  bios_post_ui_active = 1;
  bios_video_set_cursor (BIOS_POST_ROW_TTY, 0);
}

static void
bios_post_fault (const char *detail)
{
  bios_post_ui_add_alert (bios_str_en_error_prefix, detail,
			  BIOS_POST_ATTR_FAIL);
}

static void __attribute__((noreturn))
bios_post_fatal_fault (const char *detail, u8 flag)
{
  bios_work_write8 (WK_BOOT_FLAGS,
		    (u8) (bios_work_read8 (WK_BOOT_FLAGS) | flag));
  bios_post_fault (detail);
  bios_hw_disable_interrupts ();
  for (;;)
    bios_hw_halt ();
}

static void
bios_post_show_memory (void)
{
  u16 memory_kb;

  memory_kb = bios_bda_read16 (BDA_MEMORY_SIZE_KB);
  bios_post_ui_show_memory_value (memory_kb);
}

static void
bios_post_hardware_init (void)
{
  bios_serial_init ();
  bios_serial_debug_puts ("POST start\n");
  bios_video_debug_dump_state ("post");
  bios_dma_init ();
  bios_pic_init ();
  bios_pit_init ();
  bios_keyboard_init ();
  bios_hw_enable_interrupts ();
  bios_floppy_init ();
  bios_printer_init ();
  bios_rtc_init ();
  bios_ide_init ();
}

static void
bios_post_step (u8 code)
{
  bios_io_write (PORT_DEAD_DIAG, code);
  if (bios_post_ui_active)
    bios_post_ui_show_post_code (code);
}

static int
bios_post_dma_test_register (u16 port)
{
  bios_hw_out8 (0x00, PORT_DMA1_CLEAR_FF);
  bios_hw_out8 (0x55, port);
  bios_hw_out8 (0xAA, port);
  bios_hw_out8 (0x00, PORT_DMA1_CLEAR_FF);
  if (bios_hw_in8 (port) != 0x55 || bios_hw_in8 (port) != 0xAA)
    return 0;

  bios_hw_out8 (0x00, PORT_DMA1_CLEAR_FF);
  bios_hw_out8 (0xAA, port);
  bios_hw_out8 (0x55, port);
  bios_hw_out8 (0x00, PORT_DMA1_CLEAR_FF);
  return bios_hw_in8 (port) == 0xAA && bios_hw_in8 (port) == 0x55;
}

static int
bios_post_dma_test (void)
{
  u16 port;

  for (port = 0; port != 8; ++port)
    if (!bios_post_dma_test_register (port))
      return 0;

  return 1;
}

static int
bios_post_timer_test (void)
{
  u8 saved_port61;
  u16 delay;

  saved_port61 = bios_io_read (PORT_PPI_PORT_B);
  bios_io_write (PORT_PPI_PORT_B,
		 (u8) ((saved_port61 | PORT61_SPEAKER_GATE)
		       & (u8) ~PORT61_SPEAKER_DATA));

  bios_hw_out8 (0xB0, PORT_PIT_MODE);
  if ((bios_hw_in8 (PORT_SYSSTAT2_RD) & BIOS_POST_PIT_GATE_OUT) != 0)
    goto fail;

  /*
   * Match the original PC1640 ROS test: mode 0 on PIT channel 2 with a
   * one-shot count of 1.  OUT2 should start low and return high almost
   * immediately once the count expires.
   */
  bios_hw_out8 (0x01, PORT_PIT_CH2);
  bios_hw_out8 (0x00, PORT_PIT_CH2);

  for (delay = 0; delay != 6; ++delay)
    bios_hw_pause ();

  if ((bios_hw_in8 (PORT_SYSSTAT2_RD) & BIOS_POST_PIT_GATE_OUT) != 0)
    {
      bios_io_write (PORT_PPI_PORT_B, saved_port61);
      return 1;
    }

fail:
  bios_io_write (PORT_PPI_PORT_B, saved_port61);
  return 0;
}

static int
bios_post_system_status_test (void)
{
  u8 saved_port61;
  u8 saved_port64;
  u8 saved_port65;
  u8 i;

  saved_port61 = bios_io_read (PORT_PPI_PORT_B);
  saved_port64 = bios_work_read8 (WK_PORT64);
  saved_port65 = bios_work_read8 (WK_PORT65);

  bios_io_write (PORT_PPI_PORT_B, (u8) (saved_port61 | PORT61_STATUS_MODE));
  for (i = 0; i != sizeof (bios_post_status1_patterns); ++i)
    {
      u8 value;

      value = bios_post_status1_patterns[i];
      bios_io_write (PORT_SYSSTAT1_WR, value);
      if (bios_io_read (PORT_KBD_DATA) != (u8) ((value | 0x0D) & 0x7F))
	goto fail;

      value = (u8) ~ value;
      bios_io_write (PORT_SYSSTAT1_WR, value);
      if (bios_io_read (PORT_KBD_DATA) != (u8) ((value | 0x0D) & 0x7F))
	goto fail;
    }

  bios_io_write (PORT_SYSSTAT2_WR, bios_post_status2_pattern);
  bios_io_write (PORT_PPI_PORT_B,
		 (u8) ((saved_port61 | PORT61_STATUS_MODE)
		       & (u8) ~PORT61_NVR_LOW_NIBBLE));
  if (bios_io_read (PORT_SYSSTAT2_RD)
      != (u8) (bios_post_status2_pattern >> 4))
    goto fail;

  bios_io_write (PORT_PPI_PORT_B,
		 (u8) (saved_port61 | PORT61_STATUS_MODE
			| PORT61_NVR_LOW_NIBBLE));
  if (bios_io_read (PORT_SYSSTAT2_RD)
      != (u8) (bios_post_status2_pattern & 0x0F))
    goto fail;

  bios_io_write (PORT_SYSSTAT1_WR, saved_port64);
  bios_io_write (PORT_SYSSTAT2_WR, saved_port65);
  bios_io_write (PORT_PPI_PORT_B, saved_port61);
  return 1;

fail:
  bios_io_write (PORT_SYSSTAT1_WR, saved_port64);
  bios_io_write (PORT_SYSSTAT2_WR, saved_port65);
  bios_io_write (PORT_PPI_PORT_B, saved_port61);
  return 0;
}

static int
bios_post_rtc_test (void)
{
  u8 saved_value;
  u8 seconds;
  u16 ticks;

  saved_value = bios_cmos_read (CMOS_NVR_RAMDISK_SIZE);
  bios_cmos_write (CMOS_NVR_RAMDISK_SIZE, 0x55);
  if (bios_cmos_read (CMOS_NVR_RAMDISK_SIZE) != 0x55)
    goto fail;

  bios_cmos_write (CMOS_NVR_RAMDISK_SIZE, 0xAA);
  if (bios_cmos_read (CMOS_NVR_RAMDISK_SIZE) != 0xAA)
    goto fail;

  bios_cmos_write (CMOS_NVR_RAMDISK_SIZE, saved_value);
  seconds = bios_cmos_read (CMOS_SECONDS);
  for (ticks = 0; ticks != 40; ++ticks)
    {
      bios_wait_timer_ticks (1);
      if (bios_cmos_read (CMOS_SECONDS) != seconds)
	return 1;
    }

fail:
  bios_cmos_write (CMOS_NVR_RAMDISK_SIZE, saved_value);
  return 0;
}

static int
bios_post_serial_test (void)
{
  u16 base;
  u8 saved_ier;
  u8 saved_lcr;
  u8 saved_mcr;
  u16 poll;

  base = BIOS_CFG_COM1_BASE;
  if (base == 0)
    return 0;

  saved_ier = bios_hw_in8 ((u16) (base + BIOS_POST_UART_REG_IER));
  saved_lcr = bios_hw_in8 ((u16) (base + BIOS_POST_UART_REG_LCR));
  saved_mcr = bios_hw_in8 ((u16) (base + BIOS_POST_UART_REG_MCR));

  bios_hw_out8 (0x00, (u16) (base + BIOS_POST_UART_REG_IER));
  bios_hw_out8 (0x03, (u16) (base + BIOS_POST_UART_REG_LCR));
  bios_hw_out8 ((u8) (BIOS_POST_UART_MCR_LOOP | BIOS_POST_UART_MCR_DTR
		      | BIOS_POST_UART_MCR_RTS),
		(u16) (base + BIOS_POST_UART_REG_MCR));

  bios_hw_out8 (0x41, (u16) (base + BIOS_POST_UART_REG_DATA));
  for (poll = 0; poll != 0x2000; ++poll)
    {
      if ((bios_hw_in8 ((u16) (base + BIOS_POST_UART_REG_LSR))
	   & BIOS_POST_UART_LSR_DATA_READY) != 0)
	break;
      bios_hw_pause ();
    }

  if (poll == 0x2000
      || (bios_hw_in8 ((u16) (base + BIOS_POST_UART_REG_DATA)) != 0x41)
      || (bios_hw_in8 ((u16) (base + BIOS_POST_UART_REG_LSR))
	  & BIOS_POST_UART_LSR_ERROR_MASK) != 0)
    goto fail;

  bios_hw_out8 (saved_ier, (u16) (base + BIOS_POST_UART_REG_IER));
  bios_hw_out8 (saved_lcr, (u16) (base + BIOS_POST_UART_REG_LCR));
  bios_hw_out8 (saved_mcr, (u16) (base + BIOS_POST_UART_REG_MCR));
  return 1;

fail:
  bios_hw_out8 (saved_ier, (u16) (base + BIOS_POST_UART_REG_IER));
  bios_hw_out8 (saved_lcr, (u16) (base + BIOS_POST_UART_REG_LCR));
  bios_hw_out8 (saved_mcr, (u16) (base + BIOS_POST_UART_REG_MCR));
  return 0;
}

static int
bios_post_printer_test (void)
{
  u8 saved;

  saved = bios_hw_in8 (PORT_LPT1_DATA);
  bios_hw_out8 (0xAA, PORT_LPT1_DATA);
  if (bios_hw_in8 (PORT_LPT1_DATA) != 0xAA)
    goto fail;

  bios_hw_out8 (0x55, PORT_LPT1_DATA);
  if (bios_hw_in8 (PORT_LPT1_DATA) != 0x55)
    goto fail;

  bios_hw_out8 (saved, PORT_LPT1_DATA);
  return 1;

fail:
  bios_hw_out8 (saved, PORT_LPT1_DATA);
  return 0;
}

static int
bios_post_mouse_test (void)
{
  if (!BIOS_CFG_HAS_AMSTRAD_MOUSE)
    return 1;

  bios_io_write (PORT_MOUSE_X, 0x00);
  if ((signed char) bios_io_read (PORT_MOUSE_X) != 0)
    return 0;

  bios_io_write (PORT_MOUSE_Y, 0x00);
  return (signed char) bios_io_read (PORT_MOUSE_Y) == 0;
}

static int
bios_post_ram_sample_test (u32 phys)
{
  u16 address_pattern;
  u16 saved;

  saved = bios_post_phys_read16 (phys);
  address_pattern = (u16) (((phys >> 4) ^ phys) & 0xFFFFUL);

  bios_post_phys_write16 (phys, 0xAA55);
  if (bios_post_phys_read16 (phys) != 0xAA55)
    goto fail;

  bios_post_phys_write16 (phys, 0x55AA);
  if (bios_post_phys_read16 (phys) != 0x55AA)
    goto fail;

  bios_post_phys_write16 (phys, address_pattern);
  if (bios_post_phys_read16 (phys) != address_pattern)
    goto fail;

  bios_post_phys_write16 (phys, saved);
  return 1;

fail:
  bios_post_phys_write16 (phys, saved);
  return 0;
}

static u8
bios_post_run_early_device_tests (void)
{
  u8 warnings;

  warnings = 0;
  bios_post_step (0x06);
  if (!bios_post_dma_test ())
    {
      bios_post_ui_stage (BIOS_POST_ROW_STAGE_CORE, bios_post_stage_core,
			  "FAIL", BIOS_POST_ATTR_FAIL);
      bios_post_fatal_fault (bios_post_fault_dma, 0);
    }

  bios_post_step (0x07);
  if (!bios_post_timer_test ())
    {
      bios_post_ui_stage (BIOS_POST_ROW_STAGE_CORE, bios_post_stage_core,
			  "FAIL", BIOS_POST_ATTR_FAIL);
      bios_post_fatal_fault (bios_post_fault_timer, 0);
    }

  bios_post_step (0x08);
  if (!bios_post_system_status_test ())
    {
      bios_post_fault (bios_post_fault_system_status);
      warnings++;
    }

  bios_post_step (0x09);
  if (!bios_post_rtc_test ())
    {
      bios_post_fault (bios_post_fault_rtc);
      warnings++;
    }

  bios_post_step (0x0A);
  if (!bios_floppy_post_test ())
    {
      bios_post_fault (bios_post_fault_diskette);
      warnings++;
    }

  return warnings;
}

static u8
bios_post_run_late_device_tests (void)
{
  u8 warnings;

  warnings = 0;
  bios_post_step (0x0C);
  if (!bios_post_serial_test ())
    {
      bios_post_fault (bios_post_fault_serial);
      warnings++;
    }

  bios_post_step (0x0D);
  if (!bios_post_printer_test ())
    {
      bios_post_fault (bios_post_fault_printer);
      warnings++;
    }

  return warnings;
}

static int
bios_post_video_memory_test (void)
{
  u16 page_offset;
  u16 video_seg;
  u16 saved[BIOS_POST_VDU_TEST_WORDS];
  u16 i;

  video_seg =
    bios_bda_read8 (BDA_VIDEO_MODE) == VIDEO_MODE_80X25_MONO ? 0xB000 : 0xB800;
  page_offset = bios_bda_read16 (BDA_VIDEO_PAGE_OFFSET);
  for (i = 0; i != BIOS_POST_VDU_TEST_WORDS; ++i)
    saved[i] = bios_abs_read16 (video_seg, (u16) (page_offset + i * 2U));

  for (i = 0; i != BIOS_POST_VDU_TEST_WORDS; ++i)
    bios_abs_write16 (video_seg, (u16) (page_offset + i * 2U), 0xAA55);
  for (i = 0; i != BIOS_POST_VDU_TEST_WORDS; ++i)
    if (bios_abs_read16 (video_seg, (u16) (page_offset + i * 2U)) != 0xAA55)
      goto fail;

  for (i = 0; i != BIOS_POST_VDU_TEST_WORDS; ++i)
    bios_abs_write16 (video_seg, (u16) (page_offset + i * 2U), 0x55AA);
  for (i = 0; i != BIOS_POST_VDU_TEST_WORDS; ++i)
    if (bios_abs_read16 (video_seg, (u16) (page_offset + i * 2U)) != 0x55AA)
      goto fail;

  for (i = 0; i != BIOS_POST_VDU_TEST_WORDS; ++i)
    bios_abs_write16 (video_seg, (u16) (page_offset + i * 2U), saved[i]);
  return 1;

fail:
  for (i = 0; i != BIOS_POST_VDU_TEST_WORDS; ++i)
    bios_abs_write16 (video_seg, (u16) (page_offset + i * 2U), saved[i]);
  return 0;
}

static int
bios_post_ram_block_present (u32 phys)
{
  u32 mirror_phys;
  u16 pattern;
  u16 mirror_pattern;
  u16 saved;
  u16 mirror_saved;
  int present;

  mirror_phys = phys - BIOS_POST_OPTION_BLOCK_SIZE_BYTES;
  pattern = (u16) (phys >> 4);
  mirror_pattern = (u16) ~ pattern;
  saved = bios_post_phys_read16 (phys);
  mirror_saved = bios_post_phys_read16 (mirror_phys);

  bios_post_phys_write16 (mirror_phys, mirror_pattern);
  bios_post_phys_write16 (phys, pattern);
  present = bios_post_phys_read16 (phys) == pattern
    && bios_post_phys_read16 (mirror_phys) == mirror_pattern;

  bios_post_phys_write16 (phys, saved);
  bios_post_phys_write16 (mirror_phys, mirror_saved);
  return present;
}

static u16
bios_post_detect_base_memory_kb (void)
{
  u16 size_kb;
  u32 phys;

  size_kb = BIOS_POST_MIN_BASE_MEMORY_KB;
  for (phys = BIOS_POST_OPTION_BLOCK_START_PHYS;
       phys < BIOS_POST_RAM_TEST_END_PHYS;
       phys += BIOS_POST_OPTION_BLOCK_SIZE_BYTES)
    {
      if (!bios_post_ram_block_present (phys))
	break;
      size_kb = (u16) (size_kb + BIOS_POST_OPTION_BLOCK_KB);
    }

  return size_kb;
}

static int
bios_post_run_ram_tests (u16 size_kb)
{
  u32 end_phys;
  u32 phys;

  end_phys = (u32) size_kb << 10;
  if (end_phys > BIOS_POST_RAM_TEST_END_PHYS)
    end_phys = BIOS_POST_RAM_TEST_END_PHYS;

  if (end_phys <= (BIOS_POST_RAM_TEST_START_PHYS + 2U))
    return 1;

  for (phys = BIOS_POST_RAM_TEST_START_PHYS; phys < end_phys;
       phys += BIOS_POST_RAM_TEST_SAMPLED_STRIDE_PHYS)
    {
      u32 tail_phys;

      if (!bios_post_ram_sample_test (phys))
	return 0;

      tail_phys = phys + BIOS_POST_RAM_TEST_SAMPLED_STRIDE_PHYS - 2U;
      if (tail_phys >= end_phys)
	tail_phys = end_phys - 2U;

      if (tail_phys != phys && !bios_post_ram_sample_test (tail_phys))
	return 0;
    }

  return 1;
}

void
bios_post_cold_boot (void)
{
  u8 boot_flags;
  u8 early_warnings;
  u8 late_warnings;
  u16 detected_kb;
  int keyboard_ok;
  int mouse_ok;
  int warm_reset;

  bios_io_write (PORT_DEAD_DIAG, 0x01);
  warm_reset = bios_post_warm_reset_requested ();
  bios_bda_write16 (BDA_WARM_BOOT_FLAG, 0x0000);
  bios_post_hardware_init ();

  boot_flags = bios_work_read8 (WK_BOOT_FLAGS);
  if (warm_reset)
    boot_flags |= BOOT_FLAG_WARM;
  else
    boot_flags &= (u8) ~ BOOT_FLAG_WARM;
  bios_work_write8 (WK_BOOT_FLAGS, boot_flags);

  bios_io_write (PORT_DEAD_DIAG, 0x02);
  if (!bios_post_ros_checksum_valid ())
    bios_post_fatal_fault (bios_str_en_ros_checksum, BOOT_FLAG_ROS_FAULT);

  if (!warm_reset)
    {
      bios_io_write (PORT_DEAD_DIAG, 0x03);
      if (!bios_post_video_memory_test ())
	bios_post_fatal_fault (bios_str_en_vdu_ram, BOOT_FLAG_VDU_FAULT);
    }

  bios_post_banner (warm_reset);

  if (!warm_reset && BIOS_CFG_POST_SPACE_INVADERS_SOUND)
    bios_play_space_invaders_effect ();

  if ((bios_work_read8 (WK_BOOT_FLAGS) & BOOT_FLAG_BATTERY_LOW) != 0)
    bios_post_warning (bios_str_en_battery_warning);

  if (!warm_reset)
    {
      early_warnings = bios_post_run_early_device_tests ();
      bios_post_ui_stage (BIOS_POST_ROW_STAGE_CORE, bios_post_stage_core,
			  early_warnings == 0 ? "PASS" : "WARN",
			  early_warnings == 0 ? BIOS_POST_ATTR_PASS
			  : BIOS_POST_ATTR_WARN);
    }
  else
    bios_post_ui_stage (BIOS_POST_ROW_STAGE_CORE, bios_post_stage_core, "SKIP",
			BIOS_POST_ATTR_PENDING);

  if (!warm_reset)
    {
      bios_post_step (0x04);
      detected_kb = bios_post_detect_base_memory_kb ();
      bios_post_update_memory_state (detected_kb);
      bios_io_write (PORT_SYSSTAT2_WR, bios_build_status2 ());
      if (detected_kb != BIOS_CFG_BASE_MEMORY_KB)
	{
	  bios_post_ui_stage_ram_kb (BIOS_POST_ROW_STAGE_RAM_DETECT,
				     bios_post_stage_ram_detect, "FAIL",
				     BIOS_POST_ATTR_FAIL, detected_kb);
	  bios_post_fatal_fault ("RAM", BOOT_FLAG_RAM_FAULT);
	}

      bios_post_ui_stage_ram_kb (BIOS_POST_ROW_STAGE_RAM_DETECT,
				 bios_post_stage_ram_detect, "PASS",
				 BIOS_POST_ATTR_PASS, detected_kb);

      bios_post_step (0x05);
      bios_hw_disable_interrupts ();
      if (!bios_post_run_ram_tests (detected_kb))
	{
	  bios_hw_enable_interrupts ();
	  bios_post_ui_stage (BIOS_POST_ROW_STAGE_RAM_TEST,
			      bios_post_stage_ram_test, "FAIL",
			      BIOS_POST_ATTR_FAIL);
	  bios_post_fatal_fault ("RAM", BOOT_FLAG_RAM_FAULT);
	}
      bios_hw_enable_interrupts ();
      bios_post_ui_stage (BIOS_POST_ROW_STAGE_RAM_TEST,
			  bios_post_stage_ram_test, "PASS",
			  BIOS_POST_ATTR_PASS);
    }
  else
    {
      bios_post_update_memory_state (BIOS_CFG_BASE_MEMORY_KB);
      bios_post_ui_stage_ram_kb (BIOS_POST_ROW_STAGE_RAM_DETECT,
				 bios_post_stage_ram_detect, "SKIP",
				 BIOS_POST_ATTR_PENDING,
				 BIOS_CFG_BASE_MEMORY_KB);
      bios_post_ui_stage (BIOS_POST_ROW_STAGE_RAM_TEST,
			  bios_post_stage_ram_test, "SKIP",
			  BIOS_POST_ATTR_PENDING);
    }

  keyboard_ok = bios_keyboard_self_test ();
  if (!keyboard_ok)
    {
      boot_flags =
	(u8) (bios_work_read8 (WK_BOOT_FLAGS) | BOOT_FLAG_KBD_FAULT);
      bios_work_write8 (WK_BOOT_FLAGS, boot_flags);
    }

  bios_post_step (0x0B);
  mouse_ok = bios_post_mouse_test ();
  if (!mouse_ok)
    bios_post_fault (bios_post_fault_mouse);

  if (keyboard_ok && mouse_ok)
    bios_post_ui_stage (BIOS_POST_ROW_STAGE_KBD, bios_post_stage_kbd, "PASS",
			BIOS_POST_ATTR_PASS);
  else
    bios_post_ui_stage (BIOS_POST_ROW_STAGE_KBD, bios_post_stage_kbd, "WARN",
			BIOS_POST_ATTR_WARN);

  if (!warm_reset)
    {
      late_warnings = bios_post_run_late_device_tests ();
      bios_post_ui_stage (BIOS_POST_ROW_STAGE_IO, bios_post_stage_io,
			  late_warnings == 0 ? "PASS" : "WARN",
			  late_warnings == 0 ? BIOS_POST_ATTR_PASS
			  : BIOS_POST_ATTR_WARN);
    }
  else
    bios_post_ui_stage (BIOS_POST_ROW_STAGE_IO, bios_post_stage_io, "SKIP",
			BIOS_POST_ATTR_PENDING);

  bios_post_show_memory ();

  if ((bios_work_read8 (WK_BOOT_FLAGS) & BOOT_FLAG_KBD_FAULT) != 0)
    bios_post_fault (bios_str_en_check_keyboard_mouse);

  bios_io_write (PORT_NMI_MASK, 0x80);

  if (BIOS_CFG_OPTION_ROM_SCAN_ENABLED)
    {
      bios_post_ui_stage (BIOS_POST_ROW_STAGE_ROM_SCAN, bios_post_stage_rom_scan,
			  "SCAN", BIOS_POST_ATTR_HEADER);
      bios_option_rom_scan (BIOS_CFG_OPTION_ROM_SCAN_START,
			    BIOS_CFG_OPTION_ROM_SCAN_END,
			    BIOS_CFG_OPTION_ROM_SCAN_STEP);
      bios_post_ui_stage (BIOS_POST_ROW_STAGE_ROM_SCAN,
			  bios_post_stage_rom_scan, "PASS",
			  BIOS_POST_ATTR_PASS);
    }

  bios_post_ui_stage (BIOS_POST_ROW_STAGE_BOOT, bios_post_stage_boot, "BOOT",
		      BIOS_POST_ATTR_HEADER);
  bios_post_step (0x19);
  bios_video_set_cursor (BIOS_POST_ROW_TTY, 0);
  bios_invoke_int19 ();
  bios_post_ui_stage (BIOS_POST_ROW_STAGE_BOOT, bios_post_stage_boot, "FAIL",
		      BIOS_POST_ATTR_FAIL);
  bios_boot_failure ();
}
