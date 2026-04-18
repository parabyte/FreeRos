/* ================================================
 * FreeRos BIOS
 * bios_types.h: Core type definitions and memory layout constants
 * ================================================ */

#ifndef NEW_BIOS_TYPES_H
#define NEW_BIOS_TYPES_H

#include <stdint.h>

/* ================================================
 * Type definitions
 * ================================================ */

typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;

/* ================================================
 * Memory layout
 * ================================================ */

#ifndef BIOS_ROM_SEGMENT
#define BIOS_ROM_SEGMENT 0x9000
#endif

#ifndef BIOS_STACK_OFFSET
#define BIOS_STACK_OFFSET 0x7C00
#endif
#ifndef BIOS_STACK_SEGMENT
#define BIOS_STACK_SEGMENT BIOS_ROM_SEGMENT
#endif
#define BIOS_BDA_SEGMENT 0x0040
#define BIOS_ABS_SEGMENT 0x0000
#define BIOS_VIDEO_COLOR_SEGMENT 0xB800
#define BIOS_VIDEO_MONO_SEGMENT 0xB000

/* ================================================
 * Far pointer macros
 * ================================================ */

#define BIOS_MK_FP(seg, off) \
  ((void __far *) ((((unsigned long) (seg)) << 16) | ((unsigned) (off))))
#define BIOS_FP_SEG(fp) \
  ((u16) (((unsigned long) (void __far *) (fp)) >> 16))
#define BIOS_FP_OFF(fp) ((u16) (void *) (fp))

/* ================================================
 * Register and data structures
 * ================================================ */

typedef struct bios_far_vector
{
  u16 off;
  u16 seg;
} __attribute__((packed)) bios_far_vector_t;

typedef struct bios_regs
{
  u16 ax;
  u16 bx;
  u16 cx;
  u16 dx;
  u16 si;
  u16 di;
  u16 bp;
  u16 ds;
  u16 es;
  u16 flags;
} bios_regs_t;

typedef struct bios_rom_string
{
  u16 rom_offset;
  const char *text;
} bios_rom_string_t;

#endif
