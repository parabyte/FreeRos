#include "bios.h"

enum
{
  UART_REG_DATA = 0,
  UART_REG_IER = 1,
  UART_REG_LCR = 3,
  UART_REG_MCR = 4,
  UART_REG_LSR = 5,
  UART_REG_MSR = 6
};

#define UART_LSR_DATA_READY 0x01
#define UART_LSR_THR_EMPTY 0x20
#define UART_MCR_RTS 0x02
#define UART_MSR_CTS 0x10

static u16
bios_serial_baud_divisor (u8 params)
{
  u8 baud_code;

  baud_code = (u8) ((params >> 5) & 0x07);
  if (baud_code == 0)
    return 0x0417;
  return (u16) (0x0600U >> baud_code);
}

static u8
bios_serial_line_control (u8 params)
{
  return (u8) (params & 0x1F);
}

static u16
bios_serial_base (u16 index)
{
  switch (index)
    {
    case 0:
      return BIOS_CFG_COM1_BASE;

    case 1:
      return BIOS_CFG_COM2_BASE;

    default:
      return 0;
    }
}

static u16
bios_serial_port (u16 index, u8 reg)
{
  return (u16) (bios_serial_base (index) + reg);
}

static int
bios_serial_available (u16 index)
{
  return bios_serial_base (index) != 0;
}

void
bios_serial_init (void)
{
  if (!bios_serial_available (0))
    {
      bios_work_write8 (WK_SERIAL_STATUS, 0x00);
      return;
    }

  bios_hw_out8 (0x00, bios_serial_port (0, UART_REG_IER));
  bios_hw_out8 (0x80, bios_serial_port (0, UART_REG_LCR));
  bios_hw_out8 (0x0C, bios_serial_port (0, UART_REG_DATA));
  bios_hw_out8 (0x00, bios_serial_port (0, UART_REG_IER));
  bios_hw_out8 (0x03, bios_serial_port (0, UART_REG_LCR));
  bios_hw_out8 (0x03, bios_serial_port (0, UART_REG_MCR));
  bios_work_write8 (WK_SERIAL_STATUS, 0x60);
}

#if BIOS_CFG_DEBUG_PORT_E9 || BIOS_CFG_DEBUG_COM1
static void
bios_serial_wait_tx_empty (u16 index)
{
  u16 attempts;

  if (!bios_serial_available (index))
    return;

  for (attempts = 0; attempts != 0x4000; ++attempts)
    {
      if ((bios_hw_in8 (bios_serial_port (index, UART_REG_LSR))
	   & UART_LSR_THR_EMPTY) != 0)
	return;
    }
}

void
bios_serial_debug_putc (char ch)
{
#if BIOS_CFG_DEBUG_PORT_E9
  bios_hw_out8 ((u8) ch, 0x00E9);
#endif

#if BIOS_CFG_DEBUG_COM1
  if (!bios_serial_available (0))
    return;

  bios_serial_wait_tx_empty (0);
  bios_hw_out8 ((u8) ch, bios_serial_port (0, UART_REG_DATA));
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
  bios_serial_debug_putc (bios_hex_digits[(value >> 4) & 0x0F]);
  bios_serial_debug_putc (bios_hex_digits[value & 0x0F]);
}

void
bios_serial_debug_put_hex16 (u16 value)
{
  bios_serial_debug_put_hex8 (bios_hi (value));
  bios_serial_debug_put_hex8 (bios_lo (value));
}
#endif

void
bios_service_int14 (bios_regs_t __far *regs)
{
  u8 lsr;
  u16 port_index;
  u16 port;
  u16 divisor;
  u16 attempts;

  port_index = regs->dx;
  port = bios_serial_base (port_index);
  switch (bios_hi (regs->ax))
    {
    case 0x00:
      if (port == 0)
	{
	  regs->ax = 0x8000;
	  bios_set_cf (regs);
	  break;
	}

      divisor = bios_serial_baud_divisor (bios_lo (regs->ax));
      bios_hw_out8 ((u8)
		    (bios_hw_in8 (bios_serial_port (port_index, UART_REG_LCR))
		     | 0x80), bios_serial_port (port_index, UART_REG_LCR));
      bios_hw_out8 ((u8) divisor, port + UART_REG_DATA);
      bios_hw_out8 ((u8) (divisor >> 8), port + UART_REG_IER);
      bios_hw_out8 (bios_serial_line_control (bios_lo (regs->ax)),
		    bios_serial_port (port_index, UART_REG_LCR));
      bios_set_hi (&regs->ax,
		   bios_hw_in8 (bios_serial_port (port_index, UART_REG_LSR)));
      bios_set_lo (&regs->ax, bios_hw_in8 ((u16) (port + 6)));
      bios_clear_cf (regs);
      break;

    case 0x01:
      if (port == 0)
	{
	  regs->ax = 0x8000;
	  bios_set_cf (regs);
	  break;
	}

      /*
       * Original PC1640 BIOS: raise RTS, then wait for CTS and TX holding
       * register empty before sending the character.
       */
      {
	u8 mcr;

	mcr = bios_hw_in8 (bios_serial_port (port_index, UART_REG_MCR));
	bios_hw_out8 ((u8) (mcr | UART_MCR_RTS),
		      bios_serial_port (port_index, UART_REG_MCR));
      }
      lsr = 0;
      for (attempts = 0; attempts != 0x8000; ++attempts)
	{
	  lsr = bios_hw_in8 (bios_serial_port (port_index, UART_REG_LSR));
	  if ((lsr & UART_LSR_THR_EMPTY) != 0
	      && (bios_hw_in8 (bios_serial_port (port_index, UART_REG_MSR))
		  & UART_MSR_CTS) != 0)
	    {
	      bios_hw_out8 (bios_lo (regs->ax),
			    bios_serial_port (port_index, UART_REG_DATA));
	      bios_set_hi (&regs->ax, lsr);
	      bios_clear_cf (regs);
	      return;
	    }
	  bios_hw_pause ();
	}

      bios_set_hi (&regs->ax, (u8) (lsr | 0x80));
      bios_clear_cf (regs);
      break;

    case 0x02:
      if (port == 0)
	{
	  regs->ax = 0x8000;
	  bios_set_cf (regs);
	  break;
	}

      lsr = 0;
      for (attempts = 0; attempts != 0x8000; ++attempts)
	{
	  lsr = bios_hw_in8 (bios_serial_port (port_index, UART_REG_LSR));
	  if ((lsr & UART_LSR_DATA_READY) != 0)
	    {
	      bios_set_lo (&regs->ax,
			   bios_hw_in8 (bios_serial_port
					(port_index, UART_REG_DATA)));
	      bios_set_hi (&regs->ax, lsr);
	      bios_clear_cf (regs);
	      return;
	    }
	  bios_hw_pause ();
	}

      bios_set_hi (&regs->ax, (u8) (lsr | 0x80));
      bios_clear_cf (regs);
      break;

    case 0x03:
      if (port == 0)
	{
	  regs->ax = 0x8000;
	  bios_set_cf (regs);
	  break;
	}

      bios_set_hi (&regs->ax,
		   bios_hw_in8 (bios_serial_port (port_index, UART_REG_LSR)));
      bios_set_lo (&regs->ax, bios_hw_in8 ((u16) (port + 6)));
      bios_clear_cf (regs);
      break;

    default:
      bios_set_cf (regs);
      break;
    }
}
