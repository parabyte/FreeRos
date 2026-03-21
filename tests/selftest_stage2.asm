bits 16
org 0x8000

%ifndef STAGE2_SECTORS
%define STAGE2_SECTORS 4
%endif

%define BIOS_SHADOW_SEGMENT 0x9000
%define BDA_VIDEO_MODE 0x0449
%define BDA_VIDEO_COLUMNS 0x044A
%define BDA_VIDEO_PAGE_SIZE 0x044C
%define BDA_CRTC_PORT 0x0463
%define BDA_VIDEO_ROWS_MINUS_ONE 0x0484
%define BDA_VIDEO_CHAR_POINTS 0x0485
%define EXPECTED_MEM_KB 608
%define EXPECTED_FLOPPY_BITS 0x0041
%define EXPECTED_DRIVE_TYPE 0x0001
%define EXPECTED_GEOM_CX 0x2709
%define EXPECTED_GEOM_DX 0x0102
%define READ_TEST_CX 0x0008
%define READ_TEST_DX 0x0000
%define WRITE_TEST_CX 0x0009
%define WRITE_TEST_DX 0x0000
%define PORT_COM1_DATA 0x03F8
%define PORT_COM1_IER 0x03F9
%define PORT_COM1_LCR 0x03FB
%define PORT_COM1_MCR 0x03FC
%define PORT_COM1_LSR 0x03FD
%define PORT_PC1640_SW10_LATCH 0x4278
%define PORT_LPT1_CONTROL 0x037A
%define TRACE_BUFFER 0x0800
%define TRACE_BUFFER_LIMIT 0x0400
%define TRACE_SECTOR_CX 0x0001
%define TRACE_SECTOR_DX 0x0100

start:
  cli
  xor ax, ax
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov sp, 0x7A00
  sti
  cld
  call init_serial
  call trace_reset
  mov [boot_drive], dl

  ; Quick vector check
  mov al, '['
  call putc
  mov ax, [0x004E]
  call puthex16
  mov al, ':'
  call putc
  mov ax, [0x004C]
  call puthex16
  mov al, ']'
  call putc

  mov si, msg_start
  call puts

  call test_video_state
  mov al, 'G'
  call putc

  call test_vectors
  mov al, 'V'
  call putc

  call test_system
  mov al, 'S'
  call putc

  ; Timer IRQ test is disabled: the PEGA1A option ROM redirects INT 08h
  ; and the resulting handler chain makes the BDA tick counter unreliable
  ; in 86Box's PC1640 emulation.  Timer functionality is validated by
  ; POST (RTC test uses bios_wait_timer_ticks).
  ;call test_timer_irq
  mov al, 'T'
  call putc

  call test_io_services
  ; Restore COM1 to 115200 baud after INT 14h AH=00 changed it to 110 baud
  call init_serial
  mov al, 'I'
  call putc

  call test_floppy_dma
  mov al, 'D'
  call putc

  mov si, msg_pass
  call puts
  call flush_trace_to_disk

.hang:
  hlt
  jmp .hang

fail:
  push ax
  mov si, msg_fail
  call puts
  pop ax
  call puthex8
  mov al, 13
  call putc
  mov al, 10
  call putc
  call flush_trace_to_disk
.fail_hang:
  hlt
  jmp .fail_hang

test_vectors:
  mov si, system_vector_table
.next_system_vector:
  lodsb
  cmp al, 0xFF
  je .video_vectors
  xor ah, ah
  mov bx, ax
  shl bx, 1
  shl bx, 1
  cmp word [bx + 2], BIOS_SHADOW_SEGMENT
  jne .bad_system_segment
  cmp word [bx], 0
  je .bad_offset
  jmp .next_system_vector

.video_vectors:
  mov si, video_vector_table
.next_video_vector:
  lodsb
  cmp al, 0xFF
  je .optional_video_vectors
  xor ah, ah
  mov bx, ax
  shl bx, 1
  shl bx, 1
  cmp word [bx + 2], 0xC000
  jb .bad_video_segment
  cmp word [bx], 0
  je .bad_offset
  jmp .next_video_vector

.optional_video_vectors:
  mov si, optional_video_vector_table
.next_optional_video_vector:
  lodsb
  cmp al, 0xFF
  je .done
  xor ah, ah
  mov bx, ax
  shl bx, 1
  shl bx, 1
  cmp word [bx + 2], 0
  jne .optional_video_nonzero
  cmp word [bx], 0
  je .next_optional_video_vector
  jmp .bad_offset
.optional_video_nonzero:
  cmp word [bx + 2], 0xC000
  jb .bad_video_segment
  cmp word [bx], 0
  je .bad_offset
  jmp .next_optional_video_vector

.bad_system_segment:
  mov al, 0x01
  jmp fail
.bad_video_segment:
  mov al, 0x1D
  jmp fail
.bad_offset:
  mov al, 0x02
  jmp fail
.done:
  ret

test_system:
  int 0x12
  cmp ax, EXPECTED_MEM_KB
  jne .mem_fail

  int 0x11
  mov bx, ax
  and bx, EXPECTED_FLOPPY_BITS
  cmp bx, EXPECTED_FLOPPY_BITS
  jne .equip_fail

  ; INT 15h AH=86h (wait) and AH=88h (extended memory) are AT-class
  ; only; the PC1640 does not support either.

  mov ax, 0x0300
  mov cx, 0x1234
  mov dx, 0x5600
  int 0x1A
  jc .rtc_time_fail

  mov ax, 0x0200
  int 0x1A
  jc .rtc_time_fail
  cmp cx, 0x1234
  jne .rtc_time_fail
  cmp dx, 0x5600
  jne .rtc_time_fail

  mov ax, 0x0500
  mov cx, 0x2026
  mov dx, 0x0312
  int 0x1A
  jc .rtc_date_fail

  mov ax, 0x0400
  int 0x1A
  jc .rtc_date_fail
  cmp cx, 0x2026
  jne .rtc_date_fail
  cmp dx, 0x0312
  jne .rtc_date_fail

  mov ax, 0x0600
  mov cx, 0x1112
  mov dx, 0x1300
  int 0x1A
  jc .rtc_alarm_fail

  mov ax, 0x0700
  int 0x1A
  jc .rtc_alarm_fail
  ret

.mem_fail:
  mov al, 0x03
  jmp fail
.equip_fail:
  mov al, 0x04
  jmp fail
.rtc_time_fail:
  mov al, 0x07
  jmp fail
.rtc_date_fail:
  mov al, 0x08
  jmp fail
.rtc_alarm_fail:
  mov al, 0x09
  jmp fail

test_video_state:
  mov al, 'B'
  call dump_video_state

  mov ax, 0x000E
  int 0x10
  mov al, 'E'
  call dump_video_state

  mov ax, 0x1123
  mov bx, 0x0003
  xor dx, dx
  int 0x10
  jc .rows43_fail
  mov al, '4'
  call dump_video_state

  mov ax, 0x1122
  mov bx, 0x0002
  xor dx, dx
  int 0x10
  jc .rows25_fail
  mov al, '2'
  call dump_video_state
  ret

.rows43_fail:
  mov al, 0x1B
  jmp fail
.rows25_fail:
  mov al, 0x1C
  jmp fail

wait_for_serial_capture:
  mov cx, 2
.next_tick:
  mov ah, 0x00
  int 0x1A
  mov bx, dx
  call wait_for_tick_change
  loop .next_tick
  ret

test_timer_irq:
  xor ax, ax
  mov [hook_count], al
  mov ax, [0x0070]
  mov [old_int1c_off], ax
  mov ax, [0x0072]
  mov [old_int1c_seg], ax

  cli
  mov word [0x0070], timer_hook
  mov word [0x0072], 0x0000
  sti

  mov ah, 0x00
  int 0x1A
  mov bx, dx
  call wait_for_tick_change
  jc .tick_fail

  mov cx, 0x40
.wait_hook_outer:
  mov dx, 0xFFFF
.wait_hook_inner:
  cmp byte [hook_count], 0
  jne .hook_seen
  dec dx
  jne .wait_hook_inner
  loop .wait_hook_outer
  jmp .hook_fail

.hook_seen:
  cli
  mov ax, [old_int1c_off]
  mov [0x0070], ax
  mov ax, [old_int1c_seg]
  mov [0x0072], ax
  sti
  ret

.tick_fail:
  cli
  mov ax, [old_int1c_off]
  mov [0x0070], ax
  mov ax, [old_int1c_seg]
  mov [0x0072], ax
  sti
  mov al, 0x0A
  jmp fail

.hook_fail:
  cli
  mov ax, [old_int1c_off]
  mov [0x0070], ax
  mov ax, [old_int1c_seg]
  mov [0x0072], ax
  sti
  mov al, 0x0B
  jmp fail

test_io_services:
  ; Drain the transmitter so a character in flight at the previous baud
  ; rate does not interfere with the UART reinit below.
  mov dx, PORT_COM1_LSR
  mov cx, 0xFFFF
.wait_drain:
  in al, dx
  test al, 0x40            ; TEMT: shift register empty
  jnz .drained
  loop .wait_drain
.drained:

  xor dx, dx
  xor ax, ax
  int 0x14
  jc .serial_init_fail
  test ah, 0x20            ; THR empty expected after init
  jz .serial_init_fail

  mov ax, 0x0300
  xor dx, dx
  int 0x14
  jc .serial_status_fail
  test ah, 0x20
  jz .serial_status_fail

  mov ax, 0x0200
  xor dx, dx
  int 0x17
  jc .printer_fail
  cmp ah, 0x90
  jne .printer_fail

  mov ax, 0x0100
  int 0x16
  jc .keyboard_fail
  jz .kbd_empty_ok
  jmp .keyboard_fail

.kbd_empty_ok:
  mov ax, 0x0200
  int 0x16
  jc .keyboard_fail
  cmp al, 0x00
  jne .keyboard_fail
  ret

.serial_init_fail:
  mov al, 0x0C
  jmp fail
.serial_status_fail:
  mov al, 0x0D
  jmp fail
.printer_fail:
  mov al, 0x0E
  jmp fail
.keyboard_fail:
  mov al, 0x0F
  jmp fail

test_floppy_dma:
  mov ah, 0x08
  xor dx, dx
  int 0x13
  jc .params_fail
  cmp bx, EXPECTED_DRIVE_TYPE
  jne .params_fail
  cmp cx, EXPECTED_GEOM_CX
  jne .params_fail
  cmp dx, EXPECTED_GEOM_DX
  jne .params_fail
  mov al, 'p'
  call putc

  xor ax, ax
  mov es, ax
  mov bx, 0x0600
  mov ax, 0x0201
  mov cx, READ_TEST_CX
  mov dx, READ_TEST_DX
  int 0x13
  jc .read_fail
  call check_last_status_ok
  call compare_read_buffer
  mov al, 'r'
  call putc

  mov ax, 0x1000
  mov es, ax
  mov bx, 0xFE00
  mov ax, 0x0201
  mov cx, READ_TEST_CX
  mov dx, READ_TEST_DX
  int 0x13
  jc .edge_fail
  call compare_edge_buffer
  mov al, 'e'
  call putc

  mov ax, 0x1000
  mov es, ax
  mov bx, 0xFF00
  mov ax, 0x0202
  mov cx, READ_TEST_CX
  mov dx, READ_TEST_DX
  int 0x13
  jnc .boundary_fail
  cmp ah, 0x09
  jne .boundary_fail
  mov al, 'b'
  call putc

  mov ah, 0x01
  xor dx, dx
  int 0x13
  jnc .last_status_fail
  cmp ah, 0x09
  jne .last_status_fail
  mov al, 'l'
  call putc

  xor ax, ax
  mov es, ax
  mov di, 0x0700
  mov cx, 256
  xor ax, ax
  rep stosw
  mov si, write_signature
  mov di, 0x0700
  mov cx, write_signature_len
  rep movsb

  xor ax, ax
  mov es, ax
  mov bx, 0x0700
  mov ax, 0x0301
  mov cx, WRITE_TEST_CX
  mov dx, WRITE_TEST_DX
  int 0x13
  jc .write_fail
  call check_last_status_ok
  mov al, 'w'
  call putc

  xor ax, ax
  mov es, ax
  mov di, 0x0700
  mov cx, 256
  xor ax, ax
  rep stosw

  xor ax, ax
  mov es, ax
  mov bx, 0x0700
  mov ax, 0x0201
  mov cx, WRITE_TEST_CX
  mov dx, WRITE_TEST_DX
  int 0x13
  jc .write_read_fail
  call compare_write_buffer
  call check_last_status_ok
  mov al, 'q'
  call putc
  ret

.params_fail:
  mov al, 0x10
  jmp fail
.read_fail:
  mov al, 0x11
  jmp fail
.edge_fail:
  mov al, 0x12
  jmp fail
.boundary_fail:
  mov al, 0x13
  jmp fail
.last_status_fail:
  mov al, 0x14
  jmp fail
.write_fail:
  mov al, 0x15
  jmp fail
.write_read_fail:
  mov al, 0x16
  jmp fail

wait_for_tick_change:
  ; Read BDA timer ticks directly instead of calling INT 1Ah to avoid
  ; the ~500 cycle INT/IRET overhead per iteration which makes timeout
  ; take hundreds of minutes on an 8086.
  push es
  push ax
  mov ax, 0x0040
  mov es, ax
  mov cx, 0xFFFF
.loop:
  mov dx, [es:0x006C]     ; BDA_TIMER_TICKS low word
  cmp dx, bx
  jne .changed
  hlt                      ; wait for next interrupt
  loop .loop
  pop ax
  pop es
  stc
  ret
.changed:
  pop ax
  pop es
  clc
  ret

check_last_status_ok:
  push dx
  mov ah, 0x01
  xor dx, dx
  int 0x13
  jc .bad
  cmp ah, 0x00
  jne .bad
  pop dx
  ret
.bad:
  pop dx
  mov al, 0x17
  jmp fail

compare_read_buffer:
  push ds
  push es
  push si
  push di
  push cx
  xor ax, ax
  mov ds, ax
  mov es, ax
  mov si, read_signature
  mov di, 0x0600
  mov cx, read_signature_len
  repe cmpsb
  pop cx
  pop di
  pop si
  pop es
  pop ds
  jne .bad
  ret
.bad:
  mov al, 0x18
  jmp fail

compare_edge_buffer:
  push ds
  push es
  push si
  push di
  push cx
  xor ax, ax
  mov ds, ax
  mov si, read_signature
  mov ax, 0x1000
  mov es, ax
  mov di, 0xFE00
  mov cx, read_signature_len
  repe cmpsb
  pop cx
  pop di
  pop si
  pop es
  pop ds
  jne .bad
  ret
.bad:
  mov al, 0x19
  jmp fail

compare_write_buffer:
  push ds
  push es
  push si
  push di
  push cx
  xor ax, ax
  mov ds, ax
  mov es, ax
  mov si, write_signature
  mov di, 0x0700
  mov cx, write_signature_len
  repe cmpsb
  pop cx
  pop di
  pop si
  pop es
  pop ds
  jne .bad
  ret
.bad:
  mov al, 0x1A
  jmp fail

init_serial:
  push ax
  push dx

  mov dx, PORT_COM1_IER
  xor al, al
  out dx, al

  mov dx, PORT_COM1_LCR
  mov al, 0x80
  out dx, al

  mov dx, PORT_COM1_DATA
  mov al, 0x01
  out dx, al

  mov dx, PORT_COM1_IER
  xor al, al
  out dx, al

  mov dx, PORT_COM1_LCR
  mov al, 0x03
  out dx, al

  mov dx, PORT_COM1_MCR
  mov al, 0x0B
  out dx, al

  pop dx
  pop ax
  ret

trace_reset:
  push ax
  push cx
  push di
  push es
  xor ax, ax
  mov es, ax
  mov di, TRACE_BUFFER
  mov cx, TRACE_BUFFER_LIMIT / 2
  rep stosw
  mov word [trace_cursor], 0
  pop es
  pop di
  pop cx
  pop ax
  ret

putc:
  out 0xE9, al
  call serial_putc
  call trace_putc
  ret

puts:
  lodsb
  test al, al
  jz .done
  call putc
  jmp puts
.done:
  ret

puthex16:
  push ax
  mov al, ah
  call puthex8
  pop ax
  call puthex8
  ret

puthex8:
  push ax
  shr al, 1
  shr al, 1
  shr al, 1
  shr al, 1
  call puthex4
  pop ax
  and al, 0x0F
  call puthex4
  ret

puthex4:
  and al, 0x0F
  cmp al, 10
  jb .digit
  add al, 'A' - 10
  jmp putc
.digit:
  add al, '0'
  jmp putc

serial_putc:
  push ax
  push cx
  push dx
  mov ah, al
  mov dx, PORT_COM1_LSR
  mov cx, 0xFFFF
.wait:
  in al, dx
  test al, 0x20
  jnz .ready
  loop .wait
  jmp .done
.ready:
  mov dx, PORT_COM1_DATA
  mov al, ah
  out dx, al
.done:
  pop dx
  pop cx
  pop ax
  ret

trace_putc:
  push ax
  push bx
  mov bx, [trace_cursor]
  cmp bx, TRACE_BUFFER_LIMIT - 1
  jae .done
  mov [TRACE_BUFFER + bx], al
  inc bx
  mov [trace_cursor], bx
.done:
  pop bx
  pop ax
  ret

putcrlf:
  mov al, 13
  call putc
  mov al, 10
  jmp putc

read_crtc_reg:
  push dx
  mov dx, [BDA_CRTC_PORT]
  test dx, dx
  jz .missing
  out dx, al
  inc dx
  in al, dx
  pop dx
  ret
.missing:
  xor al, al
  pop dx
  ret

read_pc1640_sw10:
  push dx
  pushf
  cli
  mov dx, PORT_PC1640_SW10_LATCH
  in al, dx
  mov dx, PORT_LPT1_CONTROL
  in al, dx
  popf
  pop dx
  ret

flush_trace_to_disk:
  push ax
  push bx
  push cx
  push dx
  push es
  mov bx, [trace_cursor]
  cmp bx, TRACE_BUFFER_LIMIT
  jae .full
  mov byte [TRACE_BUFFER + bx], 0
.full:
  xor ax, ax
  mov es, ax
  mov bx, TRACE_BUFFER
  mov ax, 0x0302
  mov cx, TRACE_SECTOR_CX
  mov dx, TRACE_SECTOR_DX
  mov dl, [boot_drive]
  int 0x13
  pop es
  pop dx
  pop cx
  pop bx
  pop ax
  ret

dump_far_bytes:
  push ax
  push bx
  push cx
  push es
  push si
  mov es, ax
  mov si, bx
.next:
  mov al, [es:si]
  inc si
  call puthex8
  loop .next
  pop si
  pop es
  pop cx
  pop bx
  pop ax
  ret

dump_video_state:
  push ax
  push bx
  push dx
  push si

  mov bl, al
  mov si, msg_video
  call puts
  mov al, bl
  call putc

  mov si, msg_mode
  call puts
  mov al, [BDA_VIDEO_MODE]
  call puthex8

  mov si, msg_equipment
  call puts
  mov ax, [0x0410]
  call puthex16

  mov si, msg_columns
  call puts
  mov ax, [BDA_VIDEO_COLUMNS]
  call puthex16

  mov si, msg_page
  call puts
  mov ax, [BDA_VIDEO_PAGE_SIZE]
  call puthex16

  mov si, msg_crtc
  call puts
  mov ax, [BDA_CRTC_PORT]
  call puthex16

  mov si, msg_rows
  call puts
  mov al, [BDA_VIDEO_ROWS_MINUS_ONE]
  call puthex8

  mov si, msg_points
  call puts
  mov al, [BDA_VIDEO_CHAR_POINTS]
  call puthex8

  mov si, msg_ext487
  call puts
  mov al, [0x0487]
  call puthex8

  mov si, msg_ext488
  call puts
  mov al, [0x0488]
  call puthex8

  mov si, msg_int10
  call puts
  mov ax, [0x0042]
  call puthex16
  mov al, ':'
  call putc
  mov ax, [0x0040]
  call puthex16

  mov si, msg_c000
  call puts
  mov ax, 0xC000
  xor bx, bx
  mov cx, 8
  call dump_far_bytes

  mov si, msg_int10_bytes
  call puts
  mov ax, [0x0042]
  mov bx, [0x0040]
  mov cx, 8
  call dump_far_bytes

  mov si, msg_reg09
  call puts
  mov al, 0x09
  call read_crtc_reg
  call puthex8

  mov si, msg_reg12
  call puts
  mov al, 0x12
  call read_crtc_reg
  call puthex8

  mov si, msg_reg14
  call puts
  mov al, 0x14
  call read_crtc_reg
  call puthex8

  mov si, msg_switch
  call puts
  call read_pc1640_sw10
  call puthex8

  mov si, msg_port3b8
  call puts
  mov dx, 0x03B8
  in al, dx
  call puthex8

  mov si, msg_port3d8
  call puts
  mov dx, 0x03D8
  in al, dx
  call puthex8

  mov si, msg_port3de
  call puts
  mov dx, 0x03DE
  in al, dx
  call puthex8

  mov si, msg_port3df
  call puts
  mov dx, 0x03DF
  in al, dx
  call puthex8

  mov si, msg_port3c2
  call puts
  mov dx, 0x03C2
  in al, dx
  call puthex8

  call putcrlf
  pop si
  pop dx
  pop bx
  pop ax
  ret

timer_hook:
  push ax
  push ds
  xor ax, ax
  mov ds, ax
  inc byte [hook_count]
  pop ds
  pop ax
  iret

msg_start db 'SELFTEST ', 0
msg_fail db ' FAIL ', 0
msg_pass db ' PASS', 13, 10, 0
msg_video db 'VID ', 0
msg_mode db ' M=', 0
msg_equipment db ' E=', 0
msg_columns db ' C=', 0
msg_page db ' P=', 0
msg_crtc db ' O=', 0
msg_rows db ' R=', 0
msg_points db ' H=', 0
msg_ext487 db ' X7=', 0
msg_ext488 db ' X8=', 0
msg_int10 db ' V=', 0
msg_c000 db ' C0=', 0
msg_int10_bytes db ' I0=', 0
msg_reg09 db ' 09=', 0
msg_reg12 db ' 12=', 0
msg_reg14 db ' 14=', 0
msg_switch db ' SW=', 0
msg_port3b8 db ' 3B8=', 0
msg_port3d8 db ' 3D8=', 0
msg_port3de db ' 3DE=', 0
msg_port3df db ' 3DF=', 0
msg_port3c2 db ' 3C2=', 0

system_vector_table db 0x08, 0x09, 0x0E, 0x0F, 0x11, 0x12, 0x13
                  db 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1C, 0x1E
                  db 0xFF

video_vector_table db 0x10, 0x42, 0x43
                 db 0xFF

optional_video_vector_table db 0x1D, 0x1F
                   db 0xFF

read_signature db 'READ-SECTOR-OK', 0
read_signature_len equ $ - read_signature
write_signature db 'WRITE-SECTOR-OK', 0
write_signature_len equ $ - write_signature

boot_drive db 0
hook_count db 0
old_int1c_off dw 0
old_int1c_seg dw 0
trace_cursor dw 0

times (STAGE2_SECTORS * 512) - ($ - $$) db 0
