#!/usr/bin/env sh

if [ -f /etc/dnsmasq.ap.conf ]; then
    # wrong mode
    exit 0
fi

# Disable AP
systemctl disable --now hostapd
systemctl disable --now dnsmasq

# Restore original dhcpcd config
mv /etc/dhcpcd.conf /etc/dhcpcd.ap.conf
mv /etc/dhcpcd.orig.conf /etc/dhcpcd.conf
systemctl restart dhcpcd

# Enable normal WiFi
systemctl enable --now wpa_supplicant