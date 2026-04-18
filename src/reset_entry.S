#include "config_autogen.h"

/*
 * reset_entry.S
 *
 * Plain reset-vector assembly, split out of reset.c for readability.
 */

	.section .start, "ax", @progbits
	.code16
	.att_syntax prefix
	.globl bios_reset_entry

/*
 * PC1640DD reset path:
 * - preserve early hardware side effects from original ROS
 * - perform checksum/default-NVR decision before C stack setup
 * - install stack and transfer to C POST entry.
 */
bios_reset_entry:
	cli
	xorw %ax, %ax
	outb %al, $0xA0
	movw $0x03F2, %dx
	outb %al, %dx
	movw %ax, %ds
	cmpw $0x1234, 0x0472
	jne .Lwarm_check_done
	incw 0x0472
	/*
	 * Stock PC1640DD pokes port 66h here and waits for external reset
	 * hardware. Under 86Box that path re-enters the reset vector with the
	 * same warm marker and can loop forever. Keep the posted warm-reset
	 * marker (1235h) and continue directly into the warm POST path.
	 */
	jmp .Lpost_code

.Lwarm_check_done:
	jl .Lpost_code
	decw 0x0472

.Lpost_code:
	movw $0x03FC, %dx
	movb $0x10, %al
	outb %al, %dx
	movb $0x0D, %al
	movw $.Lchecksum_return, %bx
	jmp .Lchecksum_helper

.Lchecksum_return:
	jnz .Lload_defaults
	addb %al, %al
	jc .Lstack_setup
	cmpw $0x1234, 0x0472
	je .Lstack_setup

.Lload_defaults:
	movw $0x0070, %dx
	movb $0x0B, %al
	outb %al, %dx
	incw %dx
	movb $0x82, %al
	outb %al, %dx
	decw %dx

	pushw %cs
	popw %ds
	movw $.Lcmos_boot_defaults, %si
	xorw %ax, %ax
	movw $0x0040, %cx

.Ldefault_loop:
	movb (%si), %ah
	cmpb $0xFE, %ah
	je .Lskip_cmos_write
	outb %al, %dx
	incw %dx
	xchgb %ah, %al
	outb %al, %dx
	xchgb %ah, %al
	decw %dx

.Lskip_cmos_write:
	incb %al
	cmpw $.Lcmos_boot_defaults_last, %si
	je .Lnext_default
	incw %si
.Lnext_default:
	loop .Ldefault_loop

	movw $.Learly_port_table, %bx
.Lport_table_outer:
	movb (%bx), %cl
	xorb %ch, %ch
	jcxz .Lport_table_done
	incw %bx
	movw (%bx), %dx
	incw %bx
	incw %bx
.Lport_table_inner:
	movb (%bx), %al
	outb %al, %dx
	incw %bx
	loop .Lport_table_inner
	jmp .Lport_table_outer

.Lport_table_done:
	xorb %al, %al
	outb %al, $0x83
	outb %al, $0x81
	outb %al, $0x82

.Lstack_setup:
	movw $BIOS_CFG_ROM_ENTRY_SEGMENT, %ax
	movw %ax, %ss
	movw $0x4400, %sp
	movw $BIOS_CFG_ROM_ENTRY_SEGMENT, %ax
	movw %ax, %ds
	movw %ax, %es
	cld
	call machine_post_early_init
	cld
	jmp bios_main

/*
 * Original-PC1640-style checksum helper.
 * Returns via BX jump target and preserves caller contract.
 */
.Lchecksum_helper:
	cli
	movw $0x0070, %dx
	outb %al, %dx
	incw %dx
	inb %dx, %al
	decw %dx
	movb %al, %cl
	xorb %ah, %ah
	movb $0x3F, %ch

.Lchecksum_sum_loop:
	movb %ch, %al
	outb %al, %dx
	incw %dx
	inb %dx, %al
	decw %dx
	addb %al, %ah
	decb %ch
	cmpb $0x14, %ch
	jnc .Lchecksum_sum_loop

	movb %ah, %ch
	subb %al, %ch
	movb $0xAA, %al
	subb %ch, %al
	xchgb %cl, %al
	subb $0xAA, %ah
	jmp *%bx

.Lcmos_boot_defaults:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01
	.byte 0x01, 0x80, 0x20, 0x02, 0xFE, 0xFE, 0x00, 0x00
	.byte 0x01, 0x01, 0x01, 0x78, 0x00, 0x0D, 0x1C, 0x07
	.byte 0x22, 0xFF, 0xFF, 0xFF, 0xFF, 0x0D, 0x1C, 0x1B
	.byte 0x01, 0x0A, 0x0A, 0x20, 0x07, 0x00, 0xE3, 0xE3
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x16, 0x00
.Lcmos_boot_defaults_last:
	.byte 0x00

.Learly_port_table:
	.byte 0x01
	.word 0x0061
	.byte 0x80
	.byte 0x03
	.word 0x0043
	.byte 0x34, 0x74, 0xB0
	.byte 0x02
	.word 0x0040
	.byte 0x00, 0x00
	.byte 0x02
	.word 0x0041
	.byte 0x00, 0x12
	.byte 0x02
	.word 0x0042
	.byte 0x00, 0x01
	.byte 0x01
	.word 0x000F
	.byte 0x0F
	.byte 0x01
	.word 0x0008
	.byte 0x00
	.byte 0x01
	.word 0x000B
	.byte 0x58
	.byte 0x01
	.word 0x000C
	.byte 0x00
	.byte 0x02
	.word 0x0001
	.byte 0xFF, 0xFF
	.byte 0x01
	.word 0x000A
	.byte 0x00
	.byte 0x01
	.word 0x0020
	.byte 0x13
	.byte 0x03
	.word 0x0021
	.byte 0x08, 0x09, 0xFF
	.byte 0x01
	.word 0x03F2
	.byte 0x00
	.byte 0x01
	.word 0x03FC
	.byte 0x00
	.byte 0x00
