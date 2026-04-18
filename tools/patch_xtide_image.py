#!/usr/bin/env python3

from __future__ import annotations

import argparse
from pathlib import Path


ROMVARS_BROMSIZE = 0x02
ROMVARS_WFLAGS = 0x44
ROMVARS_WDISPLAYMODE = 0x46
ROMVARS_WBOOTTIMEOUT = 0x48
ROMVARS_BIDECNT = 0x4C
ROMVARS_BBOOTDRV = 0x4D
ROMVARS_BMINFDDCNT = 0x4E
ROMVARS_BSTEALSIZE = 0x4F
ROMVARS_BIDLETIMEOUT = 0x50
ROMVARS_IDEVARS0 = 0x51

IDEVARS_WBASEPORT = 0x00
IDEVARS_WCONTROLPORT = 0x02
IDEVARS_MASTER_FLAGS = 0x06
IDEVARS_SLAVE_FLAGS = 0x0C
IDEVARS_SIZE = 0x12

DRVPARAMS_WFLAGS = 0x00
DRVPARAMS_DWMAXLBA = 0x02
DRVPARAMS_WCYLINDERS = 0x02
DRVPARAMS_BHEADS = 0x04
DRVPARAMS_BSECT = 0x05

XTIDE_CONTROL_BLOCK_OFFSET = 0x08

FLG_ROMVARS_FULLMODE = 1 << 0
FLG_ROMVARS_CLEAR_BDA_HD_COUNT = 1 << 1
FLG_ROMVARS_SERIAL_SCANDETECT = 1 << 3

MASK_DRVPARAMS_WRITECACHE = 0x03
WRITE_CACHE_DEFAULT = 0
WRITE_CACHE_DISABLE = 1
WRITE_CACHE_ENABLE = 2
TRANSLATEMODE_FIELD_POSITION = 2
TRANSLATEMODE_NORMAL = 0
TRANSLATEMODE_LARGE = 1
TRANSLATEMODE_ASSISTED_LBA = 2
TRANSLATEMODE_AUTO = 3
MASK_DRVPARAMS_TRANSLATEMODE = 0x03 << TRANSLATEMODE_FIELD_POSITION
FLG_DRVPARAMS_BLOCKMODE = 1 << 4
FLG_DRVPARAMS_USERCHS = 1 << 5
FLG_DRVPARAMS_USERLBA = 1 << 6
FLG_DRVPARAMS_DO_NOT_DETECT = 1 << 7


def parse_bool(value: str) -> bool:
    lowered = value.lower()
    if lowered in {"y", "yes", "1", "true"}:
        return True
    if lowered in {"n", "no", "0", "false"}:
        return False
    raise argparse.ArgumentTypeError(f"invalid boolean value: {value}")


def parse_translation_mode(value: str) -> int:
    lowered = value.lower()
    mapping = {
        "0": TRANSLATEMODE_NORMAL,
        "normal": TRANSLATEMODE_NORMAL,
        "1": TRANSLATEMODE_LARGE,
        "large": TRANSLATEMODE_LARGE,
        "2": TRANSLATEMODE_ASSISTED_LBA,
        "assisted-lba": TRANSLATEMODE_ASSISTED_LBA,
        "assisted_lba": TRANSLATEMODE_ASSISTED_LBA,
        "lba": TRANSLATEMODE_ASSISTED_LBA,
        "3": TRANSLATEMODE_AUTO,
        "auto": TRANSLATEMODE_AUTO,
    }
    if lowered in mapping:
        return mapping[lowered]
    raise argparse.ArgumentTypeError(f"invalid translation mode: {value}")


def parse_write_cache(value: str) -> int:
    lowered = value.lower()
    mapping = {
        "0": WRITE_CACHE_DEFAULT,
        "default": WRITE_CACHE_DEFAULT,
        "1": WRITE_CACHE_DISABLE,
        "disable": WRITE_CACHE_DISABLE,
        "disabled": WRITE_CACHE_DISABLE,
        "2": WRITE_CACHE_ENABLE,
        "enable": WRITE_CACHE_ENABLE,
        "enabled": WRITE_CACHE_ENABLE,
    }
    if lowered in mapping:
        return mapping[lowered]
    raise argparse.ArgumentTypeError(f"invalid write-cache mode: {value}")


def store_u16(image: bytearray, offset: int, value: int) -> None:
    image[offset:offset + 2] = value.to_bytes(2, "little")


def store_u32(image: bytearray, offset: int, value: int) -> None:
    image[offset:offset + 4] = value.to_bytes(4, "little")


def patch_drive(
    image: bytearray,
    idevars_offset: int,
    drive_offset: int,
    *,
    probe: bool,
    block_mode: bool,
    translation_mode: int,
    write_cache: int,
    user_chs: bool,
    cylinders: int,
    heads: int,
    sectors: int,
    user_lba: bool,
    max_lba: int,
) -> None:
    flags = image[idevars_offset + drive_offset + DRVPARAMS_WFLAGS]
    flags &= ~(MASK_DRVPARAMS_WRITECACHE
               | MASK_DRVPARAMS_TRANSLATEMODE
               | FLG_DRVPARAMS_BLOCKMODE
               | FLG_DRVPARAMS_DO_NOT_DETECT
               | FLG_DRVPARAMS_USERCHS
               | FLG_DRVPARAMS_USERLBA)
    flags |= write_cache
    flags |= translation_mode << TRANSLATEMODE_FIELD_POSITION
    if block_mode:
        flags |= FLG_DRVPARAMS_BLOCKMODE
    if not probe:
        flags |= FLG_DRVPARAMS_DO_NOT_DETECT
    if user_chs:
        flags |= FLG_DRVPARAMS_USERCHS
    if user_lba:
        flags |= FLG_DRVPARAMS_USERLBA

    store_u16(image, idevars_offset + drive_offset + DRVPARAMS_WFLAGS, flags)

    data_offset = idevars_offset + drive_offset + DRVPARAMS_DWMAXLBA
    if user_lba:
        store_u32(image, data_offset, max_lba)
    elif user_chs:
        store_u16(image, idevars_offset + drive_offset + DRVPARAMS_WCYLINDERS, cylinders)
        image[idevars_offset + drive_offset + DRVPARAMS_BHEADS] = heads & 0xFF
        image[idevars_offset + drive_offset + DRVPARAMS_BSECT] = sectors & 0xFF
    else:
        store_u32(image, data_offset, 0)


def checksum_rom(image: bytearray) -> None:
    checksum = sum(image) & 0xFF
    image[-1] = (image[-1] - checksum) & 0xFF
    assert (sum(image) & 0xFF) == 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Patch XTIDE ROMVARS and finalize the option ROM image")
    parser.add_argument("--input", required=True, help="input XTIDE raw binary")
    parser.add_argument("--output", required=True, help="output checksummed option ROM")
    parser.add_argument("--rom-size", required=True, type=int, help="final ROM size in bytes")
    parser.add_argument("--base", required=True, type=lambda s: int(s, 0), help="XTIDE I/O base")
    parser.add_argument("--probe-master", required=True, type=parse_bool)
    parser.add_argument("--probe-slave", required=True, type=parse_bool)
    parser.add_argument("--full-mode", required=True, type=parse_bool)
    parser.add_argument("--steal-size", required=True, type=int)
    parser.add_argument("--clear-bda-hd-count", required=True, type=parse_bool)
    parser.add_argument("--serial-scan-detect", required=True, type=parse_bool)
    parser.add_argument("--display-mode", required=True, type=lambda s: int(s, 0))
    parser.add_argument("--boot-timeout", required=True, type=int)
    parser.add_argument("--boot-drive", required=True, type=lambda s: int(s, 0))
    parser.add_argument("--min-floppy-count", required=True, type=int)
    parser.add_argument("--idle-timeout", required=True, type=int)
    parser.add_argument("--master-block-mode", required=True, type=parse_bool)
    parser.add_argument("--slave-block-mode", required=True, type=parse_bool)
    parser.add_argument("--master-translation", required=True, type=parse_translation_mode)
    parser.add_argument("--slave-translation", required=True, type=parse_translation_mode)
    parser.add_argument("--master-write-cache", required=True, type=parse_write_cache)
    parser.add_argument("--slave-write-cache", required=True, type=parse_write_cache)
    parser.add_argument("--master-user-chs", required=True, type=parse_bool)
    parser.add_argument("--slave-user-chs", required=True, type=parse_bool)
    parser.add_argument("--master-cylinders", required=True, type=int)
    parser.add_argument("--slave-cylinders", required=True, type=int)
    parser.add_argument("--master-heads", required=True, type=int)
    parser.add_argument("--slave-heads", required=True, type=int)
    parser.add_argument("--master-sectors", required=True, type=int)
    parser.add_argument("--slave-sectors", required=True, type=int)
    parser.add_argument("--master-user-lba", required=True, type=parse_bool)
    parser.add_argument("--slave-user-lba", required=True, type=parse_bool)
    parser.add_argument("--master-max-lba", required=True, type=lambda s: int(s, 0))
    parser.add_argument("--slave-max-lba", required=True, type=lambda s: int(s, 0))
    args = parser.parse_args()

    if args.rom_size < 4096 or (args.rom_size % 2048) != 0:
        raise SystemExit("XTIDE ROM size must be a multiple of 2048 bytes and at least 4096")
    if args.base < 0x0200 or args.base > 0x03F0 or (args.base & 0x000F):
        raise SystemExit("XTIDE base port must be 16-byte aligned and within 0x0200-0x03F0")
    if not args.probe_master and not args.probe_slave:
        raise SystemExit("XTIDE must probe at least one device")
    if args.steal_size < 0 or args.steal_size > 255:
        raise SystemExit("XTIDE steal size must be in 0..255 KiB")
    if args.boot_timeout < 0 or args.boot_timeout > 0xFFFF:
        raise SystemExit("XTIDE boot timeout must be in 0..65535 ticks")
    if args.boot_drive < 0 or args.boot_drive > 0xFF:
        raise SystemExit("XTIDE boot drive must be in 0x00..0xFF")
    if args.min_floppy_count < 0 or args.min_floppy_count > 4:
        raise SystemExit("XTIDE minimum floppy count must be in 0..4")
    if args.idle_timeout < 0 or args.idle_timeout > 244:
        raise SystemExit("XTIDE idle timeout must be in 0..244")

    image = bytearray(Path(args.input).read_bytes())
    if len(image) > args.rom_size:
        raise SystemExit(
            f"XTIDE raw image is {len(image)} bytes but target ROM size is only {args.rom_size} bytes"
        )

    image[ROMVARS_BROMSIZE] = args.rom_size // 512

    rom_flags = image[ROMVARS_WFLAGS] | (image[ROMVARS_WFLAGS + 1] << 8)
    if args.full_mode:
        rom_flags |= FLG_ROMVARS_FULLMODE
    else:
        rom_flags &= ~FLG_ROMVARS_FULLMODE
    if args.clear_bda_hd_count:
        rom_flags |= FLG_ROMVARS_CLEAR_BDA_HD_COUNT
    else:
        rom_flags &= ~FLG_ROMVARS_CLEAR_BDA_HD_COUNT
    if args.serial_scan_detect:
        rom_flags |= FLG_ROMVARS_SERIAL_SCANDETECT
    else:
        rom_flags &= ~FLG_ROMVARS_SERIAL_SCANDETECT
    image[ROMVARS_WFLAGS] = rom_flags & 0xFF
    image[ROMVARS_WFLAGS + 1] = (rom_flags >> 8) & 0xFF

    store_u16(image, ROMVARS_WDISPLAYMODE, args.display_mode)
    store_u16(image, ROMVARS_WBOOTTIMEOUT, args.boot_timeout)
    image[ROMVARS_BIDECNT] = 1
    image[ROMVARS_BBOOTDRV] = args.boot_drive & 0xFF
    image[ROMVARS_BMINFDDCNT] = args.min_floppy_count & 0xFF
    image[ROMVARS_BSTEALSIZE] = args.steal_size & 0xFF
    image[ROMVARS_BIDLETIMEOUT] = args.idle_timeout & 0xFF

    control = args.base + XTIDE_CONTROL_BLOCK_OFFSET
    base_offset = ROMVARS_IDEVARS0 + IDEVARS_WBASEPORT
    ctrl_offset = ROMVARS_IDEVARS0 + IDEVARS_WCONTROLPORT
    image[base_offset:base_offset + 2] = args.base.to_bytes(2, "little")
    image[ctrl_offset:ctrl_offset + 2] = control.to_bytes(2, "little")

    if args.master_user_chs and args.master_user_lba:
        raise SystemExit("XTIDE master drive cannot force both user CHS and user LBA")
    if args.slave_user_chs and args.slave_user_lba:
        raise SystemExit("XTIDE slave drive cannot force both user CHS and user LBA")
    if args.master_user_chs and not (1 <= args.master_cylinders <= 16383):
        raise SystemExit("XTIDE master cylinders must be in 1..16383")
    if args.slave_user_chs and not (1 <= args.slave_cylinders <= 16383):
        raise SystemExit("XTIDE slave cylinders must be in 1..16383")
    if args.master_user_chs and not (1 <= args.master_heads <= 16):
        raise SystemExit("XTIDE master heads must be in 1..16")
    if args.slave_user_chs and not (1 <= args.slave_heads <= 16):
        raise SystemExit("XTIDE slave heads must be in 1..16")
    if args.master_user_chs and not (1 <= args.master_sectors <= 63):
        raise SystemExit("XTIDE master sectors must be in 1..63")
    if args.slave_user_chs and not (1 <= args.slave_sectors <= 63):
        raise SystemExit("XTIDE slave sectors must be in 1..63")
    if args.master_user_lba and not (0 < args.master_max_lba <= 0x0FFFFFFF):
        raise SystemExit("XTIDE master max LBA must be in 1..0x0FFFFFFF")
    if args.slave_user_lba and not (0 < args.slave_max_lba <= 0x0FFFFFFF):
        raise SystemExit("XTIDE slave max LBA must be in 1..0x0FFFFFFF")

    patch_drive(
        image,
        ROMVARS_IDEVARS0,
        IDEVARS_MASTER_FLAGS,
        probe=args.probe_master,
        block_mode=args.master_block_mode,
        translation_mode=args.master_translation,
        write_cache=args.master_write_cache,
        user_chs=args.master_user_chs,
        cylinders=args.master_cylinders,
        heads=args.master_heads,
        sectors=args.master_sectors,
        user_lba=args.master_user_lba,
        max_lba=args.master_max_lba,
    )
    patch_drive(
        image,
        ROMVARS_IDEVARS0,
        IDEVARS_SLAVE_FLAGS,
        probe=args.probe_slave,
        block_mode=args.slave_block_mode,
        translation_mode=args.slave_translation,
        write_cache=args.slave_write_cache,
        user_chs=args.slave_user_chs,
        cylinders=args.slave_cylinders,
        heads=args.slave_heads,
        sectors=args.slave_sectors,
        user_lba=args.slave_user_lba,
        max_lba=args.slave_max_lba,
    )

    if len(image) < args.rom_size:
        image.extend(b"\x00" * (args.rom_size - len(image)))

    checksum_rom(image)
    Path(args.output).write_bytes(image)

    print(
        "XTIDE:",
        f"size={args.rom_size}",
        f"base=0x{args.base:04x}",
        f"ctrl=0x{control:04x}",
        f"master={'on' if args.probe_master else 'off'}",
        f"slave={'on' if args.probe_slave else 'off'}",
        f"mode={'full' if args.full_mode else 'lite'}",
        f"master_translation={args.master_translation}",
        f"slave_translation={args.slave_translation}",
        f"boot_drive=0x{args.boot_drive:02x}",
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
