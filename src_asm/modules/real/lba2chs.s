; int lba2chs(const struct drive *d, struct drive *dst, short lba);

; sector < head < cylinder

lba2chs:
    push    bp
    mov     bp, sp

    push    si
    push    di
    push    bx
    push    dx

    mov     ax, 0

.start:
    mov     si, [bp + 4]            ; drive info
    mov     di, [bp + 6]            ; destination

    mov     al, [si + drive.head]   ; AL = maximum head num
    mul     byte [si + drive.sect]   ; AL = maximum head num * maxmum sector num
    ; maybe 0
    mov     bx, ax                  ; BX = sector num per a cylinder

    ; add
    
    mov     dx, 0           ; LBA (upper 2 bytes)
    mov     ax, [bp + 8]    ; LBA (lower 2 bytes)

    ; add
    cdecl   itoa, bx, .buff, 4, 16, 0b0100
    cdecl   puts, .bx_m
    cdecl   puts, .buff
    cdecl   puts, .fin_m
    ;; here
    div     bx
; DX = DX:AX % BX     // left sector count
; AX = DX:AX / BX    // cylinder no.

    mov     [di + drive.cyln], ax

    mov     ax, dx 
    div     byte [si + drive.sect]  ; AH = AX % sector num  // sector no.
                                    ; AL = AX / sector num  // head no.

    movzx   dx, ah  ; sector no. extend with 0
    inc     dx      ; sector starts from 1

    mov     ah, 0x00    ; AX = head no.

    mov     [di + drive.head], ax
    mov     [di + drive.sect], dx
    cdecl   puts, .m1

.finish:
    cdecl   puts, .m2
    pop     dx
    pop     bx
    pop     di
    pop     si

    mov     sp, bp
    pop     bp

    ret

.m1     db "a", 0
.m2     db "b", 0
.m3     db "c", 0
.m4     db "d", 0
.m5     db "e", 0
.m6     db "f", 0
.m7     db "g", 0

; add
.ax_m   db "ax = ", 0
.bx_m   db "bx = ", 0
.buff   db "....", 0
.fin_m  db 0x0a, 0x0d, 0
; add end