#!/usr/bin/env python3

from pathlib import Path
import re
import json


ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "Original-firmware" / "decompiled" / "system" / "bios_decomp.c"
OUT = ROOT / "src" / "bios_strings.inc"


def parse_rom_strings(text: str):
    block_match = re.search(
        r"static const RomString rom_strings\[\] = \{(.*?)\n\};",
        text,
        re.S,
    )
    if not block_match:
        raise SystemExit("unable to find rom_strings block")

    entries = []
    for off_hex, raw in re.findall(r'\{0x([0-9A-Fa-f]+),\s*"((?:\\.|[^"])*)"\}', block_match.group(1)):
        entries.append((int(off_hex, 16), raw))
    if not entries:
        raise SystemExit("no ROM strings found")
    return entries


def c_string(raw: str) -> str:
    return json.dumps(raw)[1:-1]


def main():
    entries = parse_rom_strings(SRC.read_text())
    lines = []
    lines.append("/* Auto-generated from decompiled/system/bios_decomp.c. */")
    lines.append("  {")
    lines.append("    0, 0")
    lines.append("  },")
    for off, raw in entries:
        lines.append(f'  {{0x{off:04X}, "{c_string(raw)}"}},')
    OUT.write_text("\n".join(lines) + "\n")


if __name__ == "__main__":
    main()
