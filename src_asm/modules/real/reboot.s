reboot:
    cdecl puts, wait_space

wait_for_input:
    mov     ah, 0x10
    int     0x16

    cmp     al, ' '
    jne     wait_for_input

    cdecl   puts, newline

    int 0x19

wait_space  db  0x0a, 0x0d, "Press SPACE key to reboot...", 0
newline     db  0x0a, 0x0d, 0x0a, 0x0d, 0