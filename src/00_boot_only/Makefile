buildrun: build run

build:
	nasm boot.s -o boot.img -l boot.lst

run:
	qemu-system-i386\
		-m     size=256M \
		-boot  order=c \
		-drive file=boot.img,format=raw \
		-rtc   base=localtime \

# -m = memory size to use \
# -boot = drive to boot \
# -drive = file to boot and its format \
# -rtc = on localtime \
bochs:
	 bochs -q -f ../bochsrc.bxrc
