VCPKG_TOOL ?= vcpkg
ZIG_COMPAT_DIR := zig_compat

VCPKG_LINKS := lua

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

vcpkg_all: vcpkg_x64_windows vcpkg_x64_macos vcpkg_x64_linux

vcpkg_x64_windows: $(call vcpkg_get_installed_dir,$(VCPKG_TRIPLET_WIN))
$(call vcpkg_get_installed_dir,$(VCPKG_TRIPLET_WIN)):
	$(call vcpkg_install_lib,$(VCPKG_TRIPLET_WIN))

vcpkg_x64_macos: $(call vcpkg_get_installed_dir,$(VCPKG_TRIPLET_MACOS))
$(call vcpkg_get_installed_dir,$(VCPKG_TRIPLET_MACOS)):
	$(call vcpkg_install_lib,$(VCPKG_TRIPLET_MACOS))

vcpkg_x64_linux: $(call vcpkg_get_installed_dir,$(VCPKG_TRIPLET_LINUX))
$(call vcpkg_get_installed_dir,$(VCPKG_TRIPLET_LINUX)):
	$(call vcpkg_install_lib,$(VCPKG_TRIPLET_LINUX))

.PHONY: vcpkg vcpkg_all vcpkg_x64_windows vcpkg_x64_macos vcpkg_x64_linux