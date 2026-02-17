#!/bin/bash

if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
elif [[ -n "${(%):-%x}" ]] 2>/dev/null; then
    SCRIPT_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd 2>/dev/null)" || SCRIPT_DIR="$HOME/.zorkos/lib"
else
    SCRIPT_DIR="$HOME/.zorkos/lib"
fi
[[ ! -d "$SCRIPT_DIR" ]] && SCRIPT_DIR="$HOME/.zorkos/lib"

if ! type gradient_text &>/dev/null; then
    source "${SCRIPT_DIR}/gradient_engine.sh" 2>/dev/null || source "$HOME/.zorkos/lib/gradient_engine.sh" 2>/dev/null
fi
if ! type get_size_class &>/dev/null; then
    source "${SCRIPT_DIR}/responsive.sh" 2>/dev/null || source "$HOME/.zorkos/lib/responsive.sh" 2>/dev/null
fi

SOUND_ENABLED=${SOUND_ENABLED:-false}
BOOT_SOUND_FILE=${BOOT_SOUND_FILE:-"sound.mp3"}
SOUND_DIR="${SCRIPT_DIR}/../bootsound"
BOOT_SOUND="${SOUND_DIR}/${BOOT_SOUND_FILE}"

_play_mp3() {
    local file="$1"
    [[ ! -f "$file" ]] && return
    (
        if command -v play &>/dev/null; then
            play "$file" </dev/null &>/dev/null &
        elif command -v mpv &>/dev/null; then
            mpv --no-video --really-quiet "$file" </dev/null &>/dev/null &
        elif command -v ffplay &>/dev/null; then
            ffplay -nodisp -autoexit -loglevel quiet "$file" </dev/null &>/dev/null &
        elif command -v termux-media-player &>/dev/null; then
            termux-media-player play "$file" </dev/null &>/dev/null &
        else
            termux-notification --sound --id zorkos_snd --title "ZorkOS" --content "Boot" </dev/null &>/dev/null &
        fi
    ) &>/dev/null
}

play_sound() {
    local sound_type="$1"
    [[ "$SOUND_ENABLED" != true ]] && return
    local _boot_snd="${SOUND_DIR}/${BOOT_SOUND_FILE:-sound.mp3}"
    case "$sound_type" in
        boot)
            _play_mp3 "$_boot_snd"
            ;;
        success)
            printf '\a'
            ;;
        error)
            printf '\a'; sleep 0.1; printf '\a'
            ;;
        click)
            printf '\a'
            ;;
        *)
            printf '\a'
            ;;
    esac
}

screen_wipe_down() {
    local rows
    rows=$(tput lines 2>/dev/null || echo 24)
    local cols
    cols=$(tput cols 2>/dev/null || echo 80)
    
    local i j g
    for ((i=1; i<=rows; i++)); do
        printf "\033[%d;1H" "$i"
        for ((j=0; j<cols; j++)); do
            g=$(( 50 + RANDOM % 80 ))
            printf "\033[48;2;0;%d;%dm " "$g" "$(( g / 2 ))"
        done
        sleep 0.02
    done
    sleep 0.1
    clear
    printf "\033[0m"
}

pixel_dissolve() {
    local rows cols
    rows=$(tput lines 2>/dev/null || echo 24)
    cols=$(tput cols 2>/dev/null || echo 80)
    local total=$(( rows * cols / 8 ))
    
    local i r c
    for ((i=0; i<total; i++)); do
        r=$(( RANDOM % rows + 1 ))
        c=$(( RANDOM % cols + 1 ))
        printf "\033[%d;%dH\033[48;2;0;0;0m " "$r" "$c"
    done
    sleep 0.2
    clear
    printf "\033[0m"
}

cyber_grid_boot() {
    local rows cols
    rows=$(tput lines 2>/dev/null || echo 24)
    cols=$(tput cols 2>/dev/null || echo 80)
    
    tput civis 2>/dev/null
    clear
    
    local i j r
    for ((i=1; i<=rows; i+=2)); do
        printf "\033[%d;1H" "$i"
        for ((j=0; j<cols; j++)); do
            if [[ $(( j % 4 )) -eq 0 ]]; then
                printf "\033[38;2;0;%d;%dm│" $(( 80 + RANDOM % 100 )) $(( 40 + RANDOM % 60 ))
            else
                printf "\033[38;2;0;40;20m·"
            fi
        done
        sleep 0.03
    done
    
    sleep 0.3
    
    for ((i=1; i<=cols; i+=1)); do
        for ((r=1; r<=rows; r++)); do
            printf "\033[%d;%dH\033[38;2;0;255;136m█" "$r" "$i"
        done
        sleep 0.005
        for ((r=1; r<=rows; r++)); do
            printf "\033[%d;%dH\033[38;2;0;40;20m " "$r" "$i"
        done
    done
    
    tput cnorm 2>/dev/null
    clear
}

hex_boot() {
    local rows cols
    rows=$(tput lines 2>/dev/null || echo 24)
    cols=$(tput cols 2>/dev/null || echo 80)
    local cx=$(( cols / 2 ))
    local cy=$(( rows / 2 ))
    
    tput civis 2>/dev/null
    clear
    
    local radius angle rad_x rad_y px py intensity
    for ((radius=0; radius<=rows; radius++)); do
        for angle in 0 60 120 180 240 300; do
            rad_x=$(( radius * 2 ))
            rad_y=$radius
            case $angle in
                0)   px=$(( cx + rad_x ));     py=$cy ;;
                60)  px=$(( cx + rad_x/2 ));   py=$(( cy - rad_y )) ;;
                120) px=$(( cx - rad_x/2 ));   py=$(( cy - rad_y )) ;;
                180) px=$(( cx - rad_x ));     py=$cy ;;
                240) px=$(( cx - rad_x/2 ));   py=$(( cy + rad_y )) ;;
                300) px=$(( cx + rad_x/2 ));   py=$(( cy + rad_y )) ;;
            esac
            
            if [[ $px -gt 0 ]] && [[ $px -le $cols ]] && [[ $py -gt 0 ]] && [[ $py -le $rows ]]; then
                intensity=$(( 255 - radius * 15 ))
                [[ $intensity -lt 50 ]] && intensity=50
                printf "\033[%d;%dH\033[38;2;0;%d;%dm⬡" "$py" "$px" "$intensity" "$(( intensity / 2 ))"
            fi
        done
        sleep 0.03
    done
    
    sleep 0.5
    tput cnorm 2>/dev/null
    clear
}

dna_helix() {
    local rows cols
    rows=$(tput lines 2>/dev/null || echo 24)
    cols=$(tput cols 2>/dev/null || echo 80)
    local cx=$(( cols / 2 ))
    
    tput civis 2>/dev/null
    clear
    
    local frame y offset1 offset2 wave min_x max_x mid
    for ((frame=0; frame<40; frame++)); do
        for ((y=1; y<=rows; y++)); do
            offset1=$(( cx + (15 * (frame + y) % 31 - 15) ))
            offset2=$(( cx - (15 * (frame + y) % 31 - 15) ))
            
            wave=$(( (frame + y) % 10 ))
            offset1=$(( cx + wave - 5 ))
            offset2=$(( cx - wave + 5 ))
            
            if [[ $offset1 -gt 0 ]] && [[ $offset1 -le $cols ]]; then
                printf "\033[%d;%dH\033[38;2;0;255;136m●" "$y" "$offset1"
            fi
            if [[ $offset2 -gt 0 ]] && [[ $offset2 -le $cols ]]; then
                printf "\033[%d;%dH\033[38;2;255;0;200m●" "$y" "$offset2"
            fi
            if [[ $(( y % 3 )) -eq 0 ]]; then
                min_x=$(( offset1 < offset2 ? offset1 : offset2 ))
                max_x=$(( offset1 > offset2 ? offset1 : offset2 ))
                mid=$(( (min_x + max_x) / 2 ))
                if [[ $mid -gt 0 ]] && [[ $mid -le $cols ]]; then
                    printf "\033[%d;%dH\033[38;2;100;100;255m═" "$y" "$mid"
                fi
            fi
        done
        sleep 0.05
    done
    
    tput cnorm 2>/dev/null
    clear
}

zork_logo_boot() {
    tput civis 2>/dev/null
    clear
    
    local rows cols cy
    rows=$(tput lines 2>/dev/null || echo 24)
    cols=$(tput cols 2>/dev/null || echo 80)
    cy=$(( rows / 3 ))
    [[ $cy -lt 1 ]] && cy=1
    
    local _current_banner="${CURRENT_BANNER:-ascii-name}"
    
    if ! type get_active_banner &>/dev/null; then
        [[ -f "$HOME/.zorkos/lib/banners.sh" ]] && source "$HOME/.zorkos/lib/banners.sh" 2>/dev/null
    fi
    
    local -a logo=()
    local -a _boot_gradient=()
    if type get_active_banner &>/dev/null; then
        local _bidx
        _bidx=$(_banner_name_to_index "$_current_banner" 2>/dev/null || echo 0)
        _get_banner_gradient "$_bidx" 2>/dev/null
        get_active_banner "$_current_banner"
        logo=("${ACTIVE_BANNER_LINES[@]}")
        _boot_gradient=("${ACTIVE_BANNER_GRADIENT[@]}")
    fi
    
    if [[ ${#logo[@]} -eq 0 ]]; then
        local _cmd_name
        _cmd_name=$(grep "^CMD_NAME=" "$HOME/.zorkos/user.conf" 2>/dev/null | cut -d= -f2)
        [[ -z "$_cmd_name" ]] && _cmd_name="ZORK"
        _cmd_name=$(echo "$_cmd_name" | tr '[:lower:]' '[:upper:]')
        logo=("⚡ ${_cmd_name} OS ⚡" "  v2.0 • 2026")
    fi
    
    local line_num=0
    local line lx
    for line in "${logo[@]}"; do
        lx=$(( (cols - ${#line}) / 2 ))
        [[ $lx -lt 1 ]] && lx=1
        
        printf "\033[%d;%dH" $(( cy + line_num )) "$lx"
        if type gradient_text &>/dev/null && [[ ${#_boot_gradient[@]} -gt 0 ]]; then
            gradient_text "$line" "${_boot_gradient[@]}" 2>/dev/null
        else
            local r=0 g=$(( 180 + line_num * 15 )) b=$(( 255 - line_num * 30 ))
            [[ $g -gt 255 ]] && g=255
            [[ $b -lt 80 ]] && b=80
            printf "\033[38;2;%d;%d;%dm%s" "$r" "$g" "$b" "$line"
        fi
        line_num=$((line_num + 1))
        sleep 0.05
    done
    
    local subtitle
    subtitle=$(get_responsive_subtitle 2>/dev/null || echo "[ TERMINAL EXPERT — 2026 EDITION ]")
    local sx=$(( (cols - ${#subtitle}) / 2 ))
    [[ $sx -lt 1 ]] && sx=1
    
    sleep 0.15
    printf "\033[%d;%dH\033[38;2;0;200;255m%s" $(( cy + line_num + 2 )) "$sx" "$subtitle"
    
    local madeby
    madeby=$(grep "^USERNAME=" "$HOME/.zorkos/user.conf" 2>/dev/null | cut -d= -f2)
    [[ -z "$madeby" ]] && madeby="Zork"
    madeby="${madeby}'s Terminal — Beyond All Limits"
    local mx=$(( (cols - ${#madeby}) / 2 ))
    [[ $mx -lt 1 ]] && mx=1
    
    sleep 0.1
    printf "\033[%d;%dH\033[38;2;200;100;255m%s\033[0m" $(( cy + line_num + 4 )) "$mx" "$madeby"
    
    sleep 0.5
    
    local fade_i
    for ((fade_i=1; fade_i<=rows; fade_i+=2)); do
        printf "\033[%d;1H\033[2K" "$fade_i"
        [[ $(( fade_i + 1 )) -le $rows ]] && printf "\033[%d;1H\033[2K" $(( fade_i + 1 ))
        sleep 0.008
    done
    
    clear
    tput cnorm 2>/dev/null
}

particle_explode() {
    local cx cy
    local cols rows
    cols=$(tput cols 2>/dev/null || echo 80)
    rows=$(tput lines 2>/dev/null || echo 24)
    cx=$(( cols / 2 ))
    cy=$(( rows / 2 ))
    
    tput civis 2>/dev/null
    clear
    
    local particles="★✦✧⚡❋❊✺✹◆◇●○"
    
    local frame angle rad_x rad_y px py p r g b
    for ((frame=0; frame<20; frame++)); do
        for ((angle=0; angle<360; angle+=15)); do
            rad_x=$(( frame * 3 * (100 + (angle % 50)) / 100 ))
            rad_y=$(( frame * 1 * (100 + (angle % 30)) / 100 ))
            
            px=$(( cx + rad_x * (angle % 3 - 1) ))
            py=$(( cy + rad_y * ((angle / 3) % 3 - 1) ))
            
            if [[ $px -gt 0 ]] && [[ $px -le $cols ]] && [[ $py -gt 0 ]] && [[ $py -le $rows ]]; then
                p=${particles:$(( RANDOM % ${#particles} )):1}
                r=$(( 200 + RANDOM % 56 ))
                g=$(( RANDOM % 100 + frame * 10 ))
                b=$(( 50 + RANDOM % 200 ))
                printf "\033[%d;%dH\033[38;2;%d;%d;%dm%s" "$py" "$px" "$r" "$g" "$b" "$p"
            fi
        done
        sleep 0.04
    done
    
    sleep 0.3
    tput cnorm 2>/dev/null
    clear
}

boot_loading_screen() {
    tput civis 2>/dev/null
    clear
    
    local rows cols
    rows=$(tput lines 2>/dev/null || echo 24)
    cols=$(tput cols 2>/dev/null || echo 80)
    local cy=$(( rows / 2 - 3 ))
    
    local -a stages=(
        "Initializing ZorkOS kernel..."
        "Loading gradient engine..."
        "Mounting theme filesystem..."
        "Starting animation daemon..."
        "Loading plugin registry..."
        "Calibrating color matrix..."
        "Establishing shell protocol..."
        "ZorkOS ready."
    )
    
    local width=$(( cols - 14 ))
    [[ $width -gt 50 ]] && width=50
    [[ $width -lt 10 ]] && width=10
    local bx=$(( (cols - width - 4) / 2 ))
    [[ $bx -lt 1 ]] && bx=1
    
    local idx=0
    local pct filled max_stage display_stage i gr bl hex_pos hex_pct stage
    for stage in "${stages[@]}"; do
        pct=$(( (idx + 1) * 100 / ${#stages[@]} ))
        filled=$(( pct * width / 100 ))
        
        max_stage=$(( cols - bx - 4 ))
        [[ $max_stage -lt 10 ]] && max_stage=10
        display_stage="${stage:0:$max_stage}"
        printf "\033[%d;%dH\033[2K" $(( cy )) "$bx"
        printf "\033[38;2;0;200;200m %s" "$display_stage"
        
        printf "\033[%d;%dH\033[2K" $(( cy + 2 )) "$bx"
        printf "  \033[38;5;240m["
        
        for ((i=0; i<filled; i++)); do
            gr=$(( 100 + i * 3 ))
            [[ $gr -gt 255 ]] && gr=255
            bl=$(( 255 - i * 4 ))
            [[ $bl -lt 50 ]] && bl=50
            printf "\033[38;2;0;%d;%dm█" "$gr" "$bl"
        done
        for ((i=filled; i<width; i++)); do
            printf "\033[38;5;236m░"
        done
        printf "\033[38;5;240m] \033[1;97m%3d%%\033[0m" "$pct"
        
        hex_pos=$(( bx + 2 ))
        printf "\033[%d;%dH\033[2K" $(( cy + 4 )) "$hex_pos"
        hex_pct=$(printf "0x%02X" "$pct")
        if [[ $cols -ge 40 ]]; then
            printf "\033[38;2;0;255;136mSYS_LOAD: %s [%3d%%]" "$hex_pct" "$pct"
        else
            printf "\033[38;2;0;255;136m%s %3d%%" "$hex_pct" "$pct"
        fi
        
        idx=$((idx + 1))
        sleep 0.12
    done
    
    play_sound "boot"
    sleep 0.2
    tput cnorm 2>/dev/null
    clear
}

glitch_transition() {
    local rows cols
    rows=$(tput lines 2>/dev/null || echo 24)
    cols=$(tput cols 2>/dev/null || echo 80)
    local glitch_chars="▓▒░█▄▀■□▪▫"
    
    tput civis 2>/dev/null
    
    local frame i r c gc
    for ((frame=0; frame<8; frame++)); do
        for ((i=0; i<$(( rows * cols / 20 )); i++)); do
            r=$(( RANDOM % rows + 1 ))
            c=$(( RANDOM % cols + 1 ))
            gc=${glitch_chars:$(( RANDOM % ${#glitch_chars} )):1}
            printf "\033[%d;%dH\033[38;2;%d;%d;%dm%s" "$r" "$c" $(( RANDOM % 256 )) $(( RANDOM % 100 )) $(( RANDOM % 256 )) "$gc"
        done
        sleep 0.04
        [[ $(( frame % 2 )) -eq 0 ]] && clear
    done
    
    tput cnorm 2>/dev/null
    clear
}

animated_clock() {
    local time_str
    time_str=$(date "+%H:%M:%S")
    local date_str
    date_str=$(date "+%a %b %d, %Y")
    
    local seg
    local segments=(
        "╭───────────────────"
        "│   $time_str"
        "│   $date_str"
        "╰───────────────────"
    )
    
    for seg in "${segments[@]}"; do
        gradient_text "  $seg" "${GRADIENT_ZORK[@]}"
        echo
    done
}

full_boot_sequence() {
    local boot_style="${1:-default}"
    
    [[ -n "$ZSH_VERSION" ]] && setopt localoptions NO_MONITOR NO_NOTIFY 2>/dev/null
    
    play_sound "boot"
    
    case "$boot_style" in
        matrix)
            matrix_rain 2
            zork_logo_boot
            boot_loading_screen
            ;;
        cyber)
            cyber_grid_boot
            zork_logo_boot
            boot_loading_screen
            ;;
        hex)
            hex_boot
            zork_logo_boot
            boot_loading_screen
            ;;
        dna)
            dna_helix
            zork_logo_boot
            boot_loading_screen
            ;;
        glitch)
            glitch_transition
            zork_logo_boot
            boot_loading_screen
            ;;
        particle)
            particle_explode
            zork_logo_boot
            boot_loading_screen
            ;;
        minimal)
            zork_logo_boot
            ;;
        none)
            return 0
            ;;
        *)
            zork_logo_boot
            boot_loading_screen
            ;;
    esac
    
    play_sound "success"
}
