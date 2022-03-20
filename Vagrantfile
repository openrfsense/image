# Copyright (C) 2022 OpenRFSense
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

CPUS = ENV["PIGEN_CPUS"] || 4
RAM = ENV["PIGEN_RAM"] || 8192

# Provisioning
$bootstrap= <<-SCRIPT
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
APT_PKGS=(
    apt-utils
    coreutils
    quilt
    parted
    qemu-user-static
    debootstrap
    zerofree
    zip
    dosfstools
    libarchive-tools
    libcap2-bin
    grep
    rsync
    xz-utils
    file
    git
    curl
    bc
    qemu-utils
    kpartx
    gpg
    pigz
)
apt-get install -y "${APT_PKGS[@]}"
SCRIPT

$set_environment_variables = <<SCRIPT
cat > /etc/profile.d/envvars.sh <<EOF
export ARCH=#{ENV["ARCH"]}
export LANGUAGE=en_US.UTF-8 
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
EOF
SCRIPT

$post_installation= <<-SCRIPT
apt-get autoclean -y
apt-get autoremove -y
SCRIPT

Vagrant.configure("2") do |config|
    config.vm.define "pi-gen-host" do |pgh|
        pgh.vm.box = "bento/debian-11"

        pgh.vm.provider "virtualbox" do |vb, override|
            vb.cpus = CPUS
            vb.memory = RAM

            vb.customize ["setextradata", :id, "VBoxInternal/CPUM/SSE4.1", "1"]
            vb.customize ["setextradata", :id, "VBoxInternal/CPUM/SSE4.2", "1"]

            override.vm.synced_folder ".", "/vagrant", disabled: true
            # Virtualbox synced folders are just fancy mounts and pi-gen doesn't like those
            override.vm.synced_folder ".", "/home/vagrant/project", type: "rsync", 
                rsync__auto: true,
                # The pi-gen folder can always be pulled as a submodule anyways and overwriting it
                # breaks consecutive builds
                rsync__exclude: ["*.zip", "*.img", "pi-gen/*"]
        end

        pgh.vm.hostname = "pi-gen-host"
        pgh.vm.box_check_update = true

        pgh.vm.provision "shell", privileged: true, inline: <<-SCRIPT
        #!/bin/bash
        echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
        locale-gen en_US.UTF-8
        SCRIPT
        pgh.vm.provision :shell, inline: $set_environment_variables
        pgh.vm.provision :shell, inline: $bootstrap, privileged: true
        pgh.vm.provision :shell, inline: $post_installation, privileged: true
    end
end