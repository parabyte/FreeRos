#include "bios.h"

#define BIOS_EQUIP_BOOT_FLOPPY 0x0001
#define BIOS_EQUIP_MATH_COPROCESSOR 0x0002
#define BIOS_EQUIP_VIDEO_SHIFT 4
#define BIOS_EQUIP_FLOPPY_SHIFT 6
#define BIOS_EQUIP_SERIAL_SHIFT 9
#define BIOS_EQUIP_PRINTER_SHIFT 14

#define BIOS_EQUIP_VIDEO_EGA_ADAPTER 0x0000
#define BIOS_EQUIP_VIDEO_40X25_COLOR 0x0001
#define BIOS_EQUIP_VIDEO_80X25_COLOR 0x0002
#define BIOS_EQUIP_VIDEO_MONO 0x0003

#define BIOS_INT15_UNSUPPORTED 0x86

static u16 bios_equipment_video_bits (void);

static u8
bios_pc1640_switch_latch_read (u16 latch_port)
{
  u8 control;

  if (!BIOS_CFG_VIDEO_USE_PC1640_SWITCH_BLOCK)
    return 0;

  bios_hw_disable_interrupts ();
  (void) bios_hw_in8 (latch_port);
  control = bios_hw_in8 (PORT_LPT1_CONTROL);
  bios_hw_enable_interrupts ();
  return control;
}

static u8
bios_pc1640_switch_status_read (void)
{
  return bios_pc1640_switch_latch_read (PORT_PC1640_SW10_LATCH);
}

static void
bios_boot_failure_wait_key (void)
{
  bios_regs_t regs;

  regs.ax = 0x0000;
  regs.bx = 0x0000;
  regs.cx = 0x0000;
  regs.dx = 0x0000;
  regs.si = 0x0000;
  regs.di = 0x0000;
  regs.bp = 0x0000;
  regs.ds = 0x0000;
  regs.es = 0x0000;
  regs.flags = 0x0000;
  bios_service_int16 (&regs);
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
      /*
       * Let the Paradise ROM own video-mode setup.  Using the PEGA probe
       * sequence here writes MISC output values before the option ROM has
       * initialized the adapter, which can leave bring-up stuck in 86Box.
       * Report the stock PC1640 colour text profile until the PEGA ROM
       * publishes the real active mode in the BDA.
       */
      return BIOS_EQUIP_VIDEO_80X25_COLOR;
    }

  if ((control & (LPT1_CONTROL_SWITCH_SW7 | LPT1_CONTROL_SWITCH_SW6)) == 0)
    return BIOS_EQUIP_VIDEO_EGA_ADAPTER;

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

    case BIOS_EQUIP_VIDEO_EGA_ADAPTER:
    default:
      return 0x00;
    }
}

u8
bios_default_text_mode (void)
{
  if (BIOS_CFG_HAS_PARADISE_PEGA1A
      && BIOS_CFG_VIDEO_USE_PC1640_SWITCH_BLOCK
      && (bios_pc1640_switch_status_read () & LPT1_CONTROL_SWITCH_SW10) == 0)
    return VIDEO_MODE_80X25_COLOR;

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
  u16 memory_kb;
  u8 ram_code;

  memory_kb = bios_bda_read16 (BDA_MEMORY_SIZE_KB);
  if (memory_kb < 544)
    ram_code = 0x0E;
  else if (memory_kb < 576)
    ram_code = 0x0F;
  else if (memory_kb < 608)
    ram_code = 0x10;
  else if (memory_kb < 640)
    ram_code = 0x11;
  else
    ram_code = 0x12;

  /*
   * WSS2 packs the low nibble (RAM3:0) and the selected high nibble
   * (undefined, undefined, undefined, RAM4) into one byte. The undefined
   * upper bits are kept at the stock 100b pattern used by the original ROM.
   */
  return (u8) (0x80 | ram_code);
}

u8
bios_build_video_switches (void)
{
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
      return BIOS_EQUIP_VIDEO_EGA_ADAPTER;
    }
}

static void
bios_int15_complete_unsupported (bios_regs_t __far *regs)
{
  bios_set_hi (&regs->ax, BIOS_INT15_UNSUPPORTED);
  bios_set_cf (regs);
}

u16
bios_build_equipment_word (void)
{
  u16 equipment;
  u16 floppy_drives;
  u16 serial_ports;
  u16 parallel_ports;

  /*
   * PC1640 always reports bits 2-3 set (motherboard RAM banks = 4,
   * i.e., at least 64 KiB on-board), matching the original ROS.
   */
  equipment = 0x000C;

  if (BIOS_CFG_FLOPPY_DRIVES != 0)
    {
      floppy_drives = (u16) (BIOS_CFG_FLOPPY_DRIVES - 1);
      equipment |= BIOS_EQUIP_BOOT_FLOPPY;
      equipment |=
	(u16) ((floppy_drives & 0x0003U) << BIOS_EQUIP_FLOPPY_SHIFT);
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
    case 0x00:
    case 0x01:
    case 0x02:
    case 0x03:
    case 0x04:
    case 0x05:
    case 0x06:
      bios_service_pc1640_int15 (regs);
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
		    (u8) (bios_work_read8 (WK_BOOT_FLAGS) |
			  BOOT_FLAG_BOOT_FAILED));

  bios_video_set_attribute (0x07);
  for (;;)
    {
      bios_video_puts (bios_str_en_insert_system_disk);
      bios_video_puts ("\r\n");
      bios_boot_failure_wait_key ();
      bios_invoke_int19 ();
    }
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
