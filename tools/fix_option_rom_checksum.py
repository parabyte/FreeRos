#!/usr/bin/env python3
"""Set PC/XT option-ROM checksum so sum of all covered bytes is 0 mod 256."""
from __future__ import annotations

import argparse
import sys
from pathlib import Path


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("rom", type=Path, help="option ROM binary (header at offset 0)")
    p.add_argument(
        "--pad-to-blocks",
        action="store_true",
        help="pad file with 0xFF to blocks*512 before checksumming",
    )
    args = p.parse_args()
    data = bytearray(args.rom.read_bytes())
    if len(data) < 3:
        print("ROM too small", file=sys.stderr)
        return 1
    if data[0] != 0x55 or data[1] != 0xAA:
        print("missing 55 AA signature", file=sys.stderr)
        return 1
    blocks = data[2]
    if blocks == 0:
        print("block count byte is zero", file=sys.stderr)
        return 1
    need = blocks * 512
    if args.pad_to_blocks:
        if len(data) < need:
            data.extend(b"\xff" * (need - len(data)))
        elif len(data) > need:
            print(f"ROM length {len(data)} exceeds header size {need}", file=sys.stderr)
            return 1
    else:
        if len(data) < need:
            print(
                f"ROM length {len(data)} < header size {need} (use --pad-to-blocks)",
                file=sys.stderr,
            )
            return 1
    chunk = data[:need]
    adjust = (-sum(chunk)) & 0xFF
    data[need - 1] = (data[need - 1] + adjust) & 0xFF
    if (-sum(data[:need])) & 0xFF != 0:
        print("checksum fix failed", file=sys.stderr)
        return 1
    args.rom.write_bytes(data)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
