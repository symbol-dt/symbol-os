all: kernel user

kernel:
	$(cc) $(cflags) -c kernel.c -o $(project_path)/bin/kernel.c.o
	$(as) $(sflags) kernel.asm -o $(project_path)/bin/kernel.s.o
	$(cc) $(cflags) -c asm.c -o $(project_path)/bin/asm.c.o
	$(as) $(sflags) asm.asm -o $(project_path)/bin/asm.s.o
ifeq ($(debug), true)
	$(cc) $(cflags) -S kernel.c -o $(project_path)/bin/kernel.c.S
	$(as) $(sflags) asm.asm -o $(project_path)/bin/asm.s.o -l $(project_path)/bin/asm.s.lst
endif
	$(ar) rcs $(project_path)/bin/libkernel.a\
		$(project_path)/bin/kernel.c.o\
		$(project_path)/bin/kernel.s.o\
		$(project_path)/bin/asm.c.o\
		$(project_path)/bin/asm.s.o

user:
	$(as) $(sflags) string.asm -o $(project_path)/bin/string.s.o
	$(ar) rcs $(project_path)/bin/libuser.a\
		$(project_path)/bin/string.s.o
