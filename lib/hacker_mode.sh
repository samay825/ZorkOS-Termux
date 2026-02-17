#!/bin/bash

HACKER_CONF="${HOME}/.zorkos/hacker_mode.conf"
HACKER_BACKUP="${HOME}/.zorkos/cache/.hacker_backup"
TERMUX_DIR_HACK="${HOME}/.termux"

hacker_mode_init() {
    if [[ ! -f "$HACKER_CONF" ]]; then
        echo "HACKER_MODE=false" > "$HACKER_CONF"
    fi
    source "$HACKER_CONF" 2>/dev/null
}

_hacker_colors() {
    cat << 'HACKERCOLORS'

background=#000000
foreground=#00FF41
cursor=#00FF41

color0=#000000
color8=#003B00

color1=#008F11
color9=#00FF41

color2=#00FF41
color10=#00FF41

color3=#00CC33
color11=#33FF33

color4=#007700
color12=#00AA00

color5=#00BB22
color13=#00DD33

color6=#00FF41
color14=#33FF99

color7=#00FF41
color15=#00FF41
HACKERCOLORS
}

hacker_mode_on() {
    hacker_mode_init
    mkdir -p "$TERMUX_DIR_HACK"
    mkdir -p "$(dirname "$HACKER_BACKUP")"
    
    if [[ -f "${TERMUX_DIR_HACK}/colors.properties" ]]; then
        cp "${TERMUX_DIR_HACK}/colors.properties" "${HACKER_BACKUP}.colors"
    fi
    
    _hacker_colors > "${TERMUX_DIR_HACK}/colors.properties"
    
    echo "HACKER_MODE=true" > "$HACKER_CONF"
    
    termux-reload-settings 2>/dev/null
    
    local RST="\033[0m"
    clear
    
    local cols rows
    cols=$(tput cols 2>/dev/null || echo 80)
    rows=$(tput lines 2>/dev/null || echo 24)
    
    tput civis 2>/dev/null
    
    local i r c chars
    for ((i=0; i<30; i++)); do
        r=$(( RANDOM % rows + 1 ))
        c=$(( RANDOM % cols + 1 ))
        chars="01"
        printf "\033[%d;%dH\033[38;2;0;%d;0m%s" "$r" "$c" $(( 100 + RANDOM % 155 )) "${chars:$(( RANDOM % 2 )):1}"
        sleep 0.01
    done
    
    sleep 0.3
    clear
    
    tput cnorm 2>/dev/null
    
    echo ""
    local _uname
    _uname=$(grep "^USERNAME=" "$HOME/.zorkos/user.conf" 2>/dev/null | cut -d= -f2)
    [[ -z "$_uname" ]] && _uname="User"
    local _cmd
    _cmd=$(grep "^CMD_NAME=" "$HOME/.zorkos/user.conf" 2>/dev/null | cut -d= -f2)
    [[ -z "$_cmd" ]] && _cmd="zork"
    echo ""
    echo -e "\033[38;2;0;255;65m  ╭─── HACKER MODE ─────────────────────${RST}"
    echo -e "\033[38;2;0;255;65m  │${RST}"
    echo -e "\033[38;2;0;255;65m  │  \033[1mSTATUS: ACTIVATED${RST}"
    echo -e "\033[38;2;0;255;65m  │  All systems running green...${RST}"
    echo -e "\033[38;2;0;255;65m  │${RST}"
    echo -e "\033[38;2;0;255;65m  ╰───────────────────────────────────────${RST}"
    echo ""
    echo -e "\033[38;2;0;180;30m  > Matrix color scheme applied${RST}"
    echo -e "\033[38;2;0;180;30m  > Terminal aesthetics: ENGAGED${RST}"
    echo -e "\033[38;2;0;180;30m  > Use '${_cmd} hack off' to deactivate${RST}"
    echo ""
}

hacker_mode_off() {
    hacker_mode_init
    
    if [[ -f "${HACKER_BACKUP}.colors" ]]; then
        cp "${HACKER_BACKUP}.colors" "${TERMUX_DIR_HACK}/colors.properties"
        rm -f "${HACKER_BACKUP}.colors"
    fi
    
    echo "HACKER_MODE=false" > "$HACKER_CONF"
    
    termux-reload-settings 2>/dev/null
    
    echo -e "  \033[38;2;0;255;136m✓ Hacker mode deactivated${RST}"
    echo -e "  \033[38;2;0;200;255m  Original colors restored${RST}"
}

hacker_mode_toggle() {
    hacker_mode_init
    
    if [[ "$HACKER_MODE" == "true" ]]; then
        hacker_mode_off
    else
        hacker_mode_on
    fi
}

hacker_mode_status() {
    hacker_mode_init
    if [[ "$HACKER_MODE" == "true" ]]; then
        echo -e "  \033[38;2;0;255;65m  HACKER MODE: ACTIVE\033[0m"
    else
        echo -e "  \033[38;2;100;100;120m  Hacker Mode: Inactive\033[0m"
    fi
}

hacker_mode_intensity() {
    local intensity="${1:-255}"  # 0-255
    
    [[ $intensity -lt 50 ]] && intensity=50
    [[ $intensity -gt 255 ]] && intensity=255
    
    local hex
    hex=$(printf "%02x" "$intensity")
    
    cat > "${TERMUX_DIR_HACK}/colors.properties" << EOF
background=#000000
foreground=#00${hex}41
cursor=#00${hex}41
color0=#000000
color7=#00${hex}41
color2=#00${hex}41
color15=#00${hex}41
EOF
    
    termux-reload-settings 2>/dev/null
    echo -e "  \033[38;2;0;${intensity};65m  Hacker Mode: intensity=${intensity}\033[0m"
}

hacker_mode_init
