#!/bin/bash

get_screen_size() {
    COLS=$(tput cols 2>/dev/null || echo 80)
    ROWS=$(tput lines 2>/dev/null || echo 24)
}

get_size_class() {
    get_screen_size
    if [[ $COLS -lt 45 ]]; then
        echo "small"
    elif [[ $COLS -lt 65 ]]; then
        echo "medium"
    else
        echo "large"
    fi
}

get_responsive_banner() {
    local size_class
    size_class=$(get_size_class)
    
    case "$size_class" in
        small)
            RESPONSIVE_BANNER=(
                " ▄▄▄ ZORK OS ▄▄▄"
                " ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀"
            )
            ;;
        medium)
            RESPONSIVE_BANNER=(
                " ▀▀▀▀▀ ▀▀▀▀▀ ▀▀▀▀ ▀  ▀  ▀▀▀▀ ▀▀▀▀"
                "   ▄▀  █   █ █▀▀▄ █▄▀   █  █ ▀▀▀█"
                "  ▄▀   █   █ █▀▀▄ █ █   █  █    █"
                " ▄▄▄▄▄ ▄▄▄▄▄ ▄  ▄ ▄  ▄  ▄▄▄▄ ▄▄▄▄"
            )
            ;;
        large)
            RESPONSIVE_BANNER=(
                "  ███████╗ ██████╗ ██████╗ ██╗  ██╗   ██████╗ ███████╗"
                "  ╚══███╔╝██╔═══██╗██╔══██╗██║ ██╔╝  ██╔═══██╗██╔════╝"
                "    ███╔╝ ██║   ██║██████╔╝█████╔╝   ██║   ██║███████╗"
                "   ███╔╝  ██║   ██║██╔══██╗██╔═██╗   ██║   ██║╚════██║"
                "  ███████╗╚██████╔╝██║  ██║██║  ╚██╗ ╚██████╔╝███████║"
                "  ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝   ╚═╝  ╚═════╝╚══════╝"
            )
            ;;
    esac
}

get_responsive_bye_banner() {
    local size_class
    size_class=$(get_size_class)
    
    case "$size_class" in
        small)
            RESPONSIVE_BYE_BANNER=(
                " ▄▄▄ ZORK OS ▄▄▄"
                "      Bye!"
            )
            ;;
        medium)
            RESPONSIVE_BYE_BANNER=(
                " ▀▀▀▀▀ ▀▀▀▀▀ ▀▀▀▀ ▀  ▀"
                "   ▄▀  █   █ █▀▀▄ █▄▀ "
                "  ▄▀   █   █ █▀▀▄ █ █ "
                " ▄▄▄▄▄ ▄▄▄▄▄ ▄  ▄ ▄  ▄"
            )
            ;;
        large)
            RESPONSIVE_BYE_BANNER=(
                "  ███████╗ ██████╗ ██████╗ ██╗  ██╗"
                "  ╚══███╔╝██╔═══██╗██╔══██╗██║ ██╔╝"
                "    ███╔╝ ██║   ██║██████╔╝█████╔╝ "
                "   ███╔╝  ██║   ██║██╔══██╗██╔═██╗ "
                "  ███████╗╚██████╔╝██║  ██║██║  ╚██╗"
                "  ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝   ╚═╝"
            )
            ;;
    esac
}

get_responsive_boot_logo() {
    local size_class
    size_class=$(get_size_class)
    
    local _bname
    _bname=$(grep "^CMD_NAME=" "$HOME/.zorkos/user.conf" 2>/dev/null | cut -d= -f2)
    [[ -z "$_bname" ]] && _bname="ZORK"
    _bname=$(echo "$_bname" | tr '[:lower:]' '[:upper:]')
    
    case "$size_class" in
        small)
            RESPONSIVE_BOOT_LOGO=(
                "⚡ ${_bname} OS ⚡"
                " v2.0 • 2026"
            )
            ;;
        medium|large)
            RESPONSIVE_BOOT_LOGO=(
                "⚡ ${_bname} OS ⚡"
                " v2.0 • 2026"
            )
            ;;
    esac
}

get_responsive_tagline() {
    local size_class _uname
    size_class=$(get_size_class)
    _uname=$(grep "^USERNAME=" "$HOME/.zorkos/user.conf" 2>/dev/null | cut -d= -f2)
    [[ -z "$_uname" ]] && _uname="Zork"
    
    case "$size_class" in
        small)
            echo "⚡ ${_uname}'s Terminal ⚡"
            ;;
        medium)
            echo "⚡ ${_uname}'s Terminal — Beyond All Limits ⚡"
            ;;
        large)
            echo "⚡ ${_uname}'s Terminal — Beyond All Limits — 2026 ⚡"
            ;;
    esac
}

get_responsive_subtitle() {
    local size_class
    size_class=$(get_size_class)
    
    local -a subs_small=(
        "[ SHELL MASTER 2026 ]"
        "[ TERMINAL EXPERT ]"
        "[ HACK THE PLANET ]"
        "[ BEYOND LIMITS ]"
        "[ ELITE SHELL ]"
        "[ NEXT GEN TERM ]"
    )
    local -a subs_med=(
        "[ TERMINAL EXPERT — 2026 EDITION ]"
        "[ BEYOND ALL LIMITS — ELITE SHELL ]"
        "[ HACK THE PLANET — SHELL MASTER ]"
        "[ YOUR TERMINAL, YOUR RULES ]"
        "[ NEXT LEVEL ENGINEERING ]"
        "[ UNLIMITED POWER — 2026 ]"
    )
    local -a subs_large=(
        "[  T E R M I N A L   E X P E R T  —  2 0 2 6  ]"
        "[  B E Y O N D   A L L   L I M I T S  ]"
        "[  H A C K   T H E   P L A N E T  ]"
        "[  Y O U R   T E R M I N A L ,   Y O U R   R U L E S  ]"
        "[  N E X T   L E V E L   E N G I N E E R I N G  ]"
    )
    
    local count_s=${#subs_small[@]}
    local count_m=${#subs_med[@]}
    local count_l=${#subs_large[@]}
    local rnd=$(( RANDOM ))
    local _off=0
    [[ -n "$ZSH_VERSION" ]] && _off=1
    case "$size_class" in
        small)
            local pick=$(( (rnd % count_s) + _off ))
            echo "${subs_small[$pick]}"
            ;;
        medium)
            local pick=$(( (rnd % count_m) + _off ))
            echo "${subs_med[$pick]}"
            ;;
        large)
            local pick=$(( (rnd % count_l) + _off ))
            echo "${subs_large[$pick]}"
            ;;
    esac
}

draw_responsive_box() {
    local title="$1"
    local content="$2"
    local color_r="${3:-0}"
    local color_g="${4:-255}"
    local color_b="${5:-136}"
    
    get_screen_size
    local box_width=$(( COLS - 4 ))
    [[ $box_width -lt 20 ]] && box_width=20
    [[ $box_width -gt 70 ]] && box_width=70
    
    local RST="\033[0m"
    local CLR="\033[38;2;${color_r};${color_g};${color_b}m"
    
    printf "${CLR}  ╭"
    printf '─%.0s' $(seq 1 $box_width)
    printf "${RST}\n"
    
    local title_len=${#title}
    local pad_left=$(( (box_width - title_len) / 2 ))
    printf "${CLR}  │"
    printf '%*s' $pad_left ''
    printf "%s" "$title"
    printf "${RST}\n"
    
    printf "${CLR}  ╰"
    printf '─%.0s' $(seq 1 $box_width)
    printf "${RST}\n"
}

draw_responsive_separator() {
    local char="${1:-─}"
    get_screen_size
    local width=$(( COLS - 2 ))
    [[ $width -lt 10 ]] && width=10
    
    printf " "
    local i r g b
    for ((i=0; i<width; i++)); do
        r=$(( 0 + i * 255 / width ))
        g=$(( 255 - i * 120 / width ))
        b=$(( 136 + i * 80 / width ))
        [[ $r -gt 255 ]] && r=255
        [[ $g -lt 80 ]] && g=80
        [[ $b -gt 255 ]] && b=255
        printf "\033[38;2;%d;%d;%dm%s" "$r" "$g" "$b" "$char"
    done
    printf "\033[0m\n"
}

responsive_info_row() {
    local icon="$1"
    local label="$2"
    local value="$3"
    local color_r="${4:-0}"
    local color_g="${5:-255}"
    local color_b="${6:-136}"
    
    local size_class
    size_class=$(get_size_class)
    local RST="\033[0m"
    
    case "$size_class" in
        small)
            printf "  \033[38;2;100;100;120m%s \033[38;2;%d;%d;%dm%s${RST}\n" "$icon" "$color_r" "$color_g" "$color_b" "$value"
            ;;
        medium)
            local short_label="${label:0:8}"
            printf "  \033[38;2;100;100;120m%s %-8s \033[38;2;%d;%d;%dm%s${RST}\n" "$icon" "$short_label" "$color_r" "$color_g" "$color_b" "$value"
            ;;
        large)
            printf "  \033[38;2;100;100;120m%s %-10s \033[38;2;%d;%d;%dm%s${RST}\n" "$icon" "$label" "$color_r" "$color_g" "$color_b" "$value"
            ;;
    esac
}

center_text() {
    local text="$1"
    get_screen_size
    local text_len=${#text}
    local pad=$(( (COLS - text_len) / 2 ))
    [[ $pad -lt 0 ]] && pad=0
    printf '%*s%s\n' $pad '' "$text"
}

fit_text() {
    local text="$1"
    local max_width="${2:-0}"
    get_screen_size
    [[ $max_width -eq 0 ]] && max_width=$(( COLS - 4 ))
    
    if [[ ${#text} -gt $max_width ]]; then
        echo "${text:0:$(( max_width - 3 ))}..."
    else
        echo "$text"
    fi
}
