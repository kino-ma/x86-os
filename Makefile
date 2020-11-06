ASM_SRC_DIR := src_asm

SRC_ASM_BOOT := $(ASM_SRC_DIR)/boot.s
MODULES := $(ASM_SRC_DIR)/modules/*/*.s
INCLUDES := $(ASM_SRC_DIR)/include/*.s
ASM_SRCS := $(SRC_ASM_BOOT) $(MODULES) $(INCLUDES)

LST := boot.lst

LD_SCRIPT := kernel.ld

BOOT_LOAD := build/bootloader.o

_RUST_RELEASE := target/build-target/release/libx86_os.a
RUST_KERN := build/rust_kernel.a
KERNEL := build/kernel.bin

IMG := boot.img

default: qemu

$(IMG): $(BOOT_LOAD) $(RUST_KERN)
	cp $(BOOT_LOAD) $(IMG)
	#cat $(KERNEL) >> $(IMG)


$(KERNEL): $(RUST_KERN) $(ASM_STAGE2) $(LD_SCRIPT)
	ld -n -m elf_i386 \
		-o $(KERNEL) \
		-T $(LD_SCRIPT) \
		$(RUST_KERN) \
		$(ASM_STAGE2)

$(BOOT_LOAD): $(ASM_SRCS)
	nasm $(SRC_ASM_BOOT) -o $(BOOT_LOAD)

$(RUST_KERN): src/lib.rs
	RUST_TARGET_PATH=$(shell pwd) xargo build --target build-target --release
	cp $(_RUST_RELEASE) $(RUST_KERN)

$(ASM_STAGE2): $(SRC_ASM_STAGE2)
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

bochs:
	 bochs -q -f ../env/bochsrc.bxrc

clean:
	rm -rf $(IMG) $(LST) $(BOOT_LOAD) $(RUST_KERN)

all: $(IMG)

.PHONY: default qemu bochs clean all
