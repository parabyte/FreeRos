MEMORY
{
  ROM (rx) : ORIGIN = 0x0000, LENGTH = 32K
}

SECTIONS
{
  . = ORIGIN(ROM);

  .start :
  {
    KEEP(*(.start))
  } > ROM

  .text :
  {
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
    *(.bss*)
    *(COMMON)
  } > ROM

  /* Place the reset-vector bytes in the final 16 bytes of the ROM image. */
  .reset ORIGIN(ROM) + LENGTH(ROM) - 16 :
  {
    KEEP(*(.reset))
  } > ROM

  /DISCARD/ : { *(.note*) *(.comment*) }
}
