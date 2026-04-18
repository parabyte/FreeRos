/* ================================================
 * FreeRos BIOS
 * post.c: Power-On Self-Test implementation
 * ================================================ */

#include "bios.h"
#include "machine.h"

/* ================================================
 * Constants and Defines
 * ================================================ */

#define BIOS_POST_MIN_BASE_MEMORY_KB 512
#define BIOS_POST_OPTION_BLOCK_KB 32
#define BIOS_POST_OPTION_BLOCK_COUNT 4
#define BIOS_POST_OPTION_BLOCK_START_PHYS 0x00080000UL
#define BIOS_POST_OPTION_BLOCK_SIZE_BYTES 0x00008000UL
#define BIOS_POST_RAM_TEST_START_PHYS 0x00000000UL
#define BIOS_POST_RAM_TEST_END_PHYS 0x000A0000UL
#define BIOS_POST_ROM_SEGMENT 0xFC00
#define BIOS_POST_ROS_OFFSET 0x0000U
#define BIOS_POST_ROS_SIZE 0x4000U
#define BIOS_POST_STACK_GUARD_START 0x00006800UL
#define BIOS_POST_STACK_GUARD_END 0x00007800UL
#if BIOS_CFG_EXECUTE_IN_PLACE
/*
 * In XIP mode SS must equal CS so the compiler's push-ss/pop-ds idiom
 * keeps DS pointing at ROM.  Use the A20-wrap trick: FC00:B800 maps to
 * physical 0x7800 (top of the guard window).
 */
#define BIOS_POST_TEMP_STACK_SEGMENT BIOS_ROM_SEGMENT
#define BIOS_POST_TEMP_STACK_OFFSET                                             \
  ((u16) (BIOS_POST_STACK_GUARD_END - 0xFC000UL + 0x100000UL))
#else
#define BIOS_POST_TEMP_STACK_SEGMENT ((u16) (BIOS_POST_STACK_GUARD_START >> 4))
#define BIOS_POST_TEMP_STACK_OFFSET                                             \
  ((u16) (BIOS_POST_STACK_GUARD_END - BIOS_POST_STACK_GUARD_START))
#endif
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

#define BIOS_POST_CORE_TESTS_ENABLED                                           \
  (BIOS_CFG_POST_DMA_TEST_ENABLED || BIOS_CFG_POST_TIMER_TEST_ENABLED          \
   || BIOS_CFG_POST_SYSTEM_STATUS_TEST_ENABLED                                 \
   || BIOS_CFG_POST_RTC_TEST_ENABLED)
#define BIOS_POST_IO_TESTS_ENABLED                                             \
  (BIOS_CFG_POST_SERIAL_TEST_ENABLED || BIOS_CFG_POST_PRINTER_TEST_ENABLED)
#define BIOS_POST_KBD_STAGE_ENABLED                                            \
  (BIOS_CFG_POST_KEYBOARD_TEST_ENABLED || BIOS_CFG_POST_MOUSE_TEST_ENABLED)

#if BIOS_CFG_POST_PRETTY_WAIT_PANEL
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
#define BIOS_POST_ROW_FIXED_DISK_FIRST 20
#define BIOS_POST_ROW_ALERT_FIRST 22
#define BIOS_POST_ROW_TTY 24
#define BIOS_POST_FIXED_DISK_ROWS 2
#define BIOS_POST_ALERT_ROWS 2
#else
#define BIOS_POST_ROW_TTY 0
#endif

#if !BIOS_CFG_POST_PRETTY_WAIT_PANEL
#define bios_post_ui_stage(row, label, status, attr) ((void) 0)
#define bios_post_ui_stage_ram_kb(row, label, status, attr, kb) ((void) 0)
#define bios_post_ui_set_boot_line(text, attr) ((void) 0)
#endif

#if BIOS_CFG_POST_VERBOSE_DEBUG
#define bios_post_debug_puts(x) bios_serial_debug_puts(x)
#else
#define bios_post_debug_puts(x) ((void)0)
#endif

/* ================================================
 * Static Data Tables
 * ================================================ */

static const u8 bios_post_status1_patterns[] = { 0x30, 0x31, 0x34, 0x14 };
static const u8 bios_post_status2_pattern = 0xA6;

static const char bios_post_fault_dma[] = "DMA";
static const char bios_post_fault_timer[] = "timer";
static const char bios_post_fault_system_status[] = "sts";
static const char bios_post_fault_rtc[] = "RTC";
static const char bios_post_fault_interrupt_controller[] = "PIC";
static const char bios_post_fault_diskette[] = "FDC";
static const char bios_post_fault_serial[] = "COM";
static const char bios_post_fault_printer[] = "LPT";
static const char bios_post_fault_mouse[] = "MS";
#if BIOS_CFG_POST_PRETTY_WAIT_PANEL
static const char bios_post_stage_rom[] = "ROM checksum";
static const char bios_post_stage_video[] = "Video memory";
static const char bios_post_stage_core[] = "Core devices";
static const char bios_post_stage_ram_detect[] = "Base RAM detect";
static const char bios_post_stage_ram_test[] = "Base RAM test";
static const char bios_post_stage_kbd[] = "Keyboard / mouse";
static const char bios_post_stage_io[] = "Serial / printer";
static const char bios_post_stage_rom_scan[] = "Option ROM scan";
static const char bios_post_stage_boot[] = "Bootstrap";
#endif

static u8 bios_post_alert_count;
static u8 bios_post_alert_overflow;
static u8 bios_post_ui_active;

#if BIOS_CFG_POST_PRETTY_WAIT_PANEL

/* ================================================
 * Low-Level Utility Helpers
 * ================================================ */

static u8
bios_post_text_len (const char *text)
{
  u8 len;

  len = 0;
  while (text[len] != '\0')
    len++;

  return len;
}

#endif /* BIOS_CFG_POST_PRETTY_WAIT_PANEL — text_len is panel-only */

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

static void
bios_post_restore_rom_segments (void)
{
  asm volatile ("mov %0, %%ax\n\t"
                "mov %%ax, %%ds\n\t"
                "mov %%ax, %%es"
                :
                : "i" (BIOS_ROM_SEGMENT)
                : "ax", "memory");
}

static u16
bios_post_base_memory_floor_kb (void)
{
  return BIOS_POST_MIN_BASE_MEMORY_KB;
}

static u16
bios_post_option_block_kb (void)
{
  return BIOS_POST_OPTION_BLOCK_KB;
}

static u32
bios_post_option_block_size_bytes (void)
{
  return (u32) bios_post_option_block_kb () << 10;
}

static u32
bios_post_option_block_start_phys (void)
{
  return (u32) bios_post_base_memory_floor_kb () << 10;
}

static u32
bios_post_ram_test_end_phys (void)
{
  return BIOS_POST_RAM_TEST_END_PHYS;
}

static int
bios_post_warm_reset_requested (void)
{
  u16 warm_boot_flag;

  warm_boot_flag = bios_bda_read16 (BDA_WARM_BOOT_FLAG);
  return warm_boot_flag == BIOS_POST_WARM_BOOT_REQUEST
    || warm_boot_flag == BIOS_POST_WARM_BOOT_POSTED;
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

#if BIOS_CFG_POST_PRETTY_WAIT_PANEL

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
  if (!bios_post_ui_active)
    return;
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

static u16
bios_post_fixed_disk_size_mb (u32 total_sectors)
{
  u32 size_mb;

  size_mb = (total_sectors + 1024UL) >> 11;
  if (size_mb == 0 && total_sectors != 0)
    size_mb = 1;
  if (size_mb > 65535UL)
    size_mb = 65535UL;
  return (u16) size_mb;
}

static void
bios_post_ui_show_fixed_disks (void)
{
  u8 index;

  for (index = 0; index != BIOS_POST_FIXED_DISK_ROWS; ++index)
    bios_video_fill ((u8) (BIOS_POST_ROW_FIXED_DISK_FIRST + index), 0,
                     BIOS_CFG_VIDEO_COLUMNS, ' ', BIOS_POST_ATTR_SCREEN);

  /* XTIDE option ROM sets BDA_HARD_DISK_COUNT during its INT 19h init.
     At this point in POST the XTIDE has only hooked INT 19h, so drive
     count is not yet known.  The panel shows nothing for fixed disks. */
  (void) index;
}

static void
bios_post_ui_set_boot_line (const char *text, u8 attr)
{
  bios_video_fill (BIOS_POST_ROW_TTY, 0, BIOS_CFG_VIDEO_COLUMNS, ' ',
                   BIOS_POST_ATTR_SCREEN);
  bios_video_puts_at (BIOS_POST_ROW_TTY, 0, attr, text);
  bios_video_set_cursor (BIOS_POST_ROW_TTY, 0);
}

/* ----------------------------------------------------------------
   Initial boot banner (shown before POST, dismissed by ESC or timeout)
   ---------------------------------------------------------------- */

#if BIOS_CFG_INITIAL_BANNER_ENABLED

#if BIOS_CFG_INITIAL_BANNER_STYLE == 1
/* IBM block-letter logo (72 wide x 16 tall). */
static const char bios_initial_banner_text[] =
  "\r\n"
  "  IIIIIIIIII     BBBBBBBBBBBBBBBBB        MMMMMMMM               MMMMMMMM\r\n"
  "  I::::::::I     B::::::::::::::::B       M:::::::M             M:::::::M\r\n"
  "  I::::::::I     B::::::BBBBBB:::::B      M::::::::M           M::::::::M\r\n"
  "  II::::::II     BB:::::B     B:::::B     M:::::::::M         M:::::::::M\r\n"
  "    I::::I         B::::B     B:::::B     M::::::::::M       M::::::::::M\r\n"
  "    I::::I         B::::B     B:::::B     M:::::::::::M     M:::::::::::M\r\n"
  "    I::::I         B::::BBBBBB:::::B      M:::::::M::::M   M::::M:::::::M\r\n"
  "    I::::I         B:::::::::::::BB       M::::::M M::::M M::::M M::::::M\r\n"
  "    I::::I         B::::BBBBBB:::::B      M::::::M  M::::M::::M  M::::::M\r\n"
  "    I::::I         B::::B     B:::::B     M::::::M   M:::::::M   M::::::M\r\n"
  "    I::::I         B::::B     B:::::B     M::::::M    M:::::M    M::::::M\r\n"
  "    I::::I         B::::B     B:::::B     M::::::M     MMMMM     M::::::M\r\n"
  "  II::::::II     BB:::::BBBBBB::::::B     M::::::M               M::::::M\r\n"
  "  I::::::::I     B:::::::::::::::::B      M::::::M               M::::::M\r\n"
  "  I::::::::I     B::::::::::::::::B       M::::::M               M::::::M\r\n"
  "  IIIIIIIIII     BBBBBBBBBBBBBBBBB        MMMMMMMM               MMMMMMMM\r\n";
#define BIOS_BANNER_LINES 18

#elif BIOS_CFG_INITIAL_BANNER_STYLE == 2
/* Amstrad plain ASCII-art logo (57 wide x 7 tall). */
static const char bios_initial_banner_text[] =
  "\r\n\r\n\r\n\r\n"
  "             __  __  _____ _______ _____            _____\r\n"
  "       /\\   |  \\/  |/ ____|__   __|  __ \\     /\\   |  __ \\\r\n"
  "      /  \\  | \\  / | (___    | |  | |__) |   /  \\  | |  | |\r\n"
  "     / /\\ \\ | |\\/| |\\___ \\   | |  |  _  /   / /\\ \\ | |  | |\r\n"
  "    / ____ \\| |  | |____) |  | |  | | \\ \\  / ____ \\| |__| |\r\n"
  "   /_/    \\_\\_|  |_|_____/   |_|  |_|  \\_\\/_/    \\_\\_____/\r\n";
#define BIOS_BANNER_LINES 10

#elif BIOS_CFG_INITIAL_BANNER_STYLE == 3
/* Amstrad backslash-heavy logo (wide - wraps on 80-col display). */
static const char bios_initial_banner_text[] =
  "\r\n"
  " _/\\\\\\\\\\\\\\\\\\_____/\\\\\\\\______/\\\\\\\\_____/\\\\\\\\\\\\\\\\\\\\\\_"
  "___/\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_____/\\\\\\\\\\\\\\\\\\_________/\\\\\\\\\\\\\\\\\\"
  "\\_____/\\\\\\\\\\\\\\\\\\\\\\\\_\r\n"
  " _/\\\\\\\\\\\\\\\\\\\\\\\\\\__\\/\\\\\\\\\\\\________/\\\\\\\\\\\\_"
  "__/\\\\\\/////////\\\\\\_\\///////\\\\\\//////___/\\\\\\///////\\\\\\_"
  "____/\\\\\\\\\\\\\\\\\\\\\\\\\\__\\/\\\\\\////////\\\\\\_\r\n"
  " _/\\\\\\/////////\\\\\\_\\/\\\\\\//\\\\\\____/\\\\\\//\\\\\\"
  "__\\//\\\\\\______\\///________\\/\\\\\\_______\\/\\\\\\_____\\/\\\\\\"
  "____/\\\\\\/////////\\\\\\_\\/\\\\\\______\\//\\\\\\_\r\n"
  " _\\/\\\\\\_______\\/\\\\\\_\\/\\\\\\\\///\\\\\\/\\\\\\/_\\/\\\\\\"
  "___\\////\\\\\\_______________\\/\\\\\\_______\\/\\\\\\\\\\\\\\\\\\\\\\"
  "/____\\/\\\\\\_______\\/\\\\\\_\\/\\\\\\_______\\/\\\\\\_\r\n"
  " _\\/\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_\\/\\\\\\__\\///\\\\\\/___\\/\\\\\\"
  "______\\////\\\\\\____________\\/\\\\\\_______\\/\\\\\\//////\\\\\\"
  "____\\/\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_\\/\\\\\\_______\\/\\\\\\_\r\n"
  " _\\/\\\\\\/////////\\\\\\_\\/\\\\\\____\\///_____\\/\\\\\\"
  "_________\\////\\\\\\_________\\/\\\\\\_______\\/\\\\\\____\\//\\\\\\"
  "___\\/\\\\\\/////////\\\\\\_\\/\\\\\\_______\\/\\\\\\_\r\n"
  " _\\/\\\\\\_______\\/\\\\\\_\\/\\\\\\_____________\\/\\\\\\"
  "__/\\\\\\______\\//\\\\\\________\\/\\\\\\_______\\/\\\\\\_____\\//\\\\\\"
  "__\\/\\\\\\_______\\/\\\\\\_\\/\\\\\\_______/\\\\\\_\r\n"
  " _\\/\\\\\\_______\\/\\\\\\_\\/\\\\\\_____________\\/\\\\\\"
  "_\\///\\\\\\\\\\\\\\\\\\\\\\/________\\/\\\\\\_______\\/\\\\\\______\\//\\\\\\"
  "_\\/\\\\\\_______\\/\\\\\\_\\/\\\\\\\\\\\\\\\\\\\\\\\\/___\r\n"
  " _\\///________\\///__\\///______________\\///"
  "____\\///////////___________\\///________\\///________\\///"
  "__\\///________\\///__\\////////////_____\r\n";
#define BIOS_BANNER_LINES 10

#elif BIOS_CFG_INITIAL_BANNER_STYLE == 4
/* Amstrad bubble/underscore logo (79 wide x 8 tall). */
static const char bios_initial_banner_text[] =
  "\r\n\r\n\r\n"
  "  ________  _____ ______   ________  _________  ________  ________  ________\r\n"
  " |\\   __  \\|\\   _ \\  _   \\|\\   ____\\|\\___   ___\\\\   __  \\|\\   __  \\|\\   ___ \\\r\n"
  " \\ \\  \\|\\  \\ \\  \\\\\\__\\ \\  \\ \\  \\___\\|___ \\  \\_\\ \\  \\|\\  \\ \\  \\|\\  \\ \\  \\_|\\ \\\r\n"
  "  \\ \\   __  \\ \\  \\\\|__| \\  \\ \\_____  \\   \\ \\  \\ \\ \\   _  _\\ \\   __  \\ \\  \\ \\\\ \\\r\n"
  "   \\ \\  \\ \\  \\ \\  \\    \\ \\  \\|____|\\  \\   \\ \\  \\ \\ \\  \\\\  \\\\ \\  \\ \\  \\ \\  \\_\\\\ \\\r\n"
  "    \\ \\__\\ \\__\\ \\__\\    \\ \\__\\____\\_\\  \\   \\ \\__\\ \\ \\__\\\\ _\\\\ \\__\\ \\__\\ \\_______\\\r\n"
  "     \\|__|\\|__|\\|__|     \\|__|\\_________\\   \\|__|  \\|__|\\|__|\\|__|\\|__|\\|_______|\r\n"
  "                              \\|_________|                                       \r\n";
#define BIOS_BANNER_LINES 11

#else
#error "Unknown BIOS_CFG_INITIAL_BANNER_STYLE"
#endif

static int
bios_banner_check_esc (void)
{
  u16 head;
  u16 tail;
  u16 key;

  head = bios_bda_read16 (BDA_KBD_BUF_HEAD);
  tail = bios_bda_read16 (BDA_KBD_BUF_TAIL);
  if (head == tail)
    return 0;

  key = bios_abs_read16 (0x0040, head);
  if ((key & 0xFF) != 0x1B)
    return 0;

  /* Consume the ESC key. */
  head = (u16) (head + 2);
  if (head >= bios_bda_read16 (BDA_KBD_BUF_END_PTR))
    head = bios_bda_read16 (BDA_KBD_BUF_START_PTR);
  bios_bda_write16 (BDA_KBD_BUF_HEAD, head);
  return 1;
}

static void
bios_post_show_initial_banner (void)
{
  u32 start_ticks;
  u16 timeout_ticks;
  u8 text_mode;

  text_mode =
    bios_post_display_is_mono () ? VIDEO_MODE_80X25_MONO
    : VIDEO_MODE_80X25_COLOR;
  bios_video_set_mode (text_mode);
  bios_video_clear (0x07);
  bios_video_set_attribute (0x07);

  bios_video_set_cursor (0, 0);
  bios_video_puts (bios_initial_banner_text);

  bios_video_set_cursor (24, 0);
  bios_video_set_attribute (0x08);
  bios_video_puts ("Press ESC to continue...");
  bios_video_set_attribute (0x07);
  bios_video_hide_cursor ();

  timeout_ticks = (u16) (BIOS_CFG_INITIAL_BANNER_TIMEOUT * 18U);
  start_ticks = bios_bda_read32 (BDA_TIMER_TICKS);

  while ((u32) (bios_bda_read32 (BDA_TIMER_TICKS) - start_ticks)
	 < timeout_ticks)
    {
      if (bios_banner_check_esc ())
	break;
      bios_hw_enable_interrupts ();
      bios_hw_pause ();
    }

  /* Clear any remaining keystrokes so POST starts clean. */
  bios_keyboard_clear_buffer ();
}

#endif /* BIOS_CFG_INITIAL_BANNER_ENABLED */

static void
bios_post_banner (int warm_reset)
{
  u8 text_mode;
  const char *video_status;
  u8 video_attr;

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
		      "YES");
  bios_post_ui_clear_field (BIOS_POST_ROW_SUMMARY2, 52, 13);
  bios_video_puts_at (BIOS_POST_ROW_SUMMARY2, 52, BIOS_POST_ATTR_VALUE,
		      BIOS_CFG_HAS_MATH_COPROCESSOR ? "PRESENT" : "NONE");

  bios_post_ui_rule (BIOS_POST_ROW_STAGE_RULE, '-');
  bios_video_puts_at (BIOS_POST_ROW_STAGE_TITLE, 2, BIOS_POST_ATTR_HEADER,
		      "SELF TEST");
  video_status =
    (warm_reset || !BIOS_CFG_POST_VIDEO_MEMORY_TEST_ENABLED) ? "SKIP" : "PASS";
  video_attr =
    (warm_reset || !BIOS_CFG_POST_VIDEO_MEMORY_TEST_ENABLED)
    ? BIOS_POST_ATTR_PENDING : BIOS_POST_ATTR_PASS;
#if BIOS_CFG_POST_PRETTY_WAIT_PANEL
  bios_post_ui_stage (BIOS_POST_ROW_STAGE_ROM, bios_post_stage_rom,
		      BIOS_CFG_POST_ROS_CHECKSUM_TEST_ENABLED ? "PASS" : "SKIP",
		      BIOS_CFG_POST_ROS_CHECKSUM_TEST_ENABLED
		      ? BIOS_POST_ATTR_PASS : BIOS_POST_ATTR_PENDING);
  bios_post_ui_stage (BIOS_POST_ROW_STAGE_VIDEO, bios_post_stage_video,
		      video_status, video_attr);
  bios_post_ui_stage (BIOS_POST_ROW_STAGE_CORE, bios_post_stage_core,
		      BIOS_POST_CORE_TESTS_ENABLED && !warm_reset ? "PENDING"
		      : "SKIP",
		      BIOS_POST_ATTR_PENDING);
  bios_post_ui_stage (BIOS_POST_ROW_STAGE_RAM_DETECT,
		      bios_post_stage_ram_detect,
		      !warm_reset && BIOS_CFG_POST_BASE_RAM_DETECT_ENABLED
		      ? "PENDING" : "SKIP",
		      BIOS_POST_ATTR_PENDING);
  bios_post_ui_stage (BIOS_POST_ROW_STAGE_RAM_TEST, bios_post_stage_ram_test,
		      !warm_reset && BIOS_CFG_POST_BASE_RAM_TEST_ENABLED
		      ? "PENDING" : "SKIP",
		      BIOS_POST_ATTR_PENDING);
  bios_post_ui_stage (BIOS_POST_ROW_STAGE_KBD, bios_post_stage_kbd,
		      BIOS_POST_KBD_STAGE_ENABLED ? "PENDING" : "SKIP",
		      BIOS_POST_ATTR_PENDING);
  bios_post_ui_stage (BIOS_POST_ROW_STAGE_IO, bios_post_stage_io,
		      BIOS_POST_IO_TESTS_ENABLED && !warm_reset ? "PENDING"
		      : "SKIP",
		      BIOS_POST_ATTR_PENDING);
  bios_post_ui_stage (BIOS_POST_ROW_STAGE_ROM_SCAN, bios_post_stage_rom_scan,
		      BIOS_CFG_OPTION_ROM_SCAN_ENABLED ? "PENDING" : "SKIP",
		      BIOS_CFG_OPTION_ROM_SCAN_ENABLED ? BIOS_POST_ATTR_PENDING
		      : BIOS_POST_ATTR_PENDING);
  bios_post_ui_stage (BIOS_POST_ROW_STAGE_BOOT, bios_post_stage_boot,
		      "PENDING", BIOS_POST_ATTR_PENDING);
#endif

  bios_post_ui_rule (BIOS_POST_ROW_ALERT_RULE, '-');
  bios_video_puts_at (BIOS_POST_ROW_ALERT_TITLE, 2, BIOS_POST_ATTR_HEADER,
		      "MESSAGES");
  bios_post_ui_show_fixed_disks ();
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

  if (!bios_post_ui_active)
    return;
  memory_kb = bios_bda_read16 (BDA_MEMORY_SIZE_KB);
  bios_post_ui_show_memory_value (memory_kb);
}

#else /* !BIOS_CFG_POST_PRETTY_WAIT_PANEL */

#define bios_post_basic_begin()                                                \
  do                                                                           \
    {                                                                          \
      bios_video_set_cursor (0, 0);                                            \
      bios_video_puts ("Please wait");                                         \
    }                                                                          \
  while (0)

#define bios_post_basic_dot() bios_video_putc ('.')

static void
bios_post_warning (const char *detail)
{
  bios_video_puts ("WARNING: ");
  bios_video_puts (detail);
  bios_video_puts ("\r\n");
}

static void
bios_post_fault (const char *detail)
{
  bios_video_puts (bios_str_en_error_prefix);
  bios_video_puts (": ");
  bios_video_puts (detail);
  bios_video_puts ("\r\n");
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
  (void) 0;
}

#endif /* BIOS_CFG_POST_PRETTY_WAIT_PANEL */

static void
bios_post_hardware_init (void)
{
#if BIOS_CFG_SERIAL_INT14_ENABLED || BIOS_CFG_DEBUG_COM1
  bios_serial_init ();
#endif
  bios_post_debug_puts ("POST start\n");
#if BIOS_CFG_DEBUG_VIDEO_STATE
  bios_video_debug_dump_state ("post");
#endif
#if BIOS_CFG_HAS_DMA_CONTROLLER
  bios_dma_init ();
#endif
  bios_pic_init ();
  bios_pit_init ();
  bios_keyboard_init ();
#if BIOS_CFG_HAS_FLOPPY_CONTROLLER
  bios_floppy_init ();
#endif
#if BIOS_CFG_PRINTER_ENABLED
  bios_printer_init ();
#endif
  bios_rtc_init ();
  /* IDE init moved: XTIDE option ROM is loaded after RAM detection. */
#if BIOS_CFG_EMS_ENABLED
  bios_ems_init ();
#endif
}

static void
bios_post_step (u8 code)
{
  bios_hw_out8 (code, 0x03FC);
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
bios_post_pic_test (void)
{
  static const u8 patterns[] = { 0x00, 0xFF, 0x55, 0xAA, 0x01, 0x80 };
  u8 saved_mask;
  u8 i;
  int ok;

  saved_mask = bios_hw_in8 (PORT_PIC_DATA);
  bios_hw_disable_interrupts ();

  ok = 1;
  for (i = 0; i != sizeof (patterns) / sizeof (patterns[0]); ++i)
    {
      bios_hw_out8 (patterns[i], PORT_PIC_DATA);
      if (bios_hw_in8 (PORT_PIC_DATA) != patterns[i])
        {
          ok = 0;
          break;
        }
    }

  bios_hw_out8 (saved_mask, PORT_PIC_DATA);
  bios_hw_enable_interrupts ();
  return ok;
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
  u8 poll;

  saved_value = bios_cmos_read (CMOS_NVR_RAMDISK_SIZE);
  bios_cmos_write (CMOS_NVR_RAMDISK_SIZE, 0x55);
  if (bios_cmos_read (CMOS_NVR_RAMDISK_SIZE) != 0x55)
    goto fail;

  bios_cmos_write (CMOS_NVR_RAMDISK_SIZE, 0xAA);
  if (bios_cmos_read (CMOS_NVR_RAMDISK_SIZE) != 0xAA)
    goto fail;

  bios_cmos_write (CMOS_NVR_RAMDISK_SIZE, saved_value);
  seconds = bios_cmos_read (CMOS_SECONDS);
  for (poll = 0; poll != 30; ++poll)
    {
      bios_wait_microseconds (50000UL);
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
  return machine_mouse_test ();
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
#if BIOS_CFG_POST_DMA_TEST_ENABLED
  if (!bios_post_dma_test ())
    {
      bios_post_ui_stage (BIOS_POST_ROW_STAGE_CORE, bios_post_stage_core,
			  "FAIL", BIOS_POST_ATTR_FAIL);
      bios_post_fatal_fault (bios_post_fault_dma, 0);
    }
#endif

  bios_post_step (0x07);
#if BIOS_CFG_POST_TIMER_TEST_ENABLED
  if (!bios_post_timer_test ())
    {
      bios_post_ui_stage (BIOS_POST_ROW_STAGE_CORE, bios_post_stage_core,
			  "FAIL", BIOS_POST_ATTR_FAIL);
      bios_post_fatal_fault (bios_post_fault_timer, 0);
    }
#endif

  bios_post_step (0x08);
#if BIOS_CFG_POST_SYSTEM_STATUS_TEST_ENABLED
  if (!bios_post_system_status_test ())
    {
      bios_post_fault (bios_post_fault_system_status);
      warnings++;
    }
#endif

  bios_post_step (0x09);
#if BIOS_CFG_POST_RTC_TEST_ENABLED
  if (!bios_post_rtc_test ())
    {
      bios_post_fault (bios_post_fault_rtc);
      warnings++;
    }
#endif

  return warnings;
}

static u8
bios_post_run_late_device_tests (void)
{
  u8 warnings;

  warnings = 0;
  bios_post_step (0x0A);
#if BIOS_CFG_POST_SERIAL_TEST_ENABLED
  if (!bios_post_serial_test ())
    {
      bios_post_fault (bios_post_fault_serial);
      warnings++;
    }
#endif

  bios_post_step (0x0B);
#if BIOS_CFG_POST_PRINTER_TEST_ENABLED
  if (!bios_post_printer_test ())
    {
      bios_post_fault (bios_post_fault_printer);
      warnings++;
    }
#endif

  return warnings;
}

static u8
bios_post_run_disk_tests (void)
{
  u8 warnings;

  warnings = 0;

  bios_post_step (0x0D);
#if BIOS_CFG_POST_PIC_TEST_ENABLED
  if (!bios_post_pic_test ())
    bios_post_fatal_fault (bios_post_fault_interrupt_controller, 0);
#endif

  bios_pic_enable_runtime_irqs ();
  bios_hw_enable_interrupts ();
  bios_io_write (PORT_PPI_PORT_B, 0x70);
  bios_io_write (PORT_PPI_PORT_B, 0x40);
  bios_io_write (PORT_NMI_MASK, 0x80);

  bios_post_step (0x0E);
#if BIOS_CFG_HAS_FLOPPY_CONTROLLER
#if BIOS_CFG_POST_FLOPPY_TEST_ENABLED
  if (!bios_floppy_post_test ())
    {
      bios_post_fault (bios_post_fault_diskette);
      warnings++;
    }
#endif
#endif

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

  bios_post_debug_puts ("VDU seg=");
  bios_serial_debug_put_hex16 (video_seg);
  bios_post_debug_puts (" ofs=");
  bios_serial_debug_put_hex16 (page_offset);
  bios_post_debug_puts ("\n");
  for (i = 0; i != BIOS_POST_VDU_TEST_WORDS; ++i)
    bios_abs_write16 (video_seg, (u16) (page_offset + i * 2U), 0xAA55);
  for (i = 0; i != BIOS_POST_VDU_TEST_WORDS; ++i)
    if (bios_abs_read16 (video_seg, (u16) (page_offset + i * 2U)) != 0xAA55)
      {
	bios_post_debug_puts ("VDU fail i=");
	bios_serial_debug_put_hex16 (i);
	bios_post_debug_puts (" got=");
	bios_serial_debug_put_hex16 (bios_abs_read16 (video_seg, (u16) (page_offset + i * 2U)));
	bios_post_debug_puts ("\n");
	goto fail;
      }

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
  return bios_post_phys_read16 (phys) == (u16) (phys >> 4);
}

static void
bios_post_stamp_ram_blocks (void)
{
  u32 phys;

  for (phys = bios_post_option_block_start_phys ();
       phys < bios_post_ram_test_end_phys ();
       phys += bios_post_option_block_size_bytes ())
    bios_post_phys_write16 (phys, (u16) (phys >> 4));
}

static int
bios_post_fill_ram_range_raw (u32 start_phys, u32 end_phys, u16 value)
{
  u32 phys;

  /*
   * The PC1640 destructive RAM pass is performance-sensitive. Keep the
   * hot fill/verify loop in tight 8086 string ops over 32 KiB spans so the
   * POST behaves much closer to the original ROS than the old per-word C
   * helper did.
   */
  phys = start_phys;
  while (phys < end_phys)
    {
      u32 span_end;
      u16 segment;
      u16 words;
      int ok;

      span_end = (phys & 0xFFFF8000UL) + 0x8000UL;
      if (span_end > end_phys)
        span_end = end_phys;

      segment = (u16) (phys >> 4);
      words = (u16) ((span_end - phys) >> 1);
      ok = 1;

      asm volatile ("push %%es\n\t"
                    "push %%di\n\t"
                    "push %%cx\n\t"
                    "push %%ax\n\t"
                    "mov %2, %%ax\n\t"
                    "mov %%ax, %%es\n\t"
                    "xor %%di, %%di\n\t"
                    "mov %4, %%ax\n\t"
                    "mov %3, %%cx\n\t"
                    "cld\n\t"
                    "rep stosw\n\t"
                    "mov %2, %%ax\n\t"
                    "mov %%ax, %%es\n\t"
                    "xor %%di, %%di\n\t"
                    "mov %4, %%ax\n\t"
                    "mov %3, %%cx\n\t"
                    "repe scasw\n\t"
                    "jcxz 1f\n\t"
                    "mov $0, %0\n\t"
                    "1:\n\t"
                    "pop %%ax\n\t"
                    "pop %%cx\n\t"
                    "pop %%di\n\t"
                    "pop %%es"
                    : "+r" (ok)
                    : "0" (ok), "rm" (segment), "rm" (words), "rm" (value)
                    : "ax", "cx", "di", "memory", "cc");
      if (!ok)
        return 0;

      phys = span_end;
    }

  return 1;
}

static int
bios_post_fill_ram_range (u32 start_phys, u32 end_phys, u16 value)
{
  u32 lower_end;
  u32 upper_start;

  lower_end = end_phys < BIOS_POST_STACK_GUARD_START
    ? end_phys : BIOS_POST_STACK_GUARD_START;
  if (start_phys < lower_end
      && !bios_post_fill_ram_range_raw (start_phys, lower_end, value))
    return 0;

  upper_start = start_phys > BIOS_POST_STACK_GUARD_END
    ? start_phys : BIOS_POST_STACK_GUARD_END;
  if (upper_start < end_phys
      && !bios_post_fill_ram_range_raw (upper_start, end_phys, value))
    return 0;

  return 1;
}

static int
bios_post_rewrite_ram_range_desc_raw (u32 start_phys, u32 end_phys,
                                      u16 expected, u16 rewrite)
{
  /*
   * Descending rewrite pass used by the PC1640-style destructive RAM test.
   * Work one 32 KiB span at a time so each span fits a single segment and
   * the inner loop can use STD/SCASW/STOSW like a conventional 8086 ROM.
   */
  while (end_phys > start_phys)
    {
      u32 span_start;
      u16 segment;
      u16 last_off;
      u16 words;
      int ok;

      span_start = (end_phys - 1U) & 0xFFFF8000UL;
      if (span_start < start_phys)
        span_start = start_phys;

      segment = (u16) (span_start >> 4);
      last_off = (u16) (end_phys - span_start - 2U);
      words = (u16) ((end_phys - span_start) >> 1);
      ok = 1;

      asm volatile ("push %%es\n\t"
                    "push %%di\n\t"
                    "push %%cx\n\t"
                    "push %%ax\n\t"
                    "mov %2, %%ax\n\t"
                    "mov %%ax, %%es\n\t"
                    "mov %3, %%di\n\t"
                    "mov %4, %%ax\n\t"
                    "mov %5, %%cx\n\t"
                    "std\n\t"
                    "repe scasw\n\t"
                    "jnz 2f\n\t"
                    "mov %2, %%ax\n\t"
                    "mov %%ax, %%es\n\t"
                    "mov %3, %%di\n\t"
                    "mov %6, %%ax\n\t"
                    "mov %5, %%cx\n\t"
                    "rep stosw\n\t"
                    "mov %2, %%ax\n\t"
                    "mov %%ax, %%es\n\t"
                    "mov %3, %%di\n\t"
                    "mov %6, %%ax\n\t"
                    "mov %5, %%cx\n\t"
                    "repe scasw\n\t"
                    "jcxz 1f\n\t"
                    "2:\n\t"
                    "mov $0, %0\n\t"
                    "1:\n\t"
                    "cld\n\t"
                    "pop %%ax\n\t"
                    "pop %%cx\n\t"
                    "pop %%di\n\t"
                    "pop %%es"
                    : "+r" (ok)
                    : "0" (ok), "rm" (segment), "rm" (last_off),
                      "rm" (expected), "rm" (words), "rm" (rewrite)
                    : "ax", "cx", "di", "memory", "cc");
      if (!ok)
        return 0;

      end_phys = span_start;
    }

  return 1;
}

static int
bios_post_rewrite_ram_range_desc (u32 start_phys, u32 end_phys,
                                  u16 expected, u16 rewrite)
{
  u32 upper_start;
  u32 lower_end;

  upper_start = start_phys > BIOS_POST_STACK_GUARD_END
    ? start_phys : BIOS_POST_STACK_GUARD_END;
  if (upper_start < end_phys
      && !bios_post_rewrite_ram_range_desc_raw (upper_start, end_phys,
                                                expected, rewrite))
    return 0;

  lower_end = end_phys < BIOS_POST_STACK_GUARD_START
    ? end_phys : BIOS_POST_STACK_GUARD_START;
  if (start_phys < lower_end
      && !bios_post_rewrite_ram_range_desc_raw (start_phys, lower_end,
                                                expected, rewrite))
    return 0;

  return 1;
}

static u16
bios_post_detect_base_memory_kb (void)
{
  u16 size_kb;
  u32 phys;

  size_kb = bios_post_base_memory_floor_kb ();
  bios_post_stamp_ram_blocks ();
  for (phys = bios_post_option_block_start_phys ();
       phys < bios_post_ram_test_end_phys ();
       phys += bios_post_option_block_size_bytes ())
    {
      if (!bios_post_ram_block_present (phys))
	break;
      size_kb = (u16) (size_kb + bios_post_option_block_kb ());
    }

  return size_kb;
}

static int
bios_post_run_ram_tests (u16 size_kb)
{
  u32 end_phys;

  end_phys = (u32) size_kb << 10;
  if (end_phys > bios_post_ram_test_end_phys ())
    end_phys = bios_post_ram_test_end_phys ();

  if (end_phys <= (BIOS_POST_RAM_TEST_START_PHYS + 2U))
    return 1;

  /*
   * Follow the original PC1640 POST structure more closely than the earlier
   * sampled sweep: stamp/detect the optional 32 KiB blocks, fill the tested
   * RAM range with one pattern, sweep it upward with the opposite pattern,
   * then sweep it downward back to the original pattern.
   *
   * The PC1640 path now runs the cold RAM POST tail from a dedicated guard
   * stack at 0x6800-0x77FF, so the destructive sweep can start from physical
   * zero while still leaving one live stack window untouched.
   */
  return bios_post_fill_ram_range (BIOS_POST_RAM_TEST_START_PHYS, end_phys,
                                   0xFFFF)
    && bios_post_fill_ram_range (BIOS_POST_RAM_TEST_START_PHYS, end_phys,
                                 0x0000)
    && bios_post_rewrite_ram_range_desc (BIOS_POST_RAM_TEST_START_PHYS,
                                         end_phys, 0x0000, 0xFFFF);
}

static void __attribute__((noreturn))
bios_post_finish_after_ram (int mouse_ok)
{
  u8 disk_warnings;
  int keyboard_ok;

  bios_post_restore_rom_segments ();

  /*
   * This is the post-RAM tail of POST:
   * diskette first, then keyboard/mouse, then motherboard option ROM scan,
   * then INT 19h. On PC1640 the video ROM is already alive by this point, so
   * the motherboard ROS only drives service sequencing and status reporting.
   */
  bios_post_debug_puts ("POST disk\n");
  disk_warnings = bios_post_run_disk_tests ();
#if !BIOS_CFG_POST_PRETTY_WAIT_PANEL
  bios_post_basic_dot ();
#endif

  keyboard_ok = 1;
  bios_post_step (0x0F);
  bios_post_debug_puts ("POST keyboard\n");
#if BIOS_CFG_POST_KEYBOARD_TEST_ENABLED
  keyboard_ok = bios_keyboard_self_test ();
  if (!keyboard_ok)
    bios_work_write8 (WK_BOOT_FLAGS,
                      (u8) (bios_work_read8 (WK_BOOT_FLAGS)
                            | BOOT_FLAG_KBD_FAULT));
#endif
#if !BIOS_CFG_POST_PRETTY_WAIT_PANEL
  if (BIOS_CFG_POST_KEYBOARD_TEST_ENABLED)
    bios_post_basic_dot ();
#endif

  if (!BIOS_POST_KBD_STAGE_ENABLED)
    bios_post_ui_stage (BIOS_POST_ROW_STAGE_KBD, bios_post_stage_kbd, "SKIP",
                        BIOS_POST_ATTR_PENDING);
  else if (keyboard_ok && mouse_ok)
    bios_post_ui_stage (BIOS_POST_ROW_STAGE_KBD, bios_post_stage_kbd, "PASS",
                        BIOS_POST_ATTR_PASS);
  else
    bios_post_ui_stage (BIOS_POST_ROW_STAGE_KBD, bios_post_stage_kbd, "WARN",
                        BIOS_POST_ATTR_WARN);

  bios_post_show_memory ();

  if (BIOS_CFG_POST_KEYBOARD_TEST_ENABLED
      && (bios_work_read8 (WK_BOOT_FLAGS) & BOOT_FLAG_KBD_FAULT) != 0)
    bios_post_fault (bios_str_en_check_keyboard_mouse);
  if (disk_warnings != 0)
    bios_post_ui_stage (BIOS_POST_ROW_STAGE_IO, bios_post_stage_io, "WARN",
                        BIOS_POST_ATTR_WARN);

#if BIOS_CFG_XTIDE_ENABLED && BIOS_CFG_XTIDE_EMBEDDED_IN_ROS
  /* Compressed XTIDE lives in motherboard ROM; unpack to high RAM then init. */
  bios_xtide_embedded_ram_init ();
#endif

  if (BIOS_CFG_OPTION_ROM_SCAN_ENABLED)
    {
      /*
       * Embedded XTIDE rehomes a resident copy into upper memory during its
       * own init path. A second generic C000-F000 sweep would rediscover that
       * image as if it were an external adapter ROM and recurse back into it.
       */
#if BIOS_CFG_XTIDE_ENABLED && BIOS_CFG_XTIDE_EMBEDDED_IN_ROS
      bios_post_ui_stage (BIOS_POST_ROW_STAGE_ROM_SCAN,
			  bios_post_stage_rom_scan, "SKIP",
			  BIOS_POST_ATTR_PENDING);
#else
      bios_post_ui_stage (BIOS_POST_ROW_STAGE_ROM_SCAN, bios_post_stage_rom_scan,
			  "SCAN", BIOS_POST_ATTR_HEADER);
      bios_option_rom_scan (BIOS_CFG_VIDEO_OPTION_ROM_SEGMENT,
			    BIOS_CFG_OPTION_ROM_SCAN_END,
			    BIOS_CFG_OPTION_ROM_SCAN_STEP);
      bios_post_ui_stage (BIOS_POST_ROW_STAGE_ROM_SCAN,
			  bios_post_stage_rom_scan, "PASS",
			  BIOS_POST_ATTR_PASS);
#endif
    }

  /*
   * DOS still consults the classic INT 41h/46h fixed-disk tables on XT-class
   * machines. External XTIDE owns INT 19h, so publishing these tables only in
   * the motherboard HDD boot fallback misses the real DOS boot path entirely.
   * Refresh them here after all storage option ROMs have hooked INT 13h.
   */
  bios_fixed_disk_publish_compat_tables ();

  bios_post_ui_stage (BIOS_POST_ROW_STAGE_BOOT, bios_post_stage_boot, "BOOT",
                      BIOS_POST_ATTR_HEADER);
  bios_beep_ticks (2);
  bios_post_step (0x19);
  bios_video_set_cursor (BIOS_POST_ROW_TTY, 0);
  bios_post_debug_puts ("POST int19\n");
  bios_invoke_int19 ();
  bios_post_ui_stage (BIOS_POST_ROW_STAGE_BOOT, bios_post_stage_boot, "FAIL",
                      BIOS_POST_ATTR_FAIL);
  bios_boot_failure ();
  __builtin_unreachable ();
}

static void __attribute__((noreturn))
bios_post_continue_after_mouse (int warm_reset, u8 boot_flags, int mouse_ok);

static void __attribute__((noreturn, noinline, used))
bios_post_continue_after_mouse_pc1640_cold (void)
{
  bios_post_restore_rom_segments ();
  bios_post_continue_after_mouse (0, machine_post_saved_boot_flags (),
                                  machine_post_saved_mouse_ok ());
}

static void __attribute__((noreturn, noinline, used))
bios_post_continue_after_ram_pc1640_cold (void)
{
  bios_post_restore_rom_segments ();
  bios_post_finish_after_ram (machine_post_saved_mouse_ok ());
}

static void __attribute__((noreturn, noinline))
bios_post_continue_on_temp_stack (void)
{
  /*
   * The cold destructive RAM pass must not consume the final ROS stack.
   * Switch to the guard window at 6800h-77FFh, resume the cold path there,
   * and only restore 0030:0100 once low memory has been rebuilt.
   */
  asm volatile ("cli\n\t"
                "mov %0, %%ax\n\t"
                "mov %%ax, %%ss\n\t"
                "mov %1, %%sp\n\t"
                "cld\n\t"
                "jmp bios_post_continue_after_mouse_pc1640_cold"
                :
                : "i" (BIOS_POST_TEMP_STACK_SEGMENT),
                  "i" (BIOS_POST_TEMP_STACK_OFFSET)
                : "ax", "memory", "cc");
  __builtin_unreachable ();
}

static void __attribute__((noreturn, noinline))
bios_post_continue_on_ros_stack (void)
{
  /* Return from the guard stack to the documented ROS stack for late POST. */
  asm volatile ("cli\n\t"
                "mov %0, %%ax\n\t"
                "mov %%ax, %%ss\n\t"
                "mov %1, %%sp\n\t"
                "cld\n\t"
                "jmp bios_post_continue_after_ram_pc1640_cold"
                :
                : "i" (BIOS_STACK_SEGMENT),
                  "i" (BIOS_STACK_OFFSET)
                : "ax", "memory", "cc");
  __builtin_unreachable ();
}

static void __attribute__((noreturn))
bios_post_continue_after_mouse (int warm_reset, u8 boot_flags, int mouse_ok)
{
  u16 detected_kb;
  int destructive_ram_test;

  /*
   * RAM sizing and destructive RAM test live here so the PC1640 cold path can
   * branch onto the temporary stack before testing and then republish the BDA
   * plus restored vectors immediately after the sweep.
   */
  detected_kb = BIOS_CFG_BASE_MEMORY_KB;
  destructive_ram_test = !warm_reset && BIOS_CFG_POST_BASE_RAM_TEST_ENABLED;

  if (!warm_reset)
    {
      if (BIOS_CFG_POST_BASE_RAM_DETECT_ENABLED)
        {
          bios_post_debug_puts ("POST ram detect\n");
          bios_post_step (0x04);
          detected_kb = bios_post_detect_base_memory_kb ();
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
        }
      else
        bios_post_ui_stage_ram_kb (BIOS_POST_ROW_STAGE_RAM_DETECT,
                                   bios_post_stage_ram_detect, "SKIP",
                                   BIOS_POST_ATTR_PENDING, detected_kb);

      if (BIOS_CFG_POST_BASE_RAM_TEST_ENABLED)
        {
          bios_post_step (0x05);
          bios_hw_disable_interrupts ();
          bios_post_debug_puts ("POST ram test\n");
          if (!bios_post_run_ram_tests (detected_kb))
            {
              bios_hw_enable_interrupts ();
              bios_post_ui_stage (BIOS_POST_ROW_STAGE_RAM_TEST,
                                  bios_post_stage_ram_test, "FAIL",
                                  BIOS_POST_ATTR_FAIL);
              bios_post_fatal_fault ("RAM", BOOT_FLAG_RAM_FAULT);
            }
          /*
           * Keep IF clear across the PC1640 destructive-RAM tail until the
           * motherboard-owned low-memory image and preserved PEGA vectors
           * have been rebuilt.  Enabling interrupts here can dispatch IRQs
           * through a partially reconstructed IVT/BDA image.
           */
          bios_post_restore_rom_segments ();
          if (!destructive_ram_test)
            bios_post_ui_stage (BIOS_POST_ROW_STAGE_RAM_TEST,
                                bios_post_stage_ram_test, "PASS",
                                BIOS_POST_ATTR_PASS);
          bios_post_debug_puts ("POST ram ok\n");
#if !BIOS_CFG_POST_PRETTY_WAIT_PANEL
          if (!destructive_ram_test)
            bios_post_basic_dot ();
#endif
        }
      else
        bios_post_ui_stage (BIOS_POST_ROW_STAGE_RAM_TEST,
                            bios_post_stage_ram_test, "SKIP",
                            BIOS_POST_ATTR_PENDING);

      machine_post_publish_runtime_state (detected_kb, boot_flags,
                                          destructive_ram_test);
      bios_post_restore_rom_segments ();
      if (destructive_ram_test)
        {
          bios_post_ui_stage (BIOS_POST_ROW_STAGE_RAM_TEST,
                              bios_post_stage_ram_test, "PASS",
                              BIOS_POST_ATTR_PASS);
#if !BIOS_CFG_POST_PRETTY_WAIT_PANEL
          bios_post_basic_dot ();
#endif
        }
    }
  else
    {
      machine_post_publish_runtime_state (detected_kb, boot_flags, 0);
      bios_post_restore_rom_segments ();
      bios_post_ui_stage_ram_kb (BIOS_POST_ROW_STAGE_RAM_DETECT,
                                 bios_post_stage_ram_detect, "SKIP",
                                 BIOS_POST_ATTR_PENDING, detected_kb);
      bios_post_ui_stage (BIOS_POST_ROW_STAGE_RAM_TEST,
                          bios_post_stage_ram_test, "SKIP",
                          BIOS_POST_ATTR_PENDING);
    }

  if (!warm_reset)
    bios_post_continue_on_ros_stack ();
  bios_post_finish_after_ram (mouse_ok);
}

void
bios_post_cold_boot (void)
{
  u8 boot_flags;
  u8 early_warnings;
  u8 late_warnings;
  int mouse_ok;
  int warm_reset;

  /*
   * Top-level POST dispatcher. Keep the plain-text PC1640 path close to the
   * original sequence: hardware init, ROS checksum, core devices, mouse,
   * RAM detect/test, late device checks, option ROM scan, then bootstrap.
   */
  bios_post_step (0x01);
  warm_reset = bios_post_warm_reset_requested ();
  bios_bda_write16 (BDA_WARM_BOOT_FLAG, 0x0000);
  bios_post_hardware_init ();
  bios_post_debug_puts ("POST hw done\n");

  boot_flags = bios_work_read8 (WK_BOOT_FLAGS);
  if (warm_reset)
    boot_flags |= BOOT_FLAG_WARM;
  else
    boot_flags &= (u8) ~ BOOT_FLAG_WARM;
  bios_work_write8 (WK_BOOT_FLAGS, boot_flags);

  bios_post_step (0x02);
  bios_post_debug_puts ("POST csum\n");
  if (BIOS_CFG_POST_ROS_CHECKSUM_TEST_ENABLED
      && !bios_post_ros_checksum_valid ())
    bios_post_fatal_fault (bios_str_en_ros_checksum, BOOT_FLAG_ROS_FAULT);
  bios_post_debug_puts (BIOS_CFG_POST_ROS_CHECKSUM_TEST_ENABLED
			  ? "POST csum ok\n" : "POST csum skip\n");

  if (!warm_reset && BIOS_CFG_POST_VIDEO_MEMORY_TEST_ENABLED)
    {
      bios_post_step (0x03);
      bios_post_debug_puts ("POST vdu test\n");
      if (!bios_post_video_memory_test ())
	bios_post_fatal_fault (bios_str_en_vdu_ram, BOOT_FLAG_VDU_FAULT);
      bios_post_debug_puts ("POST video ok\n");
    }

#if BIOS_CFG_INITIAL_BANNER_ENABLED
  if (!warm_reset)
    bios_post_show_initial_banner ();
#endif

#if !BIOS_CFG_POST_PRETTY_WAIT_PANEL
  bios_post_basic_begin ();
  bios_post_basic_dot ();
#endif

#if BIOS_CFG_POST_PRETTY_WAIT_PANEL
  bios_post_banner (warm_reset);
  bios_post_debug_puts ("POST banner done\n");

  if (!warm_reset && BIOS_CFG_POST_SPACE_INVADERS_SOUND)
    bios_play_space_invaders_effect ();
#endif

  if ((bios_work_read8 (WK_BOOT_FLAGS) & BOOT_FLAG_BATTERY_LOW) != 0)
    bios_post_warning (bios_str_en_battery_warning);

  if (!warm_reset)
    {
      if (BIOS_POST_CORE_TESTS_ENABLED)
	{
	  bios_post_debug_puts ("POST early tests\n");
	  early_warnings = bios_post_run_early_device_tests ();
	  bios_post_ui_stage (BIOS_POST_ROW_STAGE_CORE, bios_post_stage_core,
			      early_warnings == 0 ? "PASS" : "WARN",
			      early_warnings == 0 ? BIOS_POST_ATTR_PASS
			      : BIOS_POST_ATTR_WARN);
	  bios_post_debug_puts ("POST early done\n");
#if !BIOS_CFG_POST_PRETTY_WAIT_PANEL
	  bios_post_basic_dot ();
#endif
	}
      else
	bios_post_ui_stage (BIOS_POST_ROW_STAGE_CORE, bios_post_stage_core,
			    "SKIP", BIOS_POST_ATTR_PENDING);
    }
  else
    bios_post_ui_stage (BIOS_POST_ROW_STAGE_CORE, bios_post_stage_core, "SKIP",
			BIOS_POST_ATTR_PENDING);

  if (!warm_reset)
    {
      if (BIOS_POST_IO_TESTS_ENABLED)
	{
	  bios_post_debug_puts ("POST io tests\n");
	  late_warnings = bios_post_run_late_device_tests ();
	  bios_post_ui_stage (BIOS_POST_ROW_STAGE_IO, bios_post_stage_io,
			      late_warnings == 0 ? "PASS" : "WARN",
			      late_warnings == 0 ? BIOS_POST_ATTR_PASS
			      : BIOS_POST_ATTR_WARN);
	  bios_post_debug_puts ("POST io done\n");
#if !BIOS_CFG_POST_PRETTY_WAIT_PANEL
	  bios_post_basic_dot ();
#endif
	}
      else
	bios_post_ui_stage (BIOS_POST_ROW_STAGE_IO, bios_post_stage_io,
			    "SKIP", BIOS_POST_ATTR_PENDING);
    }
  else
    bios_post_ui_stage (BIOS_POST_ROW_STAGE_IO, bios_post_stage_io, "SKIP",
			BIOS_POST_ATTR_PENDING);

  bios_post_step (0x0C);
  bios_post_debug_puts ("POST mouse\n");
  mouse_ok = 1;
#if BIOS_CFG_POST_MOUSE_TEST_ENABLED
  mouse_ok = bios_post_mouse_test ();
  if (!mouse_ok)
    bios_post_fault (bios_post_fault_mouse);
#endif
#if !BIOS_CFG_POST_PRETTY_WAIT_PANEL
  if (BIOS_CFG_POST_MOUSE_TEST_ENABLED)
    bios_post_basic_dot ();
#endif

  if (!warm_reset)
    {
      machine_post_save_runtime_state (boot_flags, mouse_ok);
      bios_post_continue_on_temp_stack ();
    }

  bios_post_continue_after_mouse (warm_reset, boot_flags, mouse_ok);
}

void
bios_post_booting_from_hd (void)
{
  if (!bios_post_ui_active)
    return;

  bios_post_ui_set_boot_line ("Booting from HD", BIOS_POST_ATTR_HEADER);
}
