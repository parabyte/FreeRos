#include "bios.h"

static const u8 bios_video_parameter_table[32] = {
  0x38, 0x28, 0x2D, 0x0A, 0x1F, 0x06, 0x19, 0x1C,
  0x02, 0x07, 0x06, 0x07, 0x00, 0x00, 0x00, 0x00,
  0x71, 0x50, 0x5A, 0x0A, 0x1F, 0x06, 0x19, 0x1C,
  0x02, 0x07, 0x06, 0x07, 0x00, 0x00, 0x00, 0x00
};

/*
 * This layout matches the IA-16 GCC interrupt prologue that the wrappers below
 * currently generate when they touch SI, DI, and ES in addition to the normal
 * AX/BX/CX/DX/DS/BP save set. The wrappers then patch these saved words before
 * the compiler restores them and executes IRET.
 */
typedef struct bios_interrupt_frame
{
  u16 bp;
  u16 ds;
  u16 es;
  u16 di;
  u16 si;
  u16 bx;
  u16 dx;
  u16 ax;
  u16 cx;
  u16 ip;
  u16 cs;
  u16 flags;
} bios_interrupt_frame_t;

void __far bios_irq0_wrapper (void) __attribute__ ((interrupt, used));
void __far bios_irq1_wrapper (void) __attribute__ ((interrupt, used));
void __far bios_irq6_wrapper (void) __attribute__ ((interrupt, used));
void __far bios_irq7_wrapper (void) __attribute__ ((interrupt, used));
void __far bios_nmi_wrapper (void) __attribute__ ((interrupt, used));
void __far bios_int11_wrapper (void)
  __attribute__ ((interrupt, no_assume_ss_data, used));
void __far bios_int12_wrapper (void)
  __attribute__ ((interrupt, no_assume_ss_data, used));
void __far bios_int15_wrapper (void)
  __attribute__ ((interrupt, no_assume_ss_data, used));
void __far bios_int10_wrapper (void)
  __attribute__ ((interrupt, no_assume_ss_data, used));
void __far bios_int13_wrapper (void)
  __attribute__ ((interrupt, no_assume_ss_data, used));
void __far bios_int14_wrapper (void)
  __attribute__ ((interrupt, no_assume_ss_data, used));
void __far bios_int16_wrapper (void)
  __attribute__ ((interrupt, no_assume_ss_data, used));
void __far bios_int17_wrapper (void)
  __attribute__ ((interrupt, no_assume_ss_data, used));
void __far bios_int18_wrapper (void) __attribute__ ((interrupt, used));
void __far bios_int19_wrapper (void) __attribute__ ((interrupt, used));
void __far bios_int1a_wrapper (void)
  __attribute__ ((interrupt, no_assume_ss_data, used));
void __far bios_int1c_wrapper (void) __attribute__ ((interrupt, used));

#define BIOS_DEFINE_SERVICE_WRAPPER(wrapper_name, service_name)                 \
  void __far __attribute__ ((interrupt, no_assume_ss_data, used))              \
  wrapper_name (void);                                                          \
  void __far __attribute__ ((interrupt, no_assume_ss_data, used))              \
  wrapper_name (void)                                                           \
  {                                                                             \
    register u16 esr __asm__ ("es");                                            \
    register u16 sir __asm__ ("si");                                            \
    register u16 dir __asm__ ("di");                                            \
    bios_interrupt_frame_t __seg_ss *frame;                                     \
    bios_regs_t regs;                                                           \
                                                                                \
    frame = (bios_interrupt_frame_t __seg_ss *) __builtin_frame_address (0);    \
    regs.ax = frame->ax;                                                        \
    regs.bx = frame->bx;                                                        \
    regs.cx = frame->cx;                                                        \
    regs.dx = frame->dx;                                                        \
    regs.si = sir;                                                              \
    regs.di = dir;                                                              \
    regs.bp = frame->bp;                                                        \
    regs.ds = frame->ds;                                                        \
    regs.es = esr;                                                              \
    regs.flags = frame->flags;                                                  \
    service_name ((bios_regs_t __far *) &regs);                                 \
    frame->ax = regs.ax;                                                        \
    frame->bx = regs.bx;                                                        \
    frame->cx = regs.cx;                                                        \
    frame->dx = regs.dx;                                                        \
    frame->si = regs.si;                                                        \
    frame->di = regs.di;                                                        \
    frame->bp = regs.bp;                                                        \
    frame->ds = regs.ds;                                                        \
    frame->es = regs.es;                                                        \
    frame->flags = regs.flags;                                                  \
  }

static void
bios_install_service_vectors (void)
{
  BIOS_INSTALL_VECTOR (0x02, bios_nmi_wrapper);
  BIOS_INSTALL_VECTOR (0x08, bios_irq0_wrapper);
  BIOS_INSTALL_VECTOR (0x09, bios_irq1_wrapper);
  BIOS_INSTALL_VECTOR (0x0E, bios_irq6_wrapper);
  BIOS_INSTALL_VECTOR (0x0F, bios_irq7_wrapper);
  BIOS_INSTALL_VECTOR (0x10, bios_int10_wrapper);
  BIOS_INSTALL_VECTOR (0x11, bios_int11_wrapper);
  BIOS_INSTALL_VECTOR (0x12, bios_int12_wrapper);
  BIOS_INSTALL_VECTOR (0x13, bios_int13_wrapper);
  BIOS_INSTALL_VECTOR (0x14, bios_int14_wrapper);
  BIOS_INSTALL_VECTOR (0x15, bios_int15_wrapper);
  BIOS_INSTALL_VECTOR (0x16, bios_int16_wrapper);
  BIOS_INSTALL_VECTOR (0x17, bios_int17_wrapper);
  BIOS_INSTALL_VECTOR (0x18, bios_int18_wrapper);
  BIOS_INSTALL_VECTOR (0x19, bios_int19_wrapper);
  BIOS_INSTALL_VECTOR (0x1A, bios_int1a_wrapper);
  BIOS_INSTALL_VECTOR (0x1C, bios_int1c_wrapper);
  BIOS_INSTALL_DATA_VECTOR (0x1D, bios_video_parameter_table);
  BIOS_INSTALL_DATA_VECTOR (0x1E, bios_diskette_parameter_table);
}

BIOS_DEFINE_SERVICE_WRAPPER (bios_int11_wrapper, bios_service_int11)
BIOS_DEFINE_SERVICE_WRAPPER (bios_int12_wrapper, bios_service_int12)
BIOS_DEFINE_SERVICE_WRAPPER (bios_int10_wrapper, bios_service_int10)
BIOS_DEFINE_SERVICE_WRAPPER (bios_int13_wrapper, bios_service_int13)
BIOS_DEFINE_SERVICE_WRAPPER (bios_int14_wrapper, bios_service_int14)
BIOS_DEFINE_SERVICE_WRAPPER (bios_int15_wrapper, bios_service_int15)
BIOS_DEFINE_SERVICE_WRAPPER (bios_int16_wrapper, bios_service_int16)
BIOS_DEFINE_SERVICE_WRAPPER (bios_int17_wrapper, bios_service_int17)
BIOS_DEFINE_SERVICE_WRAPPER (bios_int1a_wrapper, bios_service_int1a)

void __far __attribute__ ((interrupt, used))
bios_nmi_wrapper (void)
{
  bios_nmi_handler ();
}

void __far __attribute__ ((interrupt, used))
bios_irq0_wrapper (void)
{
  bios_timer_tick ();
}

void __far __attribute__ ((interrupt, used))
bios_irq1_wrapper (void)
{
  bios_keyboard_irq1 ();
}

void __far __attribute__ ((interrupt, used))
bios_irq6_wrapper (void)
{
  bios_floppy_irq6 ();
}

void __far __attribute__ ((interrupt, used))
bios_irq7_wrapper (void)
{
  bios_printer_irq7 ();
}

void __far __attribute__ ((interrupt, used))
bios_int18_wrapper (void)
{
  bios_boot_failure ();
}

void __far __attribute__ ((interrupt, used))
bios_int19_wrapper (void)
{
  bios_bootstrap_loader ();
}

void __far __attribute__ ((interrupt, used))
bios_int1c_wrapper (void)
{
}

void
bios_install_vectors (void)
{
  bios_install_service_vectors ();
}
