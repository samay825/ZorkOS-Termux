#!/bin/bash

SCRIPT_DIR_DASH="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}" 2>/dev/null)" && pwd 2>/dev/null || echo "$HOME/.zorkos/lib")"

source "${SCRIPT_DIR_DASH}/responsive.sh" 2>/dev/null || source "$HOME/.zorkos/lib/responsive.sh" 2>/dev/null

_dash_bar() {
    local pct=$1
    local width=${2:-20}
    
    [[ $pct -gt 100 ]] && pct=100
    [[ $pct -lt 0 ]] && pct=0
    
    local filled=$(( pct * width / 100 ))
    
    local i ratio cr cg cb
    for ((i=0; i<filled; i++)); do
        ratio=$(( i * 100 / (width > 0 ? width : 1) ))
        if [[ $ratio -lt 50 ]]; then
            cr=$(( ratio * 255 / 50 ))
            cg=255
            cb=50
        else
            cr=255
            cg=$(( 255 - (ratio - 50) * 255 / 50 ))
            cb=50
        fi
        printf '\033[38;2;%d;%d;%dm█' "$cr" "$cg" "$cb"
    done
    for ((i=filled; i<width; i++)); do
        printf '\033[38;2;40;40;50m░'
    done
    printf '\033[0m'
}

_get_battery() {
    if ! command -v termux-battery-status &>/dev/null; then
        echo "?|?|?"
        return
    fi
    local battery_json
    battery_json=$(timeout 3 termux-battery-status 2>/dev/null || true)
    
    if [[ -n "$battery_json" ]]; then
        local percentage
        percentage=$(echo "$battery_json" | grep -o '"percentage":[0-9]*' | grep -o '[0-9]*' 2>/dev/null || echo "?")
        local bat_status
        bat_status=$(echo "$battery_json" | grep -o '"status":"[^"]*"' | cut -d'"' -f4 2>/dev/null || echo "?")
        local temp
        temp=$(echo "$battery_json" | grep -o '"temperature":[0-9.]*' | grep -o '[0-9.]*' 2>/dev/null || echo "?")
        
        echo "${percentage:-?}|${bat_status:-?}|${temp:-?}"
    else
        echo "?|?|?"
    fi
}

_get_network() {
    local ip="N/A"
    if command -v ifconfig &>/dev/null; then
        ip=$(ifconfig 2>/dev/null | grep 'inet ' | grep -v '127.0.0.1' | head -1 | awk '{print $2}' | tr -d 'addr:' || echo "N/A")
    fi
    [[ -z "$ip" || "$ip" == "N/A" ]] && ip=$(ip route get 1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src") print $(i+1)}' || echo "N/A")
    [[ -z "$ip" ]] && ip="N/A"
    
    local wifi_name="?" wifi_rssi="?"
    if command -v termux-wifi-connectioninfo &>/dev/null; then
        local wifi_json
        wifi_json=$(timeout 3 termux-wifi-connectioninfo 2>/dev/null || true)
        if [[ -n "$wifi_json" ]]; then
            wifi_name=$(echo "$wifi_json" | grep -o '"ssid":"[^"]*"' | cut -d'"' -f4 2>/dev/null || echo "?")
            wifi_rssi=$(echo "$wifi_json" | grep -o '"rssi":-*[0-9]*' | grep -o '-*[0-9]*' 2>/dev/null || echo "?")
        fi
    fi
    
    echo "${ip}|${wifi_name:-?}|${wifi_rssi:-?}"
}

_get_cpu_usage() {
    [[ -n "$ZSH_VERSION" ]] && setopt localoptions KSH_ARRAYS 2>/dev/null
    local usage=0
    if [[ -f /proc/stat ]]; then
        local cpu1 cpu2
        cpu1=$(head -1 /proc/stat)
        sleep 0.2
        cpu2=$(head -1 /proc/stat)
        
        local -a f1=($cpu1)
        local -a f2=($cpu2)
        
        local idle1=${f1[4]:-0} total1=0
        local idle2=${f2[4]:-0} total2=0
        local i
        for ((i=1; i<${#f1[@]}; i++)); do total1=$(( total1 + ${f1[$i]:-0} )); done
        for ((i=1; i<${#f2[@]}; i++)); do total2=$(( total2 + ${f2[$i]:-0} )); done
        
        local diff_idle=$(( idle2 - idle1 ))
        local diff_total=$(( total2 - total1 ))
        
        if [[ $diff_total -gt 0 ]]; then
            usage=$(( 100 * (diff_total - diff_idle) / diff_total ))
        fi
    fi
    [[ $usage -lt 0 ]] && usage=0
    [[ $usage -gt 100 ]] && usage=100
    echo "$usage"
}

system_dashboard() {
    local RST="\033[0m"
    local cols
    cols=$(tput cols 2>/dev/null || echo 80)
    local bar_width=20
    [[ $cols -lt 50 ]] && bar_width=12
    
    clear
    echo ""
    
    if [[ $cols -ge 50 ]]; then
        echo ""
        echo -e "  \033[1;38;2;0;255;136m  ╭─── 📊 SYSTEM DASHBOARD ─────────────────────${RST}"
        echo -e "  \033[1;38;2;0;255;136m  │\033[38;2;0;200;255m  ZorkOS Runtime Monitor${RST}"
        echo -e "  \033[1;38;2;0;255;136m  ╰──────────────────────────────────────────────${RST}"
    else
        echo -e "  \033[1;38;2;0;255;136m 📊 SYSTEM DASHBOARD${RST}"
    fi
    echo ""
    
    local cpu_usage
    cpu_usage=$(_get_cpu_usage)
    local cpu_cores
    cpu_cores=$(nproc 2>/dev/null || echo "?")
    echo -ne "  \033[38;2;100;100;120m  CPU  ${cpu_cores} cores  \033[38;2;0;200;255m${cpu_usage}%%  "
    _dash_bar "$cpu_usage" "$bar_width"
    echo -e "${RST}"
    
    local mem_total mem_used mem_pct
    mem_total=$(free -m 2>/dev/null | awk '/Mem:/{print $2}' || echo "0")
    mem_used=$(free -m 2>/dev/null | awk '/Mem:/{print $3}' || echo "0")
    [[ $mem_total -gt 0 ]] && mem_pct=$(( mem_used * 100 / mem_total )) || mem_pct=0
    echo -ne "  \033[38;2;100;100;120m  MEM  ${mem_used}/${mem_total}MB  \033[38;2;200;100;255m${mem_pct}%%  "
    _dash_bar "$mem_pct" "$bar_width"
    echo -e "${RST}"
    
    local disk_total disk_used disk_pct
    disk_used=$(df -h / 2>/dev/null | awk 'NR==2{print $3}' || echo "?")
    disk_total=$(df -h / 2>/dev/null | awk 'NR==2{print $2}' || echo "?")
    disk_pct=$(df / 2>/dev/null | awk 'NR==2{print $5}' | tr -d '%' || echo "0")
    echo -ne "  \033[38;2;100;100;120m  DISK ${disk_used}/${disk_total}  \033[38;2;255;0;200m${disk_pct}%%  "
    _dash_bar "$disk_pct" "$bar_width"
    echo -e "${RST}"
    
    local battery_info
    battery_info=$(_get_battery)
    local bat_pct bat_status bat_temp
    bat_pct="${battery_info%%|*}"; battery_info="${battery_info#*|}"
    bat_status="${battery_info%%|*}"
    bat_temp="${battery_info##*|}"
    
    if [[ "$bat_pct" != "?" ]]; then
        local bat_icon="🔋"
        [[ "$bat_status" == "CHARGING" ]] && bat_icon="⚡"
        [[ "${bat_pct}" -le 20 ]] && bat_icon="🪫"
        
        echo -ne "  \033[38;2;100;100;120m  ${bat_icon}   ${bat_pct}%%  ${bat_status}  "
        _dash_bar "${bat_pct}" "$bar_width"
        echo -e "  \033[38;2;100;100;120m${bat_temp}°C${RST}"
    fi
    
    echo ""
    echo -e "  \033[38;2;0;200;255m  Network${RST}"
    echo -e "  \033[38;2;60;60;80m  ─────────────────────${RST}"
    
    local net_info
    net_info=$(_get_network)
    local net_ip wifi_name wifi_rssi
    net_ip="${net_info%%|*}"; net_info="${net_info#*|}"
    wifi_name="${net_info%%|*}"
    wifi_rssi="${net_info##*|}"
    
    echo -e "  \033[38;2;100;100;120m  󰩟 IP       \033[38;2;0;255;200m${net_ip}${RST}"
    [[ "$wifi_name" != "?" ]] && echo -e "  \033[38;2;100;100;120m  󰖩 WiFi     \033[38;2;0;200;255m${wifi_name} (${wifi_rssi}dBm)${RST}"
    
    echo ""
    echo -e "  \033[38;2;255;165;0m  System${RST}"
    echo -e "  \033[38;2;60;60;80m  ─────────────────────${RST}"
    
    echo -e "  \033[38;2;100;100;120m   OS       \033[38;2;0;255;136m$(uname -o 2>/dev/null || echo 'Android')${RST}"
    echo -e "  \033[38;2;100;100;120m   Kernel   \033[38;2;0;255;136m$(uname -r 2>/dev/null | cut -d'-' -f1)${RST}"
    echo -e "  \033[38;2;100;100;120m   Shell    \033[38;2;0;200;255m$(basename "$SHELL" 2>/dev/null)${RST}"
    echo -e "  \033[38;2;100;100;120m   Uptime   \033[38;2;255;220;0m$(uptime -p 2>/dev/null | sed 's/up //' || echo 'N/A')${RST}"
    echo -e "  \033[38;2;100;100;120m  󰏗 Packages \033[38;2;80;180;255m$(dpkg --list 2>/dev/null | wc -l || echo '?')${RST}"
    echo -e "  \033[38;2;100;100;120m   Procs    \033[38;2;200;100;255m$(ps aux 2>/dev/null | wc -l || echo '?')${RST}"
    
    echo ""
    
    if [[ -f "${HOME}/.zorkos/zorkos.conf" ]]; then
        source "${HOME}/.zorkos/zorkos.conf" 2>/dev/null
        echo -e "  \033[38;2;0;255;136m  ZorkOS${RST}"
        echo -e "  \033[38;2;60;60;80m  ─────────────────────${RST}"
        [[ -n "$CURRENT_THEME" ]] && echo -e "  \033[38;2;100;100;120m  🎨 Theme   \033[38;2;0;200;255m${CURRENT_THEME}${RST}"
        [[ -n "$BOOT_ANIMATION" ]] && echo -e "  \033[38;2;100;100;120m  ✨ Boot    \033[38;2;200;100;255m${BOOT_ANIMATION}${RST}"
    fi
    
    if [[ -f "${HOME}/.zorkos/achievements/stats.db" ]]; then
        source "${HOME}/.zorkos/achievements/stats.db" 2>/dev/null
        source "${HOME}/.zorkos/lib/achievements.sh" 2>/dev/null
        echo -e "  \033[38;2;100;100;120m  🏆 Level   $(get_xp_progress 2>/dev/null)${RST}"
        echo -e "  \033[38;2;100;100;120m  🔥 Streak  \033[38;2;255;165;0m${CURRENT_STREAK:-0} days${RST}"
    fi
    
    echo ""
    local _dname
    _dname=$(grep "^USERNAME=" "$HOME/.zorkos/user.conf" 2>/dev/null | cut -d= -f2)
    [[ -z "$_dname" ]] && _dname="Zork"
    echo -e "  \033[38;2;60;60;80m  Updated: $(date '+%H:%M:%S')  │  ${_dname}'s Terminal${RST}"
    echo ""
}

system_dashboard_live() {
    while true; do
        system_dashboard
        echo -e "  \033[38;2;60;60;80m  Press 'q' to exit, refreshing in 5s...${RST}"
        read -t 5 -n 1 key 2>/dev/null && [[ "$key" == "q" ]] && break
    done
    clear
}

dashboard_compact() {
    local RST="\033[0m"
    
    local mem_pct cpu_usage disk_pct
    local mem_total mem_used
    mem_total=$(free -m 2>/dev/null | awk '/Mem:/{print $2}' || echo "0")
    mem_used=$(free -m 2>/dev/null | awk '/Mem:/{print $3}' || echo "0")
    [[ $mem_total -gt 0 ]] && mem_pct=$(( mem_used * 100 / mem_total )) || mem_pct=0
    cpu_usage=$(_get_cpu_usage 2>/dev/null)
    disk_pct=$(df / 2>/dev/null | awk 'NR==2{print $5}' | tr -d '%' || echo "0")
    
    local bar_width=10
    
    echo -ne "  \033[38;2;100;100;120mCPU "
    _dash_bar "${cpu_usage:-0}" $bar_width
    echo -ne " \033[38;2;100;100;120mMEM "
    _dash_bar "$mem_pct" $bar_width
    echo -ne " \033[38;2;100;100;120mDSK "
    _dash_bar "$disk_pct" $bar_width
    echo -e "${RST}"
}
