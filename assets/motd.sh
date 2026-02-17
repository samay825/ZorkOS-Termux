#!/bin/bash
# mei chahtah ho app sab yeh source code se kuch sikho !


SCRIPT_DIR_MOTD="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}" 2>/dev/null)" && pwd 2>/dev/null || echo "$HOME/.zorkos/assets")"


source "${SCRIPT_DIR_MOTD}/../lib/gradient_engine.sh" 2>/dev/null || source "$HOME/.zorkos/lib/gradient_engine.sh" 2>/dev/null
source "${SCRIPT_DIR_MOTD}/../lib/responsive.sh" 2>/dev/null || source "$HOME/.zorkos/lib/responsive.sh" 2>/dev/null
source "${SCRIPT_DIR_MOTD}/../lib/weather.sh" 2>/dev/null || source "$HOME/.zorkos/lib/weather.sh" 2>/dev/null
source "${SCRIPT_DIR_MOTD}/../lib/dashboard.sh" 2>/dev/null || source "$HOME/.zorkos/lib/dashboard.sh" 2>/dev/null
source "${SCRIPT_DIR_MOTD}/../lib/banners.sh" 2>/dev/null || source "$HOME/.zorkos/lib/banners.sh" 2>/dev/null
source "${SCRIPT_DIR_MOTD}/../lib/achievements.sh" 2>/dev/null || source "$HOME/.zorkos/lib/achievements.sh" 2>/dev/null

zork_motd() {
    local cols rows
    cols=$(tput cols 2>/dev/null || echo 80)
    rows=$(tput lines 2>/dev/null || echo 24)
    local size_class
    size_class=$(get_size_class 2>/dev/null || echo "large")
    local RST="\033[0m"
    
    
    local os_info kernel shell_info uptime_info cpu_info mem_info disk_info
    local pkg_count ip_addr time_now date_now user_name
    os_info=$(uname -o 2>/dev/null || echo "Android")
    kernel=$(uname -r 2>/dev/null | cut -d'-' -f1)
    shell_info=$(basename "$SHELL" 2>/dev/null || echo "zsh")
    uptime_info=$(uptime -p 2>/dev/null | sed 's/up //' || echo "N/A")
    cpu_info=$(nproc 2>/dev/null || echo "?")
    mem_info=$(free -h 2>/dev/null | awk '/Mem:/{print $3 "/" $2}' || echo "N/A")
    disk_info=$(df -h / 2>/dev/null | awk 'NR==2{print $3 "/" $2}' || echo "N/A")
    pkg_count=$(dpkg --list 2>/dev/null | wc -l || echo "?")
    ip_addr=$(ifconfig 2>/dev/null | grep 'inet ' | grep -v '127.0.0.1' | head -1 | awk '{print $2}' || echo "N/A")
    [[ -z "$ip_addr" ]] && ip_addr=$(ip route get 1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src") print $(i+1)}' || echo "N/A")
    [[ -z "$ip_addr" ]] && ip_addr="N/A"
    time_now=$(date "+%H:%M:%S")
    date_now=$(date "+%A, %B %d %Y")
    user_name=$(grep "^USERNAME=" "$HOME/.zorkos/user.conf" 2>/dev/null | cut -d= -f2)
    [[ -z "$user_name" ]] && user_name=$(whoami 2>/dev/null || echo "user")
    
    echo ""
    
    
    local _motd_banner="${CURRENT_BANNER:-ascii-name}"
    if type render_banner_display &>/dev/null; then
        render_banner_display "$_motd_banner" "${BANNER_BORDER_ENABLED:-true}" "${BANNER_BORDER_STYLE:-cyber-box}" "true"
    elif type get_active_banner &>/dev/null; then
        local _bidx
        _bidx=$(_banner_name_to_index "$_motd_banner" 2>/dev/null || echo 0)
        _get_banner_gradient "$_bidx" 2>/dev/null
        get_active_banner "$_motd_banner"
        for line in "${ACTIVE_BANNER_LINES[@]}"; do
            if type gradient_text &>/dev/null && [[ ${#ACTIVE_BANNER_GRADIENT[@]} -gt 0 ]]; then
                gradient_text "$line" "${ACTIVE_BANNER_GRADIENT[@]}" 2>/dev/null
            else
                echo -e "\033[38;2;0;255;136m${line}${RST}"
            fi
            echo
        done
    else
        
        get_responsive_banner 2>/dev/null
        if [[ ${#RESPONSIVE_BANNER[@]} -gt 0 ]]; then
            for line in "${RESPONSIVE_BANNER[@]}"; do
                gradient_text "$line" "${GRADIENT_ZORK[@]}" 2>/dev/null
                echo
            done
        fi
    fi
    
    echo ""
    
    
    local tagline
    tagline=$(get_responsive_tagline 2>/dev/null || echo "⚡ ${user_name}'s Terminal ⚡")
    if type gradient_text &>/dev/null && [[ ${#GRADIENT_AURORA[@]} -gt 0 ]]; then
        gradient_text "  ${tagline}" "${GRADIENT_AURORA[@]}" 2>/dev/null
        echo
    else
        echo -e "\033[1;38;2;0;200;255m  ${tagline}${RST}"
    fi
    
    echo ""
    
    
    if type draw_responsive_separator &>/dev/null; then
        draw_responsive_separator "─"
    elif type gradient_line &>/dev/null; then
        gradient_line "─" "${GRADIENT_ZORK[@]}"
    else
        printf "\033[38;2;0;255;136m"
        printf '─%.0s' $(seq 1 "$cols")
        printf "${RST}\n"
    fi
    
    echo ""
    
    
    if type responsive_info_row &>/dev/null; then
        echo -e "  \033[38;2;0;200;255m  System${RST}"
        responsive_info_row "" "OS" "$os_info" 0 255 136
        responsive_info_row "" "Kernel" "$kernel" 0 255 136
        responsive_info_row "" "Shell" "$shell_info" 0 255 136
        responsive_info_row "" "Uptime" "$uptime_info" 255 220 0
        responsive_info_row "󰍛" "CPU" "${cpu_info} cores" 255 165 0
        responsive_info_row "" "Memory" "$mem_info" 200 100 255
        responsive_info_row "󰋊" "Disk" "$disk_info" 255 0 200
        responsive_info_row "󰏗" "Packages" "$pkg_count" 80 180 255
        if [[ "$size_class" != "small" ]]; then
            responsive_info_row "󰩟" "IP" "$ip_addr" 0 255 200
        fi
    else
        echo -e "  \033[38;2;100;100;120m   OS  \033[38;2;0;255;136m${os_info}${RST}"
        echo -e "  \033[38;2;100;100;120m   Mem \033[38;2;200;100;255m${mem_info}${RST}"
    fi
    
    echo ""
    
 
    if type dashboard_compact &>/dev/null; then
        dashboard_compact 2>/dev/null
        echo ""
    fi
    
    
    if type weather_motd_line &>/dev/null; then
        weather_motd_line 2>/dev/null
    fi
    
    
    echo -e "  \033[38;2;255;0;200m  Clock${RST}"
    responsive_info_row "" "Time" "$time_now" 0 255 136 2>/dev/null || \
        echo -e "  \033[38;2;100;100;120m   Time \033[1;38;2;0;255;136m${time_now}${RST}"
    if [[ "$size_class" != "small" ]]; then
        responsive_info_row "" "Date" "$date_now" 0 200 255 2>/dev/null || \
            echo -e "  \033[38;2;100;100;120m   Date \033[38;2;0;200;255m${date_now}${RST}"
    fi
    responsive_info_row "" "User" "$user_name" 255 165 0 2>/dev/null || \
        echo -e "  \033[38;2;100;100;120m   User \033[38;2;255;165;0m${user_name}${RST}"
    echo ""
    
   
    if [[ -f "${HOME}/.zorkos/achievements/stats.db" ]]; then
        source "${HOME}/.zorkos/achievements/stats.db" 2>/dev/null
        if [[ -n "$TOTAL_XP" ]] && [[ ${TOTAL_XP:-0} -gt 0 ]]; then
            if type get_xp_progress &>/dev/null; then
                echo -e "  $(get_xp_progress 2>/dev/null)"
            fi
            [[ ${CURRENT_STREAK:-0} -gt 0 ]] && echo -e "  \033[38;2;255;165;0m  🔥 Streak: ${CURRENT_STREAK} days${RST}"
            
            if grep -q "^ADMIN_MODE=true" "$HOME/.zorkos/user.conf" 2>/dev/null; then
                echo -e "  \033[38;2;255;215;0m  🔐 Admin Elite${RST}"
            fi
            echo ""
        fi
    fi
    
    
    if type draw_responsive_separator &>/dev/null; then
        draw_responsive_separator "─"
    elif type gradient_line &>/dev/null; then
        gradient_line "─" "${GRADIENT_ZORK[@]}"
    fi
    
    
    local _mcmd
    _mcmd=$(grep "^CMD_NAME=" "$HOME/.zorkos/user.conf" 2>/dev/null | cut -d= -f2)
    [[ -z "$_mcmd" ]] && _mcmd="zork"
    local -a tips=(
        "💡 Use '${_mcmd}' to open customizer"
        "💡 Ctrl+R for fuzzy search"
        "💡 'eza --icons' for files"
        "💡 '${_mcmd} theme' to switch themes"
        "💡 'note add <text>' for notes"
        "💡 'bm save' to bookmark dirs"
        "💡 '${_mcmd} pomo' for focus timer"
        "💡 '${_mcmd} dash' for dashboard"
        "💡 '${_mcmd} hack' for hacker mode"
        "💡 '${_mcmd} achievements' for XP"
        "⚡ Developed by Zork — ZorkOS 2026"
        "🚀 ZorkOS v2.0 — Beyond All"
    )
    
    local tip_count=${#tips[@]}
    local tip_idx=$(( (RANDOM % tip_count) + 1 ))
    local random_tip="${tips[$tip_idx]}"
    echo -e "\033[3;38;2;100;100;120m  ${random_tip}${RST}"
    echo ""
}


zork_motd
