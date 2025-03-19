MOD_LDSCRIPT := mod.ld
MOD_CFLAGS   := -target mips -mips2 -mabi=32 -O2 -G0 -mno-abicalls -mno-odd-spreg -mno-check-zero-division \
			-fomit-frame-pointer -ffast-math -fno-unsafe-math-optimizations -fno-builtin-memset \
			-Wall -Wextra -Wno-incompatible-library-redeclaration -Wno-unused-parameter -Wno-unknown-pragmas -Wno-unused-variable \
			-Wno-missing-braces -Wno-unsupported-floating-point-opt -Werror=section
MOD_CPPFLAGS := -nostdinc -D_LANGUAGE_C -DMIPS -DF3DEX_GBI_2 -DF3DEX_GBI_PL -DGBI_DOWHILE -I include/mod -I include/mod/dummy_headers \
			-I mm-decomp/include -I mm-decomp/src -I mm-decomp/extracted/n64-us -I mm-decomp/include -I mm-decomp/include/libc -I assets_extracted -I assets_extracted/assets
MOD_LDFLAGS  := -nostdlib -T $(MOD_LDSCRIPT) -Map $(BUILD_DIR)/mod.map --unresolved-symbols=ignore-all --emit-relocs -e 0 --no-nmagic

MOD_C_SRCS := $(wildcard src/mod/*.c) 
MOD_C_OBJS := $(addprefix $(BUILD_DIR)/, $(MOD_C_SRCS:.c=.o))
MOD_C_DEPS := $(addprefix $(BUILD_DIR)/, $(MOD_C_SRCS:.c=.d))

$(MOD_ELF): $(MOD_C_OBJS) $(MOD_LDSCRIPT) | $(BUILD_DIR)
	$(MOD_LD) $(MOD_C_OBJS) $(MOD_LDFLAGS) -o $@

$(MOD_C_OBJS): $(BUILD_DIR)/%.o : %.c | $(BUILD_DIR) $(BUILD_MOD_DIR)
	$(MOD_CC) $(MOD_CFLAGS) $(MOD_CPPFLAGS) $< -MMD -MF $(@:.o=.d) -c -o $@

$(MOD_FILENAME): $(RECOMP_MOD_TOOL) $(MOD_ELF) elf
	$(RECOMP_MOD_TOOL) $(MOD_TOML) $(BUILD_DIR)

$(RECOMP_MOD_TOOL):
	cmake -S ./N64Recomp -B ./N64Recomp/build -G Ninja 
	cmake --build ./N64Recomp/build

mod: $(MOD_FILENAME) 
elf: $(MOD_ELF)
mod_tool: $(RECOMP_MOD_TOOL)

-include $(MOD_C_DEPS)

.PHONY: mod elf mod_tool


