# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  config.vm.box = "debian-9-amd64"

  config.ssh.insert_key = false

  # Set libvirt to local only
  config.vm.provider :libvirt do |libvirt|
    libvirt.connect_via_ssh = false
  end

  if ENV['VAGRANT_APT_PROXY']
    config.vm.provision :shell do |s|
      s.inline = "sudo mkdir -p /etc/apt/apt.conf.d/; sudo cat > /etc/apt/apt.conf.d/proxy <<EOF
Acquire::http::proxy \"http://#{ENV['VAGRANT_APT_PROXY']}/\";
EOF
sudo apt-get update >/dev/null 2>/dev/null
"
    end
  else
    config.vm.provision :shell do |s|
      s.inline = "sudo rm -f /etc/apt/apt.conf.d/proxy"
    end
  end

  config.vm.synced_folder ".", "/home/vagrant/alternc", type: "nfs"

  config.vm.synced_folder ".", "/vagrant", type: "nfs"

  if Vagrant.has_plugin?("vagrant-cachier")
    # Configure cached packages to be shared between instances of the same base box.
    # More info on the "Usage" link above
    config.cache.scope = :box

    # OPTIONAL: If you are using VirtualBox, you might want to use that to enable
    # NFS for shared folders. This is also very useful for vagrant-libvirt if you
    # want bi-directional sync
    config.cache.synced_folder_opts = {
      type: :nfs,
      # The nolock option can be useful for an NFSv3 client that wants to avoid the
      # NLM sideband protocol. Without this option, apt-get might hang if it tries
      # to lock files needed for /var/cache/* operations. All of this can be avoided
      # by using NFSv4 everywhere. Please note that the tcp option is not the default.
      mount_options: ['rw', 'vers=3', 'tcp', 'nolock']
    }
  end

  if Vagrant.has_plugin?("vagrant-hostmanager")
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.manage_guest = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = true
    config.hostmanager.aliases = %w(alternc.local test.alternc.local)
  else
    # Make sure we have a correct hostname for alternc
    # Must be checked before puppet runs alternc.install
    # The default user creation could fail without notice otherwise
    # see https://github.com/AlternC/AlternC/issues/510
    config.vm.provision :shell do |s|
      s.inline = "hostname=`hostname -f`; if [[ ${hostname//[^.]} == \"\" ]]; then hostnamectl set-hostname \"$hostname.local\"; echo \"Hostname set to $hostname.local\"; fi"
    end
  end

  # Install puppet and requirements
  config.vm.provision :shell do |s|
    s.inline = "sudo apt-get -y install puppet tzdata util-linux lsb-release augeas-tools pciutils"
  end

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file  = "default.pp"
    #puppet.options = "--verbose --debug"
    if Vagrant.has_plugin?("vagrant-librarian-puppet")
      config.librarian_puppet.puppetfile_dir = "puppet"
      puppet.module_path = "puppet/modules"
      # Makes changing the puppet code easier
      puppet.synced_folder_type = "nfs"
    end
  end

end
