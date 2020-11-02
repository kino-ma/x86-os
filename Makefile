ASM_SRC_DIR := src_asm
BOOT_SRC := $(ASM_SRC_DIR)/boot.s
MODULES := $(ASM_SRC_DIR)/modules/*/*.s
INCLUDES := $(ASM_SRC_DIR)/include/*.s
SRCS := $(BOOT_SRC) $(MODULES) $(INCLUDES)
IMG := boot.img
LST := boot.lst

default: qemu

$(IMG): $(SRCS)
	nasm -f bin $(BOOT_SRC) -o $(IMG) -l $(LST)

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