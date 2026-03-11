C sources that rebuild the extracted firmware images exactly.

Build:
- `make`

Verify against extracted binaries:
- `make verify`

Outputs:
- `video_40100_rom.bin` (16 KiB video option ROM)
- `video_40100_full.bin` (32 KiB full 40100 blob)
- `system_bios.bin` (32 KiB system BIOS interleaved from 40043.v3 + 40044.v3)
