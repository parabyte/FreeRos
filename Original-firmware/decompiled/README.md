Extracted firmware and decompilation notes for PC1640.

Sources:
- `40043.v3` + `40044.v3` (16 KiB each) interleaved into `decompiled/system/bios.bin` (32 KiB system BIOS).
  - Interleave order used: even bytes from `40044.v3`, odd bytes from `40043.v3`.
- `40100` (32 KiB) contains a 16 KiB video option ROM at offset 0 with signature `55 AA` and size byte `0x20`.

Extracted binaries:
- `decompiled/video/40100_full.bin` (full 32 KiB blob).
- `decompiled/video/40100_rom.bin` (first 16 KiB, option ROM payload).
- `decompiled/video/40100_tables.bin` (remaining 16 KiB, tables/fonts).
- `decompiled/system/bios.bin` (interleaved system BIOS).

Disassembly:
- `decompiled/video/40100_rom.asm` and `decompiled/video/40100_rom_annotated.asm` (origin `0xC0000`).
- `decompiled/system/bios.asm` and `decompiled/system/bios_annotated.asm` (origin `0xF8000`).

Decompiled C (instruction-accurate):
- `decompiled/video/40100_rom_decomp.c` (switch-based execution of reachable code; requires a CPU/memory harness).
- `decompiled/system/bios_decomp.c` (stub; far jump to missing ROM at `0xFC00:0x205B`).

C rebuilds:
- `decompiled/C/` contains C sources and a Makefile to rebuild the extracted images exactly.

Notes:
- No other valid option ROM headers were found in the blobs besides `40100` at offset 0.
- The system BIOS is a 32 KiB image mapped at `0xF8000-0xFFFFF` (reset vector at `0xFFFF0`, offset `0x7FF0`).
- Reset `ljmp` targets `0xFC00:0x205B` (physical `0xFE05B`) within the same 32 KiB image.
