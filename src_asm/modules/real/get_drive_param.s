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

; start
    mov     si, [bp + 4]        ; dst drive struct
    mov     ax, 0               ; initialize Disk Base Table Pointer
    mov     es, ax
    mov     di, ax              ; ES = DI = 0

    mov     ah, 8               ; specify function to call - get drive param
    mov     di, [si + drive.no] ; specify disk no.
    int     0x13                ; BIOS call (disk)

    jc      get_fail

get_success:
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
    jmp     get_finish

get_fail:
    mov     ax, 0   ; return 0 (error)

get_finish:
    push    di
    push    si
    push    es
    push    cx
    push    bx

    mov     sp, bp
    pop     bp

    ret