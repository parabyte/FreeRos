#include "bios.h"

void
bios_dma_init (void)
{
  /*
   * Master-clear the 8237 DMA controller, then set up channel 0 for
   * DRAM refresh: single transfer, auto-initialise, read, 64K count.
   * PIT channel 1 generates the ~15 us DREQ0 requests that drive it.
   */
  bios_hw_out8 (0x00, PORT_DMA1_MASTER_CLEAR);
  bios_hw_out8 (0x00, PORT_DMA1_CMD);
  bios_hw_out8 (0x00, PORT_DMA1_CLEAR_FF);
  bios_hw_out8 (0x58, PORT_DMA1_MODE);
  bios_hw_out8 (0x00, PORT_DMA_CH0_ADDR);
  bios_hw_out8 (0x00, PORT_DMA_CH0_ADDR);
  bios_hw_out8 (0xFF, PORT_DMA_CH0_COUNT);
  bios_hw_out8 (0xFF, PORT_DMA_CH0_COUNT);
  bios_hw_out8 (0x00, PORT_DMA_PAGE_CH0);
  bios_hw_out8 (0x00, PORT_DMA1_MASK);
}

void
bios_pic_init (void)
{
  bios_bda_write16 (BDA_EQUIPMENT_WORD, bios_build_equipment_word ());

  /*
   * The PC1640 uses an XT-class single 8259A on IRQ0-7. The original POST
   * leaves only IRQ0, IRQ1, and IRQ6 unmasked.
   */
  bios_io_write (PORT_PIC_CMD, 0x13);
  bios_io_write (PORT_PIC_DATA, 0x08);
  bios_io_write (PORT_PIC_DATA, 0x01);
  bios_io_write (PORT_PIC_DATA, 0xBC);
  bios_io_write (PORT_NMI_MASK, 0x00);
}

void
bios_pic_ack_irq (u8 irq)
{
  bios_io_write (PORT_PIC_CMD, (u8) (0x60 | (irq & 0x07)));
}

void
bios_pic_enable_runtime_irqs (void)
{
  bios_hw_out8 (0xBC, PORT_PIC_DATA);
}
