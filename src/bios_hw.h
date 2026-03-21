#ifndef NEW_BIOS_HW_H
#define NEW_BIOS_HW_H

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

static inline void __attribute__((noreturn)) bios_hw_boot_sector (u8 drive)
{
  asm volatile ("xor %%ax, %%ax\n\t"
		"mov %%ax, %%ds\n\t"
		"mov %%ax, %%es\n\t"
		"xor %%dx, %%dx\n\t"
		"mov %0, %%dl\n\t"
		"mov $0x7C00, %%bx\n\t"
		"cld\n\t"
		"push %%es\n\t"
		"push %%bx\n\t"
		"retf"::"rm" (drive):"ax", "bx", "dx", "memory");
  __builtin_unreachable ();
}

#endif
