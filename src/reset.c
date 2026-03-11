#include "bios.h"

/*
 * C cannot express the raw reset-vector control transfer directly, so the
 * final 16 bytes are described as ROM data here. The far jump matches the
 * 32 KiB layout at 0xF8000 and lands in the C entry point.
 */
__attribute__ ((used, section (".reset")))
const u8 bios_reset_vector[16] = {
  0xEA,
  0x00,
  0x00,
  (u8) (BIOS_ROM_SEGMENT & 0x00FF),
  (u8) ((BIOS_ROM_SEGMENT >> 8) & 0x00FF),
  0xFF, 0xFF, 0xFF, 0xFF,
  0xFF, 0xFF, 0xFF, 0xFF,
  0xFF, 0xFF, 0xFF
};

void __far __attribute__ ((section (".start"), noinline, used))
bios_reset_entry (void)
{
  asm volatile ("cli\n\t"
                "xor %%ax, %%ax\n\t"
                "mov %%ax, %%ss\n\t"
                "mov $0x7000, %%sp\n\t"
                "mov $0xF800, %%ax\n\t"
                "mov %%ax, %%ds\n\t"
                "mov %%ax, %%es\n\t"
                "cld\n\t"
                "jmp bios_main"
                :
                :
                : "ax", "memory");
}
