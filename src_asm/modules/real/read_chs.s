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

    ; read sectors
    mov     ch, [si + drive.cyln + 0]   ; CH = cylinder no (lower byte)
    mov     cl, [si + drive.cyln + 1]   ; CL = cylinder no (upper byte = 0..7)
    shl     cl, 6

    or      cl, [si + drive.sect]   ; CL |= sector no
    mov     dh, [si + drive.head]   ; DH = head no.
    mov     dl, [si + drive.no]     ; DL = drive no.

    mov     ax, 0x0000              ; ES:BX = dest
    mov     es, ax
    mov     bx, [bp + 8]            ; dst


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

; .10L
read_loop:
    cdecl   puts, try_msg
    mov     ah, 0x02        ; command `read sector`
    mov     al, [bp + 6]    ; count of sectors to read
    int     0x13            ; BIOS intrrupt
    jnc     read_success    ; CF is ON if some error occured

read_fail:
    cdecl   puts, fail_msg
    mov     ax, 0x0000      ; clear return value
    jmp     read_finish     ; break

; .11E
read_success:
    cdecl   puts, success_msg
    cmp     al, 0
    jne     read_finish

read_continue:
    cdecl   puts, read_continue
    mov     ax, 0           ; return value
    dec     word [bp - 2]   ; decrement `retry`
    jnz     read_loop

; .10E
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

try_msg: db "try", 0x0a, 0x0d, 0
success_msg: db "success read", 0x0a, 0x0d, 0
continue_msg: db "continue reading", 0x0a, 0x0d, 0
fail_msg: db "fail read", 0x0a, 0x0d, 0