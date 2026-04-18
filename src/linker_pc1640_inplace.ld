MEMORY
{
  ROM_LO   (rx) : ORIGIN = 0x0000, LENGTH = 0x3065
  ROM_HOLE (rx) : ORIGIN = 0x3065, LENGTH = 0x0005
  ROM_HI   (rx) : ORIGIN = 0x306A, LENGTH = 0x0F86
}

SECTIONS
{
  . = ORIGIN(ROM_LO);

  .text.low :
  {
    KEEP(*(.start))
    *(EXCLUDE_FILE (*rtc.o *machine_pc1640dd.o) .text*)
  } > ROM_LO

  /* Keep the IVT patch list in ROM_LO: it is small and must not land in the
   * 0x3065 compat hole. Remaining .rodata goes to ROM_HI (ROM_LO is too small).
   */
  .rodata.ivt : { *ivt.o(.rodata*) } > ROM_LO

  /*
   * PC1640 splits the motherboard ROS around the 0x3065 compat jump hole.
   * Keep as much of the packed XTIDE blob as possible in ROM_LO and spill the
   * tail into ROM_HI; the runtime loader stitches both chunks back together in
   * RAM before invoking the Exomizer depacker.
   */
  .rodata.xtide_payload_lo :
  {
    *xtide_compressed.o(.rodata.xtide_embedded_payload_lo)
  } > ROM_LO

  .compat_jump ORIGIN(ROM_HOLE) :
  {
    BYTE(0xEA)
    BYTE(0x00)
    BYTE(0x00)
    BYTE(0x00)
    BYTE(0x00)
  } > ROM_HOLE

  .text.high :
  {
    *(.htext*)
    *rtc.o(.text*)
    *machine_pc1640dd.o(.text*)
  } > ROM_HI

  .rodata.xtide_payload_hi :
  {
    *xtide_compressed.o(.rodata.xtide_embedded_payload_hi)
  } > ROM_HI

  .rodata :
  {
    *(EXCLUDE_FILE (*video_pega_font_en.o *ivt.o *xtide_compressed.o) .rodata*)
    *xtide_compressed.o(.rodata*)
  } > ROM_HI

  .rodata.pega_font :
  {
    *video_pega_font_en.o(.rodata*)
  } > ROM_HI

  .iplt :
  {
    *(.iplt)
  } > ROM_HI

  .data :
  {
    *(.data*)
  } > ROM_HI

  .bss (NOLOAD) :
  {
    __bss_start = .;
    *(.bss*)
    *(COMMON)
    __bss_end = .;
  } > ROM_HI

  /DISCARD/ : { *(.note*) *(.comment*) *(.msdos_mz_reloc*) *(.reset) }
}
