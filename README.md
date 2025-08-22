# Ubuntu 24.04 Desktop Vagrant Box Builder

This project automates the creation of Ubuntu 24.04 Desktop Vagrant boxes using Packer and QEMU/KVM.

## Features

- **Ubuntu 24.04 LTS** with full desktop environment
- **Automated installation** using cloud-init autoinstall
- **Pre-configured** with Vagrant SSH keys and credentials
- **Optimized** for desktop use with SPICE graphics
- **Support** for libvirt/QEMU provider

## Prerequisites

Required tools:
- Packer
- QEMU/KVM
- Vagrant with vagrant-libvirt plugin
- xorriso (for ISO creation)
- jq (for JSON processing)

## Quick Start

### 1. Build the VM Image
```bash
packer build .
```

This will:
- Download Ubuntu 24.04 Server ISO
- Run automated installation with vagrant user
- Install Ubuntu Desktop packages
- Configure SSH and sudo access
- Output a QEMU image to `output/ubuntu24.04`

Build time: ~20 minutes

### 2. Package as Vagrant Box
```bash
./package-vagrant-box.sh
```

This creates `ubuntu-24.04-desktop.box` (~1.9GB)

### 3. Add to Vagrant
```bash
vagrant box add ubuntu-24.04-desktop ubuntu-24.04-desktop.box --provider libvirt
```

### 4. Use the Box
```bash
mkdir ~/my-ubuntu-vm
cd ~/my-ubuntu-vm
vagrant init ubuntu-24.04-desktop
vagrant up --provider=libvirt
vagrant ssh
```

## Project Structure

```
.
├── auto-desktop.pkr.hcl    # Packer configuration
├── http/
│   ├── user-data          # Cloud-init autoinstall config
│   └── meta-data          # Cloud-init metadata
├── Vagrantfile            # Default box configuration
├── metadata.json          # Vagrant box metadata
└── package-vagrant-box.sh # Packaging script
```

## Configuration Details

### VM Specifications
- **Memory**: 4GB
- **CPUs**: 2
- **Disk**: 25GB
- **Graphics**: SPICE with QXL video
- **Network**: NAT with DHCP

### Credentials
- **Username**: vagrant
- **Password**: vagrant
- **SSH Key**: Vagrant insecure public key (replaced on first `vagrant up`)

### Autoinstall Configuration
The `http/user-data` file contains:
- User creation with proper SSH keys
- Package installation (desktop, development tools)
- SSH server configuration
- Sudo access without password

## Customization

### Modify VM Resources
Edit `auto-desktop.pkr.hcl`:
```hcl
memory = 8192  # Change RAM
cpus = 4       # Change CPU cores
disk_size = "50G"  # Change disk size
```

### Add Additional Packages
Edit `http/user-data` packages section:
```yaml
packages:
  - ubuntu-desktop
  - your-package-here
```

### Change Desktop Environment
Replace `ubuntu-desktop` with alternatives:
- `kubuntu-desktop` for KDE
- `xubuntu-desktop` for XFCE
- `ubuntu-mate-desktop` for MATE

## Troubleshooting

### SSH Authentication Fails
- Ensure VNC is enabled (`headless = false`) to watch installation
- Check that autoinstall completes successfully
- Verify user-data syntax is correct

### Build Timeout
- Increase `ssh_timeout` in Packer config
- Check system resources (RAM, CPU)
- Monitor installation via VNC (port 5900)

### Package Script Fails
- Ensure QEMU image exists in `output/ubuntu24.04`
- Verify `metadata.json` and `Vagrantfile` are present
- Check disk space for packaging

## Development

### Running with Debug Output
```bash
PACKER_LOG=1 packer build .
```

### Monitoring Installation
Connect VNC viewer to `localhost:5900` during build

### Cleaning Up
```bash
rm -rf output/
vagrant box remove ubuntu-24.04-desktop
```

## Files Included in Box

- `box.img` - QEMU/KVM disk image
- `metadata.json` - Provider configuration
- `Vagrantfile` - Default VM settings

## License

This project uses standard Ubuntu distribution and Vagrant configurations.

## Contributing

Feel free to submit issues and enhancement requests!