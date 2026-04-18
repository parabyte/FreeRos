/* ================================================
 * FreeRos BIOS
 * xtide_compressed.c: Exomizer-packed XTIDE in motherboard ROM -> RAM unpack
 * ================================================ */

#include "bios.h"

#if BIOS_CFG_XTIDE_ENABLED && BIOS_CFG_XTIDE_EMBEDDED_IN_ROS

#include "xtide_embedded_payload.h"

#ifndef BIOS_CFG_XTIDE_EMBEDDED_ROM_SIZE
#error "BIOS_CFG_XTIDE_EMBEDDED_ROM_SIZE must be defined by the build"
#endif

#define XTIDE_EXO_TABLE_BYTES 0x0100U

extern void __attribute__((stdcall))
bios_xtide_exo_decompress (u16 dest_seg, u16 input_off, u16 table_off);

static void
bios_xtide_publish_base_memory_kb (u16 mem_kb)
{
  bios_bda_write16 (BDA_MEMORY_SIZE_KB, mem_kb);
  bios_bda_write16 (BDA_EXTRA_MEMORY_KB,
                    mem_kb > 64U ? (u16) (mem_kb - 64U) : 0U);
}

static void
bios_xtide_copy_resident_rom (u16 src_seg, u16 dst_seg)
{
  u16 off;

  off = (u16) BIOS_CFG_XTIDE_EMBEDDED_ROM_SIZE;
  while (off != 0)
    {
      off--;
      bios_abs_write8 (dst_seg, off, bios_abs_read8 (src_seg, off));
    }
}

void
bios_xtide_embedded_ram_init (void)
{
  u16 mem_kb;
  u16 scratch_kb;
  u16 resident_kb;
  u16 scratch_seg;
  u16 resident_seg;
  u16 input_off;
  u16 table_off;
  u16 total_bytes;
  u16 i;

  input_off = (u16) BIOS_CFG_XTIDE_EMBEDDED_ROM_SIZE;
  /* Exomizer P47 indexes the decode table through BL and expects the table
   * base to be 256-byte aligned so BL starts at 0x00.
   */
  table_off = (u16) ((input_off + XTIDE_EMBEDDED_PAYLOAD_SIZE + 0x00FFU)
		     & ~0x00FFU);
  total_bytes = (u16) (table_off + XTIDE_EXO_TABLE_BYTES);

  scratch_kb = (u16) ((total_bytes + 1023U) / 1024U);
  if (scratch_kb == 0)
    scratch_kb = 1;
  resident_kb = (u16) ((((u16) BIOS_CFG_XTIDE_EMBEDDED_ROM_SIZE) + 1023U)
                       / 1024U);

  mem_kb = bios_bda_read16 (BDA_MEMORY_SIZE_KB);
  if ((u32) mem_kb < (u32) scratch_kb + 64U)
    {
      bios_serial_debug_puts ("XTIDE: RAM\n");
      return;
    }

  scratch_seg = (u16) ((u32) (mem_kb - scratch_kb) << 6);
  resident_seg = (u16) ((u32) (mem_kb - resident_kb) << 6);

#if XTIDE_EMBEDDED_PAYLOAD_LO_SIZE
  for (i = 0; i < (u16) XTIDE_EMBEDDED_PAYLOAD_LO_SIZE; ++i)
    bios_abs_write8 (scratch_seg, (u16) (input_off + i),
                     xtide_embedded_payload_lo[i]);
#endif
#if XTIDE_EMBEDDED_PAYLOAD_HI_SIZE
  for (i = 0; i < (u16) XTIDE_EMBEDDED_PAYLOAD_HI_SIZE; ++i)
    bios_abs_write8 (
      scratch_seg,
      (u16) (input_off + XTIDE_EMBEDDED_PAYLOAD_LO_SIZE + i),
      xtide_embedded_payload_hi[i]);
#endif

  bios_xtide_exo_decompress (scratch_seg, input_off, table_off);

  /*
   * Keep the resident XTIDE image in the topmost 4 KiB/8 KiB conventional-RAM
   * window and reclaim the lower decompressor scratch window before entering
   * the option ROM. This is leaner and matches the XT convention of stealing
   * only the persistent resident block from base memory.
   */
  if (resident_seg != scratch_seg)
    bios_xtide_copy_resident_rom (scratch_seg, resident_seg);

  bios_xtide_publish_base_memory_kb ((u16) (mem_kb - resident_kb));

  bios_serial_debug_puts ("XTIDE: RAM ");
  bios_serial_debug_put_hex16 (resident_seg);
  bios_serial_debug_putc ('\n');

  bios_option_rom_enter (resident_seg);
}

#endif /* BIOS_CFG_XTIDE_ENABLED && BIOS_CFG_XTIDE_EMBEDDED_IN_ROS */
