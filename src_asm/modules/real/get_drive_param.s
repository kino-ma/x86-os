; int get_drive_param(struct drive *d)
; // success -> true
; // fail    -> false

get_drive_param:
; +4 | drive
; +2 | return address

    push    bp
    mov     bp, sp

    push    bx
    push    cx
    push    es
    push    si
    push    di

.start:
    mov     si, [bp + 4]        ; dst drive struct
    mov     ax, 0x0000          ; initialize Disk Base Table Pointer
    mov     es, ax
    mov     di, ax              ; ES = DI = 0

    mov     ah, 8               ; specify function to call - get drive param
    mov     dl, [si + drive.no] ; specify disk no.

    ; add
    cdecl   puts, .start_m
    cdecl   itoa, es, .buff, 4, 16, 0b0000
    cdecl   puts, .buff
    cdecl   itoa, di, .buff, 4, 16, 0b0000
    cdecl   puts, .buff
    cdecl   puts, .fin_m
    ; done

    int     0x13                ; BIOS call (disk)

    jc      .fail

.success:
    cdecl   puts, .success_msg
    mov     al, cl          ;
    and     ax, 0b00111111  ; AX = cl[5:0] // sector count

    shr     cl, 6           ; CX[1:0][9:2] // last index of cylinder (CL:CH)
    ror     cx, 8           ; CX           // cylinder conut - 1
    inc     cx              ; CX = CYLINDER_COUNT

    movzx   bx, dh          ; BX = head count - 1 (filling with 0: move with zero extend)
    inc     bx              ; BX = head count

    mov     [si + drive.cyln], cx   ; cylinder
    mov     [si + drive.head], bx   ; head
    mov     [si + drive.sect], ax   ; sector

    mov     ax, 1       ; return "success"
    jmp     .finish

.fail:
    cdecl   puts, .fail_msg
    cdecl   itoa, ax, .buff, 4, 16, 0b0100
    cdecl   puts, .ah_m
    cdecl   puts, .buff
    cdecl   puts, .fin_m
    mov     ax, 0   ; return 0 (error)

.finish:
    push    di
    push    si
    push    es
    push    cx
    push    bx

    mov     sp, bp
    pop     bp

    ret


.fail_msg   db "get fail", 0x0a, 0x0d, 0
.success_msg   db "get success", 0x0a, 0x0d, 0

.start_m   db "ES:DI = ", 0
.fin_m  db 0x0a, 0x0d, 0
.ah_m   db "ax = ", 0
.buff   db "....", 0