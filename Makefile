# References:
#  - https://www.raspberrypi.org/documentation/linux/kernel/building.md
#  - https://github.com/RIOT-Makers/wpan-raspbian/wiki/Create-a-generic-Raspbian-image-with-6LoWPAN-support#4-new-linux-kernels-for-the-pi


TOOL_CHAIN_BIN_LOC := tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin
PATH := $(PATH):$(PWD)/$(TOOL_CHAIN_BIN_LOC)
KERNEL := kernel7
ARCH := arm 
CROSS_COMPILE := arm-linux-gnueabihf-
NUMCPUS := $(shell grep -c '^processor' /proc/cpuinfo)
LORA6 := lora6
ROOTFS = $(PWD)/rootfs


all: build_kernel modules_install prepare_rootfs build_lora6 prepare_lora6_module

build_kernel: get_tools
	if [ ! -d linux ]; then \
		git clone --depth=1 https://github.com/raspberrypi/linux; \
		cd linux && \
		make ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) bcm2709_defconfig; \
	fi
	cd linux && \
	make ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) -j $(NUMCPUS)

get_tools:
	if [ ! -d tools ]; then \
		git clone --depth 1 https://github.com/raspberrypi/tools.git; \
	fi

modules_install:
	cd linux && \
	make ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) INSTALL_MOD_PATH=$(ROOTFS) modules_install

prepare_rootfs: prepare_kernel prepare_kernel

prepare_kernel:
	mkdir -p $(ROOTFS)/boot
	cp -a linux/arch/arm/boot/dts/*.dtb $(ROOTFS)/boot
	mkdir -p $(ROOTFS)/boot/overlays
	cp -a linux/arch/arm/boot/dts/overlays/*.dtb* $(ROOTFS)/boot/overlays
	linux/scripts/mkknlimg linux/arch/arm/boot/zImage $(ROOTFS)/boot/kernel7.img

prepare_firmware: get_firmware
	mkdir -p $(ROOTFS)/opt
	cp -a firmware/hardfp/opt/* $(ROOTFS)/opt
	
get_firmware:
	if [ ! -d firmware ]; then \
		git clone --depth 1 https://github.com/raspberrypi/firmware.git --branch next --single-branch firmware; \
	fi

build_lora6: get_lora6
	cd $(LORA6) && \
	make ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) 

get_lora6:
	if [ ! -d $(LORA6) ]; then \
		git clone https://github.com/rightson/lora6; \
	fi

prepare_lora6_module:
	cd $(LORA6) && \
	cp -f $(LORA6).ko $(ROOTFS)

