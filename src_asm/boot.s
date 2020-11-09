%include "./src_asm/include/define.s"
%include "./src_asm/include/macro.s"

ORG		BOOT_LOAD          ; プログラムがロードされるアドレスのオフセットをアセンブラに知らせる


_start:
    jmp		ipl
    ; BPB (BIOS Parameter Block)
    times	90 - ($ - $$) db 0x90

; IPL (Initial Program Loader)
ipl:
    cli ; refuse interrupt

    mov		ax, 0x0000    ; AX = 0x0000
    mov		ds, ax        ; DS = 0x0000
    mov		es, ax        ; ES = 0x0000
    mov		ss, ax        ; SS = 0x0000
    mov		sp, BOOT_LOAD ; SP = 0x7C00

    sti ; accept interrupt

    mov		[BOOT + drive.no], dl ; save boot drive

    cdecl	puts, hello

    ; read all sectors left
    mov     bx, BOOT_SECT
    mov     cx, BOOT_LOAD + SECT_SIZE

    ; AX = read_chs(BOOT, BOOT_SECT - 1, BOOT_LOAD + SECT_SIZE)
        cdecl   read_chs, BOOT, bx, cx

    ;; copipe
    

    ;mov     ah, 0x02        ; command `read sector`
    ;mov     al, 1    ; count of sectors to read
    ;mov     ch, 0x00   ; CH = cylinder no (lower byte)
    ;mov     cl, 0x02   ; CL = cylinder no (upper byte)
    ;;shl     cl, 6
    ;mov     dh, 0x00       ; DH = head no.
    ;mov     dl, [BOOT.DRIVE]         ; DL = drive no.
    ;mov     bx, 0x7c00 + 512                ; BX = dst
;read;_:
    ;cdecl   puts, try_msg
    ;int     0x13            ; BIOS intrrupt
    ;jnc     boot_success

    ;; copipe end

;if (AX == BX) {
;    puts(error);
;    reboot();
;}

    cmp     ax, bx
    jz      boot_success
boot_error:
    cdecl puts, error
    call reboot
boot_success:
    cdecl   puts, success

; next stage
    jmp stage_2

hello:	db "hello boot loader", 0x0A, 0x0D, 0
error:  db "Error: sector read", 0
success:    db "Succedd", 0x0a, 0x0d, 0

ALIGN	2, db 0
BOOT:             ; ブートドライブに関する情報
.DRIVE:     dw 0
    istruc drive
        at drive.no,    dw 0
        at drive.cyln,  dw 0
        at drive.head,  dw 0
        at drive.sect,  dw 2
    iend

%include "./src_asm/modules/real/puts.s"
%include "./src_asm/modules/real/reboot.s"
%include "./src_asm/modules/real/read_chs.s"

    times	510 - ($ - $$) db 0x00
    db		0x55, 0xAA


; 512 ~
; stage_2
stage_2:
    cdecl   puts, stage2_str

    jmp     $   ; while (1);

stage2_str  db "this is stage 2", 0x0a, 0x0d, 0

    times   BOOT_SIZE - ($ - $$) db 0