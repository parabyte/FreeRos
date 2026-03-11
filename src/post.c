#include "bios.h"

static void
bios_post_banner (void)
{
  bios_serial_debug_puts ("POST banner\n");
  bios_video_puts (BIOS_CFG_MACHINE_NAME);
  bios_video_puts ("\r\n");
  bios_video_puts (bios_str_amstrad_copyright);
  bios_video_puts ("\r\n");
}

static void
bios_post_fault (const char *detail)
{
  bios_video_puts (bios_str_en_error_prefix);
  bios_video_puts (": ");
  bios_video_puts (detail);
  bios_video_puts ("\r\n");
}

static void
bios_post_show_memory (void)
{
  bios_serial_debug_puts ("POST memory 640KB\n");
#if BIOS_CFG_POST_PRETTY_WAIT_PANEL
  bios_video_puts ("+----------------------------+\r\n");
  bios_video_puts ("| NEW BIOS SYSTEM CHECK      |\r\n");
  bios_video_puts ("| Base Memory ");
  bios_video_put_hex16 (BIOS_CFG_BASE_MEMORY_KB);
  bios_video_puts (" KB         |\r\n");
  bios_video_puts ("+----------------------------+\r\n");
#else
  bios_video_puts (bios_str_en_wait);
  bios_video_puts (" ");
  bios_video_put_hex16 (BIOS_CFG_BASE_MEMORY_KB);
  bios_video_puts (" KB\r\n");
#endif
}

static void
bios_post_hardware_init (void)
{
  bios_serial_init ();
  bios_serial_debug_puts ("HW serial ok\n");
  bios_pic_init ();
  bios_serial_debug_puts ("HW pic ok\n");
  bios_pit_init ();
  bios_serial_debug_puts ("HW pit ok\n");
  bios_keyboard_init ();
  bios_serial_debug_puts ("HW kbd ok\n");
  bios_floppy_init ();
  bios_serial_debug_puts ("HW floppy ok\n");
  bios_printer_init ();
  bios_serial_debug_puts ("HW printer ok\n");
  bios_rtc_init ();
  bios_serial_debug_puts ("HW rtc ok\n");
  bios_hw_enable_interrupts ();
  bios_serial_debug_puts ("HW interrupts on\n");
}

void
bios_post_cold_boot (void)
{
  u8 boot_flags;

  bios_io_write (PORT_DEAD_DIAG, 0x01);
  bios_post_hardware_init ();
  bios_post_banner ();

  if (!bios_rtc_battery_ok ())
    {
      boot_flags = (u8) (bios_work_read8 (WK_BOOT_FLAGS) | BOOT_FLAG_BATTERY_LOW);
      bios_work_write8 (WK_BOOT_FLAGS, boot_flags);
      bios_video_puts (bios_str_en_battery_warning);
      bios_video_puts ("\r\n");
    }

  if (!bios_keyboard_self_test ())
    {
      boot_flags = (u8) (bios_work_read8 (WK_BOOT_FLAGS) | BOOT_FLAG_KBD_FAULT);
      bios_work_write8 (WK_BOOT_FLAGS, boot_flags);
      bios_video_puts (bios_str_en_check_keyboard_mouse);
      bios_video_puts ("\r\n");
    }

  bios_post_show_memory ();

  if ((bios_work_read8 (WK_BOOT_FLAGS) & BOOT_FLAG_KBD_FAULT) != 0)
    bios_post_fault (bios_str_en_check_keyboard_mouse);

  bios_io_write (PORT_DEAD_DIAG, 0x19);
  bios_bootstrap_loader ();
}
