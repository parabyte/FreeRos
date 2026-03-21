bits 16
org 0x7C00

%ifndef STAGE2_SECTORS
%define STAGE2_SECTORS 4
%endif

start:
  cli
  xor ax, ax
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov sp, 0x7C00
  sti

  mov [boot_drive], dl

  xor ax, ax
  int 0x13
  jc boot_fail

  mov bx, 0x8000
  mov cx, 0x0002
  mov si, STAGE2_SECTORS
.read_stage2:
  mov ax, 0x0201
  xor dx, dx
  mov dl, [boot_drive]
  int 0x13
  jc boot_fail
  add bx, 512
  inc cl
  dec si
  jnz .read_stage2

  mov dl, [boot_drive]
  jmp 0x0000:0x8000

boot_fail:
  mov si, boot_fail_msg
  call puts
  mov al, ah
  call puthex8
  mov al, 13
  call putc
  mov al, 10
  call putc
.hang:
  hlt
  jmp .hang

putc:
  out 0xE9, al
  ret

puts:
  lodsb
  test al, al
  jz .done
  call putc
  jmp puts
.done:
  ret

puthex8:
  push ax
  mov al, ah
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

boot_fail_msg db 'BOOT FAIL ', 0
boot_drive db 0

times 510 - ($ - $$) db 0
dw 0xAA55
