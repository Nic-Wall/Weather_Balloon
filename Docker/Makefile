# https://makefiletutorial.com/

# Rules
CC = /srcs/cross_compiler/aarch64--glibc--stable-2025.08-1/bin/aarch64-buildroot-linux-gnu-gcc

# SHA-Sums
bootlin_toolchain_sha := dfb47eee874eef9e8a7fc042eee4e0a183f444b6bcde6a82fef8f009918389c9
arm_none_eabi_sha := 563bebb2b97d53382b956d6ee1fe61e2cae26699901417234a37df505ef9b5fa
libxcrypt_sha := 71513a31c01a428bccd5367a32fd95f115d6dac50fb5b60c779d5c7942aec071
sqlite_sha := 820698fcb134775a5685e4b9bae1921ce938574c76c48bc23f70d2e2841f6150
# Pinned Git Versions
trusted_firmware_a_git := lts-v2.8
uboot_git := v2026.04-rc3
kernel_git := v7.0-rc6
busybox_git := ead17e7808236be80614d0a8755f4ddad63ab56c
dropbear_git := DROPBEAR_2026.94-2-g59870ad4

bootstrap:
	# Cross-Compiler Toolchain
	mkdir -p /srcs/cross_compiler
	wget -N https://toolchains.bootlin.com/downloads/releases/toolchains/aarch64/tarballs/aarch64--glibc--stable-2025.08-1.tar.xz -O /srcs/cross_compiler/aarch64--glibc--stable-2025.08-1.tar.xz
	# arm-none-eabi
	wget -N https://gitlab.arm.com/api/v4/projects/tooling%2Fgnu-toolchains-for-arm/packages/generic/gnu-toolchain/15.3.rel1/arm-gnu-toolchain-15.3.rel1-x86_64-arm-none-eabi.tar.xz -O /srcs/cross_compiler/arm-gnu-toolchain-15.3.rel1-x86_64-arm-none-eabi.tar.xz
	# Trusted-Firmware-A
	mkdir -p /srcs/bootloader
	git clone --branch $(trusted_firmware_a_git) https://github.com/TrustedFirmware-A/trusted-firmware-a.git /srcs/bootloader/
	# U-Boot
	git clone --branch $(uboot_git) https://source.denx.de/u-boot/u-boot.git /srcs/bootloader/
	# Kernel
	mkdir -p /srcs/kernel
	git clone --branch $(kernel_git) git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git /srcs/kernel/
	# BusyBox
	mkdir -p /srcs/additional_apps
	git clone --branch $(busybox_git) git://busybox.net/busybox.git /srcs/additional_apps/
	# SQLite
	wget https://sqlite.org/snapshot/sqlite-snapshot-202607312245.tar.gz -O /srcs/additional_apps/sqlite-snapshot-202607312245.tar.gz
	# libxcrypt	
	wget https://github.com/besser82/libxcrypt/releases/download/v4.5.2/libxcrypt-4.5.2.tar.xz -O /libxcrypt-4.5.2.tar.xz
	# Dropbear
	git clone --branch $(dropbear_git) https://github.com/mkj/dropbear.git /srcs/additional_apps/

