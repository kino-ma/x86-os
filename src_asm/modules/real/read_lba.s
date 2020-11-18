%include "./src_asm/modules/real/lba2chs.s"

; // returns count of sectors read
; int read_lba(const struct drive *d, short lba, short n_sect, char *dst);

read_lba:
    push    bp
    mov     bp, sp

    push    si

.start:
    mov     si, [bp + 4]    ; info

    mov     al, [si + drive.no]
    mov     [.chs + drive.no], al   ; drive no.

    mov     ax, [bp + 6]    ; lba
    cdecl   puts, .m1
    cdecl   lba2chs, si, .chs, ax   ; AX = lba2chs(d, *chs, lba);
    cdecl   puts, .m2

; add
    cdecl   puts, .t2
    cdecl   itoa, word [.chs + drive.no], .t1, 4, 16, 0b0000
    cdecl   puts, .t1
    cdecl   itoa, word [.chs + drive.cyln], .t1, 4, 16, 0b0000
    cdecl   puts, .t1
    cdecl   itoa, word [.chs + drive.head], .t1, 4, 16, 0b0000
    cdecl   puts, .t1
    cdecl   itoa, word [.chs + drive.sect], .t1, 4, 16, 0b0000
    cdecl   puts, .t1
    cdecl   puts, .t2

.t1     db "...., ", 0
.t2     db 0x0a, 0x0d, 0

; add end

    cdecl   read_chs, .chs, word [bp + 8], word [bp + 10]   ; AX = read_chs(*chs, n_sect, dst)
    cdecl   puts, .m3

.lba_fail:
    cdecl   puts, .l_fail_msg
; add
    cdecl   puts, .t2
    cdecl   itoa, word [.chs + drive.no], .t1, 4, 16, 0b0000
    cdecl   puts, .t1
    cdecl   itoa, word [.chs + drive.cyln], .t1, 4, 16, 0b0000
    cdecl   puts, .t1
    cdecl   itoa, word [.chs + drive.head], .t1, 4, 16, 0b0000
    cdecl   puts, .t1
    cdecl   itoa, word [.chs + drive.sect], .t1, 4, 16, 0b0000
    cdecl   puts, .t1
    cdecl   puts, .t2
; add end

.finish:
    pop     si

    mov     sp, bp
    pop     bp

    ret

.chs:   times drive_size db 0

.l_fail_msg     db  "lba2chs fail", 0x0a, 0x0d, 0

.m1     db "1", 0
.m2     db "2", 0
.m3     db "3", 0

.buff       db "....", 0
.size_msg   db " sectors", 0x0a, 0x0d, 0