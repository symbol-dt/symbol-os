OBJECT	:= string.s.o string.c.o ctype.c.o std.c.o stdio.c.o math.c.o
KOBJECT	:= asm.k.s.o int.k.s.o xdt.k.c.o

build: $(OBJECT) $(KOBJECT)
	$(foreach obj, $(OBJECT), $(shell $(AR) rcs $(TEMP)/libc.a $(TEMP)/$(obj)))\
    $(foreach kobj, $(KOBJECT), $(shell $(AR) rcs $(TEMP)/libkernel.a $(TEMP)/$(kobj)))

%.c.o: %.c
	$(CC) $< -o $(TEMP)/$@ $(CFLAGS)
%.s.o: %.asm
	$(AS) $< -o $(TEMP)/$@ $(SFLAGS)
%.k.c.o: kernel/%.c
	$(CC) $< -o $(TEMP)/$@ $(CFLAGS)
%.k.s.o: kernel/%.asm
	$(AS) $< -o $(TEMP)/$@ $(SFLAGS)
