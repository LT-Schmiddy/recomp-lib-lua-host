VCPKG_TOOL ?= vcpkg
ZIG_COMPAT := zig_compat

VCPKG_DEPS := lua sol2

VCPKG_TRIPLET_WIN ?= x64-windows-static-zig
VCPKG_TRIPLET_MACOS ?= x64-macos-zig
VCPKG_TRIPLET_LINUX ?= x64-linux-zig

VCPKG_INSTALLED_DIR_WIN := ./vcpkg_installed/$(VCPKG_TRIPLET_WIN)
VCPKG_INSTALLED_DIR_MACOS := ./vcpkg_installed/$(VCPKG_TRIPLET_MACOS)
VCPKG_INSTALLED_DIR_LINUX := ./vcpkg_installed/$(VCPKG_TRIPLET_LINUX)

VCPKG_INCLUDE_DIR_WIN := $(VCPKG_INSTALLED_DIR_WIN)/$(VCPKG_TRIPLET_WIN)/include
VCPKG_INCLUDE_DIR_MACOS := $(VCPKG_INSTALLED_DIR_MACOS)/$(VCPKG_TRIPLET_MACOS)/include
VCPKG_INCLUDE_DIR_LINUX:= $(VCPKG_INSTALLED_DIR_LINUX)/$(VCPKG_TRIPLET_LINUX)/include

VCPKG_LIB_DIR_WIN := $(VCPKG_INSTALLED_DIR_WIN)/$(VCPKG_TRIPLET_WIN)/lib
VCPKG_LIB_DIR_MACOS := $(VCPKG_INSTALLED_DIR_MACOS)/$(VCPKG_TRIPLET_MACOS)/lib
VCPKG_LIB_DIR_LINUX := $(VCPKG_INSTALLED_DIR_LINUX)/$(VCPKG_TRIPLET_LINUX)/lib

vcpkg_libs_all: vcpkg_libs_windows vcpkg_libs_macos vcpkg_libs_linux

vcpkg_libs_windows:
	$(VCPKG_TOOL) install --overlay-triplets=$(ZIG_COMPAT) --triplet=$(VCPKG_TRIPLET_WIN) --x-install-root=$(VCPKG_INSTALLED_DIR_WIN)

vcpkg_libs_macos:
	$(VCPKG_TOOL) install --overlay-triplets=$(ZIG_COMPAT) --triplet=$(VCPKG_TRIPLET_MACOS) --x-install-root=$(VCPKG_INSTALLED_DIR_MACOS)

vcpkg_libs_linux:
	$(VCPKG_TOOL) install --overlay-triplets=$(ZIG_COMPAT) --triplet=$(VCPKG_TRIPLET_LINUX) --x-install-root=$(VCPKG_INSTALLED_DIR_LINUX)

.PHONY: vcpkg