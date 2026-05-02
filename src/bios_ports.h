/* ================================================
 * FreeRos BIOS
 * bios_ports.h: I/O port addresses and BDA/CMOS register map
 * ================================================ */

#ifndef NEW_BIOS_PORTS_H
#define NEW_BIOS_PORTS_H

#include "bios_types.h"

/* ================================================
 * Language constants
 * ================================================ */

/* The trimmed ROS keeps only the English language strap value. */
#define BIOS_LANG_ENGLISH 0x07

/* ================================================
 * I/O port addresses
 * ================================================ */

/* Standard XT-class I/O plus Amstrad-specific ports. */
#define PORT_DMA_CH0_ADDR 0x0000
#define PORT_DMA_CH0_COUNT 0x0001
#define PORT_DMA_CH2_ADDR 0x0004
#define PORT_DMA_CH2_COUNT 0x0005
#define PORT_DMA1_CMD 0x0008
#define PORT_DMA1_MASK 0x000A
#define PORT_DMA1_MODE 0x000B
#define PORT_DMA1_CLEAR_FF 0x000C
#define PORT_DMA1_MASTER_CLEAR 0x000D
#define PORT_DMA_PAGE_CH0 0x0087
#define PORT_DMA_PAGE_CH1 0x0083
#define PORT_PIC_CMD 0x0020
#define PORT_PIC_DATA 0x0021
#define PORT_PIT_CH0 0x0040
#define PORT_PIT_CH1 0x0041
#define PORT_PIT_CH2 0x0042
#define PORT_PIT_MODE 0x0043
#define PORT_KBD_DATA 0x0060
#define PORT_PPI_PORT_B 0x0061
#define PORT_SYSSTAT2_RD 0x0062
#define PORT_SYSSTAT1_WR 0x0064
#define PORT_SYSSTAT2_WR 0x0065
#define PORT_SOFT_RESET 0x0066
#define PORT_CMOS_ADDR 0x0070
#define PORT_CMOS_DATA 0x0071
#define PORT_MOUSE_X 0x0078
#define PORT_MOUSE_Y 0x007A
#define PORT_DMA_PAGE_CH2 0x0081
#define PORT_DMA_PAGE_CH3 0x0082
#define PORT_NMI_MASK 0x00A0
#define PORT_LPT1_DATA 0x0378
#define PORT_LPT1_STATUS 0x0379
#define PORT_LPT1_CONTROL 0x037A
#define PORT_MDA_STATUS 0x03BA
#define PORT_VIDEO_ATTR 0x03C0
#define PORT_VIDEO_MISC_OUTPUT 0x03C2
#define PORT_VIDEO_SEQU_ADDR 0x03C4
#define PORT_VIDEO_SEQU_DATA 0x03C5
#define PORT_VIDEO_GRDC_ADDR 0x03CE
#define PORT_VIDEO_GRDC_DATA 0x03CF
#define PORT_MDA_CRTC_ADDR 0x03B4
#define PORT_CRTC_ADDR 0x03D4
#define PORT_CRTC_DATA 0x03D5
#define PORT_CGA_MODE 0x03D8
#define PORT_CGA_STATUS 0x03DA
#define PORT_VIDEO_SWITCH 0x03DB
#define PORT_VIDEO_EXT 0x03DD
#define PORT_IDA_STATUS 0x03DE
#define PORT_FDC_DOR 0x03F2
#define PORT_FDC_MSR 0x03F4
#define PORT_FDC_DATA 0x03F5
#define PORT_FDC_DIR 0x03F7
#define PORT_FDC_CCR 0x03F7
/* ================================================
 * Port bit definitions
 * ================================================ */

/* Port 0x61 shadow bits. */
#define PORT61_SPEAKER_GATE 0x01
#define PORT61_SPEAKER_DATA 0x02
#define PORT61_NVR_LOW_NIBBLE 0x04
#define PORT61_KBD_RESET 0x40
#define PORT61_STATUS_MODE 0x80

/* LPT1 status bits that the PC1640 BIOS uses as language straps. */
#define LPT1_STATUS_LANGUAGE_MASK 0x07
#define LPT1_STATUS_DIP_LATCH 0x20
#define LPT1_STATUS_DECODE_LANGUAGE(value) \
  (((value) ^ LPT1_STATUS_LANGUAGE_MASK) & LPT1_STATUS_LANGUAGE_MASK)

/*
 * The PC1640 exposes display switches through bit 5 of the printer control
 * latch. The dummy read before 0x037A chooses which source is returned there:
 *  - any implemented main-board port with A7 high: PC1512/PC1640 OPT probe
 *  - unimplemented port with A14=0, A7=0: SW9
 *  - unimplemented port with A14=1, A7=0: SW10
 */
#define PORT_PC1640_OPT_LATCH 0x03D4
#define PORT_PC1640_SW9_LATCH 0x0278
#define PORT_PC1640_SW10_LATCH 0x4278
#define LPT1_CONTROL_OPT 0x20
#define LPT1_CONTROL_SWITCH_SW10 0x20
#define LPT1_CONTROL_SWITCH_SW9 0x20
#define LPT1_CONTROL_SWITCH_SW6 0x40
#define LPT1_CONTROL_SWITCH_SW7 0x80

/* PC1640 EGC control/status at 03C2h. */
#define PC1640_EGC_CONTROL_CRTC_COLOR 0x01
#define PC1640_EGC_CONTROL_RAM_ENABLE 0x02
#define PC1640_EGC_CONTROL_SWITCH_SELECT_MASK 0x0C
#define PC1640_EGC_CONTROL_CLOCK_16MHZ 0x04
#define PC1640_EGC_CONTROL_HSYNC_NEGATIVE 0x40
#define PC1640_EGC_CONTROL_VSYNC_NEGATIVE 0x80
#define PC1640_EGC_CONTROL_SWITCH1 0x0C
#define PC1640_EGC_CONTROL_SWITCH2 0x08
#define PC1640_EGC_CONTROL_SWITCH3 0x04
#define PC1640_EGC_CONTROL_SWITCH4 0x00
#define PC1640_EGC_STATUS_SWITCH_SENSE 0x10
#define PC1640_EGC_CONTROL_MONO_TEXT \
  (PC1640_EGC_CONTROL_RAM_ENABLE | PC1640_EGC_CONTROL_VSYNC_NEGATIVE)
#define PC1640_EGC_CONTROL_COLOR_TEXT \
  (PC1640_EGC_CONTROL_CRTC_COLOR | PC1640_EGC_CONTROL_RAM_ENABLE \
   | PC1640_EGC_CONTROL_CLOCK_16MHZ | PC1640_EGC_CONTROL_HSYNC_NEGATIVE)

/* ================================================
 * Config overrides
 * ================================================ */

#include "config.h"

#undef BIOS_ROM_SEGMENT
#if BIOS_CFG_EXECUTE_IN_PLACE
#define BIOS_ROM_SEGMENT BIOS_CFG_ROM_ENTRY_SEGMENT
#else
#define BIOS_ROM_SEGMENT BIOS_CFG_RUNTIME_SEGMENT
#endif

#undef BIOS_STACK_SEGMENT
#undef BIOS_STACK_OFFSET
#if BIOS_CFG_EXECUTE_IN_PLACE
/*
 * In execute-in-place mode the compiler's small-model code restores DS from
 * SS (push %ss; pop %ds).  DS must equal CS (the ROM segment) so that near
 * pointers to const data resolve to ROM.  Therefore SS must also equal CS.
 *
 * The physical stack lives in low RAM.  With A20 disabled (standard on XT-
 * class machines) addresses above 1 MB wrap around, so FC00:4400 maps to
 * physical 0x00400 -- the same location as 0030:0100.
 */
#define BIOS_STACK_SEGMENT BIOS_ROM_SEGMENT
#define BIOS_STACK_OFFSET 0x4400
#else
#define BIOS_STACK_SEGMENT BIOS_CFG_STACK_SEGMENT
#define BIOS_STACK_OFFSET BIOS_CFG_STACK_OFFSET
#endif

/* ================================================
 * Floppy controller and DMA constants
 * ================================================ */

/* Floppy controller and DMA status bits. */
#define FDC_STATUS_BUSY 0x10
#define FDC_STATUS_NDMA 0x20
#define FDC_STATUS_DIR 0x40
#define FDC_STATUS_READY 0x80

#define FDC_ST0_EQUIPMENT_CHECK 0x10
#define FDC_ST0_SEEK_END 0x20
#define FDC_ST0_INTERRUPT_MASK 0xC0
#define FDC_ST1_MISSING_ADDRESS_MARK 0x01
#define FDC_ST1_WRITE_PROTECT 0x02
#define FDC_ST1_NO_DATA 0x04
#define FDC_ST1_OVERRUN 0x10
#define FDC_ST1_CRC 0x20
#define FDC_ST2_MISSING_ADDRESS_MARK 0x01
#define FDC_ST2_BAD_CYLINDER 0x02
#define FDC_ST2_WRONG_CYLINDER 0x10
#define FDC_ST2_CRC 0x20

#define FDC_CMD_SPECIFY 0x03
#define FDC_CMD_SENSE_INTERRUPT 0x08
#define FDC_CMD_RECALIBRATE 0x07
#define FDC_CMD_SEEK 0x0F
#define FDC_CMD_FORMAT_TRACK 0x4D
#define FDC_CMD_READ_DATA 0xE6
#define FDC_CMD_WRITE_DATA 0xC5

#define DMA_CH2 0x02
#define DMA_MODE_READ 0x44
#define DMA_MODE_WRITE 0x48

/* ================================================
 * BDA offsets
 * ================================================ */

/* BIOS Data Area offsets (segment 0x40). */
#define BDA_COM1_BASE 0x0000
#define BDA_COM2_BASE 0x0002
#define BDA_COM3_BASE 0x0004
#define BDA_COM4_BASE 0x0006
#define BDA_LPT1_BASE 0x0008
#define BDA_LPT2_BASE 0x000A
#define BDA_LPT3_BASE 0x000C
#define BDA_EQUIPMENT_WORD 0x0010
#define BDA_MEMORY_SIZE_KB 0x0013
#define BDA_EXTRA_MEMORY_KB 0x0015
#define BDA_KBD_FLAGS 0x0017
#define BDA_KBD_FLAGS_2 0x0018
#define BDA_KBD_ALT_PAD 0x0019
#define BDA_KBD_BUF_HEAD 0x001A
#define BDA_KBD_BUF_TAIL 0x001C
#define BDA_KBD_BUF_START 0x001E
#define BDA_KBD_BUF_END (BDA_KBD_BUF_START + BIOS_KBD_BUFFER_BYTES)
#define BDA_FLOPPY_RECAL 0x003E
#define BDA_FLOPPY_MOTOR 0x003F
#define BDA_FLOPPY_MOTOR_TIMEOUT 0x0040
#define BDA_FLOPPY_STATUS 0x0041
#define BDA_FDC_RESULT_BASE 0x0042
#define BDA_VIDEO_MODE 0x0049
#define BDA_VIDEO_COLUMNS 0x004A
#define BDA_VIDEO_PAGE_SIZE 0x004C
#define BDA_VIDEO_PAGE_OFFSET 0x004E
#define BDA_CURSOR_POSITIONS 0x0050
#define BDA_CURSOR_TYPE 0x0060
#define BDA_ACTIVE_PAGE 0x0062
#define BDA_CRTC_PORT 0x0063
#define BDA_VIDEO_MISC 0x0065
#define BDA_VIDEO_PALETTE 0x0066
#define BDA_IO_ROM_INIT_OFF 0x0067
#define BDA_IO_ROM_INIT_SEG 0x0069
#define BDA_VIDEO_ROWS_MINUS_ONE 0x0084
#define BDA_VIDEO_CHAR_POINTS 0x0085
#define BDA_VIDEO_EGC_STATUS 0x0087
#define BDA_VIDEO_SWITCHES 0x0088
#define BDA_VIDEO_CHAR_HEIGHT BDA_VIDEO_CHAR_POINTS
#define BDA_VIDEO_CONTROL_FLAGS BDA_VIDEO_EGC_STATUS
#define BDA_TIMER_TICKS 0x006C
#define BDA_TIMER_MIDNIGHT 0x0070
#define BDA_BREAK_FLAG 0x0071
#define BDA_WARM_BOOT_FLAG 0x0072
#define BDA_HARD_DISK_STATUS 0x0074
#define BDA_HARD_DISK_COUNT 0x0075
#define BDA_HARD_DISK_CONTROL 0x0076
#define BDA_HARD_DISK_PORT_OFFSET 0x0077
#define BDA_PRINTER_TIMEOUT_BASE 0x0078
#define BDA_SERIAL_TIMEOUT_BASE 0x007C
#define BDA_KBD_BUF_START_PTR 0x0080
#define BDA_KBD_BUF_END_PTR 0x0082

/* ================================================
 * Keyboard status flags
 * ================================================ */

/* Keyboard status flag bits in BDA 0x417. */
#define KBD_FLAG_RIGHT_SHIFT 0x01
#define KBD_FLAG_LEFT_SHIFT 0x02
#define KBD_FLAG_CTRL 0x04
#define KBD_FLAG_ALT 0x08
#define KBD_FLAG_SCROLL_LOCK 0x10
#define KBD_FLAG_NUM_LOCK 0x20
#define KBD_FLAG_CAPS_LOCK 0x40
#define KBD_FLAG_INSERT 0x80
#define KBD_FLAG_PAUSE_ACTIVE 0x08
#define KBD_FLAG_SCROLL_DOWN 0x10
#define KBD_FLAG_NUM_DOWN 0x20
#define KBD_FLAG_CAPS_DOWN 0x40
#define KBD_FLAG_INSERT_DOWN 0x80

#define BIOS_KBD_BUFFER_BYTES 32

/* ================================================
 * Work area offsets
 * ================================================ */

/* Keep ROS scratch storage inside the original PC1640 ROS RAM window. */
#define BIOS_WORK_BASE 0x0300
#define BIOS_PRINT_SCREEN_STATUS 0x0500
#define WK_PORT61 0x0000
#define WK_PORT62 0x0001
#define WK_PORT64 0x0002
#define WK_PORT65 0x0003
#define WK_CMOS_INDEX 0x0004
/* 0x0005 reserved */
/* 0x0006 is intentionally unused after removing language bookkeeping. */
#define WK_BOOT_FLAGS 0x0007
#define WK_SOFT_RESET_LATCH 0x0008
#define WK_FDC_STATUS 0x000A
#define WK_SERIAL_STATUS 0x000B
#define WK_PRINTER_STATUS 0x000C
#define WK_LPT1_STATUS 0x000D
#define WK_LAST_KBD_SCANCODE 0x000E
#define WK_LAST_KBD_ASCII 0x000F
#define WK_KBD_PREFIX 0x0010
#define WK_KBD_LED_STATE 0x0011
#define WK_VIDEO_ATTRIBUTE 0x0012
#define WK_RTC_ALARM_STATE 0x0013
#define WK_NMI_MASK 0x0014
#define WK_FDC_IRQ_PENDING 0x0015
#define WK_FDC_CYLINDER_0 0x0016
#define WK_FDC_CYLINDER_1 0x0017
#define WK_LAST_KBD_RAW 0x0018
#define WK_VIDEO_FONT_BLOCK 0x0019
#define WK_BOOT_INT13_REGS_SS 0x001A
/*
 * INT 19h bootstrap INT 13h proxy: bios_regs_t (20 bytes) in low RAM so
 * bios_service_int13 can use a real __far pointer.  Stack-resident structs
 * passed as (bios_regs_t __far *)&auto break when DS != SS in XIP.
 *
 * Must NOT live under BIOS_WORK_BASE (0x300): that overlaps the real-mode IVT
 * (INT C0h–FFh) and corrupts vectors whenever the proxy is written — floppy
 * IRQ / option ROMs can then fail unpredictably.  Use the low RAM window just
 * above the print-screen status byte (0500h), which is free on PC/XT class
 * hardware during POST/bootstrap.
 */
#define BIOS_BOOT_INT13_PROXY_OFF 0x0510
#define WK_CMOS_SHADOW 0x0040

/* ================================================
 * IDE constants
 * ================================================ */

#define IDE_STATUS_ERR 0x01
#define IDE_STATUS_DRQ 0x08
#define IDE_STATUS_DF 0x20
#define IDE_STATUS_DRDY 0x40
#define IDE_STATUS_BSY 0x80

#define IDE_ERROR_ABRT 0x04
#define IDE_ERROR_IDNF 0x10
#define IDE_ERROR_UNC 0x40
#define IDE_ERROR_BBK 0x80

#define IDE_CMD_READ_SECTORS 0x20
#define IDE_CMD_WRITE_SECTORS 0x30
#define IDE_CMD_IDENTIFY 0xEC

#define IDE_DEVCTL_NIEN 0x02
#define IDE_DEVCTL_SRST 0x04

#define BOOT_FLAG_WARM 0x01
#define BOOT_FLAG_BATTERY_LOW 0x02
#define BOOT_FLAG_KBD_FAULT 0x04
#define BOOT_FLAG_BOOT_FAILED 0x08
#define BOOT_FLAG_RAM_FAULT 0x10
#define BOOT_FLAG_VDU_FAULT 0x20
#define BOOT_FLAG_ROS_FAULT 0x40

/* INT 13h style status bytes used by the XT/AT BIOS family. */
#define FLOPPY_ST_OK 0x00
#define FLOPPY_ST_BAD_COMMAND 0x01
#define FLOPPY_ST_ADDR_MARK 0x02
#define FLOPPY_ST_WRITE_PROTECT 0x03
#define FLOPPY_ST_SECTOR_NOT_FOUND 0x04
#define FLOPPY_ST_RESET_FAILED 0x05
#define FLOPPY_ST_DISK_CHANGED 0x06
#define FLOPPY_ST_DMA_OVERRUN 0x08
#define FLOPPY_ST_DMA_BOUNDARY 0x09
#define FLOPPY_ST_BAD_CRC 0x10
#define FLOPPY_ST_CONTROLLER 0x20
#define FLOPPY_ST_SEEK_FAILED 0x40
#define FLOPPY_ST_TIMEOUT 0x80

/* ================================================
 * Video constants
 * ================================================ */

/* INT 10h mode numbers used by the legacy ROM services. */
#define VIDEO_MODE_40X25_BW 0x00
#define VIDEO_MODE_40X25_COLOR 0x01
#define VIDEO_MODE_80X25_BW 0x02
#define VIDEO_MODE_80X25_COLOR 0x03
#define VIDEO_MODE_320X200_COLOR 0x04
#define VIDEO_MODE_320X200_BW 0x05
#define VIDEO_MODE_640X200_BW 0x06
#define VIDEO_MODE_80X25_MONO 0x07

/* ================================================
 * CMOS register map
 * ================================================ */

/* CMOS bytes used by the original ROM. */
#define CMOS_REG_A 0x0A
#define CMOS_REG_B 0x0B
#define CMOS_REG_C 0x0C
#define CMOS_REG_D 0x0D
#define CMOS_ALARM_SECONDS 0x01
#define CMOS_ALARM_MINUTES 0x03
#define CMOS_ALARM_HOURS 0x05
#define CMOS_SECONDS 0x00
#define CMOS_MINUTES 0x02
#define CMOS_HOURS 0x04
#define CMOS_DAY_OF_MONTH 0x07
#define CMOS_MONTH 0x08
#define CMOS_YEAR 0x09
#define CMOS_DIAGNOSTIC_STATUS 0x0E
#define CMOS_SHUTDOWN_STATUS 0x0F
#define CMOS_FLOPPY_TYPES 0x10
#define CMOS_HARD_DISKS 0x12
#define CMOS_EQUIPMENT 0x14
#define CMOS_BASE_MEMORY_LOW 0x15
#define CMOS_BASE_MEMORY_HIGH 0x16
#define CMOS_EXT_MEMORY_LOW 0x17
#define CMOS_EXT_MEMORY_HIGH 0x18
#define CMOS_CENTURY 0x32

#define CMOS_NVR_LAST_USED_SECONDS 0x0E
#define CMOS_NVR_LAST_USED_MINUTES 0x0F
#define CMOS_NVR_LAST_USED_HOURS 0x10
#define CMOS_NVR_LAST_USED_DAY 0x11
#define CMOS_NVR_LAST_USED_MONTH 0x12
#define CMOS_NVR_LAST_USED_YEAR 0x13
#define CMOS_NVR_CHECKSUM 0x14
#define CMOS_NVR_ENTER_KEY_LO 0x15
#define CMOS_NVR_ENTER_KEY_HI 0x16
#define CMOS_NVR_DELETE_KEY_LO 0x17
#define CMOS_NVR_DELETE_KEY_HI 0x18
#define CMOS_NVR_JOYSTICK1_LO 0x19
#define CMOS_NVR_JOYSTICK1_HI 0x1A
#define CMOS_NVR_JOYSTICK2_LO 0x1B
#define CMOS_NVR_JOYSTICK2_HI 0x1C
#define CMOS_NVR_MOUSE1_LO 0x1D
#define CMOS_NVR_MOUSE1_HI 0x1E
#define CMOS_NVR_MOUSE2_LO 0x1F
#define CMOS_NVR_MOUSE2_HI 0x20
#define CMOS_NVR_MOUSE_X_SCALE 0x21
#define CMOS_NVR_MOUSE_Y_SCALE 0x22
#define CMOS_NVR_VDU_MODE 0x23
#define CMOS_NVR_VDU_ATTR 0x24
#define CMOS_NVR_RAMDISK_SIZE 0x25
#define CMOS_NVR_UART_SYSTEM 0x26
#define CMOS_NVR_UART_EXTERNAL 0x27
/*
 * The original PC1640 ROS validates the NVR block from CMOS locations 14-63
 * decimal, which is 0x14-0x3F in the RTC index space.
 */
#define CMOS_NVR_CHECKSUM_START 0x14
#define CMOS_NVR_CHECKSUM_END 0x3F

#define CMOS_REG_B_24HOUR 0x02
#define CMOS_REG_B_SET_CLOCK 0x80
#define CMOS_REG_B_DAYLIGHT 0x01
#define CMOS_REG_B_ALARM_IRQ 0x20
#define CMOS_REG_A_UPDATE_IN_PROGRESS 0x80
#define CMOS_REG_D_VRT 0x80

#endif
