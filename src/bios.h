#ifndef NEW_BIOS_H
#define NEW_BIOS_H

#include "bios_ports.h"
#include "bios_hw.h"

#define BIOS_FLAG_CF 0x0001
#define BIOS_FLAG_PF 0x0004
#define BIOS_FLAG_AF 0x0010
#define BIOS_FLAG_ZF 0x0040
#define BIOS_FLAG_SF 0x0080

typedef void __far (*bios_isr_t) (void);

#define BIOS_INSTALL_VECTOR(intno, handler)                                     \
  do                                                                            \
    {                                                                           \
      bios_far_vector_t __far *vector__;                                        \
      vector__ = (bios_far_vector_t __far *) BIOS_MK_FP (0,                     \
                                                         (u16) (intno) * 4U);   \
      vector__->off = __builtin_ia16_FP_OFF (handler);                          \
      vector__->seg = BIOS_ROM_SEGMENT;                                         \
    }                                                                           \
  while (0)

#define BIOS_INSTALL_DATA_VECTOR(intno, symbol)                                 \
  do                                                                            \
    {                                                                           \
      bios_far_vector_t __far *vector__;                                        \
      vector__ = (bios_far_vector_t __far *) BIOS_MK_FP (0,                     \
                                                         (u16) (intno) * 4U);   \
      vector__->off = __builtin_ia16_FP_OFF (symbol);                           \
      vector__->seg = BIOS_ROM_SEGMENT;                                         \
    }                                                                           \
  while (0)

static inline u8
bios_lo (u16 value)
{
  return (u8) (value & 0x00FF);
}

static inline u8
bios_hi (u16 value)
{
  return (u8) ((value >> 8) & 0x00FF);
}

#define bios_set_lo(value_ptr, lo_value)                                        \
  do                                                                            \
    {                                                                           \
      *(value_ptr) = (u16) ((*(value_ptr) & 0xFF00U) | (u16) (lo_value));      \
    }                                                                           \
  while (0)

#define bios_set_hi(value_ptr, hi_value)                                        \
  do                                                                            \
    {                                                                           \
      *(value_ptr) = (u16) ((*(value_ptr) & 0x00FFU)                           \
                            | ((u16) (hi_value) << 8));                         \
    }                                                                           \
  while (0)

#define bios_set_cf(regs_ptr)                                                   \
  do                                                                            \
    {                                                                           \
      (regs_ptr)->flags |= BIOS_FLAG_CF;                                        \
    }                                                                           \
  while (0)

#define bios_clear_cf(regs_ptr)                                                 \
  do                                                                            \
    {                                                                           \
      (regs_ptr)->flags &= (u16) ~BIOS_FLAG_CF;                                 \
    }                                                                           \
  while (0)

#define bios_set_zf(regs_ptr, set_flag_value)                                   \
  do                                                                            \
    {                                                                           \
      if (set_flag_value)                                                       \
        (regs_ptr)->flags |= BIOS_FLAG_ZF;                                      \
      else                                                                      \
        (regs_ptr)->flags &= (u16) ~BIOS_FLAG_ZF;                               \
    }                                                                           \
  while (0)

static inline volatile u8 __far *
bios_abs8_ptr (u16 seg, u16 off)
{
  return (volatile u8 __far *) BIOS_MK_FP (seg, off);
}

static inline volatile u16 __far *
bios_abs16_ptr (u16 seg, u16 off)
{
  return (volatile u16 __far *) BIOS_MK_FP (seg, off);
}

static inline volatile u32 __far *
bios_abs32_ptr (u16 seg, u16 off)
{
  return (volatile u32 __far *) BIOS_MK_FP (seg, off);
}

static inline u8
bios_abs_read8 (u16 seg, u16 off)
{
  return *bios_abs8_ptr (seg, off);
}

static inline u16
bios_abs_read16 (u16 seg, u16 off)
{
  return *bios_abs16_ptr (seg, off);
}

static inline u32
bios_abs_read32 (u16 seg, u16 off)
{
  return *bios_abs32_ptr (seg, off);
}

static inline void
bios_abs_write8 (u16 seg, u16 off, u8 value)
{
  *bios_abs8_ptr (seg, off) = value;
}

static inline void
bios_abs_write16 (u16 seg, u16 off, u16 value)
{
  *bios_abs16_ptr (seg, off) = value;
}

static inline void
bios_abs_write32 (u16 seg, u16 off, u32 value)
{
  *bios_abs32_ptr (seg, off) = value;
}

static inline u8
bios_bda_read8 (u16 off)
{
  return bios_abs_read8 (BIOS_BDA_SEGMENT, off);
}

static inline u16
bios_bda_read16 (u16 off)
{
  return bios_abs_read16 (BIOS_BDA_SEGMENT, off);
}

static inline u32
bios_bda_read32 (u16 off)
{
  return bios_abs_read32 (BIOS_BDA_SEGMENT, off);
}

static inline void
bios_bda_write8 (u16 off, u8 value)
{
  bios_abs_write8 (BIOS_BDA_SEGMENT, off, value);
}

static inline void
bios_bda_write16 (u16 off, u16 value)
{
  bios_abs_write16 (BIOS_BDA_SEGMENT, off, value);
}

static inline void
bios_bda_write32 (u16 off, u32 value)
{
  bios_abs_write32 (BIOS_BDA_SEGMENT, off, value);
}

static inline u8
bios_work_read8 (u16 off)
{
  return bios_abs_read8 (BIOS_ABS_SEGMENT, (u16) (BIOS_WORK_BASE + off));
}

static inline u16
bios_work_read16 (u16 off)
{
  return bios_abs_read16 (BIOS_ABS_SEGMENT, (u16) (BIOS_WORK_BASE + off));
}

static inline void
bios_work_write8 (u16 off, u8 value)
{
  bios_abs_write8 (BIOS_ABS_SEGMENT, (u16) (BIOS_WORK_BASE + off), value);
}

static inline void
bios_work_write16 (u16 off, u16 value)
{
  bios_abs_write16 (BIOS_ABS_SEGMENT, (u16) (BIOS_WORK_BASE + off), value);
}

static inline void
bios_mem_fill16 (u16 seg, u16 off, u16 value, u16 count)
{
  volatile u16 __far *dst = bios_abs16_ptr (seg, off);
  while (count != 0)
    {
      *dst++ = value;
      count--;
    }
}

extern const char bios_str_en_battery_warning[];
extern const char bios_str_en_check_keyboard_mouse[];
extern const char bios_str_en_insert_system_disk[];
extern const char bios_str_en_error_prefix[];
extern const char bios_str_en_wait[];
extern const char bios_str_en_memory_parity[];
extern const char bios_str_en_vdu_ram[];
extern const char bios_str_en_ros_checksum[];
extern const char bios_str_amstrad_copyright[];
extern const char bios_hex_digits[];

void bios_main (void);
void __far bios_reset_entry (void);

void bios_install_vectors (void);
void bios_install_bda_tables (void);
u16 bios_build_equipment_word (void);
u8 bios_build_status1 (void);
u8 bios_build_status2 (void);
u8 bios_build_video_switches (void);
u8 bios_default_display_mode_bits (void);
u8 bios_default_text_mode (void);
void bios_io_init_defaults (void);
u8 bios_io_read (u16 port);
void bios_io_write (u16 port, u8 value);

void bios_dma_init (void);
void bios_pic_init (void);
void bios_pic_ack_irq (u8 irq);

void bios_pit_init (void);
void bios_timer_tick (void);
void bios_beep_ticks (u16 ticks);
void bios_play_space_invaders_effect (void);
void bios_wait_microseconds (u32 delay_us);
void bios_wait_timer_ticks (u16 ticks);

void bios_keyboard_init (void);
int bios_keyboard_self_test (void);
void bios_keyboard_irq1 (void);
void bios_keyboard_clear_buffer (void);
void bios_keyboard_wait_for_keypress (void);
void bios_service_int06 (bios_regs_t __far * regs);
void bios_service_int11 (bios_regs_t __far * regs);
void bios_service_int12 (bios_regs_t __far * regs);
void bios_service_int15 (bios_regs_t __far * regs);
void bios_service_int16 (bios_regs_t __far * regs);

void bios_video_init (void);
void bios_video_putc (char ch);
void bios_video_puts (const char *text);
void bios_video_put_hex8 (u8 value);
void bios_video_put_hex16 (u16 value);
void bios_video_set_mode (u8 mode);
void bios_video_hide_cursor (void);
void bios_video_set_attribute (u8 attr);
void bios_video_set_cursor (u8 row, u8 col);
void bios_video_clear (u8 attr);
void bios_video_fill (u8 row, u8 col, u8 width, char ch, u8 attr);
void bios_video_puts_at (u8 row, u8 col, u8 attr, const char *text);
void bios_video_put_hex8_at (u8 row, u8 col, u8 attr, u8 value);
void bios_video_put_hex16_at (u8 row, u8 col, u8 attr, u16 value);
void bios_video_put_udec_at (u8 row, u8 col, u8 attr, u16 value);
void bios_service_int10 (bios_regs_t __far * regs);

void bios_ide_init (void);
void bios_ide_service_int13 (bios_regs_t __far * regs);

void bios_floppy_init (void);
void bios_floppy_irq6 (void);
int bios_floppy_post_test (void);
void bios_service_int13 (bios_regs_t __far * regs);
void bios_boot_int13_call (bios_regs_t * regs);
void bios_invoke_int19 (void);
void bios_bootstrap_loader (void);
extern const u8 bios_diskette_parameter_table[11];
u8 bios_floppy_drive_type (u8 drive);
u16 bios_floppy_drive_capacity_kb (u8 drive);

void bios_serial_init (void);
#if BIOS_CFG_DEBUG_PORT_E9 || BIOS_CFG_DEBUG_COM1
void bios_serial_debug_putc (char ch);
void bios_serial_debug_puts (const char *text);
void bios_serial_debug_put_hex8 (u8 value);
void bios_serial_debug_put_hex16 (u16 value);
#else
#define bios_serial_debug_putc(ch) ((void)0)
#define bios_serial_debug_puts(text) ((void)0)
#define bios_serial_debug_put_hex8(value) ((void)0)
#define bios_serial_debug_put_hex16(value) ((void)0)
#endif
void bios_service_int14 (bios_regs_t __far * regs);

int bios_option_rom_scan (u16 start_segment, u16 end_segment, u16 scan_step);

void bios_printer_init (void);
void bios_printer_irq7 (void);
void bios_service_int05 (bios_regs_t __far * regs);
void bios_service_int17 (bios_regs_t __far * regs);

void bios_rtc_init (void);
int bios_rtc_battery_ok (void);
u8 bios_cmos_read (u8 index);
void bios_cmos_write (u8 index, u8 value);
void bios_rtc_periodic_housekeeping (u32 ticks);
void bios_service_pc1640_int15 (bios_regs_t __far * regs);
void bios_service_int1a (bios_regs_t __far * regs);

void bios_video_debug_dump_state (const char *tag);

void bios_boot_failure (void);
void bios_nmi_handler (void);
void bios_post_cold_boot (void);

#endif
