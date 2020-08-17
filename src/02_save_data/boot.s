BOOT_LOAD	equ		0x7C00 ; ブートプログラムのロード位置

ORG		BOOT_LOAD          ; プログラムがロードされるアドレスのオフセットをアセンブラに知らせる

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

	jmp		$ ; do nothing

ALIGN	2, db 0
BOOT:             ; ブートドライブに関する情報
.DRIVE:		dw 0  ; ドライブ番号

	times	510 - ($ - $$) db 0x00
	db		0x55, 0xAA
