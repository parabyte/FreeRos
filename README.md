New BIOS implementation (C-only, IA16)

Goal
- A clean-room C implementation of the PC1640 BIOS with behavioral fidelity.
- This project is not byte-identical to the original ROM and is not expected to match the original binary.

Important constraint
- The user requested no assembler. On real 8086 hardware, port I/O and reset-vector setup
  normally require instructions that standard C cannot emit without inline asm.
- This project therefore uses C-defined ROM data for the reset vector and a C-only port
  shadow model in `src/io.c`. It compiles into ROM images and preserves the firmware logic,
  but it is not yet a hardware-complete replacement for the original ROMs.

Layout
- include/     Public headers and device APIs.
- src/         BIOS implementation modules (PIC, PIT, keyboard, video, floppy, etc).
- tools/       Helpers (string extraction).
- build/       Output artifacts (ELF, ROM images).

Build
- Uses ia16-elf-gcc from /home/arduino/elks/cross/bin.
- Outputs:
  - build/bios.elf
  - build/bios.bin (32 KiB ROM image)
  - build/40043.v3 and build/40044.v3 (split ROMs)

Commands
- make
- make clean

Notes
- The ROM is linked as a 32 KiB in-socket image with offsets `0x0000..0x7FFF`; the
  motherboard maps that image at physical `0xF8000..0xFFFFF`.
- Reset vector placement: linker script places `.reset` at image offset `0x7FF0`,
  which corresponds to physical `0xFFFF0`.
- Port I/O: `src/io.c` models the Amstrad ports and CMOS state in C so the firmware
  logic can build without assembler.
- Strings: `tools/extract_strings.py` regenerates `src/bios_strings.inc` from the
  original decompiled ROM so the clean BIOS source keeps the original text corpus.
