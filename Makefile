ASM_SRC_DIR := src_asm
BOOT_SRC := $(ASM_SRC_DIR)/boot.s
MODULES := $(ASM_SRC_DIR)/modules/*/*.s
INCLUDES := $(ASM_SRC_DIR)/include/*.s
ASM_SRCS := $(BOOT_SRC) $(MODULES) $(INCLUDES)
IMG := build/boot.img
LST := boot.lst

LD_SCRIPT := kernel.ld

RUST_KERN := target/build-target/release/libx86_os.a
BOOT_LOAD := build/bootloader.o

default: qemu

$(IMG): $(BOOT_LOAD) $(RUST_KERN) $(LD_SCRIPT)
	ld -n -m elf_i386 \
		-o $(IMG) \
		-T $(LD_SCRIPT) \
		$(RUST_KERN) \
		$(BOOT_LOAD)

$(BOOT_LOAD): $(ASM_SRCS)
	nasm -f elf32 -g $(BOOT_SRC) -o $(BOOT_LOAD)

$(RUST_KERN): src/lib.rs
	RUST_TARGET_PATH=$(shell pwd) xargo build --target build-target --release

qemu: $(IMG)
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
	rm -rf *.img *.lst *.o

.PHONY: default qemu bochs clean

obj:
	objcopy -I binary -O elf32-i386 a.out b.out

show:
	objdump -D -b binary -m i386 a.out | less