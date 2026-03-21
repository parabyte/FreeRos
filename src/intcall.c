#include "bios.h"

#define BIOS_STRINGIFY_INNER(x) #x
#define BIOS_STRINGIFY(x) BIOS_STRINGIFY_INNER(x)

asm (".arch i8086,jumps\n"
     ".code16\n"
     ".att_syntax prefix\n"
     ".text\n"
     ".global bios_int13_wrapper\n"
     ".type bios_int13_wrapper, @function\n"
     "bios_int13_wrapper:\n"
     "  pushw %bp\n"
     "  movw %sp, %bp\n"
     "  subw $20, %sp\n"
     "  movw %ax, -20(%bp)\n"
     "  movw %bx, -18(%bp)\n"
     "  movw %cx, -16(%bp)\n"
     "  movw %dx, -14(%bp)\n"
     "  movw %si, -12(%bp)\n"
     "  movw %di, -10(%bp)\n"
     "  movw 0(%bp), %ax\n"
     "  movw %ax, -8(%bp)\n"
     "  movw %ds, -6(%bp)\n"
     "  movw %es, -4(%bp)\n"
     "  movw 6(%bp), %ax\n"
     "  movw %ax, -2(%bp)\n"
     "  leaw -20(%bp), %bx\n"
     "  movw %ss, %dx\n"
     "  movw %sp, %si\n"
     "  pushw %cs\n"
     "  popw %ax\n"
     "  movw %ax, %ss\n"
     "  movw $" BIOS_STRINGIFY (BIOS_STACK_OFFSET) ", %sp\n"
     "  pushw %dx\n"
     "  pushw %si\n"
     "  pushw %dx\n"
     "  pushw %bx\n"
     "  pushw %cs\n"
     "  popw %ds\n"
     "  pushw %cs\n"
     "  popw %es\n"
     "  call bios_service_int13\n"
     "  addw $4, %sp\n"
     "  cli\n"
     "  popw %si\n"
     "  popw %dx\n"
     "  movw %dx, %ss\n"
     "  movw %si, %sp\n"
     "  movw -18(%bp), %bx\n"
     "  movw -16(%bp), %cx\n"
     "  movw -14(%bp), %dx\n"
     "  movw -12(%bp), %si\n"
     "  movw -10(%bp), %di\n"
     "  movw -6(%bp), %ax\n"
     "  movw %ax, %ds\n"
     "  movw -4(%bp), %ax\n"
     "  movw %ax, %es\n"
     "  movw -2(%bp), %ax\n"
     "  movw %ax, 6(%bp)\n"
     "  movw -8(%bp), %ax\n"
     "  movw %ax, 0(%bp)\n"
     "  movw -20(%bp), %ax\n"
     "  movw %bp, %sp\n"
     "  popw %bp\n"
     "  iret\n"
     "  .size bios_int13_wrapper, .-bios_int13_wrapper\n");

void
bios_boot_int13_call (bios_regs_t *regs)
{
  bios_service_int13 ((bios_regs_t __far *) regs);
}

void
bios_invoke_int19 (void)
{
  bios_bootstrap_loader ();
}
