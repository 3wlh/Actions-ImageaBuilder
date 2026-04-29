#!/bin/bash
dir="$(pwd)/packages/diy_packages"
test -d ${dir} || mkdir -pm 755 ${dir}
regexper='^(https?)://[a-zA-Z0-9.-]+\.[a-zA-Z0-9]{1,}(:[0-9]{1,5})?(/[^/]*)*$'
function Diy_Download(){
	if [ -f "${dir}/$(basename ${1})" ]; then
		echo -e "$(date '+%Y-%m-%d %H:%M:%S')\e[1;32m - 【$(basename ${1})】文件已存在\e[0m"
		return 0
	fi
	http_code=$(curl -o /dev/null -s --head -w "%{http_code}" "${url}")
	if [ "${http_code}" -ge 400 ] || [ "${http_code}" = "000" ]; then
		echo "无法访问或链接失效，状态码: ${http_code}"
		return 1
	fi
	echo "$(date '+%Y-%m-%d %H:%M:%S') - 开始下载: ${1}"
    curl -# -L --fail "${1}" -o "${dir}/$(basename ${1})"
    if [ "$(du -b ${dir}/$(basename ${1}) 2>/dev/null | awk '{print $1}')" -le "512" ]; then
		echo -e "$(date '+%Y-%m-%d %H:%M:%S')\e[1;31m - 【$(basename ${1})】下载失败\e[0m"
		return 1
	fi
	echo -e "$(date '+%Y-%m-%d %H:%M:%S')\e[1;32m - 【$(basename ${1})】下载完成\e[0m"
}
Diy_Download "${1}"