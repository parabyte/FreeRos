#include "bios.h"

enum
{
  UART_REG_DATA = 0,
  UART_REG_IER = 1,
  UART_REG_LCR = 3,
  UART_REG_MCR = 4,
  UART_REG_LSR = 5
};

static u16
bios_serial_com1_port (u8 reg)
{
  return (u16) (BIOS_CFG_COM1_BASE + reg);
}

static int
bios_serial_com1_available (void)
{
  return BIOS_CFG_COM1_BASE != 0;
}

static void
bios_serial_wait_tx_empty (void)
{
  u16 attempts;

  if (!bios_serial_com1_available ())
    return;

  for (attempts = 0; attempts != 0x4000; ++attempts)
    {
      if ((bios_hw_in8 (bios_serial_com1_port (UART_REG_LSR)) & 0x20) != 0)
        return;
    }
}

void
bios_serial_init (void)
{
  if (!bios_serial_com1_available ())
    {
      bios_work_write8 (WK_SERIAL_STATUS, 0x00);
      return;
    }

  bios_hw_out8 (0x00, bios_serial_com1_port (UART_REG_IER));
  bios_hw_out8 (0x80, bios_serial_com1_port (UART_REG_LCR));
  bios_hw_out8 (0x0C, bios_serial_com1_port (UART_REG_DATA));
  bios_hw_out8 (0x00, bios_serial_com1_port (UART_REG_IER));
  bios_hw_out8 (0x03, bios_serial_com1_port (UART_REG_LCR));
  bios_hw_out8 (0x03, bios_serial_com1_port (UART_REG_MCR));
  bios_work_write8 (WK_SERIAL_STATUS, 0x60);
}

void
bios_serial_debug_putc (char ch)
{
#if BIOS_CFG_DEBUG_PORT_E9
  bios_hw_out8 ((u8) ch, 0x00E9);
#endif

#if BIOS_CFG_DEBUG_COM1
  if (!bios_serial_com1_available ())
    return;

  bios_serial_wait_tx_empty ();
  bios_hw_out8 ((u8) ch, bios_serial_com1_port (UART_REG_DATA));
#else
  (void) ch;
#endif
}

void
bios_serial_debug_puts (const char *text)
{
  while (*text != '\0')
    {
      if (*text == '\n')
        bios_serial_debug_putc ('\r');
      bios_serial_debug_putc (*text++);
    }
}

void
bios_serial_debug_put_hex8 (u8 value)
{
  static const char hex[] = "0123456789ABCDEF";

  bios_serial_debug_putc (hex[(value >> 4) & 0x0F]);
  bios_serial_debug_putc (hex[value & 0x0F]);
}

void
bios_service_int14 (bios_regs_t __far *regs)
{
  switch (bios_hi (regs->ax))
    {
    case 0x00:
      if (!bios_serial_com1_available ())
        {
          regs->ax = 0x8000;
          bios_set_cf (regs);
          break;
        }

      bios_serial_init ();
      regs->ax = 0x0060;
      bios_clear_cf (regs);
      break;

    case 0x01:
      if (!bios_serial_com1_available ())
        {
          regs->ax = 0x8000;
          bios_set_cf (regs);
          break;
        }

      bios_serial_debug_putc ((char) bios_lo (regs->ax));
      regs->ax = (u16) ((bios_lo (regs->ax)) | 0x6000);
      bios_clear_cf (regs);
      break;

    case 0x02:
      regs->ax = 0x8000;
      bios_set_cf (regs);
      break;

    case 0x03:
      if (!bios_serial_com1_available ())
        {
          regs->ax = 0x8000;
          bios_set_cf (regs);
          break;
        }

      regs->ax = (u16) (bios_hw_in8 (bios_serial_com1_port (UART_REG_LSR)) << 8);
      bios_clear_cf (regs);
      break;

    default:
      bios_set_cf (regs);
      break;
    }
}
