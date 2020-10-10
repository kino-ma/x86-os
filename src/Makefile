SRC := boot.s modules/*/*.s include/*.s
IMG := boot.img

default: qemu

$(IMG): $(SRC)
	nasm boot.s -o boot.img -l boot.lst

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
	rm -rf *.img *.lst

.PHONY: default qemu bochs clean