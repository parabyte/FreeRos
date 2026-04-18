/*
 * Included from config.h when building the standalone C000h PEGA video ROM
 * (make target video-pega-rom).  Overrides motherboard XIP segment so
 * BIOS_ROM_SEGMENT and vector installs target 0xC000.
 */
#undef BIOS_CFG_EXECUTE_IN_PLACE
#define BIOS_CFG_EXECUTE_IN_PLACE 0

#undef BIOS_CFG_ROM_ENTRY_SEGMENT
#define BIOS_CFG_ROM_ENTRY_SEGMENT 0xC000

#undef BIOS_CFG_RUNTIME_SEGMENT
#define BIOS_CFG_RUNTIME_SEGMENT 0xC000

#undef BIOS_CFG_VIDEO_PEGA_INROM_DRIVER
#define BIOS_CFG_VIDEO_PEGA_INROM_DRIVER 1

#undef BIOS_CFG_VIDEO_PEGA_STANDALONE_ROM
#define BIOS_CFG_VIDEO_PEGA_STANDALONE_ROM 1
