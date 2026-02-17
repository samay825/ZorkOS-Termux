#!/bin/bash

_banner_char() {
    [[ -n "$ZSH_VERSION" ]] && setopt localoptions KSH_ARRAYS 2>/dev/null
    local ch="$1"
    local row="$2"  # 0-5

    case "$ch" in
        A) local -a L=(
            " █████╗ "
            "██╔══██╗"
            "███████║"
            "██╔══██║"
            "██║  ██║"
            "╚═╝  ╚═╝") ;;
        B) local -a L=(
            "██████╗ "
            "██╔══██╗"
            "██████╔╝"
            "██╔══██╗"
            "██████╔╝"
            "╚═════╝ ") ;;
        C) local -a L=(
            " ██████╗"
            "██╔════╝"
            "██║     "
            "██║     "
            "╚██████╗"
            " ╚═════╝") ;;
        D) local -a L=(
            "██████╗ "
            "██╔══██╗"
            "██║  ██║"
            "██║  ██║"
            "██████╔╝"
            "╚═════╝ ") ;;
        E) local -a L=(
            "███████╗"
            "██╔════╝"
            "█████╗  "
            "██╔══╝  "
            "███████╗"
            "╚══════╝") ;;
        F) local -a L=(
            "███████╗"
            "██╔════╝"
            "█████╗  "
            "██╔══╝  "
            "██║     "
            "╚═╝     ") ;;
        G) local -a L=(
            " ██████╗ "
            "██╔════╝ "
            "██║  ███╗"
            "██║   ██║"
            "╚██████╔╝"
            " ╚═════╝ ") ;;
        H) local -a L=(
            "██╗  ██╗"
            "██║  ██║"
            "███████║"
            "██╔══██║"
            "██║  ██║"
            "╚═╝  ╚═╝") ;;
        I) local -a L=(
            "██╗"
            "██║"
            "██║"
            "██║"
            "██║"
            "╚═╝") ;;
        J) local -a L=(
            "     ██╗"
            "     ██║"
            "     ██║"
            "██   ██║"
            "╚█████╔╝"
            " ╚════╝ ") ;;
        K) local -a L=(
            "██╗  ██╗"
            "██║ ██╔╝"
            "█████╔╝ "
            "██╔═██╗ "
            "██║  ██╗"
            "╚═╝  ╚═╝") ;;
        L) local -a L=(
            "██╗     "
            "██║     "
            "██║     "
            "██║     "
            "███████╗"
            "╚══════╝") ;;
        M) local -a L=(
            "███╗   ███╗"
            "████╗ ████║"
            "██╔████╔██║"
            "██║╚██╔╝██║"
            "██║ ╚═╝ ██║"
            "╚═╝     ╚═╝") ;;
        N) local -a L=(
            "███╗   ██╗"
            "████╗  ██║"
            "██╔██╗ ██║"
            "██║╚██╗██║"
            "██║ ╚████║"
            "╚═╝  ╚═══╝") ;;
        O) local -a L=(
            " ██████╗ "
            "██╔═══██╗"
            "██║   ██║"
            "██║   ██║"
            "╚██████╔╝"
            " ╚═════╝ ") ;;
        P) local -a L=(
            "██████╗ "
            "██╔══██╗"
            "██████╔╝"
            "██╔═══╝ "
            "██║     "
            "╚═╝     ") ;;
        Q) local -a L=(
            " ██████╗  "
            "██╔═══██╗ "
            "██║   ██║ "
            "██║▄▄ ██║ "
            "╚██████╔╝ "
            " ╚══▀▀═╝  ") ;;
        R) local -a L=(
            "██████╗ "
            "██╔══██╗"
            "██████╔╝"
            "██╔══██╗"
            "██║  ██║"
            "╚═╝  ╚═╝") ;;
        S) local -a L=(
            "███████╗"
            "██╔════╝"
            "███████╗"
            "╚════██║"
            "███████║"
            "╚══════╝") ;;
        T) local -a L=(
            "████████╗"
            "╚══██╔══╝"
            "   ██║   "
            "   ██║   "
            "   ██║   "
            "   ╚═╝   ") ;;
        U) local -a L=(
            "██╗   ██╗"
            "██║   ██║"
            "██║   ██║"
            "██║   ██║"
            "╚██████╔╝"
            " ╚═════╝ ") ;;
        V) local -a L=(
            "██╗   ██╗"
            "██║   ██║"
            "██║   ██║"
            "╚██╗ ██╔╝"
            " ╚████╔╝ "
            "  ╚═══╝  ") ;;
        W) local -a L=(
            "██╗    ██╗"
            "██║    ██║"
            "██║ █╗ ██║"
            "██║███╗██║"
            "╚███╔███╔╝"
            " ╚══╝╚══╝ ") ;;
        X) local -a L=(
            "██╗  ██╗"
            "╚██╗██╔╝"
            " ╚███╔╝ "
            " ██╔██╗ "
            "██╔╝ ██╗"
            "╚═╝  ╚═╝") ;;
        Y) local -a L=(
            "██╗   ██╗"
            "╚██╗ ██╔╝"
            " ╚████╔╝ "
            "  ╚██╔╝  "
            "   ██║   "
            "   ╚═╝   ") ;;
        Z) local -a L=(
            "███████╗"
            "╚══███╔╝"
            "  ███╔╝ "
            " ███╔╝  "
            "███████╗"
            "╚══════╝") ;;
        0) local -a L=(
            " ██████╗ "
            "██╔═████╗"
            "██║██╔██║"
            "████╔╝██║"
            "╚██████╔╝"
            " ╚═════╝ ") ;;
        1) local -a L=(
            " ██╗"
            "███║"
            "╚██║"
            " ██║"
            " ██║"
            " ╚═╝") ;;
        2) local -a L=(
            "██████╗ "
            "╚════██╗"
            " █████╔╝"
            "██╔═══╝ "
            "███████╗"
            "╚══════╝") ;;
        3) local -a L=(
            "██████╗ "
            "╚════██╗"
            " █████╔╝"
            " ╚═══██╗"
            "██████╔╝"
            "╚═════╝ ") ;;
        4) local -a L=(
            "██╗  ██╗"
            "██║  ██║"
            "███████║"
            "╚════██║"
            "     ██║"
            "     ╚═╝") ;;
        5) local -a L=(
            "███████╗"
            "██╔════╝"
            "███████╗"
            "╚════██║"
            "███████║"
            "╚══════╝") ;;
        6) local -a L=(
            " ██████╗"
            "██╔════╝"
            "██████╗ "
            "██╔══██╗"
            "╚█████╔╝"
            " ╚════╝ ") ;;
        7) local -a L=(
            "███████╗"
            "╚════██║"
            "    ██╔╝"
            "   ██╔╝ "
            "   ██║  "
            "   ╚═╝  ") ;;
        8) local -a L=(
            " █████╗ "
            "██╔══██╗"
            "╚█████╔╝"
            "██╔══██╗"
            "╚█████╔╝"
            " ╚════╝ ") ;;
        9) local -a L=(
            " █████╗ "
            "██╔══██╗"
            "╚██████║"
            " ╚═══██║"
            " █████╔╝"
            " ╚════╝ ") ;;
        _) local -a L=(
            "        "
            "        "
            "        "
            "        "
            "████████"
            "╚══════╝") ;;
        -) local -a L=(
            "      "
            "      "
            "█████╗"
            "╚════╝"
            "      "
            "      ") ;;
        .) local -a L=(
            "   "
            "   "
            "   "
            "   "
            "██╗"
            "╚═╝") ;;
        " ") local -a L=(
            "   "
            "   "
            "   "
            "   "
            "   "
            "   ") ;;
        *) local -a L=(
            "   "
            "   "
            " ? "
            "   "
            "   "
            "   ") ;;
    esac

    echo "${L[$row]}"
}

_generate_name_banner() {
    [[ -n "$ZSH_VERSION" ]] && setopt localoptions KSH_ARRAYS 2>/dev/null
    local name="$1"
    name=$(echo "$name" | tr '[:lower:]' '[:upper:]')
    local len=${#name}

    local row i ch line
    for ((row=0; row<6; row++)); do
        line=""
        for ((i=0; i<len; i++)); do
            ch="${name:$i:1}"
            line+="$(_banner_char "$ch" "$row")"
        done
        echo "$line"
    done
}

_banner_display_width() {
    local text="$1"
    local stripped
    stripped=$(echo "$text" | sed 's/\x1b\[[0-9;]*m//g')
    echo ${#stripped}
}

show_name_banner() {
    [[ -n "$ZSH_VERSION" ]] && setopt localoptions KSH_ARRAYS 2>/dev/null
    local name="$1"
    [[ -z "$name" ]] && name="ZORK"
    name=$(echo "$name" | tr '[:lower:]' '[:upper:]')

    local cols
    cols=$(tput cols 2>/dev/null || echo 80)

    local max_chars=$(( cols / 9 ))
    [[ $max_chars -lt 3 ]] && max_chars=3
    if [[ ${#name} -gt $max_chars ]]; then
        name="${name:0:$max_chars}"
    fi

    local RST="\033[0m"

    local -a banner_gradient=(
        "180,0,255"
        "140,20,255"
        "100,60,255"
        "60,120,255"
        "0,180,255"
        "0,220,240"
        "0,240,200"
        "0,255,180"
    )

    local -a banner_lines=()
    local row i ch line
    for ((row=0; row<6; row++)); do
        line=""
        for ((i=0; i<${#name}; i++)); do
            ch="${name:$i:1}"
            line+="$(_banner_char "$ch" "$row")"
        done
        banner_lines+=("$line")
    done

    local deco_width=$(( cols - 4 ))
    [[ $deco_width -lt 20 ]] && deco_width=20

    printf "\n"

    local top_deco=""
    local oi omod
    for ((oi=0; oi<deco_width; oi++)); do
        omod=$(( oi % 16 ))
        case $omod in
            0) top_deco+="«" ;;
            1) top_deco+="•" ;;
            2|14) top_deco+="─" ;;
            3) top_deco+="•" ;;
            4|12) top_deco+="─" ;;
            5) top_deco+="╋" ;;
            6|10) top_deco+="─" ;;
            7) top_deco+="•" ;;
            8) top_deco+="»" ;;
            9) top_deco+=" " ;;
            11) top_deco+="•" ;;
            13) top_deco+="─" ;;
            15) top_deco+=" " ;;
            *) top_deco+="─" ;;
        esac
    done

    if type gradient_text &>/dev/null; then
        printf "  "
        gradient_text "$top_deco" "${banner_gradient[@]}"
        echo
    else
        printf "\033[38;2;120;50;255m  %s${RST}\n" "$top_deco"
    fi

    local sep2=""
    for ((oi=0; oi<deco_width; oi++)); do
        omod=$(( oi % 10 ))
        case $omod in
            0) sep2+="«" ;;
            1|2|3|4|5|6|7|8) sep2+="═" ;;
            9) sep2+="»" ;;
        esac
    done
    if type gradient_text &>/dev/null; then
        printf "  "
        gradient_text "$sep2" "0,200,255" "0,255,200" "0,255,180" "0,200,255"
        echo
    else
        printf "\033[38;2;0;200;255m  %s${RST}\n" "$sep2"
    fi

    echo ""

    local bline bwidth pad_left pad_right lr lg lb rr rg rb
    local line_idx=0
    local total_lines=${#banner_lines[@]}
    for bline in "${banner_lines[@]}"; do
        bwidth=${#bline}
        local inner=$(( cols - 5 ))
        pad_left=$(( (inner - bwidth) / 2 ))
        [[ $pad_left -lt 1 ]] && pad_left=1
        pad_right=$(( inner - pad_left - bwidth ))
        [[ $pad_right -lt 0 ]] && pad_right=0

        lr=$(( 200 - line_idx * 30 ))
        lg=$(( 255 - line_idx * 10 ))
        lb=$(( 0 + line_idx * 50 ))
        [[ $lr -lt 0 ]] && lr=0
        [[ $lb -gt 255 ]] && lb=255

        rr=$(( 0 + line_idx * 10 ))
        rg=$(( 200 + line_idx * 10 ))
        rb=$(( 255 - line_idx * 20 ))
        [[ $rr -gt 255 ]] && rr=255
        [[ $rg -gt 255 ]] && rg=255
        [[ $rb -lt 100 ]] && rb=100

        printf "\033[38;2;%d;%d;%dm  ║${RST}" "$lr" "$lg" "$lb"
        printf '%*s' "$pad_left" ''
        if type gradient_text &>/dev/null; then
            gradient_text "$bline" "${banner_gradient[@]}"
        else
            printf "\033[38;2;120;80;255m%s${RST}" "$bline"
        fi
        printf '%*s' "$pad_right" ''
        printf "\033[38;2;%d;%d;%dm║${RST}\n" "$rr" "$rg" "$rb"

        line_idx=$(( line_idx + 1 ))
    done

    echo ""

    local _uname _ucmd
    _uname=$(grep "^USERNAME=" "$HOME/.zorkos/user.conf" 2>/dev/null | cut -d= -f2)
    [[ -z "$_uname" ]] && _uname="$name"
    _ucmd=$(grep "^CMD_NAME=" "$HOME/.zorkos/user.conf" 2>/dev/null | cut -d= -f2)
    [[ -z "$_ucmd" ]] && _ucmd="$name"

    local tagline="${_uname}'s Terminal"
    local tag_len=${#tagline}
    local side_len=$(( (deco_width - tag_len - 4) / 2 ))
    [[ $side_len -lt 4 ]] && side_len=4

    local left_hr=""
    local right_hr=""
    for ((oi=0; oi<side_len; oi++)); do left_hr+="─"; done
    for ((oi=0; oi<side_len; oi++)); do right_hr+="─"; done

    local full_tag="${left_hr} ${tagline} ${right_hr}"

    if type gradient_text &>/dev/null; then
        local tag_pad=$(( (cols - ${#full_tag}) / 2 ))
        [[ $tag_pad -lt 0 ]] && tag_pad=0
        printf '%*s' "$tag_pad" ''
        gradient_text "$full_tag" "0,180,255" "0,255,200" "0,255,136" "0,200,255"
        echo
    else
        local tag_pad=$(( (cols - ${#full_tag}) / 2 ))
        [[ $tag_pad -lt 0 ]] && tag_pad=0
        printf '%*s' "$tag_pad" ''
        printf "\033[1;38;2;0;200;255m%s${RST}\n" "$full_tag"
    fi

    local bot_deco=""
    for ((oi=0; oi<deco_width; oi++)); do
        omod=$(( oi % 10 ))
        case $omod in
            0) bot_deco+="«" ;;
            1|2|3|4|5|6|7|8) bot_deco+="═" ;;
            9) bot_deco+="»" ;;
        esac
    done

    if type gradient_text &>/dev/null; then
        printf "  "
        gradient_text "$bot_deco" "0,200,255" "0,255,200" "0,255,136" "0,200,255"
        echo
    else
        printf "\033[38;2;0;200;255m  %s${RST}\n" "$bot_deco"
    fi

    printf "\n"
}

show_name_banner_compact() {
    local name="$1"
    [[ -z "$name" ]] && name="ZORK"
    name=$(echo "$name" | tr '[:lower:]' '[:upper:]')

    local cols
    cols=$(tput cols 2>/dev/null || echo 40)
    local RST="\033[0m"

    local line_w=$(( cols - 4 ))
    [[ $line_w -lt 10 ]] && line_w=10

    local deco=""
    local di
    for ((di=0; di<line_w; di++)); do deco+="─"; done

    printf "\n"
    printf "\033[38;2;120;50;255m  %s${RST}\n" "$deco"
    printf "\n"

    local pad=$(( (cols - ${#name} - 4) / 2 ))
    [[ $pad -lt 0 ]] && pad=0
    printf '%*s' "$pad" ''
    printf "\033[1;38;2;200;0;255m⟨ \033[1;38;2;0;200;255m%s \033[38;2;200;0;255m⟩${RST}\n" "$name"

    printf "\n"

    local _uname
    _uname=$(grep "^USERNAME=" "$HOME/.zorkos/user.conf" 2>/dev/null | cut -d= -f2)
    [[ -z "$_uname" ]] && _uname="$name"

    local tag="${_uname}'s Terminal"
    local tpad=$(( (cols - ${#tag}) / 2 ))
    [[ $tpad -lt 0 ]] && tpad=0
    printf '%*s' "$tpad" ''
    printf "\033[38;2;0;200;255m%s${RST}\n" "$tag"

    printf "\n"
    printf "\033[38;2;0;200;255m  %s${RST}\n" "$deco"
    printf "\n"
}

show_startup_banner() {
    local name="$1"
    [[ -z "$name" ]] && name="ZORK"

    local cols
    cols=$(tput cols 2>/dev/null || echo 80)

    local name_upper
    name_upper=$(echo "$name" | tr '[:lower:]' '[:upper:]')
    local needed=$(( ${#name_upper} * 9 + 6 ))

    if [[ $cols -ge $needed ]] && [[ $cols -ge 45 ]]; then
        show_name_banner "$name"
    else
        show_name_banner_compact "$name"
    fi
}
