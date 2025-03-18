VCPKG_ROOT := ./vcpkg

ifeq ($(OS),Windows_NT)
	VCPKG_TOOL ?= $(VCPKG_ROOT)/vcpkg.exe
else
	VCPKG_TOOL ?= $(VCPKG_ROOT)/vcpkg.exe
endif

# vcpkg: $(VCPKG_TOOL)

# $(VCPKG_TOOL):
# 	$(VCPKG_ROOT)/bootstrap-vcpkg.bat -disableMetrics

# ifeq ($(OS),Windows_NT)
	
# else
# 	$(VCPKG_ROOT)/bootstrap.sh -disableMetrics
# endif