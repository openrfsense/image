#!/usr/bin/env bash
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

set -eu

if ! command -v vagrant &>/dev/null; then
    echo "Vagrant is not installed!"
    exit 1
fi

if [ ! -f ./config ]; then
    echo "ERROR: Missing config file! Write your own or use the provided example (see README.md)"
    exit 1
fi

if ! vagrant plugin list | grep vagrant-scp; then
    vagrant plugin install vagrant-scp
fi

_cpus="${PIGEN_CPUS:-$(nproc --ignore 2)}"
PIGEN_CPUS="$_cpus" vagrant up --provision

# Switch to armhf (master branch of pi-gen) if PIGEN_BITS is set to 32
# otherwise, use the arm64 branch
_branch=arm64
_suffix=-arm64
[[ "${PIGEN_BITS:-64}" = "32" ]] && {
    _branch=master
    _suffix=armhf
}

vagrant rsync
vagrant ssh -c bash <<EOF
set -euo pipefail
cd project

[ ! -d pi-gen ] && git clone --depth 1 -b $_branch https://github.com/RPI-Distro/pi-gen.git

cp -rf sensor-setup-stage pi-gen
cp -f config pi-gen

pushd pi-gen || exit 1
# We're ading another stage so avoid generating the image after stage2
rm stage2/EXPORT_* || true

# Add architecture and date to the image file name
export IMG_SUFFIX="$_suffix"
export IMG_DATE="$(date +%Y%m%d)"
sudo -E ./build.sh

# Cleanup
git reset --hard
rm -rf sensor-setup-stage
rm config
popd || exit 1
EOF

vagrant scp pi-gen-host:/home/vagrant/project/pi-gen/deploy .
# Remove the output directory from the VM to avoid pulling everything again on next build
vagrant ssh -c "sudo rm -rf /home/vagrant/project/pi-gen/deploy"