/* ================================================
 * FreeRos BIOS
 * strings.c: Runtime string table definitions
 * ================================================ */

#include "bios.h"

/* English-only POST strings to keep the 32 KiB ROM within budget. */
const char bios_str_en_battery_warning[] = "Battery low";
const char bios_str_en_check_keyboard_mouse[] = "Keyboard/mouse";
const char bios_str_en_insert_system_disk[] =
  "Insert SYSTEM disk";
const char bios_str_en_error_prefix[] = "Err";
const char bios_str_en_memory_parity[] = "Parity";
const char bios_str_en_vdu_ram[] = "VDU RAM";
const char bios_str_en_ros_checksum[] = "Checksum";
const char bios_hex_digits[] = "0123456789ABCDEF";
