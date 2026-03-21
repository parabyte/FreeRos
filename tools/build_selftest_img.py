#!/usr/bin/env python3

from __future__ import annotations

import argparse
from pathlib import Path


FLOPPY_SIZE = 360 * 1024
SECTOR_SIZE = 512
def sector_fill(prefix: bytes) -> bytes:
    data = bytearray(SECTOR_SIZE)
    data[: len(prefix)] = prefix
    for i in range(len(prefix), SECTOR_SIZE):
        data[i] = i & 0xFF
    return bytes(data)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--boot", required=True)
    parser.add_argument("--stage2", required=True)
    parser.add_argument("--stage2-sectors", type=int, required=True)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()

    boot = Path(args.boot).read_bytes()
    stage2 = Path(args.stage2).read_bytes()
    output = Path(args.output)

    if len(boot) != SECTOR_SIZE:
        raise SystemExit(f"boot sector must be exactly {SECTOR_SIZE} bytes")
    max_stage2 = args.stage2_sectors * SECTOR_SIZE
    read_sector_index = 1 + args.stage2_sectors
    write_sector_index = 2 + args.stage2_sectors
    if len(stage2) > max_stage2:
        raise SystemExit(f"stage2 too large: {len(stage2)} > {max_stage2}")

    image = bytearray(FLOPPY_SIZE)
    image[0:SECTOR_SIZE] = boot
    image[SECTOR_SIZE : SECTOR_SIZE + max_stage2] = stage2.ljust(max_stage2, b"\x00")
    image[read_sector_index * SECTOR_SIZE : (read_sector_index + 1) * SECTOR_SIZE] = sector_fill(
        b"READ-SECTOR-OK\x00"
    )
    image[write_sector_index * SECTOR_SIZE : (write_sector_index + 1) * SECTOR_SIZE] = sector_fill(
        b"WRITE-SECTOR-INIT\x00"
    )

    output.write_bytes(image)


if __name__ == "__main__":
    main()
