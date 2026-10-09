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

# Rules
SRCS = ${CURDIR}/srcs
DSTS = ${CURDIR}/dest
TOOLCHAIN = aarch64--glibc--stable-2025.08-1/
CROSS_COMPILE = $(SRCS)/cross_compiler/$(TOOLCHAIN)/bin/aarch64-buildroot-linux-gnu-.PHONY: all clean fetch

# Targets
all: fetch build
fetch: $(SRCS)/.toolchain $(SRCS)/.bootloader $(SRCS)/.busybox $(SRCS)/.kernel $(SRCS)/.sqlite $(SRCS)/.dropbear

# Fetch
TC_URL = https://toolchains.bootlin.com/downloads/releases/toolchains/aarch64/tarballs/aarch64--glibc--stable-2025.08-1.tar.xz
TC_SHASUM = dfb47eee874eef9e8a7fc042eee4e0a183f444b6bcde6a82fef8f009918389c9
NONE_EABI_URL = https://gitlab.arm.com/api/v4/projects/tooling%2Fgnu-toolchains-for-arm/packages/generic/gnu-toolchain/15.3.rel1/arm-gnu-toolchain-15.3.rel1-x86_64-arm-none-eabi.tar.xz
NONE_EABI_SHASUM = 563bebb2b97d53382b956d6ee1fe61e2cae26699901417234a37df505ef9b5fa
$(SRCS)/.toolchain:
	$(call file_fetch,$(TC_URL),$(TC_SHASUM),$(SRCS)/cross_compiler)
	$(call file_fetch,$(NONE_EABI_URL),$(NONE_EABI_SHASUM),$(SRCS)/cross_compiler)
	touch $@

TFA_URL = https://github.com/TrustedFirmware-A/trusted-firmware-a.git
TFA_SHASUM = 0d3084482653dcba5338e701837437df942f1f6f
UBOOT_URL = https://source.denx.de/u-boot/u-boot.git
UBOOT_SHASUM = 4f70106beafe30df8b0528a3d8b2543cd48fe241
$(SRCS)/.bootloader:
	$(call git_fetch,$(TFA_URL),$(TFA_SHASUM),$(SRCS)/bootloader)
	$(call git_fetch,$(UBOOT_URL),$(UBOOT_SHASUM),$(SRCS)/bootloader)
	touch $@

# GIT
KERNEL_URL = https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_SHASUM = 7aaa8047eafd0bd628065b15757d9b48c5f9c07d
$(SRCS)/.kernel:
	$(call git_fetch,$(KERNEL_URL),$(KERNEL_SHASUM),$(SRCS)/kernel)
	touch $@

# GIT
BUSYBOX_URL = https://busybox.net/busybox.git
BUSYBOX_SHASUM = ead17e7808236be80614d0a8755f4ddad63ab56c
$(SRCS)/.busybox:
	$(call git_fetch,$(BUSYBOX_URL),$(BUSYBOX_SHASUM),$(SRCS)/additional_apps)
	touch $@

# GIT
SQLITE_URL =
SQLITE_SHASUM = 1ffe6567e8986c0d3bd0384e6a1b3baefab6af51
$(SRCS)/.sqlite:
	$(call git_fetch,$(SQLITE_URL),$(SQLITE_SHASUM),$(SRCS)/additional_apps)
	touch $@

# FILE/ GIT
LIBXCRYPT_URL = https://github.com/besser82/libxcrypt/releases/download/v4.5.2/libxcrypt-4.5.2.tar.xz
LIBXCRYPT_SHASUM = 71513a31c01a428bccd5367a32fd95f115d6dac50fb5b60c779d5c7942aec071
DROPBEAR_URL = https://github.com/mkj/dropbear.git 
DROPBEAR_SHASUM = 59870ad43153fe8d4f1c96f5d5752116c94f31ff
$(SRCS)/.dropbear:
	$(call file_fetch,$(LIBXCRYPT_URL),$(LIBXCRYPT_SHASUM),$(SRCS)/additional_apps)
	$(call git_fetch,$(DROPBEAR_URL),$(DROPBEAR_SHASUM),$(SRCS)/additional_apps)
	touch $@

build: 
$(SRCS)/bootloader/trusted-firmware-a/build/rk3399/release/bl31/bl31.elf:
$(DSTS)/bootloader/rockpro/dts/upstream/src/arm64/rockchip/rk3399-rockpro64.dtb:
$(DSTS)/kernel/build_arm64/arch/arm64/boot/Image:
$(DSTS)/kernel/rockpro/uRamdisk:
