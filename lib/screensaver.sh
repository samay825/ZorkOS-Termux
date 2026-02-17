#!/bin/bash

SCREENSAVER_CONF="${HOME}/.zorkos/screensaver.conf"
SCREENSAVER_PID_FILE="${HOME}/.zorkos/cache/.screensaver_pid"

_read_key() {
    local timeout="$1"
    if [[ -n "$ZSH_VERSION" ]]; then
        read -t "$timeout" -k 1 key 2>/dev/null
    else
        read -t "$timeout" -n 1 key 2>/dev/null
    fi
}

screensaver_init() {
    if [[ ! -f "$SCREENSAVER_CONF" ]]; then
        cat > "$SCREENSAVER_CONF" << 'SSCONF'
SCREENSAVER_ENABLED=false
SCREENSAVER_STYLE=matrix
SCREENSAVER_TIMEOUT=300
SCREENSAVER_COLOR=green
SSCONF
    fi
    source "$SCREENSAVER_CONF" 2>/dev/null
}

_ss_matrix_rain() {
    [[ -n "$ZSH_VERSION" ]] && setopt localoptions KSH_ARRAYS 2>/dev/null
    local cols rows
    cols=$(tput cols 2>/dev/null || echo 80)
    rows=$(tput lines 2>/dev/null || echo 24)
    
    tput civis 2>/dev/null
    clear
    
    local chars="ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ0123456789"
    local -a drops
    
    local i
    for ((i=0; i<cols; i++)); do
        drops[$i]=$(( RANDOM % rows ))
    done
    
    local col row char trail_row trail_char fade_row
    while true; do
        _read_key 0.05 && break
        
        for ((col=0; col<cols; col+=2)); do
            row=${drops[$col]}
            char=${chars:$(( RANDOM % ${#chars} )):1}
            
            printf "\033[%d;%dH\033[1;38;2;150;255;150m%s" "$row" "$col" "$char"
            
            trail_row=$(( row - 1 ))
            if [[ $trail_row -gt 0 ]]; then
                trail_char=${chars:$(( RANDOM % ${#chars} )):1}
                printf "\033[%d;%dH\033[38;2;0;%d;0m%s" "$trail_row" "$col" $(( 80 + RANDOM % 80 )) "$trail_char"
            fi
            
            fade_row=$(( row - 8 - RANDOM % 4 ))
            if [[ $fade_row -gt 0 ]]; then
                printf "\033[%d;%dH " "$fade_row" "$col"
            fi
            
            if [[ $row -ge $rows ]] || [[ $(( RANDOM % 50 )) -eq 0 ]]; then
                drops[$col]=0
            else
                drops[$col]=$(( row + 1 ))
            fi
        done
    done
    
    tput cnorm 2>/dev/null
    clear
}

_ss_clock() {
    tput civis 2>/dev/null
    clear
    
    local rows cols
    rows=$(tput lines 2>/dev/null || echo 24)
    cols=$(tput cols 2>/dev/null || echo 80)
    
    local time_str date_str cy tx dx second hue _ssname brand
    while true; do
        _read_key 1 && break
        
        time_str=$(date "+%H : %M : %S")
        date_str=$(date "+%A, %B %d, %Y")
        
        cy=$(( rows / 2 ))
        tx=$(( (cols - ${#time_str}) / 2 ))
        dx=$(( (cols - ${#date_str}) / 2 ))
        
        second=$(date +%S)
        hue=$(( second * 255 / 60 ))
        
        printf "\033[%d;%dH\033[1;38;2;%d;255;%dm%s\033[0m" "$cy" "$tx" $(( 255 - hue )) "$hue" "$time_str"
        printf "\033[%d;%dH\033[38;2;100;100;140m%s\033[0m" $(( cy + 2 )) "$dx" "$date_str"
        
        _ssname=$(grep "^USERNAME=" "$HOME/.zorkos/user.conf" 2>/dev/null | cut -d= -f2)
        [[ -z "$_ssname" ]] && _ssname="Zork"
        brand="${_ssname}'s Terminal"
        printf "\033[%d;%dH\033[38;2;50;50;70m%s\033[0m" $(( rows - 1 )) $(( (cols - ${#brand}) / 2 )) "$brand"
    done
    
    tput cnorm 2>/dev/null
    clear
}

_ss_starfield() {
    [[ -n "$ZSH_VERSION" ]] && setopt localoptions KSH_ARRAYS 2>/dev/null
    local cols rows
    cols=$(tput cols 2>/dev/null || echo 80)
    rows=$(tput lines 2>/dev/null || echo 24)
    
    tput civis 2>/dev/null
    clear
    
    local -a star_x star_y star_speed star_char
    local stars="⋅·.*✦★✧⚬"
    local num_stars=60
    
    local i
    for ((i=0; i<num_stars; i++)); do
        star_x[$i]=$(( RANDOM % cols + 1 ))
        star_y[$i]=$(( RANDOM % rows + 1 ))
        star_speed[$i]=$(( RANDOM % 3 + 1 ))
        star_char[$i]=${stars:$(( RANDOM % ${#stars} )):1}
    done
    
    local brightness
    while true; do
        _read_key 0.08 && break
        
        for ((i=0; i<num_stars; i++)); do
            printf "\033[%d;%dH " "${star_y[$i]}" "${star_x[$i]}"
            
            star_x[$i]=$(( star_x[$i] - star_speed[$i] ))
            
            if [[ ${star_x[$i]} -le 0 ]]; then
                star_x[$i]=$cols
                star_y[$i]=$(( RANDOM % rows + 1 ))
                star_speed[$i]=$(( RANDOM % 3 + 1 ))
            fi
            
            brightness=$(( star_speed[$i] * 85 ))
            [[ $brightness -gt 255 ]] && brightness=255
            printf "\033[%d;%dH\033[38;2;%d;%d;%dm%s" "${star_y[$i]}" "${star_x[$i]}" \
                "$brightness" "$brightness" "$brightness" "${star_char[$i]}"
        done
    done
    
    tput cnorm 2>/dev/null
    clear
}

_ss_pipes() {
    [[ -n "$ZSH_VERSION" ]] && setopt localoptions KSH_ARRAYS 2>/dev/null
    local cols rows
    cols=$(tput cols 2>/dev/null || echo 80)
    rows=$(tput lines 2>/dev/null || echo 24)
    
    tput civis 2>/dev/null
    clear
    
    local x=$(( cols / 2 ))
    local y=$(( rows / 2 ))
    local dir=0  # 0=right 1=down 2=left 3=up
    local pipe_chars="│─┌┐└┘├┤┬┴┼"
    local colors=("0;255;136" "0;200;255" "200;100;255" "255;0;200" "255;220;0" "255;165;0")
    local color_idx=0
    
    local old_dir corner pipe_char
    while true; do
        _read_key 0.03 && break
        
        if [[ $(( RANDOM % 5 )) -eq 0 ]]; then
            old_dir=$dir
            dir=$(( RANDOM % 4 ))
            
            if [[ $old_dir -eq 0 && $dir -eq 1 ]] || [[ $old_dir -eq 3 && $dir -eq 2 ]]; then corner="┐"
            elif [[ $old_dir -eq 0 && $dir -eq 3 ]] || [[ $old_dir -eq 1 && $dir -eq 2 ]]; then corner="┘"
            elif [[ $old_dir -eq 2 && $dir -eq 1 ]] || [[ $old_dir -eq 3 && $dir -eq 0 ]]; then corner="┌"
            elif [[ $old_dir -eq 2 && $dir -eq 3 ]] || [[ $old_dir -eq 1 && $dir -eq 0 ]]; then corner="└"
            else corner="┼"
            fi
            
            printf "\033[%d;%dH\033[38;2;%sm%s" "$y" "$x" "${colors[$color_idx]}" "$corner"
        else
            if [[ $dir -eq 0 || $dir -eq 2 ]]; then pipe_char="─"
            else pipe_char="│"
            fi
            printf "\033[%d;%dH\033[38;2;%sm%s" "$y" "$x" "${colors[$color_idx]}" "$pipe_char"
        fi
        
        case $dir in
            0) x=$((x + 1)) ;;
            1) y=$((y + 1)) ;;
            2) x=$((x - 1)) ;;
            3) y=$((y - 1)) ;;
        esac
        
        [[ $x -gt $cols ]] && { x=1; color_idx=$(( (color_idx + 1) % ${#colors[@]} )); }
        [[ $x -lt 1 ]] && { x=$cols; color_idx=$(( (color_idx + 1) % ${#colors[@]} )); }
        [[ $y -gt $rows ]] && { y=1; color_idx=$(( (color_idx + 1) % ${#colors[@]} )); }
        [[ $y -lt 1 ]] && { y=$rows; color_idx=$(( (color_idx + 1) % ${#colors[@]} )); }
    done
    
    tput cnorm 2>/dev/null
    clear
}

run_screensaver() {
    local style="${1:-matrix}"
    
    case "$style" in
        matrix)    _ss_matrix_rain ;;
        clock)     _ss_clock ;;
        starfield) _ss_starfield ;;
        pipes)     _ss_pipes ;;
        *)         _ss_matrix_rain ;;
    esac
}

generate_screensaver_hook() {
    local timeout="${SCREENSAVER_TIMEOUT:-300}"
    local style="${SCREENSAVER_STYLE:-matrix}"
    
    cat << SSHOOK
TMOUT=${timeout}
TRAPALRM() {
    if [[ -f "\$HOME/.zorkos/lib/screensaver.sh" ]]; then
        source "\$HOME/.zorkos/lib/screensaver.sh"
        run_screensaver "${style}"
    fi
}
SSHOOK
}

screensaver_init
