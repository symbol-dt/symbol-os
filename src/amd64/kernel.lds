ENTRY (main)

SECTIONS {
    . = 0x08800;
    .text : {
        *(.text.main);
        *(.text*);
    }
    .rodata : {
        *(.rodata*);
    }
    .data : {
        *(.data*);
    }
    .bss : {
        *(.bss*);
    }
}
