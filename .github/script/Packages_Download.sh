#!/bin/bash
regexper='^(https?)://[a-zA-Z0-9.-]+\.[a-zA-Z0-9]{1,}(:[0-9]{1,5})?(/[^/]*)*$'
dir="${2}"
function download(){
    curl -# -L --fail "${1}" -o "${dir}/$(basename ${1})"
    if [[ "$(du -b $(pwd)/$(basename ${1}) 2>/dev/null | awk '{print $1}')" -le "512" ]]; then
		echo -e "$(date '+%Y-%m-%d %H:%M:%S')\e[1;31m - 【$(basename ${1})】下载失败\e[0m"
		exit
	fi
	echo -e "$(date '+%Y-%m-%d %H:%M:%S')\e[1;32m - 【$(basename ${1})】下载完成\e[0m"
}

function handle(){
	cat "${1}" 2>/dev/null | \
	while IFS= read -r LINE || [ -n "$LINE" ]; do
		[[ -z "${LINE// /}" ]] && continue
		LINE="${LINE%$'\r'}"
		if grep -qE "$regexper" <<< "${LINE}"; then
			echo "Downloading ${LINE}"
			[[ $(curl -o /dev/null -s --head -w "%{http_code}" "${LINE}") -ge 400 ]] && { echo "无法访问"; exit; }
			download "${LINE}"
		fi
	done
}

handle "${1}"
