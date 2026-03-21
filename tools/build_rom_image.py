"""
Build the final 16 KiB ROM image from the decompressor stub and compressed payload.

Layout of the 16 KiB image:
  0x0000           : decompressor stub code
  stub_size        : compressed BIOS payload
  0x3FF0           : reset vector (EA 00 00 00 FC) + padding FF bytes
  0x3FF5           : checksum byte (filled by fix_ros_checksum.py)

The reset vector is a FAR JMP to FC00:0000 which is the decompressor entry.
"""

import sys
from pathlib import Path

ROM_SIZE = 0x4000         # 16 KiB
RESET_VECTOR_OFFSET = 0x3FF0
ROM_SEG_LO = 0x00        # FC00 & 0xFF
ROM_SEG_HI = 0xFC        # FC00 >> 8
RESERVED_RANGES = (
    (0x3065, 5),
)

# Reset vector: JMP FAR FC00:0000
RESET_VECTOR = bytes([
    0xEA,                 # FAR JMP
    0x00, 0x00,           # offset 0x0000
    ROM_SEG_LO, ROM_SEG_HI,  # segment FC00
    0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF,
])


def main() -> int:
    if len(sys.argv) != 4:
        print("usage: build_rom_image.py <stub.bin> <payload.exo> <output.bin>",
              file=sys.stderr)
        return 1

    stub_path = Path(sys.argv[1])
    payload_path = Path(sys.argv[2])
    output_path = Path(sys.argv[3])

    stub = stub_path.read_bytes()
    payload = payload_path.read_bytes()

    reserved = sum(size for _, size in RESERVED_RANGES)
    total_code = len(stub) + len(payload) + reserved
    available = RESET_VECTOR_OFFSET  # bytes available before reset vector

    if total_code > available:
        print(f"ERROR: stub ({len(stub)}) + payload ({len(payload)}) = "
              f"{len(stub) + len(payload)} bytes plus {reserved} reserved bytes "
              f"exceeds available space ({available} bytes)",
              file=sys.stderr)
        return 1

    # Build the ROM image
    rom = bytearray(0xFF for _ in range(ROM_SIZE))

    # Place decompressor stub at offset 0
    rom[0:len(stub)] = stub

    # Place the compressed payload immediately after the stub, skipping any
    # fixed-address compatibility holes that must remain executable in the ROM.
    payload_pos = 0
    cursor = len(stub)
    for hole_offset, hole_size in RESERVED_RANGES:
        if cursor < hole_offset:
            chunk = payload[payload_pos:payload_pos + (hole_offset - cursor)]
            rom[cursor:cursor + len(chunk)] = chunk
            cursor += len(chunk)
            payload_pos += len(chunk)
        cursor = hole_offset + hole_size

    if payload_pos < len(payload):
        rom[cursor:cursor + (len(payload) - payload_pos)] = payload[payload_pos:]

    # Place reset vector at 0x3FF0
    rom[RESET_VECTOR_OFFSET:RESET_VECTOR_OFFSET + len(RESET_VECTOR)] = RESET_VECTOR

    output_path.write_bytes(rom)

    pad = available - total_code
    print(f"ROM image: stub={len(stub)}, payload={len(payload)}, "
          f"reserved={reserved}, free={pad}, total={ROM_SIZE}",
          file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
