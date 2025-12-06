#!/bin/bash
set -e

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
Label: RPi Mainline Kernel
Codename: stable
Architectures: arm64 armhf all
Components: main
Description: Mainline built Raspberry Pi kernels
SignWith: $KEY_ID
DebOverride: override.stable
DscOverride: override.stable
EOF

# Create options file for reprepro
cat > $REPO_DIR/conf/options <<EOF
verbose
basedir $REPO_DIR
dbdir $REPO_DIR/db
outdir $REPO_DIR/pool
EOF

# Download packages from GitHub Release
cd artifacts
RELEASE_TAG="build-$BUILD_ID"
wget -q $(curl -s https://api.github.com/repos/${{ github.repository }}/releases/tags/$RELEASE_TAG | \
  grep browser_download_url | grep '\.deb' | cut -d'"' -f4)

# Import packages into reprepro
cd $REPO_DIR
for deb in ../artifacts/*.deb; do
  reprepro includedeb stable "$deb"
done

# Export public key
gpg --export --armor ${{ secrets.KEY_ID }} > $REPO_DIR/public.key

# Create README and setup instructions
cat > $REPO_DIR/README.md <<EOF
# Raspberry Pi Custom Kernel Repository

## Usage

1. Add the GPG key:
\`\`\`bash
wget -qO- https://${{ github.repository_owner }}.github.io/${{ github.event.repository.name }}/public.key | sudo apt-key add -
\`\`\`

2. Add the repository:
\`\`\`bash
echo "deb https://${{ github.repository_owner }}.github.io/${{ github.event.repository.name }} stable main" | sudo tee /etc/apt/sources.list.d/rpi-custom-kernel.list
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