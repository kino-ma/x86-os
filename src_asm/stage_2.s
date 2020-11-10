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
    mov     ax, [BOOT + drive.no]
    cdecl   itoa, ax, .p_no, 2, 16, 0b0100
    mov     ax, [BOOT + drive.cyln]
    cdecl   itoa, ax, .p_cyln, 2, 16, 0b0100
    mov     ax, [BOOT + drive.head]
    cdecl   itoa, ax, .p_head, 2, 16, 0b0100
    mov     ax, [BOOT + drive.sect]
    cdecl   itoa, ax, .p_sect, 2, 16, 0b0100

    cdecl   puts, .t_drive
 
.t_drive    db 0x0a, 0x0d, "== BOOT DRIVE PARAMETERS ==", 0x0a, 0x0d
.t_no       db "  drive number : "
.p_no       db "..", 0x0a, 0x0d
.t_cyln     db "cylinder count : "
.p_cyln     db "..", 0x0a, 0x0d
.t_head     db "    head count : "
.p_head     db "..", 0x0a, 0x0d
.t_sect     db "  sector count : "
.p_sect     db "..", 0x0a, 0x0d, 0

ALIGN	2, db 0
BOOT:             ; ブートドライブに関する情報
    istruc drive
        at drive.no,    dw 0
        at drive.cyln,  dw 0
        at drive.head,  dw 0
        at drive.sect,  dw 2
    iend


sleep:
    hlt
    jmp     sleep


%include "./src_asm/modules/real/puts.s"
%include "./src_asm/modules/real/putc.s"
%include "./src_asm/modules/real/itoa.s"
%include "./src_asm/modules/real/reboot.s"
%include "./src_asm/modules/real/read_chs.s"
%include "./src_asm/modules/real/get_drive_param.s"

section .data

stage2_str  db "this is stage 2", 0x0a, 0x0d, 0