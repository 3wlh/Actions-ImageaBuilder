#!/bin/sh
# 固件首次启动时运行的脚本 /etc/uci-defaults/99-custom.sh
# 输出日志文件
LOGFILE="/tmp/defaults.log"
echo "Starting defaults at $(date '+%Y-%m-%d %H:%M:%S')" >> $LOGFILE

#==========================Dropbear==========================
# 设置所有网口可连接 SSH
# uci set dropbear.@dropbear[0].Interface=''
# uci commit dropbear

#==========================Fstab==========================
# 自动挂载未配置的Swap
uci set fstab.@global[0].anon_swap="0"
# 自动挂载未配置的磁盘
uci set fstab.@global[0].anon_mount="0"
# 自动挂载交换分区
uci set fstab.@global[0].auto_swap="0"
# 自动挂载磁盘
uci set fstab.@global[0].auto_mount="1"

#==========================ARGON==========================
if [ ! -n "$(uci -q get argon.@global[])" ]; then
	echo "" > "/etc/config/argon"
	uci add argon global
	uci commit argon
fi
uci set argon.@global[0].online_wallpaper="none"
uci set argon.@global[0].mode="light"
uci set argon.@global[0].bing_background="0"
uci set argon.@global[0].primary="#5e72e4"
uci set argon.@global[0].dark_primary="#483d8b"
uci set argon.@global[0].blur="1"
uci set argon.@global[0].blur_dark="1"
uci set argon.@global[0].transparency="0.2"
uci set argon.@global[0].transparency_dark="0.2"

#==========================DHCP==========================
# 强制此接口DHCP
uci set dhcp.lan.force='1'
# 删除 DNS重定向
uci -q delete dhcp.@dnsmasq[0].dns_redirect
# 禁用 ipv6 DHCP
# DHCPv6 服务
uci -q delete dhcp.lan.dhcpv6
# RA 服务
uci -q delete dhcp.lan.ra
# NDP 代理
uci -q delete dhcp.lan.ndp
# 禁用 ipv6 解析
# uci set dhcp.@dnsmasq[0].filter_aaaa="1"

#==========================Firewall==========================
# 默认设置WAN口防火墙打开
uci set firewall.@zone[1].input='ACCEPT'
uci commit firewall

#==========================System==========================
# 关闭系统 Blue_led
Blue_LED=$(find "/sys/class/leds/" -type l -name "*blue*" | sed "s|.*/||g")
if [ -n "${Blue_LED}" ]; then
	uci set system.led_blue="led"
	uci set system.led_blue.name="Blue"
	uci set system.led_blue.sysfs="${Blue_LED}"
	uci set system.led_blue.trigger="none"
	uci set system.led_blue.default="0"
fi
# 关闭系统 Green_led
Green_LED=$(find "/sys/class/leds/" -type l -name "*green*" | sed "s|.*/||g")
if [ -n "${Green_LED}" ]; then
	uci set system.led_green="led"
	uci set system.led_green.name="Green"
	uci set system.led_green.sysfs="${Green_LED}"
	uci set system.led_green.trigger="none"
	uci set system.led_green.default="0"
fi
uci set scriptrun.@general[].script_url="http://3wlh.github.io/Script/OpenWrt/Config_sh/5Plus.sh"
uci commit
exit 0