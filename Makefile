project_path := $(CURDIR)
all: clean
	@ $(MAKE) -C $(project_path)/src "project_path=$(project_path)" "debug=true" "platform=amd64"
clean: *
ifeq ($(wildcard $(project_path)/bin), )
	@ mkdir -p $(project_path)/bin
else
	@ rm -rf $(project_path)/bin/*
endif
configure: src/configure.c
	@ $(CC) -o configure src/configure.c
	@ ./configure
