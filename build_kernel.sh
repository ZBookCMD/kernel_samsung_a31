#!/bin/bash

build_dir="$(pwd)/out"
log="$build_dir/LOG"

export CROSS_COMPILE=/android/bin/aarch64-linux-android-
export CC=/android/bin/clang
export CLANG_TRIPLE=aarch64-linux-gnu-
export LDFLAGS=""
export ARCH=arm64
export ANDROID_MAJOR_VERSION=r

export KCFLAGS=-w
export CONFIG_SECTION_MISMATCH_WARN_ONLY=y

# Check if $build_dir DONT exist and create it
if [ ! -d $build_dir ]; then
	mkdir $build_dir
fi

# If .config not found, make it
if [ ! -f $build_dir/.config ]; then
	make -C $(pwd) O=$build_dir KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y a31_pmOS_defconfig
fi

# Start make kernel (if /bin/ts exist, output log with time)
if [[ -x /bin/ts || -x /usr/bin/ts ]]; then
	make -C $(pwd) O=$build_dir KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y -j2 2>&1 | ts '[%H:%M:%S]' | tee $log
else
	make -C $(pwd) O=$build_dir KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y -j2 2>&1 | tee $log
fi

# Copy Image.gz to srctree if exist
if [ -f $build_dir/arch/arm64/boot/Image.gz ]; then
	cp $build_dir/arch/arm64/boot/Image.gz $(pwd)/arch/arm64/boot/Image.gz
fi
