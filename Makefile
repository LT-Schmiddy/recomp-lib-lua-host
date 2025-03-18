BUILD_DIR := build

MOD_CC      := clang
MOD_LD      := ld.lld

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

# Targets:
mod: $(MOD_FILENAME)  
elf: $(MOD_ELF)
mod_tool: $(RECOMP_MOD_TOOL)

$(MOD_FILENAME): $(RECOMP_MOD_TOOL) $(MOD_ELF)
	$(RECOMP_MOD_TOOL) $(MOD_TOML) $(BUILD_DIR)

$(RECOMP_MOD_TOOL):
	cmake -S ./N64Recomp -B ./N64Recomp/build -G Ninja 
	cmake --build ./N64Recomp/build

include mod.mk
include vcpkg.mk
include lib.mk
