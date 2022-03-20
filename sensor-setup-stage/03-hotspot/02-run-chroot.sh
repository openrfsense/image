#!/bin/bash -e

mkdir -p /etc/hostapd
cat << EOF > /etc/hostapd/hostapd.conf
country_code=${WPA_COUNTRY}
interface=wlan0
ssid=OpenRFSense-Sensor
hw_mode=g
channel=7
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=openrfsense
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF

systemctl unmask hostapd
systemctl enable hostapd