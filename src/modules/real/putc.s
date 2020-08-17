; +4: output char
; +2: IP (return address)
putc:
	; build stack frame
	push	bp ; 元の値
	mov		bp, sp

	; save registers
	push	ax
	push 	bx

	; start procedure
	mov		al, [bp + 4] ; get char to output
	mov		ah, 0x0E     ; teletype 1 char output
	mov		bx, 0x0000   ; set page number and char color 0
	int		0x10         ; video BIOS call

	; restore registers
	pop		bx
	pop		ax

	; discard stack frame
	mov		sp, bp
	pop		bp

	ret
