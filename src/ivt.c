/* ================================================
 * FreeRos BIOS
 * ivt.c: Interrupt vector table installation
 * ================================================ */

#include "bios.h"

/* ================================================
 * External wrapper declarations
 * ================================================ */

void __far bios_default_wrapper (void);
#if BIOS_CFG_PRINTER_ENABLED
void __far bios_irq5_wrapper (void);
#endif
void __far bios_irq0_wrapper (void);
void __far bios_irq1_wrapper (void);
void __far bios_irq6_wrapper (void);
#if BIOS_CFG_PRINTER_ENABLED
void __far bios_irq7_wrapper (void);
#endif
void __far bios_nmi_wrapper (void);
#if BIOS_CFG_PRINTER_ENABLED
void __far bios_int05_wrapper (void);
#endif
void __far bios_int06_wrapper (void);
void __far bios_int11_wrapper (void);
void __far bios_int12_wrapper (void);
void __far bios_int15_wrapper (void);
void __far bios_int10_wrapper (void);
void __far bios_int13_wrapper (void);
#if BIOS_CFG_SERIAL_INT14_ENABLED
void __far bios_int14_wrapper (void);
#endif
void __far bios_int16_wrapper (void);
#if BIOS_CFG_PRINTER_ENABLED
void __far bios_int17_wrapper (void);
#endif
void __far bios_int18_wrapper (void);
void __far bios_int19_wrapper (void);
void __far bios_int1a_wrapper (void);
void __far bios_int1b_wrapper (void);
void __far bios_int1c_wrapper (void);
#if BIOS_CFG_EMS_ENABLED
void __far bios_int67_wrapper (void);
#endif

/* ================================================
 * Types and vector table
 * ================================================ */

typedef struct bios_vector_entry
{
  u8 intno;
  u16 handler_off;
} __attribute__((packed)) bios_vector_entry_t;

#define BIOS_VEC(intno, handler) \
  { (intno), __builtin_ia16_FP_OFF (handler) }

static const bios_vector_entry_t bios_vector_table[] = {
  BIOS_VEC (0x02, bios_nmi_wrapper),
#if BIOS_CFG_PRINTER_ENABLED
  BIOS_VEC (0x05, bios_int05_wrapper),
#endif
  BIOS_VEC (0x06, bios_int06_wrapper),
  BIOS_VEC (0x08, bios_irq0_wrapper),
  BIOS_VEC (0x09, bios_irq1_wrapper),
#if BIOS_CFG_PRINTER_ENABLED
  BIOS_VEC (0x0D, bios_irq5_wrapper),
#endif
  BIOS_VEC (0x0E, bios_irq6_wrapper),
#if BIOS_CFG_PRINTER_ENABLED
  BIOS_VEC (0x0F, bios_irq7_wrapper),
#endif
  BIOS_VEC (0x10, bios_int10_wrapper),
  BIOS_VEC (0x11, bios_int11_wrapper),
  BIOS_VEC (0x12, bios_int12_wrapper),
  BIOS_VEC (0x13, bios_int13_wrapper),
#if BIOS_CFG_SERIAL_INT14_ENABLED
  BIOS_VEC (0x14, bios_int14_wrapper),
#endif
  BIOS_VEC (0x15, bios_int15_wrapper),
  BIOS_VEC (0x16, bios_int16_wrapper),
#if BIOS_CFG_PRINTER_ENABLED
  BIOS_VEC (0x17, bios_int17_wrapper),
#endif
  BIOS_VEC (0x18, bios_int18_wrapper),
  BIOS_VEC (0x19, bios_int19_wrapper),
  BIOS_VEC (0x1A, bios_int1a_wrapper),
  BIOS_VEC (0x1B, bios_int1b_wrapper),
  BIOS_VEC (0x1C, bios_int1c_wrapper),
  BIOS_VEC (0x40, bios_int13_wrapper),
  BIOS_VEC (0x42, bios_int10_wrapper),
#if BIOS_CFG_EMS_ENABLED
  BIOS_VEC (0x67, bios_int67_wrapper),
#endif
};

/* ================================================
 * Vector installation
 * ================================================ */

static void
bios_install_service_vectors (void)
{
  u8 intno;
  u8 i;
  bios_far_vector_t __far *ivt;
  u16 default_off;

  ivt = (bios_far_vector_t __far *) BIOS_MK_FP (0, 0);
  default_off = __builtin_ia16_FP_OFF (bios_default_wrapper);

  /* Set INT 00h-1Fh to default IRET handler. */
  for (intno = 0; intno != 0x20; ++intno)
    {
      ivt[intno].off = default_off;
      ivt[intno].seg = BIOS_ROM_SEGMENT;
    }

  /* Install specific service handlers from table. */
  for (i = 0; i != sizeof (bios_vector_table) / sizeof (bios_vector_table[0]);
       ++i)
    {
      ivt[bios_vector_table[i].intno].off = bios_vector_table[i].handler_off;
      ivt[bios_vector_table[i].intno].seg = BIOS_ROM_SEGMENT;
    }

  /*
   * Built-in video targets export the standard tables from the system ROM.
   * Stock PC1640 leaves these to the C000 adapter BIOS until it runs.
   */
#if BIOS_CFG_VIDEO_PEGA_INROM_DRIVER
  extern const u8 bios_video_pega_font_en_8x14[];

  BIOS_INSTALL_DATA_VECTOR (0x1D, bios_video_parameter_table);
  BIOS_INSTALL_DATA_VECTOR (0x1F, bios_video_pega_font_en_8x14);
  BIOS_INSTALL_DATA_VECTOR (0x43, bios_video_pega_font_en_8x14);
#else
  bios_abs_write32 (0x0000, (u16) 0x1D * 4U, 0x00000000UL);
  bios_abs_write32 (0x0000, (u16) 0x1F * 4U, 0x00000000UL);
  bios_abs_write32 (0x0000, (u16) 0x43 * 4U, 0x00000000UL);
#endif
#if BIOS_CFG_HAS_FLOPPY_CONTROLLER
  BIOS_INSTALL_DATA_VECTOR (0x1E, bios_diskette_parameter_table);
#else
  bios_abs_write32 (0x0000, (u16) 0x1E * 4U, 0x00000000UL);
#endif
  bios_abs_write32 (0x0000, (u16) 0x44 * 4U, 0x00000000UL);
  bios_abs_write32 (0x0000, (u16) 0x41 * 4U, 0x00000000UL);
  bios_abs_write32 (0x0000, (u16) 0x46 * 4U, 0x00000000UL);
}

#if BIOS_CFG_PRINTER_ENABLED
void
bios_irq5_handler (void)
{
  bios_pic_ack_irq (5);
}
#endif

void
bios_install_vectors (void)
{
  bios_install_service_vectors ();
}
