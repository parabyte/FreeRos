#include "bios.h"

#define BIOS_IDE_BIOS_DRIVE_BASE 0x80
#define BIOS_IDE_MAX_DRIVES 2
#define BIOS_IDE_BYTES_PER_SECTOR 512U
#define BIOS_IDE_WORDS_PER_SECTOR 256U
#define BIOS_IDE_CTRL_PORT ((u16) (BIOS_CFG_XTIDE_BASE + 0x0EU))
#define BIOS_IDE_EDD_PACKET_MIN_SIZE 0x10U
#define BIOS_IDE_EDD_PARAMS_MIN_SIZE 0x1AU
#define BIOS_IDE_EDD_PARAMS_FULL_SIZE 0x1EU
#define BIOS_IDE_EDD_DPT_SIZE 16U
#define BIOS_IDE_EDD_VERSION 0x20U
#define BIOS_IDE_EDD_INSTALL_FEATURES 0x0005U
#define BIOS_IDE_LEGACY_MAX_BLOCKS 0x80U

#define BIOS_IDE_EDD_FLAG_CHS_VALID 0x0002U
#define BIOS_IDE_EDD_FLAG_WRITE_VERIFY 0x0008U

#define BIOS_IDE_ST_INVALID_FUNCTION 0x01U
#define BIOS_IDE_ST_DRIVE_PARAMETER_FAILED 0x07U
#define BIOS_IDE_ST_INVALID_SECTOR_COUNT 0x0DU

#ifndef IDE_CMD_VERIFY_SECTORS
#define IDE_CMD_VERIFY_SECTORS 0x40U
#endif

#ifndef IDE_CMD_SEEK
#define IDE_CMD_SEEK 0x70U
#endif

#ifndef BIOS_CFG_XTIDE_IRQ
#define BIOS_CFG_XTIDE_IRQ 14U
#endif

typedef struct bios_ide_drive
{
  u8 present;
  u8 use_lba;
  u8 lba_supported;
  u8 heads;
  u8 sectors;
  u16 cylinders;
  u32 total_sectors;
  u32 chs_total_sectors;

  u16 physical_cylinders;
  u8 physical_heads;
  u8 physical_sectors;
  u8 multiple_count;
  u8 translated;
} bios_ide_drive_t;

static bios_ide_drive_t bios_ide_drives[BIOS_IDE_MAX_DRIVES];
static u8 bios_ide_bios_units[BIOS_IDE_MAX_DRIVES];
static u8 bios_ide_bios_drive_count;
static u8 bios_ide_parameter_tables[BIOS_IDE_MAX_DRIVES][16];
static u8 bios_ide_dpte_tables[BIOS_IDE_MAX_DRIVES][BIOS_IDE_EDD_DPT_SIZE];

/*
 * Scratch buffer for IDENTIFY DEVICE data.  Kept in BSS rather than on the
 * stack so the BIOS stack never needs a 512-byte hole during init.
 */
static u16 bios_ide_identify_buf[BIOS_IDE_WORDS_PER_SECTOR];

/*
 * 32-bit / 16-bit unsigned division using the 8086 DIV instruction.
 * Returns quotient (capped to 16 bits) and remainder.
 * The 8086 DIV r16 divides DX:AX by r16 and faults on overflow,
 * so we split the dividend into two 16-bit halves and perform
 * the division in two stages to avoid the overflow trap.
 */
static u16
bios_ide_div_u32_u16 (u32 dividend, u16 divisor, u16 *remainder_out)
{
  u16 hi;
  u16 lo;
  u16 q_hi;
  u16 q_lo;
  u16 rem;

  if (divisor == 0)
    {
      *remainder_out = 0;
      return 0;
    }

  hi = (u16) (dividend >> 16);
  lo = (u16) dividend;

  /* First divide: hi / divisor → q_hi remainder rem */
  asm volatile ("xor %%dx,%%dx\n\t"
                "div %3"
                : "=a" (q_hi), "=d" (rem)
                : "a" (hi), "rm" (divisor)
                : "cc");

  /* Second divide: (rem:lo) / divisor → q_lo remainder rem */
  asm volatile ("div %3"
                : "=a" (q_lo), "=d" (rem)
                : "a" (lo), "d" (rem), "rm" (divisor)
                : "cc");

  *remainder_out = rem;

  /* If q_hi != 0, the full quotient exceeds 16 bits; return 0xFFFF. */
  if (q_hi != 0)
    return 0xFFFFU;

  return q_lo;
}

static u16
bios_ide_capped_ceil_div_u32_u16 (u32 dividend, u16 divisor, u16 cap)
{
  u16 remainder;
  u16 quotient;

  if (divisor == 0)
    return 0;

  quotient = bios_ide_div_u32_u16 (dividend, divisor, &remainder);

  /* Ceiling: round up if there was a remainder. */
  if (remainder != 0 && quotient != 0xFFFFU)
    ++quotient;

  return quotient > cap ? cap : quotient;
}

static u16
bios_ide_capped_floor_div_u32_u16 (u32 dividend, u16 divisor, u16 cap)
{
  u16 remainder;
  u16 quotient;

  if (divisor == 0)
    return 0;

  quotient = bios_ide_div_u32_u16 (dividend, divisor, &remainder);
  return quotient > cap ? cap : quotient;
}

static u8
bios_ide_read_reg (u8 reg)
{
  return bios_hw_in8_p ((u16) (BIOS_CFG_XTIDE_BASE + reg));
}

static void
bios_ide_write_reg (u8 reg, u8 value)
{
  bios_hw_out8 (value, (u16) (BIOS_CFG_XTIDE_BASE + reg));
}

static u8
bios_ide_alt_status (void)
{
  return bios_hw_in8_p (BIOS_IDE_CTRL_PORT);
}

static void
bios_ide_write_control (u8 value)
{
  bios_hw_out8 (value, BIOS_IDE_CTRL_PORT);
}

static void
bios_ide_delay_400ns (void)
{
  bios_ide_alt_status ();
  bios_ide_alt_status ();
  bios_ide_alt_status ();
  bios_ide_alt_status ();
}

static int
bios_ide_wait_not_busy (void)
{
  u16 poll;

  for (poll = 0; poll != (u16) BIOS_CFG_XTIDE_POLL_LOOPS; ++poll)
    if ((bios_ide_alt_status () & IDE_STATUS_BSY) == 0)
      return 1;

  return 0;
}

static int
bios_ide_wait_drq (u8 *status)
{
  u16 poll;
  u8 current;

  /* Poll via Alt Status to avoid clearing a pending interrupt. */
  for (poll = 0; poll != (u16) BIOS_CFG_XTIDE_POLL_LOOPS; ++poll)
    {
      current = bios_ide_alt_status ();
      if ((current & IDE_STATUS_BSY) != 0)
        continue;
      if ((current & (IDE_STATUS_ERR | IDE_STATUS_DF)) != 0)
        {
          /* Read primary Status once to acknowledge the interrupt. */
          *status = bios_ide_read_reg (0x07);
          return 0;
        }
      if ((current & IDE_STATUS_DRQ) != 0)
        {
          *status = bios_ide_read_reg (0x07);
          return 1;
        }
    }

  *status = bios_ide_read_reg (0x07);
  return 0;
}

static int
bios_ide_wait_command_done (u8 *status)
{
  u16 poll;
  u8 current;

  /* Poll via Alt Status to avoid clearing a pending interrupt. */
  for (poll = 0; poll != (u16) BIOS_CFG_XTIDE_POLL_LOOPS; ++poll)
    {
      current = bios_ide_alt_status ();
      if ((current & (IDE_STATUS_BSY | IDE_STATUS_DRQ)) == 0)
        {
          /* Read primary Status once to acknowledge the interrupt. */
          *status = bios_ide_read_reg (0x07);
          return (*status & (IDE_STATUS_ERR | IDE_STATUS_DF)) == 0;
        }
    }

  *status = bios_ide_read_reg (0x07);
  return 0;
}

static void
bios_ide_select_drive (u8 unit, u8 head_bits, int lba_mode)
{
  bios_ide_write_reg (0x06,
                      (u8) ((lba_mode ? 0xE0U : 0xA0U)
                            | ((unit & 1U) << 4) | (head_bits & 0x0FU)));
  bios_ide_delay_400ns ();
}

static u16
bios_ide_read_data_word (void)
{
  u16 word;

  word = bios_hw_in8_p (BIOS_CFG_XTIDE_BASE);
  word |= (u16) bios_hw_in8_p ((u16) (BIOS_CFG_XTIDE_BASE + 0x08U)) << 8;
  return word;
}

static void
bios_ide_write_data_word (u16 word)
{
  bios_hw_out8 ((u8) (word >> 8), (u16) (BIOS_CFG_XTIDE_BASE + 0x08U));
  bios_hw_out8 ((u8) word, BIOS_CFG_XTIDE_BASE);
}

static void
bios_ide_read_sector_buffer (u16 seg, u16 off)
{
  volatile u8 __far *dst;
  u16 i;

  dst = (volatile u8 __far *) BIOS_MK_FP (seg, off);
  for (i = 0; i != BIOS_IDE_BYTES_PER_SECTOR; i += 2)
    {
      u16 word;

      word = bios_ide_read_data_word ();
      dst[i] = (u8) word;
      dst[(u16) (i + 1U)] = (u8) (word >> 8);
    }
}

static void
bios_ide_write_sector_buffer (u16 seg, u16 off)
{
  volatile u8 __far *src;
  u16 i;

  src = (volatile u8 __far *) BIOS_MK_FP (seg, off);
  for (i = 0; i != BIOS_IDE_BYTES_PER_SECTOR; i += 2)
    bios_ide_write_data_word ((u16) src[i]
                              | (u16) src[(u16) (i + 1U)] << 8);
}

static u8
bios_ide_status_from_hw (u8 status)
{
  u8 error;

  if ((status & IDE_STATUS_DF) != 0)
    return FLOPPY_ST_SEEK_FAILED;
  if ((status & IDE_STATUS_ERR) == 0)
    return FLOPPY_ST_TIMEOUT;

  error = bios_ide_read_reg (0x01);
  if ((error & IDE_ERROR_IDNF) != 0)
    return FLOPPY_ST_SECTOR_NOT_FOUND;
  if ((error & (IDE_ERROR_UNC | IDE_ERROR_BBK)) != 0)
    return FLOPPY_ST_BAD_CRC;
  if ((error & IDE_ERROR_ABRT) != 0)
    return FLOPPY_ST_BAD_COMMAND;
  return FLOPPY_ST_CONTROLLER;
}

static void
bios_ide_complete (bios_regs_t __far *regs, u8 status, u8 count)
{
  bios_bda_write8 (BDA_HARD_DISK_STATUS, status);
  bios_set_hi (&regs->ax, status);
  bios_set_lo (&regs->ax, count);
  if (status == FLOPPY_ST_OK)
    bios_clear_cf (regs);
  else
    bios_set_cf (regs);
}

static void
bios_ide_return_invalid_parameters (bios_regs_t __far *regs)
{
  bios_bda_write8 (BDA_HARD_DISK_STATUS, BIOS_IDE_ST_DRIVE_PARAMETER_FAILED);
  regs->ax = (u16) BIOS_IDE_ST_DRIVE_PARAMETER_FAILED << 8;
  regs->bx = 0x0000;
  regs->cx = 0x0000;
  regs->dx = 0x0000;
  regs->es = 0x0000;
  regs->di = 0x0000;
  bios_set_cf (regs);
}

static void
bios_ide_return_no_such_drive (bios_regs_t __far *regs)
{
  bios_bda_write8 (BDA_HARD_DISK_STATUS, FLOPPY_ST_OK);
  regs->ax = 0x0000;
  regs->cx = 0x0000;
  regs->dx = 0x0000;
  bios_clear_cf (regs);
}

static int
bios_ide_get_drive (u8 bios_drive, u8 *unit_out, bios_ide_drive_t **drive_out)
{
  u8 index;
  u8 unit;

  if (bios_drive < BIOS_IDE_BIOS_DRIVE_BASE)
    return 0;

  index = (u8) (bios_drive - BIOS_IDE_BIOS_DRIVE_BASE);
  if (index >= bios_ide_bios_drive_count)
    return 0;

  unit = bios_ide_bios_units[index];
  if (unit >= BIOS_IDE_MAX_DRIVES || !bios_ide_drives[unit].present)
    return 0;

  *unit_out = unit;
  *drive_out = &bios_ide_drives[unit];
  return 1;
}

static int
bios_ide_buffer_boundary_crossed_offset (u16 offset, u16 count)
{
  u32 bytes;

  bytes = (u32) count * BIOS_IDE_BYTES_PER_SECTOR;
  if (bytes == 0)
    return 0;

  return ((u32) offset + bytes - 1U) > 0xFFFFUL;
}

static int
bios_ide_buffer_boundary_crossed (const bios_regs_t __far *regs, u8 count)
{
  return bios_ide_buffer_boundary_crossed_offset (regs->bx, count);
}

static int
bios_ide_lba_to_chs (const bios_ide_drive_t *drive, u32 lba,
                     u16 *cylinder_out, u8 *head_out, u8 *sector_out)
{
  u16 cylinder;
  u16 per_cylinder;
  u32 remainder;
  u8 head;

  per_cylinder = (u16) drive->heads * drive->sectors;
  if (per_cylinder == 0)
    return 0;

  cylinder = bios_ide_capped_floor_div_u32_u16 (lba, per_cylinder,
                                                drive->cylinders);
  remainder = lba - (u32) cylinder * per_cylinder;
  head = 0;
  while (remainder >= drive->sectors && head + 1U < drive->heads)
    {
      remainder -= drive->sectors;
      ++head;
    }

  if (cylinder >= drive->cylinders || remainder >= drive->sectors)
    return 0;

  *cylinder_out = cylinder;
  *head_out = head;
  *sector_out = (u8) (remainder + 1U);
  return 1;
}

static void
bios_ide_advance_buffer (u16 *seg, u16 *off)
{
  u32 linear;

  linear = ((u32) *seg << 4) + *off + BIOS_IDE_BYTES_PER_SECTOR;
  *seg = (u16) (linear >> 4);
  *off = (u16) (linear & 0x000FU);
}

static void
bios_ide_write_dap_count (const bios_regs_t __far *regs, u16 count)
{
  bios_abs_write16 (regs->ds, (u16) (regs->si + 2U), count);
}

static u16
bios_ide_edd_flags (const bios_ide_drive_t *drive)
{
  u16 flags;

  flags = BIOS_IDE_EDD_FLAG_CHS_VALID;
  if (drive->present)
    flags |= BIOS_IDE_EDD_FLAG_WRITE_VERIFY;

  return flags;
}

static int
bios_ide_validate_dap (const bios_regs_t __far *regs, int require_buffer,
                       bios_ide_drive_t **drive_out, u8 *unit_out,
                       u16 *count_out, u16 *buffer_seg_out,
                       u16 *buffer_off_out, u32 *lba_out, u8 *status_out)
{
  bios_ide_drive_t *drive;
  u16 count;
  u16 buffer_off;
  u16 buffer_seg;
  u32 lba;
  u32 lba_high;
  u8 packet_size;
  u8 unit;

  if (!BIOS_CFG_XTIDE_EDD_ENABLED)
    {
      *status_out = FLOPPY_ST_BAD_COMMAND;
      return 0;
    }

  if (!bios_ide_get_drive (bios_lo (regs->dx), &unit, &drive))
    {
      *status_out = FLOPPY_ST_BAD_COMMAND;
      return 0;
    }

  packet_size = bios_abs_read8 (regs->ds, regs->si);
  if (packet_size < BIOS_IDE_EDD_PACKET_MIN_SIZE
      || bios_abs_read8 (regs->ds, (u16) (regs->si + 1U)) != 0x00)
    {
      *status_out = FLOPPY_ST_BAD_COMMAND;
      return 0;
    }

  count = bios_abs_read16 (regs->ds, (u16) (regs->si + 2U));
  if (count > BIOS_CFG_XTIDE_EDD_MAX_BLOCKS)
    {
      *status_out = BIOS_IDE_ST_INVALID_SECTOR_COUNT;
      return 0;
    }

  buffer_off = bios_abs_read16 (regs->ds, (u16) (regs->si + 4U));
  buffer_seg = bios_abs_read16 (regs->ds, (u16) (regs->si + 6U));

  if (require_buffer)
    {
      if (buffer_seg == 0xFFFFU && buffer_off == 0xFFFFU)
        {
          *status_out = FLOPPY_ST_BAD_COMMAND;
          return 0;
        }

      if (bios_ide_buffer_boundary_crossed_offset (buffer_off, count))
        {
          *status_out = FLOPPY_ST_DMA_BOUNDARY;
          return 0;
        }
    }

  lba = bios_abs_read32 (regs->ds, (u16) (regs->si + 8U));
  lba_high = bios_abs_read32 (regs->ds, (u16) (regs->si + 12U));
  if (lba_high != 0
      || (count != 0
          && (lba >= drive->total_sectors
              || count > drive->total_sectors - lba)))
    {
      *status_out = FLOPPY_ST_SECTOR_NOT_FOUND;
      return 0;
    }

  *drive_out = drive;
  *unit_out = unit;
  *count_out = count;
  *buffer_seg_out = buffer_seg;
  *buffer_off_out = buffer_off;
  *lba_out = lba;
  *status_out = FLOPPY_ST_OK;
  return 1;
}

static int
bios_ide_validate_request (const bios_regs_t __far *regs,
                           bios_ide_drive_t **drive_out, u8 *unit_out,
                           u8 *count_out, u32 *lba_out, u8 *status_out)
{
  bios_ide_drive_t *drive;
  u8 count;
  u8 unit;
  u8 head;
  u8 sector;
  u16 cylinder;
  u32 lba;

  count = bios_lo (regs->ax);
  if (!bios_ide_get_drive (bios_lo (regs->dx), &unit, &drive))
    {
      *status_out = FLOPPY_ST_BAD_COMMAND;
      return 0;
    }

  if (count == 0 || count > BIOS_IDE_LEGACY_MAX_BLOCKS)
    {
      *status_out = BIOS_IDE_ST_INVALID_SECTOR_COUNT;
      return 0;
    }

  if (bios_ide_buffer_boundary_crossed (regs, count))
    {
      *status_out = FLOPPY_ST_DMA_BOUNDARY;
      return 0;
    }

  head = bios_hi (regs->dx);
  sector = (u8) (bios_lo (regs->cx) & 0x3FU);
  cylinder = (u16) (bios_hi (regs->cx) | ((bios_lo (regs->cx) & 0xC0U) << 2));
  if (head >= drive->heads
      || sector == 0
      || sector > drive->sectors
      || cylinder >= drive->cylinders)
    {
      *status_out = FLOPPY_ST_SECTOR_NOT_FOUND;
      return 0;
    }

  lba =
    (((u32) cylinder * drive->heads) + head) * drive->sectors + (sector - 1U);
  if (lba + count > drive->chs_total_sectors)
    {
      *status_out = FLOPPY_ST_SECTOR_NOT_FOUND;
      return 0;
    }

  *drive_out = drive;
  *unit_out = unit;
  *count_out = count;
  *lba_out = lba;
  *status_out = FLOPPY_ST_OK;
  return 1;
}

static int
bios_ide_program_lba_sector (u8 unit, u32 lba, u8 command, u8 *status_out)
{
  if (!bios_ide_wait_not_busy ())
    {
      *status_out = FLOPPY_ST_TIMEOUT;
      return 0;
    }

  bios_ide_write_reg (0x01, 0x00);
  bios_ide_write_reg (0x02, 0x01);

  bios_ide_write_reg (0x03, (u8) lba);
  bios_ide_write_reg (0x04, (u8) (lba >> 8));
  bios_ide_write_reg (0x05, (u8) (lba >> 16));
  bios_ide_select_drive (unit, (u8) (lba >> 24), 1);

  bios_ide_write_reg (0x07, command);
  bios_ide_delay_400ns ();
  if (!bios_ide_wait_drq (status_out))
    {
      *status_out = bios_ide_status_from_hw (*status_out);
      return 0;
    }

  return 1;
}

static int
bios_ide_program_chs_sector (u8 unit, u16 cylinder, u8 head, u8 sector,
                             u8 command, u8 *status_out)
{
  if (!bios_ide_wait_not_busy ())
    {
      *status_out = FLOPPY_ST_TIMEOUT;
      return 0;
    }

  bios_ide_write_reg (0x01, 0x00);
  bios_ide_write_reg (0x02, 0x01);
  bios_ide_write_reg (0x03, sector);
  bios_ide_write_reg (0x04, (u8) cylinder);
  bios_ide_write_reg (0x05, (u8) (cylinder >> 8));
  bios_ide_select_drive (unit, head, 0);

  bios_ide_write_reg (0x07, command);
  bios_ide_delay_400ns ();
  if (!bios_ide_wait_drq (status_out))
    {
      *status_out = bios_ide_status_from_hw (*status_out);
      return 0;
    }

  return 1;
}

static int
bios_ide_program_packet_sector (const bios_ide_drive_t *drive, u8 unit, u32 lba,
                                u8 command, u8 *status_out)
{
  u16 cylinder;
  u8 head;
  u8 sector;

  if (drive->lba_supported)
    return bios_ide_program_lba_sector (unit, lba, command, status_out);

  if (!bios_ide_lba_to_chs (drive, lba, &cylinder, &head, &sector))
    {
      *status_out = FLOPPY_ST_SECTOR_NOT_FOUND;
      return 0;
    }

  return bios_ide_program_chs_sector (unit, cylinder, head, sector, command,
                                      status_out);
}

static int
bios_ide_issue_lba_nodata_command (u8 unit, u32 lba, u8 count, u8 command,
                                   u8 *status_out)
{
  u8 status;

  if (!bios_ide_wait_not_busy ())
    {
      *status_out = FLOPPY_ST_TIMEOUT;
      return 0;
    }

  bios_ide_write_reg (0x01, 0x00);
  bios_ide_write_reg (0x02, count);
  bios_ide_write_reg (0x03, (u8) lba);
  bios_ide_write_reg (0x04, (u8) (lba >> 8));
  bios_ide_write_reg (0x05, (u8) (lba >> 16));
  bios_ide_select_drive (unit, (u8) (lba >> 24), 1);
  bios_ide_write_reg (0x07, command);
  bios_ide_delay_400ns ();

  if (!bios_ide_wait_command_done (&status))
    {
      *status_out = bios_ide_status_from_hw (status);
      return 0;
    }

  *status_out = FLOPPY_ST_OK;
  return 1;
}

static int
bios_ide_issue_chs_nodata_command (u8 unit, u16 cylinder, u8 head, u8 sector,
                                   u8 count, u8 command, u8 *status_out)
{
  u8 status;

  if (!bios_ide_wait_not_busy ())
    {
      *status_out = FLOPPY_ST_TIMEOUT;
      return 0;
    }

  bios_ide_write_reg (0x01, 0x00);
  bios_ide_write_reg (0x02, count);
  bios_ide_write_reg (0x03, sector);
  bios_ide_write_reg (0x04, (u8) cylinder);
  bios_ide_write_reg (0x05, (u8) (cylinder >> 8));
  bios_ide_select_drive (unit, head, 0);
  bios_ide_write_reg (0x07, command);
  bios_ide_delay_400ns ();

  if (!bios_ide_wait_command_done (&status))
    {
      *status_out = bios_ide_status_from_hw (status);
      return 0;
    }

  *status_out = FLOPPY_ST_OK;
  return 1;
}

static int
bios_ide_issue_packet_nodata_command (const bios_ide_drive_t *drive, u8 unit,
                                      u32 lba, u8 count, u8 command,
                                      u8 *status_out)
{
  u16 cylinder;
  u8 head;
  u8 sector;

  if (drive->lba_supported)
    return bios_ide_issue_lba_nodata_command (unit, lba, count, command,
                                              status_out);

  if (!bios_ide_lba_to_chs (drive, lba, &cylinder, &head, &sector))
    {
      *status_out = FLOPPY_ST_SECTOR_NOT_FOUND;
      return 0;
    }

  return bios_ide_issue_chs_nodata_command (unit, cylinder, head, sector, count,
                                            command, status_out);
}

static int
bios_ide_verify_blocks (const bios_ide_drive_t *drive, u8 unit, u32 lba,
                        u16 count, u16 *done_out, u8 *status_out)
{
  u16 done;

  for (done = 0; done != count; ++done)
    {
      if (!bios_ide_issue_packet_nodata_command (drive, unit, lba,
                                                 1U, IDE_CMD_VERIFY_SECTORS,
                                                 status_out))
        {
          *done_out = done;
          return 0;
        }
      ++lba;
    }

  *done_out = count;
  *status_out = FLOPPY_ST_OK;
  return 1;
}

static int
bios_ide_seek_block (const bios_ide_drive_t *drive, u8 unit, u32 lba,
                     u8 *status_out)
{
  return bios_ide_issue_packet_nodata_command (drive, unit, lba, 1U,
                                               IDE_CMD_SEEK, status_out);
}

static void
bios_ide_transfer (bios_regs_t __far *regs, u8 command)
{
  bios_ide_drive_t *drive;
  u8 count;
  u8 done;
  u8 head;
  u8 sector;
  u8 status;
  u8 unit;
  u16 cylinder;
  u16 offset;
  u32 lba;

  if (!bios_ide_validate_request (regs, &drive, &unit, &count, &lba, &status))
    {
      bios_ide_complete (regs, status, 0);
      return;
    }

  offset = regs->bx;
  head = bios_hi (regs->dx);
  sector = (u8) (bios_lo (regs->cx) & 0x3FU);
  cylinder = (u16) (bios_hi (regs->cx) | ((bios_lo (regs->cx) & 0xC0U) << 2));

  bios_serial_debug_puts (command == IDE_CMD_READ_SECTORS ? "IR " : "IW ");
  bios_serial_debug_put_hex8 (bios_lo (regs->dx));
  bios_serial_debug_puts (" C");
  bios_serial_debug_put_hex16 (cylinder);
  bios_serial_debug_puts (" H");
  bios_serial_debug_put_hex8 (head);
  bios_serial_debug_puts (" S");
  bios_serial_debug_put_hex8 (sector);
  bios_serial_debug_puts (" N");
  bios_serial_debug_put_hex8 (count);
  bios_serial_debug_puts (" E");
  bios_serial_debug_put_hex16 (regs->es);
  bios_serial_debug_putc (':');
  bios_serial_debug_put_hex16 (regs->bx);
  bios_serial_debug_putc ('\n');

  for (done = 0; done != count; ++done)
    {
      u8 hw_status;

      if ((drive->use_lba
           && !bios_ide_program_lba_sector (unit, lba, command, &hw_status))
          || (!drive->use_lba
              && !bios_ide_program_chs_sector (unit, cylinder, head, sector,
                                               command, &hw_status)))
        {
          bios_ide_complete (regs, hw_status, done);
          return;
        }

      if (command == IDE_CMD_READ_SECTORS)
        bios_ide_read_sector_buffer (regs->es, offset);
      else
        bios_ide_write_sector_buffer (regs->es, offset);

      if (!bios_ide_wait_command_done (&hw_status))
        {
          bios_ide_complete (regs, bios_ide_status_from_hw (hw_status), done);
          return;
        }

      if (command == IDE_CMD_READ_SECTORS)
        {
          bios_serial_debug_puts ("IS ");
          bios_serial_debug_put_hex16 (bios_abs_read16 (regs->es,
                                                        (u16) (offset + 510U)));
          bios_serial_debug_putc ('\n');
        }

      lba++;
      sector++;
      if (sector > drive->sectors)
        {
          sector = 1;
          head++;
          if (head >= drive->heads)
            {
              head = 0;
              cylinder++;
            }
        }
      offset = (u16) (offset + BIOS_IDE_BYTES_PER_SECTOR);
    }

  bios_ide_complete (regs, FLOPPY_ST_OK, count);
}

static void
bios_ide_verify (bios_regs_t __far *regs)
{
  bios_ide_drive_t *drive;
  u16 done;
  u32 lba;
  u8 count;
  u8 status;
  u8 unit;

  if (!bios_ide_validate_request (regs, &drive, &unit, &count, &lba, &status))
    {
      bios_ide_complete (regs, status, 0);
      return;
    }

  if (!bios_ide_verify_blocks (drive, unit, lba, count, &done, &status))
    {
      bios_ide_complete (regs, status, (u8) done);
      return;
    }

  bios_ide_complete (regs, FLOPPY_ST_OK, count);
}

static void
bios_ide_get_parameters (bios_regs_t __far *regs)
{
  bios_ide_drive_t *drive;
  u16 max_cylinder;
  u8 bios_index;
  u8 unit;

  if (!bios_ide_get_drive (bios_lo (regs->dx), &unit, &drive))
    {
      bios_ide_return_invalid_parameters (regs);
      return;
    }

  bios_index = (u8) (bios_lo (regs->dx) - BIOS_IDE_BIOS_DRIVE_BASE);
  max_cylinder = (u16) (drive->cylinders - 1U);
  regs->ax = 0x0000;
  regs->bx = 0x0000;
  regs->cx = (u16) ((max_cylinder & 0x00FFU) << 8)
    | (u16) (((max_cylinder >> 2) & 0x00C0U) | drive->sectors);
  regs->dx =
    (u16) ((u16) (drive->heads - 1U) << 8) | bios_ide_bios_drive_count;
  regs->es = BIOS_ROM_SEGMENT;
  regs->di = BIOS_FP_OFF ((void __far *) bios_ide_parameter_tables[bios_index]);
  bios_bda_write8 (BDA_HARD_DISK_STATUS, FLOPPY_ST_OK);
  bios_clear_cf (regs);
}

static void
bios_ide_drive_type (bios_regs_t __far *regs)
{
  bios_ide_drive_t *drive;
  u8 unit;

  if (!bios_ide_get_drive (bios_lo (regs->dx), &unit, &drive))
    {
      bios_ide_return_no_such_drive (regs);
      return;
    }

  regs->cx = (u16) (drive->total_sectors >> 16);
  regs->dx = (u16) drive->total_sectors;
  regs->ax = 0x0300;
  bios_bda_write8 (BDA_HARD_DISK_STATUS, FLOPPY_ST_OK);
  bios_clear_cf (regs);
}

static void
bios_ide_simple_status (bios_regs_t __far *regs)
{
  u8 unit;
  bios_ide_drive_t *drive;

  if (!bios_ide_get_drive (bios_lo (regs->dx), &unit, &drive))
    {
      bios_ide_complete (regs, FLOPPY_ST_BAD_COMMAND, 0);
      return;
    }

  bios_ide_complete (regs, FLOPPY_ST_OK, 0);
}

static void
bios_ide_edd_install_check (bios_regs_t __far *regs)
{
  bios_ide_drive_t *drive;
  u8 unit;

  bios_serial_debug_puts ("E41\n");
  if (!BIOS_CFG_XTIDE_EDD_ENABLED
      || regs->bx != 0x55AA
      || !bios_ide_get_drive (bios_lo (regs->dx), &unit, &drive))
    {
      bios_serial_debug_puts ("e41-\n");
      bios_ide_complete (regs, FLOPPY_ST_BAD_COMMAND, 0);
      return;
    }

  regs->ax = (u16) BIOS_IDE_EDD_VERSION << 8;
  regs->bx = 0xAA55;
  regs->cx = BIOS_IDE_EDD_INSTALL_FEATURES;
  bios_bda_write8 (BDA_HARD_DISK_STATUS, FLOPPY_ST_OK);
  bios_clear_cf (regs);
  bios_serial_debug_puts ("e41+\n");
}

static void
bios_ide_edd_transfer (bios_regs_t __far *regs, u8 command)
{
  bios_ide_drive_t *drive;
  u16 buffer_off;
  u16 buffer_seg;
  u16 count;
  u16 done;
  u16 verified;
  u32 lba;
  u8 hw_status;
  u8 unit;
  u8 verify_after_write;
  u8 flags;

  verify_after_write = 0;
  if (command == IDE_CMD_WRITE_SECTORS)
    {
      flags = bios_lo (regs->ax);
      if ((flags & 0xFEU) != 0)
        {
          bios_ide_write_dap_count (regs, 0);
          bios_ide_complete (regs, FLOPPY_ST_BAD_COMMAND, 0);
          return;
        }
      verify_after_write = (u8) (flags & 0x01U);
    }

  if (!bios_ide_validate_dap (regs, 1, &drive, &unit, &count, &buffer_seg,
                              &buffer_off, &lba, &hw_status))
    {
      bios_serial_debug_puts ("EX ");
      bios_serial_debug_put_hex8 (bios_hi (regs->ax));
      bios_serial_debug_putc ('\n');
      bios_ide_write_dap_count (regs, 0);
      bios_ide_complete (regs, hw_status, 0);
      return;
    }

  bios_serial_debug_puts (command == IDE_CMD_READ_SECTORS ? "ER " : "EW ");
  bios_serial_debug_put_hex8 (bios_lo (regs->dx));
  bios_serial_debug_puts (" L");
  bios_serial_debug_put_hex16 ((u16) (lba >> 16));
  bios_serial_debug_putc (':');
  bios_serial_debug_put_hex16 ((u16) lba);
  bios_serial_debug_puts (" N");
  bios_serial_debug_put_hex16 (count);
  bios_serial_debug_puts (" E");
  bios_serial_debug_put_hex16 (buffer_seg);
  bios_serial_debug_putc (':');
  bios_serial_debug_put_hex16 (buffer_off);
  bios_serial_debug_putc ('\n');

  for (done = 0; done != count; ++done)
    {
      if (!bios_ide_program_packet_sector (drive, unit, lba, command, &hw_status))
        {
          bios_ide_write_dap_count (regs, done);
          bios_ide_complete (regs, hw_status, (u8) done);
          return;
        }

      if (command == IDE_CMD_READ_SECTORS)
        bios_ide_read_sector_buffer (buffer_seg, buffer_off);
      else
        bios_ide_write_sector_buffer (buffer_seg, buffer_off);

      if (!bios_ide_wait_command_done (&hw_status))
        {
          bios_ide_write_dap_count (regs, done);
          bios_ide_complete (regs, bios_ide_status_from_hw (hw_status),
                             (u8) done);
          return;
        }

      if (command == IDE_CMD_WRITE_SECTORS && verify_after_write)
        {
          if (!bios_ide_verify_blocks (drive, unit, lba, 1U, &verified,
                                       &hw_status))
            {
              bios_ide_write_dap_count (regs, done);
              bios_ide_complete (regs, hw_status, (u8) done);
              return;
            }
        }

      ++lba;
      bios_ide_advance_buffer (&buffer_seg, &buffer_off);
    }

  bios_ide_write_dap_count (regs, count);
  bios_ide_complete (regs, FLOPPY_ST_OK, (u8) count);
}

static void
bios_ide_edd_verify (bios_regs_t __far *regs)
{
  bios_ide_drive_t *drive;
  u16 buffer_off;
  u16 buffer_seg;
  u16 count;
  u16 done;
  u32 lba;
  u8 status;
  u8 unit;

  if (!bios_ide_validate_dap (regs, 0, &drive, &unit, &count, &buffer_seg,
                              &buffer_off, &lba, &status))
    {
      bios_ide_write_dap_count (regs, 0);
      bios_ide_complete (regs, status, 0);
      return;
    }

  if (!bios_ide_verify_blocks (drive, unit, lba, count, &done, &status))
    {
      bios_ide_write_dap_count (regs, done);
      bios_ide_complete (regs, status, (u8) done);
      return;
    }

  bios_ide_write_dap_count (regs, count);
  bios_ide_complete (regs, FLOPPY_ST_OK, (u8) count);
}

static void
bios_ide_edd_seek (bios_regs_t __far *regs)
{
  bios_ide_drive_t *drive;
  u16 buffer_off;
  u16 buffer_seg;
  u16 count;
  u32 lba;
  u8 status;
  u8 unit;

  if (!bios_ide_validate_dap (regs, 0, &drive, &unit, &count, &buffer_seg,
                              &buffer_off, &lba, &status))
    {
      bios_ide_complete (regs, status, 0);
      return;
    }

  if (count == 0)
    {
      bios_ide_complete (regs, FLOPPY_ST_OK, 0);
      return;
    }

  if (!bios_ide_seek_block (drive, unit, lba, &status))
    {
      bios_ide_complete (regs, status, 0);
      return;
    }

  bios_ide_complete (regs, FLOPPY_ST_OK, 0);
}

static void
bios_ide_edd_get_parameters (bios_regs_t __far *regs)
{
  bios_ide_drive_t *drive;
  u16 buffer_size;
  u16 return_size;
  u8 unit;

  bios_serial_debug_puts ("E48\n");
  if (!BIOS_CFG_XTIDE_EDD_ENABLED
      || !bios_ide_get_drive (bios_lo (regs->dx), &unit, &drive))
    {
      bios_ide_complete (regs, FLOPPY_ST_BAD_COMMAND, 0);
      return;
    }

  buffer_size = bios_abs_read16 (regs->ds, regs->si);
  if (buffer_size < BIOS_IDE_EDD_PARAMS_MIN_SIZE)
    {
      bios_ide_complete (regs, FLOPPY_ST_BAD_COMMAND, 0);
      return;
    }

  return_size =
    buffer_size >= BIOS_IDE_EDD_PARAMS_FULL_SIZE ? BIOS_IDE_EDD_PARAMS_FULL_SIZE
    : BIOS_IDE_EDD_PARAMS_MIN_SIZE;
  bios_abs_write16 (regs->ds, regs->si, return_size);
  bios_abs_write16 (regs->ds, (u16) (regs->si + 2U), bios_ide_edd_flags (drive));
  bios_abs_write32 (regs->ds, (u16) (regs->si + 4U), drive->physical_cylinders);
  bios_abs_write32 (regs->ds, (u16) (regs->si + 8U), drive->physical_heads);
  bios_abs_write32 (regs->ds, (u16) (regs->si + 12U), drive->physical_sectors);
  bios_abs_write32 (regs->ds, (u16) (regs->si + 16U), drive->total_sectors);
  bios_abs_write32 (regs->ds, (u16) (regs->si + 20U), 0x00000000UL);
  bios_abs_write16 (regs->ds, (u16) (regs->si + 24U),
                    BIOS_IDE_BYTES_PER_SECTOR);
  if (buffer_size >= BIOS_IDE_EDD_PARAMS_FULL_SIZE)
    {
      bios_abs_write16 (regs->ds, (u16) (regs->si + 26U),
                        BIOS_FP_OFF ((void __far *) bios_ide_dpte_tables[unit]));
      bios_abs_write16 (regs->ds, (u16) (regs->si + 28U), BIOS_ROM_SEGMENT);
    }

  bios_ide_complete (regs, FLOPPY_ST_OK, 0);
}

static void
bios_ide_build_parameter_table (u8 bios_index, const bios_ide_drive_t *drive)
{
  u8 *table;
  u8 checksum;
  u8 i;

  table = bios_ide_parameter_tables[bios_index];
  for (i = 0; i != 16; ++i)
    table[i] = 0x00;

  table[0] = (u8) drive->cylinders;
  table[1] = (u8) (drive->cylinders >> 8);
  table[2] = drive->heads;
  table[3] = 0xA0;
  table[4] = drive->physical_sectors;
  table[8] = drive->physical_heads > 8 ? 0x08 : 0x00;
  table[9] = (u8) drive->physical_cylinders;
  table[10] = (u8) (drive->physical_cylinders >> 8);
  table[11] = drive->physical_heads;
  table[13] = 0x00;
  table[14] = drive->sectors;

  checksum = 0;
  for (i = 0; i != 15; ++i)
    checksum = (u8) (checksum + table[i]);
  table[15] = (u8) (0U - checksum);
}

static void
bios_ide_build_dpte_table (u8 unit, const bios_ide_drive_t *drive)
{
  u16 options;
  u8 *table;
  u8 checksum;
  u8 i;

  table = bios_ide_dpte_tables[unit];
  for (i = 0; i != BIOS_IDE_EDD_DPT_SIZE; ++i)
    table[i] = 0x00;

  table[0] = (u8) BIOS_CFG_XTIDE_BASE;
  table[1] = (u8) (BIOS_CFG_XTIDE_BASE >> 8);
  table[2] = (u8) BIOS_IDE_CTRL_PORT;
  table[3] = (u8) (BIOS_IDE_CTRL_PORT >> 8);
  table[4] = (u8) (0xA0U | ((unit & 1U) << 4)
                   | (drive->use_lba ? 0x40U : 0x00U));
  table[5] = 0x00;
  table[6] = (u8) (BIOS_CFG_XTIDE_IRQ & 0x0FU);
  table[7] = drive->multiple_count;
  table[8] = 0x00;
  table[9] = 0x00;

  options = 0x0000;
  if (drive->multiple_count != 0)
    options |= 0x0004U;
  if (drive->translated)
    options |= 0x0008U;
  if (drive->use_lba)
    options |= 0x0010U;
  if (drive->use_lba && drive->translated)
    options |= 0x0200U;

  table[10] = (u8) options;
  table[11] = (u8) (options >> 8);
  table[12] = 0x00;
  table[13] = 0x00;
  table[14] = 0x11;

  checksum = 0;
  for (i = 0; i != (u8) (BIOS_IDE_EDD_DPT_SIZE - 1U); ++i)
    checksum = (u8) (checksum + table[i]);
  table[15] = (u8) (0U - checksum);
}

static void
bios_ide_install_vector (u8 intno, u8 bios_index)
{
  bios_abs_write16 (0x0000, (u16) intno * 4U,
                    BIOS_FP_OFF ((void __far *) bios_ide_parameter_tables[bios_index]));
  bios_abs_write16 (0x0000, (u16) intno * 4U + 2U, BIOS_ROM_SEGMENT);
}

static void
bios_ide_debug_log_drive (u8 unit, const bios_ide_drive_t *drive)
{
  bios_serial_debug_puts ("IDE ");
  bios_serial_debug_put_hex8 ((u8) (BIOS_IDE_BIOS_DRIVE_BASE + unit));
  bios_serial_debug_puts (" C=");
  bios_serial_debug_put_hex16 (drive->cylinders);
  bios_serial_debug_puts (" H=");
  bios_serial_debug_put_hex8 (drive->heads);
  bios_serial_debug_puts (" S=");
  bios_serial_debug_put_hex8 (drive->sectors);
  bios_serial_debug_puts (" PC=");
  bios_serial_debug_put_hex16 (drive->physical_cylinders);
  bios_serial_debug_puts (" PH=");
  bios_serial_debug_put_hex8 (drive->physical_heads);
  bios_serial_debug_puts (" PS=");
  bios_serial_debug_put_hex8 (drive->physical_sectors);
  bios_serial_debug_puts (" T=");
  bios_serial_debug_put_hex16 ((u16) (drive->total_sectors >> 16));
  bios_serial_debug_putc (':');
  bios_serial_debug_put_hex16 ((u16) drive->total_sectors);
  if (drive->chs_total_sectors != drive->total_sectors)
    {
      bios_serial_debug_puts (" X=");
      bios_serial_debug_put_hex16 ((u16) (drive->chs_total_sectors >> 16));
      bios_serial_debug_putc (':');
      bios_serial_debug_put_hex16 ((u16) drive->chs_total_sectors);
    }
  if (drive->multiple_count != 0)
    {
      bios_serial_debug_puts (" M=");
      bios_serial_debug_put_hex8 (drive->multiple_count);
    }
  bios_serial_debug_puts (drive->lba_supported
                          ? (drive->use_lba ? " LBA\n" : " LBA-LEGACY-CHS\n")
                          : " CHS\n");
}

static int
bios_ide_identify_drive (u8 unit, bios_ide_drive_t *drive)
{
  u16 *identify = bios_ide_identify_buf;
  u16 accessible_cylinders;
  u16 base_cylinders;
  u16 current_cylinders;
  u16 default_cylinders;
  u16 i;
  u16 per_cylinder;
  u8 base_heads;
  u8 base_sectors;
  u8 current_heads;
  u8 current_sectors;
  u8 current_valid;
  u8 default_heads;
  u8 default_sectors;
  u8 lba_supported;
  u8 status;
  u32 chs_total_sectors;
  u32 current_total_sectors;
  u32 total_sectors;

  bios_ide_select_drive (unit, 0, 0);
  if (!bios_ide_wait_not_busy ())
    return 0;

  bios_ide_write_reg (0x01, 0x00);
  bios_ide_write_reg (0x02, 0x00);
  bios_ide_write_reg (0x03, 0x00);
  bios_ide_write_reg (0x04, 0x00);
  bios_ide_write_reg (0x05, 0x00);
  bios_ide_write_reg (0x07, IDE_CMD_IDENTIFY);
  bios_ide_delay_400ns ();

  /*
   * Quick check: floating bus (0xFF) or immediate zero means no drive.
   * Read Alt Status to avoid clearing any pending interrupt.
   */
  status = bios_ide_alt_status ();
  if (status == 0x00 || status == 0xFF)
    return 0;

  if (!bios_ide_wait_drq (&status))
    return 0;

  for (i = 0; i != BIOS_IDE_WORDS_PER_SECTOR; ++i)
    identify[i] = bios_ide_read_data_word ();
  bios_ide_wait_command_done (&status);

  default_cylinders = identify[1];
  default_heads = (u8) identify[3];
  default_sectors = (u8) identify[6];

  current_valid = (identify[53] & 0x0001U) != 0;
  current_cylinders = identify[54];
  current_heads = (u8) identify[55];
  current_sectors = (u8) identify[56];
  current_total_sectors = (u32) identify[57] | ((u32) identify[58] << 16);

  base_cylinders = default_cylinders;
  base_heads = default_heads;
  base_sectors = default_sectors;
  if (current_valid
      && current_cylinders != 0
      && current_heads != 0
      && current_sectors != 0)
    {
      base_cylinders = current_cylinders;
      base_heads = current_heads;
      base_sectors = current_sectors;
    }

  lba_supported = (identify[49] & 0x0200U) != 0;
  total_sectors = (u32) identify[60] | ((u32) identify[61] << 16);
  if (total_sectors == 0 && current_valid && current_total_sectors != 0)
    total_sectors = current_total_sectors;
  if (total_sectors == 0
      && base_cylinders != 0 && base_heads != 0 && base_sectors != 0)
    total_sectors = (u32) base_cylinders * base_heads * base_sectors;
  if (total_sectors == 0)
    return 0;

  drive->physical_cylinders = default_cylinders != 0 ? default_cylinders
                                                     : base_cylinders;
  drive->physical_heads = default_heads != 0 ? default_heads : base_heads;
  drive->physical_sectors = default_sectors != 0 ? default_sectors
                                                 : base_sectors;
  drive->multiple_count =
    (identify[59] & 0x0100U) != 0 ? (u8) identify[59] : 0;

  if (BIOS_CFG_XTIDE_PREFER_LBA && lba_supported)
    {
      drive->heads = BIOS_CFG_XTIDE_TRANSLATED_HEADS;
      drive->sectors = BIOS_CFG_XTIDE_TRANSLATED_SECTORS;
      per_cylinder = (u16) drive->heads * drive->sectors;
      accessible_cylinders =
        bios_ide_capped_ceil_div_u32_u16 (total_sectors, per_cylinder, 1024);
      if (accessible_cylinders == 0)
        accessible_cylinders = 1;
      drive->use_lba = 1;
      drive->cylinders = accessible_cylinders;
    }
  else
    {
      if (base_heads == 0)
        base_heads = BIOS_CFG_XTIDE_TRANSLATED_HEADS;
      if (base_sectors == 0 || base_sectors > 63)
        base_sectors = BIOS_CFG_XTIDE_TRANSLATED_SECTORS;
      if (base_cylinders == 0)
        {
          per_cylinder = (u16) base_heads * base_sectors;
          base_cylinders =
            bios_ide_capped_floor_div_u32_u16 (total_sectors, per_cylinder, 1024);
          if (base_cylinders == 0)
            base_cylinders = 1;
        }
      if (base_cylinders > 1024)
        base_cylinders = 1024;

      drive->cylinders = base_cylinders;
      drive->heads = base_heads;
      drive->sectors = base_sectors;
      drive->use_lba = 0;
    }

  chs_total_sectors = (u32) drive->cylinders * drive->heads * drive->sectors;
  if (chs_total_sectors > total_sectors)
    chs_total_sectors = total_sectors;

  drive->present = 1;
  drive->lba_supported = lba_supported;
  drive->total_sectors = total_sectors;
  drive->chs_total_sectors = chs_total_sectors;
  drive->translated =
    (drive->cylinders != drive->physical_cylinders)
    || (drive->heads != drive->physical_heads)
    || (drive->sectors != drive->physical_sectors);

  if (drive->physical_heads == 0)
    drive->physical_heads = drive->heads;
  if (drive->physical_sectors == 0)
    drive->physical_sectors = drive->sectors;
  if (drive->physical_cylinders == 0)
    drive->physical_cylinders = drive->cylinders;

  bios_ide_debug_log_drive (unit, drive);
  return 1;
}

static int
bios_ide_probe_enabled (u8 unit)
{
  return unit == 0 ? BIOS_CFG_XTIDE_PROBE_MASTER : BIOS_CFG_XTIDE_PROBE_SLAVE;
}

static int
bios_ide_soft_reset (void)
{
  u16 pause;
  u8 status;

  status = bios_ide_alt_status ();
  bios_serial_debug_puts ("IDE alt pre=");
  bios_serial_debug_put_hex8 (status);
  bios_serial_debug_putc ('\n');
  /* Assert SRST for at least 25 us (ATA spec minimum). */
  bios_ide_write_control (IDE_DEVCTL_NIEN | IDE_DEVCTL_SRST);
  for (pause = 0; pause != 0x0100; ++pause)
    bios_hw_pause ();
  status = bios_ide_alt_status ();
  bios_serial_debug_puts ("IDE alt srst=");
  bios_serial_debug_put_hex8 (status);
  bios_serial_debug_putc ('\n');

  /* Deassert SRST, then wait at least 2 ms before polling (ATA spec). */
  bios_ide_write_control (IDE_DEVCTL_NIEN);
  for (pause = 0; pause != 0x0400; ++pause)
    bios_hw_pause ();
  status = bios_ide_alt_status ();
  bios_serial_debug_puts ("IDE alt rel=");
  bios_serial_debug_put_hex8 (status);
  bios_serial_debug_putc ('\n');

  if (!bios_ide_wait_not_busy ())
    {
      status = bios_ide_alt_status ();
      bios_serial_debug_puts ("IDE alt busy=");
      bios_serial_debug_put_hex8 (status);
      bios_serial_debug_putc ('\n');
      return 0;
    }

  status = bios_ide_alt_status ();
  bios_serial_debug_puts ("IDE alt ok=");
  bios_serial_debug_put_hex8 (status);
  bios_serial_debug_putc ('\n');
  return 1;
}

void
bios_ide_init (void)
{
  u8 bios_index;
  u8 unit;

  bios_bda_write8 (BDA_HARD_DISK_STATUS, FLOPPY_ST_OK);
  bios_bda_write8 (BDA_HARD_DISK_COUNT, 0x00);
  bios_bda_write8 (BDA_HARD_DISK_CONTROL, 0x00);
  bios_bda_write8 (BDA_HARD_DISK_PORT_OFFSET, 0x00);
  bios_abs_write32 (0x0000, (u16) 0x41 * 4U, 0x00000000UL);
  bios_abs_write32 (0x0000, (u16) 0x46 * 4U, 0x00000000UL);
  bios_ide_bios_drive_count = 0;

  for (unit = 0; unit != BIOS_IDE_MAX_DRIVES; ++unit)
    bios_ide_drives[unit].present = 0;

  if (!BIOS_CFG_XTIDE_ENABLED
      || (!BIOS_CFG_XTIDE_PROBE_MASTER && !BIOS_CFG_XTIDE_PROBE_SLAVE))
    return;

  if (!bios_ide_soft_reset ())
    {
      bios_serial_debug_puts ("IDE reset fail\n");
      return;
    }

  for (unit = 0; unit != BIOS_IDE_MAX_DRIVES; ++unit)
    {
      if (!bios_ide_probe_enabled (unit))
        continue;

      if (bios_ide_identify_drive (unit, &bios_ide_drives[unit]))
        bios_ide_bios_units[bios_ide_bios_drive_count++] = unit;
    }

  bios_bda_write8 (BDA_HARD_DISK_COUNT, bios_ide_bios_drive_count);
  if (bios_ide_bios_drive_count == 0)
    {
      bios_serial_debug_puts ("IDE no drive\n");
      return;
    }

  bios_bda_write8 (BDA_HARD_DISK_PORT_OFFSET, 0x0E);
  for (bios_index = 0; bios_index != bios_ide_bios_drive_count; ++bios_index)
    {
      unit = bios_ide_bios_units[bios_index];
      bios_ide_build_parameter_table (bios_index, &bios_ide_drives[unit]);
      bios_ide_build_dpte_table (unit, &bios_ide_drives[unit]);
    }

  bios_ide_install_vector (0x41, 0);
  if (bios_ide_bios_drive_count > 1)
    bios_ide_install_vector (0x46, 1);
}

void
bios_ide_service_int13 (bios_regs_t __far *regs)
{
  switch (bios_hi (regs->ax))
    {
    case 0x00:
      {
        u8 unit;
        bios_ide_drive_t *drive;

        if (!bios_ide_get_drive (bios_lo (regs->dx), &unit, &drive))
          {
            bios_ide_complete (regs, FLOPPY_ST_RESET_FAILED, 0);
          }
        else
          {
            u16 pause;

            /* Assert SRST for at least 25 us. */
            bios_ide_write_control (IDE_DEVCTL_NIEN | IDE_DEVCTL_SRST);
            for (pause = 0; pause != 0x0100; ++pause)
              bios_hw_pause ();

            /* Deassert SRST, wait at least 2 ms per ATA spec. */
            bios_ide_write_control (IDE_DEVCTL_NIEN);
            for (pause = 0; pause != 0x0400; ++pause)
              bios_hw_pause ();

            if (bios_ide_wait_not_busy ())
              bios_ide_complete (regs, FLOPPY_ST_OK, 0);
            else
              bios_ide_complete (regs, FLOPPY_ST_RESET_FAILED, 0);
          }
      }
      break;

    case 0x01:
      bios_set_hi (&regs->ax, bios_bda_read8 (BDA_HARD_DISK_STATUS));
      if (bios_bda_read8 (BDA_HARD_DISK_STATUS) == FLOPPY_ST_OK)
        bios_clear_cf (regs);
      else
        bios_set_cf (regs);
      break;

    case 0x02:
      bios_ide_transfer (regs, IDE_CMD_READ_SECTORS);
      break;

    case 0x03:
      bios_ide_transfer (regs, IDE_CMD_WRITE_SECTORS);
      break;

    case 0x04:
      bios_ide_verify (regs);
      break;

    case 0x08:
      bios_ide_get_parameters (regs);
      break;

    case 0x09:
    case 0x0C:
    case 0x10:
    case 0x11:
      bios_ide_simple_status (regs);
      break;

    case 0x15:
      bios_ide_drive_type (regs);
      break;

    case 0x41:
      bios_ide_edd_install_check (regs);
      break;

    case 0x42:
      bios_ide_edd_transfer (regs, IDE_CMD_READ_SECTORS);
      break;

    case 0x43:
      bios_ide_edd_transfer (regs, IDE_CMD_WRITE_SECTORS);
      break;

    case 0x44:
      bios_ide_edd_verify (regs);
      break;

    case 0x47:
      bios_ide_edd_seek (regs);
      break;

    case 0x48:
      bios_ide_edd_get_parameters (regs);
      break;

    default:
      bios_ide_complete (regs, FLOPPY_ST_BAD_COMMAND, 0);
      break;
    }
}