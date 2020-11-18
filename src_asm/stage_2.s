%include "./src_asm/modules/real/itoa.s"
%include "./src_asm/modules/real/get_drive_param.s"
%include "./src_asm/modules/real/get_font_addr.s"
%include "./src_asm/modules/real/get_mem_info.s"
%include "./src_asm/modules/real/kbc.s"

global  stage_2, puts, putc, reboot, read_chs

stage_2:
    cdecl   puts, .hello_msg
.hello_msg  db "this is stage 2", 0x0a, 0x0d, 0


get_drive:
    cdecl   puts, .msg
    cdecl   get_drive_param, BOOT
    cmp     ax, 0
    jne     .success

.fail:
    cdecl   puts, .fail_msg
    cdecl   itoa, word [BOOT + drive.no], .t1, 4, 16, 0b0000
    cdecl   puts, .t1
    cdecl   itoa, word [BOOT + drive.cyln], .t1, 4, 16, 0b0000
    cdecl   puts, .t1
    cdecl   itoa, word [BOOT + drive.head], .t1, 4, 16, 0b0000
    cdecl   puts, .t1
    cdecl   itoa, word [BOOT + drive.sect], .t1, 4, 16, 0b0000
    cdecl   puts, .t1
    cdecl   puts, .t2
    call    reboot

.msg        db "getting drive info", 0x0a, 0x0d, 0
.fail_msg   db "get_drive_param failed", 0x0a, 0x0d, 0
.t1     db "...., ", 0
.t2     db 0x0a, 0x0d, 0


.success:
    cdecl   itoa, word [BOOT + drive.no], .t1, 4, 16, 0b0000
    cdecl   puts, .t1
    cdecl   itoa, word [BOOT + drive.cyln], .t1, 4, 16, 0b0000
    cdecl   puts, .t1
    cdecl   itoa, word [BOOT + drive.head], .t1, 4, 16, 0b0000
    cdecl   puts, .t1
    cdecl   itoa, word [BOOT + drive.sect], .t1, 4, 16, 0b0000
    cdecl   puts, .t1
    cdecl   puts, .t2

load_font:
    cdecl   get_font_addr, FONT

mem_info:
    cdecl   get_mem_info

a20_gate:
    cli                             ; refuce interrupt

    cdecl   kbc_cmd_write, 0xdf
    cmp     ax, 0
    je      .fail

    sti                             ; accept interrpt

    cdecl   puts, .success_msg

    jmp     load_kernel

.fail:
    cdecl   puts, .fail_msg
    call    sleep

.success_msg    db "successfully enabled A20 gate", 0x0a, 0x0d, 0
.fail_msg    db "failed to enable A20 gate", 0x0a, 0x0d, 0


load_kernel:
    cdecl   puts, .msg

    ; read kernel next to bootloader temporary
    ;cdecl   read_lba, BOOT, BOOT_SECT, KERNEL_SECT, BOOT_END
    cdecl   read_lba, BOOT, 1, 1, BOOT_END

    cmp     ax, 1
    jne     .fail

    jmp     .success

.fail:
    cdecl   puts, .fail_msg
    cdecl   itoa, ax, .buff, 4, 16, 0b0100
    cdecl   puts, .ah_m
    cdecl   puts, .buff
    cdecl   puts, .fin_m
    jmp     sleep

.success:
    cdecl   puts, .success_msg
    jmp     sleep
;
.ah_m   db "ax = ", 0
.buff   db "....", 0
.fin_m  db 0x0a, 0x0d, 0

.msg            db "loading kernel...", 0x0a, 0x0d, 0
.success_msg    db "successfully loaded kernel", 0x0a, 0x0d, 0
.fail_msg       db "failed to load kernel", 0x0a, 0x0d, 0
%include "./src_asm/modules/real/read_lba.s"

sleep:
    cdecl   puts, .msg

.loop:
    hlt
    jmp     .loop

.msg  db "sleep...", 0x0a, 0x0d, 0


times   BOOT_SIZE - ($ - $$) db 0x00