#include "bios.h"

static void
bios_clear_low_memory_state (void)
{
  u16 i;

  /*
   * The original ROM starts from a scrubbed IVT/BDA work area. The PC1640
   * video ROM touches BDA bytes like 0x487/0x488 during early init, so leaving
   * low memory uninitialized can break display bring-up before POST text.
   */
  for (i = 0; i != 0x0600; ++i)
    bios_abs_write8 (0x0000, i, 0);
}

void
bios_install_bda_tables (void)
{
  bios_bda_write16 (BDA_COM1_BASE, BIOS_CFG_COM1_BASE);
  bios_bda_write16 (BDA_COM2_BASE, BIOS_CFG_COM2_BASE);
  bios_bda_write16 (BDA_LPT1_BASE, BIOS_CFG_LPT1_BASE);
  bios_bda_write16 (BDA_LPT2_BASE, BIOS_CFG_LPT2_BASE);

  bios_bda_write16 (BDA_EQUIPMENT_WORD, bios_build_equipment_word ());
  bios_bda_write16 (BDA_MEMORY_SIZE_KB, BIOS_CFG_BASE_MEMORY_KB);
  bios_bda_write16 (BDA_KBD_BUF_HEAD, BDA_KBD_BUF_START);
  bios_bda_write16 (BDA_KBD_BUF_TAIL, BDA_KBD_BUF_START);
  bios_bda_write16 (BDA_CURSOR_TYPE, 0x0607);
  bios_bda_write8 (BDA_ACTIVE_PAGE, 0x00);
  bios_bda_write16 (BDA_CRTC_PORT, BIOS_CFG_VIDEO_CRTC_PORT);
  bios_bda_write32 (BDA_TIMER_TICKS, 0);
  bios_bda_write8 (BDA_TIMER_MIDNIGHT, 0);
}

void
bios_main (void)
{
  bios_clear_low_memory_state ();
  bios_install_bda_tables ();
  bios_io_init_defaults ();
  bios_install_vectors ();
  bios_video_init ();
  bios_post_cold_boot ();
}
