# PC1640 PEGA hardware findings

Updated 31 October 2026. These notes combine a read of the physical PC1640's
video ROM, the original hardware documentation, the current FreeRos source,
and Antler's graphics-driver experiments. Register observations, software
choices, and emulator measurements are identified separately.

## Cursor capabilities

The Paradise PEGA1A has the EGA character cursor controlled by CRTC registers
0Ah/0Bh (scan-line shape) and 0Eh/0Fh (character address). That cursor belongs
to text scanout. It is not a bitmap sprite and cannot be superimposed on a
GEM planar graphics display by redefining a character font.

No separate graphics-cursor plane or programmable cursor-glyph register was
found in the inspected firmware paths. The documented graphics mouse cursor
uses screen AND/XOR masks; the mouse API's hardware-cursor selection applies
to text mode. A read-only firmware examination cannot prove that every
undocumented circuit is absent. It provides no basis for enabling a hidden
graphics-cursor feature. See the [IGA register reference](https://www.seasip.info/AmstradXT/1640tech/section1.html)
and [mouse functions 9 and 10](https://www.seasip.info/AmstradXT/1640tech/appendices.html).

GEM must retain its graphics raster and compose its mouse pointer into video
memory. The useful hardware acceleration here is the EGA latch and set/reset
machinery described below. A text-mode font pointer is not a solution for a
graphical GEM desktop.

## Physical ROM evidence

The physical adapter ROM was read from C000:0000 without modifying video
registers or font RAM. The captured 16,384 bytes have an eight-bit additive
checksum of zero and SHA-256:

```text
f513b1d009e80af8dd70ee922f27d05574c383a59ca1cebfc05bf6f22d12aeaa
```

Identification includes `PEGA BIOS VERSION 2.015 RKG`, Paradise Systems
1986, and Amstrad PLC 1987. The ROM length recorded here is the captured
option-ROM length, not a statement about every mapped or mirrored font-ROM
address on all PC1640 revisions. The binary is not included in this repository.

Offsets below are relative to C000:0000 and apply to that exact ROM hash:

| Offset | Observation |
| --- | --- |
| 0572h | Character loader selects font access through register tables and copies glyph rows to A000h with a 32-byte character stride. |
| 0138h–0162h | Private 03DFh accesses occur in adapter initialization. |
| 1300h–13A9h | Further 03DFh accesses occur in monitor/personality handling. |
| 23C0h | 64-byte video parameter entry for colour 640x200, mode 0Eh. |
| 2480h | 64-byte video parameter entry for monochrome 640x350, mode 0Fh. |
| 24C0h | 64-byte video parameter entry for colour 640x350, mode 10h. |

The private-port observations do not identify a cursor register, an unlock
sequence for a graphics sprite, or a safe general-purpose register probe.
One live input-only read of 03C2h returned FFh; an unsequenced sample does not
decode the four monitor switches and must not be treated as a capability test.

[The evidence record](pega-rom-evidence.json) preserves the ROM identity,
the three parameter entries, and the measured cursor-model counts. It contains
no host paths, network addresses, firmware binary, or captured system memory.

## Monitor selection and hardware straps

PEGA colour and monochrome personalities are configurations of the same part.
The PC1640 service-manual switch settings used during the investigation were:

| Personality | SW1 | SW2 | SW3 | SW4 | SW5 | Monitor/use |
| --- | --- | --- | --- | --- | --- | --- |
| MDTEXT | off | off | on | off | on | MD, MDA/Hercules diagnostics |
| MDMONO | off | off | on | off | off | MD, EGA monochrome graphics |
| CDMONO | off | off | off | on | on | CD, CGA-compatible 80 columns |
| CDCOLOR | off | off | off | on | off | CD, EGA-compatible 80 columns |
| ECD200 | on | on | on | off | off | ECD, 200-line emulation |
| ECD350 | off | on | on | off | off | ECD, 350 lines |

SW5 is a hardware strap. The examined motherboard schematic routes its `EGA`
net to PAL 40097 pin 16; it is not another readable bit in the switch-sense
nibble. MDTEXT must not be mistaken for EGA monochrome graphics. Software
selecting an MD graphics timing bank cannot compensate for the wrong strap.

SW1–SW4 feed the IC919 74LS153 multiplexer. Its SWSTS output reaches bit 4 of
the input status register at 03C2h through IC915 and the PAL's read decode.
Select n in the Miscellaneous Output clock-select field senses SW(4−n).
The controlled probe uses output values 4Fh, 4Bh, 47h, 43h to sample SW1,
SW2, SW3, SW4 in that order while the sequencer is held in reset. Restore or
replace the output register with the intended mode value before releasing reset.

Interpreting select zero as SW1 reverses the nibble. That mistake caused
MDMONO's 0Bh value to be misclassified during earlier driver development.
With off encoded as one, Antler's switch-to-monitor interpretation is:

| Nibble SW4..SW1 | Monitor family | Selected graphics raster |
| --- | --- | --- |
| 9h, 3h | ECD | 640x350, Miscellaneous Output A7h |
| 7h, 6h, 8h, 0h, 1h, 2h | CD or ECD 200-line emulation | 640x200, output 23h |
| Bh, Ah, 5h, 4h | MD | 640x350, output A2h |
| Ch–Fh | Reserved | Software fallback to ECD; not proof of the attached monitor |

The SW901 video selector is separate from the motherboard option/language
switches selected through the printer-control latch. Preserve that distinction
when working on FreeRos's PC1640 option-switch logic.

## Direct graphics mode entry

The PEGA-specific personality transaction used by Antler reads 03D8h twice,
writes zero to 03DBh, reads 03B8h twice, and writes zero to 03BBh. It then
holds the sequencer in reset, senses the monitor, and loads the appropriate
standard EGA register banks. This transaction is specific to PC1640 PEGA;
Paradise VGA register recipes are not interchangeable with it.

The captured ROM entries have this layout: columns, rows-minus-one and font
height at bytes 0–2; page length at 3–4; sequencer registers 1–4 at 5–8;
Miscellaneous Output at 9; 25 CRTC values at 10–34; 20 attribute values at
35–54; and nine graphics-controller values at 55–63. The evidence JSON stores
all 64 bytes for each entry so these interpretations can be checked.

The 350-line monochrome mode needs its own timing bank. Its Miscellaneous
Output is A2h and CRTC horizontal total is 60h. The colour ECD values are
A7h and 5Bh. Substituting A6h for A7h merely changes the I/O-address bit and
leaves the wrong dot clock for the MD monitor. Sharing the colour CRTC bank
also produces incorrect line timing. Monochrome uses the 03B4h/03B5h CRTC
and 03BAh status port; colour uses 03D4h/03D5h and 03DAh. Read the matching
status port before attribute-controller writes to reset its address/data phase.

Both 350-line ROM entries use sequencer values `01 0F 00 06` and graphics
values `00 00 00 00 00 00 05 0F FF`. The drawing engine can therefore share
its planar operations while keeping mode entry, clocks, and palettes separate.

The ROM's monochrome attribute bank enables planes zero and two with 05h.
Antler's 16-colour-index desktop deliberately uses 0Fh instead and maps every
index to black, video (08h), or intensified video (18h). Its attribute mode
control is 03h, with blink disabled. This is a desktop palette policy, not a
byte-for-byte reproduction of BIOS mode 0Fh. The tested palette is:

```text
00 00 08 08 00 00 08 08 00 08 18 18 08 08 18 18
```

For the ECD 350-line colour palette, index six must select 14h for brown on
the 64-colour monitor. The CD 200-line palette uses `00..07, 10..17` for its
IRGB outputs. An ECD may deliberately use the CD 640x200 timing, reducing
visible scan lines by about 43%; the CD and MD retain their own compatible
timings. A 200-line raster needs an eight-row font, not the 14-row 350-line face.

## Font RAM and text-cursor distinction

PEGA uses the ordinary EGA programmable character generator. Font data is
accessed through plane two in the A000h window, with 32 bytes reserved per
character. Selecting that plane and the appropriate addressing mode allows
glyph changes; it does not redefine the CRTC cursor or create an overlay in
graphics mode. The [firmware character-loader interface](https://www.seasip.info/AmstradXT/1640tech/section2.html)
is the INT 10h AH=11h family. The manual's decimal function numbering should
not be confused with hexadecimal register values.

FreeRos already has a direct loader in `src/video_pega_inrom.c`. Its
`pega_load_font()` selects plane two, writes at `character * 32`, and restores
text addressing. Preserve the active text aperture, font bank, character
height, and register state when extending it. Attribute bit 3 can participate
in font-bank selection; VGA's ninth text column is not a general EGA feature.
Use EGA register meanings rather than assuming VGA chain-four behavior.

Original small glyph candidates considered during the investigation were:

| Shape | Eight bitmap rows, bit 7 at the left |
| --- | --- |
| Northwest arrow | `80 C0 E0 F0 F8 DC 8E 06` |
| Diamond, CP437 04h style | `10 38 7C FE 7C 38 10 00` |
| Right triangle, CP437 10h style | `80 C0 E0 F0 E0 C0 80 00` |

These are shape examples, not extracted firmware glyphs or a graphical
hardware-cursor interface. A software-rendered GEM pointer can use a suitable
bitmap; changing a text font cannot make that bitmap visible over graphics.

## Graphics cursor acceleration

The 256 KiB PEGA memory layout provides 64 KiB per plane. At 640 pixels wide,
each raster row occupies 80 bytes per plane. A 16-pixel pointer at an arbitrary
bit alignment spans at most three bytes per row, or 48 bytes for 16 rows.

Antler reserves A000:FF00h–FF2Fh in each plane for the saved background. That
range is outside its supported visible rasters and is owned exclusively by
the pointer. Do not reuse it if another page, a changed display start address,
or another allocator occupies it. Generic EGA adapters with less memory must
keep their RAM save buffer; PEGA's capacity must not be assumed universally.

The accelerated sequence is:

1. Enable all four sequencer write maps and use graphics write mode one.
   Each source read loads all four latches; the following destination write
   copies them together into the reserved video-memory rectangle.
2. Use write mode zero with set/reset enabled on all planes. Draw background
   and foreground as two masked colour passes. Read the destination before
   every masked write so transparent pixels retain their current latch values.
3. Hide or move the pointer by copying the saved rectangle back through write
   mode one. Restore the graphics mode, map mask, enable-set/reset, data rotate,
   and bit-mask state expected by subsequent drawing operations.

The implementation uses 8086 byte/word operations and preserves the caller's
segment registers and stack. Antler also reduced its input interval during a
drawing burst from two timer ticks to one, approximately 55 ms. Scheduling
delay can still dominate pointer smoothness under load.

The linked 8086 cursor code was executed against a four-plane latch model
over 132 draw/move/restore cases, including clipping, transparency, background
restoration, and register/ABI checks:

| Measurement | Previous path | Accelerated path |
| --- | ---: | ---: |
| Executed instructions | 2,776,036 | 1,336,040 |
| Video reads | 28,368 | 20,968 |
| Video writes | 44,688 | 20,968 |
| Port writes | 8,208 | 13,624 |

That is 51.9% fewer emulated instructions. Port writes increased, so this
figure is not a physical frame-rate or latency claim. A physical timing test
under disk, network, and redraw load is still needed to quantify responsiveness.

## FreeRos integration points

The source reviewed was commit
[`7faf4083d5b2a2e2e2d0c90b0b38c56e3e441c06`](https://github.com/parabyte/FreeRos/commit/7faf4083d5b2a2e2e2d0c90b0b38c56e3e441c06).

| File | Relevant work |
| --- | --- |
| `src/bios_ports.h` | PEGA control/status fields and colour/monochrome port selection. |
| `src/video_pega_inrom.c` | Direct font loading, mode programming, attribute writes, and INT 10h service policy. |
| `src/video_pega_rom_tables.c` | Standalone video-ROM parameter tables. |
| `src/video_pega_rom_int10.S` | INT 10h entry and register/stack wrapper. |

In the reviewed C service, AH=01h and AH=02h update cursor state in the BIOS
data area; that alone does not program CRTC cursor shape/position. AH=11h
font services are not implemented by that switch, whose default branch clears
carry. Firmware work should implement the promised interface explicitly and
distinguish unsupported functions from successful operations. A usable font
query interface is particularly useful to an OS that captures ROM font
addresses before retiring BIOS calls.

These notes document findings and integration requirements. They do not claim
that FreeRos now implements a GEM graphics cursor or the missing BIOS services.

## Validation boundaries

The physical evidence is the ROM read and its analysis. No undocumented
register-write sweep or font-RAM experiment was performed on the live machine.
Graphics pointer correctness was tested with linked 8086 code and the latch
model; a private PC1640/PEGA 86Box boot also reached the GEM desktop.

Emulator setup can mimic a video failure: the physical deployment profile
reserves the final KiB for firmware, but the emulated PC1640 still needs 640
KiB of installed RAM. Its Longshine serial mouse connector is at 02E8h/IRQ4,
whereas an ordinary emulated COM2 is 02F8h/IRQ3. A mismatched mouse port can
make GEM report display startup failure after modesetting. Match RAM,
controller geometry/jumpers, UART, and monitor personality before attributing
that failure to PEGA rendering. The hardware cursor conclusion does not depend
on the emulator.

Antler retains the ordinary GEM graphics environment and its accelerated
planar pointer. The experimental text-mode pointer was removed because it
does not satisfy the requirement for a mouse pointer inside graphical GEM.
