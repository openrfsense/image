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

{
    if ! command -v es_sensor &>/dev/null; then
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
    vagrant rsync
    vagrant ssh -c "cd project && sudo ./build.sh"

    vagrant scp pi-gen-host:/home/vagrant/project/pi-gen/deploy .
}