#include "bios.h"

/* ----------------------------------------------------------------
   Scancode-to-ASCII translation tables
   ---------------------------------------------------------------- */

static const u8 bios_keyboard_ascii_normal[128] = {
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
  '2', '3', '0', '.', 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0
};

static const u8 bios_keyboard_ascii_shift[128] = {
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
  '2', '3', '0', '.', 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0
};

/* ----------------------------------------------------------------
   Keyboard buffer management
   ---------------------------------------------------------------- */

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

/* ----------------------------------------------------------------
   Keyboard flag management
   ---------------------------------------------------------------- */

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

/* ----------------------------------------------------------------
   Character classification and translation helpers
   ---------------------------------------------------------------- */

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
	return bios_keyboard_ascii_normal[scancode];
      return 0;
    }

  if ((flags & KBD_FLAG_ALT) != 0)
    return 0;

  ascii = bios_keyboard_ascii_normal[scancode];

  if ((flags & KBD_FLAG_CTRL) != 0)
    return bios_keyboard_ctrl_ascii (ascii);

  if (bios_keyboard_is_alpha (ascii))
    shifted ^= ((flags & KBD_FLAG_CAPS_LOCK) != 0);

  return shifted ? bios_keyboard_ascii_shift[scancode] : ascii;
}

/* ----------------------------------------------------------------
   Hardware helpers (CMOS, controller acknowledge)
   ---------------------------------------------------------------- */

static u8
bios_keyboard_cmos_read_raw (u8 index)
{
  u8 value;

  index &= 0x3F;
  bios_work_write8 (WK_CMOS_INDEX, index);
  bios_hw_out8 (index, PORT_CMOS_ADDR);
  value = bios_hw_in8 (PORT_CMOS_DATA);
  bios_work_write8 ((u16) (WK_CMOS_SHADOW + index), value);
  return value;
}

static u16
bios_keyboard_nvr_token (u8 lo_index)
{
  u16 token;

  token = bios_keyboard_cmos_read_raw (lo_index);
  token |= (u16) bios_keyboard_cmos_read_raw ((u8) (lo_index + 1U)) << 8;
  return token;
}

static void
bios_keyboard_acknowledge_controller (void)
{
  u8 port61;

  port61 = bios_io_read (PORT_PPI_PORT_B);
  bios_io_write (PORT_PPI_PORT_B, (u8) (port61 | PORT61_STATUS_MODE));
  bios_io_write (PORT_PPI_PORT_B, (u8) (port61 & (u8) ~ PORT61_STATUS_MODE));
}

/* ----------------------------------------------------------------
   High-level key actions
   ---------------------------------------------------------------- */

static void
bios_keyboard_queue_token (u16 token)
{
  bios_work_write8 (WK_LAST_KBD_ASCII, bios_lo (token));
  if (token != 0xFFFF)
    bios_keyboard_put_entry (token);
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

/* ----------------------------------------------------------------
   Modifier and special key handling
   ---------------------------------------------------------------- */

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

static int
bios_keyboard_queue_nvr_token (u8 lo_index, int released)
{
  if (released)
    return 1;

  bios_keyboard_queue_token (bios_keyboard_nvr_token (lo_index));
  return 1;
}

static int
bios_keyboard_handle_mouse_button (u8 button, int released)
{
  bios_regs_t regs;

  regs.ax = (u16) ((released ? 0x80U : 0x00U) | button);
  regs.bx = 0x0000;
  regs.cx = 0x0000;
  regs.dx = 0x0000;
  regs.si = 0x0000;
  regs.di = 0x0000;
  regs.bp = 0x0000;
  regs.ds = 0x0000;
  regs.es = 0x0000;
  regs.flags = 0x0000;
  bios_service_int06 (&regs);

  if (!released && (regs.flags & BIOS_FLAG_CF) != 0)
    bios_keyboard_queue_token (regs.ax);
  return 1;
}

static int
bios_keyboard_handle_pc1640_special (u8 scancode, int released)
{
  switch (scancode)
    {
    case 0x70:
      return bios_keyboard_queue_nvr_token (CMOS_NVR_DELETE_KEY_LO, released);

    case 0x74:
      return bios_keyboard_queue_nvr_token (CMOS_NVR_ENTER_KEY_LO, released);

    case 0x77:
      return bios_keyboard_queue_nvr_token (CMOS_NVR_JOYSTICK2_LO, released);

    case 0x78:
      return bios_keyboard_queue_nvr_token (CMOS_NVR_JOYSTICK1_LO, released);

    case 0x79:
      if (!released)
	bios_keyboard_queue_token (0x4D00);
      return 1;

    case 0x7A:
      if (!released)
	bios_keyboard_queue_token (0x4B00);
      return 1;

    case 0x7B:
      if (!released)
	bios_keyboard_queue_token (0x5000);
      return 1;

    case 0x7C:
      if (!released)
	bios_keyboard_queue_token (0x4800);
      return 1;

    case 0x7D:
      return bios_keyboard_handle_mouse_button (0, released);

    case 0x7E:
      return bios_keyboard_handle_mouse_button (1, released);

    default:
      return 0;
    }
}

/* ----------------------------------------------------------------
   Public API: init, self-test, IRQ handler, BIOS services
   ---------------------------------------------------------------- */

void
bios_keyboard_clear_buffer (void)
{
  bios_bda_write8 (BDA_KBD_ALT_PAD, 0x00);
  bios_bda_write8 (BDA_BREAK_FLAG, 0x00);
  bios_bda_write16 (BDA_KBD_BUF_HEAD, BDA_KBD_BUF_START);
  bios_bda_write16 (BDA_KBD_BUF_TAIL, BDA_KBD_BUF_START);
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
  bios_bda_write8 (BDA_KBD_FLAGS, 0x00);
  bios_bda_write8 (BDA_KBD_FLAGS_2, 0x00);
  bios_keyboard_clear_buffer ();
  bios_work_write8 (WK_KBD_LED_STATE, 0x00);
}

int
bios_keyboard_self_test (void)
{
  u8 saved_port61;
  u8 normal_port61;
  u8 outer;
  u16 poll;

  saved_port61 = bios_io_read (PORT_PPI_PORT_B);
  normal_port61 = (u8) (saved_port61 & (u8) ~ (PORT61_STATUS_MODE
						| PORT61_KBD_RESET));

  /*
   * Detect the keyboard by forcing a fresh reset.
   *
   * Our keyboard test runs late in POST, long after the keyboard's
   * power-on BAT completed and the 0xAA byte was (likely) consumed
   * or lost.  Rather than retroactively detecting the earlier 0xAA,
   * force the keyboard controller to reset the keyboard by asserting
   * KBD_RESET (port 61h bit 6), then wait for the fresh BAT 0xAA.
   *
   * Sequence:
   *   1. Quick check: if IRQ1 already delivered 0xAA, succeed fast
   *   2. CLI, clear sentinel
   *   3. Assert KBD_RESET and STATUS_MODE (flush + hold reset)
   *   4. Delay, then release KBD_RESET and STATUS_MODE
   *   5. STI, poll WK_LAST_KBD_RAW for 0xAA via IRQ1
   */

  /* Fast path: IRQ already delivered 0xAA during earlier POST. */
  if (bios_work_read8 (WK_LAST_KBD_RAW) == 0xAA)
    goto success;

  bios_hw_disable_interrupts ();
  bios_work_write8 (WK_LAST_KBD_RAW, 0x00);

  /*
   * Assert KBD_RESET and STATUS_MODE to reset the keyboard and
   * flush any stale data from the shift register.
   */
  bios_io_write (PORT_PPI_PORT_B,
		 (u8) (normal_port61 | PORT61_KBD_RESET
			| PORT61_STATUS_MODE));
  for (poll = 0; poll != 0x2710; ++poll)
    bios_hw_pause ();

  /* Release: clear both KBD_RESET and STATUS_MODE. */
  bios_io_write (PORT_PPI_PORT_B, normal_port61);

  bios_hw_enable_interrupts ();

  /* Wait for the keyboard's fresh BAT 0xAA byte via IRQ1. */
  for (outer = 10; outer != 0; --outer)
    {
      poll = 0;
      do
	{
	  if (bios_work_read8 (WK_LAST_KBD_RAW) == 0xAA)
	    goto success;
	}
      while (++poll != 0);		/* 65536 iterations */
    }

  bios_io_write (PORT_PPI_PORT_B, normal_port61);
  return 0;

success:
  bios_bda_write8 (BDA_KBD_FLAGS, 0x00);
  bios_bda_write8 (BDA_KBD_FLAGS_2, 0x00);
  bios_keyboard_clear_buffer ();
  bios_io_write (PORT_PPI_PORT_B, normal_port61);
  return 1;
}

void
bios_keyboard_irq1 (void)
{
  u8 raw_scancode;
  u8 scancode;
  u8 prefix;
  u8 flags;
  u8 flags2;
  u8 digit;
  u16 token;
  int released;

  /* Read and acknowledge the scancode from the controller. */
  raw_scancode = bios_io_read (PORT_KBD_DATA);
  bios_work_write8 (WK_LAST_KBD_RAW, raw_scancode);
  bios_keyboard_acknowledge_controller ();

  if (raw_scancode == 0x00)
    {
      bios_pic_ack_irq (1);
      return;
    }

  /* Multi-byte prefix: save and wait for the next byte. */
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
  bios_work_write8 (WK_LAST_KBD_ASCII, 0x00);

  flags = bios_keyboard_flags ();
  flags2 = bios_bda_read8 (BDA_KBD_FLAGS_2);

  /* Pause state: any key except Num Lock itself clears pause. */
  if ((flags2 & KBD_FLAG_PAUSE_ACTIVE) != 0)
    {
      if (scancode != 0x45)
	bios_bda_write8 (BDA_KBD_FLAGS_2,
			 (u8) (flags2 & (u8) ~ KBD_FLAG_PAUSE_ACTIVE));
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
      && prefix == 0x00
      && scancode == 0x53
      && (flags & (KBD_FLAG_CTRL | KBD_FLAG_ALT))
	 == (KBD_FLAG_CTRL | KBD_FLAG_ALT))
    bios_keyboard_warm_reset ();

  /* PC1640-specific extended scancodes (mouse buttons, joystick, etc.). */
  if (bios_keyboard_handle_pc1640_special (scancode, released))
    {
      bios_pic_ack_irq (1);
      return;
    }

  /* Modifier keys (shift, ctrl, alt, caps/num/scroll lock, insert). */
  if (bios_keyboard_handle_modifier (scancode, released))
    {
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
      bios_pic_ack_irq (1);
      return;
    }

  /* All remaining key releases are silently discarded. */
  if (released)
    {
      bios_pic_ack_irq (1);
      return;
    }

  /* Any non-digit key while Alt is held resets the Alt-pad accumulator. */
  if ((flags & KBD_FLAG_ALT) != 0)
    bios_bda_write8 (BDA_KBD_ALT_PAD, 0x00);

  /* Build the INT 16h token (AH = scancode, AL = ASCII). */
  token = 0xFFFF;

  if (scancode >= 0x3B && scancode <= 0x44)
    {
      /* F1-F10 with modifier variants. */
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
      /* Ctrl+keypad navigation keys. */
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

      /* Keypad keys not handled by the Ctrl special cases. */
      if (token == 0xFFFF)
	{
	  if (scancode == 0x4A || scancode == 0x4E)
	    token = (u16) scancode << 8
		    | bios_keyboard_ascii_normal[scancode];
	  else if (bios_keyboard_keypad_numeric_mode (flags))
	    token = (u16) scancode << 8
		    | bios_keyboard_ascii_shift[scancode];
	  else if (scancode != 0x4C)
	    token = (u16) scancode << 8;
	}
    }
  else
    {
      /* Ordinary keys: scancode in AH, translated ASCII in AL. */
      token = (u16) scancode << 8
	      | bios_keyboard_translate_ascii (scancode, prefix);
    }

  bios_keyboard_queue_token (token);
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

/* ----------------------------------------------------------------
   INT 06h: Amstrad mouse button service
   ---------------------------------------------------------------- */

void
bios_service_int06 (bios_regs_t __far *regs)
{
  u8 button;
  u8 index;

  button = bios_lo (regs->ax);
  if ((button & 0x80) != 0)
    {
      bios_clear_cf (regs);
      return;
    }

  switch (button)
    {
    case 0:
      index = CMOS_NVR_MOUSE1_LO;
      break;

    case 1:
      index = CMOS_NVR_MOUSE2_LO;
      break;

    default:
      bios_clear_cf (regs);
      return;
    }

  regs->ax = bios_keyboard_nvr_token (index);
  bios_set_cf (regs);
}

/* ----------------------------------------------------------------
   INT 16h: keyboard BIOS service
   ---------------------------------------------------------------- */

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
