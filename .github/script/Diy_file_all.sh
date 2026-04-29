#!/bin/bash
URL="https://raw.githubusercontent.com/3wlh/Actions-ImageaBuilder/refs/heads/main/files/"

[ -d "$(pwd)/files/etc/uci-defaults" ] || mkdir -p "$(pwd)/files/etc/uci-defaults"
wget -q "${URL}/99-defaults.sh" -O "$(pwd)/files/etc/uci-defaults/99-defaults.sh"
wget -q "${URL}/sys-opkg.sh" -O "$(pwd)/files/etc/uci-defaults/sys-opkg.sh"
wget -q "${URL}/sys-bash.sh" -O "$(pwd)/files/etc/uci-defaults/sys-bash.sh"

[ -d "$(pwd)/files/etc/profile.d" ] || mkdir -p "$(pwd)/files/etc/profile.d"
wget -q "${URL}/sys-sysinfo.sh" -O "$(pwd)/files/etc/profile.d/sys-sysinfo.sh"

mkdir -p "$(pwd)/files/www/luci-static/resources/view/status/include" &&
wget -q "${URL}/29_ports.js" -O "$(pwd)/files/www/luci-static/resources/view/status/include/29_ports.js"