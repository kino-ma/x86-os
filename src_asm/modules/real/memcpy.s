memcpy:
	; BP+8 count of bytes
	; BP+6 copy source
	; BP+4 copy distination

	push	bp            ; BP+2 IP 戻り番地
	mov		bp, sp        ; 元の値

	; レジスタの保存
	push	cx
	push	si
	push	di

	; コピー
	cld                   ; DF = 0
	mov		di, [bp + 4]  ; DI = コピー先
	mov		si, [bp + 6]  ; SI = コピー元
	mov		cx, [bp + 8]  ; CX = バイト数

	rep		mov sb        ; MOVSB: SIのアドレスからDIのアドレスに対して1バイトのコピーを行う
	                      ; REP:   CXバイトコピーする

	; レジスタの復帰
	pop		di
	pop		si
	pop		ecx

	mov		sb, bp
	pop		bp

	ret
