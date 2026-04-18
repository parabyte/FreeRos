FreeRos PC1640 Compatible BIOS
==============================

This repository contains the BIOS source tree and build system for the Amstrad
PC1640DD-compatible FreeRos BIOS.

Scope
-----
- Includes BIOS source, configuration system, build scripts, and XTIDE source.
- Excludes test harnesses, emulator integrations, hidden files, and floppy or
  hard disk images.
- Keeps only the Exomizer-related build hook needed to compress payloads during
  the build plus the BIOS-side decompression code already used by the ROM.
- Builds Exomizer in a disposable temporary tree and retains only the local
  compressor binary plus a small version stamp under `build/exomizer-bin/`.

Prerequisites
-------------
- `ia16-elf-gcc` cross compiler
- `nasm`
- `python3`
- `ncurses` headers for `make menuconfig`
- `make`

Build
-----
```sh
make
```

The default build uses `config/profiles/pc1640_floppy_only.config`. To build a
different shipped profile, override `CONFIG_FILE`, for example:

```sh
make CONFIG_FILE=config/profiles/pc1640_ide_embedded.config
```

Primary outputs
---------------
- `build/bios.bin`
- `build/40043.v3`
- `build/40044.v3`
- `build/pega_video_32k.bin`
