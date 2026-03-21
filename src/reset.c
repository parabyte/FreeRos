#include "bios.h"

/*
 * The reset vector is now in the ROM stub (romstub.asm).
 * The .reset section is discarded from the payload build.
 *
 * bios_reset_entry is the first code in the decompressed payload at
 * BIOS_ROM_SEGMENT.  The ROM stub decompresses the payload there
 * and far-jumps here.  The ia16 compiler mixes DS-relative and
 * SS-relative accesses for near data, so the shadowed BIOS stack must
 * live in the same segment as the decompressed payload.  Keep SS, DS,
 * and ES all pointing at BIOS_ROM_SEGMENT so both string literals and
 * stack-built text buffers render correctly during POST.
 */

void __far __attribute__((section (".start"), noinline, used))
bios_reset_entry (void)
{
  asm volatile ("cli\n\t"
		"mov %0, %%ax\n\t"
		"mov %%ax, %%ss\n\t"
		"mov %1, %%sp\n\t"
		"mov %%ax, %%ds\n\t"
		"mov %%ax, %%es\n\t"
		"cld\n\t" "jmp bios_main"::"i"(BIOS_ROM_SEGMENT),
		"i"(BIOS_STACK_OFFSET):"ax", "memory");
}
