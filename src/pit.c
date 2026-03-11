#include "bios.h"

void
bios_pit_init (void)
{
  bios_io_write (PORT_PIT_MODE, 0x36);
  bios_io_write (PORT_PIT_CH0, 0x00);
  bios_io_write (PORT_PIT_CH0, 0x00);
}

void
bios_timer_tick (void)
{
  u32 ticks;

  ticks = bios_bda_read32 (BDA_TIMER_TICKS);
  ticks++;
  bios_bda_write32 (BDA_TIMER_TICKS, ticks);
  if (ticks >= 0x001800B0UL)
    {
      bios_bda_write32 (BDA_TIMER_TICKS, 0);
      bios_bda_write8 (BDA_TIMER_MIDNIGHT, 1);
    }
  bios_pic_ack_irq (0);
}

void
bios_beep_ticks (u16 ticks)
{
  (void) ticks;
  bios_io_write (PORT_PPI_PORT_B,
                 (u8) (bios_io_read (PORT_PPI_PORT_B)
                       | PORT61_SPEAKER_GATE
                       | PORT61_SPEAKER_DATA));
}
