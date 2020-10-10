memcmp:
	; BP+8 バイト数
	; BP+6 アドレス1
	; BP+4 アドレス0

	push	ebp ; return address
	mov		ebp, esp ; before value

	; save registers
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi

	; バイト単位での比較
	repe	cmpsb ; 異なる文字がないとZFが立つ
	jnz		.10F  ; ZF == 1
	mov		eax, 0 ; 返り値0

; 一致しなかった時
.10F:
	mov		eax, -1  ; 返り値

.10E:
	; レジスタの復帰
	pop		edi
	pop		esi
	pop		edx
	pop		ecx
	pop		ebx

	mov		esp, ebp
	pop		ebp

	ret
