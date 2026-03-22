Permission is granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
to use, compile, modify, and make derivative works of the Software **for non-commercial purposes only**,
subject to the following conditions:

1. The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
2. The Software may not be sold, offered for sale, licensed for a fee, or used in any commercial product or service without explicit prior written permission from the copyright holder.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND

commercial purposes please contact me.

FreeRos PC1640 Compatible BIOS
==============================

A clean-room C implementation of the Amstrad PC1640 BIOS with behavioral fidelity.
This project is not byte-identical to the original ROM and is not expected to match
the original binary.

Implementation notes
--------------------
- The BIOS uses GNU-style IA-16 inline assembly where real 8086 instructions are
  required: reset entry, interrupt wrappers, port I/O, and boot transfer.
- Machine state that genuinely lives in RAM still has software mirrors in the
  BDA/private work area, but device access now goes through the real x86 I/O ports
  rather than a synthetic port shadow model.

Layout
------
- `src/`         BIOS implementation modules (PIC, PIT, keyboard, video, floppy, IDE, etc).
- `config/`      ELKS-style Kconfig build system (Configure, Menuconfig, lxdialog).
- `config.in`    Master configuration description (like Linux kernel `Kconfig`).
- `scripts/`     Build helpers (mkconfig.sh translates .config to C header + make fragment).
- `tools/`       ROM image tools, 86Box test harnesses, string extraction.
- `build/`       Output artifacts (ELF, ROM images, chip files).

Prerequisites
-------------
- **ia16-elf-gcc** cross compiler (expected at `/home/arduino/elks/cross/bin`).
- **nasm** assembler.
- **python3** (for ROM image tools and Exomizer bootstrap only).
- **ncurses** development headers (for `make menuconfig`).
- **GNU make**.

Quick start
-----------
```sh
make defconfig          # Generate default .config (stock PC1640 profile)
make                    # Build ROM image, chip files, and selftest image
```

Configuration
-------------
The build system uses an ELKS/Linux kernel-style Kconfig menu system.
Configuration is stored in `.config` and translated into `build/config_autogen.h`
(C defines) and `build/config.mk` (make variables) by `scripts/mkconfig.sh`.

```sh
make defconfig          # Restore stock PC1640 defaults
make config             # Text-mode line-by-line configuration
make menuconfig         # Interactive ncurses menu configuration
```

After running any configuration command, simply `make` to rebuild with the new
settings. The build system automatically detects `.config` changes and regenerates
the header and make fragment.

### Configuration sections

| Section              | Key options |
|----------------------|-------------|
| Machine Identity     | Brand name, website, ROS release/issue numbers |
| Hardware             | Base memory, Paradise PEGA1A, Amstrad mouse, RTC, math coprocessor |
| Peripheral Ports     | COM1/COM2/LPT1/LPT2 I/O base addresses |
| Video                | Fallback video equipment, text attribute, PC1640 switch block options |
| Option ROMs          | Video and non-video option ROM scanning |
| Floppy Disk          | Controller enable, drive types (360K/720K), INT 13h AH=08 compat |
| IDE Hard Disk (XTIDE)| XTIDE enable, I/O base, LBA translation, EDD extensions |
| RTC Defaults         | Default date/time when battery is dead |
| POST Options         | Pretty wait panel, Space Invaders sound effect |
| Debug                | Port E9, COM1 debug output, video state tracing |

Build targets
-------------
Run `make help` for a complete list. Key targets:

```
Configuration:
  defconfig      - Generate default .config
  config         - Text-mode configuration (like Linux "make config")
  menuconfig     - Ncurses menu configuration (like Linux "make menuconfig")

Build:
  all            - Build ROM image, chip files, and selftest (default)
  clean          - Remove build directory
  mrproper       - Remove build directory and .config

Testing (requires 86Box):
  86box-build    - Build 86Box debug version
  86box-run      - Run BIOS in 86Box with floppy image
  86box-selftest - Run self-test in headless 86Box
  86box-ide-smoke - Run IDE smoke test in 86Box
```

Build outputs
-------------
| File | Description |
|------|-------------|
| `build/bios.bin`    | 16 KiB ROM image (compressed payload + decompressor stub) |
| `build/bios.elf`    | ELF with debug symbols |
| `build/bios.map`    | Linker map file |
| `build/40044.v3`    | Even chip file (with mirror) |
| `build/40043.v3`    | Odd chip file (with mirror) |

The ROM is built in stages:
1. Compile all C sources to a single ELF
2. Extract raw binary payload (up to 32 KiB)
3. Compress with Exomizer (`-P47`) higher values seem to crash the decruncher. will look into that
4. Assemble NASM decompressor stub
5. Pack into 16 KiB ROM image with reset vector
6. Split into interleaved even/odd chip files

IDE support
-----------
Built-in XTIDE-compatible IDE driver provides INT 13h services for ATA hard drives
connected via an 8-bit ISA IDE controller. Supports:
- Legacy CHS addressing
- LBA28 with translated CHS geometry
- INT 13h extensions (EDD) for direct LBA access
- Boot from IDE when floppy boot fails (configurable)

The IDE driver is compatible with XTIDE ISA adapters using the standard 8-bit data
transfer protocol



PCem usage
----------
Built ROMs install directly as `build/40043.v3` and `build/40044.v3`.
For local debugging, copy those ROMs into `~/.pcem/roms/pc1640/`.

Default test media
------------------
- The stock 360 KiB smoke path uses `test_media/ibm_dos_330_disk1_360k.img`.
- The companion second disk is available as `test_media/ibm_dos_330_disk2_360k.img`.

Technical notes
---------------
- The ROM is linked as a 16 KiB in-socket image; the motherboard maps it at
  physical `0xFC000..0xFFFFF`.
- Reset vector placement: linker script places `.reset` at image offset `0x3FF0`,
  which corresponds to physical `0xFFFF0`.
- Port I/O: `src/io.c` and `src/bios_hw.h` drive the XT/PC1640 ports directly with
  GNU-style inline assembly.
- Strings: `tools/extract_strings.py` regenerates `src/bios_strings.inc` from the
  original decompiled ROM so the clean BIOS source keeps the original text corpus.
