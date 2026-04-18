#include "config_autogen.h"

#if BIOS_CFG_EXECUTE_IN_PLACE
/*
 * The ROS runtime stack aliases physical 0x0400 (0030:0100) when XIP is on.
 * Interrupt services need a separate low-RAM window; otherwise the switched
 * INT stack grows back into the caller's aliased stack frame and IRQ-driven
 * services can return through corrupted IP/CS words.
 *
 * Keep the software-INT stack away from the DOS boot loader's conventional
 * low-memory buffers. MS-DOS 3.x uses 0000:0500 for the root directory,
 * 0000:0700 for the first IBMBIO.COM stage, and 0000:8000 as a later FAT/work
 * buffer. Placing the INT 13h service stack in that range lets floppy DMA
 * clobber the live return frame mid-read.
 *
 * FC00:7000 wraps to physical 0x3000 with A20 disabled. That keeps the
 * generic IRQ/service stack in conventional RAM but out of the IVT/BDA/work
 * area, the DOS stage at 0000:0700, and the later 05B9:0000..05B9:3200
 * floppy load buffers used by MS-DOS 3.x during IBMBIO.COM staging.
 *
 * Using 0x5000 for the general interrupt stack was still low enough to avoid
 * the boot loader, but DOS/COMMAND transient work on the HDD path can occupy
 * that region. Timer/keyboard IRQ frames then scribble over DOS buffers and
 * show up as post-boot corruption such as COMMAND.COM traps during DIR.
 */
#define BIOS_INT_STACK_LOW_OFFSET 0x7000
#define BIOS_INT_STACK_HIGH_OFFSET 0xD000
#define BIOS_INT_STACK_LOW_PHYS 0x3000
#define BIOS_INT_STACK_GUARD 0x0200
/*
 * Hardware IRQ handlers can interrupt a service already running on the INT
 * stack. Reusing the same top-of-stack for IRQ entry clobbers the interrupted
 * frame before the handler switches stacks, so keep IRQs on a dedicated window.
 * FC00:7800 wraps to physical 0x3800 with A20 disabled.
 */
#define BIOS_IRQ_STACK_OFFSET 0x7800
#define BIOS_INT_STACK_OFFSET BIOS_INT_STACK_LOW_OFFSET
#else
#define BIOS_INT_STACK_LOW_OFFSET BIOS_CFG_STACK_OFFSET
#define BIOS_INT_STACK_HIGH_OFFSET BIOS_CFG_STACK_OFFSET
#define BIOS_IRQ_STACK_OFFSET (BIOS_CFG_STACK_OFFSET + 0x0200)
#define BIOS_INT_STACK_OFFSET BIOS_CFG_STACK_OFFSET
#endif

	.text
	.arch i8086,jumps
	.code16
	.att_syntax prefix

/*
 * Small helper macros to keep each wrapper body plain and readable.
 */
.macro IRET_WRAPPER name
	.globl \name
	.type \name, @function
\name:
	iret
	.size \name, .-\name
.endm

.macro INTERRUPT_CALL_WRAPPER wrapper, handler
	.globl \wrapper
	.type \wrapper, @function
\wrapper:
	call bios_interrupt_call_wrapper_common
	.word \handler
	.size \wrapper, .-\wrapper
.endm

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

.macro STACK_SERVICE_WRAPPER wrapper, service
	.globl \wrapper
	.type \wrapper, @function
\wrapper:
	call bios_stack_service_wrapper_common
	.word \service
	.size \wrapper, .-\wrapper
.endm

.macro FAR_DISPATCH_SERVICE_WRAPPER wrapper, service
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
	movw %ss, %dx
	movw %sp, %si
	pushw %cs
	popw %bp
	movw %bp, %ss
	movw $BIOS_IRQ_STACK_OFFSET, %sp
	pushw %dx
	pushw %si
	movw $\service, %bx
	pushw %bx
	pushw %dx
	pushw %ax
	pushw %cs
	popw %ds
	pushw %cs
	popw %es
	call bios_service_dispatch_far
	addw $6, %sp
	cli
	popw %si
	popw %dx
	movw %dx, %ss
	movw %si, %sp
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

/*
 * Shared wrapper bodies keep the per-vector stubs tiny. Each stub emits
 * `call common` followed by a literal service/handler word; the common body
 * loads that word from the saved return address and then drops it before IRET.
 */
	.type bios_interrupt_call_wrapper_common, @function
bios_interrupt_call_wrapper_common:
	pushw %ax
	pushw %bx
	pushw %cx
	pushw %dx
	pushw %si
	pushw %di
	pushw %bp
	pushw %ds
	pushw %es
	movw %sp, %bp
	pushw %cs
	popw %ds
	pushw %cs
	popw %es
	movw 18(%bp), %bx
	movw (%bx), %bx
	movw %ss, %dx
	movw %sp, %si
	pushw %cs
	popw %cx
	movw %cx, %ss
	movw $BIOS_IRQ_STACK_OFFSET, %sp
	pushw %dx
	pushw %si
	call *%bx
	cli
	popw %si
	popw %dx
	movw %dx, %ss
	movw %si, %sp
	popw %es
	popw %ds
	popw %bp
	popw %di
	popw %si
	popw %dx
	popw %cx
	popw %bx
	popw %ax
	addw $2, %sp
	iret
	.size bios_interrupt_call_wrapper_common, .-bios_interrupt_call_wrapper_common

	.type bios_stack_service_wrapper_common, @function
bios_stack_service_wrapper_common:
	pushw %bp
	movw %sp, %bp
	subw $20, %sp
	movw %ax, -20(%bp)
	movw %bx, -18(%bp)
	movw %cx, -16(%bp)
	movw %dx, -14(%bp)
	movw %si, -12(%bp)
	movw %di, -10(%bp)
	movw %ds, -6(%bp)
	movw %es, -4(%bp)
	movw 8(%bp), %ax
	movw %ax, -2(%bp)
	movw 2(%bp), %bx
	pushw %cs
	popw %ax
	movw %ax, %ds
	movw (%bx), %bx
	leaw -20(%bp), %ax
	movw %ss, %dx
	movw %sp, %si
	pushw %cs
	popw %cx
	movw %cx, %ss
	movw $BIOS_INT_STACK_OFFSET, %sp
	pushw %dx
	pushw %si
	pushw %bx
	pushw %ax
	pushw %cx
	popw %ds
	pushw %cx
	popw %es
	call *%bx
	addw $4, %sp
	cli
	popw %si
	popw %dx
	movw %dx, %ss
	movw %si, %sp
	movw -18(%bp), %bx
	movw -16(%bp), %cx
	movw -14(%bp), %dx
	movw -12(%bp), %si
	movw -10(%bp), %di
	movw -6(%bp), %ax
	movw %ax, %ds
	movw -4(%bp), %ax
	movw %ax, %es
	movw -2(%bp), %ax
	movw %ax, 8(%bp)
	movw -20(%bp), %ax
	movw %bp, %sp
	popw %bp
	addw $2, %sp
	iret
	.size bios_stack_service_wrapper_common, .-bios_stack_service_wrapper_common

	.type bios_int13_service_wrapper_common, @function
bios_int13_service_wrapper_common:
	pushw %bp
	movw %sp, %bp
	subw $20, %sp
	movw %ax, -20(%bp)
	movw %bx, -18(%bp)
	movw %cx, -16(%bp)
	movw %dx, -14(%bp)
	movw %si, -12(%bp)
	movw %di, -10(%bp)
	movw 0(%bp), %ax
	movw %ax, -8(%bp)
	movw %ds, -6(%bp)
	movw %es, -4(%bp)
	movw 8(%bp), %ax
	movw %ax, -2(%bp)

	movw 2(%bp), %bx
	movw %cs:(%bx), %bx

	movw $BIOS_INT_STACK_LOW_OFFSET, %ax
#if BIOS_CFG_EXECUTE_IN_PLACE
	cmpb $0x02, -19(%bp)
	je 1f
	cmpb $0x03, -19(%bp)
	je 1f
	jmp 2f
1:
	movw -4(%bp), %cx
	shlw $1, %cx
	shlw $1, %cx
	shlw $1, %cx
	shlw $1, %cx
	addw -18(%bp), %cx
	movw -20(%bp), %dx
	andw $0x00ff, %dx
	shlw $1, %dx
	shlw $1, %dx
	shlw $1, %dx
	shlw $1, %dx
	shlw $1, %dx
	shlw $1, %dx
	shlw $1, %dx
	shlw $1, %dx
	shlw $1, %dx
	decw %dx
	addw %cx, %dx
	cmpw $(BIOS_INT_STACK_LOW_PHYS - BIOS_INT_STACK_GUARD), %dx
	jb 2f
	cmpw $BIOS_INT_STACK_LOW_PHYS, %cx
	jae 2f
	movw $BIOS_INT_STACK_HIGH_OFFSET, %ax
2:
#endif
	movw %ss, %dx
	movw %sp, %si
	pushw %cs
	popw %cx
	movw %cx, %ss
	movw %ax, %sp
	subw $20, %sp
	movw %sp, %di
	movw %di, %ax
	pushw %dx
	pushw %si
	pushw %ax
	movw %dx, %ds
	pushw %cx
	popw %es
	movw $10, %cx
	cld
	rep
	movsw
	pushw %bx
	pushw %es
	pushw %ax
	pushw %cs
	popw %ds
	pushw %cs
	popw %es
	call bios_service_dispatch_far
	addw $6, %sp
	cli
	popw %si
	popw %bx
	popw %dx
	pushw %cs
	popw %ds
	movw %dx, %es
	movw %bx, %di
	movw $10, %cx
	cld
	rep
	movsw
	movw %dx, %ss
	movw %bx, %sp

	pushw -6(%bp)
	pushw -4(%bp)
	movw -2(%bp), %ax
	movw %ax, 8(%bp)
	movw -8(%bp), %ax
	movw %ax, 0(%bp)
	movw -20(%bp), %ax
	movw -18(%bp), %bx
	movw -16(%bp), %cx
	movw -14(%bp), %dx
	movw -12(%bp), %si
	movw -10(%bp), %di
	popw %es
	popw %ds
	movw %bp, %sp
	popw %bp
	addw $2, %sp
	iret
	.size bios_int13_service_wrapper_common, .-bios_int13_service_wrapper_common

IRET_WRAPPER bios_default_wrapper
INTERRUPT_CALL_WRAPPER bios_nmi_wrapper, bios_nmi_handler
INTERRUPT_CALL_WRAPPER bios_irq0_wrapper, bios_timer_tick
INTERRUPT_CALL_WRAPPER bios_irq1_wrapper, bios_keyboard_irq1
#if BIOS_CFG_PRINTER_ENABLED
INTERRUPT_CALL_WRAPPER bios_irq5_wrapper, bios_irq5_handler
#endif
INTERRUPT_CALL_WRAPPER bios_irq6_wrapper, bios_floppy_irq6
#if BIOS_CFG_PRINTER_ENABLED
INTERRUPT_CALL_WRAPPER bios_irq7_wrapper, bios_printer_irq7
#endif
INTERRUPT_CALL_WRAPPER bios_int18_wrapper, bios_boot_failure
INTERRUPT_CALL_WRAPPER bios_int19_wrapper, bios_bootstrap_loader
IRET_WRAPPER bios_int1b_wrapper
IRET_WRAPPER bios_int1c_wrapper

#if BIOS_CFG_PRINTER_ENABLED
STACK_SERVICE_WRAPPER bios_int05_wrapper, bios_service_int05
#endif

STACK_SERVICE_WRAPPER bios_int06_wrapper, bios_service_int06

/*
 * Software INT callers need a real bios_regs_t frame regardless of target.
 * The older "direct" wrappers passed the raw push layout to C services, which
 * mismatched bios_regs_t and can corrupt DOS-visible INT return values.
 */
STACK_SERVICE_WRAPPER bios_int10_wrapper, bios_service_int10
STACK_SERVICE_WRAPPER bios_int11_wrapper, bios_service_int11
STACK_SERVICE_WRAPPER bios_int12_wrapper, bios_service_int12
#if BIOS_CFG_SERIAL_INT14_ENABLED
STACK_SERVICE_WRAPPER bios_int14_wrapper, bios_service_int14
#endif
STACK_SERVICE_WRAPPER bios_int15_wrapper, bios_service_int15
STACK_SERVICE_WRAPPER bios_int16_wrapper, bios_service_int16
#if BIOS_CFG_PRINTER_ENABLED
STACK_SERVICE_WRAPPER bios_int17_wrapper, bios_service_int17
#endif
STACK_SERVICE_WRAPPER bios_int1a_wrapper, bios_service_int1a
#if BIOS_CFG_EMS_ENABLED
STACK_SERVICE_WRAPPER bios_int67_wrapper, bios_service_int67
#endif

/*
 * INT 13h callers in boot sectors expect the BIOS to preserve/return a real
 * register frame.  Passing the raw interrupt-save layout as a bios_regs_t far
 * pointer corrupts AX/BX/CX/DX/ES and can redirect DMA into low RAM.
 */
	.globl bios_int13_wrapper
	.type bios_int13_wrapper, @function
bios_int13_wrapper:
	call bios_int13_service_wrapper_common
	.word bios_service_int13
	.size bios_int13_wrapper, .-bios_int13_wrapper

/*
 * Outer INT 13h bootstrap call must be asm: ia16-elf-gcc emits a broken
 * prologue (push %ds, wrong [bp+4] for the argument, saves DS after DS=0).
 * BIOS_WORK_BASE (300h) + WK_BOOT_INT13_REGS_SS (1Ah) => 31Ah.
 */
	.globl	bios_boot_int13_call
	.type	bios_boot_int13_call, @function
bios_boot_int13_call:
	pushw	%bp
	movw	%sp, %bp
	subw	$2, %sp
	movw	%ds, -2(%bp)
	movw	4(%bp), %ax
	xorw	%dx, %dx
	movw	%dx, %ds
	movw	%ax, 0x031a
	pushw	%ss
	popw	%ds
	pushw	%ax
	callw	bios_boot_int13_call_inner
	addw	$2, %sp
	movw	-2(%bp), %ds
	movw	%bp, %sp
	popw	%bp
	retw
	.size	bios_boot_int13_call, .-bios_boot_int13_call
