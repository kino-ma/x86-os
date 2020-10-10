BOOT_LOAD	equ		0x7C00 ; ブートプログラムのロード位置

ORG		BOOT_LOAD          ; プログラムがロードされるアドレスのオフセットをアセンブラに知らせる

%include "../include/macro.s"

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
    cdecl 	itoa, 8086, .s1, 8, 10, 0b0001  ; "    8086"
    cdecl	puts, .s1

    cdecl 	itoa, 8086, .s1, 8, 10, 0b0011  ; "+   8086"
    cdecl	puts, .s1

    cdecl 	itoa, -8086, .s1, 8, 10, 0b0011 ; "-   8086"
    cdecl	puts, .s1

    jmp		$ ; do nothing

.s0		db "Hello world", 0x0A, 0x0D, 0
.s1		db "........",    0x0A, 0x0D, 0

ALIGN	2, db 0
BOOT:             ; ブートドライブに関する情報
.DRIVE:		dw 0  ; ドライブ番号

%include "../modules/real/puts.s"
%include "../modules/real/itoa.s"

    times	510 - ($ - $$) db 0x00
    db		0x55, 0xAA
