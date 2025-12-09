# Raspberry Pi Custom Kernel APT Repository

This repository provides automated builds of the latest two Raspberry Pi kernel versions.

## Installation

```bash
# Download and add GPG key
curl -sSL https://ryarnyah.github.io/rpi-kernel-apt-repo/public.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/rpi-custom-kernel.gpg

# Add repository
echo "deb [arch=arm64] https://ryarnyah.github.io/rpi-kernel-apt-repo stable main" | sudo tee /etc/apt/sources.list.d/rpi-custom-kernel.list

# Update and install
sudo apt update
sudo apt install linux-kernel-mainline-rpi-v8
