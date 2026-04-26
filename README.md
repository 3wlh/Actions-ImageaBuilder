# Image Builder OpenWrt

## 项目结构

```
.
├── .github/
│   ├── script/                    # 构建脚本目录
│   │   ├── Diy_file_all.sh        # 下载通用配置文件
│   │   ├── Kmods.sh               # 内核模块处理
│   │   ├── Packages_Check.sh      # 检查缓存插件
│   │   ├── Packages_Default.sh    # 默认软件包配置
│   │   ├── Packages_Download.sh   # 下载自定义插件
│   │   └── Replace.sh             # 文件替换脚本
│   └── workflows/                 # GitHub Actions 工作流
│       ├── Build-Box-ImageBuilder.yml
│       ├── Build-ImageBuilder.yml # 主要构建工作流
│       └── Call_ImageBuilder.yml
├── diy_download/                  # 自定义插件下载链接
│   ├── aarch64.txt                # ARM64 架构插件链接
│   └── x86-64.txt                 # x86_64 架构插件链接
├── diy_env/                       # 设备环境配置
│   ├── default_packages.sh        # 默认软件包列表
│   ├── x86-64.env                 # x86_64 设备配置
│   ├── nanopi-r6s.env             # NanoPi R6S 配置
│   ├── orangepi-5plus.env         # OrangePi 5 Plus 配置
│   ├── armsr-5plus.env            # ARM 设备配置
│   └── wxy-oect.env               # 其他设备配置
├── diy_files/                     # 设备初始化脚本
│   ├── all/                       # 所有设备通用脚本
│   │   ├── 99-defaults.sh         # 首次启动默认配置
│   │   ├── 29_ports.js            # 端口状态显示
│   │   ├── sys-bash.sh            # Bash 配置
│   │   ├── sys-opkg.sh            # Opkg 配置
│   │   └── sys-sysinfo.sh         # 系统信息显示
│   ├── x86-64.sh                  # x86_64 设备初始化
│   ├── nanopi-r6s.sh              # NanoPi R6S 初始化
│   ├── orangepi-5plus.sh          # OrangePi 5 Plus 初始化
│   └── wxy-oect.sh                # 其他设备初始化
├── make/                          # 构建执行脚本
│   ├── x86-64/make.sh
│   ├── armv8/make.sh
│   └── armsr/make.sh
└── README.md
```

## 如何使用?
[ImmortalWrt Image Builder 使用说明](https://github.com/1715173329/blog/issues/8) <br><br>
[OpenWrt Image Builder 使用说明](https://openwrt.org/docs/guide-user/additional-software/imagebuilder) <br><br>
您可以在 [此处](https://hub.docker.com/r/immortalwrt/imagebuilder/tags) 获取所有可用的ImmortalWrt tags <br><br>
您可以在 [此处](https://hub.docker.com/r/openwrt/imagebuilder/tags) 获取所有可用的OpenWrt tags

## 配置说明

### diy_env 配置文件

设备环境配置文件用于定义设备型号和需要安装的软件包列表。

**文件示例 (`diy_env/*.env`)：**
```
Model="x86-64"                     # 设备模型名称
PROFILE="generic"                  # OpenWrt Profile 名称

# 自定义所需安装的包列表
DIY_PACKAGES=""
DIY_PACKAGES="$DIY_PACKAGES luci-app-scriptrun luci-app-mddns"
DIY_PACKAGES="$DIY_PACKAGES luci-i18n-argon-config-zh-cn"
DIY_PACKAGES="$DIY_PACKAGES luci-app-v2ray-server xray-core"
```

**配置项说明：**
| 参数 | 说明 |
|------|------|
| `Model` | 设备模型标识，用于构建时识别 |
| `PROFILE` | OpenWrt 设备 Profile，决定目标设备类型 |
| `DIY_PACKAGES` | 需要额外安装的软件包列表 |

**文件示例 (`diy_download/x86-64.txt`)：**
```
https://github.com/user/repo/releases/download/v1.0/luci-app-example_1.0_x86_64.ipk
https://github.com/user/repo/releases/download/v1.0/luci-i18n-example-zh-cn_1.0_x86_64.ipk
```

每行一个下载链接，构建时会自动下载并集成到固件中。

## 如何查询都有哪些插件?

**ImmortalWrt:**

<details>
<summary>aarch64</summary>
<a href="https://mirrors.sjtug.sjtu.edu.cn/immortalwrt/releases/24.10-SNAPSHOT/targets/layerscape/armv8_64b/kmods/" target="_blank">kmods</a><br>
<a href="https://mirrors.sjtug.sjtu.edu.cn/immortalwrt/releases/24.10-SNAPSHOT/packages/aarch64_generic/luci/" target="_blank">luci</a><br>
<a href="https://mirrors.sjtug.sjtu.edu.cn/immortalwrt/releases/24.10-SNAPSHOT/packages/aarch64_generic/base/" target="_blank">base</a><br>
<a href="https://mirrors.sjtug.sjtu.edu.cn/immortalwrt/releases/24.10-SNAPSHOT/packages/aarch64_generic/packages/" target="_blank">packages</a>
</details>

<details>
<summary>x86_64</summary>
<a href="https://mirrors.sjtug.sjtu.edu.cn/immortalwrt/releases/24.10-SNAPSHOT/targets/x86/64/kmods/" target="_blank">kmods</a><br>
<a href="https://mirrors.sjtug.sjtu.edu.cn/immortalwrt/releases/24.10-SNAPSHOT/packages/x86_64/luci/" target="_blank">luci</a><br>
<a href="https://mirrors.sjtug.sjtu.edu.cn/immortalwrt/releases/24.10-SNAPSHOT/packages/x86_64/base/" target="_blank">base</a><br>
<a href="https://mirrors.sjtug.sjtu.edu.cn/immortalwrt/releases/24.10-SNAPSHOT/packages/x86_64/packages/" target="_blank">packages</a>
</details>

**OpenWrt:**

<details>
<summary>aarch64</summary>
<a href="https://mirrors.sjtug.sjtu.edu.cn/openwrt/releases/24.10-SNAPSHOT/targets/layerscape/armv8_64b/kmods/" target="_blank">kmods</a><br>
<a href="https://mirrors.sjtug.sjtu.edu.cn/openwrt/releases/24.10-SNAPSHOT/packages/aarch64_generic/luci/" target="_blank">luci</a><br>
<a href="https://mirrors.sjtug.sjtu.edu.cn/openwrt/releases/24.10-SNAPSHOT/packages/aarch64_generic/base/" target="_blank">base</a><br>
<a href="https://mirrors.sjtug.sjtu.edu.cn/openwrt/releases/24.10-SNAPSHOT/packages/aarch64_generic/packages/" target="_blank">packages</a>
</details>

<details>
<summary>x86_64</summary>
<a href="https://mirrors.sjtug.sjtu.edu.cn/openwrt/releases/24.10-SNAPSHOT/targets/x86/64/kmods/" target="_blank">kmods</a><br>
<a href="https://mirrors.sjtug.sjtu.edu.cn/openwrt/releases/24.10-SNAPSHOT/packages/x86_64/luci/" target="_blank">luci</a><br>
<a href="https://mirrors.sjtug.sjtu.edu.cn/openwrt/releases/24.10-SNAPSHOT/packages/x86_64/base/" target="_blank">base</a><br>
<a href="https://mirrors.sjtug.sjtu.edu.cn/openwrt/releases/24.10-SNAPSHOT/packages/x86_64/packages/" target="_blank">packages</a>
</details>

# 鸣谢
- [openwrt](https://github.com/openwrt/openwrt)
- [immortalwrt](https://github.com/immortalwrt/immortalwrt)
- [amlogic-s9xxx-openwrt](https://github.com/ophub/amlogic-s9xxx-openwrt)