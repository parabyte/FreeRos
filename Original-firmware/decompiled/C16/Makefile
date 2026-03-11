TOOLCHAIN_BASE ?= /home/arduino/elks
TOOLCHAIN ?= $(TOOLCHAIN_BASE)/cross/bin
CC := $(TOOLCHAIN)/ia16-elf-gcc
OBJCOPY := $(TOOLCHAIN)/ia16-elf-objcopy

CFLAGS ?= -std=c99 -ffreestanding -fno-asynchronous-unwind-tables -fno-unwind-tables -fno-stack-protector -fno-pic -fno-pie -O2

# Sources are the exact-byte C arrays from ../C
VID_ROM_SRC = ../C/video_40100_rom.c
VID_FULL_SRC = ../C/video_40100_full.c
BIOS_SRC = ../C/system_bios.c

ALL_BINS = video_40100_rom.bin video_40100_full.bin bios.bin
ALL_SPLIT = 40043.v3 40044.v3

all: $(ALL_BINS) split

video_40100_rom.o: $(VID_ROM_SRC)
	$(CC) $(CFLAGS) -c $< -o $@

video_40100_full.o: $(VID_FULL_SRC)
	$(CC) $(CFLAGS) -c $< -o $@

bios.o: $(BIOS_SRC)
	$(CC) $(CFLAGS) -c $< -o $@

video_40100_rom.bin: video_40100_rom.o
	$(OBJCOPY) -O binary --only-section=.rom $< $@

video_40100_full.bin: video_40100_full.o
	$(OBJCOPY) -O binary --only-section=.rom $< $@

bios.bin: bios.o
	$(OBJCOPY) -O binary --only-section=.rom $< $@

split: bios.bin
	python3 -c "from pathlib import Path; bio=Path('bios.bin').read_bytes(); Path('40044.v3').write_bytes(bio[0::2]); Path('40043.v3').write_bytes(bio[1::2])"

verify: all
	cmp -s video_40100_rom.bin ../video/40100_rom.bin
	cmp -s video_40100_full.bin ../video/40100_full.bin
	cmp -s bios.bin ../system/bios.bin
	cmp -s 40043.v3 ../../40043.v3
	cmp -s 40044.v3 ../../40044.v3

clean:
	rm -f *.o *.bin 40043.v3 40044.v3
