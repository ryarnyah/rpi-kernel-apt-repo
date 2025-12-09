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

# Patch to add README that is needed
# Revert https://github.com/raspberrypi/linux/commit/bb1aa4df9550aa41f6c848758cbf3959f79b2401
sed -i 's/^dtb\-\(.*\)$/dtb-\1 README/' arch/arm/boot/dts/overlays/Makefile

export KERNEL=kernel8
# Setup configuration for Raspberry Pi 4 (64-bit)
make bcm2711_defconfig

# Set custom version
sed -i "s/CONFIG_LOCALVERSION=.*/CONFIG_LOCALVERSION=\"-mainline-rpi-v8\"/g" .config

git config --global user.email "ignoreme@example.com"
git config --global user.name "Ignore Me"

DEB_NAME="$(make kernelversion)-mainline-rpi-v8"
KDEB_PKGVERSION="$(make kernelversion).$BUILD_ID-1"

git tag -a "v$(make kernelversion)" -m "Release $BUILD_ID v$(make kernelversion)"

# Build kernel packages (debian package format)
make -j$(nproc) KDEB_PKGVERSION="$KDEB_PKGVERSION" deb-pkg

# Move packages to output directory
mkdir -p ../../../output
mv ../*.deb ../../../output/

# Create package list
cd ../../../output

# Build meta package
METADIR="$(mktemp -d)"
PKGDIR="$METADIR/linux-kernel-mainline-rpi-v8"
mkdir -p $PKGDIR/DEBIAN

cat > $PKGDIR/DEBIAN/control <<EOF
Package: linux-kernel-mainline-rpi-v8
Version: $KDEB_PKGVERSION
Architecture: arm64
Maintainer: Kernel Builder <builder@$(hostname)>
Depends: linux-image-$DEB_NAME (= $KDEB_PKGVERSION), linux-headers-$DEB_NAME (= $KDEB_PKGVERSION)
Section: kernel
Priority: optional
Description: Metapackage for latest Raspberry Pi 4 kernel
 This metapackage depends on the most recent kernel version.
 It will automatically pull in the newest kernel when updated.
 .
 This is version $KDEB_PKGVERSION tracking kernel $KERNEL_VERSION
EOF

dpkg-deb --build $PKGDIR linux-kernel-mainline-rpi-v8.deb
rm -rf $METADIR

ls -1 *.deb > package-list.txt

echo "Build complete. Packages generated in output/"