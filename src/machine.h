/* ================================================
 * FreeRos BIOS
 * machine.h: Machine abstraction layer interface
 * ================================================ */

#ifndef FREEROS_MACHINE_H
#define FREEROS_MACHINE_H

#include "bios_types.h"

/*
 * Machine-specific interface.
 *
 * This tree builds only the PC1640DD machine implementation in
 * src/machine/pc1640dd/machine_pc1640dd.c.
 */

/* Early POST before video and vector install. */
void machine_post_early_init (void);

/* Video hardware setup (option ROM scan, built-in CGA, etc.). */
void machine_video_init (void);

/* Post-video vector fixup (e.g., PEGA ROM vector restore on PC1640). */
void machine_post_vectors_fixup (void);

/*
 * PC1640-specific POST helpers used to preserve PEGA/runtime state across the
 * destructive RAM phase.
 */
void machine_post_save_runtime_state (u8 boot_flags, int mouse_ok);
u8 machine_post_saved_boot_flags (void);
int machine_post_saved_mouse_ok (void);
void machine_post_publish_runtime_state (u16 size_kb, u8 boot_flags,
                                         int destructive_ram_test);

/*
 * Return non-zero to preserve low memory across this reset/boot transition.
 * PC1640 keeps PEGA-owned BDA extension bytes intact during its warm-reset
 * handshake.
 */
int machine_preserve_low_memory_state (u16 warm_boot_flag);

/* Video equipment bits for the BIOS equipment word (INT 11h). */
u16 machine_equipment_video_bits (void);

/* Default text mode number for POST display. */
u8 machine_default_text_mode (void);

/*
 * Machine-specific INT 15h subfunctions.
 * Returns 1 if the request was handled, 0 if not (caller returns unsupported).
 */
struct bios_regs;
int machine_int15_extensions (struct bios_regs __far *regs);

/*
 * Machine-specific scancode handling (PC1640: mouse buttons, NVR keys).
 * Returns 1 if the scancode was consumed, 0 if not.
 */
int machine_keyboard_special (u8 scancode, int released);

/* POST mouse/pointing device hardware test. Returns 1 if OK, 0 if fault. */
int machine_mouse_test (void);

/* Machine-specific NVR/CMOS initialization during RTC init. */
void machine_nvr_init (void);

/* Machine-specific status byte builders (PC1640 WSS1/WSS2). */
u8 machine_build_status1 (void);
u8 machine_build_status2 (void);
u8 machine_build_video_switches (void);

/* Equipment word base bits (PC1640 sets bits 2-3 for RAM banks). */
u16 machine_equipment_base_bits (void);

/*
 * Periodic RTC housekeeping called from the timer tick (every ~256 ticks).
 * PC1640 copies the current RTC time into the NVR "last used" registers.
 */
void machine_rtc_periodic (void);

/*
 * Machine-specific video hardware programming after CRTC/BDA setup.
 */
void machine_video_program_mode (u8 mode);

#endif
