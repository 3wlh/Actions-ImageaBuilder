#!/bin/sh
# 固件首次启动时运行的脚本 /etc/uci-defaults/99-custom.sh
# 输出日志文件
LOGFILE="/tmp/defaults.log"
echo "Starting defaults at $(date '+%Y-%m-%d %H:%M:%S')" >> $LOGFILE

#==========================Network==========================
# 旁路设置
# uci set network.lan.proto='static'
# uci set network.lan.ipaddr="10.10.10.250"
# 添加 网关 和 DNS
uci set network.lan.gateway="10.10.10.254"
uci add_list network.lan.dns="10.10.10.254"
uci add_list network.lan.dns="8.8.8.8"
uci add_list network.lan.dns="114.114.114.114"
uci add_list network.lan.dns="233.5.5.5"
# 删除 WAN 口
uci -q delete network.wan
uci -q delete network.wan6
uci commit network

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
uci commit fstab

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
uci commit argon
#==========================DHCP==========================
# 不提供DHCP服务
uci delete dhcp.lan.force
uci set dhcp.lan.dynamicdhcp="0"
uci set dhcp.lan.ignore="1"
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
uci commit dhcp
#==========================Firewall==========================
# 默认设置WAN口防火墙打开
uci set firewall.@defaults[0].fullcone='1'
uci set firewall.@defaults[0].fullcone6='1'
uci set firewall.@defaults[0].input='ACCEPT'
uci set firewall.@defaults[0].output='ACCEPT'
uci set firewall.@defaults[0].forward='ACCEPT'
uci set firewall.@zone[1].input='ACCEPT'
uci set firewall.docker.input='ACCEPT'
uci set firewall.docker.output='ACCEPT'
uci set firewall.docker.forward='ACCEPT'
#==========================在线配置==========================
uci set scriptrun.@general[].script_url="http://3wlh.github.io/Script/OpenWrt/Config_sh/OECT.sh"
uci commit
exit 0