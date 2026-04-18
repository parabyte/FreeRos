/* ================================================
 * FreeRos BIOS
 * bios_hw.h: Low-level hardware access primitives
 * ================================================ */

#ifndef NEW_BIOS_HW_H
#define NEW_BIOS_HW_H

#define BIOS_HW_FLAG_IF 0x0200

/* ================================================
 * Port I/O
 * ================================================ */

static inline void
bios_hw_out8 (u8 value, u16 port)
{
  asm volatile ("outb %%al,%%dx"::"Ral" (value), "d" (port));
}

static inline u8
bios_hw_in8 (u16 port)
{
  u8 value;

  asm volatile ("inb %%dx,%%al":"=Ral" (value):"d" (port));
  return value;
}

static inline void
bios_hw_out8_p (u8 value, u16 port)
{
  asm volatile ("outb %%al,%%dx\n\t"
		"outb %%al,$0x80"::"Ral" (value), "d" (port));
}

static inline u8
bios_hw_in8_p (u16 port)
{
  u8 value;

  asm volatile ("inb %%dx,%%al\n\t"
		"outb %%al,$0x80":"=Ral" (value):"d" (port));
  return value;
}

/* ================================================
 * Interrupt control
 * ================================================ */

static inline void
bios_hw_enable_interrupts (void)
{
  asm volatile ("sti");
}

static inline void
bios_hw_disable_interrupts (void)
{
  asm volatile ("cli");
}

static inline u16
bios_hw_irq_save_disable (void)
{
  u16 flags;

  asm volatile ("pushf\n\t"
                "pop %0\n\t"
                "cli"
                : "=rm" (flags)
                :
                : "memory", "cc");
  return flags;
}

static inline void
bios_hw_irq_restore (u16 flags)
{
  if ((flags & BIOS_HW_FLAG_IF) != 0)
    asm volatile ("sti" ::: "memory", "cc");
  else
    asm volatile ("cli" ::: "memory", "cc");
}

/* ================================================
 * CPU control
 * ================================================ */

static inline void
bios_hw_halt (void)
{
  asm volatile ("hlt");
}

static inline void
bios_hw_pause (void)
{
  asm volatile ("outb %%al,$0x80"::"Ral" ((u8) 0));
}

/* ================================================
 * Boot transfer
 * ================================================ */

static inline void __attribute__((noreturn)) bios_hw_boot_sector (u8 drive)
{
  register u8 drv asm ("dl") = drive;

  asm volatile ("cli\n\t"
		"xor %%ax, %%ax\n\t"
		"mov %%ax, %%ds\n\t"
		"mov %%ax, %%es\n\t"
		"mov %%ax, %%ss\n\t"
		"mov $0x7C00, %%sp\n\t"
		"xor %%dh, %%dh\n\t"
		"xor %%bx, %%bx\n\t"
		"xor %%cx, %%cx\n\t"
		"xor %%si, %%si\n\t"
		"xor %%di, %%di\n\t"
		"xor %%bp, %%bp\n\t"
		"xor %%ax, %%ax\n\t"
		"cld\n\t"
		"sti\n\t"
		"ljmp $0x0000, $0x7C00"
		::"r" (drv)
		:"ax", "bx", "cx", "si", "di", "memory");
  __builtin_unreachable ();
}

#endif
