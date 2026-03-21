bits 16
org 0x7C00

start:
  cli
  xor ax, ax
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov sp, 0x7C00
  sti

  mov ax, 0xB800
  mov es, ax
  xor di, di
  mov si, video_msg
.video_loop:
  lodsb
  test al, al
  jz .video_done
  mov ah, 0x1E
  stosw
  jmp .video_loop
.video_done:

  call com1_init_9600
  mov si, serial_msg
  call puts_com1

.hang:
  hlt
  jmp .hang

com1_init_9600:
  mov dx, 0x03FB
  mov al, 0x80
  out dx, al
  mov dx, 0x03F8
  mov al, 0x0C
  out dx, al
  mov dx, 0x03F9
  xor al, al
  out dx, al
  mov dx, 0x03FB
  mov al, 0x03
  out dx, al
  mov dx, 0x03FC
  mov al, 0x03
  out dx, al
  ret

puts_com1:
  lodsb
  test al, al
  jz .done
  call putc_com1
  jmp puts_com1
.done:
  ret

putc_com1:
  push ax
  mov ah, al
.wait:
  mov dx, 0x03FD
  in al, dx
  test al, 0x20
  jz .wait
  mov al, ah
  mov dx, 0x03F8
  out dx, al
  pop ax
  ret

video_msg db 'IDE BOOT OK', 0
serial_msg db 'IDEBOOT', 13, 10, 0

times 510 - ($ - $$) db 0
dw 0xAA55
