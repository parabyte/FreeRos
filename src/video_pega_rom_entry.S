#include "config.h"

	.section .pega_rom_header, "ax", @progbits
	.code16
	.att_syntax prefix

/*
 * PC/AT option ROM at C000:0000 — POST enters C000:0003.
 * Byte 2: size in 512-byte blocks (0x40 = 32 KiB).
 */
	.globl _start
_start:
	.byte	0x55, 0xAA, 0x40

	.globl	pega_rom_option_entry
pega_rom_option_entry:
	jmp	pega_rom_after_header

	.globl	pega_rom_after_header
pega_rom_after_header:
	call	bios_video_pega_standalone_init
	retf
