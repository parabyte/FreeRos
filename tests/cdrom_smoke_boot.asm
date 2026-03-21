; cdrom_smoke_boot.asm - El Torito no-emulation boot sector for CD-ROM smoke test
;
; This boot image is loaded by the BIOS El Torito implementation.
; For no-emulation boot, CS:IP starts at the load segment:0000,
; DL = drive number (0xE0 for CD-ROM).
;
; Test plan:
;   1. Output '>' to serial (we're alive)
;   2. Check DL == 0xE0 (CD-ROM drive number)
;   3. INT 13h AH=41h - check EDD extensions on drive 0xE0
;   4. INT 13h AH=48h - get drive parameters (should report 2048 bytes/sector)
;   5. INT 13h AH=42h - read LBA 16 (ISO PVD) and verify "CD001" signature
;   6. Output 'P' to serial (all passed)
;
; Output codes (serial port 0x3F8):
;   >  = boot image started
;   a  = DL check passed
;   b  = INT 13h AH=41h passed (EDD check)
;   c  = INT 13h AH=48h passed (get params)
;   d  = sector size is 2048
;   e  = INT 13h AH=42h read issued
;   f  = read completed successfully
;   g  = CD001 signature verified
;   P  = ALL TESTS PASSED
;
;   1  = FAIL: DL != 0xE0
;   2  = FAIL: EDD check failed
;   3  = FAIL: get params failed
;   4  = FAIL: sector size != 2048
;   5  = FAIL: read failed
;   6  = FAIL: CD001 mismatch
;
; Halt codes:
;   H  = halt (after pass or fail)

[bits 16]
[org 0]

start:
    ; Set up segments and stack
    cli
    mov     ax, cs
    mov     ds, ax
    mov     es, ax
    mov     ss, ax
    mov     sp, 0xFFF0
    sti

    ; Save drive number from DL
    mov     [drive_num], dl

    ; 1. We're alive
    mov     al, '>'
    call    serial_out

    ; Also show on screen
    mov     si, msg_started
    call    video_puts

    ; 2. Check DL == 0xE0
    cmp     byte [drive_num], 0xE0
    je      .dl_ok
    mov     al, '1'
    call    serial_out
    mov     si, msg_fail_dl
    call    video_puts
    jmp     halt
.dl_ok:
    mov     al, 'a'
    call    serial_out

    ; 3. INT 13h AH=41h - check extensions present
    mov     ah, 0x41
    mov     bx, 0x55AA
    mov     dl, [drive_num]
    int     0x13
    jc      .edd_fail
    cmp     bx, 0xAA55
    jne     .edd_fail
    jmp     .edd_ok
.edd_fail:
    mov     al, '2'
    call    serial_out
    mov     si, msg_fail_edd
    call    video_puts
    jmp     halt
.edd_ok:
    mov     al, 'b'
    call    serial_out

    ; 4. INT 13h AH=48h - get drive parameters
    mov     ah, 0x48
    mov     dl, [drive_num]
    mov     si, param_buf
    mov     word [param_buf], 26      ; buffer size
    int     0x13
    jc      .params_fail
    jmp     .params_ok
.params_fail:
    mov     al, '3'
    call    serial_out
    mov     si, msg_fail_params
    call    video_puts
    jmp     halt
.params_ok:
    mov     al, 'c'
    call    serial_out

    ; 5. Check sector size == 2048
    mov     ax, [param_buf + 24]      ; bytes per sector
    cmp     ax, 2048
    je      .sector_size_ok
    mov     al, '4'
    call    serial_out
    mov     si, msg_fail_secsize
    call    video_puts
    jmp     halt
.sector_size_ok:
    mov     al, 'd'
    call    serial_out

    ; 6. INT 13h AH=42h - extended read: read LBA 16 (ISO PVD)
    ; Set up DAP
    mov     byte [dap_size], 16
    mov     byte [dap_reserved], 0
    mov     word [dap_count], 1
    mov     word [dap_buf_off], read_buffer
    mov     ax, cs
    mov     word [dap_buf_seg], ax
    mov     dword [dap_lba_lo], 16
    mov     dword [dap_lba_hi], 0

    mov     al, 'e'
    call    serial_out

    mov     ah, 0x42
    mov     dl, [drive_num]
    mov     si, dap_size
    int     0x13
    jc      .read_fail
    jmp     .read_ok
.read_fail:
    mov     al, '5'
    call    serial_out
    mov     si, msg_fail_read
    call    video_puts
    jmp     halt
.read_ok:
    mov     al, 'f'
    call    serial_out

    ; 7. Verify "CD001" at offset 1 of PVD (byte 0 = 0x01 for PVD)
    cmp     byte [read_buffer + 0], 0x01       ; PVD type
    jne     .sig_fail
    cmp     byte [read_buffer + 1], 'C'
    jne     .sig_fail
    cmp     byte [read_buffer + 2], 'D'
    jne     .sig_fail
    cmp     byte [read_buffer + 3], '0'
    jne     .sig_fail
    cmp     byte [read_buffer + 4], '0'
    jne     .sig_fail
    cmp     byte [read_buffer + 5], '1'
    jne     .sig_fail
    jmp     .sig_ok
.sig_fail:
    mov     al, '6'
    call    serial_out
    mov     si, msg_fail_sig
    call    video_puts
    jmp     halt
.sig_ok:
    mov     al, 'g'
    call    serial_out

    ; ALL TESTS PASSED
    mov     al, 'P'
    call    serial_out
    mov     si, msg_pass
    call    video_puts

halt:
    mov     al, 'H'
    call    serial_out
    cli
    hlt
    jmp     halt

; --- Subroutines ---

; Output AL to COM1 (0x3F8)
serial_out:
    push    dx
    push    ax
    mov     dx, 0x3FD
.wait:
    in      al, dx
    test    al, 0x20
    jz      .wait
    pop     ax
    mov     dx, 0x3F8
    out     dx, al
    pop     dx
    ret

; Output null-terminated string at DS:SI via INT 10h
video_puts:
    push    ax
    push    bx
    push    si
.loop:
    lodsb
    or      al, al
    jz      .done
    mov     ah, 0x0E
    mov     bx, 0x0007
    int     0x10
    jmp     .loop
.done:
    pop     si
    pop     bx
    pop     ax
    ret

; --- Data ---

drive_num:      db 0

msg_started:    db 'CD-ROM boot test started', 13, 10, 0
msg_fail_dl:    db 'FAIL: DL != 0xE0', 13, 10, 0
msg_fail_edd:   db 'FAIL: EDD check', 13, 10, 0
msg_fail_params:db 'FAIL: get params', 13, 10, 0
msg_fail_secsize:db 'FAIL: sector size', 13, 10, 0
msg_fail_read:  db 'FAIL: read LBA 16', 13, 10, 0
msg_fail_sig:   db 'FAIL: CD001 sig', 13, 10, 0
msg_pass:       db 'ALL CD-ROM TESTS PASSED', 13, 10, 0

; DAP for INT 13h AH=42h
align 4
dap_size:       db 16
dap_reserved:   db 0
dap_count:      dw 1
dap_buf_off:    dw 0
dap_buf_seg:    dw 0
dap_lba_lo:     dd 0
dap_lba_hi:     dd 0

; Parameter buffer for AH=48h (26 bytes)
align 2
param_buf:      times 26 db 0

; Read buffer (must be at least 2048 bytes for CD sector)
align 16
read_buffer:
; Pad boot image to at least 2048 bytes (one CD sector)
; genisoimage requires the boot image, and we want enough room for the buffer
times 2048 - ($ - $$) db 0
; Extra space for read buffer (2048 bytes)
times 2048 db 0
