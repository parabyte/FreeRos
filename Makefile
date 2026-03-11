TOOLCHAIN ?= /home/arduino/elks/cross/bin
CC := $(TOOLCHAIN)/ia16-elf-gcc
OBJCOPY := $(TOOLCHAIN)/ia16-elf-objcopy

CFLAGS ?= -std=gnu99 -ffreestanding -fno-asynchronous-unwind-tables -fno-unwind-tables \
          -fno-stack-protector -fno-pic -fno-pie -fno-jump-tables \
          -mtune=i8086 -Os -mcmodel=small -msegment-relocation-stuff -Isrc
LDFLAGS ?= -nostdlib -T src/linker.ld -Wl,-Map,build/bios.map

SRCS := \
  src/reset.c \
  src/main.c \
  src/io.c \
  src/system.c \
  src/strings.c \
  src/post.c \
  src/ivt.c \
  src/pic.c \
  src/pit.c \
  src/keyboard.c \
  src/video.c \
  src/floppy.c \
  src/serial.c \
  src/printer.c \
  src/rtc.c

OBJS := $(SRCS:src/%.c=build/%.o)

all: build/bios.bin build/40043.v3 build/40044.v3

regen-strings: src/bios_strings.inc

src/bios_strings.inc: tools/extract_strings.py Original-firmware/decompiled/system/bios_decomp.c
	python3 tools/extract_strings.py

build:
	mkdir -p build

build/%.o: src/%.c | build
	$(CC) $(CFLAGS) -c $< -o $@

build/bios.elf: $(OBJS) src/linker.ld | build
	$(CC) $(CFLAGS) $(OBJS) -o $@ $(LDFLAGS)

build/bios.bin: build/bios.elf
	$(OBJCOPY) -O binary $< $@
	python3 -c "from pathlib import Path; p=Path('build/bios.bin'); data=p.read_bytes(); assert len(data) <= 32768, 'ROM image too large: %d bytes' % len(data); p.write_bytes(data + b'\\xFF' * (32768 - len(data)))"

build/40044.v3: build/bios.bin
	python3 -c "from pathlib import Path; bio=Path('build/bios.bin').read_bytes(); Path('build/40044.v3').write_bytes(bio[0::2])"

build/40043.v3: build/bios.bin
	python3 -c "from pathlib import Path; bio=Path('build/bios.bin').read_bytes(); Path('build/40043.v3').write_bytes(bio[1::2])"

clean:
	rm -rf build

.PHONY: all clean regen-strings
