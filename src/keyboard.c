#include "bios.h"

static const u8 bios_keyboard_ascii_normal[128] = {
  0,   27,  '1', '2', '3', '4', '5', '6',
  '7', '8', '9', '0', '-', '=', '\b', '\t',
  'q', 'w', 'e', 'r', 't', 'y', 'u', 'i',
  'o', 'p', '[', ']', '\r', 0,   'a', 's',
  'd', 'f', 'g', 'h', 'j', 'k', 'l', ';',
  '\'', '`', 0,   '\\', 'z', 'x', 'c', 'v',
  'b', 'n', 'm', ',', '.', '/', 0,   '*',
  0,   ' ', 0,   0,   0,   0,   0,   0,
  0,   0,   0,   0,   0,   0,   0,   '7',
  '8', '9', '-', '4', '5', '6', '+', '1',
  '2', '3', '0', '.', 0,   0,   0,   0,
  0,   0,   0,   0,   0,   0,   0,   0,
  0,   0,   0,   0,   0,   0,   0,   0,
  0,   0,   0,   0,   0,   0,   0,   0,
  0,   0,   0,   0,   0,   0,   0,   0
};

static const u8 bios_keyboard_ascii_shift[128] = {
  0,   27,  '!', '@', '#', '$', '%', '^',
  '&', '*', '(', ')', '_', '+', '\b', '\t',
  'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I',
  'O', 'P', '{', '}', '\r', 0,   'A', 'S',
  'D', 'F', 'G', 'H', 'J', 'K', 'L', ':',
  '"', '~', 0,   '|', 'Z', 'X', 'C', 'V',
  'B', 'N', 'M', '<', '>', '?', 0,   '*',
  0,   ' ', 0,   0,   0,   0,   0,   0,
  0,   0,   0,   0,   0,   0,   0,   '7',
  '8', '9', '-', '4', '5', '6', '+', '1',
  '2', '3', '0', '.', 0,   0,   0,   0,
  0,   0,   0,   0,   0,   0,   0,   0,
  0,   0,   0,   0,   0,   0,   0,   0,
  0,   0,   0,   0,   0,   0,   0,   0,
  0,   0,   0,   0,   0,   0,   0,   0
};

static void
bios_keyboard_put_entry (u16 entry)
{
  u16 head;
  u16 tail;
  u16 next_tail;

  head = bios_bda_read16 (BDA_KBD_BUF_HEAD);
  tail = bios_bda_read16 (BDA_KBD_BUF_TAIL);
  next_tail = (u16) (tail + 2);
  if (next_tail >= BDA_KBD_BUF_END)
    next_tail = BDA_KBD_BUF_START;
  if (next_tail == head)
    return;

  bios_bda_write16 (tail, entry);
  bios_bda_write16 (BDA_KBD_BUF_TAIL, next_tail);
}

static int
bios_keyboard_peek_entry (u16 *entry)
{
  u16 head;
  u16 tail;

  head = bios_bda_read16 (BDA_KBD_BUF_HEAD);
  tail = bios_bda_read16 (BDA_KBD_BUF_TAIL);
  if (head == tail)
    return 0;

  *entry = bios_bda_read16 (head);
  return 1;
}

static int
bios_keyboard_get_entry (u16 *entry)
{
  u16 head;
  u16 tail;
  u16 next_head;

  head = bios_bda_read16 (BDA_KBD_BUF_HEAD);
  tail = bios_bda_read16 (BDA_KBD_BUF_TAIL);
  if (head == tail)
    return 0;

  *entry = bios_bda_read16 (head);
  next_head = (u16) (head + 2);
  if (next_head >= BDA_KBD_BUF_END)
    next_head = BDA_KBD_BUF_START;
  bios_bda_write16 (BDA_KBD_BUF_HEAD, next_head);
  return 1;
}

static u8
bios_keyboard_flags (void)
{
  return bios_bda_read8 (BDA_KBD_FLAGS);
}

static void
bios_keyboard_set_flags (u8 flags)
{
  bios_bda_write8 (BDA_KBD_FLAGS, flags);
  bios_work_write8 (WK_KBD_LED_STATE,
                    (u8) (flags & (KBD_FLAG_SCROLL_LOCK
                                   | KBD_FLAG_NUM_LOCK
                                   | KBD_FLAG_CAPS_LOCK)));
}

static void
bios_keyboard_update_flag (u8 mask, int set_flag)
{
  u8 flags;

  flags = bios_keyboard_flags ();
  if (set_flag)
    flags |= mask;
  else
    flags &= (u8) ~mask;
  bios_keyboard_set_flags (flags);
}

static void
bios_keyboard_toggle_flag (u8 mask)
{
  bios_keyboard_set_flags ((u8) (bios_keyboard_flags () ^ mask));
}

static int
bios_keyboard_is_alpha (u8 ascii)
{
  return ascii >= 'a' && ascii <= 'z';
}

static int
bios_keyboard_is_keypad_key (u8 scancode)
{
  switch (scancode)
    {
    case 0x47:
    case 0x48:
    case 0x49:
    case 0x4A:
    case 0x4B:
    case 0x4C:
    case 0x4D:
    case 0x4E:
    case 0x4F:
    case 0x50:
    case 0x51:
    case 0x52:
    case 0x53:
      return 1;

    default:
      return 0;
    }
}

static u8
bios_keyboard_ctrl_ascii (u8 ascii)
{
  if (ascii >= 'a' && ascii <= 'z')
    return (u8) (ascii - 'a' + 1);

  switch (ascii)
    {
    case '[':
      return 0x1B;

    case '\\':
      return 0x1C;

    case ']':
      return 0x1D;

    case '6':
      return 0x1E;

    case '-':
      return 0x1F;

    default:
      return 0;
    }
}

static u8
bios_keyboard_translate_ascii (u8 scancode, u8 prefix)
{
  u8 flags;
  u8 ascii;
  int shifted;
  int caps_lock;

  flags = bios_keyboard_flags ();
  shifted = (flags & (KBD_FLAG_LEFT_SHIFT | KBD_FLAG_RIGHT_SHIFT)) != 0;
  caps_lock = (flags & KBD_FLAG_CAPS_LOCK) != 0;

  if (prefix != 0)
    {
      if (scancode == 0x1C)
        return '\r';
      if (scancode == 0x35)
        return '/';
      return 0;
    }

  if ((flags & KBD_FLAG_ALT) != 0)
    return 0;

  if (bios_keyboard_is_keypad_key (scancode))
    {
      if ((flags & KBD_FLAG_NUM_LOCK) == 0
          || shifted
          || scancode == 0x4A
          || scancode == 0x4E)
        {
          if (scancode == 0x4A || scancode == 0x4E)
            return bios_keyboard_ascii_normal[scancode];
          return 0;
        }
    }

  ascii = shifted ? bios_keyboard_ascii_shift[scancode]
                  : bios_keyboard_ascii_normal[scancode];
  if (bios_keyboard_is_alpha (bios_keyboard_ascii_normal[scancode]))
    {
      if (shifted ^ caps_lock)
        ascii = bios_keyboard_ascii_shift[scancode];
      else
        ascii = bios_keyboard_ascii_normal[scancode];
    }

  if ((flags & KBD_FLAG_CTRL) != 0)
    ascii = bios_keyboard_ctrl_ascii (bios_keyboard_ascii_normal[scancode]);

  return ascii;
}

static void
bios_keyboard_acknowledge_controller (void)
{
  u8 port61;

  port61 = bios_io_read (PORT_PPI_PORT_B);
  bios_io_write (PORT_PPI_PORT_B, (u8) (port61 | PORT61_STATUS_MODE));
  bios_io_write (PORT_PPI_PORT_B, (u8) (port61 & (u8) ~PORT61_STATUS_MODE));
}

static int
bios_keyboard_handle_modifier (u8 scancode, u8 prefix, int released)
{
  switch (scancode)
    {
    case 0x2A:
      bios_keyboard_update_flag (KBD_FLAG_LEFT_SHIFT, !released);
      return 1;

    case 0x36:
      bios_keyboard_update_flag (KBD_FLAG_RIGHT_SHIFT, !released);
      return 1;

    case 0x1D:
      if (prefix != 0)
        bios_bda_write8 (BDA_KBD_FLAGS_2,
                         released ? (u8) (bios_bda_read8 (BDA_KBD_FLAGS_2)
                                           & (u8) ~0x04)
                                  : (u8) (bios_bda_read8 (BDA_KBD_FLAGS_2)
                                          | 0x04));
      bios_keyboard_update_flag (KBD_FLAG_CTRL, !released);
      return 1;

    case 0x38:
      if (prefix != 0)
        bios_bda_write8 (BDA_KBD_FLAGS_2,
                         released ? (u8) (bios_bda_read8 (BDA_KBD_FLAGS_2)
                                           & (u8) ~0x08)
                                  : (u8) (bios_bda_read8 (BDA_KBD_FLAGS_2)
                                          | 0x08));
      bios_keyboard_update_flag (KBD_FLAG_ALT, !released);
      return 1;

    case 0x3A:
      if (!released)
        bios_keyboard_toggle_flag (KBD_FLAG_CAPS_LOCK);
      return 1;

    case 0x45:
      if (!released)
        bios_keyboard_toggle_flag (KBD_FLAG_NUM_LOCK);
      return 1;

    case 0x46:
      if (!released)
        bios_keyboard_toggle_flag (KBD_FLAG_SCROLL_LOCK);
      return 1;

    case 0x52:
      if (prefix != 0)
        {
          bios_keyboard_update_flag (KBD_FLAG_INSERT, !released);
          return 1;
        }
      return 0;

    default:
      return 0;
    }
}

void
bios_keyboard_init (void)
{
  bios_bda_write8 (BDA_KBD_FLAGS, 0x00);
  bios_bda_write8 (BDA_KBD_FLAGS_2, 0x00);
  bios_bda_write8 (BDA_KBD_ALT_PAD, 0x00);
  bios_bda_write16 (BDA_KBD_BUF_HEAD, BDA_KBD_BUF_START);
  bios_bda_write16 (BDA_KBD_BUF_TAIL, BDA_KBD_BUF_START);
  bios_work_write8 (WK_KBD_PREFIX, 0x00);
  bios_work_write8 (WK_LAST_KBD_SCANCODE, 0x00);
  bios_work_write8 (WK_LAST_KBD_ASCII, 0x00);
  bios_work_write8 (WK_KBD_LED_STATE, 0x00);
}

int
bios_keyboard_self_test (void)
{
  return 1;
}

void
bios_keyboard_irq1 (void)
{
  u8 raw_scancode;
  u8 scancode;
  u8 prefix;
  u8 ascii;
  int released;

  raw_scancode = bios_io_read (PORT_KBD_DATA);
  bios_keyboard_acknowledge_controller ();

  if (raw_scancode == 0xE0 || raw_scancode == 0xE1)
    {
      bios_work_write8 (WK_KBD_PREFIX, raw_scancode);
      bios_pic_ack_irq (1);
      return;
    }

  prefix = bios_work_read8 (WK_KBD_PREFIX);
  bios_work_write8 (WK_KBD_PREFIX, 0x00);

  scancode = (u8) (raw_scancode & 0x7F);
  released = (raw_scancode & 0x80) != 0;
  bios_work_write8 (WK_LAST_KBD_SCANCODE, scancode);

  if (bios_keyboard_handle_modifier (scancode, prefix, released))
    {
      bios_pic_ack_irq (1);
      return;
    }

  if (released)
    {
      bios_pic_ack_irq (1);
      return;
    }

  ascii = bios_keyboard_translate_ascii (scancode, prefix);
  bios_work_write8 (WK_LAST_KBD_ASCII, ascii);
  bios_keyboard_put_entry ((u16) scancode << 8 | ascii);
  bios_pic_ack_irq (1);
}

void
bios_keyboard_wait_for_keypress (void)
{
  u16 entry;

  while (!bios_keyboard_peek_entry (&entry))
    {
      bios_hw_enable_interrupts ();
      bios_hw_halt ();
    }
}

void
bios_service_int16 (bios_regs_t __far *regs)
{
  u16 entry;

  switch (bios_hi (regs->ax))
    {
    case 0x00:
      while (!bios_keyboard_get_entry (&entry))
        bios_keyboard_wait_for_keypress ();
      regs->ax = entry;
      bios_set_zf (regs, 0);
      bios_clear_cf (regs);
      break;

    case 0x01:
      if (bios_keyboard_peek_entry (&entry))
        {
          regs->ax = entry;
          bios_set_zf (regs, 0);
        }
      else
        {
          regs->ax = 0;
          bios_set_zf (regs, 1);
        }
      bios_clear_cf (regs);
      break;

    case 0x02:
      bios_set_lo (&regs->ax, bios_keyboard_flags ());
      bios_set_zf (regs, 0);
      bios_clear_cf (regs);
      break;

    default:
      bios_set_cf (regs);
      break;
    }
}
