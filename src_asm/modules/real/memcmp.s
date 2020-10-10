memcmp:
	; BP+8 バイト数
	; BP+6 アドレス1
	; BP+4 アドレス0

	push	bp ; return address
	mov		bp, sp ; before value

	; save registers
	push	bx
	push	cx
	push	dx
	push	si
	push	di

	; バイト単位での比較
	repe	cmpsb ; 異なる文字がないとZFが立つ
	jnz		.10F  ; ZF == 1
	mov		ax, 0 ; 返り値0

; 一致しなかった時
.10F:
	mov		ax, -1  ; 返り値

.10E:
	; レジスタの復帰
	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx

	mov		sp, bp
	pop		bp

	ret
