#!/bin/bash

supports_truecolor() {
    if [[ "$COLORTERM" == "truecolor" ]] || [[ "$COLORTERM" == "24bit" ]]; then
        return 0
    fi
    return 1
}

rgb_fg() { printf "\033[38;2;%d;%d;%dm" "$1" "$2" "$3"; }
rgb_bg() { printf "\033[48;2;%d;%d;%dm" "$1" "$2" "$3"; }

c256_fg() { printf "\033[38;5;%dm" "$1"; }
c256_bg() { printf "\033[48;5;%dm" "$1"; }

RST="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"
ITALIC="\033[3m"
UNDERLINE="\033[4m"
BLINK="\033[5m"
REVERSE="\033[7m"
HIDDEN="\033[8m"
STRIKE="\033[9m"

declare -A GRADIENT_PRESETS

GRADIENT_CYBER_PURPLE=(
    "138,43,226"    # BlueViolet
    "148,0,211"     # DarkViolet
    "186,85,211"    # MediumOrchid
    "255,0,255"     # Magenta
    "218,112,214"   # Orchid
    "238,130,238"   # Violet
)

GRADIENT_NEON_FIRE=(
    "255,0,0"       # Red
    "255,69,0"      # OrangeRed
    "255,140,0"     # DarkOrange
    "255,215,0"     # Gold
    "255,255,0"     # Yellow
    "173,255,47"    # GreenYellow
)

GRADIENT_OCEAN_DEEP=(
    "0,0,139"       # DarkBlue
    "0,0,205"       # MediumBlue
    "0,100,255"     # RoyalBlue
    "0,191,255"     # DeepSkyBlue
    "0,255,255"     # Cyan
    "127,255,212"   # Aquamarine
)

GRADIENT_MATRIX=(
    "0,50,0"
    "0,100,0"
    "0,150,0"
    "0,200,0"
    "0,255,0"
    "50,255,50"
)

GRADIENT_SUNSET=(
    "255,94,77"     # Coral
    "255,154,0"     # Orange
    "255,206,0"     # Amber
    "255,0,110"     # Rose
    "131,56,236"    # Purple
    "58,12,163"     # DeepPurple
)

GRADIENT_ICE=(
    "200,233,255"
    "150,200,255"
    "100,180,255"
    "50,150,255"
    "0,120,255"
    "0,80,200"
)

GRADIENT_ZORK=(
    "0,255,136"     # Zork Green
    "0,255,200"     # Zork Cyan
    "0,200,255"     # Zork Blue
    "100,100,255"   # Zork Indigo
    "200,0,255"     # Zork Purple
    "255,0,200"     # Zork Pink
)

GRADIENT_BLOOD=(
    "139,0,0"
    "178,34,34"
    "220,20,60"
    "255,0,0"
    "255,69,0"
    "255,99,71"
)

GRADIENT_AURORA=(
    "0,255,127"
    "0,200,200"
    "50,100,255"
    "100,0,255"
    "200,0,200"
    "255,0,128"
)

_parse_rgb() {
    local _csv="$1"
    _PR="${_csv%%,*}"
    local _rest="${_csv#*,}"
    _PG="${_rest%%,*}"
    _PB="${_rest##*,}"
}

_interpolate_rgb() {
    local r1=$1 g1=$2 b1=$3
    local r2=$4 g2=$5 b2=$6
    local t=$7  # integer 0-100
    
    _IR=$(( r1 + (r2 - r1) * t / 100 ))
    _IG=$(( g1 + (g2 - g1) * t / 100 ))
    _IB=$(( b1 + (b2 - b1) * t / 100 ))
}

gradient_text() {
    [[ -n "$ZSH_VERSION" ]] && setopt localoptions KSH_ARRAYS 2>/dev/null
    local text="$1"
    shift
    local colors=("$@")
    local len=${#text}
    local num_colors=${#colors[@]}
    
    if [[ $len -eq 0 ]] || [[ $num_colors -eq 0 ]]; then
        echo "$text"
        return
    fi
    
    local i r1 g1 b1 r2 g2 b2 char pos idx frac
    for ((i=0; i<len; i++)); do
        char="${text:$i:1}"
        pos=$(( i * (num_colors - 1) * 100 / (len > 1 ? len - 1 : 1) ))
        idx=$(( pos / 100 ))
        frac=$(( pos % 100 ))
        
        if [[ $idx -ge $((num_colors - 1)) ]]; then
            idx=$((num_colors - 2))
            frac=100
        fi
        
        _parse_rgb "${colors[$idx]}"
        r1=$_PR; g1=$_PG; b1=$_PB
        _parse_rgb "${colors[$((idx + 1))]}"
        r2=$_PR; g2=$_PG; b2=$_PB
        
        _interpolate_rgb $r1 $g1 $b1 $r2 $g2 $b2 $frac
        
        printf "\033[38;2;%d;%d;%dm%s" "$_IR" "$_IG" "$_IB" "$char"
    done
    printf "${RST}"
}

gradient_line() {
    local char="${1:-═}"
    shift
    local colors=("$@")
    local width
    width=$(tput cols 2>/dev/null || echo 80)
    
    local text="" i
    for ((i=0; i<width; i++)); do
        text+="$char"
    done
    
    gradient_text "$text" "${colors[@]}"
    echo
}

vertical_gradient_text() {
    [[ -n "$ZSH_VERSION" ]] && setopt localoptions KSH_ARRAYS 2>/dev/null
    local -a lines=()
    local text="$1"
    shift
    local colors=("$@")
    
    while IFS= read -r line; do
        lines+=("$line")
    done <<< "$text"
    
    local num_lines=${#lines[@]}
    local num_colors=${#colors[@]}
    
    local i r1 g1 b1 r2 g2 b2 pos idx frac
    for ((i=0; i<num_lines; i++)); do
        pos=$(( i * (num_colors - 1) * 100 / (num_lines > 1 ? num_lines - 1 : 1) ))
        idx=$(( pos / 100 ))
        frac=$(( pos % 100 ))
        
        if [[ $idx -ge $((num_colors - 1)) ]]; then
            idx=$((num_colors - 2))
            frac=100
        fi
        
        _parse_rgb "${colors[$idx]}"
        r1=$_PR; g1=$_PG; b1=$_PB
        _parse_rgb "${colors[$((idx + 1))]}"
        r2=$_PR; g2=$_PG; b2=$_PB
        
        _interpolate_rgb $r1 $g1 $b1 $r2 $g2 $b2 $frac
        
        printf "\033[38;2;%d;%d;%dm%s${RST}\n" "$_IR" "$_IG" "$_IB" "${lines[$i]}"
    done
}

animate_gradient_sweep() {
    [[ -n "$ZSH_VERSION" ]] && setopt localoptions KSH_ARRAYS 2>/dev/null
    local text="$1"
    local speed="${2:-0.03}"
    local cycles="${3:-2}"
    shift 3
    local colors=("$@")
    local len=${#text}
    local num_colors=${#colors[@]}
    
    local cycle r1 g1 b1 r2 g2 b2 i char shifted_i pos idx frac
    for ((cycle=0; cycle<cycles*len; cycle++)); do
        printf "\r"
        for ((i=0; i<len; i++)); do
            char="${text:$i:1}"
            shifted_i=$(( (i + cycle) % len ))
            pos=$(( shifted_i * (num_colors - 1) * 100 / (len > 1 ? len - 1 : 1) ))
            idx=$(( pos / 100 ))
            frac=$(( pos % 100 ))
            
            if [[ $idx -ge $((num_colors - 1)) ]]; then
                idx=$((num_colors - 2))
                frac=100
            fi
            
            _parse_rgb "${colors[$idx]}"
            r1=$_PR; g1=$_PG; b1=$_PB
            _parse_rgb "${colors[$((idx + 1))]}"
            r2=$_PR; g2=$_PG; b2=$_PB
            
            _interpolate_rgb $r1 $g1 $b1 $r2 $g2 $b2 $frac
            
            printf "\033[38;2;%d;%d;%dm%s" "$_IR" "$_IG" "$_IB" "$char"
        done
        sleep "$speed"
    done
    printf "${RST}\n"
}

pulse_text() {
    local text="$1"
    local r="$2" g="$3" b="$4"
    local pulses="${5:-3}"
    
    local p step pr pg pb
    for ((p=0; p<pulses; p++)); do
        for step in 30 60 90 100 90 60 30; do
            pr=$(( r * step / 100 ))
            pg=$(( g * step / 100 ))
            pb=$(( b * step / 100 ))
            printf "\r\033[38;2;%d;%d;%dm%s${RST}" "$pr" "$pg" "$pb" "$text"
            sleep 0.04
        done
    done
    echo
}

rainbow_wave() {
    local text="$1"
    local frames="${2:-30}"
    local speed="${3:-0.05}"
    
    local frame i hue h f q r g b
    for ((frame=0; frame<frames; frame++)); do
        printf "\r"
        for ((i=0; i<${#text}; i++)); do
            hue=$(( (i * 15 + frame * 12) % 360 ))
            h=$(( hue / 60 ))
            f=$(( (hue % 60) * 255 / 60 ))
            q=$(( 255 - f ))
            case $h in
                0) r=255; g=$f;   b=0   ;;
                1) r=$q;  g=255;  b=0   ;;
                2) r=0;   g=255;  b=$f  ;;
                3) r=0;   g=$q;   b=255 ;;
                4) r=$f;  g=0;    b=255 ;;
                5) r=255; g=0;    b=$q  ;;
            esac
            printf "\033[38;2;%d;%d;%dm%s" "$r" "$g" "$b" "${text:$i:1}"
        done
        sleep "$speed"
    done
    printf "${RST}\n"
}

gradient_box() {
    local title="$1"
    shift
    local colors=("$@")
    local width
    width=$(tput cols 2>/dev/null || echo 80)
    width=$(( width > 70 ? 68 : width - 2 ))
    
    local top="╭"
    for ((i=0; i<width-2; i++)); do top+="─"; done
    gradient_text "$top" "${colors[@]}"
    echo
    
    local title_len=${#title}
    local pad_left=$(( (width - 2 - title_len) / 2 ))
    local pad_right=$(( width - 2 - title_len - pad_left ))
    local title_line="│$(printf '%*s' $pad_left '')${title}"
    gradient_text "$title_line" "${colors[@]}"
    echo
    
    local bot="╰"
    for ((i=0; i<width-2; i++)); do bot+="─"; done
    gradient_text "$bot" "${colors[@]}"
    echo
}

gradient_typing() {
    [[ -n "$ZSH_VERSION" ]] && setopt localoptions KSH_ARRAYS 2>/dev/null
    local text="$1"
    local speed="${2:-0.02}"
    shift 2
    local colors=("$@")
    local len=${#text}
    local num_colors=${#colors[@]}
    
    local i char pos idx frac
    for ((i=0; i<len; i++)); do
        char="${text:$i:1}"
        pos=$(( i * (num_colors - 1) * 100 / (len > 1 ? len - 1 : 1) ))
        idx=$(( pos / 100 ))
        frac=$(( pos % 100 ))
        
        if [[ $idx -ge $((num_colors - 1)) ]]; then
            idx=$((num_colors - 2))
            frac=100
        fi
        
        _parse_rgb "${colors[$idx]}"
        r1=$_PR; g1=$_PG; b1=$_PB
        _parse_rgb "${colors[$((idx + 1))]}"
        r2=$_PR; g2=$_PG; b2=$_PB
        
        _interpolate_rgb $r1 $g1 $b1 $r2 $g2 $b2 $frac
        
        printf "\033[38;2;%d;%d;%dm%s" "$_IR" "$_IG" "$_IB" "$char"
        sleep "$speed"
    done
    printf "${RST}"
}

sparkle_text() {
    local text="$1"
    local iterations="${2:-15}"
    local speed="${3:-0.05}"
    local sparkle_chars="★✦✧⚡❋❊✺✹"
    
    local len=${#text}
    local iter i sc
    for ((iter=0; iter<iterations; iter++)); do
        printf "\r"
        for ((i=0; i<len; i++)); do
            if [[ $(( RANDOM % 4 )) -eq 0 ]] && [[ $iter -lt $((iterations - 1)) ]]; then
                sc=${sparkle_chars:$(( RANDOM % ${#sparkle_chars} )):1}
                printf "\033[38;2;%d;%d;%dm%s" $(( RANDOM % 256 )) $(( RANDOM % 256 )) $(( RANDOM % 256 )) "$sc"
            else
                printf "\033[38;2;0;255;%dm%s" $(( 136 + RANDOM % 120 )) "${text:$i:1}"
            fi
        done
        sleep "$speed"
    done
    printf "${RST}\n"
}

matrix_column() {
    local col="$1"
    local rows="$2"
    local chars="ﾊﾐﾋｰｳｼﾅﾓﾆｻﾜﾂｵﾘｱﾎﾃﾏｹﾒｴｶｷﾑﾕﾗｾﾈｽﾀﾇﾍ0123456789ZORK"
    local speed=0.03
    
    local row c intensity
    for ((row=0; row<rows; row++)); do
        c=${chars:$(( RANDOM % ${#chars} )):1}
        intensity=$(( 255 - (rows - row) * 20 ))
        [[ $intensity -lt 50 ]] && intensity=50
        printf "\033[%d;%dH\033[38;2;0;%d;0m%s" "$row" "$col" "$intensity" "$c"
        sleep "$speed"
    done
}

matrix_rain() {
    local duration="${1:-3}"
    local cols
    local rows
    cols=$(tput cols 2>/dev/null || echo 80)
    rows=$(tput lines 2>/dev/null || echo 24)
    local chars="ﾊﾐﾋｰｳｼﾅﾓﾆｻﾜﾂｵﾘｱﾎﾃﾏｹﾒｴｶｷﾑﾕﾗｾﾈｽﾀﾇﾍ01234ZORK"
    
    tput civis 2>/dev/null  # Hide cursor
    clear
    
    local end_time=$(( $(date +%s) + duration ))
    local col row c g
    while [[ $(date +%s) -lt $end_time ]]; do
        col=$(( RANDOM % cols + 1 ))
        row=$(( RANDOM % rows + 1 ))
        c=${chars:$(( RANDOM % ${#chars} )):1}
        g=$(( 100 + RANDOM % 156 ))
        printf "\033[%d;%dH\033[38;2;0;%d;0m%s" "$row" "$col" "$g" "$c"
        sleep 0.01
    done
    
    tput cnorm 2>/dev/null  # Show cursor
}

gradient_progress() {
    local current="$1"
    local total="$2"
    local label="${3:-Progress}"
    local width=40
    
    local filled=$(( current * width / total ))
    local empty=$(( width - filled ))
    local pct=$(( current * 100 / total ))
    
    printf "\r  \033[1m%s\033[0m [" "$label"
    
    local i r g b
    for ((i=0; i<filled; i++)); do
        r=$(( 0 ))
        g=$(( 100 + i * 155 / width ))
        b=$(( 255 - i * 200 / width ))
        printf "\033[38;2;%d;%d;%dm█" "$r" "$g" "$b"
    done
    
    for ((i=0; i<empty; i++)); do
        printf "\033[38;5;236m░"
    done
    
    printf "\033[0m] \033[1;97m%3d%%\033[0m" "$pct"
}

gradient_spinner() {
    local pid="$1"
    local msg="${2:-Loading}"
    local spinchars='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    
    local c hue h f q r g b
    while kill -0 "$pid" 2>/dev/null; do
        c=${spinchars:$((i % ${#spinchars})):1}
        hue=$(( (i * 30) % 360 ))
        h=$(( hue / 60 ))
        f=$(( (hue % 60) * 255 / 60 ))
        q=$(( 255 - f ))
        case $h in
            0) r=255; g=$f;   b=0   ;;
            1) r=$q;  g=255;  b=0   ;;
            2) r=0;   g=255;  b=$f  ;;
            3) r=0;   g=$q;   b=255 ;;
            4) r=$f;  g=0;    b=255 ;;
            5) r=255; g=0;    b=$q  ;;
        esac
        printf "\r  \033[38;2;%d;%d;%dm%s\033[0m %s" "$r" "$g" "$b" "$c" "$msg"
        i=$((i + 1))
        sleep 0.08
    done
    printf "\r  \033[1;32m✓\033[0m %s\n" "$msg"
}
