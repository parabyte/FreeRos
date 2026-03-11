#include "bios.h"

static int
bios_printer_available (u16 index)
{
  if (index == 0)
    return BIOS_CFG_LPT1_BASE != 0;

  if (index == 1)
    return BIOS_CFG_LPT2_BASE != 0;

  return 0;
}

void
bios_printer_init (void)
{
  bios_work_write8 (WK_PRINTER_STATUS,
                    (u8) (bios_printer_available (0) ? 0x90 : 0x00));
}

void
bios_printer_irq7 (void)
{
  bios_pic_ack_irq (7);
}

void
bios_service_int17 (bios_regs_t __far *regs)
{
  switch (bios_hi (regs->ax))
    {
    case 0x00:
    case 0x01:
    case 0x02:
      if (!bios_printer_available (regs->dx))
        {
          bios_set_cf (regs);
          break;
        }

      bios_set_hi (&regs->ax, bios_work_read8 (WK_PRINTER_STATUS));
      bios_clear_cf (regs);
      break;

    default:
      bios_set_cf (regs);
      break;
    }
}
