LIB_CFLAGS := -O2
LIB_CPPFLAGS := -I include/lib 
LIB_LDFLAGS  := -llua

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

.PHONY: lib_x86_64-windows lib_x86_64-macos lib_x86_64-linux
