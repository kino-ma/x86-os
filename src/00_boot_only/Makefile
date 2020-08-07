buildrun: build run

build:
	nasm boot.s -o boot.img -l boot.lst

run:
	qemu-system-i386\
		-m     size=256M                     # memory size to use \
		-boot  order=c                       # drive to boot \
		-drive file=boot.img,format=raw      # file to boot and its format \
		-rtc   base=localtime                # on RTC time \

bochs:
	 bochs -q -f ../bochsrc.bxrc
