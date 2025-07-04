all:
ifeq ($(platform), amd64)
	@echo "Building for x86_64"
	@$(MAKE) -C $(project_path)/arch/amd64 build platform=amd64 "debug=$(debug)" "project_path=$(project_path)"
else ifeq ($(platform), arm64)
	@echo "Building for aarch64"
	@$(MAKE) -C. $(project_path)/arch/aarch64 build platform=arm64 "debug=$(debug)" "project_path=$(project_path)"
else
	@echo "Unknown platform: $(platform)"
endif
