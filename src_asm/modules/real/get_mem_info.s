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