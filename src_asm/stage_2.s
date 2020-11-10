%include "./src_asm/include/define.s"
%include "./src_asm/include/macro.s"

BITS    16

section .text

global  stage_2, puts, putc, reboot, read_chs

stage_2:
    cdecl   puts, stage2_str

get_drive:
    cdecl   get_drive_param, BOOT
    cmp     ax, 0
    jne     .success

.fail:
    cdecl   puts, .fail_msg
    call    reboot
.fail_msg   db "get_drive_param failed", 0x0a, 0x0d, 0

.success:

load_font:
    cdecl   get_font_addr, FONT


sleep:
    hlt
    jmp     sleep


ALIGN	2, db 0
BOOT:             ; ブートドライブに関する情報
    istruc drive
        at drive.no,    dw 0
        at drive.cyln,  dw 0
        at drive.head,  dw 0
        at drive.sect,  dw 2
    iend

; 7c00 in book
FONT:
    .segment    dw 0
    .offset     dw 0


%include "./src_asm/modules/real/puts.s"
%include "./src_asm/modules/real/putc.s"
%include "./src_asm/modules/real/itoa.s"
%include "./src_asm/modules/real/reboot.s"
%include "./src_asm/modules/real/read_chs.s"
%include "./src_asm/modules/real/get_drive_param.s"

section .data

stage2_str  db "this is stage 2", 0x0a, 0x0d, 0