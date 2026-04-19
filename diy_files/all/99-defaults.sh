#!/bin/sh
# 固件首次启动时运行的脚本 /etc/uci-defaults/99-defaults.sh
# 输出日志文件
LOGFILE="/tmp/defaults.log"
echo "Starting 99-defaults.sh at $(date '+%Y-%m-%d %H:%M:%S')" >> $LOGFILE
#=================== 获取key ===================
mac="$(ip -o link show eth0 2>/dev/null | grep -Eo 'permaddr ([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}' | awk '{print $NF}')"
[ -z "${mac}" ] && mac="$(cat /sys/class/net/eth0/address 2>/dev/null)"
[ -n "${mac}" ] && key="$(echo -n "${mac}" | md5sum | awk '{print $1}' | cut -c9-24)"
function AES_D(){ #解密函数
[ -z "$1" ] || echo "$1" | tr -d "\n" |openssl enc -e -aes-128-cbc -a -K ${key} -iv ${key} -base64 -d 2>/dev/null
}
# 检查配置文件diy-settings是否存在
SETTINGS_FILE="/etc/config/diy-settings"
if [ -f "$SETTINGS_FILE" ]; then
   # 读取diy-settings信息
   source "$SETTINGS_FILE"
fi

#=================== 设置LAN口IP ===================
if [ -n "${settings_lan}" ]; then
uci set network.lan.ipaddr="${settings_lan}"
fi
#==================== 添加插件源 ====================
# sed -i "s/option check_signature/# option check_signature/g" "/etc/opkg.conf"
opkg-conf="/etc/opkg/customfeeds.conf"
sed -i '$a\src/gz 3wlh https://packages.11121314.xyz/packages/aarch64_generic' ${opkg-conf}

#========================== TTYD ==========================
[[ -f "/etc/config/ttyd" ]] && uci delete ttyd.@ttyd[0].interface

#========================== Fstab ==========================
# 自动挂载未配置的Swap
uci set fstab.@global[0].anon_swap="0"
# 自动挂载未配置的磁盘
uci set fstab.@global[0].anon_mount="0"
# 自动挂载交换分区
uci set fstab.@global[0].auto_swap="0"
# 自动挂载磁盘
uci set fstab.@global[0].auto_mount="1"

#========================== PPPoE ==========================
# 设置拨号协议
if $enable_pppoe; then
	uci set network.wan.proto="pppoe"
	echo "PPPoE_Protocol configuration completed successfully." >> $LOGFILE
fi
if [ -n "${key}" ]; then
   account="$(AES_D "${pppoe_account}")"
   if [ -n "${account}" ]; then
      uci set network.wan.username="${account}"
      echo "PPPoE_Account configuration completed successfully." >> $LOGFILE
   fi
   password="$(AES_D "${pppoe_password}")"
   if [ -n "${password}" ]; then
      uci set network.wan.password="${password}"
      echo "PPPoE_Password configuration completed successfully." >> $LOGFILE
   fi
fi
#========================== System ==========================
# 更改名称
if [ -n "${settings_model}" ]; then
uci set system.@system[0].hostname="${settings_model}"
fi
#========================== 作者信息 ==========================
# 设置编译作者信息
FILE_PATH="/etc/openwrt_release"
NEW_DESCRIPTION="Compiled by 3wlh"
sed -i "s/DISTRIB_DESCRIPTION='[^']*'/DISTRIB_DESCRIPTION='$NEW_DESCRIPTION'/" "$FILE_PATH"
# 删除配置文件
rm -f "${SETTINGS_FILE}"
uci commit
exit 0