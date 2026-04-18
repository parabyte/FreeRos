/* ================================================
 * FreeRos BIOS
 * main.c: Entry point, BDA initialization, and BSS clearing
 * ================================================ */

#include "bios.h"
#include "machine.h"

void
bios_prepare_low_memory_state (void)
{
  u16 warm_boot_flag;

  warm_boot_flag = bios_abs_read16 (0x0000, BDA_WARM_BOOT_FLAG);

  if (machine_preserve_low_memory_state (warm_boot_flag))
    return;

  /*
   * Scrub only the documented low-memory ROS state: IVT, BDA, the PC1640
   * init-stack window at 0x0300-0x03FF, and the ROS variable area through
   * the print-screen status byte at 0x0500.
   */
  bios_mem_fill16 (0x0000, 0x0000, 0x0000, 0x0280);
  bios_abs_write8 (0x0000, BIOS_PRINT_SCREEN_STATUS, 0x00);

  bios_abs_write16 (0x0000, BDA_WARM_BOOT_FLAG, warm_boot_flag);
}

typedef struct bios_bda_init16_entry
{
  u16 off;
  u16 val;
} __attribute__((packed)) bios_bda_init16_entry_t;

static const bios_bda_init16_entry_t bios_bda_init16_table[] = {
  { BDA_COM1_BASE, BIOS_CFG_COM1_BASE },
  { BDA_COM2_BASE, BIOS_CFG_COM2_BASE },
  { BDA_LPT1_BASE, BIOS_CFG_LPT1_BASE },
  { BDA_LPT2_BASE, BIOS_CFG_LPT2_BASE },
  { BDA_MEMORY_SIZE_KB, BIOS_CFG_BASE_MEMORY_KB },
  { BDA_EXTRA_MEMORY_KB, BIOS_CFG_BASE_MEMORY_KB > 64
    ? (u16) (BIOS_CFG_BASE_MEMORY_KB - 64) : 0 },
  { BDA_KBD_BUF_HEAD, BDA_KBD_BUF_START },
  { BDA_KBD_BUF_TAIL, BDA_KBD_BUF_START },
  { BDA_KBD_BUF_START_PTR, BDA_KBD_BUF_START },
  { BDA_KBD_BUF_END_PTR, BDA_KBD_BUF_END },
};

/* ================================================
 * BDA initialization
 * ================================================ */

void
bios_install_bda_tables (void)
{
  u8 i;

  /*
   * Seed only the motherboard-owned BDA fields here. On the PC1640 build the
   * video adapter ROM owns the classic video slots until the machine-specific
   * POST path decides which values may safely be mirrored into low memory.
   */
  for (i = 0; i != sizeof (bios_bda_init16_table)
	 / sizeof (bios_bda_init16_table[0]); ++i)
    bios_bda_write16 (bios_bda_init16_table[i].off,
		      bios_bda_init16_table[i].val);

  bios_bda_write16 (BDA_EQUIPMENT_WORD, bios_build_equipment_word ());
  bios_bda_write32 (BDA_TIMER_TICKS, 0);

  for (i = 0; i != 4; ++i)
    bios_bda_write8 ((u16) (BDA_PRINTER_TIMEOUT_BASE + i), 20);

  for (i = 0; i != 4; ++i)
    bios_bda_write8 ((u16) (BDA_SERIAL_TIMEOUT_BASE + i), 1);
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

/* ================================================
 * Entry point
 * ================================================ */

void
bios_main (void)
{
  bios_clear_bss ();

  machine_post_early_init ();
  /*
   * Seed the motherboard IVT first so option-ROM init can safely issue BIOS
   * service calls (the stock PC1640 PEGA ROM uses INT 15h during C000 init).
   * After the video ROM returns, reapply the motherboard service vectors while
   * preserving the PEGA-owned runtime entries.
   *
   * The IVT *must* be populated before bios_post_hardware_init() enables
   * any device IRQs (FDC reset unmasks IRQ6, PIT enables IRQ0).  Without
   * valid vectors the CPU would execute from 0000:0000 on the first
   * interrupt.  BDA tables are deferred to machine_post_publish_runtime_state
   * after the destructive RAM test, but the IRQ dispatch path only needs
   * the IVT entries.
   */
  bios_io_init_defaults ();
  bios_install_vectors ();
  machine_video_init ();
  machine_post_vectors_fixup ();

  bios_post_cold_boot ();
}
