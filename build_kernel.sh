#!/bin/bash
set -e

mkdir -p out

# Use variables or take from environment if set
BUILD_CROSS_COMPILE="${BUILD_CROSS_COMPILE:-$(pwd)/toolchains/google/bin/aarch64-linux-android-}"
KERNEL_LLVM_BIN="${KERNEL_LLVM_BIN:-$(pwd)/toolchains/clang/bin/clang}"
CLANG_TRIPLE="${CLANG_TRIPLE:-aarch64-linux-gnu-}"
KERNEL_MAKE_ENV="DTC_EXT=$(pwd)/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y"
JOBS="${JOBS:-$(nproc --all)}"
DEFCONFIG="${1:-vendor/a42xq_eur_open_defconfig}"

# Build defconfig
make -j"${JOBS}" -C "$(pwd)" O="$(pwd)/out" $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE="$BUILD_CROSS_COMPILE" REAL_CC="$KERNEL_LLVM_BIN" CLANG_TRIPLE="$CLANG_TRIPLE" "$DEFCONFIG"

# Build kernel
make -j"${JOBS}" -C "$(pwd)" O="$(pwd)/out" $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE="$BUILD_CROSS_COMPILE" REAL_CC="$KERNEL_LLVM_BIN" CLANG_TRIPLE="$CLANG_TRIPLE"

# Copy kernel image if it exists
if [ -f out/arch/arm64/boot/Image ]; then
  mkdir -p arch/arm64/boot
  cp out/arch/arm64/boot/Image arch/arm64/boot/Image
else
  echo "Kernel image not found!"
  exit 1
fi
