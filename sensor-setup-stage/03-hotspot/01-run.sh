#!/bin/bash -e

install -m 644 files/dhcpcd.ap.conf "${ROOTFS_DIR}/etc/"
install -m 644 files/dnsmasq.conf "${ROOTFS_DIR}/etc/"
install -m 644 files/orfs-ap-off.sh "${ROOTFS_DIR}/usr/bin/"

install -m 644 files/hostapd-stopper.timer "${ROOTFS_DIR}/lib/systemd/system/"
install -m 644 files/hostapd-stopper.service "${ROOTFS_DIR}/lib/systemd/system/"

on_chroot <<EOF
systemctl disable hostapd
systemctl disable dnsmasq
mkdir -p /etc/hostapd

cat <<AP_EOF > /etc/hostapd/hostapd.conf
country_code=${WPA_COUNTRY}
interface=wlan0
ssid=OpenRFSense Node
hw_mode=g
channel=7
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=${AP_PASSWORD:-openrfsense}
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
AP_EOF
EOF

# The AP should be enabled only if WiFi is not already configured
if [ ! -v WPA_ESSID ]; then
    on_chroot <<EOF
mv /etc/dhcpcd.conf /etc/dhcpcd.default.conf
mv /etc/dhcpcd.ap.conf /etc/dhcpcd.conf
systemctl restart dhcpcd

# Enable AP on boot
systemctl unmask hostapd
systemctl enable hostapd
systemctl enable dnsmasq

# Enable AP stopper timer
systemctl enable hostapd-stopper.timer

# Disable normal wireless networking (most boards cannot have AP and normal
# WiFi work at the same time)
# systemctl disable wpa_supplicant
EOF
fi