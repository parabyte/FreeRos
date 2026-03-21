#include "bios.h"

#define BIOS_OPTION_ROM_SIGNATURE 0xAA55

static int
bios_option_rom_present (u16 segment)
{
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

static void
bios_option_rom_enter (u16 segment)
{
  bios_bda_write16 (BDA_IO_ROM_INIT_OFF, 0x0003);
  bios_bda_write16 (BDA_IO_ROM_INIT_SEG, segment);

  asm volatile ("push %%bp\n\t"
		"push %%ds\n\t"
		"push %%es\n\t"
		"cld\n\t"
		"mov %0, %%dx\n\t"
		"mov %%dx, %%ds\n\t"
		"mov $0x0040, %%ax\n\t"
		"mov %%ax, %%es\n\t"
		"push %%cs\n\t"
		"mov $1f, %%bx\n\t"
		"push %%bx\n\t"
		"push %%dx\n\t"
		"mov $0x0003, %%bx\n\t"
		"push %%bx\n\t"
		"retf\n\t"
		"1:\n\t"
		"pop %%es\n\t"
		"pop %%ds\n\t"
		"pop %%bp"::"rm" (segment):"ax", "bx", "cx", "dx", "si", "di",
		"memory", "cc");
}

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

      next_segment = (u16) (segment + scan_step);
      if (bios_option_rom_present (segment))
	{
	  u8 blocks;

	  blocks = bios_abs_read8 (segment, 0x0002);
	  next_segment = (u16) (segment + ((u16) blocks << 5));

	  if (bios_option_rom_checksum_valid (segment))
	    {
	      bios_serial_debug_puts ("ROM scan ok\n");
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
