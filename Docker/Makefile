# https://makefiletutorial.com/
# Functions
# https://stackoverflow.com/questions/6783243/functions-in-makefiles
# $(call file_fetch,URL,SHASUM/Revision,dest_dir)
define file_fetch
	$(info Fetching $(basename $(basename $(notdir $(1)))) using wget...)
	mkdir -p $(3)
	wget -c -P $(3) $(1)
	echo "$(2)  $(3)/$(notdir $(1))" | shasum -a 256 -c -
	tar -xf $(3)/$(notdir $(1)) -C $(3)/
endef

# $(call git_fetch,URL,Revision,Dest_Dir)
define git_fetch
	$(info Fetching $(basename $(notdir $(1))) using git...)
	mkdir -p $(3)/$(basename $(notdir $(1)))
	cd $(3)/$(basename $(notdir $(1))) && \
	git init -q && \
	{ git remote add origin $(1) 2>/dev/null || git remote set-url origin $(1); } && \
	git fetch --depth 1 origin $(2) && \
	git checkout -q --detach FETCH_HEAD	
endef

# General Rules
SRCS = ${CURDIR}/srcs
DSTS = ${CURDIR}/dsts
TOOLCHAIN = aarch64--glibc--stable-2025.08-1
arm_none_eabi = arm-gnu-toolchain-15.3.rel1-x86_64-arm-none-eabi
CROSS_COMPILE = $(SRCS)/cross_compiler/$(TOOLCHAIN)/bin/aarch64-buildroot-linux-gnu-
arm_none_eabi_bin = $(SRCS)/cross_compiler/$(arm_none_eabi)/bin/arm-none-eabi-
NPROC = $(shell nproc)

# Targets
.PHONY: all clean fetch
all: fetch bootloader kernel additional_apps rootfs gen_initramfs
fetch: $(SRCS)/.toolchain $(SRCS)/.bootloader $(SRCS)/.busybox $(SRCS)/.kernel $(SRCS)/.sqlite $(SRCS)/.dropbear

# Cross Compilation Toolchain
TC_URL = https://toolchains.bootlin.com/downloads/releases/toolchains/aarch64/tarballs/aarch64--glibc--stable-2025.08-1.tar.xz
TC_SHASUM = dfb47eee874eef9e8a7fc042eee4e0a183f444b6bcde6a82fef8f009918389c9
NONE_EABI_URL = https://gitlab.arm.com/api/v4/projects/tooling%2Fgnu-toolchains-for-arm/packages/generic/gnu-toolchain/15.3.rel1/arm-gnu-toolchain-15.3.rel1-x86_64-arm-none-eabi.tar.xz
NONE_EABI_SHASUM = 563bebb2b97d53382b956d6ee1fe61e2cae26699901417234a37df505ef9b5fa
$(SRCS)/.toolchain:
	$(call file_fetch,$(TC_URL),$(TC_SHASUM),$(SRCS)/cross_compiler)
	$(call file_fetch,$(NONE_EABI_URL),$(NONE_EABI_SHASUM),$(SRCS)/cross_compiler)
	touch $@

# Trusted Firmware A and U-Boot Boot Loader
TFA_URL = https://github.com/TrustedFirmware-A/trusted-firmware-a.git
TFA_SHASUM = 0d3084482653dcba5338e701837437df942f1f6f
UBOOT_URL = https://source.denx.de/u-boot/u-boot.git
UBOOT_SHASUM = 4f70106beafe30df8b0528a3d8b2543cd48fe241
$(SRCS)/.bootloader:
	$(call git_fetch,$(TFA_URL),$(TFA_SHASUM),$(SRCS)/bootloader)
	$(call git_fetch,$(UBOOT_URL),$(UBOOT_SHASUM),$(SRCS)/bootloader)
	touch $@

# Kernel
KERNEL_URL = https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_SHASUM = 7aaa8047eafd0bd628065b15757d9b48c5f9c07d
$(SRCS)/.kernel:
	$(call git_fetch,$(KERNEL_URL),$(KERNEL_SHASUM),$(SRCS)/kernel)
	touch $@

# BusyBox
BUSYBOX_URL = git://busybox.net/busybox.git
BUSYBOX_SHASUM = ead17e7808236be80614d0a8755f4ddad63ab56c
$(SRCS)/.busybox:
	$(call git_fetch,$(BUSYBOX_URL),$(BUSYBOX_SHASUM),$(SRCS)/additional_apps)
	touch $@

# SQLite
SQLITE_URL = https://sqlite.org/2026/sqlite-autoconf-3540000.tar.gz
SQLITE_SHASUM = 134ec0802dda5795816e25d25872d20b312cb3973438c49b30bc40b7705ea9ed
$(SRCS)/.sqlite:
	$(call file_fetch,$(SQLITE_URL),$(SQLITE_SHASUM),$(SRCS)/additional_apps)
	touch $@

# Dropbear SSH
#LIBXCRYPT_URL = https://github.com/besser82/libxcrypt/releases/download/v4.5.2/libxcrypt-4.5.2.tar.xz
#LIBXCRYPT_SHASUM = 71513a31c01a428bccd5367a32fd95f115d6dac50fb5b60c779d5c7942aec071
DROPBEAR_URL = https://github.com/mkj/dropbear.git 
DROPBEAR_SHASUM = 59870ad43153fe8d4f1c96f5d5752116c94f31ff
$(SRCS)/.dropbear:
	$(call git_fetch,$(DROPBEAR_URL),$(DROPBEAR_SHASUM),$(SRCS)/additional_apps)
	touch $@

BL31 = $(DSTS)/.rk3399_bl3
RK3399_UBOOT_BIN = $(DSTS)/.rk3399_dtb
QEMU_UBOOT_BIN = $(DSTS)/.qemu_bin
BL31_ELF = $(SRCS)/bootloader/trusted-firmware-a/build/rk3399/release/bl31/bl31.elf
ROCKPRO_DTB = $(DSTS)/bootloader/rockpro/dts/upstream/src/arm64/rockchip/rk3399-rockpro64.dtb
ROCKPRO_MKIMAGE = $(DSTS)/bootloader/rockpro/tools/mkimage
bootloader: $(BL31) $(RK3399_UBOOT_BIN) $(DSTS)/bootloader/boot.scr
$(BL31): $(SRCS)/.bootloader
	cd $(SRCS)/bootloader/trusted-firmware-a && $(MAKE) distclean && $(MAKE) -j$(NPROC) CROSS_COMPILE=$(CROSS_COMPILE) PLAT=rk3399 M0_CROSS_COMPILE=$(arm_none_eabi_bin)
	touch $@
$(RK3399_UBOOT_BIN): $(BL31) $(SRCS)/.bootloader
	mkdir -p $(DSTS)/bootloader/rockpro
	cp $(SRCS)/configs/bootloader/rockpro_uboot.config $(DSTS)/bootloader/rockpro/.config
	cd $(SRCS)/bootloader/u-boot && $(MAKE) mrproper && $(MAKE) -j$(NPROC) CROSS_COMPILE=$(CROSS_COMPILE) O=$(DSTS)/bootloader/rockpro BL31=$(BL31_ELF)
	touch $@
$(QEMU_UBOOT_BIN): $(SRCS)/.bootloader
	mkdir -p $(DSTS)/bootloader/qemu
	cp $(SRCS)/configs/bootloader/qemu_uboot.config $(DSTS)/bootloader/qemu/.config
	cd $(SRCS)/bootloader/u-boot && $(MAKE) mrproper && $(MAKE) -j$(NPROC) qemu_arm64_defconfig O=$(DSTS)/bootloader/qemu && make CROSS_COMPILE=$(CROSS_COMPILE) O=$(DSTS)/bootloader/qemu
	touch $@
$(DSTS)/bootloader/boot.scr: $(RK3399_UBOOT_BIN)
	$(ROCKPRO_MKIMAGE) -A arm64 -O linux -T script -d $(SRCS)/configs/bootloader/bootscript.txt $(DSTS)/bootloader/boot.scr
	
BUILD = 7.0.0-rc6wb-0.1
KERNEL_IMAGE = $(DSTS)/.kernel_image
KERNEL_DTBS = $(DSTS)/.kernel_dtbs
KERNEL_MODULES = $(DSTS)/.kernel_modules
KERNEL_BUILD_DSTS = $(DSTS)/kernel/build_arm64
LINUX_STABLE = $(SRCS)/kernel/linux-stable
kernel: $(KERNEL_IMAGE) $(KERNEL_DTBS) $(KERNEL_MODULES)
$(KERNEL_IMAGE): $(SRCS)/.kernel
	mkdir -p $(DSTS)/kernel/modules $(KERNEL_BUILD_DSTS)
	cp $(SRCS)/configs/rockpro_kernel.config $(KERNEL_BUILD_DSTS)/.config
	cd $(LINUX_STABLE) && $(MAKE) ARCH=arm64 CROSS_COMPILE=$(CROSS_COMPILE) O=$(KERNEL_BUILD_DSTS) prepare
	cd $(LINUX_STABLE) && $(MAKE) -j$(NPROC) ARCH=arm64 CROSS_COMPILE=$(CROSS_COMPILE) Image.gz O=$(KERNEL_BUILD_DSTS)
	touch $@
$(KERNEL_DTBS): $(KERNEL_IMAGE)
	cd $(LINUX_STABLE) && $(MAKE) -j$(NPROC) ARCH=arm64 dtbs CROSS_COMPILE=$(CROSS_COMPILE) O=$(KERNEL_BUILD_DSTS)
	touch $@
$(KERNEL_MODULES): $(KERNEL_DTBS)
	cd $(LINUX_STABLE) && $(MAKE) -j$(NPROC) ARCH=arm64 CROSS_COMPILE=$(CROSS_COMPILE) INSTALL_MOD_PATH=$(DSTS)/kernel/modules O=$(KERNEL_BUILD_DSTS)
	cd $(LINUX_STABLE) && $(MAKE) -j$(NPROC) ARCH=arm64 CROSS_COMPILE=$(CROSS_COMPILE) INSTALL_MOD_PATH=$(DSTS)/kernel/modules O=$(KERNEL_BUILD_DSTS) modules_install
	touch $@

DROPBEAR = $(DSTS)/.dropbear_stamp
BUSYBOX = $(DSTS)/.busybox_stamp
APP_DSTS = $(DSTS)/additional_apps
additional_apps: $(DROPBEAR) $(BUSYBOX)
$(DROPBEAR): $(SRCS)/.dropbear
	mkdir -p $(APP_DSTS)/dropbear
	cd $(SRCS)/additional_apps/dropbear && ./configure --host=aarch64-linux-gnu --disable-lastlog --disable-utmp --disable-utmpx --disable-wtmp --disable-wtmpx --enable-static --disable-zlib CROSS_COMPILE=$(CROSS_COMPILE)
	cd $(SRCS)/additional_apps/dropbear && $(MAKE) -j$(NPROC) PROGRAMS="dropbear dropbearkey" DESTDIR=$(APP_DSTS)/dropbear install
	touch $@
$(BUSYBOX): $(SRCS)/.busybox
	mkdir -p $(APP_DSTS)/busybox
	cp $(SRCS)/configs/rockpro_busybox.config $(SRCS)/additional_apps/busybox/.config
	cd $(SRCS)/additional_apps/busybox && $(MAKE) -j$(NPROC) ARCH=arm64 CROSS_COMPILE=$(CROSS_COMPILE)
	touch $@
# NEED SQLite Headers

RFS = $(DSTS)/rfs
ROOTFS_STAMP = $(DSTS)/.rootfs
INCLUDE_ADDAPPS = $(DSTS)/.include_addApps
rootfs: $(ROOTFS_STAMP) $(INCLUDE_ADDAPPS)
$(ROOTFS_STAMP): $(KERNEL_MODULES)
	mkdir -p $(RFS)/bin $(RFS)/dev $(RFS)/etc/init.d $(RFS)/home $(RFS)/lib $(RFS)/proc $(RFS)/sbin $(RFS)/sys $(RFS)/tmp $(RFS)/usr/bin $(RFS)/usr/lib $(RFS)/usr/sbin $(RFS)/var/log
	cd $(RFS) && ln -s lib lib64
	cp -r $(SRCS)/rfs_skeleton/* $(RFS)/etc/
	cd $(RFS) && mknod -m 666 dev/null c 1 3
	cd $(RFS) && mknod -m 600 dev/console c 5 1
	cp -a $(DSTS)/kernel/modules/lib/modules $(RFS)/lib/
	rm -r $(RFS)/lib/modules/$(BUILD)/build
	touch $@
$(INCLUDE_ADDAPPS): $(additional_apps) $(ROOTFS_STAMP)
	$(info Copying dropbear and dropbearkey into the rootfs...)
	cp  $(APP_DSTS)/dropbear/usr/local/sbin/dropbear $(RFS)/sbin/dropbear
	cp $(APP_DSTS)/dropbear/usr/local/bin/dropbearkey $(RFS)/bin/dropbearkey
	$(info Copying busybox into the rootfs...)
	cd $(SRCS)/configs/additional_apps/busybox && $(MAKE) ARCH=arm64 CROSS_COMPILE=$(CROSS_COMPILE) install
	mkdir -p $(RFS)/usr/share/udhcp
	cp $(SRCS)/additional_apps/busybox/examples/udhcp/simple.script $(RFS)/usr/share/udhcp/default.script
	touch $@

gen_initramfs: $(KERNEL_BUILD_DSTS)/initramfs.cpio.gz $(DSTS)/kernel/rockpro/uRamdisk
$(KERNEL_BUILD_DSTS)/initramfs.cpio.gz: $(kernel) $(rootfs)
	mkdir -p $(DSTS)/kernel/rockpro $(DSTS)/kernel/qemu
	cp $(KERNEL_BUILD_DSTS)/usr/gen_init_cpio $(SRCS)/linux-stable/usr
	$(shell $(SRCS)/linux-stable/usr/gen_initramfs.sh -o $(KERNEL_BUILD_DSTS)/initramfs.cpio -u 1000 -g 1000 $(RFS) $(SRCS)/config/gen_initramfs.list)
	gzip $(KERNEL_BUILD_DSTS)/initramfs.cpio
$(DSTS)/kernel/rockpro/uRamdisk: $(kernel) $(bootloader)
	cp $(KERNEL_BUILD_DSTS)/initramfs.cpio.gz $(DSTS)/kernel/rockpro/
	cp $(KERNEL_BUILD_DSTS)/initramfs.cpio.gz $(DSTS)/kernel/qemu/
	$(shell $(SRCS)/bootloader/rockpro/tools/mkimage -A arm64 -O linux -T ramdisk -d $(KERNEL_BUILD_DSTS)/initramfs.cpio.gz $(DSTS)/kernel/rockpro/uRamdisk)
	$(shell $(SRCS)/bootloader/qemu/tools/mkimage -A arm64 -O linux -T ramdisk -d $(KERNEL_BUILD_DSTS)/initramfs.cpio.gz $(DSTS)/kernel/qemu/uRamdisk)

clean:
