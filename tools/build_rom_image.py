"""
Build the final target ROM image from the BIOS payload and, when needed, an
optional reset/copy stub.

The reset vector always occupies the last 16 bytes of the ROM image and jumps
to the ROM entry segment selected for the active machine target.
"""

import argparse
import sys
from pathlib import Path

DEFAULT_ROM_SIZE = 0x4000
DEFAULT_ENTRY_SEGMENT = 0xFC00


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("payload")
    parser.add_argument("output")
    parser.add_argument("--stub", default=None)
    parser.add_argument("--rom-size", default=hex(DEFAULT_ROM_SIZE))
    parser.add_argument("--entry-segment", default=hex(DEFAULT_ENTRY_SEGMENT))
    parser.add_argument("--machine-id-byte", default=None)
    parser.add_argument("--reserved-range", action="append", default=[],
                        help="ROM hole as offset:size, both in C/Python int syntax")
    return parser.parse_args()


def parse_int(text: str) -> int:
    return int(text, 0)


def parse_reserved_ranges(items: list[str]) -> list[tuple[int, int]]:
    ranges: list[tuple[int, int]] = []
    for item in items:
        offset_text, size_text = item.split(":", 1)
        ranges.append((parse_int(offset_text), parse_int(size_text)))
    return ranges


def build_reset_vector(entry_segment: int) -> bytes:
    return bytes((
        0xEA,
        0x00, 0x00,
        entry_segment & 0xFF,
        (entry_segment >> 8) & 0xFF,
        0xFF, 0xFF, 0xFF, 0xFF,
        0xFF, 0xFF, 0xFF, 0xFF,
        0xFF, 0xFF, 0xFF,
    ))


def main() -> int:
    args = parse_args()
    rom_size = parse_int(args.rom_size)
    entry_segment = parse_int(args.entry_segment)
    reset_vector_offset = rom_size - 0x10
    reserved_ranges = parse_reserved_ranges(args.reserved_range)

    payload_path = Path(args.payload)
    output_path = Path(args.output)

    stub = b""
    if args.stub is not None:
        stub = Path(args.stub).read_bytes()
    payload = payload_path.read_bytes()

    reserved = sum(size for _, size in reserved_ranges)
    total_code = len(stub) + len(payload) + reserved
    available = reset_vector_offset

    if total_code > available:
        print(f"ERROR: stub ({len(stub)}) + payload ({len(payload)}) = "
              f"{len(stub) + len(payload)} bytes plus {reserved} reserved bytes "
              f"exceeds available space ({available} bytes)",
              file=sys.stderr)
        return 1

    # Build the ROM image
    rom = bytearray(0xFF for _ in range(rom_size))

    if stub:
        rom[0:len(stub)] = stub

    # Place the payload immediately after the stub, skipping any fixed-address
    # compatibility holes that must remain executable in the ROM.
    payload_pos = 0
    cursor = len(stub)
    for hole_offset, hole_size in sorted(reserved_ranges):
        if cursor < hole_offset:
            chunk = payload[payload_pos:payload_pos + (hole_offset - cursor)]
            rom[cursor:cursor + len(chunk)] = chunk
            cursor += len(chunk)
            payload_pos += len(chunk)
        cursor = hole_offset + hole_size

    if payload_pos < len(payload):
        rom[cursor:cursor + (len(payload) - payload_pos)] = payload[payload_pos:]

    reset_vector = build_reset_vector(entry_segment)
    rom[reset_vector_offset:reset_vector_offset + len(reset_vector)] = reset_vector

    if args.machine_id_byte is not None:
        rom[rom_size - 2] = parse_int(args.machine_id_byte) & 0xFF

    output_path.write_bytes(rom)

    pad = available - total_code
    print(f"ROM image: stub={len(stub)}, payload={len(payload)}, "
          f"reserved={reserved}, free={pad}, total={rom_size}",
          file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
