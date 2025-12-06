# Raspberry Pi Custom Kernel APT Repository

This repository provides automated builds of the latest two Raspberry Pi kernel versions.

## Installation

```bash
# Download and add GPG key
curl -sSL https://[USERNAME].github.io/[REPO-NAME]/public.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/rpi-custom-kernel.gpg

# Add repository
echo "deb [arch=arm64] https://[USERNAME].github.io/[REPO-NAME] stable main" | sudo tee /etc/apt/sources.list.d/rpi-custom-kernel.list

# Update and install
sudo apt update
sudo apt install raspberrypi-kernel-custom