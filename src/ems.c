/* ================================================
 * FreeRos BIOS
 * ems.c: LIM EMS 3.2 expanded memory driver
 * ================================================ */

#include "bios.h"

/*
 * LIM EMS 3.2 driver for Lo-tech 2MB EMS Board.
 *
 * The board provides 2 MiB of expanded memory via four 16 KiB physical
 * page windows in the EMS page frame (default segment D000h).  Each of
 * the four I/O ports at EMS_BASE+0..EMS_BASE+3 selects which 16 KiB
 * logical page appears in the corresponding window.  Writing 0xFF
 * unmaps the window.
 *
 * Page numbering: 2 MiB / 16 KiB = 128 logical pages (0-127).
 */

#if BIOS_CFG_EMS_ENABLED

#define EMS_VERSION             0x32    /* BCD 3.2 */
#define EMS_TOTAL_PAGES         128     /* 2 MiB / 16 KiB */
#define EMS_PHYSICAL_PAGES      4       /* four 16 KiB windows */
#define EMS_MAX_HANDLES         15      /* handle 0 reserved; 1..14 user handles */
#define EMS_PAGE_UNMAP          0xFF
#define EMS_PAGE_OWNER_FREE     0x0F
#define EMS_HANDLE_SAVED_FLAG   0x80

/* EMS status codes. */
#define EMS_OK                  0x00
#define EMS_SOFTWARE_MALFUNCTION 0x80
#define EMS_HARDWARE_MALFUNCTION 0x81
#define EMS_INVALID_HANDLE      0x83
#define EMS_FUNCTION_NOT_FOUND  0x84
#define EMS_NO_FREE_HANDLES     0x85
#define EMS_SAVE_RESTORE_ERROR  0x86
#define EMS_INSUFFICIENT_PAGES  0x87
#define EMS_ZERO_PAGES          0x89
#define EMS_INVALID_LOGICAL_PAGE 0x8A
#define EMS_INVALID_PHYSICAL_PAGE 0x8B
#define EMS_SAVE_AREA_FULL      0x8C
#define EMS_SAVE_ALREADY_EXISTS 0x8D
#define EMS_SAVE_NOT_FOUND      0x8E

/* Per-handle state. */
typedef struct ems_handle
{
  u8 page_count_and_flags;
  u8 saved_map[EMS_PHYSICAL_PAGES]; /* saved mapping for this handle */
} ems_handle_t;

static ems_handle_t ems_handles[EMS_MAX_HANDLES];
static u8 ems_page_owner[EMS_TOTAL_PAGES / 2]; /* two 4-bit owners per byte */
static u8 ems_current_map[EMS_PHYSICAL_PAGES]; /* current mapping per window */
static u8 ems_free_pages;
static u8 ems_active_handles;
static u8 ems_hardware_ok;

static u8
ems_handle_page_count (u8 handle)
{
  return (u8) (ems_handles[handle].page_count_and_flags
               & (u8) ~EMS_HANDLE_SAVED_FLAG);
}

static void
ems_handle_set_page_count (u8 handle, u8 count)
{
  ems_handles[handle].page_count_and_flags =
    (u8) ((ems_handles[handle].page_count_and_flags & EMS_HANDLE_SAVED_FLAG)
          | (count & (u8) ~EMS_HANDLE_SAVED_FLAG));
}

static int
ems_handle_active (u8 handle)
{
  return ems_handle_page_count (handle) != 0;
}

static int
ems_handle_saved_valid (u8 handle)
{
  return (ems_handles[handle].page_count_and_flags & EMS_HANDLE_SAVED_FLAG) != 0;
}

static void
ems_handle_set_saved_valid (u8 handle, int valid)
{
  if (valid)
    ems_handles[handle].page_count_and_flags |= EMS_HANDLE_SAVED_FLAG;
  else
    ems_handles[handle].page_count_and_flags &= (u8) ~EMS_HANDLE_SAVED_FLAG;
}

static u8
ems_page_owner_get (u8 page)
{
  u8 packed;

  packed = ems_page_owner[page >> 1];
  if ((page & 1U) != 0)
    return (u8) (packed >> 4);
  return (u8) (packed & 0x0F);
}

static void
ems_page_owner_set (u8 page, u8 owner)
{
  u8 *slot;

  slot = &ems_page_owner[page >> 1];
  owner &= 0x0F;
  if ((page & 1U) != 0)
    *slot = (u8) ((*slot & 0x0F) | (owner << 4));
  else
    *slot = (u8) ((*slot & 0xF0) | owner);
}

/*
 * Write a page number to one of the four board registers.
 * Writing EMS_PAGE_UNMAP (0xFF) unmaps the window.
 */
static void
ems_board_map_page (u8 physical_page, u8 logical_page)
{
  bios_hw_out8 (logical_page,
                (u16) (BIOS_CFG_EMS_IO_BASE + physical_page));
  ems_current_map[physical_page] = logical_page;
}

/*
 * Quick hardware probe: write a known value to page register 0, read
 * back, write another value, read back.  If the board isn't there the
 * reads return 0xFF (open bus).
 *
 * Then do a data test: map page 0, write a signature word, map page 1,
 * write a different signature, switch back to page 0 and verify.
 */
static int
ems_board_probe (void)
{
  u16 frame_seg;
  volatile u8 __far *frame;
  u8 test_val;

  /* Register probe: write 0x00 to port, expect readback of 0x00. */
  bios_hw_out8 (0x00, (u16) BIOS_CFG_EMS_IO_BASE);
  bios_hw_pause ();
  test_val = bios_hw_in8 ((u16) BIOS_CFG_EMS_IO_BASE);
  if (test_val != 0x00)
    return 0;

  bios_hw_out8 (0x01, (u16) BIOS_CFG_EMS_IO_BASE);
  bios_hw_pause ();
  test_val = bios_hw_in8 ((u16) BIOS_CFG_EMS_IO_BASE);
  if (test_val != 0x01)
    return 0;

  /* Memory probe: map page 0 into window 0, write signature. */
  frame_seg = BIOS_CFG_EMS_FRAME_SEGMENT;
  bios_hw_out8 (0x00, (u16) BIOS_CFG_EMS_IO_BASE);
  frame = (volatile u8 __far *) BIOS_MK_FP (frame_seg, 0x0000);
  frame[0] = 0xA5;
  frame[1] = 0x5A;

  /* Map page 1 into window 0, write different signature. */
  bios_hw_out8 (0x01, (u16) BIOS_CFG_EMS_IO_BASE);
  frame[0] = 0x12;
  frame[1] = 0x34;

  /* Switch back to page 0, verify original signature persists. */
  bios_hw_out8 (0x00, (u16) BIOS_CFG_EMS_IO_BASE);
  if (frame[0] != 0xA5 || frame[1] != 0x5A)
    return 0;

  /* Unmap all windows. */
  bios_hw_out8 (EMS_PAGE_UNMAP, (u16) (BIOS_CFG_EMS_IO_BASE + 0));
  bios_hw_out8 (EMS_PAGE_UNMAP, (u16) (BIOS_CFG_EMS_IO_BASE + 1));
  bios_hw_out8 (EMS_PAGE_UNMAP, (u16) (BIOS_CFG_EMS_IO_BASE + 2));
  bios_hw_out8 (EMS_PAGE_UNMAP, (u16) (BIOS_CFG_EMS_IO_BASE + 3));

  return 1;
}

/*
 * Allocate a contiguous run of `count` pages from the free pool.
 * Returns the first logical page number, or 0xFF on failure.
 */
static u8
ems_alloc_pages (u8 count, u8 handle)
{
  u8 run_start;
  u8 run_len;
  u8 i;

  run_start = 0;
  run_len = 0;

  for (i = 0; i < EMS_TOTAL_PAGES; i++)
    {
      if (ems_page_owner[i] == 0xFF)
        {
          if (run_len == 0)
            run_start = i;
          run_len++;
          if (run_len == count)
            {
              /* Mark pages as owned. */
              for (i = run_start; i < (u8) (run_start + count); i++)
                ems_page_owner[i] = handle;
              ems_free_pages -= count;
              return run_start;
            }
        }
      else
        {
          run_len = 0;
        }
    }

  return 0xFF;
}

/*
 * Free all pages belonging to a handle.
 */
static void
ems_free_handle_pages (u8 handle)
{
  u8 i;

  for (i = 0; i < EMS_TOTAL_PAGES; i++)
    {
      if (ems_page_owner[i] == handle)
        {
          ems_page_owner[i] = 0xFF;
          ems_free_pages++;
        }
    }
}

/* AH=40h: Get EMM status. */
static void
ems_fn_get_status (bios_regs_t __far *regs)
{
  bios_set_hi (&regs->ax, ems_hardware_ok ? EMS_OK : EMS_HARDWARE_MALFUNCTION);
}

/* AH=41h: Get page frame segment. */
static void
ems_fn_get_frame_segment (bios_regs_t __far *regs)
{
  if (!ems_hardware_ok)
    {
      bios_set_hi (&regs->ax, EMS_HARDWARE_MALFUNCTION);
      return;
    }
  regs->bx = BIOS_CFG_EMS_FRAME_SEGMENT;
  bios_set_hi (&regs->ax, EMS_OK);
}

/* AH=42h: Get unallocated page count. */
static void
ems_fn_get_page_counts (bios_regs_t __far *regs)
{
  if (!ems_hardware_ok)
    {
      bios_set_hi (&regs->ax, EMS_HARDWARE_MALFUNCTION);
      return;
    }
  regs->bx = (u16) ems_free_pages;
  regs->dx = (u16) EMS_TOTAL_PAGES;
  bios_set_hi (&regs->ax, EMS_OK);
}

/* AH=43h: Allocate pages, return handle in DX. */
static void
ems_fn_allocate (bios_regs_t __far *regs)
{
  u8 count;
  u8 handle;
  u8 first;

  if (!ems_hardware_ok)
    {
      bios_set_hi (&regs->ax, EMS_HARDWARE_MALFUNCTION);
      return;
    }

  count = bios_lo (regs->bx);
  if (count == 0)
    {
      bios_set_hi (&regs->ax, EMS_ZERO_PAGES);
      return;
    }
  if (count > ems_free_pages)
    {
      bios_set_hi (&regs->ax, EMS_INSUFFICIENT_PAGES);
      return;
    }

  /* Find a free handle (skip handle 0, reserved for OS). */
  handle = 0xFF;
  for (u8 h = 1; h < EMS_MAX_HANDLES; h++)
    {
      if (!ems_handles[h].active)
        {
          handle = h;
          break;
        }
    }
  if (handle == 0xFF)
    {
      bios_set_hi (&regs->ax, EMS_NO_FREE_HANDLES);
      return;
    }

  first = ems_alloc_pages (count, handle);
  if (first == 0xFF)
    {
      /* Pages exist but not contiguous — try non-contiguous allocation. */
      u8 allocated = 0;
      u8 first_found = 0xFF;
      for (u8 i = 0; i < EMS_TOTAL_PAGES && allocated < count; i++)
        {
          if (ems_page_owner[i] == 0xFF)
            {
              ems_page_owner[i] = handle;
              if (first_found == 0xFF)
                first_found = i;
              allocated++;
            }
        }
      if (allocated < count)
        {
          /* Shouldn't happen — we checked free_pages. Rollback. */
          ems_free_handle_pages (handle);
          bios_set_hi (&regs->ax, EMS_INSUFFICIENT_PAGES);
          return;
        }
      ems_free_pages -= count;
      first = first_found;
    }

  ems_handles[handle].active = 1;
  ems_handles[handle].page_count = count;
  ems_handles[handle].first_page = first;
  ems_handles[handle].saved_valid = 0;
  ems_active_handles++;

  regs->dx = (u16) handle;
  bios_set_hi (&regs->ax, EMS_OK);
}

/* AH=44h: Map/unmap logical page to physical page. */
static void
ems_fn_map_page (bios_regs_t __far *regs)
{
  u8 physical;
  u16 logical;
  u8 handle;

  if (!ems_hardware_ok)
    {
      bios_set_hi (&regs->ax, EMS_HARDWARE_MALFUNCTION);
      return;
    }

  physical = bios_lo (regs->ax);     /* AL = physical page (0-3) */
  logical = regs->bx;                /* BX = logical page number */
  handle = bios_lo (regs->dx);       /* DX = handle */

  if (handle >= EMS_MAX_HANDLES || !ems_handles[handle].active)
    {
      bios_set_hi (&regs->ax, EMS_INVALID_HANDLE);
      return;
    }
  if (physical >= EMS_PHYSICAL_PAGES)
    {
      bios_set_hi (&regs->ax, EMS_INVALID_PHYSICAL_PAGE);
      return;
    }

  /* BX = 0xFFFF means unmap. */
  if (logical == 0xFFFFU)
    {
      ems_board_map_page (physical, EMS_PAGE_UNMAP);
      bios_set_hi (&regs->ax, EMS_OK);
      return;
    }

  /* Verify the logical page belongs to this handle. */
  if (logical >= EMS_TOTAL_PAGES
      || ems_page_owner[(u8) logical] != handle)
    {
      bios_set_hi (&regs->ax, EMS_INVALID_LOGICAL_PAGE);
      return;
    }

  ems_board_map_page (physical, (u8) logical);
  bios_set_hi (&regs->ax, EMS_OK);
}

/* AH=45h: Deallocate handle and free pages. */
static void
ems_fn_deallocate (bios_regs_t __far *regs)
{
  u8 handle;

  handle = bios_lo (regs->dx);
  if (handle == 0 || handle >= EMS_MAX_HANDLES
      || !ems_handles[handle].active)
    {
      bios_set_hi (&regs->ax, EMS_INVALID_HANDLE);
      return;
    }

  /* Unmap any windows currently pointing to this handle's pages. */
  for (u8 w = 0; w < EMS_PHYSICAL_PAGES; w++)
    {
      u8 mapped = ems_current_map[w];
      if (mapped != EMS_PAGE_UNMAP && ems_page_owner[mapped] == handle)
        ems_board_map_page (w, EMS_PAGE_UNMAP);
    }

  ems_free_handle_pages (handle);
  ems_handles[handle].active = 0;
  ems_handles[handle].page_count = 0;
  ems_handles[handle].saved_valid = 0;
  ems_active_handles--;

  bios_set_hi (&regs->ax, EMS_OK);
}

/* AH=46h: Get EMM version. */
static void
ems_fn_get_version (bios_regs_t __far *regs)
{
  if (!ems_hardware_ok)
    {
      bios_set_hi (&regs->ax, EMS_HARDWARE_MALFUNCTION);
      return;
    }
  bios_set_hi (&regs->ax, EMS_OK);
  bios_set_lo (&regs->ax, EMS_VERSION);
}

/* AH=47h: Save page map for handle. */
static void
ems_fn_save_page_map (bios_regs_t __far *regs)
{
  u8 handle;

  handle = bios_lo (regs->dx);
  if (handle >= EMS_MAX_HANDLES || !ems_handles[handle].active)
    {
      bios_set_hi (&regs->ax, EMS_INVALID_HANDLE);
      return;
    }
  if (ems_handles[handle].saved_valid)
    {
      bios_set_hi (&regs->ax, EMS_SAVE_ALREADY_EXISTS);
      return;
    }

  for (u8 i = 0; i < EMS_PHYSICAL_PAGES; i++)
    ems_handles[handle].saved_map[i] = ems_current_map[i];
  ems_handles[handle].saved_valid = 1;

  bios_set_hi (&regs->ax, EMS_OK);
}

/* AH=48h: Restore page map for handle. */
static void
ems_fn_restore_page_map (bios_regs_t __far *regs)
{
  u8 handle;

  handle = bios_lo (regs->dx);
  if (handle >= EMS_MAX_HANDLES || !ems_handles[handle].active)
    {
      bios_set_hi (&regs->ax, EMS_INVALID_HANDLE);
      return;
    }
  if (!ems_handles[handle].saved_valid)
    {
      bios_set_hi (&regs->ax, EMS_SAVE_NOT_FOUND);
      return;
    }

  for (u8 i = 0; i < EMS_PHYSICAL_PAGES; i++)
    ems_board_map_page (i, ems_handles[handle].saved_map[i]);
  ems_handles[handle].saved_valid = 0;

  bios_set_hi (&regs->ax, EMS_OK);
}

/* AH=4Bh: Get number of active EMM handles. */
static void
ems_fn_get_handle_count (bios_regs_t __far *regs)
{
  if (!ems_hardware_ok)
    {
      bios_set_hi (&regs->ax, EMS_HARDWARE_MALFUNCTION);
      return;
    }
  regs->bx = (u16) ems_active_handles;
  bios_set_hi (&regs->ax, EMS_OK);
}

/* AH=4Ch: Get pages owned by handle. */
static void
ems_fn_get_handle_pages (bios_regs_t __far *regs)
{
  u8 handle;

  handle = bios_lo (regs->dx);
  if (handle >= EMS_MAX_HANDLES || !ems_handles[handle].active)
    {
      bios_set_hi (&regs->ax, EMS_INVALID_HANDLE);
      return;
    }
  regs->bx = (u16) ems_handles[handle].page_count;
  bios_set_hi (&regs->ax, EMS_OK);
}

/* AH=4Dh: Get pages for all handles. */
static void
ems_fn_get_all_handle_pages (bios_regs_t __far *regs)
{
  volatile u16 __far *dest;
  u8 count;

  if (!ems_hardware_ok)
    {
      bios_set_hi (&regs->ax, EMS_HARDWARE_MALFUNCTION);
      return;
    }

  dest = (volatile u16 __far *) BIOS_MK_FP (regs->es, regs->di);
  count = 0;

  for (u8 h = 0; h < EMS_MAX_HANDLES; h++)
    {
      if (ems_handles[h].active)
        {
          *dest++ = (u16) h;
          *dest++ = (u16) ems_handles[h].page_count;
          count++;
        }
    }

  regs->bx = (u16) count;
  bios_set_hi (&regs->ax, EMS_OK);
}

/*
 * INT 67h dispatch — EMS service entry point.
 */
void
bios_service_int67 (bios_regs_t __far *regs)
{
  u8 func;

  func = bios_hi (regs->ax);

  switch (func)
    {
    case 0x40:
      ems_fn_get_status (regs);
      break;
    case 0x41:
      ems_fn_get_frame_segment (regs);
      break;
    case 0x42:
      ems_fn_get_page_counts (regs);
      break;
    case 0x43:
      ems_fn_allocate (regs);
      break;
    case 0x44:
      ems_fn_map_page (regs);
      break;
    case 0x45:
      ems_fn_deallocate (regs);
      break;
    case 0x46:
      ems_fn_get_version (regs);
      break;
    case 0x47:
      ems_fn_save_page_map (regs);
      break;
    case 0x48:
      ems_fn_restore_page_map (regs);
      break;
    case 0x4B:
      ems_fn_get_handle_count (regs);
      break;
    case 0x4C:
      ems_fn_get_handle_pages (regs);
      break;
    case 0x4D:
      ems_fn_get_all_handle_pages (regs);
      break;
    default:
      bios_set_hi (&regs->ax, EMS_FUNCTION_NOT_FOUND);
      break;
    }
}

/*
 * Initialise the EMS subsystem during POST.
 * Probes the Lo-tech EMS board; if not found, INT 67h returns
 * hardware failure on every call.
 */
void
bios_ems_init (void)
{
  u8 i;

  ems_hardware_ok = 0;
  ems_free_pages = 0;
  ems_active_handles = 0;

  for (i = 0; i < EMS_TOTAL_PAGES; i++)
    ems_page_owner[i] = 0xFF;

  for (i = 0; i < EMS_PHYSICAL_PAGES; i++)
    ems_current_map[i] = EMS_PAGE_UNMAP;

  for (i = 0; i < EMS_MAX_HANDLES; i++)
    {
      ems_handles[i].active = 0;
      ems_handles[i].page_count = 0;
      ems_handles[i].saved_valid = 0;
    }

  if (!ems_board_probe ())
    {
      return;
    }

  ems_hardware_ok = 1;
  ems_free_pages = EMS_TOTAL_PAGES;
}

#endif /* BIOS_CFG_EMS_ENABLED */
