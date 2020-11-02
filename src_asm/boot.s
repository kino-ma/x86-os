BOOT_LOAD	equ		0x7C00 ; ブートプログラムのロード位置

ORG		BOOT_LOAD          ; プログラムがロードされるアドレスのオフセットをアセンブラに知らせる

;extern  start

%include "./src_asm//include/macro.s"

entry:
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

    mov		[BOOT.DRIVE], dl ; save boot drive

    ; itoa(num, buf, radix, bufsize, flags)
    cdecl	puts, .s0

    ; read next 512 bytes
    mov     ah, 0x02            ; 読み込み命令
    mov     al, 1               ; 読み込むセクタ数
    mov     ch, 0x00            ; シリンダ
    mov     cl, 0x02            ; セクタ
    mov     dh, 0x00            ; ヘッド位置
    mov     dl, [BOOT.DRIVE]    ; ドライブ番号
    mov     bx, 0x7C00 + 512    ; オフセット

;if (CF = BIOS(0x13, 0x02)) {
;    puts(.e0);
;    reboot();
;}
    int     0x13                ; 
.10Q: jnc   .10E
.10T: cdecl puts, .e0
    call reboot
.10E:

; next stage
    jmp stage_2
    ;jmp start

.s0		db "Booting...", 0x0A, 0x0D, 0
.e0     db "Error: sector read", 0

ALIGN	2, db 0
BOOT:             ; ブートドライブに関する情報
.DRIVE:		dw 0  ; ドライブ番号

%include "./src_asm/modules/real/puts.s"
%include "./src_asm/modules/real/itoa.s"
%include "./src_asm/modules/real/reboot.s"

    times	510 - ($ - $$) db 0x00
    db		0x55, 0xAA


; 512 ~
stage_2:
    cdecl   puts, .s0

    jmp     $   ; while (1);

.s0     db "Hello Stage 2!", 0x0a, 0x0d, 0

    times   (1024 * 8) - ($ - $$) db 0