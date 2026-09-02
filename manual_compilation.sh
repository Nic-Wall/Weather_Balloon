#!/bin/bash

mkdir -p manual
BUILD_DIR=$(pwd)/manual
cd $BUILD_DIR

# Build cross-compiler
mkdir -p crossCompiler
cd crossCompiler
# Install the actual cross-compiling toolchain
curl https://toolchains.bootlin.com/downloads/releases/toolchains/aarch64/tarballs/aarch64--glibc--stable-2025.08-1.tar.xz --output aarch64--glibc--stable-2025.08-1.tar.xz
tar -xf aarch64--glibc--stable-2025.08-1.tar.xz
export PATH="$PATH:$BUILD_DIR/crossCompiler/aarch64--glibc--stable-2025.08-1/bin/:$PATH"
# Install the arm-none-eabi from ARM for the compilation of the M0 driver
curl https://gitlab.arm.com/api/v4/projects/tooling%2Fgnu-toolchains-for-arm/packages/generic/gnu-toolchain/15.3.rel1/arm-gnu-toolchain-15.3.rel1-x86_64-arm-none-eabi.tar.xz --output arm-gnu-toolchain-15.3.rel1-x86_64-arm-none-eabi.tar.xz
tar -xf arm-gnu-toolchain-15.3.rel1-x86_64-arm-none-eabi.tar.xz
cd $BUILD_DIR

# Build bootloader
printf "Creating Python venv for the installation of setuptools and pyelftools...\n"
python3 -m venv forThePips
source forThePips/bin/activate
pip install setuptools
pip install pyelftools
printf "Creating manual/bootloader/ qemu and rockpro directories...\n"
mkdir -p bootloader/qemu bootloader/rockpro
cd bootloader
printf "Cloning the Trusted-Firmware-A (TFA) github (lts-v2.8) repo...\n"
git clone --depth 1 -b lts-v2.8 https://github.com/TrustedFirmware-A/trusted-firmware-a.git
cd trusted-firmware-a
make distclean
printf "Compiling the Trusted-Firmware-A reference implementation for the rk3399 platform...\n"
make CROSS_COMPILE=aarch64-buildroot-linux-gnu- PLAT=rk3399
cd ..

printf "Cloning the U-Boot (v2026.04) repository...\n"
git clone https://source.denx.de/u-boot/u-boot.git
cd u-boot
git checkout v2026.04-rc3
make mrproper
printf "Copying the pre-made U-Boot .config into the manual/bootloader/rockpro directory...\n"
cp $BUILD_DIR/../manual_configs/rockpro_uboot.config ../rockpro/.config
printf "Adding BL31 shell variable, created during the compilation of TFA, for the rk3399 platform...\n"
export BL31=../trusted-firmware-a/build/rk3399/release/bl31/bl31.elf
printf "Compiling the rockpro64-rk3399 U-Boot binary...\n"
# Below is imported from manual_configs 
#make rockpro64-rk3399_defconfig
make CROSS_COMPILE=aarch64-buildroot-linux-gnu- O=../rockpro
make mrproper
printf "Removing the BL31 shell variable...\n"
unset BL31
printf "Compiling the QEMU U-Boot binary for arm64...\n"
make qemu_arm64_defconfig O=../qemu
make CROSS_COMPILE=aarch64-buildroot-linux-gnu- O=../qemu
cd $BUILD_DIR
printf "Finished setting up U-Boot for QEMU and the RockPro board...\n"

# Build kernel
printf "Creating manual/kernel/ modules and build_arm64 directories...\n"
mkdir -p kernel/modules kernel/build_arm64
cd kernel
printf "Cloning the linux-stable kernel source (v7.0-rc6)...\n"
git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
cd linux-stable
git checkout v7.0-rc6
#printf "Preparing the linux-stable kernel for compilation...\n"
#make ARCH=arm64 CROSS_COMPILE=aarch64-buildroot-linux-gnu- O=../build_arm64 prepare
printf "Copying the the pre-made Linux kernel .config into the manual/kernel/build_arm64 directory...\n"
cp $BUILD_DIR/../manual_configs/rockpro_kernel.config ../build_arm64/.config
printf "Compiling the kernel into manual/kernel/build_arm64/Image.gz\n"
make -j$(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-buildroot-linux-gnu- Image.gz O=../build_arm64
printf "Compiling the device tree into the manual/kernel/build_arm64 directory...\n"
make ARCH=arm64 dtbs CROSS_COMPILE=aarch64-buildroot-linux-gnu- O=../build_arm64
printf "Compiling and installing the modules into the manual/kernel/modules directory...\n"
make -j$(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-buildroot-linux-gnu- INSTALL_MOD_PATH=../modules O=../build_arm64
make -j$(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-buildroot-linux-gnu- INSTALL_MOD_PATH=../modules O=../build_arm64 modules_install
cd $BUILD_DIR
printf "Finished compiling the Linux kernel, device tree, and modules...\n"

# Build rootfs
printf "Creating the filesystem directory for coreutils and rootfs at manual/filesystem...\n"
mkdir -p filesystem
cd filesystem
mkdir rootfs
cd rootfs
printf "Creating the skeleton directory structure for the root filesystem...\n"
mkdir -p bin dev etc/init.d home lib proc sbin sys tmp usr/bin usr/lib usr/sbin var/log
printf "Linking lib with lib64 in manual/filesystem/rootfs...\n"
ln -s lib lib64
printf "Copying the pre-made etc files into rootfs/etc...\n"
cp -r $BUILD_DIR/../manual_configs/rfs_etc/* etc/
printf "SUDO REQUIRED: Building the modules dev/null and dev/console in manual/filesystem/rootfs...\n"
sudo mknod -m 666 dev/null c 1 3
sudo mknod -m 600 dev/console c 5 1
printf "Copying the linux modules into manual/filesystem/rootfs/lib/modules...\n"
cp -a $BUILD_DIR/kernel/modules/lib/modules lib/
printf "Removing the symlinked lib/modules/7.0.0-rc6wb-0.1 from the rootfs to prevent missing directory errors...\n"
rm -r lib/modules/7.0.0-rc6wb-0.1/build
cd $BUILD_DIR
printf "Finished creating the rootfs...\n"

# Build BusyBox (core utils)
printf "Cloning the BusyBox (1_38_0) source...\n"
git clone git://busybox.net/busybox.git
cd busybox
# Version 1_38_0 was not available for checkout at the time of writing, only 1_37_0, so I used the SHA instead
git checkout ead17e7808236be80614d0a8755f4ddad63ab56c
make distclean
printf "Copying the pre-made BusyBox .config into manual/filesystem/u-boot/.config...\n"
cp $BUILD_DIR/../manual_configs/rockpro_busybox.config .config
printf "Compiling BusyBox..."
make ARCH=arm64 CROSS_COMPILE=aarch64-buildroot-linux-gnu-
printf "Installing BusyBox into manual/filesystem/rootfs...\n"
make ARCH=arm64 CROSS_COMPILE=aarch64-buildroot-linux-gnu- install
cd ..
printf "SUDO REQUIRED: chown root:root and setuid root for the busybox binary in manual/filesystem/rootfs/usr/bin/busybox...\n"
sudo chown root:root rootfs/bin/busybox
sudo chmod u+s rootfs/bin/busybox
cd ..
printf "Finished creating and installing BusyBox core-utils...\n"

# Generate initramfs
cd kernel
printf "Creating manual/kernel/ rockpro and qemu directories for each mkinitcpio...\n"
mkdir -p rockpro qemu
printf "Copying build_arm64/usr/gen_init_cpio into linux-stable/usr to prep for the initramfs generation...\n"
cp build_arm64/usr/gen_init_cpio linux-stable/usr
printf "Generating initramfs (-u 1000 -g 1000) into manual/kernel based on manual/filesystem/rootfs...\n"
cd linux-stable
./usr/gen_initramfs.sh -o ../initramfs.cpio -u 1000 -g 1000 ../../filesystem/rootfs/
cd ..
printf "gzip-ing the initramfs...\n"
gzip initramfs.cpio
printf "Moving and copying the initramfs into the manual/kernel/ rockpro and qemu directories before imaging..."
mv initramfs.cpio.gz ./rockpro/
cp ./rockpro/initramfs.cpio.gz ./qemu/
printf "Creating initramfs.cpio.gz and uRamdisk with U-Boot's mkimage tool...\n"
cd rockpro
$BUILD_DIR/bootloader/rockpro/tools/mkimage -A arm64 -O linux -T ramdisk -d initramfs.cpio.gz uRamdisk
cd ../qemu
$BUILD_DIR/bootloader/qemu/tools/mkimage -A arm64 -O linux -T ramdisk -d initramfs.cpio.gz uRamdisk
printf "Finished generating initramfs...\n"

# Deactivating the forThePips venv
deactivate

printf "All processes completed...\n"
