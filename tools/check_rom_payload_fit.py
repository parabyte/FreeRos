#!/usr/bin/env python3
"""Exit non-zero if BIOS payload binary exceeds max size for ROM image layout."""

import argparse
import sys
from pathlib import Path


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("payload", type=Path)
    ap.add_argument("max_size", type=lambda x: int(x, 0))
    args = ap.parse_args()
    data = args.payload.read_bytes()
    if len(data) > args.max_size:
        print(
            f"check_rom_payload_fit: payload {len(data)} bytes exceeds limit {args.max_size}",
            file=sys.stderr,
        )
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
