; // returns 0 if fail
; // port 0x60: data write
; // port 0x64: command write
; int kbc_write(char port, char data);

kbc_write:
    push    bp
    mov     bp, sp
    push    bx
    push    cx

    mov     cx, 0

.loop:
    in      al, 0x64    ; KBC status
    test    al, 0x02    ; ZF = AL & 0x02
    loopnz  .loop        ; while (--CX && !ZF)

.break:
    cmp     cx, 0
    jz      .timeout

.output:
    mov     al, [bp + 6]
    mov     bl, [bp + 4]
    out     bl, al

    jmp     .finish

; if timeout, CX will be 0
.timeout:

.finish:
    mov     ax, cx

    pop     cx
    pop     bx

    mov     sp, bp
    pop     bp

    ret


kbc_data_write:
    cdecl    kbc_write, 0x60, [sp + 4]
    ret
    
kbc_cmd_write:
    cdecl    kbc_write, 0x64, [sp + 4]
    ret
    


; // returns 0 if fail
; // port 0x60: data read
; int kbc_read(char port, char *data);

kbc_read:
    push    bp
    mov     bp, sp
    push    bx
    push    cx

    mov     cx, 0

.loop:
    in      al, 0x64    ; KBC status
    test    al, 0x01    ; ZF = AL & 0x02
    loopnz  .loop        ; while (--CX && !ZF)

.break:
    cmp     cx, 0
    jz      .timeout

.output:
    mov     bl, [bp + 4]
    mov     ah, 0x00
    in      al, bl

    mov     di, [bp + 6]    ; dst
    mov     [di + 0], ax    ; write data

    jmp     .finish

; if timeout, CX will be 0
.timeout:

.finish:
    mov     ax, cx

    pop     cx

    mov     sp, bp
    pop     bp

    ret


kbc_data_read:
    cdecl    kbc_read, 0x60, [sp + 4]
    ret
    