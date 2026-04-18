;; ================================================
;; FreeRos BIOS
;; pc1640_reset_stub.inc: PC1640 warm-reset handshake assembly macro
;; ================================================

%macro pc1640_reset_stub_preamble 0
    ; Match the original PC1640 reset-vector handshake around 0040:0072.
    ; PEGA requests a soft reset by leaving 0x1234 in the warm-boot flag.
    out 0xA0, al
    mov dx, 0x3F2
    out dx, al
    mov ds, ax
    cmp word [0x0472], 0x1234
    jne %%not_requested
    inc word [0x0472]
    out 0x66, al
%%wait_reset:
    jmp %%wait_reset
%%not_requested:
    jl %%done
    dec word [0x0472]
%%done:
%endmacro
