import argparse
import subprocess
from pathlib import Path


ROS_VIDEO_INT10_COMPAT_ROM_OFFSET = 0x3065
JMP_FAR_OPCODE = 0xEA


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--nm", required=True)
    parser.add_argument("--elf", required=True)
    parser.add_argument("--rom", required=True)
    parser.add_argument("--segment", required=True)
    return parser.parse_args()


def symbol_offset(nm_path: str, elf_path: str, symbol: str) -> int:
    output = subprocess.check_output([nm_path, "-an", elf_path], text=True)
    for line in output.splitlines():
        parts = line.split()
        if len(parts) >= 3 and parts[2] == symbol:
            return int(parts[0], 16) & 0xFFFF
    raise SystemExit(f"symbol not found: {symbol}")


def first_symbol_offset(nm_path: str, elf_path: str, symbols: tuple[str, ...]) -> int:
    for symbol in symbols:
        try:
            return symbol_offset(nm_path, elf_path, symbol)
        except SystemExit:
            pass
    raise SystemExit(f"symbol not found: {', '.join(symbols)}")


def far_jump(segment: int, offset: int) -> bytes:
    return bytes((
        JMP_FAR_OPCODE,
        offset & 0xFF,
        (offset >> 8) & 0xFF,
        segment & 0xFF,
        (segment >> 8) & 0xFF,
    ))


def main() -> int:
    args = parse_args()
    rom_path = Path(args.rom)
    rom = bytearray(rom_path.read_bytes())
    segment = int(args.segment, 0)
    int10_wrapper_off = first_symbol_offset(
        args.nm,
        args.elf,
        (
            "bios_int10_wrapper",
            "bios_int42_wrapper",
        ),
    )
    rom[ROS_VIDEO_INT10_COMPAT_ROM_OFFSET:
        ROS_VIDEO_INT10_COMPAT_ROM_OFFSET + 5] = far_jump(segment,
                                                          int10_wrapper_off)
    rom_path.write_bytes(rom)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
