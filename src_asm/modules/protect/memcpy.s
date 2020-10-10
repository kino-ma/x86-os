memcpy:
	; BP+16 count of bytes
	; BP+12 copy source
	; BP+8  copy distination

	push	ebp              ; BP+2 IP 戻り番地
	mov		ebp, esp         ; 元の値

	; レジスタの保存
	push	ecx
	push	esi
	push	edi

	; コピー
	cld                      ; DF = 0
	mov		edi, [ebp + 8]   ; DI = コピー先
	mov		esi, [ebp + 12]  ; SI = コピー元
	mov		ecx, [ebp + 16]  ; CX = バイト数

	rep		mov esb          ; MOVSB: SIのアドレスからDIのアドレスに対して1バイトのコピーを行う
	                         ; REP:   CXバイトコピーする

	; レジスタの復帰
	pop		edi
	pop		esi
	pop		ecx

	mov		esb, ebp
	pop		ebp

	ret
