TOOLCHAIN ?= /home/arduino/elks/cross/bin
CONFIG_FILE ?= config/profiles/pc1640_floppy_only.config
CC := $(TOOLCHAIN)/ia16-elf-gcc
OBJCOPY := $(TOOLCHAIN)/ia16-elf-objcopy
NM := $(TOOLCHAIN)/ia16-elf-nm
NASM ?= nasm
PYTHON ?= python3
EXOMIZER ?= build/exomizer-bin/exomizer
EXOMIZER_TOOL := tools/ensure_exomizer.py
BIOS_DEBUG_DEFS ?=
# Optional: make FDC_BOOT_TRACE=1 — single-byte ISA debug port 0xE9 trace (INT19 / FDC read path).
ifdef FDC_BOOT_TRACE
BIOS_DEBUG_DEFS += -DBIOS_CFG_FDC_BOOT_TRACE_E9=1
endif
CONFIG_HEADER := build/config_autogen.h
CONFIG_MK := build/config.mk
CONFIG_SOURCE_STAMP := build/.config-source
CONFIG_FILE_ABS := $(abspath $(CONFIG_FILE))
PC1640_PROFILE_FLOPPY_ONLY := config/profiles/pc1640_floppy_only.config
PC1640_PROFILE_IDE_EMBEDDED := config/profiles/pc1640_ide_embedded.config
PC1640_PROFILE_FLOPPY_EXTERNAL_XTIDE := config/profiles/pc1640_floppy_external_xtide.config
LINKER_SCRIPT := src/linker.ld
ifneq ($(filter clean,$(MAKECMDGOALS)),clean)
ifneq ($(wildcard $(CONFIG_MK)),)
ifeq ($(wildcard $(CONFIG_SOURCE_STAMP)),)
$(shell rm -f $(CONFIG_MK) $(CONFIG_HEADER))
endif
endif
ifneq ($(wildcard $(CONFIG_SOURCE_STAMP)),)
ifneq ($(strip $(shell cat $(CONFIG_SOURCE_STAMP) 2>/dev/null)),$(CONFIG_FILE_ABS))
$(shell rm -f $(CONFIG_MK) $(CONFIG_HEADER))
endif
endif
-include $(CONFIG_MK)
endif

ifeq ($(CONFIG_MACHINE_TARGET),pc1640dd)
ifneq ($(CONFIG_EXECUTE_IN_PLACE),y)
$(error PC1640DD build requires execute-in-place; ROM copy stub is disabled)
endif
ifneq ($(CONFIG_ROM_ENTRY_SEGMENT),0xFC00)
$(error PC1640DD requires ROM entry segment 0xFC00)
endif
ifneq ($(CONFIG_ROM_IMAGE_SIZE),0x4000)
$(error PC1640DD requires 16KiB ROM image (0x4000))
endif
ifneq ($(CONFIG_STACK_SEGMENT),0x0030)
$(error PC1640DD requires legacy init stack segment 0x0030)
endif
ifneq ($(CONFIG_STACK_OFFSET),0x0100)
$(error PC1640DD requires legacy init stack offset 0x0100)
endif
endif

CFLAGS ?= -std=gnu99 -ffreestanding -fno-asynchronous-unwind-tables -fno-unwind-tables \
          -fno-stack-protector -fno-pic -fno-pie -fno-jump-tables \
          -ffunction-sections -fdata-sections \
          -mtune=i8086 -Os -mcmodel=small -msegment-relocation-stuff -MMD -MP -Isrc -Ibuild \
          $(CONFIG_BIOS_DEBUG_DEFS) $(BIOS_DEBUG_DEFS)
# Append DEBUG_GDB=1 for source-level debugging in GDB (larger ELF, still fits ROM payload rules).
ifeq ($(DEBUG_GDB),1)
CFLAGS += -g -Og
endif
ifeq ($(CONFIG_EXECUTE_IN_PLACE),y)
ifeq ($(CONFIG_MACHINE_TARGET),pc1640dd)
ifneq ($(CONFIG_XTIDE_ENABLED),y)
LINKER_SCRIPT := src/linker_pc1640_floppy_compat.ld
else
LINKER_SCRIPT := src/linker_pc1640_inplace.ld
endif
else
LINKER_SCRIPT := src/linker_pc1640_inplace.ld
endif
endif

LDFLAGS ?= -nostdlib -T $(LINKER_SCRIPT) -Wl,-Map,build/bios.map -Wl,--gc-sections

XTIDE_REPO ?= xtide/xtideuniversalbios
XTIDE_SRC := $(XTIDE_REPO)/XTIDE_Universal_BIOS
XTIDE_EXTERNAL_XT_ROM := build/ide_xt.bin
XTIDE_EXTERNAL_XT_RAW := build/xtide_xt_raw.bin
XTIDE_EXTERNAL_XT_ROM_SIZE := 8192
XTIDE_EXTERNAL_XTL_ROM := build/ide_xtl.bin
XTIDE_EXTERNAL_XTL_RAW := build/xtide_xtl_raw.bin
XTIDE_EXTERNAL_XTL_ROM_SIZE := 10240
XTIDE_EMBEDDED_ROM := build/ide_tiny.bin
XTIDE_EMBEDDED_RAW := build/xtide_tiny_raw.bin
XTIDE_EMBEDDED_ROM_SIZE := 4096
# PC1640 execute-in-place builds can consume almost all of ROM_LO before the
# 0x3065 compat jump hole; keep 2 bytes of slack below that boundary.
XTIDE_EMBEDDED_ROM_LO_MAX := 3184
# External XTIDE ROM follows the generated config rather than hard-forcing the
# full upstream XT Large UI stack. PC1640 builds only need IDE boot support;
# optional UI/serial/power-management modules are enabled from config when the
# target actually asks for them.
XTIDE_EXTERNAL_DEFINES := \
  -DMODULE_STRINGS_COMPRESSED -DMODULE_8BIT_IDE \
  -DRESERVE_DIAGNOSTIC_CYLINDER -DNO_ATAID_VALIDATION -DCLD_NEEDED
ifeq ($(CONFIG_XTIDE_EDD_ENABLED),y)
XTIDE_EXTERNAL_DEFINES += -DMODULE_EBIOS
endif
ifeq ($(CONFIG_XTIDE_FULL_MODE),y)
XTIDE_EXTERNAL_DEFINES += -DMODULE_8BIT_IDE_ADVANCED
endif
ifeq ($(CONFIG_XTIDE_COMPATIBLE_TABLES),y)
XTIDE_EXTERNAL_DEFINES += -DMODULE_COMPATIBLE_TABLES
endif
ifeq ($(CONFIG_XTIDE_BOOT_MENU_ENABLED),y)
XTIDE_EXTERNAL_DEFINES += -DMODULE_BOOT_MENU
endif
ifeq ($(CONFIG_XTIDE_HOTKEYS_ENABLED),y)
XTIDE_EXTERNAL_DEFINES += -DMODULE_HOTKEYS
endif
ifeq ($(CONFIG_XTIDE_POWER_MANAGEMENT_ENABLED),y)
XTIDE_EXTERNAL_DEFINES += -DMODULE_POWER_MANAGEMENT
endif
ifeq ($(CONFIG_XTIDE_SERIAL_SCAN_DETECT),y)
XTIDE_EXTERNAL_DEFINES += -DMODULE_SERIAL -DMODULE_SERIAL_FLOPPY
endif
# 86Box's PC1640 status port can hold the XTIDE CGA-snow bit high forever,
# which traps the external ROM in its 3DAh retrace wait loop during POST.
# Keep the upstream snow-elimination path for other machine targets only.
ifneq ($(CONFIG_MACHINE_TARGET),pc1640dd)
XTIDE_EXTERNAL_DEFINES += -DELIMINATE_CGA_SNOW
endif
# Embedded PC1640 path is intentionally the tiny 4 KiB exception so it can be
# staged inside the 16 KiB motherboard ROS and relocated into RAM at POST time.
XTIDE_EMBEDDED_DEFINES := \
  -DMODULE_STRINGS_COMPRESSED -DMODULE_8BIT_IDE \
  -DNO_ATAID_VALIDATION -DNO_ATAID_CORRECTION -DCLD_NEEDED
XTIDE_COMMON_PATCH_DEFINES := \
  -DXTIDE_EBIOS_MAX_SECTORS=$(if $(CONFIG_XTIDE_EDD_MAX_SECTORS),$(CONFIG_XTIDE_EDD_MAX_SECTORS),127) \
  -DXTIDE_TIMEOUT_DRQ=$(if $(CONFIG_XTIDE_TIMEOUT_DRQ),$(CONFIG_XTIDE_TIMEOUT_DRQ),255) \
  -DXTIDE_TIMEOUT_BSY=$(if $(CONFIG_XTIDE_TIMEOUT_BSY),$(CONFIG_XTIDE_TIMEOUT_BSY),47) \
  -DXTIDE_TIMEOUT_DRDY=$(if $(CONFIG_XTIDE_TIMEOUT_DRDY),$(CONFIG_XTIDE_TIMEOUT_DRDY),47)
XTIDE_CPU_GUARD_DEFINES := \
  -UUSE_NEC_V -UUSE_186 -UUSE_286 -UUSE_386 -UUSE_UNDOC_INTEL
XTIDE_EXTERNAL_XT_DEFINES := \
  $(XTIDE_EXTERNAL_DEFINES) -DBIOS_SIZE=$(XTIDE_EXTERNAL_XT_ROM_SIZE) \
  $(XTIDE_COMMON_PATCH_DEFINES)
XTIDE_EXTERNAL_XTL_DEFINES := \
  $(XTIDE_EXTERNAL_DEFINES) -DBIOS_SIZE=$(XTIDE_EXTERNAL_XTL_ROM_SIZE) \
  $(XTIDE_COMMON_PATCH_DEFINES)
XTIDE_EMBEDDED_DEFINES += -DBIOS_SIZE=$(XTIDE_EMBEDDED_ROM_SIZE) $(XTIDE_COMMON_PATCH_DEFINES)
XTIDE_INCLUDES := \
  -I$(XTIDE_SRC)/Inc/ -I$(XTIDE_SRC)/Inc/Controllers/ \
  -I$(XTIDE_SRC)/Src/ -I$(XTIDE_SRC)/Src/Handlers/ \
  -I$(XTIDE_SRC)/Src/Handlers/Int13h/ -I$(XTIDE_SRC)/Src/Handlers/Int13h/EBIOS/ \
  -I$(XTIDE_SRC)/Src/Handlers/Int13h/Tools/ -I$(XTIDE_SRC)/Src/Handlers/Int19h/ \
  -I$(XTIDE_SRC)/Src/Device/ -I$(XTIDE_SRC)/Src/Device/IDE/ \
  -I$(XTIDE_SRC)/Src/Device/MemoryMappedIDE/ -I$(XTIDE_SRC)/Src/Device/Serial/ \
  -I$(XTIDE_SRC)/Src/Initialization/ -I$(XTIDE_SRC)/Src/Initialization/AdvancedAta/ \
  -I$(XTIDE_SRC)/Src/Menus/ -I$(XTIDE_SRC)/Src/Menus/BootMenu/ \
  -I$(XTIDE_SRC)/Src/Libraries/ -I$(XTIDE_SRC)/Src/VariablesAndDPTs/ \
  -I$(XTIDE_REPO)/Assembly_Library/Inc/ -I$(XTIDE_REPO)/Assembly_Library/Src/ \
  -I$(XTIDE_REPO)/Assembly_Library/Src/Display/ -I$(XTIDE_REPO)/Assembly_Library/Src/File/ \
  -I$(XTIDE_REPO)/Assembly_Library/Src/Keyboard/ -I$(XTIDE_REPO)/Assembly_Library/Src/Menu/ \
  -I$(XTIDE_REPO)/Assembly_Library/Src/Menu/Dialog/ -I$(XTIDE_REPO)/Assembly_Library/Src/String/ \
  -I$(XTIDE_REPO)/Assembly_Library/Src/Time/ -I$(XTIDE_REPO)/Assembly_Library/Src/Util/ \
  -I$(XTIDE_REPO)/Assembly_Library/Src/Serial/ \
  -I$(XTIDE_SRC)/Inc/

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
  src/video_pega_inrom.c \
  src/optionrom.c \
  src/floppy.c \
  src/serial.c \
  src/printer.c \
  src/rtc.c \
  src/ems.c

ASM_SRCS := \
  src/optionrom_entry.S \
  src/intcall_wrappers.S \
  src/reset_entry.S

ifneq ($(CONFIG_MACHINE_SRC),)
SRCS += $(CONFIG_MACHINE_SRC)
endif

ifeq ($(CONFIG_VIDEO_PEGA_INROM_DRIVER),y)
SRCS += src/video_pega_font_en.c
endif

ifeq ($(CONFIG_XTIDE_EMBEDDED_IN_ROS),y)
CFLAGS += -DBIOS_CFG_XTIDE_EMBEDDED_ROM_SIZE=$(XTIDE_EMBEDDED_ROM_SIZE)
SRCS += src/xtide_compressed.c
ASM_SRCS += src/xtide_exo.S
endif

# The PC1640 ROS split (ROM below 0x3065, compat hole, ROM high) only works if
# .text.low stays under 0x3065 bytes. The full BIOS is slightly over the 16 KiB
# payload budget; omitting these objects when the services are disabled saves
# ~1.2 KiB. Embedded XTIDE (CONFIG_XTIDE_EMBEDDED_IN_ROS) needs extra headroom.
ifneq ($(CONFIG_SERIAL_INT14_ENABLED),y)
ifeq ($(findstring BIOS_CFG_DEBUG_COM1=1,$(CONFIG_BIOS_DEBUG_DEFS)),)
ifeq ($(findstring BIOS_CFG_DEBUG_PORT_E9=1,$(CONFIG_BIOS_DEBUG_DEFS)),)
SRCS := $(filter-out src/serial.c,$(SRCS))
endif
endif
endif
ifneq ($(CONFIG_PRINTER_ENABLED),y)
SRCS := $(filter-out src/printer.c,$(SRCS))
endif

ifeq ($(CONFIG_FLOPPY_DRIVES),0)
ifneq ($(CONFIG_XTIDE_ENABLED),y)
SRCS := $(filter-out src/floppy.c,$(SRCS))
endif
endif
ifneq ($(CONFIG_EMS_ENABLED),y)
SRCS := $(filter-out src/ems.c,$(SRCS))
endif

OBJS := $(SRCS:src/%.c=build/%.o) $(ASM_SRCS:src/%.S=build/%.o)
DEPS := $(OBJS:.o=.d)

ifeq ($(CONFIG_XTIDE_EMBEDDED_IN_ROS),y)
build/bios.elf: build/xtide_embedded_payload.h
endif
BOOT_FLOPPY_IMAGE ?= $(CONFIG_BOOT_FLOPPY_IMAGE)
BOOT_FLOPPY_IMAGE ?= test_media/ibm_dos_330_disk1_360k.img
SELFTEST_STAGE2_SECTORS := 6

ROM_RESERVED_ARGS :=
ifeq ($(CONFIG_EXECUTE_IN_PLACE),)
ifneq ($(CONFIG_ROM_COMPAT_HOLE_SIZE),0)
ROM_RESERVED_ARGS += --reserved-range $(CONFIG_ROM_COMPAT_HOLE_OFFSET):$(CONFIG_ROM_COMPAT_HOLE_SIZE)
endif
endif

ROM_COMPAT_SEGMENT := $(CONFIG_RUNTIME_SEGMENT)
ifeq ($(CONFIG_EXECUTE_IN_PLACE),y)
ROM_COMPAT_SEGMENT := $(CONFIG_ROM_ENTRY_SEGMENT)
endif

DEFAULT_MACHINE_TARGET := $(if $(CONFIG_MACHINE_TARGET),$(CONFIG_MACHINE_TARGET),pc1640dd)

TARGET_ARTIFACTS := build/bios.bin build/40043.v3 build/40044.v3
ifeq ($(CONFIG_VIDEO_PEGA_STANDALONE_ROM),y)
TARGET_ARTIFACTS += build/pega_video_32k.bin build/pega_video_40043.v3 build/pega_video_40044.v3
endif
ifeq ($(CONFIG_XTIDE_ENABLED),y)
TARGET_ARTIFACTS += $(XTIDE_EXTERNAL_XT_ROM) $(XTIDE_EXTERNAL_XTL_ROM)
ifeq ($(CONFIG_XTIDE_EMBEDDED_IN_ROS),y)
TARGET_ARTIFACTS += $(XTIDE_EMBEDDED_ROM)
endif
endif

all: $(CONFIG_FILE) $(CONFIG_HEADER) $(TARGET_ARTIFACTS)

# GDB: ROM-linear breakpoints for 86Box (0xFC000 + nm VMA; not `break bios_main`).
.PHONY: pc1640-gdb-breaks
pc1640-gdb-breaks: build/bios.elf tools/gen_pc1640_gdb_breakpoints.py | build
	$(PYTHON) tools/gen_pc1640_gdb_breakpoints.py build/bios.elf build/pc1640_gdb_breakpoints.gdb --nm $(TOOLCHAIN)/ia16-elf-nm

build:
	mkdir -p build

.PHONY: FORCE
FORCE:

$(CONFIG_SOURCE_STAMP): FORCE | build
	@tmp="$@.tmp"; \
	printf '%s\n' '$(abspath $(CONFIG_FILE))' > "$$tmp"; \
	if [ ! -f "$@" ] || ! cmp -s "$$tmp" "$@"; then \
		mv "$$tmp" "$@"; \
	else \
		rm -f "$$tmp"; \
	fi

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

$(CONFIG_HEADER) $(CONFIG_MK): $(CONFIG_FILE) $(CONFIG_SOURCE_STAMP) scripts/mkconfig.sh | build
	@scripts/mkconfig.sh $(CONFIG_FILE) $(CONFIG_HEADER) $(CONFIG_MK)

$(CONFIG_FILE):
	@if [ ! -f "$(CONFIG_FILE)" ]; then \
		if [ "$(CONFIG_FILE)" = ".config" ]; then \
			echo '*** No .config found, running defconfig...'; \
			yes '' | config/Configure -d config.in; \
			scripts/mkconfig.sh .config $(CONFIG_HEADER) $(CONFIG_MK); \
		else \
			echo "*** Missing config file: $(CONFIG_FILE)"; \
			exit 1; \
		fi; \
	fi

# ---------------------------------------------------------------
# BIOS build
# ---------------------------------------------------------------

build/%.o: src/%.c $(CONFIG_HEADER) | build
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

build/%.o: src/%.S $(CONFIG_HEADER) | build
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

-include $(DEPS)

# ---------------------------------------------------------------
# XTIDE option ROMs (external XT Large plus embedded XT Tiny exception)
# ---------------------------------------------------------------
$(XTIDE_EXTERNAL_XT_RAW): $(XTIDE_SRC)/Src/Main.asm $(CONFIG_MK) Makefile | build
	$(NASM) $< -f bin $(XTIDE_INCLUDES) $(XTIDE_CPU_GUARD_DEFINES) \
	  $(XTIDE_EXTERNAL_XT_DEFINES) -Worphan-labels -Ox -o $@

$(XTIDE_EXTERNAL_XT_ROM): $(XTIDE_EXTERNAL_XT_RAW) tools/patch_xtide_image.py $(CONFIG_MK) Makefile | build
	$(PYTHON) tools/patch_xtide_image.py \
	  --input $< \
	  --output $@ \
	  --rom-size $(XTIDE_EXTERNAL_XT_ROM_SIZE) \
	  --base 0x$(if $(CONFIG_XTIDE_BASE),$(CONFIG_XTIDE_BASE),0300) \
	  --probe-master $(if $(filter y,$(CONFIG_XTIDE_PROBE_MASTER)),y,n) \
	  --probe-slave $(if $(filter y,$(CONFIG_XTIDE_PROBE_SLAVE)),y,n) \
	  --full-mode $(if $(filter y,$(CONFIG_XTIDE_FULL_MODE)),y,n) \
	  --steal-size $(if $(CONFIG_XTIDE_STEAL_SIZE),$(CONFIG_XTIDE_STEAL_SIZE),1) \
	  --clear-bda-hd-count $(if $(filter y,$(CONFIG_XTIDE_CLEAR_BDA_HD_COUNT)),y,n) \
	  --serial-scan-detect $(if $(filter y,$(CONFIG_XTIDE_SERIAL_SCAN_DETECT)),y,n) \
	  --display-mode 0x$(if $(CONFIG_XTIDE_BOOT_DISPLAY_MODE),$(CONFIG_XTIDE_BOOT_DISPLAY_MODE),0004) \
	  --boot-timeout $(if $(CONFIG_XTIDE_BOOT_TIMEOUT_TICKS),$(CONFIG_XTIDE_BOOT_TIMEOUT_TICKS),546) \
	  --boot-drive 0x$(if $(CONFIG_XTIDE_BOOT_DRIVE),$(CONFIG_XTIDE_BOOT_DRIVE),80) \
	  --min-floppy-count $(if $(CONFIG_XTIDE_MIN_FLOPPY_COUNT),$(CONFIG_XTIDE_MIN_FLOPPY_COUNT),0) \
	  --idle-timeout $(if $(CONFIG_XTIDE_IDLE_TIMEOUT),$(CONFIG_XTIDE_IDLE_TIMEOUT),0) \
	  --master-block-mode $(if $(filter y,$(CONFIG_XTIDE_MASTER_BLOCK_MODE)),y,n) \
	  --slave-block-mode $(if $(filter y,$(CONFIG_XTIDE_SLAVE_BLOCK_MODE)),y,n) \
	  --master-translation $(if $(CONFIG_XTIDE_MASTER_TRANSLATION_MODE),$(CONFIG_XTIDE_MASTER_TRANSLATION_MODE),3) \
	  --slave-translation $(if $(CONFIG_XTIDE_SLAVE_TRANSLATION_MODE),$(CONFIG_XTIDE_SLAVE_TRANSLATION_MODE),3) \
	  --master-write-cache $(if $(CONFIG_XTIDE_MASTER_WRITE_CACHE),$(CONFIG_XTIDE_MASTER_WRITE_CACHE),1) \
	  --slave-write-cache $(if $(CONFIG_XTIDE_SLAVE_WRITE_CACHE),$(CONFIG_XTIDE_SLAVE_WRITE_CACHE),1) \
	  --master-user-chs $(if $(filter y,$(CONFIG_XTIDE_MASTER_USER_CHS)),y,n) \
	  --slave-user-chs $(if $(filter y,$(CONFIG_XTIDE_SLAVE_USER_CHS)),y,n) \
	  --master-cylinders $(if $(CONFIG_XTIDE_MASTER_CYLINDERS),$(CONFIG_XTIDE_MASTER_CYLINDERS),1024) \
	  --slave-cylinders $(if $(CONFIG_XTIDE_SLAVE_CYLINDERS),$(CONFIG_XTIDE_SLAVE_CYLINDERS),1024) \
	  --master-heads $(if $(CONFIG_XTIDE_MASTER_HEADS),$(CONFIG_XTIDE_MASTER_HEADS),16) \
	  --slave-heads $(if $(CONFIG_XTIDE_SLAVE_HEADS),$(CONFIG_XTIDE_SLAVE_HEADS),16) \
	  --master-sectors $(if $(CONFIG_XTIDE_MASTER_SECTORS),$(CONFIG_XTIDE_MASTER_SECTORS),63) \
	  --slave-sectors $(if $(CONFIG_XTIDE_SLAVE_SECTORS),$(CONFIG_XTIDE_SLAVE_SECTORS),63) \
	  --master-user-lba $(if $(filter y,$(CONFIG_XTIDE_MASTER_USER_LBA)),y,n) \
	  --slave-user-lba $(if $(filter y,$(CONFIG_XTIDE_SLAVE_USER_LBA)),y,n) \
	  --master-max-lba 0x$(if $(CONFIG_XTIDE_MASTER_MAX_LBA),$(CONFIG_XTIDE_MASTER_MAX_LBA),0FFFFFFF) \
	  --slave-max-lba 0x$(if $(CONFIG_XTIDE_SLAVE_MAX_LBA),$(CONFIG_XTIDE_SLAVE_MAX_LBA),0FFFFFFF)

$(XTIDE_EXTERNAL_XTL_RAW): $(XTIDE_SRC)/Src/Main.asm $(CONFIG_MK) Makefile | build
	$(NASM) $< -f bin $(XTIDE_INCLUDES) $(XTIDE_CPU_GUARD_DEFINES) \
	  $(XTIDE_EXTERNAL_XTL_DEFINES) -Worphan-labels -Ox -o $@

$(XTIDE_EXTERNAL_XTL_ROM): $(XTIDE_EXTERNAL_XTL_RAW) tools/patch_xtide_image.py $(CONFIG_MK) Makefile | build
	$(PYTHON) tools/patch_xtide_image.py \
	  --input $< \
	  --output $@ \
	  --rom-size $(XTIDE_EXTERNAL_XTL_ROM_SIZE) \
	  --base 0x$(if $(CONFIG_XTIDE_BASE),$(CONFIG_XTIDE_BASE),0300) \
	  --probe-master $(if $(filter y,$(CONFIG_XTIDE_PROBE_MASTER)),y,n) \
	  --probe-slave $(if $(filter y,$(CONFIG_XTIDE_PROBE_SLAVE)),y,n) \
	  --full-mode $(if $(filter y,$(CONFIG_XTIDE_FULL_MODE)),y,n) \
	  --steal-size $(if $(CONFIG_XTIDE_STEAL_SIZE),$(CONFIG_XTIDE_STEAL_SIZE),1) \
	  --clear-bda-hd-count $(if $(filter y,$(CONFIG_XTIDE_CLEAR_BDA_HD_COUNT)),y,n) \
	  --serial-scan-detect $(if $(filter y,$(CONFIG_XTIDE_SERIAL_SCAN_DETECT)),y,n) \
	  --display-mode 0x$(if $(CONFIG_XTIDE_BOOT_DISPLAY_MODE),$(CONFIG_XTIDE_BOOT_DISPLAY_MODE),0004) \
	  --boot-timeout $(if $(CONFIG_XTIDE_BOOT_TIMEOUT_TICKS),$(CONFIG_XTIDE_BOOT_TIMEOUT_TICKS),546) \
	  --boot-drive 0x$(if $(CONFIG_XTIDE_BOOT_DRIVE),$(CONFIG_XTIDE_BOOT_DRIVE),80) \
	  --min-floppy-count $(if $(CONFIG_XTIDE_MIN_FLOPPY_COUNT),$(CONFIG_XTIDE_MIN_FLOPPY_COUNT),0) \
	  --idle-timeout $(if $(CONFIG_XTIDE_IDLE_TIMEOUT),$(CONFIG_XTIDE_IDLE_TIMEOUT),0) \
	  --master-block-mode $(if $(filter y,$(CONFIG_XTIDE_MASTER_BLOCK_MODE)),y,n) \
	  --slave-block-mode $(if $(filter y,$(CONFIG_XTIDE_SLAVE_BLOCK_MODE)),y,n) \
	  --master-translation $(if $(CONFIG_XTIDE_MASTER_TRANSLATION_MODE),$(CONFIG_XTIDE_MASTER_TRANSLATION_MODE),3) \
	  --slave-translation $(if $(CONFIG_XTIDE_SLAVE_TRANSLATION_MODE),$(CONFIG_XTIDE_SLAVE_TRANSLATION_MODE),3) \
	  --master-write-cache $(if $(CONFIG_XTIDE_MASTER_WRITE_CACHE),$(CONFIG_XTIDE_MASTER_WRITE_CACHE),1) \
	  --slave-write-cache $(if $(CONFIG_XTIDE_SLAVE_WRITE_CACHE),$(CONFIG_XTIDE_SLAVE_WRITE_CACHE),1) \
	  --master-user-chs $(if $(filter y,$(CONFIG_XTIDE_MASTER_USER_CHS)),y,n) \
	  --slave-user-chs $(if $(filter y,$(CONFIG_XTIDE_SLAVE_USER_CHS)),y,n) \
	  --master-cylinders $(if $(CONFIG_XTIDE_MASTER_CYLINDERS),$(CONFIG_XTIDE_MASTER_CYLINDERS),1024) \
	  --slave-cylinders $(if $(CONFIG_XTIDE_SLAVE_CYLINDERS),$(CONFIG_XTIDE_SLAVE_CYLINDERS),1024) \
	  --master-heads $(if $(CONFIG_XTIDE_MASTER_HEADS),$(CONFIG_XTIDE_MASTER_HEADS),16) \
	  --slave-heads $(if $(CONFIG_XTIDE_SLAVE_HEADS),$(CONFIG_XTIDE_SLAVE_HEADS),16) \
	  --master-sectors $(if $(CONFIG_XTIDE_MASTER_SECTORS),$(CONFIG_XTIDE_MASTER_SECTORS),63) \
	  --slave-sectors $(if $(CONFIG_XTIDE_SLAVE_SECTORS),$(CONFIG_XTIDE_SLAVE_SECTORS),63) \
	  --master-user-lba $(if $(filter y,$(CONFIG_XTIDE_MASTER_USER_LBA)),y,n) \
	  --slave-user-lba $(if $(filter y,$(CONFIG_XTIDE_SLAVE_USER_LBA)),y,n) \
	  --master-max-lba 0x$(if $(CONFIG_XTIDE_MASTER_MAX_LBA),$(CONFIG_XTIDE_MASTER_MAX_LBA),0FFFFFFF) \
	  --slave-max-lba 0x$(if $(CONFIG_XTIDE_SLAVE_MAX_LBA),$(CONFIG_XTIDE_SLAVE_MAX_LBA),0FFFFFFF)

$(XTIDE_EMBEDDED_RAW): $(XTIDE_SRC)/Src/Main.asm $(CONFIG_MK) Makefile | build
	$(NASM) $< -f bin $(XTIDE_INCLUDES) $(XTIDE_CPU_GUARD_DEFINES) \
	  $(XTIDE_EMBEDDED_DEFINES) -Worphan-labels -Ox -o $@

$(XTIDE_EMBEDDED_ROM): $(XTIDE_EMBEDDED_RAW) tools/patch_xtide_image.py $(CONFIG_MK) Makefile | build
	$(PYTHON) tools/patch_xtide_image.py \
	  --input $< \
	  --output $@ \
	  --rom-size $(XTIDE_EMBEDDED_ROM_SIZE) \
	  --base 0x$(if $(CONFIG_XTIDE_BASE),$(CONFIG_XTIDE_BASE),0300) \
	  --probe-master $(if $(filter y,$(CONFIG_XTIDE_PROBE_MASTER)),y,n) \
	  --probe-slave $(if $(filter y,$(CONFIG_XTIDE_PROBE_SLAVE)),y,n) \
	  --full-mode $(if $(filter y,$(CONFIG_XTIDE_FULL_MODE)),y,n) \
	  --steal-size $(if $(CONFIG_XTIDE_STEAL_SIZE),$(CONFIG_XTIDE_STEAL_SIZE),1) \
	  --clear-bda-hd-count $(if $(filter y,$(CONFIG_XTIDE_CLEAR_BDA_HD_COUNT)),y,n) \
	  --serial-scan-detect $(if $(filter y,$(CONFIG_XTIDE_SERIAL_SCAN_DETECT)),y,n) \
	  --display-mode 0x$(if $(CONFIG_XTIDE_BOOT_DISPLAY_MODE),$(CONFIG_XTIDE_BOOT_DISPLAY_MODE),0004) \
	  --boot-timeout $(if $(CONFIG_XTIDE_BOOT_TIMEOUT_TICKS),$(CONFIG_XTIDE_BOOT_TIMEOUT_TICKS),546) \
	  --boot-drive 0x$(if $(CONFIG_XTIDE_BOOT_DRIVE),$(CONFIG_XTIDE_BOOT_DRIVE),80) \
	  --min-floppy-count $(if $(CONFIG_XTIDE_MIN_FLOPPY_COUNT),$(CONFIG_XTIDE_MIN_FLOPPY_COUNT),0) \
	  --idle-timeout $(if $(CONFIG_XTIDE_IDLE_TIMEOUT),$(CONFIG_XTIDE_IDLE_TIMEOUT),0) \
	  --master-block-mode $(if $(filter y,$(CONFIG_XTIDE_MASTER_BLOCK_MODE)),y,n) \
	  --slave-block-mode $(if $(filter y,$(CONFIG_XTIDE_SLAVE_BLOCK_MODE)),y,n) \
	  --master-translation $(if $(CONFIG_XTIDE_MASTER_TRANSLATION_MODE),$(CONFIG_XTIDE_MASTER_TRANSLATION_MODE),3) \
	  --slave-translation $(if $(CONFIG_XTIDE_SLAVE_TRANSLATION_MODE),$(CONFIG_XTIDE_SLAVE_TRANSLATION_MODE),3) \
	  --master-write-cache $(if $(CONFIG_XTIDE_MASTER_WRITE_CACHE),$(CONFIG_XTIDE_MASTER_WRITE_CACHE),1) \
	  --slave-write-cache $(if $(CONFIG_XTIDE_SLAVE_WRITE_CACHE),$(CONFIG_XTIDE_SLAVE_WRITE_CACHE),1) \
	  --master-user-chs $(if $(filter y,$(CONFIG_XTIDE_MASTER_USER_CHS)),y,n) \
	  --slave-user-chs $(if $(filter y,$(CONFIG_XTIDE_SLAVE_USER_CHS)),y,n) \
	  --master-cylinders $(if $(CONFIG_XTIDE_MASTER_CYLINDERS),$(CONFIG_XTIDE_MASTER_CYLINDERS),1024) \
	  --slave-cylinders $(if $(CONFIG_XTIDE_SLAVE_CYLINDERS),$(CONFIG_XTIDE_SLAVE_CYLINDERS),1024) \
	  --master-heads $(if $(CONFIG_XTIDE_MASTER_HEADS),$(CONFIG_XTIDE_MASTER_HEADS),16) \
	  --slave-heads $(if $(CONFIG_XTIDE_SLAVE_HEADS),$(CONFIG_XTIDE_SLAVE_HEADS),16) \
	  --master-sectors $(if $(CONFIG_XTIDE_MASTER_SECTORS),$(CONFIG_XTIDE_MASTER_SECTORS),63) \
	  --slave-sectors $(if $(CONFIG_XTIDE_SLAVE_SECTORS),$(CONFIG_XTIDE_SLAVE_SECTORS),63) \
	  --master-user-lba $(if $(filter y,$(CONFIG_XTIDE_MASTER_USER_LBA)),y,n) \
	  --slave-user-lba $(if $(filter y,$(CONFIG_XTIDE_SLAVE_USER_LBA)),y,n) \
	  --master-max-lba 0x$(if $(CONFIG_XTIDE_MASTER_MAX_LBA),$(CONFIG_XTIDE_MASTER_MAX_LBA),0FFFFFFF) \
	  --slave-max-lba 0x$(if $(CONFIG_XTIDE_SLAVE_MAX_LBA),$(CONFIG_XTIDE_SLAVE_MAX_LBA),0FFFFFFF)

$(EXOMIZER): $(EXOMIZER_TOOL) | build
	$(PYTHON) $(EXOMIZER_TOOL) $@

ifeq ($(CONFIG_XTIDE_EMBEDDED_IN_ROS),y)
build/xtide_packed.bin: $(XTIDE_EMBEDDED_ROM) $(EXOMIZER) Makefile | build
	$(EXOMIZER) raw -P 47 $< -o $@

build/xtide_embedded_payload.h: build/xtide_packed.bin tools/bin2c_split.py Makefile | build
	$(PYTHON) tools/bin2c_split.py \
	  --input $< \
	  --output $@ \
	  --array-name xtide_embedded_payload \
	  --split-size $(XTIDE_EMBEDDED_ROM_LO_MAX) \
	  --section-low .rodata.xtide_embedded_payload_lo \
	  --section-high .rodata.xtide_embedded_payload_hi

build/xtide_compressed.o: build/xtide_embedded_payload.h
endif

# ---------------------------------------------------------------
# BIOS payload
# ---------------------------------------------------------------

# Stage 1: Compile the BIOS payload
build/bios.elf: $(OBJS) $(LINKER_SCRIPT) | build
	$(CC) $(CFLAGS) $(OBJS) -o $@ $(LDFLAGS)

build/bios-payload.bin: build/bios.elf | build
	$(OBJCOPY) -O binary --gap-fill 0xFF $< $@
	$(PYTHON) tools/check_rom_payload_fit.py $@ 0x3FF0

ifeq ($(CONFIG_EXECUTE_IN_PLACE),y)

ROM_STUB_ARG :=
ROM_PAYLOAD := build/bios-payload.bin

else

# Raw ROM payload: copy the BIOS payload directly into the runtime segment.
build/romstub.bin: src/romstub_raw.asm build/bios-payload.bin | build
	$(NASM) -f bin \
	  -DDEST_SEG=$(CONFIG_RUNTIME_SEGMENT) \
	  -DROM_SEG=$(CONFIG_ROM_ENTRY_SEGMENT) \
	  -DCOMPAT_HOLE_OFFSET=$(CONFIG_ROM_COMPAT_HOLE_OFFSET) \
	  -DCOMPAT_HOLE_SIZE=$(CONFIG_ROM_COMPAT_HOLE_SIZE) \
	  -DDEST_SIZE=$$(wc -c < build/bios-payload.bin) \
	  $< -o $@

ROM_STUB_ARG := --stub build/romstub.bin
ROM_PAYLOAD := build/bios-payload.bin

endif

build/bios.bin: $(ROM_PAYLOAD) build/bios.elf tools/build_rom_image.py tools/patch_rom_compat_vectors.py tools/fix_ros_checksum.py $(if $(ROM_STUB_ARG),build/romstub.bin) | build
	$(PYTHON) tools/build_rom_image.py \
	  $(ROM_STUB_ARG) \
	  --rom-size $(CONFIG_ROM_IMAGE_SIZE) \
	  --entry-segment $(CONFIG_ROM_ENTRY_SEGMENT) \
	  --machine-id-byte $(CONFIG_ROM_MACHINE_ID_BYTE) \
	  $(ROM_RESERVED_ARGS) \
	  $(ROM_PAYLOAD) $@
ifeq ($(CONFIG_ROM_COMPAT_PATCH_ENABLED),y)
	$(PYTHON) tools/patch_rom_compat_vectors.py --nm $(NM) --elf build/bios.elf --rom $@ --segment $(ROM_COMPAT_SEGMENT)
endif
ifeq ($(CONFIG_ROM_ROS_CHECKSUM_ENABLED),y)
	$(PYTHON) tools/fix_ros_checksum.py $@
endif

build/bios.rom: build/bios.bin | build
	cp $< $@

# Stage 5: Split into interleaved chip files with mirrored halves
build/40044.v3: build/bios.bin
	$(PYTHON) -c "from pathlib import Path; bio=Path('build/bios.bin').read_bytes(); half=bio[0::2]; Path('build/40044.v3').write_bytes(half + half)"

build/40043.v3: build/bios.bin
	$(PYTHON) -c "from pathlib import Path; bio=Path('build/bios.bin').read_bytes(); half=bio[1::2]; Path('build/40043.v3').write_bytes(half + half)"

ORIGINAL_SYSTEM_ROM_EVEN := build/original_40044.v3
ORIGINAL_SYSTEM_ROM_ODD := build/original_40043.v3

$(ORIGINAL_SYSTEM_ROM_EVEN): Original-firmware/decompiled/C16/40044.v3 Makefile | build
	cp $< $@

$(ORIGINAL_SYSTEM_ROM_ODD): Original-firmware/decompiled/C16/40043.v3 Makefile | build
	cp $< $@

# ---------------------------------------------------------------
# Standalone Paradise PEGA video option ROM (32 KiB @ C00000, for socket / 86Box)
# ---------------------------------------------------------------

PEGA_VIDEO_ROM_OBJDIR := build/pega_video_rom
PEGA_VIDEO_ROM_LD := src/linker_pega_video_rom.ld
PEGA_VIDEO_ROM_ELF := build/pega_video_rom.elf
PEGA_VIDEO_ROM_BIN := build/pega_video_32k.bin

PEGA_VIDEO_ROM_LINK_OBJS := \
	$(PEGA_VIDEO_ROM_OBJDIR)/video_pega_rom_entry.o \
	$(PEGA_VIDEO_ROM_OBJDIR)/video_pega_rom_int10.o \
	$(PEGA_VIDEO_ROM_OBJDIR)/video_pega_rom_init.o \
	$(PEGA_VIDEO_ROM_OBJDIR)/video_pega_rom_tables.o \
	$(PEGA_VIDEO_ROM_OBJDIR)/video_pega_inrom.o \
	$(PEGA_VIDEO_ROM_OBJDIR)/video_pega_font_en.o \
	$(PEGA_VIDEO_ROM_OBJDIR)/intcall.o

PEGA_VIDEO_ROM_CFLAGS := $(CFLAGS) -DVIDEO_PEGA_ROM_BUILD=1
PEGA_VIDEO_ROM_LDFLAGS := -nostdlib -T $(PEGA_VIDEO_ROM_LD) \
	-Wl,-Map,build/pega_video_rom.map -Wl,--gc-sections

.PHONY: video-pega-rom

video-pega-rom: $(CONFIG_HEADER) $(PEGA_VIDEO_ROM_BIN) build/pega_video_40043.v3 build/pega_video_40044.v3

$(PEGA_VIDEO_ROM_OBJDIR): | build
	mkdir -p $(PEGA_VIDEO_ROM_OBJDIR)

$(PEGA_VIDEO_ROM_OBJDIR)/%.o: src/%.c $(CONFIG_HEADER) | $(PEGA_VIDEO_ROM_OBJDIR)
	$(CC) $(PEGA_VIDEO_ROM_CFLAGS) -c $< -o $@

$(PEGA_VIDEO_ROM_OBJDIR)/%.o: src/%.S $(CONFIG_HEADER) | $(PEGA_VIDEO_ROM_OBJDIR)
	$(CC) $(PEGA_VIDEO_ROM_CFLAGS) -c $< -o $@

$(PEGA_VIDEO_ROM_ELF): $(PEGA_VIDEO_ROM_LINK_OBJS) | build
	$(CC) $(PEGA_VIDEO_ROM_CFLAGS) $(PEGA_VIDEO_ROM_LINK_OBJS) -o $@ $(PEGA_VIDEO_ROM_LDFLAGS)

build/pega_video_rom_raw.bin: $(PEGA_VIDEO_ROM_ELF) | build
	$(OBJCOPY) -O binary $< $@

$(PEGA_VIDEO_ROM_BIN): build/pega_video_rom_raw.bin tools/fix_option_rom_checksum.py | build
	$(PYTHON) -c "from pathlib import Path; \
	  r=Path('build/pega_video_rom_raw.bin').read_bytes(); \
	  Path('$(PEGA_VIDEO_ROM_BIN)').write_bytes(r.ljust(0x8000, bytes([0xFF])))"
	$(PYTHON) tools/fix_option_rom_checksum.py $(PEGA_VIDEO_ROM_BIN)

build/pega_video_40044.v3: $(PEGA_VIDEO_ROM_BIN)
	$(PYTHON) -c "from pathlib import Path; \
	  bio=Path('$(PEGA_VIDEO_ROM_BIN)').read_bytes(); half=bio[0::2]; \
	  Path('build/pega_video_40044.v3').write_bytes(half + half)"

build/pega_video_40043.v3: $(PEGA_VIDEO_ROM_BIN)
	$(PYTHON) -c "from pathlib import Path; \
	  bio=Path('$(PEGA_VIDEO_ROM_BIN)').read_bytes(); half=bio[1::2]; \
	  Path('build/pega_video_40043.v3').write_bytes(half + half)"

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
	EIGHTYSIXBOX_MACHINE_TARGET="$(DEFAULT_MACHINE_TARGET)" \
	EIGHTYSIXBOX_CAPTURE_COM1=$(EIGHTYSIXBOX_CAPTURE_COM1) \
	tools/run_86box_pc1640_debug.sh --image $(BOOT_FLOPPY_IMAGE)

86box-selftest:
	EIGHTYSIXBOX_MACHINE_TARGET="$(DEFAULT_MACHINE_TARGET)" \
	EIGHTYSIXBOX_CAPTURE_COM1=$(EIGHTYSIXBOX_CAPTURE_COM1) \
	tools/run_86box_pc1640_debug.sh --headless --timeout 25 --image build/selftest-360k.img

# Default MS-DOS test media must have 55 AA at 1FEh; 86box-selftest proves INT 19h loads 0:7C00.
msdos-boot-check: build/selftest-360k.img build/40043.v3 build/40044.v3
	$(PYTHON) tools/check_floppy_boot_sector.py $(BOOT_FLOPPY_IMAGE)
	$(MAKE) 86box-selftest

# Headless smoke run with the configured DOS floppy (copy fresh ROMs into 86Box staging).
86box-msdos: build/40043.v3 build/40044.v3
	cp -f build/40043.v3 build/40044.v3 build/86box-roms/machines/pc1640/
	EIGHTYSIXBOX_SKIP_BUILD=1 \
	EIGHTYSIXBOX_CONFIG_FILE="$(CONFIG_FILE)" \
	EIGHTYSIXBOX_MACHINE_TARGET="$(DEFAULT_MACHINE_TARGET)" \
	EIGHTYSIXBOX_CAPTURE_COM1=$(EIGHTYSIXBOX_CAPTURE_COM1) \
	tools/run_86box_pc1640_debug.sh --headless --timeout 120 --image $(BOOT_FLOPPY_IMAGE)

# 86Box with GDB stub + probe_msdos_boot_gdb.py: BIOS loads boot sector at 0:7C00 (55 AA @ 7DFE).
86box-msdos-gdb: build/40043.v3 build/40044.v3
	@img='$(BOOT_FLOPPY_IMAGE)'; test -n "$$img" || img='test_media/ibm_dos_330_disk1_360k.img'; \
	BOOT_FLOPPY_IMAGE="$$img" \
	EIGHTYSIXBOX_CONFIG_FILE="$(CONFIG_FILE)" \
	EIGHTYSIXBOX_MACHINE_TARGET="$(DEFAULT_MACHINE_TARGET)" \
	$(SHELL) tools/run_86box_msdos_gdb_verify.sh

86box-floppy-smoke: 86box-msdos

86box-floppy-smoke-gdb: 86box-msdos-gdb

86box-stability-floppy-only:
	$(MAKE) -j1 CONFIG_FILE="$(PC1640_PROFILE_FLOPPY_ONLY)" build/40043.v3 build/40044.v3
	BOOT_FLOPPY_IMAGE="$(CURDIR)/test_media/ibm_dos_330_disk1_360k.img" \
	EIGHTYSIXBOX_CONFIG_FILE="$(PC1640_PROFILE_FLOPPY_ONLY)" \
	EIGHTYSIXBOX_MACHINE_TARGET=pc1640dd \
	EIGHTYSIXBOX_XTIDE_ENABLED=0 \
	EIGHTYSIXBOX_GDB_PORT=22345 \
	EIGHTYSIXBOX_VM_ROOT="$(CURDIR)/build/86box-floppy-only-gdb" \
	MSDOS_EXPECT_IMAGE="$(CURDIR)/test_media/ibm_dos_330_disk1_360k.img" \
	$(SHELL) tools/run_86box_msdos_gdb_verify.sh

86box-stability-ide-embedded:
	$(MAKE) -j1 CONFIG_FILE="$(PC1640_PROFILE_IDE_EMBEDDED)" build/40043.v3 build/40044.v3
	EIGHTYSIXBOX_CONFIG_FILE="$(PC1640_PROFILE_IDE_EMBEDDED)" \
	EIGHTYSIXBOX_MACHINE_TARGET=pc1640dd \
	EIGHTYSIXBOX_VM_ROOT="$(CURDIR)/build/86box-ide-only-gdb" \
	EIGHTYSIXBOX_IDE_HDD_IMAGE="$(CURDIR)/test_media/MSDOS330-C400-pcjs-fixed.img" \
	EIGHTYSIXBOX_IDE_HDD_CYLINDERS=306 \
	EIGHTYSIXBOX_IDE_HDD_HEADS=4 \
	EIGHTYSIXBOX_IDE_HDD_SPT=17 \
	MSDOS_EXPECT_IMAGE="$(CURDIR)/test_media/MSDOS330-C400-pcjs-fixed.img" \
	$(SHELL) tools/run_86box_ide_gdb_verify.sh

86box-stability-combo-external-floppy:
	$(MAKE) -j1 CONFIG_FILE="$(PC1640_PROFILE_FLOPPY_EXTERNAL_XTIDE)" build/40043.v3 build/40044.v3 $(XTIDE_EXTERNAL_XT_ROM)
	BOOT_FLOPPY_IMAGE="$(CURDIR)/test_media/ibm_dos_330_disk1_360k.img" \
	EIGHTYSIXBOX_CONFIG_FILE="$(PC1640_PROFILE_FLOPPY_EXTERNAL_XTIDE)" \
	EIGHTYSIXBOX_MACHINE_TARGET=pc1640dd \
	EIGHTYSIXBOX_VM_ROOT="$(CURDIR)/build/86box-combo-external-floppy" \
	EIGHTYSIXBOX_IDE_HDD_IMAGE="$(CURDIR)/test_media/MSDOS330-C400-pcjs-fixed.img" \
	EIGHTYSIXBOX_IDE_HDD_CYLINDERS=306 \
	EIGHTYSIXBOX_IDE_HDD_HEADS=4 \
	EIGHTYSIXBOX_IDE_HDD_SPT=17 \
	MSDOS_EXPECT_IMAGE="$(CURDIR)/test_media/ibm_dos_330_disk1_360k.img" \
	$(SHELL) tools/run_86box_msdos_gdb_verify.sh

86box-stability-combo-external-hdd:
	$(MAKE) -j1 CONFIG_FILE="$(PC1640_PROFILE_FLOPPY_EXTERNAL_XTIDE)" build/40043.v3 build/40044.v3 $(XTIDE_EXTERNAL_XT_ROM)
	EIGHTYSIXBOX_CONFIG_FILE="$(PC1640_PROFILE_FLOPPY_EXTERNAL_XTIDE)" \
	EIGHTYSIXBOX_MACHINE_TARGET=pc1640dd \
	EIGHTYSIXBOX_VM_ROOT="$(CURDIR)/build/86box-combo-external-hdd" \
	EIGHTYSIXBOX_IDE_HDD_IMAGE="$(CURDIR)/test_media/MSDOS330-C400-pcjs-fixed.img" \
	EIGHTYSIXBOX_IDE_HDD_CYLINDERS=306 \
	EIGHTYSIXBOX_IDE_HDD_HEADS=4 \
	EIGHTYSIXBOX_IDE_HDD_SPT=17 \
	MSDOS_EXPECT_IMAGE="$(CURDIR)/test_media/MSDOS330-C400-pcjs-fixed.img" \
	$(SHELL) tools/run_86box_ide_gdb_verify.sh

86box-stability-matrix:
	$(MAKE) 86box-stability-floppy-only
	$(MAKE) 86box-stability-ide-embedded
	$(MAKE) 86box-stability-combo-external-floppy
	$(MAKE) 86box-stability-combo-external-hdd

86box-msdos-state-current:
	$(MAKE) -j1 CONFIG_FILE="$(PC1640_PROFILE_FLOPPY_ONLY)" build/40043.v3 build/40044.v3
	BOOT_FLOPPY_IMAGE="$(CURDIR)/test_media/ibm_dos_330_disk1_360k.img" \
	PC1640_STATE_PROFILE=pc1640-floppy \
	EIGHTYSIXBOX_CONFIG_FILE="$(PC1640_PROFILE_FLOPPY_ONLY)" \
	EIGHTYSIXBOX_MACHINE_TARGET=pc1640dd \
	EIGHTYSIXBOX_XTIDE_ENABLED=0 \
	EIGHTYSIXBOX_GDB_PORT=22346 \
	EIGHTYSIXBOX_VM_ROOT="$(CURDIR)/build/86box-msdos-state-current" \
	$(SHELL) tools/run_86box_pc1640_state_capture.sh \
	  --output "$(CURDIR)/build/current-msdos-state.json" \
	  --image "$(CURDIR)/test_media/ibm_dos_330_disk1_360k.img"

86box-msdos-state-original: $(ORIGINAL_SYSTEM_ROM_ODD) $(ORIGINAL_SYSTEM_ROM_EVEN)
	BOOT_FLOPPY_IMAGE="$(CURDIR)/test_media/ibm_dos_330_disk1_360k.img" \
	EIGHTYSIXBOX_CONFIG_FILE="$(PC1640_PROFILE_FLOPPY_ONLY)" \
	EIGHTYSIXBOX_MACHINE_TARGET=pc1640dd \
	EIGHTYSIXBOX_XTIDE_ENABLED=0 \
	EIGHTYSIXBOX_GDB_PORT=22347 \
	EIGHTYSIXBOX_VM_ROOT="$(CURDIR)/build/86box-msdos-state-original" \
	PC1640_SYSTEM_ROM_EVEN="$(CURDIR)/$(ORIGINAL_SYSTEM_ROM_EVEN)" \
	PC1640_SYSTEM_ROM_ODD="$(CURDIR)/$(ORIGINAL_SYSTEM_ROM_ODD)" \
	$(SHELL) tools/run_86box_pc1640_state_capture.sh \
	  --output "$(CURDIR)/build/original-msdos-state.json" \
	  --image "$(CURDIR)/test_media/ibm_dos_330_disk1_360k.img"

86box-msdos-state-check:
	$(MAKE) 86box-msdos-state-current

86box-msdos-state-compare:
	$(MAKE) 86box-msdos-state-check

86box-msdos-ega-state-current:
	$(MAKE) -j1 CONFIG_FILE="$(PC1640_PROFILE_FLOPPY_ONLY)" build/40043.v3 build/40044.v3
	BOOT_FLOPPY_IMAGE="$(CURDIR)/test_media/ibm_dos_330_disk1_360k.img" \
	PC1640_STATE_PROFILE=pc1640-floppy-ega \
	PC1640_BOOT_SIGNATURE_ONLY=1 \
	EIGHTYSIXBOX_CONFIG_FILE="$(PC1640_PROFILE_FLOPPY_ONLY)" \
	EIGHTYSIXBOX_MACHINE_TARGET=pc1640dd \
	EIGHTYSIXBOX_GFXCARD=ega \
	EIGHTYSIXBOX_XTIDE_ENABLED=0 \
	EIGHTYSIXBOX_GDB_PORT=22348 \
	EIGHTYSIXBOX_VM_ROOT="$(CURDIR)/build/86box-msdos-ega-state-current" \
	$(SHELL) tools/run_86box_pc1640_state_capture.sh \
	  --output "$(CURDIR)/build/current-msdos-ega-state.json" \
	  --image "$(CURDIR)/test_media/ibm_dos_330_disk1_360k.img"

86box-msdos-ega-state-original: $(ORIGINAL_SYSTEM_ROM_ODD) $(ORIGINAL_SYSTEM_ROM_EVEN)
	BOOT_FLOPPY_IMAGE="$(CURDIR)/test_media/ibm_dos_330_disk1_360k.img" \
	PC1640_STATE_PROFILE=pc1640-floppy-ega \
	PC1640_BOOT_SIGNATURE_ONLY=1 \
	EIGHTYSIXBOX_CONFIG_FILE="$(PC1640_PROFILE_FLOPPY_ONLY)" \
	EIGHTYSIXBOX_MACHINE_TARGET=pc1640dd \
	EIGHTYSIXBOX_GFXCARD=ega \
	EIGHTYSIXBOX_XTIDE_ENABLED=0 \
	EIGHTYSIXBOX_GDB_PORT=22349 \
	EIGHTYSIXBOX_VM_ROOT="$(CURDIR)/build/86box-msdos-ega-state-original" \
	PC1640_SYSTEM_ROM_EVEN="$(CURDIR)/$(ORIGINAL_SYSTEM_ROM_EVEN)" \
	PC1640_SYSTEM_ROM_ODD="$(CURDIR)/$(ORIGINAL_SYSTEM_ROM_ODD)" \
	$(SHELL) tools/run_86box_pc1640_state_capture.sh \
	  --output "$(CURDIR)/build/original-msdos-ega-state.json" \
	  --image "$(CURDIR)/test_media/ibm_dos_330_disk1_360k.img"

86box-msdos-ega-state-check:
	$(MAKE) 86box-msdos-ega-state-current

86box-msdos-ega-state-compare:
	$(MAKE) 86box-msdos-ega-state-check

86box-xtide-embedded-state:
	$(MAKE) -j1 CONFIG_FILE="$(PC1640_PROFILE_IDE_EMBEDDED)" build/40043.v3 build/40044.v3
	PC1640_STATE_PROFILE=pc1640-xtide-embedded \
	PC1640_STATE_XTIDE_MODE=embedded \
	EIGHTYSIXBOX_CONFIG_FILE="$(PC1640_PROFILE_IDE_EMBEDDED)" \
	EIGHTYSIXBOX_MACHINE_TARGET=pc1640dd \
	EIGHTYSIXBOX_VM_ROOT="$(CURDIR)/build/86box-xtide-embedded-state" \
	EIGHTYSIXBOX_IDE_HDD_IMAGE="$(CURDIR)/test_media/MSDOS330-C400-pcjs-fixed.img" \
	EIGHTYSIXBOX_IDE_HDD_CYLINDERS=306 \
	EIGHTYSIXBOX_IDE_HDD_HEADS=4 \
	EIGHTYSIXBOX_IDE_HDD_SPT=17 \
	$(SHELL) tools/run_86box_pc1640_state_capture.sh \
	  --output "$(CURDIR)/build/xtide-embedded-state.json" \
	  --ide-image "$(CURDIR)/test_media/MSDOS330-C400-pcjs-fixed.img"

86box-xtide-external-state:
	$(MAKE) -j1 CONFIG_FILE="$(PC1640_PROFILE_FLOPPY_EXTERNAL_XTIDE)" build/40043.v3 build/40044.v3 $(XTIDE_EXTERNAL_XT_ROM)
	PC1640_STATE_PROFILE=pc1640-xtide-external \
	PC1640_STATE_XTIDE_MODE=external \
	EIGHTYSIXBOX_CONFIG_FILE="$(PC1640_PROFILE_FLOPPY_EXTERNAL_XTIDE)" \
	EIGHTYSIXBOX_MACHINE_TARGET=pc1640dd \
	EIGHTYSIXBOX_VM_ROOT="$(CURDIR)/build/86box-xtide-external-state" \
	EIGHTYSIXBOX_IDE_HDD_IMAGE="$(CURDIR)/test_media/MSDOS330-C400-pcjs-fixed.img" \
	EIGHTYSIXBOX_IDE_HDD_CYLINDERS=306 \
	EIGHTYSIXBOX_IDE_HDD_HEADS=4 \
	EIGHTYSIXBOX_IDE_HDD_SPT=17 \
	$(SHELL) tools/run_86box_pc1640_state_capture.sh \
	  --output "$(CURDIR)/build/xtide-external-state.json" \
	  --ide-image "$(CURDIR)/test_media/MSDOS330-C400-pcjs-fixed.img"

86box-compat-matrix:
	$(MAKE) 86box-stability-matrix
	$(MAKE) 86box-msdos-state-check
	$(MAKE) 86box-msdos-ega-state-check
	$(MAKE) 86box-xtide-embedded-state
	$(MAKE) 86box-xtide-external-state

86box-selftest-video-trace:
	$(MAKE) -j1 CONFIG_FILE="$(PC1640_PROFILE_FLOPPY_ONLY)" build/selftest-360k.img build/40043.v3 build/40044.v3
	cp build/selftest-360k.img build/selftest-current.img
	EIGHTYSIXBOX_CONFIG_FILE="$(PC1640_PROFILE_FLOPPY_ONLY)" \
	EIGHTYSIXBOX_VM_ROOT="$(CURDIR)/build/86box-vm-current" \
	EIGHTYSIXBOX_CFG="$(CURDIR)/build/86box-vm-current/pc1640dd.cfg" \
	EIGHTYSIXBOX_LOG="$(CURDIR)/build/86box-vm-current/86box.log" \
	EIGHTYSIXBOX_SERIAL_STDERR="$(CURDIR)/build/86box-vm-current/86box.stderr.log" \
	EIGHTYSIXBOX_LPT1_DEVICE=text_prt \
	EIGHTYSIXBOX_MACHINE_TARGET=pc1640dd \
	EIGHTYSIXBOX_XTIDE_ENABLED=0 \
	EIGHTYSIXBOX_GDB_PORT=22350 \
	$(SHELL) tools/run_86box_pc1640_selftest_capture.sh \
	  --image "$(CURDIR)/build/selftest-current.img" \
	  --output "$(CURDIR)/build/current-trace.bin"

86box-selftest-video-trace-original: $(ORIGINAL_SYSTEM_ROM_ODD) $(ORIGINAL_SYSTEM_ROM_EVEN)
	cp build/selftest-360k.img build/selftest-original.img
	EIGHTYSIXBOX_CONFIG_FILE="$(PC1640_PROFILE_FLOPPY_ONLY)" \
	EIGHTYSIXBOX_VM_ROOT="$(CURDIR)/build/86box-vm-original" \
	EIGHTYSIXBOX_CFG="$(CURDIR)/build/86box-vm-original/pc1640.cfg" \
	EIGHTYSIXBOX_LOG="$(CURDIR)/build/86box-vm-original/86box.log" \
	EIGHTYSIXBOX_SERIAL_STDERR="$(CURDIR)/build/86box-vm-original/86box.stderr.log" \
	EIGHTYSIXBOX_LPT1_DEVICE=text_prt \
	SELFTEST_CAPTURE_ALLOW_FAIL=1 \
	PC1640_SYSTEM_ROM_EVEN="$(CURDIR)/$(ORIGINAL_SYSTEM_ROM_EVEN)" \
	PC1640_SYSTEM_ROM_ODD="$(CURDIR)/$(ORIGINAL_SYSTEM_ROM_ODD)" \
	EIGHTYSIXBOX_MACHINE_TARGET=pc1640dd \
	EIGHTYSIXBOX_XTIDE_ENABLED=0 \
	EIGHTYSIXBOX_GDB_PORT=22351 \
	$(SHELL) tools/run_86box_pc1640_selftest_capture.sh \
	  --image "$(CURDIR)/build/selftest-original.img" \
	  --output "$(CURDIR)/build/original-trace.bin"

86box-selftest-video-compare:
	$(MAKE) 86box-selftest-video-trace
	$(MAKE) 86box-selftest-video-trace-original
	$(PYTHON) tools/compare_pc1640_video_trace.py build/current-trace.bin build/original-trace.bin

86box-selftest-ega-video-trace:
	$(MAKE) -j1 CONFIG_FILE="$(PC1640_PROFILE_FLOPPY_ONLY)" build/selftest-360k.img build/40043.v3 build/40044.v3
	cp build/selftest-360k.img build/selftest-ega-current.img
	EIGHTYSIXBOX_CONFIG_FILE="$(PC1640_PROFILE_FLOPPY_ONLY)" \
	EIGHTYSIXBOX_VM_ROOT="$(CURDIR)/build/86box-vm-ega-current" \
	EIGHTYSIXBOX_CFG="$(CURDIR)/build/86box-vm-ega-current/pc1640dd.cfg" \
	EIGHTYSIXBOX_LOG="$(CURDIR)/build/86box-vm-ega-current/86box.log" \
	EIGHTYSIXBOX_SERIAL_STDERR="$(CURDIR)/build/86box-vm-ega-current/86box.stderr.log" \
	EIGHTYSIXBOX_LPT1_DEVICE=text_prt \
	EIGHTYSIXBOX_GFXCARD=ega \
	EIGHTYSIXBOX_MACHINE_TARGET=pc1640dd \
	EIGHTYSIXBOX_XTIDE_ENABLED=0 \
	EIGHTYSIXBOX_GDB_PORT=22352 \
	$(SHELL) tools/run_86box_pc1640_selftest_capture.sh \
	  --image "$(CURDIR)/build/selftest-ega-current.img" \
	  --output "$(CURDIR)/build/current-ega-trace.bin"

86box-selftest-ega-video-trace-original: $(ORIGINAL_SYSTEM_ROM_ODD) $(ORIGINAL_SYSTEM_ROM_EVEN)
	cp build/selftest-360k.img build/selftest-ega-original.img
	EIGHTYSIXBOX_CONFIG_FILE="$(PC1640_PROFILE_FLOPPY_ONLY)" \
	EIGHTYSIXBOX_VM_ROOT="$(CURDIR)/build/86box-vm-ega-original" \
	EIGHTYSIXBOX_CFG="$(CURDIR)/build/86box-vm-ega-original/pc1640.cfg" \
	EIGHTYSIXBOX_LOG="$(CURDIR)/build/86box-vm-ega-original/86box.log" \
	EIGHTYSIXBOX_SERIAL_STDERR="$(CURDIR)/build/86box-vm-ega-original/86box.stderr.log" \
	EIGHTYSIXBOX_LPT1_DEVICE=text_prt \
	SELFTEST_CAPTURE_ALLOW_FAIL=1 \
	EIGHTYSIXBOX_GFXCARD=ega \
	PC1640_SYSTEM_ROM_EVEN="$(CURDIR)/$(ORIGINAL_SYSTEM_ROM_EVEN)" \
	PC1640_SYSTEM_ROM_ODD="$(CURDIR)/$(ORIGINAL_SYSTEM_ROM_ODD)" \
	EIGHTYSIXBOX_MACHINE_TARGET=pc1640dd \
	EIGHTYSIXBOX_XTIDE_ENABLED=0 \
	EIGHTYSIXBOX_GDB_PORT=22353 \
	$(SHELL) tools/run_86box_pc1640_selftest_capture.sh \
	  --image "$(CURDIR)/build/selftest-ega-original.img" \
	  --output "$(CURDIR)/build/original-ega-trace.bin"

86box-selftest-ega-video-compare:
	$(MAKE) 86box-selftest-ega-video-trace
	$(MAKE) 86box-selftest-ega-video-trace-original
	$(PYTHON) tools/compare_pc1640_video_trace.py build/current-ega-trace.bin build/original-ega-trace.bin

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
	EIGHTYSIXBOX_XTIDE_ENABLED=1 \
	EIGHTYSIXBOX_XTIDE_BIOS=none \
	EIGHTYSIXBOX_XTIDE_BASE_IO=0x300 \
	EIGHTYSIXBOX_IDE_HDD_IMAGE="$(CURDIR)/build/ide-smoke-hdd.img" \
	EIGHTYSIXBOX_IDE_HDD_CYLINDERS=306 \
	EIGHTYSIXBOX_IDE_HDD_HEADS=4 \
	EIGHTYSIXBOX_IDE_HDD_SPT=17 \
	EIGHTYSIXBOX_VM_ROOT="$(CURDIR)/build/86box-vm-idesmoke" \
	EIGHTYSIXBOX_CFG="$(CURDIR)/build/86box-vm-idesmoke/$(CONFIG_MACHINE_TARGET).cfg" \
	EIGHTYSIXBOX_LOG="$(CURDIR)/build/86box-vm-idesmoke/86box.log" \
	EIGHTYSIXBOX_SERIAL_STDERR="$(CURDIR)/build/86box-vm-idesmoke/86box.stderr.log" \
	EIGHTYSIXBOX_MACHINE_TARGET="$(CONFIG_MACHINE_TARGET)" \
	BIOS_DEBUG_DEFS="-DBIOS_CFG_DEBUG_PORT_E9=1 -DBIOS_CFG_DEBUG_COM1=0" \
	tools/run_86box_pc1640_debug.sh --headless --timeout 30

86box-ide-smoke-gdb: build/ide-smoke-hdd.img build/40043.v3 build/40044.v3
	EIGHTYSIXBOX_IDE_HDD_IMAGE="$(CURDIR)/build/ide-smoke-hdd.img" \
	EIGHTYSIXBOX_IDE_HDD_CYLINDERS=306 \
	EIGHTYSIXBOX_IDE_HDD_HEADS=4 \
	EIGHTYSIXBOX_IDE_HDD_SPT=17 \
	EIGHTYSIXBOX_CONFIG_FILE="$(CONFIG_FILE)" \
	EIGHTYSIXBOX_MACHINE_TARGET="$(CONFIG_MACHINE_TARGET)" \
	$(SHELL) tools/run_86box_ide_gdb_verify.sh

check-8086:
	$(SHELL) tools/check_8086_compat.sh

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
	@echo '  86box-floppy-smoke - Run floppy smoke test with DOS media'
	@echo '  86box-floppy-smoke-gdb - GDB-verified floppy smoke test'
	@echo '  86box-ide-smoke - Run IDE smoke test in 86Box'
	@echo '  86box-ide-smoke-gdb - GDB-verified IDE smoke test'
	@echo '  86box-stability-floppy-only - DOS floppy boot with IDE disabled'
	@echo '  86box-stability-ide-embedded - DOS hard-disk boot with floppy disabled'
	@echo '  86box-stability-combo-external-floppy - Floppy wins over external XTIDE'
	@echo '  86box-stability-combo-external-hdd - External XTIDE boots with no floppy'
	@echo '  86box-stability-matrix - Run the full stability matrix'
	@echo '  86box-msdos-state-check - Validate DOS-handoff IVT/BDA state for the floppy PC1640 profile'
	@echo '  86box-msdos-ega-state-check - Validate EGA DOS-handoff IVT/BDA state for the floppy PC1640 profile'
	@echo '  86box-xtide-embedded-state - Capture and validate DOS-handoff IVT/BDA state for embedded XTIDE boot'
	@echo '  86box-xtide-external-state - Capture and validate DOS-handoff IVT/BDA state for external XTIDE boot'
	@echo '  86box-compat-matrix - Run DOS/XTIDE boot plus IVT/BDA/video compatibility checks'
	@echo '  check-8086   - Audit BIOS/test binaries and XTIDE build flags for 8086-only paths'
	@echo ''
	@echo 'Build outputs:'
	@echo '  build/bios.bin    - 16 KiB ROM image'
	@echo '  build/40043.v3    - Odd chip file (with mirror)'
	@echo '  build/40044.v3    - Even chip file (with mirror)'
	@echo '  build/ide_xt.bin  - XTIDE Universal BIOS 8 KiB option ROM for 86Box XTIDE'
	@echo '  build/ide_xtl.bin - XTIDE Universal BIOS XT Large option ROM'
	@echo '  build/ide_tiny.bin - XTIDE Universal BIOS XT Tiny embedded image'
	@echo '  build/bios.elf    - ELF with debug symbols'
	@echo '  build/bios.map    - Linker map file'
	@echo ''
	@echo 'Deploy:'
	@echo '  deploy-xt-emporium - rsync ROM artifacts to root@xt-emporium.com:/opt/xt-emporium/Site'

deploy-xt-emporium: $(TARGET_ARTIFACTS)
	@chmod +x tools/deploy_xt_emporium.sh
	tools/deploy_xt_emporium.sh

.PHONY: all clean mrproper regen-strings defconfig config menuconfig kconfig help FORCE \
	deploy-xt-emporium \
	86box-build 86box-run 86box-selftest msdos-boot-check 86box-msdos \
	86box-floppy-smoke 86box-floppy-smoke-gdb 86box-ide-smoke 86box-ide-smoke-gdb \
	86box-stability-floppy-only 86box-stability-ide-embedded \
	86box-stability-combo-external-floppy 86box-stability-combo-external-hdd \
	86box-stability-matrix 86box-msdos-state-current 86box-msdos-state-original \
	86box-msdos-state-check 86box-msdos-state-compare 86box-msdos-ega-state-current \
	86box-msdos-ega-state-original 86box-msdos-ega-state-check 86box-msdos-ega-state-compare \
	86box-xtide-embedded-state 86box-xtide-external-state 86box-compat-matrix \
	check-8086 \
	86box-selftest-video-trace 86box-selftest-video-trace-original \
	86box-selftest-video-compare 86box-selftest-ega-video-trace \
	86box-selftest-ega-video-trace-original 86box-selftest-ega-video-compare
