; void itoa(num, buff, size, radix, flag);
itoa:
    ;+12 | flags        [fill 0?][show sign?][signed?]
    ;+10 | radix
    ;+8  | size
    ;+6  | buff
    ;+4  | num
    ;+2  | IP (戻り番地)

    push    bp
    mov     bp, sp

    push    ax
    push    bx
    push    cx
    push    dx
    push    si
    push    di

    mov     ax, [bp + 4]    ; num (`val`)
    mov     si, [bp + 6]    ; buff (`dst`)
    mov     cx, [bp + 8]    ; size (buff size left)

    mov     di, si          ; バッファの最後尾
    add     di, cx          ; dst = dst[size - 1]
    dec     di

    mov     bx, word [bp + 12]  ; flags


;if (flags & 0x01 && val < 0) {
;    flags |= 2;
;}
    test    bx, 0b0001
.10Q: je    .10E
    cmp     ax, 0
.12Q: jge   .12E
    or      bx, 0b0010
.12E:
.10E:

; // 符号出力判定
; if (flags & 0x02) {
;     if (val < 0) {
;         val *= -1;
;         *si = '-';
;     } else {
;         *si = '+';
;     }
;     size -= 1;
; }
    test bx, 0b0010
.20Q:   je  .20E
    cmp     ax, 0
.22Q:   jge .22F
    neg     ax
    mov     [si], byte '-'
    jmp .22E
.22F:
    mov     [si], byte '+'
.22E:
    dec     cx
.20E:


; ASCI変換

;bx = radix
;do {
;    dx = 0;
;    dx = dx:ax % bx;
;    ax = dx:ax / bx;
;
;    dl = ASCII[dx];
;    *dst = dl;
;    dst -= 1;
;} while (ax);
    mov     bx, [bp + 10]       ; radix
.30L:
    mov     dx, 0
    div     bx      ; ax:dx <- %:/

    mov     si, dx
    mov     dl, byte [.ascii + si]

    mov     [di], dl
    dec     di

    cmp     ax, 0
    loopnz  .30L
.30E:

; // 空欄を埋める
;if (size) {
;    al = ' ';
;    if (flags & 0x04) {
;        al = '0';
;    }
;    while (--size) {
;        *dl-- = al;
;    }
;}
    cmp     cx, 0
.40Q: je    .40E
    mov     al, ' '
    cmp     [bp + 12], word 0b0100
.42Q: jne   .42E
    mov     al, '0'
.42E:
    std                 ; マイナス方向
    rep     stosb       ; while (--cx) { mov [di--], [al] }
.40E:

    pop     di
    pop     si
    pop     dx
    pop     cx
    pop     bx
    pop     ax

    mov     sp, bp
    pop     bp

    ret

.ascii db   "0123456789ABCDEF"  ; ASCII table