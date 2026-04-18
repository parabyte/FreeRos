#include "bios.h"

extern void __far bios_int10_wrapper (void);

void
bios_video_pega_standalone_init (void)
{
  BIOS_INSTALL_VECTOR (0x10, bios_int10_wrapper);
  BIOS_INSTALL_VECTOR (0x42, bios_int10_wrapper);
  BIOS_INSTALL_DATA_VECTOR (0x1D, bios_video_parameter_table);
  BIOS_INSTALL_DATA_VECTOR (0x1F, bios_video_pega_font_en_8x14);
  BIOS_INSTALL_DATA_VECTOR (0x43, bios_video_pega_font_en_8x14);

  bios_video_pega_apply_text_mode (VIDEO_MODE_80X25_COLOR, 1);
}
