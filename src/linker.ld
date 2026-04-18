MEMORY
{
  ROM (rx) : ORIGIN = 0x0000, LENGTH = 32K
}

SECTIONS
{
  . = ORIGIN(ROM);

  .text :
  {
    KEEP(*(.start))
    *(.text*)
  } > ROM

  .rodata :
  {
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
