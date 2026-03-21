TOOLCHAIN ?= /home/arduino/elks/cross/bin
CC := $(TOOLCHAIN)/ia16-elf-gcc
OBJCOPY := $(TOOLCHAIN)/ia16-elf-objcopy
NM := $(TOOLCHAIN)/ia16-elf-nm
NASM ?= nasm
PYTHON ?= python3
BIOS_DEBUG_DEFS ?=
CONFIG_HEADER := build/config_autogen.h
CONFIG_MK := build/config.mk
EXOMIZER ?= build/exomizer-source/src/exomizer
EXOMIZER_TOOL := tools/ensure_exomizer.py

ifneq ($(filter clean,$(MAKECMDGOALS)),clean)
-include $(CONFIG_MK)
endif

CFLAGS ?= -std=gnu99 -ffreestanding -fno-asynchronous-unwind-tables -fno-unwind-tables \
          -fno-stack-protector -fno-pic -fno-pie -fno-jump-tables \
          -ffunction-sections -fdata-sections \
          -mtune=i8086 -Os -mcmodel=small -msegment-relocation-stuff -MMD -MP -Isrc -Ibuild \
          $(CONFIG_BIOS_DEBUG_DEFS) $(BIOS_DEBUG_DEFS)
LDFLAGS ?= -nostdlib -T src/linker.ld -Wl,-Map,build/bios.map -Wl,--gc-sections

SRCS := \
  src/intcall.c \
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
  src/optionrom.c \
  src/ide.c \
  src/floppy.c \
  src/serial.c \
  src/printer.c \
  src/rtc.c

OBJS := $(SRCS:src/%.c=build/%.o)
DEPS := $(OBJS:.o=.d)
BOOT_FLOPPY_IMAGE ?= $(CONFIG_BOOT_FLOPPY_IMAGE)
BOOT_FLOPPY_IMAGE ?= test_media/ibm_dos_330_disk1_360k.img
SELFTEST_STAGE2_SECTORS := 6

all: .config $(CONFIG_HEADER) build/bios.bin build/40043.v3 build/40044.v3 build/selftest-360k.img

regen-strings: src/bios_strings.inc

src/bios_strings.inc: tools/extract_strings.py Original-firmware/decompiled/system/bios_decomp.c
	$(PYTHON) tools/extract_strings.py

build:
	mkdir -p build

# ---------------------------------------------------------------
# Configuration system (Linux/ELKS-style Kconfig)
# ---------------------------------------------------------------

kconfig:
	$(MAKE) -C config all

defconfig:
	@rm -f .config
	@yes '' | config/Configure -d config.in
	@scripts/mkconfig.sh .config $(CONFIG_HEADER) $(CONFIG_MK)
	@echo '*** Default configuration written to .config'

config: kconfig
	config/Configure config.in
	@scripts/mkconfig.sh .config $(CONFIG_HEADER) $(CONFIG_MK)

menuconfig: kconfig
	config/Menuconfig config.in
	@scripts/mkconfig.sh .config $(CONFIG_HEADER) $(CONFIG_MK)

$(CONFIG_HEADER) $(CONFIG_MK): .config scripts/mkconfig.sh | build
	@scripts/mkconfig.sh .config $(CONFIG_HEADER) $(CONFIG_MK)

.config:
	@if [ ! -f .config ]; then \
		echo '*** No .config found, running defconfig...'; \
		yes '' | config/Configure -d config.in; \
		scripts/mkconfig.sh .config $(CONFIG_HEADER) $(CONFIG_MK); \
	fi

# ---------------------------------------------------------------
# BIOS build
# ---------------------------------------------------------------

build/%.o: src/%.c $(CONFIG_HEADER) | build
	$(CC) $(CFLAGS) -c $< -o $@

-include $(DEPS)

# Stage 1: Compile the BIOS payload (up to 32 KiB raw binary)
build/bios.elf: $(OBJS) src/linker.ld | build
	$(CC) $(CFLAGS) $(OBJS) -o $@ $(LDFLAGS)

build/bios-payload.bin: build/bios.elf | build
	$(OBJCOPY) -O binary $< $@

# Stage 2: Compress the payload with Exomizer raw (-P63)
$(EXOMIZER): $(EXOMIZER_TOOL) | build
	$(PYTHON) $(EXOMIZER_TOOL) $@

build/bios-payload.exo: build/bios-payload.bin $(EXOMIZER) | build
	$(EXOMIZER) raw -q -P 47 $< -o $@

# Stage 3: Assemble the ROM decompressor stub
build/romstub.bin: src/romstub.asm build/bios-payload.bin build/bios-payload.exo | build
	$(NASM) -f bin \
	  -DDEST_SIZE=$$(wc -c < build/bios-payload.bin) \
	  -DCOMPRESSED_SIZE=$$(wc -c < build/bios-payload.exo) \
	  $< -o $@

# Stage 4: Build the 16 KiB ROM image (stub + compressed payload + reset vector)
build/bios.bin: build/romstub.bin build/bios-payload.exo build/bios.elf tools/build_rom_image.py tools/patch_rom_compat_vectors.py tools/fix_ros_checksum.py | build
	$(PYTHON) tools/build_rom_image.py build/romstub.bin build/bios-payload.exo $@
	$(PYTHON) tools/patch_rom_compat_vectors.py --nm $(NM) --elf build/bios.elf --rom $@
	$(PYTHON) tools/fix_ros_checksum.py $@

# Stage 5: Split into interleaved chip files with mirrored halves
build/40044.v3: build/bios.bin
	$(PYTHON) -c "from pathlib import Path; bio=Path('build/bios.bin').read_bytes(); half=bio[0::2]; Path('build/40044.v3').write_bytes(half + half)"

build/40043.v3: build/bios.bin
	$(PYTHON) -c "from pathlib import Path; bio=Path('build/bios.bin').read_bytes(); half=bio[1::2]; Path('build/40043.v3').write_bytes(half + half)"

# ---------------------------------------------------------------
# Self-test image
# ---------------------------------------------------------------

build/selftest-boot.bin: tests/selftest_boot.asm | build
	$(NASM) -f bin -DSTAGE2_SECTORS=$(SELFTEST_STAGE2_SECTORS) $< -o $@

build/selftest-stage2.bin: tests/selftest_stage2.asm | build
	$(NASM) -f bin -DSTAGE2_SECTORS=$(SELFTEST_STAGE2_SECTORS) $< -o $@

build/selftest-360k.img: build/selftest-boot.bin build/selftest-stage2.bin tools/build_selftest_img.py | build
	$(PYTHON) tools/build_selftest_img.py \
	  --boot build/selftest-boot.bin \
	  --stage2 build/selftest-stage2.bin \
	  --stage2-sectors $(SELFTEST_STAGE2_SECTORS) \
	  --output $@

# ---------------------------------------------------------------
# Clean
# ---------------------------------------------------------------

clean:
	rm -rf build
	$(MAKE) -C config clean

mrproper: clean
	rm -f .config .config.old

# ---------------------------------------------------------------
# 86Box test targets
# ---------------------------------------------------------------

86box-build:
	tools/build_86box_debug.sh

86box-run:
	EIGHTYSIXBOX_CAPTURE_COM1=$(EIGHTYSIXBOX_CAPTURE_COM1) \
	tools/run_86box_pc1640_debug.sh --image $(BOOT_FLOPPY_IMAGE)

86box-selftest:
	EIGHTYSIXBOX_CAPTURE_COM1=$(EIGHTYSIXBOX_CAPTURE_COM1) \
	tools/run_86box_pc1640_debug.sh --headless --timeout 25 --image build/selftest-360k.img

86box-selftest-video-trace:
	cp build/selftest-360k.img build/selftest-current.img
	EIGHTYSIXBOX_CAPTURE_COM1=1 \
	EIGHTYSIXBOX_VM_ROOT="$(CURDIR)/build/86box-vm-current" \
	EIGHTYSIXBOX_CFG="$(CURDIR)/build/86box-vm-current/pc1640.cfg" \
	EIGHTYSIXBOX_LOG="$(CURDIR)/build/86box-vm-current/86box.log" \
	EIGHTYSIXBOX_SERIAL_LOG="$(CURDIR)/build/86box-vm-current/com1.log" \
	EIGHTYSIXBOX_SERIAL_STDERR="$(CURDIR)/build/86box-vm-current/86box.stderr.log" \
	tools/run_86box_pc1640_debug.sh --headless --timeout 25 --image build/selftest-current.img
	$(PYTHON) tools/extract_selftest_trace.py --image build/selftest-current.img --output build/current-trace.bin

86box-selftest-video-trace-original:
	cp build/selftest-360k.img build/selftest-original.img
	EIGHTYSIXBOX_CAPTURE_COM1=1 \
	EIGHTYSIXBOX_VM_ROOT="$(CURDIR)/build/86box-vm-original" \
	EIGHTYSIXBOX_CFG="$(CURDIR)/build/86box-vm-original/pc1640.cfg" \
	EIGHTYSIXBOX_LOG="$(CURDIR)/build/86box-vm-original/86box.log" \
	EIGHTYSIXBOX_SERIAL_LOG="$(CURDIR)/build/86box-vm-original/com1.log" \
	EIGHTYSIXBOX_SERIAL_STDERR="$(CURDIR)/build/86box-vm-original/86box.stderr.log" \
	PC1640_SYSTEM_ROM_EVEN="$(CURDIR)/Original-firmware/40044.v3" \
	PC1640_SYSTEM_ROM_ODD="$(CURDIR)/Original-firmware/40043.v3" \
	tools/run_86box_pc1640_debug.sh --headless --timeout 25 --image build/selftest-original.img
	$(PYTHON) tools/extract_selftest_trace.py --image build/selftest-original.img --output build/original-trace.bin

86box-selftest-video-compare:
	$(MAKE) 86box-selftest-video-trace
	$(MAKE) 86box-selftest-video-trace-original
	cmp -s build/current-trace.bin build/original-trace.bin

86box-selftest-ega-video-trace:
	cp build/selftest-360k.img build/selftest-ega-current.img
	EIGHTYSIXBOX_CAPTURE_COM1=1 \
	EIGHTYSIXBOX_VM_ROOT="$(CURDIR)/build/86box-vm-ega-current" \
	EIGHTYSIXBOX_CFG="$(CURDIR)/build/86box-vm-ega-current/pc1640.cfg" \
	EIGHTYSIXBOX_LOG="$(CURDIR)/build/86box-vm-ega-current/86box.log" \
	EIGHTYSIXBOX_SERIAL_LOG="$(CURDIR)/build/86box-vm-ega-current/com1.log" \
	EIGHTYSIXBOX_SERIAL_STDERR="$(CURDIR)/build/86box-vm-ega-current/86box.stderr.log" \
	EIGHTYSIXBOX_GFXCARD=ega \
	tools/run_86box_pc1640_debug.sh --headless --timeout 25 --image build/selftest-ega-current.img
	$(PYTHON) tools/extract_selftest_trace.py --image build/selftest-ega-current.img --output build/current-ega-trace.bin

86box-selftest-ega-video-trace-original:
	cp build/selftest-360k.img build/selftest-ega-original.img
	EIGHTYSIXBOX_CAPTURE_COM1=1 \
	EIGHTYSIXBOX_VM_ROOT="$(CURDIR)/build/86box-vm-ega-original" \
	EIGHTYSIXBOX_CFG="$(CURDIR)/build/86box-vm-ega-original/pc1640.cfg" \
	EIGHTYSIXBOX_LOG="$(CURDIR)/build/86box-vm-ega-original/86box.log" \
	EIGHTYSIXBOX_SERIAL_LOG="$(CURDIR)/build/86box-vm-ega-original/com1.log" \
	EIGHTYSIXBOX_SERIAL_STDERR="$(CURDIR)/build/86box-vm-ega-original/86box.stderr.log" \
	EIGHTYSIXBOX_GFXCARD=ega \
	PC1640_SYSTEM_ROM_EVEN="$(CURDIR)/Original-firmware/40044.v3" \
	PC1640_SYSTEM_ROM_ODD="$(CURDIR)/Original-firmware/40043.v3" \
	tools/run_86box_pc1640_debug.sh --headless --timeout 25 --image build/selftest-ega-original.img
	$(PYTHON) tools/extract_selftest_trace.py --image build/selftest-ega-original.img --output build/original-ega-trace.bin

86box-selftest-ega-video-compare:
	$(MAKE) 86box-selftest-ega-video-trace
	$(MAKE) 86box-selftest-ega-video-trace-original
	cmp -s build/current-ega-trace.bin build/original-ega-trace.bin

build/edd_smoke_boot.bin: tests/edd_smoke_boot.asm | build
	$(NASM) -f bin $< -o $@

build/ide-smoke-hdd.img: build/edd_smoke_boot.bin | build
	$(PYTHON) -c "\
import sys; \
boot = open('build/edd_smoke_boot.bin','rb').read(); \
assert len(boot) == 512; \
marker = bytearray(512); \
marker[0:4] = b'EDD!'; \
marker[510] = 0x55; marker[511] = 0xAA; \
total = 306*4*17*512; \
img = bytearray(total); \
img[0:512] = boot; \
img[512:1024] = marker; \
open('$@','wb').write(img)"

86box-ide-smoke: build/ide-smoke-hdd.img
	EIGHTYSIXBOX_CAPTURE_COM1=1 \
	EIGHTYSIXBOX_XTIDE_ENABLED=1 \
	EIGHTYSIXBOX_XTIDE_BIOS=none \
	EIGHTYSIXBOX_XTIDE_BASE_IO=0x300 \
	EIGHTYSIXBOX_IDE_HDD_IMAGE="$(CURDIR)/build/ide-smoke-hdd.img" \
	EIGHTYSIXBOX_IDE_HDD_CYLINDERS=306 \
	EIGHTYSIXBOX_IDE_HDD_HEADS=4 \
	EIGHTYSIXBOX_IDE_HDD_SPT=17 \
	EIGHTYSIXBOX_VM_ROOT="$(CURDIR)/build/86box-vm-idesmoke" \
	EIGHTYSIXBOX_CFG="$(CURDIR)/build/86box-vm-idesmoke/pc1640.cfg" \
	EIGHTYSIXBOX_LOG="$(CURDIR)/build/86box-vm-idesmoke/86box.log" \
	EIGHTYSIXBOX_SERIAL_LOG="$(CURDIR)/build/86box-vm-idesmoke/com1.log" \
	EIGHTYSIXBOX_SERIAL_STDERR="$(CURDIR)/build/86box-vm-idesmoke/86box.stderr.log" \
	BIOS_DEBUG_DEFS="-DBIOS_CFG_DEBUG_COM1=1" \
	tools/run_86box_pc1640_debug.sh --headless --timeout 30

# ---------------------------------------------------------------
# Help
# ---------------------------------------------------------------

help:
	@echo 'FreeRos BIOS Build System'
	@echo ''
	@echo 'Configuration:'
	@echo '  defconfig      - Generate default .config'
	@echo '  config         - Text-mode configuration (like Linux "make config")'
	@echo '  menuconfig     - Ncurses menu configuration (like Linux "make menuconfig")'
	@echo ''
	@echo 'Build:'
	@echo '  all            - Build ROM image, chip files, and selftest (default)'
	@echo '  clean          - Remove build directory'
	@echo '  mrproper       - Remove build directory and .config'
	@echo ''
	@echo 'Testing (requires 86Box):'
	@echo '  86box-build    - Build 86Box debug version'
	@echo '  86box-run      - Run BIOS in 86Box with floppy image'
	@echo '  86box-selftest - Run self-test in headless 86Box'
	@echo '  86box-ide-smoke - Run IDE smoke test in 86Box'
	@echo ''
	@echo 'Build outputs:'
	@echo '  build/bios.bin    - 16 KiB ROM image'
	@echo '  build/40043.v3    - Odd chip file (with mirror)'
	@echo '  build/40044.v3    - Even chip file (with mirror)'
	@echo '  build/bios.elf    - ELF with debug symbols'
	@echo '  build/bios.map    - Linker map file'

.PHONY: all clean mrproper regen-strings defconfig config menuconfig kconfig help \
	86box-build 86box-run 86box-selftest 86box-ide-smoke \
	86box-selftest-video-trace 86box-selftest-video-trace-original \
	86box-selftest-video-compare 86box-selftest-ega-video-trace \
	86box-selftest-ega-video-trace-original 86box-selftest-ega-video-compare
