#!/bin/bash -e

# Exit if package electrosense-decoders is already installed
dpkg-query -l electrosense-decoders &>/dev/null && exit 0

pushd /tmp
wget https://github.com/Baldomo/es-sensor-decoders/archive/refs/heads/master.zip
unzip -o -q master.zip && rm master.zip

pushd es-sensor-decoders-master
export DEB_CFLAGS_APPEND="-fcommon"
export DEB_CXXFLAGS_APPEND="-fcommon"
dpkg-buildpackage -us -uc
popd

rm -rf es-sensor-decoders-master
dpkg -i electrosense-decoders_*_*.deb
popd