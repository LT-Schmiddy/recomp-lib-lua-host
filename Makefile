BUILD_DIR := build

MOD_CC := clang
MOD_LD := ld.lld

ZIG_CC ?= zig cc
ZIG_CXX ?= zig c++
ZIG_LD ?= zig ld.lld
ZIG_AR ?= zig ar

MOD_FILENAME := mm_recomp_host_lua_lib

ifeq ($(OS),Windows_NT)
RECOMP_MOD_TOOL ?= ./N64Recomp/build/RecompModTool.exe
else
RECOMP_MOD_TOOL ?= ./N64Recomp/build/RecompModTool
endif

MOD_TOML ?= ./mod.toml
MOD_ELF  := $(BUILD_DIR)/mod.elf
LIB_FILE  := $(BUILD_DIR)/lua_host
BUILD_MOD_DIR := $(BUILD_DIR)/src/mod
BUILD_LIB_DIR := $(BUILD_DIR)/src/lib

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

.PHONY: 

.PHONY: all clean