#include "config.h"

/*
 * Minimal interrupt glue for the standalone video ROM (INT 10h / INT 42h only).
 * Mirrors DIRECT_SERVICE_WRAPPER for PC1640 from intcall_wrappers.S.
 */

#if BIOS_CFG_STACK_OFFSET != 0x0100
#error video_pega_rom_int10.S expects BIOS_CFG_STACK_OFFSET 0x0100
#endif

	.text
	.arch i8086,jumps
	.code16
	.att_syntax prefix

.macro DIRECT_SERVICE_WRAPPER wrapper, service
	.globl \wrapper
	.type \wrapper, @function
\wrapper:
	pushw %cx
	pushw %ax
	pushw %dx
	pushw %bx
	pushw %si
	pushw %di
	pushw %es
	pushw %ds
	pushw %bp
	movw %sp, %ax
	movw $\service, %bx
	pushw %bx
	pushw %ax
	xorw %dx, %dx
	movw %dx, %ds
	call bios_service_dispatch
	addw $4, %sp
	cli
	popw %bp
	popw %ds
	popw %es
	popw %di
	popw %si
	popw %bx
	popw %dx
	popw %ax
	popw %cx
	iret
	.size \wrapper, .-\wrapper
.endm

DIRECT_SERVICE_WRAPPER bios_int10_wrapper, bios_service_int10
