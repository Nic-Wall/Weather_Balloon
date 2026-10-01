# https://makefiletutorial.com/
src/crossCompiler:
	mkdir -p src/crossCompiler
	cd src/crossCompiler
	wget https://toolchains.bootlin.com/downloads/releases/toolchains/aarch64/tarballs/aarch64--glibc--stable-2025.08-1.tar.xz
	tar -xf aarch64--glibc--stable-2025.08-1.tar.xz
	rm aarch64--glibc--stable-2025.08-1.tar.xz
	wget https://gitlab.arm.com/api/v4/projects/tooling%2fgnu-toolchains-forarm/packages/generic/gnu-toolchains/15.3.rel1/arm-gnu-toolchain-15.3.rel1-x86_64-arm-none-eabi.tar.xz
	tar -xf arm-gnu-toolchain-15.3.rel1-x86_64-arm-none-eabi.tar.xz
	rm arm-gnu-toolchain-15.3.rel1-x86_64-arm-none-eabi.tar.xz

src/bootloader:
	mkdir -p src/bootloader/qemu src/bootloader/rockpro
	cd src/bootloader
