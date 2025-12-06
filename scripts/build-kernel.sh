#!/bin/bash
set -e

BRANCH=$1
BUILD_ID=$2
KERNEL_VERSION=$(echo $BRANCH | sed 's/rpi-//; s/\.y//')

echo "Building kernel from branch: $BRANCH"
echo "Kernel version: $KERNEL_VERSION"

# Clean and prepare workspace
rm -rf linux-build && mkdir -p linux-build
cd linux-build

# Clone raspberrypi/linux
git clone --depth 1 --branch $BRANCH https://github.com/raspberrypi/linux.git
cd linux

# Setup configuration for Raspberry Pi 4 (64-bit)
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- bcm2711_defconfig

# Set custom local version for package naming
sed -i "s/CONFIG_LOCALVERSION=.*/CONFIG_LOCALVERSION=\"-rpi-custom-$BUILD_ID\"/g" .config

# Build kernel packages (debian package format)
make -j$(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- \
  KBUILD_DEBARCH=arm64 \
  KDEB_PKGVERSION="1.$BUILD_ID" \
  deb-pkg -j$(nproc)

# Move packages to output directory
mkdir -p ../../../output
mv ../*.deb ../../../output/

# Create package list
cd ../../../output
ls -1 *.deb > package-list.txt

echo "Build complete. Packages generated in output/"