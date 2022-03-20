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

set -euo pipefail

{
    [ ! -d pi-gen ] && git clone --depth 1 -b arm64 https://github.com/RPI-Distro/pi-gen.git

    cp -rf sensor-setup-stage pi-gen
    cp -f config pi-gen

    pushd pi-gen || exit 1
    rm stage2/EXPORT_* || true
    ./build.sh

    git reset --hard
    rm -rf sensor-setup-stage
    rm config
    popd || exit 1
}