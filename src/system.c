#include "bios.h"

#define BIOS_EQUIP_BOOT_FLOPPY 0x0001
#define BIOS_EQUIP_MATH_COPROCESSOR 0x0002
#define BIOS_EQUIP_VIDEO_SHIFT 4
#define BIOS_EQUIP_FLOPPY_SHIFT 6
#define BIOS_EQUIP_SERIAL_SHIFT 9
#define BIOS_EQUIP_PRINTER_SHIFT 14

#define BIOS_EQUIP_VIDEO_EGA_VGA 0x0000
#define BIOS_EQUIP_VIDEO_40X25_COLOR 0x0001
#define BIOS_EQUIP_VIDEO_80X25_COLOR 0x0002
#define BIOS_EQUIP_VIDEO_MONO 0x0003

#define BIOS_INT15_WAIT_US_PER_TICK 54925UL
#define BIOS_INT15_UNSUPPORTED 0x86

static u16 bios_equipment_video_bits (void);

static const u8 bios_pc1640_pega_switch_table[16] = {
  0xD0, 0xE0, 0xE0, 0xE0,
  0x71, 0xB1, 0x70, 0xB0,
  0xB0, 0xB0, 0xD1, 0xE1,
  0x00, 0x00, 0x10, 0x10
};

static u8
bios_pc1640_switch_status_read (void)
{
  if (!BIOS_CFG_VIDEO_USE_PC1640_SWITCH_BLOCK)
    return 0;

  (void) bios_hw_in8 (PORT_PC1640_SWITCH_LATCH);
  return bios_hw_in8 (PORT_LPT1_CONTROL);
}

static u8
bios_pc1640_pega_switch_code_read (void)
{
  static const u8 probe_values[4] = { 0x0D, 0x09, 0x05, 0x01 };
  u8 code;
  u8 bit;
  u8 i;

  code = 0;
  bit = 1;
  for (i = 0; i != 4; ++i)
    {
      bios_hw_out8 (probe_values[i], 0x03C2);
      if ((bios_hw_in8 (0x03C2) & 0x10) != 0)
        code |= bit;
      bit <<= 1;
    }

  return code;
}

static u8
bios_pc1640_pega_switch_entry (void)
{
  return bios_pc1640_pega_switch_table[bios_pc1640_pega_switch_code_read () & 0x0F];
}

static u16
bios_equipment_video_bits_from_switch_block (void)
{
  u8 control;

  if (!BIOS_CFG_VIDEO_USE_PC1640_SWITCH_BLOCK)
    return BIOS_CFG_VIDEO_EQUIPMENT;

  control = bios_pc1640_switch_status_read ();

  if ((control & LPT1_CONTROL_SWITCH_SW10) == 0)
    {
      if (BIOS_CFG_HAS_PARADISE_PEGA1A)
        {
          switch (bios_pc1640_pega_switch_entry () & 0x30)
            {
            case 0x10:
              return BIOS_EQUIP_VIDEO_40X25_COLOR;

            case 0x30:
              return BIOS_EQUIP_VIDEO_MONO;

            case 0x00:
            case 0x20:
            default:
              return BIOS_EQUIP_VIDEO_80X25_COLOR;
            }
        }

      return BIOS_CFG_VIDEO_EQUIPMENT;
    }

  if ((control & (LPT1_CONTROL_SWITCH_SW7 | LPT1_CONTROL_SWITCH_SW6)) == 0)
    return BIOS_EQUIP_VIDEO_EGA_VGA;

  if ((control & (LPT1_CONTROL_SWITCH_SW7 | LPT1_CONTROL_SWITCH_SW6))
      == LPT1_CONTROL_SWITCH_SW6)
    return BIOS_EQUIP_VIDEO_40X25_COLOR;

  if ((control & (LPT1_CONTROL_SWITCH_SW7 | LPT1_CONTROL_SWITCH_SW6))
      == LPT1_CONTROL_SWITCH_SW7)
    return BIOS_EQUIP_VIDEO_80X25_COLOR;

  return BIOS_EQUIP_VIDEO_MONO;
}

u8
bios_default_display_mode_bits (void)
{
  u16 video_bits;

  video_bits = bios_equipment_video_bits ();
  switch (video_bits)
    {
    case BIOS_EQUIP_VIDEO_40X25_COLOR:
      return 0x10;

    case BIOS_EQUIP_VIDEO_80X25_COLOR:
      return 0x20;

    case BIOS_EQUIP_VIDEO_MONO:
      return 0x30;

    case BIOS_EQUIP_VIDEO_EGA_VGA:
    default:
      return 0x00;
    }
}

u8
bios_default_text_mode (void)
{
  switch (bios_default_display_mode_bits ())
    {
    case 0x10:
      return VIDEO_MODE_40X25_COLOR;

    case 0x30:
      return VIDEO_MODE_80X25_MONO;

    case 0x00:
    case 0x20:
    default:
      return VIDEO_MODE_80X25_COLOR;
    }
}

u8
bios_default_pc1640_video_mode (void)
{
  if (BIOS_CFG_HAS_PARADISE_PEGA1A
      && (bios_pc1640_switch_status_read () & LPT1_CONTROL_SWITCH_SW10) == 0
      && (bios_pc1640_pega_switch_entry () & 0x01) != 0)
    return BIOS_CFG_VIDEO_MODE_PC1640_MONO;

  if (bios_default_display_mode_bits () == 0x30)
    return BIOS_CFG_VIDEO_MODE_PC1640_MONO;

  return BIOS_CFG_VIDEO_MODE_PC1640_COLOR;
}

u8
bios_build_status1 (void)
{
  u8 value;

  value = bios_default_display_mode_bits ();
  if (BIOS_CFG_FLOPPY_DRIVES > 1)
    value |= 0x40;
  if (BIOS_CFG_HAS_MATH_COPROCESSOR)
    value |= 0x02;
  return value;
}

u8
bios_build_status2 (void)
{
  /*
   * RAM4:0 encoding for 640 KiB is 10010b. The hardware exposes either the
   * high or low nibble depending on PB2, so we keep the packed form here.
   */
  return 0x92;
}

u8
bios_build_video_switches (void)
{
  if (BIOS_CFG_HAS_PARADISE_PEGA1A
      && BIOS_CFG_VIDEO_USE_PC1640_SWITCH_BLOCK
      && (bios_pc1640_switch_status_read () & LPT1_CONTROL_SWITCH_SW10) == 0)
    return (u8) (bios_pc1640_pega_switch_code_read () & 0x0F);

  return 0x09;
}

static u16
bios_count_serial_ports (void)
{
  u16 count;

  count = 0;
  if (BIOS_CFG_COM1_BASE != 0)
    count++;
  if (BIOS_CFG_COM2_BASE != 0)
    count++;
  return count;
}

static u16
bios_count_parallel_ports (void)
{
  u16 count;

  count = 0;
  if (BIOS_CFG_LPT1_BASE != 0)
    count++;
  if (BIOS_CFG_LPT2_BASE != 0)
    count++;
  return count;
}

static u16
bios_equipment_video_bits (void)
{
  if (BIOS_CFG_VIDEO_USE_PC1640_SWITCH_BLOCK)
    return bios_equipment_video_bits_from_switch_block ();

  switch (BIOS_CFG_VIDEO_EQUIPMENT)
    {
    case BIOS_CFG_VIDEO_EQUIPMENT_40X25_COLOR:
      return BIOS_EQUIP_VIDEO_40X25_COLOR;

    case BIOS_CFG_VIDEO_EQUIPMENT_80X25_COLOR:
      return BIOS_EQUIP_VIDEO_80X25_COLOR;

    case BIOS_CFG_VIDEO_EQUIPMENT_MONO:
      return BIOS_EQUIP_VIDEO_MONO;

    default:
      return BIOS_EQUIP_VIDEO_EGA_VGA;
    }
}

static void
bios_int15_complete_success (bios_regs_t __far *regs)
{
  bios_set_hi (&regs->ax, 0x00);
  bios_clear_cf (regs);
}

static void
bios_int15_complete_unsupported (bios_regs_t __far *regs)
{
  bios_set_hi (&regs->ax, BIOS_INT15_UNSUPPORTED);
  bios_set_cf (regs);
}

static void
bios_int15_wait (bios_regs_t __far *regs)
{
  u32 requested_us;
  u32 minimum_ticks;

  requested_us = ((u32) regs->cx << 16) | regs->dx;
  minimum_ticks = requested_us / BIOS_INT15_WAIT_US_PER_TICK;
  if (requested_us != 0
      && (requested_us % BIOS_INT15_WAIT_US_PER_TICK) != 0)
    minimum_ticks++;

  /*
   * The current clean-room BIOS still uses a C port shadow model rather than
   * hardware timer programming, so this service can only provide a logical
   * compatibility surface. Returning success keeps DOS installers and option
   * ROM probes moving without hanging on an unimplemented PIT backend.
   */
  (void) minimum_ticks;
  bios_int15_complete_success (regs);
}

u16
bios_build_equipment_word (void)
{
  u16 equipment;
  u16 floppy_drives;
  u16 serial_ports;
  u16 parallel_ports;

  equipment = 0x0000;

  if (BIOS_CFG_FLOPPY_DRIVES != 0)
    {
      floppy_drives = (u16) (BIOS_CFG_FLOPPY_DRIVES - 1);
      equipment |= BIOS_EQUIP_BOOT_FLOPPY;
      equipment |= (u16) ((floppy_drives & 0x0003U) << BIOS_EQUIP_FLOPPY_SHIFT);
    }

  if (BIOS_CFG_HAS_MATH_COPROCESSOR)
    equipment |= BIOS_EQUIP_MATH_COPROCESSOR;

  equipment |= (u16) ((bios_equipment_video_bits () & 0x0003U)
                      << BIOS_EQUIP_VIDEO_SHIFT);

  serial_ports = bios_count_serial_ports ();
  parallel_ports = bios_count_parallel_ports ();
  equipment |= (u16) ((serial_ports & 0x0007U) << BIOS_EQUIP_SERIAL_SHIFT);
  equipment |= (u16) ((parallel_ports & 0x0003U) << BIOS_EQUIP_PRINTER_SHIFT);

  return equipment;
}

void
bios_service_int11 (bios_regs_t __far *regs)
{
  regs->ax = bios_bda_read16 (BDA_EQUIPMENT_WORD);
}

void
bios_service_int12 (bios_regs_t __far *regs)
{
  regs->ax = bios_bda_read16 (BDA_MEMORY_SIZE_KB);
}

void
bios_service_int15 (bios_regs_t __far *regs)
{
  switch (bios_hi (regs->ax))
    {
    case 0x86:
      bios_int15_wait (regs);
      break;

    case 0x88:
      regs->ax = BIOS_CFG_EXTENDED_MEMORY_KB;
      bios_clear_cf (regs);
      break;

    default:
      bios_int15_complete_unsupported (regs);
      break;
    }
}

void
bios_boot_failure (void)
{
  bios_work_write8 (WK_BOOT_FLAGS,
                    (u8) (bios_work_read8 (WK_BOOT_FLAGS) | BOOT_FLAG_BOOT_FAILED));

  for (;;)
    bios_bootstrap_loader ();
}

void
bios_nmi_handler (void)
{
  bios_work_write8 (WK_LAST_POST_CODE, 0xFF);
  bios_video_puts ("\r\n");
  bios_video_puts (bios_str_en_error_prefix);
  bios_video_puts (": ");
  bios_video_puts (bios_str_en_memory_parity);
  bios_video_puts ("\r\n");

  for (;;)
    {
    }
}
