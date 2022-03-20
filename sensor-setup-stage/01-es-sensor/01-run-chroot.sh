#!/bin/bash -e

# Exit if command es_sensor is already installed
command -v es_sensor &>/dev/null && exit 0

pushd /tmp
wget https://github.com/Baldomo/es-sensor/archive/refs/heads/master.zip
unzip -o master.zip && rm master.zip

pushd es-sensor-master
cmake .
cpack .
dpkg -i ./*.deb
popd

rm -rf es-sensor-master
popd