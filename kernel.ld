ENTRY(_start)

/*出力フォーマット*/
OUTPUT_FORMAT("binary")

MEMORY {
    RAM : ORIGIN = 0x00007c00, LENGTH = 64k
}

/*セクション*/
SECTIONS{
    .text : {
        *(.text)
    } > RAM

    .data : {
        *(.data)
    } > RAM
}