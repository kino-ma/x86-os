stage_2:
    cdecl   puts, stage2_str

    jmp     start_rs   ; while (1);


    ;times   (1024 * 8) - ($ - $$) db 0


section .data
    hello	db "hello", 0x0A, 0x0D, 0
    error   db "Error: sector read", 0
    stage2_str  db "this is stage 2", 0x0a, 0x0d, 0