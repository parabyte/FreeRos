FreeRos PC1640 Compatible BIOS
==============================

This repository contains the BIOS source tree and build system for the Amstrad
PC1640DD-compatible FreeRos BIOS.

Contact me for licensing details, do not use in commercial products, xtide code i am using is excempt from this clause

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
