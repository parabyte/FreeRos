#!/usr/bin/env python3
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Iterable, Tuple

PRINTABLE_MIN = 0x20
PRINTABLE_MAX = 0x7E


@dataclass
class SectionNote:
    offset: int
    note: str


def is_printable(b: int) -> bool:
    return PRINTABLE_MIN <= b <= PRINTABLE_MAX


def find_c_strings(data: bytes, min_len: int = 4) -> List[Tuple[int, str]]:
    """Find null-terminated ASCII strings.

    Only sequences of printable ASCII are accepted and must end with a NUL byte.
    """
    results: List[Tuple[int, str]] = []
    i = 0
    n = len(data)
    while i < n:
        if is_printable(data[i]):
            j = i
            while j < n and is_printable(data[j]):
                j += 1
            if j - i >= min_len and j < n and data[j] == 0x00:
                s = data[i:j].decode('ascii', errors='replace')
                # Require at least one alphabetic character.
                if any(('A' <= ch <= 'Z') or ('a' <= ch <= 'z') for ch in s):
                    results.append((i, s))
                i = j + 1
            else:
                i = j + 1
        else:
            i += 1
    return results


def sanitize_comment(text: str) -> str:
    # Prevent closing comment sequences.
    return text.replace('*/', '* /')


def emit_c_array(
    data: bytes,
    symbol: str,
    chunk_size: int = 0x4000,
    section_notes: Iterable[SectionNote] = (),
    annotate_strings: bool = True,
) -> str:
    """Emit a C file with ROM bytes split into chunks and annotated comments."""
    lines: List[str] = []
    lines.append('#include <stdint.h>')
    lines.append('')
    lines.append('/*')
    lines.append(' * Raw ROM bytes, preserved exactly as in the original image.')
    lines.append(' * Comments annotate known strings and high-level data sections.')
    lines.append(' */')

    notes_by_off: Dict[int, List[str]] = {}
    for note in section_notes:
        notes_by_off.setdefault(note.offset, []).append(note.note)

    if annotate_strings:
        for off, s in find_c_strings(data):
            notes_by_off.setdefault(off, []).append(f'string: "{sanitize_comment(s)}"')

    # Precompute chunks in forward order, but emit in reverse so ia16-elf-gcc
    # produces a .rom section in ascending ROM order.
    chunks = [(i, data[i:i + chunk_size]) for i in range(0, len(data), chunk_size)]

    lines.append('')
    lines.append('// Split into 16 KiB chunks to satisfy IA16 compiler object size limits.')
    lines.append('// ia16-elf-gcc emits section objects in reverse order; declare chunks in reverse')
    lines.append('// so the .rom section is in ascending ROM order after compilation.')

    note_offsets = sorted(notes_by_off.keys())

    for start, chunk in reversed(chunks):
        end = start + len(chunk) - 1
        lines.append('')
        lines.append(f'/* 0x{start:04X}-0x{end:04X} */')
        lines.append('__attribute__((section(".rom"), used, aligned(1)))')
        lines.append(f'const uint8_t {symbol}_{start:04x}[] = {{')
        # Notes that fall within this chunk (sorted).
        chunk_notes = [o for o in note_offsets if start <= o < start + len(chunk)]
        note_idx = 0
        for rel in range(0, len(chunk), 12):
            row = chunk[rel:rel + 12]
            row_start = start + rel
            row_end = row_start + len(row)
            while note_idx < len(chunk_notes) and chunk_notes[note_idx] < row_start:
                note_idx += 1
            while note_idx < len(chunk_notes) and chunk_notes[note_idx] < row_end:
                off = chunk_notes[note_idx]
                for note in notes_by_off[off]:
                    lines.append(f'    /* 0x{off:04X}: {note} */')
                note_idx += 1
            hexes = ', '.join(f'0x{b:02x}' for b in row)
            lines.append(f'    {hexes},')
        lines.append('};')

    lines.append('')
    return '\n'.join(lines)


def write_rom_c(
    bin_path: Path,
    out_path: Path,
    symbol: str,
    section_notes: Iterable[SectionNote] = (),
) -> None:
    data = bin_path.read_bytes()
    out_path.write_text(
        emit_c_array(
            data,
            symbol=symbol,
            chunk_size=0x4000,
            section_notes=section_notes,
            annotate_strings=True,
        )
    )


def main() -> None:
    root = Path('/home/gatekeeper/.pcem/roms/pc1640/decompiled')

    # Video option ROM (16 KiB)
    write_rom_c(
        root / 'video' / '40100_rom.bin',
        root / 'C' / 'video_40100_rom.c',
        'video_40100_rom',
        section_notes=[
            SectionNote(0x0000, 'Paradise PEGA1A video BIOS option ROM header (55 AA, size=0x20 = 16 KiB) + entry jump'),
        ],
    )

    # Full 40100 blob (32 KiB)
    write_rom_c(
        root / 'video' / '40100_full.bin',
        root / 'C' / 'video_40100_full.c',
        'video_40100_full',
        section_notes=[
            SectionNote(0x0000, 'Paradise PEGA1A option ROM code/data (same as 40100_rom.bin)'),
            SectionNote(0x4000, 'tables/fonts (non-code graphics data)'),
        ],
    )

    # System BIOS (32 KiB)
    write_rom_c(
        root / 'system' / 'bios.bin',
        root / 'C' / 'system_bios.c',
        'system_bios',
        section_notes=[
            SectionNote(0x0000, 'system BIOS lower 16 KiB (maps to 0xF8000)'),
            SectionNote(0x4000, 'system BIOS upper 16 KiB (maps to 0xFC000)'),
        ],
    )


if __name__ == '__main__':
    main()
