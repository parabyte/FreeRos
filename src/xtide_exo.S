	.text
	.arch i8086,jumps
	.code16
	.intel_syntax noprefix

/*
 * void __attribute__((stdcall))
 * bios_xtide_exo_decompress(u16 dest_seg, u16 input_off, u16 table_off);
 *
 * DS/ES are switched to dest_seg. The compressed Exomizer stream must already
 * be staged at dest_seg:input_off. The option ROM is decrunched to dest_seg:0.
 * table_off points to a 256-byte scratch area inside the same hidden RAM
 * block; using caller-supplied storage avoids the old fixed 0xFF00 table.
 */

.globl bios_xtide_exo_decompress
.type bios_xtide_exo_decompress, @function
bios_xtide_exo_decompress:
	push bp
	mov bp, sp
	push bx
	push si
	push di
	push ds
	push es

	mov ax, WORD PTR [bp + 4]
	mov si, WORD PTR [bp + 6]
	mov bx, WORD PTR [bp + 8]
	mov ds, ax
	mov es, ax
	xor di, di

	mov ax, 0x0180
	xor ch, ch
	cld
	push di

.Lexo_initable:
	test bl, 63
	jne .Lexo_node1
	mov di, 1

.Lexo_node1:
	mov cl, 4
	call .Lexo_getbits
	mov cl, dl
	ror cl, 1
	mov BYTE PTR [bx], cl
	jnc .Lexo_skip_plus8
	add cl, -120

.Lexo_skip_plus8:
	mov bp, 1
	shl bp, cl
	inc bx
	inc bx
	mov WORD PTR [bx], di
	inc bx
	inc bx
	add di, bp
	cmp bl, 52 * 4
	jne .Lexo_initable

	pop di
	xor cx, cx

.Lexo_literalcopy1:
	movsb
	stc

.Lexo_mainloop:
	adc ah, ah
	add al, al
	jnz .Lexo_mainloop_bit_ready
	lodsb
	adc al, al
.Lexo_mainloop_bit_ready:
	jc .Lexo_literalcopy1
	dec cx

.Lexo_getindex:
	inc cx
	add al, al
	jnz .Lexo_getindex_bit_ready
	lodsb
	adc al, al
.Lexo_getindex_bit_ready:
	jnc .Lexo_getindex
	cmp cl, 16
	jc .Lexo_continue
	jz .Lexo_done
	mov ch, BYTE PTR [si]
	inc si
	mov cl, BYTE PTR [si]
	inc si

.Lexo_literalcopy:
	rep movsb
	stc
	jmp .Lexo_mainloop

.Lexo_continue:
	mov bl, cl
	call .Lexo_getpair
	mov cl, ah
	and cl, 3
	dec cl
	jnz .Lexo_not_reuse_offset
	add al, al
	jnz .Lexo_reuse_bit_ready
	lodsb
	adc al, al
.Lexo_reuse_bit_ready:
	jnc .Lexo_not_reuse_offset
	mov cx, dx
	jmp short .Lexo_reuse_offset

.Lexo_not_reuse_offset:
	push dx
	mov cl, 0x02
	mov bl, 0x30
	dec dx
	jz .Lexo_gogetbits
	mov cl, 0x04
	mov bl, 0x20
	dec dx
	jz .Lexo_gogetbits
	mov bl, 0x10

.Lexo_gogetbits:
	call .Lexo_getbits
	add bl, dl
	call .Lexo_getpair
	mov bp, dx
	pop cx

.Lexo_reuse_offset:
	mov dx, si
	mov si, di
	sub si, bp
	rep movsb
	mov si, dx
	jmp .Lexo_mainloop

.Lexo_getpair:
	add bl, bl
	add bl, bl
	mov cl, BYTE PTR [bx]
	call .Lexo_getbits
	inc bx
	inc bx
	add dx, WORD PTR [bx]
	ret

.Lexo_getbits:
	xor dx, dx
	test cl, cl
	jz .Lexo_subret
	jns .Lexo_gettingbits
	and cl, 0x7f
	jz .Lexo_greater_than_7_zero
	call .Lexo_gettingbits
	mov dh, dl

.Lexo_greater_than_7_zero:
	mov dl, BYTE PTR [si]
	inc si
	ret

.Lexo_gettingbits:
	add al, al
	jnz .Lexo_gettingbits_bit_ready
	lodsb
	adc al, al
.Lexo_gettingbits_bit_ready:
	adc dx, dx
	loop .Lexo_gettingbits

.Lexo_subret:
	ret

.Lexo_done:
	pop es
	pop ds
	pop di
	pop si
	pop bx
	pop bp
	ret 6

.size bios_xtide_exo_decompress, .-bios_xtide_exo_decompress
