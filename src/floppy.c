#include "bios.h"

/*
 * Original INT 1Eh diskette parameter table bytes from ROM address 0xFEFC7.
 */
const u8 bios_diskette_parameter_table[11] = {
  0xDF, 0x02, 0x64, 0x02, 0x09, 0x2A, 0xFF, 0x50, 0xF6, 0x0F, 0x04
};

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
  bios_bda_write8 (BDA_FLOPPY_STATUS, status);
  bios_bda_write8 (BDA_FLOPPY_MOTOR_TIMEOUT, bios_diskette_parameter_table[2]);
  bios_set_hi (&regs->ax, status);
  bios_set_lo (&regs->ax, count);
  if (status == FLOPPY_ST_OK)
    bios_clear_cf (regs);
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
  bios_work_write8 (drive == 0 ? WK_FDC_CYLINDER_0 : WK_FDC_CYLINDER_1, cylinder);
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
  u16 spins;
  u8 status;

  while (attempts-- != 0)
    {
      for (spins = 0; spins != 0x0400; ++spins)
        {
          if (bios_work_read8 (WK_FDC_IRQ_PENDING) != 0)
            {
              bios_floppy_reset_irq ();
              return 1;
            }

          status = (u8) (bios_hw_in8_p (PORT_FDC_MSR)
                         & (FDC_STATUS_BUSY | FDC_STATUS_READY | FDC_STATUS_DIR));
          if (status == FDC_STATUS_READY
              || status == (u8) (FDC_STATUS_BUSY | FDC_STATUS_READY
                                 | FDC_STATUS_DIR))
            return 1;

          bios_hw_pause ();
        }
	    }

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

      if (status == (u8) (FDC_STATUS_BUSY | FDC_STATUS_READY | FDC_STATUS_DIR))
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
bios_floppy_select_drive (u8 drive)
{
  bios_bda_write8 (BDA_FLOPPY_MOTOR, (u8) (1U << drive));
  bios_io_write (PORT_FDC_DOR, (u8) (0x0C | (u8) (0x10U << drive) | drive));
}

static int
bios_floppy_program_dma (const bios_regs_t __far *regs, u8 sectors)
{
  u32 addr;
  u16 count;

  addr = ((u32) regs->es << 4) + regs->bx;
  count = (u16) sectors * BIOS_CFG_FLOPPY_SECTOR_SIZE;

  bios_hw_disable_interrupts ();
  bios_hw_out8 ((u8) (DMA_CH2 | 0x04), PORT_DMA1_MASK);
  bios_hw_out8 (0x00, PORT_DMA1_CLEAR_FF);
  bios_hw_out8 ((u8) (DMA_CH2 | DMA_MODE_READ), PORT_DMA1_MODE);
  bios_hw_out8 ((u8) (addr & 0xFF), PORT_DMA_CH2_ADDR);
  bios_hw_out8 ((u8) ((addr >> 8) & 0xFF), PORT_DMA_CH2_ADDR);
  bios_hw_out8 ((u8) ((addr >> 16) & 0xFF), PORT_DMA_PAGE_CH2);
  count--;
  bios_hw_out8 ((u8) (count & 0xFF), PORT_DMA_CH2_COUNT);
  bios_hw_out8 ((u8) ((count >> 8) & 0xFF), PORT_DMA_CH2_COUNT);
  bios_hw_out8 (DMA_CH2, PORT_DMA1_MASK);
  bios_hw_enable_interrupts ();
  return 1;
}

static int
bios_floppy_issue_specify (void)
{
  return bios_floppy_output_byte (FDC_CMD_SPECIFY)
         && bios_floppy_output_byte (bios_diskette_parameter_table[0])
         && bios_floppy_output_byte (bios_diskette_parameter_table[1]);
}

static int
bios_floppy_reset_controller (void)
{
  u8 st0;
  u8 pcn;
  u8 i;

  bios_serial_debug_puts ("FDC reset begin\n");
  bios_floppy_reset_irq ();
  bios_bda_write8 (BDA_FLOPPY_RECAL, 0x00);
  bios_bda_write8 (BDA_FLOPPY_MOTOR, 0x00);
  bios_bda_write8 (BDA_FLOPPY_STATUS, FLOPPY_ST_OK);
  bios_bda_write8 (BDA_FLOPPY_MOTOR_TIMEOUT, bios_diskette_parameter_table[2]);
  bios_floppy_set_current_cylinder (0, 0xFF);
  bios_floppy_set_current_cylinder (1, 0xFF);

  bios_io_write (PORT_FDC_DOR, 0x08);
  bios_hw_pause ();
  bios_hw_pause ();
  bios_io_write (PORT_FDC_CCR, BIOS_CFG_FLOPPY_RATE);
  bios_io_write (PORT_FDC_DOR, 0x0C);

  if (!bios_floppy_wait_irq (32))
    {
      bios_serial_debug_puts ("FDC reset no irq\n");
      return 0;
    }

  for (i = 0; i != 4; ++i)
    {
      if (!bios_floppy_sense_interrupt (&st0, &pcn))
        break;
    }

  if (!bios_floppy_issue_specify ())
    {
      bios_serial_debug_puts ("FDC specify failed\n");
      return 0;
    }

  bios_serial_debug_puts ("FDC reset ok\n");
  return 1;
}

static int
bios_floppy_recalibrate (u8 drive)
{
  u8 st0;
  u8 pcn;

  bios_serial_debug_puts ("FDC recal ");
  bios_serial_debug_put_hex8 (drive);
  bios_serial_debug_puts ("\n");
  bios_floppy_select_drive (drive);
  bios_floppy_reset_irq ();

  if (!bios_floppy_output_byte (FDC_CMD_RECALIBRATE)
      || !bios_floppy_output_byte (drive))
    return 0;

  if (!bios_floppy_wait_irq (64))
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
bios_floppy_seek (u8 drive, u8 head, u8 cylinder)
{
  u8 st0;
  u8 pcn;

  if (bios_floppy_current_cylinder (drive) == cylinder)
    return 1;

  bios_floppy_select_drive (drive);
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

  if (!bios_floppy_wait_irq (64))
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
                 | FDC_ST2_BAD_CYLINDER | FDC_ST2_CRC))
         == 0)
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
  return drive < BIOS_CFG_FLOPPY_DRIVES;
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
  u16 byte_count;

  byte_count = (u16) sectors * BIOS_CFG_FLOPPY_SECTOR_SIZE;
  return (u16) (regs->bx + byte_count) < regs->bx;
}

static int
bios_floppy_validate_transfer (const bios_regs_t __far *regs, u8 *status,
                               int require_dma)
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

  if (!bios_floppy_drive_valid (drive))
    {
      *status = FLOPPY_ST_BAD_COMMAND;
      return 0;
    }

  if (count == 0)
    {
      *status = FLOPPY_ST_BAD_COMMAND;
      return 0;
    }

  if (head >= BIOS_CFG_FLOPPY_HEADS
      || cylinder >= BIOS_CFG_FLOPPY_TRACKS
      || sector == 0
      || sector > BIOS_CFG_FLOPPY_SECTORS
      || (u16) sector + count - 1 > BIOS_CFG_FLOPPY_SECTORS)
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
  u16 max_cylinder;
  u8 max_sector;
  u8 max_head;

  max_cylinder = (u16) (BIOS_CFG_FLOPPY_TRACKS - 1);
  max_sector = BIOS_CFG_FLOPPY_SECTORS;
  max_head = (u8) (BIOS_CFG_FLOPPY_HEADS - 1);

  regs->bx = BIOS_CFG_FLOPPY_TYPE_A;
  regs->cx = (u16) ((max_cylinder & 0x00FF) << 8)
             | (u16) (((max_cylinder >> 2) & 0xC0) | max_sector);
  regs->dx = (u16) max_head << 8 | BIOS_CFG_FLOPPY_DRIVES;
  bios_floppy_complete (regs, FLOPPY_ST_OK, 0);
}

static void
bios_floppy_read (bios_regs_t __far *regs)
{
  u8 count;
  u8 drive;
  u8 head;
  u8 sector;
  u8 result[7];
  u8 result_count;
  u8 status;
  u16 cylinder;

  if (!bios_floppy_validate_transfer (regs, &status, 1))
    {
      bios_floppy_complete (regs, status, 0);
      return;
    }

  count = bios_lo (regs->ax);
  drive = bios_lo (regs->dx);
  head = bios_hi (regs->dx);
  sector = bios_floppy_sector (regs);
  cylinder = bios_floppy_cylinder (regs);

  bios_floppy_select_drive (drive);
  bios_io_write (PORT_FDC_CCR, BIOS_CFG_FLOPPY_RATE);

  if (!bios_floppy_issue_specify ())
    {
      bios_floppy_complete (regs, FLOPPY_ST_TIMEOUT, 0);
      return;
    }

  if (bios_floppy_current_cylinder (drive) == 0xFF
      && !bios_floppy_recalibrate (drive))
    {
      bios_floppy_complete (regs, FLOPPY_ST_RESET_FAILED, 0);
      return;
    }

  if (!bios_floppy_seek (drive, head, (u8) cylinder))
    {
      bios_floppy_set_current_cylinder (drive, 0xFF);
      if (!bios_floppy_recalibrate (drive)
          || !bios_floppy_seek (drive, head, (u8) cylinder))
        {
          bios_floppy_complete (regs, FLOPPY_ST_SEEK_FAILED, 0);
          return;
        }
    }

  bios_floppy_program_dma (regs, count);
  bios_floppy_reset_irq ();

  bios_serial_debug_puts ("FDC read c=");
  bios_serial_debug_put_hex8 ((u8) cylinder);
  bios_serial_debug_puts (" h=");
  bios_serial_debug_put_hex8 (head);
  bios_serial_debug_puts (" s=");
  bios_serial_debug_put_hex8 (sector);
  bios_serial_debug_puts ("\n");

  if (!bios_floppy_output_byte (FDC_CMD_READ_DATA)
      || !bios_floppy_output_byte ((u8) ((head << 2) | drive))
      || !bios_floppy_output_byte ((u8) cylinder)
      || !bios_floppy_output_byte (head)
      || !bios_floppy_output_byte (sector)
      || !bios_floppy_output_byte (bios_diskette_parameter_table[3])
      || !bios_floppy_output_byte (bios_diskette_parameter_table[4])
      || !bios_floppy_output_byte (bios_diskette_parameter_table[5])
      || !bios_floppy_output_byte (bios_diskette_parameter_table[6]))
    {
      bios_floppy_complete (regs, FLOPPY_ST_TIMEOUT, 0);
      return;
    }

  if (!bios_floppy_wait_irq (96))
    {
      bios_serial_debug_puts ("FDC read timeout\n");
      bios_floppy_complete (regs, FLOPPY_ST_TIMEOUT, 0);
      return;
    }

  if (!bios_floppy_collect_result (result, &result_count) || result_count != 7)
    {
      bios_floppy_complete (regs, FLOPPY_ST_CONTROLLER, 0);
      return;
    }

  status = bios_floppy_status_from_result (result);
  bios_floppy_complete (regs, status, status == FLOPPY_ST_OK ? count : 0);
}

static void
bios_floppy_verify (bios_regs_t __far *regs)
{
  u8 drive;
  u8 head;
  u8 status;
  u16 cylinder;

  if (!bios_floppy_validate_transfer (regs, &status, 0))
    {
      bios_floppy_complete (regs, status, 0);
      return;
    }

  drive = bios_lo (regs->dx);
  head = bios_hi (regs->dx);
  cylinder = bios_floppy_cylinder (regs);

  bios_floppy_select_drive (drive);
  bios_io_write (PORT_FDC_CCR, BIOS_CFG_FLOPPY_RATE);
  if (!bios_floppy_issue_specify ())
    {
      bios_floppy_complete (regs, FLOPPY_ST_TIMEOUT, 0);
      return;
    }
  if (bios_floppy_current_cylinder (drive) == 0xFF
      && !bios_floppy_recalibrate (drive))
    {
      bios_floppy_complete (regs, FLOPPY_ST_RESET_FAILED, 0);
      return;
    }
  if (!bios_floppy_seek (drive, head, (u8) cylinder))
    {
      bios_floppy_complete (regs, FLOPPY_ST_SEEK_FAILED, 0);
      return;
    }

  bios_floppy_complete (regs, FLOPPY_ST_OK, bios_lo (regs->ax));
}

void
bios_floppy_init (void)
{
  if (!bios_floppy_reset_controller ())
    bios_bda_write8 (BDA_FLOPPY_STATUS, FLOPPY_ST_RESET_FAILED);
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
      bios_clear_cf (regs);
      break;

    case 0x02:
      bios_floppy_read (regs);
      break;

    case 0x04:
      bios_floppy_verify (regs);
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

  bios_serial_debug_puts ("INT19 start\n");
  for (attempt = 0; attempt != 10; ++attempt)
    {
      bios_serial_debug_puts ("INT19 try ");
      bios_serial_debug_put_hex8 (attempt);
      bios_serial_debug_puts ("\n");

      regs.ax = 0x0000;
      regs.bx = 0x0000;
      regs.cx = 0x0000;
      regs.dx = 0x0000;
      regs.si = 0x0000;
      regs.di = 0x0000;
      regs.bp = 0x0000;
      regs.ds = 0x0000;
      regs.es = 0x0000;
      regs.flags = 0x0000;
      bios_service_int13 (&regs);

      regs.ax = 0x0201;
      regs.bx = 0x7C00;
      regs.cx = 0x0001;
      regs.dx = 0x0000;
      regs.si = 0x0000;
      regs.di = 0x0000;
      regs.bp = 0x0000;
      regs.ds = 0x0000;
      regs.es = 0x0000;
      regs.flags = 0x0000;
      bios_service_int13 (&regs);
      if ((regs.flags & BIOS_FLAG_CF) == 0
          && bios_abs_read16 (0x0000, 0x7DFE) == 0xAA55)
        {
          bios_serial_debug_puts ("INT19 boot sector ok\n");
          bios_hw_boot_sector (0);
        }

      if ((bios_hi (regs.ax) & FLOPPY_ST_TIMEOUT) != 0)
        break;
    }

  bios_serial_debug_puts ("INT19 failed\n");
  bios_video_puts (bios_str_en_insert_system_disk);
  bios_video_puts ("\r\n");
  bios_keyboard_wait_for_keypress ();
  bios_work_write8 (WK_BOOT_FLAGS,
                    (u8) (bios_work_read8 (WK_BOOT_FLAGS) | BOOT_FLAG_BOOT_FAILED));
}
