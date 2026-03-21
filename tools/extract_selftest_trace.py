#!/usr/bin/env python3

from __future__ import annotations

import argparse
from pathlib import Path


SECTOR_SIZE = 512
SECTORS_PER_TRACK = 9
HEADS = 2


def chs_offset(cylinder: int, head: int, sector: int) -> int:
    lba = ((cylinder * HEADS) + head) * SECTORS_PER_TRACK + (sector - 1)
    return lba * SECTOR_SIZE


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--image", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--cylinder", type=int, default=0)
    parser.add_argument("--head", type=int, default=1)
    parser.add_argument("--sector", type=int, default=1)
    parser.add_argument("--count", type=int, default=2)
    args = parser.parse_args()

    image = Path(args.image).read_bytes()
    start = chs_offset(args.cylinder, args.head, args.sector)
    size = args.count * SECTOR_SIZE
    end = start + size
    if end > len(image):
        raise SystemExit("requested trace range exceeds image size")

    trace = image[start:end]
    nul = trace.find(b"\x00")
    if nul != -1:
        trace = trace[:nul]
    Path(args.output).write_bytes(trace)


if __name__ == "__main__":
    main()
