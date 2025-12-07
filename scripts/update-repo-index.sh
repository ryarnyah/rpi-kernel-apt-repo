#!/bin/bash
set -ex

BUILD_ID=$1
BRANCH=$2
KEY_ID=$3
REPO_DIR="../gh-pages"
REPO_NAME="rpi-kernel-custom"

echo "Updating APT repository index..."

# Create repository structure
mkdir -p $REPO_DIR/conf $REPO_DIR/pool/main

# Create distributions file
cat > $REPO_DIR/conf/distributions <<EOF
Origin: Raspberry Pi Mainline Kernel
Label: RPi arm64 Mainline Kernel
Codename: stable
Architectures: arm64
Components: main
Description: Mainline built Raspberry Pi kernels
SignWith: $KEY_ID
EOF

# Create options file for reprepro
cat > $REPO_DIR/conf/options <<EOF
verbose
basedir $REPO_DIR
dbdir $REPO_DIR/db
outdir $REPO_DIR/pool
EOF

# Download packages from GitHub Release
cd ../artifacts
wget -q $(curl https://api.github.com/repos/ryarnyah/rpi-kernel-apt-repo/releases | jq -r '.[].assets.[].browser_download_url' | grep '\.deb')

# Import packages into reprepro
cd $REPO_DIR
for deb in ../artifacts/*.deb; do
  reprepro includedeb stable "$deb"
done

# Export public key
gpg --export --armor $KEY_ID > $REPO_DIR/public.key

# Create README and setup instructions
cat > $REPO_DIR/README.md <<EOF
# Raspberry Pi Custom Kernel Repository

## Usage

1. Add the GPG key:
\`\`\`bash
wget -qO- https://ryarnyah.github.io/rpi-kernel-apt-repo/public.key | sudo apt-key add -
\`\`\`

2. Add the repository:
\`\`\`bash
echo "deb https://ryarnyah.github.io/rpi-kernel-apt-repo stable main" | sudo tee /etc/apt/sources.list.d/rpi-custom-kernel.list
\`\`\`

## Available Packages
$(reprepro list stable)
EOF

# Generate Packages files
cd $REPO_DIR
apt-ftparchive packages . > Packages
gzip -k -f Packages
apt-ftparchive release . > Release
gpg --clearsign -o InRelease Release
gpg -abs -o Release.gpg Release

echo "APT repository updated successfully"