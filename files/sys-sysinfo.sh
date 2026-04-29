#!/bin/sh

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export LANG=zh_CN.UTF-8

THIS_SCRIPT="sysinfo"
MOTD_DISABLE=""

SHOW_IP_PATTERN="^[ewr].*|^br.*|^lt.*|^umts.*"

DATA_STORAGE=/userdisk/data
MEDIA_STORAGE=/userdisk/snail

# don't edit below here
display()
{
    # $1=name $2=value $3=red_limit $4=minimal_show_limit $5=unit $6=after
    if [ "$1" = "Battery" ]; then
        great="<"
    else
        great=">"
    fi
    if [ -n "$2" ] && [ "$2" -gt 0 ] 2>/dev/null && [ "${2%.*}" -ge "$4" ] 2>/dev/null; then
        printf "%-14s%s" "$1:"
        if awk "BEGIN{exit ! ($2 $great $3)}" 2>/dev/null; then
            printf "\033[0;91m %s" "$2"
        else
            printf "\033[0;92m %s" "$2"
        fi
        printf "%-1s%s\033[0m" "$5"
        printf "%-11s%s\t" "$6"
        return 0
    fi
    return 1
}

get_ip_addresses()
{
    ip_list=""
    for f in /sys/class/net/*; do
        intf=$(basename "$f")
        case $intf in
            [ewr]*|br*|lt*|umts*)
                tmp=$(ip -4 addr show dev "$intf" 2>/dev/null | awk '/inet/ {print $2}' | cut -d'/' -f1)
                if [ -n "$tmp" ]; then
                    ip_list="$ip_list $tmp"
                fi
                ;;
        esac
    done
    echo "${ip_list# }"
}

storage_info()
{
    RootInfo=$(df -h / 2>/dev/null)
    if [ -n "$RootInfo" ]; then
        root_usage=$(echo "$RootInfo" | awk '/\// {print $(NF-1)}' | sed 's/%//g')
        root_total=$(echo "$RootInfo" | awk '/\// {print $(NF-4)}')
    else
        root_usage="0"
        root_total="0"
    fi
}

storage_info
critical_load=$(( 1 + $(grep -c processor /proc/cpuinfo 2>/dev/null) / 2 ))

UptimeString=$(uptime 2>/dev/null | tr -d ',')
time=$(echo "$UptimeString" | awk -F" " '{print $3" "$4}')
load=$(echo "$UptimeString" | awk -F"average: " '{print $2}')
case $time in
    1:*)
        time=$(echo "$UptimeString" | awk -F" " '{print $3" 小时"}')
        ;;
    *:*)
        time=$(echo "$UptimeString" | awk -F" " '{print $3" 小时"}')
        ;;
    *day)
        days=$(echo "$UptimeString" | awk -F" " '{print $3"天"}')
        time=$(echo "$UptimeString" | awk -F" " '{print $5}')
        time="$days $(echo "$time" | awk -F":" '{print $1"小时 "$2"分钟"}')"
        ;;
esac

mem_info=$(LC_ALL=C free -w 2>/dev/null | grep "^Mem" || LC_ALL=C free | grep "^Mem")
if [ -n "$mem_info" ]; then
    memory_usage=$(echo "$mem_info" | awk '{printf("%.0f",(($2-($4+$6))/$2) * 100)}')
    memory_total=$(echo "$mem_info" | awk '{printf("%d",$2/1024)}')
else
    memory_usage="0"
    memory_total="0"
fi

swap_info=$(LC_ALL=C free -m 2>/dev/null | grep "^Swap")
if [ -n "$swap_info" ]; then
    swap_usage=$(echo "$swap_info" | awk '{printf("%3.0f", $3/$2*100)}' 2>/dev/null | tr -c -d '[:digit:]')
    swap_total=$(echo "$swap_info" | awk '{print $(2)}')
else
    swap_usage="0"
    swap_total="0"
fi

c=0
while [ -z "$(get_ip_addresses)" ]; do
    [ $c -eq 3 ] && break || c=$((c+1))
    sleep 1
done
ip_address="$(get_ip_addresses)"

load_1min=$(echo "$load" | awk '{print $1}')
load_rest=$(echo "$load" | awk '{$1=""; print $0}' | sed 's/^[ \t]*//')

if [ -n "$load_1min" ] && [ "$(echo "$load_1min > 0" | bc 2>/dev/null)" = "1" ]; then
    printf "%-14s" "系统负载:"
    if [ "$(echo "$load_1min > $critical_load" | bc 2>/dev/null)" = "1" ]; then
        printf "\033[0;91m %s\033[0m" "$load_1min"
    else
        printf "\033[0;92m %s\033[0m" "$load_1min"
    fi
    printf " %s\t" "$load_rest"
else
    printf "%-14s\033[0;92m %s\033[0m %s\t" "系统负载:" "$load_1min" "$load_rest"
fi
printf "运行时间:  \033[92m%s\033[0m\t" "$time"
echo ""

display "内存已用" "$memory_usage" "70" "0" " %" " of ${memory_total}MB"
printf "IP  地址:  \033[92m%s\033[0m" "$ip_address"
echo ""

display "系统存储" "$root_usage" "90" "1" "%" " of $root_total"
if [ -x /sbin/cpuinfo ]; then
    printf "CPU 信息: \033[92m%s\033[0m\t" "$( /sbin/cpuinfo 2>/dev/null | cut -d ' ' -f -4 )"
fi
echo ""
