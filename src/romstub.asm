; romstub.asm - PC1640 16 KiB ROM decompressor stub
;
; This stub stages the compressed Exomizer raw stream into RAM and then
; decrunches it with a NASM-adapted 8086/P47 decoder based on the upstream
; Exomizer 3.1.2 raw decruncher contributed by Ivan Gorodetsky.
;
; The ROM payload is compressed with:
;   exomizer raw -P 47 <payload.bin> -o <payload.exo>
;
; Mutable decoder state lives in the RAM staging segment. The ROM hole at
; FC00:3065 is skipped while copying the compressed stream out of the ROM.

bits 16
org 0

%macro GetBit 0
    add al, al
    jnz %%done
    lodsb
    adc al, al
%%done:
%endmacro

%ifndef DEST_SIZE
%error "DEST_SIZE must be provided by the build"
%endif

%ifndef COMPRESSED_SIZE
%error "COMPRESSED_SIZE must be provided by the build"
%endif

; Keep this in sync with BIOS_ROM_SEGMENT in src/bios_types.h.
DEST_SEG             equ 0x9000
ROM_SEG              equ 0xFC00
ROS_INT10_COMPAT_OFFSET equ 0x3065
ROS_INT10_COMPAT_SIZE   equ 5
ROS_INT10_COMPAT_END    equ ROS_INT10_COMPAT_OFFSET + ROS_INT10_COMPAT_SIZE
INPUT_OFFSET         equ ((DEST_SIZE + 15) & ~15)
EXO_TABLE_OFFSET     equ 0xFF00

%if INPUT_OFFSET < DEST_SIZE
%error "INPUT_OFFSET must be at or above the decompressed payload size"
%endif

%if INPUT_OFFSET + COMPRESSED_SIZE > EXO_TABLE_OFFSET
%error "Compressed stream overlaps the Exomizer table buffer"
%endif

%if ((DEST_SEG << 4) + EXO_TABLE_OFFSET + 256) > 0xA0000
%error "Destination segment and Exomizer table buffer overlap video memory"
%endif

entry:
    cli
    cld
    xor ax, ax
    mov ss, ax
    mov sp, 0x7000

    ; Debug: romstub entry reached
    mov al, 'R'
    out 0xE9, al

    mov ax, ROM_SEG
    mov ds, ax
    mov ax, DEST_SEG
    mov es, ax
    mov si, compressed_data
    mov di, INPUT_OFFSET
    mov cx, COMPRESSED_SIZE
    call copy_compressed_payload

    ; Debug: copy done
    mov al, 'C'
    out 0xE9, al

    mov ax, DEST_SEG
    mov ds, ax
    mov es, ax
    mov si, INPUT_OFFSET
    xor di, di

    call deexo

    ; Debug: decompression done
    mov al, 'D'
    out 0xE9, al

    jmp DEST_SEG:0x0000

copy_compressed_payload:
.loop:
    call read_rom_byte
    stosb
    loop .loop
    ret

read_rom_byte:
    cmp si, ROS_INT10_COMPAT_OFFSET
    jb .read
    cmp si, ROS_INT10_COMPAT_END
    jae .read
    mov si, ROS_INT10_COMPAT_END
.read:
    lodsb
    ret

deexo:
    mov ax, 0x0180
    mov bx, EXO_TABLE_OFFSET
    xor ch, ch
    cld
    push di

exo_initable:
    test bl, 63
    jnz exo_node1
    mov di, 1

exo_node1:
    mov cl, 4
    call exo_getbits
    mov cl, dl
    ror cl, 1
    mov [bx], cl
    jnc exo_skip_plus8
    add cl, -128 + 8

exo_skip_plus8:
    mov bp, 1
    shl bp, cl
    inc bx
    inc bx
    mov [bx], di
    inc bx
    inc bx
    add di, bp
    cmp bl, 52 * 4
    jne exo_initable
    pop di
    xor cx, cx

exo_literalcopy1:
    movsb
    stc

exo_mainloop:
    adc ah, ah
    GetBit
    jc exo_literalcopy1
    dec cx

exo_getindex:
    inc cx
    GetBit
    jnc exo_getindex
    cmp cl, 16
    jc exo_continue
    jz exo_ret
    mov ch, [si]
    inc si
    mov cl, [si]
    inc si

exo_literalcopy:
    rep movsb
    stc
    jmp exo_mainloop

exo_continue:
    mov bl, cl
    call exo_getpair
    mov cl, ah
    and cl, 3
    dec cl
    jnz exo_not_reuse_offset
    GetBit
    jnc exo_not_reuse_offset
    mov cx, dx
    jmp short exo_reuse_offset

exo_not_reuse_offset:
    push dx
    mov cl, 0x02
    mov bl, 0x30
    dec dx
    jz exo_gogetbits
    mov cl, 0x04
    mov bl, 0x20
    dec dx
    jz exo_gogetbits
    mov bl, 0x10

exo_gogetbits:
    call exo_getbits
    add bl, dl
    call exo_getpair
    mov bp, dx
    pop cx

exo_reuse_offset:
    mov dx, si
    mov si, di
    sub si, bp
    rep movsb
    mov si, dx
    jmp exo_mainloop

exo_getpair:
    add bl, bl
    add bl, bl
    mov cl, [bx]
    call exo_getbits
    inc bx
    inc bx
    add dx, [bx]
    ret

exo_getbits:
    xor dx, dx
    test cl, cl
    jz exo_ret
    jns exo_gettingbits
    and cl, 0x7F
    jz exo_greater_than_7_zero
    call exo_gettingbits
    mov dh, dl

exo_greater_than_7_zero:
    mov dl, [si]
    inc si
    ret

exo_gettingbits:
    GetBit
    adc dx, dx
    loop exo_gettingbits

exo_ret:
    ret

compressed_data:
