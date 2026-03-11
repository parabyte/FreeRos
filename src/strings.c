#include "bios.h"

const bios_rom_string_t bios_rom_strings[] = {
#include "bios_strings.inc"
};

const u16 bios_rom_string_count =
  (u16) (sizeof (bios_rom_strings) / sizeof (bios_rom_strings[0]) - 1U);

/*
 * The original BIOS stores many user-facing messages as fragments. These
 * clean-room aliases keep POST code readable while preserving the complete
 * extracted ROM string table above.
 */
const char bios_str_en_battery_warning[] = "Please fit new batteries";
const char bios_str_en_check_keyboard_mouse[] = "Check keyboard and mouse";
const char bios_str_en_insert_system_disk[] =
  "Please insert SYSTEM disk in drive A\\Then press any key";
const char bios_str_en_error_prefix[] = "Error";
const char bios_str_en_wait[] = "Please wait";
const char bios_str_en_memory_parity[] = "memory (parity error)";
const char bios_str_en_vdu_ram[] = "VDU RAM";
const char bios_str_amstrad_copyright[] = "(c)1988 Amstrad plc";

const char *
bios_lookup_rom_string (u16 rom_offset)
{
  u16 i;

  for (i = 1; i <= bios_rom_string_count; ++i)
    if (bios_rom_strings[i].rom_offset == rom_offset)
      return bios_rom_strings[i].text;
  return 0;
}
