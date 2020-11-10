; void get_font_addr(short *out);

get_font_addr:
; +4 | addr to set address of got font data
; +2 | return address

    push    bp
    mov     bp, sp

    push    ax
    push    bx
    push    si
    push    es
    push    bp

    mov     si, [bp + 4]

.start:
    mov     ax, 0x1130      ; get current character generator info
    mov     bh, 0x06        ; VGA 8x16 font
    int     0x10            ; ES:BP = FONT ADDRESS

    mov     [si + 0], es    ; memory segment
    mov     [si + 1], bp    ; memory offset

.finish:
    pop     bp
    pop     es
    pop     si
    pop     bx
    pop     ax

    mov     sp, bp
    pop     bp

    ret