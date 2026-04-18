/* Paradise PEGA standalone option ROM: linear image mapped at 0xC0000 (32 KiB). */
OUTPUT_FORMAT("elf32-i386", "elf32-i386", "elf32-i386")
OUTPUT_ARCH(i8086)
ENTRY(_start)

MEMORY
{
  /* VMA starts at 0 so 16-bit real-mode relocations fit; image is loaded at C000:0. */
  ROM (rwx) : ORIGIN = 0x0000, LENGTH = 0x8000
}

SECTIONS
{
  .text :
  {
    *(.pega_rom_header)
    *(.text*)
    *(.rodata*)
  } > ROM

  .data :
  {
    *(.data*)
  } > ROM

  .bss (NOLOAD) :
  {
    __bss_start = .;
    *(.bss*)
    *(COMMON)
    __bss_end = .;
  } > ROM

  /DISCARD/ : { *(.note*) *(.comment*) *(.msdos_mz_reloc*) *(.reset) }
}
