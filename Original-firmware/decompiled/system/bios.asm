000F8000  E9C600            jmp 0x80c9
000F8003  284329            sub [bp+di+0x29],al
000F8006  20436F            and [bp+di+0x6f],al
000F8009  7079              jo 0x8084
000F800B  7269              jc 0x8076
000F800D  67687420          push word 0x2074
000F8011  3139              xor [bx+di],di
000F8013  3838              cmp [bx+si],bh
000F8015  20416D            and [bx+di+0x6d],al
000F8018  7374              jnc 0x808e
000F801A  7261              jc 0x807d
000F801C  6420706C          and [fs:bx+si+0x6c],dh
000F8020  6328              arpl [bx+si],bp
000F8022  284343            sub [bp+di+0x43],al
000F8025  2929              sub [bx+di],bp
000F8027  2020              and [bx+si],ah
000F8029  43                inc bx
000F802A  43                inc bx
000F802B  6F                outsw
000F802C  6F                outsw
000F802D  7070              jo 0x809f
000F802F  7979              jns 0x80aa
000F8031  7272              jc 0x80a5
000F8033  6969676768        imul bp,[bx+di+0x67],word 0x6867
000F8038  687474            push word 0x7474
000F803B  2020              and [bx+si],ah
000F803D  3131              xor [bx+di],si
000F803F  3939              cmp [bx+di],di
000F8041  3838              cmp [bx+si],bh
000F8043  3838              cmp [bx+si],bh
000F8045  2020              and [bx+si],ah
000F8047  41                inc cx
000F8048  41                inc cx
000F8049  6D                insw
000F804A  6D                insw
000F804B  7373              jnc 0x80c0
000F804D  7474              jz 0x80c3
000F804F  7272              jc 0x80c3
000F8051  61                popa
000F8052  61                popa
000F8053  64642020          and [fs:bx+si],ah
000F8057  7070              jo 0x80c9
000F8059  6C                insb
000F805A  6C                insb
000F805B  636360            arpl [bp+di+0x60],sp
000F805E  32E4              xor ah,ah
000F8060  8BD8              mov bx,ax
000F8062  8BEA              mov bp,dx
000F8064  B800B8            mov ax,0xb800
000F8067  8ED8              mov ds,ax
000F8069  C6072E            mov byte [bx],0x2e
000F806C  B4B0              mov ah,0xb0
000F806E  8ED8              mov ds,ax
000F8070  C6072E            mov byte [bx],0x2e
000F8073  D1CB              ror bx,1
000F8075  43                inc bx
000F8076  B97E00            mov cx,0x7e
000F8079  BAD403            mov dx,0x3d4
000F807C  EB05              jmp short 0x8083
000F807E  8BCF              mov cx,di
000F8080  BAB403            mov dx,0x3b4
000F8083  B00F              mov al,0xf
000F8085  EE                out dx,al
000F8086  8AC3              mov al,bl
000F8088  42                inc dx
000F8089  EE                out dx,al
000F808A  8BD5              mov dx,bp
000F808C  FFE1              jmp cx
000F808E  B90410            mov cx,0x1004
000F8091  BAC203            mov dx,0x3c2
000F8094  33C0              xor ax,ax
000F8096  80ED04            sub ch,0x4
000F8099  8AC5              mov al,ch
000F809B  EE                out dx,al
000F809C  8A07              mov al,[bx]
000F809E  EC                in al,dx
000F809F  F6D0              not al
000F80A1  2410              and al,0x10
000F80A3  D2E8              shr al,cl
000F80A5  0AE0              or ah,al
000F80A7  FEC9              dec cl
000F80A9  75EB              jnz 0x8096
000F80AB  80FC0A            cmp ah,0xa
000F80AE  7203              jc 0x80b3
000F80B0  80EC06            sub ah,0x6
000F80B3  8BDE              mov bx,si
000F80B5  BED72F            mov si,0x2fd7
000F80B8  80FC05            cmp ah,0x5
000F80BB  7603              jna 0x80c0
000F80BD  BE733F            mov si,0x3f73
000F80C0  FC                cld
000F80C1  8CC8              mov ax,cs
000F80C3  8ED0              mov ss,ax
000F80C5  BC593F            mov sp,0x3f59
000F80C8  C3                ret
000F80C9  FA                cli
000F80CA  33C0              xor ax,ax
000F80CC  E6A0              out 0xa0,al
000F80CE  BAF203            mov dx,0x3f2
000F80D1  EE                out dx,al
000F80D2  8ED8              mov ds,ax
000F80D4  813E72043412      cmp word [0x472],0x1234
000F80DA  7508              jnz 0x80e4
000F80DC  FF067204          inc word [0x472]
000F80E0  E666              out 0x66,al
000F80E2  EBFE              jmp short 0x80e2
000F80E4  7C04              jl 0x80ea
000F80E6  FF0E7204          dec word [0x472]
000F80EA  BAFC03            mov dx,0x3fc
000F80ED  B010              mov al,0x10
000F80EF  EE                out dx,al
000F80F0  B00D              mov al,0xd
000F80F2  BBF800            mov bx,0xf8
000F80F5  E9890B            jmp 0x8c81
000F80F8  750C              jnz 0x8106
000F80FA  02C0              add al,al
000F80FC  7228              jc 0x8126
000F80FE  813E72043412      cmp word [0x472],0x1234
000F8104  7420              jz 0x8126
000F8106  B80B82            mov ax,0x820b
000F8109  EF                out dx,ax
000F810A  B94000            mov cx,0x40
000F810D  BB0502            mov bx,0x205
000F8110  33C0              xor ax,ax
000F8112  2E8A27            mov ah,[cs:bx]
000F8115  80FCFE            cmp ah,0xfe
000F8118  7401              jz 0x811b
000F811A  EF                out dx,ax
000F811B  FEC0              inc al
000F811D  81FB2E02          cmp bx,0x22e
000F8121  7401              jz 0x8124
000F8123  43                inc bx
000F8124  E2EC              loop 0x8112
000F8126  B023              mov al,0x23
000F8128  BB2E01            mov bx,0x12e
000F812B  E9530B            jmp 0x8c81
000F812E  8AE0              mov ah,al
000F8130  B700              mov bh,0x0
000F8132  7402              jz 0x8136
000F8134  B7FF              mov bh,0xff
000F8136  BADA03            mov dx,0x3da
000F8139  EC                in al,dx
000F813A  B27A              mov dl,0x7a
000F813C  EC                in al,dx
000F813D  A820              test al,0x20
000F813F  754E              jnz 0x818f
000F8141  EC                in al,dx
000F8142  24C0              and al,0xc0
000F8144  B102              mov cl,0x2
000F8146  D2C0              rol al,cl
000F8148  8AD8              mov bl,al
000F814A  FECE              dec dh
000F814C  EC                in al,dx
000F814D  FEC6              inc dh
000F814F  EC                in al,dx
000F8150  2420              and al,0x20
000F8152  D2C8              ror al,cl
000F8154  D0C8              ror al,1
000F8156  0AD8              or bl,al
000F8158  B642              mov dh,0x42
000F815A  EC                in al,dx
000F815B  B603              mov dh,0x3
000F815D  EC                in al,dx
000F815E  2420              and al,0x20
000F8160  D2C8              ror al,cl
000F8162  0AD8              or bl,al
000F8164  80E4C0            and ah,0xc0
000F8167  0AE3              or ah,bl
000F8169  2408              and al,0x8
000F816B  7407              jz 0x8174
000F816D  EC                in al,dx
000F816E  24C0              and al,0xc0
000F8170  D2C8              ror al,cl
000F8172  0AE0              or ah,al
000F8174  B023              mov al,0x23
000F8176  BA7000            mov dx,0x70
000F8179  EF                out dx,ax
000F817A  B82801            mov ax,0x128
000F817D  EF                out dx,ax
000F817E  0AFF              or bh,bh
000F8180  750B              jnz 0x818d
000F8182  BB8801            mov bx,0x188
000F8185  E9010B            jmp 0x8c89
000F8188  8AE1              mov ah,cl
000F818A  B014              mov al,0x14
000F818C  EF                out dx,ax
000F818D  2AC0              sub al,al
000F818F  8AE0              mov ah,al
000F8191  BA7903            mov dx,0x379
000F8194  EC                in al,dx
000F8195  2407              and al,0x7
000F8197  752F              jnz 0x81c8
000F8199  0AE4              or ah,ah
000F819B  7512              jnz 0x81af
000F819D  B800E0            mov ax,0xe000
000F81A0  8ED8              mov ds,ax
000F81A2  813E000055AA      cmp word [0x0],0xaa55
000F81A8  7505              jnz 0x81af
000F81AA  EA030000E0        jmp 0xe000:0x3
000F81AF  B800C0            mov ax,0xc000
000F81B2  8ED8              mov ds,ax
000F81B4  813E000055AA      cmp word [0x0],0xaa55
000F81BA  7525              jnz 0x81e1
000F81BC  803E020020        cmp byte [0x2],0x20
000F81C1  741E              jz 0x81e1
000F81C3  EA030000C0        jmp 0xc000:0x3
000F81C8  33DB              xor bx,bx
000F81CA  B90040            mov cx,0x4000
000F81CD  33C0              xor ax,ax
000F81CF  2E0207            add al,[cs:bx]
000F81D2  43                inc bx
000F81D3  E2FA              loop 0x81cf
000F81D5  0AC0              or al,al
000F81D7  7503              jnz 0x81dc
000F81D9  EB54              jmp short 0x822f
000F81DB  90                nop
000F81DC  B00D              mov al,0xd
000F81DE  E9E015            jmp 0x97c1
000F81E1  BB490B            mov bx,0xb49
000F81E4  2E8A0F            mov cl,[cs:bx]
000F81E7  32ED              xor ch,ch
000F81E9  E30F              jcxz 0x81fa
000F81EB  43                inc bx
000F81EC  2E8B17            mov dx,[cs:bx]
000F81EF  43                inc bx
000F81F0  43                inc bx
000F81F1  2E8A07            mov al,[cs:bx]
000F81F4  EE                out dx,al
000F81F5  43                inc bx
000F81F6  E2F9              loop 0x81f1
000F81F8  EBEA              jmp short 0x81e4
000F81FA  32C0              xor al,al
000F81FC  E683              out 0x83,al
000F81FE  E681              out 0x81,al
000F8200  E682              out 0x82,al
000F8202  E91504            jmp 0x861a
000F8205  0000              add [bx+si],al
000F8207  0000              add [bx+si],al
000F8209  0000              add [bx+si],al
000F820B  0101              add [bx+di],ax
000F820D  01802002          add [bx+si+0x220],ax
000F8211  FE                db 0xfe
000F8212  FE00              inc byte [bx+si]
000F8214  0001              add [bx+di],al
000F8216  0101              add [bx+di],ax
000F8218  7800              js 0x821a
000F821A  0D1C07            or ax,0x71c
000F821D  22FF              and bh,bh
000F821F  FF                db 0xff
000F8220  FF                db 0xff
000F8221  FF0D              dec word [di]
000F8223  1C1B              sbb al,0x1b
000F8225  010A              add [bp+si],cx
000F8227  0A20              or ah,[bx+si]
000F8229  07                pop es
000F822A  00E3              add bl,ah
000F822C  E300              jcxz 0x822e
000F822E  00B028BB          add [bx+si-0x44d8],dh
000F8232  37                aaa
000F8233  02E9              add ch,cl
000F8235  4A                dec dx
000F8236  0A0A              or cl,[bp+si]
000F8238  C0                db 0xc0
000F8239  7403              jz 0x823e
000F823B  E9E000            jmp 0x831e
000F823E  BAD803            mov dx,0x3d8
000F8241  B012              mov al,0x12
000F8243  EE                out dx,al
000F8244  B800B8            mov ax,0xb800
000F8247  8EC0              mov es,ax
000F8249  8ED8              mov ds,ax
000F824B  33FF              xor di,di
000F824D  BADD03            mov dx,0x3dd
000F8250  B80100            mov ax,0x1
000F8253  EF                out dx,ax
000F8254  33C9              xor cx,cx
000F8256  890D              mov [di],cx
000F8258  3B0D              cmp cx,[di]
000F825A  7513              jnz 0x826f
000F825C  F7D1              not cx
000F825E  890D              mov [di],cx
000F8260  3B0D              cmp cx,[di]
000F8262  750B              jnz 0x826f
000F8264  F7D1              not cx
000F8266  83F901            cmp cx,byte +0x1
000F8269  13C9              adc cx,cx
000F826B  73E9              jnc 0x8256
000F826D  EB05              jmp short 0x8274
000F826F  B002              mov al,0x2
000F8271  E94D15            jmp 0x97c1
000F8274  BEFF00            mov si,0xff
000F8277  33C0              xor ax,ax
000F8279  8ED8              mov ds,ax
000F827B  813E72043412      cmp word [0x472],0x1234
000F8281  745F              jz 0x82e2
000F8283  8CC0              mov ax,es
000F8285  8ED8              mov ds,ax
000F8287  FC                cld
000F8288  B00F              mov al,0xf
000F828A  EE                out dx,al
000F828B  33FF              xor di,di
000F828D  B90020            mov cx,0x2000
000F8290  8BC6              mov ax,si
000F8292  8AE0              mov ah,al
000F8294  F3AB              rep stosw
000F8296  B90040            mov cx,0x4000
000F8299  33FF              xor di,di
000F829B  BB0804            mov bx,0x408
000F829E  8BC3              mov ax,bx
000F82A0  FECC              dec ah
000F82A2  EF                out dx,ax
000F82A3  8BC6              mov ax,si
000F82A5  3205              xor al,[di]
000F82A7  8825              mov [di],ah
000F82A9  3225              xor ah,[di]
000F82AB  0BC0              or ax,ax
000F82AD  75C0              jnz 0x826f
000F82AF  D0CB              ror bl,1
000F82B1  FECF              dec bh
000F82B3  75E9              jnz 0x829e
000F82B5  47                inc di
000F82B6  E2E3              loop 0x829b
000F82B8  F7D6              not si
000F82BA  FD                std
000F82BB  8BCF              mov cx,di
000F82BD  4F                dec di
000F82BE  BB0100            mov bx,0x1
000F82C1  8BC3              mov ax,bx
000F82C3  EF                out dx,ax
000F82C4  8BC6              mov ax,si
000F82C6  3205              xor al,[di]
000F82C8  8825              mov [di],ah
000F82CA  3225              xor ah,[di]
000F82CC  0BC0              or ax,ax
000F82CE  759F              jnz 0x826f
000F82D0  D0C3              rol bl,1
000F82D2  FEC7              inc bh
000F82D4  80FF04            cmp bh,0x4
000F82D7  75E8              jnz 0x82c1
000F82D9  4F                dec di
000F82DA  E2E2              loop 0x82be
000F82DC  F7C6FF00          test si,0xff
000F82E0  74A5              jz 0x8287
000F82E2  BADA03            mov dx,0x3da
000F82E5  33C9              xor cx,cx
000F82E7  EC                in al,dx
000F82E8  8AE0              mov ah,al
000F82EA  EC                in al,dx
000F82EB  32C4              xor al,ah
000F82ED  2401              and al,0x1
000F82EF  7504              jnz 0x82f5
000F82F1  E2F7              loop 0x82ea
000F82F3  EB4B              jmp short 0x8340
000F82F5  32DB              xor bl,bl
000F82F7  33C9              xor cx,cx
000F82F9  BEFE02            mov si,0x2fe
000F82FC  EB25              jmp short 0x8323
000F82FE  B308              mov bl,0x8
000F8300  B9600C            mov cx,0xc60
000F8303  BE0803            mov si,0x308
000F8306  EB1B              jmp short 0x8323
000F8308  81F91C0B          cmp cx,0xb1c
000F830C  7732              ja 0x8340
000F830E  32DB              xor bl,bl
000F8310  B90004            mov cx,0x400
000F8313  BE1803            mov si,0x318
000F8316  EB0B              jmp short 0x8323
000F8318  81F99603          cmp cx,0x396
000F831C  7722              ja 0x8340
000F831E  B00F              mov al,0xf
000F8320  E99E14            jmp 0x97c1
000F8323  EC                in al,dx
000F8324  2408              and al,0x8
000F8326  8AF8              mov bh,al
000F8328  EC                in al,dx
000F8329  2408              and al,0x8
000F832B  32F8              xor bh,al
000F832D  8AF8              mov bh,al
000F832F  F9                stc
000F8330  740C              jz 0x833e
000F8332  32C3              xor al,bl
000F8334  7508              jnz 0x833e
000F8336  33C0              xor ax,ax
000F8338  8ED8              mov ds,ax
000F833A  890F              mov [bx],cx
000F833C  FFE6              jmp si
000F833E  E2E8              loop 0x8328
000F8340  B009              mov al,0x9
000F8342  E97C14            jmp 0x97c1
000F8345  B0A0              mov al,0xa0
000F8347  BF4D03            mov di,0x34d
000F834A  E911FD            jmp 0x805e
000F834D  BA0800            mov dx,0x8
000F8350  B004              mov al,0x4
000F8352  EE                out dx,al
000F8353  B90800            mov cx,0x8
000F8356  BA0000            mov dx,0x0
000F8359  BE5E03            mov si,0x35e
000F835C  EB13              jmp short 0x8371
000F835E  42                inc dx
000F835F  E2F8              loop 0x8359
000F8361  B90800            mov cx,0x8
000F8364  BA0700            mov dx,0x7
000F8367  BE6C03            mov si,0x36c
000F836A  EB05              jmp short 0x8371
000F836C  4A                dec dx
000F836D  E2F8              loop 0x8367
000F836F  EB1C              jmp short 0x838d
000F8371  E60C              out 0xc,al
000F8373  8AC2              mov al,dl
000F8375  90                nop
000F8376  EE                out dx,al
000F8377  90                nop
000F8378  90                nop
000F8379  EE                out dx,al
000F837A  90                nop
000F837B  90                nop
000F837C  EC                in al,dx
000F837D  3AC2              cmp al,dl
000F837F  7507              jnz 0x8388
000F8381  EC                in al,dx
000F8382  3AC2              cmp al,dl
000F8384  7502              jnz 0x8388
000F8386  FFE6              jmp si
000F8388  B004              mov al,0x4
000F838A  E93414            jmp 0x97c1
000F838D  B0A2              mov al,0xa2
000F838F  BF9503            mov di,0x395
000F8392  E9C9FC            jmp 0x805e
000F8395  33C0              xor ax,ax
000F8397  8ED8              mov ds,ax
000F8399  32C0              xor al,al
000F839B  E661              out 0x61,al
000F839D  BA4300            mov dx,0x43
000F83A0  B0B0              mov al,0xb0
000F83A2  F8                clc
000F83A3  EE                out dx,al
000F83A4  33DB              xor bx,bx
000F83A6  BA4200            mov dx,0x42
000F83A9  8AC3              mov al,bl
000F83AB  EE                out dx,al
000F83AC  EB00              jmp short 0x83ae
000F83AE  EE                out dx,al
000F83AF  8B360004          mov si,[0x400]
000F83B3  EC                in al,dx
000F83B4  3AC3              cmp al,bl
000F83B6  753E              jnz 0x83f6
000F83B8  90                nop
000F83B9  EC                in al,dx
000F83BA  3AC3              cmp al,bl
000F83BC  7538              jnz 0x83f6
000F83BE  F7D3              not bx
000F83C0  0BDB              or bx,bx
000F83C2  75E2              jnz 0x83a6
000F83C4  B078              mov al,0x78
000F83C6  E643              out 0x43,al
000F83C8  BA4100            mov dx,0x41
000F83CB  B07C              mov al,0x7c
000F83CD  F8                clc
000F83CE  EE                out dx,al
000F83CF  B02E              mov al,0x2e
000F83D1  90                nop
000F83D2  90                nop
000F83D3  EE                out dx,al
000F83D4  B9A005            mov cx,0x5a0
000F83D7  90                nop
000F83D8  90                nop
000F83D9  90                nop
000F83DA  B048              mov al,0x48
000F83DC  E643              out 0x43,al
000F83DE  EB00              jmp short 0x83e0
000F83E0  EC                in al,dx
000F83E1  EB00              jmp short 0x83e3
000F83E3  EC                in al,dx
000F83E4  3C2E              cmp al,0x2e
000F83E6  7704              ja 0x83ec
000F83E8  E2F0              loop 0x83da
000F83EA  EB0A              jmp short 0x83f6
000F83EC  81F91005          cmp cx,0x510
000F83F0  7704              ja 0x83f6
000F83F2  890F              mov [bx],cx
000F83F4  EB0B              jmp short 0x8401
000F83F6  890F              mov [bx],cx
000F83F8  B006              mov al,0x6
000F83FA  E9C413            jmp 0x97c1
000F83FD  0F1D2D            hint_nop45 word [di]
000F8400  4D                dec bp
000F8401  B0A4              mov al,0xa4
000F8403  BF0904            mov di,0x409
000F8406  E955FC            jmp 0x805e
000F8409  B0B0              mov al,0xb0
000F840B  E661              out 0x61,al
000F840D  BBFD03            mov bx,0x3fd
000F8410  B90400            mov cx,0x4
000F8413  BA6000            mov dx,0x60
000F8416  2E8A07            mov al,[cs:bx]
000F8419  E664              out 0x64,al
000F841B  EC                in al,dx
000F841C  2E3A07            cmp al,[cs:bx]
000F841F  755F              jnz 0x8480
000F8421  F6D0              not al
000F8423  E664              out 0x64,al
000F8425  EC                in al,dx
000F8426  F6D0              not al
000F8428  348D              xor al,0x8d
000F842A  2E3A07            cmp al,[cs:bx]
000F842D  7551              jnz 0x8480
000F842F  43                inc bx
000F8430  E2E4              loop 0x8416
000F8432  B90400            mov cx,0x4
000F8435  42                inc dx
000F8436  8AC5              mov al,ch
000F8438  BF3E04            mov di,0x43e
000F843B  EB48              jmp short 0x8485
000F843D  90                nop
000F843E  3AC5              cmp al,ch
000F8440  753E              jnz 0x8480
000F8442  F6D0              not al
000F8444  BF4A04            mov di,0x44a
000F8447  EB3C              jmp short 0x8485
000F8449  90                nop
000F844A  341F              xor al,0x1f
000F844C  3AC5              cmp al,ch
000F844E  7530              jnz 0x8480
000F8450  B510              mov ch,0x10
000F8452  0AC0              or al,al
000F8454  74E0              jz 0x8436
000F8456  D0D8              rcr al,1
000F8458  8AE8              mov ch,al
000F845A  73DA              jnc 0x8436
000F845C  B031              mov al,0x31
000F845E  EE                out dx,al
000F845F  B0B0              mov al,0xb0
000F8461  E643              out 0x43,al
000F8463  EB00              jmp short 0x8465
000F8465  E462              in al,0x62
000F8467  2420              and al,0x20
000F8469  7515              jnz 0x8480
000F846B  40                inc ax
000F846C  E642              out 0x42,al
000F846E  EB00              jmp short 0x8470
000F8470  FEC8              dec al
000F8472  E642              out 0x42,al
000F8474  B90600            mov cx,0x6
000F8477  90                nop
000F8478  E2FE              loop 0x8478
000F847A  E462              in al,0x62
000F847C  2420              and al,0x20
000F847E  751D              jnz 0x849d
000F8480  B007              mov al,0x7
000F8482  E93C13            jmp 0x97c1
000F8485  E665              out 0x65,al
000F8487  B030              mov al,0x30
000F8489  EE                out dx,al
000F848A  E462              in al,0x62
000F848C  D2D0              rcl al,cl
000F848E  2410              and al,0x10
000F8490  8AE0              mov ah,al
000F8492  B034              mov al,0x34
000F8494  EE                out dx,al
000F8495  E462              in al,0x62
000F8497  240F              and al,0xf
000F8499  0AC4              or al,ah
000F849B  FFE7              jmp di
000F849D  B0A6              mov al,0xa6
000F849F  BFA504            mov di,0x4a5
000F84A2  E9B9FB            jmp 0x805e
000F84A5  BA7000            mov dx,0x70
000F84A8  B37F              mov bl,0x7f
000F84AA  BEAF04            mov si,0x4af
000F84AD  EB55              jmp short 0x8504
000F84AF  B000              mov al,0x0
000F84B1  BDB704            mov bp,0x4b7
000F84B4  EB7E              jmp short 0x8534
000F84B6  90                nop
000F84B7  8EC0              mov es,ax
000F84B9  B37F              mov bl,0x7f
000F84BB  BEC004            mov si,0x4c0
000F84BE  EB44              jmp short 0x8504
000F84C0  B000              mov al,0x0
000F84C2  BDC704            mov bp,0x4c7
000F84C5  EB6D              jmp short 0x8534
000F84C7  8CC1              mov cx,es
000F84C9  3AC1              cmp al,cl
000F84CB  746D              jz 0x853a
000F84CD  BDD204            mov bp,0x4d2
000F84D0  EB60              jmp short 0x8532
000F84D2  8AC8              mov cl,al
000F84D4  32ED              xor ch,ch
000F84D6  8AE5              mov ah,ch
000F84D8  B014              mov al,0x14
000F84DA  EF                out dx,ax
000F84DB  BDE004            mov bp,0x4e0
000F84DE  EB52              jmp short 0x8532
000F84E0  3AC5              cmp al,ch
000F84E2  7556              jnz 0x853a
000F84E4  F6D0              not al
000F84E6  8AE0              mov ah,al
000F84E8  B014              mov al,0x14
000F84EA  EF                out dx,ax
000F84EB  BDF004            mov bp,0x4f0
000F84EE  EB42              jmp short 0x8532
000F84F0  F6D0              not al
000F84F2  3AC5              cmp al,ch
000F84F4  7544              jnz 0x853a
000F84F6  80FD01            cmp ch,0x1
000F84F9  12ED              adc ch,ch
000F84FB  73D9              jnc 0x84d6
000F84FD  8AE1              mov ah,cl
000F84FF  B014              mov al,0x14
000F8501  EF                out dx,ax
000F8502  EB3B              jmp short 0x853f
000F8504  B00A              mov al,0xa
000F8506  BD0C05            mov bp,0x50c
000F8509  EB29              jmp short 0x8534
000F850B  90                nop
000F850C  8AF8              mov bh,al
000F850E  BF0A00            mov di,0xa
000F8511  33C9              xor cx,cx
000F8513  B00A              mov al,0xa
000F8515  BD1A05            mov bp,0x51a
000F8518  EB1A              jmp short 0x8534
000F851A  32F8              xor bh,al
000F851C  80E780            and bh,0x80
000F851F  8AF8              mov bh,al
000F8521  7406              jz 0x8529
000F8523  32C3              xor al,bl
000F8525  2480              and al,0x80
000F8527  7407              jz 0x8530
000F8529  E2E8              loop 0x8513
000F852B  4F                dec di
000F852C  75E5              jnz 0x8513
000F852E  EB0A              jmp short 0x853a
000F8530  FFE6              jmp si
000F8532  B014              mov al,0x14
000F8534  EE                out dx,al
000F8535  42                inc dx
000F8536  EC                in al,dx
000F8537  4A                dec dx
000F8538  FFE5              jmp bp
000F853A  B008              mov al,0x8
000F853C  E98212            jmp 0x97c1
000F853F  BAFB03            mov dx,0x3fb
000F8542  B09B              mov al,0x9b
000F8544  EE                out dx,al
000F8545  EB00              jmp short 0x8547
000F8547  BAF803            mov dx,0x3f8
000F854A  B00C              mov al,0xc
000F854C  EE                out dx,al
000F854D  EB00              jmp short 0x854f
000F854F  42                inc dx
000F8550  32C0              xor al,al
000F8552  EE                out dx,al
000F8553  EB00              jmp short 0x8555
000F8555  BAFB03            mov dx,0x3fb
000F8558  B01B              mov al,0x1b
000F855A  EE                out dx,al
000F855B  EB00              jmp short 0x855d
000F855D  BAF903            mov dx,0x3f9
000F8560  B000              mov al,0x0
000F8562  EE                out dx,al
000F8563  B96202            mov cx,0x262
000F8566  E2FE              loop 0x8566
000F8568  42                inc dx
000F8569  42                inc dx
000F856A  EC                in al,dx
000F856B  EB00              jmp short 0x856d
000F856D  90                nop
000F856E  BAF803            mov dx,0x3f8
000F8571  EC                in al,dx
000F8572  B341              mov bl,0x41
000F8574  BE7905            mov si,0x579
000F8577  EB05              jmp short 0x857e
000F8579  B343              mov bl,0x43
000F857B  BEC205            mov si,0x5c2
000F857E  33C9              xor cx,cx
000F8580  BAFD03            mov dx,0x3fd
000F8583  EC                in al,dx
000F8584  2420              and al,0x20
000F8586  7505              jnz 0x858d
000F8588  E2F6              loop 0x8580
000F858A  EB31              jmp short 0x85bd
000F858C  90                nop
000F858D  BAF803            mov dx,0x3f8
000F8590  8AC3              mov al,bl
000F8592  EE                out dx,al
000F8593  BAFD03            mov dx,0x3fd
000F8596  B404              mov ah,0x4
000F8598  33C9              xor cx,cx
000F859A  EB00              jmp short 0x859c
000F859C  EC                in al,dx
000F859D  2401              and al,0x1
000F859F  7508              jnz 0x85a9
000F85A1  E2F9              loop 0x859c
000F85A3  FECC              dec ah
000F85A5  75F5              jnz 0x859c
000F85A7  EB14              jmp short 0x85bd
000F85A9  BAF803            mov dx,0x3f8
000F85AC  EC                in al,dx
000F85AD  3AC3              cmp al,bl
000F85AF  750C              jnz 0x85bd
000F85B1  EB00              jmp short 0x85b3
000F85B3  BAFD03            mov dx,0x3fd
000F85B6  EC                in al,dx
000F85B7  240E              and al,0xe
000F85B9  7502              jnz 0x85bd
000F85BB  FFE6              jmp si
000F85BD  B00B              mov al,0xb
000F85BF  E9FF11            jmp 0x97c1
000F85C2  B0A8              mov al,0xa8
000F85C4  BFCA05            mov di,0x5ca
000F85C7  E994FA            jmp 0x805e
000F85CA  BA7A03            mov dx,0x37a
000F85CD  32C0              xor al,al
000F85CF  EE                out dx,al
000F85D0  BA7803            mov dx,0x378
000F85D3  32ED              xor ch,ch
000F85D5  8AC5              mov al,ch
000F85D7  EE                out dx,al
000F85D8  8B3E0004          mov di,[0x400]
000F85DC  EC                in al,dx
000F85DD  3AC5              cmp al,ch
000F85DF  7517              jnz 0x85f8
000F85E1  F6D0              not al
000F85E3  EE                out dx,al
000F85E4  8B3E0004          mov di,[0x400]
000F85E8  EC                in al,dx
000F85E9  F6D0              not al
000F85EB  3AC5              cmp al,ch
000F85ED  7509              jnz 0x85f8
000F85EF  80FD01            cmp ch,0x1
000F85F2  12ED              adc ch,ch
000F85F4  73DF              jnc 0x85d5
000F85F6  EB05              jmp short 0x85fd
000F85F8  B00A              mov al,0xa
000F85FA  E9C411            jmp 0x97c1
000F85FD  BA7800            mov dx,0x78
000F8600  32C0              xor al,al
000F8602  EE                out dx,al
000F8603  EC                in al,dx
000F8604  0AC0              or al,al
000F8606  750D              jnz 0x8615
000F8608  42                inc dx
000F8609  42                inc dx
000F860A  32C0              xor al,al
000F860C  EE                out dx,al
000F860D  EC                in al,dx
000F860E  0AC0              or al,al
000F8610  7503              jnz 0x8615
000F8612  E9CCFB            jmp 0x81e1
000F8615  B00C              mov al,0xc
000F8617  E9A711            jmp 0x97c1
000F861A  BA7903            mov dx,0x379
000F861D  EC                in al,dx
000F861E  33F6              xor si,si
000F8620  B210              mov dl,0x10
000F8622  2407              and al,0x7
000F8624  7472              jz 0x8698
000F8626  B0AA              mov al,0xaa
000F8628  BF2E06            mov di,0x62e
000F862B  E930FA            jmp 0x805e
000F862E  33DB              xor bx,bx
000F8630  B90400            mov cx,0x4
000F8633  B80080            mov ax,0x8000
000F8636  8ED8              mov ds,ax
000F8638  8907              mov [bx],ax
000F863A  050008            add ax,0x800
000F863D  E2F7              loop 0x8636
000F863F  B80080            mov ax,0x8000
000F8642  B90400            mov cx,0x4
000F8645  8ED8              mov ds,ax
000F8647  3907              cmp [bx],ax
000F8649  7505              jnz 0x8650
000F864B  050008            add ax,0x800
000F864E  E2F5              loop 0x8645
000F8650  B103              mov cl,0x3
000F8652  D2CC              ror ah,cl
000F8654  8AD4              mov dl,ah
000F8656  33C0              xor ax,ax
000F8658  8ED8              mov ds,ax
000F865A  8AF2              mov dh,dl
000F865C  8BC8              mov cx,ax
000F865E  890F              mov [bx],cx
000F8660  390F              cmp [bx],cx
000F8662  751E              jnz 0x8682
000F8664  8BC1              mov ax,cx
000F8666  F7D0              not ax
000F8668  8907              mov [bx],ax
000F866A  3907              cmp [bx],ax
000F866C  7514              jnz 0x8682
000F866E  83F901            cmp cx,byte +0x1
000F8671  13C9              adc cx,cx
000F8673  73E9              jnc 0x865e
000F8675  8CD8              mov ax,ds
000F8677  050008            add ax,0x800
000F867A  8ED8              mov ds,ax
000F867C  FECE              dec dh
000F867E  75DE              jnz 0x865e
000F8680  EB05              jmp short 0x8687
000F8682  B001              mov al,0x1
000F8684  E93A11            jmp 0x97c1
000F8687  33C0              xor ax,ax
000F8689  8ED8              mov ds,ax
000F868B  8B2E7204          mov bp,[0x472]
000F868F  33F6              xor si,si
000F8691  81FD3412          cmp bp,0x1234
000F8695  7401              jz 0x8698
000F8697  4E                dec si
000F8698  8AF2              mov dh,dl
000F869A  33C0              xor ax,ax
000F869C  8EC0              mov es,ax
000F869E  8ED8              mov ds,ax
000F86A0  FC                cld
000F86A1  B90040            mov cx,0x4000
000F86A4  33FF              xor di,di
000F86A6  8BC6              mov ax,si
000F86A8  F3AB              rep stosw
000F86AA  8CC0              mov ax,es
000F86AC  050008            add ax,0x800
000F86AF  8EC0              mov es,ax
000F86B1  FECE              dec dh
000F86B3  75EC              jnz 0x86a1
000F86B5  8AE2              mov ah,dl
000F86B7  BA7903            mov dx,0x379
000F86BA  EC                in al,dx
000F86BB  8AD4              mov dl,ah
000F86BD  2407              and al,0x7
000F86BF  740A              jz 0x86cb
000F86C1  81FD3412          cmp bp,0x1234
000F86C5  872E7204          xchg [0x472],bp
000F86C9  7503              jnz 0x86ce
000F86CB  E98000            jmp 0x874e
000F86CE  872E7204          xchg [0x472],bp
000F86D2  8AF2              mov dh,dl
000F86D4  8BFE              mov di,si
000F86D6  F7D7              not di
000F86D8  33C0              xor ax,ax
000F86DA  8ED0              mov ss,ax
000F86DC  B90020            mov cx,0x2000
000F86DF  33E4              xor sp,sp
000F86E1  90                nop
000F86E2  5D                pop bp
000F86E3  33EE              xor bp,si
000F86E5  57                push di
000F86E6  58                pop ax
000F86E7  33C7              xor ax,di
000F86E9  0BE8              or bp,ax
000F86EB  58                pop ax
000F86EC  33C6              xor ax,si
000F86EE  0BE8              or bp,ax
000F86F0  57                push di
000F86F1  58                pop ax
000F86F2  33C7              xor ax,di
000F86F4  0BC5              or ax,bp
000F86F6  E1EA              loope 0x86e2
000F86F8  0BC9              or cx,cx
000F86FA  7586              jnz 0x8682
000F86FC  8CD0              mov ax,ss
000F86FE  050008            add ax,0x800
000F8701  FECE              dec dh
000F8703  75D5              jnz 0x86da
000F8705  87F7              xchg di,si
000F8707  8AF2              mov dh,dl
000F8709  2D0008            sub ax,0x800
000F870C  BB0400            mov bx,0x4
000F870F  8ED0              mov ss,ax
000F8711  BC0280            mov sp,0x8002
000F8714  B90020            mov cx,0x2000
000F8717  90                nop
000F8718  2BE3              sub sp,bx
000F871A  5D                pop bp
000F871B  33EE              xor bp,si
000F871D  57                push di
000F871E  58                pop ax
000F871F  33C7              xor ax,di
000F8721  0BE8              or bp,ax
000F8723  2BE3              sub sp,bx
000F8725  58                pop ax
000F8726  33C6              xor ax,si
000F8728  0BE8              or bp,ax
000F872A  57                push di
000F872B  58                pop ax
000F872C  33C7              xor ax,di
000F872E  0BC5              or ax,bp
000F8730  E1E6              loope 0x8718
000F8732  0BC9              or cx,cx
000F8734  75C4              jnz 0x86fa
000F8736  8CD0              mov ax,ss
000F8738  2D0008            sub ax,0x800
000F873B  FECE              dec dh
000F873D  75D0              jnz 0x870f
000F873F  0BF6              or si,si
000F8741  750B              jnz 0x874e
000F8743  B0AC              mov al,0xac
000F8745  BF4B07            mov di,0x74b
000F8748  E913F9            jmp 0x805e
000F874B  E94AFF            jmp 0x8698
000F874E  B83000            mov ax,0x30
000F8751  8ED0              mov ss,ax
000F8753  BC0001            mov sp,0x100
000F8756  33C0              xor ax,ax
000F8758  8EC0              mov es,ax
000F875A  8ED8              mov ds,ax
000F875C  33C9              xor cx,cx
000F875E  E83D00            call 0x879e
000F8761  E83A00            call 0x879e
000F8764  80FD01            cmp ch,0x1
000F8767  12ED              adc ch,ch
000F8769  73F3              jnc 0x875e
000F876B  FEC5              inc ch
000F876D  33FF              xor di,di
000F876F  FC                cld
000F8770  B89207            mov ax,0x792
000F8773  AB                stosw
000F8774  8CC8              mov ax,cs
000F8776  AB                stosw
000F8777  E2F7              loop 0x8770
000F8779  C70620009707      mov word [0x20],0x797
000F877F  33DB              xor bx,bx
000F8781  B0FE              mov al,0xfe
000F8783  E621              out 0x21,al
000F8785  FB                sti
000F8786  E2FE              loop 0x8786
000F8788  FA                cli
000F8789  B0FF              mov al,0xff
000F878B  E621              out 0x21,al
000F878D  80FB3B            cmp bl,0x3b
000F8790  741D              jz 0x87af
000F8792  B003              mov al,0x3
000F8794  E92A10            jmp 0x97c1
000F8797  B33B              mov bl,0x3b
000F8799  B060              mov al,0x60
000F879B  E620              out 0x20,al
000F879D  CF                iret
000F879E  8AC5              mov al,ch
000F87A0  E621              out 0x21,al
000F87A2  8B1E0004          mov bx,[0x400]
000F87A6  E421              in al,0x21
000F87A8  3AC5              cmp al,ch
000F87AA  75E6              jnz 0x8792
000F87AC  F6D5              not ch
000F87AE  C3                ret
000F87AF  8AC2              mov al,dl
000F87B1  48                dec ax
000F87B2  48                dec ax
000F87B3  E665              out 0x65,al
000F87B5  B105              mov cl,0x5
000F87B7  98                cbw
000F87B8  D3E0              shl ax,cl
000F87BA  A31504            mov [0x415],ax
000F87BD  054000            add ax,0x40
000F87C0  A31304            mov [0x413],ax
000F87C3  E8FE00            call 0x88c4
000F87C6  E81301            call 0x88dc
000F87C9  BEF33E            mov si,0x3ef3
000F87CC  BF0000            mov di,0x0
000F87CF  1E                push ds
000F87D0  8CC8              mov ax,cs
000F87D2  8ED8              mov ds,ax
000F87D4  B91F00            mov cx,0x1f
000F87D7  A5                movsw
000F87D8  AB                stosw
000F87D9  E2FC              loop 0x87d7
000F87DB  33C0              xor ax,ax
000F87DD  B9C201            mov cx,0x1c2
000F87E0  F3AB              rep stosw
000F87E2  1F                pop ds
000F87E3  32DB              xor bl,bl
000F87E5  C7066004FFFF      mov word [0x460],0xffff
000F87EB  9BDBE3            finit
000F87EE  9BDD3E6004        fstsw [0x460]
000F87F3  9BFF066004        wait inc word [0x460]
000F87F8  7402              jz 0x87fc
000F87FA  43                inc bx
000F87FB  43                inc bx
000F87FC  B023              mov al,0x23
000F87FE  E87504            call 0x8c76
000F8801  8AF8              mov bh,al
000F8803  2430              and al,0x30
000F8805  740A              jz 0x8811
000F8807  B80300            mov ax,0x3
000F880A  CD10              int 0x10
000F880C  B80700            mov ax,0x7
000F880F  CD10              int 0x10
000F8811  8AC7              mov al,bh
000F8813  2470              and al,0x70
000F8815  0AC3              or al,bl
000F8817  0C0D              or al,0xd
000F8819  E664              out 0x64,al
000F881B  A21004            mov [0x410],al
000F881E  2430              and al,0x30
000F8820  740E              jz 0x8830
000F8822  3C20              cmp al,0x20
000F8824  770A              ja 0x8830
000F8826  B003              mov al,0x3
000F8828  7402              jz 0x882c
000F882A  48                dec ax
000F882B  48                dec ax
000F882C  B400              mov ah,0x0
000F882E  CD10              int 0x10
000F8830  B0BC              mov al,0xbc
000F8832  E621              out 0x21,al
000F8834  FB                sti
000F8835  B070              mov al,0x70
000F8837  E661              out 0x61,al
000F8839  B040              mov al,0x40
000F883B  E661              out 0x61,al
000F883D  B080              mov al,0x80
000F883F  E6A0              out 0xa0,al
000F8841  B400              mov ah,0x0
000F8843  CD13              int 0x13
000F8845  730D              jnc 0x8854
000F8847  BA7903            mov dx,0x379
000F884A  EC                in al,dx
000F884B  2407              and al,0x7
000F884D  744B              jz 0x889a
000F884F  B005              mov al,0x5
000F8851  E96D0F            jmp 0x97c1
000F8854  32D2              xor dl,dl
000F8856  B50A              mov ch,0xa
000F8858  E84B25            call 0xada6
000F885B  72EA              jc 0x8847
000F885D  B023              mov al,0x23
000F885F  E81404            call 0x8c76
000F8862  7506              jnz 0x886a
000F8864  A840              test al,0x40
000F8866  7432              jz 0x889a
000F8868  32C0              xor al,al
000F886A  9C                pushf
000F886B  B201              mov dl,0x1
000F886D  B50A              mov ch,0xa
000F886F  E83425            call 0xada6
000F8872  730A              jnc 0x887e
000F8874  9D                popf
000F8875  7523              jnz 0x889a
000F8877  80261004BF        and byte [0x410],0xbf
000F887C  EB17              jmp short 0x8895
000F887E  9D                popf
000F887F  7419              jz 0x889a
000F8881  B023              mov al,0x23
000F8883  E8F003            call 0x8c76
000F8886  0C40              or al,0x40
000F8888  8AE0              mov ah,al
000F888A  BA7000            mov dx,0x70
000F888D  B023              mov al,0x23
000F888F  EF                out dx,ax
000F8890  800E100440        or byte [0x410],0x40
000F8895  A01004            mov al,[0x410]
000F8898  E664              out 0x64,al
000F889A  E8AE00            call 0x894b
000F889D  E421              in al,0x21
000F889F  24BC              and al,0xbc
000F88A1  E621              out 0x21,al
000F88A3  E8BF1D            call 0xa665
000F88A6  33C9              xor cx,cx
000F88A8  8ED9              mov ds,cx
000F88AA  8EC1              mov es,cx
000F88AC  B00A              mov al,0xa
000F88AE  E2FE              loop 0x88ae
000F88B0  FEC8              dec al
000F88B2  75FA              jnz 0x88ae
000F88B4  E8F200            call 0x89a9
000F88B7  E89901            call 0x8a53
000F88BA  C70672043412      mov word [0x472],0x1234
000F88C0  CD19              int 0x19
000F88C2  EBF6              jmp short 0x88ba
000F88C4  FC                cld
000F88C5  B81E00            mov ax,0x1e
000F88C8  BF1A04            mov di,0x41a
000F88CB  AB                stosw
000F88CC  AB                stosw
000F88CD  BF8004            mov di,0x480
000F88D0  AB                stosw
000F88D1  052000            add ax,0x20
000F88D4  AB                stosw
000F88D5  C3                ret
000F88D6  BC0378            mov sp,0x7803
000F88D9  037802            add di,[bx+si+0x2]
000F88DC  B142              mov cl,0x42
000F88DE  C7060004F803      mov word [0x400],0x3f8
000F88E4  BAFB02            mov dx,0x2fb
000F88E7  B0AA              mov al,0xaa
000F88E9  EE                out dx,al
000F88EA  EB00              jmp short 0x88ec
000F88EC  EC                in al,dx
000F88ED  3CAA              cmp al,0xaa
000F88EF  7512              jnz 0x8903
000F88F1  F6D0              not al
000F88F3  EE                out dx,al
000F88F4  EB00              jmp short 0x88f6
000F88F6  EC                in al,dx
000F88F7  3C55              cmp al,0x55
000F88F9  7508              jnz 0x8903
000F88FB  C7060204F802      mov word [0x402],0x2f8
000F8901  41                inc cx
000F8902  41                inc cx
000F8903  80E1BF            and cl,0xbf
000F8906  BB0804            mov bx,0x408
000F8909  BFD608            mov di,0x8d6
000F890C  2E8B15            mov dx,[cs:di]
000F890F  B0AA              mov al,0xaa
000F8911  EE                out dx,al
000F8912  EC                in al,dx
000F8913  3CAA              cmp al,0xaa
000F8915  750F              jnz 0x8926
000F8917  F6D0              not al
000F8919  EE                out dx,al
000F891A  EC                in al,dx
000F891B  3C55              cmp al,0x55
000F891D  7507              jnz 0x8926
000F891F  8917              mov [bx],dx
000F8921  43                inc bx
000F8922  43                inc bx
000F8923  80C140            add cl,0x40
000F8926  47                inc di
000F8927  47                inc di
000F8928  81FFDC08          cmp di,0x8dc
000F892C  72DE              jc 0x890c
000F892E  BA0102            mov dx,0x201
000F8931  EC                in al,dx
000F8932  240F              and al,0xf
000F8934  7503              jnz 0x8939
000F8936  80C908            or cl,0x8
000F8939  880E1104          mov [0x411],cl
000F893D  B81414            mov ax,0x1414
000F8940  BF7804            mov di,0x478
000F8943  AB                stosw
000F8944  AB                stosw
000F8945  B80101            mov ax,0x101
000F8948  AB                stosw
000F8949  AB                stosw
000F894A  C3                ret
000F894B  B800C0            mov ax,0xc000
000F894E  8ED8              mov ds,ax
000F8950  058000            add ax,0x80
000F8953  813E000055AA      cmp word [0x0],0xaa55
000F8959  7514              jnz 0x896f
000F895B  1E                push ds
000F895C  0E                push cs
000F895D  E81500            call 0x8975
000F8960  1F                pop ds
000F8961  8A360200          mov dh,[0x2]
000F8965  32D2              xor dl,dl
000F8967  B103              mov cl,0x3
000F8969  D3EA              shr dx,cl
000F896B  8CD8              mov ax,ds
000F896D  03C2              add ax,dx
000F896F  3D00F0            cmp ax,0xf000
000F8972  72DA              jc 0x894e
000F8974  C3                ret
000F8975  1E                push ds
000F8976  8A160200          mov dl,[0x2]
000F897A  32F6              xor dh,dh
000F897C  B90002            mov cx,0x200
000F897F  33DB              xor bx,bx
000F8981  0237              add dh,[bx]
000F8983  43                inc bx
000F8984  E2FB              loop 0x8981
000F8986  8CD8              mov ax,ds
000F8988  052000            add ax,0x20
000F898B  8ED8              mov ds,ax
000F898D  FECA              dec dl
000F898F  75EB              jnz 0x897c
000F8991  1F                pop ds
000F8992  0AF6              or dh,dh
000F8994  7408              jz 0x899e
000F8996  33DB              xor bx,bx
000F8998  B007              mov al,0x7
000F899A  E8E30C            call 0x9680
000F899D  CB                retf
000F899E  1E                push ds
000F899F  BB0300            mov bx,0x3
000F89A2  53                push bx
000F89A3  B84000            mov ax,0x40
000F89A6  8EC0              mov es,ax
000F89A8  CB                retf
000F89A9  8B161304          mov dx,[0x413]
000F89AD  B000              mov al,0x0
000F89AF  E8CE0C            call 0x9680
000F89B2  B014              mov al,0x14
000F89B4  E8BF02            call 0x8c76
000F89B7  7534              jnz 0x89ed
000F89B9  A01004            mov al,[0x410]
000F89BC  2430              and al,0x30
000F89BE  3C10              cmp al,0x10
000F89C0  750A              jnz 0x89cc
000F89C2  B80D0E            mov ax,0xe0d
000F89C5  CD10              int 0x10
000F89C7  B80A0E            mov ax,0xe0a
000F89CA  CD10              int 0x10
000F89CC  B402              mov ah,0x2
000F89CE  CD1A              int 0x1a
000F89D0  51                push cx
000F89D1  B404              mov ah,0x4
000F89D3  CD1A              int 0x1a
000F89D5  87CA              xchg dx,cx
000F89D7  86E9              xchg cl,ch
000F89D9  5B                pop bx
000F89DA  B001              mov al,0x1
000F89DC  E85600            call 0x8a35
000F89DF  813E72043412      cmp word [0x472],0x1234
000F89E5  7521              jnz 0x8a08
000F89E7  B80A0E            mov ax,0xe0a
000F89EA  CD10              int 0x10
000F89EC  C3                ret
000F89ED  B003              mov al,0x3
000F89EF  E88E0C            call 0x9680
000F89F2  B00D              mov al,0xd
000F89F4  E87F02            call 0x8c76
000F89F7  2480              and al,0x80
000F89F9  7505              jnz 0x8a00
000F89FB  B004              mov al,0x4
000F89FD  E8800C            call 0x9680
000F8A00  B300              mov bl,0x0
000F8A02  B81401            mov ax,0x114
000F8A05  CD15              int 0x15
000F8A07  C3                ret
000F8A08  B00E              mov al,0xe
000F8A0A  E86902            call 0x8c76
000F8A0D  8AD8              mov bl,al
000F8A0F  B00F              mov al,0xf
000F8A11  E86202            call 0x8c76
000F8A14  8AF8              mov bh,al
000F8A16  B013              mov al,0x13
000F8A18  E85B02            call 0x8c76
000F8A1B  8AD0              mov dl,al
000F8A1D  B619              mov dh,0x19
000F8A1F  3C80              cmp al,0x80
000F8A21  7302              jnc 0x8a25
000F8A23  B620              mov dh,0x20
000F8A25  B011              mov al,0x11
000F8A27  E84C02            call 0x8c76
000F8A2A  8AE8              mov ch,al
000F8A2C  B012              mov al,0x12
000F8A2E  E84502            call 0x8c76
000F8A31  8AC8              mov cl,al
000F8A33  B002              mov al,0x2
000F8A35  50                push ax
000F8A36  8AE1              mov ah,cl
000F8A38  8AC4              mov al,ah
000F8A3A  B104              mov cl,0x4
000F8A3C  D2C4              rol ah,cl
000F8A3E  250F0F            and ax,0xf0f
000F8A41  D50A              aad
000F8A43  48                dec ax
000F8A44  3C0C              cmp al,0xc
000F8A46  7202              jc 0x8a4a
000F8A48  B000              mov al,0x0
000F8A4A  8AC8              mov cl,al
000F8A4C  80E77F            and bh,0x7f
000F8A4F  58                pop ax
000F8A50  E92D0C            jmp 0x9680
000F8A53  BA7903            mov dx,0x379
000F8A56  EC                in al,dx
000F8A57  2407              and al,0x7
000F8A59  746E              jz 0x8ac9
000F8A5B  B205              mov dl,0x5
000F8A5D  FA                cli
000F8A5E  FF362400          push word [0x24]
000F8A62  FF362600          push word [0x26]
000F8A66  C7062400CA0A      mov word [0x24],0xaca
000F8A6C  8C0E2600          mov [0x26],cs
000F8A70  E461              in al,0x61
000F8A72  50                push ax
000F8A73  24BF              and al,0xbf
000F8A75  0C80              or al,0x80
000F8A77  E661              out 0x61,al
000F8A79  B91027            mov cx,0x2710
000F8A7C  E2FE              loop 0x8a7c
000F8A7E  58                pop ax
000F8A7F  E661              out 0x61,al
000F8A81  BB0A00            mov bx,0xa
000F8A84  FB                sti
000F8A85  0AFF              or bh,bh
000F8A87  7506              jnz 0x8a8f
000F8A89  E2FA              loop 0x8a85
000F8A8B  FECB              dec bl
000F8A8D  75F6              jnz 0x8a85
000F8A8F  FA                cli
000F8A90  8F062600          pop word [0x26]
000F8A94  8F062400          pop word [0x24]
000F8A98  E829FE            call 0x88c4
000F8A9B  C70617040000      mov word [0x417],0x0
000F8AA1  FB                sti
000F8AA2  80FFAA            cmp bh,0xaa
000F8AA5  7412              jz 0x8ab9
000F8AA7  8AC2              mov al,dl
000F8AA9  0AC0              or al,al
000F8AAB  7405              jz 0x8ab2
000F8AAD  E8D00B            call 0x9680
000F8AB0  32D2              xor dl,dl
000F8AB2  B8070E            mov ax,0xe07
000F8AB5  CD10              int 0x10
000F8AB7  EBA4              jmp short 0x8a5d
000F8AB9  B80D0E            mov ax,0xe0d
000F8ABC  CD10              int 0x10
000F8ABE  B95000            mov cx,0x50
000F8AC1  BB0100            mov bx,0x1
000F8AC4  B8200A            mov ax,0xa20
000F8AC7  CD10              int 0x10
000F8AC9  C3                ret
000F8ACA  50                push ax
000F8ACB  E460              in al,0x60
000F8ACD  0AFF              or bh,bh
000F8ACF  B7FF              mov bh,0xff
000F8AD1  7502              jnz 0x8ad5
000F8AD3  8AF8              mov bh,al
000F8AD5  E461              in al,0x61
000F8AD7  0C80              or al,0x80
000F8AD9  E661              out 0x61,al
000F8ADB  247F              and al,0x7f
000F8ADD  E661              out 0x61,al
000F8ADF  B061              mov al,0x61
000F8AE1  E620              out 0x20,al
000F8AE3  58                pop ax
000F8AE4  CF                iret
000F8AE5  33C0              xor ax,ax
000F8AE7  8ED8              mov ds,ax
000F8AE9  8C0E7A00          mov [0x7a],cs
000F8AED  C7067800C72F      mov word [0x78],0x2fc7
000F8AF3  B90A00            mov cx,0xa
000F8AF6  B400              mov ah,0x0
000F8AF8  CD13              int 0x13
000F8AFA  51                push cx
000F8AFB  33D2              xor dx,dx
000F8AFD  BB007C            mov bx,0x7c00
000F8B00  8EC2              mov es,dx
000F8B02  B90100            mov cx,0x1
000F8B05  B80102            mov ax,0x201
000F8B08  CD13              int 0x13
000F8B0A  59                pop cx
000F8B0B  7319              jnc 0x8b26
000F8B0D  D0C4              rol ah,1
000F8B0F  721C              jc 0x8b2d
000F8B11  F6C101            test cl,0x1
000F8B14  740C              jz 0x8b22
000F8B16  51                push cx
000F8B17  33D2              xor dx,dx
000F8B19  B90127            mov cx,0x2701
000F8B1C  B80104            mov ax,0x401
000F8B1F  CD13              int 0x13
000F8B21  59                pop cx
000F8B22  E2D2              loop 0x8af6
000F8B24  EB07              jmp short 0x8b2d
000F8B26  33C0              xor ax,ax
000F8B28  8ED8              mov ds,ax
000F8B2A  06                push es
000F8B2B  53                push bx
000F8B2C  CB                retf
000F8B2D  B006              mov al,0x6
000F8B2F  E84E0B            call 0x9680
000F8B32  33C0              xor ax,ax
000F8B34  8EC0              mov es,ax
000F8B36  E88BFD            call 0x88c4
000F8B39  B400              mov ah,0x0
000F8B3B  CD16              int 0x16
000F8B3D  B80A0E            mov ax,0xe0a
000F8B40  CD10              int 0x10
000F8B42  B80D0E            mov ax,0xe0d
000F8B45  CD10              int 0x10
000F8B47  CD19              int 0x19
000F8B49  016100            add [bx+di+0x0],sp
000F8B4C  800343            add byte [bp+di],0x43
000F8B4F  0034              add [si],dh
000F8B51  74B0              jz 0x8b03
000F8B53  024000            add al,[bx+si+0x0]
000F8B56  0000              add [bx+si],al
000F8B58  024100            add al,[bx+di+0x0]
000F8B5B  1200              adc al,[bx+si]
000F8B5D  024200            add al,[bp+si+0x0]
000F8B60  0100              add [bx+si],ax
000F8B62  010F              add [bx],cx
000F8B64  000F              add [bx],cl
000F8B66  0108              add [bx+si],cx
000F8B68  0000              add [bx+si],al
000F8B6A  010B              add [bp+di],cx
000F8B6C  005801            add [bx+si+0x1],bl
000F8B6F  0C00              or al,0x0
000F8B71  0002              add [bp+si],al
000F8B73  0100              add [bx+si],ax
000F8B75  FF                db 0xff
000F8B76  FF01              inc word [bx+di]
000F8B78  0A00              or al,[bx+si]
000F8B7A  0001              add [bx+di],al
000F8B7C  2000              and [bx+si],al
000F8B7E  1303              adc ax,[bp+di]
000F8B80  2100              and [bx+si],ax
000F8B82  0809              or [bx+di],cl
000F8B84  FF01              inc word [bx+di]
000F8B86  F20300            repne add ax,[bx+si]
000F8B89  01FC              add sp,di
000F8B8B  0300              add ax,[bx+si]
000F8B8D  0000              add [bx+si],al
000F8B8F  0000              add [bx+si],al
000F8B91  0000              add [bx+si],al
000F8B93  0000              add [bx+si],al
000F8B95  0000              add [bx+si],al
000F8B97  0000              add [bx+si],al
000F8B99  0000              add [bx+si],al
000F8B9B  0000              add [bx+si],al
000F8B9D  0000              add [bx+si],al
000F8B9F  008BE558          add [bp+di+0x58e5],cl
000F8BA3  5B                pop bx
000F8BA4  59                pop cx
000F8BA5  5A                pop dx
000F8BA6  1F                pop ds
000F8BA7  07                pop es
000F8BA8  5D                pop bp
000F8BA9  5F                pop di
000F8BAA  5E                pop si
000F8BAB  CA0200            retf 0x2
000F8BAE  FB                sti
000F8BAF  57                push di
000F8BB0  55                push bp
000F8BB1  06                push es
000F8BB2  1E                push ds
000F8BB3  52                push dx
000F8BB4  51                push cx
000F8BB5  53                push bx
000F8BB6  50                push ax
000F8BB7  33DB              xor bx,bx
000F8BB9  8EDB              mov ds,bx
000F8BBB  8BEC              mov bp,sp
000F8BBD  877610            xchg [bp+0x10],si
000F8BC0  FFD6              call si
000F8BC2  8BE5              mov sp,bp
000F8BC4  58                pop ax
000F8BC5  5B                pop bx
000F8BC6  59                pop cx
000F8BC7  5A                pop dx
000F8BC8  1F                pop ds
000F8BC9  07                pop es
000F8BCA  5D                pop bp
000F8BCB  5F                pop di
000F8BCC  5E                pop si
000F8BCD  CF                iret
000F8BCE  1E                push ds
000F8BCF  33C0              xor ax,ax
000F8BD1  8ED8              mov ds,ax
000F8BD3  A11304            mov ax,[0x413]
000F8BD6  1F                pop ds
000F8BD7  CF                iret
000F8BD8  1E                push ds
000F8BD9  33C0              xor ax,ax
000F8BDB  8ED8              mov ds,ax
000F8BDD  A11004            mov ax,[0x410]
000F8BE0  1F                pop ds
000F8BE1  CF                iret
000F8BE2  E8C9FF            call 0x8bae
000F8BE5  80FC07            cmp ah,0x7
000F8BE8  F5                cmc
000F8BE9  720C              jc 0x8bf7
000F8BEB  02E4              add ah,ah
000F8BED  86DC              xchg ah,bl
000F8BEF  32FF              xor bh,bh
000F8BF1  2EFF97FC0B        call [cs:bx+0xbfc]
000F8BF6  F8                clc
000F8BF7  9F                lahf
000F8BF8  886616            mov [bp+0x16],ah
000F8BFB  C3                ret
000F8BFC  0A0C              or cl,[si]
000F8BFE  2D0C61            sub ax,0x610c
000F8C01  0CC7              or al,0xc7
000F8C03  0CCC              or al,0xcc
000F8C05  0CD1              or al,0xd1
000F8C07  0C64              or al,0x64
000F8C09  18FA              sbb dl,bh
000F8C0B  BA7800            mov dx,0x78
000F8C0E  E80D00            call 0x8c1e
000F8C11  894604            mov [bp+0x4],ax
000F8C14  42                inc dx
000F8C15  42                inc dx
000F8C16  E80500            call 0x8c1e
000F8C19  894606            mov [bp+0x6],ax
000F8C1C  FB                sti
000F8C1D  C3                ret
000F8C1E  EC                in al,dx
000F8C1F  8AE0              mov ah,al
000F8C21  EC                in al,dx
000F8C22  3AC4              cmp al,ah
000F8C24  75F8              jnz 0x8c1e
000F8C26  98                cbw
000F8C27  50                push ax
000F8C28  32C0              xor al,al
000F8C2A  EE                out dx,al
000F8C2B  58                pop ax
000F8C2C  C3                ret
000F8C2D  3C40              cmp al,0x40
000F8C2F  7205              jc 0x8c36
000F8C31  C6460101          mov byte [bp+0x1],0x1
000F8C35  C3                ret
000F8C36  8A6602            mov ah,[bp+0x2]
000F8C39  BA7000            mov dx,0x70
000F8C3C  EF                out dx,ax
000F8C3D  3C14              cmp al,0x14
000F8C3F  720C              jc 0x8c4d
000F8C41  50                push ax
000F8C42  BB470C            mov bx,0xc47
000F8C45  EB42              jmp short 0x8c89
000F8C47  8AE1              mov ah,cl
000F8C49  B014              mov al,0x14
000F8C4B  EF                out dx,ax
000F8C4C  58                pop ax
000F8C4D  3C0E              cmp al,0xe
000F8C4F  7209              jc 0x8c5a
000F8C51  E86D00            call 0x8cc1
000F8C54  2AE0              sub ah,al
000F8C56  B402              mov ah,0x2
000F8C58  7502              jnz 0x8c5c
000F8C5A  32E4              xor ah,ah
000F8C5C  886601            mov [bp+0x1],ah
000F8C5F  FB                sti
000F8C60  C3                ret
000F8C61  3C40              cmp al,0x40
000F8C63  7205              jc 0x8c6a
000F8C65  C6460101          mov byte [bp+0x1],0x1
000F8C69  C3                ret
000F8C6A  E80900            call 0x8c76
000F8C6D  7402              jz 0x8c71
000F8C6F  B402              mov ah,0x2
000F8C71  894600            mov [bp+0x0],ax
000F8C74  FB                sti
000F8C75  C3                ret
000F8C76  52                push dx
000F8C77  51                push cx
000F8C78  53                push bx
000F8C79  E80400            call 0x8c80
000F8C7C  5B                pop bx
000F8C7D  59                pop cx
000F8C7E  5A                pop dx
000F8C7F  C3                ret
000F8C80  5B                pop bx
000F8C81  FA                cli
000F8C82  BA7000            mov dx,0x70
000F8C85  EE                out dx,al
000F8C86  42                inc dx
000F8C87  EC                in al,dx
000F8C88  4A                dec dx
000F8C89  8AC8              mov cl,al
000F8C8B  32E4              xor ah,ah
000F8C8D  B53F              mov ch,0x3f
000F8C8F  8AC5              mov al,ch
000F8C91  EE                out dx,al
000F8C92  42                inc dx
000F8C93  EC                in al,dx
000F8C94  4A                dec dx
000F8C95  02E0              add ah,al
000F8C97  FECD              dec ch
000F8C99  80FD14            cmp ch,0x14
000F8C9C  73F1              jnc 0x8c8f
000F8C9E  8AEC              mov ch,ah
000F8CA0  2AE8              sub ch,al
000F8CA2  B0AA              mov al,0xaa
000F8CA4  2AC5              sub al,ch
000F8CA6  86C1              xchg cl,al
000F8CA8  80ECAA            sub ah,0xaa
000F8CAB  FFE3              jmp bx
000F8CAD  52                push dx
000F8CAE  8AE0              mov ah,al
000F8CB0  E80B00            call 0x8cbe
000F8CB3  86E0              xchg al,ah
000F8CB5  FEC0              inc al
000F8CB7  E80700            call 0x8cc1
000F8CBA  86E0              xchg al,ah
000F8CBC  5A                pop dx
000F8CBD  C3                ret
000F8CBE  BA7000            mov dx,0x70
000F8CC1  FA                cli
000F8CC2  EE                out dx,al
000F8CC3  42                inc dx
000F8CC4  EC                in al,dx
000F8CC5  4A                dec dx
000F8CC6  C3                ret
000F8CC7  BADD03            mov dx,0x3dd
000F8CCA  EE                out dx,al
000F8CCB  C3                ret
000F8CCC  BADE03            mov dx,0x3de
000F8CCF  EE                out dx,al
000F8CD0  C3                ret
000F8CD1  BADF03            mov dx,0x3df
000F8CD4  EE                out dx,al
000F8CD5  C3                ret
000F8CD6  E8D5FE            call 0x8bae
000F8CD9  80FC08            cmp ah,0x8
000F8CDC  730B              jnc 0x8ce9
000F8CDE  02E4              add ah,ah
000F8CE0  8ADC              mov bl,ah
000F8CE2  32FF              xor bh,bh
000F8CE4  2EFFA7EA0C        jmp [cs:bx+0xcea]
000F8CE9  C3                ret
000F8CEA  FA                cli
000F8CEB  0C14              or al,0x14
000F8CED  0DDF0D            or ax,0xddf
000F8CF0  B20D              mov dl,0xd
000F8CF2  390EFE0D          cmp [0xdfe],cx
000F8CF6  60                pusha
000F8CF7  0E                push cs
000F8CF8  860EFAA1          xchg [0xa1fa],cl
000F8CFC  6E                outsb
000F8CFD  0489              add al,0x89
000F8CFF  46                inc si
000F8D00  04A1              add al,0xa1
000F8D02  6C                insb
000F8D03  0489              add al,0x89
000F8D05  46                inc si
000F8D06  06                push es
000F8D07  32C0              xor al,al
000F8D09  86067004          xchg [0x470],al
000F8D0D  2401              and al,0x1
000F8D0F  884600            mov [bp+0x0],al
000F8D12  FB                sti
000F8D13  C3                ret
000F8D14  FA                cli
000F8D15  890E6E04          mov [0x46e],cx
000F8D19  89166C04          mov [0x46c],dx
000F8D1D  C606700400        mov byte [0x470],0x0
000F8D22  FB                sti
000F8D23  C3                ret
000F8D24  1E                push ds
000F8D25  52                push dx
000F8D26  50                push ax
000F8D27  33C0              xor ax,ax
000F8D29  8ED8              mov ds,ax
000F8D2B  FB                sti
000F8D2C  FE0E4004          dec byte [0x440]
000F8D30  750B              jnz 0x8d3d
000F8D32  C6063F0400        mov byte [0x43f],0x0
000F8D37  BAF203            mov dx,0x3f2
000F8D3A  B00C              mov al,0xc
000F8D3C  EE                out dx,al
000F8D3D  FF066C04          inc word [0x46c]
000F8D41  7504              jnz 0x8d47
000F8D43  FF066E04          inc word [0x46e]
000F8D47  813E6C04B000      cmp word [0x46c],0xb0
000F8D4D  7514              jnz 0x8d63
000F8D4F  833E6E0418        cmp word [0x46e],byte +0x18
000F8D54  750D              jnz 0x8d63
000F8D56  C6067004FF        mov byte [0x470],0xff
000F8D5B  33C0              xor ax,ax
000F8D5D  A36C04            mov [0x46c],ax
000F8D60  A36E04            mov [0x46e],ax
000F8D63  F6066C04FF        test byte [0x46c],0xff
000F8D68  7503              jnz 0x8d6d
000F8D6A  E80F00            call 0x8d7c
000F8D6D  B84000            mov ax,0x40
000F8D70  8ED8              mov ds,ax
000F8D72  CD1C              int 0x1c
000F8D74  B060              mov al,0x60
000F8D76  E620              out 0x20,al
000F8D78  58                pop ax
000F8D79  5A                pop dx
000F8D7A  1F                pop ds
000F8D7B  CF                iret
000F8D7C  53                push bx
000F8D7D  BA7000            mov dx,0x70
000F8D80  E81901            call 0x8e9c
000F8D83  B402              mov ah,0x2
000F8D85  B30E              mov bl,0xe
000F8D87  E81500            call 0x8d9f
000F8D8A  80C402            add ah,0x2
000F8D8D  E80F00            call 0x8d9f
000F8D90  80C402            add ah,0x2
000F8D93  E80900            call 0x8d9f
000F8D96  FEC4              inc ah
000F8D98  80FC0A            cmp ah,0xa
000F8D9B  72F6              jc 0x8d93
000F8D9D  5B                pop bx
000F8D9E  C3                ret
000F8D9F  8AC4              mov al,ah
000F8DA1  EE                out dx,al
000F8DA2  42                inc dx
000F8DA3  EC                in al,dx
000F8DA4  8AF8              mov bh,al
000F8DA6  4A                dec dx
000F8DA7  8AC3              mov al,bl
000F8DA9  EE                out dx,al
000F8DAA  42                inc dx
000F8DAB  8AC7              mov al,bh
000F8DAD  EE                out dx,al
000F8DAE  4A                dec dx
000F8DAF  FEC3              inc bl
000F8DB1  C3                ret
000F8DB2  E86E00            call 0x8e23
000F8DB5  8A6606            mov ah,[bp+0x6]
000F8DB8  80E401            and ah,0x1
000F8DBB  80CC02            or ah,0x2
000F8DBE  8ADC              mov bl,ah
000F8DC0  B00B              mov al,0xb
000F8DC2  EF                out dx,ax
000F8DC3  B004              mov al,0x4
000F8DC5  8AE5              mov ah,ch
000F8DC7  EF                out dx,ax
000F8DC8  B002              mov al,0x2
000F8DCA  8AE1              mov ah,cl
000F8DCC  EF                out dx,ax
000F8DCD  B000              mov al,0x0
000F8DCF  8A6607            mov ah,[bp+0x7]
000F8DD2  EF                out dx,ax
000F8DD3  B80A20            mov ax,0x200a
000F8DD6  EF                out dx,ax
000F8DD7  B80B7F            mov ax,0x7f0b
000F8DDA  22E3              and ah,bl
000F8DDC  EF                out dx,ax
000F8DDD  EB3A              jmp short 0x8e19
000F8DDF  E8BA00            call 0x8e9c
000F8DE2  7239              jc 0x8e1d
000F8DE4  B004              mov al,0x4
000F8DE6  E8D8FE            call 0x8cc1
000F8DE9  884605            mov [bp+0x5],al
000F8DEC  B002              mov al,0x2
000F8DEE  E8D0FE            call 0x8cc1
000F8DF1  884604            mov [bp+0x4],al
000F8DF4  B000              mov al,0x0
000F8DF6  E8C8FE            call 0x8cc1
000F8DF9  884607            mov [bp+0x7],al
000F8DFC  EB1E              jmp short 0x8e1c
000F8DFE  E89B00            call 0x8e9c
000F8E01  721A              jc 0x8e1d
000F8E03  B009              mov al,0x9
000F8E05  8AE1              mov ah,cl
000F8E07  EF                out dx,ax
000F8E08  B008              mov al,0x8
000F8E0A  8A6607            mov ah,[bp+0x7]
000F8E0D  EF                out dx,ax
000F8E0E  B007              mov al,0x7
000F8E10  8A6606            mov ah,[bp+0x6]
000F8E13  EF                out dx,ax
000F8E14  B006              mov al,0x6
000F8E16  32E4              xor ah,ah
000F8E18  EF                out dx,ax
000F8E19  E860FF            call 0x8d7c
000F8E1C  F8                clc
000F8E1D  9F                lahf
000F8E1E  886616            mov [bp+0x16],ah
000F8E21  FB                sti
000F8E22  C3                ret
000F8E23  BA7000            mov dx,0x70
000F8E26  B00B              mov al,0xb
000F8E28  E896FE            call 0x8cc1
000F8E2B  0C80              or al,0x80
000F8E2D  8AD8              mov bl,al
000F8E2F  8AE0              mov ah,al
000F8E31  B00B              mov al,0xb
000F8E33  EF                out dx,ax
000F8E34  B80A70            mov ax,0x700a
000F8E37  EF                out dx,ax
000F8E38  C3                ret
000F8E39  E86000            call 0x8e9c
000F8E3C  72DF              jc 0x8e1d
000F8E3E  B009              mov al,0x9
000F8E40  E87EFE            call 0x8cc1
000F8E43  B419              mov ah,0x19
000F8E45  3C80              cmp al,0x80
000F8E47  7302              jnc 0x8e4b
000F8E49  B420              mov ah,0x20
000F8E4B  894604            mov [bp+0x4],ax
000F8E4E  B008              mov al,0x8
000F8E50  E86EFE            call 0x8cc1
000F8E53  884607            mov [bp+0x7],al
000F8E56  B007              mov al,0x7
000F8E58  E866FE            call 0x8cc1
000F8E5B  884606            mov [bp+0x6],al
000F8E5E  EBBC              jmp short 0x8e1c
000F8E60  E83900            call 0x8e9c
000F8E63  72B8              jc 0x8e1d
000F8E65  B00B              mov al,0xb
000F8E67  E857FE            call 0x8cc1
000F8E6A  2420              and al,0x20
000F8E6C  7403              jz 0x8e71
000F8E6E  F9                stc
000F8E6F  EBAC              jmp short 0x8e1d
000F8E71  B005              mov al,0x5
000F8E73  8AE5              mov ah,ch
000F8E75  EF                out dx,ax
000F8E76  B003              mov al,0x3
000F8E78  8AE1              mov ah,cl
000F8E7A  EF                out dx,ax
000F8E7B  B001              mov al,0x1
000F8E7D  8A6607            mov ah,[bp+0x7]
000F8E80  EF                out dx,ax
000F8E81  BB2000            mov bx,0x20
000F8E84  EB03              jmp short 0x8e89
000F8E86  BB00DF            mov bx,0xdf00
000F8E89  BA7000            mov dx,0x70
000F8E8C  B00B              mov al,0xb
000F8E8E  E830FE            call 0x8cc1
000F8E91  22C7              and al,bh
000F8E93  0AC3              or al,bl
000F8E95  8AE0              mov ah,al
000F8E97  B00B              mov al,0xb
000F8E99  EF                out dx,ax
000F8E9A  EB80              jmp short 0x8e1c
000F8E9C  51                push cx
000F8E9D  B90000            mov cx,0x0
000F8EA0  BA7000            mov dx,0x70
000F8EA3  FA                cli
000F8EA4  B00A              mov al,0xa
000F8EA6  EE                out dx,al
000F8EA7  42                inc dx
000F8EA8  EC                in al,dx
000F8EA9  4A                dec dx
000F8EAA  D0D0              rcl al,1
000F8EAC  7303              jnc 0x8eb1
000F8EAE  E2F4              loop 0x8ea4
000F8EB0  F9                stc
000F8EB1  59                pop cx
000F8EB2  C3                ret
000F8EB3  E8F8FC            call 0x8bae
000F8EB6  8BDA              mov bx,dx
000F8EB8  03DB              add bx,bx
000F8EBA  8B970804          mov dx,[bx+0x408]
000F8EBE  0BD2              or dx,dx
000F8EC0  7416              jz 0x8ed8
000F8EC2  80FC03            cmp ah,0x3
000F8EC5  730B              jnc 0x8ed2
000F8EC7  02E4              add ah,ah
000F8EC9  8ADC              mov bl,ah
000F8ECB  32FF              xor bh,bh
000F8ECD  2EFFA7D90E        jmp [cs:bx+0xed9]
000F8ED2  80EC02            sub ah,0x2
000F8ED5  886601            mov [bp+0x1],ah
000F8ED8  C3                ret
000F8ED9  DF0E140F          fisttp word [0xf14]
000F8EDD  2A0F              sub cl,[bx]
000F8EDF  8B5E06            mov bx,[bp+0x6]
000F8EE2  8A9F7804          mov bl,[bx+0x478]
000F8EE6  03DB              add bx,bx
000F8EE8  03DB              add bx,bx
000F8EEA  42                inc dx
000F8EEB  B9BEEC            mov cx,0xecbe
000F8EEE  EC                in al,dx
000F8EEF  2480              and al,0x80
000F8EF1  750D              jnz 0x8f00
000F8EF3  E2F9              loop 0x8eee
000F8EF5  4B                dec bx
000F8EF6  75F3              jnz 0x8eeb
000F8EF8  E83000            call 0x8f2b
000F8EFB  804E0101          or byte [bp+0x1],0x1
000F8EFF  C3                ret
000F8F00  8A4600            mov al,[bp+0x0]
000F8F03  4A                dec dx
000F8F04  EE                out dx,al
000F8F05  42                inc dx
000F8F06  42                inc dx
000F8F07  B00D              mov al,0xd
000F8F09  EE                out dx,al
000F8F0A  50                push ax
000F8F0B  50                push ax
000F8F0C  58                pop ax
000F8F0D  58                pop ax
000F8F0E  B00C              mov al,0xc
000F8F10  EE                out dx,al
000F8F11  4A                dec dx
000F8F12  EB17              jmp short 0x8f2b
000F8F14  42                inc dx
000F8F15  42                inc dx
000F8F16  B008              mov al,0x8
000F8F18  EE                out dx,al
000F8F19  B004              mov al,0x4
000F8F1B  B93FF7            mov cx,0xf73f
000F8F1E  E2FE              loop 0x8f1e
000F8F20  FEC8              dec al
000F8F22  75F7              jnz 0x8f1b
000F8F24  B00C              mov al,0xc
000F8F26  EE                out dx,al
000F8F27  4A                dec dx
000F8F28  EB01              jmp short 0x8f2b
000F8F2A  42                inc dx
000F8F2B  EC                in al,dx
000F8F2C  24F8              and al,0xf8
000F8F2E  3448              xor al,0x48
000F8F30  884601            mov [bp+0x1],al
000F8F33  C3                ret
000F8F34  FB                sti
000F8F35  1E                push ds
000F8F36  52                push dx
000F8F37  51                push cx
000F8F38  53                push bx
000F8F39  50                push ax
000F8F3A  33C0              xor ax,ax
000F8F3C  8ED8              mov ds,ax
000F8F3E  803E000501        cmp byte [0x500],0x1
000F8F43  7453              jz 0x8f98
000F8F45  C606000501        mov byte [0x500],0x1
000F8F4A  B40F              mov ah,0xf
000F8F4C  CD10              int 0x10
000F8F4E  8ADC              mov bl,ah
000F8F50  B403              mov ah,0x3
000F8F52  CD10              int 0x10
000F8F54  52                push dx
000F8F55  32F6              xor dh,dh
000F8F57  B00D              mov al,0xd
000F8F59  E84200            call 0x8f9e
000F8F5C  7530              jnz 0x8f8e
000F8F5E  B00A              mov al,0xa
000F8F60  E83B00            call 0x8f9e
000F8F63  7529              jnz 0x8f8e
000F8F65  32D2              xor dl,dl
000F8F67  B402              mov ah,0x2
000F8F69  CD10              int 0x10
000F8F6B  B408              mov ah,0x8
000F8F6D  CD10              int 0x10
000F8F6F  0AC0              or al,al
000F8F71  7502              jnz 0x8f75
000F8F73  B020              mov al,0x20
000F8F75  E82600            call 0x8f9e
000F8F78  7514              jnz 0x8f8e
000F8F7A  FEC2              inc dl
000F8F7C  3AD3              cmp dl,bl
000F8F7E  72E7              jc 0x8f67
000F8F80  FEC6              inc dh
000F8F82  80FE19            cmp dh,0x19
000F8F85  72D0              jc 0x8f57
000F8F87  C606000500        mov byte [0x500],0x0
000F8F8C  EB05              jmp short 0x8f93
000F8F8E  C6060005FF        mov byte [0x500],0xff
000F8F93  5A                pop dx
000F8F94  B402              mov ah,0x2
000F8F96  CD10              int 0x10
000F8F98  58                pop ax
000F8F99  5B                pop bx
000F8F9A  59                pop cx
000F8F9B  5A                pop dx
000F8F9C  1F                pop ds
000F8F9D  CF                iret
000F8F9E  8BCA              mov cx,dx
000F8FA0  33D2              xor dx,dx
000F8FA2  B400              mov ah,0x0
000F8FA4  CD17              int 0x17
000F8FA6  F6C401            test ah,0x1
000F8FA9  8BD1              mov dx,cx
000F8FAB  C3                ret
000F8FAC  E8FFFB            call 0x8bae
000F8FAF  8BDA              mov bx,dx
000F8FB1  03DB              add bx,bx
000F8FB3  8B970004          mov dx,[bx+0x400]
000F8FB7  0BD2              or dx,dx
000F8FB9  7416              jz 0x8fd1
000F8FBB  80FC04            cmp ah,0x4
000F8FBE  730B              jnc 0x8fcb
000F8FC0  02E4              add ah,ah
000F8FC2  8ADC              mov bl,ah
000F8FC4  32FF              xor bh,bh
000F8FC6  2EFFA7D20F        jmp [cs:bx+0xfd2]
000F8FCB  80EC03            sub ah,0x3
000F8FCE  886601            mov [bp+0x1],ah
000F8FD1  C3                ret
000F8FD2  DA0F              fimul dword [bx]
000F8FD4  47                inc di
000F8FD5  1089102A          adc [bx+di+0x2a10],cl
000F8FD9  1024              adc [si],ah
000F8FDB  1F                pop ds
000F8FDC  8AC8              mov cl,al
000F8FDE  0C80              or al,0x80
000F8FE0  83C203            add dx,byte +0x3
000F8FE3  EE                out dx,al
000F8FE4  8A4600            mov al,[bp+0x0]
000F8FE7  24E0              and al,0xe0
000F8FE9  D0C0              rol al,1
000F8FEB  D0C0              rol al,1
000F8FED  D0C0              rol al,1
000F8FEF  32E4              xor ah,ah
000F8FF1  03C0              add ax,ax
000F8FF3  8BD8              mov bx,ax
000F8FF5  2E8A873710        mov al,[cs:bx+0x1037]
000F8FFA  83EA03            sub dx,byte +0x3
000F8FFD  EE                out dx,al
000F8FFE  42                inc dx
000F8FFF  2E8A873810        mov al,[cs:bx+0x1038]
000F9004  EE                out dx,al
000F9005  EB00              jmp short 0x9007
000F9007  42                inc dx
000F9008  42                inc dx
000F9009  8AC1              mov al,cl
000F900B  EE                out dx,al
000F900C  42                inc dx
000F900D  E8C600            call 0x90d6
000F9010  7305              jnc 0x9017
000F9012  B002              mov al,0x2
000F9014  EE                out dx,al
000F9015  EB00              jmp short 0x9017
000F9017  42                inc dx
000F9018  EC                in al,dx
000F9019  EB00              jmp short 0x901b
000F901B  42                inc dx
000F901C  EC                in al,dx
000F901D  EB00              jmp short 0x901f
000F901F  83EA06            sub dx,byte +0x6
000F9022  EC                in al,dx
000F9023  EB00              jmp short 0x9025
000F9025  42                inc dx
000F9026  32C0              xor al,al
000F9028  EE                out dx,al
000F9029  4A                dec dx
000F902A  83C206            add dx,byte +0x6
000F902D  EC                in al,dx
000F902E  884600            mov [bp+0x0],al
000F9031  4A                dec dx
000F9032  EC                in al,dx
000F9033  884601            mov [bp+0x1],al
000F9036  C3                ret
000F9037  17                pop ss
000F9038  0400              add al,0x0
000F903A  038001C0          add ax,[bx+si-0x3fff]
000F903E  006000            add [bx+si+0x0],ah
000F9041  3000              xor [bx+si],al
000F9043  1800              sbb [bx+si],al
000F9045  0C00              or al,0x0
000F9047  83C204            add dx,byte +0x4
000F904A  E88900            call 0x90d6
000F904D  B80210            mov ax,0x1002
000F9050  7203              jc 0x9055
000F9052  0D0120            or ax,0x2001
000F9055  EE                out dx,al
000F9056  42                inc dx
000F9057  42                inc dx
000F9058  E88600            call 0x90e1
000F905B  EC                in al,dx
000F905C  22C4              and al,ah
000F905E  3AC4              cmp al,ah
000F9060  7407              jz 0x9069
000F9062  E2F7              loop 0x905b
000F9064  4B                dec bx
000F9065  75F4              jnz 0x905b
000F9067  EB0D              jmp short 0x9076
000F9069  4A                dec dx
000F906A  EC                in al,dx
000F906B  2420              and al,0x20
000F906D  90                nop
000F906E  750E              jnz 0x907e
000F9070  E2F8              loop 0x906a
000F9072  4B                dec bx
000F9073  75F5              jnz 0x906a
000F9075  42                inc dx
000F9076  E8B9FF            call 0x9032
000F9079  804E0180          or byte [bp+0x1],0x80
000F907D  C3                ret
000F907E  8A4600            mov al,[bp+0x0]
000F9081  52                push dx
000F9082  83EA05            sub dx,byte +0x5
000F9085  EE                out dx,al
000F9086  5A                pop dx
000F9087  EBA9              jmp short 0x9032
000F9089  83C204            add dx,byte +0x4
000F908C  EC                in al,dx
000F908D  EB00              jmp short 0x908f
000F908F  0C01              or al,0x1
000F9091  EE                out dx,al
000F9092  42                inc dx
000F9093  42                inc dx
000F9094  E84A00            call 0x90e1
000F9097  EC                in al,dx
000F9098  2420              and al,0x20
000F909A  90                nop
000F909B  7507              jnz 0x90a4
000F909D  E2F8              loop 0x9097
000F909F  4B                dec bx
000F90A0  75F5              jnz 0x9097
000F90A2  EB0D              jmp short 0x90b1
000F90A4  4A                dec dx
000F90A5  EC                in al,dx
000F90A6  2401              and al,0x1
000F90A8  90                nop
000F90A9  750E              jnz 0x90b9
000F90AB  E2F8              loop 0x90a5
000F90AD  4B                dec bx
000F90AE  75F5              jnz 0x90a5
000F90B0  42                inc dx
000F90B1  E87EFF            call 0x9032
000F90B4  804E0180          or byte [bp+0x1],0x80
000F90B8  C3                ret
000F90B9  4A                dec dx
000F90BA  E81900            call 0x90d6
000F90BD  7305              jnc 0x90c4
000F90BF  B002              mov al,0x2
000F90C1  EE                out dx,al
000F90C2  EB00              jmp short 0x90c4
000F90C4  83EA04            sub dx,byte +0x4
000F90C7  EC                in al,dx
000F90C8  884600            mov [bp+0x0],al
000F90CB  83C205            add dx,byte +0x5
000F90CE  E861FF            call 0x9032
000F90D1  8066011E          and byte [bp+0x1],0x1e
000F90D5  C3                ret
000F90D6  52                push dx
000F90D7  B023              mov al,0x23
000F90D9  E8E2FB            call 0x8cbe
000F90DC  FB                sti
000F90DD  5A                pop dx
000F90DE  D0D0              rcl al,1
000F90E0  C3                ret
000F90E1  8B5E06            mov bx,[bp+0x6]
000F90E4  8A9F7C04          mov bl,[bx+0x47c]
000F90E8  32FF              xor bh,bh
000F90EA  8BCB              mov cx,bx
000F90EC  D1E3              shl bx,1
000F90EE  03D9              add bx,cx
000F90F0  33C9              xor cx,cx
000F90F2  C3                ret
000F90F3  0000              add [bx+si],al
000F90F5  0000              add [bx+si],al
000F90F7  0000              add [bx+si],al
000F90F9  0000              add [bx+si],al
000F90FB  0000              add [bx+si],al
000F90FD  0000              add [bx+si],al
000F90FF  00E8              add al,ch
000F9101  AB                stosw
000F9102  FA                cli
000F9103  80FC03            cmp ah,0x3
000F9106  7207              jc 0x910f
000F9108  80EC02            sub ah,0x2
000F910B  886601            mov [bp+0x1],ah
000F910E  C3                ret
000F910F  8ADC              mov bl,ah
000F9111  32FF              xor bh,bh
000F9113  03DB              add bx,bx
000F9115  2EFFA71A11        jmp [cs:bx+0x111a]
000F911A  2011              and [bx+di],dl
000F911C  3811              cmp [bx+di],dl
000F911E  56                push si
000F911F  11FB              adc bx,di
000F9121  E81B00            call 0x913f
000F9124  74FA              jz 0x9120
000F9126  43                inc bx
000F9127  43                inc bx
000F9128  3B1E8204          cmp bx,[0x482]
000F912C  7204              jc 0x9132
000F912E  8B1E8004          mov bx,[0x480]
000F9132  891E1A04          mov [0x41a],bx
000F9136  FB                sti
000F9137  C3                ret
000F9138  E80400            call 0x913f
000F913B  FB                sti
000F913C  E961FA            jmp 0x8ba0
000F913F  FA                cli
000F9140  8B1E1A04          mov bx,[0x41a]
000F9144  3B1E1C04          cmp bx,[0x41c]
000F9148  740B              jz 0x9155
000F914A  B84000            mov ax,0x40
000F914D  8EC0              mov es,ax
000F914F  268B07            mov ax,[es:bx]
000F9152  894600            mov [bp+0x0],ax
000F9155  C3                ret
000F9156  A01704            mov al,[0x417]
000F9159  32E4              xor ah,ah
000F915B  894600            mov [bp+0x0],ax
000F915E  C3                ret
000F915F  1E                push ds
000F9160  52                push dx
000F9161  51                push cx
000F9162  53                push bx
000F9163  50                push ax
000F9164  E460              in al,0x60
000F9166  8AE0              mov ah,al
000F9168  E461              in al,0x61
000F916A  0C80              or al,0x80
000F916C  E661              out 0x61,al
000F916E  247F              and al,0x7f
000F9170  E661              out 0x61,al
000F9172  8AD4              mov dl,ah
000F9174  33C0              xor ax,ax
000F9176  8ED8              mov ds,ax
000F9178  E80A00            call 0x9185
000F917B  B061              mov al,0x61
000F917D  E620              out 0x20,al
000F917F  58                pop ax
000F9180  5B                pop bx
000F9181  59                pop cx
000F9182  5A                pop dx
000F9183  1F                pop ds
000F9184  CF                iret
000F9185  8AC2              mov al,dl
000F9187  247F              and al,0x7f
000F9189  3C54              cmp al,0x54
000F918B  724F              jc 0x91dc
000F918D  F6C280            test dl,0x80
000F9190  7507              jnz 0x9199
000F9192  F606180408        test byte [0x418],0x8
000F9197  7511              jnz 0x91aa
000F9199  BBC113            mov bx,0x13c1
000F919C  B90A00            mov cx,0xa
000F919F  90                nop
000F91A0  2E3A07            cmp al,[cs:bx]
000F91A3  740B              jz 0x91b0
000F91A5  43                inc bx
000F91A6  43                inc bx
000F91A7  43                inc bx
000F91A8  E2F6              loop 0x91a0
000F91AA  80261804F7        and byte [0x418],0xf7
000F91AF  C3                ret
000F91B0  2E8B4701          mov ax,[cs:bx+0x1]
000F91B4  F6C4FF            test ah,0xff
000F91B7  7505              jnz 0x91be
000F91B9  E8F1FA            call 0x8cad
000F91BC  EB0A              jmp short 0x91c8
000F91BE  8ADA              mov bl,dl
000F91C0  80E37F            and bl,0x7f
000F91C3  80FB7D            cmp bl,0x7d
000F91C6  7308              jnc 0x91d0
000F91C8  F6C280            test dl,0x80
000F91CB  75E2              jnz 0x91af
000F91CD  E98400            jmp 0x9254
000F91D0  80E280            and dl,0x80
000F91D3  0AC2              or al,dl
000F91D5  CD06              int 0x6
000F91D7  73D6              jnc 0x91af
000F91D9  EB79              jmp short 0x9254
000F91DB  90                nop
000F91DC  8AD8              mov bl,al
000F91DE  A01704            mov al,[0x417]
000F91E1  8AC8              mov cl,al
000F91E3  24BF              and al,0xbf
000F91E5  A803              test al,0x3
000F91E7  7405              jz 0x91ee
000F91E9  80F140            xor cl,0x40
000F91EC  3460              xor al,0x60
000F91EE  80FB47            cmp bl,0x47
000F91F1  7204              jc 0x91f7
000F91F3  242C              and al,0x2c
000F91F5  EB02              jmp short 0x91f9
000F91F7  244C              and al,0x4c
000F91F9  7412              jz 0x920d
000F91FB  8AE0              mov ah,al
000F91FD  B002              mov al,0x2
000F91FF  F6C408            test ah,0x8
000F9202  7509              jnz 0x920d
000F9204  D0E0              shl al,1
000F9206  F6C404            test ah,0x4
000F9209  7502              jnz 0x920d
000F920B  40                inc ax
000F920C  40                inc ax
000F920D  32FF              xor bh,bh
000F920F  03DB              add bx,bx
000F9211  03DB              add bx,bx
000F9213  03DB              add bx,bx
000F9215  32E4              xor ah,ah
000F9217  03D8              add bx,ax
000F9219  2E8B9FDF13        mov bx,[cs:bx+0x13df]
000F921E  80FFF0            cmp bh,0xf0
000F9221  720C              jc 0x922f
000F9223  8AE7              mov ah,bh
000F9225  32FF              xor bh,bh
000F9227  F6C280            test dl,0x80
000F922A  2EFFA7A513        jmp [cs:bx+0x13a5]
000F922F  F6C280            test dl,0x80
000F9232  751F              jnz 0x9253
000F9234  8BC3              mov ax,bx
000F9236  F606180408        test byte [0x418],0x8
000F923B  7511              jnz 0x924e
000F923D  F6C140            test cl,0x40
000F9240  7412              jz 0x9254
000F9242  3C61              cmp al,0x61
000F9244  720E              jc 0x9254
000F9246  3C7A              cmp al,0x7a
000F9248  770A              ja 0x9254
000F924A  2C20              sub al,0x20
000F924C  EB06              jmp short 0x9254
000F924E  80261804F7        and byte [0x418],0xf7
000F9253  C3                ret
000F9254  40                inc ax
000F9255  742C              jz 0x9283
000F9257  48                dec ax
000F9258  8B1E1C04          mov bx,[0x41c]
000F925C  53                push bx
000F925D  43                inc bx
000F925E  43                inc bx
000F925F  3B1E8204          cmp bx,[0x482]
000F9263  7204              jc 0x9269
000F9265  8B1E8004          mov bx,[0x480]
000F9269  3B1E1A04          cmp bx,[0x41a]
000F926D  7410              jz 0x927f
000F926F  891E1C04          mov [0x41c],bx
000F9273  5B                pop bx
000F9274  06                push es
000F9275  B94000            mov cx,0x40
000F9278  8EC1              mov es,cx
000F927A  268907            mov [es:bx],ax
000F927D  07                pop es
000F927E  C3                ret
000F927F  5B                pop bx
000F9280  E9A31E            jmp 0xb126
000F9283  C606190400        mov byte [0x419],0x0
000F9288  C3                ret
000F9289  751C              jnz 0x92a7
000F928B  F606180408        test byte [0x418],0x8
000F9290  7576              jnz 0x9308
000F9292  A01904            mov al,[0x419]
000F9295  02C0              add al,al
000F9297  8AD8              mov bl,al
000F9299  02C0              add al,al
000F929B  02C0              add al,al
000F929D  02C3              add al,bl
000F929F  80E40F            and ah,0xf
000F92A2  02C4              add al,ah
000F92A4  A21904            mov [0x419],al
000F92A7  C3                ret
000F92A8  75FD              jnz 0x92a7
000F92AA  F606180408        test byte [0x418],0x8
000F92AF  7557              jnz 0x9308
000F92B1  A18004            mov ax,[0x480]
000F92B4  A31C04            mov [0x41c],ax
000F92B7  A31A04            mov [0x41a],ax
000F92BA  C606710480        mov byte [0x471],0x80
000F92BF  1E                push ds
000F92C0  B84000            mov ax,0x40
000F92C3  8ED8              mov ds,ax
000F92C5  CD1B              int 0x1b
000F92C7  1F                pop ds
000F92C8  B80000            mov ax,0x0
000F92CB  EB87              jmp short 0x9254
000F92CD  755F              jnz 0x932e
000F92CF  F606170404        test byte [0x417],0x4
000F92D4  7458              jz 0x932e
000F92D6  33C0              xor ax,ax
000F92D8  8ED8              mov ds,ax
000F92DA  C70672043412      mov word [0x472],0x1234
000F92E0  E9E6ED            jmp 0x80c9
000F92E3  7549              jnz 0x932e
000F92E5  F606180408        test byte [0x418],0x8
000F92EA  751C              jnz 0x9308
000F92EC  E80200            call 0x92f1
000F92EF  CD05              int 0x5
000F92F1  803E490407        cmp byte [0x449],0x7
000F92F6  740B              jz 0x9303
000F92F8  8B166304          mov dx,[0x463]
000F92FC  83C204            add dx,byte +0x4
000F92FF  A06504            mov al,[0x465]
000F9302  EE                out dx,al
000F9303  B061              mov al,0x61
000F9305  E620              out 0x20,al
000F9307  C3                ret
000F9308  80261804F7        and byte [0x418],0xf7
000F930D  C3                ret
000F930E  7549              jnz 0x9359
000F9310  E84600            call 0x9359
000F9313  F606180408        test byte [0x418],0x8
000F9318  7514              jnz 0x932e
000F931A  800E180408        or byte [0x418],0x8
000F931F  E8CFFF            call 0x92f1
000F9322  FB                sti
000F9323  F606180408        test byte [0x418],0x8
000F9328  75F9              jnz 0x9323
000F932A  58                pop ax
000F932B  E951FE            jmp 0x917f
000F932E  C3                ret
000F932F  A880              test al,0x80
000F9331  7508              jnz 0x933b
000F9333  02C0              add al,al
000F9335  041D              add al,0x1d
000F9337  E873F9            call 0x8cad
000F933A  F9                stc
000F933B  CA0200            retf 0x2
000F933E  B480              mov ah,0x80
000F9340  7519              jnz 0x935b
000F9342  84261804          test [0x418],ah
000F9346  755C              jnz 0x93a4
000F9348  E81000            call 0x935b
000F934B  B80052            mov ax,0x5200
000F934E  E903FF            jmp 0x9254
000F9351  B410              mov ah,0x10
000F9353  EB06              jmp short 0x935b
000F9355  B440              mov ah,0x40
000F9357  EB02              jmp short 0x935b
000F9359  B420              mov ah,0x20
000F935B  750F              jnz 0x936c
000F935D  84261804          test [0x418],ah
000F9361  7508              jnz 0x936b
000F9363  08261804          or [0x418],ah
000F9367  30261704          xor [0x417],ah
000F936B  C3                ret
000F936C  F6D4              not ah
000F936E  20261804          and [0x418],ah
000F9372  C3                ret
000F9373  9C                pushf
000F9374  B408              mov ah,0x8
000F9376  E81E00            call 0x9397
000F9379  A01904            mov al,[0x419]
000F937C  C606190400        mov byte [0x419],0x0
000F9381  9D                popf
000F9382  74AA              jz 0x932e
000F9384  0AC0              or al,al
000F9386  74A6              jz 0x932e
000F9388  32E4              xor ah,ah
000F938A  E9C7FE            jmp 0x9254
000F938D  B404              mov ah,0x4
000F938F  EB06              jmp short 0x9397
000F9391  B402              mov ah,0x2
000F9393  EB02              jmp short 0x9397
000F9395  B401              mov ah,0x1
000F9397  7505              jnz 0x939e
000F9399  08261704          or [0x417],ah
000F939D  C3                ret
000F939E  F6D4              not ah
000F93A0  20261704          and [0x417],ah
000F93A4  C3                ret
000F93A5  8912              mov [bp+si],dx
000F93A7  0E                push cs
000F93A8  13A812CD          adc bp,[bx+si-0x32ee]
000F93AC  12E3              adc ah,bl
000F93AE  123E1351          adc bh,[0x5113]
000F93B2  135513            adc dx,[di+0x13]
000F93B5  59                pop cx
000F93B6  13911395          adc dx,[bx+di-0x6aed]
000F93BA  137313            adc si,[bp+di+0x13]
000F93BD  8D13              lea dx,[bp+di]
000F93BF  831274            adc word [bp+si],byte +0x74
000F93C2  150070            adc ax,0x7000
000F93C5  17                pop ss
000F93C6  00771B            add [bx+0x1b],dh
000F93C9  007819            add [bx+si+0x19],bh
000F93CC  007900            add [bx+di+0x0],bh
000F93CF  4D                dec bp
000F93D0  7A00              jpe 0x93d2
000F93D2  4B                dec bx
000F93D3  7B00              jpo 0x93d5
000F93D5  50                push ax
000F93D6  7C00              jl 0x93d8
000F93D8  48                dec ax
000F93D9  7E00              jng 0x93db
000F93DB  017D01            add [di+0x1],di
000F93DE  011A              add [bp+si],bx
000F93E0  F01AF0            lock sbb dh,al
000F93E3  1AF0              sbb dh,al
000F93E5  1AF0              sbb dh,al
000F93E7  1B01              sbb ax,[bx+di]
000F93E9  1AF0              sbb dh,al
000F93EB  1B01              sbb ax,[bx+di]
000F93ED  1B01              sbb ax,[bx+di]
000F93EF  3102              xor [bp+si],ax
000F93F1  00781A            add [bx+si+0x1a],bh
000F93F4  F02102            lock and [bp+si],ax
000F93F7  3203              xor al,[bp+di]
000F93F9  007900            add [bx+di+0x0],bh
000F93FC  034003            add ax,[bx+si+0x3]
000F93FF  3304              xor ax,[si]
000F9401  007A1A            add [bp+si+0x1a],bh
000F9404  F02304            lock and ax,[si]
000F9407  3405              xor al,0x5
000F9409  007B1A            add [bp+di+0x1a],bh
000F940C  F02405            lock and al,0x5
000F940F  350600            xor ax,0x6
000F9412  7C1A              jl 0x942e
000F9414  F0250636          lock and ax,0x3606
000F9418  07                pop es
000F9419  007D1E            add [di+0x1e],bh
000F941C  07                pop es
000F941D  5E                pop si
000F941E  07                pop es
000F941F  37                aaa
000F9420  0800              or [bx+si],al
000F9422  7E1A              jng 0x943e
000F9424  F0260838          lock or [es:bx+si],bh
000F9428  0900              or [bx+si],ax
000F942A  7F1A              jg 0x9446
000F942C  F02A09            lock sub cl,[bx+di]
000F942F  390A              cmp [bp+si],cx
000F9431  00801AF0          add [bx+si-0xfe6],al
000F9435  280A              sub [bp+si],cl
000F9437  300B              xor [bp+di],cl
000F9439  00811AF0          add [bx+di-0xfe6],al
000F943D  290B              sub [bp+di],cx
000F943F  2D0C00            sub ax,0xc
000F9442  82                db 0x82
000F9443  1F                pop ds
000F9444  0C5F              or al,0x5f
000F9446  0C3D              or al,0x3d
000F9448  0D0083            or ax,0x8300
000F944B  1AF0              sbb dh,al
000F944D  2B0D              sub cx,[di]
000F944F  080E1AF0          or [0xf01a],cl
000F9453  7F0E              jg 0x9463
000F9455  080E090F          or [0xf09],cl
000F9459  1AF0              sbb dh,al
000F945B  1AF0              sbb dh,al
000F945D  000F              add [bx],cl
000F945F  7110              jno 0x9471
000F9461  0010              add [bx+si],dl
000F9463  1110              adc [bx+si],dx
000F9465  7110              jno 0x9477
000F9467  7711              ja 0x947a
000F9469  0011              add [bx+di],dl
000F946B  17                pop ss
000F946C  117711            adc [bx+0x11],si
000F946F  651200            adc al,[gs:bx+si]
000F9472  1205              adc al,[di]
000F9474  126512            adc ah,[di+0x12]
000F9477  7213              jc 0x948c
000F9479  0013              add [bp+di],dl
000F947B  1213              adc dl,[bp+di]
000F947D  7213              jc 0x9492
000F947F  7414              jz 0x9495
000F9481  0014              add [si],dl
000F9483  1414              adc al,0x14
000F9485  7414              jz 0x949b
000F9487  7915              jns 0x949e
000F9489  0015              add [di],dl
000F948B  1915              sbb [di],dx
000F948D  7915              jns 0x94a4
000F948F  7516              jnz 0x94a7
000F9491  00161516          add [0x1615],dl
000F9495  7516              jnz 0x94ad
000F9497  69170017          imul dx,[bx],word 0x1700
000F949B  0917              or [bx],dx
000F949D  69176F18          imul dx,[bx],word 0x186f
000F94A1  0018              add [bx+si],bl
000F94A3  0F186F18          hint_nop5 word [bx+0x18]
000F94A7  7019              jo 0x94c2
000F94A9  0019              add [bx+di],bl
000F94AB  1019              adc [bx+di],bl
000F94AD  7019              jo 0x94c8
000F94AF  5B                pop bx
000F94B0  1A1A              sbb bl,[bp+si]
000F94B2  F01B1A            lock sbb bx,[bp+si]
000F94B5  7B1A              jpo 0x94d1
000F94B7  5D                pop bp
000F94B8  1B1A              sbb bx,[bp+si]
000F94BA  F01D1B7D          lock sbb ax,0x7d1b
000F94BE  1B0D              sbb cx,[di]
000F94C0  1C1A              sbb al,0x1a
000F94C2  F00A1C            lock or bl,[si]
000F94C5  0D1C18            or ax,0x181c
000F94C8  F018F0            lock sbb al,dh
000F94CB  18F0              sbb al,dh
000F94CD  18F0              sbb al,dh
000F94CF  61                popa
000F94D0  1E                push ds
000F94D1  001E011E          add [0x1e01],bl
000F94D5  61                popa
000F94D6  1E                push ds
000F94D7  731F              jnc 0x94f8
000F94D9  001F              add [bx],bl
000F94DB  131F              adc bx,[bx]
000F94DD  731F              jnc 0x94fe
000F94DF  642000            and [fs:bx+si],al
000F94E2  2004              and [si],al
000F94E4  206420            and [si+0x20],ah
000F94E7  662100            and [bx+si],eax
000F94EA  21062166          and [0x6621],ax
000F94EE  216722            and [bx+0x22],sp
000F94F1  0022              add [bp+si],ah
000F94F3  07                pop es
000F94F4  226722            and ah,[bx+0x22]
000F94F7  682300            push word 0x23
000F94FA  2308              and cx,[bx+si]
000F94FC  236823            and bp,[bx+si+0x23]
000F94FF  6A24              push byte +0x24
000F9501  0024              add [si],ah
000F9503  0A24              or ah,[si]
000F9505  6A24              push byte +0x24
000F9507  6B2500            imul sp,[di],byte +0x0
000F950A  250B25            and ax,0x250b
000F950D  6B256C            imul sp,[di],byte +0x6c
000F9510  2600260C26        add [es:0x260c],ah
000F9515  6C                insb
000F9516  263B27            cmp sp,[es:bx]
000F9519  1AF0              sbb dh,al
000F951B  1AF0              sbb dh,al
000F951D  3A27              cmp ah,[bx]
000F951F  27                daa
000F9520  281A              sub [bp+si],bl
000F9522  F01AF0            lock sbb dh,al
000F9525  2228              and ch,[bx+si]
000F9527  60                pusha
000F9528  291A              sub [bp+si],bx
000F952A  F01AF0            lock sbb dh,al
000F952D  7E29              jng 0x9558
000F952F  12F0              adc dh,al
000F9531  12F0              adc dh,al
000F9533  12F0              adc dh,al
000F9535  12F0              adc dh,al
000F9537  5C                pop sp
000F9538  2B1A              sub bx,[bp+si]
000F953A  F01C2B            lock sbb al,0x2b
000F953D  7C2B              jl 0x956a
000F953F  7A2C              jpe 0x956d
000F9541  002C              add [si],ch
000F9543  1A2C              sbb ch,[si]
000F9545  7A2C              jpe 0x9573
000F9547  782D              js 0x9576
000F9549  002D              add [di],ch
000F954B  182D              sbb [di],ch
000F954D  782D              js 0x957c
000F954F  632E002E          arpl [0x2e00],bp
000F9553  032E632E          add bp,[0x2e63]
000F9557  762F              jna 0x9588
000F9559  002F              add [bx],ch
000F955B  16                push ss
000F955C  2F                das
000F955D  762F              jna 0x958e
000F955F  6230              bound si,[bx+si]
000F9561  0030              add [bx+si],dh
000F9563  0230              add dh,[bx+si]
000F9565  6230              bound si,[bx+si]
000F9567  6E                outsb
000F9568  3100              xor [bx+si],ax
000F956A  310E316E          xor [0x6e31],cx
000F956E  316D32            xor [di+0x32],bp
000F9571  0032              add [bp+si],dh
000F9573  0D326D            or ax,0x6d32
000F9576  322C              xor ch,[si]
000F9578  331A              xor bx,[bp+si]
000F957A  F01AF0            lock sbb dh,al
000F957D  3C33              cmp al,0x33
000F957F  2E341A            cs xor al,0x1a
000F9582  F01AF0            lock sbb dh,al
000F9585  3E342F            ds xor al,0x2f
000F9588  351AF0            xor ax,0xf01a
000F958B  1AF0              sbb dh,al
000F958D  3F                aas
000F958E  3514F0            xor ax,0xf014
000F9591  14F0              adc al,0xf0
000F9593  14F0              adc al,0xf0
000F9595  14F0              adc al,0xf0
000F9597  2A37              sub dh,[bx]
000F9599  1AF0              sbb dh,al
000F959B  007208            add [bp+si+0x8],dh
000F959E  F016              lock push ss
000F95A0  F016              lock push ss
000F95A2  F016              lock push ss
000F95A4  F016              lock push ss
000F95A6  F02039            lock and [bx+di],bh
000F95A9  2039              and [bx+di],bh
000F95AB  2039              and [bx+di],bh
000F95AD  2039              and [bx+di],bh
000F95AF  0E                push cs
000F95B0  F00E              lock push cs
000F95B2  F00E              lock push cs
000F95B4  F00E              lock push cs
000F95B6  F0003B            lock add [bp+di],bh
000F95B9  006800            add [bx+si+0x0],ch
000F95BC  5E                pop si
000F95BD  005400            add [si+0x0],dl
000F95C0  3C00              cmp al,0x0
000F95C2  69005F00          imul ax,[bx+si],word 0x5f
000F95C6  55                push bp
000F95C7  003D              add [di],bh
000F95C9  006A00            add [bp+si+0x0],ch
000F95CC  60                pusha
000F95CD  005600            add [bp+0x0],dl
000F95D0  3E006B00          add [ds:bp+di+0x0],ch
000F95D4  61                popa
000F95D5  005700            add [bx+0x0],dl
000F95D8  3F                aas
000F95D9  006C00            add [si+0x0],ch
000F95DC  6200              bound ax,[bx+si]
000F95DE  58                pop ax
000F95DF  004000            add [bx+si+0x0],al
000F95E2  6D                insw
000F95E3  006300            add [bp+di+0x0],ah
000F95E6  59                pop cx
000F95E7  004100            add [bx+di+0x0],al
000F95EA  6E                outsb
000F95EB  006400            add [si+0x0],ah
000F95EE  5A                pop dx
000F95EF  004200            add [bp+si+0x0],al
000F95F2  6F                outsw
000F95F3  006500            add [di+0x0],ah
000F95F6  5B                pop bx
000F95F7  004300            add [bp+di+0x0],al
000F95FA  7000              jo 0x95fc
000F95FC  66005C00          o32 add [si+0x0],bl
000F9600  44                inc sp
000F9601  007100            add [bx+di+0x0],dh
000F9604  67005D10          add [ebp+0x10],bl
000F9608  F010F0            lock adc al,dh
000F960B  02F0              add dh,al
000F960D  10F0              adc al,dh
000F960F  0CF0              or al,0xf0
000F9611  0CF0              or al,0xf0
000F9613  04F0              add al,0xf0
000F9615  0CF0              or al,0xf0
000F9617  004700            add [bx+0x0],al
000F961A  F7007737          test word [bx+si],0x3777
000F961E  47                inc di
000F961F  004800            add [bx+si+0x0],cl
000F9622  F8                clc
000F9623  1AF0              sbb dh,al
000F9625  384800            cmp [bx+si+0x0],cl
000F9628  49                dec cx
000F9629  00F9              add cl,bh
000F962B  00843949          add [si+0x4939],al
000F962F  2D4A1A            sub ax,0x1a4a
000F9632  F01AF0            lock sbb dh,al
000F9635  2D4A00            sub ax,0x4a
000F9638  4B                dec bx
000F9639  00F4              add ah,dh
000F963B  007334            add [bp+di+0x34],dh
000F963E  4B                dec bx
000F963F  1AF0              sbb dh,al
000F9641  00F5              add ch,dh
000F9643  1AF0              sbb dh,al
000F9645  354C00            xor ax,0x4c
000F9648  4D                dec bp
000F9649  00F6              add dh,dh
000F964B  007436            add [si+0x36],dh
000F964E  4D                dec bp
000F964F  2B4E1A            sub cx,[bp+0x1a]
000F9652  F01AF0            lock sbb dh,al
000F9655  2B4E00            sub cx,[bp+0x0]
000F9658  4F                dec di
000F9659  00F1              add cl,dh
000F965B  007531            add [di+0x31],dh
000F965E  4F                dec di
000F965F  005000            add [bx+si+0x0],dl
000F9662  F21AF0            repne sbb dh,al
000F9665  325000            xor dl,[bx+si+0x0]
000F9668  51                push cx
000F9669  00F3              add bl,dh
000F966B  007633            add [bp+0x33],dh
000F966E  51                push cx
000F966F  0AF0              or dh,al
000F9671  00F0              add al,dh
000F9673  1AF0              sbb dh,al
000F9675  305200            xor [bp+si+0x0],dl
000F9678  53                push bx
000F9679  06                push es
000F967A  F01AF0            lock sbb dh,al
000F967D  2E53              cs push bx
000F967F  00E8              add al,ch
000F9681  1C01              sbb al,0x1
000F9683  56                push si
000F9684  8BF0              mov si,ax
000F9686  FC                cld
000F9687  2EAC              cs lodsb
000F9689  0AC0              or al,al
000F968B  7407              jz 0x9694
000F968D  51                push cx
000F968E  E80500            call 0x9696
000F9691  59                pop cx
000F9692  EBF3              jmp short 0x9687
000F9694  5E                pop si
000F9695  C3                ret
000F9696  7904              jns 0x969c
000F9698  247F              and al,0x7f
000F969A  EBE4              jmp short 0x9680
000F969C  3C20              cmp al,0x20
000F969E  7326              jnc 0x96c6
000F96A0  3C02              cmp al,0x2
000F96A2  7516              jnz 0x96ba
000F96A4  2EAC              cs lodsb
000F96A6  8AC8              mov cl,al
000F96A8  56                push si
000F96A9  32ED              xor ch,ch
000F96AB  BEC822            mov si,0x22c8
000F96AE  E3D6              jcxz 0x9686
000F96B0  2EAC              cs lodsb
000F96B2  0AC0              or al,al
000F96B4  75FA              jnz 0x96b0
000F96B6  E2F8              loop 0x96b0
000F96B8  EBCC              jmp short 0x9686
000F96BA  3C07              cmp al,0x7
000F96BC  7413              jz 0x96d1
000F96BE  3C1B              cmp al,0x1b
000F96C0  751B              jnz 0x96dd
000F96C2  2EAC              cs lodsb
000F96C4  EB0B              jmp short 0x96d1
000F96C6  3C5C              cmp al,0x5c
000F96C8  7507              jnz 0x96d1
000F96CA  B00D              mov al,0xd
000F96CC  E8C700            call 0x9796
000F96CF  B00A              mov al,0xa
000F96D1  E8C200            call 0x9796
000F96D4  3C07              cmp al,0x7
000F96D6  7504              jnz 0x96dc
000F96D8  33C9              xor cx,cx
000F96DA  E2FE              loop 0x96da
000F96DC  C3                ret
000F96DD  3C0F              cmp al,0xf
000F96DF  751C              jnz 0x96fd
000F96E1  B009              mov al,0x9
000F96E3  90                nop
000F96E4  E8B800            call 0x979f
000F96E7  32ED              xor ch,ch
000F96E9  E398              jcxz 0x9683
000F96EB  53                push bx
000F96EC  8BD8              mov bx,ax
000F96EE  2E8A2F            mov ch,[cs:bx]
000F96F1  43                inc bx
000F96F2  0AED              or ch,ch
000F96F4  75F8              jnz 0x96ee
000F96F6  E2F6              loop 0x96ee
000F96F8  8BC3              mov ax,bx
000F96FA  5B                pop bx
000F96FB  EB86              jmp short 0x9683
000F96FD  3C15              cmp al,0x15
000F96FF  7422              jz 0x9723
000F9701  3C10              cmp al,0x10
000F9703  744E              jz 0x9753
000F9705  B103              mov cl,0x3
000F9707  3C14              cmp al,0x14
000F9709  7464              jz 0x976f
000F970B  32C9              xor cl,cl
000F970D  3C12              cmp al,0x12
000F970F  8AC3              mov al,bl
000F9711  7463              jz 0x9776
000F9713  8AC7              mov al,bh
000F9715  725F              jc 0x9776
000F9717  8AC5              mov al,ch
000F9719  EB5B              jmp short 0x9776
000F971B  1027              adc [bx],ah
000F971D  E80364            call 0xfb23
000F9720  000A              add [bp+si],cl
000F9722  00568B            add [bp-0x75],dl
000F9725  DABE1B17          fidivr dword [bp+0x171b]
000F9729  B90400            mov cx,0x4
000F972C  FC                cld
000F972D  2EAD              cs lodsw
000F972F  33D2              xor dx,dx
000F9731  93                xchg ax,bx
000F9732  F7F3              div bx
000F9734  8BDA              mov bx,dx
000F9736  0AC0              or al,al
000F9738  7404              jz 0x973e
000F973A  B530              mov ch,0x30
000F973C  EB04              jmp short 0x9742
000F973E  0AED              or ch,ch
000F9740  7405              jz 0x9747
000F9742  02C5              add al,ch
000F9744  E84F00            call 0x9796
000F9747  FEC9              dec cl
000F9749  75E2              jnz 0x972d
000F974B  8AC3              mov al,bl
000F974D  0430              add al,0x30
000F974F  5E                pop si
000F9750  EB44              jmp short 0x9796
000F9752  90                nop
000F9753  52                push dx
000F9754  8CDA              mov dx,ds
000F9756  B104              mov cl,0x4
000F9758  D3C2              rol dx,cl
000F975A  8AC2              mov al,dl
000F975C  80E2F0            and dl,0xf0
000F975F  03D3              add dx,bx
000F9761  7302              jnc 0x9765
000F9763  FEC0              inc al
000F9765  32C9              xor cl,cl
000F9767  E81700            call 0x9781
000F976A  E80200            call 0x976f
000F976D  5A                pop dx
000F976E  C3                ret
000F976F  8AC6              mov al,dh
000F9771  E80200            call 0x9776
000F9774  8AC2              mov al,dl
000F9776  50                push ax
000F9777  51                push cx
000F9778  B104              mov cl,0x4
000F977A  D2C0              rol al,cl
000F977C  59                pop cx
000F977D  E80100            call 0x9781
000F9780  58                pop ax
000F9781  240F              and al,0xf
000F9783  0490              add al,0x90
000F9785  27                daa
000F9786  1440              adc al,0x40
000F9788  27                daa
000F9789  3C30              cmp al,0x30
000F978B  7507              jnz 0x9794
000F978D  0AC9              or cl,cl
000F978F  7403              jz 0x9794
000F9791  FEC9              dec cl
000F9793  C3                ret
000F9794  32C9              xor cl,cl
000F9796  53                push bx
000F9797  B40E              mov ah,0xe
000F9799  33DB              xor bx,bx
000F979B  CD10              int 0x10
000F979D  5B                pop bx
000F979E  C3                ret
000F979F  53                push bx
000F97A0  52                push dx
000F97A1  32E4              xor ah,ah
000F97A3  50                push ax
000F97A4  BA7903            mov dx,0x379
000F97A7  EC                in al,dx
000F97A8  250700            and ax,0x7
000F97AB  D1E0              shl ax,1
000F97AD  8BD8              mov bx,ax
000F97AF  2E8B9F2E27        mov bx,[cs:bx+0x272e]
000F97B4  58                pop ax
000F97B5  5A                pop dx
000F97B6  D1E0              shl ax,1
000F97B8  03D8              add bx,ax
000F97BA  2E8B07            mov ax,[cs:bx]
000F97BD  5B                pop bx
000F97BE  C3                ret
000F97BF  B00E              mov al,0xe
000F97C1  FA                cli
000F97C2  8BE8              mov bp,ax
000F97C4  BBCA17            mov bx,0x17ca
000F97C7  E9E819            jmp 0xb1b2
000F97CA  33FF              xor di,di
000F97CC  B800B0            mov ax,0xb000
000F97CF  8EC0              mov es,ax
000F97D1  BA7903            mov dx,0x379
000F97D4  EC                in al,dx
000F97D5  250700            and ax,0x7
000F97D8  D1E0              shl ax,1
000F97DA  8BD8              mov bx,ax
000F97DC  8CC8              mov ax,cs
000F97DE  8ED8              mov ds,ax
000F97E0  8B9F2E27          mov bx,[bx+0x272e]
000F97E4  8BC5              mov ax,bp
000F97E6  3C0F              cmp al,0xf
000F97E8  BA4503            mov dx,0x345
000F97EB  740C              jz 0x97f9
000F97ED  B000              mov al,0x0
000F97EF  BAF417            mov dx,0x17f4
000F97F2  EB05              jmp short 0x97f9
000F97F4  8BC5              mov ax,bp
000F97F6  BA6218            mov dx,0x1862
000F97F9  8B7710            mov si,[bx+0x10]
000F97FC  FC                cld
000F97FD  8BC8              mov cx,ax
000F97FF  32ED              xor ch,ch
000F9801  E307              jcxz 0x980a
000F9803  AC                lodsb
000F9804  0AC0              or al,al
000F9806  75FB              jnz 0x9803
000F9808  E2F9              loop 0x9803
000F980A  AC                lodsb
000F980B  3C1B              cmp al,0x1b
000F980D  7503              jnz 0x9812
000F980F  AC                lodsb
000F9810  EB1F              jmp short 0x9831
000F9812  0AC0              or al,al
000F9814  7826              js 0x983c
000F9816  7502              jnz 0x981a
000F9818  FFE2              jmp dx
000F981A  3C02              cmp al,0x2
000F981C  7513              jnz 0x9831
000F981E  AC                lodsb
000F981F  8AE0              mov ah,al
000F9821  8BCE              mov cx,si
000F9823  BEC822            mov si,0x22c8
000F9826  AC                lodsb
000F9827  0AC0              or al,al
000F9829  75FB              jnz 0x9826
000F982B  FECC              dec ah
000F982D  75F7              jnz 0x9826
000F982F  EB18              jmp short 0x9849
000F9831  268805            mov [es:di],al
000F9834  81F70080          xor di,0x8000
000F9838  AA                stosb
000F9839  47                inc di
000F983A  EBCE              jmp short 0x980a
000F983C  257F00            and ax,0x7f
000F983F  D1E0              shl ax,1
000F9841  8BC8              mov cx,ax
000F9843  87F1              xchg cx,si
000F9845  03F3              add si,bx
000F9847  8B34              mov si,[si]
000F9849  AC                lodsb
000F984A  0AC0              or al,al
000F984C  87F1              xchg cx,si
000F984E  74BA              jz 0x980a
000F9850  87F1              xchg cx,si
000F9852  3C1B              cmp al,0x1b
000F9854  7501              jnz 0x9857
000F9856  AC                lodsb
000F9857  268805            mov [es:di],al
000F985A  81F70080          xor di,0x8000
000F985E  AA                stosb
000F985F  47                inc di
000F9860  EBE7              jmp short 0x9849
000F9862  EBFE              jmp short 0x9862
000F9864  C746020103        mov word [bp+0x2],0x301
000F9869  C3                ret
000F986A  8A02              mov al,[bp+si]
000F986C  0300              add ax,[bx+si]
000F986E  5C                pop sp
000F986F  53                push bx
000F9870  49                dec cx
000F9871  44                inc sp
000F9872  53                push bx
000F9873  54                push sp
000F9874  204245            and [bp+si+0x45],al
000F9877  4E                dec si
000F9878  59                pop cx
000F9879  54                push sp
000F987A  54                push sp
000F987B  45                inc bp
000F987C  54                push sp
000F987D  3A20              cmp ah,[bx+si]
000F987F  8A5C07            mov bl,[si+0x7]
000F9882  0002              add [bp+si],al
000F9884  035C49            add bx,[si+0x49]
000F9887  6E                outsb
000F9888  647374            fs jnc 0x98ff
000F988B  696C204461        imul bp,[si+0x20],word 0x6144
000F9890  746F              jz 0x9901
000F9892  206F67            and [bx+0x67],ch
000F9895  204B6C            and [bp+di+0x6c],cl
000F9898  6F                outsw
000F9899  6B6B6573          imul bp,[bp+di+0x65],byte +0x73
000F989D  6C                insb
000F989E  65745C            gs jz 0x98fd
000F98A1  4A                dec dx
000F98A2  7573              jnz 0x9917
000F98A4  7465              jz 0x990b
000F98A6  7227              jc 0x98cf
000F98A8  206F70            and [bx+0x70],ch
000F98AB  7374              jnc 0x9921
000F98AD  61                popa
000F98AE  7274              jc 0x9924
000F98B0  7376              jnc 0x9928
000F98B2  1B917264          sbb dx,[bx+di+0x6472]
000F98B6  6965726E65        imul sp,[di+0x72],word 0x656e
000F98BB  2028              and [bx+si],ch
000F98BD  4B                dec bx
000F98BE  756E              jnz 0x992e
000F98C0  206876            and [bx+si+0x76],ch
000F98C3  6973206E1B        imul si,[bp+di+0x20],word 0x1b6e
000F98C8  9B647665          fs wait jna 0x9931
000F98CC  6E                outsb
000F98CD  64696774295C      imul sp,[fs:bx+0x74],word 0x5c29
000F98D3  07                pop es
000F98D4  07                pop es
000F98D5  07                pop es
000F98D6  004D6F            add [di+0x6f],cl
000F98D9  6E                outsb
000F98DA  7465              jz 0x9941
000F98DC  7220              jc 0x98fe
000F98DE  7665              jna 0x9945
000F98E0  6E                outsb
000F98E1  6C                insb
000F98E2  6967737420        imul sp,[bx+0x73],word 0x2074
000F98E7  6E                outsb
000F98E8  7965              jns 0x994f
000F98EA  206261            and [bp+si+0x61],ah
000F98ED  7474              jz 0x9963
000F98EF  657269            gs jc 0x995b
000F98F2  65725C            gs jc 0x9951
000F98F5  005C43            add [si+0x43],bl
000F98F8  686563            push word 0x6365
000F98FB  6B2054            imul sp,[bx+si],byte +0x54
000F98FE  61                popa
000F98FF  7374              jnc 0x9975
000F9901  61                popa
000F9902  7475              jz 0x9979
000F9904  7265              jc 0x996b
000F9906  7420              jz 0x9928
000F9908  6F                outsw
000F9909  67204D75          and [ebp+0x75],cl
000F990D  7365              jnc 0x9974
000F990F  6E                outsb
000F9910  005C49            add [si+0x49],bl
000F9913  6E                outsb
000F9914  64731B            fs jnc 0x9932
000F9917  91                xchg ax,cx
000F9918  7420              jz 0x993a
000F991A  7665              jna 0x9981
000F991C  6E                outsb
000F991D  6C                insb
000F991E  6967737420        imul sp,[bx+0x73],word 0x2074
000F9923  656E              gs outsb
000F9925  2002              and [bp+si],al
000F9927  16                push ss
000F9928  206469            and [si+0x69],ah
000F992B  736B              jnc 0x9998
000F992D  657474            gs jz 0x99a4
000F9930  65206920          and [gs:bx+di+0x20],ch
000F9934  44                inc sp
000F9935  52                push dx
000F9936  45                inc bp
000F9937  56                push si
000F9938  20415C            and [bx+di+0x5c],al
000F993B  6F                outsw
000F993C  6720747279        and [dword edx+esi*2+0x79],dh
000F9941  6B2070            imul sp,[bx+si],byte +0x70
000F9944  1B862065          sbb ax,[bp+0x6520]
000F9948  6E                outsb
000F9949  207461            and [si+0x61],dh
000F994C  7374              jnc 0x99c2
000F994E  005C46            add [si+0x46],bl
000F9951  45                inc bp
000F9952  4A                dec dx
000F9953  4C                dec sp
000F9954  3A02              cmp al,[bp+si]
000F9956  1B02              sbb ax,[bp+si]
000F9958  1D3A5C            sbb ax,0x5c3a
000F995B  52                push dx
000F995C  4F                dec di
000F995D  4D                dec bp
000F995E  206164            and [bx+di+0x64],ah
000F9961  7265              jc 0x99c8
000F9963  7373              jnc 0x99d8
000F9965  65203D            and [gs:di],bh
000F9968  2010              and [bx+si],dl
000F996A  5C                pop sp
000F996B  004645            add [bp+0x45],al
000F996E  4A                dec dx
000F996F  4C                dec sp
000F9970  3A20              cmp ah,[bx+si]
000F9972  008B0216          add [bp+di+0x1602],cl
000F9976  205241            and [bp+si+0x41],dl
000F9979  4D                dec bp
000F997A  008B8D20          add [bp+di+0x208d],cl
000F997E  52                push dx
000F997F  41                inc cx
000F9980  4D                dec bp
000F9981  008B0220          add [bp+di+0x2002],cl
000F9985  8C00              mov [bx+si],es
000F9987  46                inc si
000F9988  656A6C            gs push byte +0x6c
000F998B  206C61            and [si+0x61],ch
000F998E  6765728C          gs jc 0x991e
000F9992  008B021C          add [bp+di+0x1c02],cl
000F9996  6B6F6E74          imul bp,[bx+0x6e],byte +0x74
000F999A  726F              jc 0x9a0b
000F999C  6C                insb
000F999D  20656C            and [di+0x6c],ah
000F99A0  6C                insb
000F99A1  657220            gs jc 0x99c4
000F99A4  021C              add bl,[si]
000F99A6  647265            fs jc 0x9a0e
000F99A9  7600              jna 0x99ab
000F99AB  8B02              mov ax,[bp+si]
000F99AD  1120              adc [bx+si],sp
000F99AF  0212              add dl,[bp+si]
000F99B1  008B0216          add [bp+di+0x1602],cl
000F99B5  2002              and [bp+si],al
000F99B7  1420              adc al,0x20
000F99B9  0215              add dl,[di]
000F99BB  008B0217          add [bp+di+0x1702],cl
000F99BF  7469              jz 0x9a2a
000F99C1  647320            fs jnc 0x99e4
000F99C4  7572              jnz 0x9a38
000F99C6  008B8D8C          add [bp+di-0x7373],cl
000F99CA  008B0216          add [bp+di+0x1602],cl
000F99CE  2002              and [bp+si],al
000F99D0  182D              sbb [di],ch
000F99D2  706F              jo 0x9a43
000F99D4  7274              jc 0x9a4a
000F99D6  008B0216          add [bp+di+0x1602],cl
000F99DA  0219              add bl,[bx+di]
000F99DC  2D706F            sub ax,0x6f70
000F99DF  7274              jc 0x9a55
000F99E1  008B0215          add [bp+di+0x1502],cl
000F99E5  207469            and [si+0x69],dh
000F99E8  6C                insb
000F99E9  206D75            and [di+0x75],ch
000F99EC  7300              jnc 0x99ee
000F99EE  43                inc bx
000F99EF  686563            push word 0x6365
000F99F2  6B73756D          imul si,[bp+di+0x75],byte +0x6d
000F99F6  66656A6C          gs o32 push byte +0x6c
000F99FA  206920            and [bx+di+0x20],ch
000F99FD  02162052          add dl,[0x5220]
000F9A01  4F                dec di
000F9A02  4D                dec bp
000F9A03  008B6C61          add [bp+di+0x616c],cl
000F9A07  67657220          gs jc 0x9a2b
000F9A0B  287061            sub [bx+si+0x61],dh
000F9A0E  7269              jc 0x9a79
000F9A10  7465              jz 0x9a77
000F9A12  7473              jz 0x9a87
000F9A14  206665            and [bp+0x65],ah
000F9A17  6A6C              push byte +0x6c
000F9A19  2900              sub [bx+si],ax
000F9A1B  56                push si
000F9A1C  656E              gs outsb
000F9A1E  7420              jz 0x9a40
000F9A20  657420            gs jz 0x9a43
000F9A23  6F                outsw
000F9A24  6A65              push byte +0x65
000F9A26  626C69            bound bp,[si+0x69]
000F9A29  6B2021            imul sp,[bx+si],byte +0x21
000F9A2C  0002              add [bp+si],al
000F9A2E  0400              add al,0x0
000F9A30  0205              add al,[di]
000F9A32  004D61            add [di+0x61],cl
000F9A35  7274              jc 0x9aab
000F9A37  7300              jnc 0x9a39
000F9A39  0209              add cl,[bx+di]
000F9A3B  004D61            add [di+0x61],cl
000F9A3E  6A00              push byte +0x0
000F9A40  02060002          add al,[0x200]
000F9A44  07                pop es
000F9A45  0002              add [bp+si],al
000F9A47  0A00              or al,[bx+si]
000F9A49  020B              add cl,[bp+di]
000F9A4B  0002              add [bp+si],al
000F9A4D  0C00              or al,0x0
000F9A4F  020D              add cl,[di]
000F9A51  0002              add [bp+si],al
000F9A53  0E                push cs
000F9A54  0011              add [bx+di],dl
000F9A56  3A12              cmp dl,[bp+si]
000F9A58  206465            and [si+0x65],ah
000F9A5B  6E                outsb
000F9A5C  2013              and [bp+di],dl
000F9A5E  200F              and [bx],cl
000F9A60  2014              and [si],dl
000F9A62  0020              add [bx+si],ah
000F9A64  6B6F6E74          imul bp,[bx+0x6e],byte +0x74
000F9A68  726F              jc 0x9ad9
000F9A6A  6C                insb
000F9A6B  20656E            and [di+0x6e],ah
000F9A6E  686564            push word 0x6465
000F9A71  004665            add [bp+0x65],al
000F9A74  6A6C              push byte +0x6c
000F9A76  206920            and [bx+di+0x20],ch
000F9A79  00736B            add [bp+di+0x6b],dh
000F9A7C  61                popa
000F9A7D  65726D            gs jc 0x9aed
000F9A80  008A0203          add [bp+si+0x302],cl
000F9A84  005C44            add [si+0x44],bl
000F9A87  65726E            gs jc 0x9af8
000F9A8A  6965722061        imul sp,[di+0x72],word 0x6120
000F9A8F  7272              jc 0x9b03
000F9A91  1B887420          sbb cx,[bx+si+0x2074]
000F9A95  1B85208A          sbb ax,[di-0x75e0]
000F9A99  5C                pop sp
000F9A9A  07                pop es
000F9A9B  0002              add [bp+si],al
000F9A9D  035C56            add bx,[si+0x56]
000F9AA0  657569            gs jnz 0x9b0c
000F9AA3  6C                insb
000F9AA4  6C                insb
000F9AA5  657A20            gs jpe 0x9ac8
000F9AA8  646F              fs outsw
000F9AAA  6E                outsb
000F9AAB  6E                outsb
000F9AAC  657220            gs jc 0x9acf
000F9AAF  6C                insb
000F9AB0  61                popa
000F9AB1  206461            and [si+0x61],ah
000F9AB4  7465              jz 0x9b1b
000F9AB6  206574            and [di+0x74],ah
000F9AB9  206C27            and [si+0x27],ch
000F9ABC  686575            push word 0x7565
000F9ABF  7265              jc 0x9b26
000F9AC1  5C                pop sp
000F9AC2  53                push bx
000F9AC3  69206E1B          imul sp,[bx+si],word 0x1b6e
000F9AC7  82                db 0x82
000F9AC8  636573            arpl [di+0x73],sp
000F9ACB  7361              jnc 0x9b2e
000F9ACD  6972652072        imul si,[bp+si+0x65],word 0x7220
000F9AD2  65641B826669      sbb ax,[fs:bp+si+0x6966]
000F9AD8  6E                outsb
000F9AD9  697373657A        imul si,[bp+di+0x73],word 0x7a65
000F9ADE  206C65            and [si+0x65],ch
000F9AE1  7320              jnc 0x9b03
000F9AE3  6F                outsw
000F9AE4  7074              jo 0x9b5a
000F9AE6  696F6E735C        imul bp,[bx+0x6e],word 0x5c73
000F9AEB  07                pop es
000F9AEC  07                pop es
000F9AED  07                pop es
000F9AEE  005665            add [bp+0x65],dl
000F9AF1  7569              jnz 0x9b5c
000F9AF3  6C                insb
000F9AF4  6C                insb
000F9AF5  657A20            gs jpe 0x9b18
000F9AF8  6D                insw
000F9AF9  657474            gs jz 0x9b70
000F9AFC  7265              jc 0x9b63
000F9AFE  206465            and [si+0x65],ah
000F9B01  7320              jnc 0x9b23
000F9B03  7069              jo 0x9b6e
000F9B05  6C                insb
000F9B06  657320            gs jnc 0x9b29
000F9B09  6E                outsb
000F9B0A  657576            gs jnz 0x9b83
000F9B0D  65735C            gs jnc 0x9b6c
000F9B10  005C56            add [si+0x56],bl
000F9B13  1B827269          sbb ax,[bp+si+0x6972]
000F9B17  6669657A206C6520  imul esp,[di+0x7a],dword 0x20656c20
000F9B1F  636C61            arpl [si+0x61],bp
000F9B22  7669              jna 0x9b8d
000F9B24  657220            gs jc 0x9b47
000F9B27  657420            gs jz 0x9b4a
000F9B2A  6C                insb
000F9B2B  61                popa
000F9B2C  20736F            and [bp+di+0x6f],dh
000F9B2F  7572              jnz 0x9ba3
000F9B31  6973005C4D        imul si,[bp+di+0x0],word 0x4d5c
000F9B36  657474            gs jz 0x9bad
000F9B39  657A20            gs jpe 0x9b5c
000F9B3C  756E              jnz 0x9bac
000F9B3E  65206469          and [gs:si+0x69],ah
000F9B42  7371              jnc 0x9bb5
000F9B44  7565              jnz 0x9bab
000F9B46  7474              jz 0x9bbc
000F9B48  65205379          and [gs:bp+di+0x79],dl
000F9B4C  7374              jnc 0x9bc2
000F9B4E  1B8A6D65          sbb cx,[bp+si+0x656d]
000F9B52  206461            and [si+0x61],ah
000F9B55  6E                outsb
000F9B56  7320              jnc 0x9b78
000F9B58  6C                insb
000F9B59  65204472          and [gs:si+0x72],al
000F9B5D  6976652041        imul si,[bp+0x65],word 0x4120
000F9B62  5C                pop sp
000F9B63  50                push ax
000F9B64  7569              jnz 0x9bcf
000F9B66  7320              jnc 0x9b88
000F9B68  7461              jz 0x9bcb
000F9B6A  7065              jo 0x9bd1
000F9B6C  7A20              jpe 0x9b8e
000F9B6E  756E              jnz 0x9bde
000F9B70  6520746F          and [gs:si+0x6f],dh
000F9B74  7563              jnz 0x9bd9
000F9B76  686520            push word 0x2065
000F9B79  7175              jno 0x9bf0
000F9B7B  656C              gs insb
000F9B7D  636F6E            arpl [bx+0x6e],bp
000F9B80  7175              jno 0x9bf7
000F9B82  65005C45          add [gs:si+0x45],bl
000F9B86  7272              jc 0x9bfa
000F9B88  657572            gs jnz 0x9bfd
000F9B8B  203A              and [bp+si],bh
000F9B8D  20746F            and [si+0x6f],dh
000F9B90  7461              jz 0x9bf3
000F9B92  6C                insb
000F9B93  20696E            and [bx+di+0x6e],ch
000F9B96  636F72            arpl [bx+0x72],bp
000F9B99  7265              jc 0x9c00
000F9B9B  637420            arpl [si+0x20],si
000F9B9E  6461              fs popa
000F9BA0  6E                outsb
000F9BA1  7320              jnc 0x9bc3
000F9BA3  6C                insb
000F9BA4  61                popa
000F9BA5  20524F            and [bp+si+0x4f],dl
000F9BA8  4D                dec bp
000F9BA9  206578            and [di+0x78],ah
000F9BAC  7465              jz 0x9c13
000F9BAE  726E              jc 0x9c1e
000F9BB0  65203A            and [gs:bp+si],bh
000F9BB3  5C                pop sp
000F9BB4  61                popa
000F9BB5  647265            fs jc 0x9c1d
000F9BB8  7373              jnc 0x9c2d
000F9BBA  6520656E          and [gs:di+0x6e],ah
000F9BBE  20524F            and [bp+si+0x4f],dl
000F9BC1  4D                dec bp
000F9BC2  203D              and [di],bh
000F9BC4  2010              and [bx+si],dl
000F9BC6  5C                pop sp
000F9BC7  004572            add [di+0x72],al
000F9BCA  7265              jc 0x9c31
000F9BCC  7572              jnz 0x9c40
000F9BCE  203A              and [bp+si],bh
000F9BD0  204465            and [si+0x65],al
000F9BD3  6661              popad
000F9BD5  696C6C616E        imul bp,[si+0x6c],word 0x6e61
000F9BDA  636520            arpl [di+0x20],sp
000F9BDD  008C0216          add [si+0x1602],cl
000F9BE1  45                inc bp
000F9BE2  008C5644          add [si+0x4456],cl
000F9BE6  55                push bp
000F9BE7  008B6427          add [bp+di+0x2764],cl
000F9BEB  696E746572        imul bp,[bp+0x74],word 0x7265
000F9BF0  7275              jc 0x9c67
000F9BF2  7074              jo 0x9c68
000F9BF4  696F6E7300        imul bp,[bx+0x6e],word 0x73
000F9BF9  8B444D            mov ax,[si+0x4d]
000F9BFC  41                inc cx
000F9BFD  008B6F75          add [bp+di+0x756f],cl
000F9C01  206475            and [si+0x75],ah
000F9C04  206C65            and [si+0x65],ch
000F9C07  637465            arpl [si+0x65],si
000F9C0A  7572              jnz 0x9c7e
000F9C0C  006475            add [si+0x75],ah
000F9C0F  206368            and [bp+di+0x68],ah
000F9C12  726F              jc 0x9c83
000F9C14  6E                outsb
000F9C15  6F                outsw
000F9C16  6D                insw
000F9C17  657472            gs jz 0x9c8c
000F9C1A  65006475          add [gs:si+0x75],ah
000F9C1E  207265            and [bp+si+0x65],dh
000F9C21  676973747265      imul si,[ebx+0x74],word 0x6572
000F9C27  206427            and [si+0x27],ah
000F9C2A  657461            gs jz 0x9c8e
000F9C2D  7420              jz 0x9c4f
000F9C2F  647520            fs jnz 0x9c52
000F9C32  7379              jnc 0x9cad
000F9C34  7374              jnc 0x9caa
000F9C36  656D              gs insw
000F9C38  65006465          add [gs:si+0x65],ah
000F9C3C  206C27            and [si+0x27],ch
000F9C3F  686F72            push word 0x726f
000F9C42  6C                insb
000F9C43  6F                outsw
000F9C44  676500647520      add [dword gs:ebp+esi*2+0x20],ah
000F9C4A  636F6E            arpl [bx+0x6e],bp
000F9C4D  7472              jz 0x9cc1
000F9C4F  6F                outsw
000F9C50  6C                insb
000F9C51  657572            gs jnz 0x9cc6
000F9C54  205644            and [bp+0x44],dl
000F9C57  55                push bp
000F9C58  008D6427          add [di+0x2764],cl
000F9C5C  696D707269        imul bp,[di+0x70],word 0x6972
000F9C61  6D                insw
000F9C62  61                popa
000F9C63  6E                outsb
000F9C64  7465              jz 0x9ccb
000F9C66  008D7365          add [di+0x6573],cl
000F9C6A  7269              jc 0x9cd5
000F9C6C  65006465          add [gs:si+0x65],ah
000F9C70  7320              jnc 0x9c92
000F9C72  7265              jc 0x9cd9
000F9C74  676973747265      imul si,[ebx+0x74],word 0x6572
000F9C7A  7320              jnc 0x9c9c
000F9C7C  636F6F            arpl [bx+0x6f],bp
000F9C7F  7264              jc 0x9ce5
000F9C81  6F                outsw
000F9C82  6E                outsb
000F9C83  6E                outsb
000F9C84  65657320          gs jnc 0x9ca8
000F9C88  736F              jnc 0x9cf9
000F9C8A  7572              jnz 0x9cfe
000F9C8C  6973006465        imul si,[bp+di+0x0],word 0x6564
000F9C91  7320              jnc 0x9cb3
000F9C93  746F              jz 0x9d04
000F9C95  7461              jz 0x9cf8
000F9C97  6C                insb
000F9C98  6973617469        imul si,[bp+di+0x61],word 0x6974
000F9C9D  6F                outsw
000F9C9E  6E                outsb
000F9C9F  7320              jnc 0x9cc1
000F9CA1  52                push dx
000F9CA2  4F                dec di
000F9CA3  53                push bx
000F9CA4  004D65            add [di+0x65],cl
000F9CA7  6D                insw
000F9CA8  6F                outsw
000F9CA9  6972652028        imul si,[bp+si+0x65],word 0x2820
000F9CAE  657272            gs jc 0x9d23
000F9CB1  657572            gs jnz 0x9d26
000F9CB4  206465            and [si+0x65],ah
000F9CB7  207061            and [bx+si+0x61],dh
000F9CBA  7269              jc 0x9d25
000F9CBC  7465              jz 0x9d23
000F9CBE  2900              sub [bx+si],ax
000F9CC0  50                push ax
000F9CC1  61                popa
000F9CC2  7469              jz 0x9d2d
000F9CC4  656E              gs outsb
000F9CC6  7465              jz 0x9d2d
000F9CC8  7A00              jpe 0x9cca
000F9CCA  4A                dec dx
000F9CCB  61                popa
000F9CCC  6E                outsb
000F9CCD  7669              jna 0x9d38
000F9CCF  657200            gs jc 0x9cd2
000F9CD2  46                inc si
000F9CD3  1B827672          sbb ax,[bp+si+0x7276]
000F9CD7  696572004D        imul sp,[di+0x72],word 0x4d00
000F9CDC  61                popa
000F9CDD  7273              jc 0x9d52
000F9CDF  004176            add [bx+di+0x76],al
000F9CE2  7269              jc 0x9d4d
000F9CE4  6C                insb
000F9CE5  004D61            add [di+0x61],cl
000F9CE8  69004A75          imul ax,[bx+si],word 0x754a
000F9CEC  696E004A75        imul bp,[bp+0x0],word 0x754a
000F9CF1  696C6C6574        imul bp,[si+0x6c],word 0x7465
000F9CF6  00416F            add [bx+di+0x6f],al
000F9CF9  1B967400          sbb dx,[bp+0x74]
000F9CFD  53                push bx
000F9CFE  657074            gs jo 0x9d75
000F9D01  656D              gs insw
000F9D03  627265            bound si,[bp+si+0x65]
000F9D06  004F63            add [bx+0x63],cl
000F9D09  746F              jz 0x9d7a
000F9D0B  627265            bound si,[bp+si+0x65]
000F9D0E  004E6F            add [bp+0x6f],cl
000F9D11  7665              jna 0x9d78
000F9D13  6D                insw
000F9D14  627265            bound si,[bp+si+0x65]
000F9D17  00441B            add [si+0x1b],al
000F9D1A  82                db 0x82
000F9D1B  63656D            arpl [di+0x6d],sp
000F9D1E  627265            bound si,[bp+si+0x65]
000F9D21  0011              add [bx+di],dl
000F9D23  3A12              cmp dl,[bp+si]
000F9D25  206C65            and [si+0x65],ch
000F9D28  2013              and [bp+di],dl
000F9D2A  200F              and [bx],cl
000F9D2C  2014              and [si],dl
000F9D2E  006475            add [si+0x75],ah
000F9D31  20636F            and [bp+di+0x6f],ah
000F9D34  6E                outsb
000F9D35  7472              jz 0x9da9
000F9D37  6F                outsw
000F9D38  6C                insb
000F9D39  657572            gs jnz 0x9dae
000F9D3C  2000              and [bx+si],al
000F9D3E  6465206C61        and [gs:si+0x61],ch
000F9D43  205241            and [bp+si+0x41],dl
000F9D46  4D                dec bp
000F9D47  2000              and [bx+si],al
000F9D49  6465206C61        and [gs:si+0x61],ch
000F9D4E  20736F            and [bp+di+0x6f],dh
000F9D51  7274              jc 0x9dc7
000F9D53  696520008A        imul sp,[di+0x20],word 0x8a00
000F9D58  0203              add al,[bp+di]
000F9D5A  005C55            add [si+0x55],bl
000F9D5D  6C                insb
000F9D5E  7469              jz 0x9dc9
000F9D60  6D                insw
000F9D61  6F                outsw
000F9D62  207573            and [di+0x73],dh
000F9D65  6F                outsw
000F9D66  20616C            and [bx+di+0x6c],ah
000F9D69  6C                insb
000F9D6A  65208A5C07        and [gs:bp+si+0x75c],cl
000F9D6F  0002              add [bp+si],al
000F9D71  035C41            add bx,[si+0x41]
000F9D74  6767696F726E61    imul bp,[edi+0x72],word 0x616e
000F9D7B  7265              jc 0x9de2
000F9D7D  206C61            and [si+0x61],ch
000F9D80  206461            and [si+0x61],ah
000F9D83  7461              jz 0x9de6
000F9D85  206520            and [di+0x20],ah
000F9D88  6C                insb
000F9D89  27                daa
000F9D8A  6F                outsw
000F9D8B  7261              jc 0x9dee
000F9D8D  5C                pop sp
000F9D8E  44                inc sp
000F9D8F  6566696E69726520  imul ebp,[gs:bp+0x69],dword 0x6c206572
         -6C
000F9D98  65204F70          and [gs:bx+0x70],cl
000F9D9C  7A69              jpe 0x9e07
000F9D9E  6F                outsw
000F9D9F  6E                outsb
000F9DA0  69205574          imul sp,[bx+si],word 0x7455
000F9DA4  656E              gs outsb
000F9DA6  7465              jz 0x9e0d
000F9DA8  2028              and [bx+si],ch
000F9DAA  53                push bx
000F9DAB  65207269          and [gs:bp+si+0x69],dh
000F9DAF  636869            arpl [bx+si+0x69],bp
000F9DB2  657374            gs jnc 0x9e29
000F9DB5  6F                outsw
000F9DB6  295C07            sub [si+0x7],bx
000F9DB9  07                pop es
000F9DBA  07                pop es
000F9DBB  004261            add [bp+si+0x61],al
000F9DBE  7474              jz 0x9e34
000F9DC0  657269            gs jc 0x9e2c
000F9DC3  65206461          and [gs:si+0x61],ah
000F9DC7  20736F            and [bp+di+0x6f],dh
000F9DCA  7374              jnc 0x9e40
000F9DCC  6974756972        imul si,[si+0x75],word 0x7269
000F9DD1  655C              gs pop sp
000F9DD3  005C50            add [si+0x50],bl
000F9DD6  726F              jc 0x9e47
000F9DD8  7661              jna 0x9e3b
000F9DDA  7265              jc 0x9e41
000F9DDC  206C61            and [si+0x61],ch
000F9DDF  207461            and [si+0x61],dh
000F9DE2  7374              jnc 0x9e58
000F9DE4  6965726120        imul sp,[di+0x72],word 0x2061
000F9DE9  6520696C          and [gs:bx+di+0x6c],ch
000F9DED  206D6F            and [di+0x6f],ch
000F9DF0  7573              jnz 0x9e65
000F9DF2  65005C49          add [gs:si+0x49],bl
000F9DF6  6E                outsb
000F9DF7  7365              jnc 0x9e5e
000F9DF9  7269              jc 0x9e64
000F9DFB  7265              jc 0x9e62
000F9DFD  20756E            and [di+0x6e],dh
000F9E00  206469            and [si+0x69],ah
000F9E03  7363              jnc 0x9e68
000F9E05  6F                outsw
000F9E06  206469            and [si+0x69],ah
000F9E09  205349            and [bp+di+0x49],dl
000F9E0C  53                push bx
000F9E0D  54                push sp
000F9E0E  45                inc bp
000F9E0F  4D                dec bp
000F9E10  41                inc cx
000F9E11  206E65            and [bp+0x65],ch
000F9E14  6C                insb
000F9E15  204472            and [si+0x72],al
000F9E18  6976652041        imul si,[bp+0x65],word 0x4120
000F9E1D  5C                pop sp
000F9E1E  50                push ax
000F9E1F  6F                outsw
000F9E20  69207072          imul sp,[bx+si],word 0x7270
000F9E24  656D              gs insw
000F9E26  657265            gs jc 0x9e8e
000F9E29  20756E            and [di+0x6e],dh
000F9E2C  207461            and [si+0x61],dh
000F9E2F  7374              jnc 0x9ea5
000F9E31  6F                outsw
000F9E32  005C45            add [si+0x45],bl
000F9E35  7272              jc 0x9ea9
000F9E37  6F                outsw
000F9E38  7265              jc 0x9e9f
000F9E3A  3A20              cmp ah,[bx+si]
000F9E3C  7365              jnc 0x9ea3
000F9E3E  676E              a32 outsb
000F9E40  61                popa
000F9E41  6C                insb
000F9E42  65206572          and [gs:di+0x72],ah
000F9E46  7261              jc 0x9ea9
000F9E48  746F              jz 0x9eb9
000F9E4A  206461            and [si+0x61],ah
000F9E4D  6C                insb
000F9E4E  6C                insb
000F9E4F  61                popa
000F9E50  20524F            and [bp+si+0x4f],dl
000F9E53  4D                dec bp
000F9E54  204573            and [di+0x73],al
000F9E57  7465              jz 0x9ebe
000F9E59  726E              jc 0x9ec9
000F9E5B  61                popa
000F9E5C  3A5C69            cmp bl,[si+0x69]
000F9E5F  6E                outsb
000F9E60  646972697A7A      imul si,[fs:bp+si+0x69],word 0x7a7a
000F9E66  6F                outsw
000F9E67  20524F            and [bp+si+0x4f],dl
000F9E6A  4D                dec bp
000F9E6B  203D              and [di],bh
000F9E6D  2010              and [bx+si],dl
000F9E6F  5C                pop sp
000F9E70  004572            add [di+0x72],al
000F9E73  726F              jc 0x9ee4
000F9E75  7265              jc 0x9edc
000F9E77  3A20              cmp ah,[bx+si]
000F9E79  005241            add [bp+si+0x41],dl
000F9E7C  4D                dec bp
000F9E7D  8D8C6100          lea cx,[si+0x61]
000F9E81  52                push dx
000F9E82  41                inc cx
000F9E83  4D                dec bp
000F9E84  207669            and [bp+0x69],dh
000F9E87  64656F            gs outsw
000F9E8A  8C6100            mov [bx+di+0x0],fs
000F9E8D  8B696E            mov bp,[bx+di+0x6e]
000F9E90  7465              jz 0x9ef7
000F9E92  7272              jc 0x9f06
000F9E94  757A              jnz 0x9f10
000F9E96  696F6E698C        imul bp,[bx+0x6e],word 0x8c69
000F9E9B  6F                outsw
000F9E9C  008B6469          add [bp+di+0x6964],cl
000F9EA0  206163            and [bx+di+0x63],ah
000F9EA3  636573            arpl [di+0x73],sp
000F9EA6  736F              jnc 0x9f17
000F9EA8  206469            and [si+0x69],ah
000F9EAB  7265              jc 0x9f12
000F9EAD  7474              jz 0x9f23
000F9EAF  6F                outsw
000F9EB0  20616C            and [bx+di+0x6c],ah
000F9EB3  6C                insb
000F9EB4  61                popa
000F9EB5  206D65            and [di+0x65],ch
000F9EB8  6D                insw
000F9EB9  6F                outsw
000F9EBA  7269              jc 0x9f25
000F9EBC  61                popa
000F9EBD  8C6F00            mov [bx+0x0],gs
000F9EC0  8B6465            mov sp,[si+0x65]
000F9EC3  6C                insb
000F9EC4  206469            and [si+0x69],ah
000F9EC7  7363              jnc 0x9f2c
000F9EC9  6F                outsw
000F9ECA  206F20            and [bx+0x20],ch
000F9ECD  647269            fs jc 0x9f39
000F9ED0  7665              jna 0x9f37
000F9ED2  8C6F00            mov [bx+0x0],gs
000F9ED5  7465              jz 0x9f3c
000F9ED7  6D                insw
000F9ED8  706F              jo 0x9f49
000F9EDA  7269              jc 0x9f45
000F9EDC  7A7A              jpe 0x9f58
000F9EDE  61                popa
000F9EDF  746F              jz 0x9f50
000F9EE1  7265              jc 0x9f48
000F9EE3  8C6F00            mov [bx+0x0],gs
000F9EE6  7265              jc 0x9f4d
000F9EE8  67697374726F      imul si,[ebx+0x74],word 0x6f72
000F9EEE  206469            and [si+0x69],ah
000F9EF1  207374            and [bp+di+0x74],dh
000F9EF4  61                popa
000F9EF5  746F              jz 0x9f66
000F9EF7  206465            and [si+0x65],ah
000F9EFA  6C                insb
000F9EFB  205349            and [bp+di+0x49],dl
000F9EFE  53                push bx
000F9EFF  54                push sp
000F9F00  45                inc bp
000F9F01  4D                dec bp
000F9F02  41                inc cx
000F9F03  8C6F00            mov [bx+0x0],gs
000F9F06  636C6F            arpl [si+0x6f],bp
000F9F09  636B20            arpl [bp+di+0x20],bp
000F9F0C  696E207465        imul bp,[bp+0x20],word 0x6574
000F9F11  6D                insw
000F9F12  706F              jo 0x9f83
000F9F14  207265            and [bp+si+0x65],dh
000F9F17  61                popa
000F9F18  6C                insb
000F9F19  658C6F00          mov [gs:bx+0x0],gs
000F9F1D  8B6465            mov sp,[si+0x65]
000F9F20  6C                insb
000F9F21  207669            and [bp+0x69],dh
000F9F24  64656F            gs outsw
000F9F27  8C6F00            mov [bx+0x0],gs
000F9F2A  706F              jo 0x9f9b
000F9F2C  7274              jc 0x9fa2
000F9F2E  61                popa
000F9F2F  207374            and [bp+di+0x74],dh
000F9F32  61                popa
000F9F33  6D                insw
000F9F34  7061              jo 0x9f97
000F9F36  6E                outsb
000F9F37  7465              jz 0x9f9e
000F9F39  8D8C6100          lea cx,[si+0x61]
000F9F3D  706F              jo 0x9fae
000F9F3F  7274              jc 0x9fb5
000F9F41  61                popa
000F9F42  207365            and [bp+di+0x65],dh
000F9F45  7269              jc 0x9fb0
000F9F47  61                popa
000F9F48  6C                insb
000F9F49  658D8C6100        lea cx,[gs:si+0x61]
000F9F4E  7265              jc 0x9fb5
000F9F50  676973747269      imul si,[ebx+0x74],word 0x6972
000F9F56  20636F            and [bp+di+0x6f],ah
000F9F59  6F                outsw
000F9F5A  7264              jc 0x9fc0
000F9F5C  696E617465        imul bp,[bp+0x61],word 0x6574
000F9F61  206D6F            and [di+0x6f],ch
000F9F64  7573              jnz 0x9fd9
000F9F66  658C6900          mov [gs:bx+di+0x0],gs
000F9F6A  7665              jna 0x9fd1
000F9F6C  7269              jc 0x9fd7
000F9F6E  66696361206C6574  imul esp,[bp+di+0x61],dword 0x74656c20
000F9F76  7475              jz 0x9fed
000F9F78  7261              jc 0x9fdb
000F9F7A  206465            and [si+0x65],ah
000F9F7D  6C                insb
000F9F7E  6C                insb
000F9F7F  61                popa
000F9F80  20524F            and [bp+si+0x4f],dl
000F9F83  53                push bx
000F9F84  206661            and [bp+0x61],ah
000F9F87  6C                insb
000F9F88  6C                insb
000F9F89  697461006D        imul si,[si+0x61],word 0x6d00
000F9F8E  656D              gs insw
000F9F90  6F                outsw
000F9F91  7269              jc 0x9ffc
000F9F93  61                popa
000F9F94  8C6120            mov [bx+di+0x20],fs
000F9F97  286572            sub [di+0x72],ah
000F9F9A  726F              jc 0xa00b
000F9F9C  7265              jc 0xa003
000F9F9E  206469            and [si+0x69],ah
000F9FA1  207061            and [bx+si+0x61],dh
000F9FA4  7269              jc 0xa00f
000F9FA6  7461              jz 0xa009
000F9FA8  2900              sub [bx+si],ax
000F9FAA  50                push ax
000F9FAB  7265              jc 0xa012
000F9FAD  676F              a32 outsw
000F9FAF  206174            and [bx+di+0x74],ah
000F9FB2  7465              jz 0xa019
000F9FB4  6E                outsb
000F9FB5  64657265          gs jc 0xa01e
000F9FB9  004765            add [bx+0x65],al
000F9FBC  6E                outsb
000F9FBD  6E                outsb
000F9FBE  61                popa
000F9FBF  696F004665        imul bp,[bx+0x0],word 0x6546
000F9FC4  626272            bound sp,[bp+si+0x72]
000F9FC7  61                popa
000F9FC8  696F004D61        imul bp,[bx+0x0],word 0x614d
000F9FCD  727A              jc 0xa049
000F9FCF  6F                outsw
000F9FD0  0002              add [bp+si],al
000F9FD2  096500            or [di+0x0],sp
000F9FD5  4D                dec bp
000F9FD6  61                popa
000F9FD7  6767696F004769    imul bp,[edi+0x0],word 0x6947
000F9FDE  7567              jnz 0xa047
000F9FE0  6E                outsb
000F9FE1  6F                outsw
000F9FE2  004C75            add [si+0x75],cl
000F9FE5  676C              a32 insb
000F9FE7  696F004167        imul bp,[bx+0x0],word 0x6741
000F9FEC  6F                outsw
000F9FED  7374              jnc 0xa063
000F9FEF  6F                outsw
000F9FF0  005365            add [bp+di+0x65],dl
000F9FF3  7474              jz 0xa069
000F9FF5  656D              gs insw
000F9FF7  627265            bound si,[bp+si+0x65]
000F9FFA  004F74            add [bx+0x74],cl
000F9FFD  746F              jz 0xa06e
000F9FFF  627265            bound si,[bp+si+0x65]
000FA002  004E6F            add [bp+0x6f],cl
000FA005  7665              jna 0xa06c
000FA007  6D                insw
000FA008  627265            bound si,[bp+si+0x65]
000FA00B  004469            add [si+0x69],al
000FA00E  63656D            arpl [di+0x6d],sp
000FA011  627265            bound si,[bp+si+0x65]
000FA014  0011              add [bx+di],dl
000FA016  3A12              cmp dl,[bp+si]
000FA018  206465            and [si+0x65],ah
000FA01B  6C                insb
000FA01C  2013              and [bp+di],dl
000FA01E  200F              and [bx],cl
000FA020  2014              and [si],dl
000FA022  00636F            add [bp+di+0x6f],ah
000FA025  6E                outsb
000FA026  7472              jz 0xa09a
000FA028  6F                outsw
000FA029  6C                insb
000FA02A  6C                insb
000FA02B  6F                outsw
000FA02C  7265              jc 0xa093
000FA02E  2000              and [bx+si],al
000FA030  206469            and [si+0x69],ah
000FA033  66657474          gs o32 jz 0xa0ab
000FA037  6F                outsw
000FA038  7300              jnc 0xa03a
000FA03A  206469            and [si+0x69],ah
000FA03D  205349            and [bp+di+0x49],dl
000FA040  53                push bx
000FA041  54                push sp
000FA042  45                inc bp
000FA043  4D                dec bp
000FA044  41                inc cx
000FA045  004942            add [bx+di+0x42],cl
000FA048  4D                dec bp
000FA049  55                push bp
000FA04A  53                push bx
000FA04B  204E4F            and [bp+0x4f],cl
000FA04E  4E                dec si
000FA04F  204341            and [bp+di+0x41],al
000FA052  52                push dx
000FA053  42                inc dx
000FA054  4F                dec di
000FA055  52                push dx
000FA056  55                push bp
000FA057  4E                dec si
000FA058  44                inc sp
000FA059  55                push bp
000FA05A  4D                dec bp
000FA05B  EAC90000FC        jmp 0xfc00:0xc9
000FA060  8A02              mov al,[bp+si]
000FA062  0300              add ax,[bx+si]
000FA064  5C                pop sp
000FA065  53                push bx
000FA066  656E              gs outsb
000FA068  61                popa
000FA069  7374              jnc 0xa0df
000FA06B  20616E            and [bx+di+0x6e],ah
000FA06E  761B              jna 0xa08b
000FA070  846E64            test [bp+0x64],ch
000FA073  208A5C07          and [bp+si+0x75c],cl
000FA077  0002              add [bp+si],al
000FA079  035C56            add bx,[si+0x56]
000FA07C  2E672E20731B      and [cs:ebx+0x1b],dh
000FA082  847474            test [si+0x74],dh
000FA085  206461            and [si+0x61],ah
000FA088  7475              jz 0xa0ff
000FA08A  6D                insw
000FA08B  206F63            and [bx+0x63],ch
000FA08E  682074            push word 0x7420
000FA091  69645C562E        imul sp,[si+0x5c],word 0x2e56
000FA096  672E207374        and [cs:ebx+0x74],dh
000FA09B  1B846C6C          sbb ax,[si+0x6c6c]
000FA09F  20696E            and [bx+di+0x6e],ch
000FA0A2  20616E            and [bx+di+0x6e],ah
000FA0A5  761B              jna 0xa0c2
000FA0A7  846E64            test [bp+0x64],ch
000FA0AA  61                popa
000FA0AB  7276              jc 0xa123
000FA0AD  1B847264          sbb ax,[si+0x6472]
000FA0B1  656E              gs outsb
000FA0B3  2028              and [bx+si],ch
000FA0B5  7669              jna 0xa120
000FA0B7  64206265          and [fs:bp+si+0x65],ah
000FA0BB  686F76            push word 0x766f
000FA0BE  295C07            sub [si+0x7],bx
000FA0C1  07                pop es
000FA0C2  07                pop es
000FA0C3  00562E            add [bp+0x2e],dl
000FA0C6  672E20616E        and [cs:ecx+0x6e],ah
000FA0CB  736C              jnc 0xa139
000FA0CD  7574              jnz 0xa143
000FA0CF  206E79            and [bp+0x79],ch
000FA0D2  61                popa
000FA0D3  206261            and [bp+si+0x61],ah
000FA0D6  7474              jz 0xa14c
000FA0D8  657269            gs jc 0xa144
000FA0DB  65725C            gs jc 0xa13a
000FA0DE  005C4B            add [si+0x4b],bl
000FA0E1  6F                outsw
000FA0E2  6E                outsb
000FA0E3  7472              jz 0xa157
000FA0E5  6F                outsw
000FA0E6  6C                insb
000FA0E7  6C                insb
000FA0E8  657261            gs jc 0xa14c
000FA0EB  207461            and [si+0x61],dh
000FA0EE  6E                outsb
000FA0EF  67656E            gs a32 outsb
000FA0F2  7462              jz 0xa156
000FA0F4  6F                outsw
000FA0F5  7264              jc 0xa15b
000FA0F7  206F63            and [bx+0x63],ch
000FA0FA  68206D            push word 0x6d20
000FA0FD  7573              jnz 0xa172
000FA0FF  005C53            add [si+0x53],bl
000FA102  1B847474          sbb ax,[si+0x7474]
000FA106  206920            and [bx+di+0x20],ch
000FA109  656E              gs outsb
000FA10B  205359            and [bp+di+0x59],dl
000FA10E  53                push bx
000FA10F  54                push sp
000FA110  45                inc bp
000FA111  4D                dec bp
000FA112  44                inc sp
000FA113  49                dec cx
000FA114  53                push bx
000FA115  4B                dec bx
000FA116  45                inc bp
000FA117  54                push sp
000FA118  54                push sp
000FA119  206920            and [bx+di+0x20],ch
000FA11C  656E              gs outsb
000FA11E  686574            push word 0x7465
000FA121  20415C            and [bx+di+0x5c],al
000FA124  54                push sp
000FA125  7279              jc 0xa1a0
000FA127  636B20            arpl [bp+di+0x20],bp
000FA12A  641B847265        sbb ax,[fs:si+0x6572]
000FA12F  667465            o32 jz 0xa197
000FA132  7220              jc 0xa154
000FA134  6E                outsb
000FA135  657220            gs jc 0xa158
000FA138  656E              gs outsb
000FA13A  207461            and [si+0x61],dh
000FA13D  6E                outsb
000FA13E  67656E            gs a32 outsb
000FA141  7400              jz 0xa143
000FA143  5C                pop sp
000FA144  46                inc si
000FA145  656C              gs insb
000FA147  3A02              cmp al,[bp+si]
000FA149  1B20              sbb sp,[bx+si]
000FA14B  52                push dx
000FA14C  4F                dec di
000FA14D  4D                dec bp
000FA14E  208B7375          and [bp+di+0x7573],cl
000FA152  6D                insw
000FA153  6D                insw
000FA154  61                popa
000FA155  206665            and [bp+0x65],ah
000FA158  6C                insb
000FA159  61                popa
000FA15A  6B746967          imul si,[si+0x69],byte +0x67
000FA15E  3A5C52            cmp bl,[si+0x52]
000FA161  4F                dec di
000FA162  4D                dec bp
000FA163  206164            and [bx+di+0x64],ah
000FA166  7265              jc 0xa1cd
000FA168  7373              jnc 0xa1dd
000FA16A  203D              and [di],bh
000FA16C  2010              and [bx+si],dl
000FA16E  5C                pop sp
000FA16F  004665            add [bp+0x65],al
000FA172  6C                insb
000FA173  3A20              cmp ah,[bx+si]
000FA175  46                inc si
000FA176  656C              gs insb
000FA178  61                popa
000FA179  6B746967          imul si,[si+0x69],byte +0x67
000FA17D  0020              add [bx+si],ah
000FA17F  02162052          add dl,[0x5220]
000FA183  41                inc cx
000FA184  4D                dec bp
000FA185  0020              add [bx+si],ah
000FA187  56                push si
000FA188  44                inc sp
000FA189  55                push bp
000FA18A  205241            and [bp+si+0x41],dl
000FA18D  4D                dec bp
000FA18E  0020              add [bx+si],ah
000FA190  61                popa
000FA191  7662              jna 0xa1f5
000FA193  726F              jc 0xa204
000FA195  7474              jz 0xa20b
000FA197  738B              jnc 0xa124
000FA199  0020              add [bx+si],ah
000FA19B  8B20              mov sp,[bx+si]
000FA19D  61                popa
000FA19E  7620              jna 0xa1c0
000FA1A0  646972656B74      imul si,[fs:bp+si+0x65],word 0x746b
000FA1A6  6D                insw
000FA1A7  696E6E6573        imul bp,[bp+0x6e],word 0x7365
000FA1AC  61                popa
000FA1AD  746B              jz 0xa21a
000FA1AF  6F                outsw
000FA1B0  6D                insw
000FA1B1  7374              jnc 0xa227
000FA1B3  0020              add [bx+si],ah
000FA1B5  6469736B8B20      imul si,[fs:bp+di+0x6b],word 0x208b
000FA1BB  656C              gs insb
000FA1BD  6C                insb
000FA1BE  657220            gs jc 0xa1e1
000FA1C1  736B              jnc 0xa22e
000FA1C3  6976656E68        imul si,[bp+0x65],word 0x686e
000FA1C8  657400            gs jz 0xa1cb
000FA1CB  2002              and [bp+si],al
000FA1CD  116C02            adc [si+0x2],bp
000FA1D0  1200              adc al,[bx+si]
000FA1D2  0213              add dl,[bp+di]
000FA1D4  0214              add dl,[si]
000FA1D6  0215              add dl,[di]
000FA1D8  0020              add [bx+si],ah
000FA1DA  0217              add dl,[bx]
000FA1DC  7469              jz 0xa247
000FA1DE  64736B            fs jnc 0xa24c
000FA1E1  6C                insb
000FA1E2  6F                outsw
000FA1E3  636B61            arpl [bp+di+0x61],bp
000FA1E6  0020              add [bx+si],ah
000FA1E8  56                push si
000FA1E9  44                inc sp
000FA1EA  55                push bp
000FA1EB  208B0002          and [bp+di+0x200],cl
000FA1EF  1302              adc ax,[bp+si]
000FA1F1  18706F            sbb [bx+si+0x6f],dh
000FA1F4  7274              jc 0xa26a
000FA1F6  0002              add [bp+si],al
000FA1F8  137365            adc si,[bp+di+0x65]
000FA1FB  7269              jc 0xa266
000FA1FD  656C              gs insb
000FA1FF  6C                insb
000FA200  706F              jo 0xa271
000FA202  7274              jc 0xa278
000FA204  007420            add [si+0x20],dh
000FA207  6D                insw
000FA208  7573              jnz 0xa27d
000FA20A  6B6F6F72          imul bp,[bx+0x6f],byte +0x72
000FA20E  64696E617402      imul bp,[fs:bp+0x61],word 0x274
000FA214  150020            adc ax,0x2000
000FA217  52                push dx
000FA218  4F                dec di
000FA219  53                push bx
000FA21A  208B7375          and [bp+di+0x7573],cl
000FA21E  6D                insw
000FA21F  6D                insw
000FA220  61                popa
000FA221  007420            add [si+0x20],dh
000FA224  6D                insw
000FA225  696E6E6520        imul bp,[bp+0x6e],word 0x2065
000FA22A  287061            sub [bx+si+0x61],dh
000FA22D  7269              jc 0xa298
000FA22F  7465              jz 0xa296
000FA231  7473              jz 0xa2a6
000FA233  66656C            gs o32 insb
000FA236  2900              sub [bx+si],ax
000FA238  56                push si
000FA239  2E672E207661      and [cs:esi+0x61],dh
000FA23F  6E                outsb
000FA240  7461              jz 0xa2a3
000FA242  006A61            add [bp+si+0x61],ch
000FA245  6E                outsb
000FA246  7561              jnz 0xa2a9
000FA248  7269              jc 0xa2b3
000FA24A  006665            add [bp+0x65],ah
000FA24D  627275            bound si,[bp+si+0x75]
000FA250  61                popa
000FA251  7269              jc 0xa2bc
000FA253  006D61            add [di+0x61],ch
000FA256  7273              jc 0xa2cb
000FA258  006170            add [bx+di+0x70],ah
000FA25B  7269              jc 0xa2c6
000FA25D  6C                insb
000FA25E  006D61            add [di+0x61],ch
000FA261  6A00              push byte +0x0
000FA263  6A75              push byte +0x75
000FA265  6E                outsb
000FA266  69006A75          imul ax,[bx+si],word 0x756a
000FA26A  6C                insb
000FA26B  69006175          imul ax,[bx+si],word 0x7561
000FA26F  677573            jnz 0xa2e5
000FA272  7469              jz 0xa2dd
000FA274  007365            add [bp+di+0x65],dh
000FA277  7074              jo 0xa2ed
000FA279  656D              gs insw
000FA27B  626572            bound sp,[di+0x72]
000FA27E  006F6B            add [bx+0x6b],ch
000FA281  746F              jz 0xa2f2
000FA283  626572            bound sp,[di+0x72]
000FA286  006E6F            add [bp+0x6f],ch
000FA289  7665              jna 0xa2f0
000FA28B  6D                insw
000FA28C  626572            bound sp,[di+0x72]
000FA28F  006465            add [si+0x65],ah
000FA292  63656D            arpl [di+0x6d],sp
000FA295  626572            bound sp,[di+0x72]
000FA298  0011              add [bx+di],dl
000FA29A  3A12              cmp dl,[bp+si]
000FA29C  206465            and [si+0x65],ah
000FA29F  6E                outsb
000FA2A0  2013              and [bp+di],dl
000FA2A2  200F              and [bx],cl
000FA2A4  2014              and [si],dl
000FA2A6  006B6F            add [bp+di+0x6f],ch
000FA2A9  6E                outsb
000FA2AA  7472              jz 0xa31e
000FA2AC  6F                outsw
000FA2AD  6C                insb
000FA2AE  6C                insb
000FA2AF  0000              add [bx+si],al
000FA2B1  0000              add [bx+si],al
000FA2B3  0000              add [bx+si],al
000FA2B5  0000              add [bx+si],al
000FA2B7  0000              add [bx+si],al
000FA2B9  0000              add [bx+si],al
000FA2BB  0000              add [bx+si],al
000FA2BD  0000              add [bx+si],al
000FA2BF  0000              add [bx+si],al
000FA2C1  0000              add [bx+si],al
000FA2C3  EABF1700FC        jmp 0xfc00:0x17bf
000FA2C8  0201              add al,[bx+di]
000FA2CA  56                push si
000FA2CB  0202              add al,[bp+si]
000FA2CD  00416D            add [bx+di+0x6d],al
000FA2D0  7374              jnc 0xa346
000FA2D2  7261              jc 0xa335
000FA2D4  64205043          and [fs:bx+si+0x43],dl
000FA2D8  2015              and [di],dl
000FA2DA  4B                dec bx
000FA2DB  2028              and [bx+si],ch
000FA2DD  0033              add [bp+di],dh
000FA2DF  2E3129            xor [cs:bx+di],bp
000FA2E2  2020              and [bx+si],ah
000FA2E4  005C28            add [si+0x28],bl
000FA2E7  6329              arpl [bx+di],bp
000FA2E9  3139              xor [bx+di],di
000FA2EB  3838              cmp [bx+si],bh
000FA2ED  20416D            and [bx+di+0x6d],al
000FA2F0  7374              jnc 0xa366
000FA2F2  7261              jc 0xa355
000FA2F4  6420706C          and [fs:bx+si+0x6c],dh
000FA2F8  635C00            arpl [si+0x0],bx
000FA2FB  4A                dec dx
000FA2FC  61                popa
000FA2FD  6E                outsb
000FA2FE  7561              jnz 0xa361
000FA300  7200              jc 0xa302
000FA302  46                inc si
000FA303  65627275          bound si,[gs:bp+si+0x75]
000FA307  61                popa
000FA308  7200              jc 0xa30a
000FA30A  4A                dec dx
000FA30B  756E              jnz 0xa37b
000FA30D  69004A75          imul ax,[bx+si],word 0x754a
000FA311  6C                insb
000FA312  69004F6B          imul ax,[bx+si],word 0x6b4f
000FA316  746F              jz 0xa387
000FA318  626572            bound sp,[di+0x72]
000FA31B  004170            add [bx+di+0x70],al
000FA31E  7269              jc 0xa389
000FA320  6C                insb
000FA321  004175            add [bx+di+0x75],al
000FA324  677573            jnz 0xa39a
000FA327  7400              jz 0xa329
000FA329  53                push bx
000FA32A  657074            gs jo 0xa3a1
000FA32D  020F              add cl,[bx]
000FA32F  004F6B            add [bx+0x6b],cl
000FA332  746F              jz 0xa3a3
000FA334  626572            bound sp,[di+0x72]
000FA337  004E6F            add [bp+0x6f],cl
000FA33A  7602              jna 0xa33e
000FA33C  0F004465          sldt [si+0x65]
000FA340  6302              arpl [bp+si],ax
000FA342  0F00656D          verr [di+0x6d]
000FA346  626572            bound sp,[di+0x72]
000FA349  004572            add [di+0x72],al
000FA34C  726F              jc 0xa3bd
000FA34E  7200              jc 0xa350
000FA350  696E746572        imul bp,[bp+0x74],word 0x7265
000FA355  7661              jna 0xa3b8
000FA357  6C                insb
000FA358  007469            add [si+0x69],dh
000FA35B  6D                insw
000FA35C  657200            gs jc 0xa35f
000FA35F  207379            and [bp+di+0x79],dh
000FA362  7374              jnc 0xa3d8
000FA364  656D              gs insw
000FA366  007374            add [bp+di+0x74],dh
000FA369  61                popa
000FA36A  7475              jz 0xa3e1
000FA36C  7300              jnc 0xa36e
000FA36E  7265              jc 0xa3d5
000FA370  676973746572      imul si,[ebx+0x74],word 0x7265
000FA376  005359            add [bp+di+0x59],dl
000FA379  53                push bx
000FA37A  54                push sp
000FA37B  45                inc bp
000FA37C  4D                dec bp
000FA37D  007265            add [bp+si+0x65],dh
000FA380  61                popa
000FA381  6C                insb
000FA382  007072            add [bx+si+0x72],dh
000FA385  696E746572        imul bp,[bp+0x74],word 0x7265
000FA38A  0020              add [bx+si],ah
000FA38C  7365              jnc 0xa3f3
000FA38E  7269              jc 0xa3f9
000FA390  656C              gs insb
000FA392  0020              add [bx+si],ah
000FA394  706F              jo 0xa405
000FA396  7274              jc 0xa40c
000FA398  0020              add [bx+si],ah
000FA39A  45                inc bp
000FA39B  7874              js 0xa411
000FA39D  65726E            gs jc 0xa40e
000FA3A0  006469            add [si+0x69],ah
000FA3A3  736B              jnc 0xa410
000FA3A5  2000              and [bx+si],al
000FA3A7  20524F            and [bp+si+0x4f],dl
000FA3AA  4D                dec bp
000FA3AB  206368            and [bp+di+0x68],ah
000FA3AE  65636B73          arpl [gs:bp+di+0x73],bp
000FA3B2  756D              jnz 0xa421
000FA3B4  004469            add [si+0x69],al
000FA3B7  7265              jc 0xa41e
000FA3B9  637420            arpl [si+0x20],si
000FA3BC  4D                dec bp
000FA3BD  656D              gs insw
000FA3BF  6F                outsw
000FA3C0  7279              jc 0xa43b
000FA3C2  204163            and [bx+di+0x63],al
000FA3C5  636573            arpl [di+0x73],sp
000FA3C8  7300              jnc 0xa3ca
000FA3CA  20436F            and [bp+di+0x6f],al
000FA3CD  6E                outsb
000FA3CE  7472              jz 0xa442
000FA3D0  6F                outsw
000FA3D1  6C                insb
000FA3D2  6C                insb
000FA3D3  657200            gs jc 0xa3d6
000FA3D6  49                dec cx
000FA3D7  6E                outsb
000FA3D8  7465              jz 0xa43f
000FA3DA  7272              jc 0xa44e
000FA3DC  7570              jnz 0xa44e
000FA3DE  7400              jz 0xa3e0
000FA3E0  0201              add al,[bx+di]
000FA3E2  7302              jnc 0xa3e6
000FA3E4  0200              add al,[bx+si]
000FA3E6  113A              adc [bp+si],di
000FA3E8  1220              adc ah,[bx+si]
000FA3EA  2013              and [bp+di],dl
000FA3EC  200F              and [bx],cl
000FA3EE  2014              and [si],dl
000FA3F0  0203              add al,[bp+di]
000FA3F2  005C55            add [si+0x55],bl
000FA3F5  7469              jz 0xa460
000FA3F7  6C                insb
000FA3F8  697A61646F        imul di,[bp+si+0x61],word 0x6f64
000FA3FD  20706F            and [bx+si+0x6f],dh
000FA400  7220              jc 0xa422
000FA402  1BA36C74          sbb sp,[bp+di+0x746c]
000FA406  696D612076        imul bp,[di+0x61],word 0x7620
000FA40B  657A20            gs jpe 0xa42e
000FA40E  61                popa
000FA40F  206C61            and [si+0x61],ch
000FA412  7320              jnc 0xa434
000FA414  113A              adc [bp+si],di
000FA416  1220              adc ah,[bx+si]
000FA418  656C              gs insb
000FA41A  2013              and [bp+di],dl
000FA41C  200F              and [bx],cl
000FA41E  2014              and [si],dl
000FA420  5C                pop sp
000FA421  07                pop es
000FA422  0002              add [bp+si],al
000FA424  035C92            add bx,[si-0x6e]
000FA427  93                xchg ax,bx
000FA428  6665636861        o32 arpl [gs:bx+si+0x61],bp
000FA42D  207920            and [bx+di+0x20],bh
000FA430  686F72            push word 0x726f
000FA433  61                popa
000FA434  5C                pop sp
000FA435  92                xchg ax,dx
000FA436  93                xchg ax,bx
000FA437  6F                outsw
000FA438  7063              jo 0xa49d
000FA43A  696F6E6573        imul bp,[bx+0x6e],word 0x7365
000FA43F  8E7573            mov segr6,[di+0x73]
000FA442  7561              jnz 0xa4a5
000FA444  7269              jc 0xa4af
000FA446  6F                outsw
000FA447  2028              and [bx+si],ch
000FA449  7369              jnc 0xa4b4
000FA44B  206573            and [di+0x73],ah
000FA44E  206E65            and [bp+0x65],ch
000FA451  636573            arpl [di+0x73],sp
000FA454  61                popa
000FA455  7269              jc 0xa4c0
000FA457  6F                outsw
000FA458  295C07            sub [si+0x7],bx
000FA45B  07                pop es
000FA45C  07                pop es
000FA45D  0092706F          add [bp+si+0x6f70],dl
000FA461  6E                outsb
000FA462  6761              a32 popa
000FA464  207069            and [bx+si+0x69],dh
000FA467  6C                insb
000FA468  657320            gs jnc 0xa48b
000FA46B  6E                outsb
000FA46C  7565              jnz 0xa4d3
000FA46E  7661              jna 0xa4d1
000FA470  735C              jnc 0xa4ce
000FA472  005C43            add [si+0x43],bl
000FA475  6F                outsw
000FA476  6D                insw
000FA477  7072              jo 0xa4eb
000FA479  7565              jnz 0xa4e0
000FA47B  626520            bound sp,[di+0x20]
000FA47E  656C              gs insb
000FA480  207465            and [si+0x65],dh
000FA483  636C61            arpl [si+0x61],bp
000FA486  646F              fs outsw
000FA488  207920            and [bx+di+0x20],bh
000FA48B  656C              gs insb
000FA48D  207261            and [bp+si+0x61],dh
000FA490  741B              jz 0xa4ad
000FA492  A26E00            mov [0x6e],al
000FA495  5C                pop sp
000FA496  49                dec cx
000FA497  6E                outsb
000FA498  7472              jz 0xa50c
000FA49A  6F                outsw
000FA49B  64757A            fs jnz 0xa518
000FA49E  636120            arpl [bx+di+0x20],sp
000FA4A1  756E              jnz 0xa511
000FA4A3  206469            and [si+0x69],ah
000FA4A6  7363              jnc 0xa50b
000FA4A8  6F                outsw
000FA4A9  8E7369            mov segr6,[bp+di+0x69]
000FA4AC  7374              jnc 0xa522
000FA4AE  656D              gs insw
000FA4B0  61                popa
000FA4B1  208C756E          and [si+0x6e75],cl
000FA4B5  6964616420        imul sp,[si+0x61],word 0x2064
000FA4BA  41                inc cx
000FA4BB  5C                pop sp
000FA4BC  7920              jns 0xa4de
000FA4BE  6C                insb
000FA4BF  7565              jnz 0xa526
000FA4C1  676F              a32 outsw
000FA4C3  207075            and [bx+si+0x75],dh
000FA4C6  6C                insb
000FA4C7  7365              jnc 0xa52e
000FA4C9  20756E            and [di+0x6e],dh
000FA4CC  61                popa
000FA4CD  207465            and [si+0x65],dh
000FA4D0  636C61            arpl [si+0x61],bp
000FA4D3  005C02            add [si+0x2],bl
000FA4D6  103A              adc [bp+si],bh
000FA4D8  207375            and [bp+di+0x75],dh
000FA4DB  6D                insw
000FA4DC  61                popa
000FA4DD  8E636F            mov fs,[bp+di+0x6f]
000FA4E0  6D                insw
000FA4E1  7072              jo 0xa555
000FA4E3  6F                outsw
000FA4E4  626163            bound sp,[bx+di+0x63]
000FA4E7  696F6E2069        imul bp,[bx+0x6e],word 0x6920
000FA4EC  6E                outsb
000FA4ED  636F72            arpl [bx+0x72],bp
000FA4F0  7265              jc 0xa557
000FA4F2  637461            arpl [si+0x61],si
000FA4F5  20656E            and [di+0x6e],ah
000FA4F8  20524F            and [bp+si+0x4f],dl
000FA4FB  4D                dec bp
000FA4FC  206578            and [di+0x78],ah
000FA4FF  7465              jz 0xa566
000FA501  726E              jc 0xa571
000FA503  61                popa
000FA504  3B20              cmp sp,[bx+si]
000FA506  646972656363      imul si,[fs:bp+si+0x65],word 0x6363
000FA50C  696F6E8E52        imul bp,[bx+0x6e],word 0x528e
000FA511  4F                dec di
000FA512  4D                dec bp
000FA513  203D              and [di],bh
000FA515  2010              and [bx+si],dl
000FA517  5C                pop sp
000FA518  0002              add [bp+si],al
000FA51A  103A              adc [bp+si],bh
000FA51C  206661            and [bp+0x61],ah
000FA51F  6C                insb
000FA520  6C                insb
000FA521  6F                outsw
000FA522  2000              and [bx+si],al
000FA524  8C5241            mov [bp+si+0x41],ss
000FA527  4D                dec bp
000FA528  8F00              pop word [bx+si]
000FA52A  8C5241            mov [bp+si+0x41],ss
000FA52D  4D                dec bp
000FA52E  8E8D5644          mov cs,[di+0x4456]
000FA532  55                push bp
000FA533  008B9169          add [bp+di+0x6991],cl
000FA537  6E                outsb
000FA538  7465              jz 0xa59f
000FA53A  7272              jc 0xa5ae
000FA53C  7570              jnz 0xa5ae
000FA53E  63696F            arpl [bx+di+0x6f],bp
000FA541  6E                outsb
000FA542  657300            gs jnc 0xa545
000FA545  8B916163          mov dx,[bx+di+0x6361]
000FA549  636573            arpl [di+0x73],sp
000FA54C  6F                outsw
000FA54D  206469            and [si+0x69],ah
000FA550  7265              jc 0xa5b7
000FA552  63746F            arpl [si+0x6f],si
000FA555  206120            and [bx+di+0x20],ah
000FA558  8D6D65            lea bp,[di+0x65]
000FA55B  6D                insw
000FA55C  6F                outsw
000FA55D  7269              jc 0xa5c8
000FA55F  61                popa
000FA560  008B9164          add [bp+di+0x6491],cl
000FA564  6973636F20        imul si,[bp+di+0x63],word 0x206f
000FA569  666C              o32 insb
000FA56B  657869            gs js 0xa5d7
000FA56E  626C65            bound bp,[si+0x65]
000FA571  206F20            and [bx+0x20],ch
000FA574  8C756E            mov [di+0x6e],segr6
000FA577  696461648E        imul sp,[si+0x61],word 0x8e64
000FA57C  646973636F00      imul si,[fs:bp+di+0x63],word 0x6f
000FA582  8B7465            mov si,[si+0x65]
000FA585  6D                insw
000FA586  706F              jo 0xa5f7
000FA588  7269              jc 0xa5f3
000FA58A  7A61              jpe 0xa5ed
000FA58C  646F              fs outsw
000FA58E  7220              jc 0xa5b0
000FA590  7072              jo 0xa604
000FA592  6F                outsw
000FA593  677261            jc 0xa5f7
000FA596  6D                insw
000FA597  61                popa
000FA598  626C65            bound bp,[si+0x65]
000FA59B  008B7265          add [bp+di+0x6572],cl
000FA59F  67697374726F      imul si,[ebx+0x74],word 0x6f72
000FA5A5  8E6573            mov fs,[di+0x73]
000FA5A8  7461              jz 0xa60b
000FA5AA  646F              fs outsw
000FA5AC  8F00              pop word [bx+si]
000FA5AE  8B7265            mov si,[bp+si+0x65]
000FA5B1  6C                insb
000FA5B2  6F                outsw
000FA5B3  6A8E              push byte -0x72
000FA5B5  7469              jz 0xa620
000FA5B7  656D              gs insw
000FA5B9  706F              jo 0xa62a
000FA5BB  207265            and [bp+si+0x65],dh
000FA5BE  61                popa
000FA5BF  6C                insb
000FA5C0  008B918D          add [bp+di-0x726f],cl
000FA5C4  56                push si
000FA5C5  44                inc sp
000FA5C6  55                push bp
000FA5C7  008C7075          add [si+0x7570],cl
000FA5CB  657274            gs jc 0xa642
000FA5CE  61                popa
000FA5CF  8E696D            mov gs,[bx+di+0x6d]
000FA5D2  7072              jo 0xa646
000FA5D4  65736F            gs jnc 0xa646
000FA5D7  7261              jc 0xa63a
000FA5D9  8F00              pop word [bx+si]
000FA5DB  8C7075            mov [bx+si+0x75],segr6
000FA5DE  657274            gs jc 0xa655
000FA5E1  61                popa
000FA5E2  207365            and [bp+di+0x65],dh
000FA5E5  7269              jc 0xa650
000FA5E7  658F00            pop word [gs:bx+si]
000FA5EA  656E              gs outsb
000FA5EC  206C6F            and [si+0x6f],ch
000FA5EF  7320              jnc 0xa611
000FA5F1  7265              jc 0xa658
000FA5F3  67697374726F      imul si,[ebx+0x74],word 0x6f72
000FA5F9  738E              jnc 0xa589
000FA5FB  636F6F            arpl [bx+0x6f],bp
000FA5FE  7264              jc 0xa664
000FA600  656E              gs outsb
000FA602  61                popa
000FA603  6461              fs popa
000FA605  7320              jnc 0xa627
000FA607  64656C            gs insb
000FA60A  207261            and [bp+si+0x61],dh
000FA60D  746F              jz 0xa67e
000FA60F  6E                outsb
000FA610  006469            add [si+0x69],ah
000FA613  207375            and [bp+di+0x75],dh
000FA616  6D                insw
000FA617  61                popa
000FA618  206469            and [si+0x69],ah
000FA61B  20636F            and [bp+di+0x6f],ah
000FA61E  6D                insw
000FA61F  7072              jo 0xa693
000FA621  6F                outsw
000FA622  626163            bound sp,[bx+di+0x63]
000FA625  696F6E208B        imul bp,[bx+0x6e],word 0x8b20
000FA62A  52                push dx
000FA62B  4F                dec di
000FA62C  53                push bx
000FA62D  206465            and [si+0x65],ah
000FA630  90                nop
000FA631  008C6D65          add [si+0x656d],cl
000FA635  6D                insw
000FA636  6F                outsw
000FA637  7269              jc 0xa6a2
000FA639  61                popa
000FA63A  205241            and [bp+si+0x41],dl
000FA63D  4D                dec bp
000FA63E  2028              and [bx+si],ch
000FA640  657272            gs jc 0xa6b5
000FA643  6F                outsw
000FA644  728E              jc 0xa5d4
000FA646  7061              jo 0xa6a9
000FA648  7269              jc 0xa6b3
000FA64A  6461              fs popa
000FA64C  642900            sub [fs:bx+si],ax
000FA64F  92                xchg ax,dx
000FA650  657370            gs jnc 0xa6c3
000FA653  657265            gs jc 0xa6bb
000FA656  0000              add [bx+si],al
000FA658  0000              add [bx+si],al
000FA65A  0000              add [bx+si],al
000FA65C  0000              add [bx+si],al
000FA65E  0000              add [bx+si],al
000FA660  124504            adc al,[di+0x4]
000FA663  07                pop es
000FA664  0A0E1FB8          or cl,[0xb81f]
000FA668  2602CD            es add cl,ch
000FA66B  1532E4            adc ax,0xe432
000FA66E  33D2              xor dx,dx
000FA670  CD14              int 0x14
000FA672  B82702            mov ax,0x227
000FA675  CD15              int 0x15
000FA677  32E4              xor ah,ah
000FA679  42                inc dx
000FA67A  CD14              int 0x14
000FA67C  B402              mov ah,0x2
000FA67E  CD1A              int 0x1a
000FA680  8AC6              mov al,dh
000FA682  E82800            call 0xa6ad
000FA685  F6266026          mul byte [0x2660]
000FA689  8BD8              mov bx,ax
000FA68B  8AC1              mov al,cl
000FA68D  E81D00            call 0xa6ad
000FA690  F7266126          mul word [0x2661]
000FA694  03D8              add bx,ax
000FA696  8AC5              mov al,ch
000FA698  E81200            call 0xa6ad
000FA69B  8BC8              mov cx,ax
000FA69D  F6266326          mul byte [0x2663]
000FA6A1  03D8              add bx,ax
000FA6A3  83D100            adc cx,byte +0x0
000FA6A6  8BD3              mov dx,bx
000FA6A8  B401              mov ah,0x1
000FA6AA  CD1A              int 0x1a
000FA6AC  C3                ret
000FA6AD  53                push bx
000FA6AE  51                push cx
000FA6AF  8AD8              mov bl,al
000FA6B1  80E30F            and bl,0xf
000FA6B4  B104              mov cl,0x4
000FA6B6  D2E8              shr al,cl
000FA6B8  F6266426          mul byte [0x2664]
000FA6BC  02C3              add al,bl
000FA6BE  59                pop cx
000FA6BF  5B                pop bx
000FA6C0  C3                ret
000FA6C1  0000              add [bx+si],al
000FA6C3  0000              add [bx+si],al
000FA6C5  0000              add [bx+si],al
000FA6C7  0000              add [bx+si],al
000FA6C9  0000              add [bx+si],al
000FA6CB  0000              add [bx+si],al
000FA6CD  0000              add [bx+si],al
000FA6CF  0000              add [bx+si],al
000FA6D1  0000              add [bx+si],al
000FA6D3  0000              add [bx+si],al
000FA6D5  0000              add [bx+si],al
000FA6D7  0000              add [bx+si],al
000FA6D9  0000              add [bx+si],al
000FA6DB  0000              add [bx+si],al
000FA6DD  0000              add [bx+si],al
000FA6DF  0000              add [bx+si],al
000FA6E1  0000              add [bx+si],al
000FA6E3  0000              add [bx+si],al
000FA6E5  0000              add [bx+si],al
000FA6E7  0000              add [bx+si],al
000FA6E9  0000              add [bx+si],al
000FA6EB  0000              add [bx+si],al
000FA6ED  0000              add [bx+si],al
000FA6EF  0000              add [bx+si],al
000FA6F1  00EA              add dl,ch
000FA6F3  E50A              in ax,0xa
000FA6F5  00FC              add ah,bh
000FA6F7  2EAD              cs lodsw
000FA6F9  8AD4              mov dl,ah
000FA6FB  EE                out dx,al
000FA6FC  C3                ret
000FA6FD  BF0100            mov di,0x1
000FA700  EB07              jmp short 0xa709
000FA702  2EAC              cs lodsb
000FA704  8AD0              mov dl,al
000FA706  EC                in al,dx
000FA707  33FF              xor di,di
000FA709  2EAC              cs lodsb
000FA70B  98                cbw
000FA70C  8BC8              mov cx,ax
000FA70E  2EAD              cs lodsw
000FA710  8AD0              mov dl,al
000FA712  8AC4              mov al,ah
000FA714  EE                out dx,al
000FA715  FEC4              inc ah
000FA717  03D7              add dx,di
000FA719  2EAC              cs lodsb
000FA71B  EE                out dx,al
000FA71C  2BD7              sub dx,di
000FA71E  E2F2              loop 0xa712
000FA720  33FF              xor di,di
000FA722  C3                ret
000FA723  0000              add [bx+si],al
000FA725  0000              add [bx+si],al
000FA727  0000              add [bx+si],al
000FA729  EAAC0F00FC        jmp 0xfc00:0xfac
000FA72E  3E27              ds daa
000FA730  7827              js 0xa759
000FA732  94                xchg ax,sp
000FA733  27                daa
000FA734  AC                lodsb
000FA735  27                daa
000FA736  E427              in al,0x27
000FA738  C8275E27          enter 0x5e27,0x27
000FA73C  3E27              ds daa
000FA73E  C8225238          enter 0x5222,0x38
000FA742  56                push si
000FA743  386838            cmp [bx+si+0x38],ch
000FA746  98                cbw
000FA747  38AC38C6          cmp [si-0x39c8],ch
000FA74B  38F1              cmp cl,dh
000FA74D  3818              cmp [bx+si],bl
000FA74F  39B239E5          cmp [bp+si-0x1ac7],si
000FA753  39F2              cmp dx,si
000FA755  39F9              cmp cx,di
000FA757  3901              cmp [bx+di],ax
000FA759  3A07              cmp al,[bx]
000FA75B  3A0E3AC8          cmp cl,[0xc83a]
000FA75F  228C2990          and cl,[si-0x6fd7]
000FA763  29A82901          sub [bx+si+0x129],bp
000FA767  2A1C              sub bl,[si]
000FA769  2A3C              sub bh,[si]
000FA76B  2A882AC7          sub cl,[bx+si-0x38d6]
000FA76F  2AF5              sub dh,ch
000FA771  2B20              sub sp,[bx+si]
000FA773  2C32              sub al,0x32
000FA775  2C2D              sub al,0x2d
000FA777  2CC8              sub al,0xc8
000FA779  22571D            and dl,[bx+0x1d]
000FA77C  5B                pop bx
000FA77D  1D701D            sbb ax,0x1d70
000FA780  BC1DD4            mov sp,0xd41d
000FA783  1DF41D            sbb ax,0x1df4
000FA786  331E711E          xor bx,[0x1e71]
000FA78A  BA1F15            mov dx,0x151f
000FA78D  2023              and [bp+di],ah
000FA78F  2030              and [bx+si],dh
000FA791  203A              and [bp+si],bh
000FA793  20C8              and al,cl
000FA795  226020            and ah,[bx+si+0x20]
000FA798  64207820          and [fs:bx+si+0x20],bh
000FA79C  C420              les sp,[bx+si]
000FA79E  DF20              fbld tword [bx+si]
000FA7A0  0021              add [bx+di],ah
000FA7A2  43                inc bx
000FA7A3  217021            and [bx+si+0x21],si
000FA7A6  43                inc bx
000FA7A7  229922A7          and bl,[bx+di-0x58de]
000FA7AB  22C8              and cl,al
000FA7AD  226A18            and ch,[bp+si+0x18]
000FA7B0  6E                outsb
000FA7B1  188318D7          sbb [bp+di-0x28e8],al
000FA7B5  18F6              sbb dh,dh
000FA7B7  1811              sbb [bx+di],dl
000FA7B9  194F19            sbb [bx+0x19],cx
000FA7BC  6C                insb
000FA7BD  192D              sbb [di],bp
000FA7BF  1A551A            sbb dl,[di+0x1a]
000FA7C2  721A              jc 0xa7de
000FA7C4  631A              arpl [bp+si],bx
000FA7C6  7A1A              jpe 0xa7e2
000FA7C8  C822811A          enter 0x8122,0x1a
000FA7CC  851A              test [bp+si],bx
000FA7CE  9C                pushf
000FA7CF  1AEF              sbb ch,bh
000FA7D1  1A11              sbb dl,[bx+di]
000FA7D3  1B34              sbb si,[si]
000FA7D5  1B841BC8          sbb ax,[si-0x37e5]
000FA7D9  1BCA              sbb cx,dx
000FA7DB  1C22              sbb al,0x22
000FA7DD  1D2F1D            sbb ax,0x1d2f
000FA7E0  3E1D491D          ds sbb ax,0x1d49
000FA7E4  E023              loopne 0xa809
000FA7E6  E623              out 0x23,al
000FA7E8  F32323            rep and sp,[bp+di]
000FA7EB  245E              and al,0x5e
000FA7ED  2473              and al,0x73
000FA7EF  2495              and al,0x95
000FA7F1  24D4              and al,0xd4
000FA7F3  2419              and al,0x19
000FA7F5  254228            and ax,0x2842
000FA7F8  9A28A728AE        call 0xae28:0xa728
000FA7FD  28B128B5          sub [bx+di-0x4ad8],dh
000FA801  28BA28BE          sub [bp+si-0x41d8],bh
000FA805  28C7              sub bh,al
000FA807  28D7              sub bh,dl
000FA809  28E3              sub bl,ah
000FA80B  2800              sub [bx+si],al
000FA80D  0000              add [bx+si],al
000FA80F  0000              add [bx+si],al
000FA811  0000              add [bx+si],al
000FA813  0000              add [bx+si],al
000FA815  0000              add [bx+si],al
000FA817  0000              add [bx+si],al
000FA819  0000              add [bx+si],al
000FA81B  0000              add [bx+si],al
000FA81D  0000              add [bx+si],al
000FA81F  0000              add [bx+si],al
000FA821  0000              add [bx+si],al
000FA823  0000              add [bx+si],al
000FA825  0000              add [bx+si],al
000FA827  0000              add [bx+si],al
000FA829  0000              add [bx+si],al
000FA82B  0000              add [bx+si],al
000FA82D  00EA              add dl,ch
000FA82F  0011              add [bx+di],dl
000FA831  00FC              add ah,bh
000FA833  EA721100FC        jmp 0xfc00:0x1172
000FA838  EA223100FC        jmp 0xfc00:0x3122
000FA83D  EAD61200FC        jmp 0xfc00:0x12d6
000FA842  656E              gs outsb
000FA844  65726F            gs jc 0xa8b6
000FA847  006665            add [bp+0x65],ah
000FA84A  627265            bound si,[bp+si+0x65]
000FA84D  726F              jc 0xa8be
000FA84F  006D61            add [di+0x61],ch
000FA852  727A              jc 0xa8ce
000FA854  6F                outsw
000FA855  006162            add [bx+di+0x62],ah
000FA858  7269              jc 0xa8c3
000FA85A  6C                insb
000FA85B  006D61            add [di+0x61],ch
000FA85E  796F              jns 0xa8cf
000FA860  006A75            add [bp+si+0x75],ch
000FA863  6E                outsb
000FA864  696F006A75        imul bp,[bx+0x0],word 0x756a
000FA869  6C                insb
000FA86A  696F006167        imul bp,[bx+0x0],word 0x6761
000FA86F  6F                outsw
000FA870  7374              jnc 0xa8e6
000FA872  6F                outsw
000FA873  007365            add [bp+di+0x65],dh
000FA876  7469              jz 0xa8e1
000FA878  656D              gs insw
000FA87A  627265            bound si,[bp+si+0x65]
000FA87D  006F63            add [bx+0x63],ch
000FA880  7475              jz 0xa8f7
000FA882  627265            bound si,[bp+si+0x65]
000FA885  006E6F            add [bp+0x6f],ch
000FA888  7669              jna 0xa8f3
000FA88A  656D              gs insw
000FA88C  627265            bound si,[bp+si+0x65]
000FA88F  006469            add [si+0x69],ah
000FA892  636965            arpl [bx+di+0x65],bp
000FA895  6D                insw
000FA896  627265            bound si,[bp+si+0x65]
000FA899  0011              add [bx+di],dl
000FA89B  3A12              cmp dl,[bp+si]
000FA89D  20656C            and [di+0x6c],ah
000FA8A0  2013              and [bp+di],dl
000FA8A2  200F              and [bx],cl
000FA8A4  2014              and [si],dl
000FA8A6  00656E            add [di+0x6e],ah
000FA8A9  20656C            and [di+0x6c],ah
000FA8AC  2000              and [bx+si],al
000FA8AE  656E              gs outsb
000FA8B0  206C61            and [si+0x61],ch
000FA8B3  2000              and [bx+si],al
000FA8B5  206465            and [si+0x65],ah
000FA8B8  2000              and [bx+si],al
000FA8BA  206465            and [si+0x65],ah
000FA8BD  6C                insb
000FA8BE  207369            and [bp+di+0x69],dh
000FA8C1  7374              jnc 0xa937
000FA8C3  656D              gs insw
000FA8C5  61                popa
000FA8C6  00636F            add [bp+di+0x6f],ah
000FA8C9  6E                outsb
000FA8CA  7472              jz 0xa93e
000FA8CC  6F                outsw
000FA8CD  6C                insb
000FA8CE  61                popa
000FA8CF  646F              fs outsw
000FA8D1  7220              jc 0xa8f3
000FA8D3  64652000          and [gs:bx+si],al
000FA8D7  50                push ax
000FA8D8  6F                outsw
000FA8D9  7220              jc 0xa8fb
000FA8DB  6661              popad
000FA8DD  766F              jna 0xa94e
000FA8DF  722C              jc 0xa90d
000FA8E1  2000              and [bx+si],al
000FA8E3  657374            gs jnc 0xa95a
000FA8E6  61                popa
000FA8E7  626C65            bound bp,[si+0x65]
000FA8EA  7A63              jpe 0xa94f
000FA8EC  61                popa
000FA8ED  2000              and [bx+si],al
000FA8EF  0000              add [bx+si],al
000FA8F1  0000              add [bx+si],al
000FA8F3  0000              add [bx+si],al
000FA8F5  0000              add [bx+si],al
000FA8F7  0000              add [bx+si],al
000FA8F9  0000              add [bx+si],al
000FA8FB  0000              add [bx+si],al
000FA8FD  0000              add [bx+si],al
000FA8FF  0000              add [bx+si],al
000FA901  0000              add [bx+si],al
000FA903  0000              add [bx+si],al
000FA905  0000              add [bx+si],al
000FA907  0000              add [bx+si],al
000FA909  0000              add [bx+si],al
000FA90B  0000              add [bx+si],al
000FA90D  0000              add [bx+si],al
000FA90F  0000              add [bx+si],al
000FA911  0000              add [bx+si],al
000FA913  0000              add [bx+si],al
000FA915  0000              add [bx+si],al
000FA917  0000              add [bx+si],al
000FA919  0000              add [bx+si],al
000FA91B  0000              add [bx+si],al
000FA91D  0000              add [bx+si],al
000FA91F  0000              add [bx+si],al
000FA921  0000              add [bx+si],al
000FA923  0000              add [bx+si],al
000FA925  0000              add [bx+si],al
000FA927  0000              add [bx+si],al
000FA929  0000              add [bx+si],al
000FA92B  0000              add [bx+si],al
000FA92D  0000              add [bx+si],al
000FA92F  0000              add [bx+si],al
000FA931  0000              add [bx+si],al
000FA933  0000              add [bx+si],al
000FA935  0000              add [bx+si],al
000FA937  0000              add [bx+si],al
000FA939  0000              add [bx+si],al
000FA93B  0000              add [bx+si],al
000FA93D  0000              add [bx+si],al
000FA93F  0000              add [bx+si],al
000FA941  0000              add [bx+si],al
000FA943  0000              add [bx+si],al
000FA945  0000              add [bx+si],al
000FA947  0000              add [bx+si],al
000FA949  0000              add [bx+si],al
000FA94B  0000              add [bx+si],al
000FA94D  0000              add [bx+si],al
000FA94F  0000              add [bx+si],al
000FA951  0000              add [bx+si],al
000FA953  0000              add [bx+si],al
000FA955  0000              add [bx+si],al
000FA957  0000              add [bx+si],al
000FA959  0000              add [bx+si],al
000FA95B  0000              add [bx+si],al
000FA95D  0000              add [bx+si],al
000FA95F  0000              add [bx+si],al
000FA961  0000              add [bx+si],al
000FA963  0000              add [bx+si],al
000FA965  0000              add [bx+si],al
000FA967  0000              add [bx+si],al
000FA969  0000              add [bx+si],al
000FA96B  0000              add [bx+si],al
000FA96D  0000              add [bx+si],al
000FA96F  0000              add [bx+si],al
000FA971  0000              add [bx+si],al
000FA973  0000              add [bx+si],al
000FA975  0000              add [bx+si],al
000FA977  0000              add [bx+si],al
000FA979  0000              add [bx+si],al
000FA97B  0000              add [bx+si],al
000FA97D  0000              add [bx+si],al
000FA97F  0000              add [bx+si],al
000FA981  0000              add [bx+si],al
000FA983  0000              add [bx+si],al
000FA985  0000              add [bx+si],al
000FA987  EA5F1100FC        jmp 0xfc00:0x115f
000FA98C  8A02              mov al,[bp+si]
000FA98E  0300              add ax,[bx+si]
000FA990  5C                pop sp
000FA991  5A                pop dx
000FA992  756C              jnz 0xaa00
000FA994  65747A            gs jz 0xaa11
000FA997  7420              jz 0xa9b9
000FA999  62656E            bound sp,[di+0x6e]
000FA99C  7574              jnz 0xaa12
000FA99E  7A74              jpe 0xaa14
000FA9A0  20756D            and [di+0x6d],dh
000FA9A3  208A5C07          and [bp+si+0x75c],cl
000FA9A7  0002              add [bp+si],al
000FA9A9  035C8B            add bx,[si-0x75]
000FA9AC  44                inc sp
000FA9AD  61                popa
000FA9AE  7475              jz 0xaa25
000FA9B0  6D                insw
000FA9B1  20756E            and [di+0x6e],dh
000FA9B4  64205568          and [fs:di+0x68],dl
000FA9B8  727A              jc 0xaa34
000FA9BA  656974206569      imul si,[gs:si+0x20],word 0x6965
000FA9C0  6E                outsb
000FA9C1  7374              jnc 0xaa37
000FA9C3  656C              gs insb
000FA9C5  6C                insb
000FA9C6  656E              gs outsb
000FA9C8  5C                pop sp
000FA9C9  8B6469            mov sp,[si+0x69]
000FA9CC  65205374          and [gs:bp+di+0x74],dl
000FA9D0  61                popa
000FA9D1  6E                outsb
000FA9D2  6461              fs popa
000FA9D4  7264              jc 0xaa3a
000FA9D6  2D4569            sub ax,0x6945
000FA9D9  6E                outsb
000FA9DA  7374              jnc 0xaa50
000FA9DC  656C              gs insb
000FA9DE  6C                insb
000FA9DF  756E              jnz 0xaa4f
000FA9E1  67201B            and [ebx],bl
000FA9E4  846E64            test [bp+0x64],ch
000FA9E7  65726E            gs jc 0xaa58
000FA9EA  2028              and [bx+si],ch
000FA9EC  7765              ja 0xaa53
000FA9EE  6E                outsb
000FA9EF  6E                outsb
000FA9F0  206765            and [bx+0x65],ah
000FA9F3  771B              ja 0xaa10
000FA9F5  816E736368        sub word [bp+0x73],0x6863
000FA9FA  7429              jz 0xaa25
000FA9FC  5C                pop sp
000FA9FD  07                pop es
000FA9FE  07                pop es
000FA9FF  07                pop es
000FAA00  008B6E65          add [bp+di+0x656e],cl
000FAA04  7565              jnz 0xaa6b
000FAA06  204261            and [bp+si+0x61],al
000FAA09  7474              jz 0xaa7f
000FAA0B  657269            gs jc 0xaa77
000FAA0E  656E              gs outsb
000FAA10  206569            and [di+0x69],ah
000FAA13  6E                outsb
000FAA14  7365              jnc 0xaa7b
000FAA16  747A              jz 0xaa92
000FAA18  656E              gs outsb
000FAA1A  5C                pop sp
000FAA1B  005C54            add [si+0x54],bl
000FAA1E  61                popa
000FAA1F  7374              jnc 0xaa95
000FAA21  61                popa
000FAA22  7475              jz 0xaa99
000FAA24  7220              jc 0xaa46
000FAA26  756E              jnz 0xaa96
000FAA28  64204D61          and [fs:di+0x61],cl
000FAA2C  7573              jnz 0xaaa1
000FAA2E  201B              and [bp+di],bl
000FAA30  8162657270        and word [bp+si+0x65],0x7072
000FAA35  721B              jc 0xaa52
000FAA37  8166656E00        and word [bp+0x65],0x6e
000FAA3C  5C                pop sp
000FAA3D  4C                dec sp
000FAA3E  6567656E          gs a32 outsb
000FAA42  205369            and [bp+di+0x69],dl
000FAA45  65206569          and [gs:di+0x69],ah
000FAA49  6E                outsb
000FAA4A  65205359          and [gs:bp+di+0x59],dl
000FAA4E  53                push bx
000FAA4F  54                push sp
000FAA50  45                inc bp
000FAA51  4D                dec bp
000FAA52  2D4469            sub ax,0x6944
000FAA55  736B              jnc 0xaac2
000FAA57  657474            gs jz 0xaace
000FAA5A  6520696E          and [gs:bx+di+0x6e],ch
000FAA5E  204C61            and [si+0x61],cl
000FAA61  7566              jnz 0xaac9
000FAA63  7765              ja 0xaaca
000FAA65  726B              jc 0xaad2
000FAA67  20415C            and [bx+di+0x5c],al
000FAA6A  44                inc sp
000FAA6B  61                popa
000FAA6C  6E                outsb
000FAA6D  6E                outsb
000FAA6E  206265            and [bp+si+0x65],ah
000FAA71  6C                insb
000FAA72  6965626967        imul sp,[di+0x62],word 0x6769
000FAA77  65205461          and [gs:si+0x61],dl
000FAA7B  7374              jnc 0xaaf1
000FAA7D  65206472          and [gs:si+0x72],ah
000FAA81  1B81636B          sbb ax,[bx+di+0x6b63]
000FAA85  656E              gs outsb
000FAA87  005C46            add [si+0x46],bl
000FAA8A  65686C65          gs push word 0x656c
000FAA8E  723A              jc 0xaaca
000FAA90  204661            and [bp+0x61],al
000FAA93  6C                insb
000FAA94  7363              jnc 0xaaf9
000FAA96  686520            push word 0x2065
000FAA99  50                push ax
000FAA9A  7275              jc 0xab11
000FAA9C  65667375          gs o32 jnc 0xab15
000FAAA0  6D                insw
000FAAA1  6D                insw
000FAAA2  65206265          and [gs:bp+si+0x65],ah
000FAAA6  69206578          imul sp,[bx+si],word 0x7865
000FAAAA  7465              jz 0xab11
000FAAAC  726E              jc 0xab1c
000FAAAE  656D              gs insw
000FAAB0  20524F            and [bp+si+0x4f],dl
000FAAB3  4D                dec bp
000FAAB4  3A5C52            cmp bl,[si+0x52]
000FAAB7  4F                dec di
000FAAB8  4D                dec bp
000FAAB9  2D4164            sub ax,0x6441
000FAABC  7265              jc 0xab23
000FAABE  7373              jnc 0xab33
000FAAC0  65203D            and [gs:di],bh
000FAAC3  2010              and [bx+si],dl
000FAAC5  5C                pop sp
000FAAC6  004665            add [bp+0x65],al
000FAAC9  686C65            push word 0x656c
000FAACC  7200              jc 0xaace
000FAACE  8C02              mov [bp+si],es
000FAAD0  16                push ss
000FAAD1  205241            and [bp+si+0x41],dl
000FAAD4  4D                dec bp
000FAAD5  008C5644          add [si+0x4456],cl
000FAAD9  55                push bp
000FAADA  205241            and [bp+si+0x41],dl
000FAADD  4D                dec bp
000FAADE  008C0220          add [si+0x2002],cl
000FAAE2  021F              add bl,[bx]
000FAAE4  008C444D          add [si+0x4d44],cl
000FAAE8  41                inc cx
000FAAE9  021F              add bl,[bx]
000FAAEB  008C466C          add [si+0x6c46],cl
000FAAEF  6F                outsw
000FAAF0  7070              jo 0xab62
000FAAF2  792D              jns 0xab21
000FAAF4  44                inc sp
000FAAF5  69736B2D43        imul si,[bp+di+0x6b],word 0x432d
000FAAFA  6F                outsw
000FAAFB  6E                outsb
000FAAFC  7472              jz 0xab70
000FAAFE  6F                outsw
000FAAFF  6C                insb
000FAB00  6C                insb
000FAB01  657220            gs jc 0xab24
000FAB04  6F                outsw
000FAB05  6465728C          gs jc 0xaa95
000FAB09  4C                dec sp
000FAB0A  61                popa
000FAB0B  7566              jnz 0xab73
000FAB0D  7765              ja 0xab74
000FAB0F  726B              jc 0xab7c
000FAB11  008C5A65          add [si+0x655a],cl
000FAB15  6974676562        imul si,[si+0x67],word 0x6265
000FAB1A  657200            gs jc 0xab1d
000FAB1D  8C02              mov [bp+si],es
000FAB1F  16                push ss
000FAB20  205374            and [bp+di+0x74],dl
000FAB23  61                popa
000FAB24  7475              jz 0xab9b
000FAB26  732D              jnc 0xab55
000FAB28  52                push dx
000FAB29  65676973746572    imul si,[gs:ebx+0x74],word 0x7265
000FAB30  0020              add [bx+si],ah
000FAB32  696E206465        imul bp,[bp+0x20],word 0x6564
000FAB37  7220              jc 0xab59
000FAB39  45                inc bp
000FAB3A  636874            arpl [bx+si+0x74],bp
000FAB3D  7A65              jpe 0xaba4
000FAB3F  69742D5568        imul si,[si+0x2d],word 0x6855
000FAB44  7200              jc 0xab46
000FAB46  8C5644            mov [bp+0x44],ss
000FAB49  55                push bp
000FAB4A  021F              add bl,[bx]
000FAB4C  0020              add [bx+si],ah
000FAB4E  61                popa
000FAB4F  6D                insw
000FAB50  204175            and [bx+di+0x75],al
000FAB53  7367              jnc 0xabbc
000FAB55  61                popa
000FAB56  6E                outsb
000FAB57  67206675          and [esi+0x75],ah
000FAB5B  657220            gs jc 0xab7e
000FAB5E  64656E            gs outsb
000FAB61  205379            and [bp+di+0x79],dl
000FAB64  7374              jnc 0xabda
000FAB66  656D              gs insw
000FAB68  2D4472            sub ax,0x7244
000FAB6B  7563              jnz 0xabd0
000FAB6D  6B657200          imul sp,[di+0x72],byte +0x0
000FAB71  20616D            and [bx+di+0x6d],ah
000FAB74  207365            and [bp+di+0x65],dh
000FAB77  7269              jc 0xabe2
000FAB79  656C              gs insb
000FAB7B  6C                insb
000FAB7C  656E              gs outsb
000FAB7E  205379            and [bp+di+0x79],dl
000FAB81  7374              jnc 0xabf7
000FAB83  656D              gs insw
000FAB85  2D4175            sub ax,0x7541
000FAB88  7367              jnc 0xabf1
000FAB8A  61                popa
000FAB8B  6E                outsb
000FAB8C  670020            add [eax],ah
000FAB8F  696E206465        imul bp,[bp+0x20],word 0x6564
000FAB94  6E                outsb
000FAB95  205374            and [bp+di+0x74],dl
000FAB98  657565            gs jnz 0xac00
000FAB9B  722D              jc 0xabca
000FAB9D  52                push dx
000FAB9E  65676973746572    imul si,[gs:ebx+0x74],word 0x7265
000FABA5  6E                outsb
000FABA6  206675            and [bp+0x75],ah
000FABA9  657220            gs jc 0xabcc
000FABAC  646965204D61      imul sp,[fs:di+0x20],word 0x614d
000FABB2  7573              jnz 0xac27
000FABB4  003A              add [bp+si],bh
000FABB6  204661            and [bp+0x61],al
000FABB9  6C                insb
000FABBA  7363              jnc 0xac1f
000FABBC  686520            push word 0x2065
000FABBF  52                push dx
000FABC0  4F                dec di
000FABC1  53                push bx
000FABC2  2D5072            sub ax,0x7250
000FABC5  7565              jnz 0xac2c
000FABC7  667375            o32 jnc 0xac3f
000FABCA  6D                insw
000FABCB  6D                insw
000FABCC  65008C4861        add [gs:si+0x6148],cl
000FABD1  7570              jnz 0xac43
000FABD3  7473              jz 0xac48
000FABD5  7065              jo 0xac3c
000FABD7  6963686572        imul sp,[bp+di+0x68],word 0x7265
000FABDC  2028              and [bx+si],ch
000FABDE  50                push ax
000FABDF  61                popa
000FABE0  7269              jc 0xac4b
000FABE2  7479              jz 0xac5d
000FABE4  2D4665            sub ax,0x6546
000FABE7  686C65            push word 0x656c
000FABEA  7229              jc 0xac15
000FABEC  008B7761          add [bp+di+0x6177],cl
000FABF0  7274              jc 0xac66
000FABF2  656E              gs outsb
000FABF4  0002              add [bp+si],al
000FABF6  0400              add al,0x0
000FABF8  0205              add al,[di]
000FABFA  004D1B            add [di+0x1b],cl
000FABFD  84727A            test [bp+si+0x7a],dh
000FAC00  0002              add [bp+si],al
000FAC02  0900              or [bx+si],ax
000FAC04  4D                dec bp
000FAC05  61                popa
000FAC06  69000206          imul ax,[bx+si],word 0x602
000FAC0A  0002              add [bp+si],al
000FAC0C  07                pop es
000FAC0D  0002              add [bp+si],al
000FAC0F  0A00              or al,[bx+si]
000FAC11  020B              add cl,[bp+di]
000FAC13  0002              add [bp+si],al
000FAC15  0800              or [bx+si],al
000FAC17  020D              add cl,[di]
000FAC19  004465            add [si+0x65],al
000FAC1C  7A02              jpe 0xac20
000FAC1E  0F0011            lldt [bx+di]
000FAC21  3A12              cmp dl,[bp+si]
000FAC23  20616D            and [bx+di+0x6d],ah
000FAC26  2013              and [bp+di],dl
000FAC28  200F              and [bx],cl
000FAC2A  2014              and [si],dl
000FAC2C  0020              add [bx+si],ah
000FAC2E  696D200042        imul bp,[di+0x20],word 0x4200
000FAC33  6974746520        imul si,[si+0x74],word 0x2065
000FAC38  0000              add [bx+si],al
000FAC3A  0000              add [bx+si],al
000FAC3C  0000              add [bx+si],al
000FAC3E  0000              add [bx+si],al
000FAC40  0000              add [bx+si],al
000FAC42  0000              add [bx+si],al
000FAC44  0000              add [bx+si],al
000FAC46  0000              add [bx+si],al
000FAC48  0000              add [bx+si],al
000FAC4A  0000              add [bx+si],al
000FAC4C  0000              add [bx+si],al
000FAC4E  0000              add [bx+si],al
000FAC50  0000              add [bx+si],al
000FAC52  0000              add [bx+si],al
000FAC54  0000              add [bx+si],al
000FAC56  0000              add [bx+si],al
000FAC58  00EA              add dl,ch
000FAC5A  5E                pop si
000FAC5B  2C00              sub al,0x0
000FAC5D  FC                cld
000FAC5E  E84DDF            call 0x8bae
000FAC61  80FC02            cmp ah,0x2
000FAC64  7215              jc 0xac7b
000FAC66  80FC06            cmp ah,0x6
000FAC69  7305              jnc 0xac70
000FAC6B  80FA02            cmp dl,0x2
000FAC6E  7205              jc 0xac75
000FAC70  B401              mov ah,0x1
000FAC72  E9D700            jmp 0xad4c
000FAC75  E8F102            call 0xaf69
000FAC78  E8A801            call 0xae23
000FAC7B  8A5E01            mov bl,[bp+0x1]
000FAC7E  02DB              add bl,bl
000FAC80  32FF              xor bh,bh
000FAC82  2EFF978A2C        call [cs:bx+0x2c8a]
000FAC87  E9C400            jmp 0xad4e
000FAC8A  672DA02D          sub ax,0x2da0
000FAC8E  E42C              in al,0x2c
000FAC90  96                xchg ax,si
000FAC91  2CE8              sub al,0xe8
000FAC93  2CA2              sub al,0xa2
000FAC95  2CB6              sub al,0xb6
000FAC97  4A                dec dx
000FAC98  E81C01            call 0xadb7
000FAC9B  B4C5              mov ah,0xc5
000FAC9D  E84F00            call 0xacef
000FACA0  EB3A              jmp short 0xacdc
000FACA2  B004              mov al,0x4
000FACA4  E87302            call 0xaf1a
000FACA7  8ADC              mov bl,ah
000FACA9  D0E3              shl bl,1
000FACAB  D0E3              shl bl,1
000FACAD  32FF              xor bh,bh
000FACAF  B64A              mov dh,0x4a
000FACB1  E82701            call 0xaddb
000FACB4  B44D              mov ah,0x4d
000FACB6  E84002            call 0xaef9
000FACB9  8A6607            mov ah,[bp+0x7]
000FACBC  D0C4              rol ah,1
000FACBE  D0C4              rol ah,1
000FACC0  026606            add ah,[bp+0x6]
000FACC3  E83302            call 0xaef9
000FACC6  B003              mov al,0x3
000FACC8  E82B02            call 0xaef6
000FACCB  E82302            call 0xaef1
000FACCE  43                inc bx
000FACCF  43                inc bx
000FACD0  E81E02            call 0xaef1
000FACD3  268A27            mov ah,[es:bx]
000FACD6  E84C00            call 0xad25
000FACD9  8A4600            mov al,[bp+0x0]
000FACDC  9C                pushf
000FACDD  B91B03            mov cx,0x31b
000FACE0  E2FE              loop 0xace0
000FACE2  9D                popf
000FACE3  C3                ret
000FACE4  B646              mov dh,0x46
000FACE6  EB02              jmp short 0xacea
000FACE8  B642              mov dh,0x42
000FACEA  E8CA00            call 0xadb7
000FACED  B4E6              mov ah,0xe6
000FACEF  E80702            call 0xaef9
000FACF2  8A6607            mov ah,[bp+0x7]
000FACF5  D0C4              rol ah,1
000FACF7  D0C4              rol ah,1
000FACF9  026606            add ah,[bp+0x6]
000FACFC  E8FA01            call 0xaef9
000FACFF  8A6605            mov ah,[bp+0x5]
000FAD02  E8F401            call 0xaef9
000FAD05  8A6607            mov ah,[bp+0x7]
000FAD08  E8EE01            call 0xaef9
000FAD0B  8A6604            mov ah,[bp+0x4]
000FAD0E  E8E801            call 0xaef9
000FAD11  B003              mov al,0x3
000FAD13  E8E001            call 0xaef6
000FAD16  268A27            mov ah,[es:bx]
000FAD19  E8DD01            call 0xaef9
000FAD1C  268A27            mov ah,[es:bx]
000FAD1F  E8D701            call 0xaef9
000FAD22  268A27            mov ah,[es:bx]
000FAD25  E85101            call 0xae79
000FAD28  E87301            call 0xae9e
000FAD2B  7501              jnz 0xad2e
000FAD2D  C3                ret
000FAD2E  B90700            mov cx,0x7
000FAD31  8A264304          mov ah,[0x443]
000FAD35  D0DC              rcr ah,1
000FAD37  7202              jc 0xad3b
000FAD39  E2FA              loop 0xad35
000FAD3B  BB442D            mov bx,0x2d44
000FAD3E  03D9              add bx,cx
000FAD40  2E8A27            mov ah,[cs:bx]
000FAD43  C3                ret
000FAD44  2020              and [bx+si],ah
000FAD46  1008              adc [bx+si],cl
000FAD48  2004              and [si],al
000FAD4A  0302              add ax,[bp+si]
000FAD4C  32C0              xor al,al
000FAD4E  894600            mov [bp+0x0],ax
000FAD51  88264104          mov [0x441],ah
000FAD55  80FC01            cmp ah,0x1
000FAD58  F5                cmc
000FAD59  9C                pushf
000FAD5A  B002              mov al,0x2
000FAD5C  E8BB01            call 0xaf1a
000FAD5F  88264004          mov [0x440],ah
000FAD63  9D                popf
000FAD64  E939DE            jmp 0x8ba0
000FAD67  C6063E0400        mov byte [0x43e],0x0
000FAD6C  BAF203            mov dx,0x3f2
000FAD6F  B008              mov al,0x8
000FAD71  EE                out dx,al
000FAD72  B91E00            mov cx,0x1e
000FAD75  E2FE              loop 0xad75
000FAD77  C6063F0400        mov byte [0x43f],0x0
000FAD7C  C70640040000      mov word [0x440],0x0
000FAD82  B00C              mov al,0xc
000FAD84  EE                out dx,al
000FAD85  E8F900            call 0xae81
000FAD88  E8E600            call 0xae71
000FAD8B  B403              mov ah,0x3
000FAD8D  E86901            call 0xaef9
000FAD90  B000              mov al,0x0
000FAD92  E86101            call 0xaef6
000FAD95  B001              mov al,0x1
000FAD97  E85C01            call 0xaef6
000FAD9A  33C0              xor ax,ax
000FAD9C  8A4600            mov al,[bp+0x0]
000FAD9F  C3                ret
000FADA0  A04104            mov al,[0x441]
000FADA3  8AE0              mov ah,al
000FADA5  C3                ret
000FADA6  9C                pushf
000FADA7  0E                push cs
000FADA8  E80100            call 0xadac
000FADAB  C3                ret
000FADAC  E8FFDD            call 0x8bae
000FADAF  E8B701            call 0xaf69
000FADB2  E86E00            call 0xae23
000FADB5  EB97              jmp short 0xad4e
000FADB7  52                push dx
000FADB8  B003              mov al,0x3
000FADBA  E85D01            call 0xaf1a
000FADBD  750B              jnz 0xadca
000FADBF  B006              mov al,0x6
000FADC1  E85601            call 0xaf1a
000FADC4  8AC4              mov al,ah
000FADC6  32E4              xor ah,ah
000FADC8  EB07              jmp short 0xadd1
000FADCA  8ACC              mov cl,ah
000FADCC  B88000            mov ax,0x80
000FADCF  D3C0              rol ax,cl
000FADD1  8A5E00            mov bl,[bp+0x0]
000FADD4  B700              mov bh,0x0
000FADD6  F7E3              mul bx
000FADD8  8BD8              mov bx,ax
000FADDA  5A                pop dx
000FADDB  8B460A            mov ax,[bp+0xa]
000FADDE  B104              mov cl,0x4
000FADE0  D3C0              rol ax,cl
000FADE2  8AD0              mov dl,al
000FADE4  80E20F            and dl,0xf
000FADE7  24F0              and al,0xf0
000FADE9  034602            add ax,[bp+0x2]
000FADEC  7302              jnc 0xadf0
000FADEE  FEC2              inc dl
000FADF0  8BC8              mov cx,ax
000FADF2  03C3              add ax,bx
000FADF4  7402              jz 0xadf8
000FADF6  7226              jc 0xae1e
000FADF8  B006              mov al,0x6
000FADFA  E60A              out 0xa,al
000FADFC  FA                cli
000FADFD  E60C              out 0xc,al
000FADFF  8AC1              mov al,cl
000FAE01  E604              out 0x4,al
000FAE03  8AC5              mov al,ch
000FAE05  E604              out 0x4,al
000FAE07  8AC2              mov al,dl
000FAE09  E681              out 0x81,al
000FAE0B  4B                dec bx
000FAE0C  8AC3              mov al,bl
000FAE0E  E605              out 0x5,al
000FAE10  8AC7              mov al,bh
000FAE12  E605              out 0x5,al
000FAE14  FB                sti
000FAE15  8AC6              mov al,dh
000FAE17  E60B              out 0xb,al
000FAE19  B002              mov al,0x2
000FAE1B  E60A              out 0xa,al
000FAE1D  C3                ret
000FAE1E  B409              mov ah,0x9
000FAE20  E929FF            jmp 0xad4c
000FAE23  8A3E3F04          mov bh,[0x43f]
000FAE27  843E3E04          test [0x43e],bh
000FAE2B  7510              jnz 0xae3d
000FAE2D  53                push bx
000FAE2E  E82500            call 0xae56
000FAE31  7405              jz 0xae38
000FAE33  E82000            call 0xae56
000FAE36  7519              jnz 0xae51
000FAE38  5B                pop bx
000FAE39  083E3E04          or [0x43e],bh
000FAE3D  B40F              mov ah,0xf
000FAE3F  E8B700            call 0xaef9
000FAE42  8A6606            mov ah,[bp+0x6]
000FAE45  E8B100            call 0xaef9
000FAE48  8A6605            mov ah,[bp+0x5]
000FAE4B  E81000            call 0xae5e
000FAE4E  7201              jc 0xae51
000FAE50  C3                ret
000FAE51  B440              mov ah,0x40
000FAE53  E9F6FE            jmp 0xad4c
000FAE56  B407              mov ah,0x7
000FAE58  E89E00            call 0xaef9
000FAE5B  8A6606            mov ah,[bp+0x6]
000FAE5E  E81800            call 0xae79
000FAE61  B009              mov al,0x9
000FAE63  E8B400            call 0xaf1a
000FAE66  7409              jz 0xae71
000FAE68  B9C601            mov cx,0x1c6
000FAE6B  E2FE              loop 0xae6b
000FAE6D  FECC              dec ah
000FAE6F  75F7              jnz 0xae68
000FAE71  B408              mov ah,0x8
000FAE73  E88300            call 0xaef9
000FAE76  EB26              jmp short 0xae9e
000FAE78  90                nop
000FAE79  80263E047F        and byte [0x43e],0x7f
000FAE7E  E87800            call 0xaef9
000FAE81  B90000            mov cx,0x0
000FAE84  B005              mov al,0x5
000FAE86  F6063E0480        test byte [0x43e],0x80
000FAE8B  750B              jnz 0xae98
000FAE8D  E2F7              loop 0xae86
000FAE8F  FEC8              dec al
000FAE91  75F3              jnz 0xae86
000FAE93  B480              mov ah,0x80
000FAE95  E9B4FE            jmp 0xad4c
000FAE98  80263E047F        and byte [0x43e],0x7f
000FAE9D  C3                ret
000FAE9E  FC                cld
000FAE9F  BAF403            mov dx,0x3f4
000FAEA2  8D1E4204          lea bx,[0x442]
000FAEA6  B407              mov ah,0x7
000FAEA8  B90000            mov cx,0x0
000FAEAB  EC                in al,dx
000FAEAC  D0D0              rcl al,1
000FAEAE  7207              jc 0xaeb7
000FAEB0  E2F9              loop 0xaeab
000FAEB2  B420              mov ah,0x20
000FAEB4  E995FE            jmp 0xad4c
000FAEB7  D0D0              rcl al,1
000FAEB9  7313              jnc 0xaece
000FAEBB  0AE4              or ah,ah
000FAEBD  74F3              jz 0xaeb2
000FAEBF  42                inc dx
000FAEC0  EC                in al,dx
000FAEC1  4A                dec dx
000FAEC2  8807              mov [bx],al
000FAEC4  43                inc bx
000FAEC5  FECC              dec ah
000FAEC7  B90C00            mov cx,0xc
000FAECA  E2FE              loop 0xaeca
000FAECC  EBDD              jmp short 0xaeab
000FAECE  A04604            mov al,[0x446]
000FAED1  3A4607            cmp al,[bp+0x7]
000FAED4  A04704            mov al,[0x447]
000FAED7  740B              jz 0xaee4
000FAED9  B004              mov al,0x4
000FAEDB  E83C00            call 0xaf1a
000FAEDE  8AC4              mov al,ah
000FAEE0  02064704          add al,[0x447]
000FAEE4  2A4604            sub al,[bp+0x4]
000FAEE7  8A264204          mov ah,[0x442]
000FAEEB  F6C4C0            test ah,0xc0
000FAEEE  B400              mov ah,0x0
000FAEF0  C3                ret
000FAEF1  268A27            mov ah,[es:bx]
000FAEF4  EB03              jmp short 0xaef9
000FAEF6  E82100            call 0xaf1a
000FAEF9  BAF403            mov dx,0x3f4
000FAEFC  B90000            mov cx,0x0
000FAEFF  EC                in al,dx
000FAF00  D0D0              rcl al,1
000FAF02  7207              jc 0xaf0b
000FAF04  E2F9              loop 0xaeff
000FAF06  B420              mov ah,0x20
000FAF08  E941FE            jmp 0xad4c
000FAF0B  D0D0              rcl al,1
000FAF0D  72F7              jc 0xaf06
000FAF0F  8AC4              mov al,ah
000FAF11  42                inc dx
000FAF12  EE                out dx,al
000FAF13  B90800            mov cx,0x8
000FAF16  E2FE              loop 0xaf16
000FAF18  43                inc bx
000FAF19  C3                ret
000FAF1A  C41E7800          les bx,[0x78]
000FAF1E  98                cbw
000FAF1F  03D8              add bx,ax
000FAF21  268A27            mov ah,[es:bx]
000FAF24  0AE4              or ah,ah
000FAF26  C3                ret
000FAF27  0000              add [bx+si],al
000FAF29  0000              add [bx+si],al
000FAF2B  0000              add [bx+si],al
000FAF2D  0000              add [bx+si],al
000FAF2F  0000              add [bx+si],al
000FAF31  0000              add [bx+si],al
000FAF33  0000              add [bx+si],al
000FAF35  0000              add [bx+si],al
000FAF37  0000              add [bx+si],al
000FAF39  0000              add [bx+si],al
000FAF3B  0000              add [bx+si],al
000FAF3D  0000              add [bx+si],al
000FAF3F  0000              add [bx+si],al
000FAF41  0000              add [bx+si],al
000FAF43  0000              add [bx+si],al
000FAF45  0000              add [bx+si],al
000FAF47  0000              add [bx+si],al
000FAF49  0000              add [bx+si],al
000FAF4B  0000              add [bx+si],al
000FAF4D  0000              add [bx+si],al
000FAF4F  0000              add [bx+si],al
000FAF51  0000              add [bx+si],al
000FAF53  0000              add [bx+si],al
000FAF55  0000              add [bx+si],al
000FAF57  1E                push ds
000FAF58  50                push ax
000FAF59  33C0              xor ax,ax
000FAF5B  8ED8              mov ds,ax
000FAF5D  800E3E0480        or byte [0x43e],0x80
000FAF62  B066              mov al,0x66
000FAF64  E620              out 0x20,al
000FAF66  58                pop ax
000FAF67  1F                pop ds
000FAF68  CF                iret
000FAF69  C6064004FF        mov byte [0x440],0xff
000FAF6E  8A4E06            mov cl,[bp+0x6]
000FAF71  B080              mov al,0x80
000FAF73  FEC1              inc cl
000FAF75  D2C0              rol al,cl
000FAF77  84063F04          test [0x43f],al
000FAF7B  752B              jnz 0xafa8
000FAF7D  A23F04            mov [0x43f],al
000FAF80  B104              mov cl,0x4
000FAF82  D2C0              rol al,cl
000FAF84  0A4606            or al,[bp+0x6]
000FAF87  0C0C              or al,0xc
000FAF89  BAF203            mov dx,0x3f2
000FAF8C  EE                out dx,al
000FAF8D  B00A              mov al,0xa
000FAF8F  E888FF            call 0xaf1a
000FAF92  80FC04            cmp ah,0x4
000FAF95  7302              jnc 0xaf99
000FAF97  B404              mov ah,0x4
000FAF99  B07D              mov al,0x7d
000FAF9B  B9C601            mov cx,0x1c6
000FAF9E  E2FE              loop 0xaf9e
000FAFA0  FEC8              dec al
000FAFA2  75F7              jnz 0xaf9b
000FAFA4  FECC              dec ah
000FAFA6  75F1              jnz 0xaf99
000FAFA8  C3                ret
000FAFA9  0000              add [bx+si],al
000FAFAB  0000              add [bx+si],al
000FAFAD  0000              add [bx+si],al
000FAFAF  0000              add [bx+si],al
000FAFB1  0000              add [bx+si],al
000FAFB3  0000              add [bx+si],al
000FAFB5  0000              add [bx+si],al
000FAFB7  0000              add [bx+si],al
000FAFB9  0000              add [bx+si],al
000FAFBB  0000              add [bx+si],al
000FAFBD  0000              add [bx+si],al
000FAFBF  0000              add [bx+si],al
000FAFC1  0000              add [bx+si],al
000FAFC3  0000              add [bx+si],al
000FAFC5  0000              add [bx+si],al
000FAFC7  DF02              fild word [bp+si]
000FAFC9  640209            add cl,[fs:bx+di]
000FAFCC  2AFF              sub bh,bh
000FAFCE  50                push ax
000FAFCF  F6                db 0xf6
000FAFD0  0F                db 0x0f
000FAFD1  04EA              add al,0xea
000FAFD3  B30E              mov bl,0xe
000FAFD5  00FC              add ah,bh
000FAFD7  05C400            add ax,0xc4
000FAFDA  0100              add [bx+si],ax
000FAFDC  0400              add al,0x0
000FAFDE  07                pop es
000FAFDF  A6                cmpsb
000FAFE0  C200BA            ret 0xba00
000FAFE3  01C4              add sp,ax
000FAFE5  0003              add [bp+di],al
000FAFE7  19B40060          sbb [si+0x6000],si
000FAFEB  4F                dec di
000FAFEC  56                push si
000FAFED  3A5160            cmp dl,[bx+di+0x60]
000FAFF0  701F              jo 0xb011
000FAFF2  000D              add [di],cl
000FAFF4  0B0D              or cx,[di]
000FAFF6  0000              add [bx+si],al
000FAFF8  0000              add [bx+si],al
000FAFFA  5E                pop si
000FAFFB  2E5D              cs pop bp
000FAFFD  280D              sub [di],cl
000FAFFF  5E                pop si
000FB000  6E                outsb
000FB001  A3FF00            mov [0xff],ax
000FB004  CC                int3
000FB005  01CA              add dx,cx
000FB007  09CE              or si,cx
000FB009  0000              add [bx+si],al
000FB00B  0000              add [bx+si],al
000FB00D  0000              add [bx+si],al
000FB00F  0008              add [bx+si],cl
000FB011  00FF              add bh,bh
000FB013  BA14C0            mov dx,0xc014
000FB016  0000              add [bx+si],al
000FB018  0808              or [bx+si],cl
000FB01A  0808              or [bx+si],cl
000FB01C  0808              or [bx+si],cl
000FB01E  0810              or [bx+si],dl
000FB020  1818              sbb [bx+si],bl
000FB022  1818              sbb [bx+si],bl
000FB024  1818              sbb [bx+si],bl
000FB026  180E000F          sbb [0xf00],cl
000FB02A  0800              or [bx+si],al
000FB02C  B003              mov al,0x3
000FB02E  C402              les ax,[bp+si]
000FB030  0300              add ax,[bx+si]
000FB032  0302              add ax,[bp+si]
000FB034  CE                into
000FB035  05100A            add ax,0xa10
000FB038  0008              add [bx+si],cl
000FB03A  0300              add ax,[bx+si]
000FB03C  0000              add [bx+si],al
000FB03E  0000              add [bx+si],al
000FB040  0000              add [bx+si],al
000FB042  0000              add [bx+si],al
000FB044  005531            add [di+0x31],dl
000FB047  1833              sbb [bp+di],dh
000FB049  3133              xor [bp+di],si
000FB04B  D833              fdiv dword [bp+di]
000FB04D  7D37              jnl 0xb086
000FB04F  96                xchg ax,si
000FB050  32FC              xor bh,ah
000FB052  33ED              xor bp,bp
000FB054  33E9              xor bp,cx
000FB056  3403              xor al,0x3
000FB058  351635            xor ax,0x3516
000FB05B  D932              fnstenv [bp+si]
000FB05D  94                xchg ax,sp
000FB05E  366F              ss outsw
000FB060  37                aaa
000FB061  27                daa
000FB062  350B33            xor ax,0x330b
000FB065  EA6A3000FC        jmp 0xfc00:0x306a
000FB06A  E841DB            call 0x8bae
000FB06D  80FC10            cmp ah,0x10
000FB070  731F              jnc 0xb091
000FB072  8A1E1004          mov bl,[0x410]
000FB076  80E330            and bl,0x30
000FB079  80FB30            cmp bl,0x30
000FB07C  BB00B8            mov bx,0xb800
000FB07F  7503              jnz 0xb084
000FB081  BB00B0            mov bx,0xb000
000FB084  8EC3              mov es,bx
000FB086  8ADC              mov bl,ah
000FB088  32FF              xor bh,bh
000FB08A  03DB              add bx,bx
000FB08C  2EFFA74530        jmp [cs:bx+0x3045]
000FB091  C3                ret
000FB092  0000              add [bx+si],al
000FB094  0000              add [bx+si],al
000FB096  0000              add [bx+si],al
000FB098  0000              add [bx+si],al
000FB09A  0000              add [bx+si],al
000FB09C  0000              add [bx+si],al
000FB09E  0000              add [bx+si],al
000FB0A0  0000              add [bx+si],al
000FB0A2  0000              add [bx+si],al
000FB0A4  3828              cmp [bx+si],ch
000FB0A6  2D0A1F            sub ax,0x1f0a
000FB0A9  06                push es
000FB0AA  191C              sbb [si],bx
000FB0AC  0207              add al,[bx]
000FB0AE  06                push es
000FB0AF  07                pop es
000FB0B0  0000              add [bx+si],al
000FB0B2  0000              add [bx+si],al
000FB0B4  7150              jno 0xb106
000FB0B6  5A                pop dx
000FB0B7  0A1F              or bl,[bx]
000FB0B9  06                push es
000FB0BA  191C              sbb [si],bx
000FB0BC  0207              add al,[bx]
000FB0BE  06                push es
000FB0BF  07                pop es
000FB0C0  0000              add [bx+si],al
000FB0C2  0000              add [bx+si],al
000FB0C4  3828              cmp [bx+si],ch
000FB0C6  2D0A7F            sub ax,0x7f0a
000FB0C9  06                push es
000FB0CA  647002            fs jo 0xb0cf
000FB0CD  01060700          add [0x7],ax
000FB0D1  0000              add [bx+si],al
000FB0D3  006150            add [bx+di+0x50],ah
000FB0D6  52                push dx
000FB0D7  0F19061919        hint_nop8 word [0x1919]
000FB0DC  020D              add cl,[di]
000FB0DE  0B0C              or cx,[si]
000FB0E0  0000              add [bx+si],al
000FB0E2  0000              add [bx+si],al
000FB0E4  E81D00            call 0xb104
000FB0E7  8B166304          mov dx,[0x463]
000FB0EB  83C204            add dx,byte +0x4
000FB0EE  A06504            mov al,[0x465]
000FB0F1  EE                out dx,al
000FB0F2  C3                ret
000FB0F3  E80E00            call 0xb104
000FB0F6  8B166304          mov dx,[0x463]
000FB0FA  83C204            add dx,byte +0x4
000FB0FD  A06504            mov al,[0x465]
000FB100  24F7              and al,0xf7
000FB102  EE                out dx,al
000FB103  C3                ret
000FB104  8B166304          mov dx,[0x463]
000FB108  81FAB403          cmp dx,0x3b4
000FB10C  7413              jz 0xb121
000FB10E  83C206            add dx,byte +0x6
000FB111  33C9              xor cx,cx
000FB113  EC                in al,dx
000FB114  2408              and al,0x8
000FB116  7402              jz 0xb11a
000FB118  E2F9              loop 0xb113
000FB11A  EC                in al,dx
000FB11B  2408              and al,0x8
000FB11D  7502              jnz 0xb121
000FB11F  E2F9              loop 0xb11a
000FB121  C3                ret
000FB122  E80100            call 0xb126
000FB125  CB                retf
000FB126  BBE803            mov bx,0x3e8
000FB129  B92E22            mov cx,0x222e
000FB12C  7A06              jpe 0xb134
000FB12E  BBD007            mov bx,0x7d0
000FB131  B9B888            mov cx,0x88b8
000FB134  B0B6              mov al,0xb6
000FB136  E643              out 0x43,al
000FB138  8AC3              mov al,bl
000FB13A  E642              out 0x42,al
000FB13C  8AC7              mov al,bh
000FB13E  E642              out 0x42,al
000FB140  E461              in al,0x61
000FB142  0C03              or al,0x3
000FB144  E661              out 0x61,al
000FB146  B402              mov ah,0x2
000FB148  51                push cx
000FB149  E2FE              loop 0xb149
000FB14B  59                pop cx
000FB14C  FECC              dec ah
000FB14E  75F8              jnz 0xb148
000FB150  24FE              and al,0xfe
000FB152  E661              out 0x61,al
000FB154  C3                ret
000FB155  BF4E04            mov di,0x44e
000FB158  B91500            mov cx,0x15
000FB15B  33C0              xor ax,ax
000FB15D  8EC0              mov es,ax
000FB15F  FC                cld
000FB160  F3AA              rep stosb
000FB162  A01004            mov al,[0x410]
000FB165  2430              and al,0x30
000FB167  3C30              cmp al,0x30
000FB169  B307              mov bl,0x7
000FB16B  7403              jz 0xb170
000FB16D  8A5E00            mov bl,[bp+0x0]
000FB170  881E4904          mov [0x449],bl
000FB174  C43E7400          les di,[0x74]
000FB178  B024              mov al,0x24
000FB17A  E8F9DA            call 0x8c76
000FB17D  7402              jz 0xb181
000FB17F  B007              mov al,0x7
000FB181  8AE8              mov ch,al
000FB183  BE8831            mov si,0x3188
000FB186  EB69              jmp short 0xb1f1
000FB188  83EA05            sub dx,byte +0x5
000FB18B  89166304          mov [0x463],dx
000FB18F  A36504            mov [0x465],ax
000FB192  F6C302            test bl,0x2
000FB195  B82800            mov ax,0x28
000FB198  7402              jz 0xb19c
000FB19A  D1E0              shl ax,1
000FB19C  A34A04            mov [0x44a],ax
000FB19F  03DB              add bx,bx
000FB1A1  2E8B870838        mov ax,[cs:bx+0x3808]
000FB1A6  A34C04            mov [0x44c],ax
000FB1A9  C70660040706      mov word [0x460],0x607
000FB1AF  E932FF            jmp 0xb0e4
000FB1B2  8EDB              mov ds,bx
000FB1B4  B023              mov al,0x23
000FB1B6  BBBC31            mov bx,0x31bc
000FB1B9  E9C5DA            jmp 0x8c81
000FB1BC  2430              and al,0x30
000FB1BE  7506              jnz 0xb1c6
000FB1C0  BED131            mov si,0x31d1
000FB1C3  E9C8CE            jmp 0x808e
000FB1C6  BECD31            mov si,0x31cd
000FB1C9  B003              mov al,0x3
000FB1CB  EB0F              jmp short 0xb1dc
000FB1CD  4A                dec dx
000FB1CE  EE                out dx,al
000FB1CF  B007              mov al,0x7
000FB1D1  BED631            mov si,0x31d6
000FB1D4  EB06              jmp short 0xb1dc
000FB1D6  4A                dec dx
000FB1D7  EE                out dx,al
000FB1D8  8CD8              mov ax,ds
000FB1DA  FFE0              jmp ax
000FB1DC  8BF8              mov di,ax
000FB1DE  B024              mov al,0x24
000FB1E0  BBE631            mov bx,0x31e6
000FB1E3  E99BDA            jmp 0x8c81
000FB1E6  8AE8              mov ch,al
000FB1E8  8BDF              mov bx,di
000FB1EA  8CC8              mov ax,cs
000FB1EC  8EC0              mov es,ax
000FB1EE  BFA430            mov di,0x30a4
000FB1F1  BAD903            mov dx,0x3d9
000FB1F4  33C0              xor ax,ax
000FB1F6  80FB07            cmp bl,0x7
000FB1F9  7504              jnz 0xb1ff
000FB1FB  B2B9              mov dl,0xb9
000FB1FD  FEC4              inc ah
000FB1FF  EE                out dx,al
000FB200  4A                dec dx
000FB201  8AC4              mov al,ah
000FB203  EE                out dx,al
000FB204  80EA04            sub dl,0x4
000FB207  8AFD              mov bh,ch
000FB209  8AC3              mov al,bl
000FB20B  3C06              cmp al,0x6
000FB20D  7502              jnz 0xb211
000FB20F  FEC8              dec al
000FB211  24FE              and al,0xfe
000FB213  32E4              xor ah,ah
000FB215  B103              mov cl,0x3
000FB217  D3E0              shl ax,cl
000FB219  03F8              add di,ax
000FB21B  B91000            mov cx,0x10
000FB21E  33C0              xor ax,ax
000FB220  268A25            mov ah,[es:di]
000FB223  EF                out dx,ax
000FB224  47                inc di
000FB225  FEC0              inc al
000FB227  E2F7              loop 0xb220
000FB229  FC                cld
000FB22A  80C204            add dl,0x4
000FB22D  80FB07            cmp bl,0x7
000FB230  7411              jz 0xb243
000FB232  B012              mov al,0x12
000FB234  EE                out dx,al
000FB235  B800B8            mov ax,0xb800
000FB238  8EC0              mov es,ax
000FB23A  B90020            mov cx,0x2000
000FB23D  33C0              xor ax,ax
000FB23F  33FF              xor di,di
000FB241  F3AB              rep stosw
000FB243  8AEF              mov ch,bh
000FB245  32FF              xor bh,bh
000FB247  2E8A871838        mov al,[cs:bx+0x3818]
000FB24C  24F7              and al,0xf7
000FB24E  EE                out dx,al
000FB24F  8AE5              mov ah,ch
000FB251  BF00B0            mov di,0xb000
000FB254  B90008            mov cx,0x800
000FB257  80FB07            cmp bl,0x7
000FB25A  740B              jz 0xb267
000FB25C  F6C304            test bl,0x4
000FB25F  7510              jnz 0xb271
000FB261  BF00B8            mov di,0xb800
000FB264  B90020            mov cx,0x2000
000FB267  B020              mov al,0x20
000FB269  8EC7              mov es,di
000FB26B  33FF              xor di,di
000FB26D  F3AB              rep stosw
000FB26F  8AFC              mov bh,ah
000FB271  B010              mov al,0x10
000FB273  80FB05            cmp bl,0x5
000FB276  7411              jz 0xb289
000FB278  8AC7              mov al,bh
000FB27A  B104              mov cl,0x4
000FB27C  D2C8              ror al,cl
000FB27E  2407              and al,0x7
000FB280  0C30              or al,0x30
000FB282  80FB06            cmp bl,0x6
000FB285  7502              jnz 0xb289
000FB287  0C07              or al,0x7
000FB289  42                inc dx
000FB28A  EE                out dx,al
000FB28B  8AE0              mov ah,al
000FB28D  32FF              xor bh,bh
000FB28F  2E8A871838        mov al,[cs:bx+0x3818]
000FB294  FFE6              jmp si
000FB296  803E490403        cmp byte [0x449],0x3
000FB29B  773B              ja 0xb2d8
000FB29D  8A5E00            mov bl,[bp+0x0]
000FB2A0  80FB04            cmp bl,0x4
000FB2A3  720C              jc 0xb2b1
000FB2A5  80FB08            cmp bl,0x8
000FB2A8  732E              jnc 0xb2d8
000FB2AA  803E490401        cmp byte [0x449],0x1
000FB2AF  7727              ja 0xb2d8
000FB2B1  881E6204          mov [0x462],bl
000FB2B5  A14C04            mov ax,[0x44c]
000FB2B8  32FF              xor bh,bh
000FB2BA  53                push bx
000FB2BB  F7E3              mul bx
000FB2BD  A34E04            mov [0x44e],ax
000FB2C0  D1E8              shr ax,1
000FB2C2  8BD8              mov bx,ax
000FB2C4  E83DFE            call 0xb104
000FB2C7  B40C              mov ah,0xc
000FB2C9  E88400            call 0xb350
000FB2CC  5B                pop bx
000FB2CD  03DB              add bx,bx
000FB2CF  8B8F5004          mov cx,[bx+0x450]
000FB2D3  D1EB              shr bx,1
000FB2D5  EB70              jmp short 0xb347
000FB2D7  90                nop
000FB2D8  C3                ret
000FB2D9  E828FE            call 0xb104
000FB2DC  8B4602            mov ax,[bp+0x2]
000FB2DF  0AE4              or ah,ah
000FB2E1  8A266604          mov ah,[0x466]
000FB2E5  7507              jnz 0xb2ee
000FB2E7  80E420            and ah,0x20
000FB2EA  0AC4              or al,ah
000FB2EC  EB11              jmp short 0xb2ff
000FB2EE  86C4              xchg ah,al
000FB2F0  24DF              and al,0xdf
000FB2F2  803E490405        cmp byte [0x449],0x5
000FB2F7  7406              jz 0xb2ff
000FB2F9  0AE4              or ah,ah
000FB2FB  7402              jz 0xb2ff
000FB2FD  0C20              or al,0x20
000FB2FF  A26604            mov [0x466],al
000FB302  8B166304          mov dx,[0x463]
000FB306  83C205            add dx,byte +0x5
000FB309  EE                out dx,al
000FB30A  C3                ret
000FB30B  A14904            mov ax,[0x449]
000FB30E  894600            mov [bp+0x0],ax
000FB311  A06204            mov al,[0x462]
000FB314  884603            mov [bp+0x3],al
000FB317  C3                ret
000FB318  890E6004          mov [0x460],cx
000FB31C  803E490407        cmp byte [0x449],0x7
000FB321  7408              jz 0xb32b
000FB323  80FD20            cmp ch,0x20
000FB326  7203              jc 0xb32b
000FB328  B91E1E            mov cx,0x1e1e
000FB32B  B40A              mov ah,0xa
000FB32D  8BD9              mov bx,cx
000FB32F  EB1F              jmp short 0xb350
000FB331  8A5E03            mov bl,[bp+0x3]
000FB334  32FF              xor bh,bh
000FB336  D1E3              shl bx,1
000FB338  89975004          mov [bx+0x450],dx
000FB33C  D1EB              shr bx,1
000FB33E  8BCA              mov cx,dx
000FB340  3A1E6204          cmp bl,[0x462]
000FB344  7401              jz 0xb347
000FB346  C3                ret
000FB347  E84700            call 0xb391
000FB34A  8BDF              mov bx,di
000FB34C  D1EB              shr bx,1
000FB34E  B40E              mov ah,0xe
000FB350  8B166304          mov dx,[0x463]
000FB354  8AC4              mov al,ah
000FB356  EE                out dx,al
000FB357  42                inc dx
000FB358  8AC7              mov al,bh
000FB35A  EE                out dx,al
000FB35B  4A                dec dx
000FB35C  8AC4              mov al,ah
000FB35E  40                inc ax
000FB35F  EE                out dx,al
000FB360  8AC3              mov al,bl
000FB362  42                inc dx
000FB363  EE                out dx,al
000FB364  4A                dec dx
000FB365  C3                ret
000FB366  A04904            mov al,[0x449]
000FB369  3C07              cmp al,0x7
000FB36B  740A              jz 0xb377
000FB36D  A804              test al,0x4
000FB36F  7406              jz 0xb377
000FB371  8B0E5004          mov cx,[0x450]
000FB375  EB43              jmp short 0xb3ba
000FB377  8A5E03            mov bl,[bp+0x3]
000FB37A  32FF              xor bh,bh
000FB37C  D0E3              shl bl,1
000FB37E  8B8F5004          mov cx,[bx+0x450]
000FB382  D0EB              shr bl,1
000FB384  EB0B              jmp short 0xb391
000FB386  A04904            mov al,[0x449]
000FB389  3C07              cmp al,0x7
000FB38B  7404              jz 0xb391
000FB38D  A804              test al,0x4
000FB38F  7529              jnz 0xb3ba
000FB391  A14A04            mov ax,[0x44a]
000FB394  D1E0              shl ax,1
000FB396  F6E5              mul ch
000FB398  8BF9              mov di,cx
000FB39A  81E7FF00          and di,0xff
000FB39E  D1E7              shl di,1
000FB3A0  03F8              add di,ax
000FB3A2  A14C04            mov ax,[0x44c]
000FB3A5  81E3FF00          and bx,0xff
000FB3A9  7409              jz 0xb3b4
000FB3AB  52                push dx
000FB3AC  A14C04            mov ax,[0x44c]
000FB3AF  F7E3              mul bx
000FB3B1  03F8              add di,ax
000FB3B3  5A                pop dx
000FB3B4  F8                clc
000FB3B5  C3                ret
000FB3B6  8B0E5004          mov cx,[0x450]
000FB3BA  B85000            mov ax,0x50
000FB3BD  F6E5              mul ch
000FB3BF  D1E0              shl ax,1
000FB3C1  D1E0              shl ax,1
000FB3C3  8BF9              mov di,cx
000FB3C5  81E7FF00          and di,0xff
000FB3C9  03C7              add ax,di
000FB3CB  803E490406        cmp byte [0x449],0x6
000FB3D0  7402              jz 0xb3d4
000FB3D2  03C7              add ax,di
000FB3D4  8BF8              mov di,ax
000FB3D6  F9                stc
000FB3D7  C3                ret
000FB3D8  8A5E03            mov bl,[bp+0x3]
000FB3DB  02DB              add bl,bl
000FB3DD  32FF              xor bh,bh
000FB3DF  8B875004          mov ax,[bx+0x450]
000FB3E3  894606            mov [bp+0x6],ax
000FB3E6  A16004            mov ax,[0x460]
000FB3E9  894604            mov [bp+0x4],ax
000FB3EC  C3                ret
000FB3ED  8BCA              mov cx,dx
000FB3EF  2AE8              sub ch,al
000FB3F1  8B1E4A04          mov bx,[0x44a]
000FB3F5  D1E3              shl bx,1
000FB3F7  F7DB              neg bx
000FB3F9  FD                std
000FB3FA  EB0B              jmp short 0xb407
000FB3FC  8BD1              mov dx,cx
000FB3FE  02E8              add ch,al
000FB400  8B1E4A04          mov bx,[0x44a]
000FB404  D1E3              shl bx,1
000FB406  FC                cld
000FB407  53                push bx
000FB408  8A1E6204          mov bl,[0x462]
000FB40C  E877FF            call 0xb386
000FB40F  8BF7              mov si,di
000FB411  8BCA              mov cx,dx
000FB413  E870FF            call 0xb386
000FB416  E8EBFC            call 0xb104
000FB419  5A                pop dx
000FB41A  8A4E06            mov cl,[bp+0x6]
000FB41D  2A4E04            sub cl,[bp+0x4]
000FB420  FEC1              inc cl
000FB422  32ED              xor ch,ch
000FB424  8A7E03            mov bh,[bp+0x3]
000FB427  8A5E07            mov bl,[bp+0x7]
000FB42A  2A5E05            sub bl,[bp+0x5]
000FB42D  8A4600            mov al,[bp+0x0]
000FB430  2AD8              sub bl,al
000FB432  FEC3              inc bl
000FB434  E82F00            call 0xb466
000FB437  723D              jc 0xb476
000FB439  0AC0              or al,al
000FB43B  7418              jz 0xb455
000FB43D  06                push es
000FB43E  1F                pop ds
000FB43F  56                push si
000FB440  57                push di
000FB441  51                push cx
000FB442  F3A5              rep movsw
000FB444  59                pop cx
000FB445  5F                pop di
000FB446  5E                pop si
000FB447  03F2              add si,dx
000FB449  03FA              add di,dx
000FB44B  FECB              dec bl
000FB44D  75F0              jnz 0xb43f
000FB44F  8AD8              mov bl,al
000FB451  33C0              xor ax,ax
000FB453  8ED8              mov ds,ax
000FB455  8AE7              mov ah,bh
000FB457  B020              mov al,0x20
000FB459  57                push di
000FB45A  51                push cx
000FB45B  F3AB              rep stosw
000FB45D  59                pop cx
000FB45E  5F                pop di
000FB45F  03FA              add di,dx
000FB461  FECB              dec bl
000FB463  75F4              jnz 0xb459
000FB465  C3                ret
000FB466  803E490407        cmp byte [0x449],0x7
000FB46B  7408              jz 0xb475
000FB46D  F606490404        test byte [0x449],0x4
000FB472  7401              jz 0xb475
000FB474  F9                stc
000FB475  C3                ret
000FB476  50                push ax
000FB477  803E490406        cmp byte [0x449],0x6
000FB47C  740A              jz 0xb488
000FB47E  03C9              add cx,cx
000FB480  0AF6              or dh,dh
000FB482  7917              jns 0xb49b
000FB484  47                inc di
000FB485  46                inc si
000FB486  EB0B              jmp short 0xb493
000FB488  8BC2              mov ax,dx
000FB48A  D1E8              shr ax,1
000FB48C  98                cbw
000FB48D  8BD0              mov dx,ax
000FB48F  0AF6              or dh,dh
000FB491  7908              jns 0xb49b
000FB493  81C7F000          add di,0xf0
000FB497  81C6F000          add si,0xf0
000FB49B  58                pop ax
000FB49C  0AC0              or al,al
000FB49E  742C              jz 0xb4cc
000FB4A0  D0E3              shl bl,1
000FB4A2  D0E3              shl bl,1
000FB4A4  06                push es
000FB4A5  1F                pop ds
000FB4A6  56                push si
000FB4A7  57                push di
000FB4A8  51                push cx
000FB4A9  F3A4              rep movsb
000FB4AB  59                pop cx
000FB4AC  5F                pop di
000FB4AD  5E                pop si
000FB4AE  56                push si
000FB4AF  57                push di
000FB4B0  51                push cx
000FB4B1  81C70020          add di,0x2000
000FB4B5  81C60020          add si,0x2000
000FB4B9  F3A4              rep movsb
000FB4BB  59                pop cx
000FB4BC  5F                pop di
000FB4BD  5E                pop si
000FB4BE  03FA              add di,dx
000FB4C0  03F2              add si,dx
000FB4C2  FECB              dec bl
000FB4C4  75E0              jnz 0xb4a6
000FB4C6  33F6              xor si,si
000FB4C8  8EDE              mov ds,si
000FB4CA  8AD8              mov bl,al
000FB4CC  8AC7              mov al,bh
000FB4CE  D0E3              shl bl,1
000FB4D0  D0E3              shl bl,1
000FB4D2  57                push di
000FB4D3  51                push cx
000FB4D4  F3AA              rep stosb
000FB4D6  59                pop cx
000FB4D7  5F                pop di
000FB4D8  57                push di
000FB4D9  51                push cx
000FB4DA  81C70020          add di,0x2000
000FB4DE  F3AA              rep stosb
000FB4E0  59                pop cx
000FB4E1  5F                pop di
000FB4E2  03FA              add di,dx
000FB4E4  FECB              dec bl
000FB4E6  75EA              jnz 0xb4d2
000FB4E8  C3                ret
000FB4E9  E87AFE            call 0xb366
000FB4EC  7303              jnc 0xb4f1
000FB4EE  E9FE01            jmp 0xb6ef
000FB4F1  268B05            mov ax,[es:di]
000FB4F4  894600            mov [bp+0x0],ax
000FB4F7  C3                ret
000FB4F8  E86601            call 0xb661
000FB4FB  53                push bx
000FB4FC  E8EC00            call 0xb5eb
000FB4FF  5B                pop bx
000FB500  E2F9              loop 0xb4fb
000FB502  C3                ret
000FB503  E860FE            call 0xb366
000FB506  8B4E04            mov cx,[bp+0x4]
000FB509  72ED              jc 0xb4f8
000FB50B  8A4600            mov al,[bp+0x0]
000FB50E  8A6602            mov ah,[bp+0x2]
000FB511  FC                cld
000FB512  AB                stosw
000FB513  E2FD              loop 0xb512
000FB515  C3                ret
000FB516  E84DFE            call 0xb366
000FB519  8B4E04            mov cx,[bp+0x4]
000FB51C  72DA              jc 0xb4f8
000FB51E  FC                cld
000FB51F  8A4600            mov al,[bp+0x0]
000FB522  AA                stosb
000FB523  47                inc di
000FB524  E2F9              loop 0xb51f
000FB526  C3                ret
000FB527  8A1E6204          mov bl,[0x462]
000FB52B  D0E3              shl bl,1
000FB52D  32FF              xor bh,bh
000FB52F  8B8F5004          mov cx,[bx+0x450]
000FB533  33D2              xor dx,dx
000FB535  86D1              xchg cl,dl
000FB537  D0EB              shr bl,1
000FB539  E84AFE            call 0xb386
000FB53C  1AE4              sbb ah,ah
000FB53E  8A4600            mov al,[bp+0x0]
000FB541  3C20              cmp al,0x20
000FB543  7322              jnc 0xb567
000FB545  3C07              cmp al,0x7
000FB547  7503              jnz 0xb54c
000FB549  E9E2FB            jmp 0xb12e
000FB54C  3C0A              cmp al,0xa
000FB54E  7444              jz 0xb594
000FB550  3C08              cmp al,0x8
000FB552  750A              jnz 0xb55e
000FB554  0AD2              or dl,dl
000FB556  7501              jnz 0xb559
000FB558  C3                ret
000FB559  FECA              dec dl
000FB55B  EB79              jmp short 0xb5d6
000FB55D  90                nop
000FB55E  3C0D              cmp al,0xd
000FB560  7505              jnz 0xb567
000FB562  B200              mov dl,0x0
000FB564  EB70              jmp short 0xb5d6
000FB566  90                nop
000FB567  57                push di
000FB568  03FA              add di,dx
000FB56A  03FA              add di,dx
000FB56C  0AE4              or ah,ah
000FB56E  7506              jnz 0xb576
000FB570  8A4600            mov al,[bp+0x0]
000FB573  AA                stosb
000FB574  EB13              jmp short 0xb589
000FB576  52                push dx
000FB577  51                push cx
000FB578  803E490406        cmp byte [0x449],0x6
000FB57D  7502              jnz 0xb581
000FB57F  2BFA              sub di,dx
000FB581  E8DD00            call 0xb661
000FB584  E86400            call 0xb5eb
000FB587  59                pop cx
000FB588  5A                pop dx
000FB589  5F                pop di
000FB58A  FEC2              inc dl
000FB58C  3A164A04          cmp dl,[0x44a]
000FB590  7244              jc 0xb5d6
000FB592  32D2              xor dl,dl
000FB594  80FD18            cmp ch,0x18
000FB597  7233              jc 0xb5cc
000FB599  268A7D01          mov bh,[es:di+0x1]
000FB59D  E8C6FE            call 0xb466
000FB5A0  7302              jnc 0xb5a4
000FB5A2  32FF              xor bh,bh
000FB5A4  53                push bx
000FB5A5  E82E00            call 0xb5d6
000FB5A8  E859FB            call 0xb104
000FB5AB  8A1E6204          mov bl,[0x462]
000FB5AF  B90001            mov cx,0x100
000FB5B2  E8D1FD            call 0xb386
000FB5B5  8BF7              mov si,di
000FB5B7  8B3E4E04          mov di,[0x44e]
000FB5BB  8B0E4A04          mov cx,[0x44a]
000FB5BF  8BD1              mov dx,cx
000FB5C1  03D2              add dx,dx
000FB5C3  FC                cld
000FB5C4  5B                pop bx
000FB5C5  B318              mov bl,0x18
000FB5C7  B001              mov al,0x1
000FB5C9  E968FE            jmp 0xb434
000FB5CC  8B1E4A04          mov bx,[0x44a]
000FB5D0  03DB              add bx,bx
000FB5D2  03FB              add di,bx
000FB5D4  FEC5              inc ch
000FB5D6  8A1E6204          mov bl,[0x462]
000FB5DA  8ACA              mov cl,dl
000FB5DC  32FF              xor bh,bh
000FB5DE  03DB              add bx,bx
000FB5E0  898F5004          mov [bx+0x450],cx
000FB5E4  03FA              add di,dx
000FB5E6  03FA              add di,dx
000FB5E8  E95FFD            jmp 0xb34a
000FB5EB  51                push cx
000FB5EC  57                push di
000FB5ED  B90800            mov cx,0x8
000FB5F0  803E490406        cmp byte [0x449],0x6
000FB5F5  7444              jz 0xb63b
000FB5F7  8A4602            mov al,[bp+0x2]
000FB5FA  2403              and al,0x3
000FB5FC  32E4              xor ah,ah
000FB5FE  8BF0              mov si,ax
000FB600  56                push si
000FB601  33C0              xor ax,ax
000FB603  1E                push ds
000FB604  8EDA              mov ds,dx
000FB606  8A2F              mov ch,[bx]
000FB608  43                inc bx
000FB609  1F                pop ds
000FB60A  D0ED              shr ch,1
000FB60C  7302              jnc 0xb610
000FB60E  0BC6              or ax,si
000FB610  D1E6              shl si,1
000FB612  D1E6              shl si,1
000FB614  0AED              or ch,ch
000FB616  75F2              jnz 0xb60a
000FB618  86E0              xchg al,ah
000FB61A  F6460280          test byte [bp+0x2],0x80
000FB61E  7403              jz 0xb623
000FB620  263305            xor ax,[es:di]
000FB623  268905            mov [es:di],ax
000FB626  B80020            mov ax,0x2000
000FB629  F6C101            test cl,0x1
000FB62C  7403              jz 0xb631
000FB62E  B850E0            mov ax,0xe050
000FB631  03F8              add di,ax
000FB633  5E                pop si
000FB634  E2CA              loop 0xb600
000FB636  5F                pop di
000FB637  47                inc di
000FB638  47                inc di
000FB639  59                pop cx
000FB63A  C3                ret
000FB63B  1E                push ds
000FB63C  8EDA              mov ds,dx
000FB63E  8A07              mov al,[bx]
000FB640  F6460280          test byte [bp+0x2],0x80
000FB644  7403              jz 0xb649
000FB646  263205            xor al,[es:di]
000FB649  268805            mov [es:di],al
000FB64C  43                inc bx
000FB64D  B80020            mov ax,0x2000
000FB650  F6C101            test cl,0x1
000FB653  7403              jz 0xb658
000FB655  B850E0            mov ax,0xe050
000FB658  03F8              add di,ax
000FB65A  E2E2              loop 0xb63e
000FB65C  1F                pop ds
000FB65D  5F                pop di
000FB65E  47                inc di
000FB65F  59                pop cx
000FB660  C3                ret
000FB661  8A6600            mov ah,[bp+0x0]
000FB664  80FC80            cmp ah,0x80
000FB667  720A              jc 0xb673
000FB669  80E47F            and ah,0x7f
000FB66C  E81600            call 0xb685
000FB66F  7507              jnz 0xb678
000FB671  B420              mov ah,0x20
000FB673  8CCA              mov dx,cs
000FB675  BB6E3A            mov bx,0x3a6e
000FB678  8AC4              mov al,ah
000FB67A  32E4              xor ah,ah
000FB67C  03C0              add ax,ax
000FB67E  03C0              add ax,ax
000FB680  03C0              add ax,ax
000FB682  03D8              add bx,ax
000FB684  C3                ret
000FB685  50                push ax
000FB686  8B1E7C00          mov bx,[0x7c]
000FB68A  8B167E00          mov dx,[0x7e]
000FB68E  8BC2              mov ax,dx
000FB690  0BC3              or ax,bx
000FB692  58                pop ax
000FB693  C3                ret
000FB694  E81D00            call 0xb6b4
000FB697  8A4600            mov al,[bp+0x0]
000FB69A  D2C8              ror al,cl
000FB69C  22C4              and al,ah
000FB69E  F6460080          test byte [bp+0x0],0x80
000FB6A2  7407              jz 0xb6ab
000FB6A4  263205            xor al,[es:di]
000FB6A7  268805            mov [es:di],al
000FB6AA  C3                ret
000FB6AB  F6D4              not ah
000FB6AD  262025            and [es:di],ah
000FB6B0  260805            or [es:di],al
000FB6B3  C3                ret
000FB6B4  B050              mov al,0x50
000FB6B6  D1CA              ror dx,1
000FB6B8  F6E2              mul dl
000FB6BA  F6C680            test dh,0x80
000FB6BD  7403              jz 0xb6c2
000FB6BF  050020            add ax,0x2000
000FB6C2  8BD1              mov dx,cx
000FB6C4  D1EA              shr dx,1
000FB6C6  D1EA              shr dx,1
000FB6C8  803E490406        cmp byte [0x449],0x6
000FB6CD  7510              jnz 0xb6df
000FB6CF  D1EA              shr dx,1
000FB6D1  03C2              add ax,dx
000FB6D3  8BF8              mov di,ax
000FB6D5  80E107            and cl,0x7
000FB6D8  FEC1              inc cl
000FB6DA  B401              mov ah,0x1
000FB6DC  D2CC              ror ah,cl
000FB6DE  C3                ret
000FB6DF  03C2              add ax,dx
000FB6E1  8BF8              mov di,ax
000FB6E3  80E103            and cl,0x3
000FB6E6  FEC1              inc cl
000FB6E8  02C9              add cl,cl
000FB6EA  B403              mov ah,0x3
000FB6EC  D2CC              ror ah,cl
000FB6EE  C3                ret
000FB6EF  8CCA              mov dx,cs
000FB6F1  BB6E3A            mov bx,0x3a6e
000FB6F4  E81200            call 0xb709
000FB6F7  720C              jc 0xb705
000FB6F9  E889FF            call 0xb685
000FB6FC  7407              jz 0xb705
000FB6FE  E80800            call 0xb709
000FB701  7302              jnc 0xb705
000FB703  0C80              or al,0x80
000FB705  884600            mov [bp+0x0],al
000FB708  C3                ret
000FB709  53                push bx
000FB70A  B98000            mov cx,0x80
000FB70D  57                push di
000FB70E  51                push cx
000FB70F  53                push bx
000FB710  B90800            mov cx,0x8
000FB713  268B05            mov ax,[es:di]
000FB716  8AE8              mov ch,al
000FB718  86E0              xchg al,ah
000FB71A  803E490406        cmp byte [0x449],0x6
000FB71F  741A              jz 0xb73b
000FB721  51                push cx
000FB722  B108              mov cl,0x8
000FB724  BE0300            mov si,0x3
000FB727  32ED              xor ch,ch
000FB729  85C6              test si,ax
000FB72B  7401              jz 0xb72e
000FB72D  F9                stc
000FB72E  D0DD              rcr ch,1
000FB730  D1E6              shl si,1
000FB732  D1E6              shl si,1
000FB734  FEC9              dec cl
000FB736  75F1              jnz 0xb729
000FB738  58                pop ax
000FB739  8AC8              mov cl,al
000FB73B  1E                push ds
000FB73C  8EDA              mov ds,dx
000FB73E  3A2F              cmp ch,[bx]
000FB740  1F                pop ds
000FB741  7520              jnz 0xb763
000FB743  B80020            mov ax,0x2000
000FB746  F6C101            test cl,0x1
000FB749  7403              jz 0xb74e
000FB74B  B850E0            mov ax,0xe050
000FB74E  03F8              add di,ax
000FB750  43                inc bx
000FB751  FEC9              dec cl
000FB753  75BE              jnz 0xb713
000FB755  58                pop ax
000FB756  59                pop cx
000FB757  5F                pop di
000FB758  5B                pop bx
000FB759  2BC3              sub ax,bx
000FB75B  D1E8              shr ax,1
000FB75D  D1E8              shr ax,1
000FB75F  D1E8              shr ax,1
000FB761  F9                stc
000FB762  C3                ret
000FB763  5B                pop bx
000FB764  59                pop cx
000FB765  5F                pop di
000FB766  83C308            add bx,byte +0x8
000FB769  E2A2              loop 0xb70d
000FB76B  33C0              xor ax,ax
000FB76D  5B                pop bx
000FB76E  C3                ret
000FB76F  E842FF            call 0xb6b4
000FB772  268A05            mov al,[es:di]
000FB775  22C4              and al,ah
000FB777  D2C0              rol al,cl
000FB779  884600            mov [bp+0x0],al
000FB77C  C3                ret
000FB77D  8B166304          mov dx,[0x463]
000FB781  83C206            add dx,byte +0x6
000FB784  EC                in al,dx
000FB785  2406              and al,0x6
000FB787  3C02              cmp al,0x2
000FB789  7408              jz 0xb793
000FB78B  7202              jc 0xb78f
000FB78D  42                inc dx
000FB78E  EE                out dx,al
000FB78F  33C0              xor ax,ax
000FB791  EB69              jmp short 0xb7fc
000FB793  83EA06            sub dx,byte +0x6
000FB796  B010              mov al,0x10
000FB798  EE                out dx,al
000FB799  42                inc dx
000FB79A  EC                in al,dx
000FB79B  8AE0              mov ah,al
000FB79D  4A                dec dx
000FB79E  B011              mov al,0x11
000FB7A0  EE                out dx,al
000FB7A1  42                inc dx
000FB7A2  EC                in al,dx
000FB7A3  83C206            add dx,byte +0x6
000FB7A6  EE                out dx,al
000FB7A7  33DB              xor bx,bx
000FB7A9  8A1E4904          mov bl,[0x449]
000FB7AD  2E8A9F0038        mov bl,[cs:bx+0x3800]
000FB7B2  2BC3              sub ax,bx
000FB7B4  720A              jc 0xb7c0
000FB7B6  8B0E4E04          mov cx,[0x44e]
000FB7BA  D1E9              shr cx,1
000FB7BC  2BC1              sub ax,cx
000FB7BE  7302              jnc 0xb7c2
000FB7C0  33C0              xor ax,ax
000FB7C2  D0EB              shr bl,1
000FB7C4  FECB              dec bl
000FB7C6  B328              mov bl,0x28
000FB7C8  7402              jz 0xb7cc
000FB7CA  D0E3              shl bl,1
000FB7CC  F6F3              div bl
000FB7CE  8AE8              mov ch,al
000FB7D0  D0E5              shl ch,1
000FB7D2  8AD4              mov dl,ah
000FB7D4  803E490406        cmp byte [0x449],0x6
000FB7D9  7502              jnz 0xb7dd
000FB7DB  D0E2              shl dl,1
000FB7DD  E886FC            call 0xb466
000FB7E0  B102              mov cl,0x2
000FB7E2  7202              jc 0xb7e6
000FB7E4  D2E5              shl ch,cl
000FB7E6  33DB              xor bx,bx
000FB7E8  8ADA              mov bl,dl
000FB7EA  41                inc cx
000FB7EB  D3E3              shl bx,cl
000FB7ED  8AF5              mov dh,ch
000FB7EF  D2EE              shr dh,cl
000FB7F1  895606            mov [bp+0x6],dx
000FB7F4  886E05            mov [bp+0x5],ch
000FB7F7  895E02            mov [bp+0x2],bx
000FB7FA  B001              mov al,0x1
000FB7FC  884601            mov [bp+0x1],al
000FB7FF  C3                ret
000FB800  0202              add al,[bp+si]
000FB802  0404              add al,0x4
000FB804  0202              add al,[bp+si]
000FB806  0204              add al,[si]
000FB808  0008              add [bx+si],cl
000FB80A  0008              add [bx+si],cl
000FB80C  0010              add [bx+si],dl
000FB80E  0010              add [bx+si],dl
000FB810  004000            add [bx+si+0x0],al
000FB813  40                inc ax
000FB814  004000            add [bx+si+0x0],al
000FB817  1028              adc [bx+si],ch
000FB819  2829              sub [bx+di],ch
000FB81B  290A              sub [bp+si],cx
000FB81D  0E                push cs
000FB81E  1A29              sbb ch,[bx+di]
000FB820  0000              add [bx+si],al
000FB822  0000              add [bx+si],al
000FB824  0000              add [bx+si],al
000FB826  0000              add [bx+si],al
000FB828  0000              add [bx+si],al
000FB82A  0000              add [bx+si],al
000FB82C  0000              add [bx+si],al
000FB82E  0000              add [bx+si],al
000FB830  0000              add [bx+si],al
000FB832  0000              add [bx+si],al
000FB834  0000              add [bx+si],al
000FB836  0000              add [bx+si],al
000FB838  0000              add [bx+si],al
000FB83A  0000              add [bx+si],al
000FB83C  0000              add [bx+si],al
000FB83E  0000              add [bx+si],al
000FB840  00EA              add dl,ch
000FB842  CE                into
000FB843  0B00              or ax,[bx+si]
000FB845  FC                cld
000FB846  0000              add [bx+si],al
000FB848  0000              add [bx+si],al
000FB84A  0000              add [bx+si],al
000FB84C  00EA              add dl,ch
000FB84E  D80B              fmul dword [bp+di]
000FB850  00FC              add ah,bh
000FB852  8A02              mov al,[bp+si]
000FB854  0300              add ax,[bx+si]
000FB856  5C                pop sp
000FB857  4C                dec sp
000FB858  61                popa
000FB859  7374              jnc 0xb8cf
000FB85B  207573            and [di+0x73],dh
000FB85E  6564206174        and [fs:bx+di+0x74],ah
000FB863  208A5C07          and [bp+si+0x75c],cl
000FB867  0002              add [bp+si],al
000FB869  038B7469          add cx,[bp+di+0x6974]
000FB86D  6D                insw
000FB86E  6520616E          and [gs:bx+di+0x6e],ah
000FB872  64206461          and [fs:si+0x61],ah
000FB876  7465              jz 0xb8dd
000FB878  8B7573            mov si,[di+0x73]
000FB87B  657220            gs jc 0xb89e
000FB87E  6F                outsw
000FB87F  7074              jo 0xb8f5
000FB881  696F6E7320        imul bp,[bx+0x6e],word 0x2073
000FB886  286966            sub [bx+di+0x66],ch
000FB889  207265            and [bp+si+0x65],dh
000FB88C  7175              jno 0xb903
000FB88E  6972656429        imul si,[bp+si+0x65],word 0x2964
000FB893  5C                pop sp
000FB894  07                pop es
000FB895  07                pop es
000FB896  07                pop es
000FB897  008F6669          add [bx+0x6966],cl
000FB89B  7420              jz 0xb8bd
000FB89D  6E                outsb
000FB89E  657720            gs ja 0xb8c1
000FB8A1  626174            bound sp,[bx+di+0x74]
000FB8A4  7465              jz 0xb90b
000FB8A6  7269              jc 0xb911
000FB8A8  65735C            gs jnc 0xb907
000FB8AB  005C43            add [si+0x43],bl
000FB8AE  686563            push word 0x6365
000FB8B1  6B206B            imul sp,[bx+si],byte +0x6b
000FB8B4  657962            gs jns 0xb919
000FB8B7  6F                outsw
000FB8B8  61                popa
000FB8B9  7264              jc 0xb91f
000FB8BB  20616E            and [bx+di+0x6e],ah
000FB8BE  64206D6F          and [fs:di+0x6f],ch
000FB8C2  7573              jnz 0xb937
000FB8C4  65005C49          add [gs:si+0x49],bl
000FB8C8  6E                outsb
000FB8C9  7365              jnc 0xb930
000FB8CB  7274              jc 0xb941
000FB8CD  206120            and [bx+di+0x20],ah
000FB8D0  8C6469            mov [si+0x69],fs
000FB8D3  736B              jnc 0xb940
000FB8D5  20696E            and [bx+di+0x6e],ch
000FB8D8  746F              jz 0xb949
000FB8DA  8E20              mov fs,[bx+si]
000FB8DC  41                inc cx
000FB8DD  5C                pop sp
000FB8DE  54                push sp
000FB8DF  68656E            push word 0x6e65
000FB8E2  207072            and [bx+si+0x72],dh
000FB8E5  657373            gs jnc 0xb95b
000FB8E8  20616E            and [bx+di+0x6e],ah
000FB8EB  7920              jns 0xb90d
000FB8ED  6B657900          imul sp,[di+0x79],byte +0x0
000FB8F1  5C                pop sp
000FB8F2  0210              add dl,[bx+si]
000FB8F4  3A02              cmp al,[bp+si]
000FB8F6  1B616C            sbb sp,[bx+di+0x6c]
000FB8F9  021D              add bl,[di]
000FB8FB  20696E            and [bx+di+0x6e],ch
000FB8FE  636F72            arpl [bx+0x72],bp
000FB901  7265              jc 0xb968
000FB903  63743A            arpl [si+0x3a],si
000FB906  5C                pop sp
000FB907  52                push dx
000FB908  4F                dec di
000FB909  4D                dec bp
000FB90A  206164            and [bx+di+0x64],ah
000FB90D  647265            fs jc 0xb975
000FB910  7373              jnc 0xb985
000FB912  203D              and [di],bh
000FB914  2010              and [bx+si],dl
000FB916  5C                pop sp
000FB917  0002              add [bp+si],al
000FB919  103A              adc [bp+si],bh
000FB91B  204661            and [bp+0x61],al
000FB91E  756C              jnz 0xb98c
000FB920  7479              jz 0xb99b
000FB922  2000              and [bx+si],al
000FB924  8C5241            mov [bp+si+0x41],ss
000FB927  4D                dec bp
000FB928  005644            add [bp+0x44],dl
000FB92B  55                push bp
000FB92C  205241            and [bp+si+0x41],dl
000FB92F  4D                dec bp
000FB930  0002              add [bp+si],al
000FB932  2002              and [bp+si],al
000FB934  1F                pop ds
000FB935  0002              add [bp+si],al
000FB937  1E                push ds
000FB938  021F              add bl,[bx]
000FB93A  00666C            add [bp+0x6c],ah
000FB93D  6F                outsw
000FB93E  7070              jo 0xb9b0
000FB940  798D              jns 0xb8cf
000FB942  021F              add bl,[bx]
000FB944  206F72            and [bx+0x72],ch
000FB947  8D8E0002          lea cx,[bp+0x200]
000FB94B  1120              adc [bx+si],sp
000FB94D  0212              add dl,[bp+si]
000FB94F  008C0214          add [si+0x1402],cl
000FB953  2002              and [bp+si],al
000FB955  150002            adc ax,0x200
000FB958  17                pop ss
000FB959  207469            and [si+0x69],dh
000FB95C  6D                insw
000FB95D  6520636C          and [gs:bp+di+0x6c],ah
000FB961  6F                outsw
000FB962  636B00            arpl [bp+di+0x0],bp
000FB965  56                push si
000FB966  44                inc sp
000FB967  55                push bp
000FB968  021F              add bl,[bx]
000FB96A  008C0218          add [si+0x1802],cl
000FB96E  021A              add bl,[bp+si]
000FB970  008C7365          add [si+0x6573],cl
000FB974  7269              jc 0xb9df
000FB976  61                popa
000FB977  6C                insb
000FB978  021A              add bl,[bp+si]
000FB97A  006D6F            add [di+0x6f],ch
000FB97D  7573              jnz 0xb9f2
000FB97F  6520636F          and [gs:bp+di+0x6f],ah
000FB983  6F                outsw
000FB984  7264              jc 0xb9ea
000FB986  696E617465        imul bp,[bp+0x61],word 0x6574
000FB98B  2002              and [bp+si],al
000FB98D  157300            adc ax,0x73
000FB990  52                push dx
000FB991  4F                dec di
000FB992  53                push bx
000FB993  021D              add bl,[di]
000FB995  006D65            add [di+0x65],ch
000FB998  6D                insw
000FB999  6F                outsw
000FB99A  7279              jc 0xba15
000FB99C  2028              and [bx+si],ch
000FB99E  7061              jo 0xba01
000FB9A0  7269              jc 0xba0b
000FB9A2  7479              jz 0xba1d
000FB9A4  206572            and [di+0x72],ah
000FB9A7  726F              jc 0xba18
000FB9A9  7229              jc 0xb9d4
000FB9AB  008F7761          add [bx+0x6177],cl
000FB9AF  6974000204        imul si,[si+0x0],word 0x402
000FB9B4  7900              jns 0xb9b6
000FB9B6  0205              add al,[di]
000FB9B8  7900              jns 0xb9ba
000FB9BA  4D                dec bp
000FB9BB  61                popa
000FB9BC  7263              jc 0xba21
000FB9BE  680002            push word 0x200
000FB9C1  0900              or [bx+si],ax
000FB9C3  4D                dec bp
000FB9C4  61                popa
000FB9C5  7900              jns 0xb9c7
000FB9C7  4A                dec dx
000FB9C8  756E              jnz 0xba38
000FB9CA  65004A75          add [gs:bp+si+0x75],cl
000FB9CE  6C                insb
000FB9CF  7900              jns 0xb9d1
000FB9D1  020A              add cl,[bp+si]
000FB9D3  0002              add [bp+si],al
000FB9D5  0B00              or ax,[bx+si]
000FB9D7  4F                dec di
000FB9D8  63746F            arpl [si+0x6f],si
000FB9DB  626572            bound sp,[di+0x72]
000FB9DE  0002              add [bp+si],al
000FB9E0  0D0002            or ax,0x200
000FB9E3  0E                push cs
000FB9E4  0011              add [bx+di],dl
000FB9E6  3A12              cmp dl,[bp+si]
000FB9E8  206F6E            and [bx+0x6e],ch
000FB9EB  2013              and [bp+di],dl
000FB9ED  200F              and [bx],cl
000FB9EF  2014              and [si],dl
000FB9F1  005C8F            add [si-0x71],bl
000FB9F4  7365              jnc 0xba5b
000FB9F6  7420              jz 0xba18
000FB9F8  005359            add [bp+di+0x59],dl
000FB9FB  53                push bx
000FB9FC  54                push sp
000FB9FD  45                inc bp
000FB9FE  4D                dec bp
000FB9FF  2000              and [bx+si],al
000FBA01  206469            and [si+0x69],ah
000FBA04  736B              jnc 0xba71
000FBA06  0020              add [bx+si],ah
000FBA08  647269            fs jc 0xba74
000FBA0B  7665              jna 0xba72
000FBA0D  00506C            add [bx+si+0x6c],dl
000FBA10  6561              gs popa
000FBA12  7365              jnc 0xba79
000FBA14  2000              and [bx+si],al
000FBA16  0000              add [bx+si],al
000FBA18  0000              add [bx+si],al
000FBA1A  0000              add [bx+si],al
000FBA1C  0000              add [bx+si],al
000FBA1E  0000              add [bx+si],al
000FBA20  0000              add [bx+si],al
000FBA22  0000              add [bx+si],al
000FBA24  0000              add [bx+si],al
000FBA26  0000              add [bx+si],al
000FBA28  0000              add [bx+si],al
000FBA2A  0000              add [bx+si],al
000FBA2C  0000              add [bx+si],al
000FBA2E  0000              add [bx+si],al
000FBA30  0000              add [bx+si],al
000FBA32  0000              add [bx+si],al
000FBA34  0000              add [bx+si],al
000FBA36  0000              add [bx+si],al
000FBA38  0000              add [bx+si],al
000FBA3A  0000              add [bx+si],al
000FBA3C  0000              add [bx+si],al
000FBA3E  0000              add [bx+si],al
000FBA40  0000              add [bx+si],al
000FBA42  0000              add [bx+si],al
000FBA44  0000              add [bx+si],al
000FBA46  0000              add [bx+si],al
000FBA48  0000              add [bx+si],al
000FBA4A  0000              add [bx+si],al
000FBA4C  0000              add [bx+si],al
000FBA4E  0000              add [bx+si],al
000FBA50  0000              add [bx+si],al
000FBA52  0000              add [bx+si],al
000FBA54  0000              add [bx+si],al
000FBA56  0000              add [bx+si],al
000FBA58  0000              add [bx+si],al
000FBA5A  0000              add [bx+si],al
000FBA5C  0000              add [bx+si],al
000FBA5E  0000              add [bx+si],al
000FBA60  0000              add [bx+si],al
000FBA62  0000              add [bx+si],al
000FBA64  0000              add [bx+si],al
000FBA66  0000              add [bx+si],al
000FBA68  0000              add [bx+si],al
000FBA6A  0000              add [bx+si],al
000FBA6C  0000              add [bx+si],al
000FBA6E  0000              add [bx+si],al
000FBA70  0000              add [bx+si],al
000FBA72  0000              add [bx+si],al
000FBA74  0000              add [bx+si],al
000FBA76  7EC3              jng 0xba3b
000FBA78  A5                movsw
000FBA79  81A599C37E7E      and word [di-0x3c67],0x7e7e
000FBA7F  FF                db 0xff
000FBA80  DB                db 0xdb
000FBA81  FF                db 0xff
000FBA82  DB                db 0xdb
000FBA83  E7FF              out 0xff,ax
000FBA85  7E00              jng 0xba87
000FBA87  6C                insb
000FBA88  FE                db 0xfe
000FBA89  FE                db 0xfe
000FBA8A  7C38              jl 0xbac4
000FBA8C  1000              adc [bx+si],al
000FBA8E  0010              add [bx+si],dl
000FBA90  387CFE            cmp [si-0x2],bh
000FBA93  7C38              jl 0xbacd
000FBA95  1000              adc [bx+si],al
000FBA97  3838              cmp [bx+si],bh
000FBA99  D6                salc
000FBA9A  FE                db 0xfe
000FBA9B  D6                salc
000FBA9C  1038              adc [bx+si],bh
000FBA9E  0010              add [bx+si],dl
000FBAA0  387CFE            cmp [si-0x2],bh
000FBAA3  D6                salc
000FBAA4  1038              adc [bx+si],bh
000FBAA6  0000              add [bx+si],al
000FBAA8  183C              sbb [si],bh
000FBAAA  3C18              cmp al,0x18
000FBAAC  0000              add [bx+si],al
000FBAAE  FF                db 0xff
000FBAAF  FFE7              jmp di
000FBAB1  C3                ret
000FBAB2  C3                ret
000FBAB3  E7FF              out 0xff,ax
000FBAB5  FF00              inc word [bx+si]
000FBAB7  3C66              cmp al,0x66
000FBAB9  42                inc dx
000FBABA  42                inc dx
000FBABB  663C00            o32 cmp al,0x0
000FBABE  FFC3              inc bx
000FBAC0  99                cwd
000FBAC1  BDBD99            mov bp,0x99bd
000FBAC4  C3                ret
000FBAC5  FF0F              dec word [bx]
000FBAC7  07                pop es
000FBAC8  0F                db 0x0f
000FBAC9  7DCC              jnl 0xba97
000FBACB  CC                int3
000FBACC  CC                int3
000FBACD  783C              js 0xbb0b
000FBACF  6666663C18        o32 cmp al,0x18
000FBAD4  7E18              jng 0xbaee
000FBAD6  3038              xor [bx+si],bh
000FBAD8  3C34              cmp al,0x34
000FBADA  30D0              xor al,dl
000FBADC  F060              lock pusha
000FBADE  3F                aas
000FBADF  333F              xor di,[bx]
000FBAE1  3333              xor si,[bp+di]
000FBAE3  DD                db 0xdd
000FBAE4  FF6699            jmp [bp-0x67]
000FBAE7  5A                pop dx
000FBAE8  24C3              and al,0xc3
000FBAEA  C3                ret
000FBAEB  245A              and al,0x5a
000FBAED  99                cwd
000FBAEE  40                inc ax
000FBAEF  707C              jo 0xbb6d
000FBAF1  7E7C              jng 0xbb6f
000FBAF3  7040              jo 0xbb35
000FBAF5  0002              add [bp+si],al
000FBAF7  0E                push cs
000FBAF8  3E7E3E            ds jng 0xbb39
000FBAFB  0E                push cs
000FBAFC  0200              add al,[bx+si]
000FBAFE  183C              sbb [si],bh
000FBB00  7E18              jng 0xbb1a
000FBB02  187E3C            sbb [bp+0x3c],bh
000FBB05  186C6C            sbb [si+0x6c],ch
000FBB08  6C                insb
000FBB09  6C                insb
000FBB0A  6C                insb
000FBB0B  006C00            add [si+0x0],ch
000FBB0E  7EF4              jng 0xbb04
000FBB10  F4                hlt
000FBB11  7434              jz 0xbb47
000FBB13  3434              xor al,0x34
000FBB15  003C              add [si],bh
000FBB17  60                pusha
000FBB18  386C6C            cmp [si+0x6c],ch
000FBB1B  380C              cmp [si],cl
000FBB1D  7800              js 0xbb1f
000FBB1F  0000              add [bx+si],al
000FBB21  007E7E            add [bp+0x7e],bh
000FBB24  7E00              jng 0xbb26
000FBB26  183C              sbb [si],bh
000FBB28  7E18              jng 0xbb42
000FBB2A  7E3C              jng 0xbb68
000FBB2C  187E18            sbb [bp+0x18],bh
000FBB2F  3C7E              cmp al,0x7e
000FBB31  1818              sbb [bx+si],bl
000FBB33  1818              sbb [bx+si],bl
000FBB35  1818              sbb [bx+si],bl
000FBB37  1818              sbb [bx+si],bl
000FBB39  1818              sbb [bx+si],bl
000FBB3B  7E3C              jng 0xbb79
000FBB3D  1800              sbb [bx+si],al
000FBB3F  0406              add al,0x6
000FBB41  FF                db 0xff
000FBB42  FF060400          inc word [0x4]
000FBB46  0020              add [bx+si],ah
000FBB48  60                pusha
000FBB49  FF                db 0xff
000FBB4A  FF6020            jmp [bx+si+0x20]
000FBB4D  0000              add [bx+si],al
000FBB4F  60                pusha
000FBB50  60                pusha
000FBB51  60                pusha
000FBB52  60                pusha
000FBB53  7E00              jng 0xbb55
000FBB55  0000              add [bx+si],al
000FBB57  2466              and al,0x66
000FBB59  FF                db 0xff
000FBB5A  FF6624            jmp [bp+0x24]
000FBB5D  0000              add [bx+si],al
000FBB5F  081C              or [si],bl
000FBB61  3E7F7F            ds jg 0xbbe3
000FBB64  7F00              jg 0xbb66
000FBB66  007F7F            add [bx+0x7f],bh
000FBB69  7F3E              jg 0xbba9
000FBB6B  1C08              sbb al,0x8
000FBB6D  0000              add [bx+si],al
000FBB6F  0000              add [bx+si],al
000FBB71  0000              add [bx+si],al
000FBB73  0000              add [bx+si],al
000FBB75  0018              add [bx+si],bl
000FBB77  1818              sbb [bx+si],bl
000FBB79  1818              sbb [bx+si],bl
000FBB7B  0018              add [bx+si],bl
000FBB7D  006C6C            add [si+0x6c],ch
000FBB80  6C                insb
000FBB81  0000              add [bx+si],al
000FBB83  0000              add [bx+si],al
000FBB85  006C6C            add [si+0x6c],ch
000FBB88  FE                db 0xfe
000FBB89  6C                insb
000FBB8A  FE                db 0xfe
000FBB8B  6C                insb
000FBB8C  6C                insb
000FBB8D  0018              add [bx+si],bl
000FBB8F  3E58              ds pop ax
000FBB91  3C1A              cmp al,0x1a
000FBB93  7C18              jl 0xbbad
000FBB95  0000              add [bx+si],al
000FBB97  63660C            arpl [bp+0xc],sp
000FBB9A  1833              sbb [bp+di],dh
000FBB9C  6300              arpl [bx+si],ax
000FBB9E  1C36              sbb al,0x36
000FBBA0  1C3B              sbb al,0x3b
000FBBA2  6E                outsb
000FBBA3  663B00            cmp eax,[bx+si]
000FBBA6  1818              sbb [bx+si],bl
000FBBA8  3000              xor [bx+si],al
000FBBAA  0000              add [bx+si],al
000FBBAC  0000              add [bx+si],al
000FBBAE  0C18              or al,0x18
000FBBB0  3030              xor [bx+si],dh
000FBBB2  3018              xor [bx+si],bl
000FBBB4  0C00              or al,0x0
000FBBB6  3018              xor [bx+si],bl
000FBBB8  0C0C              or al,0xc
000FBBBA  0C18              or al,0x18
000FBBBC  3000              xor [bx+si],al
000FBBBE  00663C            add [bp+0x3c],ah
000FBBC1  FF                db 0xff
000FBBC2  3C66              cmp al,0x66
000FBBC4  0000              add [bx+si],al
000FBBC6  0018              add [bx+si],bl
000FBBC8  187E18            sbb [bp+0x18],bh
000FBBCB  1800              sbb [bx+si],al
000FBBCD  0000              add [bx+si],al
000FBBCF  0000              add [bx+si],al
000FBBD1  0000              add [bx+si],al
000FBBD3  1818              sbb [bx+si],bl
000FBBD5  3000              xor [bx+si],al
000FBBD7  0000              add [bx+si],al
000FBBD9  7E00              jng 0xbbdb
000FBBDB  0000              add [bx+si],al
000FBBDD  0000              add [bx+si],al
000FBBDF  0000              add [bx+si],al
000FBBE1  0000              add [bx+si],al
000FBBE3  1818              sbb [bx+si],bl
000FBBE5  00060C18          add [0x180c],al
000FBBE9  3060C0            xor [bx+si-0x40],ah
000FBBEC  80007C            add byte [bx+si],0x7c
000FBBEF  C6                db 0xc6
000FBBF0  CE                into
000FBBF1  D6                salc
000FBBF2  E6C6              out 0xc6,al
000FBBF4  7C00              jl 0xbbf6
000FBBF6  1838              sbb [bx+si],bh
000FBBF8  1818              sbb [bx+si],bl
000FBBFA  1818              sbb [bx+si],bl
000FBBFC  1800              sbb [bx+si],al
000FBBFE  3C66              cmp al,0x66
000FBC00  06                push es
000FBC01  0C18              or al,0x18
000FBC03  307E00            xor [bp+0x0],bh
000FBC06  3C66              cmp al,0x66
000FBC08  06                push es
000FBC09  1C06              sbb al,0x6
000FBC0B  663C00            o32 cmp al,0x0
000FBC0E  1C3C              sbb al,0x3c
000FBC10  6C                insb
000FBC11  CC                int3
000FBC12  FE0C              dec byte [si]
000FBC14  0C00              or al,0x0
000FBC16  7E60              jng 0xbc78
000FBC18  7C06              jl 0xbc20
000FBC1A  06                push es
000FBC1B  663C00            o32 cmp al,0x0
000FBC1E  3C66              cmp al,0x66
000FBC20  60                pusha
000FBC21  7C66              jl 0xbc89
000FBC23  663C00            o32 cmp al,0x0
000FBC26  7E06              jng 0xbc2e
000FBC28  06                push es
000FBC29  0C18              or al,0x18
000FBC2B  1818              sbb [bx+si],bl
000FBC2D  003C              add [si],bh
000FBC2F  66663C66          o32 cmp al,0x66
000FBC33  663C00            o32 cmp al,0x0
000FBC36  3C66              cmp al,0x66
000FBC38  663E0C18          ds o32 or al,0x18
000FBC3C  3000              xor [bx+si],al
000FBC3E  0000              add [bx+si],al
000FBC40  1818              sbb [bx+si],bl
000FBC42  0018              add [bx+si],bl
000FBC44  1800              sbb [bx+si],al
000FBC46  0000              add [bx+si],al
000FBC48  1818              sbb [bx+si],bl
000FBC4A  0018              add [bx+si],bl
000FBC4C  1830              sbb [bx+si],dh
000FBC4E  0C18              or al,0x18
000FBC50  306030            xor [bx+si+0x30],ah
000FBC53  180C              sbb [si],cl
000FBC55  0000              add [bx+si],al
000FBC57  007E00            add [bp+0x0],bh
000FBC5A  007E00            add [bp+0x0],bh
000FBC5D  006030            add [bx+si+0x30],ah
000FBC60  180C              sbb [si],cl
000FBC62  1830              sbb [bx+si],dh
000FBC64  60                pusha
000FBC65  003C              add [si],bh
000FBC67  6606              o32 push es
000FBC69  0C18              or al,0x18
000FBC6B  0018              add [bx+si],bl
000FBC6D  007CC6            add [si-0x3a],bh
000FBC70  DE                db 0xde
000FBC71  DE                db 0xde
000FBC72  DEC0              faddp st0
000FBC74  7C00              jl 0xbc76
000FBC76  386CC6            cmp [si-0x3a],ch
000FBC79  C6                db 0xc6
000FBC7A  FEC6              inc dh
000FBC7C  C600FC            mov byte [bx+si],0xfc
000FBC7F  C6C6FC            mov dh,0xfc
000FBC82  C6C6FC            mov dh,0xfc
000FBC85  003C              add [si],bh
000FBC87  66C0C0C0          o32 rol al,byte 0xc0
000FBC8B  663C00            o32 cmp al,0x0
000FBC8E  F8                clc
000FBC8F  CC                int3
000FBC90  C6C6C6            mov dh,0xc6
000FBC93  CC                int3
000FBC94  F8                clc
000FBC95  00FE              add dh,bh
000FBC97  C0C0F8            rol al,byte 0xf8
000FBC9A  C0C0FE            rol al,byte 0xfe
000FBC9D  00FE              add dh,bh
000FBC9F  C0C0F8            rol al,byte 0xf8
000FBCA2  C0C0C0            rol al,byte 0xc0
000FBCA5  003C              add [si],bh
000FBCA7  66C0C0CE          o32 rol al,byte 0xce
000FBCAB  663E00C6          ds o32 add dh,al
000FBCAF  C6C6FE            mov dh,0xfe
000FBCB2  C6C6C6            mov dh,0xc6
000FBCB5  007830            add [bx+si+0x30],bh
000FBCB8  3030              xor [bx+si],dh
000FBCBA  3030              xor [bx+si],dh
000FBCBC  7800              js 0xbcbe
000FBCBE  06                push es
000FBCBF  06                push es
000FBCC0  06                push es
000FBCC1  06                push es
000FBCC2  C6C67C            mov dh,0x7c
000FBCC5  00C6              add dh,al
000FBCC7  CC                int3
000FBCC8  D8F0              fdiv st0
000FBCCA  D8CC              fmul st4
000FBCCC  C600C0            mov byte [bx+si],0xc0
000FBCCF  C0C0C0            rol al,byte 0xc0
000FBCD2  C0C0FE            rol al,byte 0xfe
000FBCD5  00C6              add dh,al
000FBCD7  EE                out dx,al
000FBCD8  FE                db 0xfe
000FBCD9  D6                salc
000FBCDA  C6C6C6            mov dh,0xc6
000FBCDD  00C6              add dh,al
000FBCDF  E6F6              out 0xf6,al
000FBCE1  DECE              fmulp st6
000FBCE3  C6C600            mov dh,0x0
000FBCE6  386CC6            cmp [si-0x3a],ch
000FBCE9  C6C66C            mov dh,0x6c
000FBCEC  3800              cmp [bx+si],al
000FBCEE  FC                cld
000FBCEF  C6C6FC            mov dh,0xfc
000FBCF2  C0C0C0            rol al,byte 0xc0
000FBCF5  0038              add [bx+si],bh
000FBCF7  6C                insb
000FBCF8  C6C6DA            mov dh,0xda
000FBCFB  6C                insb
000FBCFC  3600FC            ss add ah,bh
000FBCFF  C6C6FC            mov dh,0xfc
000FBD02  CC                int3
000FBD03  C6C600            mov dh,0x0
000FBD06  7CC6              jl 0xbcce
000FBD08  C07C06C6          sar byte [si+0x6],byte 0xc6
000FBD0C  7C00              jl 0xbd0e
000FBD0E  FC                cld
000FBD0F  3030              xor [bx+si],dh
000FBD11  3030              xor [bx+si],dh
000FBD13  3030              xor [bx+si],dh
000FBD15  00C6              add dh,al
000FBD17  C6C6C6            mov dh,0xc6
000FBD1A  C6C67C            mov dh,0x7c
000FBD1D  00C6              add dh,al
000FBD1F  C6C6C6            mov dh,0xc6
000FBD22  C6                db 0xc6
000FBD23  6C                insb
000FBD24  3800              cmp [bx+si],al
000FBD26  C6C6C6            mov dh,0xc6
000FBD29  D6                salc
000FBD2A  FE                db 0xfe
000FBD2B  EE                out dx,al
000FBD2C  C600C6            mov byte [bx+si],0xc6
000FBD2F  C6                db 0xc6
000FBD30  6C                insb
000FBD31  386CC6            cmp [si-0x3a],ch
000FBD34  C60066            mov byte [bx+si],0x66
000FBD37  66663C18          o32 cmp al,0x18
000FBD3B  1818              sbb [bx+si],bl
000FBD3D  00FE              add dh,bh
000FBD3F  06                push es
000FBD40  0C18              or al,0x18
000FBD42  3060FE            xor [bx+si-0x2],ah
000FBD45  003C              add [si],bh
000FBD47  3030              xor [bx+si],dh
000FBD49  3030              xor [bx+si],dh
000FBD4B  303C              xor [si],bh
000FBD4D  00C0              add al,al
000FBD4F  60                pusha
000FBD50  3018              xor [bx+si],bl
000FBD52  0C06              or al,0x6
000FBD54  0200              add al,[bx+si]
000FBD56  3C0C              cmp al,0xc
000FBD58  0C0C              or al,0xc
000FBD5A  0C0C              or al,0xc
000FBD5C  3C00              cmp al,0x0
000FBD5E  081C              or [si],bl
000FBD60  366300            arpl [ss:bx+si],ax
000FBD63  0000              add [bx+si],al
000FBD65  0000              add [bx+si],al
000FBD67  0000              add [bx+si],al
000FBD69  0000              add [bx+si],al
000FBD6B  0000              add [bx+si],al
000FBD6D  FF30              push word [bx+si]
000FBD6F  180C              sbb [si],cl
000FBD71  0000              add [bx+si],al
000FBD73  0000              add [bx+si],al
000FBD75  0000              add [bx+si],al
000FBD77  007C06            add [si+0x6],bh
000FBD7A  7EC6              jng 0xbd42
000FBD7C  7E00              jng 0xbd7e
000FBD7E  C0C0FC            rol al,byte 0xfc
000FBD81  C6C6C6            mov dh,0xc6
000FBD84  FC                cld
000FBD85  0000              add [bx+si],al
000FBD87  007CC6            add [si-0x3a],bh
000FBD8A  C0C67C            rol dh,byte 0x7c
000FBD8D  0006067E          add [0x7e06],al
000FBD91  C6C6C6            mov dh,0xc6
000FBD94  7E00              jng 0xbd96
000FBD96  0000              add [bx+si],al
000FBD98  7CC6              jl 0xbd60
000FBD9A  FEC0              inc al
000FBD9C  7C00              jl 0xbd9e
000FBD9E  3C66              cmp al,0x66
000FBDA0  60                pusha
000FBDA1  F8                clc
000FBDA2  60                pusha
000FBDA3  60                pusha
000FBDA4  60                pusha
000FBDA5  0000              add [bx+si],al
000FBDA7  007EC6            add [bp-0x3a],bh
000FBDAA  C6                db 0xc6
000FBDAB  7E06              jng 0xbdb3
000FBDAD  FC                cld
000FBDAE  C0C0FC            rol al,byte 0xfc
000FBDB1  C6C6C6            mov dh,0xc6
000FBDB4  C60018            mov byte [bx+si],0x18
000FBDB7  0018              add [bx+si],bl
000FBDB9  1818              sbb [bx+si],bl
000FBDBB  1818              sbb [bx+si],bl
000FBDBD  000C              add [si],cl
000FBDBF  000C              add [si],cl
000FBDC1  0C0C              or al,0xc
000FBDC3  0CCC              or al,0xcc
000FBDC5  78C0              js 0xbd87
000FBDC7  C0C6CC            rol dh,byte 0xcc
000FBDCA  F8                clc
000FBDCB  CC                int3
000FBDCC  C60018            mov byte [bx+si],0x18
000FBDCF  1818              sbb [bx+si],bl
000FBDD1  1818              sbb [bx+si],bl
000FBDD3  1818              sbb [bx+si],bl
000FBDD5  0000              add [bx+si],al
000FBDD7  006CFE            add [si-0x2],ch
000FBDDA  D6                salc
000FBDDB  C6C600            mov dh,0x0
000FBDDE  0000              add [bx+si],al
000FBDE0  FC                cld
000FBDE1  C6C6C6            mov dh,0xc6
000FBDE4  C60000            mov byte [bx+si],0x0
000FBDE7  007CC6            add [si-0x3a],bh
000FBDEA  C6C67C            mov dh,0x7c
000FBDED  0000              add [bx+si],al
000FBDEF  00FC              add ah,bh
000FBDF1  C6C6FC            mov dh,0xfc
000FBDF4  C0C000            rol al,byte 0x0
000FBDF7  007EC6            add [bp-0x3a],bh
000FBDFA  C6                db 0xc6
000FBDFB  7E06              jng 0xbe03
000FBDFD  06                push es
000FBDFE  0000              add [bx+si],al
000FBE00  FC                cld
000FBE01  C6C0C0            mov al,0xc0
000FBE04  C00000            rol byte [bx+si],byte 0x0
000FBE07  007CC0            add [si-0x40],bh
000FBE0A  7C06              jl 0xbe12
000FBE0C  FC                cld
000FBE0D  006060            add [bx+si+0x60],ah
000FBE10  FC                cld
000FBE11  60                pusha
000FBE12  60                pusha
000FBE13  663C00            o32 cmp al,0x0
000FBE16  0000              add [bx+si],al
000FBE18  C6C6C6            mov dh,0xc6
000FBE1B  C6                db 0xc6
000FBE1C  7E00              jng 0xbe1e
000FBE1E  0000              add [bx+si],al
000FBE20  C6C6C6            mov dh,0xc6
000FBE23  6C                insb
000FBE24  3800              cmp [bx+si],al
000FBE26  0000              add [bx+si],al
000FBE28  C6C6D6            mov dh,0xd6
000FBE2B  FE                db 0xfe
000FBE2C  6C                insb
000FBE2D  0000              add [bx+si],al
000FBE2F  00C6              add dh,al
000FBE31  6C                insb
000FBE32  386CC6            cmp [si-0x3a],ch
000FBE35  0000              add [bx+si],al
000FBE37  00C6              add dh,al
000FBE39  C6C67E            mov dh,0x7e
000FBE3C  06                push es
000FBE3D  FC                cld
000FBE3E  0000              add [bx+si],al
000FBE40  7E0C              jng 0xbe4e
000FBE42  1830              sbb [bx+si],dh
000FBE44  7E00              jng 0xbe46
000FBE46  0E                push cs
000FBE47  1818              sbb [bx+si],bl
000FBE49  7018              jo 0xbe63
000FBE4B  180E0018          sbb [0x1800],cl
000FBE4F  1818              sbb [bx+si],bl
000FBE51  0018              add [bx+si],bl
000FBE53  1818              sbb [bx+si],bl
000FBE55  007018            add [bx+si+0x18],dh
000FBE58  180E1818          sbb [0x1818],cl
000FBE5C  7000              jo 0xbe5e
000FBE5E  324C00            xor cl,[si+0x0]
000FBE61  0000              add [bx+si],al
000FBE63  0000              add [bx+si],al
000FBE65  0000              add [bx+si],al
000FBE67  183C              sbb [si],bh
000FBE69  66C3              retd
000FBE6B  C3                ret
000FBE6C  FF00              inc word [bx+si]
000FBE6E  EAD60C00FC        jmp 0xfc00:0xcd6
000FBE73  0000              add [bx+si],al
000FBE75  0000              add [bx+si],al
000FBE77  0000              add [bx+si],al
000FBE79  0000              add [bx+si],al
000FBE7B  0000              add [bx+si],al
000FBE7D  0000              add [bx+si],al
000FBE7F  0000              add [bx+si],al
000FBE81  0000              add [bx+si],al
000FBE83  0000              add [bx+si],al
000FBE85  0000              add [bx+si],al
000FBE87  0000              add [bx+si],al
000FBE89  0000              add [bx+si],al
000FBE8B  0000              add [bx+si],al
000FBE8D  0000              add [bx+si],al
000FBE8F  0000              add [bx+si],al
000FBE91  0000              add [bx+si],al
000FBE93  0000              add [bx+si],al
000FBE95  0000              add [bx+si],al
000FBE97  0000              add [bx+si],al
000FBE99  0000              add [bx+si],al
000FBE9B  0000              add [bx+si],al
000FBE9D  0000              add [bx+si],al
000FBE9F  0000              add [bx+si],al
000FBEA1  0000              add [bx+si],al
000FBEA3  0000              add [bx+si],al
000FBEA5  EA240D00FC        jmp 0xfc00:0xd24
000FBEAA  2E27              cs daa
000FBEAC  E8D1D7            call 0x9680
000FBEAF  CB                retf
000FBEB0  BAAF3E            mov dx,0x3eaf
000FBEB3  E943D9            jmp 0x97f9
000FBEB6  002EAD8E          add [0x8ead],ch
000FBEBA  C08BD6BE6E        ror byte [bp+di-0x412a],byte 0x6e
000FBEBF  3AB1042E          cmp dh,[bx+di+0x2e04]
000FBEC3  AD                lodsw
000FBEC4  AB                stosw
000FBEC5  E2FB              loop 0xbec2
000FBEC7  33C0              xor ax,ax
000FBEC9  B10C              mov cl,0xc
000FBECB  F3AB              rep stosw
000FBECD  81FF0010          cmp di,0x1000
000FBED1  72ED              jc 0xbec0
000FBED3  8BF2              mov si,dx
000FBED5  B603              mov dh,0x3
000FBED7  C3                ret
000FBED8  2EAD              cs lodsw
000FBEDA  8BC8              mov cx,ax
000FBEDC  B82007            mov ax,0x720
000FBEDF  F3AB              rep stosw
000FBEE1  B2C0              mov dl,0xc0
000FBEE3  B020              mov al,0x20
000FBEE5  EE                out dx,al
000FBEE6  2EAC              cs lodsb
000FBEE8  FFE3              jmp bx
000FBEEA  BAC003            mov dx,0x3c0
000FBEED  32C0              xor al,al
000FBEEF  EE                out dx,al
000FBEF0  EE                out dx,al
000FBEF1  C3                ret
000FBEF2  004D3F            add [di+0x3f],cl
000FBEF5  4D                dec bp
000FBEF6  3F                aas
000FBEF7  BF174D            mov di,0x4d17
000FBEFA  3F                aas
000FBEFB  4D                dec bp
000FBEFC  3F                aas
000FBEFD  340F              xor al,0xf
000FBEFF  2F                das
000FBF00  134D3F            adc cx,[di+0x3f]
000FBF03  240D              and al,0xd
000FBF05  5F                pop di
000FBF06  11473F            adc [bx+0x3f],ax
000FBF09  47                inc di
000FBF0A  3F                aas
000FBF0B  47                inc di
000FBF0C  3F                aas
000FBF0D  47                inc di
000FBF0E  3F                aas
000FBF0F  57                push di
000FBF10  2F                das
000FBF11  47                inc di
000FBF12  3F                aas
000FBF13  6530D8            gs xor al,bl
000FBF16  0BCE              or cx,si
000FBF18  0B592C            or bx,[bx+di+0x2c]
000FBF1B  AC                lodsb
000FBF1C  0FE20B            psrad mm1,[bp+di]
000FBF1F  0011              add [bx+di],dl
000FBF21  B30E              mov bl,0xe
000FBF23  2D0BE5            sub ax,0xe50b
000FBF26  0AD6              or dl,dh
000FBF28  0C4D              or al,0x4d
000FBF2A  3F                aas
000FBF2B  4D                dec bp
000FBF2C  3F                aas
000FBF2D  A4                movsb
000FBF2E  30C7              xor bh,al
000FBF30  2F                das
000FBF31  0000              add [bx+si],al
000FBF33  0000              add [bx+si],al
000FBF35  0000              add [bx+si],al
000FBF37  0000              add [bx+si],al
000FBF39  0000              add [bx+si],al
000FBF3B  0000              add [bx+si],al
000FBF3D  0000              add [bx+si],al
000FBF3F  0000              add [bx+si],al
000FBF41  0000              add [bx+si],al
000FBF43  0000              add [bx+si],al
000FBF45  0000              add [bx+si],al
000FBF47  50                push ax
000FBF48  B020              mov al,0x20
000FBF4A  E620              out 0x20,al
000FBF4C  58                pop ax
000FBF4D  CF                iret
000FBF4E  0000              add [bx+si],al
000FBF50  0000              add [bx+si],al
000FBF52  0000              add [bx+si],al
000FBF54  EA340F00FC        jmp 0xfc00:0xf34
000FBF59  FD                std
000FBF5A  26F726F726        mul word [es:0x26f7]
000FBF5F  FD                std
000FBF60  26FD              es std
000FBF62  26F726F726        mul word [es:0x26f7]
000FBF67  FD                std
000FBF68  260227            add ah,[es:bx]
000FBF6B  B73E              mov bh,0x3e
000FBF6D  FD                std
000FBF6E  26FD              es std
000FBF70  26D83E05C4        fdivr dword [es:0xc405]
000FBF75  0001              add [bx+di],al
000FBF77  0104              add [si],ax
000FBF79  0007              add [bx],al
000FBF7B  23C2              and ax,dx
000FBF7D  00DA              add dl,bl
000FBF7F  01C4              add sp,ax
000FBF81  0003              add [bp+di],al
000FBF83  19D4              sbb sp,dx
000FBF85  00704F            add [bx+si+0x4f],dh
000FBF88  5C                pop sp
000FBF89  2F                das
000FBF8A  5F                pop di
000FBF8B  07                pop es
000FBF8C  0411              add al,0x11
000FBF8E  0007              add [bx],al
000FBF90  06                push es
000FBF91  0000              add [bx+si],al
000FBF93  0000              add [bx+si],al
000FBF95  00E1              add cl,ah
000FBF97  24C7              and al,0xc7
000FBF99  2808              sub [bx+si],cl
000FBF9B  E0F0              loopne 0xbf8d
000FBF9D  A3FF00            mov [0xff],ax
000FBFA0  CC                int3
000FBFA1  01CA              add dx,cx
000FBFA3  09CE              or si,cx
000FBFA5  0000              add [bx+si],al
000FBFA7  0000              add [bx+si],al
000FBFA9  0000              add [bx+si],al
000FBFAB  000C              add [si],cl
000FBFAD  00FF              add bh,bh
000FBFAF  DA14              ficom dword [si]
000FBFB1  C00000            rol byte [bx+si],byte 0x0
000FBFB4  0102              add [bp+si],ax
000FBFB6  0304              add ax,[si]
000FBFB8  050607            add ax,0x706
000FBFBB  1011              adc [bx+di],dl
000FBFBD  1213              adc dl,[bp+di]
000FBFBF  1415              adc al,0x15
000FBFC1  16                push ss
000FBFC2  17                pop ss
000FBFC3  0800              or [bx+si],al
000FBFC5  0F0000            sldt [bx+si]
000FBFC8  B803C4            mov ax,0xc403
000FBFCB  0203              add al,[bp+di]
000FBFCD  0003              add [bp+di],al
000FBFCF  02CE              add cl,dh
000FBFD1  05100E            add ax,0xe10
000FBFD4  0020              add [bx+si],ah
000FBFD6  07                pop es
000FBFD7  0000              add [bx+si],al
000FBFD9  0000              add [bx+si],al
000FBFDB  0000              add [bx+si],al
000FBFDD  0000              add [bx+si],al
000FBFDF  0000              add [bx+si],al
000FBFE1  0000              add [bx+si],al
000FBFE3  0000              add [bx+si],al
000FBFE5  0000              add [bx+si],al
000FBFE7  0000              add [bx+si],al
000FBFE9  0000              add [bx+si],al
000FBFEB  0000              add [bx+si],al
000FBFED  0000              add [bx+si],al
000FBFEF  00EA              add dl,ch
000FBFF1  5B                pop bx
000FBFF2  2000              and [bx+si],al
000FBFF4  FC                cld
000FBFF5  07                pop es
000FBFF6  0000              add [bx+si],al
000FBFF8  0000              add [bx+si],al
000FBFFA  0000              add [bx+si],al
000FBFFC  0000              add [bx+si],al
000FBFFE  FF                db 0xff
000FBFFF  FF                db 0xff
000FC000  E9C600            jmp 0xc0c9
000FC003  284329            sub [bp+di+0x29],al
000FC006  20436F            and [bp+di+0x6f],al
000FC009  7079              jo 0xc084
000FC00B  7269              jc 0xc076
000FC00D  67687420          push word 0x2074
000FC011  3139              xor [bx+di],di
000FC013  3838              cmp [bx+si],bh
000FC015  20416D            and [bx+di+0x6d],al
000FC018  7374              jnc 0xc08e
000FC01A  7261              jc 0xc07d
000FC01C  6420706C          and [fs:bx+si+0x6c],dh
000FC020  6328              arpl [bx+si],bp
000FC022  284343            sub [bp+di+0x43],al
000FC025  2929              sub [bx+di],bp
000FC027  2020              and [bx+si],ah
000FC029  43                inc bx
000FC02A  43                inc bx
000FC02B  6F                outsw
000FC02C  6F                outsw
000FC02D  7070              jo 0xc09f
000FC02F  7979              jns 0xc0aa
000FC031  7272              jc 0xc0a5
000FC033  6969676768        imul bp,[bx+di+0x67],word 0x6867
000FC038  687474            push word 0x7474
000FC03B  2020              and [bx+si],ah
000FC03D  3131              xor [bx+di],si
000FC03F  3939              cmp [bx+di],di
000FC041  3838              cmp [bx+si],bh
000FC043  3838              cmp [bx+si],bh
000FC045  2020              and [bx+si],ah
000FC047  41                inc cx
000FC048  41                inc cx
000FC049  6D                insw
000FC04A  6D                insw
000FC04B  7373              jnc 0xc0c0
000FC04D  7474              jz 0xc0c3
000FC04F  7272              jc 0xc0c3
000FC051  61                popa
000FC052  61                popa
000FC053  64642020          and [fs:bx+si],ah
000FC057  7070              jo 0xc0c9
000FC059  6C                insb
000FC05A  6C                insb
000FC05B  636360            arpl [bp+di+0x60],sp
000FC05E  32E4              xor ah,ah
000FC060  8BD8              mov bx,ax
000FC062  8BEA              mov bp,dx
000FC064  B800B8            mov ax,0xb800
000FC067  8ED8              mov ds,ax
000FC069  C6072E            mov byte [bx],0x2e
000FC06C  B4B0              mov ah,0xb0
000FC06E  8ED8              mov ds,ax
000FC070  C6072E            mov byte [bx],0x2e
000FC073  D1CB              ror bx,1
000FC075  43                inc bx
000FC076  B97E00            mov cx,0x7e
000FC079  BAD403            mov dx,0x3d4
000FC07C  EB05              jmp short 0xc083
000FC07E  8BCF              mov cx,di
000FC080  BAB403            mov dx,0x3b4
000FC083  B00F              mov al,0xf
000FC085  EE                out dx,al
000FC086  8AC3              mov al,bl
000FC088  42                inc dx
000FC089  EE                out dx,al
000FC08A  8BD5              mov dx,bp
000FC08C  FFE1              jmp cx
000FC08E  B90410            mov cx,0x1004
000FC091  BAC203            mov dx,0x3c2
000FC094  33C0              xor ax,ax
000FC096  80ED04            sub ch,0x4
000FC099  8AC5              mov al,ch
000FC09B  EE                out dx,al
000FC09C  8A07              mov al,[bx]
000FC09E  EC                in al,dx
000FC09F  F6D0              not al
000FC0A1  2410              and al,0x10
000FC0A3  D2E8              shr al,cl
000FC0A5  0AE0              or ah,al
000FC0A7  FEC9              dec cl
000FC0A9  75EB              jnz 0xc096
000FC0AB  80FC0A            cmp ah,0xa
000FC0AE  7203              jc 0xc0b3
000FC0B0  80EC06            sub ah,0x6
000FC0B3  8BDE              mov bx,si
000FC0B5  BED72F            mov si,0x2fd7
000FC0B8  80FC05            cmp ah,0x5
000FC0BB  7603              jna 0xc0c0
000FC0BD  BE733F            mov si,0x3f73
000FC0C0  FC                cld
000FC0C1  8CC8              mov ax,cs
000FC0C3  8ED0              mov ss,ax
000FC0C5  BC593F            mov sp,0x3f59
000FC0C8  C3                ret
000FC0C9  FA                cli
000FC0CA  33C0              xor ax,ax
000FC0CC  E6A0              out 0xa0,al
000FC0CE  BAF203            mov dx,0x3f2
000FC0D1  EE                out dx,al
000FC0D2  8ED8              mov ds,ax
000FC0D4  813E72043412      cmp word [0x472],0x1234
000FC0DA  7508              jnz 0xc0e4
000FC0DC  FF067204          inc word [0x472]
000FC0E0  E666              out 0x66,al
000FC0E2  EBFE              jmp short 0xc0e2
000FC0E4  7C04              jl 0xc0ea
000FC0E6  FF0E7204          dec word [0x472]
000FC0EA  BAFC03            mov dx,0x3fc
000FC0ED  B010              mov al,0x10
000FC0EF  EE                out dx,al
000FC0F0  B00D              mov al,0xd
000FC0F2  BBF800            mov bx,0xf8
000FC0F5  E9890B            jmp 0xcc81
000FC0F8  750C              jnz 0xc106
000FC0FA  02C0              add al,al
000FC0FC  7228              jc 0xc126
000FC0FE  813E72043412      cmp word [0x472],0x1234
000FC104  7420              jz 0xc126
000FC106  B80B82            mov ax,0x820b
000FC109  EF                out dx,ax
000FC10A  B94000            mov cx,0x40
000FC10D  BB0502            mov bx,0x205
000FC110  33C0              xor ax,ax
000FC112  2E8A27            mov ah,[cs:bx]
000FC115  80FCFE            cmp ah,0xfe
000FC118  7401              jz 0xc11b
000FC11A  EF                out dx,ax
000FC11B  FEC0              inc al
000FC11D  81FB2E02          cmp bx,0x22e
000FC121  7401              jz 0xc124
000FC123  43                inc bx
000FC124  E2EC              loop 0xc112
000FC126  B023              mov al,0x23
000FC128  BB2E01            mov bx,0x12e
000FC12B  E9530B            jmp 0xcc81
000FC12E  8AE0              mov ah,al
000FC130  B700              mov bh,0x0
000FC132  7402              jz 0xc136
000FC134  B7FF              mov bh,0xff
000FC136  BADA03            mov dx,0x3da
000FC139  EC                in al,dx
000FC13A  B27A              mov dl,0x7a
000FC13C  EC                in al,dx
000FC13D  A820              test al,0x20
000FC13F  754E              jnz 0xc18f
000FC141  EC                in al,dx
000FC142  24C0              and al,0xc0
000FC144  B102              mov cl,0x2
000FC146  D2C0              rol al,cl
000FC148  8AD8              mov bl,al
000FC14A  FECE              dec dh
000FC14C  EC                in al,dx
000FC14D  FEC6              inc dh
000FC14F  EC                in al,dx
000FC150  2420              and al,0x20
000FC152  D2C8              ror al,cl
000FC154  D0C8              ror al,1
000FC156  0AD8              or bl,al
000FC158  B642              mov dh,0x42
000FC15A  EC                in al,dx
000FC15B  B603              mov dh,0x3
000FC15D  EC                in al,dx
000FC15E  2420              and al,0x20
000FC160  D2C8              ror al,cl
000FC162  0AD8              or bl,al
000FC164  80E4C0            and ah,0xc0
000FC167  0AE3              or ah,bl
000FC169  2408              and al,0x8
000FC16B  7407              jz 0xc174
000FC16D  EC                in al,dx
000FC16E  24C0              and al,0xc0
000FC170  D2C8              ror al,cl
000FC172  0AE0              or ah,al
000FC174  B023              mov al,0x23
000FC176  BA7000            mov dx,0x70
000FC179  EF                out dx,ax
000FC17A  B82801            mov ax,0x128
000FC17D  EF                out dx,ax
000FC17E  0AFF              or bh,bh
000FC180  750B              jnz 0xc18d
000FC182  BB8801            mov bx,0x188
000FC185  E9010B            jmp 0xcc89
000FC188  8AE1              mov ah,cl
000FC18A  B014              mov al,0x14
000FC18C  EF                out dx,ax
000FC18D  2AC0              sub al,al
000FC18F  8AE0              mov ah,al
000FC191  BA7903            mov dx,0x379
000FC194  EC                in al,dx
000FC195  2407              and al,0x7
000FC197  752F              jnz 0xc1c8
000FC199  0AE4              or ah,ah
000FC19B  7512              jnz 0xc1af
000FC19D  B800E0            mov ax,0xe000
000FC1A0  8ED8              mov ds,ax
000FC1A2  813E000055AA      cmp word [0x0],0xaa55
000FC1A8  7505              jnz 0xc1af
000FC1AA  EA030000E0        jmp 0xe000:0x3
000FC1AF  B800C0            mov ax,0xc000
000FC1B2  8ED8              mov ds,ax
000FC1B4  813E000055AA      cmp word [0x0],0xaa55
000FC1BA  7525              jnz 0xc1e1
000FC1BC  803E020020        cmp byte [0x2],0x20
000FC1C1  741E              jz 0xc1e1
000FC1C3  EA030000C0        jmp 0xc000:0x3
000FC1C8  33DB              xor bx,bx
000FC1CA  B90040            mov cx,0x4000
000FC1CD  33C0              xor ax,ax
000FC1CF  2E0207            add al,[cs:bx]
000FC1D2  43                inc bx
000FC1D3  E2FA              loop 0xc1cf
000FC1D5  0AC0              or al,al
000FC1D7  7503              jnz 0xc1dc
000FC1D9  EB54              jmp short 0xc22f
000FC1DB  90                nop
000FC1DC  B00D              mov al,0xd
000FC1DE  E9E015            jmp 0xd7c1
000FC1E1  BB490B            mov bx,0xb49
000FC1E4  2E8A0F            mov cl,[cs:bx]
000FC1E7  32ED              xor ch,ch
000FC1E9  E30F              jcxz 0xc1fa
000FC1EB  43                inc bx
000FC1EC  2E8B17            mov dx,[cs:bx]
000FC1EF  43                inc bx
000FC1F0  43                inc bx
000FC1F1  2E8A07            mov al,[cs:bx]
000FC1F4  EE                out dx,al
000FC1F5  43                inc bx
000FC1F6  E2F9              loop 0xc1f1
000FC1F8  EBEA              jmp short 0xc1e4
000FC1FA  32C0              xor al,al
000FC1FC  E683              out 0x83,al
000FC1FE  E681              out 0x81,al
000FC200  E682              out 0x82,al
000FC202  E91504            jmp 0xc61a
000FC205  0000              add [bx+si],al
000FC207  0000              add [bx+si],al
000FC209  0000              add [bx+si],al
000FC20B  0101              add [bx+di],ax
000FC20D  01802002          add [bx+si+0x220],ax
000FC211  FE                db 0xfe
000FC212  FE00              inc byte [bx+si]
000FC214  0001              add [bx+di],al
000FC216  0101              add [bx+di],ax
000FC218  7800              js 0xc21a
000FC21A  0D1C07            or ax,0x71c
000FC21D  22FF              and bh,bh
000FC21F  FF                db 0xff
000FC220  FF                db 0xff
000FC221  FF0D              dec word [di]
000FC223  1C1B              sbb al,0x1b
000FC225  010A              add [bp+si],cx
000FC227  0A20              or ah,[bx+si]
000FC229  07                pop es
000FC22A  00E3              add bl,ah
000FC22C  E300              jcxz 0xc22e
000FC22E  00B028BB          add [bx+si-0x44d8],dh
000FC232  37                aaa
000FC233  02E9              add ch,cl
000FC235  4A                dec dx
000FC236  0A0A              or cl,[bp+si]
000FC238  C0                db 0xc0
000FC239  7403              jz 0xc23e
000FC23B  E9E000            jmp 0xc31e
000FC23E  BAD803            mov dx,0x3d8
000FC241  B012              mov al,0x12
000FC243  EE                out dx,al
000FC244  B800B8            mov ax,0xb800
000FC247  8EC0              mov es,ax
000FC249  8ED8              mov ds,ax
000FC24B  33FF              xor di,di
000FC24D  BADD03            mov dx,0x3dd
000FC250  B80100            mov ax,0x1
000FC253  EF                out dx,ax
000FC254  33C9              xor cx,cx
000FC256  890D              mov [di],cx
000FC258  3B0D              cmp cx,[di]
000FC25A  7513              jnz 0xc26f
000FC25C  F7D1              not cx
000FC25E  890D              mov [di],cx
000FC260  3B0D              cmp cx,[di]
000FC262  750B              jnz 0xc26f
000FC264  F7D1              not cx
000FC266  83F901            cmp cx,byte +0x1
000FC269  13C9              adc cx,cx
000FC26B  73E9              jnc 0xc256
000FC26D  EB05              jmp short 0xc274
000FC26F  B002              mov al,0x2
000FC271  E94D15            jmp 0xd7c1
000FC274  BEFF00            mov si,0xff
000FC277  33C0              xor ax,ax
000FC279  8ED8              mov ds,ax
000FC27B  813E72043412      cmp word [0x472],0x1234
000FC281  745F              jz 0xc2e2
000FC283  8CC0              mov ax,es
000FC285  8ED8              mov ds,ax
000FC287  FC                cld
000FC288  B00F              mov al,0xf
000FC28A  EE                out dx,al
000FC28B  33FF              xor di,di
000FC28D  B90020            mov cx,0x2000
000FC290  8BC6              mov ax,si
000FC292  8AE0              mov ah,al
000FC294  F3AB              rep stosw
000FC296  B90040            mov cx,0x4000
000FC299  33FF              xor di,di
000FC29B  BB0804            mov bx,0x408
000FC29E  8BC3              mov ax,bx
000FC2A0  FECC              dec ah
000FC2A2  EF                out dx,ax
000FC2A3  8BC6              mov ax,si
000FC2A5  3205              xor al,[di]
000FC2A7  8825              mov [di],ah
000FC2A9  3225              xor ah,[di]
000FC2AB  0BC0              or ax,ax
000FC2AD  75C0              jnz 0xc26f
000FC2AF  D0CB              ror bl,1
000FC2B1  FECF              dec bh
000FC2B3  75E9              jnz 0xc29e
000FC2B5  47                inc di
000FC2B6  E2E3              loop 0xc29b
000FC2B8  F7D6              not si
000FC2BA  FD                std
000FC2BB  8BCF              mov cx,di
000FC2BD  4F                dec di
000FC2BE  BB0100            mov bx,0x1
000FC2C1  8BC3              mov ax,bx
000FC2C3  EF                out dx,ax
000FC2C4  8BC6              mov ax,si
000FC2C6  3205              xor al,[di]
000FC2C8  8825              mov [di],ah
000FC2CA  3225              xor ah,[di]
000FC2CC  0BC0              or ax,ax
000FC2CE  759F              jnz 0xc26f
000FC2D0  D0C3              rol bl,1
000FC2D2  FEC7              inc bh
000FC2D4  80FF04            cmp bh,0x4
000FC2D7  75E8              jnz 0xc2c1
000FC2D9  4F                dec di
000FC2DA  E2E2              loop 0xc2be
000FC2DC  F7C6FF00          test si,0xff
000FC2E0  74A5              jz 0xc287
000FC2E2  BADA03            mov dx,0x3da
000FC2E5  33C9              xor cx,cx
000FC2E7  EC                in al,dx
000FC2E8  8AE0              mov ah,al
000FC2EA  EC                in al,dx
000FC2EB  32C4              xor al,ah
000FC2ED  2401              and al,0x1
000FC2EF  7504              jnz 0xc2f5
000FC2F1  E2F7              loop 0xc2ea
000FC2F3  EB4B              jmp short 0xc340
000FC2F5  32DB              xor bl,bl
000FC2F7  33C9              xor cx,cx
000FC2F9  BEFE02            mov si,0x2fe
000FC2FC  EB25              jmp short 0xc323
000FC2FE  B308              mov bl,0x8
000FC300  B9600C            mov cx,0xc60
000FC303  BE0803            mov si,0x308
000FC306  EB1B              jmp short 0xc323
000FC308  81F91C0B          cmp cx,0xb1c
000FC30C  7732              ja 0xc340
000FC30E  32DB              xor bl,bl
000FC310  B90004            mov cx,0x400
000FC313  BE1803            mov si,0x318
000FC316  EB0B              jmp short 0xc323
000FC318  81F99603          cmp cx,0x396
000FC31C  7722              ja 0xc340
000FC31E  B00F              mov al,0xf
000FC320  E99E14            jmp 0xd7c1
000FC323  EC                in al,dx
000FC324  2408              and al,0x8
000FC326  8AF8              mov bh,al
000FC328  EC                in al,dx
000FC329  2408              and al,0x8
000FC32B  32F8              xor bh,al
000FC32D  8AF8              mov bh,al
000FC32F  F9                stc
000FC330  740C              jz 0xc33e
000FC332  32C3              xor al,bl
000FC334  7508              jnz 0xc33e
000FC336  33C0              xor ax,ax
000FC338  8ED8              mov ds,ax
000FC33A  890F              mov [bx],cx
000FC33C  FFE6              jmp si
000FC33E  E2E8              loop 0xc328
000FC340  B009              mov al,0x9
000FC342  E97C14            jmp 0xd7c1
000FC345  B0A0              mov al,0xa0
000FC347  BF4D03            mov di,0x34d
000FC34A  E911FD            jmp 0xc05e
000FC34D  BA0800            mov dx,0x8
000FC350  B004              mov al,0x4
000FC352  EE                out dx,al
000FC353  B90800            mov cx,0x8
000FC356  BA0000            mov dx,0x0
000FC359  BE5E03            mov si,0x35e
000FC35C  EB13              jmp short 0xc371
000FC35E  42                inc dx
000FC35F  E2F8              loop 0xc359
000FC361  B90800            mov cx,0x8
000FC364  BA0700            mov dx,0x7
000FC367  BE6C03            mov si,0x36c
000FC36A  EB05              jmp short 0xc371
000FC36C  4A                dec dx
000FC36D  E2F8              loop 0xc367
000FC36F  EB1C              jmp short 0xc38d
000FC371  E60C              out 0xc,al
000FC373  8AC2              mov al,dl
000FC375  90                nop
000FC376  EE                out dx,al
000FC377  90                nop
000FC378  90                nop
000FC379  EE                out dx,al
000FC37A  90                nop
000FC37B  90                nop
000FC37C  EC                in al,dx
000FC37D  3AC2              cmp al,dl
000FC37F  7507              jnz 0xc388
000FC381  EC                in al,dx
000FC382  3AC2              cmp al,dl
000FC384  7502              jnz 0xc388
000FC386  FFE6              jmp si
000FC388  B004              mov al,0x4
000FC38A  E93414            jmp 0xd7c1
000FC38D  B0A2              mov al,0xa2
000FC38F  BF9503            mov di,0x395
000FC392  E9C9FC            jmp 0xc05e
000FC395  33C0              xor ax,ax
000FC397  8ED8              mov ds,ax
000FC399  32C0              xor al,al
000FC39B  E661              out 0x61,al
000FC39D  BA4300            mov dx,0x43
000FC3A0  B0B0              mov al,0xb0
000FC3A2  F8                clc
000FC3A3  EE                out dx,al
000FC3A4  33DB              xor bx,bx
000FC3A6  BA4200            mov dx,0x42
000FC3A9  8AC3              mov al,bl
000FC3AB  EE                out dx,al
000FC3AC  EB00              jmp short 0xc3ae
000FC3AE  EE                out dx,al
000FC3AF  8B360004          mov si,[0x400]
000FC3B3  EC                in al,dx
000FC3B4  3AC3              cmp al,bl
000FC3B6  753E              jnz 0xc3f6
000FC3B8  90                nop
000FC3B9  EC                in al,dx
000FC3BA  3AC3              cmp al,bl
000FC3BC  7538              jnz 0xc3f6
000FC3BE  F7D3              not bx
000FC3C0  0BDB              or bx,bx
000FC3C2  75E2              jnz 0xc3a6
000FC3C4  B078              mov al,0x78
000FC3C6  E643              out 0x43,al
000FC3C8  BA4100            mov dx,0x41
000FC3CB  B07C              mov al,0x7c
000FC3CD  F8                clc
000FC3CE  EE                out dx,al
000FC3CF  B02E              mov al,0x2e
000FC3D1  90                nop
000FC3D2  90                nop
000FC3D3  EE                out dx,al
000FC3D4  B9A005            mov cx,0x5a0
000FC3D7  90                nop
000FC3D8  90                nop
000FC3D9  90                nop
000FC3DA  B048              mov al,0x48
000FC3DC  E643              out 0x43,al
000FC3DE  EB00              jmp short 0xc3e0
000FC3E0  EC                in al,dx
000FC3E1  EB00              jmp short 0xc3e3
000FC3E3  EC                in al,dx
000FC3E4  3C2E              cmp al,0x2e
000FC3E6  7704              ja 0xc3ec
000FC3E8  E2F0              loop 0xc3da
000FC3EA  EB0A              jmp short 0xc3f6
000FC3EC  81F91005          cmp cx,0x510
000FC3F0  7704              ja 0xc3f6
000FC3F2  890F              mov [bx],cx
000FC3F4  EB0B              jmp short 0xc401
000FC3F6  890F              mov [bx],cx
000FC3F8  B006              mov al,0x6
000FC3FA  E9C413            jmp 0xd7c1
000FC3FD  0F1D2D            hint_nop45 word [di]
000FC400  4D                dec bp
000FC401  B0A4              mov al,0xa4
000FC403  BF0904            mov di,0x409
000FC406  E955FC            jmp 0xc05e
000FC409  B0B0              mov al,0xb0
000FC40B  E661              out 0x61,al
000FC40D  BBFD03            mov bx,0x3fd
000FC410  B90400            mov cx,0x4
000FC413  BA6000            mov dx,0x60
000FC416  2E8A07            mov al,[cs:bx]
000FC419  E664              out 0x64,al
000FC41B  EC                in al,dx
000FC41C  2E3A07            cmp al,[cs:bx]
000FC41F  755F              jnz 0xc480
000FC421  F6D0              not al
000FC423  E664              out 0x64,al
000FC425  EC                in al,dx
000FC426  F6D0              not al
000FC428  348D              xor al,0x8d
000FC42A  2E3A07            cmp al,[cs:bx]
000FC42D  7551              jnz 0xc480
000FC42F  43                inc bx
000FC430  E2E4              loop 0xc416
000FC432  B90400            mov cx,0x4
000FC435  42                inc dx
000FC436  8AC5              mov al,ch
000FC438  BF3E04            mov di,0x43e
000FC43B  EB48              jmp short 0xc485
000FC43D  90                nop
000FC43E  3AC5              cmp al,ch
000FC440  753E              jnz 0xc480
000FC442  F6D0              not al
000FC444  BF4A04            mov di,0x44a
000FC447  EB3C              jmp short 0xc485
000FC449  90                nop
000FC44A  341F              xor al,0x1f
000FC44C  3AC5              cmp al,ch
000FC44E  7530              jnz 0xc480
000FC450  B510              mov ch,0x10
000FC452  0AC0              or al,al
000FC454  74E0              jz 0xc436
000FC456  D0D8              rcr al,1
000FC458  8AE8              mov ch,al
000FC45A  73DA              jnc 0xc436
000FC45C  B031              mov al,0x31
000FC45E  EE                out dx,al
000FC45F  B0B0              mov al,0xb0
000FC461  E643              out 0x43,al
000FC463  EB00              jmp short 0xc465
000FC465  E462              in al,0x62
000FC467  2420              and al,0x20
000FC469  7515              jnz 0xc480
000FC46B  40                inc ax
000FC46C  E642              out 0x42,al
000FC46E  EB00              jmp short 0xc470
000FC470  FEC8              dec al
000FC472  E642              out 0x42,al
000FC474  B90600            mov cx,0x6
000FC477  90                nop
000FC478  E2FE              loop 0xc478
000FC47A  E462              in al,0x62
000FC47C  2420              and al,0x20
000FC47E  751D              jnz 0xc49d
000FC480  B007              mov al,0x7
000FC482  E93C13            jmp 0xd7c1
000FC485  E665              out 0x65,al
000FC487  B030              mov al,0x30
000FC489  EE                out dx,al
000FC48A  E462              in al,0x62
000FC48C  D2D0              rcl al,cl
000FC48E  2410              and al,0x10
000FC490  8AE0              mov ah,al
000FC492  B034              mov al,0x34
000FC494  EE                out dx,al
000FC495  E462              in al,0x62
000FC497  240F              and al,0xf
000FC499  0AC4              or al,ah
000FC49B  FFE7              jmp di
000FC49D  B0A6              mov al,0xa6
000FC49F  BFA504            mov di,0x4a5
000FC4A2  E9B9FB            jmp 0xc05e
000FC4A5  BA7000            mov dx,0x70
000FC4A8  B37F              mov bl,0x7f
000FC4AA  BEAF04            mov si,0x4af
000FC4AD  EB55              jmp short 0xc504
000FC4AF  B000              mov al,0x0
000FC4B1  BDB704            mov bp,0x4b7
000FC4B4  EB7E              jmp short 0xc534
000FC4B6  90                nop
000FC4B7  8EC0              mov es,ax
000FC4B9  B37F              mov bl,0x7f
000FC4BB  BEC004            mov si,0x4c0
000FC4BE  EB44              jmp short 0xc504
000FC4C0  B000              mov al,0x0
000FC4C2  BDC704            mov bp,0x4c7
000FC4C5  EB6D              jmp short 0xc534
000FC4C7  8CC1              mov cx,es
000FC4C9  3AC1              cmp al,cl
000FC4CB  746D              jz 0xc53a
000FC4CD  BDD204            mov bp,0x4d2
000FC4D0  EB60              jmp short 0xc532
000FC4D2  8AC8              mov cl,al
000FC4D4  32ED              xor ch,ch
000FC4D6  8AE5              mov ah,ch
000FC4D8  B014              mov al,0x14
000FC4DA  EF                out dx,ax
000FC4DB  BDE004            mov bp,0x4e0
000FC4DE  EB52              jmp short 0xc532
000FC4E0  3AC5              cmp al,ch
000FC4E2  7556              jnz 0xc53a
000FC4E4  F6D0              not al
000FC4E6  8AE0              mov ah,al
000FC4E8  B014              mov al,0x14
000FC4EA  EF                out dx,ax
000FC4EB  BDF004            mov bp,0x4f0
000FC4EE  EB42              jmp short 0xc532
000FC4F0  F6D0              not al
000FC4F2  3AC5              cmp al,ch
000FC4F4  7544              jnz 0xc53a
000FC4F6  80FD01            cmp ch,0x1
000FC4F9  12ED              adc ch,ch
000FC4FB  73D9              jnc 0xc4d6
000FC4FD  8AE1              mov ah,cl
000FC4FF  B014              mov al,0x14
000FC501  EF                out dx,ax
000FC502  EB3B              jmp short 0xc53f
000FC504  B00A              mov al,0xa
000FC506  BD0C05            mov bp,0x50c
000FC509  EB29              jmp short 0xc534
000FC50B  90                nop
000FC50C  8AF8              mov bh,al
000FC50E  BF0A00            mov di,0xa
000FC511  33C9              xor cx,cx
000FC513  B00A              mov al,0xa
000FC515  BD1A05            mov bp,0x51a
000FC518  EB1A              jmp short 0xc534
000FC51A  32F8              xor bh,al
000FC51C  80E780            and bh,0x80
000FC51F  8AF8              mov bh,al
000FC521  7406              jz 0xc529
000FC523  32C3              xor al,bl
000FC525  2480              and al,0x80
000FC527  7407              jz 0xc530
000FC529  E2E8              loop 0xc513
000FC52B  4F                dec di
000FC52C  75E5              jnz 0xc513
000FC52E  EB0A              jmp short 0xc53a
000FC530  FFE6              jmp si
000FC532  B014              mov al,0x14
000FC534  EE                out dx,al
000FC535  42                inc dx
000FC536  EC                in al,dx
000FC537  4A                dec dx
000FC538  FFE5              jmp bp
000FC53A  B008              mov al,0x8
000FC53C  E98212            jmp 0xd7c1
000FC53F  BAFB03            mov dx,0x3fb
000FC542  B09B              mov al,0x9b
000FC544  EE                out dx,al
000FC545  EB00              jmp short 0xc547
000FC547  BAF803            mov dx,0x3f8
000FC54A  B00C              mov al,0xc
000FC54C  EE                out dx,al
000FC54D  EB00              jmp short 0xc54f
000FC54F  42                inc dx
000FC550  32C0              xor al,al
000FC552  EE                out dx,al
000FC553  EB00              jmp short 0xc555
000FC555  BAFB03            mov dx,0x3fb
000FC558  B01B              mov al,0x1b
000FC55A  EE                out dx,al
000FC55B  EB00              jmp short 0xc55d
000FC55D  BAF903            mov dx,0x3f9
000FC560  B000              mov al,0x0
000FC562  EE                out dx,al
000FC563  B96202            mov cx,0x262
000FC566  E2FE              loop 0xc566
000FC568  42                inc dx
000FC569  42                inc dx
000FC56A  EC                in al,dx
000FC56B  EB00              jmp short 0xc56d
000FC56D  90                nop
000FC56E  BAF803            mov dx,0x3f8
000FC571  EC                in al,dx
000FC572  B341              mov bl,0x41
000FC574  BE7905            mov si,0x579
000FC577  EB05              jmp short 0xc57e
000FC579  B343              mov bl,0x43
000FC57B  BEC205            mov si,0x5c2
000FC57E  33C9              xor cx,cx
000FC580  BAFD03            mov dx,0x3fd
000FC583  EC                in al,dx
000FC584  2420              and al,0x20
000FC586  7505              jnz 0xc58d
000FC588  E2F6              loop 0xc580
000FC58A  EB31              jmp short 0xc5bd
000FC58C  90                nop
000FC58D  BAF803            mov dx,0x3f8
000FC590  8AC3              mov al,bl
000FC592  EE                out dx,al
000FC593  BAFD03            mov dx,0x3fd
000FC596  B404              mov ah,0x4
000FC598  33C9              xor cx,cx
000FC59A  EB00              jmp short 0xc59c
000FC59C  EC                in al,dx
000FC59D  2401              and al,0x1
000FC59F  7508              jnz 0xc5a9
000FC5A1  E2F9              loop 0xc59c
000FC5A3  FECC              dec ah
000FC5A5  75F5              jnz 0xc59c
000FC5A7  EB14              jmp short 0xc5bd
000FC5A9  BAF803            mov dx,0x3f8
000FC5AC  EC                in al,dx
000FC5AD  3AC3              cmp al,bl
000FC5AF  750C              jnz 0xc5bd
000FC5B1  EB00              jmp short 0xc5b3
000FC5B3  BAFD03            mov dx,0x3fd
000FC5B6  EC                in al,dx
000FC5B7  240E              and al,0xe
000FC5B9  7502              jnz 0xc5bd
000FC5BB  FFE6              jmp si
000FC5BD  B00B              mov al,0xb
000FC5BF  E9FF11            jmp 0xd7c1
000FC5C2  B0A8              mov al,0xa8
000FC5C4  BFCA05            mov di,0x5ca
000FC5C7  E994FA            jmp 0xc05e
000FC5CA  BA7A03            mov dx,0x37a
000FC5CD  32C0              xor al,al
000FC5CF  EE                out dx,al
000FC5D0  BA7803            mov dx,0x378
000FC5D3  32ED              xor ch,ch
000FC5D5  8AC5              mov al,ch
000FC5D7  EE                out dx,al
000FC5D8  8B3E0004          mov di,[0x400]
000FC5DC  EC                in al,dx
000FC5DD  3AC5              cmp al,ch
000FC5DF  7517              jnz 0xc5f8
000FC5E1  F6D0              not al
000FC5E3  EE                out dx,al
000FC5E4  8B3E0004          mov di,[0x400]
000FC5E8  EC                in al,dx
000FC5E9  F6D0              not al
000FC5EB  3AC5              cmp al,ch
000FC5ED  7509              jnz 0xc5f8
000FC5EF  80FD01            cmp ch,0x1
000FC5F2  12ED              adc ch,ch
000FC5F4  73DF              jnc 0xc5d5
000FC5F6  EB05              jmp short 0xc5fd
000FC5F8  B00A              mov al,0xa
000FC5FA  E9C411            jmp 0xd7c1
000FC5FD  BA7800            mov dx,0x78
000FC600  32C0              xor al,al
000FC602  EE                out dx,al
000FC603  EC                in al,dx
000FC604  0AC0              or al,al
000FC606  750D              jnz 0xc615
000FC608  42                inc dx
000FC609  42                inc dx
000FC60A  32C0              xor al,al
000FC60C  EE                out dx,al
000FC60D  EC                in al,dx
000FC60E  0AC0              or al,al
000FC610  7503              jnz 0xc615
000FC612  E9CCFB            jmp 0xc1e1
000FC615  B00C              mov al,0xc
000FC617  E9A711            jmp 0xd7c1
000FC61A  BA7903            mov dx,0x379
000FC61D  EC                in al,dx
000FC61E  33F6              xor si,si
000FC620  B210              mov dl,0x10
000FC622  2407              and al,0x7
000FC624  7472              jz 0xc698
000FC626  B0AA              mov al,0xaa
000FC628  BF2E06            mov di,0x62e
000FC62B  E930FA            jmp 0xc05e
000FC62E  33DB              xor bx,bx
000FC630  B90400            mov cx,0x4
000FC633  B80080            mov ax,0x8000
000FC636  8ED8              mov ds,ax
000FC638  8907              mov [bx],ax
000FC63A  050008            add ax,0x800
000FC63D  E2F7              loop 0xc636
000FC63F  B80080            mov ax,0x8000
000FC642  B90400            mov cx,0x4
000FC645  8ED8              mov ds,ax
000FC647  3907              cmp [bx],ax
000FC649  7505              jnz 0xc650
000FC64B  050008            add ax,0x800
000FC64E  E2F5              loop 0xc645
000FC650  B103              mov cl,0x3
000FC652  D2CC              ror ah,cl
000FC654  8AD4              mov dl,ah
000FC656  33C0              xor ax,ax
000FC658  8ED8              mov ds,ax
000FC65A  8AF2              mov dh,dl
000FC65C  8BC8              mov cx,ax
000FC65E  890F              mov [bx],cx
000FC660  390F              cmp [bx],cx
000FC662  751E              jnz 0xc682
000FC664  8BC1              mov ax,cx
000FC666  F7D0              not ax
000FC668  8907              mov [bx],ax
000FC66A  3907              cmp [bx],ax
000FC66C  7514              jnz 0xc682
000FC66E  83F901            cmp cx,byte +0x1
000FC671  13C9              adc cx,cx
000FC673  73E9              jnc 0xc65e
000FC675  8CD8              mov ax,ds
000FC677  050008            add ax,0x800
000FC67A  8ED8              mov ds,ax
000FC67C  FECE              dec dh
000FC67E  75DE              jnz 0xc65e
000FC680  EB05              jmp short 0xc687
000FC682  B001              mov al,0x1
000FC684  E93A11            jmp 0xd7c1
000FC687  33C0              xor ax,ax
000FC689  8ED8              mov ds,ax
000FC68B  8B2E7204          mov bp,[0x472]
000FC68F  33F6              xor si,si
000FC691  81FD3412          cmp bp,0x1234
000FC695  7401              jz 0xc698
000FC697  4E                dec si
000FC698  8AF2              mov dh,dl
000FC69A  33C0              xor ax,ax
000FC69C  8EC0              mov es,ax
000FC69E  8ED8              mov ds,ax
000FC6A0  FC                cld
000FC6A1  B90040            mov cx,0x4000
000FC6A4  33FF              xor di,di
000FC6A6  8BC6              mov ax,si
000FC6A8  F3AB              rep stosw
000FC6AA  8CC0              mov ax,es
000FC6AC  050008            add ax,0x800
000FC6AF  8EC0              mov es,ax
000FC6B1  FECE              dec dh
000FC6B3  75EC              jnz 0xc6a1
000FC6B5  8AE2              mov ah,dl
000FC6B7  BA7903            mov dx,0x379
000FC6BA  EC                in al,dx
000FC6BB  8AD4              mov dl,ah
000FC6BD  2407              and al,0x7
000FC6BF  740A              jz 0xc6cb
000FC6C1  81FD3412          cmp bp,0x1234
000FC6C5  872E7204          xchg [0x472],bp
000FC6C9  7503              jnz 0xc6ce
000FC6CB  E98000            jmp 0xc74e
000FC6CE  872E7204          xchg [0x472],bp
000FC6D2  8AF2              mov dh,dl
000FC6D4  8BFE              mov di,si
000FC6D6  F7D7              not di
000FC6D8  33C0              xor ax,ax
000FC6DA  8ED0              mov ss,ax
000FC6DC  B90020            mov cx,0x2000
000FC6DF  33E4              xor sp,sp
000FC6E1  90                nop
000FC6E2  5D                pop bp
000FC6E3  33EE              xor bp,si
000FC6E5  57                push di
000FC6E6  58                pop ax
000FC6E7  33C7              xor ax,di
000FC6E9  0BE8              or bp,ax
000FC6EB  58                pop ax
000FC6EC  33C6              xor ax,si
000FC6EE  0BE8              or bp,ax
000FC6F0  57                push di
000FC6F1  58                pop ax
000FC6F2  33C7              xor ax,di
000FC6F4  0BC5              or ax,bp
000FC6F6  E1EA              loope 0xc6e2
000FC6F8  0BC9              or cx,cx
000FC6FA  7586              jnz 0xc682
000FC6FC  8CD0              mov ax,ss
000FC6FE  050008            add ax,0x800
000FC701  FECE              dec dh
000FC703  75D5              jnz 0xc6da
000FC705  87F7              xchg di,si
000FC707  8AF2              mov dh,dl
000FC709  2D0008            sub ax,0x800
000FC70C  BB0400            mov bx,0x4
000FC70F  8ED0              mov ss,ax
000FC711  BC0280            mov sp,0x8002
000FC714  B90020            mov cx,0x2000
000FC717  90                nop
000FC718  2BE3              sub sp,bx
000FC71A  5D                pop bp
000FC71B  33EE              xor bp,si
000FC71D  57                push di
000FC71E  58                pop ax
000FC71F  33C7              xor ax,di
000FC721  0BE8              or bp,ax
000FC723  2BE3              sub sp,bx
000FC725  58                pop ax
000FC726  33C6              xor ax,si
000FC728  0BE8              or bp,ax
000FC72A  57                push di
000FC72B  58                pop ax
000FC72C  33C7              xor ax,di
000FC72E  0BC5              or ax,bp
000FC730  E1E6              loope 0xc718
000FC732  0BC9              or cx,cx
000FC734  75C4              jnz 0xc6fa
000FC736  8CD0              mov ax,ss
000FC738  2D0008            sub ax,0x800
000FC73B  FECE              dec dh
000FC73D  75D0              jnz 0xc70f
000FC73F  0BF6              or si,si
000FC741  750B              jnz 0xc74e
000FC743  B0AC              mov al,0xac
000FC745  BF4B07            mov di,0x74b
000FC748  E913F9            jmp 0xc05e
000FC74B  E94AFF            jmp 0xc698
000FC74E  B83000            mov ax,0x30
000FC751  8ED0              mov ss,ax
000FC753  BC0001            mov sp,0x100
000FC756  33C0              xor ax,ax
000FC758  8EC0              mov es,ax
000FC75A  8ED8              mov ds,ax
000FC75C  33C9              xor cx,cx
000FC75E  E83D00            call 0xc79e
000FC761  E83A00            call 0xc79e
000FC764  80FD01            cmp ch,0x1
000FC767  12ED              adc ch,ch
000FC769  73F3              jnc 0xc75e
000FC76B  FEC5              inc ch
000FC76D  33FF              xor di,di
000FC76F  FC                cld
000FC770  B89207            mov ax,0x792
000FC773  AB                stosw
000FC774  8CC8              mov ax,cs
000FC776  AB                stosw
000FC777  E2F7              loop 0xc770
000FC779  C70620009707      mov word [0x20],0x797
000FC77F  33DB              xor bx,bx
000FC781  B0FE              mov al,0xfe
000FC783  E621              out 0x21,al
000FC785  FB                sti
000FC786  E2FE              loop 0xc786
000FC788  FA                cli
000FC789  B0FF              mov al,0xff
000FC78B  E621              out 0x21,al
000FC78D  80FB3B            cmp bl,0x3b
000FC790  741D              jz 0xc7af
000FC792  B003              mov al,0x3
000FC794  E92A10            jmp 0xd7c1
000FC797  B33B              mov bl,0x3b
000FC799  B060              mov al,0x60
000FC79B  E620              out 0x20,al
000FC79D  CF                iret
000FC79E  8AC5              mov al,ch
000FC7A0  E621              out 0x21,al
000FC7A2  8B1E0004          mov bx,[0x400]
000FC7A6  E421              in al,0x21
000FC7A8  3AC5              cmp al,ch
000FC7AA  75E6              jnz 0xc792
000FC7AC  F6D5              not ch
000FC7AE  C3                ret
000FC7AF  8AC2              mov al,dl
000FC7B1  48                dec ax
000FC7B2  48                dec ax
000FC7B3  E665              out 0x65,al
000FC7B5  B105              mov cl,0x5
000FC7B7  98                cbw
000FC7B8  D3E0              shl ax,cl
000FC7BA  A31504            mov [0x415],ax
000FC7BD  054000            add ax,0x40
000FC7C0  A31304            mov [0x413],ax
000FC7C3  E8FE00            call 0xc8c4
000FC7C6  E81301            call 0xc8dc
000FC7C9  BEF33E            mov si,0x3ef3
000FC7CC  BF0000            mov di,0x0
000FC7CF  1E                push ds
000FC7D0  8CC8              mov ax,cs
000FC7D2  8ED8              mov ds,ax
000FC7D4  B91F00            mov cx,0x1f
000FC7D7  A5                movsw
000FC7D8  AB                stosw
000FC7D9  E2FC              loop 0xc7d7
000FC7DB  33C0              xor ax,ax
000FC7DD  B9C201            mov cx,0x1c2
000FC7E0  F3AB              rep stosw
000FC7E2  1F                pop ds
000FC7E3  32DB              xor bl,bl
000FC7E5  C7066004FFFF      mov word [0x460],0xffff
000FC7EB  9BDBE3            finit
000FC7EE  9BDD3E6004        fstsw [0x460]
000FC7F3  9BFF066004        wait inc word [0x460]
000FC7F8  7402              jz 0xc7fc
000FC7FA  43                inc bx
000FC7FB  43                inc bx
000FC7FC  B023              mov al,0x23
000FC7FE  E87504            call 0xcc76
000FC801  8AF8              mov bh,al
000FC803  2430              and al,0x30
000FC805  740A              jz 0xc811
000FC807  B80300            mov ax,0x3
000FC80A  CD10              int 0x10
000FC80C  B80700            mov ax,0x7
000FC80F  CD10              int 0x10
000FC811  8AC7              mov al,bh
000FC813  2470              and al,0x70
000FC815  0AC3              or al,bl
000FC817  0C0D              or al,0xd
000FC819  E664              out 0x64,al
000FC81B  A21004            mov [0x410],al
000FC81E  2430              and al,0x30
000FC820  740E              jz 0xc830
000FC822  3C20              cmp al,0x20
000FC824  770A              ja 0xc830
000FC826  B003              mov al,0x3
000FC828  7402              jz 0xc82c
000FC82A  48                dec ax
000FC82B  48                dec ax
000FC82C  B400              mov ah,0x0
000FC82E  CD10              int 0x10
000FC830  B0BC              mov al,0xbc
000FC832  E621              out 0x21,al
000FC834  FB                sti
000FC835  B070              mov al,0x70
000FC837  E661              out 0x61,al
000FC839  B040              mov al,0x40
000FC83B  E661              out 0x61,al
000FC83D  B080              mov al,0x80
000FC83F  E6A0              out 0xa0,al
000FC841  B400              mov ah,0x0
000FC843  CD13              int 0x13
000FC845  730D              jnc 0xc854
000FC847  BA7903            mov dx,0x379
000FC84A  EC                in al,dx
000FC84B  2407              and al,0x7
000FC84D  744B              jz 0xc89a
000FC84F  B005              mov al,0x5
000FC851  E96D0F            jmp 0xd7c1
000FC854  32D2              xor dl,dl
000FC856  B50A              mov ch,0xa
000FC858  E84B25            call 0xeda6
000FC85B  72EA              jc 0xc847
000FC85D  B023              mov al,0x23
000FC85F  E81404            call 0xcc76
000FC862  7506              jnz 0xc86a
000FC864  A840              test al,0x40
000FC866  7432              jz 0xc89a
000FC868  32C0              xor al,al
000FC86A  9C                pushf
000FC86B  B201              mov dl,0x1
000FC86D  B50A              mov ch,0xa
000FC86F  E83425            call 0xeda6
000FC872  730A              jnc 0xc87e
000FC874  9D                popf
000FC875  7523              jnz 0xc89a
000FC877  80261004BF        and byte [0x410],0xbf
000FC87C  EB17              jmp short 0xc895
000FC87E  9D                popf
000FC87F  7419              jz 0xc89a
000FC881  B023              mov al,0x23
000FC883  E8F003            call 0xcc76
000FC886  0C40              or al,0x40
000FC888  8AE0              mov ah,al
000FC88A  BA7000            mov dx,0x70
000FC88D  B023              mov al,0x23
000FC88F  EF                out dx,ax
000FC890  800E100440        or byte [0x410],0x40
000FC895  A01004            mov al,[0x410]
000FC898  E664              out 0x64,al
000FC89A  E8AE00            call 0xc94b
000FC89D  E421              in al,0x21
000FC89F  24BC              and al,0xbc
000FC8A1  E621              out 0x21,al
000FC8A3  E8BF1D            call 0xe665
000FC8A6  33C9              xor cx,cx
000FC8A8  8ED9              mov ds,cx
000FC8AA  8EC1              mov es,cx
000FC8AC  B00A              mov al,0xa
000FC8AE  E2FE              loop 0xc8ae
000FC8B0  FEC8              dec al
000FC8B2  75FA              jnz 0xc8ae
000FC8B4  E8F200            call 0xc9a9
000FC8B7  E89901            call 0xca53
000FC8BA  C70672043412      mov word [0x472],0x1234
000FC8C0  CD19              int 0x19
000FC8C2  EBF6              jmp short 0xc8ba
000FC8C4  FC                cld
000FC8C5  B81E00            mov ax,0x1e
000FC8C8  BF1A04            mov di,0x41a
000FC8CB  AB                stosw
000FC8CC  AB                stosw
000FC8CD  BF8004            mov di,0x480
000FC8D0  AB                stosw
000FC8D1  052000            add ax,0x20
000FC8D4  AB                stosw
000FC8D5  C3                ret
000FC8D6  BC0378            mov sp,0x7803
000FC8D9  037802            add di,[bx+si+0x2]
000FC8DC  B142              mov cl,0x42
000FC8DE  C7060004F803      mov word [0x400],0x3f8
000FC8E4  BAFB02            mov dx,0x2fb
000FC8E7  B0AA              mov al,0xaa
000FC8E9  EE                out dx,al
000FC8EA  EB00              jmp short 0xc8ec
000FC8EC  EC                in al,dx
000FC8ED  3CAA              cmp al,0xaa
000FC8EF  7512              jnz 0xc903
000FC8F1  F6D0              not al
000FC8F3  EE                out dx,al
000FC8F4  EB00              jmp short 0xc8f6
000FC8F6  EC                in al,dx
000FC8F7  3C55              cmp al,0x55
000FC8F9  7508              jnz 0xc903
000FC8FB  C7060204F802      mov word [0x402],0x2f8
000FC901  41                inc cx
000FC902  41                inc cx
000FC903  80E1BF            and cl,0xbf
000FC906  BB0804            mov bx,0x408
000FC909  BFD608            mov di,0x8d6
000FC90C  2E8B15            mov dx,[cs:di]
000FC90F  B0AA              mov al,0xaa
000FC911  EE                out dx,al
000FC912  EC                in al,dx
000FC913  3CAA              cmp al,0xaa
000FC915  750F              jnz 0xc926
000FC917  F6D0              not al
000FC919  EE                out dx,al
000FC91A  EC                in al,dx
000FC91B  3C55              cmp al,0x55
000FC91D  7507              jnz 0xc926
000FC91F  8917              mov [bx],dx
000FC921  43                inc bx
000FC922  43                inc bx
000FC923  80C140            add cl,0x40
000FC926  47                inc di
000FC927  47                inc di
000FC928  81FFDC08          cmp di,0x8dc
000FC92C  72DE              jc 0xc90c
000FC92E  BA0102            mov dx,0x201
000FC931  EC                in al,dx
000FC932  240F              and al,0xf
000FC934  7503              jnz 0xc939
000FC936  80C908            or cl,0x8
000FC939  880E1104          mov [0x411],cl
000FC93D  B81414            mov ax,0x1414
000FC940  BF7804            mov di,0x478
000FC943  AB                stosw
000FC944  AB                stosw
000FC945  B80101            mov ax,0x101
000FC948  AB                stosw
000FC949  AB                stosw
000FC94A  C3                ret
000FC94B  B800C0            mov ax,0xc000
000FC94E  8ED8              mov ds,ax
000FC950  058000            add ax,0x80
000FC953  813E000055AA      cmp word [0x0],0xaa55
000FC959  7514              jnz 0xc96f
000FC95B  1E                push ds
000FC95C  0E                push cs
000FC95D  E81500            call 0xc975
000FC960  1F                pop ds
000FC961  8A360200          mov dh,[0x2]
000FC965  32D2              xor dl,dl
000FC967  B103              mov cl,0x3
000FC969  D3EA              shr dx,cl
000FC96B  8CD8              mov ax,ds
000FC96D  03C2              add ax,dx
000FC96F  3D00F0            cmp ax,0xf000
000FC972  72DA              jc 0xc94e
000FC974  C3                ret
000FC975  1E                push ds
000FC976  8A160200          mov dl,[0x2]
000FC97A  32F6              xor dh,dh
000FC97C  B90002            mov cx,0x200
000FC97F  33DB              xor bx,bx
000FC981  0237              add dh,[bx]
000FC983  43                inc bx
000FC984  E2FB              loop 0xc981
000FC986  8CD8              mov ax,ds
000FC988  052000            add ax,0x20
000FC98B  8ED8              mov ds,ax
000FC98D  FECA              dec dl
000FC98F  75EB              jnz 0xc97c
000FC991  1F                pop ds
000FC992  0AF6              or dh,dh
000FC994  7408              jz 0xc99e
000FC996  33DB              xor bx,bx
000FC998  B007              mov al,0x7
000FC99A  E8E30C            call 0xd680
000FC99D  CB                retf
000FC99E  1E                push ds
000FC99F  BB0300            mov bx,0x3
000FC9A2  53                push bx
000FC9A3  B84000            mov ax,0x40
000FC9A6  8EC0              mov es,ax
000FC9A8  CB                retf
000FC9A9  8B161304          mov dx,[0x413]
000FC9AD  B000              mov al,0x0
000FC9AF  E8CE0C            call 0xd680
000FC9B2  B014              mov al,0x14
000FC9B4  E8BF02            call 0xcc76
000FC9B7  7534              jnz 0xc9ed
000FC9B9  A01004            mov al,[0x410]
000FC9BC  2430              and al,0x30
000FC9BE  3C10              cmp al,0x10
000FC9C0  750A              jnz 0xc9cc
000FC9C2  B80D0E            mov ax,0xe0d
000FC9C5  CD10              int 0x10
000FC9C7  B80A0E            mov ax,0xe0a
000FC9CA  CD10              int 0x10
000FC9CC  B402              mov ah,0x2
000FC9CE  CD1A              int 0x1a
000FC9D0  51                push cx
000FC9D1  B404              mov ah,0x4
000FC9D3  CD1A              int 0x1a
000FC9D5  87CA              xchg dx,cx
000FC9D7  86E9              xchg cl,ch
000FC9D9  5B                pop bx
000FC9DA  B001              mov al,0x1
000FC9DC  E85600            call 0xca35
000FC9DF  813E72043412      cmp word [0x472],0x1234
000FC9E5  7521              jnz 0xca08
000FC9E7  B80A0E            mov ax,0xe0a
000FC9EA  CD10              int 0x10
000FC9EC  C3                ret
000FC9ED  B003              mov al,0x3
000FC9EF  E88E0C            call 0xd680
000FC9F2  B00D              mov al,0xd
000FC9F4  E87F02            call 0xcc76
000FC9F7  2480              and al,0x80
000FC9F9  7505              jnz 0xca00
000FC9FB  B004              mov al,0x4
000FC9FD  E8800C            call 0xd680
000FCA00  B300              mov bl,0x0
000FCA02  B81401            mov ax,0x114
000FCA05  CD15              int 0x15
000FCA07  C3                ret
000FCA08  B00E              mov al,0xe
000FCA0A  E86902            call 0xcc76
000FCA0D  8AD8              mov bl,al
000FCA0F  B00F              mov al,0xf
000FCA11  E86202            call 0xcc76
000FCA14  8AF8              mov bh,al
000FCA16  B013              mov al,0x13
000FCA18  E85B02            call 0xcc76
000FCA1B  8AD0              mov dl,al
000FCA1D  B619              mov dh,0x19
000FCA1F  3C80              cmp al,0x80
000FCA21  7302              jnc 0xca25
000FCA23  B620              mov dh,0x20
000FCA25  B011              mov al,0x11
000FCA27  E84C02            call 0xcc76
000FCA2A  8AE8              mov ch,al
000FCA2C  B012              mov al,0x12
000FCA2E  E84502            call 0xcc76
000FCA31  8AC8              mov cl,al
000FCA33  B002              mov al,0x2
000FCA35  50                push ax
000FCA36  8AE1              mov ah,cl
000FCA38  8AC4              mov al,ah
000FCA3A  B104              mov cl,0x4
000FCA3C  D2C4              rol ah,cl
000FCA3E  250F0F            and ax,0xf0f
000FCA41  D50A              aad
000FCA43  48                dec ax
000FCA44  3C0C              cmp al,0xc
000FCA46  7202              jc 0xca4a
000FCA48  B000              mov al,0x0
000FCA4A  8AC8              mov cl,al
000FCA4C  80E77F            and bh,0x7f
000FCA4F  58                pop ax
000FCA50  E92D0C            jmp 0xd680
000FCA53  BA7903            mov dx,0x379
000FCA56  EC                in al,dx
000FCA57  2407              and al,0x7
000FCA59  746E              jz 0xcac9
000FCA5B  B205              mov dl,0x5
000FCA5D  FA                cli
000FCA5E  FF362400          push word [0x24]
000FCA62  FF362600          push word [0x26]
000FCA66  C7062400CA0A      mov word [0x24],0xaca
000FCA6C  8C0E2600          mov [0x26],cs
000FCA70  E461              in al,0x61
000FCA72  50                push ax
000FCA73  24BF              and al,0xbf
000FCA75  0C80              or al,0x80
000FCA77  E661              out 0x61,al
000FCA79  B91027            mov cx,0x2710
000FCA7C  E2FE              loop 0xca7c
000FCA7E  58                pop ax
000FCA7F  E661              out 0x61,al
000FCA81  BB0A00            mov bx,0xa
000FCA84  FB                sti
000FCA85  0AFF              or bh,bh
000FCA87  7506              jnz 0xca8f
000FCA89  E2FA              loop 0xca85
000FCA8B  FECB              dec bl
000FCA8D  75F6              jnz 0xca85
000FCA8F  FA                cli
000FCA90  8F062600          pop word [0x26]
000FCA94  8F062400          pop word [0x24]
000FCA98  E829FE            call 0xc8c4
000FCA9B  C70617040000      mov word [0x417],0x0
000FCAA1  FB                sti
000FCAA2  80FFAA            cmp bh,0xaa
000FCAA5  7412              jz 0xcab9
000FCAA7  8AC2              mov al,dl
000FCAA9  0AC0              or al,al
000FCAAB  7405              jz 0xcab2
000FCAAD  E8D00B            call 0xd680
000FCAB0  32D2              xor dl,dl
000FCAB2  B8070E            mov ax,0xe07
000FCAB5  CD10              int 0x10
000FCAB7  EBA4              jmp short 0xca5d
000FCAB9  B80D0E            mov ax,0xe0d
000FCABC  CD10              int 0x10
000FCABE  B95000            mov cx,0x50
000FCAC1  BB0100            mov bx,0x1
000FCAC4  B8200A            mov ax,0xa20
000FCAC7  CD10              int 0x10
000FCAC9  C3                ret
000FCACA  50                push ax
000FCACB  E460              in al,0x60
000FCACD  0AFF              or bh,bh
000FCACF  B7FF              mov bh,0xff
000FCAD1  7502              jnz 0xcad5
000FCAD3  8AF8              mov bh,al
000FCAD5  E461              in al,0x61
000FCAD7  0C80              or al,0x80
000FCAD9  E661              out 0x61,al
000FCADB  247F              and al,0x7f
000FCADD  E661              out 0x61,al
000FCADF  B061              mov al,0x61
000FCAE1  E620              out 0x20,al
000FCAE3  58                pop ax
000FCAE4  CF                iret
000FCAE5  33C0              xor ax,ax
000FCAE7  8ED8              mov ds,ax
000FCAE9  8C0E7A00          mov [0x7a],cs
000FCAED  C7067800C72F      mov word [0x78],0x2fc7
000FCAF3  B90A00            mov cx,0xa
000FCAF6  B400              mov ah,0x0
000FCAF8  CD13              int 0x13
000FCAFA  51                push cx
000FCAFB  33D2              xor dx,dx
000FCAFD  BB007C            mov bx,0x7c00
000FCB00  8EC2              mov es,dx
000FCB02  B90100            mov cx,0x1
000FCB05  B80102            mov ax,0x201
000FCB08  CD13              int 0x13
000FCB0A  59                pop cx
000FCB0B  7319              jnc 0xcb26
000FCB0D  D0C4              rol ah,1
000FCB0F  721C              jc 0xcb2d
000FCB11  F6C101            test cl,0x1
000FCB14  740C              jz 0xcb22
000FCB16  51                push cx
000FCB17  33D2              xor dx,dx
000FCB19  B90127            mov cx,0x2701
000FCB1C  B80104            mov ax,0x401
000FCB1F  CD13              int 0x13
000FCB21  59                pop cx
000FCB22  E2D2              loop 0xcaf6
000FCB24  EB07              jmp short 0xcb2d
000FCB26  33C0              xor ax,ax
000FCB28  8ED8              mov ds,ax
000FCB2A  06                push es
000FCB2B  53                push bx
000FCB2C  CB                retf
000FCB2D  B006              mov al,0x6
000FCB2F  E84E0B            call 0xd680
000FCB32  33C0              xor ax,ax
000FCB34  8EC0              mov es,ax
000FCB36  E88BFD            call 0xc8c4
000FCB39  B400              mov ah,0x0
000FCB3B  CD16              int 0x16
000FCB3D  B80A0E            mov ax,0xe0a
000FCB40  CD10              int 0x10
000FCB42  B80D0E            mov ax,0xe0d
000FCB45  CD10              int 0x10
000FCB47  CD19              int 0x19
000FCB49  016100            add [bx+di+0x0],sp
000FCB4C  800343            add byte [bp+di],0x43
000FCB4F  0034              add [si],dh
000FCB51  74B0              jz 0xcb03
000FCB53  024000            add al,[bx+si+0x0]
000FCB56  0000              add [bx+si],al
000FCB58  024100            add al,[bx+di+0x0]
000FCB5B  1200              adc al,[bx+si]
000FCB5D  024200            add al,[bp+si+0x0]
000FCB60  0100              add [bx+si],ax
000FCB62  010F              add [bx],cx
000FCB64  000F              add [bx],cl
000FCB66  0108              add [bx+si],cx
000FCB68  0000              add [bx+si],al
000FCB6A  010B              add [bp+di],cx
000FCB6C  005801            add [bx+si+0x1],bl
000FCB6F  0C00              or al,0x0
000FCB71  0002              add [bp+si],al
000FCB73  0100              add [bx+si],ax
000FCB75  FF                db 0xff
000FCB76  FF01              inc word [bx+di]
000FCB78  0A00              or al,[bx+si]
000FCB7A  0001              add [bx+di],al
000FCB7C  2000              and [bx+si],al
000FCB7E  1303              adc ax,[bp+di]
000FCB80  2100              and [bx+si],ax
000FCB82  0809              or [bx+di],cl
000FCB84  FF01              inc word [bx+di]
000FCB86  F20300            repne add ax,[bx+si]
000FCB89  01FC              add sp,di
000FCB8B  0300              add ax,[bx+si]
000FCB8D  0000              add [bx+si],al
000FCB8F  0000              add [bx+si],al
000FCB91  0000              add [bx+si],al
000FCB93  0000              add [bx+si],al
000FCB95  0000              add [bx+si],al
000FCB97  0000              add [bx+si],al
000FCB99  0000              add [bx+si],al
000FCB9B  0000              add [bx+si],al
000FCB9D  0000              add [bx+si],al
000FCB9F  008BE558          add [bp+di+0x58e5],cl
000FCBA3  5B                pop bx
000FCBA4  59                pop cx
000FCBA5  5A                pop dx
000FCBA6  1F                pop ds
000FCBA7  07                pop es
000FCBA8  5D                pop bp
000FCBA9  5F                pop di
000FCBAA  5E                pop si
000FCBAB  CA0200            retf 0x2
000FCBAE  FB                sti
000FCBAF  57                push di
000FCBB0  55                push bp
000FCBB1  06                push es
000FCBB2  1E                push ds
000FCBB3  52                push dx
000FCBB4  51                push cx
000FCBB5  53                push bx
000FCBB6  50                push ax
000FCBB7  33DB              xor bx,bx
000FCBB9  8EDB              mov ds,bx
000FCBBB  8BEC              mov bp,sp
000FCBBD  877610            xchg [bp+0x10],si
000FCBC0  FFD6              call si
000FCBC2  8BE5              mov sp,bp
000FCBC4  58                pop ax
000FCBC5  5B                pop bx
000FCBC6  59                pop cx
000FCBC7  5A                pop dx
000FCBC8  1F                pop ds
000FCBC9  07                pop es
000FCBCA  5D                pop bp
000FCBCB  5F                pop di
000FCBCC  5E                pop si
000FCBCD  CF                iret
000FCBCE  1E                push ds
000FCBCF  33C0              xor ax,ax
000FCBD1  8ED8              mov ds,ax
000FCBD3  A11304            mov ax,[0x413]
000FCBD6  1F                pop ds
000FCBD7  CF                iret
000FCBD8  1E                push ds
000FCBD9  33C0              xor ax,ax
000FCBDB  8ED8              mov ds,ax
000FCBDD  A11004            mov ax,[0x410]
000FCBE0  1F                pop ds
000FCBE1  CF                iret
000FCBE2  E8C9FF            call 0xcbae
000FCBE5  80FC07            cmp ah,0x7
000FCBE8  F5                cmc
000FCBE9  720C              jc 0xcbf7
000FCBEB  02E4              add ah,ah
000FCBED  86DC              xchg ah,bl
000FCBEF  32FF              xor bh,bh
000FCBF1  2EFF97FC0B        call [cs:bx+0xbfc]
000FCBF6  F8                clc
000FCBF7  9F                lahf
000FCBF8  886616            mov [bp+0x16],ah
000FCBFB  C3                ret
000FCBFC  0A0C              or cl,[si]
000FCBFE  2D0C61            sub ax,0x610c
000FCC01  0CC7              or al,0xc7
000FCC03  0CCC              or al,0xcc
000FCC05  0CD1              or al,0xd1
000FCC07  0C64              or al,0x64
000FCC09  18FA              sbb dl,bh
000FCC0B  BA7800            mov dx,0x78
000FCC0E  E80D00            call 0xcc1e
000FCC11  894604            mov [bp+0x4],ax
000FCC14  42                inc dx
000FCC15  42                inc dx
000FCC16  E80500            call 0xcc1e
000FCC19  894606            mov [bp+0x6],ax
000FCC1C  FB                sti
000FCC1D  C3                ret
000FCC1E  EC                in al,dx
000FCC1F  8AE0              mov ah,al
000FCC21  EC                in al,dx
000FCC22  3AC4              cmp al,ah
000FCC24  75F8              jnz 0xcc1e
000FCC26  98                cbw
000FCC27  50                push ax
000FCC28  32C0              xor al,al
000FCC2A  EE                out dx,al
000FCC2B  58                pop ax
000FCC2C  C3                ret
000FCC2D  3C40              cmp al,0x40
000FCC2F  7205              jc 0xcc36
000FCC31  C6460101          mov byte [bp+0x1],0x1
000FCC35  C3                ret
000FCC36  8A6602            mov ah,[bp+0x2]
000FCC39  BA7000            mov dx,0x70
000FCC3C  EF                out dx,ax
000FCC3D  3C14              cmp al,0x14
000FCC3F  720C              jc 0xcc4d
000FCC41  50                push ax
000FCC42  BB470C            mov bx,0xc47
000FCC45  EB42              jmp short 0xcc89
000FCC47  8AE1              mov ah,cl
000FCC49  B014              mov al,0x14
000FCC4B  EF                out dx,ax
000FCC4C  58                pop ax
000FCC4D  3C0E              cmp al,0xe
000FCC4F  7209              jc 0xcc5a
000FCC51  E86D00            call 0xccc1
000FCC54  2AE0              sub ah,al
000FCC56  B402              mov ah,0x2
000FCC58  7502              jnz 0xcc5c
000FCC5A  32E4              xor ah,ah
000FCC5C  886601            mov [bp+0x1],ah
000FCC5F  FB                sti
000FCC60  C3                ret
000FCC61  3C40              cmp al,0x40
000FCC63  7205              jc 0xcc6a
000FCC65  C6460101          mov byte [bp+0x1],0x1
000FCC69  C3                ret
000FCC6A  E80900            call 0xcc76
000FCC6D  7402              jz 0xcc71
000FCC6F  B402              mov ah,0x2
000FCC71  894600            mov [bp+0x0],ax
000FCC74  FB                sti
000FCC75  C3                ret
000FCC76  52                push dx
000FCC77  51                push cx
000FCC78  53                push bx
000FCC79  E80400            call 0xcc80
000FCC7C  5B                pop bx
000FCC7D  59                pop cx
000FCC7E  5A                pop dx
000FCC7F  C3                ret
000FCC80  5B                pop bx
000FCC81  FA                cli
000FCC82  BA7000            mov dx,0x70
000FCC85  EE                out dx,al
000FCC86  42                inc dx
000FCC87  EC                in al,dx
000FCC88  4A                dec dx
000FCC89  8AC8              mov cl,al
000FCC8B  32E4              xor ah,ah
000FCC8D  B53F              mov ch,0x3f
000FCC8F  8AC5              mov al,ch
000FCC91  EE                out dx,al
000FCC92  42                inc dx
000FCC93  EC                in al,dx
000FCC94  4A                dec dx
000FCC95  02E0              add ah,al
000FCC97  FECD              dec ch
000FCC99  80FD14            cmp ch,0x14
000FCC9C  73F1              jnc 0xcc8f
000FCC9E  8AEC              mov ch,ah
000FCCA0  2AE8              sub ch,al
000FCCA2  B0AA              mov al,0xaa
000FCCA4  2AC5              sub al,ch
000FCCA6  86C1              xchg cl,al
000FCCA8  80ECAA            sub ah,0xaa
000FCCAB  FFE3              jmp bx
000FCCAD  52                push dx
000FCCAE  8AE0              mov ah,al
000FCCB0  E80B00            call 0xccbe
000FCCB3  86E0              xchg al,ah
000FCCB5  FEC0              inc al
000FCCB7  E80700            call 0xccc1
000FCCBA  86E0              xchg al,ah
000FCCBC  5A                pop dx
000FCCBD  C3                ret
000FCCBE  BA7000            mov dx,0x70
000FCCC1  FA                cli
000FCCC2  EE                out dx,al
000FCCC3  42                inc dx
000FCCC4  EC                in al,dx
000FCCC5  4A                dec dx
000FCCC6  C3                ret
000FCCC7  BADD03            mov dx,0x3dd
000FCCCA  EE                out dx,al
000FCCCB  C3                ret
000FCCCC  BADE03            mov dx,0x3de
000FCCCF  EE                out dx,al
000FCCD0  C3                ret
000FCCD1  BADF03            mov dx,0x3df
000FCCD4  EE                out dx,al
000FCCD5  C3                ret
000FCCD6  E8D5FE            call 0xcbae
000FCCD9  80FC08            cmp ah,0x8
000FCCDC  730B              jnc 0xcce9
000FCCDE  02E4              add ah,ah
000FCCE0  8ADC              mov bl,ah
000FCCE2  32FF              xor bh,bh
000FCCE4  2EFFA7EA0C        jmp [cs:bx+0xcea]
000FCCE9  C3                ret
000FCCEA  FA                cli
000FCCEB  0C14              or al,0x14
000FCCED  0DDF0D            or ax,0xddf
000FCCF0  B20D              mov dl,0xd
000FCCF2  390EFE0D          cmp [0xdfe],cx
000FCCF6  60                pusha
000FCCF7  0E                push cs
000FCCF8  860EFAA1          xchg [0xa1fa],cl
000FCCFC  6E                outsb
000FCCFD  0489              add al,0x89
000FCCFF  46                inc si
000FCD00  04A1              add al,0xa1
000FCD02  6C                insb
000FCD03  0489              add al,0x89
000FCD05  46                inc si
000FCD06  06                push es
000FCD07  32C0              xor al,al
000FCD09  86067004          xchg [0x470],al
000FCD0D  2401              and al,0x1
000FCD0F  884600            mov [bp+0x0],al
000FCD12  FB                sti
000FCD13  C3                ret
000FCD14  FA                cli
000FCD15  890E6E04          mov [0x46e],cx
000FCD19  89166C04          mov [0x46c],dx
000FCD1D  C606700400        mov byte [0x470],0x0
000FCD22  FB                sti
000FCD23  C3                ret
000FCD24  1E                push ds
000FCD25  52                push dx
000FCD26  50                push ax
000FCD27  33C0              xor ax,ax
000FCD29  8ED8              mov ds,ax
000FCD2B  FB                sti
000FCD2C  FE0E4004          dec byte [0x440]
000FCD30  750B              jnz 0xcd3d
000FCD32  C6063F0400        mov byte [0x43f],0x0
000FCD37  BAF203            mov dx,0x3f2
000FCD3A  B00C              mov al,0xc
000FCD3C  EE                out dx,al
000FCD3D  FF066C04          inc word [0x46c]
000FCD41  7504              jnz 0xcd47
000FCD43  FF066E04          inc word [0x46e]
000FCD47  813E6C04B000      cmp word [0x46c],0xb0
000FCD4D  7514              jnz 0xcd63
000FCD4F  833E6E0418        cmp word [0x46e],byte +0x18
000FCD54  750D              jnz 0xcd63
000FCD56  C6067004FF        mov byte [0x470],0xff
000FCD5B  33C0              xor ax,ax
000FCD5D  A36C04            mov [0x46c],ax
000FCD60  A36E04            mov [0x46e],ax
000FCD63  F6066C04FF        test byte [0x46c],0xff
000FCD68  7503              jnz 0xcd6d
000FCD6A  E80F00            call 0xcd7c
000FCD6D  B84000            mov ax,0x40
000FCD70  8ED8              mov ds,ax
000FCD72  CD1C              int 0x1c
000FCD74  B060              mov al,0x60
000FCD76  E620              out 0x20,al
000FCD78  58                pop ax
000FCD79  5A                pop dx
000FCD7A  1F                pop ds
000FCD7B  CF                iret
000FCD7C  53                push bx
000FCD7D  BA7000            mov dx,0x70
000FCD80  E81901            call 0xce9c
000FCD83  B402              mov ah,0x2
000FCD85  B30E              mov bl,0xe
000FCD87  E81500            call 0xcd9f
000FCD8A  80C402            add ah,0x2
000FCD8D  E80F00            call 0xcd9f
000FCD90  80C402            add ah,0x2
000FCD93  E80900            call 0xcd9f
000FCD96  FEC4              inc ah
000FCD98  80FC0A            cmp ah,0xa
000FCD9B  72F6              jc 0xcd93
000FCD9D  5B                pop bx
000FCD9E  C3                ret
000FCD9F  8AC4              mov al,ah
000FCDA1  EE                out dx,al
000FCDA2  42                inc dx
000FCDA3  EC                in al,dx
000FCDA4  8AF8              mov bh,al
000FCDA6  4A                dec dx
000FCDA7  8AC3              mov al,bl
000FCDA9  EE                out dx,al
000FCDAA  42                inc dx
000FCDAB  8AC7              mov al,bh
000FCDAD  EE                out dx,al
000FCDAE  4A                dec dx
000FCDAF  FEC3              inc bl
000FCDB1  C3                ret
000FCDB2  E86E00            call 0xce23
000FCDB5  8A6606            mov ah,[bp+0x6]
000FCDB8  80E401            and ah,0x1
000FCDBB  80CC02            or ah,0x2
000FCDBE  8ADC              mov bl,ah
000FCDC0  B00B              mov al,0xb
000FCDC2  EF                out dx,ax
000FCDC3  B004              mov al,0x4
000FCDC5  8AE5              mov ah,ch
000FCDC7  EF                out dx,ax
000FCDC8  B002              mov al,0x2
000FCDCA  8AE1              mov ah,cl
000FCDCC  EF                out dx,ax
000FCDCD  B000              mov al,0x0
000FCDCF  8A6607            mov ah,[bp+0x7]
000FCDD2  EF                out dx,ax
000FCDD3  B80A20            mov ax,0x200a
000FCDD6  EF                out dx,ax
000FCDD7  B80B7F            mov ax,0x7f0b
000FCDDA  22E3              and ah,bl
000FCDDC  EF                out dx,ax
000FCDDD  EB3A              jmp short 0xce19
000FCDDF  E8BA00            call 0xce9c
000FCDE2  7239              jc 0xce1d
000FCDE4  B004              mov al,0x4
000FCDE6  E8D8FE            call 0xccc1
000FCDE9  884605            mov [bp+0x5],al
000FCDEC  B002              mov al,0x2
000FCDEE  E8D0FE            call 0xccc1
000FCDF1  884604            mov [bp+0x4],al
000FCDF4  B000              mov al,0x0
000FCDF6  E8C8FE            call 0xccc1
000FCDF9  884607            mov [bp+0x7],al
000FCDFC  EB1E              jmp short 0xce1c
000FCDFE  E89B00            call 0xce9c
000FCE01  721A              jc 0xce1d
000FCE03  B009              mov al,0x9
000FCE05  8AE1              mov ah,cl
000FCE07  EF                out dx,ax
000FCE08  B008              mov al,0x8
000FCE0A  8A6607            mov ah,[bp+0x7]
000FCE0D  EF                out dx,ax
000FCE0E  B007              mov al,0x7
000FCE10  8A6606            mov ah,[bp+0x6]
000FCE13  EF                out dx,ax
000FCE14  B006              mov al,0x6
000FCE16  32E4              xor ah,ah
000FCE18  EF                out dx,ax
000FCE19  E860FF            call 0xcd7c
000FCE1C  F8                clc
000FCE1D  9F                lahf
000FCE1E  886616            mov [bp+0x16],ah
000FCE21  FB                sti
000FCE22  C3                ret
000FCE23  BA7000            mov dx,0x70
000FCE26  B00B              mov al,0xb
000FCE28  E896FE            call 0xccc1
000FCE2B  0C80              or al,0x80
000FCE2D  8AD8              mov bl,al
000FCE2F  8AE0              mov ah,al
000FCE31  B00B              mov al,0xb
000FCE33  EF                out dx,ax
000FCE34  B80A70            mov ax,0x700a
000FCE37  EF                out dx,ax
000FCE38  C3                ret
000FCE39  E86000            call 0xce9c
000FCE3C  72DF              jc 0xce1d
000FCE3E  B009              mov al,0x9
000FCE40  E87EFE            call 0xccc1
000FCE43  B419              mov ah,0x19
000FCE45  3C80              cmp al,0x80
000FCE47  7302              jnc 0xce4b
000FCE49  B420              mov ah,0x20
000FCE4B  894604            mov [bp+0x4],ax
000FCE4E  B008              mov al,0x8
000FCE50  E86EFE            call 0xccc1
000FCE53  884607            mov [bp+0x7],al
000FCE56  B007              mov al,0x7
000FCE58  E866FE            call 0xccc1
000FCE5B  884606            mov [bp+0x6],al
000FCE5E  EBBC              jmp short 0xce1c
000FCE60  E83900            call 0xce9c
000FCE63  72B8              jc 0xce1d
000FCE65  B00B              mov al,0xb
000FCE67  E857FE            call 0xccc1
000FCE6A  2420              and al,0x20
000FCE6C  7403              jz 0xce71
000FCE6E  F9                stc
000FCE6F  EBAC              jmp short 0xce1d
000FCE71  B005              mov al,0x5
000FCE73  8AE5              mov ah,ch
000FCE75  EF                out dx,ax
000FCE76  B003              mov al,0x3
000FCE78  8AE1              mov ah,cl
000FCE7A  EF                out dx,ax
000FCE7B  B001              mov al,0x1
000FCE7D  8A6607            mov ah,[bp+0x7]
000FCE80  EF                out dx,ax
000FCE81  BB2000            mov bx,0x20
000FCE84  EB03              jmp short 0xce89
000FCE86  BB00DF            mov bx,0xdf00
000FCE89  BA7000            mov dx,0x70
000FCE8C  B00B              mov al,0xb
000FCE8E  E830FE            call 0xccc1
000FCE91  22C7              and al,bh
000FCE93  0AC3              or al,bl
000FCE95  8AE0              mov ah,al
000FCE97  B00B              mov al,0xb
000FCE99  EF                out dx,ax
000FCE9A  EB80              jmp short 0xce1c
000FCE9C  51                push cx
000FCE9D  B90000            mov cx,0x0
000FCEA0  BA7000            mov dx,0x70
000FCEA3  FA                cli
000FCEA4  B00A              mov al,0xa
000FCEA6  EE                out dx,al
000FCEA7  42                inc dx
000FCEA8  EC                in al,dx
000FCEA9  4A                dec dx
000FCEAA  D0D0              rcl al,1
000FCEAC  7303              jnc 0xceb1
000FCEAE  E2F4              loop 0xcea4
000FCEB0  F9                stc
000FCEB1  59                pop cx
000FCEB2  C3                ret
000FCEB3  E8F8FC            call 0xcbae
000FCEB6  8BDA              mov bx,dx
000FCEB8  03DB              add bx,bx
000FCEBA  8B970804          mov dx,[bx+0x408]
000FCEBE  0BD2              or dx,dx
000FCEC0  7416              jz 0xced8
000FCEC2  80FC03            cmp ah,0x3
000FCEC5  730B              jnc 0xced2
000FCEC7  02E4              add ah,ah
000FCEC9  8ADC              mov bl,ah
000FCECB  32FF              xor bh,bh
000FCECD  2EFFA7D90E        jmp [cs:bx+0xed9]
000FCED2  80EC02            sub ah,0x2
000FCED5  886601            mov [bp+0x1],ah
000FCED8  C3                ret
000FCED9  DF0E140F          fisttp word [0xf14]
000FCEDD  2A0F              sub cl,[bx]
000FCEDF  8B5E06            mov bx,[bp+0x6]
000FCEE2  8A9F7804          mov bl,[bx+0x478]
000FCEE6  03DB              add bx,bx
000FCEE8  03DB              add bx,bx
000FCEEA  42                inc dx
000FCEEB  B9BEEC            mov cx,0xecbe
000FCEEE  EC                in al,dx
000FCEEF  2480              and al,0x80
000FCEF1  750D              jnz 0xcf00
000FCEF3  E2F9              loop 0xceee
000FCEF5  4B                dec bx
000FCEF6  75F3              jnz 0xceeb
000FCEF8  E83000            call 0xcf2b
000FCEFB  804E0101          or byte [bp+0x1],0x1
000FCEFF  C3                ret
000FCF00  8A4600            mov al,[bp+0x0]
000FCF03  4A                dec dx
000FCF04  EE                out dx,al
000FCF05  42                inc dx
000FCF06  42                inc dx
000FCF07  B00D              mov al,0xd
000FCF09  EE                out dx,al
000FCF0A  50                push ax
000FCF0B  50                push ax
000FCF0C  58                pop ax
000FCF0D  58                pop ax
000FCF0E  B00C              mov al,0xc
000FCF10  EE                out dx,al
000FCF11  4A                dec dx
000FCF12  EB17              jmp short 0xcf2b
000FCF14  42                inc dx
000FCF15  42                inc dx
000FCF16  B008              mov al,0x8
000FCF18  EE                out dx,al
000FCF19  B004              mov al,0x4
000FCF1B  B93FF7            mov cx,0xf73f
000FCF1E  E2FE              loop 0xcf1e
000FCF20  FEC8              dec al
000FCF22  75F7              jnz 0xcf1b
000FCF24  B00C              mov al,0xc
000FCF26  EE                out dx,al
000FCF27  4A                dec dx
000FCF28  EB01              jmp short 0xcf2b
000FCF2A  42                inc dx
000FCF2B  EC                in al,dx
000FCF2C  24F8              and al,0xf8
000FCF2E  3448              xor al,0x48
000FCF30  884601            mov [bp+0x1],al
000FCF33  C3                ret
000FCF34  FB                sti
000FCF35  1E                push ds
000FCF36  52                push dx
000FCF37  51                push cx
000FCF38  53                push bx
000FCF39  50                push ax
000FCF3A  33C0              xor ax,ax
000FCF3C  8ED8              mov ds,ax
000FCF3E  803E000501        cmp byte [0x500],0x1
000FCF43  7453              jz 0xcf98
000FCF45  C606000501        mov byte [0x500],0x1
000FCF4A  B40F              mov ah,0xf
000FCF4C  CD10              int 0x10
000FCF4E  8ADC              mov bl,ah
000FCF50  B403              mov ah,0x3
000FCF52  CD10              int 0x10
000FCF54  52                push dx
000FCF55  32F6              xor dh,dh
000FCF57  B00D              mov al,0xd
000FCF59  E84200            call 0xcf9e
000FCF5C  7530              jnz 0xcf8e
000FCF5E  B00A              mov al,0xa
000FCF60  E83B00            call 0xcf9e
000FCF63  7529              jnz 0xcf8e
000FCF65  32D2              xor dl,dl
000FCF67  B402              mov ah,0x2
000FCF69  CD10              int 0x10
000FCF6B  B408              mov ah,0x8
000FCF6D  CD10              int 0x10
000FCF6F  0AC0              or al,al
000FCF71  7502              jnz 0xcf75
000FCF73  B020              mov al,0x20
000FCF75  E82600            call 0xcf9e
000FCF78  7514              jnz 0xcf8e
000FCF7A  FEC2              inc dl
000FCF7C  3AD3              cmp dl,bl
000FCF7E  72E7              jc 0xcf67
000FCF80  FEC6              inc dh
000FCF82  80FE19            cmp dh,0x19
000FCF85  72D0              jc 0xcf57
000FCF87  C606000500        mov byte [0x500],0x0
000FCF8C  EB05              jmp short 0xcf93
000FCF8E  C6060005FF        mov byte [0x500],0xff
000FCF93  5A                pop dx
000FCF94  B402              mov ah,0x2
000FCF96  CD10              int 0x10
000FCF98  58                pop ax
000FCF99  5B                pop bx
000FCF9A  59                pop cx
000FCF9B  5A                pop dx
000FCF9C  1F                pop ds
000FCF9D  CF                iret
000FCF9E  8BCA              mov cx,dx
000FCFA0  33D2              xor dx,dx
000FCFA2  B400              mov ah,0x0
000FCFA4  CD17              int 0x17
000FCFA6  F6C401            test ah,0x1
000FCFA9  8BD1              mov dx,cx
000FCFAB  C3                ret
000FCFAC  E8FFFB            call 0xcbae
000FCFAF  8BDA              mov bx,dx
000FCFB1  03DB              add bx,bx
000FCFB3  8B970004          mov dx,[bx+0x400]
000FCFB7  0BD2              or dx,dx
000FCFB9  7416              jz 0xcfd1
000FCFBB  80FC04            cmp ah,0x4
000FCFBE  730B              jnc 0xcfcb
000FCFC0  02E4              add ah,ah
000FCFC2  8ADC              mov bl,ah
000FCFC4  32FF              xor bh,bh
000FCFC6  2EFFA7D20F        jmp [cs:bx+0xfd2]
000FCFCB  80EC03            sub ah,0x3
000FCFCE  886601            mov [bp+0x1],ah
000FCFD1  C3                ret
000FCFD2  DA0F              fimul dword [bx]
000FCFD4  47                inc di
000FCFD5  1089102A          adc [bx+di+0x2a10],cl
000FCFD9  1024              adc [si],ah
000FCFDB  1F                pop ds
000FCFDC  8AC8              mov cl,al
000FCFDE  0C80              or al,0x80
000FCFE0  83C203            add dx,byte +0x3
000FCFE3  EE                out dx,al
000FCFE4  8A4600            mov al,[bp+0x0]
000FCFE7  24E0              and al,0xe0
000FCFE9  D0C0              rol al,1
000FCFEB  D0C0              rol al,1
000FCFED  D0C0              rol al,1
000FCFEF  32E4              xor ah,ah
000FCFF1  03C0              add ax,ax
000FCFF3  8BD8              mov bx,ax
000FCFF5  2E8A873710        mov al,[cs:bx+0x1037]
000FCFFA  83EA03            sub dx,byte +0x3
000FCFFD  EE                out dx,al
000FCFFE  42                inc dx
000FCFFF  2E8A873810        mov al,[cs:bx+0x1038]
000FD004  EE                out dx,al
000FD005  EB00              jmp short 0xd007
000FD007  42                inc dx
000FD008  42                inc dx
000FD009  8AC1              mov al,cl
000FD00B  EE                out dx,al
000FD00C  42                inc dx
000FD00D  E8C600            call 0xd0d6
000FD010  7305              jnc 0xd017
000FD012  B002              mov al,0x2
000FD014  EE                out dx,al
000FD015  EB00              jmp short 0xd017
000FD017  42                inc dx
000FD018  EC                in al,dx
000FD019  EB00              jmp short 0xd01b
000FD01B  42                inc dx
000FD01C  EC                in al,dx
000FD01D  EB00              jmp short 0xd01f
000FD01F  83EA06            sub dx,byte +0x6
000FD022  EC                in al,dx
000FD023  EB00              jmp short 0xd025
000FD025  42                inc dx
000FD026  32C0              xor al,al
000FD028  EE                out dx,al
000FD029  4A                dec dx
000FD02A  83C206            add dx,byte +0x6
000FD02D  EC                in al,dx
000FD02E  884600            mov [bp+0x0],al
000FD031  4A                dec dx
000FD032  EC                in al,dx
000FD033  884601            mov [bp+0x1],al
000FD036  C3                ret
000FD037  17                pop ss
000FD038  0400              add al,0x0
000FD03A  038001C0          add ax,[bx+si-0x3fff]
000FD03E  006000            add [bx+si+0x0],ah
000FD041  3000              xor [bx+si],al
000FD043  1800              sbb [bx+si],al
000FD045  0C00              or al,0x0
000FD047  83C204            add dx,byte +0x4
000FD04A  E88900            call 0xd0d6
000FD04D  B80210            mov ax,0x1002
000FD050  7203              jc 0xd055
000FD052  0D0120            or ax,0x2001
000FD055  EE                out dx,al
000FD056  42                inc dx
000FD057  42                inc dx
000FD058  E88600            call 0xd0e1
000FD05B  EC                in al,dx
000FD05C  22C4              and al,ah
000FD05E  3AC4              cmp al,ah
000FD060  7407              jz 0xd069
000FD062  E2F7              loop 0xd05b
000FD064  4B                dec bx
000FD065  75F4              jnz 0xd05b
000FD067  EB0D              jmp short 0xd076
000FD069  4A                dec dx
000FD06A  EC                in al,dx
000FD06B  2420              and al,0x20
000FD06D  90                nop
000FD06E  750E              jnz 0xd07e
000FD070  E2F8              loop 0xd06a
000FD072  4B                dec bx
000FD073  75F5              jnz 0xd06a
000FD075  42                inc dx
000FD076  E8B9FF            call 0xd032
000FD079  804E0180          or byte [bp+0x1],0x80
000FD07D  C3                ret
000FD07E  8A4600            mov al,[bp+0x0]
000FD081  52                push dx
000FD082  83EA05            sub dx,byte +0x5
000FD085  EE                out dx,al
000FD086  5A                pop dx
000FD087  EBA9              jmp short 0xd032
000FD089  83C204            add dx,byte +0x4
000FD08C  EC                in al,dx
000FD08D  EB00              jmp short 0xd08f
000FD08F  0C01              or al,0x1
000FD091  EE                out dx,al
000FD092  42                inc dx
000FD093  42                inc dx
000FD094  E84A00            call 0xd0e1
000FD097  EC                in al,dx
000FD098  2420              and al,0x20
000FD09A  90                nop
000FD09B  7507              jnz 0xd0a4
000FD09D  E2F8              loop 0xd097
000FD09F  4B                dec bx
000FD0A0  75F5              jnz 0xd097
000FD0A2  EB0D              jmp short 0xd0b1
000FD0A4  4A                dec dx
000FD0A5  EC                in al,dx
000FD0A6  2401              and al,0x1
000FD0A8  90                nop
000FD0A9  750E              jnz 0xd0b9
000FD0AB  E2F8              loop 0xd0a5
000FD0AD  4B                dec bx
000FD0AE  75F5              jnz 0xd0a5
000FD0B0  42                inc dx
000FD0B1  E87EFF            call 0xd032
000FD0B4  804E0180          or byte [bp+0x1],0x80
000FD0B8  C3                ret
000FD0B9  4A                dec dx
000FD0BA  E81900            call 0xd0d6
000FD0BD  7305              jnc 0xd0c4
000FD0BF  B002              mov al,0x2
000FD0C1  EE                out dx,al
000FD0C2  EB00              jmp short 0xd0c4
000FD0C4  83EA04            sub dx,byte +0x4
000FD0C7  EC                in al,dx
000FD0C8  884600            mov [bp+0x0],al
000FD0CB  83C205            add dx,byte +0x5
000FD0CE  E861FF            call 0xd032
000FD0D1  8066011E          and byte [bp+0x1],0x1e
000FD0D5  C3                ret
000FD0D6  52                push dx
000FD0D7  B023              mov al,0x23
000FD0D9  E8E2FB            call 0xccbe
000FD0DC  FB                sti
000FD0DD  5A                pop dx
000FD0DE  D0D0              rcl al,1
000FD0E0  C3                ret
000FD0E1  8B5E06            mov bx,[bp+0x6]
000FD0E4  8A9F7C04          mov bl,[bx+0x47c]
000FD0E8  32FF              xor bh,bh
000FD0EA  8BCB              mov cx,bx
000FD0EC  D1E3              shl bx,1
000FD0EE  03D9              add bx,cx
000FD0F0  33C9              xor cx,cx
000FD0F2  C3                ret
000FD0F3  0000              add [bx+si],al
000FD0F5  0000              add [bx+si],al
000FD0F7  0000              add [bx+si],al
000FD0F9  0000              add [bx+si],al
000FD0FB  0000              add [bx+si],al
000FD0FD  0000              add [bx+si],al
000FD0FF  00E8              add al,ch
000FD101  AB                stosw
000FD102  FA                cli
000FD103  80FC03            cmp ah,0x3
000FD106  7207              jc 0xd10f
000FD108  80EC02            sub ah,0x2
000FD10B  886601            mov [bp+0x1],ah
000FD10E  C3                ret
000FD10F  8ADC              mov bl,ah
000FD111  32FF              xor bh,bh
000FD113  03DB              add bx,bx
000FD115  2EFFA71A11        jmp [cs:bx+0x111a]
000FD11A  2011              and [bx+di],dl
000FD11C  3811              cmp [bx+di],dl
000FD11E  56                push si
000FD11F  11FB              adc bx,di
000FD121  E81B00            call 0xd13f
000FD124  74FA              jz 0xd120
000FD126  43                inc bx
000FD127  43                inc bx
000FD128  3B1E8204          cmp bx,[0x482]
000FD12C  7204              jc 0xd132
000FD12E  8B1E8004          mov bx,[0x480]
000FD132  891E1A04          mov [0x41a],bx
000FD136  FB                sti
000FD137  C3                ret
000FD138  E80400            call 0xd13f
000FD13B  FB                sti
000FD13C  E961FA            jmp 0xcba0
000FD13F  FA                cli
000FD140  8B1E1A04          mov bx,[0x41a]
000FD144  3B1E1C04          cmp bx,[0x41c]
000FD148  740B              jz 0xd155
000FD14A  B84000            mov ax,0x40
000FD14D  8EC0              mov es,ax
000FD14F  268B07            mov ax,[es:bx]
000FD152  894600            mov [bp+0x0],ax
000FD155  C3                ret
000FD156  A01704            mov al,[0x417]
000FD159  32E4              xor ah,ah
000FD15B  894600            mov [bp+0x0],ax
000FD15E  C3                ret
000FD15F  1E                push ds
000FD160  52                push dx
000FD161  51                push cx
000FD162  53                push bx
000FD163  50                push ax
000FD164  E460              in al,0x60
000FD166  8AE0              mov ah,al
000FD168  E461              in al,0x61
000FD16A  0C80              or al,0x80
000FD16C  E661              out 0x61,al
000FD16E  247F              and al,0x7f
000FD170  E661              out 0x61,al
000FD172  8AD4              mov dl,ah
000FD174  33C0              xor ax,ax
000FD176  8ED8              mov ds,ax
000FD178  E80A00            call 0xd185
000FD17B  B061              mov al,0x61
000FD17D  E620              out 0x20,al
000FD17F  58                pop ax
000FD180  5B                pop bx
000FD181  59                pop cx
000FD182  5A                pop dx
000FD183  1F                pop ds
000FD184  CF                iret
000FD185  8AC2              mov al,dl
000FD187  247F              and al,0x7f
000FD189  3C54              cmp al,0x54
000FD18B  724F              jc 0xd1dc
000FD18D  F6C280            test dl,0x80
000FD190  7507              jnz 0xd199
000FD192  F606180408        test byte [0x418],0x8
000FD197  7511              jnz 0xd1aa
000FD199  BBC113            mov bx,0x13c1
000FD19C  B90A00            mov cx,0xa
000FD19F  90                nop
000FD1A0  2E3A07            cmp al,[cs:bx]
000FD1A3  740B              jz 0xd1b0
000FD1A5  43                inc bx
000FD1A6  43                inc bx
000FD1A7  43                inc bx
000FD1A8  E2F6              loop 0xd1a0
000FD1AA  80261804F7        and byte [0x418],0xf7
000FD1AF  C3                ret
000FD1B0  2E8B4701          mov ax,[cs:bx+0x1]
000FD1B4  F6C4FF            test ah,0xff
000FD1B7  7505              jnz 0xd1be
000FD1B9  E8F1FA            call 0xccad
000FD1BC  EB0A              jmp short 0xd1c8
000FD1BE  8ADA              mov bl,dl
000FD1C0  80E37F            and bl,0x7f
000FD1C3  80FB7D            cmp bl,0x7d
000FD1C6  7308              jnc 0xd1d0
000FD1C8  F6C280            test dl,0x80
000FD1CB  75E2              jnz 0xd1af
000FD1CD  E98400            jmp 0xd254
000FD1D0  80E280            and dl,0x80
000FD1D3  0AC2              or al,dl
000FD1D5  CD06              int 0x6
000FD1D7  73D6              jnc 0xd1af
000FD1D9  EB79              jmp short 0xd254
000FD1DB  90                nop
000FD1DC  8AD8              mov bl,al
000FD1DE  A01704            mov al,[0x417]
000FD1E1  8AC8              mov cl,al
000FD1E3  24BF              and al,0xbf
000FD1E5  A803              test al,0x3
000FD1E7  7405              jz 0xd1ee
000FD1E9  80F140            xor cl,0x40
000FD1EC  3460              xor al,0x60
000FD1EE  80FB47            cmp bl,0x47
000FD1F1  7204              jc 0xd1f7
000FD1F3  242C              and al,0x2c
000FD1F5  EB02              jmp short 0xd1f9
000FD1F7  244C              and al,0x4c
000FD1F9  7412              jz 0xd20d
000FD1FB  8AE0              mov ah,al
000FD1FD  B002              mov al,0x2
000FD1FF  F6C408            test ah,0x8
000FD202  7509              jnz 0xd20d
000FD204  D0E0              shl al,1
000FD206  F6C404            test ah,0x4
000FD209  7502              jnz 0xd20d
000FD20B  40                inc ax
000FD20C  40                inc ax
000FD20D  32FF              xor bh,bh
000FD20F  03DB              add bx,bx
000FD211  03DB              add bx,bx
000FD213  03DB              add bx,bx
000FD215  32E4              xor ah,ah
000FD217  03D8              add bx,ax
000FD219  2E8B9FDF13        mov bx,[cs:bx+0x13df]
000FD21E  80FFF0            cmp bh,0xf0
000FD221  720C              jc 0xd22f
000FD223  8AE7              mov ah,bh
000FD225  32FF              xor bh,bh
000FD227  F6C280            test dl,0x80
000FD22A  2EFFA7A513        jmp [cs:bx+0x13a5]
000FD22F  F6C280            test dl,0x80
000FD232  751F              jnz 0xd253
000FD234  8BC3              mov ax,bx
000FD236  F606180408        test byte [0x418],0x8
000FD23B  7511              jnz 0xd24e
000FD23D  F6C140            test cl,0x40
000FD240  7412              jz 0xd254
000FD242  3C61              cmp al,0x61
000FD244  720E              jc 0xd254
000FD246  3C7A              cmp al,0x7a
000FD248  770A              ja 0xd254
000FD24A  2C20              sub al,0x20
000FD24C  EB06              jmp short 0xd254
000FD24E  80261804F7        and byte [0x418],0xf7
000FD253  C3                ret
000FD254  40                inc ax
000FD255  742C              jz 0xd283
000FD257  48                dec ax
000FD258  8B1E1C04          mov bx,[0x41c]
000FD25C  53                push bx
000FD25D  43                inc bx
000FD25E  43                inc bx
000FD25F  3B1E8204          cmp bx,[0x482]
000FD263  7204              jc 0xd269
000FD265  8B1E8004          mov bx,[0x480]
000FD269  3B1E1A04          cmp bx,[0x41a]
000FD26D  7410              jz 0xd27f
000FD26F  891E1C04          mov [0x41c],bx
000FD273  5B                pop bx
000FD274  06                push es
000FD275  B94000            mov cx,0x40
000FD278  8EC1              mov es,cx
000FD27A  268907            mov [es:bx],ax
000FD27D  07                pop es
000FD27E  C3                ret
000FD27F  5B                pop bx
000FD280  E9A31E            jmp 0xf126
000FD283  C606190400        mov byte [0x419],0x0
000FD288  C3                ret
000FD289  751C              jnz 0xd2a7
000FD28B  F606180408        test byte [0x418],0x8
000FD290  7576              jnz 0xd308
000FD292  A01904            mov al,[0x419]
000FD295  02C0              add al,al
000FD297  8AD8              mov bl,al
000FD299  02C0              add al,al
000FD29B  02C0              add al,al
000FD29D  02C3              add al,bl
000FD29F  80E40F            and ah,0xf
000FD2A2  02C4              add al,ah
000FD2A4  A21904            mov [0x419],al
000FD2A7  C3                ret
000FD2A8  75FD              jnz 0xd2a7
000FD2AA  F606180408        test byte [0x418],0x8
000FD2AF  7557              jnz 0xd308
000FD2B1  A18004            mov ax,[0x480]
000FD2B4  A31C04            mov [0x41c],ax
000FD2B7  A31A04            mov [0x41a],ax
000FD2BA  C606710480        mov byte [0x471],0x80
000FD2BF  1E                push ds
000FD2C0  B84000            mov ax,0x40
000FD2C3  8ED8              mov ds,ax
000FD2C5  CD1B              int 0x1b
000FD2C7  1F                pop ds
000FD2C8  B80000            mov ax,0x0
000FD2CB  EB87              jmp short 0xd254
000FD2CD  755F              jnz 0xd32e
000FD2CF  F606170404        test byte [0x417],0x4
000FD2D4  7458              jz 0xd32e
000FD2D6  33C0              xor ax,ax
000FD2D8  8ED8              mov ds,ax
000FD2DA  C70672043412      mov word [0x472],0x1234
000FD2E0  E9E6ED            jmp 0xc0c9
000FD2E3  7549              jnz 0xd32e
000FD2E5  F606180408        test byte [0x418],0x8
000FD2EA  751C              jnz 0xd308
000FD2EC  E80200            call 0xd2f1
000FD2EF  CD05              int 0x5
000FD2F1  803E490407        cmp byte [0x449],0x7
000FD2F6  740B              jz 0xd303
000FD2F8  8B166304          mov dx,[0x463]
000FD2FC  83C204            add dx,byte +0x4
000FD2FF  A06504            mov al,[0x465]
000FD302  EE                out dx,al
000FD303  B061              mov al,0x61
000FD305  E620              out 0x20,al
000FD307  C3                ret
000FD308  80261804F7        and byte [0x418],0xf7
000FD30D  C3                ret
000FD30E  7549              jnz 0xd359
000FD310  E84600            call 0xd359
000FD313  F606180408        test byte [0x418],0x8
000FD318  7514              jnz 0xd32e
000FD31A  800E180408        or byte [0x418],0x8
000FD31F  E8CFFF            call 0xd2f1
000FD322  FB                sti
000FD323  F606180408        test byte [0x418],0x8
000FD328  75F9              jnz 0xd323
000FD32A  58                pop ax
000FD32B  E951FE            jmp 0xd17f
000FD32E  C3                ret
000FD32F  A880              test al,0x80
000FD331  7508              jnz 0xd33b
000FD333  02C0              add al,al
000FD335  041D              add al,0x1d
000FD337  E873F9            call 0xccad
000FD33A  F9                stc
000FD33B  CA0200            retf 0x2
000FD33E  B480              mov ah,0x80
000FD340  7519              jnz 0xd35b
000FD342  84261804          test [0x418],ah
000FD346  755C              jnz 0xd3a4
000FD348  E81000            call 0xd35b
000FD34B  B80052            mov ax,0x5200
000FD34E  E903FF            jmp 0xd254
000FD351  B410              mov ah,0x10
000FD353  EB06              jmp short 0xd35b
000FD355  B440              mov ah,0x40
000FD357  EB02              jmp short 0xd35b
000FD359  B420              mov ah,0x20
000FD35B  750F              jnz 0xd36c
000FD35D  84261804          test [0x418],ah
000FD361  7508              jnz 0xd36b
000FD363  08261804          or [0x418],ah
000FD367  30261704          xor [0x417],ah
000FD36B  C3                ret
000FD36C  F6D4              not ah
000FD36E  20261804          and [0x418],ah
000FD372  C3                ret
000FD373  9C                pushf
000FD374  B408              mov ah,0x8
000FD376  E81E00            call 0xd397
000FD379  A01904            mov al,[0x419]
000FD37C  C606190400        mov byte [0x419],0x0
000FD381  9D                popf
000FD382  74AA              jz 0xd32e
000FD384  0AC0              or al,al
000FD386  74A6              jz 0xd32e
000FD388  32E4              xor ah,ah
000FD38A  E9C7FE            jmp 0xd254
000FD38D  B404              mov ah,0x4
000FD38F  EB06              jmp short 0xd397
000FD391  B402              mov ah,0x2
000FD393  EB02              jmp short 0xd397
000FD395  B401              mov ah,0x1
000FD397  7505              jnz 0xd39e
000FD399  08261704          or [0x417],ah
000FD39D  C3                ret
000FD39E  F6D4              not ah
000FD3A0  20261704          and [0x417],ah
000FD3A4  C3                ret
000FD3A5  8912              mov [bp+si],dx
000FD3A7  0E                push cs
000FD3A8  13A812CD          adc bp,[bx+si-0x32ee]
000FD3AC  12E3              adc ah,bl
000FD3AE  123E1351          adc bh,[0x5113]
000FD3B2  135513            adc dx,[di+0x13]
000FD3B5  59                pop cx
000FD3B6  13911395          adc dx,[bx+di-0x6aed]
000FD3BA  137313            adc si,[bp+di+0x13]
000FD3BD  8D13              lea dx,[bp+di]
000FD3BF  831274            adc word [bp+si],byte +0x74
000FD3C2  150070            adc ax,0x7000
000FD3C5  17                pop ss
000FD3C6  00771B            add [bx+0x1b],dh
000FD3C9  007819            add [bx+si+0x19],bh
000FD3CC  007900            add [bx+di+0x0],bh
000FD3CF  4D                dec bp
000FD3D0  7A00              jpe 0xd3d2
000FD3D2  4B                dec bx
000FD3D3  7B00              jpo 0xd3d5
000FD3D5  50                push ax
000FD3D6  7C00              jl 0xd3d8
000FD3D8  48                dec ax
000FD3D9  7E00              jng 0xd3db
000FD3DB  017D01            add [di+0x1],di
000FD3DE  011A              add [bp+si],bx
000FD3E0  F01AF0            lock sbb dh,al
000FD3E3  1AF0              sbb dh,al
000FD3E5  1AF0              sbb dh,al
000FD3E7  1B01              sbb ax,[bx+di]
000FD3E9  1AF0              sbb dh,al
000FD3EB  1B01              sbb ax,[bx+di]
000FD3ED  1B01              sbb ax,[bx+di]
000FD3EF  3102              xor [bp+si],ax
000FD3F1  00781A            add [bx+si+0x1a],bh
000FD3F4  F02102            lock and [bp+si],ax
000FD3F7  3203              xor al,[bp+di]
000FD3F9  007900            add [bx+di+0x0],bh
000FD3FC  034003            add ax,[bx+si+0x3]
000FD3FF  3304              xor ax,[si]
000FD401  007A1A            add [bp+si+0x1a],bh
000FD404  F02304            lock and ax,[si]
000FD407  3405              xor al,0x5
000FD409  007B1A            add [bp+di+0x1a],bh
000FD40C  F02405            lock and al,0x5
000FD40F  350600            xor ax,0x6
000FD412  7C1A              jl 0xd42e
000FD414  F0250636          lock and ax,0x3606
000FD418  07                pop es
000FD419  007D1E            add [di+0x1e],bh
000FD41C  07                pop es
000FD41D  5E                pop si
000FD41E  07                pop es
000FD41F  37                aaa
000FD420  0800              or [bx+si],al
000FD422  7E1A              jng 0xd43e
000FD424  F0260838          lock or [es:bx+si],bh
000FD428  0900              or [bx+si],ax
000FD42A  7F1A              jg 0xd446
000FD42C  F02A09            lock sub cl,[bx+di]
000FD42F  390A              cmp [bp+si],cx
000FD431  00801AF0          add [bx+si-0xfe6],al
000FD435  280A              sub [bp+si],cl
000FD437  300B              xor [bp+di],cl
000FD439  00811AF0          add [bx+di-0xfe6],al
000FD43D  290B              sub [bp+di],cx
000FD43F  2D0C00            sub ax,0xc
000FD442  82                db 0x82
000FD443  1F                pop ds
000FD444  0C5F              or al,0x5f
000FD446  0C3D              or al,0x3d
000FD448  0D0083            or ax,0x8300
000FD44B  1AF0              sbb dh,al
000FD44D  2B0D              sub cx,[di]
000FD44F  080E1AF0          or [0xf01a],cl
000FD453  7F0E              jg 0xd463
000FD455  080E090F          or [0xf09],cl
000FD459  1AF0              sbb dh,al
000FD45B  1AF0              sbb dh,al
000FD45D  000F              add [bx],cl
000FD45F  7110              jno 0xd471
000FD461  0010              add [bx+si],dl
000FD463  1110              adc [bx+si],dx
000FD465  7110              jno 0xd477
000FD467  7711              ja 0xd47a
000FD469  0011              add [bx+di],dl
000FD46B  17                pop ss
000FD46C  117711            adc [bx+0x11],si
000FD46F  651200            adc al,[gs:bx+si]
000FD472  1205              adc al,[di]
000FD474  126512            adc ah,[di+0x12]
000FD477  7213              jc 0xd48c
000FD479  0013              add [bp+di],dl
000FD47B  1213              adc dl,[bp+di]
000FD47D  7213              jc 0xd492
000FD47F  7414              jz 0xd495
000FD481  0014              add [si],dl
000FD483  1414              adc al,0x14
000FD485  7414              jz 0xd49b
000FD487  7915              jns 0xd49e
000FD489  0015              add [di],dl
000FD48B  1915              sbb [di],dx
000FD48D  7915              jns 0xd4a4
000FD48F  7516              jnz 0xd4a7
000FD491  00161516          add [0x1615],dl
000FD495  7516              jnz 0xd4ad
000FD497  69170017          imul dx,[bx],word 0x1700
000FD49B  0917              or [bx],dx
000FD49D  69176F18          imul dx,[bx],word 0x186f
000FD4A1  0018              add [bx+si],bl
000FD4A3  0F186F18          hint_nop5 word [bx+0x18]
000FD4A7  7019              jo 0xd4c2
000FD4A9  0019              add [bx+di],bl
000FD4AB  1019              adc [bx+di],bl
000FD4AD  7019              jo 0xd4c8
000FD4AF  5B                pop bx
000FD4B0  1A1A              sbb bl,[bp+si]
000FD4B2  F01B1A            lock sbb bx,[bp+si]
000FD4B5  7B1A              jpo 0xd4d1
000FD4B7  5D                pop bp
000FD4B8  1B1A              sbb bx,[bp+si]
000FD4BA  F01D1B7D          lock sbb ax,0x7d1b
000FD4BE  1B0D              sbb cx,[di]
000FD4C0  1C1A              sbb al,0x1a
000FD4C2  F00A1C            lock or bl,[si]
000FD4C5  0D1C18            or ax,0x181c
000FD4C8  F018F0            lock sbb al,dh
000FD4CB  18F0              sbb al,dh
000FD4CD  18F0              sbb al,dh
000FD4CF  61                popa
000FD4D0  1E                push ds
000FD4D1  001E011E          add [0x1e01],bl
000FD4D5  61                popa
000FD4D6  1E                push ds
000FD4D7  731F              jnc 0xd4f8
000FD4D9  001F              add [bx],bl
000FD4DB  131F              adc bx,[bx]
000FD4DD  731F              jnc 0xd4fe
000FD4DF  642000            and [fs:bx+si],al
000FD4E2  2004              and [si],al
000FD4E4  206420            and [si+0x20],ah
000FD4E7  662100            and [bx+si],eax
000FD4EA  21062166          and [0x6621],ax
000FD4EE  216722            and [bx+0x22],sp
000FD4F1  0022              add [bp+si],ah
000FD4F3  07                pop es
000FD4F4  226722            and ah,[bx+0x22]
000FD4F7  682300            push word 0x23
000FD4FA  2308              and cx,[bx+si]
000FD4FC  236823            and bp,[bx+si+0x23]
000FD4FF  6A24              push byte +0x24
000FD501  0024              add [si],ah
000FD503  0A24              or ah,[si]
000FD505  6A24              push byte +0x24
000FD507  6B2500            imul sp,[di],byte +0x0
000FD50A  250B25            and ax,0x250b
000FD50D  6B256C            imul sp,[di],byte +0x6c
000FD510  2600260C26        add [es:0x260c],ah
000FD515  6C                insb
000FD516  263B27            cmp sp,[es:bx]
000FD519  1AF0              sbb dh,al
000FD51B  1AF0              sbb dh,al
000FD51D  3A27              cmp ah,[bx]
000FD51F  27                daa
000FD520  281A              sub [bp+si],bl
000FD522  F01AF0            lock sbb dh,al
000FD525  2228              and ch,[bx+si]
000FD527  60                pusha
000FD528  291A              sub [bp+si],bx
000FD52A  F01AF0            lock sbb dh,al
000FD52D  7E29              jng 0xd558
000FD52F  12F0              adc dh,al
000FD531  12F0              adc dh,al
000FD533  12F0              adc dh,al
000FD535  12F0              adc dh,al
000FD537  5C                pop sp
000FD538  2B1A              sub bx,[bp+si]
000FD53A  F01C2B            lock sbb al,0x2b
000FD53D  7C2B              jl 0xd56a
000FD53F  7A2C              jpe 0xd56d
000FD541  002C              add [si],ch
000FD543  1A2C              sbb ch,[si]
000FD545  7A2C              jpe 0xd573
000FD547  782D              js 0xd576
000FD549  002D              add [di],ch
000FD54B  182D              sbb [di],ch
000FD54D  782D              js 0xd57c
000FD54F  632E002E          arpl [0x2e00],bp
000FD553  032E632E          add bp,[0x2e63]
000FD557  762F              jna 0xd588
000FD559  002F              add [bx],ch
000FD55B  16                push ss
000FD55C  2F                das
000FD55D  762F              jna 0xd58e
000FD55F  6230              bound si,[bx+si]
000FD561  0030              add [bx+si],dh
000FD563  0230              add dh,[bx+si]
000FD565  6230              bound si,[bx+si]
000FD567  6E                outsb
000FD568  3100              xor [bx+si],ax
000FD56A  310E316E          xor [0x6e31],cx
000FD56E  316D32            xor [di+0x32],bp
000FD571  0032              add [bp+si],dh
000FD573  0D326D            or ax,0x6d32
000FD576  322C              xor ch,[si]
000FD578  331A              xor bx,[bp+si]
000FD57A  F01AF0            lock sbb dh,al
000FD57D  3C33              cmp al,0x33
000FD57F  2E341A            cs xor al,0x1a
000FD582  F01AF0            lock sbb dh,al
000FD585  3E342F            ds xor al,0x2f
000FD588  351AF0            xor ax,0xf01a
000FD58B  1AF0              sbb dh,al
000FD58D  3F                aas
000FD58E  3514F0            xor ax,0xf014
000FD591  14F0              adc al,0xf0
000FD593  14F0              adc al,0xf0
000FD595  14F0              adc al,0xf0
000FD597  2A37              sub dh,[bx]
000FD599  1AF0              sbb dh,al
000FD59B  007208            add [bp+si+0x8],dh
000FD59E  F016              lock push ss
000FD5A0  F016              lock push ss
000FD5A2  F016              lock push ss
000FD5A4  F016              lock push ss
000FD5A6  F02039            lock and [bx+di],bh
000FD5A9  2039              and [bx+di],bh
000FD5AB  2039              and [bx+di],bh
000FD5AD  2039              and [bx+di],bh
000FD5AF  0E                push cs
000FD5B0  F00E              lock push cs
000FD5B2  F00E              lock push cs
000FD5B4  F00E              lock push cs
000FD5B6  F0003B            lock add [bp+di],bh
000FD5B9  006800            add [bx+si+0x0],ch
000FD5BC  5E                pop si
000FD5BD  005400            add [si+0x0],dl
000FD5C0  3C00              cmp al,0x0
000FD5C2  69005F00          imul ax,[bx+si],word 0x5f
000FD5C6  55                push bp
000FD5C7  003D              add [di],bh
000FD5C9  006A00            add [bp+si+0x0],ch
000FD5CC  60                pusha
000FD5CD  005600            add [bp+0x0],dl
000FD5D0  3E006B00          add [ds:bp+di+0x0],ch
000FD5D4  61                popa
000FD5D5  005700            add [bx+0x0],dl
000FD5D8  3F                aas
000FD5D9  006C00            add [si+0x0],ch
000FD5DC  6200              bound ax,[bx+si]
000FD5DE  58                pop ax
000FD5DF  004000            add [bx+si+0x0],al
000FD5E2  6D                insw
000FD5E3  006300            add [bp+di+0x0],ah
000FD5E6  59                pop cx
000FD5E7  004100            add [bx+di+0x0],al
000FD5EA  6E                outsb
000FD5EB  006400            add [si+0x0],ah
000FD5EE  5A                pop dx
000FD5EF  004200            add [bp+si+0x0],al
000FD5F2  6F                outsw
000FD5F3  006500            add [di+0x0],ah
000FD5F6  5B                pop bx
000FD5F7  004300            add [bp+di+0x0],al
000FD5FA  7000              jo 0xd5fc
000FD5FC  66005C00          o32 add [si+0x0],bl
000FD600  44                inc sp
000FD601  007100            add [bx+di+0x0],dh
000FD604  67005D10          add [ebp+0x10],bl
000FD608  F010F0            lock adc al,dh
000FD60B  02F0              add dh,al
000FD60D  10F0              adc al,dh
000FD60F  0CF0              or al,0xf0
000FD611  0CF0              or al,0xf0
000FD613  04F0              add al,0xf0
000FD615  0CF0              or al,0xf0
000FD617  004700            add [bx+0x0],al
000FD61A  F7007737          test word [bx+si],0x3777
000FD61E  47                inc di
000FD61F  004800            add [bx+si+0x0],cl
000FD622  F8                clc
000FD623  1AF0              sbb dh,al
000FD625  384800            cmp [bx+si+0x0],cl
000FD628  49                dec cx
000FD629  00F9              add cl,bh
000FD62B  00843949          add [si+0x4939],al
000FD62F  2D4A1A            sub ax,0x1a4a
000FD632  F01AF0            lock sbb dh,al
000FD635  2D4A00            sub ax,0x4a
000FD638  4B                dec bx
000FD639  00F4              add ah,dh
000FD63B  007334            add [bp+di+0x34],dh
000FD63E  4B                dec bx
000FD63F  1AF0              sbb dh,al
000FD641  00F5              add ch,dh
000FD643  1AF0              sbb dh,al
000FD645  354C00            xor ax,0x4c
000FD648  4D                dec bp
000FD649  00F6              add dh,dh
000FD64B  007436            add [si+0x36],dh
000FD64E  4D                dec bp
000FD64F  2B4E1A            sub cx,[bp+0x1a]
000FD652  F01AF0            lock sbb dh,al
000FD655  2B4E00            sub cx,[bp+0x0]
000FD658  4F                dec di
000FD659  00F1              add cl,dh
000FD65B  007531            add [di+0x31],dh
000FD65E  4F                dec di
000FD65F  005000            add [bx+si+0x0],dl
000FD662  F21AF0            repne sbb dh,al
000FD665  325000            xor dl,[bx+si+0x0]
000FD668  51                push cx
000FD669  00F3              add bl,dh
000FD66B  007633            add [bp+0x33],dh
000FD66E  51                push cx
000FD66F  0AF0              or dh,al
000FD671  00F0              add al,dh
000FD673  1AF0              sbb dh,al
000FD675  305200            xor [bp+si+0x0],dl
000FD678  53                push bx
000FD679  06                push es
000FD67A  F01AF0            lock sbb dh,al
000FD67D  2E53              cs push bx
000FD67F  00E8              add al,ch
000FD681  1C01              sbb al,0x1
000FD683  56                push si
000FD684  8BF0              mov si,ax
000FD686  FC                cld
000FD687  2EAC              cs lodsb
000FD689  0AC0              or al,al
000FD68B  7407              jz 0xd694
000FD68D  51                push cx
000FD68E  E80500            call 0xd696
000FD691  59                pop cx
000FD692  EBF3              jmp short 0xd687
000FD694  5E                pop si
000FD695  C3                ret
000FD696  7904              jns 0xd69c
000FD698  247F              and al,0x7f
000FD69A  EBE4              jmp short 0xd680
000FD69C  3C20              cmp al,0x20
000FD69E  7326              jnc 0xd6c6
000FD6A0  3C02              cmp al,0x2
000FD6A2  7516              jnz 0xd6ba
000FD6A4  2EAC              cs lodsb
000FD6A6  8AC8              mov cl,al
000FD6A8  56                push si
000FD6A9  32ED              xor ch,ch
000FD6AB  BEC822            mov si,0x22c8
000FD6AE  E3D6              jcxz 0xd686
000FD6B0  2EAC              cs lodsb
000FD6B2  0AC0              or al,al
000FD6B4  75FA              jnz 0xd6b0
000FD6B6  E2F8              loop 0xd6b0
000FD6B8  EBCC              jmp short 0xd686
000FD6BA  3C07              cmp al,0x7
000FD6BC  7413              jz 0xd6d1
000FD6BE  3C1B              cmp al,0x1b
000FD6C0  751B              jnz 0xd6dd
000FD6C2  2EAC              cs lodsb
000FD6C4  EB0B              jmp short 0xd6d1
000FD6C6  3C5C              cmp al,0x5c
000FD6C8  7507              jnz 0xd6d1
000FD6CA  B00D              mov al,0xd
000FD6CC  E8C700            call 0xd796
000FD6CF  B00A              mov al,0xa
000FD6D1  E8C200            call 0xd796
000FD6D4  3C07              cmp al,0x7
000FD6D6  7504              jnz 0xd6dc
000FD6D8  33C9              xor cx,cx
000FD6DA  E2FE              loop 0xd6da
000FD6DC  C3                ret
000FD6DD  3C0F              cmp al,0xf
000FD6DF  751C              jnz 0xd6fd
000FD6E1  B009              mov al,0x9
000FD6E3  90                nop
000FD6E4  E8B800            call 0xd79f
000FD6E7  32ED              xor ch,ch
000FD6E9  E398              jcxz 0xd683
000FD6EB  53                push bx
000FD6EC  8BD8              mov bx,ax
000FD6EE  2E8A2F            mov ch,[cs:bx]
000FD6F1  43                inc bx
000FD6F2  0AED              or ch,ch
000FD6F4  75F8              jnz 0xd6ee
000FD6F6  E2F6              loop 0xd6ee
000FD6F8  8BC3              mov ax,bx
000FD6FA  5B                pop bx
000FD6FB  EB86              jmp short 0xd683
000FD6FD  3C15              cmp al,0x15
000FD6FF  7422              jz 0xd723
000FD701  3C10              cmp al,0x10
000FD703  744E              jz 0xd753
000FD705  B103              mov cl,0x3
000FD707  3C14              cmp al,0x14
000FD709  7464              jz 0xd76f
000FD70B  32C9              xor cl,cl
000FD70D  3C12              cmp al,0x12
000FD70F  8AC3              mov al,bl
000FD711  7463              jz 0xd776
000FD713  8AC7              mov al,bh
000FD715  725F              jc 0xd776
000FD717  8AC5              mov al,ch
000FD719  EB5B              jmp short 0xd776
000FD71B  1027              adc [bx],ah
000FD71D  E80364            call 0x3b23
000FD720  000A              add [bp+si],cl
000FD722  00568B            add [bp-0x75],dl
000FD725  DABE1B17          fidivr dword [bp+0x171b]
000FD729  B90400            mov cx,0x4
000FD72C  FC                cld
000FD72D  2EAD              cs lodsw
000FD72F  33D2              xor dx,dx
000FD731  93                xchg ax,bx
000FD732  F7F3              div bx
000FD734  8BDA              mov bx,dx
000FD736  0AC0              or al,al
000FD738  7404              jz 0xd73e
000FD73A  B530              mov ch,0x30
000FD73C  EB04              jmp short 0xd742
000FD73E  0AED              or ch,ch
000FD740  7405              jz 0xd747
000FD742  02C5              add al,ch
000FD744  E84F00            call 0xd796
000FD747  FEC9              dec cl
000FD749  75E2              jnz 0xd72d
000FD74B  8AC3              mov al,bl
000FD74D  0430              add al,0x30
000FD74F  5E                pop si
000FD750  EB44              jmp short 0xd796
000FD752  90                nop
000FD753  52                push dx
000FD754  8CDA              mov dx,ds
000FD756  B104              mov cl,0x4
000FD758  D3C2              rol dx,cl
000FD75A  8AC2              mov al,dl
000FD75C  80E2F0            and dl,0xf0
000FD75F  03D3              add dx,bx
000FD761  7302              jnc 0xd765
000FD763  FEC0              inc al
000FD765  32C9              xor cl,cl
000FD767  E81700            call 0xd781
000FD76A  E80200            call 0xd76f
000FD76D  5A                pop dx
000FD76E  C3                ret
000FD76F  8AC6              mov al,dh
000FD771  E80200            call 0xd776
000FD774  8AC2              mov al,dl
000FD776  50                push ax
000FD777  51                push cx
000FD778  B104              mov cl,0x4
000FD77A  D2C0              rol al,cl
000FD77C  59                pop cx
000FD77D  E80100            call 0xd781
000FD780  58                pop ax
000FD781  240F              and al,0xf
000FD783  0490              add al,0x90
000FD785  27                daa
000FD786  1440              adc al,0x40
000FD788  27                daa
000FD789  3C30              cmp al,0x30
000FD78B  7507              jnz 0xd794
000FD78D  0AC9              or cl,cl
000FD78F  7403              jz 0xd794
000FD791  FEC9              dec cl
000FD793  C3                ret
000FD794  32C9              xor cl,cl
000FD796  53                push bx
000FD797  B40E              mov ah,0xe
000FD799  33DB              xor bx,bx
000FD79B  CD10              int 0x10
000FD79D  5B                pop bx
000FD79E  C3                ret
000FD79F  53                push bx
000FD7A0  52                push dx
000FD7A1  32E4              xor ah,ah
000FD7A3  50                push ax
000FD7A4  BA7903            mov dx,0x379
000FD7A7  EC                in al,dx
000FD7A8  250700            and ax,0x7
000FD7AB  D1E0              shl ax,1
000FD7AD  8BD8              mov bx,ax
000FD7AF  2E8B9F2E27        mov bx,[cs:bx+0x272e]
000FD7B4  58                pop ax
000FD7B5  5A                pop dx
000FD7B6  D1E0              shl ax,1
000FD7B8  03D8              add bx,ax
000FD7BA  2E8B07            mov ax,[cs:bx]
000FD7BD  5B                pop bx
000FD7BE  C3                ret
000FD7BF  B00E              mov al,0xe
000FD7C1  FA                cli
000FD7C2  8BE8              mov bp,ax
000FD7C4  BBCA17            mov bx,0x17ca
000FD7C7  E9E819            jmp 0xf1b2
000FD7CA  33FF              xor di,di
000FD7CC  B800B0            mov ax,0xb000
000FD7CF  8EC0              mov es,ax
000FD7D1  BA7903            mov dx,0x379
000FD7D4  EC                in al,dx
000FD7D5  250700            and ax,0x7
000FD7D8  D1E0              shl ax,1
000FD7DA  8BD8              mov bx,ax
000FD7DC  8CC8              mov ax,cs
000FD7DE  8ED8              mov ds,ax
000FD7E0  8B9F2E27          mov bx,[bx+0x272e]
000FD7E4  8BC5              mov ax,bp
000FD7E6  3C0F              cmp al,0xf
000FD7E8  BA4503            mov dx,0x345
000FD7EB  740C              jz 0xd7f9
000FD7ED  B000              mov al,0x0
000FD7EF  BAF417            mov dx,0x17f4
000FD7F2  EB05              jmp short 0xd7f9
000FD7F4  8BC5              mov ax,bp
000FD7F6  BA6218            mov dx,0x1862
000FD7F9  8B7710            mov si,[bx+0x10]
000FD7FC  FC                cld
000FD7FD  8BC8              mov cx,ax
000FD7FF  32ED              xor ch,ch
000FD801  E307              jcxz 0xd80a
000FD803  AC                lodsb
000FD804  0AC0              or al,al
000FD806  75FB              jnz 0xd803
000FD808  E2F9              loop 0xd803
000FD80A  AC                lodsb
000FD80B  3C1B              cmp al,0x1b
000FD80D  7503              jnz 0xd812
000FD80F  AC                lodsb
000FD810  EB1F              jmp short 0xd831
000FD812  0AC0              or al,al
000FD814  7826              js 0xd83c
000FD816  7502              jnz 0xd81a
000FD818  FFE2              jmp dx
000FD81A  3C02              cmp al,0x2
000FD81C  7513              jnz 0xd831
000FD81E  AC                lodsb
000FD81F  8AE0              mov ah,al
000FD821  8BCE              mov cx,si
000FD823  BEC822            mov si,0x22c8
000FD826  AC                lodsb
000FD827  0AC0              or al,al
000FD829  75FB              jnz 0xd826
000FD82B  FECC              dec ah
000FD82D  75F7              jnz 0xd826
000FD82F  EB18              jmp short 0xd849
000FD831  268805            mov [es:di],al
000FD834  81F70080          xor di,0x8000
000FD838  AA                stosb
000FD839  47                inc di
000FD83A  EBCE              jmp short 0xd80a
000FD83C  257F00            and ax,0x7f
000FD83F  D1E0              shl ax,1
000FD841  8BC8              mov cx,ax
000FD843  87F1              xchg cx,si
000FD845  03F3              add si,bx
000FD847  8B34              mov si,[si]
000FD849  AC                lodsb
000FD84A  0AC0              or al,al
000FD84C  87F1              xchg cx,si
000FD84E  74BA              jz 0xd80a
000FD850  87F1              xchg cx,si
000FD852  3C1B              cmp al,0x1b
000FD854  7501              jnz 0xd857
000FD856  AC                lodsb
000FD857  268805            mov [es:di],al
000FD85A  81F70080          xor di,0x8000
000FD85E  AA                stosb
000FD85F  47                inc di
000FD860  EBE7              jmp short 0xd849
000FD862  EBFE              jmp short 0xd862
000FD864  C746020103        mov word [bp+0x2],0x301
000FD869  C3                ret
000FD86A  8A02              mov al,[bp+si]
000FD86C  0300              add ax,[bx+si]
000FD86E  5C                pop sp
000FD86F  53                push bx
000FD870  49                dec cx
000FD871  44                inc sp
000FD872  53                push bx
000FD873  54                push sp
000FD874  204245            and [bp+si+0x45],al
000FD877  4E                dec si
000FD878  59                pop cx
000FD879  54                push sp
000FD87A  54                push sp
000FD87B  45                inc bp
000FD87C  54                push sp
000FD87D  3A20              cmp ah,[bx+si]
000FD87F  8A5C07            mov bl,[si+0x7]
000FD882  0002              add [bp+si],al
000FD884  035C49            add bx,[si+0x49]
000FD887  6E                outsb
000FD888  647374            fs jnc 0xd8ff
000FD88B  696C204461        imul bp,[si+0x20],word 0x6144
000FD890  746F              jz 0xd901
000FD892  206F67            and [bx+0x67],ch
000FD895  204B6C            and [bp+di+0x6c],cl
000FD898  6F                outsw
000FD899  6B6B6573          imul bp,[bp+di+0x65],byte +0x73
000FD89D  6C                insb
000FD89E  65745C            gs jz 0xd8fd
000FD8A1  4A                dec dx
000FD8A2  7573              jnz 0xd917
000FD8A4  7465              jz 0xd90b
000FD8A6  7227              jc 0xd8cf
000FD8A8  206F70            and [bx+0x70],ch
000FD8AB  7374              jnc 0xd921
000FD8AD  61                popa
000FD8AE  7274              jc 0xd924
000FD8B0  7376              jnc 0xd928
000FD8B2  1B917264          sbb dx,[bx+di+0x6472]
000FD8B6  6965726E65        imul sp,[di+0x72],word 0x656e
000FD8BB  2028              and [bx+si],ch
000FD8BD  4B                dec bx
000FD8BE  756E              jnz 0xd92e
000FD8C0  206876            and [bx+si+0x76],ch
000FD8C3  6973206E1B        imul si,[bp+di+0x20],word 0x1b6e
000FD8C8  9B647665          fs wait jna 0xd931
000FD8CC  6E                outsb
000FD8CD  64696774295C      imul sp,[fs:bx+0x74],word 0x5c29
000FD8D3  07                pop es
000FD8D4  07                pop es
000FD8D5  07                pop es
000FD8D6  004D6F            add [di+0x6f],cl
000FD8D9  6E                outsb
000FD8DA  7465              jz 0xd941
000FD8DC  7220              jc 0xd8fe
000FD8DE  7665              jna 0xd945
000FD8E0  6E                outsb
000FD8E1  6C                insb
000FD8E2  6967737420        imul sp,[bx+0x73],word 0x2074
000FD8E7  6E                outsb
000FD8E8  7965              jns 0xd94f
000FD8EA  206261            and [bp+si+0x61],ah
000FD8ED  7474              jz 0xd963
000FD8EF  657269            gs jc 0xd95b
000FD8F2  65725C            gs jc 0xd951
000FD8F5  005C43            add [si+0x43],bl
000FD8F8  686563            push word 0x6365
000FD8FB  6B2054            imul sp,[bx+si],byte +0x54
000FD8FE  61                popa
000FD8FF  7374              jnc 0xd975
000FD901  61                popa
000FD902  7475              jz 0xd979
000FD904  7265              jc 0xd96b
000FD906  7420              jz 0xd928
000FD908  6F                outsw
000FD909  67204D75          and [ebp+0x75],cl
000FD90D  7365              jnc 0xd974
000FD90F  6E                outsb
000FD910  005C49            add [si+0x49],bl
000FD913  6E                outsb
000FD914  64731B            fs jnc 0xd932
000FD917  91                xchg ax,cx
000FD918  7420              jz 0xd93a
000FD91A  7665              jna 0xd981
000FD91C  6E                outsb
000FD91D  6C                insb
000FD91E  6967737420        imul sp,[bx+0x73],word 0x2074
000FD923  656E              gs outsb
000FD925  2002              and [bp+si],al
000FD927  16                push ss
000FD928  206469            and [si+0x69],ah
000FD92B  736B              jnc 0xd998
000FD92D  657474            gs jz 0xd9a4
000FD930  65206920          and [gs:bx+di+0x20],ch
000FD934  44                inc sp
000FD935  52                push dx
000FD936  45                inc bp
000FD937  56                push si
000FD938  20415C            and [bx+di+0x5c],al
000FD93B  6F                outsw
000FD93C  6720747279        and [dword edx+esi*2+0x79],dh
000FD941  6B2070            imul sp,[bx+si],byte +0x70
000FD944  1B862065          sbb ax,[bp+0x6520]
000FD948  6E                outsb
000FD949  207461            and [si+0x61],dh
000FD94C  7374              jnc 0xd9c2
000FD94E  005C46            add [si+0x46],bl
000FD951  45                inc bp
000FD952  4A                dec dx
000FD953  4C                dec sp
000FD954  3A02              cmp al,[bp+si]
000FD956  1B02              sbb ax,[bp+si]
000FD958  1D3A5C            sbb ax,0x5c3a
000FD95B  52                push dx
000FD95C  4F                dec di
000FD95D  4D                dec bp
000FD95E  206164            and [bx+di+0x64],ah
000FD961  7265              jc 0xd9c8
000FD963  7373              jnc 0xd9d8
000FD965  65203D            and [gs:di],bh
000FD968  2010              and [bx+si],dl
000FD96A  5C                pop sp
000FD96B  004645            add [bp+0x45],al
000FD96E  4A                dec dx
000FD96F  4C                dec sp
000FD970  3A20              cmp ah,[bx+si]
000FD972  008B0216          add [bp+di+0x1602],cl
000FD976  205241            and [bp+si+0x41],dl
000FD979  4D                dec bp
000FD97A  008B8D20          add [bp+di+0x208d],cl
000FD97E  52                push dx
000FD97F  41                inc cx
000FD980  4D                dec bp
000FD981  008B0220          add [bp+di+0x2002],cl
000FD985  8C00              mov [bx+si],es
000FD987  46                inc si
000FD988  656A6C            gs push byte +0x6c
000FD98B  206C61            and [si+0x61],ch
000FD98E  6765728C          gs jc 0xd91e
000FD992  008B021C          add [bp+di+0x1c02],cl
000FD996  6B6F6E74          imul bp,[bx+0x6e],byte +0x74
000FD99A  726F              jc 0xda0b
000FD99C  6C                insb
000FD99D  20656C            and [di+0x6c],ah
000FD9A0  6C                insb
000FD9A1  657220            gs jc 0xd9c4
000FD9A4  021C              add bl,[si]
000FD9A6  647265            fs jc 0xda0e
000FD9A9  7600              jna 0xd9ab
000FD9AB  8B02              mov ax,[bp+si]
000FD9AD  1120              adc [bx+si],sp
000FD9AF  0212              add dl,[bp+si]
000FD9B1  008B0216          add [bp+di+0x1602],cl
000FD9B5  2002              and [bp+si],al
000FD9B7  1420              adc al,0x20
000FD9B9  0215              add dl,[di]
000FD9BB  008B0217          add [bp+di+0x1702],cl
000FD9BF  7469              jz 0xda2a
000FD9C1  647320            fs jnc 0xd9e4
000FD9C4  7572              jnz 0xda38
000FD9C6  008B8D8C          add [bp+di-0x7373],cl
000FD9CA  008B0216          add [bp+di+0x1602],cl
000FD9CE  2002              and [bp+si],al
000FD9D0  182D              sbb [di],ch
000FD9D2  706F              jo 0xda43
000FD9D4  7274              jc 0xda4a
000FD9D6  008B0216          add [bp+di+0x1602],cl
000FD9DA  0219              add bl,[bx+di]
000FD9DC  2D706F            sub ax,0x6f70
000FD9DF  7274              jc 0xda55
000FD9E1  008B0215          add [bp+di+0x1502],cl
000FD9E5  207469            and [si+0x69],dh
000FD9E8  6C                insb
000FD9E9  206D75            and [di+0x75],ch
000FD9EC  7300              jnc 0xd9ee
000FD9EE  43                inc bx
000FD9EF  686563            push word 0x6365
000FD9F2  6B73756D          imul si,[bp+di+0x75],byte +0x6d
000FD9F6  66656A6C          gs o32 push byte +0x6c
000FD9FA  206920            and [bx+di+0x20],ch
000FD9FD  02162052          add dl,[0x5220]
000FDA01  4F                dec di
000FDA02  4D                dec bp
000FDA03  008B6C61          add [bp+di+0x616c],cl
000FDA07  67657220          gs jc 0xda2b
000FDA0B  287061            sub [bx+si+0x61],dh
000FDA0E  7269              jc 0xda79
000FDA10  7465              jz 0xda77
000FDA12  7473              jz 0xda87
000FDA14  206665            and [bp+0x65],ah
000FDA17  6A6C              push byte +0x6c
000FDA19  2900              sub [bx+si],ax
000FDA1B  56                push si
000FDA1C  656E              gs outsb
000FDA1E  7420              jz 0xda40
000FDA20  657420            gs jz 0xda43
000FDA23  6F                outsw
000FDA24  6A65              push byte +0x65
000FDA26  626C69            bound bp,[si+0x69]
000FDA29  6B2021            imul sp,[bx+si],byte +0x21
000FDA2C  0002              add [bp+si],al
000FDA2E  0400              add al,0x0
000FDA30  0205              add al,[di]
000FDA32  004D61            add [di+0x61],cl
000FDA35  7274              jc 0xdaab
000FDA37  7300              jnc 0xda39
000FDA39  0209              add cl,[bx+di]
000FDA3B  004D61            add [di+0x61],cl
000FDA3E  6A00              push byte +0x0
000FDA40  02060002          add al,[0x200]
000FDA44  07                pop es
000FDA45  0002              add [bp+si],al
000FDA47  0A00              or al,[bx+si]
000FDA49  020B              add cl,[bp+di]
000FDA4B  0002              add [bp+si],al
000FDA4D  0C00              or al,0x0
000FDA4F  020D              add cl,[di]
000FDA51  0002              add [bp+si],al
000FDA53  0E                push cs
000FDA54  0011              add [bx+di],dl
000FDA56  3A12              cmp dl,[bp+si]
000FDA58  206465            and [si+0x65],ah
000FDA5B  6E                outsb
000FDA5C  2013              and [bp+di],dl
000FDA5E  200F              and [bx],cl
000FDA60  2014              and [si],dl
000FDA62  0020              add [bx+si],ah
000FDA64  6B6F6E74          imul bp,[bx+0x6e],byte +0x74
000FDA68  726F              jc 0xdad9
000FDA6A  6C                insb
000FDA6B  20656E            and [di+0x6e],ah
000FDA6E  686564            push word 0x6465
000FDA71  004665            add [bp+0x65],al
000FDA74  6A6C              push byte +0x6c
000FDA76  206920            and [bx+di+0x20],ch
000FDA79  00736B            add [bp+di+0x6b],dh
000FDA7C  61                popa
000FDA7D  65726D            gs jc 0xdaed
000FDA80  008A0203          add [bp+si+0x302],cl
000FDA84  005C44            add [si+0x44],bl
000FDA87  65726E            gs jc 0xdaf8
000FDA8A  6965722061        imul sp,[di+0x72],word 0x6120
000FDA8F  7272              jc 0xdb03
000FDA91  1B887420          sbb cx,[bx+si+0x2074]
000FDA95  1B85208A          sbb ax,[di-0x75e0]
000FDA99  5C                pop sp
000FDA9A  07                pop es
000FDA9B  0002              add [bp+si],al
000FDA9D  035C56            add bx,[si+0x56]
000FDAA0  657569            gs jnz 0xdb0c
000FDAA3  6C                insb
000FDAA4  6C                insb
000FDAA5  657A20            gs jpe 0xdac8
000FDAA8  646F              fs outsw
000FDAAA  6E                outsb
000FDAAB  6E                outsb
000FDAAC  657220            gs jc 0xdacf
000FDAAF  6C                insb
000FDAB0  61                popa
000FDAB1  206461            and [si+0x61],ah
000FDAB4  7465              jz 0xdb1b
000FDAB6  206574            and [di+0x74],ah
000FDAB9  206C27            and [si+0x27],ch
000FDABC  686575            push word 0x7565
000FDABF  7265              jc 0xdb26
000FDAC1  5C                pop sp
000FDAC2  53                push bx
000FDAC3  69206E1B          imul sp,[bx+si],word 0x1b6e
000FDAC7  82                db 0x82
000FDAC8  636573            arpl [di+0x73],sp
000FDACB  7361              jnc 0xdb2e
000FDACD  6972652072        imul si,[bp+si+0x65],word 0x7220
000FDAD2  65641B826669      sbb ax,[fs:bp+si+0x6966]
000FDAD8  6E                outsb
000FDAD9  697373657A        imul si,[bp+di+0x73],word 0x7a65
000FDADE  206C65            and [si+0x65],ch
000FDAE1  7320              jnc 0xdb03
000FDAE3  6F                outsw
000FDAE4  7074              jo 0xdb5a
000FDAE6  696F6E735C        imul bp,[bx+0x6e],word 0x5c73
000FDAEB  07                pop es
000FDAEC  07                pop es
000FDAED  07                pop es
000FDAEE  005665            add [bp+0x65],dl
000FDAF1  7569              jnz 0xdb5c
000FDAF3  6C                insb
000FDAF4  6C                insb
000FDAF5  657A20            gs jpe 0xdb18
000FDAF8  6D                insw
000FDAF9  657474            gs jz 0xdb70
000FDAFC  7265              jc 0xdb63
000FDAFE  206465            and [si+0x65],ah
000FDB01  7320              jnc 0xdb23
000FDB03  7069              jo 0xdb6e
000FDB05  6C                insb
000FDB06  657320            gs jnc 0xdb29
000FDB09  6E                outsb
000FDB0A  657576            gs jnz 0xdb83
000FDB0D  65735C            gs jnc 0xdb6c
000FDB10  005C56            add [si+0x56],bl
000FDB13  1B827269          sbb ax,[bp+si+0x6972]
000FDB17  6669657A206C6520  imul esp,[di+0x7a],dword 0x20656c20
000FDB1F  636C61            arpl [si+0x61],bp
000FDB22  7669              jna 0xdb8d
000FDB24  657220            gs jc 0xdb47
000FDB27  657420            gs jz 0xdb4a
000FDB2A  6C                insb
000FDB2B  61                popa
000FDB2C  20736F            and [bp+di+0x6f],dh
000FDB2F  7572              jnz 0xdba3
000FDB31  6973005C4D        imul si,[bp+di+0x0],word 0x4d5c
000FDB36  657474            gs jz 0xdbad
000FDB39  657A20            gs jpe 0xdb5c
000FDB3C  756E              jnz 0xdbac
000FDB3E  65206469          and [gs:si+0x69],ah
000FDB42  7371              jnc 0xdbb5
000FDB44  7565              jnz 0xdbab
000FDB46  7474              jz 0xdbbc
000FDB48  65205379          and [gs:bp+di+0x79],dl
000FDB4C  7374              jnc 0xdbc2
000FDB4E  1B8A6D65          sbb cx,[bp+si+0x656d]
000FDB52  206461            and [si+0x61],ah
000FDB55  6E                outsb
000FDB56  7320              jnc 0xdb78
000FDB58  6C                insb
000FDB59  65204472          and [gs:si+0x72],al
000FDB5D  6976652041        imul si,[bp+0x65],word 0x4120
000FDB62  5C                pop sp
000FDB63  50                push ax
000FDB64  7569              jnz 0xdbcf
000FDB66  7320              jnc 0xdb88
000FDB68  7461              jz 0xdbcb
000FDB6A  7065              jo 0xdbd1
000FDB6C  7A20              jpe 0xdb8e
000FDB6E  756E              jnz 0xdbde
000FDB70  6520746F          and [gs:si+0x6f],dh
000FDB74  7563              jnz 0xdbd9
000FDB76  686520            push word 0x2065
000FDB79  7175              jno 0xdbf0
000FDB7B  656C              gs insb
000FDB7D  636F6E            arpl [bx+0x6e],bp
000FDB80  7175              jno 0xdbf7
000FDB82  65005C45          add [gs:si+0x45],bl
000FDB86  7272              jc 0xdbfa
000FDB88  657572            gs jnz 0xdbfd
000FDB8B  203A              and [bp+si],bh
000FDB8D  20746F            and [si+0x6f],dh
000FDB90  7461              jz 0xdbf3
000FDB92  6C                insb
000FDB93  20696E            and [bx+di+0x6e],ch
000FDB96  636F72            arpl [bx+0x72],bp
000FDB99  7265              jc 0xdc00
000FDB9B  637420            arpl [si+0x20],si
000FDB9E  6461              fs popa
000FDBA0  6E                outsb
000FDBA1  7320              jnc 0xdbc3
000FDBA3  6C                insb
000FDBA4  61                popa
000FDBA5  20524F            and [bp+si+0x4f],dl
000FDBA8  4D                dec bp
000FDBA9  206578            and [di+0x78],ah
000FDBAC  7465              jz 0xdc13
000FDBAE  726E              jc 0xdc1e
000FDBB0  65203A            and [gs:bp+si],bh
000FDBB3  5C                pop sp
000FDBB4  61                popa
000FDBB5  647265            fs jc 0xdc1d
000FDBB8  7373              jnc 0xdc2d
000FDBBA  6520656E          and [gs:di+0x6e],ah
000FDBBE  20524F            and [bp+si+0x4f],dl
000FDBC1  4D                dec bp
000FDBC2  203D              and [di],bh
000FDBC4  2010              and [bx+si],dl
000FDBC6  5C                pop sp
000FDBC7  004572            add [di+0x72],al
000FDBCA  7265              jc 0xdc31
000FDBCC  7572              jnz 0xdc40
000FDBCE  203A              and [bp+si],bh
000FDBD0  204465            and [si+0x65],al
000FDBD3  6661              popad
000FDBD5  696C6C616E        imul bp,[si+0x6c],word 0x6e61
000FDBDA  636520            arpl [di+0x20],sp
000FDBDD  008C0216          add [si+0x1602],cl
000FDBE1  45                inc bp
000FDBE2  008C5644          add [si+0x4456],cl
000FDBE6  55                push bp
000FDBE7  008B6427          add [bp+di+0x2764],cl
000FDBEB  696E746572        imul bp,[bp+0x74],word 0x7265
000FDBF0  7275              jc 0xdc67
000FDBF2  7074              jo 0xdc68
000FDBF4  696F6E7300        imul bp,[bx+0x6e],word 0x73
000FDBF9  8B444D            mov ax,[si+0x4d]
000FDBFC  41                inc cx
000FDBFD  008B6F75          add [bp+di+0x756f],cl
000FDC01  206475            and [si+0x75],ah
000FDC04  206C65            and [si+0x65],ch
000FDC07  637465            arpl [si+0x65],si
000FDC0A  7572              jnz 0xdc7e
000FDC0C  006475            add [si+0x75],ah
000FDC0F  206368            and [bp+di+0x68],ah
000FDC12  726F              jc 0xdc83
000FDC14  6E                outsb
000FDC15  6F                outsw
000FDC16  6D                insw
000FDC17  657472            gs jz 0xdc8c
000FDC1A  65006475          add [gs:si+0x75],ah
000FDC1E  207265            and [bp+si+0x65],dh
000FDC21  676973747265      imul si,[ebx+0x74],word 0x6572
000FDC27  206427            and [si+0x27],ah
000FDC2A  657461            gs jz 0xdc8e
000FDC2D  7420              jz 0xdc4f
000FDC2F  647520            fs jnz 0xdc52
000FDC32  7379              jnc 0xdcad
000FDC34  7374              jnc 0xdcaa
000FDC36  656D              gs insw
000FDC38  65006465          add [gs:si+0x65],ah
000FDC3C  206C27            and [si+0x27],ch
000FDC3F  686F72            push word 0x726f
000FDC42  6C                insb
000FDC43  6F                outsw
000FDC44  676500647520      add [dword gs:ebp+esi*2+0x20],ah
000FDC4A  636F6E            arpl [bx+0x6e],bp
000FDC4D  7472              jz 0xdcc1
000FDC4F  6F                outsw
000FDC50  6C                insb
000FDC51  657572            gs jnz 0xdcc6
000FDC54  205644            and [bp+0x44],dl
000FDC57  55                push bp
000FDC58  008D6427          add [di+0x2764],cl
000FDC5C  696D707269        imul bp,[di+0x70],word 0x6972
000FDC61  6D                insw
000FDC62  61                popa
000FDC63  6E                outsb
000FDC64  7465              jz 0xdccb
000FDC66  008D7365          add [di+0x6573],cl
000FDC6A  7269              jc 0xdcd5
000FDC6C  65006465          add [gs:si+0x65],ah
000FDC70  7320              jnc 0xdc92
000FDC72  7265              jc 0xdcd9
000FDC74  676973747265      imul si,[ebx+0x74],word 0x6572
000FDC7A  7320              jnc 0xdc9c
000FDC7C  636F6F            arpl [bx+0x6f],bp
000FDC7F  7264              jc 0xdce5
000FDC81  6F                outsw
000FDC82  6E                outsb
000FDC83  6E                outsb
000FDC84  65657320          gs jnc 0xdca8
000FDC88  736F              jnc 0xdcf9
000FDC8A  7572              jnz 0xdcfe
000FDC8C  6973006465        imul si,[bp+di+0x0],word 0x6564
000FDC91  7320              jnc 0xdcb3
000FDC93  746F              jz 0xdd04
000FDC95  7461              jz 0xdcf8
000FDC97  6C                insb
000FDC98  6973617469        imul si,[bp+di+0x61],word 0x6974
000FDC9D  6F                outsw
000FDC9E  6E                outsb
000FDC9F  7320              jnc 0xdcc1
000FDCA1  52                push dx
000FDCA2  4F                dec di
000FDCA3  53                push bx
000FDCA4  004D65            add [di+0x65],cl
000FDCA7  6D                insw
000FDCA8  6F                outsw
000FDCA9  6972652028        imul si,[bp+si+0x65],word 0x2820
000FDCAE  657272            gs jc 0xdd23
000FDCB1  657572            gs jnz 0xdd26
000FDCB4  206465            and [si+0x65],ah
000FDCB7  207061            and [bx+si+0x61],dh
000FDCBA  7269              jc 0xdd25
000FDCBC  7465              jz 0xdd23
000FDCBE  2900              sub [bx+si],ax
000FDCC0  50                push ax
000FDCC1  61                popa
000FDCC2  7469              jz 0xdd2d
000FDCC4  656E              gs outsb
000FDCC6  7465              jz 0xdd2d
000FDCC8  7A00              jpe 0xdcca
000FDCCA  4A                dec dx
000FDCCB  61                popa
000FDCCC  6E                outsb
000FDCCD  7669              jna 0xdd38
000FDCCF  657200            gs jc 0xdcd2
000FDCD2  46                inc si
000FDCD3  1B827672          sbb ax,[bp+si+0x7276]
000FDCD7  696572004D        imul sp,[di+0x72],word 0x4d00
000FDCDC  61                popa
000FDCDD  7273              jc 0xdd52
000FDCDF  004176            add [bx+di+0x76],al
000FDCE2  7269              jc 0xdd4d
000FDCE4  6C                insb
000FDCE5  004D61            add [di+0x61],cl
000FDCE8  69004A75          imul ax,[bx+si],word 0x754a
000FDCEC  696E004A75        imul bp,[bp+0x0],word 0x754a
000FDCF1  696C6C6574        imul bp,[si+0x6c],word 0x7465
000FDCF6  00416F            add [bx+di+0x6f],al
000FDCF9  1B967400          sbb dx,[bp+0x74]
000FDCFD  53                push bx
000FDCFE  657074            gs jo 0xdd75
000FDD01  656D              gs insw
000FDD03  627265            bound si,[bp+si+0x65]
000FDD06  004F63            add [bx+0x63],cl
000FDD09  746F              jz 0xdd7a
000FDD0B  627265            bound si,[bp+si+0x65]
000FDD0E  004E6F            add [bp+0x6f],cl
000FDD11  7665              jna 0xdd78
000FDD13  6D                insw
000FDD14  627265            bound si,[bp+si+0x65]
000FDD17  00441B            add [si+0x1b],al
000FDD1A  82                db 0x82
000FDD1B  63656D            arpl [di+0x6d],sp
000FDD1E  627265            bound si,[bp+si+0x65]
000FDD21  0011              add [bx+di],dl
000FDD23  3A12              cmp dl,[bp+si]
000FDD25  206C65            and [si+0x65],ch
000FDD28  2013              and [bp+di],dl
000FDD2A  200F              and [bx],cl
000FDD2C  2014              and [si],dl
000FDD2E  006475            add [si+0x75],ah
000FDD31  20636F            and [bp+di+0x6f],ah
000FDD34  6E                outsb
000FDD35  7472              jz 0xdda9
000FDD37  6F                outsw
000FDD38  6C                insb
000FDD39  657572            gs jnz 0xddae
000FDD3C  2000              and [bx+si],al
000FDD3E  6465206C61        and [gs:si+0x61],ch
000FDD43  205241            and [bp+si+0x41],dl
000FDD46  4D                dec bp
000FDD47  2000              and [bx+si],al
000FDD49  6465206C61        and [gs:si+0x61],ch
000FDD4E  20736F            and [bp+di+0x6f],dh
000FDD51  7274              jc 0xddc7
000FDD53  696520008A        imul sp,[di+0x20],word 0x8a00
000FDD58  0203              add al,[bp+di]
000FDD5A  005C55            add [si+0x55],bl
000FDD5D  6C                insb
000FDD5E  7469              jz 0xddc9
000FDD60  6D                insw
000FDD61  6F                outsw
000FDD62  207573            and [di+0x73],dh
000FDD65  6F                outsw
000FDD66  20616C            and [bx+di+0x6c],ah
000FDD69  6C                insb
000FDD6A  65208A5C07        and [gs:bp+si+0x75c],cl
000FDD6F  0002              add [bp+si],al
000FDD71  035C41            add bx,[si+0x41]
000FDD74  6767696F726E61    imul bp,[edi+0x72],word 0x616e
000FDD7B  7265              jc 0xdde2
000FDD7D  206C61            and [si+0x61],ch
000FDD80  206461            and [si+0x61],ah
000FDD83  7461              jz 0xdde6
000FDD85  206520            and [di+0x20],ah
000FDD88  6C                insb
000FDD89  27                daa
000FDD8A  6F                outsw
000FDD8B  7261              jc 0xddee
000FDD8D  5C                pop sp
000FDD8E  44                inc sp
000FDD8F  6566696E69726520  imul ebp,[gs:bp+0x69],dword 0x6c206572
         -6C
000FDD98  65204F70          and [gs:bx+0x70],cl
000FDD9C  7A69              jpe 0xde07
000FDD9E  6F                outsw
000FDD9F  6E                outsb
000FDDA0  69205574          imul sp,[bx+si],word 0x7455
000FDDA4  656E              gs outsb
000FDDA6  7465              jz 0xde0d
000FDDA8  2028              and [bx+si],ch
000FDDAA  53                push bx
000FDDAB  65207269          and [gs:bp+si+0x69],dh
000FDDAF  636869            arpl [bx+si+0x69],bp
000FDDB2  657374            gs jnc 0xde29
000FDDB5  6F                outsw
000FDDB6  295C07            sub [si+0x7],bx
000FDDB9  07                pop es
000FDDBA  07                pop es
000FDDBB  004261            add [bp+si+0x61],al
000FDDBE  7474              jz 0xde34
000FDDC0  657269            gs jc 0xde2c
000FDDC3  65206461          and [gs:si+0x61],ah
000FDDC7  20736F            and [bp+di+0x6f],dh
000FDDCA  7374              jnc 0xde40
000FDDCC  6974756972        imul si,[si+0x75],word 0x7269
000FDDD1  655C              gs pop sp
000FDDD3  005C50            add [si+0x50],bl
000FDDD6  726F              jc 0xde47
000FDDD8  7661              jna 0xde3b
000FDDDA  7265              jc 0xde41
000FDDDC  206C61            and [si+0x61],ch
000FDDDF  207461            and [si+0x61],dh
000FDDE2  7374              jnc 0xde58
000FDDE4  6965726120        imul sp,[di+0x72],word 0x2061
000FDDE9  6520696C          and [gs:bx+di+0x6c],ch
000FDDED  206D6F            and [di+0x6f],ch
000FDDF0  7573              jnz 0xde65
000FDDF2  65005C49          add [gs:si+0x49],bl
000FDDF6  6E                outsb
000FDDF7  7365              jnc 0xde5e
000FDDF9  7269              jc 0xde64
000FDDFB  7265              jc 0xde62
000FDDFD  20756E            and [di+0x6e],dh
000FDE00  206469            and [si+0x69],ah
000FDE03  7363              jnc 0xde68
000FDE05  6F                outsw
000FDE06  206469            and [si+0x69],ah
000FDE09  205349            and [bp+di+0x49],dl
000FDE0C  53                push bx
000FDE0D  54                push sp
000FDE0E  45                inc bp
000FDE0F  4D                dec bp
000FDE10  41                inc cx
000FDE11  206E65            and [bp+0x65],ch
000FDE14  6C                insb
000FDE15  204472            and [si+0x72],al
000FDE18  6976652041        imul si,[bp+0x65],word 0x4120
000FDE1D  5C                pop sp
000FDE1E  50                push ax
000FDE1F  6F                outsw
000FDE20  69207072          imul sp,[bx+si],word 0x7270
000FDE24  656D              gs insw
000FDE26  657265            gs jc 0xde8e
000FDE29  20756E            and [di+0x6e],dh
000FDE2C  207461            and [si+0x61],dh
000FDE2F  7374              jnc 0xdea5
000FDE31  6F                outsw
000FDE32  005C45            add [si+0x45],bl
000FDE35  7272              jc 0xdea9
000FDE37  6F                outsw
000FDE38  7265              jc 0xde9f
000FDE3A  3A20              cmp ah,[bx+si]
000FDE3C  7365              jnc 0xdea3
000FDE3E  676E              a32 outsb
000FDE40  61                popa
000FDE41  6C                insb
000FDE42  65206572          and [gs:di+0x72],ah
000FDE46  7261              jc 0xdea9
000FDE48  746F              jz 0xdeb9
000FDE4A  206461            and [si+0x61],ah
000FDE4D  6C                insb
000FDE4E  6C                insb
000FDE4F  61                popa
000FDE50  20524F            and [bp+si+0x4f],dl
000FDE53  4D                dec bp
000FDE54  204573            and [di+0x73],al
000FDE57  7465              jz 0xdebe
000FDE59  726E              jc 0xdec9
000FDE5B  61                popa
000FDE5C  3A5C69            cmp bl,[si+0x69]
000FDE5F  6E                outsb
000FDE60  646972697A7A      imul si,[fs:bp+si+0x69],word 0x7a7a
000FDE66  6F                outsw
000FDE67  20524F            and [bp+si+0x4f],dl
000FDE6A  4D                dec bp
000FDE6B  203D              and [di],bh
000FDE6D  2010              and [bx+si],dl
000FDE6F  5C                pop sp
000FDE70  004572            add [di+0x72],al
000FDE73  726F              jc 0xdee4
000FDE75  7265              jc 0xdedc
000FDE77  3A20              cmp ah,[bx+si]
000FDE79  005241            add [bp+si+0x41],dl
000FDE7C  4D                dec bp
000FDE7D  8D8C6100          lea cx,[si+0x61]
000FDE81  52                push dx
000FDE82  41                inc cx
000FDE83  4D                dec bp
000FDE84  207669            and [bp+0x69],dh
000FDE87  64656F            gs outsw
000FDE8A  8C6100            mov [bx+di+0x0],fs
000FDE8D  8B696E            mov bp,[bx+di+0x6e]
000FDE90  7465              jz 0xdef7
000FDE92  7272              jc 0xdf06
000FDE94  757A              jnz 0xdf10
000FDE96  696F6E698C        imul bp,[bx+0x6e],word 0x8c69
000FDE9B  6F                outsw
000FDE9C  008B6469          add [bp+di+0x6964],cl
000FDEA0  206163            and [bx+di+0x63],ah
000FDEA3  636573            arpl [di+0x73],sp
000FDEA6  736F              jnc 0xdf17
000FDEA8  206469            and [si+0x69],ah
000FDEAB  7265              jc 0xdf12
000FDEAD  7474              jz 0xdf23
000FDEAF  6F                outsw
000FDEB0  20616C            and [bx+di+0x6c],ah
000FDEB3  6C                insb
000FDEB4  61                popa
000FDEB5  206D65            and [di+0x65],ch
000FDEB8  6D                insw
000FDEB9  6F                outsw
000FDEBA  7269              jc 0xdf25
000FDEBC  61                popa
000FDEBD  8C6F00            mov [bx+0x0],gs
000FDEC0  8B6465            mov sp,[si+0x65]
000FDEC3  6C                insb
000FDEC4  206469            and [si+0x69],ah
000FDEC7  7363              jnc 0xdf2c
000FDEC9  6F                outsw
000FDECA  206F20            and [bx+0x20],ch
000FDECD  647269            fs jc 0xdf39
000FDED0  7665              jna 0xdf37
000FDED2  8C6F00            mov [bx+0x0],gs
000FDED5  7465              jz 0xdf3c
000FDED7  6D                insw
000FDED8  706F              jo 0xdf49
000FDEDA  7269              jc 0xdf45
000FDEDC  7A7A              jpe 0xdf58
000FDEDE  61                popa
000FDEDF  746F              jz 0xdf50
000FDEE1  7265              jc 0xdf48
000FDEE3  8C6F00            mov [bx+0x0],gs
000FDEE6  7265              jc 0xdf4d
000FDEE8  67697374726F      imul si,[ebx+0x74],word 0x6f72
000FDEEE  206469            and [si+0x69],ah
000FDEF1  207374            and [bp+di+0x74],dh
000FDEF4  61                popa
000FDEF5  746F              jz 0xdf66
000FDEF7  206465            and [si+0x65],ah
000FDEFA  6C                insb
000FDEFB  205349            and [bp+di+0x49],dl
000FDEFE  53                push bx
000FDEFF  54                push sp
000FDF00  45                inc bp
000FDF01  4D                dec bp
000FDF02  41                inc cx
000FDF03  8C6F00            mov [bx+0x0],gs
000FDF06  636C6F            arpl [si+0x6f],bp
000FDF09  636B20            arpl [bp+di+0x20],bp
000FDF0C  696E207465        imul bp,[bp+0x20],word 0x6574
000FDF11  6D                insw
000FDF12  706F              jo 0xdf83
000FDF14  207265            and [bp+si+0x65],dh
000FDF17  61                popa
000FDF18  6C                insb
000FDF19  658C6F00          mov [gs:bx+0x0],gs
000FDF1D  8B6465            mov sp,[si+0x65]
000FDF20  6C                insb
000FDF21  207669            and [bp+0x69],dh
000FDF24  64656F            gs outsw
000FDF27  8C6F00            mov [bx+0x0],gs
000FDF2A  706F              jo 0xdf9b
000FDF2C  7274              jc 0xdfa2
000FDF2E  61                popa
000FDF2F  207374            and [bp+di+0x74],dh
000FDF32  61                popa
000FDF33  6D                insw
000FDF34  7061              jo 0xdf97
000FDF36  6E                outsb
000FDF37  7465              jz 0xdf9e
000FDF39  8D8C6100          lea cx,[si+0x61]
000FDF3D  706F              jo 0xdfae
000FDF3F  7274              jc 0xdfb5
000FDF41  61                popa
000FDF42  207365            and [bp+di+0x65],dh
000FDF45  7269              jc 0xdfb0
000FDF47  61                popa
000FDF48  6C                insb
000FDF49  658D8C6100        lea cx,[gs:si+0x61]
000FDF4E  7265              jc 0xdfb5
000FDF50  676973747269      imul si,[ebx+0x74],word 0x6972
000FDF56  20636F            and [bp+di+0x6f],ah
000FDF59  6F                outsw
000FDF5A  7264              jc 0xdfc0
000FDF5C  696E617465        imul bp,[bp+0x61],word 0x6574
000FDF61  206D6F            and [di+0x6f],ch
000FDF64  7573              jnz 0xdfd9
000FDF66  658C6900          mov [gs:bx+di+0x0],gs
000FDF6A  7665              jna 0xdfd1
000FDF6C  7269              jc 0xdfd7
000FDF6E  66696361206C6574  imul esp,[bp+di+0x61],dword 0x74656c20
000FDF76  7475              jz 0xdfed
000FDF78  7261              jc 0xdfdb
000FDF7A  206465            and [si+0x65],ah
000FDF7D  6C                insb
000FDF7E  6C                insb
000FDF7F  61                popa
000FDF80  20524F            and [bp+si+0x4f],dl
000FDF83  53                push bx
000FDF84  206661            and [bp+0x61],ah
000FDF87  6C                insb
000FDF88  6C                insb
000FDF89  697461006D        imul si,[si+0x61],word 0x6d00
000FDF8E  656D              gs insw
000FDF90  6F                outsw
000FDF91  7269              jc 0xdffc
000FDF93  61                popa
000FDF94  8C6120            mov [bx+di+0x20],fs
000FDF97  286572            sub [di+0x72],ah
000FDF9A  726F              jc 0xe00b
000FDF9C  7265              jc 0xe003
000FDF9E  206469            and [si+0x69],ah
000FDFA1  207061            and [bx+si+0x61],dh
000FDFA4  7269              jc 0xe00f
000FDFA6  7461              jz 0xe009
000FDFA8  2900              sub [bx+si],ax
000FDFAA  50                push ax
000FDFAB  7265              jc 0xe012
000FDFAD  676F              a32 outsw
000FDFAF  206174            and [bx+di+0x74],ah
000FDFB2  7465              jz 0xe019
000FDFB4  6E                outsb
000FDFB5  64657265          gs jc 0xe01e
000FDFB9  004765            add [bx+0x65],al
000FDFBC  6E                outsb
000FDFBD  6E                outsb
000FDFBE  61                popa
000FDFBF  696F004665        imul bp,[bx+0x0],word 0x6546
000FDFC4  626272            bound sp,[bp+si+0x72]
000FDFC7  61                popa
000FDFC8  696F004D61        imul bp,[bx+0x0],word 0x614d
000FDFCD  727A              jc 0xe049
000FDFCF  6F                outsw
000FDFD0  0002              add [bp+si],al
000FDFD2  096500            or [di+0x0],sp
000FDFD5  4D                dec bp
000FDFD6  61                popa
000FDFD7  6767696F004769    imul bp,[edi+0x0],word 0x6947
000FDFDE  7567              jnz 0xe047
000FDFE0  6E                outsb
000FDFE1  6F                outsw
000FDFE2  004C75            add [si+0x75],cl
000FDFE5  676C              a32 insb
000FDFE7  696F004167        imul bp,[bx+0x0],word 0x6741
000FDFEC  6F                outsw
000FDFED  7374              jnc 0xe063
000FDFEF  6F                outsw
000FDFF0  005365            add [bp+di+0x65],dl
000FDFF3  7474              jz 0xe069
000FDFF5  656D              gs insw
000FDFF7  627265            bound si,[bp+si+0x65]
000FDFFA  004F74            add [bx+0x74],cl
000FDFFD  746F              jz 0xe06e
000FDFFF  627265            bound si,[bp+si+0x65]
000FE002  004E6F            add [bp+0x6f],cl
000FE005  7665              jna 0xe06c
000FE007  6D                insw
000FE008  627265            bound si,[bp+si+0x65]
000FE00B  004469            add [si+0x69],al
000FE00E  63656D            arpl [di+0x6d],sp
000FE011  627265            bound si,[bp+si+0x65]
000FE014  0011              add [bx+di],dl
000FE016  3A12              cmp dl,[bp+si]
000FE018  206465            and [si+0x65],ah
000FE01B  6C                insb
000FE01C  2013              and [bp+di],dl
000FE01E  200F              and [bx],cl
000FE020  2014              and [si],dl
000FE022  00636F            add [bp+di+0x6f],ah
000FE025  6E                outsb
000FE026  7472              jz 0xe09a
000FE028  6F                outsw
000FE029  6C                insb
000FE02A  6C                insb
000FE02B  6F                outsw
000FE02C  7265              jc 0xe093
000FE02E  2000              and [bx+si],al
000FE030  206469            and [si+0x69],ah
000FE033  66657474          gs o32 jz 0xe0ab
000FE037  6F                outsw
000FE038  7300              jnc 0xe03a
000FE03A  206469            and [si+0x69],ah
000FE03D  205349            and [bp+di+0x49],dl
000FE040  53                push bx
000FE041  54                push sp
000FE042  45                inc bp
000FE043  4D                dec bp
000FE044  41                inc cx
000FE045  004942            add [bx+di+0x42],cl
000FE048  4D                dec bp
000FE049  55                push bp
000FE04A  53                push bx
000FE04B  204E4F            and [bp+0x4f],cl
000FE04E  4E                dec si
000FE04F  204341            and [bp+di+0x41],al
000FE052  52                push dx
000FE053  42                inc dx
000FE054  4F                dec di
000FE055  52                push dx
000FE056  55                push bp
000FE057  4E                dec si
000FE058  44                inc sp
000FE059  55                push bp
000FE05A  4D                dec bp
000FE05B  EAC90000FC        jmp 0xfc00:0xc9
000FE060  8A02              mov al,[bp+si]
000FE062  0300              add ax,[bx+si]
000FE064  5C                pop sp
000FE065  53                push bx
000FE066  656E              gs outsb
000FE068  61                popa
000FE069  7374              jnc 0xe0df
000FE06B  20616E            and [bx+di+0x6e],ah
000FE06E  761B              jna 0xe08b
000FE070  846E64            test [bp+0x64],ch
000FE073  208A5C07          and [bp+si+0x75c],cl
000FE077  0002              add [bp+si],al
000FE079  035C56            add bx,[si+0x56]
000FE07C  2E672E20731B      and [cs:ebx+0x1b],dh
000FE082  847474            test [si+0x74],dh
000FE085  206461            and [si+0x61],ah
000FE088  7475              jz 0xe0ff
000FE08A  6D                insw
000FE08B  206F63            and [bx+0x63],ch
000FE08E  682074            push word 0x7420
000FE091  69645C562E        imul sp,[si+0x5c],word 0x2e56
000FE096  672E207374        and [cs:ebx+0x74],dh
000FE09B  1B846C6C          sbb ax,[si+0x6c6c]
000FE09F  20696E            and [bx+di+0x6e],ch
000FE0A2  20616E            and [bx+di+0x6e],ah
000FE0A5  761B              jna 0xe0c2
000FE0A7  846E64            test [bp+0x64],ch
000FE0AA  61                popa
000FE0AB  7276              jc 0xe123
000FE0AD  1B847264          sbb ax,[si+0x6472]
000FE0B1  656E              gs outsb
000FE0B3  2028              and [bx+si],ch
000FE0B5  7669              jna 0xe120
000FE0B7  64206265          and [fs:bp+si+0x65],ah
000FE0BB  686F76            push word 0x766f
000FE0BE  295C07            sub [si+0x7],bx
000FE0C1  07                pop es
000FE0C2  07                pop es
000FE0C3  00562E            add [bp+0x2e],dl
000FE0C6  672E20616E        and [cs:ecx+0x6e],ah
000FE0CB  736C              jnc 0xe139
000FE0CD  7574              jnz 0xe143
000FE0CF  206E79            and [bp+0x79],ch
000FE0D2  61                popa
000FE0D3  206261            and [bp+si+0x61],ah
000FE0D6  7474              jz 0xe14c
000FE0D8  657269            gs jc 0xe144
000FE0DB  65725C            gs jc 0xe13a
000FE0DE  005C4B            add [si+0x4b],bl
000FE0E1  6F                outsw
000FE0E2  6E                outsb
000FE0E3  7472              jz 0xe157
000FE0E5  6F                outsw
000FE0E6  6C                insb
000FE0E7  6C                insb
000FE0E8  657261            gs jc 0xe14c
000FE0EB  207461            and [si+0x61],dh
000FE0EE  6E                outsb
000FE0EF  67656E            gs a32 outsb
000FE0F2  7462              jz 0xe156
000FE0F4  6F                outsw
000FE0F5  7264              jc 0xe15b
000FE0F7  206F63            and [bx+0x63],ch
000FE0FA  68206D            push word 0x6d20
000FE0FD  7573              jnz 0xe172
000FE0FF  005C53            add [si+0x53],bl
000FE102  1B847474          sbb ax,[si+0x7474]
000FE106  206920            and [bx+di+0x20],ch
000FE109  656E              gs outsb
000FE10B  205359            and [bp+di+0x59],dl
000FE10E  53                push bx
000FE10F  54                push sp
000FE110  45                inc bp
000FE111  4D                dec bp
000FE112  44                inc sp
000FE113  49                dec cx
000FE114  53                push bx
000FE115  4B                dec bx
000FE116  45                inc bp
000FE117  54                push sp
000FE118  54                push sp
000FE119  206920            and [bx+di+0x20],ch
000FE11C  656E              gs outsb
000FE11E  686574            push word 0x7465
000FE121  20415C            and [bx+di+0x5c],al
000FE124  54                push sp
000FE125  7279              jc 0xe1a0
000FE127  636B20            arpl [bp+di+0x20],bp
000FE12A  641B847265        sbb ax,[fs:si+0x6572]
000FE12F  667465            o32 jz 0xe197
000FE132  7220              jc 0xe154
000FE134  6E                outsb
000FE135  657220            gs jc 0xe158
000FE138  656E              gs outsb
000FE13A  207461            and [si+0x61],dh
000FE13D  6E                outsb
000FE13E  67656E            gs a32 outsb
000FE141  7400              jz 0xe143
000FE143  5C                pop sp
000FE144  46                inc si
000FE145  656C              gs insb
000FE147  3A02              cmp al,[bp+si]
000FE149  1B20              sbb sp,[bx+si]
000FE14B  52                push dx
000FE14C  4F                dec di
000FE14D  4D                dec bp
000FE14E  208B7375          and [bp+di+0x7573],cl
000FE152  6D                insw
000FE153  6D                insw
000FE154  61                popa
000FE155  206665            and [bp+0x65],ah
000FE158  6C                insb
000FE159  61                popa
000FE15A  6B746967          imul si,[si+0x69],byte +0x67
000FE15E  3A5C52            cmp bl,[si+0x52]
000FE161  4F                dec di
000FE162  4D                dec bp
000FE163  206164            and [bx+di+0x64],ah
000FE166  7265              jc 0xe1cd
000FE168  7373              jnc 0xe1dd
000FE16A  203D              and [di],bh
000FE16C  2010              and [bx+si],dl
000FE16E  5C                pop sp
000FE16F  004665            add [bp+0x65],al
000FE172  6C                insb
000FE173  3A20              cmp ah,[bx+si]
000FE175  46                inc si
000FE176  656C              gs insb
000FE178  61                popa
000FE179  6B746967          imul si,[si+0x69],byte +0x67
000FE17D  0020              add [bx+si],ah
000FE17F  02162052          add dl,[0x5220]
000FE183  41                inc cx
000FE184  4D                dec bp
000FE185  0020              add [bx+si],ah
000FE187  56                push si
000FE188  44                inc sp
000FE189  55                push bp
000FE18A  205241            and [bp+si+0x41],dl
000FE18D  4D                dec bp
000FE18E  0020              add [bx+si],ah
000FE190  61                popa
000FE191  7662              jna 0xe1f5
000FE193  726F              jc 0xe204
000FE195  7474              jz 0xe20b
000FE197  738B              jnc 0xe124
000FE199  0020              add [bx+si],ah
000FE19B  8B20              mov sp,[bx+si]
000FE19D  61                popa
000FE19E  7620              jna 0xe1c0
000FE1A0  646972656B74      imul si,[fs:bp+si+0x65],word 0x746b
000FE1A6  6D                insw
000FE1A7  696E6E6573        imul bp,[bp+0x6e],word 0x7365
000FE1AC  61                popa
000FE1AD  746B              jz 0xe21a
000FE1AF  6F                outsw
000FE1B0  6D                insw
000FE1B1  7374              jnc 0xe227
000FE1B3  0020              add [bx+si],ah
000FE1B5  6469736B8B20      imul si,[fs:bp+di+0x6b],word 0x208b
000FE1BB  656C              gs insb
000FE1BD  6C                insb
000FE1BE  657220            gs jc 0xe1e1
000FE1C1  736B              jnc 0xe22e
000FE1C3  6976656E68        imul si,[bp+0x65],word 0x686e
000FE1C8  657400            gs jz 0xe1cb
000FE1CB  2002              and [bp+si],al
000FE1CD  116C02            adc [si+0x2],bp
000FE1D0  1200              adc al,[bx+si]
000FE1D2  0213              add dl,[bp+di]
000FE1D4  0214              add dl,[si]
000FE1D6  0215              add dl,[di]
000FE1D8  0020              add [bx+si],ah
000FE1DA  0217              add dl,[bx]
000FE1DC  7469              jz 0xe247
000FE1DE  64736B            fs jnc 0xe24c
000FE1E1  6C                insb
000FE1E2  6F                outsw
000FE1E3  636B61            arpl [bp+di+0x61],bp
000FE1E6  0020              add [bx+si],ah
000FE1E8  56                push si
000FE1E9  44                inc sp
000FE1EA  55                push bp
000FE1EB  208B0002          and [bp+di+0x200],cl
000FE1EF  1302              adc ax,[bp+si]
000FE1F1  18706F            sbb [bx+si+0x6f],dh
000FE1F4  7274              jc 0xe26a
000FE1F6  0002              add [bp+si],al
000FE1F8  137365            adc si,[bp+di+0x65]
000FE1FB  7269              jc 0xe266
000FE1FD  656C              gs insb
000FE1FF  6C                insb
000FE200  706F              jo 0xe271
000FE202  7274              jc 0xe278
000FE204  007420            add [si+0x20],dh
000FE207  6D                insw
000FE208  7573              jnz 0xe27d
000FE20A  6B6F6F72          imul bp,[bx+0x6f],byte +0x72
000FE20E  64696E617402      imul bp,[fs:bp+0x61],word 0x274
000FE214  150020            adc ax,0x2000
000FE217  52                push dx
000FE218  4F                dec di
000FE219  53                push bx
000FE21A  208B7375          and [bp+di+0x7573],cl
000FE21E  6D                insw
000FE21F  6D                insw
000FE220  61                popa
000FE221  007420            add [si+0x20],dh
000FE224  6D                insw
000FE225  696E6E6520        imul bp,[bp+0x6e],word 0x2065
000FE22A  287061            sub [bx+si+0x61],dh
000FE22D  7269              jc 0xe298
000FE22F  7465              jz 0xe296
000FE231  7473              jz 0xe2a6
000FE233  66656C            gs o32 insb
000FE236  2900              sub [bx+si],ax
000FE238  56                push si
000FE239  2E672E207661      and [cs:esi+0x61],dh
000FE23F  6E                outsb
000FE240  7461              jz 0xe2a3
000FE242  006A61            add [bp+si+0x61],ch
000FE245  6E                outsb
000FE246  7561              jnz 0xe2a9
000FE248  7269              jc 0xe2b3
000FE24A  006665            add [bp+0x65],ah
000FE24D  627275            bound si,[bp+si+0x75]
000FE250  61                popa
000FE251  7269              jc 0xe2bc
000FE253  006D61            add [di+0x61],ch
000FE256  7273              jc 0xe2cb
000FE258  006170            add [bx+di+0x70],ah
000FE25B  7269              jc 0xe2c6
000FE25D  6C                insb
000FE25E  006D61            add [di+0x61],ch
000FE261  6A00              push byte +0x0
000FE263  6A75              push byte +0x75
000FE265  6E                outsb
000FE266  69006A75          imul ax,[bx+si],word 0x756a
000FE26A  6C                insb
000FE26B  69006175          imul ax,[bx+si],word 0x7561
000FE26F  677573            jnz 0xe2e5
000FE272  7469              jz 0xe2dd
000FE274  007365            add [bp+di+0x65],dh
000FE277  7074              jo 0xe2ed
000FE279  656D              gs insw
000FE27B  626572            bound sp,[di+0x72]
000FE27E  006F6B            add [bx+0x6b],ch
000FE281  746F              jz 0xe2f2
000FE283  626572            bound sp,[di+0x72]
000FE286  006E6F            add [bp+0x6f],ch
000FE289  7665              jna 0xe2f0
000FE28B  6D                insw
000FE28C  626572            bound sp,[di+0x72]
000FE28F  006465            add [si+0x65],ah
000FE292  63656D            arpl [di+0x6d],sp
000FE295  626572            bound sp,[di+0x72]
000FE298  0011              add [bx+di],dl
000FE29A  3A12              cmp dl,[bp+si]
000FE29C  206465            and [si+0x65],ah
000FE29F  6E                outsb
000FE2A0  2013              and [bp+di],dl
000FE2A2  200F              and [bx],cl
000FE2A4  2014              and [si],dl
000FE2A6  006B6F            add [bp+di+0x6f],ch
000FE2A9  6E                outsb
000FE2AA  7472              jz 0xe31e
000FE2AC  6F                outsw
000FE2AD  6C                insb
000FE2AE  6C                insb
000FE2AF  0000              add [bx+si],al
000FE2B1  0000              add [bx+si],al
000FE2B3  0000              add [bx+si],al
000FE2B5  0000              add [bx+si],al
000FE2B7  0000              add [bx+si],al
000FE2B9  0000              add [bx+si],al
000FE2BB  0000              add [bx+si],al
000FE2BD  0000              add [bx+si],al
000FE2BF  0000              add [bx+si],al
000FE2C1  0000              add [bx+si],al
000FE2C3  EABF1700FC        jmp 0xfc00:0x17bf
000FE2C8  0201              add al,[bx+di]
000FE2CA  56                push si
000FE2CB  0202              add al,[bp+si]
000FE2CD  00416D            add [bx+di+0x6d],al
000FE2D0  7374              jnc 0xe346
000FE2D2  7261              jc 0xe335
000FE2D4  64205043          and [fs:bx+si+0x43],dl
000FE2D8  2015              and [di],dl
000FE2DA  4B                dec bx
000FE2DB  2028              and [bx+si],ch
000FE2DD  0033              add [bp+di],dh
000FE2DF  2E3129            xor [cs:bx+di],bp
000FE2E2  2020              and [bx+si],ah
000FE2E4  005C28            add [si+0x28],bl
000FE2E7  6329              arpl [bx+di],bp
000FE2E9  3139              xor [bx+di],di
000FE2EB  3838              cmp [bx+si],bh
000FE2ED  20416D            and [bx+di+0x6d],al
000FE2F0  7374              jnc 0xe366
000FE2F2  7261              jc 0xe355
000FE2F4  6420706C          and [fs:bx+si+0x6c],dh
000FE2F8  635C00            arpl [si+0x0],bx
000FE2FB  4A                dec dx
000FE2FC  61                popa
000FE2FD  6E                outsb
000FE2FE  7561              jnz 0xe361
000FE300  7200              jc 0xe302
000FE302  46                inc si
000FE303  65627275          bound si,[gs:bp+si+0x75]
000FE307  61                popa
000FE308  7200              jc 0xe30a
000FE30A  4A                dec dx
000FE30B  756E              jnz 0xe37b
000FE30D  69004A75          imul ax,[bx+si],word 0x754a
000FE311  6C                insb
000FE312  69004F6B          imul ax,[bx+si],word 0x6b4f
000FE316  746F              jz 0xe387
000FE318  626572            bound sp,[di+0x72]
000FE31B  004170            add [bx+di+0x70],al
000FE31E  7269              jc 0xe389
000FE320  6C                insb
000FE321  004175            add [bx+di+0x75],al
000FE324  677573            jnz 0xe39a
000FE327  7400              jz 0xe329
000FE329  53                push bx
000FE32A  657074            gs jo 0xe3a1
000FE32D  020F              add cl,[bx]
000FE32F  004F6B            add [bx+0x6b],cl
000FE332  746F              jz 0xe3a3
000FE334  626572            bound sp,[di+0x72]
000FE337  004E6F            add [bp+0x6f],cl
000FE33A  7602              jna 0xe33e
000FE33C  0F004465          sldt [si+0x65]
000FE340  6302              arpl [bp+si],ax
000FE342  0F00656D          verr [di+0x6d]
000FE346  626572            bound sp,[di+0x72]
000FE349  004572            add [di+0x72],al
000FE34C  726F              jc 0xe3bd
000FE34E  7200              jc 0xe350
000FE350  696E746572        imul bp,[bp+0x74],word 0x7265
000FE355  7661              jna 0xe3b8
000FE357  6C                insb
000FE358  007469            add [si+0x69],dh
000FE35B  6D                insw
000FE35C  657200            gs jc 0xe35f
000FE35F  207379            and [bp+di+0x79],dh
000FE362  7374              jnc 0xe3d8
000FE364  656D              gs insw
000FE366  007374            add [bp+di+0x74],dh
000FE369  61                popa
000FE36A  7475              jz 0xe3e1
000FE36C  7300              jnc 0xe36e
000FE36E  7265              jc 0xe3d5
000FE370  676973746572      imul si,[ebx+0x74],word 0x7265
000FE376  005359            add [bp+di+0x59],dl
000FE379  53                push bx
000FE37A  54                push sp
000FE37B  45                inc bp
000FE37C  4D                dec bp
000FE37D  007265            add [bp+si+0x65],dh
000FE380  61                popa
000FE381  6C                insb
000FE382  007072            add [bx+si+0x72],dh
000FE385  696E746572        imul bp,[bp+0x74],word 0x7265
000FE38A  0020              add [bx+si],ah
000FE38C  7365              jnc 0xe3f3
000FE38E  7269              jc 0xe3f9
000FE390  656C              gs insb
000FE392  0020              add [bx+si],ah
000FE394  706F              jo 0xe405
000FE396  7274              jc 0xe40c
000FE398  0020              add [bx+si],ah
000FE39A  45                inc bp
000FE39B  7874              js 0xe411
000FE39D  65726E            gs jc 0xe40e
000FE3A0  006469            add [si+0x69],ah
000FE3A3  736B              jnc 0xe410
000FE3A5  2000              and [bx+si],al
000FE3A7  20524F            and [bp+si+0x4f],dl
000FE3AA  4D                dec bp
000FE3AB  206368            and [bp+di+0x68],ah
000FE3AE  65636B73          arpl [gs:bp+di+0x73],bp
000FE3B2  756D              jnz 0xe421
000FE3B4  004469            add [si+0x69],al
000FE3B7  7265              jc 0xe41e
000FE3B9  637420            arpl [si+0x20],si
000FE3BC  4D                dec bp
000FE3BD  656D              gs insw
000FE3BF  6F                outsw
000FE3C0  7279              jc 0xe43b
000FE3C2  204163            and [bx+di+0x63],al
000FE3C5  636573            arpl [di+0x73],sp
000FE3C8  7300              jnc 0xe3ca
000FE3CA  20436F            and [bp+di+0x6f],al
000FE3CD  6E                outsb
000FE3CE  7472              jz 0xe442
000FE3D0  6F                outsw
000FE3D1  6C                insb
000FE3D2  6C                insb
000FE3D3  657200            gs jc 0xe3d6
000FE3D6  49                dec cx
000FE3D7  6E                outsb
000FE3D8  7465              jz 0xe43f
000FE3DA  7272              jc 0xe44e
000FE3DC  7570              jnz 0xe44e
000FE3DE  7400              jz 0xe3e0
000FE3E0  0201              add al,[bx+di]
000FE3E2  7302              jnc 0xe3e6
000FE3E4  0200              add al,[bx+si]
000FE3E6  113A              adc [bp+si],di
000FE3E8  1220              adc ah,[bx+si]
000FE3EA  2013              and [bp+di],dl
000FE3EC  200F              and [bx],cl
000FE3EE  2014              and [si],dl
000FE3F0  0203              add al,[bp+di]
000FE3F2  005C55            add [si+0x55],bl
000FE3F5  7469              jz 0xe460
000FE3F7  6C                insb
000FE3F8  697A61646F        imul di,[bp+si+0x61],word 0x6f64
000FE3FD  20706F            and [bx+si+0x6f],dh
000FE400  7220              jc 0xe422
000FE402  1BA36C74          sbb sp,[bp+di+0x746c]
000FE406  696D612076        imul bp,[di+0x61],word 0x7620
000FE40B  657A20            gs jpe 0xe42e
000FE40E  61                popa
000FE40F  206C61            and [si+0x61],ch
000FE412  7320              jnc 0xe434
000FE414  113A              adc [bp+si],di
000FE416  1220              adc ah,[bx+si]
000FE418  656C              gs insb
000FE41A  2013              and [bp+di],dl
000FE41C  200F              and [bx],cl
000FE41E  2014              and [si],dl
000FE420  5C                pop sp
000FE421  07                pop es
000FE422  0002              add [bp+si],al
000FE424  035C92            add bx,[si-0x6e]
000FE427  93                xchg ax,bx
000FE428  6665636861        o32 arpl [gs:bx+si+0x61],bp
000FE42D  207920            and [bx+di+0x20],bh
000FE430  686F72            push word 0x726f
000FE433  61                popa
000FE434  5C                pop sp
000FE435  92                xchg ax,dx
000FE436  93                xchg ax,bx
000FE437  6F                outsw
000FE438  7063              jo 0xe49d
000FE43A  696F6E6573        imul bp,[bx+0x6e],word 0x7365
000FE43F  8E7573            mov segr6,[di+0x73]
000FE442  7561              jnz 0xe4a5
000FE444  7269              jc 0xe4af
000FE446  6F                outsw
000FE447  2028              and [bx+si],ch
000FE449  7369              jnc 0xe4b4
000FE44B  206573            and [di+0x73],ah
000FE44E  206E65            and [bp+0x65],ch
000FE451  636573            arpl [di+0x73],sp
000FE454  61                popa
000FE455  7269              jc 0xe4c0
000FE457  6F                outsw
000FE458  295C07            sub [si+0x7],bx
000FE45B  07                pop es
000FE45C  07                pop es
000FE45D  0092706F          add [bp+si+0x6f70],dl
000FE461  6E                outsb
000FE462  6761              a32 popa
000FE464  207069            and [bx+si+0x69],dh
000FE467  6C                insb
000FE468  657320            gs jnc 0xe48b
000FE46B  6E                outsb
000FE46C  7565              jnz 0xe4d3
000FE46E  7661              jna 0xe4d1
000FE470  735C              jnc 0xe4ce
000FE472  005C43            add [si+0x43],bl
000FE475  6F                outsw
000FE476  6D                insw
000FE477  7072              jo 0xe4eb
000FE479  7565              jnz 0xe4e0
000FE47B  626520            bound sp,[di+0x20]
000FE47E  656C              gs insb
000FE480  207465            and [si+0x65],dh
000FE483  636C61            arpl [si+0x61],bp
000FE486  646F              fs outsw
000FE488  207920            and [bx+di+0x20],bh
000FE48B  656C              gs insb
000FE48D  207261            and [bp+si+0x61],dh
000FE490  741B              jz 0xe4ad
000FE492  A26E00            mov [0x6e],al
000FE495  5C                pop sp
000FE496  49                dec cx
000FE497  6E                outsb
000FE498  7472              jz 0xe50c
000FE49A  6F                outsw
000FE49B  64757A            fs jnz 0xe518
000FE49E  636120            arpl [bx+di+0x20],sp
000FE4A1  756E              jnz 0xe511
000FE4A3  206469            and [si+0x69],ah
000FE4A6  7363              jnc 0xe50b
000FE4A8  6F                outsw
000FE4A9  8E7369            mov segr6,[bp+di+0x69]
000FE4AC  7374              jnc 0xe522
000FE4AE  656D              gs insw
000FE4B0  61                popa
000FE4B1  208C756E          and [si+0x6e75],cl
000FE4B5  6964616420        imul sp,[si+0x61],word 0x2064
000FE4BA  41                inc cx
000FE4BB  5C                pop sp
000FE4BC  7920              jns 0xe4de
000FE4BE  6C                insb
000FE4BF  7565              jnz 0xe526
000FE4C1  676F              a32 outsw
000FE4C3  207075            and [bx+si+0x75],dh
000FE4C6  6C                insb
000FE4C7  7365              jnc 0xe52e
000FE4C9  20756E            and [di+0x6e],dh
000FE4CC  61                popa
000FE4CD  207465            and [si+0x65],dh
000FE4D0  636C61            arpl [si+0x61],bp
000FE4D3  005C02            add [si+0x2],bl
000FE4D6  103A              adc [bp+si],bh
000FE4D8  207375            and [bp+di+0x75],dh
000FE4DB  6D                insw
000FE4DC  61                popa
000FE4DD  8E636F            mov fs,[bp+di+0x6f]
000FE4E0  6D                insw
000FE4E1  7072              jo 0xe555
000FE4E3  6F                outsw
000FE4E4  626163            bound sp,[bx+di+0x63]
000FE4E7  696F6E2069        imul bp,[bx+0x6e],word 0x6920
000FE4EC  6E                outsb
000FE4ED  636F72            arpl [bx+0x72],bp
000FE4F0  7265              jc 0xe557
000FE4F2  637461            arpl [si+0x61],si
000FE4F5  20656E            and [di+0x6e],ah
000FE4F8  20524F            and [bp+si+0x4f],dl
000FE4FB  4D                dec bp
000FE4FC  206578            and [di+0x78],ah
000FE4FF  7465              jz 0xe566
000FE501  726E              jc 0xe571
000FE503  61                popa
000FE504  3B20              cmp sp,[bx+si]
000FE506  646972656363      imul si,[fs:bp+si+0x65],word 0x6363
000FE50C  696F6E8E52        imul bp,[bx+0x6e],word 0x528e
000FE511  4F                dec di
000FE512  4D                dec bp
000FE513  203D              and [di],bh
000FE515  2010              and [bx+si],dl
000FE517  5C                pop sp
000FE518  0002              add [bp+si],al
000FE51A  103A              adc [bp+si],bh
000FE51C  206661            and [bp+0x61],ah
000FE51F  6C                insb
000FE520  6C                insb
000FE521  6F                outsw
000FE522  2000              and [bx+si],al
000FE524  8C5241            mov [bp+si+0x41],ss
000FE527  4D                dec bp
000FE528  8F00              pop word [bx+si]
000FE52A  8C5241            mov [bp+si+0x41],ss
000FE52D  4D                dec bp
000FE52E  8E8D5644          mov cs,[di+0x4456]
000FE532  55                push bp
000FE533  008B9169          add [bp+di+0x6991],cl
000FE537  6E                outsb
000FE538  7465              jz 0xe59f
000FE53A  7272              jc 0xe5ae
000FE53C  7570              jnz 0xe5ae
000FE53E  63696F            arpl [bx+di+0x6f],bp
000FE541  6E                outsb
000FE542  657300            gs jnc 0xe545
000FE545  8B916163          mov dx,[bx+di+0x6361]
000FE549  636573            arpl [di+0x73],sp
000FE54C  6F                outsw
000FE54D  206469            and [si+0x69],ah
000FE550  7265              jc 0xe5b7
000FE552  63746F            arpl [si+0x6f],si
000FE555  206120            and [bx+di+0x20],ah
000FE558  8D6D65            lea bp,[di+0x65]
000FE55B  6D                insw
000FE55C  6F                outsw
000FE55D  7269              jc 0xe5c8
000FE55F  61                popa
000FE560  008B9164          add [bp+di+0x6491],cl
000FE564  6973636F20        imul si,[bp+di+0x63],word 0x206f
000FE569  666C              o32 insb
000FE56B  657869            gs js 0xe5d7
000FE56E  626C65            bound bp,[si+0x65]
000FE571  206F20            and [bx+0x20],ch
000FE574  8C756E            mov [di+0x6e],segr6
000FE577  696461648E        imul sp,[si+0x61],word 0x8e64
000FE57C  646973636F00      imul si,[fs:bp+di+0x63],word 0x6f
000FE582  8B7465            mov si,[si+0x65]
000FE585  6D                insw
000FE586  706F              jo 0xe5f7
000FE588  7269              jc 0xe5f3
000FE58A  7A61              jpe 0xe5ed
000FE58C  646F              fs outsw
000FE58E  7220              jc 0xe5b0
000FE590  7072              jo 0xe604
000FE592  6F                outsw
000FE593  677261            jc 0xe5f7
000FE596  6D                insw
000FE597  61                popa
000FE598  626C65            bound bp,[si+0x65]
000FE59B  008B7265          add [bp+di+0x6572],cl
000FE59F  67697374726F      imul si,[ebx+0x74],word 0x6f72
000FE5A5  8E6573            mov fs,[di+0x73]
000FE5A8  7461              jz 0xe60b
000FE5AA  646F              fs outsw
000FE5AC  8F00              pop word [bx+si]
000FE5AE  8B7265            mov si,[bp+si+0x65]
000FE5B1  6C                insb
000FE5B2  6F                outsw
000FE5B3  6A8E              push byte -0x72
000FE5B5  7469              jz 0xe620
000FE5B7  656D              gs insw
000FE5B9  706F              jo 0xe62a
000FE5BB  207265            and [bp+si+0x65],dh
000FE5BE  61                popa
000FE5BF  6C                insb
000FE5C0  008B918D          add [bp+di-0x726f],cl
000FE5C4  56                push si
000FE5C5  44                inc sp
000FE5C6  55                push bp
000FE5C7  008C7075          add [si+0x7570],cl
000FE5CB  657274            gs jc 0xe642
000FE5CE  61                popa
000FE5CF  8E696D            mov gs,[bx+di+0x6d]
000FE5D2  7072              jo 0xe646
000FE5D4  65736F            gs jnc 0xe646
000FE5D7  7261              jc 0xe63a
000FE5D9  8F00              pop word [bx+si]
000FE5DB  8C7075            mov [bx+si+0x75],segr6
000FE5DE  657274            gs jc 0xe655
000FE5E1  61                popa
000FE5E2  207365            and [bp+di+0x65],dh
000FE5E5  7269              jc 0xe650
000FE5E7  658F00            pop word [gs:bx+si]
000FE5EA  656E              gs outsb
000FE5EC  206C6F            and [si+0x6f],ch
000FE5EF  7320              jnc 0xe611
000FE5F1  7265              jc 0xe658
000FE5F3  67697374726F      imul si,[ebx+0x74],word 0x6f72
000FE5F9  738E              jnc 0xe589
000FE5FB  636F6F            arpl [bx+0x6f],bp
000FE5FE  7264              jc 0xe664
000FE600  656E              gs outsb
000FE602  61                popa
000FE603  6461              fs popa
000FE605  7320              jnc 0xe627
000FE607  64656C            gs insb
000FE60A  207261            and [bp+si+0x61],dh
000FE60D  746F              jz 0xe67e
000FE60F  6E                outsb
000FE610  006469            add [si+0x69],ah
000FE613  207375            and [bp+di+0x75],dh
000FE616  6D                insw
000FE617  61                popa
000FE618  206469            and [si+0x69],ah
000FE61B  20636F            and [bp+di+0x6f],ah
000FE61E  6D                insw
000FE61F  7072              jo 0xe693
000FE621  6F                outsw
000FE622  626163            bound sp,[bx+di+0x63]
000FE625  696F6E208B        imul bp,[bx+0x6e],word 0x8b20
000FE62A  52                push dx
000FE62B  4F                dec di
000FE62C  53                push bx
000FE62D  206465            and [si+0x65],ah
000FE630  90                nop
000FE631  008C6D65          add [si+0x656d],cl
000FE635  6D                insw
000FE636  6F                outsw
000FE637  7269              jc 0xe6a2
000FE639  61                popa
000FE63A  205241            and [bp+si+0x41],dl
000FE63D  4D                dec bp
000FE63E  2028              and [bx+si],ch
000FE640  657272            gs jc 0xe6b5
000FE643  6F                outsw
000FE644  728E              jc 0xe5d4
000FE646  7061              jo 0xe6a9
000FE648  7269              jc 0xe6b3
000FE64A  6461              fs popa
000FE64C  642900            sub [fs:bx+si],ax
000FE64F  92                xchg ax,dx
000FE650  657370            gs jnc 0xe6c3
000FE653  657265            gs jc 0xe6bb
000FE656  0000              add [bx+si],al
000FE658  0000              add [bx+si],al
000FE65A  0000              add [bx+si],al
000FE65C  0000              add [bx+si],al
000FE65E  0000              add [bx+si],al
000FE660  124504            adc al,[di+0x4]
000FE663  07                pop es
000FE664  0A0E1FB8          or cl,[0xb81f]
000FE668  2602CD            es add cl,ch
000FE66B  1532E4            adc ax,0xe432
000FE66E  33D2              xor dx,dx
000FE670  CD14              int 0x14
000FE672  B82702            mov ax,0x227
000FE675  CD15              int 0x15
000FE677  32E4              xor ah,ah
000FE679  42                inc dx
000FE67A  CD14              int 0x14
000FE67C  B402              mov ah,0x2
000FE67E  CD1A              int 0x1a
000FE680  8AC6              mov al,dh
000FE682  E82800            call 0xe6ad
000FE685  F6266026          mul byte [0x2660]
000FE689  8BD8              mov bx,ax
000FE68B  8AC1              mov al,cl
000FE68D  E81D00            call 0xe6ad
000FE690  F7266126          mul word [0x2661]
000FE694  03D8              add bx,ax
000FE696  8AC5              mov al,ch
000FE698  E81200            call 0xe6ad
000FE69B  8BC8              mov cx,ax
000FE69D  F6266326          mul byte [0x2663]
000FE6A1  03D8              add bx,ax
000FE6A3  83D100            adc cx,byte +0x0
000FE6A6  8BD3              mov dx,bx
000FE6A8  B401              mov ah,0x1
000FE6AA  CD1A              int 0x1a
000FE6AC  C3                ret
000FE6AD  53                push bx
000FE6AE  51                push cx
000FE6AF  8AD8              mov bl,al
000FE6B1  80E30F            and bl,0xf
000FE6B4  B104              mov cl,0x4
000FE6B6  D2E8              shr al,cl
000FE6B8  F6266426          mul byte [0x2664]
000FE6BC  02C3              add al,bl
000FE6BE  59                pop cx
000FE6BF  5B                pop bx
000FE6C0  C3                ret
000FE6C1  0000              add [bx+si],al
000FE6C3  0000              add [bx+si],al
000FE6C5  0000              add [bx+si],al
000FE6C7  0000              add [bx+si],al
000FE6C9  0000              add [bx+si],al
000FE6CB  0000              add [bx+si],al
000FE6CD  0000              add [bx+si],al
000FE6CF  0000              add [bx+si],al
000FE6D1  0000              add [bx+si],al
000FE6D3  0000              add [bx+si],al
000FE6D5  0000              add [bx+si],al
000FE6D7  0000              add [bx+si],al
000FE6D9  0000              add [bx+si],al
000FE6DB  0000              add [bx+si],al
000FE6DD  0000              add [bx+si],al
000FE6DF  0000              add [bx+si],al
000FE6E1  0000              add [bx+si],al
000FE6E3  0000              add [bx+si],al
000FE6E5  0000              add [bx+si],al
000FE6E7  0000              add [bx+si],al
000FE6E9  0000              add [bx+si],al
000FE6EB  0000              add [bx+si],al
000FE6ED  0000              add [bx+si],al
000FE6EF  0000              add [bx+si],al
000FE6F1  00EA              add dl,ch
000FE6F3  E50A              in ax,0xa
000FE6F5  00FC              add ah,bh
000FE6F7  2EAD              cs lodsw
000FE6F9  8AD4              mov dl,ah
000FE6FB  EE                out dx,al
000FE6FC  C3                ret
000FE6FD  BF0100            mov di,0x1
000FE700  EB07              jmp short 0xe709
000FE702  2EAC              cs lodsb
000FE704  8AD0              mov dl,al
000FE706  EC                in al,dx
000FE707  33FF              xor di,di
000FE709  2EAC              cs lodsb
000FE70B  98                cbw
000FE70C  8BC8              mov cx,ax
000FE70E  2EAD              cs lodsw
000FE710  8AD0              mov dl,al
000FE712  8AC4              mov al,ah
000FE714  EE                out dx,al
000FE715  FEC4              inc ah
000FE717  03D7              add dx,di
000FE719  2EAC              cs lodsb
000FE71B  EE                out dx,al
000FE71C  2BD7              sub dx,di
000FE71E  E2F2              loop 0xe712
000FE720  33FF              xor di,di
000FE722  C3                ret
000FE723  0000              add [bx+si],al
000FE725  0000              add [bx+si],al
000FE727  0000              add [bx+si],al
000FE729  EAAC0F00FC        jmp 0xfc00:0xfac
000FE72E  3E27              ds daa
000FE730  7827              js 0xe759
000FE732  94                xchg ax,sp
000FE733  27                daa
000FE734  AC                lodsb
000FE735  27                daa
000FE736  E427              in al,0x27
000FE738  C8275E27          enter 0x5e27,0x27
000FE73C  3E27              ds daa
000FE73E  C8225238          enter 0x5222,0x38
000FE742  56                push si
000FE743  386838            cmp [bx+si+0x38],ch
000FE746  98                cbw
000FE747  38AC38C6          cmp [si-0x39c8],ch
000FE74B  38F1              cmp cl,dh
000FE74D  3818              cmp [bx+si],bl
000FE74F  39B239E5          cmp [bp+si-0x1ac7],si
000FE753  39F2              cmp dx,si
000FE755  39F9              cmp cx,di
000FE757  3901              cmp [bx+di],ax
000FE759  3A07              cmp al,[bx]
000FE75B  3A0E3AC8          cmp cl,[0xc83a]
000FE75F  228C2990          and cl,[si-0x6fd7]
000FE763  29A82901          sub [bx+si+0x129],bp
000FE767  2A1C              sub bl,[si]
000FE769  2A3C              sub bh,[si]
000FE76B  2A882AC7          sub cl,[bx+si-0x38d6]
000FE76F  2AF5              sub dh,ch
000FE771  2B20              sub sp,[bx+si]
000FE773  2C32              sub al,0x32
000FE775  2C2D              sub al,0x2d
000FE777  2CC8              sub al,0xc8
000FE779  22571D            and dl,[bx+0x1d]
000FE77C  5B                pop bx
000FE77D  1D701D            sbb ax,0x1d70
000FE780  BC1DD4            mov sp,0xd41d
000FE783  1DF41D            sbb ax,0x1df4
000FE786  331E711E          xor bx,[0x1e71]
000FE78A  BA1F15            mov dx,0x151f
000FE78D  2023              and [bp+di],ah
000FE78F  2030              and [bx+si],dh
000FE791  203A              and [bp+si],bh
000FE793  20C8              and al,cl
000FE795  226020            and ah,[bx+si+0x20]
000FE798  64207820          and [fs:bx+si+0x20],bh
000FE79C  C420              les sp,[bx+si]
000FE79E  DF20              fbld tword [bx+si]
000FE7A0  0021              add [bx+di],ah
000FE7A2  43                inc bx
000FE7A3  217021            and [bx+si+0x21],si
000FE7A6  43                inc bx
000FE7A7  229922A7          and bl,[bx+di-0x58de]
000FE7AB  22C8              and cl,al
000FE7AD  226A18            and ch,[bp+si+0x18]
000FE7B0  6E                outsb
000FE7B1  188318D7          sbb [bp+di-0x28e8],al
000FE7B5  18F6              sbb dh,dh
000FE7B7  1811              sbb [bx+di],dl
000FE7B9  194F19            sbb [bx+0x19],cx
000FE7BC  6C                insb
000FE7BD  192D              sbb [di],bp
000FE7BF  1A551A            sbb dl,[di+0x1a]
000FE7C2  721A              jc 0xe7de
000FE7C4  631A              arpl [bp+si],bx
000FE7C6  7A1A              jpe 0xe7e2
000FE7C8  C822811A          enter 0x8122,0x1a
000FE7CC  851A              test [bp+si],bx
000FE7CE  9C                pushf
000FE7CF  1AEF              sbb ch,bh
000FE7D1  1A11              sbb dl,[bx+di]
000FE7D3  1B34              sbb si,[si]
000FE7D5  1B841BC8          sbb ax,[si-0x37e5]
000FE7D9  1BCA              sbb cx,dx
000FE7DB  1C22              sbb al,0x22
000FE7DD  1D2F1D            sbb ax,0x1d2f
000FE7E0  3E1D491D          ds sbb ax,0x1d49
000FE7E4  E023              loopne 0xe809
000FE7E6  E623              out 0x23,al
000FE7E8  F32323            rep and sp,[bp+di]
000FE7EB  245E              and al,0x5e
000FE7ED  2473              and al,0x73
000FE7EF  2495              and al,0x95
000FE7F1  24D4              and al,0xd4
000FE7F3  2419              and al,0x19
000FE7F5  254228            and ax,0x2842
000FE7F8  9A28A728AE        call 0xae28:0xa728
000FE7FD  28B128B5          sub [bx+di-0x4ad8],dh
000FE801  28BA28BE          sub [bp+si-0x41d8],bh
000FE805  28C7              sub bh,al
000FE807  28D7              sub bh,dl
000FE809  28E3              sub bl,ah
000FE80B  2800              sub [bx+si],al
000FE80D  0000              add [bx+si],al
000FE80F  0000              add [bx+si],al
000FE811  0000              add [bx+si],al
000FE813  0000              add [bx+si],al
000FE815  0000              add [bx+si],al
000FE817  0000              add [bx+si],al
000FE819  0000              add [bx+si],al
000FE81B  0000              add [bx+si],al
000FE81D  0000              add [bx+si],al
000FE81F  0000              add [bx+si],al
000FE821  0000              add [bx+si],al
000FE823  0000              add [bx+si],al
000FE825  0000              add [bx+si],al
000FE827  0000              add [bx+si],al
000FE829  0000              add [bx+si],al
000FE82B  0000              add [bx+si],al
000FE82D  00EA              add dl,ch
000FE82F  0011              add [bx+di],dl
000FE831  00FC              add ah,bh
000FE833  EA721100FC        jmp 0xfc00:0x1172
000FE838  EA223100FC        jmp 0xfc00:0x3122
000FE83D  EAD61200FC        jmp 0xfc00:0x12d6
000FE842  656E              gs outsb
000FE844  65726F            gs jc 0xe8b6
000FE847  006665            add [bp+0x65],ah
000FE84A  627265            bound si,[bp+si+0x65]
000FE84D  726F              jc 0xe8be
000FE84F  006D61            add [di+0x61],ch
000FE852  727A              jc 0xe8ce
000FE854  6F                outsw
000FE855  006162            add [bx+di+0x62],ah
000FE858  7269              jc 0xe8c3
000FE85A  6C                insb
000FE85B  006D61            add [di+0x61],ch
000FE85E  796F              jns 0xe8cf
000FE860  006A75            add [bp+si+0x75],ch
000FE863  6E                outsb
000FE864  696F006A75        imul bp,[bx+0x0],word 0x756a
000FE869  6C                insb
000FE86A  696F006167        imul bp,[bx+0x0],word 0x6761
000FE86F  6F                outsw
000FE870  7374              jnc 0xe8e6
000FE872  6F                outsw
000FE873  007365            add [bp+di+0x65],dh
000FE876  7469              jz 0xe8e1
000FE878  656D              gs insw
000FE87A  627265            bound si,[bp+si+0x65]
000FE87D  006F63            add [bx+0x63],ch
000FE880  7475              jz 0xe8f7
000FE882  627265            bound si,[bp+si+0x65]
000FE885  006E6F            add [bp+0x6f],ch
000FE888  7669              jna 0xe8f3
000FE88A  656D              gs insw
000FE88C  627265            bound si,[bp+si+0x65]
000FE88F  006469            add [si+0x69],ah
000FE892  636965            arpl [bx+di+0x65],bp
000FE895  6D                insw
000FE896  627265            bound si,[bp+si+0x65]
000FE899  0011              add [bx+di],dl
000FE89B  3A12              cmp dl,[bp+si]
000FE89D  20656C            and [di+0x6c],ah
000FE8A0  2013              and [bp+di],dl
000FE8A2  200F              and [bx],cl
000FE8A4  2014              and [si],dl
000FE8A6  00656E            add [di+0x6e],ah
000FE8A9  20656C            and [di+0x6c],ah
000FE8AC  2000              and [bx+si],al
000FE8AE  656E              gs outsb
000FE8B0  206C61            and [si+0x61],ch
000FE8B3  2000              and [bx+si],al
000FE8B5  206465            and [si+0x65],ah
000FE8B8  2000              and [bx+si],al
000FE8BA  206465            and [si+0x65],ah
000FE8BD  6C                insb
000FE8BE  207369            and [bp+di+0x69],dh
000FE8C1  7374              jnc 0xe937
000FE8C3  656D              gs insw
000FE8C5  61                popa
000FE8C6  00636F            add [bp+di+0x6f],ah
000FE8C9  6E                outsb
000FE8CA  7472              jz 0xe93e
000FE8CC  6F                outsw
000FE8CD  6C                insb
000FE8CE  61                popa
000FE8CF  646F              fs outsw
000FE8D1  7220              jc 0xe8f3
000FE8D3  64652000          and [gs:bx+si],al
000FE8D7  50                push ax
000FE8D8  6F                outsw
000FE8D9  7220              jc 0xe8fb
000FE8DB  6661              popad
000FE8DD  766F              jna 0xe94e
000FE8DF  722C              jc 0xe90d
000FE8E1  2000              and [bx+si],al
000FE8E3  657374            gs jnc 0xe95a
000FE8E6  61                popa
000FE8E7  626C65            bound bp,[si+0x65]
000FE8EA  7A63              jpe 0xe94f
000FE8EC  61                popa
000FE8ED  2000              and [bx+si],al
000FE8EF  0000              add [bx+si],al
000FE8F1  0000              add [bx+si],al
000FE8F3  0000              add [bx+si],al
000FE8F5  0000              add [bx+si],al
000FE8F7  0000              add [bx+si],al
000FE8F9  0000              add [bx+si],al
000FE8FB  0000              add [bx+si],al
000FE8FD  0000              add [bx+si],al
000FE8FF  0000              add [bx+si],al
000FE901  0000              add [bx+si],al
000FE903  0000              add [bx+si],al
000FE905  0000              add [bx+si],al
000FE907  0000              add [bx+si],al
000FE909  0000              add [bx+si],al
000FE90B  0000              add [bx+si],al
000FE90D  0000              add [bx+si],al
000FE90F  0000              add [bx+si],al
000FE911  0000              add [bx+si],al
000FE913  0000              add [bx+si],al
000FE915  0000              add [bx+si],al
000FE917  0000              add [bx+si],al
000FE919  0000              add [bx+si],al
000FE91B  0000              add [bx+si],al
000FE91D  0000              add [bx+si],al
000FE91F  0000              add [bx+si],al
000FE921  0000              add [bx+si],al
000FE923  0000              add [bx+si],al
000FE925  0000              add [bx+si],al
000FE927  0000              add [bx+si],al
000FE929  0000              add [bx+si],al
000FE92B  0000              add [bx+si],al
000FE92D  0000              add [bx+si],al
000FE92F  0000              add [bx+si],al
000FE931  0000              add [bx+si],al
000FE933  0000              add [bx+si],al
000FE935  0000              add [bx+si],al
000FE937  0000              add [bx+si],al
000FE939  0000              add [bx+si],al
000FE93B  0000              add [bx+si],al
000FE93D  0000              add [bx+si],al
000FE93F  0000              add [bx+si],al
000FE941  0000              add [bx+si],al
000FE943  0000              add [bx+si],al
000FE945  0000              add [bx+si],al
000FE947  0000              add [bx+si],al
000FE949  0000              add [bx+si],al
000FE94B  0000              add [bx+si],al
000FE94D  0000              add [bx+si],al
000FE94F  0000              add [bx+si],al
000FE951  0000              add [bx+si],al
000FE953  0000              add [bx+si],al
000FE955  0000              add [bx+si],al
000FE957  0000              add [bx+si],al
000FE959  0000              add [bx+si],al
000FE95B  0000              add [bx+si],al
000FE95D  0000              add [bx+si],al
000FE95F  0000              add [bx+si],al
000FE961  0000              add [bx+si],al
000FE963  0000              add [bx+si],al
000FE965  0000              add [bx+si],al
000FE967  0000              add [bx+si],al
000FE969  0000              add [bx+si],al
000FE96B  0000              add [bx+si],al
000FE96D  0000              add [bx+si],al
000FE96F  0000              add [bx+si],al
000FE971  0000              add [bx+si],al
000FE973  0000              add [bx+si],al
000FE975  0000              add [bx+si],al
000FE977  0000              add [bx+si],al
000FE979  0000              add [bx+si],al
000FE97B  0000              add [bx+si],al
000FE97D  0000              add [bx+si],al
000FE97F  0000              add [bx+si],al
000FE981  0000              add [bx+si],al
000FE983  0000              add [bx+si],al
000FE985  0000              add [bx+si],al
000FE987  EA5F1100FC        jmp 0xfc00:0x115f
000FE98C  8A02              mov al,[bp+si]
000FE98E  0300              add ax,[bx+si]
000FE990  5C                pop sp
000FE991  5A                pop dx
000FE992  756C              jnz 0xea00
000FE994  65747A            gs jz 0xea11
000FE997  7420              jz 0xe9b9
000FE999  62656E            bound sp,[di+0x6e]
000FE99C  7574              jnz 0xea12
000FE99E  7A74              jpe 0xea14
000FE9A0  20756D            and [di+0x6d],dh
000FE9A3  208A5C07          and [bp+si+0x75c],cl
000FE9A7  0002              add [bp+si],al
000FE9A9  035C8B            add bx,[si-0x75]
000FE9AC  44                inc sp
000FE9AD  61                popa
000FE9AE  7475              jz 0xea25
000FE9B0  6D                insw
000FE9B1  20756E            and [di+0x6e],dh
000FE9B4  64205568          and [fs:di+0x68],dl
000FE9B8  727A              jc 0xea34
000FE9BA  656974206569      imul si,[gs:si+0x20],word 0x6965
000FE9C0  6E                outsb
000FE9C1  7374              jnc 0xea37
000FE9C3  656C              gs insb
000FE9C5  6C                insb
000FE9C6  656E              gs outsb
000FE9C8  5C                pop sp
000FE9C9  8B6469            mov sp,[si+0x69]
000FE9CC  65205374          and [gs:bp+di+0x74],dl
000FE9D0  61                popa
000FE9D1  6E                outsb
000FE9D2  6461              fs popa
000FE9D4  7264              jc 0xea3a
000FE9D6  2D4569            sub ax,0x6945
000FE9D9  6E                outsb
000FE9DA  7374              jnc 0xea50
000FE9DC  656C              gs insb
000FE9DE  6C                insb
000FE9DF  756E              jnz 0xea4f
000FE9E1  67201B            and [ebx],bl
000FE9E4  846E64            test [bp+0x64],ch
000FE9E7  65726E            gs jc 0xea58
000FE9EA  2028              and [bx+si],ch
000FE9EC  7765              ja 0xea53
000FE9EE  6E                outsb
000FE9EF  6E                outsb
000FE9F0  206765            and [bx+0x65],ah
000FE9F3  771B              ja 0xea10
000FE9F5  816E736368        sub word [bp+0x73],0x6863
000FE9FA  7429              jz 0xea25
000FE9FC  5C                pop sp
000FE9FD  07                pop es
000FE9FE  07                pop es
000FE9FF  07                pop es
000FEA00  008B6E65          add [bp+di+0x656e],cl
000FEA04  7565              jnz 0xea6b
000FEA06  204261            and [bp+si+0x61],al
000FEA09  7474              jz 0xea7f
000FEA0B  657269            gs jc 0xea77
000FEA0E  656E              gs outsb
000FEA10  206569            and [di+0x69],ah
000FEA13  6E                outsb
000FEA14  7365              jnc 0xea7b
000FEA16  747A              jz 0xea92
000FEA18  656E              gs outsb
000FEA1A  5C                pop sp
000FEA1B  005C54            add [si+0x54],bl
000FEA1E  61                popa
000FEA1F  7374              jnc 0xea95
000FEA21  61                popa
000FEA22  7475              jz 0xea99
000FEA24  7220              jc 0xea46
000FEA26  756E              jnz 0xea96
000FEA28  64204D61          and [fs:di+0x61],cl
000FEA2C  7573              jnz 0xeaa1
000FEA2E  201B              and [bp+di],bl
000FEA30  8162657270        and word [bp+si+0x65],0x7072
000FEA35  721B              jc 0xea52
000FEA37  8166656E00        and word [bp+0x65],0x6e
000FEA3C  5C                pop sp
000FEA3D  4C                dec sp
000FEA3E  6567656E          gs a32 outsb
000FEA42  205369            and [bp+di+0x69],dl
000FEA45  65206569          and [gs:di+0x69],ah
000FEA49  6E                outsb
000FEA4A  65205359          and [gs:bp+di+0x59],dl
000FEA4E  53                push bx
000FEA4F  54                push sp
000FEA50  45                inc bp
000FEA51  4D                dec bp
000FEA52  2D4469            sub ax,0x6944
000FEA55  736B              jnc 0xeac2
000FEA57  657474            gs jz 0xeace
000FEA5A  6520696E          and [gs:bx+di+0x6e],ch
000FEA5E  204C61            and [si+0x61],cl
000FEA61  7566              jnz 0xeac9
000FEA63  7765              ja 0xeaca
000FEA65  726B              jc 0xead2
000FEA67  20415C            and [bx+di+0x5c],al
000FEA6A  44                inc sp
000FEA6B  61                popa
000FEA6C  6E                outsb
000FEA6D  6E                outsb
000FEA6E  206265            and [bp+si+0x65],ah
000FEA71  6C                insb
000FEA72  6965626967        imul sp,[di+0x62],word 0x6769
000FEA77  65205461          and [gs:si+0x61],dl
000FEA7B  7374              jnc 0xeaf1
000FEA7D  65206472          and [gs:si+0x72],ah
000FEA81  1B81636B          sbb ax,[bx+di+0x6b63]
000FEA85  656E              gs outsb
000FEA87  005C46            add [si+0x46],bl
000FEA8A  65686C65          gs push word 0x656c
000FEA8E  723A              jc 0xeaca
000FEA90  204661            and [bp+0x61],al
000FEA93  6C                insb
000FEA94  7363              jnc 0xeaf9
000FEA96  686520            push word 0x2065
000FEA99  50                push ax
000FEA9A  7275              jc 0xeb11
000FEA9C  65667375          gs o32 jnc 0xeb15
000FEAA0  6D                insw
000FEAA1  6D                insw
000FEAA2  65206265          and [gs:bp+si+0x65],ah
000FEAA6  69206578          imul sp,[bx+si],word 0x7865
000FEAAA  7465              jz 0xeb11
000FEAAC  726E              jc 0xeb1c
000FEAAE  656D              gs insw
000FEAB0  20524F            and [bp+si+0x4f],dl
000FEAB3  4D                dec bp
000FEAB4  3A5C52            cmp bl,[si+0x52]
000FEAB7  4F                dec di
000FEAB8  4D                dec bp
000FEAB9  2D4164            sub ax,0x6441
000FEABC  7265              jc 0xeb23
000FEABE  7373              jnc 0xeb33
000FEAC0  65203D            and [gs:di],bh
000FEAC3  2010              and [bx+si],dl
000FEAC5  5C                pop sp
000FEAC6  004665            add [bp+0x65],al
000FEAC9  686C65            push word 0x656c
000FEACC  7200              jc 0xeace
000FEACE  8C02              mov [bp+si],es
000FEAD0  16                push ss
000FEAD1  205241            and [bp+si+0x41],dl
000FEAD4  4D                dec bp
000FEAD5  008C5644          add [si+0x4456],cl
000FEAD9  55                push bp
000FEADA  205241            and [bp+si+0x41],dl
000FEADD  4D                dec bp
000FEADE  008C0220          add [si+0x2002],cl
000FEAE2  021F              add bl,[bx]
000FEAE4  008C444D          add [si+0x4d44],cl
000FEAE8  41                inc cx
000FEAE9  021F              add bl,[bx]
000FEAEB  008C466C          add [si+0x6c46],cl
000FEAEF  6F                outsw
000FEAF0  7070              jo 0xeb62
000FEAF2  792D              jns 0xeb21
000FEAF4  44                inc sp
000FEAF5  69736B2D43        imul si,[bp+di+0x6b],word 0x432d
000FEAFA  6F                outsw
000FEAFB  6E                outsb
000FEAFC  7472              jz 0xeb70
000FEAFE  6F                outsw
000FEAFF  6C                insb
000FEB00  6C                insb
000FEB01  657220            gs jc 0xeb24
000FEB04  6F                outsw
000FEB05  6465728C          gs jc 0xea95
000FEB09  4C                dec sp
000FEB0A  61                popa
000FEB0B  7566              jnz 0xeb73
000FEB0D  7765              ja 0xeb74
000FEB0F  726B              jc 0xeb7c
000FEB11  008C5A65          add [si+0x655a],cl
000FEB15  6974676562        imul si,[si+0x67],word 0x6265
000FEB1A  657200            gs jc 0xeb1d
000FEB1D  8C02              mov [bp+si],es
000FEB1F  16                push ss
000FEB20  205374            and [bp+di+0x74],dl
000FEB23  61                popa
000FEB24  7475              jz 0xeb9b
000FEB26  732D              jnc 0xeb55
000FEB28  52                push dx
000FEB29  65676973746572    imul si,[gs:ebx+0x74],word 0x7265
000FEB30  0020              add [bx+si],ah
000FEB32  696E206465        imul bp,[bp+0x20],word 0x6564
000FEB37  7220              jc 0xeb59
000FEB39  45                inc bp
000FEB3A  636874            arpl [bx+si+0x74],bp
000FEB3D  7A65              jpe 0xeba4
000FEB3F  69742D5568        imul si,[si+0x2d],word 0x6855
000FEB44  7200              jc 0xeb46
000FEB46  8C5644            mov [bp+0x44],ss
000FEB49  55                push bp
000FEB4A  021F              add bl,[bx]
000FEB4C  0020              add [bx+si],ah
000FEB4E  61                popa
000FEB4F  6D                insw
000FEB50  204175            and [bx+di+0x75],al
000FEB53  7367              jnc 0xebbc
000FEB55  61                popa
000FEB56  6E                outsb
000FEB57  67206675          and [esi+0x75],ah
000FEB5B  657220            gs jc 0xeb7e
000FEB5E  64656E            gs outsb
000FEB61  205379            and [bp+di+0x79],dl
000FEB64  7374              jnc 0xebda
000FEB66  656D              gs insw
000FEB68  2D4472            sub ax,0x7244
000FEB6B  7563              jnz 0xebd0
000FEB6D  6B657200          imul sp,[di+0x72],byte +0x0
000FEB71  20616D            and [bx+di+0x6d],ah
000FEB74  207365            and [bp+di+0x65],dh
000FEB77  7269              jc 0xebe2
000FEB79  656C              gs insb
000FEB7B  6C                insb
000FEB7C  656E              gs outsb
000FEB7E  205379            and [bp+di+0x79],dl
000FEB81  7374              jnc 0xebf7
000FEB83  656D              gs insw
000FEB85  2D4175            sub ax,0x7541
000FEB88  7367              jnc 0xebf1
000FEB8A  61                popa
000FEB8B  6E                outsb
000FEB8C  670020            add [eax],ah
000FEB8F  696E206465        imul bp,[bp+0x20],word 0x6564
000FEB94  6E                outsb
000FEB95  205374            and [bp+di+0x74],dl
000FEB98  657565            gs jnz 0xec00
000FEB9B  722D              jc 0xebca
000FEB9D  52                push dx
000FEB9E  65676973746572    imul si,[gs:ebx+0x74],word 0x7265
000FEBA5  6E                outsb
000FEBA6  206675            and [bp+0x75],ah
000FEBA9  657220            gs jc 0xebcc
000FEBAC  646965204D61      imul sp,[fs:di+0x20],word 0x614d
000FEBB2  7573              jnz 0xec27
000FEBB4  003A              add [bp+si],bh
000FEBB6  204661            and [bp+0x61],al
000FEBB9  6C                insb
000FEBBA  7363              jnc 0xec1f
000FEBBC  686520            push word 0x2065
000FEBBF  52                push dx
000FEBC0  4F                dec di
000FEBC1  53                push bx
000FEBC2  2D5072            sub ax,0x7250
000FEBC5  7565              jnz 0xec2c
000FEBC7  667375            o32 jnc 0xec3f
000FEBCA  6D                insw
000FEBCB  6D                insw
000FEBCC  65008C4861        add [gs:si+0x6148],cl
000FEBD1  7570              jnz 0xec43
000FEBD3  7473              jz 0xec48
000FEBD5  7065              jo 0xec3c
000FEBD7  6963686572        imul sp,[bp+di+0x68],word 0x7265
000FEBDC  2028              and [bx+si],ch
000FEBDE  50                push ax
000FEBDF  61                popa
000FEBE0  7269              jc 0xec4b
000FEBE2  7479              jz 0xec5d
000FEBE4  2D4665            sub ax,0x6546
000FEBE7  686C65            push word 0x656c
000FEBEA  7229              jc 0xec15
000FEBEC  008B7761          add [bp+di+0x6177],cl
000FEBF0  7274              jc 0xec66
000FEBF2  656E              gs outsb
000FEBF4  0002              add [bp+si],al
000FEBF6  0400              add al,0x0
000FEBF8  0205              add al,[di]
000FEBFA  004D1B            add [di+0x1b],cl
000FEBFD  84727A            test [bp+si+0x7a],dh
000FEC00  0002              add [bp+si],al
000FEC02  0900              or [bx+si],ax
000FEC04  4D                dec bp
000FEC05  61                popa
000FEC06  69000206          imul ax,[bx+si],word 0x602
000FEC0A  0002              add [bp+si],al
000FEC0C  07                pop es
000FEC0D  0002              add [bp+si],al
000FEC0F  0A00              or al,[bx+si]
000FEC11  020B              add cl,[bp+di]
000FEC13  0002              add [bp+si],al
000FEC15  0800              or [bx+si],al
000FEC17  020D              add cl,[di]
000FEC19  004465            add [si+0x65],al
000FEC1C  7A02              jpe 0xec20
000FEC1E  0F0011            lldt [bx+di]
000FEC21  3A12              cmp dl,[bp+si]
000FEC23  20616D            and [bx+di+0x6d],ah
000FEC26  2013              and [bp+di],dl
000FEC28  200F              and [bx],cl
000FEC2A  2014              and [si],dl
000FEC2C  0020              add [bx+si],ah
000FEC2E  696D200042        imul bp,[di+0x20],word 0x4200
000FEC33  6974746520        imul si,[si+0x74],word 0x2065
000FEC38  0000              add [bx+si],al
000FEC3A  0000              add [bx+si],al
000FEC3C  0000              add [bx+si],al
000FEC3E  0000              add [bx+si],al
000FEC40  0000              add [bx+si],al
000FEC42  0000              add [bx+si],al
000FEC44  0000              add [bx+si],al
000FEC46  0000              add [bx+si],al
000FEC48  0000              add [bx+si],al
000FEC4A  0000              add [bx+si],al
000FEC4C  0000              add [bx+si],al
000FEC4E  0000              add [bx+si],al
000FEC50  0000              add [bx+si],al
000FEC52  0000              add [bx+si],al
000FEC54  0000              add [bx+si],al
000FEC56  0000              add [bx+si],al
000FEC58  00EA              add dl,ch
000FEC5A  5E                pop si
000FEC5B  2C00              sub al,0x0
000FEC5D  FC                cld
000FEC5E  E84DDF            call 0xcbae
000FEC61  80FC02            cmp ah,0x2
000FEC64  7215              jc 0xec7b
000FEC66  80FC06            cmp ah,0x6
000FEC69  7305              jnc 0xec70
000FEC6B  80FA02            cmp dl,0x2
000FEC6E  7205              jc 0xec75
000FEC70  B401              mov ah,0x1
000FEC72  E9D700            jmp 0xed4c
000FEC75  E8F102            call 0xef69
000FEC78  E8A801            call 0xee23
000FEC7B  8A5E01            mov bl,[bp+0x1]
000FEC7E  02DB              add bl,bl
000FEC80  32FF              xor bh,bh
000FEC82  2EFF978A2C        call [cs:bx+0x2c8a]
000FEC87  E9C400            jmp 0xed4e
000FEC8A  672DA02D          sub ax,0x2da0
000FEC8E  E42C              in al,0x2c
000FEC90  96                xchg ax,si
000FEC91  2CE8              sub al,0xe8
000FEC93  2CA2              sub al,0xa2
000FEC95  2CB6              sub al,0xb6
000FEC97  4A                dec dx
000FEC98  E81C01            call 0xedb7
000FEC9B  B4C5              mov ah,0xc5
000FEC9D  E84F00            call 0xecef
000FECA0  EB3A              jmp short 0xecdc
000FECA2  B004              mov al,0x4
000FECA4  E87302            call 0xef1a
000FECA7  8ADC              mov bl,ah
000FECA9  D0E3              shl bl,1
000FECAB  D0E3              shl bl,1
000FECAD  32FF              xor bh,bh
000FECAF  B64A              mov dh,0x4a
000FECB1  E82701            call 0xeddb
000FECB4  B44D              mov ah,0x4d
000FECB6  E84002            call 0xeef9
000FECB9  8A6607            mov ah,[bp+0x7]
000FECBC  D0C4              rol ah,1
000FECBE  D0C4              rol ah,1
000FECC0  026606            add ah,[bp+0x6]
000FECC3  E83302            call 0xeef9
000FECC6  B003              mov al,0x3
000FECC8  E82B02            call 0xeef6
000FECCB  E82302            call 0xeef1
000FECCE  43                inc bx
000FECCF  43                inc bx
000FECD0  E81E02            call 0xeef1
000FECD3  268A27            mov ah,[es:bx]
000FECD6  E84C00            call 0xed25
000FECD9  8A4600            mov al,[bp+0x0]
000FECDC  9C                pushf
000FECDD  B91B03            mov cx,0x31b
000FECE0  E2FE              loop 0xece0
000FECE2  9D                popf
000FECE3  C3                ret
000FECE4  B646              mov dh,0x46
000FECE6  EB02              jmp short 0xecea
000FECE8  B642              mov dh,0x42
000FECEA  E8CA00            call 0xedb7
000FECED  B4E6              mov ah,0xe6
000FECEF  E80702            call 0xeef9
000FECF2  8A6607            mov ah,[bp+0x7]
000FECF5  D0C4              rol ah,1
000FECF7  D0C4              rol ah,1
000FECF9  026606            add ah,[bp+0x6]
000FECFC  E8FA01            call 0xeef9
000FECFF  8A6605            mov ah,[bp+0x5]
000FED02  E8F401            call 0xeef9
000FED05  8A6607            mov ah,[bp+0x7]
000FED08  E8EE01            call 0xeef9
000FED0B  8A6604            mov ah,[bp+0x4]
000FED0E  E8E801            call 0xeef9
000FED11  B003              mov al,0x3
000FED13  E8E001            call 0xeef6
000FED16  268A27            mov ah,[es:bx]
000FED19  E8DD01            call 0xeef9
000FED1C  268A27            mov ah,[es:bx]
000FED1F  E8D701            call 0xeef9
000FED22  268A27            mov ah,[es:bx]
000FED25  E85101            call 0xee79
000FED28  E87301            call 0xee9e
000FED2B  7501              jnz 0xed2e
000FED2D  C3                ret
000FED2E  B90700            mov cx,0x7
000FED31  8A264304          mov ah,[0x443]
000FED35  D0DC              rcr ah,1
000FED37  7202              jc 0xed3b
000FED39  E2FA              loop 0xed35
000FED3B  BB442D            mov bx,0x2d44
000FED3E  03D9              add bx,cx
000FED40  2E8A27            mov ah,[cs:bx]
000FED43  C3                ret
000FED44  2020              and [bx+si],ah
000FED46  1008              adc [bx+si],cl
000FED48  2004              and [si],al
000FED4A  0302              add ax,[bp+si]
000FED4C  32C0              xor al,al
000FED4E  894600            mov [bp+0x0],ax
000FED51  88264104          mov [0x441],ah
000FED55  80FC01            cmp ah,0x1
000FED58  F5                cmc
000FED59  9C                pushf
000FED5A  B002              mov al,0x2
000FED5C  E8BB01            call 0xef1a
000FED5F  88264004          mov [0x440],ah
000FED63  9D                popf
000FED64  E939DE            jmp 0xcba0
000FED67  C6063E0400        mov byte [0x43e],0x0
000FED6C  BAF203            mov dx,0x3f2
000FED6F  B008              mov al,0x8
000FED71  EE                out dx,al
000FED72  B91E00            mov cx,0x1e
000FED75  E2FE              loop 0xed75
000FED77  C6063F0400        mov byte [0x43f],0x0
000FED7C  C70640040000      mov word [0x440],0x0
000FED82  B00C              mov al,0xc
000FED84  EE                out dx,al
000FED85  E8F900            call 0xee81
000FED88  E8E600            call 0xee71
000FED8B  B403              mov ah,0x3
000FED8D  E86901            call 0xeef9
000FED90  B000              mov al,0x0
000FED92  E86101            call 0xeef6
000FED95  B001              mov al,0x1
000FED97  E85C01            call 0xeef6
000FED9A  33C0              xor ax,ax
000FED9C  8A4600            mov al,[bp+0x0]
000FED9F  C3                ret
000FEDA0  A04104            mov al,[0x441]
000FEDA3  8AE0              mov ah,al
000FEDA5  C3                ret
000FEDA6  9C                pushf
000FEDA7  0E                push cs
000FEDA8  E80100            call 0xedac
000FEDAB  C3                ret
000FEDAC  E8FFDD            call 0xcbae
000FEDAF  E8B701            call 0xef69
000FEDB2  E86E00            call 0xee23
000FEDB5  EB97              jmp short 0xed4e
000FEDB7  52                push dx
000FEDB8  B003              mov al,0x3
000FEDBA  E85D01            call 0xef1a
000FEDBD  750B              jnz 0xedca
000FEDBF  B006              mov al,0x6
000FEDC1  E85601            call 0xef1a
000FEDC4  8AC4              mov al,ah
000FEDC6  32E4              xor ah,ah
000FEDC8  EB07              jmp short 0xedd1
000FEDCA  8ACC              mov cl,ah
000FEDCC  B88000            mov ax,0x80
000FEDCF  D3C0              rol ax,cl
000FEDD1  8A5E00            mov bl,[bp+0x0]
000FEDD4  B700              mov bh,0x0
000FEDD6  F7E3              mul bx
000FEDD8  8BD8              mov bx,ax
000FEDDA  5A                pop dx
000FEDDB  8B460A            mov ax,[bp+0xa]
000FEDDE  B104              mov cl,0x4
000FEDE0  D3C0              rol ax,cl
000FEDE2  8AD0              mov dl,al
000FEDE4  80E20F            and dl,0xf
000FEDE7  24F0              and al,0xf0
000FEDE9  034602            add ax,[bp+0x2]
000FEDEC  7302              jnc 0xedf0
000FEDEE  FEC2              inc dl
000FEDF0  8BC8              mov cx,ax
000FEDF2  03C3              add ax,bx
000FEDF4  7402              jz 0xedf8
000FEDF6  7226              jc 0xee1e
000FEDF8  B006              mov al,0x6
000FEDFA  E60A              out 0xa,al
000FEDFC  FA                cli
000FEDFD  E60C              out 0xc,al
000FEDFF  8AC1              mov al,cl
000FEE01  E604              out 0x4,al
000FEE03  8AC5              mov al,ch
000FEE05  E604              out 0x4,al
000FEE07  8AC2              mov al,dl
000FEE09  E681              out 0x81,al
000FEE0B  4B                dec bx
000FEE0C  8AC3              mov al,bl
000FEE0E  E605              out 0x5,al
000FEE10  8AC7              mov al,bh
000FEE12  E605              out 0x5,al
000FEE14  FB                sti
000FEE15  8AC6              mov al,dh
000FEE17  E60B              out 0xb,al
000FEE19  B002              mov al,0x2
000FEE1B  E60A              out 0xa,al
000FEE1D  C3                ret
000FEE1E  B409              mov ah,0x9
000FEE20  E929FF            jmp 0xed4c
000FEE23  8A3E3F04          mov bh,[0x43f]
000FEE27  843E3E04          test [0x43e],bh
000FEE2B  7510              jnz 0xee3d
000FEE2D  53                push bx
000FEE2E  E82500            call 0xee56
000FEE31  7405              jz 0xee38
000FEE33  E82000            call 0xee56
000FEE36  7519              jnz 0xee51
000FEE38  5B                pop bx
000FEE39  083E3E04          or [0x43e],bh
000FEE3D  B40F              mov ah,0xf
000FEE3F  E8B700            call 0xeef9
000FEE42  8A6606            mov ah,[bp+0x6]
000FEE45  E8B100            call 0xeef9
000FEE48  8A6605            mov ah,[bp+0x5]
000FEE4B  E81000            call 0xee5e
000FEE4E  7201              jc 0xee51
000FEE50  C3                ret
000FEE51  B440              mov ah,0x40
000FEE53  E9F6FE            jmp 0xed4c
000FEE56  B407              mov ah,0x7
000FEE58  E89E00            call 0xeef9
000FEE5B  8A6606            mov ah,[bp+0x6]
000FEE5E  E81800            call 0xee79
000FEE61  B009              mov al,0x9
000FEE63  E8B400            call 0xef1a
000FEE66  7409              jz 0xee71
000FEE68  B9C601            mov cx,0x1c6
000FEE6B  E2FE              loop 0xee6b
000FEE6D  FECC              dec ah
000FEE6F  75F7              jnz 0xee68
000FEE71  B408              mov ah,0x8
000FEE73  E88300            call 0xeef9
000FEE76  EB26              jmp short 0xee9e
000FEE78  90                nop
000FEE79  80263E047F        and byte [0x43e],0x7f
000FEE7E  E87800            call 0xeef9
000FEE81  B90000            mov cx,0x0
000FEE84  B005              mov al,0x5
000FEE86  F6063E0480        test byte [0x43e],0x80
000FEE8B  750B              jnz 0xee98
000FEE8D  E2F7              loop 0xee86
000FEE8F  FEC8              dec al
000FEE91  75F3              jnz 0xee86
000FEE93  B480              mov ah,0x80
000FEE95  E9B4FE            jmp 0xed4c
000FEE98  80263E047F        and byte [0x43e],0x7f
000FEE9D  C3                ret
000FEE9E  FC                cld
000FEE9F  BAF403            mov dx,0x3f4
000FEEA2  8D1E4204          lea bx,[0x442]
000FEEA6  B407              mov ah,0x7
000FEEA8  B90000            mov cx,0x0
000FEEAB  EC                in al,dx
000FEEAC  D0D0              rcl al,1
000FEEAE  7207              jc 0xeeb7
000FEEB0  E2F9              loop 0xeeab
000FEEB2  B420              mov ah,0x20
000FEEB4  E995FE            jmp 0xed4c
000FEEB7  D0D0              rcl al,1
000FEEB9  7313              jnc 0xeece
000FEEBB  0AE4              or ah,ah
000FEEBD  74F3              jz 0xeeb2
000FEEBF  42                inc dx
000FEEC0  EC                in al,dx
000FEEC1  4A                dec dx
000FEEC2  8807              mov [bx],al
000FEEC4  43                inc bx
000FEEC5  FECC              dec ah
000FEEC7  B90C00            mov cx,0xc
000FEECA  E2FE              loop 0xeeca
000FEECC  EBDD              jmp short 0xeeab
000FEECE  A04604            mov al,[0x446]
000FEED1  3A4607            cmp al,[bp+0x7]
000FEED4  A04704            mov al,[0x447]
000FEED7  740B              jz 0xeee4
000FEED9  B004              mov al,0x4
000FEEDB  E83C00            call 0xef1a
000FEEDE  8AC4              mov al,ah
000FEEE0  02064704          add al,[0x447]
000FEEE4  2A4604            sub al,[bp+0x4]
000FEEE7  8A264204          mov ah,[0x442]
000FEEEB  F6C4C0            test ah,0xc0
000FEEEE  B400              mov ah,0x0
000FEEF0  C3                ret
000FEEF1  268A27            mov ah,[es:bx]
000FEEF4  EB03              jmp short 0xeef9
000FEEF6  E82100            call 0xef1a
000FEEF9  BAF403            mov dx,0x3f4
000FEEFC  B90000            mov cx,0x0
000FEEFF  EC                in al,dx
000FEF00  D0D0              rcl al,1
000FEF02  7207              jc 0xef0b
000FEF04  E2F9              loop 0xeeff
000FEF06  B420              mov ah,0x20
000FEF08  E941FE            jmp 0xed4c
000FEF0B  D0D0              rcl al,1
000FEF0D  72F7              jc 0xef06
000FEF0F  8AC4              mov al,ah
000FEF11  42                inc dx
000FEF12  EE                out dx,al
000FEF13  B90800            mov cx,0x8
000FEF16  E2FE              loop 0xef16
000FEF18  43                inc bx
000FEF19  C3                ret
000FEF1A  C41E7800          les bx,[0x78]
000FEF1E  98                cbw
000FEF1F  03D8              add bx,ax
000FEF21  268A27            mov ah,[es:bx]
000FEF24  0AE4              or ah,ah
000FEF26  C3                ret
000FEF27  0000              add [bx+si],al
000FEF29  0000              add [bx+si],al
000FEF2B  0000              add [bx+si],al
000FEF2D  0000              add [bx+si],al
000FEF2F  0000              add [bx+si],al
000FEF31  0000              add [bx+si],al
000FEF33  0000              add [bx+si],al
000FEF35  0000              add [bx+si],al
000FEF37  0000              add [bx+si],al
000FEF39  0000              add [bx+si],al
000FEF3B  0000              add [bx+si],al
000FEF3D  0000              add [bx+si],al
000FEF3F  0000              add [bx+si],al
000FEF41  0000              add [bx+si],al
000FEF43  0000              add [bx+si],al
000FEF45  0000              add [bx+si],al
000FEF47  0000              add [bx+si],al
000FEF49  0000              add [bx+si],al
000FEF4B  0000              add [bx+si],al
000FEF4D  0000              add [bx+si],al
000FEF4F  0000              add [bx+si],al
000FEF51  0000              add [bx+si],al
000FEF53  0000              add [bx+si],al
000FEF55  0000              add [bx+si],al
000FEF57  1E                push ds
000FEF58  50                push ax
000FEF59  33C0              xor ax,ax
000FEF5B  8ED8              mov ds,ax
000FEF5D  800E3E0480        or byte [0x43e],0x80
000FEF62  B066              mov al,0x66
000FEF64  E620              out 0x20,al
000FEF66  58                pop ax
000FEF67  1F                pop ds
000FEF68  CF                iret
000FEF69  C6064004FF        mov byte [0x440],0xff
000FEF6E  8A4E06            mov cl,[bp+0x6]
000FEF71  B080              mov al,0x80
000FEF73  FEC1              inc cl
000FEF75  D2C0              rol al,cl
000FEF77  84063F04          test [0x43f],al
000FEF7B  752B              jnz 0xefa8
000FEF7D  A23F04            mov [0x43f],al
000FEF80  B104              mov cl,0x4
000FEF82  D2C0              rol al,cl
000FEF84  0A4606            or al,[bp+0x6]
000FEF87  0C0C              or al,0xc
000FEF89  BAF203            mov dx,0x3f2
000FEF8C  EE                out dx,al
000FEF8D  B00A              mov al,0xa
000FEF8F  E888FF            call 0xef1a
000FEF92  80FC04            cmp ah,0x4
000FEF95  7302              jnc 0xef99
000FEF97  B404              mov ah,0x4
000FEF99  B07D              mov al,0x7d
000FEF9B  B9C601            mov cx,0x1c6
000FEF9E  E2FE              loop 0xef9e
000FEFA0  FEC8              dec al
000FEFA2  75F7              jnz 0xef9b
000FEFA4  FECC              dec ah
000FEFA6  75F1              jnz 0xef99
000FEFA8  C3                ret
000FEFA9  0000              add [bx+si],al
000FEFAB  0000              add [bx+si],al
000FEFAD  0000              add [bx+si],al
000FEFAF  0000              add [bx+si],al
000FEFB1  0000              add [bx+si],al
000FEFB3  0000              add [bx+si],al
000FEFB5  0000              add [bx+si],al
000FEFB7  0000              add [bx+si],al
000FEFB9  0000              add [bx+si],al
000FEFBB  0000              add [bx+si],al
000FEFBD  0000              add [bx+si],al
000FEFBF  0000              add [bx+si],al
000FEFC1  0000              add [bx+si],al
000FEFC3  0000              add [bx+si],al
000FEFC5  0000              add [bx+si],al
000FEFC7  DF02              fild word [bp+si]
000FEFC9  640209            add cl,[fs:bx+di]
000FEFCC  2AFF              sub bh,bh
000FEFCE  50                push ax
000FEFCF  F6                db 0xf6
000FEFD0  0F                db 0x0f
000FEFD1  04EA              add al,0xea
000FEFD3  B30E              mov bl,0xe
000FEFD5  00FC              add ah,bh
000FEFD7  05C400            add ax,0xc4
000FEFDA  0100              add [bx+si],ax
000FEFDC  0400              add al,0x0
000FEFDE  07                pop es
000FEFDF  A6                cmpsb
000FEFE0  C200BA            ret 0xba00
000FEFE3  01C4              add sp,ax
000FEFE5  0003              add [bp+di],al
000FEFE7  19B40060          sbb [si+0x6000],si
000FEFEB  4F                dec di
000FEFEC  56                push si
000FEFED  3A5160            cmp dl,[bx+di+0x60]
000FEFF0  701F              jo 0xf011
000FEFF2  000D              add [di],cl
000FEFF4  0B0D              or cx,[di]
000FEFF6  0000              add [bx+si],al
000FEFF8  0000              add [bx+si],al
000FEFFA  5E                pop si
000FEFFB  2E5D              cs pop bp
000FEFFD  280D              sub [di],cl
000FEFFF  5E                pop si
000FF000  6E                outsb
000FF001  A3FF00            mov [0xff],ax
000FF004  CC                int3
000FF005  01CA              add dx,cx
000FF007  09CE              or si,cx
000FF009  0000              add [bx+si],al
000FF00B  0000              add [bx+si],al
000FF00D  0000              add [bx+si],al
000FF00F  0008              add [bx+si],cl
000FF011  00FF              add bh,bh
000FF013  BA14C0            mov dx,0xc014
000FF016  0000              add [bx+si],al
000FF018  0808              or [bx+si],cl
000FF01A  0808              or [bx+si],cl
000FF01C  0808              or [bx+si],cl
000FF01E  0810              or [bx+si],dl
000FF020  1818              sbb [bx+si],bl
000FF022  1818              sbb [bx+si],bl
000FF024  1818              sbb [bx+si],bl
000FF026  180E000F          sbb [0xf00],cl
000FF02A  0800              or [bx+si],al
000FF02C  B003              mov al,0x3
000FF02E  C402              les ax,[bp+si]
000FF030  0300              add ax,[bx+si]
000FF032  0302              add ax,[bp+si]
000FF034  CE                into
000FF035  05100A            add ax,0xa10
000FF038  0008              add [bx+si],cl
000FF03A  0300              add ax,[bx+si]
000FF03C  0000              add [bx+si],al
000FF03E  0000              add [bx+si],al
000FF040  0000              add [bx+si],al
000FF042  0000              add [bx+si],al
000FF044  005531            add [di+0x31],dl
000FF047  1833              sbb [bp+di],dh
000FF049  3133              xor [bp+di],si
000FF04B  D833              fdiv dword [bp+di]
000FF04D  7D37              jnl 0xf086
000FF04F  96                xchg ax,si
000FF050  32FC              xor bh,ah
000FF052  33ED              xor bp,bp
000FF054  33E9              xor bp,cx
000FF056  3403              xor al,0x3
000FF058  351635            xor ax,0x3516
000FF05B  D932              fnstenv [bp+si]
000FF05D  94                xchg ax,sp
000FF05E  366F              ss outsw
000FF060  37                aaa
000FF061  27                daa
000FF062  350B33            xor ax,0x330b
000FF065  EA6A3000FC        jmp 0xfc00:0x306a
000FF06A  E841DB            call 0xcbae
000FF06D  80FC10            cmp ah,0x10
000FF070  731F              jnc 0xf091
000FF072  8A1E1004          mov bl,[0x410]
000FF076  80E330            and bl,0x30
000FF079  80FB30            cmp bl,0x30
000FF07C  BB00B8            mov bx,0xb800
000FF07F  7503              jnz 0xf084
000FF081  BB00B0            mov bx,0xb000
000FF084  8EC3              mov es,bx
000FF086  8ADC              mov bl,ah
000FF088  32FF              xor bh,bh
000FF08A  03DB              add bx,bx
000FF08C  2EFFA74530        jmp [cs:bx+0x3045]
000FF091  C3                ret
000FF092  0000              add [bx+si],al
000FF094  0000              add [bx+si],al
000FF096  0000              add [bx+si],al
000FF098  0000              add [bx+si],al
000FF09A  0000              add [bx+si],al
000FF09C  0000              add [bx+si],al
000FF09E  0000              add [bx+si],al
000FF0A0  0000              add [bx+si],al
000FF0A2  0000              add [bx+si],al
000FF0A4  3828              cmp [bx+si],ch
000FF0A6  2D0A1F            sub ax,0x1f0a
000FF0A9  06                push es
000FF0AA  191C              sbb [si],bx
000FF0AC  0207              add al,[bx]
000FF0AE  06                push es
000FF0AF  07                pop es
000FF0B0  0000              add [bx+si],al
000FF0B2  0000              add [bx+si],al
000FF0B4  7150              jno 0xf106
000FF0B6  5A                pop dx
000FF0B7  0A1F              or bl,[bx]
000FF0B9  06                push es
000FF0BA  191C              sbb [si],bx
000FF0BC  0207              add al,[bx]
000FF0BE  06                push es
000FF0BF  07                pop es
000FF0C0  0000              add [bx+si],al
000FF0C2  0000              add [bx+si],al
000FF0C4  3828              cmp [bx+si],ch
000FF0C6  2D0A7F            sub ax,0x7f0a
000FF0C9  06                push es
000FF0CA  647002            fs jo 0xf0cf
000FF0CD  01060700          add [0x7],ax
000FF0D1  0000              add [bx+si],al
000FF0D3  006150            add [bx+di+0x50],ah
000FF0D6  52                push dx
000FF0D7  0F19061919        hint_nop8 word [0x1919]
000FF0DC  020D              add cl,[di]
000FF0DE  0B0C              or cx,[si]
000FF0E0  0000              add [bx+si],al
000FF0E2  0000              add [bx+si],al
000FF0E4  E81D00            call 0xf104
000FF0E7  8B166304          mov dx,[0x463]
000FF0EB  83C204            add dx,byte +0x4
000FF0EE  A06504            mov al,[0x465]
000FF0F1  EE                out dx,al
000FF0F2  C3                ret
000FF0F3  E80E00            call 0xf104
000FF0F6  8B166304          mov dx,[0x463]
000FF0FA  83C204            add dx,byte +0x4
000FF0FD  A06504            mov al,[0x465]
000FF100  24F7              and al,0xf7
000FF102  EE                out dx,al
000FF103  C3                ret
000FF104  8B166304          mov dx,[0x463]
000FF108  81FAB403          cmp dx,0x3b4
000FF10C  7413              jz 0xf121
000FF10E  83C206            add dx,byte +0x6
000FF111  33C9              xor cx,cx
000FF113  EC                in al,dx
000FF114  2408              and al,0x8
000FF116  7402              jz 0xf11a
000FF118  E2F9              loop 0xf113
000FF11A  EC                in al,dx
000FF11B  2408              and al,0x8
000FF11D  7502              jnz 0xf121
000FF11F  E2F9              loop 0xf11a
000FF121  C3                ret
000FF122  E80100            call 0xf126
000FF125  CB                retf
000FF126  BBE803            mov bx,0x3e8
000FF129  B92E22            mov cx,0x222e
000FF12C  7A06              jpe 0xf134
000FF12E  BBD007            mov bx,0x7d0
000FF131  B9B888            mov cx,0x88b8
000FF134  B0B6              mov al,0xb6
000FF136  E643              out 0x43,al
000FF138  8AC3              mov al,bl
000FF13A  E642              out 0x42,al
000FF13C  8AC7              mov al,bh
000FF13E  E642              out 0x42,al
000FF140  E461              in al,0x61
000FF142  0C03              or al,0x3
000FF144  E661              out 0x61,al
000FF146  B402              mov ah,0x2
000FF148  51                push cx
000FF149  E2FE              loop 0xf149
000FF14B  59                pop cx
000FF14C  FECC              dec ah
000FF14E  75F8              jnz 0xf148
000FF150  24FE              and al,0xfe
000FF152  E661              out 0x61,al
000FF154  C3                ret
000FF155  BF4E04            mov di,0x44e
000FF158  B91500            mov cx,0x15
000FF15B  33C0              xor ax,ax
000FF15D  8EC0              mov es,ax
000FF15F  FC                cld
000FF160  F3AA              rep stosb
000FF162  A01004            mov al,[0x410]
000FF165  2430              and al,0x30
000FF167  3C30              cmp al,0x30
000FF169  B307              mov bl,0x7
000FF16B  7403              jz 0xf170
000FF16D  8A5E00            mov bl,[bp+0x0]
000FF170  881E4904          mov [0x449],bl
000FF174  C43E7400          les di,[0x74]
000FF178  B024              mov al,0x24
000FF17A  E8F9DA            call 0xcc76
000FF17D  7402              jz 0xf181
000FF17F  B007              mov al,0x7
000FF181  8AE8              mov ch,al
000FF183  BE8831            mov si,0x3188
000FF186  EB69              jmp short 0xf1f1
000FF188  83EA05            sub dx,byte +0x5
000FF18B  89166304          mov [0x463],dx
000FF18F  A36504            mov [0x465],ax
000FF192  F6C302            test bl,0x2
000FF195  B82800            mov ax,0x28
000FF198  7402              jz 0xf19c
000FF19A  D1E0              shl ax,1
000FF19C  A34A04            mov [0x44a],ax
000FF19F  03DB              add bx,bx
000FF1A1  2E8B870838        mov ax,[cs:bx+0x3808]
000FF1A6  A34C04            mov [0x44c],ax
000FF1A9  C70660040706      mov word [0x460],0x607
000FF1AF  E932FF            jmp 0xf0e4
000FF1B2  8EDB              mov ds,bx
000FF1B4  B023              mov al,0x23
000FF1B6  BBBC31            mov bx,0x31bc
000FF1B9  E9C5DA            jmp 0xcc81
000FF1BC  2430              and al,0x30
000FF1BE  7506              jnz 0xf1c6
000FF1C0  BED131            mov si,0x31d1
000FF1C3  E9C8CE            jmp 0xc08e
000FF1C6  BECD31            mov si,0x31cd
000FF1C9  B003              mov al,0x3
000FF1CB  EB0F              jmp short 0xf1dc
000FF1CD  4A                dec dx
000FF1CE  EE                out dx,al
000FF1CF  B007              mov al,0x7
000FF1D1  BED631            mov si,0x31d6
000FF1D4  EB06              jmp short 0xf1dc
000FF1D6  4A                dec dx
000FF1D7  EE                out dx,al
000FF1D8  8CD8              mov ax,ds
000FF1DA  FFE0              jmp ax
000FF1DC  8BF8              mov di,ax
000FF1DE  B024              mov al,0x24
000FF1E0  BBE631            mov bx,0x31e6
000FF1E3  E99BDA            jmp 0xcc81
000FF1E6  8AE8              mov ch,al
000FF1E8  8BDF              mov bx,di
000FF1EA  8CC8              mov ax,cs
000FF1EC  8EC0              mov es,ax
000FF1EE  BFA430            mov di,0x30a4
000FF1F1  BAD903            mov dx,0x3d9
000FF1F4  33C0              xor ax,ax
000FF1F6  80FB07            cmp bl,0x7
000FF1F9  7504              jnz 0xf1ff
000FF1FB  B2B9              mov dl,0xb9
000FF1FD  FEC4              inc ah
000FF1FF  EE                out dx,al
000FF200  4A                dec dx
000FF201  8AC4              mov al,ah
000FF203  EE                out dx,al
000FF204  80EA04            sub dl,0x4
000FF207  8AFD              mov bh,ch
000FF209  8AC3              mov al,bl
000FF20B  3C06              cmp al,0x6
000FF20D  7502              jnz 0xf211
000FF20F  FEC8              dec al
000FF211  24FE              and al,0xfe
000FF213  32E4              xor ah,ah
000FF215  B103              mov cl,0x3
000FF217  D3E0              shl ax,cl
000FF219  03F8              add di,ax
000FF21B  B91000            mov cx,0x10
000FF21E  33C0              xor ax,ax
000FF220  268A25            mov ah,[es:di]
000FF223  EF                out dx,ax
000FF224  47                inc di
000FF225  FEC0              inc al
000FF227  E2F7              loop 0xf220
000FF229  FC                cld
000FF22A  80C204            add dl,0x4
000FF22D  80FB07            cmp bl,0x7
000FF230  7411              jz 0xf243
000FF232  B012              mov al,0x12
000FF234  EE                out dx,al
000FF235  B800B8            mov ax,0xb800
000FF238  8EC0              mov es,ax
000FF23A  B90020            mov cx,0x2000
000FF23D  33C0              xor ax,ax
000FF23F  33FF              xor di,di
000FF241  F3AB              rep stosw
000FF243  8AEF              mov ch,bh
000FF245  32FF              xor bh,bh
000FF247  2E8A871838        mov al,[cs:bx+0x3818]
000FF24C  24F7              and al,0xf7
000FF24E  EE                out dx,al
000FF24F  8AE5              mov ah,ch
000FF251  BF00B0            mov di,0xb000
000FF254  B90008            mov cx,0x800
000FF257  80FB07            cmp bl,0x7
000FF25A  740B              jz 0xf267
000FF25C  F6C304            test bl,0x4
000FF25F  7510              jnz 0xf271
000FF261  BF00B8            mov di,0xb800
000FF264  B90020            mov cx,0x2000
000FF267  B020              mov al,0x20
000FF269  8EC7              mov es,di
000FF26B  33FF              xor di,di
000FF26D  F3AB              rep stosw
000FF26F  8AFC              mov bh,ah
000FF271  B010              mov al,0x10
000FF273  80FB05            cmp bl,0x5
000FF276  7411              jz 0xf289
000FF278  8AC7              mov al,bh
000FF27A  B104              mov cl,0x4
000FF27C  D2C8              ror al,cl
000FF27E  2407              and al,0x7
000FF280  0C30              or al,0x30
000FF282  80FB06            cmp bl,0x6
000FF285  7502              jnz 0xf289
000FF287  0C07              or al,0x7
000FF289  42                inc dx
000FF28A  EE                out dx,al
000FF28B  8AE0              mov ah,al
000FF28D  32FF              xor bh,bh
000FF28F  2E8A871838        mov al,[cs:bx+0x3818]
000FF294  FFE6              jmp si
000FF296  803E490403        cmp byte [0x449],0x3
000FF29B  773B              ja 0xf2d8
000FF29D  8A5E00            mov bl,[bp+0x0]
000FF2A0  80FB04            cmp bl,0x4
000FF2A3  720C              jc 0xf2b1
000FF2A5  80FB08            cmp bl,0x8
000FF2A8  732E              jnc 0xf2d8
000FF2AA  803E490401        cmp byte [0x449],0x1
000FF2AF  7727              ja 0xf2d8
000FF2B1  881E6204          mov [0x462],bl
000FF2B5  A14C04            mov ax,[0x44c]
000FF2B8  32FF              xor bh,bh
000FF2BA  53                push bx
000FF2BB  F7E3              mul bx
000FF2BD  A34E04            mov [0x44e],ax
000FF2C0  D1E8              shr ax,1
000FF2C2  8BD8              mov bx,ax
000FF2C4  E83DFE            call 0xf104
000FF2C7  B40C              mov ah,0xc
000FF2C9  E88400            call 0xf350
000FF2CC  5B                pop bx
000FF2CD  03DB              add bx,bx
000FF2CF  8B8F5004          mov cx,[bx+0x450]
000FF2D3  D1EB              shr bx,1
000FF2D5  EB70              jmp short 0xf347
000FF2D7  90                nop
000FF2D8  C3                ret
000FF2D9  E828FE            call 0xf104
000FF2DC  8B4602            mov ax,[bp+0x2]
000FF2DF  0AE4              or ah,ah
000FF2E1  8A266604          mov ah,[0x466]
000FF2E5  7507              jnz 0xf2ee
000FF2E7  80E420            and ah,0x20
000FF2EA  0AC4              or al,ah
000FF2EC  EB11              jmp short 0xf2ff
000FF2EE  86C4              xchg ah,al
000FF2F0  24DF              and al,0xdf
000FF2F2  803E490405        cmp byte [0x449],0x5
000FF2F7  7406              jz 0xf2ff
000FF2F9  0AE4              or ah,ah
000FF2FB  7402              jz 0xf2ff
000FF2FD  0C20              or al,0x20
000FF2FF  A26604            mov [0x466],al
000FF302  8B166304          mov dx,[0x463]
000FF306  83C205            add dx,byte +0x5
000FF309  EE                out dx,al
000FF30A  C3                ret
000FF30B  A14904            mov ax,[0x449]
000FF30E  894600            mov [bp+0x0],ax
000FF311  A06204            mov al,[0x462]
000FF314  884603            mov [bp+0x3],al
000FF317  C3                ret
000FF318  890E6004          mov [0x460],cx
000FF31C  803E490407        cmp byte [0x449],0x7
000FF321  7408              jz 0xf32b
000FF323  80FD20            cmp ch,0x20
000FF326  7203              jc 0xf32b
000FF328  B91E1E            mov cx,0x1e1e
000FF32B  B40A              mov ah,0xa
000FF32D  8BD9              mov bx,cx
000FF32F  EB1F              jmp short 0xf350
000FF331  8A5E03            mov bl,[bp+0x3]
000FF334  32FF              xor bh,bh
000FF336  D1E3              shl bx,1
000FF338  89975004          mov [bx+0x450],dx
000FF33C  D1EB              shr bx,1
000FF33E  8BCA              mov cx,dx
000FF340  3A1E6204          cmp bl,[0x462]
000FF344  7401              jz 0xf347
000FF346  C3                ret
000FF347  E84700            call 0xf391
000FF34A  8BDF              mov bx,di
000FF34C  D1EB              shr bx,1
000FF34E  B40E              mov ah,0xe
000FF350  8B166304          mov dx,[0x463]
000FF354  8AC4              mov al,ah
000FF356  EE                out dx,al
000FF357  42                inc dx
000FF358  8AC7              mov al,bh
000FF35A  EE                out dx,al
000FF35B  4A                dec dx
000FF35C  8AC4              mov al,ah
000FF35E  40                inc ax
000FF35F  EE                out dx,al
000FF360  8AC3              mov al,bl
000FF362  42                inc dx
000FF363  EE                out dx,al
000FF364  4A                dec dx
000FF365  C3                ret
000FF366  A04904            mov al,[0x449]
000FF369  3C07              cmp al,0x7
000FF36B  740A              jz 0xf377
000FF36D  A804              test al,0x4
000FF36F  7406              jz 0xf377
000FF371  8B0E5004          mov cx,[0x450]
000FF375  EB43              jmp short 0xf3ba
000FF377  8A5E03            mov bl,[bp+0x3]
000FF37A  32FF              xor bh,bh
000FF37C  D0E3              shl bl,1
000FF37E  8B8F5004          mov cx,[bx+0x450]
000FF382  D0EB              shr bl,1
000FF384  EB0B              jmp short 0xf391
000FF386  A04904            mov al,[0x449]
000FF389  3C07              cmp al,0x7
000FF38B  7404              jz 0xf391
000FF38D  A804              test al,0x4
000FF38F  7529              jnz 0xf3ba
000FF391  A14A04            mov ax,[0x44a]
000FF394  D1E0              shl ax,1
000FF396  F6E5              mul ch
000FF398  8BF9              mov di,cx
000FF39A  81E7FF00          and di,0xff
000FF39E  D1E7              shl di,1
000FF3A0  03F8              add di,ax
000FF3A2  A14C04            mov ax,[0x44c]
000FF3A5  81E3FF00          and bx,0xff
000FF3A9  7409              jz 0xf3b4
000FF3AB  52                push dx
000FF3AC  A14C04            mov ax,[0x44c]
000FF3AF  F7E3              mul bx
000FF3B1  03F8              add di,ax
000FF3B3  5A                pop dx
000FF3B4  F8                clc
000FF3B5  C3                ret
000FF3B6  8B0E5004          mov cx,[0x450]
000FF3BA  B85000            mov ax,0x50
000FF3BD  F6E5              mul ch
000FF3BF  D1E0              shl ax,1
000FF3C1  D1E0              shl ax,1
000FF3C3  8BF9              mov di,cx
000FF3C5  81E7FF00          and di,0xff
000FF3C9  03C7              add ax,di
000FF3CB  803E490406        cmp byte [0x449],0x6
000FF3D0  7402              jz 0xf3d4
000FF3D2  03C7              add ax,di
000FF3D4  8BF8              mov di,ax
000FF3D6  F9                stc
000FF3D7  C3                ret
000FF3D8  8A5E03            mov bl,[bp+0x3]
000FF3DB  02DB              add bl,bl
000FF3DD  32FF              xor bh,bh
000FF3DF  8B875004          mov ax,[bx+0x450]
000FF3E3  894606            mov [bp+0x6],ax
000FF3E6  A16004            mov ax,[0x460]
000FF3E9  894604            mov [bp+0x4],ax
000FF3EC  C3                ret
000FF3ED  8BCA              mov cx,dx
000FF3EF  2AE8              sub ch,al
000FF3F1  8B1E4A04          mov bx,[0x44a]
000FF3F5  D1E3              shl bx,1
000FF3F7  F7DB              neg bx
000FF3F9  FD                std
000FF3FA  EB0B              jmp short 0xf407
000FF3FC  8BD1              mov dx,cx
000FF3FE  02E8              add ch,al
000FF400  8B1E4A04          mov bx,[0x44a]
000FF404  D1E3              shl bx,1
000FF406  FC                cld
000FF407  53                push bx
000FF408  8A1E6204          mov bl,[0x462]
000FF40C  E877FF            call 0xf386
000FF40F  8BF7              mov si,di
000FF411  8BCA              mov cx,dx
000FF413  E870FF            call 0xf386
000FF416  E8EBFC            call 0xf104
000FF419  5A                pop dx
000FF41A  8A4E06            mov cl,[bp+0x6]
000FF41D  2A4E04            sub cl,[bp+0x4]
000FF420  FEC1              inc cl
000FF422  32ED              xor ch,ch
000FF424  8A7E03            mov bh,[bp+0x3]
000FF427  8A5E07            mov bl,[bp+0x7]
000FF42A  2A5E05            sub bl,[bp+0x5]
000FF42D  8A4600            mov al,[bp+0x0]
000FF430  2AD8              sub bl,al
000FF432  FEC3              inc bl
000FF434  E82F00            call 0xf466
000FF437  723D              jc 0xf476
000FF439  0AC0              or al,al
000FF43B  7418              jz 0xf455
000FF43D  06                push es
000FF43E  1F                pop ds
000FF43F  56                push si
000FF440  57                push di
000FF441  51                push cx
000FF442  F3A5              rep movsw
000FF444  59                pop cx
000FF445  5F                pop di
000FF446  5E                pop si
000FF447  03F2              add si,dx
000FF449  03FA              add di,dx
000FF44B  FECB              dec bl
000FF44D  75F0              jnz 0xf43f
000FF44F  8AD8              mov bl,al
000FF451  33C0              xor ax,ax
000FF453  8ED8              mov ds,ax
000FF455  8AE7              mov ah,bh
000FF457  B020              mov al,0x20
000FF459  57                push di
000FF45A  51                push cx
000FF45B  F3AB              rep stosw
000FF45D  59                pop cx
000FF45E  5F                pop di
000FF45F  03FA              add di,dx
000FF461  FECB              dec bl
000FF463  75F4              jnz 0xf459
000FF465  C3                ret
000FF466  803E490407        cmp byte [0x449],0x7
000FF46B  7408              jz 0xf475
000FF46D  F606490404        test byte [0x449],0x4
000FF472  7401              jz 0xf475
000FF474  F9                stc
000FF475  C3                ret
000FF476  50                push ax
000FF477  803E490406        cmp byte [0x449],0x6
000FF47C  740A              jz 0xf488
000FF47E  03C9              add cx,cx
000FF480  0AF6              or dh,dh
000FF482  7917              jns 0xf49b
000FF484  47                inc di
000FF485  46                inc si
000FF486  EB0B              jmp short 0xf493
000FF488  8BC2              mov ax,dx
000FF48A  D1E8              shr ax,1
000FF48C  98                cbw
000FF48D  8BD0              mov dx,ax
000FF48F  0AF6              or dh,dh
000FF491  7908              jns 0xf49b
000FF493  81C7F000          add di,0xf0
000FF497  81C6F000          add si,0xf0
000FF49B  58                pop ax
000FF49C  0AC0              or al,al
000FF49E  742C              jz 0xf4cc
000FF4A0  D0E3              shl bl,1
000FF4A2  D0E3              shl bl,1
000FF4A4  06                push es
000FF4A5  1F                pop ds
000FF4A6  56                push si
000FF4A7  57                push di
000FF4A8  51                push cx
000FF4A9  F3A4              rep movsb
000FF4AB  59                pop cx
000FF4AC  5F                pop di
000FF4AD  5E                pop si
000FF4AE  56                push si
000FF4AF  57                push di
000FF4B0  51                push cx
000FF4B1  81C70020          add di,0x2000
000FF4B5  81C60020          add si,0x2000
000FF4B9  F3A4              rep movsb
000FF4BB  59                pop cx
000FF4BC  5F                pop di
000FF4BD  5E                pop si
000FF4BE  03FA              add di,dx
000FF4C0  03F2              add si,dx
000FF4C2  FECB              dec bl
000FF4C4  75E0              jnz 0xf4a6
000FF4C6  33F6              xor si,si
000FF4C8  8EDE              mov ds,si
000FF4CA  8AD8              mov bl,al
000FF4CC  8AC7              mov al,bh
000FF4CE  D0E3              shl bl,1
000FF4D0  D0E3              shl bl,1
000FF4D2  57                push di
000FF4D3  51                push cx
000FF4D4  F3AA              rep stosb
000FF4D6  59                pop cx
000FF4D7  5F                pop di
000FF4D8  57                push di
000FF4D9  51                push cx
000FF4DA  81C70020          add di,0x2000
000FF4DE  F3AA              rep stosb
000FF4E0  59                pop cx
000FF4E1  5F                pop di
000FF4E2  03FA              add di,dx
000FF4E4  FECB              dec bl
000FF4E6  75EA              jnz 0xf4d2
000FF4E8  C3                ret
000FF4E9  E87AFE            call 0xf366
000FF4EC  7303              jnc 0xf4f1
000FF4EE  E9FE01            jmp 0xf6ef
000FF4F1  268B05            mov ax,[es:di]
000FF4F4  894600            mov [bp+0x0],ax
000FF4F7  C3                ret
000FF4F8  E86601            call 0xf661
000FF4FB  53                push bx
000FF4FC  E8EC00            call 0xf5eb
000FF4FF  5B                pop bx
000FF500  E2F9              loop 0xf4fb
000FF502  C3                ret
000FF503  E860FE            call 0xf366
000FF506  8B4E04            mov cx,[bp+0x4]
000FF509  72ED              jc 0xf4f8
000FF50B  8A4600            mov al,[bp+0x0]
000FF50E  8A6602            mov ah,[bp+0x2]
000FF511  FC                cld
000FF512  AB                stosw
000FF513  E2FD              loop 0xf512
000FF515  C3                ret
000FF516  E84DFE            call 0xf366
000FF519  8B4E04            mov cx,[bp+0x4]
000FF51C  72DA              jc 0xf4f8
000FF51E  FC                cld
000FF51F  8A4600            mov al,[bp+0x0]
000FF522  AA                stosb
000FF523  47                inc di
000FF524  E2F9              loop 0xf51f
000FF526  C3                ret
000FF527  8A1E6204          mov bl,[0x462]
000FF52B  D0E3              shl bl,1
000FF52D  32FF              xor bh,bh
000FF52F  8B8F5004          mov cx,[bx+0x450]
000FF533  33D2              xor dx,dx
000FF535  86D1              xchg cl,dl
000FF537  D0EB              shr bl,1
000FF539  E84AFE            call 0xf386
000FF53C  1AE4              sbb ah,ah
000FF53E  8A4600            mov al,[bp+0x0]
000FF541  3C20              cmp al,0x20
000FF543  7322              jnc 0xf567
000FF545  3C07              cmp al,0x7
000FF547  7503              jnz 0xf54c
000FF549  E9E2FB            jmp 0xf12e
000FF54C  3C0A              cmp al,0xa
000FF54E  7444              jz 0xf594
000FF550  3C08              cmp al,0x8
000FF552  750A              jnz 0xf55e
000FF554  0AD2              or dl,dl
000FF556  7501              jnz 0xf559
000FF558  C3                ret
000FF559  FECA              dec dl
000FF55B  EB79              jmp short 0xf5d6
000FF55D  90                nop
000FF55E  3C0D              cmp al,0xd
000FF560  7505              jnz 0xf567
000FF562  B200              mov dl,0x0
000FF564  EB70              jmp short 0xf5d6
000FF566  90                nop
000FF567  57                push di
000FF568  03FA              add di,dx
000FF56A  03FA              add di,dx
000FF56C  0AE4              or ah,ah
000FF56E  7506              jnz 0xf576
000FF570  8A4600            mov al,[bp+0x0]
000FF573  AA                stosb
000FF574  EB13              jmp short 0xf589
000FF576  52                push dx
000FF577  51                push cx
000FF578  803E490406        cmp byte [0x449],0x6
000FF57D  7502              jnz 0xf581
000FF57F  2BFA              sub di,dx
000FF581  E8DD00            call 0xf661
000FF584  E86400            call 0xf5eb
000FF587  59                pop cx
000FF588  5A                pop dx
000FF589  5F                pop di
000FF58A  FEC2              inc dl
000FF58C  3A164A04          cmp dl,[0x44a]
000FF590  7244              jc 0xf5d6
000FF592  32D2              xor dl,dl
000FF594  80FD18            cmp ch,0x18
000FF597  7233              jc 0xf5cc
000FF599  268A7D01          mov bh,[es:di+0x1]
000FF59D  E8C6FE            call 0xf466
000FF5A0  7302              jnc 0xf5a4
000FF5A2  32FF              xor bh,bh
000FF5A4  53                push bx
000FF5A5  E82E00            call 0xf5d6
000FF5A8  E859FB            call 0xf104
000FF5AB  8A1E6204          mov bl,[0x462]
000FF5AF  B90001            mov cx,0x100
000FF5B2  E8D1FD            call 0xf386
000FF5B5  8BF7              mov si,di
000FF5B7  8B3E4E04          mov di,[0x44e]
000FF5BB  8B0E4A04          mov cx,[0x44a]
000FF5BF  8BD1              mov dx,cx
000FF5C1  03D2              add dx,dx
000FF5C3  FC                cld
000FF5C4  5B                pop bx
000FF5C5  B318              mov bl,0x18
000FF5C7  B001              mov al,0x1
000FF5C9  E968FE            jmp 0xf434
000FF5CC  8B1E4A04          mov bx,[0x44a]
000FF5D0  03DB              add bx,bx
000FF5D2  03FB              add di,bx
000FF5D4  FEC5              inc ch
000FF5D6  8A1E6204          mov bl,[0x462]
000FF5DA  8ACA              mov cl,dl
000FF5DC  32FF              xor bh,bh
000FF5DE  03DB              add bx,bx
000FF5E0  898F5004          mov [bx+0x450],cx
000FF5E4  03FA              add di,dx
000FF5E6  03FA              add di,dx
000FF5E8  E95FFD            jmp 0xf34a
000FF5EB  51                push cx
000FF5EC  57                push di
000FF5ED  B90800            mov cx,0x8
000FF5F0  803E490406        cmp byte [0x449],0x6
000FF5F5  7444              jz 0xf63b
000FF5F7  8A4602            mov al,[bp+0x2]
000FF5FA  2403              and al,0x3
000FF5FC  32E4              xor ah,ah
000FF5FE  8BF0              mov si,ax
000FF600  56                push si
000FF601  33C0              xor ax,ax
000FF603  1E                push ds
000FF604  8EDA              mov ds,dx
000FF606  8A2F              mov ch,[bx]
000FF608  43                inc bx
000FF609  1F                pop ds
000FF60A  D0ED              shr ch,1
000FF60C  7302              jnc 0xf610
000FF60E  0BC6              or ax,si
000FF610  D1E6              shl si,1
000FF612  D1E6              shl si,1
000FF614  0AED              or ch,ch
000FF616  75F2              jnz 0xf60a
000FF618  86E0              xchg al,ah
000FF61A  F6460280          test byte [bp+0x2],0x80
000FF61E  7403              jz 0xf623
000FF620  263305            xor ax,[es:di]
000FF623  268905            mov [es:di],ax
000FF626  B80020            mov ax,0x2000
000FF629  F6C101            test cl,0x1
000FF62C  7403              jz 0xf631
000FF62E  B850E0            mov ax,0xe050
000FF631  03F8              add di,ax
000FF633  5E                pop si
000FF634  E2CA              loop 0xf600
000FF636  5F                pop di
000FF637  47                inc di
000FF638  47                inc di
000FF639  59                pop cx
000FF63A  C3                ret
000FF63B  1E                push ds
000FF63C  8EDA              mov ds,dx
000FF63E  8A07              mov al,[bx]
000FF640  F6460280          test byte [bp+0x2],0x80
000FF644  7403              jz 0xf649
000FF646  263205            xor al,[es:di]
000FF649  268805            mov [es:di],al
000FF64C  43                inc bx
000FF64D  B80020            mov ax,0x2000
000FF650  F6C101            test cl,0x1
000FF653  7403              jz 0xf658
000FF655  B850E0            mov ax,0xe050
000FF658  03F8              add di,ax
000FF65A  E2E2              loop 0xf63e
000FF65C  1F                pop ds
000FF65D  5F                pop di
000FF65E  47                inc di
000FF65F  59                pop cx
000FF660  C3                ret
000FF661  8A6600            mov ah,[bp+0x0]
000FF664  80FC80            cmp ah,0x80
000FF667  720A              jc 0xf673
000FF669  80E47F            and ah,0x7f
000FF66C  E81600            call 0xf685
000FF66F  7507              jnz 0xf678
000FF671  B420              mov ah,0x20
000FF673  8CCA              mov dx,cs
000FF675  BB6E3A            mov bx,0x3a6e
000FF678  8AC4              mov al,ah
000FF67A  32E4              xor ah,ah
000FF67C  03C0              add ax,ax
000FF67E  03C0              add ax,ax
000FF680  03C0              add ax,ax
000FF682  03D8              add bx,ax
000FF684  C3                ret
000FF685  50                push ax
000FF686  8B1E7C00          mov bx,[0x7c]
000FF68A  8B167E00          mov dx,[0x7e]
000FF68E  8BC2              mov ax,dx
000FF690  0BC3              or ax,bx
000FF692  58                pop ax
000FF693  C3                ret
000FF694  E81D00            call 0xf6b4
000FF697  8A4600            mov al,[bp+0x0]
000FF69A  D2C8              ror al,cl
000FF69C  22C4              and al,ah
000FF69E  F6460080          test byte [bp+0x0],0x80
000FF6A2  7407              jz 0xf6ab
000FF6A4  263205            xor al,[es:di]
000FF6A7  268805            mov [es:di],al
000FF6AA  C3                ret
000FF6AB  F6D4              not ah
000FF6AD  262025            and [es:di],ah
000FF6B0  260805            or [es:di],al
000FF6B3  C3                ret
000FF6B4  B050              mov al,0x50
000FF6B6  D1CA              ror dx,1
000FF6B8  F6E2              mul dl
000FF6BA  F6C680            test dh,0x80
000FF6BD  7403              jz 0xf6c2
000FF6BF  050020            add ax,0x2000
000FF6C2  8BD1              mov dx,cx
000FF6C4  D1EA              shr dx,1
000FF6C6  D1EA              shr dx,1
000FF6C8  803E490406        cmp byte [0x449],0x6
000FF6CD  7510              jnz 0xf6df
000FF6CF  D1EA              shr dx,1
000FF6D1  03C2              add ax,dx
000FF6D3  8BF8              mov di,ax
000FF6D5  80E107            and cl,0x7
000FF6D8  FEC1              inc cl
000FF6DA  B401              mov ah,0x1
000FF6DC  D2CC              ror ah,cl
000FF6DE  C3                ret
000FF6DF  03C2              add ax,dx
000FF6E1  8BF8              mov di,ax
000FF6E3  80E103            and cl,0x3
000FF6E6  FEC1              inc cl
000FF6E8  02C9              add cl,cl
000FF6EA  B403              mov ah,0x3
000FF6EC  D2CC              ror ah,cl
000FF6EE  C3                ret
000FF6EF  8CCA              mov dx,cs
000FF6F1  BB6E3A            mov bx,0x3a6e
000FF6F4  E81200            call 0xf709
000FF6F7  720C              jc 0xf705
000FF6F9  E889FF            call 0xf685
000FF6FC  7407              jz 0xf705
000FF6FE  E80800            call 0xf709
000FF701  7302              jnc 0xf705
000FF703  0C80              or al,0x80
000FF705  884600            mov [bp+0x0],al
000FF708  C3                ret
000FF709  53                push bx
000FF70A  B98000            mov cx,0x80
000FF70D  57                push di
000FF70E  51                push cx
000FF70F  53                push bx
000FF710  B90800            mov cx,0x8
000FF713  268B05            mov ax,[es:di]
000FF716  8AE8              mov ch,al
000FF718  86E0              xchg al,ah
000FF71A  803E490406        cmp byte [0x449],0x6
000FF71F  741A              jz 0xf73b
000FF721  51                push cx
000FF722  B108              mov cl,0x8
000FF724  BE0300            mov si,0x3
000FF727  32ED              xor ch,ch
000FF729  85C6              test si,ax
000FF72B  7401              jz 0xf72e
000FF72D  F9                stc
000FF72E  D0DD              rcr ch,1
000FF730  D1E6              shl si,1
000FF732  D1E6              shl si,1
000FF734  FEC9              dec cl
000FF736  75F1              jnz 0xf729
000FF738  58                pop ax
000FF739  8AC8              mov cl,al
000FF73B  1E                push ds
000FF73C  8EDA              mov ds,dx
000FF73E  3A2F              cmp ch,[bx]
000FF740  1F                pop ds
000FF741  7520              jnz 0xf763
000FF743  B80020            mov ax,0x2000
000FF746  F6C101            test cl,0x1
000FF749  7403              jz 0xf74e
000FF74B  B850E0            mov ax,0xe050
000FF74E  03F8              add di,ax
000FF750  43                inc bx
000FF751  FEC9              dec cl
000FF753  75BE              jnz 0xf713
000FF755  58                pop ax
000FF756  59                pop cx
000FF757  5F                pop di
000FF758  5B                pop bx
000FF759  2BC3              sub ax,bx
000FF75B  D1E8              shr ax,1
000FF75D  D1E8              shr ax,1
000FF75F  D1E8              shr ax,1
000FF761  F9                stc
000FF762  C3                ret
000FF763  5B                pop bx
000FF764  59                pop cx
000FF765  5F                pop di
000FF766  83C308            add bx,byte +0x8
000FF769  E2A2              loop 0xf70d
000FF76B  33C0              xor ax,ax
000FF76D  5B                pop bx
000FF76E  C3                ret
000FF76F  E842FF            call 0xf6b4
000FF772  268A05            mov al,[es:di]
000FF775  22C4              and al,ah
000FF777  D2C0              rol al,cl
000FF779  884600            mov [bp+0x0],al
000FF77C  C3                ret
000FF77D  8B166304          mov dx,[0x463]
000FF781  83C206            add dx,byte +0x6
000FF784  EC                in al,dx
000FF785  2406              and al,0x6
000FF787  3C02              cmp al,0x2
000FF789  7408              jz 0xf793
000FF78B  7202              jc 0xf78f
000FF78D  42                inc dx
000FF78E  EE                out dx,al
000FF78F  33C0              xor ax,ax
000FF791  EB69              jmp short 0xf7fc
000FF793  83EA06            sub dx,byte +0x6
000FF796  B010              mov al,0x10
000FF798  EE                out dx,al
000FF799  42                inc dx
000FF79A  EC                in al,dx
000FF79B  8AE0              mov ah,al
000FF79D  4A                dec dx
000FF79E  B011              mov al,0x11
000FF7A0  EE                out dx,al
000FF7A1  42                inc dx
000FF7A2  EC                in al,dx
000FF7A3  83C206            add dx,byte +0x6
000FF7A6  EE                out dx,al
000FF7A7  33DB              xor bx,bx
000FF7A9  8A1E4904          mov bl,[0x449]
000FF7AD  2E8A9F0038        mov bl,[cs:bx+0x3800]
000FF7B2  2BC3              sub ax,bx
000FF7B4  720A              jc 0xf7c0
000FF7B6  8B0E4E04          mov cx,[0x44e]
000FF7BA  D1E9              shr cx,1
000FF7BC  2BC1              sub ax,cx
000FF7BE  7302              jnc 0xf7c2
000FF7C0  33C0              xor ax,ax
000FF7C2  D0EB              shr bl,1
000FF7C4  FECB              dec bl
000FF7C6  B328              mov bl,0x28
000FF7C8  7402              jz 0xf7cc
000FF7CA  D0E3              shl bl,1
000FF7CC  F6F3              div bl
000FF7CE  8AE8              mov ch,al
000FF7D0  D0E5              shl ch,1
000FF7D2  8AD4              mov dl,ah
000FF7D4  803E490406        cmp byte [0x449],0x6
000FF7D9  7502              jnz 0xf7dd
000FF7DB  D0E2              shl dl,1
000FF7DD  E886FC            call 0xf466
000FF7E0  B102              mov cl,0x2
000FF7E2  7202              jc 0xf7e6
000FF7E4  D2E5              shl ch,cl
000FF7E6  33DB              xor bx,bx
000FF7E8  8ADA              mov bl,dl
000FF7EA  41                inc cx
000FF7EB  D3E3              shl bx,cl
000FF7ED  8AF5              mov dh,ch
000FF7EF  D2EE              shr dh,cl
000FF7F1  895606            mov [bp+0x6],dx
000FF7F4  886E05            mov [bp+0x5],ch
000FF7F7  895E02            mov [bp+0x2],bx
000FF7FA  B001              mov al,0x1
000FF7FC  884601            mov [bp+0x1],al
000FF7FF  C3                ret
000FF800  0202              add al,[bp+si]
000FF802  0404              add al,0x4
000FF804  0202              add al,[bp+si]
000FF806  0204              add al,[si]
000FF808  0008              add [bx+si],cl
000FF80A  0008              add [bx+si],cl
000FF80C  0010              add [bx+si],dl
000FF80E  0010              add [bx+si],dl
000FF810  004000            add [bx+si+0x0],al
000FF813  40                inc ax
000FF814  004000            add [bx+si+0x0],al
000FF817  1028              adc [bx+si],ch
000FF819  2829              sub [bx+di],ch
000FF81B  290A              sub [bp+si],cx
000FF81D  0E                push cs
000FF81E  1A29              sbb ch,[bx+di]
000FF820  0000              add [bx+si],al
000FF822  0000              add [bx+si],al
000FF824  0000              add [bx+si],al
000FF826  0000              add [bx+si],al
000FF828  0000              add [bx+si],al
000FF82A  0000              add [bx+si],al
000FF82C  0000              add [bx+si],al
000FF82E  0000              add [bx+si],al
000FF830  0000              add [bx+si],al
000FF832  0000              add [bx+si],al
000FF834  0000              add [bx+si],al
000FF836  0000              add [bx+si],al
000FF838  0000              add [bx+si],al
000FF83A  0000              add [bx+si],al
000FF83C  0000              add [bx+si],al
000FF83E  0000              add [bx+si],al
000FF840  00EA              add dl,ch
000FF842  CE                into
000FF843  0B00              or ax,[bx+si]
000FF845  FC                cld
000FF846  0000              add [bx+si],al
000FF848  0000              add [bx+si],al
000FF84A  0000              add [bx+si],al
000FF84C  00EA              add dl,ch
000FF84E  D80B              fmul dword [bp+di]
000FF850  00FC              add ah,bh
000FF852  8A02              mov al,[bp+si]
000FF854  0300              add ax,[bx+si]
000FF856  5C                pop sp
000FF857  4C                dec sp
000FF858  61                popa
000FF859  7374              jnc 0xf8cf
000FF85B  207573            and [di+0x73],dh
000FF85E  6564206174        and [fs:bx+di+0x74],ah
000FF863  208A5C07          and [bp+si+0x75c],cl
000FF867  0002              add [bp+si],al
000FF869  038B7469          add cx,[bp+di+0x6974]
000FF86D  6D                insw
000FF86E  6520616E          and [gs:bx+di+0x6e],ah
000FF872  64206461          and [fs:si+0x61],ah
000FF876  7465              jz 0xf8dd
000FF878  8B7573            mov si,[di+0x73]
000FF87B  657220            gs jc 0xf89e
000FF87E  6F                outsw
000FF87F  7074              jo 0xf8f5
000FF881  696F6E7320        imul bp,[bx+0x6e],word 0x2073
000FF886  286966            sub [bx+di+0x66],ch
000FF889  207265            and [bp+si+0x65],dh
000FF88C  7175              jno 0xf903
000FF88E  6972656429        imul si,[bp+si+0x65],word 0x2964
000FF893  5C                pop sp
000FF894  07                pop es
000FF895  07                pop es
000FF896  07                pop es
000FF897  008F6669          add [bx+0x6966],cl
000FF89B  7420              jz 0xf8bd
000FF89D  6E                outsb
000FF89E  657720            gs ja 0xf8c1
000FF8A1  626174            bound sp,[bx+di+0x74]
000FF8A4  7465              jz 0xf90b
000FF8A6  7269              jc 0xf911
000FF8A8  65735C            gs jnc 0xf907
000FF8AB  005C43            add [si+0x43],bl
000FF8AE  686563            push word 0x6365
000FF8B1  6B206B            imul sp,[bx+si],byte +0x6b
000FF8B4  657962            gs jns 0xf919
000FF8B7  6F                outsw
000FF8B8  61                popa
000FF8B9  7264              jc 0xf91f
000FF8BB  20616E            and [bx+di+0x6e],ah
000FF8BE  64206D6F          and [fs:di+0x6f],ch
000FF8C2  7573              jnz 0xf937
000FF8C4  65005C49          add [gs:si+0x49],bl
000FF8C8  6E                outsb
000FF8C9  7365              jnc 0xf930
000FF8CB  7274              jc 0xf941
000FF8CD  206120            and [bx+di+0x20],ah
000FF8D0  8C6469            mov [si+0x69],fs
000FF8D3  736B              jnc 0xf940
000FF8D5  20696E            and [bx+di+0x6e],ch
000FF8D8  746F              jz 0xf949
000FF8DA  8E20              mov fs,[bx+si]
000FF8DC  41                inc cx
000FF8DD  5C                pop sp
000FF8DE  54                push sp
000FF8DF  68656E            push word 0x6e65
000FF8E2  207072            and [bx+si+0x72],dh
000FF8E5  657373            gs jnc 0xf95b
000FF8E8  20616E            and [bx+di+0x6e],ah
000FF8EB  7920              jns 0xf90d
000FF8ED  6B657900          imul sp,[di+0x79],byte +0x0
000FF8F1  5C                pop sp
000FF8F2  0210              add dl,[bx+si]
000FF8F4  3A02              cmp al,[bp+si]
000FF8F6  1B616C            sbb sp,[bx+di+0x6c]
000FF8F9  021D              add bl,[di]
000FF8FB  20696E            and [bx+di+0x6e],ch
000FF8FE  636F72            arpl [bx+0x72],bp
000FF901  7265              jc 0xf968
000FF903  63743A            arpl [si+0x3a],si
000FF906  5C                pop sp
000FF907  52                push dx
000FF908  4F                dec di
000FF909  4D                dec bp
000FF90A  206164            and [bx+di+0x64],ah
000FF90D  647265            fs jc 0xf975
000FF910  7373              jnc 0xf985
000FF912  203D              and [di],bh
000FF914  2010              and [bx+si],dl
000FF916  5C                pop sp
000FF917  0002              add [bp+si],al
000FF919  103A              adc [bp+si],bh
000FF91B  204661            and [bp+0x61],al
000FF91E  756C              jnz 0xf98c
000FF920  7479              jz 0xf99b
000FF922  2000              and [bx+si],al
000FF924  8C5241            mov [bp+si+0x41],ss
000FF927  4D                dec bp
000FF928  005644            add [bp+0x44],dl
000FF92B  55                push bp
000FF92C  205241            and [bp+si+0x41],dl
000FF92F  4D                dec bp
000FF930  0002              add [bp+si],al
000FF932  2002              and [bp+si],al
000FF934  1F                pop ds
000FF935  0002              add [bp+si],al
000FF937  1E                push ds
000FF938  021F              add bl,[bx]
000FF93A  00666C            add [bp+0x6c],ah
000FF93D  6F                outsw
000FF93E  7070              jo 0xf9b0
000FF940  798D              jns 0xf8cf
000FF942  021F              add bl,[bx]
000FF944  206F72            and [bx+0x72],ch
000FF947  8D8E0002          lea cx,[bp+0x200]
000FF94B  1120              adc [bx+si],sp
000FF94D  0212              add dl,[bp+si]
000FF94F  008C0214          add [si+0x1402],cl
000FF953  2002              and [bp+si],al
000FF955  150002            adc ax,0x200
000FF958  17                pop ss
000FF959  207469            and [si+0x69],dh
000FF95C  6D                insw
000FF95D  6520636C          and [gs:bp+di+0x6c],ah
000FF961  6F                outsw
000FF962  636B00            arpl [bp+di+0x0],bp
000FF965  56                push si
000FF966  44                inc sp
000FF967  55                push bp
000FF968  021F              add bl,[bx]
000FF96A  008C0218          add [si+0x1802],cl
000FF96E  021A              add bl,[bp+si]
000FF970  008C7365          add [si+0x6573],cl
000FF974  7269              jc 0xf9df
000FF976  61                popa
000FF977  6C                insb
000FF978  021A              add bl,[bp+si]
000FF97A  006D6F            add [di+0x6f],ch
000FF97D  7573              jnz 0xf9f2
000FF97F  6520636F          and [gs:bp+di+0x6f],ah
000FF983  6F                outsw
000FF984  7264              jc 0xf9ea
000FF986  696E617465        imul bp,[bp+0x61],word 0x6574
000FF98B  2002              and [bp+si],al
000FF98D  157300            adc ax,0x73
000FF990  52                push dx
000FF991  4F                dec di
000FF992  53                push bx
000FF993  021D              add bl,[di]
000FF995  006D65            add [di+0x65],ch
000FF998  6D                insw
000FF999  6F                outsw
000FF99A  7279              jc 0xfa15
000FF99C  2028              and [bx+si],ch
000FF99E  7061              jo 0xfa01
000FF9A0  7269              jc 0xfa0b
000FF9A2  7479              jz 0xfa1d
000FF9A4  206572            and [di+0x72],ah
000FF9A7  726F              jc 0xfa18
000FF9A9  7229              jc 0xf9d4
000FF9AB  008F7761          add [bx+0x6177],cl
000FF9AF  6974000204        imul si,[si+0x0],word 0x402
000FF9B4  7900              jns 0xf9b6
000FF9B6  0205              add al,[di]
000FF9B8  7900              jns 0xf9ba
000FF9BA  4D                dec bp
000FF9BB  61                popa
000FF9BC  7263              jc 0xfa21
000FF9BE  680002            push word 0x200
000FF9C1  0900              or [bx+si],ax
000FF9C3  4D                dec bp
000FF9C4  61                popa
000FF9C5  7900              jns 0xf9c7
000FF9C7  4A                dec dx
000FF9C8  756E              jnz 0xfa38
000FF9CA  65004A75          add [gs:bp+si+0x75],cl
000FF9CE  6C                insb
000FF9CF  7900              jns 0xf9d1
000FF9D1  020A              add cl,[bp+si]
000FF9D3  0002              add [bp+si],al
000FF9D5  0B00              or ax,[bx+si]
000FF9D7  4F                dec di
000FF9D8  63746F            arpl [si+0x6f],si
000FF9DB  626572            bound sp,[di+0x72]
000FF9DE  0002              add [bp+si],al
000FF9E0  0D0002            or ax,0x200
000FF9E3  0E                push cs
000FF9E4  0011              add [bx+di],dl
000FF9E6  3A12              cmp dl,[bp+si]
000FF9E8  206F6E            and [bx+0x6e],ch
000FF9EB  2013              and [bp+di],dl
000FF9ED  200F              and [bx],cl
000FF9EF  2014              and [si],dl
000FF9F1  005C8F            add [si-0x71],bl
000FF9F4  7365              jnc 0xfa5b
000FF9F6  7420              jz 0xfa18
000FF9F8  005359            add [bp+di+0x59],dl
000FF9FB  53                push bx
000FF9FC  54                push sp
000FF9FD  45                inc bp
000FF9FE  4D                dec bp
000FF9FF  2000              and [bx+si],al
000FFA01  206469            and [si+0x69],ah
000FFA04  736B              jnc 0xfa71
000FFA06  0020              add [bx+si],ah
000FFA08  647269            fs jc 0xfa74
000FFA0B  7665              jna 0xfa72
000FFA0D  00506C            add [bx+si+0x6c],dl
000FFA10  6561              gs popa
000FFA12  7365              jnc 0xfa79
000FFA14  2000              and [bx+si],al
000FFA16  0000              add [bx+si],al
000FFA18  0000              add [bx+si],al
000FFA1A  0000              add [bx+si],al
000FFA1C  0000              add [bx+si],al
000FFA1E  0000              add [bx+si],al
000FFA20  0000              add [bx+si],al
000FFA22  0000              add [bx+si],al
000FFA24  0000              add [bx+si],al
000FFA26  0000              add [bx+si],al
000FFA28  0000              add [bx+si],al
000FFA2A  0000              add [bx+si],al
000FFA2C  0000              add [bx+si],al
000FFA2E  0000              add [bx+si],al
000FFA30  0000              add [bx+si],al
000FFA32  0000              add [bx+si],al
000FFA34  0000              add [bx+si],al
000FFA36  0000              add [bx+si],al
000FFA38  0000              add [bx+si],al
000FFA3A  0000              add [bx+si],al
000FFA3C  0000              add [bx+si],al
000FFA3E  0000              add [bx+si],al
000FFA40  0000              add [bx+si],al
000FFA42  0000              add [bx+si],al
000FFA44  0000              add [bx+si],al
000FFA46  0000              add [bx+si],al
000FFA48  0000              add [bx+si],al
000FFA4A  0000              add [bx+si],al
000FFA4C  0000              add [bx+si],al
000FFA4E  0000              add [bx+si],al
000FFA50  0000              add [bx+si],al
000FFA52  0000              add [bx+si],al
000FFA54  0000              add [bx+si],al
000FFA56  0000              add [bx+si],al
000FFA58  0000              add [bx+si],al
000FFA5A  0000              add [bx+si],al
000FFA5C  0000              add [bx+si],al
000FFA5E  0000              add [bx+si],al
000FFA60  0000              add [bx+si],al
000FFA62  0000              add [bx+si],al
000FFA64  0000              add [bx+si],al
000FFA66  0000              add [bx+si],al
000FFA68  0000              add [bx+si],al
000FFA6A  0000              add [bx+si],al
000FFA6C  0000              add [bx+si],al
000FFA6E  0000              add [bx+si],al
000FFA70  0000              add [bx+si],al
000FFA72  0000              add [bx+si],al
000FFA74  0000              add [bx+si],al
000FFA76  7EC3              jng 0xfa3b
000FFA78  A5                movsw
000FFA79  81A599C37E7E      and word [di-0x3c67],0x7e7e
000FFA7F  FF                db 0xff
000FFA80  DB                db 0xdb
000FFA81  FF                db 0xff
000FFA82  DB                db 0xdb
000FFA83  E7FF              out 0xff,ax
000FFA85  7E00              jng 0xfa87
000FFA87  6C                insb
000FFA88  FE                db 0xfe
000FFA89  FE                db 0xfe
000FFA8A  7C38              jl 0xfac4
000FFA8C  1000              adc [bx+si],al
000FFA8E  0010              add [bx+si],dl
000FFA90  387CFE            cmp [si-0x2],bh
000FFA93  7C38              jl 0xfacd
000FFA95  1000              adc [bx+si],al
000FFA97  3838              cmp [bx+si],bh
000FFA99  D6                salc
000FFA9A  FE                db 0xfe
000FFA9B  D6                salc
000FFA9C  1038              adc [bx+si],bh
000FFA9E  0010              add [bx+si],dl
000FFAA0  387CFE            cmp [si-0x2],bh
000FFAA3  D6                salc
000FFAA4  1038              adc [bx+si],bh
000FFAA6  0000              add [bx+si],al
000FFAA8  183C              sbb [si],bh
000FFAAA  3C18              cmp al,0x18
000FFAAC  0000              add [bx+si],al
000FFAAE  FF                db 0xff
000FFAAF  FFE7              jmp di
000FFAB1  C3                ret
000FFAB2  C3                ret
000FFAB3  E7FF              out 0xff,ax
000FFAB5  FF00              inc word [bx+si]
000FFAB7  3C66              cmp al,0x66
000FFAB9  42                inc dx
000FFABA  42                inc dx
000FFABB  663C00            o32 cmp al,0x0
000FFABE  FFC3              inc bx
000FFAC0  99                cwd
000FFAC1  BDBD99            mov bp,0x99bd
000FFAC4  C3                ret
000FFAC5  FF0F              dec word [bx]
000FFAC7  07                pop es
000FFAC8  0F                db 0x0f
000FFAC9  7DCC              jnl 0xfa97
000FFACB  CC                int3
000FFACC  CC                int3
000FFACD  783C              js 0xfb0b
000FFACF  6666663C18        o32 cmp al,0x18
000FFAD4  7E18              jng 0xfaee
000FFAD6  3038              xor [bx+si],bh
000FFAD8  3C34              cmp al,0x34
000FFADA  30D0              xor al,dl
000FFADC  F060              lock pusha
000FFADE  3F                aas
000FFADF  333F              xor di,[bx]
000FFAE1  3333              xor si,[bp+di]
000FFAE3  DD                db 0xdd
000FFAE4  FF6699            jmp [bp-0x67]
000FFAE7  5A                pop dx
000FFAE8  24C3              and al,0xc3
000FFAEA  C3                ret
000FFAEB  245A              and al,0x5a
000FFAED  99                cwd
000FFAEE  40                inc ax
000FFAEF  707C              jo 0xfb6d
000FFAF1  7E7C              jng 0xfb6f
000FFAF3  7040              jo 0xfb35
000FFAF5  0002              add [bp+si],al
000FFAF7  0E                push cs
000FFAF8  3E7E3E            ds jng 0xfb39
000FFAFB  0E                push cs
000FFAFC  0200              add al,[bx+si]
000FFAFE  183C              sbb [si],bh
000FFB00  7E18              jng 0xfb1a
000FFB02  187E3C            sbb [bp+0x3c],bh
000FFB05  186C6C            sbb [si+0x6c],ch
000FFB08  6C                insb
000FFB09  6C                insb
000FFB0A  6C                insb
000FFB0B  006C00            add [si+0x0],ch
000FFB0E  7EF4              jng 0xfb04
000FFB10  F4                hlt
000FFB11  7434              jz 0xfb47
000FFB13  3434              xor al,0x34
000FFB15  003C              add [si],bh
000FFB17  60                pusha
000FFB18  386C6C            cmp [si+0x6c],ch
000FFB1B  380C              cmp [si],cl
000FFB1D  7800              js 0xfb1f
000FFB1F  0000              add [bx+si],al
000FFB21  007E7E            add [bp+0x7e],bh
000FFB24  7E00              jng 0xfb26
000FFB26  183C              sbb [si],bh
000FFB28  7E18              jng 0xfb42
000FFB2A  7E3C              jng 0xfb68
000FFB2C  187E18            sbb [bp+0x18],bh
000FFB2F  3C7E              cmp al,0x7e
000FFB31  1818              sbb [bx+si],bl
000FFB33  1818              sbb [bx+si],bl
000FFB35  1818              sbb [bx+si],bl
000FFB37  1818              sbb [bx+si],bl
000FFB39  1818              sbb [bx+si],bl
000FFB3B  7E3C              jng 0xfb79
000FFB3D  1800              sbb [bx+si],al
000FFB3F  0406              add al,0x6
000FFB41  FF                db 0xff
000FFB42  FF060400          inc word [0x4]
000FFB46  0020              add [bx+si],ah
000FFB48  60                pusha
000FFB49  FF                db 0xff
000FFB4A  FF6020            jmp [bx+si+0x20]
000FFB4D  0000              add [bx+si],al
000FFB4F  60                pusha
000FFB50  60                pusha
000FFB51  60                pusha
000FFB52  60                pusha
000FFB53  7E00              jng 0xfb55
000FFB55  0000              add [bx+si],al
000FFB57  2466              and al,0x66
000FFB59  FF                db 0xff
000FFB5A  FF6624            jmp [bp+0x24]
000FFB5D  0000              add [bx+si],al
000FFB5F  081C              or [si],bl
000FFB61  3E7F7F            ds jg 0xfbe3
000FFB64  7F00              jg 0xfb66
000FFB66  007F7F            add [bx+0x7f],bh
000FFB69  7F3E              jg 0xfba9
000FFB6B  1C08              sbb al,0x8
000FFB6D  0000              add [bx+si],al
000FFB6F  0000              add [bx+si],al
000FFB71  0000              add [bx+si],al
000FFB73  0000              add [bx+si],al
000FFB75  0018              add [bx+si],bl
000FFB77  1818              sbb [bx+si],bl
000FFB79  1818              sbb [bx+si],bl
000FFB7B  0018              add [bx+si],bl
000FFB7D  006C6C            add [si+0x6c],ch
000FFB80  6C                insb
000FFB81  0000              add [bx+si],al
000FFB83  0000              add [bx+si],al
000FFB85  006C6C            add [si+0x6c],ch
000FFB88  FE                db 0xfe
000FFB89  6C                insb
000FFB8A  FE                db 0xfe
000FFB8B  6C                insb
000FFB8C  6C                insb
000FFB8D  0018              add [bx+si],bl
000FFB8F  3E58              ds pop ax
000FFB91  3C1A              cmp al,0x1a
000FFB93  7C18              jl 0xfbad
000FFB95  0000              add [bx+si],al
000FFB97  63660C            arpl [bp+0xc],sp
000FFB9A  1833              sbb [bp+di],dh
000FFB9C  6300              arpl [bx+si],ax
000FFB9E  1C36              sbb al,0x36
000FFBA0  1C3B              sbb al,0x3b
000FFBA2  6E                outsb
000FFBA3  663B00            cmp eax,[bx+si]
000FFBA6  1818              sbb [bx+si],bl
000FFBA8  3000              xor [bx+si],al
000FFBAA  0000              add [bx+si],al
000FFBAC  0000              add [bx+si],al
000FFBAE  0C18              or al,0x18
000FFBB0  3030              xor [bx+si],dh
000FFBB2  3018              xor [bx+si],bl
000FFBB4  0C00              or al,0x0
000FFBB6  3018              xor [bx+si],bl
000FFBB8  0C0C              or al,0xc
000FFBBA  0C18              or al,0x18
000FFBBC  3000              xor [bx+si],al
000FFBBE  00663C            add [bp+0x3c],ah
000FFBC1  FF                db 0xff
000FFBC2  3C66              cmp al,0x66
000FFBC4  0000              add [bx+si],al
000FFBC6  0018              add [bx+si],bl
000FFBC8  187E18            sbb [bp+0x18],bh
000FFBCB  1800              sbb [bx+si],al
000FFBCD  0000              add [bx+si],al
000FFBCF  0000              add [bx+si],al
000FFBD1  0000              add [bx+si],al
000FFBD3  1818              sbb [bx+si],bl
000FFBD5  3000              xor [bx+si],al
000FFBD7  0000              add [bx+si],al
000FFBD9  7E00              jng 0xfbdb
000FFBDB  0000              add [bx+si],al
000FFBDD  0000              add [bx+si],al
000FFBDF  0000              add [bx+si],al
000FFBE1  0000              add [bx+si],al
000FFBE3  1818              sbb [bx+si],bl
000FFBE5  00060C18          add [0x180c],al
000FFBE9  3060C0            xor [bx+si-0x40],ah
000FFBEC  80007C            add byte [bx+si],0x7c
000FFBEF  C6                db 0xc6
000FFBF0  CE                into
000FFBF1  D6                salc
000FFBF2  E6C6              out 0xc6,al
000FFBF4  7C00              jl 0xfbf6
000FFBF6  1838              sbb [bx+si],bh
000FFBF8  1818              sbb [bx+si],bl
000FFBFA  1818              sbb [bx+si],bl
000FFBFC  1800              sbb [bx+si],al
000FFBFE  3C66              cmp al,0x66
000FFC00  06                push es
000FFC01  0C18              or al,0x18
000FFC03  307E00            xor [bp+0x0],bh
000FFC06  3C66              cmp al,0x66
000FFC08  06                push es
000FFC09  1C06              sbb al,0x6
000FFC0B  663C00            o32 cmp al,0x0
000FFC0E  1C3C              sbb al,0x3c
000FFC10  6C                insb
000FFC11  CC                int3
000FFC12  FE0C              dec byte [si]
000FFC14  0C00              or al,0x0
000FFC16  7E60              jng 0xfc78
000FFC18  7C06              jl 0xfc20
000FFC1A  06                push es
000FFC1B  663C00            o32 cmp al,0x0
000FFC1E  3C66              cmp al,0x66
000FFC20  60                pusha
000FFC21  7C66              jl 0xfc89
000FFC23  663C00            o32 cmp al,0x0
000FFC26  7E06              jng 0xfc2e
000FFC28  06                push es
000FFC29  0C18              or al,0x18
000FFC2B  1818              sbb [bx+si],bl
000FFC2D  003C              add [si],bh
000FFC2F  66663C66          o32 cmp al,0x66
000FFC33  663C00            o32 cmp al,0x0
000FFC36  3C66              cmp al,0x66
000FFC38  663E0C18          ds o32 or al,0x18
000FFC3C  3000              xor [bx+si],al
000FFC3E  0000              add [bx+si],al
000FFC40  1818              sbb [bx+si],bl
000FFC42  0018              add [bx+si],bl
000FFC44  1800              sbb [bx+si],al
000FFC46  0000              add [bx+si],al
000FFC48  1818              sbb [bx+si],bl
000FFC4A  0018              add [bx+si],bl
000FFC4C  1830              sbb [bx+si],dh
000FFC4E  0C18              or al,0x18
000FFC50  306030            xor [bx+si+0x30],ah
000FFC53  180C              sbb [si],cl
000FFC55  0000              add [bx+si],al
000FFC57  007E00            add [bp+0x0],bh
000FFC5A  007E00            add [bp+0x0],bh
000FFC5D  006030            add [bx+si+0x30],ah
000FFC60  180C              sbb [si],cl
000FFC62  1830              sbb [bx+si],dh
000FFC64  60                pusha
000FFC65  003C              add [si],bh
000FFC67  6606              o32 push es
000FFC69  0C18              or al,0x18
000FFC6B  0018              add [bx+si],bl
000FFC6D  007CC6            add [si-0x3a],bh
000FFC70  DE                db 0xde
000FFC71  DE                db 0xde
000FFC72  DEC0              faddp st0
000FFC74  7C00              jl 0xfc76
000FFC76  386CC6            cmp [si-0x3a],ch
000FFC79  C6                db 0xc6
000FFC7A  FEC6              inc dh
000FFC7C  C600FC            mov byte [bx+si],0xfc
000FFC7F  C6C6FC            mov dh,0xfc
000FFC82  C6C6FC            mov dh,0xfc
000FFC85  003C              add [si],bh
000FFC87  66C0C0C0          o32 rol al,byte 0xc0
000FFC8B  663C00            o32 cmp al,0x0
000FFC8E  F8                clc
000FFC8F  CC                int3
000FFC90  C6C6C6            mov dh,0xc6
000FFC93  CC                int3
000FFC94  F8                clc
000FFC95  00FE              add dh,bh
000FFC97  C0C0F8            rol al,byte 0xf8
000FFC9A  C0C0FE            rol al,byte 0xfe
000FFC9D  00FE              add dh,bh
000FFC9F  C0C0F8            rol al,byte 0xf8
000FFCA2  C0C0C0            rol al,byte 0xc0
000FFCA5  003C              add [si],bh
000FFCA7  66C0C0CE          o32 rol al,byte 0xce
000FFCAB  663E00C6          ds o32 add dh,al
000FFCAF  C6C6FE            mov dh,0xfe
000FFCB2  C6C6C6            mov dh,0xc6
000FFCB5  007830            add [bx+si+0x30],bh
000FFCB8  3030              xor [bx+si],dh
000FFCBA  3030              xor [bx+si],dh
000FFCBC  7800              js 0xfcbe
000FFCBE  06                push es
000FFCBF  06                push es
000FFCC0  06                push es
000FFCC1  06                push es
000FFCC2  C6C67C            mov dh,0x7c
000FFCC5  00C6              add dh,al
000FFCC7  CC                int3
000FFCC8  D8F0              fdiv st0
000FFCCA  D8CC              fmul st4
000FFCCC  C600C0            mov byte [bx+si],0xc0
000FFCCF  C0C0C0            rol al,byte 0xc0
000FFCD2  C0C0FE            rol al,byte 0xfe
000FFCD5  00C6              add dh,al
000FFCD7  EE                out dx,al
000FFCD8  FE                db 0xfe
000FFCD9  D6                salc
000FFCDA  C6C6C6            mov dh,0xc6
000FFCDD  00C6              add dh,al
000FFCDF  E6F6              out 0xf6,al
000FFCE1  DECE              fmulp st6
000FFCE3  C6C600            mov dh,0x0
000FFCE6  386CC6            cmp [si-0x3a],ch
000FFCE9  C6C66C            mov dh,0x6c
000FFCEC  3800              cmp [bx+si],al
000FFCEE  FC                cld
000FFCEF  C6C6FC            mov dh,0xfc
000FFCF2  C0C0C0            rol al,byte 0xc0
000FFCF5  0038              add [bx+si],bh
000FFCF7  6C                insb
000FFCF8  C6C6DA            mov dh,0xda
000FFCFB  6C                insb
000FFCFC  3600FC            ss add ah,bh
000FFCFF  C6C6FC            mov dh,0xfc
000FFD02  CC                int3
000FFD03  C6C600            mov dh,0x0
000FFD06  7CC6              jl 0xfcce
000FFD08  C07C06C6          sar byte [si+0x6],byte 0xc6
000FFD0C  7C00              jl 0xfd0e
000FFD0E  FC                cld
000FFD0F  3030              xor [bx+si],dh
000FFD11  3030              xor [bx+si],dh
000FFD13  3030              xor [bx+si],dh
000FFD15  00C6              add dh,al
000FFD17  C6C6C6            mov dh,0xc6
000FFD1A  C6C67C            mov dh,0x7c
000FFD1D  00C6              add dh,al
000FFD1F  C6C6C6            mov dh,0xc6
000FFD22  C6                db 0xc6
000FFD23  6C                insb
000FFD24  3800              cmp [bx+si],al
000FFD26  C6C6C6            mov dh,0xc6
000FFD29  D6                salc
000FFD2A  FE                db 0xfe
000FFD2B  EE                out dx,al
000FFD2C  C600C6            mov byte [bx+si],0xc6
000FFD2F  C6                db 0xc6
000FFD30  6C                insb
000FFD31  386CC6            cmp [si-0x3a],ch
000FFD34  C60066            mov byte [bx+si],0x66
000FFD37  66663C18          o32 cmp al,0x18
000FFD3B  1818              sbb [bx+si],bl
000FFD3D  00FE              add dh,bh
000FFD3F  06                push es
000FFD40  0C18              or al,0x18
000FFD42  3060FE            xor [bx+si-0x2],ah
000FFD45  003C              add [si],bh
000FFD47  3030              xor [bx+si],dh
000FFD49  3030              xor [bx+si],dh
000FFD4B  303C              xor [si],bh
000FFD4D  00C0              add al,al
000FFD4F  60                pusha
000FFD50  3018              xor [bx+si],bl
000FFD52  0C06              or al,0x6
000FFD54  0200              add al,[bx+si]
000FFD56  3C0C              cmp al,0xc
000FFD58  0C0C              or al,0xc
000FFD5A  0C0C              or al,0xc
000FFD5C  3C00              cmp al,0x0
000FFD5E  081C              or [si],bl
000FFD60  366300            arpl [ss:bx+si],ax
000FFD63  0000              add [bx+si],al
000FFD65  0000              add [bx+si],al
000FFD67  0000              add [bx+si],al
000FFD69  0000              add [bx+si],al
000FFD6B  0000              add [bx+si],al
000FFD6D  FF30              push word [bx+si]
000FFD6F  180C              sbb [si],cl
000FFD71  0000              add [bx+si],al
000FFD73  0000              add [bx+si],al
000FFD75  0000              add [bx+si],al
000FFD77  007C06            add [si+0x6],bh
000FFD7A  7EC6              jng 0xfd42
000FFD7C  7E00              jng 0xfd7e
000FFD7E  C0C0FC            rol al,byte 0xfc
000FFD81  C6C6C6            mov dh,0xc6
000FFD84  FC                cld
000FFD85  0000              add [bx+si],al
000FFD87  007CC6            add [si-0x3a],bh
000FFD8A  C0C67C            rol dh,byte 0x7c
000FFD8D  0006067E          add [0x7e06],al
000FFD91  C6C6C6            mov dh,0xc6
000FFD94  7E00              jng 0xfd96
000FFD96  0000              add [bx+si],al
000FFD98  7CC6              jl 0xfd60
000FFD9A  FEC0              inc al
000FFD9C  7C00              jl 0xfd9e
000FFD9E  3C66              cmp al,0x66
000FFDA0  60                pusha
000FFDA1  F8                clc
000FFDA2  60                pusha
000FFDA3  60                pusha
000FFDA4  60                pusha
000FFDA5  0000              add [bx+si],al
000FFDA7  007EC6            add [bp-0x3a],bh
000FFDAA  C6                db 0xc6
000FFDAB  7E06              jng 0xfdb3
000FFDAD  FC                cld
000FFDAE  C0C0FC            rol al,byte 0xfc
000FFDB1  C6C6C6            mov dh,0xc6
000FFDB4  C60018            mov byte [bx+si],0x18
000FFDB7  0018              add [bx+si],bl
000FFDB9  1818              sbb [bx+si],bl
000FFDBB  1818              sbb [bx+si],bl
000FFDBD  000C              add [si],cl
000FFDBF  000C              add [si],cl
000FFDC1  0C0C              or al,0xc
000FFDC3  0CCC              or al,0xcc
000FFDC5  78C0              js 0xfd87
000FFDC7  C0C6CC            rol dh,byte 0xcc
000FFDCA  F8                clc
000FFDCB  CC                int3
000FFDCC  C60018            mov byte [bx+si],0x18
000FFDCF  1818              sbb [bx+si],bl
000FFDD1  1818              sbb [bx+si],bl
000FFDD3  1818              sbb [bx+si],bl
000FFDD5  0000              add [bx+si],al
000FFDD7  006CFE            add [si-0x2],ch
000FFDDA  D6                salc
000FFDDB  C6C600            mov dh,0x0
000FFDDE  0000              add [bx+si],al
000FFDE0  FC                cld
000FFDE1  C6C6C6            mov dh,0xc6
000FFDE4  C60000            mov byte [bx+si],0x0
000FFDE7  007CC6            add [si-0x3a],bh
000FFDEA  C6C67C            mov dh,0x7c
000FFDED  0000              add [bx+si],al
000FFDEF  00FC              add ah,bh
000FFDF1  C6C6FC            mov dh,0xfc
000FFDF4  C0C000            rol al,byte 0x0
000FFDF7  007EC6            add [bp-0x3a],bh
000FFDFA  C6                db 0xc6
000FFDFB  7E06              jng 0xfe03
000FFDFD  06                push es
000FFDFE  0000              add [bx+si],al
000FFE00  FC                cld
000FFE01  C6C0C0            mov al,0xc0
000FFE04  C00000            rol byte [bx+si],byte 0x0
000FFE07  007CC0            add [si-0x40],bh
000FFE0A  7C06              jl 0xfe12
000FFE0C  FC                cld
000FFE0D  006060            add [bx+si+0x60],ah
000FFE10  FC                cld
000FFE11  60                pusha
000FFE12  60                pusha
000FFE13  663C00            o32 cmp al,0x0
000FFE16  0000              add [bx+si],al
000FFE18  C6C6C6            mov dh,0xc6
000FFE1B  C6                db 0xc6
000FFE1C  7E00              jng 0xfe1e
000FFE1E  0000              add [bx+si],al
000FFE20  C6C6C6            mov dh,0xc6
000FFE23  6C                insb
000FFE24  3800              cmp [bx+si],al
000FFE26  0000              add [bx+si],al
000FFE28  C6C6D6            mov dh,0xd6
000FFE2B  FE                db 0xfe
000FFE2C  6C                insb
000FFE2D  0000              add [bx+si],al
000FFE2F  00C6              add dh,al
000FFE31  6C                insb
000FFE32  386CC6            cmp [si-0x3a],ch
000FFE35  0000              add [bx+si],al
000FFE37  00C6              add dh,al
000FFE39  C6C67E            mov dh,0x7e
000FFE3C  06                push es
000FFE3D  FC                cld
000FFE3E  0000              add [bx+si],al
000FFE40  7E0C              jng 0xfe4e
000FFE42  1830              sbb [bx+si],dh
000FFE44  7E00              jng 0xfe46
000FFE46  0E                push cs
000FFE47  1818              sbb [bx+si],bl
000FFE49  7018              jo 0xfe63
000FFE4B  180E0018          sbb [0x1800],cl
000FFE4F  1818              sbb [bx+si],bl
000FFE51  0018              add [bx+si],bl
000FFE53  1818              sbb [bx+si],bl
000FFE55  007018            add [bx+si+0x18],dh
000FFE58  180E1818          sbb [0x1818],cl
000FFE5C  7000              jo 0xfe5e
000FFE5E  324C00            xor cl,[si+0x0]
000FFE61  0000              add [bx+si],al
000FFE63  0000              add [bx+si],al
000FFE65  0000              add [bx+si],al
000FFE67  183C              sbb [si],bh
000FFE69  66C3              retd
000FFE6B  C3                ret
000FFE6C  FF00              inc word [bx+si]
000FFE6E  EAD60C00FC        jmp 0xfc00:0xcd6
000FFE73  0000              add [bx+si],al
000FFE75  0000              add [bx+si],al
000FFE77  0000              add [bx+si],al
000FFE79  0000              add [bx+si],al
000FFE7B  0000              add [bx+si],al
000FFE7D  0000              add [bx+si],al
000FFE7F  0000              add [bx+si],al
000FFE81  0000              add [bx+si],al
000FFE83  0000              add [bx+si],al
000FFE85  0000              add [bx+si],al
000FFE87  0000              add [bx+si],al
000FFE89  0000              add [bx+si],al
000FFE8B  0000              add [bx+si],al
000FFE8D  0000              add [bx+si],al
000FFE8F  0000              add [bx+si],al
000FFE91  0000              add [bx+si],al
000FFE93  0000              add [bx+si],al
000FFE95  0000              add [bx+si],al
000FFE97  0000              add [bx+si],al
000FFE99  0000              add [bx+si],al
000FFE9B  0000              add [bx+si],al
000FFE9D  0000              add [bx+si],al
000FFE9F  0000              add [bx+si],al
000FFEA1  0000              add [bx+si],al
000FFEA3  0000              add [bx+si],al
000FFEA5  EA240D00FC        jmp 0xfc00:0xd24
000FFEAA  2E27              cs daa
000FFEAC  E8D1D7            call 0xd680
000FFEAF  CB                retf
000FFEB0  BAAF3E            mov dx,0x3eaf
000FFEB3  E943D9            jmp 0xd7f9
000FFEB6  002EAD8E          add [0x8ead],ch
000FFEBA  C08BD6BE6E        ror byte [bp+di-0x412a],byte 0x6e
000FFEBF  3AB1042E          cmp dh,[bx+di+0x2e04]
000FFEC3  AD                lodsw
000FFEC4  AB                stosw
000FFEC5  E2FB              loop 0xfec2
000FFEC7  33C0              xor ax,ax
000FFEC9  B10C              mov cl,0xc
000FFECB  F3AB              rep stosw
000FFECD  81FF0010          cmp di,0x1000
000FFED1  72ED              jc 0xfec0
000FFED3  8BF2              mov si,dx
000FFED5  B603              mov dh,0x3
000FFED7  C3                ret
000FFED8  2EAD              cs lodsw
000FFEDA  8BC8              mov cx,ax
000FFEDC  B82007            mov ax,0x720
000FFEDF  F3AB              rep stosw
000FFEE1  B2C0              mov dl,0xc0
000FFEE3  B020              mov al,0x20
000FFEE5  EE                out dx,al
000FFEE6  2EAC              cs lodsb
000FFEE8  FFE3              jmp bx
000FFEEA  BAC003            mov dx,0x3c0
000FFEED  32C0              xor al,al
000FFEEF  EE                out dx,al
000FFEF0  EE                out dx,al
000FFEF1  C3                ret
000FFEF2  004D3F            add [di+0x3f],cl
000FFEF5  4D                dec bp
000FFEF6  3F                aas
000FFEF7  BF174D            mov di,0x4d17
000FFEFA  3F                aas
000FFEFB  4D                dec bp
000FFEFC  3F                aas
000FFEFD  340F              xor al,0xf
000FFEFF  2F                das
000FFF00  134D3F            adc cx,[di+0x3f]
000FFF03  240D              and al,0xd
000FFF05  5F                pop di
000FFF06  11473F            adc [bx+0x3f],ax
000FFF09  47                inc di
000FFF0A  3F                aas
000FFF0B  47                inc di
000FFF0C  3F                aas
000FFF0D  47                inc di
000FFF0E  3F                aas
000FFF0F  57                push di
000FFF10  2F                das
000FFF11  47                inc di
000FFF12  3F                aas
000FFF13  6530D8            gs xor al,bl
000FFF16  0BCE              or cx,si
000FFF18  0B592C            or bx,[bx+di+0x2c]
000FFF1B  AC                lodsb
000FFF1C  0FE20B            psrad mm1,[bp+di]
000FFF1F  0011              add [bx+di],dl
000FFF21  B30E              mov bl,0xe
000FFF23  2D0BE5            sub ax,0xe50b
000FFF26  0AD6              or dl,dh
000FFF28  0C4D              or al,0x4d
000FFF2A  3F                aas
000FFF2B  4D                dec bp
000FFF2C  3F                aas
000FFF2D  A4                movsb
000FFF2E  30C7              xor bh,al
000FFF30  2F                das
000FFF31  0000              add [bx+si],al
000FFF33  0000              add [bx+si],al
000FFF35  0000              add [bx+si],al
000FFF37  0000              add [bx+si],al
000FFF39  0000              add [bx+si],al
000FFF3B  0000              add [bx+si],al
000FFF3D  0000              add [bx+si],al
000FFF3F  0000              add [bx+si],al
000FFF41  0000              add [bx+si],al
000FFF43  0000              add [bx+si],al
000FFF45  0000              add [bx+si],al
000FFF47  50                push ax
000FFF48  B020              mov al,0x20
000FFF4A  E620              out 0x20,al
000FFF4C  58                pop ax
000FFF4D  CF                iret
000FFF4E  0000              add [bx+si],al
000FFF50  0000              add [bx+si],al
000FFF52  0000              add [bx+si],al
000FFF54  EA340F00FC        jmp 0xfc00:0xf34
000FFF59  FD                std
000FFF5A  26F726F726        mul word [es:0x26f7]
000FFF5F  FD                std
000FFF60  26FD              es std
000FFF62  26F726F726        mul word [es:0x26f7]
000FFF67  FD                std
000FFF68  260227            add ah,[es:bx]
000FFF6B  B73E              mov bh,0x3e
000FFF6D  FD                std
000FFF6E  26FD              es std
000FFF70  26D83E05C4        fdivr dword [es:0xc405]
000FFF75  0001              add [bx+di],al
000FFF77  0104              add [si],ax
000FFF79  0007              add [bx],al
000FFF7B  23C2              and ax,dx
000FFF7D  00DA              add dl,bl
000FFF7F  01C4              add sp,ax
000FFF81  0003              add [bp+di],al
000FFF83  19D4              sbb sp,dx
000FFF85  00704F            add [bx+si+0x4f],dh
000FFF88  5C                pop sp
000FFF89  2F                das
000FFF8A  5F                pop di
000FFF8B  07                pop es
000FFF8C  0411              add al,0x11
000FFF8E  0007              add [bx],al
000FFF90  06                push es
000FFF91  0000              add [bx+si],al
000FFF93  0000              add [bx+si],al
000FFF95  00E1              add cl,ah
000FFF97  24C7              and al,0xc7
000FFF99  2808              sub [bx+si],cl
000FFF9B  E0F0              loopne 0xff8d
000FFF9D  A3FF00            mov [0xff],ax
000FFFA0  CC                int3
000FFFA1  01CA              add dx,cx
000FFFA3  09CE              or si,cx
000FFFA5  0000              add [bx+si],al
000FFFA7  0000              add [bx+si],al
000FFFA9  0000              add [bx+si],al
000FFFAB  000C              add [si],cl
000FFFAD  00FF              add bh,bh
000FFFAF  DA14              ficom dword [si]
000FFFB1  C00000            rol byte [bx+si],byte 0x0
000FFFB4  0102              add [bp+si],ax
000FFFB6  0304              add ax,[si]
000FFFB8  050607            add ax,0x706
000FFFBB  1011              adc [bx+di],dl
000FFFBD  1213              adc dl,[bp+di]
000FFFBF  1415              adc al,0x15
000FFFC1  16                push ss
000FFFC2  17                pop ss
000FFFC3  0800              or [bx+si],al
000FFFC5  0F0000            sldt [bx+si]
000FFFC8  B803C4            mov ax,0xc403
000FFFCB  0203              add al,[bp+di]
000FFFCD  0003              add [bp+di],al
000FFFCF  02CE              add cl,dh
000FFFD1  05100E            add ax,0xe10
000FFFD4  0020              add [bx+si],ah
000FFFD6  07                pop es
000FFFD7  0000              add [bx+si],al
000FFFD9  0000              add [bx+si],al
000FFFDB  0000              add [bx+si],al
000FFFDD  0000              add [bx+si],al
000FFFDF  0000              add [bx+si],al
000FFFE1  0000              add [bx+si],al
000FFFE3  0000              add [bx+si],al
000FFFE5  0000              add [bx+si],al
000FFFE7  0000              add [bx+si],al
000FFFE9  0000              add [bx+si],al
000FFFEB  0000              add [bx+si],al
000FFFED  0000              add [bx+si],al
000FFFEF  00EA              add dl,ch
000FFFF1  5B                pop bx
000FFFF2  2000              and [bx+si],al
000FFFF4  FC                cld
000FFFF5  07                pop es
000FFFF6  0000              add [bx+si],al
000FFFF8  0000              add [bx+si],al
000FFFFA  0000              add [bx+si],al
000FFFFC  0000              add [bx+si],al
000FFFFE  FF                db 0xff
000FFFFF  FF                db 0xff
