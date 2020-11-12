ASM_SRC_DIR := src_asm
LST := boot.lst
BOCHS_CNFG := ./env/bochsrc.bxrc

SRC_ASM_BOOT := $(ASM_SRC_DIR)/boot.s
SRC_ASM_STAGE2 := $(ASM_SRC_DIR)/stage_2.s
MODULES := $(ASM_SRC_DIR)/modules/*/*.s
INCLUDES := $(ASM_SRC_DIR)/include/*.s
ASM_SRCS := $(SRC_ASM_BOOT) $(SRC_ASM_STAGE2) $(MODULES) $(INCLUDES)

LD_SCRIPT := kernel.ld

BOOT_LOAD := build/bootloader.bin
ASM_STAGE2 := build/stage_2.o
_RUST_RELEASE := target/build-target/release/libx86_os.a
RUST_KERN := build/rust_kernel.a

KERNEL := build/kernel.bin

OBJS := $(IMG) $(BOOT_LOAD) $(RUST_KERN) $(ASM_STAGE2) $(KERNEL)

IMG := boot.img


default: qemu

$(IMG): $(BOOT_LOAD) $(KERNEL)
	cp $(BOOT_LOAD) $(IMG)
	cat $(KERNEL) >> $(IMG)
	truncate -s 8k $(IMG)


$(KERNEL): $(RUST_KERN) $(ASM_STAGE2) $(LD_SCRIPT)
	ld -n -m elf_i386 \
		-o $(KERNEL) \
		-T $(LD_SCRIPT) \
		$(ASM_STAGE2)

		#$(RUST_KERN) \

$(BOOT_LOAD): $(ASM_SRCS)
	nasm $(SRC_ASM_BOOT) -o $(BOOT_LOAD)

$(RUST_KERN): src/lib.rs
	RUST_TARGET_PATH=$(shell pwd) xargo build --target build-target --release
	cp $(_RUST_RELEASE) $(RUST_KERN)

$(ASM_STAGE2): $(SRC_ASM_STAGE2) $(MODULES) $(INCLUDES)
	nasm -f elf32 $(SRC_ASM_STAGE2) -o $(ASM_STAGE2)


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

all: $(IMG)

.PHONY: default qemu bochs clean all dump_img dump_kern