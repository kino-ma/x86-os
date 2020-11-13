; // returns 0 if fail
; // port 0x60: data write
; // port 0x64: command write
; int kbc_write(char data);


kbc_data_write:
    push    bp
    mov     bp, sp
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
    mov     al, [bp + 4]
    out     0x60, al
    jmp     .finish

; if timeout, CX will be 0
.timeout:

.finish:
    mov     ax, cx

    pop     cx

    mov     sp, bp
    pop     bp

    ret
    
kbc_cmd_write:
    push    bp
    mov     bp, sp
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
    mov     al, [bp + 4]
    out     0x64, al
    jmp     .finish

; if timeout, CX will be 0
.timeout:

.finish:
    mov     ax, cx

    pop     cx

    mov     sp, bp
    pop     bp

    ret
    


; // returns 0 if fail
; // port 0x60: data read
; int kbc_read(char *data);

kbc_data_read:
    push    bp
    mov     bp, sp
    push    cx
    push    di

    mov     cx, 0

.loop:
    in      al, 0x64    ; KBC status
    test    al, 0x01    ; ZF = AL & 0x01
    loopnz  .loop        ; while (--CX && !ZF)

.break:
    cmp     cx, 0
    jz      .timeout

.input:
    mov     ah, 0x00
    in      al, 0x60

    mov     di, [bp + 4]    ; dst
    mov     [di + 0], ax    ; write data

    jmp     .finish

; if timeout, CX will be 0
.timeout:

.finish:
    mov     ax, cx

    pop     di
    pop     cx

    mov     sp, bp
    pop     bp

    ret

.wait_msg   db ".", 0