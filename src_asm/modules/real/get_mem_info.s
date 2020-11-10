; void get_mem_info();

get_mem_info:
    push    eax
    push    ebx
    push    ecx
    push    edx
    push    si
    push    di
    push    bp

    mov     bp, 0
    mov     ebx, 0

.loop:
    mov     eax, 0x0000e820         ; INT15 (get memory info)
    mov     ecx, E820_RECORD_SIZE   ; ECX = require n bytes
    mov     edx, 'PAMS'             ; signature. to get mem maps
    mov     di, .buffer             ; dst buffer
    int     0x15

    cmp     eax, 'PAMS' ; if supports this BIOS call, EAX will be set to 'SMAP'
    jne     .fail       ; not supported
    jc      .fail       ; if fail, CF is set

    cdecl   put_memory_info, di

    mov     eax, [di + 16]      ; EAX = record type
    cmp     eax, 3
    jne     .next

; type 3 is record of ACPI (Advanced Configuration and Power Interface)
; save ACPI info 
.acpi:
    mov     eax, [di + 0]           ;
    mov     [ACPI_DATA.adr], eax    ; save BASE
    mov     eax, [di + 8]           ;
    mov     [ACPI_DATA.len], eax    ; save Length

.next:
    cmp     ebx, 0      ; if have finished to read all maps, EBX will be set 0
    jnz     .loop

.success:
    cdecl   puts, .success_msg

.fail:
.finish:
    pop     bp
    pop     di
    pop     si
    pop     edx
    pop     ecx
    pop     ebx
    pop     eax

    ret


ALIGN 4, db 0

.buffer:    times E820_RECORD_SIZE db 0
.success_msg    db "success loading mem info", 0x0a, 0x0d, 0


put_memory_info:
		push	bp
		mov		bp, sp

		push	bx
		push	si

		mov		si, [bp + 4]

		; Base(64bit)
		cdecl	itoa, word [si + 6], .p2 + 0, 4, 16, 0b0100
		cdecl	itoa, word [si + 4], .p2 + 4, 4, 16, 0b0100
		cdecl	itoa, word [si + 2], .p3 + 0, 4, 16, 0b0100
		cdecl	itoa, word [si + 0], .p3 + 4, 4, 16, 0b0100

		; Length(64bit)
		cdecl	itoa, word [si +14], .p4 + 0, 4, 16, 0b0100
		cdecl	itoa, word [si +12], .p4 + 4, 4, 16, 0b0100
		cdecl	itoa, word [si +10], .p5 + 0, 4, 16, 0b0100
		cdecl	itoa, word [si + 8], .p5 + 4, 4, 16, 0b0100

		; Type(32bit)
		cdecl	itoa, word [si +18], .p6 + 0, 4, 16, 0b0100
		cdecl	itoa, word [si +16], .p6 + 4, 4, 16, 0b0100

		cdecl	puts, .s1

		mov		bx, [si +16]
		and		bx, 0x07
		shl		bx, 1
		add		bx, .t0
		cdecl	puts, word [bx]

		pop		si
		pop		bx

		mov		sp, bp
		pop		bp

		ret

.s1:	db " "
.p2:	db "ZZZZZZZZ_"
.p3:	db "ZZZZZZZZ "
.p4:	db "ZZZZZZZZ_"
.p5:	db "ZZZZZZZZ "
.p6:	db "ZZZZZZZZ", 0

.s4:	db " (Unknown)", 0x0A, 0x0D, 0
.s5:	db " (usable)", 0x0A, 0x0D, 0
.s6:	db " (reserved)", 0x0A, 0x0D, 0
.s7:	db " (ACPI data)", 0x0A, 0x0D, 0
.s8:	db " (ACPI NVS)", 0x0A, 0x0D, 0
.s9:	db " (bad memory)", 0x0A, 0x0D, 0

.t0:	dw .s4, .s5, .s6, .s7, .s8, .s9, .s4, .s4
