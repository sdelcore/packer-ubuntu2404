packer {
  required_plugins {
    qemu = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

source "qemu" "ubuntu" {
  iso_url          = "https://releases.ubuntu.com/24.04.3/ubuntu-24.04.3-live-server-amd64.iso"
  iso_checksum     = "sha256:c3514bf0056180d09376462a7a1b4f213c1d6e8ea67fae5c25099c6fd3d8274b"
  output_directory = "output"
  shutdown_command = "echo 'vagrant' | sudo -S shutdown -P now"
  disk_size        = "25G"
  memory           = 4096
  cpus             = 2
  format           = "qcow2"
  accelerator      = "kvm"
  ssh_username     = "vagrant"
  ssh_password     = "vagrant"
  ssh_timeout      = "90m"
  ssh_handshake_attempts = 50
  vm_name          = "ubuntu24.04"
  net_device       = "virtio-net"
  disk_interface   = "virtio"
  boot_wait        = "5s"
  efi_boot         = false
  headless         = false
  vnc_bind_address = "0.0.0.0"
  vnc_port_min     = 5900
  vnc_port_max     = 5900
  
  http_directory = "http"
  boot_command = [
    "c<wait>",
    "linux /casper/vmlinuz --- autoinstall ds='nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/'<enter><wait>",
    "initrd /casper/initrd<enter><wait>",
    "boot<enter>"
  ]

}

build {
  sources = ["source.qemu.ubuntu"]

  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 5; done",
    ]
  }

  provisioner "shell" {
    inline = [
      "echo 'Installing Ubuntu Desktop...'",
      "sudo apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y ubuntu-desktop",
      "sudo systemctl set-default graphical.target",
      "echo 'Ubuntu Desktop installation complete'"
    ]
  }
}