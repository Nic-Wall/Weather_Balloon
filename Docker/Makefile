# https://makefiletutorial.com/
# Functions
# https://stackoverflow.com/questions/6783243/functions-in-makefiles
# $(call file_fetch,URL,SHASUM/Revision,dest_dir)
define file_fetch
	$(info Fetching $(basename $(basename $(notdir $(1)))) using wget...)
	mkdir -p $(3)
	wget -c -P $(3) $(1)
	echo "$(2)  $(3)/$(notdir $(1))" | shasum -a 256 -c -
	mkdir -p $(3)/$(basename $(basename $(notdir $(1))))
	tar -xf $(3)/$(notdir $(1)) -C $(3)/$(basename $(basename $(notdir $(1))))
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
DSTS = ${CURDIR}/dest
TOOLCHAIN = aarch64--glibc--stable-2025.08-1
arm_none_eabi = arm-gnu-toolchain-15.3.rel1-x86_64-arm-none-eabi
CROSS_COMPILE = $(SRCS)/cross_compiler/$(TOOLCHAIN)/bin/aarch64-buildroot-linux-gnu-
arm_none_eabi_bin = $(SRCS)/cross_compiler/$(arm_none_eabi)/bin/arm-none-eabi-

# Targets
.PHONY: all clean fetch
all: fetch bootloader kernel rootfs additional_apps gen_initramfs
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
BUSYBOX_URL = https://busybox.net/busybox.git
BUSYBOX_SHASUM = ead17e7808236be80614d0a8755f4ddad63ab56c
$(SRCS)/.busybox:
	$(call git_fetch,$(BUSYBOX_URL),$(BUSYBOX_SHASUM),$(SRCS)/additional_apps)
	touch $@

# SQLite
SQLITE_URL =
SQLITE_SHASUM = 1ffe6567e8986c0d3bd0384e6a1b3baefab6af51
$(SRCS)/.sqlite:
	$(call git_fetch,$(SQLITE_URL),$(SQLITE_SHASUM),$(SRCS)/additional_apps)
	touch $@

# Dropbear SSH
LIBXCRYPT_URL = https://github.com/besser82/libxcrypt/releases/download/v4.5.2/libxcrypt-4.5.2.tar.xz
LIBXCRYPT_SHASUM = 71513a31c01a428bccd5367a32fd95f115d6dac50fb5b60c779d5c7942aec071
DROPBEAR_URL = https://github.com/mkj/dropbear.git 
DROPBEAR_SHASUM = 59870ad43153fe8d4f1c96f5d5752116c94f31ff
$(SRCS)/.dropbear:
	$(call file_fetch,$(LIBXCRYPT_URL),$(LIBXCRYPT_SHASUM),$(SRCS)/additional_apps)
	$(call git_fetch,$(DROPBEAR_URL),$(DROPBEAR_SHASUM),$(SRCS)/additional_apps)
	touch $@

bootloader: 
$(SRCS)/bootloader/trusted-firmware-a/build/rk3399/release/bl31/bl31.elf:
	cd bootloader/trusted-firmware-a && $(MAKE) distclean && $(MAKE) CROSS_COMPILE=$(CROSS_COMPILE) PLAT=rk3399 M0_CROSS_COMPILE=$(arm_none_eabi_bin)
$(SRCS)/configs/bootloader/rockpro_uboot.config: $(SRCS)/bootloader/trusted-firmware-a/build/rk3399/release/bl31/bl31.elf
	mkdir -p $(DSTS)/bootloader/rockpro
	cp $(SRCS)/configs/bootloader/rockpro_uboot.config $(DSTS)/bootloader/rockpro/.config
	cd bootloader/u-boot && $(MAKE) mrproper && $(MAKE) CROSS_COMPILE=$(CROSS_COMPILE) O=$(DSTS)/bootloader/rockpro BL31=../trusted-firmware-a/build/rk3399/release/bl31/bl31.elf
$(SRCS)/configs/bootloader/qemu_uboot.config:
	mkdir -p $(DSTS)bootloader/qemu
	cp $(SRCS)/configs/bootloader/qemu_uboot.config $(DSTS)/bootloader/qemu/.config
	cd bootloader/u-boot && $(MAKE) mrproper && $(MAKE) qemu_arm64_defconfig O=$(DSTS)/bootloader/qemu
$(SRCS)/configs/bootloader/bootscript.txt:
	$(SRCS)/bootloader/rockpro/tools/mkimage A=arm64 -O linux -T script -d $(SRCS)/configs/bootloader/bootscript.txt $(DSTS)/bootloader/boot.scr
	
kernel:
KERNEL_BUILD_DSTS = $(DSTS)/kernel/build_arm64
$(SRCS)/configs/rockpro_kernel.config:
	mkdir -p $(DSTS)/kernel/modules $(DSTS)/kernel/build_arm64
	cp $(SRCS)/configs/rockpro_kernel.config $(KERNEL_BUILD_DSTS)/.config
	cd $(SRCS)/linux-stable/ && $(MAKE) ARCH=arm64 CROSS_COMPILE=$(CROSS_COMPILE) O=$(KERNEL_BUILD_DSTS) prepare
	cd $(SRCS)/linux-stable/ && $(MAKE) -j$(shell nproc) ARCH=arm64 CROSS_COMPILE=$(CROSS_COMPILE) Image.gz O=$(KERNEL_BUILD_DSTS)
	cd $(SRCS)/linux-stable/ && $(MAKE) -j$(shell nproc) ARCH=arm64 dtbs CROSS_COMPILE=$(CROSS_COMPILE) O=$(KERNEL_BUILD_DSTS)
	cd $(SRCS)/linux-stable/ && $(MAKE) -j$(shell nproc) ARCH=arm64 CROSS_COMPILE=$(CROSS_COMPILE) INSTALL_MOD_PATH=$(DSTS)/kernel/modules O=$(KERNEL_BUILD_DSTS)
	cd $(SRCS)/linux-stable/ && $(MAKE) -j$(shell nproc) ARCH=arm64 CROSS_COMPILE=$(CROSS_COMPILE) INSTALL_MOD_PATH=$(DSTS)/kernel/modules O=$(KERNEL_BUILD_DSTS) modules_install

RFS = $(DSTS)/rootfs
BUILD = 7.0.0-rc6wb-0.1
rootfs:
$(SRCS)/.rootfs:
	mkdir -p $(RFS)/bin $(RFS)/dev $(RFS)/etc/init.d $(RFS)/home $(RFS)/lib $(RFS)/proc $(RFS)/sbin $(RFS)/sys $(RFS)/tmp $(RFS)/usr/bin $(RFS)/usr/lib $(RFS)/usr/sbin $(RFS)/var/log
	cd $(RFS) && ln -s lib lib64
	cp -r $(SRCS)/rfs_skeleton/* $(RFS)/etc/
	cd $(RFS) && mknod -m 666 dev/null c 1 3
	cd $(RFS) && mknod -m 600 dev/console c 5 1
	cp -a $(DSTS)/kernel/modules/lib/modules $(RFS)/lib/
	rm -r $(RFS)/lib/modules/$(BUILD)/build
	touch $@

apps = $(DSTS)/additional_apps
additional_apps:
# NEED LIBXCRYPT AS DEPENDS FOR DROPBEAR
$(RFS)/sbin/dropbear:

# NEED SQLite HEADERS HERE

# https://stackoverflow.com/questions/25005637/makefile-rule-depend-on-directory-content-changes
RFS_DIRS = $(shell find $(SRCS)/rootfs/ -type d)
RFS_FILES = $(shell find $(SRCS)/rootfs/ -type f -name '*')
gen_initramfs: $(DSTS)/kernel/build_arm64/arch/arm64/boot/Image $(DSTS)/kernel/rockpro/uRamdisk
$(DSTS)/kernel/build_arm64/arch/arm64/boot/Image: $(KERNEL_BUILD_DSTS)/Image.gz $(RFS_DIRS) $(RFS_FILES)
$(DSTS)/kernel/rockpro/uRamdisk: $(DSTS)/kernel/build_arm64/initramfs.cpio.gz

clean:
