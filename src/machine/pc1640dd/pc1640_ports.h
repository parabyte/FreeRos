/* ================================================
 * FreeRos BIOS
 * pc1640_ports.h: Amstrad PC1640 port definitions and NVR register map
 * ================================================ */

#ifndef FREEROS_PC1640_PORTS_H
#define FREEROS_PC1640_PORTS_H

/* ================================================
 * Mouse port definitions
 * ================================================ */

/* Amstrad mouse interface. */
#define PORT_MOUSE_X 0x0078
#define PORT_MOUSE_Y 0x007A

/* ================================================
 * System control port bits
 * ================================================ */

/* Port 61h shadow: NVR low nibble select bit. */
#define PORT61_NVR_LOW_NIBBLE 0x04

/* LPT1 status bits used as language straps on the PC1640. */
#define LPT1_STATUS_LANGUAGE_MASK 0x07
#define LPT1_STATUS_DIP_LATCH 0x20

/* ================================================
 * Display switch latch definitions
 * ================================================ */

/*
 * PC1640 display switches exposed through the printer status latch.
 * A dummy read from 0x0078 selects SW9 and from 0x4278 selects SW10
 * before the following read from 0x037A.
 */
#define PORT_PC1640_SW9_LATCH 0x0078
#define PORT_PC1640_SW10_LATCH 0x4278
#define LPT1_CONTROL_SWITCH_SW10 0x20
#define LPT1_CONTROL_SWITCH_SW9 0x20
#define LPT1_CONTROL_SWITCH_SW6 0x40
#define LPT1_CONTROL_SWITCH_SW7 0x80

/* ================================================
 * NVR (Non-Volatile RAM) CMOS register layout
 * ================================================ */

/* Amstrad NVR (Non-Volatile RAM) CMOS register layout. */
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
#define CMOS_NVR_BOOT_STATE 0x28
#define CMOS_NVR_CHECKSUM_START 0x14
#define CMOS_NVR_CHECKSUM_END 0x3F

#endif
