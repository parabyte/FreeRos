bits 16
org 0x7C00

%define DAP_BUFFER   0x0500
%define PARAM_BUFFER 0x0600
%define DATA_BUFFER  0x0800

start:
  cli
  xor ax, ax
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov sp, 0x7C00
  sti

  mov [boot_drive], dl
  call com1_init_9600

  mov al, '>'
  call putc

  mov ah, 0x41
  mov bx, 0x55AA
  mov dl, [boot_drive]
  int 0x13

  ; Save flags and regs from INT 13h before putc clobbers them
  pushf
  push bx
  push cx
  mov al, '<'
  call putc
  pop cx
  pop bx
  popf
  jc fail_1
  cmp bx, 0xAA55
  jne fail_1
  test cx, 0x0001
  jz fail_1
  test cx, 0x0004
  jz fail_1
  mov al, 'a'
  call putc

  mov word [PARAM_BUFFER], 0x001E
  mov si, PARAM_BUFFER
  mov al, 'b'
  call putc
  mov ah, 0x48
  mov dl, [boot_drive]
  int 0x13
  jc fail_2
  mov al, 'c'
  call putc
  cmp word [PARAM_BUFFER + 24], 512
  jne fail_2
  mov ax, [PARAM_BUFFER + 16]
  or ax, [PARAM_BUFFER + 18]
  or ax, [PARAM_BUFFER + 20]
  or ax, [PARAM_BUFFER + 22]
  jz fail_2

  call build_sector1_dap
  mov si, DAP_BUFFER
  mov ah, 0x42
  mov dl, [boot_drive]
  int 0x13
  jc fail_3
  mov al, 'd'
  call putc
  cmp word [DATA_BUFFER], 0x4445
  jne fail_m
  cmp word [DATA_BUFFER + 2], 0x2144
  jne fail_m
  cmp word [DATA_BUFFER + 510], 0xAA55
  jne fail_m

  mov al, 'P'
  call putc
.hang:
  hlt
  jmp .hang

fail_1:
  mov al, '1'
  jmp fail
fail_2:
  mov al, '2'
  jmp fail
fail_3:
  mov al, '3'
  jmp fail
fail_m:
  mov al, 'M'
fail:
  call putc
.fail_hang:
  hlt
  jmp .fail_hang

build_sector1_dap:
  mov word [DAP_BUFFER + 0], 0x0010
  mov word [DAP_BUFFER + 2], 0x0001
  mov word [DAP_BUFFER + 4], DATA_BUFFER
  mov word [DAP_BUFFER + 6], 0x0000
  mov word [DAP_BUFFER + 8], 0x0001
  mov word [DAP_BUFFER + 10], 0x0000
  mov word [DAP_BUFFER + 12], 0x0000
  mov word [DAP_BUFFER + 14], 0x0000
  ret

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

putc:
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

boot_drive db 0

times 510 - ($ - $$) db 0
dw 0xAA55
