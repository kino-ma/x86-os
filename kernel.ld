ENTRY("kernel_main")
OUTPUT_FORMAT("binary")

MEMORY {
    PRG_BOOT (xr)  : ORIGIN = 0x7c00,                               LENGTH = 0x0200
    PRG_KERN (xr)  : ORIGIN = ORIGIN(PRG_BOOT) + LENGTH(PRG_BOOT),  LENGTH = 4K
    RAM_KERN (xrw) : ORIGIN = ORIGIN(PRG_KERN) + LENGTH(PRG_KERN),  LENGTH = 8K - LENGTH(PRG_BOOT) - LENGTH(PRG_KERN)
}

SECTIONS {
    .text : {
        *(.text)
    } > PRG_KERN

    .rodata : {
        *(.rodata)
    } >  RAM_KERN

    .data : {
        *(.data)
    } > RAM_KERN

    .bss : {
        *(.bss)
    } > RAM_KERN
}