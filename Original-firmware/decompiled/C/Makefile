CC ?= gcc
CFLAGS ?= -std=c99 -ffreestanding -fno-asynchronous-unwind-tables -fno-unwind-tables -fno-stack-protector -fno-pie -fno-pic -O2

ALL_BINS = video_40100_rom.bin video_40100_full.bin system_bios.bin

all: $(ALL_BINS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.bin: %.o
	objcopy -O binary --only-section=.rom $< $@

verify: all
	cmp -s video_40100_rom.bin ../video/40100_rom.bin
	cmp -s video_40100_full.bin ../video/40100_full.bin
	cmp -s system_bios.bin ../system/bios.bin

clean:
	rm -f *.o *.bin
