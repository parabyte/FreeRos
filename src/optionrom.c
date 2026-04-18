/* ================================================
 * FreeRos BIOS
 * optionrom.c: Option ROM detection and execution
 * ================================================ */

#include "bios.h"

/* ================================================
 * Defines
 * ================================================ */

#define BIOS_OPTION_ROM_SIGNATURE 0xAA55
#define BIOS_OPTION_ROM_PC1640_VIDEO_INT10_OFF 0x1299

/* Plain assembly helper implemented in optionrom_entry.S. */
extern void bios_option_rom_enter_asm (u16 segment);

/* ================================================
 * Private helpers
 * ================================================ */

static int
bios_option_rom_present (u16 segment)
{
  /*
   * Motherboard ROM scan matches the conventional XT option-ROM test:
   * 55AAh signature at offset 0000h and a non-zero 512-byte block count at
   * offset 0002h.
   */
  return bios_abs_read16 (segment, 0x0000) == BIOS_OPTION_ROM_SIGNATURE
    && bios_abs_read8 (segment, 0x0002) != 0x00;
}

static int
bios_option_rom_checksum_valid (u16 segment)
{
  u8 blocks;
  u8 sum;
  u16 block;
  u16 offset;

  blocks = bios_abs_read8 (segment, 0x0002);
  if (blocks == 0)
    return 0;

  sum = 0;
  for (block = 0; block < blocks; ++block)
    {
      u16 block_segment;

      block_segment = (u16) (segment + (block << 5));
      for (offset = 0; offset != 0x0200; ++offset)
	sum = (u8) (sum + bios_abs_read8 (block_segment, offset));
    }

  return sum == 0;
}

void
bios_option_rom_enter (u16 segment)
{
  /*
   * Keep the BDA callback pointer in the same shape expected by adapter ROMs:
   * 0040:0067 = 0003h, 0040:0069 = segment. The far-return frame below then
   * enters segment:0003 with ES already loaded with the BDA segment.
   */
  bios_bda_write16 (BDA_IO_ROM_INIT_OFF, 0x0003);
  bios_bda_write16 (BDA_IO_ROM_INIT_SEG, segment);
  /*
   * The stock 40100 PEGA ROM issues INT 10h during its init path before it
   * patches IVT vector 10h itself. Seed the known 40100 handler target so the
   * nested calls land inside the adapter ROM instead of the motherboard stub.
   */
  if (segment == BIOS_CFG_VIDEO_OPTION_ROM_SEGMENT)
    {
      bios_abs_write16 (0x0000, (u16) 0x10 * 4U,
                        BIOS_OPTION_ROM_PC1640_VIDEO_INT10_OFF);
      bios_abs_write16 (0x0000, (u16) ((0x10 * 4U) + 2U), segment);
    }
  bios_serial_debug_putc ('>');
  bios_option_rom_enter_asm (segment);
  bios_serial_debug_putc ('<');
}

/* ================================================
 * Public ROM scan
 * ================================================ */

int
bios_option_rom_scan (u16 start_segment, u16 end_segment, u16 scan_step)
{
  u16 segment;
  int option_rom_called;

  if (scan_step == 0)
    return 0;

  segment = start_segment;
  option_rom_called = 0;

  while (segment < end_segment)
    {
      u16 next_segment;

      /*
       * Default advance uses the caller-provided scan stride. A valid ROM
       * header overrides that with the header's own block-count so the scan
       * walks exactly the installed images, just like the original XT-family
       * ROS code.
       */
      next_segment = (u16) (segment + scan_step);
      if (bios_option_rom_present (segment))
	{
	  u8 blocks;

	  blocks = bios_abs_read8 (segment, 0x0002);
	  next_segment = (u16) (segment + ((u16) blocks << 5));

	  if (bios_option_rom_checksum_valid (segment))
	    {
	      int run_init = 1;

	      /*
	       * PC1640 brings the onboard PEGA ROM up before the motherboard
	       * POST sweep reaches C000h.  The later scan should still walk over
	       * the image, but it must not enter it again or the adapter init
	       * sequence runs twice.
	       */
	      if (segment == BIOS_CFG_VIDEO_OPTION_ROM_SEGMENT)
		run_init = 0;
	      bios_serial_debug_puts ("ROM scan ok\n");
	      if (run_init)
		bios_option_rom_enter (segment);
	      option_rom_called = 1;
	    }
	  else
	    bios_serial_debug_puts ("ROM checksum bad\n");
	}

      if (next_segment <= segment)
	break;

      segment = next_segment;
    }

  return option_rom_called;
}
