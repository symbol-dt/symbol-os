cc		:= gcc
as		:= nasm
ld 		:= ld
ar 		:= ar

cflags	:= -m64 -nostdinc -nostdlib -static --std=c99\
			-I$(CURDIR)/include -L$(project_path)/bin\
		   -ffreestanding -ffunction-sections\
		   -Wall -Wextra -fno-builtin -fno-pie\
		   -fno-unwind-tables -fno-asynchronous-unwind-tables\
		   -fomit-frame-pointer -fno-stack-protector -fno-stack-check\
		   -Wno-pointer-to-int-cast -Wno-int-to-pointer-cast -Wunused-function
sflags	:= -f elf64
lflags	:= -m elf_x86_64 -T kernel.lds --oformat binary

ifeq ($(debug), true)
	cflags += -g -O0 -DDEBUG
else
	cflags += -O2
endif

all: clean bootloader library kernel
ifeq ($(debug), true)
	dd if=/dev/zero of=$(project_path)/bin/system.img seek=0 bs=512 count=2880 conv=notrunc
	dd if=$(project_path)/bin/boot.bin of=$(project_path)/bin/system.img seek=0 bs=512 count=16 conv=notrunc
	dd if=$(project_path)/bin/loader.bin of=$(project_path)/bin/system.img seek=16 bs=512 count=16 conv=notrunc
	dd if=$(project_path)/bin/kernel.bin of=$(project_path)/bin/system.img seek=20 bs=512 count=16 conv=notrunc
	qemu-system-x86_64 -drive format=raw,file=$(project_path)/bin/system.img -display gtk -s -S -d guest_errors
endif

clean:
	- rm $(project_path)/bin/*

bootloader: boot.asm loader.asm
ifeq ($(debug), true)
	$(as) boot.asm -f bin -o $(project_path)/bin/boot.bin -l $(project_path)/bin/boot.lst
	$(as) loader.asm -f bin -o $(project_path)/bin/loader.bin -l $(project_path)/bin/loader.lst
endif
	$(as) boot.asm -f bin -o $(project_path)/bin/boot.bin
	$(as) loader.asm -f bin -o $(project_path)/bin/loader.bin

kernel: kernel.c kernel.lds
	$(cc) $(cflags) -c kernel.c -o $(project_path)/bin/kernel.o
ifeq ($(debug), true)
	$(cc) $(cflags) -S kernel.c -o $(project_path)/bin/kernel.S
endif
	$(ld) $(lflags) $(project_path)/bin/kernel.o \
	    -L$(project_path)/bin -lkernel -luser \
		-o $(project_path)/bin/kernel.bin

library:
	$(MAKE) -C $(CURDIR)/lib "as=$(as)" "cc=$(cc)" "ar=$(ar)" "ld=$(ld)"\
		"cflags=$(cflags)" "sflags=$(sflags)" "lflags=$(lflags)"\
		"project_path=$(project_path)" "debug=$(debug)"
