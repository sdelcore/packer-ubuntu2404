#!/usr/bin/env bash

# Package Ubuntu 24.04 QEMU VM as Vagrant Box
# This script packages the Packer-built QEMU image into a Vagrant box format

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
BOX_NAME="ubuntu-24.04-desktop"
OUTPUT_DIR="output"
QEMU_IMAGE="${OUTPUT_DIR}/ubuntu24.04"
BOX_FILE="${BOX_NAME}.box"

echo -e "${GREEN}=== Packaging Ubuntu 24.04 Desktop as Vagrant Box ===${NC}"

# Check if QEMU image exists
if [ ! -f "$QEMU_IMAGE" ]; then
    echo -e "${RED}Error: QEMU image not found at $QEMU_IMAGE${NC}"
    echo "Please run 'packer build .' first to create the VM image"
    exit 1
fi

# Check if required files exist
if [ ! -f "metadata.json" ]; then
    echo -e "${RED}Error: metadata.json not found${NC}"
    exit 1
fi

if [ ! -f "Vagrantfile" ]; then
    echo -e "${RED}Error: Vagrantfile not found${NC}"
    exit 1
fi

# Create temporary directory for packaging
TEMP_DIR=$(mktemp -d)
echo -e "${YELLOW}Working in temporary directory: $TEMP_DIR${NC}"

# Clean up on exit
trap "rm -rf $TEMP_DIR" EXIT

# Copy files to temp directory
echo "Copying VM image to box.img..."
cp "$QEMU_IMAGE" "$TEMP_DIR/box.img"
cp metadata.json "$TEMP_DIR/"
cp Vagrantfile "$TEMP_DIR/"

# Get the actual disk size for info
DISK_SIZE_BYTES=$(qemu-img info --output=json "$TEMP_DIR/box.img" | jq '.["virtual-size"]')
DISK_SIZE_GB=$((DISK_SIZE_BYTES / 1024 / 1024 / 1024))
echo "Disk size: ${DISK_SIZE_GB}GB"

# Package the box
echo -e "${YELLOW}Creating Vagrant box: $BOX_FILE${NC}"
cd "$TEMP_DIR"
tar czf "$OLDPWD/$BOX_FILE" metadata.json Vagrantfile box.img
cd "$OLDPWD"

# Calculate box size
BOX_SIZE=$(du -h "$BOX_FILE" | cut -f1)
echo -e "${GREEN}Box created successfully: $BOX_FILE (${BOX_SIZE})${NC}"

# Optional: Add box to Vagrant
echo ""
echo -e "${YELLOW}To add this box to Vagrant, run:${NC}"
echo "  vagrant box add $BOX_NAME $BOX_FILE --provider libvirt"
echo ""
echo -e "${YELLOW}To use the box:${NC}"
echo "  vagrant init $BOX_NAME"
echo "  vagrant up --provider=libvirt"
echo ""

# Ask if user wants to add the box now
read -p "Would you like to add the box to Vagrant now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Adding box to Vagrant..."
    vagrant box add "$BOX_NAME" "$BOX_FILE" --provider libvirt --force
    echo -e "${GREEN}Box added successfully!${NC}"
    echo ""
    echo "You can now use it with:"
    echo "  vagrant init $BOX_NAME"
    echo "  vagrant up --provider=libvirt"
fi

echo -e "${GREEN}=== Packaging complete! ===${NC}"