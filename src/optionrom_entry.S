#include "config_autogen.h"

/*
 * Assembly entry for option ROM init calls.
 *
 * Kept in plain .S form (instead of inline C asm strings) so stack/segment
 * handling is readable and maintainable.
 */

#if BIOS_CFG_EXECUTE_IN_PLACE
#define OPTIONROM_XIP_STACK_SEG BIOS_CFG_ROM_ENTRY_SEGMENT
#define OPTIONROM_XIP_STACK_OFF 0x4400
#define OPTIONROM_STACK_DELTA_TO_LEGACY \
  (BIOS_CFG_STACK_OFFSET - OPTIONROM_XIP_STACK_OFF)
#define OPTIONROM_STACK_DELTA_TO_XIP \
  (OPTIONROM_XIP_STACK_OFF - BIOS_CFG_STACK_OFFSET)
#endif

	.text
	.code16gcc
	.globl bios_option_rom_enter_asm
	.type bios_option_rom_enter_asm, @function

/*
 * void bios_option_rom_enter_asm(u16 segment);
 *
 * Argument:
 *   [bp+4] = option ROM segment (e.g. C000h)
 */
bios_option_rom_enter_asm:
	pushw	%bp
	movw	%sp, %bp
	pushw	%bx
	movw	4(%bp), %dx

#if BIOS_CFG_EXECUTE_IN_PLACE \
  && !(BIOS_CFG_XTIDE_ENABLED && BIOS_CFG_XTIDE_EMBEDDED_IN_ROS)
	/*
	 * PEGA/adapter ROM code expects the legacy stack segment (0030h).
	 *
	 * The XIP stack and legacy stack are arranged to alias the same physical
	 * RAM through A20 wrap. We therefore only retag SS and adjust SP by the
	 * precomputed offset delta.
	 */
	cli
	movw	$BIOS_CFG_STACK_SEGMENT, %ax
	movw	%ax, %ss
	addw	$OPTIONROM_STACK_DELTA_TO_LEGACY, %sp
	sti
#endif

	/*
	 * Enter segment:0003 using a far return frame:
	 *   push return cs:ip
	 *   push target seg:off
	 *   retf
	 *
	 * DS = ROM segment for any ROM-local data access.
	 * ES = 0040h so adapter ROMs see the standard BDA segment.
	 */
	pushw	%ds
	pushw	%es
	cld
	movw	%dx, %ds
	movw	$0x0040, %ax
	movw	%ax, %es
	pushw	%cs
	movw	$1f, %ax
	pushw	%ax
	pushw	%dx
	xorw	%ax, %ax
	movb	$0x03, %al
	pushw	%ax
	/*
	 * `.code16gcc` would encode `retf` as operand-size overridden `retfd`.
	 * Emit the 8086 far-return opcode directly so the stack frame above is
	 * consumed as IP:CS, not EIP:CS.
	 */
	.byte	0xCB
1:
#if BIOS_CFG_EXECUTE_IN_PLACE \
  && !(BIOS_CFG_XTIDE_ENABLED && BIOS_CFG_XTIDE_EMBEDDED_IN_ROS)
	/*
	 * XTIDE's init entry returns with the saved ROM CS word still sitting
	 * above the caller-save slots on the aliased legacy stack. Detect that
	 * layout and skip the stray word so the final BX/BP/RET pops line up with
	 * the original XIP caller frame again.
	 */
	movw	%sp, %bp
	movw	0(%bp), %ax
	movw	$OPTIONROM_XIP_STACK_SEG, %dx
	cmpw	%dx, %ax
	jne	2f
	movw	2(%bp), %ax
	cmpw	%dx, %ax
	je	2f
	addw	$2, %sp
2:
#endif
	popw	%es
	popw	%ds

#if BIOS_CFG_EXECUTE_IN_PLACE \
  && !(BIOS_CFG_XTIDE_ENABLED && BIOS_CFG_XTIDE_EMBEDDED_IN_ROS)
	/* Restore XIP SS:SP view expected by BIOS C code. */
	cli
	movw	$OPTIONROM_XIP_STACK_SEG, %ax
	movw	%ax, %ss
	addw	$OPTIONROM_STACK_DELTA_TO_XIP, %sp
	sti
#endif

	popw	%bx
	popw	%bp
	retw
