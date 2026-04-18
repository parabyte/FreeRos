/* ================================================
 * FreeRos BIOS
 * keyboard.c: INT 16h keyboard services and scancode translation
 * ================================================ */

#include "bios.h"
#include "machine.h"

/* ================================================
 * Scancode-to-ASCII Translation Tables
 * ================================================ */

static const u8 bios_keyboard_ascii_normal[0x54] = {
  0, 27, '1', '2', '3', '4', '5', '6',
  '7', '8', '9', '0', '-', '=', '\b', '\t',
  'q', 'w', 'e', 'r', 't', 'y', 'u', 'i',
  'o', 'p', '[', ']', '\r', 0, 'a', 's',
  'd', 'f', 'g', 'h', 'j', 'k', 'l', ';',
  '\'', '`', 0, '\\', 'z', 'x', 'c', 'v',
  'b', 'n', 'm', ',', '.', '/', 0, '*',
  0, ' ', 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, '7',
  '8', '9', '-', '4', '5', '6', '+', '1',
  '2', '3', '0', '.'
};

static const u8 bios_keyboard_ascii_shift[0x54] = {
  0, 27, '!', '@', '#', '$', '%', '^',
  '&', '*', '(', ')', '_', '+', '\b', '\t',
  'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I',
  'O', 'P', '{', '}', '\r', 0, 'A', 'S',
  'D', 'F', 'G', 'H', 'J', 'K', 'L', ':',
  '"', '~', 0, '|', 'Z', 'X', 'C', 'V',
  'B', 'N', 'M', '<', '>', '?', 0, '*',
  0, ' ', 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, '7',
  '8', '9', '-', '4', '5', '6', '+', '1',
  '2', '3', '0', '.'
};

/*
 * Exact PC1640 Alt tokens extracted from the original ROS translation
 * table at FC00:13E7. Most exact tokens only differ in AH, so keep the
 * high byte only and let the original special-case entries fall back to
 * the legacy path. Scancode 39h is the one exact non-zero AL case.
 */
static const u8 bios_keyboard_token_alt_hi[0x54] = {
  0x00, 0x00, 0x78, 0x79, 0x7A, 0x7B, 0x7C, 0x7D,
  0x7E, 0x7F, 0x80, 0x81, 0x82, 0x83, 0x00, 0x00,
  0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17,
  0x18, 0x19, 0x00, 0x00, 0x00, 0x00, 0x1E, 0x1F,
  0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x2C, 0x2D, 0x2E, 0x2F,
  0x30, 0x31, 0x32, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x39, 0x00, 0x68, 0x69, 0x6A, 0x6B, 0x6C,
  0x6D, 0x6E, 0x6F, 0x70, 0x71, 0x00, 0x00, 0xF7,
  0xF8, 0xF9, 0x00, 0xF4, 0xF5, 0xF6, 0x00, 0xF1,
  0xF2, 0xF3, 0xF0, 0x00,
};

#if BIOS_CFG_DEBUG_PORT_E9 || BIOS_CFG_DEBUG_COM1
static void
bios_keyboard_trace_raw (u8 raw_scancode, u8 prefix, u8 flags, u8 flags2)
{
  bios_serial_debug_puts ("K raw=");
  bios_serial_debug_put_hex8 (raw_scancode);
  bios_serial_debug_puts (" pre=");
  bios_serial_debug_put_hex8 (prefix);
  bios_serial_debug_puts (" f=");
  bios_serial_debug_put_hex8 (flags);
  bios_serial_debug_puts (" f2=");
  bios_serial_debug_put_hex8 (flags2);
  bios_serial_debug_puts ("\n");
}

static void
bios_keyboard_trace_token (u8 scancode, u8 prefix, u8 flags, u16 token)
{
  bios_serial_debug_puts ("K tok sc=");
  bios_serial_debug_put_hex8 (scancode);
  bios_serial_debug_puts (" pre=");
  bios_serial_debug_put_hex8 (prefix);
  bios_serial_debug_puts (" f=");
  bios_serial_debug_put_hex8 (flags);
  bios_serial_debug_puts (" ax=");
  bios_serial_debug_put_hex16 (token);
  bios_serial_debug_puts ("\n");
}
#else
#define bios_keyboard_trace_raw(raw_scancode, prefix, flags, flags2) ((void) 0)
#define bios_keyboard_trace_token(scancode, prefix, flags, token) ((void) 0)
#endif

/* ================================================
 * Keyboard Buffer Management
 * ================================================ */

static void
bios_keyboard_put_entry (u16 entry)
{
  u16 head;
  u16 start;
  u16 tail;
  u16 end;
  u16 next_tail;

  start = bios_bda_read16 (BDA_KBD_BUF_START_PTR);
  end = bios_bda_read16 (BDA_KBD_BUF_END_PTR);
  if (start == 0 || end <= start)
    {
      start = BDA_KBD_BUF_START;
      end = BDA_KBD_BUF_END;
    }
  head = bios_bda_read16 (BDA_KBD_BUF_HEAD);
  tail = bios_bda_read16 (BDA_KBD_BUF_TAIL);
  next_tail = (u16) (tail + 2);
  if (next_tail >= end)
    next_tail = start;
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
  u16 start;
  u16 tail;
  u16 end;
  u16 next_head;

  start = bios_bda_read16 (BDA_KBD_BUF_START_PTR);
  end = bios_bda_read16 (BDA_KBD_BUF_END_PTR);
  if (start == 0 || end <= start)
    {
      start = BDA_KBD_BUF_START;
      end = BDA_KBD_BUF_END;
    }
  head = bios_bda_read16 (BDA_KBD_BUF_HEAD);
  tail = bios_bda_read16 (BDA_KBD_BUF_TAIL);
  if (head == tail)
    return 0;

  *entry = bios_bda_read16 (head);
  next_head = (u16) (head + 2);
  if (next_head >= end)
    next_head = start;
  bios_bda_write16 (BDA_KBD_BUF_HEAD, next_head);
  return 1;
}

/* ================================================
 * Keyboard Flag Management
 * ================================================ */

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
    flags &= (u8) ~ mask;
  bios_keyboard_set_flags (flags);
}

static void
bios_keyboard_toggle_flag (u8 mask)
{
  bios_keyboard_set_flags ((u8) (bios_keyboard_flags () ^ mask));
}

/* ================================================
 * Character Classification and Translation Helpers
 * ================================================ */

static int
bios_keyboard_is_alpha (u8 ascii)
{
  return (u8) (ascii - 'a') < 26u;
}

static int
bios_keyboard_is_keypad_key (u8 scancode)
{
  return scancode >= 0x47 && scancode <= 0x53;
}

static u8
bios_keyboard_ctrl_ascii (u8 ascii)
{
  if (bios_keyboard_is_alpha (ascii))
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

static int
bios_keyboard_keypad_numeric_mode (u8 flags)
{
  return (((flags & KBD_FLAG_NUM_LOCK) != 0)
	  ^ ((flags & (KBD_FLAG_LEFT_SHIFT | KBD_FLAG_RIGHT_SHIFT)) != 0));
}

static int
bios_keyboard_is_keypad_digit (u8 scancode, u8 *digit)
{
  u8 ascii;

  if (!bios_keyboard_is_keypad_key (scancode)
      || scancode == 0x4A || scancode == 0x4E || scancode == 0x53)
    return 0;

  ascii = bios_keyboard_ascii_shift[scancode];
  if (ascii < '0' || ascii > '9')
    return 0;

  *digit = (u8) (ascii - '0');
  return 1;
}

static u8
bios_keyboard_ascii_lookup (const u8 *table, u8 scancode)
{
  if (scancode >= 0x54)
    return 0;
  return table[scancode];
}

static u8
bios_keyboard_translate_ascii (u8 scancode, u8 prefix)
{
  u8 flags;
  u8 ascii;
  int shifted;

  flags = bios_keyboard_flags ();
  shifted = (flags & (KBD_FLAG_LEFT_SHIFT | KBD_FLAG_RIGHT_SHIFT)) != 0;

  if (prefix != 0)
    {
      if (scancode == 0x1C || scancode == 0x35)
	return bios_keyboard_ascii_lookup (bios_keyboard_ascii_normal, scancode);
      return 0;
    }

  if ((flags & KBD_FLAG_ALT) != 0)
    return 0;

  ascii = bios_keyboard_ascii_lookup (bios_keyboard_ascii_normal, scancode);

  if ((flags & KBD_FLAG_CTRL) != 0)
    return bios_keyboard_ctrl_ascii (ascii);

  if (bios_keyboard_is_alpha (ascii))
    shifted ^= ((flags & KBD_FLAG_CAPS_LOCK) != 0);

  return shifted ? bios_keyboard_ascii_lookup (bios_keyboard_ascii_shift,
					       scancode) : ascii;
}

static u16
bios_keyboard_build_token_exact (u8 scancode, u8 prefix, u8 flags)
{
  u8 token_hi;

  if (prefix != 0 || scancode == 0 || scancode >= 0x54)
    return 0xFFFF;

  if ((flags & KBD_FLAG_ALT) == 0)
    return 0xFFFF;

  token_hi = bios_keyboard_token_alt_hi[scancode];
  if (token_hi == 0x00)
    return 0xFFFF;

  if (scancode == 0x39)
    return 0x3920;

  return (u16) token_hi << 8;
}

static u16
bios_keyboard_build_token_legacy (u8 scancode, u8 prefix, u8 flags)
{
  u16 token;

  token = 0xFFFF;

  if (scancode >= 0x3B && scancode <= 0x44)
    {
      u8 index;

      index = (u8) (scancode - 0x3B);
      if ((flags & KBD_FLAG_ALT) != 0)
        token = (u16) (0x68 + index) << 8;
      else if ((flags & KBD_FLAG_CTRL) != 0)
        token = (u16) (0x5E + index) << 8;
      else if ((flags & (KBD_FLAG_LEFT_SHIFT | KBD_FLAG_RIGHT_SHIFT)) != 0)
        token = (u16) (0x54 + index) << 8;
      else
        token = (u16) scancode << 8;
    }
  else if (bios_keyboard_is_keypad_key (scancode))
    {
      if ((flags & KBD_FLAG_CTRL) != 0)
        switch (scancode)
          {
          case 0x47: token = 0x7700; break;
          case 0x49: token = 0x8400; break;
          case 0x4B: token = 0x7300; break;
          case 0x4D: token = 0x7400; break;
          case 0x4F: token = 0x7500; break;
          case 0x51: token = 0x7600; break;
          default: break;
          }

      if (token == 0xFFFF)
        {
          if (scancode == 0x4A || scancode == 0x4E)
            token = (u16) scancode << 8
                    | bios_keyboard_ascii_lookup (bios_keyboard_ascii_normal,
						  scancode);
          else if (bios_keyboard_keypad_numeric_mode (flags))
            token = (u16) scancode << 8
                    | bios_keyboard_ascii_lookup (bios_keyboard_ascii_shift,
						  scancode);
          else if (scancode != 0x4C)
            token = (u16) scancode << 8;
        }
    }
  else
    {
      token = (u16) scancode << 8
              | bios_keyboard_translate_ascii (scancode, prefix);
    }

  return token;
}

/* ================================================
 * Hardware Helpers
 * ================================================ */

static u8
bios_keyboard_read_port61 (void)
{
  u8 value;

  asm volatile ("inb $0x61,%%al":"=Ral" (value));
  bios_work_write8 (WK_PORT61, value);
  return value;
}

static void
bios_keyboard_write_port61 (u8 value)
{
  bios_work_write8 (WK_PORT61, value);
  asm volatile ("outb %%al,$0x61"::"Ral" (value));
}

static void
bios_keyboard_acknowledge_controller (void)
{
  u8 port61;

  port61 = bios_keyboard_read_port61 ();
  bios_keyboard_write_port61 ((u8) (port61 | PORT61_STATUS_MODE));
  bios_keyboard_write_port61 ((u8) (port61 & (u8) ~ PORT61_STATUS_MODE));
}

/* ================================================
 * High-level Key Actions
 * ================================================ */

static void
bios_keyboard_queue_token (u16 token)
{
  bios_work_write8 (WK_LAST_KBD_ASCII, bios_lo (token));
  if (token != 0xFFFF)
    bios_keyboard_put_entry (token);
}

void
bios_keyboard_enqueue_token (u16 token)
{
  bios_keyboard_queue_token (token);
}

static void
bios_keyboard_call_int05 (void)
{
  bios_pic_ack_irq (1);
  bios_hw_enable_interrupts ();
  asm volatile ("push %%bp\n\t"
		"push %%ds\n\t"
		"push %%es\n\t"
		"int $0x05\n\t"
		"pop %%es\n\t"
		"pop %%ds\n\t"
		"pop %%bp":::"ax", "bx", "cx", "dx", "si", "di", "cc",
		"memory");
}

static void
bios_keyboard_call_int1b (void)
{
  bios_pic_ack_irq (1);
  bios_hw_enable_interrupts ();
  asm volatile ("push %%bp\n\t"
		"push %%ds\n\t"
		"push %%es\n\t"
		"int $0x1B\n\t"
		"pop %%es\n\t"
		"pop %%ds\n\t"
		"pop %%bp":::"ax", "bx", "cx", "dx", "si", "di", "cc",
		"memory");
}

static void __attribute__ ((noreturn))
bios_keyboard_warm_reset (void)
{
  bios_bda_write16 (BDA_WARM_BOOT_FLAG, 0x1234);
  asm volatile ("ljmp $0xFFFF, $0x0000");
  __builtin_unreachable ();
}

/* ================================================
 * Modifier and Special Key Handling
 * ================================================ */

static int
bios_keyboard_handle_modifier (u8 scancode, int released)
{
  u8 flags2;

  switch (scancode)
    {
    case 0x2A:
      bios_keyboard_update_flag (KBD_FLAG_LEFT_SHIFT, !released);
      return 1;

    case 0x36:
      bios_keyboard_update_flag (KBD_FLAG_RIGHT_SHIFT, !released);
      return 1;

    case 0x1D:
      bios_keyboard_update_flag (KBD_FLAG_CTRL, !released);
      return 1;

    case 0x38:
      if (released)
	{
	  bios_keyboard_update_flag (KBD_FLAG_ALT, 0);
	  flags2 = bios_bda_read8 (BDA_KBD_ALT_PAD);
	  if (flags2 != 0)
	    bios_keyboard_queue_token (flags2);
	  bios_bda_write8 (BDA_KBD_ALT_PAD, 0x00);
	}
      else
	{
	  bios_keyboard_update_flag (KBD_FLAG_ALT, 1);
	  bios_bda_write8 (BDA_KBD_ALT_PAD, 0x00);
	}
      return 1;

    case 0x3A:
      flags2 = bios_bda_read8 (BDA_KBD_FLAGS_2);
      if (released)
	bios_bda_write8 (BDA_KBD_FLAGS_2,
			 (u8) (flags2 & (u8) ~ KBD_FLAG_CAPS_DOWN));
      else if ((flags2 & KBD_FLAG_CAPS_DOWN) == 0)
	{
	  bios_bda_write8 (BDA_KBD_FLAGS_2,
			   (u8) (flags2 | KBD_FLAG_CAPS_DOWN));
	  bios_keyboard_toggle_flag (KBD_FLAG_CAPS_LOCK);
	}
      return 1;

    case 0x45:
      flags2 = bios_bda_read8 (BDA_KBD_FLAGS_2);
      if (released)
	bios_bda_write8 (BDA_KBD_FLAGS_2,
			 (u8) (flags2 & (u8) ~ KBD_FLAG_NUM_DOWN));
      else if ((flags2 & KBD_FLAG_NUM_DOWN) == 0)
	{
	  bios_bda_write8 (BDA_KBD_FLAGS_2,
			   (u8) (flags2 | KBD_FLAG_NUM_DOWN));
	  bios_keyboard_toggle_flag (KBD_FLAG_NUM_LOCK);
	}
      return 1;

    case 0x46:
      flags2 = bios_bda_read8 (BDA_KBD_FLAGS_2);
      if (released)
	bios_bda_write8 (BDA_KBD_FLAGS_2,
			 (u8) (flags2 & (u8) ~ KBD_FLAG_SCROLL_DOWN));
      else if ((flags2 & KBD_FLAG_SCROLL_DOWN) == 0)
	{
	  bios_bda_write8 (BDA_KBD_FLAGS_2,
			   (u8) (flags2 | KBD_FLAG_SCROLL_DOWN));
	  bios_keyboard_toggle_flag (KBD_FLAG_SCROLL_LOCK);
	}
      return 1;

    case 0x52:
      flags2 = bios_bda_read8 (BDA_KBD_FLAGS_2);
      if (released)
	{
	  bios_bda_write8 (BDA_KBD_FLAGS_2,
			   (u8) (flags2 & (u8) ~ KBD_FLAG_INSERT_DOWN));
	  return 1;
	}

      if (bios_keyboard_keypad_numeric_mode (bios_keyboard_flags ()))
	return 0;

      if ((flags2 & KBD_FLAG_INSERT_DOWN) == 0)
	{
	  bios_bda_write8 (BDA_KBD_FLAGS_2,
			   (u8) (flags2 | KBD_FLAG_INSERT_DOWN));
	  bios_keyboard_toggle_flag (KBD_FLAG_INSERT);
	}
      return 0;

    default:
      return 0;
    }
}

/* ================================================
 * Public API: Init, Self-test, IRQ Handler, BIOS Services
 * ================================================ */

void
bios_keyboard_clear_buffer (void)
{
  u16 start;

  start = bios_bda_read16 (BDA_KBD_BUF_START_PTR);
  if (start == 0)
    start = BDA_KBD_BUF_START;
  bios_bda_write8 (BDA_KBD_ALT_PAD, 0x00);
  bios_bda_write8 (BDA_BREAK_FLAG, 0x00);
  bios_bda_write16 (BDA_KBD_BUF_HEAD, start);
  bios_bda_write16 (BDA_KBD_BUF_TAIL, start);
  bios_work_write8 (WK_KBD_PREFIX, 0x00);
  bios_work_write8 (WK_LAST_KBD_SCANCODE, 0x00);
  bios_work_write8 (WK_LAST_KBD_ASCII, 0x00);
  /*
   * WK_LAST_KBD_RAW is intentionally NOT cleared here.  The
   * keyboard BAT 0xAA byte may arrive via IRQ1 before the
   * self-test runs; clearing it would destroy the evidence
   * that bios_keyboard_self_test() needs.
   */
}

void
bios_keyboard_init (void)
{
  bios_bda_write16 (BDA_KBD_BUF_START_PTR, BDA_KBD_BUF_START);
  bios_bda_write16 (BDA_KBD_BUF_END_PTR, BDA_KBD_BUF_END);
  bios_bda_write8 (BDA_KBD_FLAGS, 0x00);
  bios_bda_write8 (BDA_KBD_FLAGS_2, 0x00);
  bios_keyboard_clear_buffer ();
  bios_work_write8 (WK_KBD_LED_STATE, 0x00);
}

int
bios_keyboard_self_test (void)
{
  u8 saved_port61;
  u8 raw_scancode;
  u8 reset_port61;
  u8 outer;
  u16 poll;

  saved_port61 = bios_keyboard_read_port61 ();
  reset_port61 = (u8) ((saved_port61 & (u8) ~PORT61_KBD_RESET)
                       | PORT61_STATUS_MODE);

  /* Fast path: IRQ already delivered 0xAA during earlier POST. */
  if (bios_work_read8 (WK_LAST_KBD_RAW) == 0xAA)
    goto success;

  bios_hw_disable_interrupts ();
  bios_work_write8 (WK_LAST_KBD_RAW, 0x00);

  /*
   * Match the original PC1640 late-POST keyboard BAT more closely:
   * port 61h is pulsed with bit 7 set while bit 6 stays clear, then
   * the previous 61h image is restored and IRQ1 is allowed to report
   * the BAT byte through WK_LAST_KBD_RAW.
   */
  bios_keyboard_write_port61 (reset_port61);
  for (poll = 0; poll != 0x2710; ++poll)
    bios_hw_pause ();
  bios_keyboard_write_port61 (saved_port61);

  bios_hw_enable_interrupts ();

  /*
   * Wait for IRQ1 to deposit any fresh BAT/result byte. The original
   * ROS treats a non-zero byte as the end of the wait window and then
   * compares it against AAh.
   */
  raw_scancode = 0x00;
  for (outer = 10; outer != 0; --outer)
    {
      poll = 0;
      do
	{
	  raw_scancode = bios_work_read8 (WK_LAST_KBD_RAW);
	  if (raw_scancode != 0x00)
	    goto have_result;
	}
      while (++poll != 0);		/* 65536 iterations */
    }

have_result:
  bios_keyboard_write_port61 (saved_port61);
  if (raw_scancode != 0xAA)
    return 0;

success:
  bios_bda_write8 (BDA_KBD_FLAGS, 0x00);
  bios_bda_write8 (BDA_KBD_FLAGS_2, 0x00);
  bios_keyboard_clear_buffer ();
  bios_keyboard_write_port61 (saved_port61);
  return 1;

  /* NOTREACHED */
  return 0;
}

static void
bios_keyboard_process_scancode (u8 raw_scancode, int ack_irq1)
{
  u8 scancode;
  u8 prefix;
  u8 flags;
  u8 flags2;
  u8 digit;
  u16 token;
  int released;

  bios_work_write8 (WK_LAST_KBD_RAW, raw_scancode);

  if (raw_scancode == 0x00)
    {
      if (ack_irq1)
        bios_pic_ack_irq (1);
      return;
    }

  /* Multi-byte prefix: save and wait for the next byte. */
  if (raw_scancode == 0xE0 || raw_scancode == 0xE1)
    {
      bios_work_write8 (WK_KBD_PREFIX, raw_scancode);
      if (ack_irq1)
        bios_pic_ack_irq (1);
      return;
    }

  prefix = bios_work_read8 (WK_KBD_PREFIX);
  bios_work_write8 (WK_KBD_PREFIX, 0x00);

  scancode = (u8) (raw_scancode & 0x7F);
  released = (raw_scancode & 0x80) != 0;
  bios_work_write8 (WK_LAST_KBD_SCANCODE, scancode);
  bios_work_write8 (WK_LAST_KBD_ASCII, 0x00);

  flags = bios_keyboard_flags ();
  flags2 = bios_bda_read8 (BDA_KBD_FLAGS_2);
  bios_keyboard_trace_raw (raw_scancode, prefix, flags, flags2);

  /* Pause state: any key except Num Lock itself clears pause. */
  if ((flags2 & KBD_FLAG_PAUSE_ACTIVE) != 0)
    {
      if (scancode != 0x45)
	bios_bda_write8 (BDA_KBD_FLAGS_2,
			 (u8) (flags2 & (u8) ~ KBD_FLAG_PAUSE_ACTIVE));
      if (ack_irq1)
        bios_pic_ack_irq (1);
      return;
    }

  /* Ctrl+Num Lock: enter pause state. */
  if (!released
      && prefix == 0x00 && scancode == 0x45 && (flags & KBD_FLAG_CTRL) != 0)
    {
      bios_keyboard_toggle_flag (KBD_FLAG_NUM_LOCK);
      bios_bda_write8 (BDA_KBD_FLAGS_2,
		       (u8) (flags2 | KBD_FLAG_PAUSE_ACTIVE));
      if (ack_irq1)
        bios_pic_ack_irq (1);
      bios_hw_enable_interrupts ();
      while ((bios_bda_read8 (BDA_KBD_FLAGS_2) & KBD_FLAG_PAUSE_ACTIVE) != 0)
	bios_hw_halt ();
      return;
    }

  /* Ctrl+Scroll Lock: break (INT 1Bh). */
  if (!released
      && prefix == 0x00 && scancode == 0x46 && (flags & KBD_FLAG_CTRL) != 0)
    {
      bios_bda_write16 (BDA_KBD_BUF_HEAD, BDA_KBD_BUF_START);
      bios_bda_write16 (BDA_KBD_BUF_TAIL, BDA_KBD_BUF_START);
      bios_bda_write8 (BDA_BREAK_FLAG, 0x80);
      bios_keyboard_queue_token (0x0000);
      bios_keyboard_call_int1b ();
      return;
    }

  /* Shift+PrtSc: print screen (INT 05h). */
  if (!released
      && prefix == 0x00
      && scancode == 0x37
      && (flags & (KBD_FLAG_LEFT_SHIFT | KBD_FLAG_RIGHT_SHIFT)) != 0)
    {
      bios_keyboard_call_int05 ();
      return;
    }

  /* Ctrl+Alt+Del: warm reboot. */
  if (!released
      && ((prefix == 0x00 && (scancode == 0x53 || scancode == 0x70))
          || (prefix == 0xE0 && scancode == 0x53))
      && (flags & (KBD_FLAG_CTRL | KBD_FLAG_ALT))
	 == (KBD_FLAG_CTRL | KBD_FLAG_ALT))
    bios_keyboard_warm_reset ();

  if (machine_keyboard_special (scancode, released))
    {
      if (ack_irq1)
        bios_pic_ack_irq (1);
      return;
    }

  /* Modifier keys (shift, ctrl, alt, caps/num/scroll lock, insert). */
  if (bios_keyboard_handle_modifier (scancode, released))
    {
      if (ack_irq1)
        bios_pic_ack_irq (1);
      return;
    }

  /* Alt+keypad digit: accumulate into the Alt-numpad entry. */
  if (!released
      && prefix == 0x00
      && (flags & KBD_FLAG_ALT) != 0
      && bios_keyboard_is_keypad_digit (scancode, &digit))
    {
      bios_bda_write8 (BDA_KBD_ALT_PAD,
		       (u8) (bios_bda_read8 (BDA_KBD_ALT_PAD) * 10 + digit));
      if (ack_irq1)
        bios_pic_ack_irq (1);
      return;
    }

  /* All remaining key releases are silently discarded. */
  if (released)
    {
      if (ack_irq1)
        bios_pic_ack_irq (1);
      return;
    }

  /* Any non-digit key while Alt is held resets the Alt-pad accumulator. */
  if ((flags & KBD_FLAG_ALT) != 0)
    bios_bda_write8 (BDA_KBD_ALT_PAD, 0x00);

  /* Build the INT 16h token (AH = scancode, AL = ASCII). */
  token = bios_keyboard_build_token_exact (scancode, prefix, flags);
  if (token == 0xFFFF)
    token = bios_keyboard_build_token_legacy (scancode, prefix, flags);

  bios_keyboard_trace_token (scancode, prefix, flags, token);
  bios_keyboard_queue_token (token);
  if (ack_irq1)
    bios_pic_ack_irq (1);
}

void
bios_keyboard_irq1 (void)
{
  u8 raw_scancode;

  /*
   * IRQ1 must drain the live keyboard data byte. The BIOS port 60h helper
   * also emulates the PC1640 "status mode" multiplexing used by POST, and
   * consulting that shadow here can fabricate a bogus scancode if port 61h
   * was left with STATUS_MODE set.
   */
  raw_scancode = bios_hw_in8 (PORT_KBD_DATA);
  bios_keyboard_acknowledge_controller ();
  bios_keyboard_process_scancode (raw_scancode, 1);
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

/* ================================================
 * INT 16h Service Dispatch
 * ================================================ */

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

    case 0x03:
      bios_set_cf (regs);
      break;

    default:
      bios_set_cf (regs);
      break;
    }
}
