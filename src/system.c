/* ================================================
 * FreeRos BIOS
 * system.c: Equipment word and system service routines
 * ================================================ */

#include "bios.h"
#include "machine.h"

/* ================================================
 * Defines
 * ================================================ */

#define BIOS_EQUIP_BOOT_FLOPPY 0x0001
#define BIOS_EQUIP_MATH_COPROCESSOR 0x0002
#define BIOS_EQUIP_VIDEO_SHIFT 4
#define BIOS_EQUIP_FLOPPY_SHIFT 6
#define BIOS_EQUIP_SERIAL_SHIFT 9
#define BIOS_EQUIP_PRINTER_SHIFT 14

#define BIOS_EQUIP_VIDEO_EGA_ADAPTER 0x0000
#define BIOS_EQUIP_VIDEO_40X25_COLOR 0x0001
#define BIOS_EQUIP_VIDEO_80X25_COLOR 0x0002
#define BIOS_EQUIP_VIDEO_MONO 0x0003

#define BIOS_INT15_UNSUPPORTED 0x86

/* ================================================
 * Private helpers
 * ================================================ */

static u16 bios_equipment_video_bits (void);

u8
bios_default_text_mode (void)
{
  return machine_default_text_mode ();
}

u8
bios_build_status1 (void)
{
  return machine_build_status1 ();
}

u8
bios_build_status2 (void)
{
  return machine_build_status2 ();
}

u8
bios_build_video_switches (void)
{
  return machine_build_video_switches ();
}

static u16
bios_count_serial_ports (void)
{
  u16 count;

  count = 0;
  if (BIOS_CFG_COM1_BASE != 0)
    count++;
  if (BIOS_CFG_COM2_BASE != 0)
    count++;
  return count;
}

static u16
bios_count_parallel_ports (void)
{
  u16 count;

  count = 0;
  if (BIOS_CFG_LPT1_BASE != 0)
    count++;
  if (BIOS_CFG_LPT2_BASE != 0)
    count++;
  return count;
}

static u16
bios_equipment_video_bits (void)
{
  return machine_equipment_video_bits ();
}

static void
bios_int15_complete_unsupported (bios_regs_t __far *regs)
{
  bios_set_hi (&regs->ax, BIOS_INT15_UNSUPPORTED);
  bios_set_cf (regs);
}

/* ================================================
 * Equipment word
 * ================================================ */

u16
bios_build_equipment_word (void)
{
  u16 equipment;
  u16 floppy_drives;
  u16 serial_ports;
  u16 parallel_ports;

  equipment = machine_equipment_base_bits ();

  if (BIOS_CFG_FLOPPY_DRIVES != 0)
    {
      floppy_drives = (u16) (BIOS_CFG_FLOPPY_DRIVES - 1);
      equipment |= BIOS_EQUIP_BOOT_FLOPPY;
      equipment |=
	(u16) ((floppy_drives & 0x0003U) << BIOS_EQUIP_FLOPPY_SHIFT);
    }

  if (BIOS_CFG_HAS_MATH_COPROCESSOR)
    equipment |= BIOS_EQUIP_MATH_COPROCESSOR;

  equipment |= (u16) ((bios_equipment_video_bits () & 0x0003U)
		      << BIOS_EQUIP_VIDEO_SHIFT);

  serial_ports = bios_count_serial_ports ();
  parallel_ports = bios_count_parallel_ports ();
  equipment |= (u16) ((serial_ports & 0x0007U) << BIOS_EQUIP_SERIAL_SHIFT);
  equipment |= (u16) ((parallel_ports & 0x0003U) << BIOS_EQUIP_PRINTER_SHIFT);

  return equipment;
}

/* ================================================
 * Interrupt service handlers
 * ================================================ */

void
bios_service_int11 (bios_regs_t __far *regs)
{
  regs->ax = bios_bda_read16 (BDA_EQUIPMENT_WORD);
}

void
bios_service_int12 (bios_regs_t __far *regs)
{
  regs->ax = bios_bda_read16 (BDA_MEMORY_SIZE_KB);
}

void
bios_service_int15 (bios_regs_t __far *regs)
{
  if (!machine_int15_extensions (regs))
    bios_int15_complete_unsupported (regs);
}

/* ================================================
 * Boot failure and NMI
 * ================================================ */

void
bios_boot_failure (void)
{
  bios_work_write8 (WK_BOOT_FLAGS,
		    (u8) (bios_work_read8 (WK_BOOT_FLAGS) |
			  BOOT_FLAG_BOOT_FAILED));

  bios_video_set_attribute (0x07);
#if BIOS_CFG_MODE_ELKS
  bios_video_puts ("No bootable device.\r\n");
  bios_hw_disable_interrupts ();
  for (;;)
    bios_hw_halt ();
#else
  /*
   * Retry INT 19h on a timer cadence.  INT 16h AH=00 after a failed boot
   * blocks forever with no key — headless runs never retried the floppy.
   */
  for (;;)
    {
      bios_video_puts (bios_str_en_insert_system_disk);
      bios_video_puts ("\r\n");
      bios_invoke_int19 ();
      bios_wait_timer_ticks (55);
    }
#endif
}

void
bios_nmi_handler (void)
{
  bios_hw_out8 (0xFF, 0x03FC);
  bios_video_puts ("\r\n");
  bios_video_puts (bios_str_en_error_prefix);
  bios_video_puts (": ");
  bios_video_puts (bios_str_en_memory_parity);
  bios_video_puts ("\r\n");

  for (;;)
    {
    }
}
