ENTRY(_start)

/*出力フォーマット*/
OUTPUT_FORMAT("binary")

MEMORY {
    PRG_BOOT (xr)  : ORIGIN = 0x7c00,   LENGTH = 0x0200
    PRG_KERN (xr)  : ORIGIN = 0x280000, LENGTH = 1M
    RAM_KERN (xrw) : ORIGIN = 0x400000, LENGTH = 1M
}

/*セクション*/
SECTIONS {
    .text : {
        *(.text)
    } > ROM

    .rodata : {
        *(.rodata)
    } >  ROM

    .data : {
        *(.data)
    } > RAM AT > ROM

    .bss : {
        *(.bss)
    } > RAM
}