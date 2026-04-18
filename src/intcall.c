#include "bios.h"

void
bios_invoke_int19 (void)
{
  /*
   * Must go through the IVT so option ROMs that hook INT 19h during their
   * init entry (e.g. XTIDE late-init) get control before the bootstrap
   * loader runs.
   */
  asm volatile ("int $0x19" ::: "memory", "cc");
  __builtin_unreachable ();
}

void
bios_service_dispatch (bios_regs_t *regs,
                       void (*service) (bios_regs_t __far *))
{
  service ((bios_regs_t __far *) regs);
}

void
bios_service_dispatch_far (bios_regs_t __far *regs,
                           void (*service) (bios_regs_t __far *))
{
  service (regs);
}

void
bios_boot_int13_call_inner (bios_regs_t *regs)
{
  u16 ax;
  u16 bx;
  u16 cx;
  u16 dx;
  u16 flags;

  ax = regs->ax;
  bx = regs->bx;
  cx = regs->cx;
  dx = regs->dx;
  flags = 0;

  /*
   * INT 19h bootstrapping must honor the live INT 13h vector so embedded
   * XTIDE can service fixed-disk reads after it hooks the IVT.  Preserve the
   * compiler-visible frame registers around the software interrupt; the boot
   * path only relies on AX/BX/CX/DX/FLAGS.
   */
  __asm__ __volatile__ (
    "push %%bp\n\t"
    "push %%si\n\t"
    "push %%di\n\t"
    "push %%ds\n\t"
    "push %%es\n\t"
    "mov %5, %%es\n\t"
    "int $0x13\n\t"
    "pushf\n\t"
    "pop %4\n\t"
    "pop %%es\n\t"
    "pop %%ds\n\t"
    "pop %%di\n\t"
    "pop %%si\n\t"
    "pop %%bp"
    : "+a" (ax), "+b" (bx), "+c" (cx), "+d" (dx), "=rm" (flags)
    : "rm" (regs->es)
    : "cc", "memory");

  regs->ax = ax;
  regs->bx = bx;
  regs->cx = cx;
  regs->dx = dx;
  regs->flags = flags;
}

#if !BIOS_CFG_HAS_FLOPPY_CONTROLLER && !BIOS_CFG_HD_BOOT_ENABLED
void
bios_service_int13 (bios_regs_t __far *regs)
{
  bios_set_hi (&regs->ax, 0x01); /* Bad command */
  bios_set_cf (regs);
}

void
bios_bootstrap_loader (void)
{
  /* Halt if no floppy/IDE available */
  for (;;);
}

void
bios_floppy_irq6 (void)
{
}
#endif
