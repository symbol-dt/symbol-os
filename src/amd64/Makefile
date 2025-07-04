TEMP	:= $(CURDIR)/build
CFLAGS	:= -I$(CURDIR)/include -nostdinc -nostdlib -static\
	-Wall -Wno-format -Wno-unused -Wno-unused-parameter -ffunction-sections \
	-ffreestanding -fno-builtin -fno-pie -m64 -c
SFLAGS	:= -f elf64
AS		:= nasm
CC		:= gcc
LD		:= ld
AR		:= ar
PRJ		:= $(CURDIR)/../..

build: clean archive bootloader kernel

debug: build
	dd if=/dev/zero of=$(PRJ)/kernel/kernel.img seek=0 bs=512 count=2880 conv=notrunc
	dd if=$(TEMP)/boot.bin of=$(PRJ)/kernel/kernel.img seek=0 bs=512 count=16 conv=notrunc
	dd if=$(TEMP)/loader.bin of=$(PRJ)/kernel/kernel.img seek=16 bs=512 count=4 conv=notrunc
	dd if=$(TEMP)/kernel.bin of=$(PRJ)/kernel/kernel.img seek=20 bs=512 count=44 conv=notrunc

clean:
ifeq ($(wildcard $(TEMP)), )
	- mkdir $(TEMP)
else
	- rm $(TEMP)/*
endif

bootloader: boot.bin loader.bin

boot.bin: boot.asm
	$(AS) boot.asm -o $(TEMP)/boot.bin -f bin -l $(TEMP)/boot.lst

loader.bin: loader.asm
	$(AS) loader.asm -o $(TEMP)/loader.bin -f bin -l $(TEMP)/loader.lst

kernel: kernel.c
	$(CC) kernel.c -o $(TEMP)/kernel.o $(CFLAGS)
	$(LD) -m elf_x86_64 $(TEMP)/kernel.o \
		-L$(TEMP) -T ./kernel.lds \
		--oformat binary -o $(TEMP)/kernel.bin

archive:
	$(MAKE) -C./lib build "AS=$(AS)" "CC=$(CC)" "AR=$(AR)" "PRJ=$(PRJ)" "TEMP=$(TEMP)" "CFLAGS=$(CFLAGS)" "SFLAGS=$(SFLAGS)"
