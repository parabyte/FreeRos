#include "bios.h"

typedef struct bios_saved_vector
{
  u16 off;
  u16 seg;
} bios_saved_vector_t;

static bios_saved_vector_t
bios_read_ivt_vector (u8 intno)
{
  bios_saved_vector_t vector;
  u16 off;

  off = (u16) intno * 4U;
  vector.off = bios_abs_read16 (0x0000, off);
  vector.seg = bios_abs_read16 (0x0000, (u16) (off + 2U));
  return vector;
}

static void
bios_write_ivt_vector (u8 intno, bios_saved_vector_t vector)
{
  u16 off;

  off = (u16) intno * 4U;
  bios_abs_write16 (0x0000, off, vector.off);
  bios_abs_write16 (0x0000, (u16) (off + 2U), vector.seg);
}

static void
bios_clear_low_memory_state (void)
{
  u16 i;
  u16 warm_boot_flag;

  warm_boot_flag = bios_abs_read16 (0x0000, BDA_WARM_BOOT_FLAG);

  /*
   * The original ROM starts from a scrubbed IVT/BDA work area. The PC1640
   * video ROM touches BDA bytes like 0x487/0x488 during early init, so leaving
   * low memory uninitialized can break display bring-up before POST text.
   */
  for (i = 0; i != 0x0700; ++i)
    bios_abs_write8 (0x0000, i, 0);

  bios_abs_write16 (0x0000, BDA_WARM_BOOT_FLAG, warm_boot_flag);
}

void
bios_install_bda_tables (void)
{
  u16 i;

  bios_bda_write16 (BDA_COM1_BASE, BIOS_CFG_COM1_BASE);
  bios_bda_write16 (BDA_COM2_BASE, BIOS_CFG_COM2_BASE);
  bios_bda_write16 (BDA_LPT1_BASE, BIOS_CFG_LPT1_BASE);
  bios_bda_write16 (BDA_LPT2_BASE, BIOS_CFG_LPT2_BASE);

  bios_bda_write16 (BDA_EQUIPMENT_WORD, bios_build_equipment_word ());
  bios_bda_write16 (BDA_MEMORY_SIZE_KB, BIOS_CFG_BASE_MEMORY_KB);
  bios_bda_write16 (BDA_EXTRA_MEMORY_KB,
		    BIOS_CFG_BASE_MEMORY_KB > 64
		    ? (u16) (BIOS_CFG_BASE_MEMORY_KB - 64)
		    : 0);
  bios_bda_write16 (BDA_KBD_BUF_HEAD, BDA_KBD_BUF_START);
  bios_bda_write16 (BDA_KBD_BUF_TAIL, BDA_KBD_BUF_START);
  bios_bda_write16 (BDA_KBD_BUF_START_PTR, BDA_KBD_BUF_START);
  bios_bda_write16 (BDA_KBD_BUF_END_PTR, BDA_KBD_BUF_END);
  bios_bda_write16 (BDA_CURSOR_TYPE, 0x0607);
  bios_bda_write8 (BDA_ACTIVE_PAGE, 0x00);
  bios_bda_write16 (BDA_CRTC_PORT, BIOS_CFG_VIDEO_CRTC_PORT);
  bios_bda_write32 (BDA_TIMER_TICKS, 0);
  bios_bda_write8 (BDA_TIMER_MIDNIGHT, 0);
  bios_bda_write8 (BDA_HARD_DISK_STATUS, 0x00);
  bios_bda_write8 (BDA_HARD_DISK_COUNT, 0x00);
  bios_bda_write8 (BDA_HARD_DISK_CONTROL, 0x00);
  bios_bda_write8 (BDA_HARD_DISK_PORT_OFFSET, 0x00);
  bios_abs_write8 (0x0000, BIOS_PRINT_SCREEN_STATUS, 0x00);

  for (i = 0; i != 4; ++i)
    {
      bios_bda_write8 ((u16) (BDA_PRINTER_TIMEOUT_BASE + i), 20);
      bios_bda_write8 ((u16) (BDA_SERIAL_TIMEOUT_BASE + i), 1);
    }
}

extern u8 __bss_start[];
extern u8 __bss_end[];

static void
bios_clear_bss (void)
{
  volatile u8 *p;

  for (p = (volatile u8 *) __bss_start; p != (volatile u8 *) __bss_end; ++p)
    *p = 0;
}

void
bios_main (void)
{
  bios_saved_vector_t int10_vector;
  bios_saved_vector_t int1d_vector;
  bios_saved_vector_t int1f_vector;
  bios_saved_vector_t int42_vector;
  bios_saved_vector_t int43_vector;

  /* Debug: port E9 trace */
  bios_hw_out8 ('M', 0xE9);

  bios_clear_bss ();

  bios_hw_out8 ('B', 0xE9);

  bios_clear_low_memory_state ();
  bios_install_bda_tables ();
  bios_io_init_defaults ();
  bios_install_vectors ();

  bios_hw_out8 ('V', 0xE9);

  bios_video_init ();

  bios_hw_out8 ('W', 0xE9);

  /*
   * The PEGA1A option ROM at C000h hardcodes vector offsets matching the
   * original Amstrad system ROM layout.  Our C-compiled ROM has different
   * code placement, so every non-video vector the PEGA ROM "normalises"
   * ends up pointing at the wrong address.  Fix this by reinstalling all
   * vectors, then restoring the video-related vectors exactly as the PEGA
   * ROM left them.  On the PC1640 this reliably covers INT 10h (video
   * services), INT 42h (original video), and INT 43h (EGA font pointer),
   * with INT 1Dh/INT 1Fh preserved if the option ROM populated them.
   */
  int10_vector = bios_read_ivt_vector (0x10);
  int1d_vector = bios_read_ivt_vector (0x1D);
  int1f_vector = bios_read_ivt_vector (0x1F);
  int42_vector = bios_read_ivt_vector (0x42);
  int43_vector = bios_read_ivt_vector (0x43);

  bios_install_vectors ();

  bios_write_ivt_vector (0x10, int10_vector);
  bios_write_ivt_vector (0x1D, int1d_vector);
  bios_write_ivt_vector (0x1F, int1f_vector);
  bios_write_ivt_vector (0x42, int42_vector);
  bios_write_ivt_vector (0x43, int43_vector);

  bios_post_cold_boot ();
}
