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

mem_info:
    cdecl   get_mem_info

a20_gate:
    cli                             ; refuce interrupt

    cdecl   kbc_cmd_write, 0xdf
    cmp     ax, 0
    je      .fail

    sti                             ; accept interrpt

    cdecl   puts, .success_msg

    jmp     sleep

.fail:
    cdecl   puts, .fail_msg
    call    sleep

.success_msg    db "successfully enabled A20 gate", 0x0a, 0x0d, 0
.fail_msg    db "failed to enable A20 gate", 0x0a, 0x0d, 0

sleep:
    cdecl   puts, .msg

.loop:
    hlt
    jmp     .loop

.msg  db "sleep...", 0x0a, 0x0d, 0


times   BOOT_SIZE - ($ - $$) db 0x00