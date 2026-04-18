#include "bios.h"

/*
 * Original INT 1Eh diskette parameter table bytes from ROM address 0xFEFC7.
 */
#define BIOS_FLOPPY_DPT_360K \
  { 0xDF, 0x02, 0x64, 0x02, 0x09, 0x2A, 0xFF, 0x50, 0xF6, 0x0F, 0x04 }
#define BIOS_FLOPPY_DPT_720K \
  { 0xDF, 0x02, 0x64, 0x02, 0x09, 0x2A, 0xFF, 0x50, 0xF6, 0x0F, 0x04 }

typedef struct bios_floppy_drive_geometry
{
  u8 type;
  u8 tracks;
  u8 heads;
  u8 sectors;
  u8 data_rate;
  const u8 *parameter_table;
} bios_floppy_drive_geometry_t;

#define BIOS_FIXED_DISK_DPT0_OFF 0x0530
#define BIOS_FIXED_DISK_DPT1_OFF 0x0540
#define BIOS_FIXED_DISK_DPT_SIZE 16

#if BIOS_CFG_TARGET_PC1640DD && !BIOS_CFG_XTIDE_ENABLED
#define BIOS_PC1640_FLOPPY_DPT_ATTR __attribute__((section(".rodata.compat_floppy")))
#else
#define BIOS_PC1640_FLOPPY_DPT_ATTR
#endif
/*
 * The stock 360K and 720K PC1640 tables are byte-identical, so keep one
 * motherboard-owned DPT and publish it at the original ROM offset.
 */
#if BIOS_CFG_FLOPPY_TYPE_A == BIOS_FLOPPY_TYPE_720K_35DD
const u8 bios_diskette_parameter_table[11] BIOS_PC1640_FLOPPY_DPT_ATTR
  = BIOS_FLOPPY_DPT_720K;
#else
const u8 bios_diskette_parameter_table[11] BIOS_PC1640_FLOPPY_DPT_ATTR
  = BIOS_FLOPPY_DPT_360K;
#endif

#undef BIOS_FLOPPY_DPT_360K
#undef BIOS_FLOPPY_DPT_720K
#undef BIOS_PC1640_FLOPPY_DPT_ATTR

#if BIOS_CFG_FDC_BOOT_TRACE_E9
static void
bios_floppy_trace_emit (u8 value)
{
  bios_hw_out8 (value, 0x00E9);
}

static void
bios_floppy_trace_read_begin (const bios_regs_t __far *regs)
{
  bios_floppy_trace_emit ('R');
  bios_floppy_trace_emit (bios_lo (regs->ax));
  bios_floppy_trace_emit (bios_hi (regs->cx));
  bios_floppy_trace_emit (bios_hi (regs->dx));
  bios_floppy_trace_emit (bios_lo (regs->cx));
  bios_floppy_trace_emit (bios_hi (regs->es));
  bios_floppy_trace_emit (bios_lo (regs->es));
  bios_floppy_trace_emit (bios_hi (regs->bx));
  bios_floppy_trace_emit (bios_lo (regs->bx));
}

static void
bios_floppy_trace_read_done (const bios_regs_t __far *regs, u8 status, u8 count)
{
  bios_floppy_trace_emit ('r');
  bios_floppy_trace_emit (status);
  bios_floppy_trace_emit (count);
  bios_floppy_trace_emit (bios_hi (regs->es));
  bios_floppy_trace_emit (bios_lo (regs->es));
  bios_floppy_trace_emit (bios_hi (regs->bx));
  bios_floppy_trace_emit (bios_lo (regs->bx));
  if (status == FLOPPY_ST_OK)
    {
      bios_floppy_trace_emit (bios_abs_read8 (regs->es, regs->bx));
      bios_floppy_trace_emit (bios_abs_read8 (regs->es, (u16) (regs->bx + 1U)));
    }
  else
    {
      bios_floppy_trace_emit (0x00);
      bios_floppy_trace_emit (0x00);
    }
}

static void
bios_floppy_trace_boot_jump (u8 drive)
{
  bios_floppy_trace_emit ('J');
  bios_floppy_trace_emit (drive);
  bios_floppy_trace_emit (bios_abs_read8 (0x0000, 0x7C00));
  bios_floppy_trace_emit (bios_abs_read8 (0x0000, 0x7C01));
  bios_floppy_trace_emit (bios_abs_read8 (0x0000, 0x7C02));
  bios_floppy_trace_emit (bios_abs_read8 (0x0000, 0x7C03));
}
#else
#define bios_floppy_trace_read_begin(regs) ((void) 0)
#define bios_floppy_trace_read_done(regs, status, count) ((void) 0)
#define bios_floppy_trace_boot_jump(drive) ((void) 0)
#endif

static u8 bios_floppy_configured_type (u8 drive);
static int bios_floppy_geometry (u8 drive, bios_floppy_drive_geometry_t *geom);
static const u8 *bios_floppy_parameter_table_for_drive (u8 drive);
static u16 bios_floppy_last_track_cx (u8 drive);

static u8
bios_floppy_configured_type (u8 drive)
{
  switch (drive)
    {
    case 0:
      return BIOS_CFG_FLOPPY_TYPE_A;

    case 1:
      return BIOS_CFG_FLOPPY_TYPE_B;

    default:
      return BIOS_FLOPPY_TYPE_NONE;
    }
}

static int
bios_floppy_geometry (u8 drive, bios_floppy_drive_geometry_t *geom)
{
  u8 type;

  type = bios_floppy_configured_type (drive);
  switch (type)
    {
    case BIOS_FLOPPY_TYPE_360K_525DD:
      geom->type = type;
      geom->tracks = 40;
      geom->heads = 2;
      geom->sectors = 9;
      geom->data_rate = 0x02;
      geom->parameter_table = bios_diskette_parameter_table;
      return 1;

    case BIOS_FLOPPY_TYPE_720K_35DD:
      geom->type = type;
      geom->tracks = 80;
      geom->heads = 2;
      geom->sectors = 9;
      geom->data_rate = 0x02;
      geom->parameter_table = bios_diskette_parameter_table;
      return 1;

    default:
      return 0;
    }
}

static const u8 *
bios_floppy_parameter_table_for_drive (u8 drive)
{
  return bios_diskette_parameter_table;
}

u8
bios_floppy_drive_type (u8 drive)
{
  bios_floppy_drive_geometry_t geom;

  if (!bios_floppy_geometry (drive, &geom))
    return BIOS_FLOPPY_TYPE_NONE;
  return geom.type;
}

u16
bios_floppy_drive_capacity_kb (u8 drive)
{
  bios_floppy_drive_geometry_t geom;
  u32 capacity_bytes;

  if (!bios_floppy_geometry (drive, &geom))
    return 0;

  capacity_bytes =
    (u32) geom.tracks * geom.heads * geom.sectors * BIOS_CFG_FLOPPY_SECTOR_SIZE;
  return (u16) (capacity_bytes / 1024UL);
}

static u16
bios_floppy_last_track_cx (u8 drive)
{
  bios_floppy_drive_geometry_t geom;
  u16 last_track;

  if (!bios_floppy_geometry (drive, &geom))
    last_track = 39;
  else
    last_track = (u16) (geom.tracks - 1U);

  return (u16) ((last_track & 0x00FFU) << 8)
    | (u16) ((((last_track >> 2) & 0x00C0U)) | 0x01U);
}

static void
bios_boot_setup_regs (bios_regs_t *regs, u16 ax, u16 bx, u16 cx, u16 dx)
{
  regs->ax = ax;
  regs->bx = bx;
  regs->cx = cx;
  regs->dx = dx;
  regs->si = 0x0000;
  regs->di = 0x0000;
  regs->bp = 0x0000;
  regs->ds = 0x0000;
  regs->es = 0x0000;
  regs->flags = 0x0000;
}

static int
bios_floppy_ega_boot_patch_needed (void)
{
  bios_far_vector_t int1f;
  bios_far_vector_t int43;

  int1f = bios_ivt_read_vector (0x1F);
  if (int1f.seg == 0xC000 && int1f.off != 0x0000)
    return 1;

  /*
   * The stock PC1640 CGA path keeps INT 43h at C000:2600, while the EGA PEGA
   * ROM publishes its 8x14 font at C000:3160.  Use that live ROM-owned layout
   * as a fallback discriminator so the floppy boot-sector DPT handoff matches
   * the original ROS even when INT 1Fh is still clear at INT 19h time.
   */
  int43 = bios_ivt_read_vector (0x43);
  return int43.seg == 0xC000 && int43.off >= 0x3000;
}

static void
bios_floppy_publish_bootsector_dpt (u8 drive)
{
  const u8 *table;
  u8 i;

  if (!bios_floppy_ega_boot_patch_needed ())
    return;

  table = bios_floppy_parameter_table_for_drive (drive);
  for (i = 0; i != 11; ++i)
    {
      u16 off;

      off = (u16) (0x7C2B + i);
      /*
       * Match the DOS 3.30 floppy boot-sector merge at 0000:7C40: keep the
       * BPB/overlay bytes that are already nonzero in the boot sector and
       * fill only the zero slots from INT 1Eh's source DPT.
       */
      if (bios_abs_read8 (0x0000, off) == 0x00)
        bios_abs_write8 (0x0000, off, table[i]);
    }

  bios_abs_write16 (0x0000, (u16) 0x1E * 4U, 0x7C2B);
  bios_abs_write16 (0x0000, (u16) (0x1E * 4U + 2U), 0x0000);
}

static void
bios_floppy_prepare_zero_es (void)
{
  /*
   * The boot INT 13h trampoline preserves the caller's ES, and the inlined
   * EGA boot-sector DPT publish path uses ES-relative IVT accesses.  Refresh
   * ES to the IVT segment so the helper seeds 0000:0078 as intended.
   */
  asm volatile ("xor %%ax, %%ax\n\t"
                "mov %%ax, %%es"
                :
                :
                : "ax", "memory");
}

static u16
bios_fixed_disk_cylinder_count (u16 cx)
{
  u16 max_cylinder;

  max_cylinder = (u16) (((cx >> 8) & 0x00FFU) | ((cx & 0x00C0U) << 2));
  return (u16) (max_cylinder + 1U);
}

static u8
bios_fixed_disk_sector_count (u16 cx)
{
  return (u8) (cx & 0x003FU);
}

static int
bios_fixed_disk_query_parameters (u8 drive, bios_regs_t *regs)
{
  bios_boot_setup_regs (regs, 0x0000, 0x0000, 0x0000, drive);
  bios_boot_int13_call (regs);

  bios_boot_setup_regs (regs, 0x0800, 0x0000, 0x0000, drive);
  bios_boot_int13_call (regs);

  if ((regs->flags & BIOS_FLAG_CF) != 0
      || bios_fixed_disk_sector_count (regs->cx) == 0
      || bios_hi (regs->dx) == 0xFF)
    return 0;

  return 1;
}

static void
bios_fixed_disk_write_compat_dpt (u16 dpt_off, const bios_regs_t *regs)
{
  u16 cylinders;
  u8 heads;
  u8 sectors;
  u8 control;
  u8 i;

  cylinders = bios_fixed_disk_cylinder_count (regs->cx);
  heads = (u8) (bios_hi (regs->dx) + 1U);
  sectors = bios_fixed_disk_sector_count (regs->cx);
  control = 0x02;
  if (heads > 8U)
    control |= 0x08;

  for (i = 0; i != BIOS_FIXED_DISK_DPT_SIZE; ++i)
    bios_abs_write8 (0x0000, (u16) (dpt_off + i), 0x00);

  bios_abs_write16 (0x0000, dpt_off, cylinders);
  bios_abs_write8 (0x0000, (u16) (dpt_off + 2U), heads);
  bios_abs_write8 (0x0000, (u16) (dpt_off + 8U), control);
  bios_abs_write8 (0x0000, (u16) (dpt_off + 14U), sectors);
}

static void
bios_fixed_disk_publish_compat_vector (u8 intno, u8 drive, u16 dpt_off)
{
  bios_far_vector_t vector;
  bios_regs_t regs;
  u8 drive_count;

  vector = bios_ivt_read_vector (intno);
  if (vector.off != 0x0000 || vector.seg != 0x0000)
    return;

  if (!bios_fixed_disk_query_parameters (drive, &regs))
    return;

  bios_fixed_disk_write_compat_dpt (dpt_off, &regs);
  vector.off = dpt_off;
  vector.seg = 0x0000;
  bios_ivt_write_vector (intno, vector);

  drive_count = bios_lo (regs.dx);
  if (drive_count > bios_bda_read8 (BDA_HARD_DISK_COUNT))
    bios_bda_write8 (BDA_HARD_DISK_COUNT, drive_count);
}

void
bios_fixed_disk_publish_compat_tables (void)
{
  bios_fixed_disk_publish_compat_vector (0x41, 0x80, BIOS_FIXED_DISK_DPT0_OFF);
  bios_fixed_disk_publish_compat_vector (0x46, 0x81, BIOS_FIXED_DISK_DPT1_OFF);
}

static int
bios_boot_sector_ready (void)
{
  return bios_abs_read16 (0x0000, 0x7DFE) == 0xAA55;
}

static int
bios_fixed_disk_present (void)
{
  return bios_bda_read8 (BDA_HARD_DISK_COUNT) != 0
    || bios_abs_read32 (0x0000, (u16) 0x41 * 4U) != 0
    || bios_abs_read32 (0x0000, (u16) 0x46 * 4U) != 0;
}

static void
bios_floppy_store_result_bytes (const u8 *result, u8 count)
{
  u8 i;

  for (i = 0; i != 7; ++i)
    bios_bda_write8 ((u16) (BDA_FDC_RESULT_BASE + i),
		     i < count ? result[i] : 0x00);
}

static void
bios_floppy_complete (bios_regs_t __far *regs, u8 status, u8 count)
{
  const u8 *table;

  table = bios_diskette_parameter_table;
  bios_bda_write8 (BDA_FLOPPY_STATUS, status);
  bios_bda_write8 (BDA_FLOPPY_MOTOR_TIMEOUT, table[2]);
  bios_set_hi (&regs->ax, status);
  bios_set_lo (&regs->ax, count);
  if (status == FLOPPY_ST_OK)
    {
      /*
       * The PC1640 EGA DOS boot path expects INT 1Eh to point at the merged
       * boot-sector DPT in 0000:7C2B once a valid sector is resident there.
       * Our floppy services do not consume INT 1Eh internally, so refreshing
       * that DOS-visible view on successful floppy calls is safe and keeps the
       * handoff aligned with the original ROS.
       */
      if (bios_lo (regs->dx) == 0x00
          && bios_abs_read16 (0x0000, 0x7DFE) == 0xAA55)
        bios_floppy_publish_bootsector_dpt (0);
      bios_clear_cf (regs);
    }
  else
    {
      bios_set_cf (regs);
      bios_serial_debug_puts ("INT13 status ");
      bios_serial_debug_put_hex8 (status);
      bios_serial_debug_puts ("\n");
    }
}

static void
bios_floppy_set_current_cylinder (u8 drive, u8 cylinder)
{
  bios_work_write8 (drive == 0 ? WK_FDC_CYLINDER_0 : WK_FDC_CYLINDER_1,
		    cylinder);
}

static u8
bios_floppy_current_cylinder (u8 drive)
{
  return bios_work_read8 (drive == 0 ? WK_FDC_CYLINDER_0 : WK_FDC_CYLINDER_1);
}

static void
bios_floppy_reset_irq (void)
{
  bios_work_write8 (WK_FDC_IRQ_PENDING, 0x00);
}

static int
bios_floppy_wait_irq (u16 attempts)
{
  u16 flags;
  u16 spins;

  flags = bios_hw_irq_save_disable ();
  bios_hw_enable_interrupts ();
  while (attempts-- != 0)
    {
      /*
       * The original 1640DD INT 13h path waits on the IRQ6 completion flag
       * for substantially longer than the short bring-up loop we used during
       * earlier emulator debugging. Sector reads need enough time for motor
       * spin/rotational latency, so keep the wait IRQ-driven and lengthen the
       * inner window to a stock-like scale.
       */
      for (spins = 0; spins != 0x1000; ++spins)
	{
	  if (bios_work_read8 (WK_FDC_IRQ_PENDING) != 0)
	    {
	      bios_floppy_reset_irq ();
	      bios_hw_irq_restore (flags);
	      return 1;
	    }

	  bios_hw_pause ();
	}
    }

  bios_hw_irq_restore (flags);
  bios_serial_debug_puts ("FDC IRQ timeout msr=");
  bios_serial_debug_put_hex8 (bios_hw_in8 (PORT_FDC_MSR));
  bios_serial_debug_puts ("\n");
  return 0;
}

static int
bios_floppy_output_byte (u8 value)
{
  u16 attempts;
  u8 status;

  for (attempts = 0; attempts != 0x4000; ++attempts)
    {
      status = (u8) (bios_hw_in8_p (PORT_FDC_MSR)
		     & (FDC_STATUS_READY | FDC_STATUS_DIR));
      if (status == FDC_STATUS_READY)
	{
	  bios_hw_out8 (value, PORT_FDC_DATA);
	  return 1;
	}
    }

  return 0;
}

static int
bios_floppy_collect_result (u8 *result, u8 *count)
{
  u16 attempts;
  u8 status;

  *count = 0;
  for (attempts = 0; attempts != 0x4000; ++attempts)
    {
      status = (u8) (bios_hw_in8_p (PORT_FDC_MSR)
		     & (FDC_STATUS_BUSY | FDC_STATUS_READY | FDC_STATUS_DIR));
      if (status == FDC_STATUS_READY)
	{
	  bios_floppy_store_result_bytes (result, *count);
	  return 1;
	}

      if (status ==
	  (u8) (FDC_STATUS_BUSY | FDC_STATUS_READY | FDC_STATUS_DIR))
	{
	  if (*count >= 7)
	    return 0;

	  result[*count] = bios_hw_in8_p (PORT_FDC_DATA);
	  (*count)++;
	  attempts = 0;
	}
    }

  bios_floppy_store_result_bytes (result, *count);
  return 0;
}

static int
bios_floppy_sense_interrupt (u8 *st0, u8 *pcn)
{
  u8 result[7];
  u8 count;

  if (!bios_floppy_output_byte (FDC_CMD_SENSE_INTERRUPT))
    return 0;
  if (!bios_floppy_collect_result (result, &count) || count != 2)
    return 0;

  *st0 = result[0];
  *pcn = result[1];
  return 1;
}

static void
bios_floppy_wait_motor_start (const u8 *table)
{
  u16 wait_ticks;

  wait_ticks = (u16) (((u16) table[10] * 9U + 3U) / 4U);
  if (wait_ticks == 0)
    wait_ticks = 1;

  bios_wait_timer_ticks (wait_ticks);
}

static void
bios_floppy_select_drive (u8 drive, const u8 *table)
{
  u8 motor_mask;
  u8 motor_state;
  int motor_was_off;

  motor_mask = (u8) (1U << drive);
  motor_state = (u8) (bios_bda_read8 (BDA_FLOPPY_MOTOR) & 0x0F);
  motor_was_off = (motor_state & motor_mask) == 0;
  motor_state = (u8) (motor_state | motor_mask);

  /*
   * Reload the BIOS motor timeout whenever a command sequence selects a
   * drive. Otherwise IRQ0 can age the counter to zero and drop the DOR
   * during an active seek/read, leaving INT 13h stuck waiting for IRQ6.
   */
  bios_bda_write8 (BDA_FLOPPY_MOTOR_TIMEOUT, table[2]);
  bios_bda_write8 (BDA_FLOPPY_MOTOR, motor_state);
  bios_io_write (PORT_FDC_DOR, (u8) (0x0C | drive | (u8) (motor_state << 4)));
  if (motor_was_off)
    bios_floppy_wait_motor_start (table);
}

static int
bios_floppy_program_dma (const bios_regs_t __far *regs, u8 sectors,
			 u8 dma_mode)
{
  u32 addr;
  u16 count;
  u16 flags;

  addr = ((u32) regs->es << 4) + regs->bx;
  count = (u16) sectors *BIOS_CFG_FLOPPY_SECTOR_SIZE;

  flags = bios_hw_irq_save_disable ();
  bios_hw_out8 ((u8) (DMA_CH2 | 0x04), PORT_DMA1_MASK);
  bios_hw_out8 (0x00, PORT_DMA1_CLEAR_FF);
  bios_hw_out8 ((u8) (DMA_CH2 | dma_mode), PORT_DMA1_MODE);
  bios_hw_out8 ((u8) (addr & 0xFF), PORT_DMA_CH2_ADDR);
  bios_hw_out8 ((u8) ((addr >> 8) & 0xFF), PORT_DMA_CH2_ADDR);
  bios_hw_out8 ((u8) ((addr >> 16) & 0xFF), PORT_DMA_PAGE_CH2);
  count--;
  bios_hw_out8 ((u8) (count & 0xFF), PORT_DMA_CH2_COUNT);
  bios_hw_out8 ((u8) ((count >> 8) & 0xFF), PORT_DMA_CH2_COUNT);
  bios_hw_out8 (DMA_CH2, PORT_DMA1_MASK);
  bios_hw_irq_restore (flags);
  return 1;
}

static int
bios_floppy_issue_specify (const u8 *table)
{
  return bios_floppy_output_byte (FDC_CMD_SPECIFY)
    && bios_floppy_output_byte (table[0])
    && bios_floppy_output_byte (table[1]);
}

static int
bios_floppy_reset_controller (void)
{
  const u8 *table;
  u8 st0;
  u8 pcn;
  u8 i;
  u16 delay;

  table = bios_diskette_parameter_table;
  bios_serial_debug_puts ("FDC reset begin\n");
  bios_floppy_reset_irq ();
  bios_bda_write8 (BDA_FLOPPY_RECAL, 0x00);
  bios_bda_write8 (BDA_FLOPPY_MOTOR, 0x00);
  bios_bda_write8 (BDA_FLOPPY_STATUS, FLOPPY_ST_OK);
  bios_bda_write8 (BDA_FLOPPY_MOTOR_TIMEOUT, table[2]);
  bios_floppy_set_current_cylinder (0, 0xFF);
  bios_floppy_set_current_cylinder (1, 0xFF);

  bios_io_write (PORT_FDC_DOR, 0x08);
  for (delay = 0; delay != 0x001E; ++delay)
    bios_hw_pause ();
  bios_io_write (PORT_FDC_DOR, 0x0C);

  if (!bios_floppy_wait_irq (256))
    {
      bios_serial_debug_puts ("FDC reset no irq\n");
      return 0;
    }

  for (i = 0; i != 4; ++i)
    {
      if (!bios_floppy_sense_interrupt (&st0, &pcn))
	break;
    }

  if (!bios_floppy_issue_specify (table))
    {
      bios_serial_debug_puts ("FDC specify failed\n");
      return 0;
    }

  bios_serial_debug_puts ("FDC reset ok\n");
  return 1;
}

static int
bios_floppy_recalibrate (u8 drive, const u8 *table)
{
  u8 st0;
  u8 pcn;

  bios_serial_debug_puts ("FDC recal ");
  bios_serial_debug_put_hex8 (drive);
  bios_serial_debug_puts ("\n");
  bios_floppy_select_drive (drive, table);
  bios_floppy_reset_irq ();

  if (!bios_floppy_output_byte (FDC_CMD_RECALIBRATE)
      || !bios_floppy_output_byte (drive))
    return 0;

  if (!bios_floppy_wait_irq (256))
    {
      bios_serial_debug_puts ("FDC recal timeout\n");
      return 0;
    }
  if (!bios_floppy_sense_interrupt (&st0, &pcn))
    return 0;
  if ((st0 & FDC_ST0_INTERRUPT_MASK) != 0x00 || pcn != 0x00)
    return 0;

  bios_floppy_set_current_cylinder (drive, 0x00);
  bios_bda_write8 (BDA_FLOPPY_RECAL, 0x00);
  return 1;
}

static int
bios_floppy_seek (u8 drive, u8 head, u8 cylinder, const u8 *table)
{
  u8 st0;
  u8 pcn;

  if (bios_floppy_current_cylinder (drive) == cylinder)
    return 1;

  bios_floppy_select_drive (drive, table);
  bios_floppy_reset_irq ();

  bios_serial_debug_puts ("FDC seek ");
  bios_serial_debug_put_hex8 (drive);
  bios_serial_debug_putc (':');
  bios_serial_debug_put_hex8 (cylinder);
  bios_serial_debug_puts ("\n");

  if (!bios_floppy_output_byte (FDC_CMD_SEEK)
      || !bios_floppy_output_byte ((u8) ((head << 2) | drive))
      || !bios_floppy_output_byte (cylinder))
    return 0;

  if (!bios_floppy_wait_irq (256))
    {
      bios_serial_debug_puts ("FDC seek timeout\n");
      return 0;
    }
  if (!bios_floppy_sense_interrupt (&st0, &pcn))
    return 0;
  if ((st0 & 0xF8) != 0x20 || pcn != cylinder)
    return 0;

  bios_floppy_set_current_cylinder (drive, cylinder);
  return 1;
}

static u8
bios_floppy_status_from_result (const u8 *result)
{
  u8 st0;
  u8 st1;
  u8 st2;

  st0 = result[0];
  st1 = result[1];
  st2 = result[2];

  if ((st0 & FDC_ST0_INTERRUPT_MASK) == 0x00
      && (st1 & (FDC_ST1_MISSING_ADDRESS_MARK | FDC_ST1_NO_DATA
		 | FDC_ST1_OVERRUN | FDC_ST1_CRC | FDC_ST1_WRITE_PROTECT))
      == 0
      && (st2 & (FDC_ST2_MISSING_ADDRESS_MARK | FDC_ST2_WRONG_CYLINDER
		 | FDC_ST2_BAD_CYLINDER | FDC_ST2_CRC)) == 0)
    return FLOPPY_ST_OK;

  if ((st1 & FDC_ST1_WRITE_PROTECT) != 0)
    return FLOPPY_ST_WRITE_PROTECT;
  if ((st1 & FDC_ST1_OVERRUN) != 0)
    return FLOPPY_ST_DMA_OVERRUN;
  if ((st1 & (FDC_ST1_MISSING_ADDRESS_MARK | FDC_ST1_NO_DATA)) != 0
      || (st2 & FDC_ST2_MISSING_ADDRESS_MARK) != 0)
    return FLOPPY_ST_SECTOR_NOT_FOUND;
  if ((st1 & FDC_ST1_CRC) != 0 || (st2 & FDC_ST2_CRC) != 0)
    return FLOPPY_ST_BAD_CRC;
  if ((st2 & (FDC_ST2_WRONG_CYLINDER | FDC_ST2_BAD_CYLINDER)) != 0
      || (st0 & FDC_ST0_EQUIPMENT_CHECK) != 0)
    return FLOPPY_ST_SEEK_FAILED;

  return FLOPPY_ST_CONTROLLER;
}

static int
bios_floppy_drive_valid (u8 drive)
{
  bios_floppy_drive_geometry_t geom;

  return bios_floppy_geometry (drive, &geom);
}

static u16
bios_floppy_cylinder (const bios_regs_t __far *regs)
{
  return (u16) (bios_hi (regs->cx) | ((bios_lo (regs->cx) & 0xC0) << 2));
}

static u8
bios_floppy_sector (const bios_regs_t __far *regs)
{
  return (u8) (bios_lo (regs->cx) & 0x3F);
}

static int
bios_floppy_dma_boundary_crossed (const bios_regs_t __far *regs, u8 sectors)
{
  u32 dma_addr;
  u16 dma_offset;
  u16 byte_count;

  dma_addr = ((u32) regs->es << 4) + regs->bx;
  dma_offset = (u16) dma_addr;
  byte_count = (u16) sectors *BIOS_CFG_FLOPPY_SECTOR_SIZE;
  return (u16) (dma_offset + byte_count - 1U) < dma_offset;
}

static int
bios_floppy_validate_transfer (const bios_regs_t __far *regs, u8 *status,
				       int require_dma,
				       bios_floppy_drive_geometry_t *geom)
{
  u8 count;
  u8 drive;
  u8 head;
  u8 sector;
  u16 cylinder;

  count = bios_lo (regs->ax);
  drive = bios_lo (regs->dx);
  head = bios_hi (regs->dx);
  sector = bios_floppy_sector (regs);
  cylinder = bios_floppy_cylinder (regs);

  if (!bios_floppy_geometry (drive, geom))
    {
      *status = FLOPPY_ST_BAD_COMMAND;
      return 0;
    }

  if (count == 0)
    {
      *status = FLOPPY_ST_BAD_COMMAND;
      return 0;
    }

  if (head >= geom->heads
      || cylinder >= geom->tracks
      || sector == 0
      || sector > geom->sectors
      || (u16) sector + count - 1 > geom->sectors)
    {
      *status = FLOPPY_ST_SECTOR_NOT_FOUND;
      return 0;
    }

  if (require_dma && bios_floppy_dma_boundary_crossed (regs, count))
    {
      *status = FLOPPY_ST_DMA_BOUNDARY;
      return 0;
    }

  *status = FLOPPY_ST_OK;
  return 1;
}

static void
bios_floppy_get_parameters (bios_regs_t __far *regs)
{
  bios_floppy_drive_geometry_t geom;
  u16 max_cylinder;
  u8 drive;
  u8 max_sector;
  u8 max_head;

  drive = bios_lo (regs->dx);
  if (!bios_floppy_geometry (drive, &geom))
    {
      bios_floppy_complete (regs, FLOPPY_ST_BAD_COMMAND, 0);
      return;
    }

  max_cylinder = (u16) (geom.tracks - 1);
  max_sector = geom.sectors;
  max_head = (u8) (geom.heads - 1);

  regs->bx = geom.type;
  regs->cx = (u16) ((max_cylinder & 0x00FF) << 8)
    | (u16) (((max_cylinder >> 2) & 0xC0) | max_sector);
  regs->dx = (u16) max_head << 8 | BIOS_CFG_FLOPPY_DRIVES;

  /*
   * Return the diskette parameter table pointer in ES:DI. MS-DOS 3.30
   * reads the table through this pointer after AH=08h to determine
   * sector size, gap length, and other geometry details.
   */
  if (drive == 0x00 && bios_floppy_ega_boot_patch_needed ())
    {
      regs->di = 0x7C2B;
      regs->es = 0x0000;
    }
  else
    {
      regs->di = BIOS_FP_OFF ((void __far *) geom.parameter_table);
      regs->es = BIOS_ROM_SEGMENT;
    }

  bios_floppy_complete (regs, FLOPPY_ST_OK, 0);
}

static void
bios_floppy_transfer (bios_regs_t __far *regs, u8 dma_mode, u8 fdc_command)
{
  bios_floppy_drive_geometry_t geom;
  u8 count;
  u8 drive;
  u8 head;
  u8 sector;
  u8 result[7];
  u8 result_count;
  u8 status;
  u16 cylinder;

  if (!bios_floppy_validate_transfer (regs, &status, 1, &geom))
    {
      bios_floppy_complete (regs, status, 0);
      return;
    }

  count = bios_lo (regs->ax);
  drive = bios_lo (regs->dx);
  head = bios_hi (regs->dx);
  sector = bios_floppy_sector (regs);
  cylinder = bios_floppy_cylinder (regs);

  bios_floppy_select_drive (drive, geom.parameter_table);
  bios_io_write (PORT_FDC_CCR, geom.data_rate);

  if (!bios_floppy_issue_specify (geom.parameter_table))
    {
      bios_floppy_complete (regs, FLOPPY_ST_TIMEOUT, 0);
      return;
    }

  if (bios_floppy_current_cylinder (drive) == 0xFF
      && !bios_floppy_recalibrate (drive, geom.parameter_table))
    {
      bios_floppy_complete (regs, FLOPPY_ST_RESET_FAILED, 0);
      return;
    }

  if (!bios_floppy_seek (drive, head, (u8) cylinder, geom.parameter_table))
    {
      bios_floppy_set_current_cylinder (drive, 0xFF);
      if (!bios_floppy_recalibrate (drive, geom.parameter_table)
		  || !bios_floppy_seek (drive, head, (u8) cylinder,
					geom.parameter_table))
		{
		  bios_floppy_complete (regs, FLOPPY_ST_SEEK_FAILED, 0);
		  return;
	}
    }

  bios_floppy_program_dma (regs, count, dma_mode);
  bios_floppy_reset_irq ();

  bios_serial_debug_puts (fdc_command == FDC_CMD_WRITE_DATA ? "FDC write c="
			  : "FDC read c=");
  bios_serial_debug_put_hex8 ((u8) cylinder);
  bios_serial_debug_puts (" h=");
  bios_serial_debug_put_hex8 (head);
  bios_serial_debug_puts (" s=");
  bios_serial_debug_put_hex8 (sector);
  bios_serial_debug_puts ("\n");
  if (fdc_command == FDC_CMD_READ_DATA)
    bios_floppy_trace_read_begin (regs);

  if (!bios_floppy_output_byte (fdc_command)
      || !bios_floppy_output_byte ((u8) ((head << 2) | drive))
      || !bios_floppy_output_byte ((u8) cylinder)
      || !bios_floppy_output_byte (head)
      || !bios_floppy_output_byte (sector)
      || !bios_floppy_output_byte (geom.parameter_table[3])
      || !bios_floppy_output_byte (geom.parameter_table[4])
      || !bios_floppy_output_byte (geom.parameter_table[5])
      || !bios_floppy_output_byte (geom.parameter_table[6]))
    {
      bios_floppy_complete (regs, FLOPPY_ST_TIMEOUT, 0);
      return;
    }

  if (!bios_floppy_wait_irq (1024))
    {
      bios_serial_debug_puts (fdc_command == FDC_CMD_WRITE_DATA
			      ? "FDC write timeout\n" : "FDC read timeout\n");
      bios_floppy_complete (regs, FLOPPY_ST_TIMEOUT, 0);
      return;
    }

  if (!bios_floppy_collect_result (result, &result_count)
      || result_count != 7)
    {
      bios_floppy_complete (regs, FLOPPY_ST_CONTROLLER, 0);
      return;
    }

  status = bios_floppy_status_from_result (result);
  if (fdc_command == FDC_CMD_READ_DATA)
    bios_floppy_trace_read_done (regs, status, status == FLOPPY_ST_OK ? count : 0);
  bios_floppy_complete (regs, status, status == FLOPPY_ST_OK ? count : 0);
}

static void
bios_floppy_read (bios_regs_t __far *regs)
{
  bios_floppy_transfer (regs, DMA_MODE_READ, FDC_CMD_READ_DATA);
}

static void
bios_floppy_write (bios_regs_t __far *regs)
{
  bios_floppy_transfer (regs, DMA_MODE_WRITE, FDC_CMD_WRITE_DATA);
}

static void
bios_floppy_verify (bios_regs_t __far *regs)
{
  bios_floppy_drive_geometry_t geom;
  u8 drive;
  u8 head;
  u8 status;
  u16 cylinder;

  if (!bios_floppy_validate_transfer (regs, &status, 0, &geom))
    {
      bios_floppy_complete (regs, status, 0);
      return;
    }

  drive = bios_lo (regs->dx);
  head = bios_hi (regs->dx);
  cylinder = bios_floppy_cylinder (regs);

  bios_floppy_select_drive (drive, geom.parameter_table);
  bios_io_write (PORT_FDC_CCR, geom.data_rate);
  if (!bios_floppy_issue_specify (geom.parameter_table))
    {
      bios_floppy_complete (regs, FLOPPY_ST_TIMEOUT, 0);
      return;
    }
  if (bios_floppy_current_cylinder (drive) == 0xFF
      && !bios_floppy_recalibrate (drive, geom.parameter_table))
    {
      bios_floppy_complete (regs, FLOPPY_ST_RESET_FAILED, 0);
      return;
    }
  if (!bios_floppy_seek (drive, head, (u8) cylinder, geom.parameter_table))
    {
      bios_floppy_complete (regs, FLOPPY_ST_SEEK_FAILED, 0);
      return;
    }

  bios_floppy_complete (regs, FLOPPY_ST_OK, bios_lo (regs->ax));
}

static void
bios_floppy_format_track (bios_regs_t __far *regs)
{
  bios_floppy_drive_geometry_t geom;
  u32 dma_addr;
  u16 dma_count;
  u16 dma_offset;
  u8 drive;
  u8 head;
  u8 result[7];
  u8 result_count;
  u8 sectors_per_track;
  u8 status;
  u16 cylinder;

  drive = bios_lo (regs->dx);
  head = bios_hi (regs->dx);
  cylinder = bios_floppy_cylinder (regs);

  if (!bios_floppy_geometry (drive, &geom))
    {
      bios_floppy_complete (regs, FLOPPY_ST_BAD_COMMAND, 0);
      return;
    }

  sectors_per_track = geom.parameter_table[4];

  if (head >= geom.heads || cylinder >= geom.tracks)
    {
      bios_floppy_complete (regs, FLOPPY_ST_SECTOR_NOT_FOUND, 0);
      return;
    }

  dma_addr = ((u32) regs->es << 4) + regs->bx;
  dma_offset = (u16) dma_addr;
  if ((u16) (dma_offset + (u16) sectors_per_track * 4U - 1U) < dma_offset)
    {
      bios_floppy_complete (regs, FLOPPY_ST_DMA_BOUNDARY, 0);
      return;
    }

  bios_floppy_select_drive (drive, geom.parameter_table);
  bios_io_write (PORT_FDC_CCR, geom.data_rate);

  if (!bios_floppy_issue_specify (geom.parameter_table))
    {
      bios_floppy_complete (regs, FLOPPY_ST_TIMEOUT, 0);
      return;
    }

  if (bios_floppy_current_cylinder (drive) == 0xFF
      && !bios_floppy_recalibrate (drive, geom.parameter_table))
    {
      bios_floppy_complete (regs, FLOPPY_ST_RESET_FAILED, 0);
      return;
    }

  if (!bios_floppy_seek (drive, head, (u8) cylinder, geom.parameter_table))
    {
      bios_floppy_set_current_cylinder (drive, 0xFF);
      if (!bios_floppy_recalibrate (drive, geom.parameter_table)
		  || !bios_floppy_seek (drive, head, (u8) cylinder,
					geom.parameter_table))
		{
		  bios_floppy_complete (regs, FLOPPY_ST_SEEK_FAILED, 0);
		  return;
	}
    }

  dma_count = (u16) sectors_per_track *4U;
  {
    u16 flags;

    flags = bios_hw_irq_save_disable ();
    bios_hw_out8 ((u8) (DMA_CH2 | 0x04), PORT_DMA1_MASK);
    bios_hw_out8 ((u8) (DMA_CH2 | 0x04), PORT_DMA1_CLEAR_FF);
    bios_hw_out8 ((u8) (dma_addr & 0xFF), PORT_DMA_CH2_ADDR);
    bios_hw_out8 ((u8) ((dma_addr >> 8) & 0xFF), PORT_DMA_CH2_ADDR);
    bios_hw_out8 ((u8) ((dma_addr >> 16) & 0xFF), PORT_DMA_PAGE_CH2);
    dma_count--;
    bios_hw_out8 ((u8) (dma_count & 0xFF), PORT_DMA_CH2_COUNT);
    bios_hw_out8 ((u8) ((dma_count >> 8) & 0xFF), PORT_DMA_CH2_COUNT);
    bios_hw_irq_restore (flags);
  }
  bios_hw_out8 ((u8) (DMA_CH2 | DMA_MODE_WRITE), PORT_DMA1_MODE);
  bios_hw_out8 (DMA_CH2, PORT_DMA1_MASK);
  bios_floppy_reset_irq ();

  bios_serial_debug_puts ("FDC format c=");
  bios_serial_debug_put_hex8 ((u8) cylinder);
  bios_serial_debug_puts (" h=");
  bios_serial_debug_put_hex8 (head);
  bios_serial_debug_puts ("\n");

  if (!bios_floppy_output_byte (FDC_CMD_FORMAT_TRACK)
      || !bios_floppy_output_byte ((u8) ((head << 2) | drive))
      || !bios_floppy_output_byte (geom.parameter_table[3])
      || !bios_floppy_output_byte (sectors_per_track)
      || !bios_floppy_output_byte (geom.parameter_table[7])
      || !bios_floppy_output_byte (geom.parameter_table[8]))
    {
      bios_floppy_complete (regs, FLOPPY_ST_TIMEOUT, 0);
      return;
    }

  if (!bios_floppy_wait_irq (1024))
    {
      bios_serial_debug_puts ("FDC format timeout\n");
      bios_floppy_complete (regs, FLOPPY_ST_TIMEOUT, 0);
      return;
    }

  if (!bios_floppy_collect_result (result, &result_count)
      || result_count != 7)
    {
      bios_floppy_complete (regs, FLOPPY_ST_CONTROLLER, 0);
      return;
    }

  status = bios_floppy_status_from_result (result);
  bios_floppy_complete (regs, status, 0);
}

void
bios_floppy_init (void)
{
  if (!BIOS_CFG_HAS_FLOPPY_CONTROLLER)
    {
      bios_bda_write8 (BDA_FLOPPY_STATUS, FLOPPY_ST_TIMEOUT);
      return;
    }

  if (!bios_floppy_reset_controller ())
    bios_bda_write8 (BDA_FLOPPY_STATUS, FLOPPY_ST_RESET_FAILED);
}

int
bios_floppy_post_test (void)
{
  bios_floppy_drive_geometry_t geom;
  u8 drive;

  if (!BIOS_CFG_HAS_FLOPPY_CONTROLLER)
    return 1;

  if (!bios_floppy_reset_controller ())
    return 0;

  for (drive = 0; drive != BIOS_CFG_FLOPPY_DRIVES; ++drive)
    {
      if (!bios_floppy_geometry (drive, &geom))
	return 0;
      if (!bios_floppy_recalibrate (drive, geom.parameter_table))
	return 0;
      if (!bios_floppy_seek (drive, 0, 10, geom.parameter_table))
	return 0;
    }

  return 1;
}

void
bios_floppy_irq6 (void)
{
  bios_work_write8 (WK_FDC_IRQ_PENDING, 0x80);
  bios_bda_write8 (BDA_FLOPPY_STATUS, FLOPPY_ST_OK);
  bios_serial_debug_puts ("IRQ6\n");
  bios_pic_ack_irq (6);
}

void
bios_service_int13 (bios_regs_t __far *regs)
{
  u8 status;

  if (bios_lo (regs->dx) >= 0x80)
    {
      bios_floppy_complete (regs, FLOPPY_ST_BAD_COMMAND, 0);
      return;
    }

  if (!BIOS_CFG_HAS_FLOPPY_CONTROLLER)
    {
      bios_floppy_complete (regs, FLOPPY_ST_TIMEOUT, 0);
      return;
    }

  switch (bios_hi (regs->ax))
    {
    case 0x00:
      if (bios_floppy_reset_controller ())
	bios_floppy_complete (regs, FLOPPY_ST_OK, 0);
      else
	bios_floppy_complete (regs, FLOPPY_ST_RESET_FAILED, 0);
      break;

    case 0x01:
      bios_set_hi (&regs->ax, bios_bda_read8 (BDA_FLOPPY_STATUS));
      if (bios_bda_read8 (BDA_FLOPPY_STATUS) == FLOPPY_ST_OK)
	bios_clear_cf (regs);
      else
	bios_set_cf (regs);
      break;

    case 0x02:
      bios_floppy_read (regs);
      break;

    case 0x03:
      bios_floppy_write (regs);
      break;

    case 0x04:
      bios_floppy_verify (regs);
      break;

    case 0x05:
      bios_floppy_format_track (regs);
      break;

#if BIOS_CFG_FLOPPY_ENABLE_AH08_COMPAT
    case 0x08:
      if (!bios_floppy_drive_valid (bios_lo (regs->dx)))
	{
	  bios_floppy_complete (regs, FLOPPY_ST_BAD_COMMAND, 0);
	  break;
	}

      bios_floppy_get_parameters (regs);
      break;
#endif

    default:
      status = FLOPPY_ST_BAD_COMMAND;
      bios_floppy_complete (regs, status, 0);
      break;
    }
}

void
bios_bootstrap_loader (void)
{
  bios_regs_t regs;
  u8 attempt;
  u16 last_track_cx;

  bios_serial_debug_puts ("INT19 start\n");
  BIOS_INSTALL_DATA_VECTOR (0x1E, bios_diskette_parameter_table);
  last_track_cx = bios_floppy_last_track_cx (0);

  for (attempt = 0; attempt != 10; ++attempt)
    {
      bios_serial_debug_puts ("INT19 try ");
      bios_serial_debug_put_hex8 (attempt);
      bios_serial_debug_puts ("\n");

      bios_boot_setup_regs (&regs, 0x0000, 0x0000, 0x0000, 0x0000);
      bios_boot_int13_call (&regs);

      bios_boot_setup_regs (&regs, 0x0201, 0x7C00, 0x0001, 0x0000);
      bios_boot_int13_call (&regs);
      if ((regs.flags & BIOS_FLAG_CF) == 0 && bios_boot_sector_ready ())
	{
	  bios_floppy_prepare_zero_es ();
	  bios_floppy_publish_bootsector_dpt (0);
	  bios_serial_debug_puts ("INT19 boot sector ok\n");
	  bios_floppy_trace_boot_jump (0);
	  bios_keyboard_clear_buffer ();
	  bios_hw_boot_sector (0);
	}

      if ((bios_hi (regs.ax) & 0x80) != 0)
	break;

      if ((attempt & 0x01) != 0)
	{
	  bios_boot_setup_regs (&regs, 0x0401, 0x0000, last_track_cx, 0x0000);
	  bios_boot_int13_call (&regs);
	}
    }

  if (BIOS_CFG_HD_BOOT_ENABLED && bios_fixed_disk_present ())
    {
      for (attempt = 0; attempt != 2; ++attempt)
	{
	  bios_serial_debug_puts ("INT19 try C:");
	  bios_serial_debug_put_hex8 (attempt);
	  bios_serial_debug_puts ("\n");

	  bios_boot_setup_regs (&regs, 0x0000, 0x0000, 0x0000, 0x0080);
	  bios_boot_int13_call (&regs);

	  bios_boot_setup_regs (&regs, 0x0201, 0x7C00, 0x0001, 0x0080);
	  bios_boot_int13_call (&regs);
	  if ((regs.flags & BIOS_FLAG_CF) == 0 && bios_boot_sector_ready ())
	    {
	      bios_fixed_disk_publish_compat_tables ();
	      bios_serial_debug_puts ("INT19 C boot sector ok\n");
	      bios_floppy_trace_boot_jump (0x80);
	      bios_keyboard_clear_buffer ();
	      bios_hw_boot_sector (0x80);
	    }

	  if ((regs.flags & BIOS_FLAG_CF) == 0)
	    break;
	}
    }



  bios_serial_debug_puts ("INT19 failed\n");

  /* No bootable media found — halt the system. */
  for (;;)
    bios_hw_halt ();
}
