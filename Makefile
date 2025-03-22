BUILD_DIR := build

# Compilers:
MOD_CC ?= clang
MOD_LD ?= ld.lld

ZIG_CC ?= zig cc
ZIG_CXX ?= zig c++
ZIG_LD ?= zig ld.lld
ZIG_AR ?= zig ar

# Recomp Tools:
ifeq ($(OS),Windows_NT)
RECOMP_MOD_TOOL ?= ./N64Recomp/build/RecompModTool.exe
else
RECOMP_MOD_TOOL ?= ./N64Recomp/build/RecompModTool
endif

MOD_FILENAME := mm_recomp_host_lua_lib
MOD_TOML ?= ./mod.toml
MOD_ELF  := $(BUILD_DIR)/mod.elf
LIB_FILE  := $(BUILD_DIR)/lua_host
BUILD_MOD_DIR := $(BUILD_DIR)/src/mod
BUILD_LIB_DIR := $(BUILD_DIR)/src/lib

# Python call info:
ifeq ($(OS),Windows_NT)
PYTHON_EXEC ?= python
else
PYTHON_EXEC ?= python3
endif

PYTHON_FUNC_MODULE ?= make_python_functions
define python_func
	$(PYTHON_EXEC) -c "import $(PYTHON_FUNC_MODULE); $(PYTHON_FUNC_MODULE).$(1)($(2))"
endef

# Targets:
all: $(BUILD_DIR) $(BUILD_LIB_DIR) $(BUILD_MOD_DIR) lib_all mod

$(BUILD_DIR) $(BUILD_LIB_DIR) $(BUILD_MOD_DIR):
ifeq ($(OS),Windows_NT)
	mkdir $(subst /,\,$@)
else
	mkdir -p $@
endif

include mod.mk
include vcpkg.mk
include lib.mk

clean:
	rm -rf $(BUILD_DIR)
	rm -rf ./N64Recomp/build/
	rm -rf ./vcpkg_installed/

.PHONY: 

.PHONY: all clean