set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE static)
set(VCPKG_LIBRARY_LINKAGE static)

set(VCPKG_CMAKE_SYSTEM_NAME Generic)
# set(VCPKG_OSX_ARCHITECTURES x86_64)


# set(CMAKE_INSTALL_NAME_TOOL "C:/ProgramData/chocolatey/bin/llvm-install-name-tool.exe")
# set("CMAKE_PLATFORM_HAS_INSTALLNAME ": "OFF")

set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/x64-macos-zig_toolchain.cmake")

message(STATUS "DO WE REACH HERE?")
# set(CMAKE_INSTALL_NAME_TOOL "llvm-install-name-tool")
# set(CMAKE_SKIP_INSTALL_RPATH TRUE)
