ENTRY(main)

SECTIONS {
    . = 0x8800;
    kernel_start = .;
    .text : {
        kernel_text_start = .;
        *(.text.main);
        *(.text*);
        kernel_text_end = .;
    }
    . = ALIGN(8);
    .data : {
        kernel_data_start = .;
        *(.data*);
        kernel_data_end = .;
    }
    .rodata : {
        kernel_rodata_start = .;
        *(.rodata*);
        kernel_rodata_end = .;
    }
    . = ALIGN(4096);
    .data.init_stack : {
        *(.data.init_stack);
    }
    .bss : {
        kernel_bss_start = .;
        *(.bss*);
        kernel_bss_end = .;
    }
    kernel_end = .;
}