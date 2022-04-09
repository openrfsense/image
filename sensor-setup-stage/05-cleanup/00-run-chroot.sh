#!/bin/bash -e

apt-get purge -q -y cmake git file build-essential debhelper
apt-get autoremove -q -y
apt-get clean -q -y