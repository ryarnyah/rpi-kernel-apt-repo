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

export KERNEL=kernel8
# Setup configuration for Raspberry Pi 4 (64-bit)
make bcm2711_defconfig

git config --global user.email "ignoreme@example.com"
git config --global user.name "Ignore Me"

git tag -a "v$(make kernelversion)" -m "Release $BUILD_ID v$(make kernelversion)"

# Build kernel packages (debian package format)
make -j$(nproc) KDEB_PKGVERSION="1.$BUILD_ID" deb-pkg

# Move packages to output directory
mkdir -p ../../../output
mv ../*.deb ../../../output/

# Create package list
cd ../../../output
ls -1 *.deb > package-list.txt

echo "Build complete. Packages generated in output/"