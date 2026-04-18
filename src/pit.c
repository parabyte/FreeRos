#include "bios.h"

#define BIOS_PIT_CH0_RELOAD 65536UL
#define BIOS_TIMER_TICK_US 54925UL
#define BIOS_SPEAKER_DIVISOR 0x07D0

static void bios_speaker_square_wave_ticks (u16 divisor, u16 ticks);

static u8
bios_pit_read_port61 (void)
{
  u8 value;

  asm volatile ("inb $0x61,%%al":"=Ral" (value));
  bios_work_write8 (WK_PORT61, value);
  return value;
}

static void
bios_pit_write_port61 (u8 value)
{
  bios_work_write8 (WK_PORT61, value);
  asm volatile ("outb %%al,$0x61"::"Ral" (value));
}

void
bios_wait_timer_ticks (u16 ticks)
{
  u16 flags;
  u32 start_ticks;

  if (ticks == 0)
    return;

  /*
   * Tick-based waits only make forward progress if IRQ0 can run. Preserve the
   * caller's IF state so INT handlers can safely borrow this helper without
   * leaving interrupts enabled on return.
   */
  flags = bios_hw_irq_save_disable ();
  start_ticks = bios_bda_read32 (BDA_TIMER_TICKS);
  bios_hw_enable_interrupts ();
  while ((u32) (bios_bda_read32 (BDA_TIMER_TICKS) - start_ticks) < ticks)
    bios_hw_pause ();
  bios_hw_irq_restore (flags);
}

void
bios_wait_microseconds (u32 delay_us)
{
  u16 start;
  u16 counts;
  u8 lo;
  u8 hi;

  if (delay_us == 0)
    return;

  /*
   * Convert microseconds to PIT counts (1.193182 MHz).
   * For delays up to ~54 ms (one timer tick), use the PIT channel 0
   * countdown directly.  For longer delays, fall through to tick-based
   * waiting.  The callers in this BIOS only need short sub-tick delays
   * (printer strobe timing), so the simple path covers all current uses.
   *
   * counts = delay_us * 1193182 / 1000000 ≈ delay_us + delay_us / 5
   * This slightly overestimates, which is safe for minimum-delay usage.
   */
  if (delay_us >= BIOS_TIMER_TICK_US)
    {
      u16 ticks;

      ticks = 0;
      while (delay_us >= BIOS_TIMER_TICK_US)
        {
          delay_us -= BIOS_TIMER_TICK_US;
          ticks++;
        }
      bios_wait_timer_ticks ((u16) (ticks + 1U));
      return;
    }

  /* counts ≈ delay_us * 1.2 ≈ delay_us + delay_us/4 (slight overcount is safe) */
  counts = (u16) delay_us + (u16) (delay_us >> 2);
  if (counts == 0)
    counts = 1;

  /* Latch and read channel 0. */
  bios_hw_disable_interrupts ();
  bios_hw_out8 (0x00, PORT_PIT_MODE);
  lo = bios_hw_in8 (PORT_PIT_CH0);
  hi = bios_hw_in8 (PORT_PIT_CH0);
  bios_hw_enable_interrupts ();
  start = (u16) lo | (u16) hi << 8;

  for (;;)
    {
      u16 now;

      bios_hw_disable_interrupts ();
      bios_hw_out8 (0x00, PORT_PIT_MODE);
      lo = bios_hw_in8 (PORT_PIT_CH0);
      hi = bios_hw_in8 (PORT_PIT_CH0);
      bios_hw_enable_interrupts ();
      now = (u16) lo | (u16) hi << 8;

      if ((u16) (start - now) >= counts)
        break;

      bios_hw_pause ();
    }
}

void
bios_pit_init (void)
{
  /* Channel 0: System timer, mode 3 (square wave), max count = 65536. */
  bios_io_write (PORT_PIT_MODE, 0x36);
  bios_io_write (PORT_PIT_CH0, 0x00);
  bios_io_write (PORT_PIT_CH0, 0x00);

  /*
   * Channel 1: DRAM refresh, mode 2 (rate generator), count 18.
   * At 1.19318 MHz this gives ~15.09 us per request, matching the original
   * PC1640 POST initialization ("counter 1, 15.13 us period").
   */
  bios_hw_out8 (0x54, PORT_PIT_MODE);
  bios_hw_out8 (18, 0x0041);
  bios_hw_out8 (0, 0x0041);
}

void
bios_timer_tick (void)
{
  u32 ticks;
  u8 motor_timeout;

  ticks = bios_bda_read32 (BDA_TIMER_TICKS);
  ticks++;
  bios_bda_write32 (BDA_TIMER_TICKS, ticks);
  bios_rtc_periodic_housekeeping (ticks);
  if (ticks >= 0x001800B0UL)
    {
      bios_bda_write32 (BDA_TIMER_TICKS, 0);
      bios_bda_write8 (BDA_TIMER_MIDNIGHT, 1);
    }

  /*
   * Original PC1640 BIOS decrements the floppy motor timeout counter each
   * tick. When it reaches zero, all drive motors are turned off by writing
   * 0x0C to the DOR (controller enabled, no drive selected, no motors).
   */
  motor_timeout = bios_bda_read8 (BDA_FLOPPY_MOTOR_TIMEOUT);
  if (motor_timeout != 0)
    {
      motor_timeout--;
      bios_bda_write8 (BDA_FLOPPY_MOTOR_TIMEOUT, motor_timeout);
      if (motor_timeout == 0)
	{
	  bios_bda_write8 (BDA_FLOPPY_MOTOR, 0x00);
	  bios_hw_out8 (0x0C, PORT_FDC_DOR);
	}
    }

  /*
   * XT/AT-class BIOS IRQ0 handling chains the user timer hook on INT 1Ch
   * after updating the BIOS tick count and before issuing the EOI.
   */
  asm volatile ("push %%ax\n\t"
		"push %%bx\n\t"
		"push %%cx\n\t"
		"push %%dx\n\t"
		"push %%si\n\t"
		"push %%di\n\t"
		"push %%bp\n\t"
		"push %%ds\n\t"
		"push %%es\n\t"
		"int $0x1c\n\t"
		"pop %%es\n\t"
		"pop %%ds\n\t"
		"pop %%bp\n\t"
		"pop %%di\n\t"
		"pop %%si\n\t"
		"pop %%dx\n\t"
		"pop %%cx\n\t" "pop %%bx\n\t" "pop %%ax":::"cc", "memory");

  bios_pic_ack_irq (0);
}

void
bios_beep_ticks (u16 ticks)
{
  bios_speaker_square_wave_ticks (BIOS_SPEAKER_DIVISOR, ticks);
}

static void
bios_speaker_square_wave_ticks (u16 divisor, u16 ticks)
{
  u8 port61;

  if (ticks == 0 || divisor == 0)
    return;

  bios_hw_out8 (0xB6, PORT_PIT_MODE);
  bios_hw_out8 ((u8) (divisor & 0x00FF), PORT_PIT_CH2);
  bios_hw_out8 ((u8) (divisor >> 8), PORT_PIT_CH2);

  port61 = bios_pit_read_port61 ();
  bios_pit_write_port61 ((u8) (port61 | PORT61_SPEAKER_GATE
                               | PORT61_SPEAKER_DATA));
  bios_wait_timer_ticks (ticks);
  bios_pit_write_port61 ((u8) (port61 & (u8) ~ (PORT61_SPEAKER_GATE
                                                | PORT61_SPEAKER_DATA)));
}

void
bios_play_space_invaders_effect (void)
{
  static const u16 divisors[] = { 0x0534, 0x05F2, 0x06B8, 0x0780, 0x06B8, 0x05F2 };
  u8 i;

  for (i = 0; i != (sizeof (divisors) / sizeof (divisors[0])); ++i)
    {
      bios_speaker_square_wave_ticks (divisors[i], 1);
      bios_wait_timer_ticks (1);
    }
}
