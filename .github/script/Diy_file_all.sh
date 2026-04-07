#!/bin/bash
mkdir -p "$(pwd)/files/www/luci-static/resources/view/status/include" &&
wget -q https://github.com/3wlh/Actions-ImageaBuilder/releases/download/GitHub-Files/29_ports.js \
-O $(pwd)/files/www/luci-static/resources/view/status/include/29_ports.js

[[ -d "$(pwd)/files/etc/uci-defaults" ]] || mkdir -p "$(pwd)/files/etc/uci-defaults"
[[ -f "$(pwd)/files/99-defaults.sh" ]] && \
mv -f "$(pwd)/files/99-defaults.sh" "$(pwd)/files/etc/uci-defaults"

[[ -f "$(pwd)/all/sys-bash.sh" ]] && \
mv -f "$(pwd)/all/sys-bash.sh" "$(pwd)/files/etc/uci-defaults"

[[ -f "$(pwd)/all/sys-opkg.sh" ]] && \
mv -f "$(pwd)/all/sys-opkg.sh" "$(pwd)/files/etc/uci-defaults"

[[ -d "$(pwd)/files/etc/profile.d" ]] || mkdir -p "$(pwd)/files/etc/profile.d"
[[ -f "$(pwd)/all/sys-sysinfo.sh" ]] && \
mv -f "$(pwd)/all/sys-sysinfo.sh" "$(pwd)/files/etc/profile.d"

