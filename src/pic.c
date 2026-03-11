#include "bios.h"

void
bios_pic_init (void)
{
  bios_bda_write16 (BDA_EQUIPMENT_WORD, bios_build_equipment_word ());

  bios_io_write (PORT_PIC_CMD, 0x11);
  bios_io_write (PORT_PIC_DATA, 0x08);
  bios_io_write (PORT_PIC_DATA, 0x04);
  bios_io_write (PORT_PIC_DATA, 0x01);
  bios_io_write (PORT_PIC_DATA, 0x1C);
  bios_io_write (PORT_NMI_MASK, 0x00);
}

void
bios_pic_ack_irq (u8 irq)
{
  bios_io_write (PORT_PIC_CMD, (u8) (0x60 | (irq & 0x07)));
}
