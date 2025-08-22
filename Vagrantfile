Vagrant.configure("2") do |config|
  # Default settings for this box
  config.vm.box = "ubuntu-24.04-desktop"
  
  # SSH configuration
  config.ssh.username = "vagrant"
  config.ssh.password = "vagrant"
  config.ssh.insert_key = false
  
  # Libvirt provider settings
  config.vm.provider :libvirt do |libvirt|
    libvirt.memory = 4096
    libvirt.cpus = 2
    
    # Graphics settings for desktop
    libvirt.graphics_type = "spice"
    libvirt.video_type = "qxl"
    libvirt.graphics_autoport = true
    libvirt.sound_type = "ich6"
    
    # Enable SPICE channel for better desktop experience
    libvirt.channel :type => 'spicevmc', 
                    :target_name => 'com.redhat.spice.0', 
                    :target_type => 'virtio'
    
    # Enable shared clipboard
    libvirt.channel :type => 'spicevmc',
                    :target_name => 'org.spice-space.webdav.0',
                    :target_type => 'virtio'
  end
  
  # Synced folder using rsync (most compatible)
  config.vm.synced_folder ".", "/vagrant", type: "rsync"
  
  # Optional: VirtualBox settings if converted later
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "4096"
    vb.cpus = 2
    vb.gui = true
    vb.customize ["modifyvm", :id, "--vram", "128"]
    vb.customize ["modifyvm", :id, "--accelerate3d", "on"]
  end
end