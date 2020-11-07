; read_chs(struct drive *d, int sect, char *dst)
read_chs:
    ; +8 | dst
    ; +6 | sector
    ; +4 | pointer to drive struct
    ; +2 | return address

    push    bp
    mov     bp, sp
    push    3           ; bp - 2 | retry count
    push    0           ; bp - 4 | count of read sectors

    ; save register
    push    bx
    push    cx
    push    dx
    push    es
    push    si

    ; start
    mov     si, [bp + 4]    ; si: struct drive
    mov     ch, [si + drive.cyln + 0]   ; CH = cylinder no (lower byte)
    mov     cl, [si + drive.cyln + 1]   ; CL = cylinder no (upper byte)
    shl     cl, 6

    ; read sectors
    mov     dh, [si + drive.head]       ; DH = head no.
    mov     dl, [si + 0]                ; DL = drive no.
    mov     ax, 0x0000                  ; AX = 0x0000
    mov     es, ax                      ; ES = segment
    mov     bx, [bp + 8]                ; BX = dst


;// retry 3 times while neither error nor success
;while (retry) {
;    // error
;    if (CF = BIOS(0x13, sect)) {
;        AL = 0;
;        return 0;
;    }
;
;    // Al is set to count of read setors
;    if (AL > 0) {
;        return 0;
;    }
;
;    retry -= 1;
;}

read_loop:
    mov     ah, 0x02        ; command `read sector`
    mov     al, [bp + 6]    ; count of sectors to read
    int     0x13            ; BIOS intrrupt
    jnc     read_success    ; CF is ON if some error occured
    mov     al, 0
    jmp     read_finish          ; break

read_success:
    cmp     al, 0
    jne     read_finish
    mov     ax, 0           ; return value
    dec     word [bp - 2]   ; decrement `retry`
    jnz     read_loop

read_finish:
    mov     ah, 0

; recover registers
    pop     si
    pop     es
    pop     dx
    pop     cx
    pop     bx

    mov     sp, bp
    pop     bp

    ret
