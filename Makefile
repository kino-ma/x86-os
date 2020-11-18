ifeq ($(shell uname),Linux)
	LD := ld
else
	LD := i386-elf-ld
endif

ASM_SRC_DIR := src_asm
BOCHS_CNFG := ./env/bochsrc.bxrc

# bootloader sources
SRC_ASM_BOOT := $(ASM_SRC_DIR)/boot.s
SRC_ASM_STAGE2 := $(ASM_SRC_DIR)/stage_2.s

INCLUDES := $(ASM_SRC_DIR)/include/*.s

# assembly modules
MODULES_REAL := $(ASM_SRC_DIR)/modules/real/*.s
MODULES_PROTECT := $(ASM_SRC_DIR)/modules/protect/*.s

# bootloader binary
BOOT_LOAD := build/bootloader.bin


LD_SCRIPT := kernel.ld

# main kernel source
_RUST_RELEASE := target/build-target/release/libx86_os.a
RUST_KERN := build/rust_kernel.a

# assembly library
SRC_ASM_LIB := src_asm/lib_protect.s
ASM_LIB := build/asm_lib.o

# kernel binary
KERNEL := build/kernel.bin

# object files generated while building
OBJS := $(IMG) $(BOOT_LOAD) $(RUST_KERN) $(ASM_STAGE2) $(KERNEL)


# final image
IMG := boot.img


default: qemu


$(IMG): $(BOOT_LOAD) $(KERNEL)
	cp $(BOOT_LOAD) $(IMG)
	cat $(KERNEL) >> $(IMG)

$(BOOT_LOAD): $(SRC_ASM_BOOT) $(SRC_ASM_STAGE2) $(MODULES_REAL) $(INCLUDES)
	nasm $(SRC_ASM_BOOT) -o $(BOOT_LOAD)


$(KERNEL): $(RUST_KERN) $(ASM_LIB) $(LD_SCRIPT)
	$(LD) -n -m elf_i386 \
		-o $(KERNEL) \
		-T $(LD_SCRIPT) \
		$(RUST_KERN) \
		$(ASM_LIB)
	truncate -s 8k $(KERNEL)

$(RUST_KERN): src/lib.rs
	RUST_TARGET_PATH=$(shell pwd) xargo build --target build-target --release
	cp $(_RUST_RELEASE) $(RUST_KERN)

$(ASM_LIB): $(SRC_ASM_LIB) $(MODULES_PROTECT) $(INCLUDES)
	nasm -f elf32 $(SRC_ASM_LIB) -o $(ASM_LIB)


qemu: all
	qemu-system-i386\
		-m     size=256M \
		-boot  order=c \
		-drive file=$(IMG),format=raw \
		-rtc   base=localtime \

# -m = memory size to use \
# -boot = drive to boot \
# -drive = file to boot and its format \
# -rtc = on localtime \

bochs: $(IMG)
	bochs -q -f $(BOCHS_CNFG)

clean:
	rm -rf $(IMG) $(LST) $(OBJS)

dump_img: $(IMG)
	objdump -D -z -b binary -mi386 -Maddr16,data16 $(IMG) | less

dump_kern: $(KERNEL)
	objdump -D -z -b binary -mi386 -Maddr16,data16 $(KERNEL) | less

all: $(KERNEL) $(IMG)

.PHONY: default qemu bochs clean all dump_img dump_kern
