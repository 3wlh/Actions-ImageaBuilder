#!/bin/bash
echo "============================= 下载Script ============================="
Script_url="https://raw.githubusercontent.com/3wlh/Actions-ImageaBuilder/refs/heads/main/.github/script"
wget -q ${Script_url}/Packages_Download.sh -O "/bin/Packages_Download" && chmod 755 "/bin/Packages_Download"
wget -q ${Script_url}/Replace.sh -O "/bin/Replace" && chmod 755 "/bin/Replace"
wget -q ${Script_url}/Packages_Default.sh -O "$(pwd)/def_pkg.env" && source "$(pwd)/def_pkg.env"
[[ -f "$(pwd)/diy_config/diy_pkg.env" ]] && source "$(pwd)/diy_config/diy_pkg.env"
echo "============================= 初始化 ============================="
find . -maxdepth 1 -type f -name "repositories.conf" -exec cp {} "$(pwd)/packages/" \;
echo "============================= DIY配置 ============================="
[[ -z "${PROFILE}" ]] && { echo "获取编译设备配置失败！";exit 1; }
export Model="${Model}"
[[ -d "$(pwd)/files/etc/opkg/keys" ]] || mkdir -p "$(pwd)/files/etc/opkg/keys"
wget -qO- ${Script_url}/Diy_file_all.sh | bash
[[ -f "$(pwd)/diy_config/defaults.sh" ]] && \
cp -f "$(pwd)/diy_config/defaults.sh" "$(pwd)/files/etc/uci-defaults/99-defaults1.sh"
echo "============================= 下载插件 ============================="
[[ -d "$(pwd)/packages/diy_packages" ]] || mkdir -p "$(pwd)/packages/diy_packages"
echo "Download_Path: $(pwd)/packages/diy_packages"
[[ -d "$(pwd)/packages/diy_packages" ]] || mkdir -p "$(pwd)/packages/diy_packages"
echo "Download_Path: $(pwd)/packages/diy_packages"
[[ -f "$(pwd)/diy_config/url" ]] && Packages_Download "$(pwd)/diy_config/url" "$(pwd)/packages/diy_packages"
# 添加签名
echo -e "untrusted comment: public key 29026b52f8ff825c\nRWQpAmtS+P+CXP4/60amOLDZs7jqKfTrFlKt5+UHYTU0ED9pRmh73vz7" >\
"$(pwd)/keys/29026b52f8ff825c" && cp -f "$(pwd)/keys/29026b52f8ff825c" "$(pwd)/files/etc/opkg/keys/"
sed -i '1a src/gz 3wlh https://packages.11121314.xyz/packages/aarch64_generic' "repositories.conf"

echo "=========================== 查看下载插件 ==========================="

ls $(pwd)/packages/diy_packages

echo "============================= 检查缓存 ============================="
if [[ $(find "$(pwd)/dl" -type f 2>/dev/null | wc -l) -gt 0 ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - 正在检查缓存插件："
    wget -qO- ${Script_url}/Packages_Check.sh | bash
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - 没有缓存插件."
fi
echo "============================= 镜像信息 ============================="
echo "路由器型号: $PROFILE"
echo "固件大小: $ROOTFS_PARTSIZE"

#========== 创建自定义配置文件 ==========# 
mkdir -p "$(pwd)/files/etc/config"
cat << EOF > "$(pwd)/files/etc/config/diy-settings"
settings_model=${Model}
settings_lan=${NETWORK_LAN}
enable_pppoe=${ENABLE_PPPOE}
pppoe_account=${PPPOE_ACCOUNT}
pppoe_password=${PPPOE_PASSWORD}
EOF
echo "========================= 查看自定义配置 ========================="
cat "$(pwd)/files/etc/config/diy-settings"
echo "================================================================="

#=============== 开始构建镜像 ===============#
echo "$(date '+%Y-%m-%d %H:%M:%S') - 开始构建镜像..."
echo "$(date '+%Y-%m-%d %H:%M:%S') - 系统Version: ${VERSION} ..."
#========== 定义所需安装的包列表 ==========#
PACKAGES=""
#========== 删除插件包 ==========#
PACKAGES="$PACKAGES -luci-app-cpufreq"
if [[ "${BRANCH}" == "openwrt" ]]; then
PACKAGES="$PACKAGES -dnsmasq"
fi
#========== 添加内核驱动 ==========#
if [[ "${BRANCH}" == "immortalwrt" ]]; then
echo "$(date '+%Y-%m-%d %H:%M:%S') - 添加${BRANCH}内核模块..."
if [[ "${PROFILE}" == "generic" ]]; then
PACKAGES="$PACKAGES kmod-drm-gem-shmem-helper kmod-drm-dma-helper"
else
PACKAGES="$PACKAGES kmod-drm-gem-shmem-helper kmod-drm-panfrost kmod-drm-rockchip" #kmod-drm-lima:kmod-drm-panfrost kmod-drm-rockchip:kmod-drm-dma-helper
fi
PACKAGES="$PACKAGES  kmod-nft-fullcone"
else
echo "$(date '+%Y-%m-%d %H:%M:%S') - 添加${BRANCH}内核模块..."
PACKAGES="$PACKAGES kmod-drm-dma-helper"
PACKAGES="$PACKAGES luci-lib-ipkg"
fi
if [[ "$(echo ${VERSION} |  cut -d '.' -f 1 )" -ge "24" ]]; then
PACKAGES="$PACKAGES luci-i18n-package-manager-zh-cn"
else
PACKAGES="$PACKAGES luci-i18n-opkg-zh-cn"
fi
PACKAGES="$PACKAGES luci-i18n-ramfree-zh-cn"
#========== 添加插件包 ==========#
PACKAGES="$PACKAGES $PACKAGE"
PACKAGES="$PACKAGES $DIY_PACKAGES"
# 添加Docker插件
if $INCLUDE_DOCKER; then
echo "$(date '+%Y-%m-%d %H:%M:%S') - 添加docker插件..." 
PACKAGES="$PACKAGES docker dockerd docker-compose luci-i18n-dockerman-zh-cn"
fi

#=============== 开始打包镜像 ===============#
echo "============================= 默认插件 ============================="
echo "$(date '+%Y-%m-%d %H:%M:%S') - 默认插件包："
echo "$(make info | grep "Default Packages:" | sed 's/Default Packages: //')"
echo "=========================== 编译添加插件 ==========================="
echo "$(date '+%Y-%m-%d %H:%M:%S') - 编译添加插件："
echo "$PACKAGES"
echo "============================ 编辑Config ============================"
Replace "CONFIG_TARGET_KERNEL_PARTSIZE" "32"
Replace "CONFIG_TARGET_ROOTFS_PARTSIZE" "${ROOTFS_PARTSIZE}"
Replace "CONFIG_TARGET_ROOTFS_EXT4FS"
Replace "CONFIG_TARGET_EXT4_JOURNAL"
cp -f "$(pwd)/.config" "$(pwd)/bin/buildinfo.config"
#========== kmods版本 ==========#
echo "========== kmods版本 =========="
wget -qO- ${Script_url}/Kmods.sh | bash
echo "============================= 打包镜像 ============================="
cp -f "$(pwd)/repositories.conf" "$(pwd)/bin/repositories.conf"
make image PROFILE=$PROFILE PACKAGES="$PACKAGES" FILES="$(pwd)/files" ROOTFS_PARTSIZE=$ROOTFS_PARTSIZE
echo "============================= 构建结果 ============================="
if [ $? -ne 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - 打包镜像失败!"
    echo "building=failure" >> "$(pwd)/bin/.bashrc"
fi
echo "$(date '+%Y-%m-%d %H:%M:%S') - 查看文件."
find "$(pwd)/bin/targets/" -type f
if [[ -n "$(find "$(pwd)/bin/targets/" -type f -name "*.img.gz")" ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - 打包镜像完成."
    echo "building=success" >> "$(pwd)/bin/.bashrc"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - 打包镜像文件失败!"
    echo "building=failure" >> "$(pwd)/bin/.bashrc"
fi 