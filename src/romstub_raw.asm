;; ================================================
;; FreeRos BIOS
;; romstub_raw.asm: Legacy non-XIP copy stub (non execute-in-place builds)
;; ================================================

; romstub_raw.asm - legacy raw ROM copy stub for non-XIP builds
;
; This path is intentionally NOT used for PC1640DD execute-in-place builds.
; It copies the raw BIOS payload from ROM into RAM at DEST_SEG and jumps there.
;
; The ROM hole at FC00:3065 is skipped while reading.

cpu 8086
bits 16
org 0

%ifndef DEST_SIZE
%error "DEST_SIZE must be provided by the build"
%endif

%ifndef DEST_SEG
%define DEST_SEG 0x9000
%endif

%ifndef ROM_SEG
%define ROM_SEG 0xFC00
%endif

%ifndef COMPAT_HOLE_OFFSET
%define COMPAT_HOLE_OFFSET 0x3065
%endif

%ifndef COMPAT_HOLE_SIZE
%define COMPAT_HOLE_SIZE 5
%endif

ROS_INT10_COMPAT_OFFSET equ COMPAT_HOLE_OFFSET
ROS_INT10_COMPAT_SIZE   equ COMPAT_HOLE_SIZE
ROS_INT10_COMPAT_END    equ ROS_INT10_COMPAT_OFFSET + ROS_INT10_COMPAT_SIZE

%include "src/machine/pc1640dd/pc1640_reset_stub.inc"

entry:
    cli
    cld
    xor ax, ax
    mov ss, ax
    mov sp, 0x7000
    pc1640_reset_stub_preamble

    mov ax, ROM_SEG
    mov ds, ax
    mov ax, DEST_SEG
    mov es, ax
    mov si, raw_data
    xor di, di
    mov cx, DEST_SIZE

.copy:
    call read_rom_byte
    stosb
    loop .copy

    jmp DEST_SEG:0x0000

times (0x0080 - ($ - $$)) db 0x90

read_rom_byte:
    cmp si, ROS_INT10_COMPAT_OFFSET
    jb .read
    cmp si, ROS_INT10_COMPAT_END
    jae .read
    mov si, ROS_INT10_COMPAT_END
.read:
    lodsb
    ret

raw_data:
