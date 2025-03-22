
# ========== CONFIGURATION ==========
MOD_TOML ?= ./mod.toml
BUILD_DIR ?= build
LIB_NAME ?= lua_host
LIB_LINKS ?= -llua
ASSETS_EXTRACTED_DIR ?= assets_extracted

# ========== COMPILATION TOOLS ==========
MOD_CC ?= clang
MOD_LD ?= ld.lld

ZIG_CC ?= zig cc
ZIG_CXX ?= zig c++
ZIG_LD ?= zig ld.lld
ZIG_AR ?= zig ar

# ========== INIT PYTHON INTEGRATION ==========
ifeq ($(OS),Windows_NT)
PYTHON_EXEC ?= python
else
PYTHON_EXEC ?= python3
endif

PYTHON_FUNC_MODULE := make_python_functions
define call_python_func
	$(PYTHON_EXEC) -c "import $(PYTHON_FUNC_MODULE); $(PYTHON_FUNC_MODULE).ModInfo(\"$(MOD_TOML)\", \"$(BUILD_DIR)\").$(1)($(2))"
endef

define get_python_func
$(shell $(PYTHON_EXEC) -c "import $(PYTHON_FUNC_MODULE); $(PYTHON_FUNC_MODULE).ModInfo(\"$(MOD_TOML)\", \"$(BUILD_DIR)\").$(1)($(2))")
endef

define get_python_val
$(shell $(PYTHON_EXEC) -c "import $(PYTHON_FUNC_MODULE); print($(PYTHON_FUNC_MODULE).ModInfo(\"$(MOD_TOML)\", \"$(BUILD_DIR)\").$(1))")
endef

# ========== INITIALIZE BUILD DIRS AND TARGETS ==========
BUILD_MOD_DIR := $(BUILD_DIR)/src/mod
BUILD_LIB_DIR := $(BUILD_DIR)/src/lib
all: $(BUILD_DIR) $(BUILD_LIB_DIR) $(BUILD_MOD_DIR) lib_all mod

$(BUILD_DIR) $(BUILD_LIB_DIR) $(BUILD_MOD_DIR):
ifeq ($(OS),Windows_NT)
	mkdir $(subst /,\,$@)
else
	mkdir -p $@
endif

# ========== BUILD MOD CONFIG ==========
MOD_FILE := $(call get_python_func,get_mod_file,)
$(info MOD_FILE=$(MOD_FILE))
MOD_ELF  := $(call get_python_func,get_mod_elf,)
$(info MOD_ELF=$(MOD_ELF))

ifeq ($(OS),Windows_NT)
RECOMP_MOD_TOOL ?= ./N64Recomp/build/RecompModTool.exe
else
RECOMP_MOD_TOOL ?= ./N64Recomp/build/RecompModTool
endif

MOD_LDSCRIPT := mod.ld
MOD_CFLAGS   := -target mips -mips2 -mabi=32 -O2 -G0 -mno-abicalls -mno-odd-spreg -mno-check-zero-division \
			-fomit-frame-pointer -ffast-math -fno-unsafe-math-optimizations -fno-builtin-memset \
			-Wall -Wextra -Wno-incompatible-library-redeclaration -Wno-unused-parameter -Wno-unknown-pragmas -Wno-unused-variable \
			-Wno-missing-braces -Wno-unsupported-floating-point-opt -Werror=section
MOD_CPPFLAGS := -nostdinc -D_LANGUAGE_C -DMIPS -DF3DEX_GBI_2 -DF3DEX_GBI_PL -DGBI_DOWHILE -I include/mod -I include/mod/dummy_headers \
			-I mm-decomp/include -I mm-decomp/src -I mm-decomp/extracted/n64-us -I mm-decomp/include -I mm-decomp/include/libc \
			-I $(ASSETS_EXTRACTED_DIR) -I $(ASSETS_EXTRACTED_DIR)/assets
MOD_LDFLAGS  := -nostdlib -T $(MOD_LDSCRIPT) -Map $(BUILD_DIR)/mod.map --unresolved-symbols=ignore-all --emit-relocs -e 0 --no-nmagic

MOD_C_SRCS := $(wildcard src/mod/*.c) 
MOD_C_OBJS := $(addprefix $(BUILD_DIR)/, $(MOD_C_SRCS:.c=.o))
MOD_C_DEPS := $(addprefix $(BUILD_DIR)/, $(MOD_C_SRCS:.c=.d))

$(MOD_ELF): $(MOD_C_OBJS) $(MOD_LDSCRIPT) | $(BUILD_DIR) $(ASSETS_EXTRACTED_DIR)
	$(MOD_LD) $(MOD_C_OBJS) $(MOD_LDFLAGS) -o $@

$(MOD_C_OBJS): $(BUILD_DIR)/%.o : %.c | $(BUILD_DIR) $(BUILD_MOD_DIR) $(ASSETS_EXTRACTED_DIR)
	$(MOD_CC) $(MOD_CFLAGS) $(MOD_CPPFLAGS) $< -MMD -MF $(@:.o=.d) -c -o $@

$(MOD_FILE): $(RECOMP_MOD_TOOL) $(MOD_ELF) elf
	$(RECOMP_MOD_TOOL) $(MOD_TOML) $(BUILD_DIR)

$(RECOMP_MOD_TOOL):
	cmake -S ./N64Recomp -B ./N64Recomp/build -G Ninja 
	cmake --build ./N64Recomp/build

$(ASSETS_EXTRACTED_DIR):
	$(call call_python_func,create_asset_archive,\"$(ASSETS_EXTRACTED_DIR)\")

mod: $(MOD_FILE) 
elf: $(MOD_ELF)
mod_tool: $(RECOMP_MOD_TOOL)

-include $(MOD_C_DEPS)

# ========== BUILD VCPKG CONFIG ==========
VCPKG_TOOL ?= vcpkg
ZIG_COMPAT_DIR := zig_compat
ZIG_SHIMS_DIR := $(ZIG_COMPAT_DIR)/shims

define vcpkg_link_paths
$(call vcpkg_get_lib_dir,$(1))
endef

VCPKG_TRIPLET_WIN ?=x64-windows-static-zig
VCPKG_TRIPLET_MACOS ?=x64-macos-zig
VCPKG_TRIPLET_LINUX ?=x64-linux-zig

define vcpkg_get_installed_dir
./vcpkg_installed/$(1)
endef

define vcpkg_get_include_dir
$(call vcpkg_get_installed_dir,$(1))/$(1)/include
endef

define vcpkg_get_lib_dir
$(call vcpkg_get_installed_dir,$(1))/$(1)/lib
endef

define vcpkg_install_lib
	$(VCPKG_TOOL) install --overlay-triplets=$(ZIG_COMPAT_DIR) --triplet=$(1) --x-install-root=$(call vcpkg_get_installed_dir,$(1))
endef

zig_shims: $(ZIG_SHIMS_DIR)
$(ZIG_SHIMS_DIR):
	$(call call_python_func,build_zig_shims,)

	
vcpkg_all: vcpkg_x64_windows vcpkg_x64_macos vcpkg_x64_linux

vcpkg_x64_windows: $(call vcpkg_get_installed_dir,$(VCPKG_TRIPLET_WIN))
$(call vcpkg_get_installed_dir,$(VCPKG_TRIPLET_WIN)): $(ZIG_SHIMS_DIR)
	$(call vcpkg_install_lib,$(VCPKG_TRIPLET_WIN))

vcpkg_x64_macos: $(call vcpkg_get_installed_dir,$(VCPKG_TRIPLET_MACOS))
$(call vcpkg_get_installed_dir,$(VCPKG_TRIPLET_MACOS)): $(ZIG_SHIMS_DIR)
	$(call vcpkg_install_lib,$(VCPKG_TRIPLET_MACOS))

vcpkg_x64_linux: $(call vcpkg_get_installed_dir,$(VCPKG_TRIPLET_LINUX))
$(call vcpkg_get_installed_dir,$(VCPKG_TRIPLET_LINUX)): $(ZIG_SHIMS_DIR)
	$(call vcpkg_install_lib,$(VCPKG_TRIPLET_LINUX))


# ========== BUILD LIB CONFIG ==========
LIB_FILE  := $(BUILD_DIR)/$(LIB_NAME)

LIB_CFLAGS := -O2
LIB_CPPFLAGS := -I include/lib 
LIB_LDFLAGS  := $(LIB_LINKS)

LIB_SRCS := $(wildcard src/lib/*.cpp) $(wildcard src/lib/*.c)

define compile_lib_flags
-target $(1) -L $(call vcpkg_get_lib_dir,$(2)) -I $(call vcpkg_get_include_dir,$(2))
endef

define compile_lib
	$(ZIG_CXX) -shared $(LIB_LDFLAGS) $(LIB_CFLAGS) $(CXXFLAGS) $(3) -o $(4) $(LIB_SRCS) $(call compile_lib_flags,$(1),$(2))
endef

lib_all: $(BUILD_DIR) $(BUILD_LIB_DIR) lib_x86_64-windows lib_x86_64-macos lib_x86_64-linux

lib_x86_64-windows: $(call vcpkg_get_installed_dir,$(VCPKG_TRIPLET_WIN)) $(BUILD_DIR) $(BUILD_LIB_DIR)
	$(call compile_lib,x86_64-windows,$(VCPKG_TRIPLET_WIN),,$(LIB_FILE).dll)
# $(ZIG_CXX) -shared -target x86_64-windows $(LIB_LDFLAGS) $(LIB_CFLAGS) $(CXXFLAGS) -o $(LIB_FILE).dll $(LIB_SRCS)

lib_x86_64-macos: $(call vcpkg_get_installed_dir,$(VCPKG_TRIPLET_MACOS)) $(BUILD_DIR) $(BUILD_LIB_DIR)
	$(call compile_lib,x86_64-macos,$(VCPKG_TRIPLET_MACOS),,$(LIB_FILE).dylib)

lib_x86_64-linux: $(call vcpkg_get_installed_dir,$(VCPKG_TRIPLET_LINUX)) $(BUILD_DIR) $(BUILD_LIB_DIR)
	$(call compile_lib,x86_64-linux,$(VCPKG_TRIPLET_LINUX),,$(LIB_FILE).so)


# =========== MISC ==========

clean:
	rm -rf $(BUILD_DIR)
	rm -rf ./N64Recomp/build/
	rm -rf ./vcpkg_installed/

.PHONY: all clean lib_x86_64-windows lib_x86_64-macos lib_x86_64-linux vcpkg_all vcpkg_x64_windows vcpkg_x64_macos \
	 vcpkg_x64_linux zig_shims mod elf mod_tool