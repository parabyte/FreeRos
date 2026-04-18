#!/usr/bin/env python3
"""Convert a binary file into split C arrays for low/high ROM placement."""

from __future__ import annotations

import argparse
from pathlib import Path


def emit_array(out, name: str, section: str, data: bytes) -> None:
    macro = f"{name.upper()}_SIZE"
    out.write(f"#define {macro} {len(data)}U\n")
    if not data:
        out.write(f"#if {macro}\n")
        out.write(
            f"static const u8 {name}[] __attribute__((section(\"{section}\"), aligned(1))) = {{ 0x00 }};\n"
        )
        out.write("#endif\n")
        return

    out.write(f"#if {macro}\n")
    out.write(
        f"static const u8 {name}[] __attribute__((section(\"{section}\"), aligned(1))) = {{\n"
    )
    for offset in range(0, len(data), 16):
        chunk = data[offset:offset + 16]
        line = ", ".join(f"0x{byte:02X}" for byte in chunk)
        out.write(f"  {line},\n")
    out.write("};\n")
    out.write("#endif\n")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Convert a binary blob into low/high split C arrays"
    )
    parser.add_argument("--input", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--array-name", required=True)
    parser.add_argument("--split-size", required=True, type=int)
    parser.add_argument("--section-low", required=True)
    parser.add_argument("--section-high", required=True)
    args = parser.parse_args()

    data = Path(args.input).read_bytes()
    split = min(args.split_size, len(data))
    low = data[:split]
    high = data[split:]

    with Path(args.output).open("w", encoding="ascii") as out:
        out.write(f"/* Auto-generated from {Path(args.input).name}; do not edit. */\n")
        out.write(
            f"#define {args.array_name.upper()}_SIZE {len(data)}U\n"
        )
        emit_array(
            out,
            f"{args.array_name}_lo",
            args.section_low,
            low,
        )
        emit_array(
            out,
            f"{args.array_name}_hi",
            args.section_high,
            high,
        )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
