%include "./src_asm/include/define.s"
%include "./src_asm/include/macro.s"

BITS    16

section .text

;extern  start_rs
;global  start_rs, stage_2, puts, putc, reboot, read_chs
global  stage_2, puts, putc, reboot, read_chs

stage_2:
    cdecl   puts, stage2_str

    ;jmp     start_rs
sleep:
    hlt
    jmp     sleep


%include "./src_asm/modules/real/puts.s"
%include "./src_asm/modules/real/putc.s"
%include "./src_asm/modules/real/reboot.s"
%include "./src_asm/modules/real/read_chs.s"

section .data

stage2_str  db "this is stage 2", 0x0a, 0x0d, 0