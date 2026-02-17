#!/bin/bash

BANNER_COUNT=11
BANNER_NAMES=(
    "ascii-name"
    "zork-classic"
    "cyber-skull"
    "neon-ghost"
    "shadow-blade"
    "matrix-eye"
    "hex-core"
    "dragon-flame"
    "phantom-glitch"
    "circuit-storm"
    "death-terminal"
)
BANNER_DESCRIPTIONS=(
    "ASCII Name — Your Custom Name"
    "Classic ZorkOS — Original"
    "Cyber Skull — Dark Hacker"
    "Neon Ghost — Spectral Glow"
    "Shadow Blade — Sharp Edge"
    "Matrix Eye — All-Seeing"
    "Hex Core — Digital Core"
    "Dragon Flame — Fire Power"
    "Phantom Glitch — Corrupted"
    "Circuit Storm — Electric"
    "Death Terminal — Reaper"
)

BANNER_GRADIENT_0=("180,0,255" "140,20,255" "100,60,255" "60,120,255" "0,180,255" "0,255,200")
BANNER_GRADIENT_1=("0,255,136" "0,255,200" "0,200,255" "100,100,255" "200,0,255" "255,0,200")
BANNER_GRADIENT_2=("255,0,0" "200,0,50" "150,0,100" "100,0,150" "180,0,80" "255,50,50")
BANNER_GRADIENT_3=("0,255,255" "0,200,255" "100,150,255" "180,100,255" "255,50,255" "255,100,200")
BANNER_GRADIENT_4=("200,200,220" "150,150,180" "100,100,160" "180,0,255" "255,0,200" "255,0,100")
BANNER_GRADIENT_5=("0,255,0" "50,200,0" "100,255,50" "0,200,0" "0,150,0" "50,255,100")
BANNER_GRADIENT_6=("255,100,0" "255,150,0" "255,200,0" "255,255,100" "200,255,0" "150,255,50")
BANNER_GRADIENT_7=("255,0,0" "255,80,0" "255,160,0" "255,200,0" "255,255,0" "255,200,100")
BANNER_GRADIENT_8=("255,0,100" "200,0,200" "100,0,255" "50,50,255" "0,100,200" "100,200,255")
BANNER_GRADIENT_9=("0,100,255" "0,200,255" "0,255,255" "100,255,200" "200,255,100" "255,255,0")
BANNER_GRADIENT_10=("80,0,0" "120,0,0" "180,0,0" "220,0,0" "255,50,0" "255,100,50")

_get_banner_gradient() {
    local idx="${1:-0}"
    case "$idx" in
        0) ACTIVE_BANNER_GRADIENT=("${BANNER_GRADIENT_0[@]}") ;;
        1) ACTIVE_BANNER_GRADIENT=("${BANNER_GRADIENT_1[@]}") ;;
        2) ACTIVE_BANNER_GRADIENT=("${BANNER_GRADIENT_2[@]}") ;;
        3) ACTIVE_BANNER_GRADIENT=("${BANNER_GRADIENT_3[@]}") ;;
        4) ACTIVE_BANNER_GRADIENT=("${BANNER_GRADIENT_4[@]}") ;;
        5) ACTIVE_BANNER_GRADIENT=("${BANNER_GRADIENT_5[@]}") ;;
        6) ACTIVE_BANNER_GRADIENT=("${BANNER_GRADIENT_6[@]}") ;;
        7) ACTIVE_BANNER_GRADIENT=("${BANNER_GRADIENT_7[@]}") ;;
        8) ACTIVE_BANNER_GRADIENT=("${BANNER_GRADIENT_8[@]}") ;;
        9) ACTIVE_BANNER_GRADIENT=("${BANNER_GRADIENT_9[@]}") ;;
        10) ACTIVE_BANNER_GRADIENT=("${BANNER_GRADIENT_10[@]}") ;;
        *) ACTIVE_BANNER_GRADIENT=("${BANNER_GRADIENT_0[@]}") ;;
    esac
}

_banner_ascii_name() {
    local _cmd_name=""
    _cmd_name=$(grep "^CMD_NAME=" "$HOME/.zorkos/user.conf" 2>/dev/null | cut -d= -f2)
    [[ -z "$_cmd_name" ]] && _cmd_name="ZORK"
    _cmd_name=$(echo "$_cmd_name" | tr '[:lower:]' '[:upper:]')

    local size_class
    size_class=$(get_size_class 2>/dev/null || echo "large")

    case "$size_class" in
        small)
            ACTIVE_BANNER_LINES=(
                "⟨ ${_cmd_name} ⟩"
            ) ;;
        medium)
            if type _banner_char &>/dev/null; then
                local _max_chars=5
                [[ ${#_cmd_name} -gt $_max_chars ]] && _cmd_name="${_cmd_name:0:$_max_chars}"
                ACTIVE_BANNER_LINES=()
                local _row _line _ch _i _len=${#_cmd_name}
                for ((_row=0; _row<6; _row++)); do
                    _line=""
                    for ((_i=0; _i<_len; _i++)); do
                        _ch="${_cmd_name:$_i:1}"
                        _line+="$(_banner_char "$_ch" "$_row")"
                    done
                    ACTIVE_BANNER_LINES+=("$_line")
                done
            else
                ACTIVE_BANNER_LINES=(
                    " ▀▀ ${_cmd_name} ▀▀"
                )
            fi ;;
        large|*)
            if type _banner_char &>/dev/null; then
                local cols
                cols=$(tput cols 2>/dev/null || echo 80)
                local _max_chars=$(( cols / 9 ))
                [[ $_max_chars -lt 3 ]] && _max_chars=3
                [[ ${#_cmd_name} -gt $_max_chars ]] && _cmd_name="${_cmd_name:0:$_max_chars}"
                ACTIVE_BANNER_LINES=()
                local _row _line _ch _i _len=${#_cmd_name}
                for ((_row=0; _row<6; _row++)); do
                    _line=""
                    for ((_i=0; _i<_len; _i++)); do
                        _ch="${_cmd_name:$_i:1}"
                        _line+="$(_banner_char "$_ch" "$_row")"
                    done
                    ACTIVE_BANNER_LINES+=("$_line")
                done
            else
                ACTIVE_BANNER_LINES=(
                    "  ███████╗ ██████╗ ██████╗ ██╗  ██╗   ██████╗ ███████╗"
                    "  ╚══███╔╝██╔═══██╗██╔══██╗██║ ██╔╝  ██╔═══██╗██╔════╝"
                    "    ███╔╝ ██║   ██║██████╔╝█████╔╝   ██║   ██║███████╗"
                    "   ███╔╝  ██║   ██║██╔══██╗██╔═██╗   ██║   ██║╚════██║"
                    "  ███████╗╚██████╔╝██║  ██║██║  ╚██╗ ╚██████╔╝███████║"
                    "  ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝   ╚═╝  ╚═════╝╚══════╝"
                )
            fi ;;
    esac
}

_banner_zork_classic() {
    local size_class
    size_class=$(get_size_class 2>/dev/null || echo "large")
    case "$size_class" in
        small)
            ACTIVE_BANNER_LINES=(
                " ▄▄▄ ZORK OS ▄▄▄"
                " ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀"
            ) ;;
        medium)
            ACTIVE_BANNER_LINES=(
                " ▀▀▀▀▀ ▀▀▀▀▀ ▀▀▀▀ ▀  ▀  ▀▀▀▀ ▀▀▀▀"
                "   ▄▀  █   █ █▀▀▄ █▄▀   █  █ ▀▀▀█"
                "  ▄▀   █   █ █▀▀▄ █ █   █  █    █"
                " ▄▄▄▄▄ ▄▄▄▄▄ ▄  ▄ ▄  ▄  ▄▄▄▄ ▄▄▄▄"
            ) ;;
        large|*)
            ACTIVE_BANNER_LINES=(
                "  ███████╗ ██████╗ ██████╗ ██╗  ██╗   ██████╗ ███████╗"
                "  ╚══███╔╝██╔═══██╗██╔══██╗██║ ██╔╝  ██╔═══██╗██╔════╝"
                "    ███╔╝ ██║   ██║██████╔╝█████╔╝   ██║   ██║███████╗"
                "   ███╔╝  ██║   ██║██╔══██╗██╔═██╗   ██║   ██║╚════██║"
                "  ███████╗╚██████╔╝██║  ██║██║  ╚██╗ ╚██████╔╝███████║"
                "  ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝   ╚═╝  ╚═════╝╚══════╝"
            ) ;;
    esac
}

_banner_cyber_skull() {
    local size_class
    size_class=$(get_size_class 2>/dev/null || echo "large")
    case "$size_class" in
        small)
            ACTIVE_BANNER_LINES=(
                "   ☠ ZORK ☠"
                "  ╾━━━━━━━╼"
            ) ;;
        medium)
            ACTIVE_BANNER_LINES=(
                "      ▄▄▄████▄▄▄"
                "    ▄██▀▀    ▀▀██▄"
                "   ██  ◉    ◉  ██"
                "   ██    ▄▄    ██"
                "    ▀█▄ ▀▀▀▀ ▄█▀"
                "      ▀▀████▀▀"
            ) ;;
        large|*)
            ACTIVE_BANNER_LINES=(
                "         ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄"
                "      ▄██▛▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀██▄"
                "    ▄██▀   ╔══╗          ╔══╗   ▀██▄"
                "   ███     ║◉◉║          ║◉◉║     ███"
                "   ███     ╚══╝    ▄▄    ╚══╝     ███"
                "   ▀██▄         ┌──██──┐         ▄██▀"
                "    ▀██▄  ▄▄▄▄▄ │▀▀▀▀▀▀│ ▄▄▄▄▄  ▄██▀"
                "      ▀██▛░░░░░▀└──────┘▀░░░░░▜██▀"
                "        ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀"
                "     ╔═══════╗ Z O R K  O S ╔═══════╗"
                "     ╚═══════╩═══════════════╩═══════╝"
            ) ;;
    esac
}

_banner_neon_ghost() {
    local size_class
    size_class=$(get_size_class 2>/dev/null || echo "large")
    case "$size_class" in
        small)
            ACTIVE_BANNER_LINES=(
                "  👻 ZORK 👻"
                "  ═══════════"
            ) ;;
        medium)
            ACTIVE_BANNER_LINES=(
                "     ▄▄▄▄▄▄▄▄▄"
                "   ▄█░░░░░░░░░█▄"
                "  █░ ◯ ░░░ ◯ ░█"
                "  █░░░ ▀▀▀ ░░░█"
                "  ▀█▄░░░░░░░▄█▀"
                "    ▀▀█▄▄▄█▀▀"
            ) ;;
        large|*)
            ACTIVE_BANNER_LINES=(
                "         ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄"
                "       ▄█░░░░░░░░░░░░░░░░░░░█▄"
                "     ▄█░░░░░░░░░░░░░░░░░░░░░░░█▄"
                "    █░░░ ╭──╮ ░░░░░░░ ╭──╮ ░░░█"
                "    █░░░ │◉◉│ ░░░░░░░ │◉◉│ ░░░█"
                "    █░░░ ╰──╯ ░░▄▄▄░░ ╰──╯ ░░░█"
                "    █░░░░░░░░░ ▀▀▀▀▀ ░░░░░░░░░█"
                "    ▀█░░░░░░░░░░░░░░░░░░░░░░░█▀"
                "      ▀█▄░░░░░░░░░░░░░░░░░▄█▀"
                "    ════╩══ Z O R K  O S ══╩════"
            ) ;;
    esac
}

_banner_shadow_blade() {
    local size_class
    size_class=$(get_size_class 2>/dev/null || echo "large")
    case "$size_class" in
        small)
            ACTIVE_BANNER_LINES=(
                "  ⚔ ZORK ⚔"
                "  ╾━━━━━━━╼"
            ) ;;
        medium)
            ACTIVE_BANNER_LINES=(
                "    ╱╲     ╱╲"
                "   ╱  ╲   ╱  ╲"
                "  ╱ ▓▓ ╲ ╱ ▓▓ ╲"
                "  ╲▓▓▓▓╱ ╲▓▓▓▓╱"
                "   ╲▓▓╱   ╲▓▓╱"
                "    ╲╱ ZORK ╲╱"
            ) ;;
        large|*)
            ACTIVE_BANNER_LINES=(
                "  ═══════════════════════════════════════════════════"
                "  ██╗   ██╗████████╗██╗██╗     ████████╗██████╗ ██╗"
                "  ╚██╗ ██╔╝╚══██╔══╝██║██║     ╚══██╔══╝╚════██╗██║"
                "   ╚████╔╝    ██║   ██║██║        ██║    █████╔╝██║"
                "    ╚██╔╝     ██║   ██║██║        ██║   ██╔═══╝ ╚═╝"
                "     ██║      ██║   ██║███████╗   ██║   ███████╗██╗"
                "     ╚═╝      ╚═╝   ╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝"
                "  ─── ⚔  Z O R K  O S  ──  B E Y O N D  A L L  ⚔ ───"
                "  ═══════════════════════════════════════════════════"
            ) ;;
    esac
}

_banner_matrix_eye() {
    local size_class
    size_class=$(get_size_class 2>/dev/null || echo "large")
    case "$size_class" in
        small)
            ACTIVE_BANNER_LINES=(
                "   ◉ ZORK ◉"
                "  ═══════════"
            ) ;;
        medium)
            ACTIVE_BANNER_LINES=(
                "     ▄▄▄▄▄▄▄▄▄"
                "   ╱▓▓▓▓▓▓▓▓▓▓▓╲"
                "  ╱▓▓▓╱╲ ◉ ╱╲▓▓▓╲"
                "  ╲▓▓▓╲╱   ╲╱▓▓▓╱"
                "   ╲▓▓▓▓▓▓▓▓▓▓▓╱"
                "     ▀▀▀▀▀▀▀▀▀"
            ) ;;
        large|*)
            ACTIVE_BANNER_LINES=(
                "              ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄"
                "          ▄▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄"
                "       ▄▓▓▓▓▓▓▓╱╲▓▓▓▓▓▓▓▓▓╱╲▓▓▓▓▓▓▓▓▓▄"
                "     ▓▓▓▓▓▓▓▓╱   ╲▓▓ ◉◉◉ ▓╱   ╲▓▓▓▓▓▓▓▓"
                "     ▓▓▓▓▓▓▓▓╲   ╱▓▓▓▓▓▓▓▓╲   ╱▓▓▓▓▓▓▓▓"
                "       ▀▓▓▓▓▓▓▓╲╱▓▓▓▓▓▓▓▓▓▓▓╲╱▓▓▓▓▓▓▓▀"
                "          ▀▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▀"
                "              ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀"
                "        ╔════ Z O R K  ─  M A T R I X ════╗"
                "        ╚═════════════════════════════════╝"
            ) ;;
    esac
}

_banner_hex_core() {
    local size_class
    size_class=$(get_size_class 2>/dev/null || echo "large")
    case "$size_class" in
        small)
            ACTIVE_BANNER_LINES=(
                "  ⬡ ZORK ⬡"
                "  ═══════════"
            ) ;;
        medium)
            ACTIVE_BANNER_LINES=(
                "     ╱╲   ╱╲   ╱╲"
                "    ╱  ╲ ╱  ╲ ╱  ╲"
                "   │ ⬡  │ ⬡  │ ⬡  │"
                "    ╲  ╱ ╲  ╱ ╲  ╱"
                "     ╲╱   ╲╱   ╲╱"
                "     Z O R K  O S"
            ) ;;
        large|*)
            ACTIVE_BANNER_LINES=(
                "       ╱╲     ╱╲     ╱╲     ╱╲     ╱╲"
                "      ╱  ╲   ╱  ╲   ╱  ╲   ╱  ╲   ╱  ╲"
                "     ╱ ⬡  ╲ ╱ ⬡  ╲ ╱ ⬡  ╲ ╱ ⬡  ╲ ╱ ⬡  ╲"
                "    │ 5A  │ │ 4F  │ │ 52  │ │ 4B  │ │ 21  │"
                "     ╲    ╱ ╲    ╱ ╲    ╱ ╲    ╱ ╲    ╱"
                "      ╲  ╱   ╲  ╱   ╲  ╱   ╲  ╱   ╲  ╱"
                "       ╲╱     ╲╱     ╲╱     ╲╱     ╲╱"
                "    ═══════════════════════════════════════"
                "     ⬡ Z O R K  O S  ─  H E X  C O R E ⬡"
                "    ═══════════════════════════════════════"
            ) ;;
    esac
}

_banner_dragon_flame() {
    local size_class
    size_class=$(get_size_class 2>/dev/null || echo "large")
    case "$size_class" in
        small)
            ACTIVE_BANNER_LINES=(
                "  🐉 ZORK 🐉"
                "  ═══════════"
            ) ;;
        medium)
            ACTIVE_BANNER_LINES=(
                "       ▄▄▄"
                "     ▄█▓▓▓█▄  ╱╱"
                "    █▓◉▓▓▓▓█╱╱"
                "    █▓▓▓▓▄▄█▓▓╲"
                "     ▀█▓▓▓▓▓▓█▀"
                "       ▀▀▀▀▀"
            ) ;;
        large|*)
            ACTIVE_BANNER_LINES=(
                "               ▄▄▄▄▄▄"
                "             ▄█▓▓▓▓▓▓█▄      ╱╱╱"
                "           ▄█▓▓▓▓▓▓▓▓▓▓█▄  ╱╱╱"
                "          █▓▓◉▓▓▓▓▓▓▓▓▓▓▓█╱╱╱"
                "          █▓▓▓▓▓▓▓▓▄▄▄▄▄▓▓▓▓▓╲╲"
                "          █▓▓▓▓▓▓▓█▀▀▀▀▀█▓▓▓▓▓╲╲╲"
                "           ▀█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█▀"
                "             ▀█▓▓▓▓▓▓▓▓▓▓▓█▀"
                "               ▀▀▀▀▀▀▀▀▀▀▀"
                "     ──── 🐉 Z O R K  O S  ─  D R A G O N 🐉 ────"
            ) ;;
    esac
}

_banner_phantom_glitch() {
    local size_class
    size_class=$(get_size_class 2>/dev/null || echo "large")
    case "$size_class" in
        small)
            ACTIVE_BANNER_LINES=(
                "  ░▒▓ ZORK ▓▒░"
                "  ▓▒░░░░░░░▒▓"
            ) ;;
        medium)
            ACTIVE_BANNER_LINES=(
                "  ░▒▓██▓▒░░▒▓██▓▒░"
                "  █▓ Z░O░R░K ▓█"
                "  ░▒▓█O█▓▒░▒▓█S█▓▒░"
                "  ▓▒░▒▓█████▓▒░▒▓"
                "  ░▒▓GLITCH▓▒░░▒▓░"
                "  ▓▒░░░░░░░░░░░░▒▓"
            ) ;;
        large|*)
            ACTIVE_BANNER_LINES=(
                "  ░▒▓████████████████████████████████████████▓▒░"
                "  █▓▒░                                    ░▒▓█"
                "  █▓  ▄▄▄█ ▄▄▄█ ▄▄▄▄  ▄▄▄  ▄▄▄█         ▓█"
                "  █░  ▄▀   █  █ █▀▀▄  █▀▄  █  █  ░█▓▒    ░█"
                "  █▒  █▄▄  █▄▄█ █  █  █▄▀  █▄▄█  ▒▓█░    ▒█"
                "  █░  ░▒▓█████████████████████▓▒░  ░▒▓    ░█"
                "  █   ▓▒░ G L I T C H  M O D E ░▒▓       █"
                "  █▓▒░                                    ░▒▓█"
                "  ░▒▓████████████████████████████████████████▓▒░"
            ) ;;
    esac
}

_banner_circuit_storm() {
    local size_class
    size_class=$(get_size_class 2>/dev/null || echo "large")
    case "$size_class" in
        small)
            ACTIVE_BANNER_LINES=(
                "  ⚡ZORK⚡"
                "  ═══════════"
            ) ;;
        medium)
            ACTIVE_BANNER_LINES=(
                "  ┌──┬──┬──┬──┐"
                "  │⚡│░░│⚡│░░│"
                "  ├──┼──┼──┼──┤"
                "  │ ZORK  OS  │"
                "  ├──┼──┼──┼──┤"
                "  └──┴──┴──┴──┘"
            ) ;;
        large|*)
            ACTIVE_BANNER_LINES=(
                "  ┌────┬────┬────┬────┬────┬────┬────┬────┐"
                "  │ ░░ │ ▓▓ │ ░░ │ ⚡ │ ⚡ │ ░░ │ ▓▓ │ ░░ │"
                "  ├────┼────┼────┼────┼────┼────┼────┼────┤"
                "  │ ▓▓ │ ░░ │ ▓▓ │ ░░ │ ░░ │ ▓▓ │ ░░ │ ▓▓ │"
                "  ├════╪════╪════╪════╪════╪════╪════╪════┤"
                "  │    ⚡ Z O R K  O S — C I R C U I T ⚡    │"
                "  ├════╪════╪════╪════╪════╪════╪════╪════┤"
                "  │ ░░ │ ▓▓ │ ░░ │ ▓▓ │ ▓▓ │ ░░ │ ▓▓ │ ░░ │"
                "  ├────┼────┼────┼────┼────┼────┼────┼────┤"
                "  │ ▓▓ │ ░░ │ ▓▓ │ ░░ │ ░░ │ ▓▓ │ ░░ │ ▓▓ │"
                "  └────┴────┴────┴────┴────┴────┴────┴────┘"
            ) ;;
    esac
}

_banner_death_terminal() {
    local size_class
    size_class=$(get_size_class 2>/dev/null || echo "large")
    case "$size_class" in
        small)
            ACTIVE_BANNER_LINES=(
                "  💀 ZORK 💀"
                "  ═══════════"
            ) ;;
        medium)
            ACTIVE_BANNER_LINES=(
                "     ▄▄█████▄▄"
                "   ▄██▀     ▀██▄"
                "  ██ ▄▀▄   ▄▀▄ ██"
                "  ██  ▄▄▄▄▄▄▄  ██"
                "   ▀██ ▀▀▀▀▀ ██▀"
                "     ▀▀█████▀▀"
            ) ;;
        large|*)
            ACTIVE_BANNER_LINES=(
                "           ▄▄▄██████████▄▄▄"
                "        ▄██▀▀▀          ▀▀▀██▄"
                "      ▄██▀                  ▀██▄"
                "     ██▌  ▄▀█▀▄      ▄▀█▀▄  ▐██"
                "     ██▌  ▀▄█▄▀      ▀▄█▄▀  ▐██"
                "     ██▌        ████        ▐██"
                "      ██▄   ▀▀▀▀▀▀▀▀▀▀   ▄██"
                "       ▀██▄  ╔═══════╗  ▄██▀"
                "         ▀██▄╚═══════╝▄██▀"
                "           ▀▀▀████████▀▀▀"
                "     ──── 💀 D E A T H  T E R M I N A L 💀 ────"
            ) ;;
    esac
}

get_active_banner() {
    local style="${1:-ascii-name}"
    
    case "$style" in
        ascii-name|0)      _banner_ascii_name ;;
        zork-classic|1)    _banner_zork_classic ;;
        cyber-skull|2)     _banner_cyber_skull ;;
        neon-ghost|3)      _banner_neon_ghost ;;
        shadow-blade|4)    _banner_shadow_blade ;;
        matrix-eye|5)      _banner_matrix_eye ;;
        hex-core|6)        _banner_hex_core ;;
        dragon-flame|7)    _banner_dragon_flame ;;
        phantom-glitch|8)  _banner_phantom_glitch ;;
        circuit-storm|9)   _banner_circuit_storm ;;
        death-terminal|10) _banner_death_terminal ;;
        *)                 _banner_ascii_name ;;
    esac
}

_banner_name_to_index() {
    local name="$1"
    case "$name" in
        ascii-name)      echo 0 ;;
        zork-classic)    echo 1 ;;
        cyber-skull)     echo 2 ;;
        neon-ghost)      echo 3 ;;
        shadow-blade)    echo 4 ;;
        matrix-eye)      echo 5 ;;
        hex-core)        echo 6 ;;
        dragon-flame)    echo 7 ;;
        phantom-glitch)  echo 8 ;;
        circuit-storm)   echo 9 ;;
        death-terminal)  echo 10 ;;
        *)               echo 0 ;;
    esac
}

BORDER_STYLE_COUNT=6
BORDER_STYLE_NAMES=(
    "cyber-box"
    "double-line"
    "rounded"
    "heavy-block"
    "matrix-dots"
    "neon-pipe"
)
BORDER_STYLE_DESCRIPTIONS=(
    "Cyber Box — ╔═══╗ Hacker Frame"
    "Double Line — ╠═══╣ Classic"
    "Rounded — ╭───╮ Smooth Edges"
    "Heavy Block — ┏━━━┓ Bold"
    "Matrix Dots — ·····  Dotted Grid"
    "Neon Pipe — ┃───┃ Glowing Pipe"
)

_get_border_chars() {
    local style="${1:-cyber-box}"
    case "$style" in
        cyber-box|0)
            B_TL="╔" B_TR="╗" B_BL="╚" B_BR="╝" B_H="═" B_V="║"
            B_TM="╦" B_BM="╩" B_LM="╠" B_RM="╣"
            ;;
        double-line|1)
            B_TL="╔" B_TR="╗" B_BL="╚" B_BR="╝" B_H="═" B_V="║"
            B_TM="═" B_BM="═" B_LM="╠" B_RM="╣"
            ;;
        rounded|2)
            B_TL="╭" B_TR="╮" B_BL="╰" B_BR="╯" B_H="─" B_V="│"
            B_TM="─" B_BM="─" B_LM="├" B_RM="┤"
            ;;
        heavy-block|3)
            B_TL="┏" B_TR="┓" B_BL="┗" B_BR="┛" B_H="━" B_V="┃"
            B_TM="━" B_BM="━" B_LM="┣" B_RM="┫"
            ;;
        matrix-dots|4)
            B_TL="·" B_TR="·" B_BL="·" B_BR="·" B_H="·" B_V="·"
            B_TM="·" B_BM="·" B_LM="·" B_RM="·"
            ;;
        neon-pipe|5)
            B_TL="┌" B_TR="┐" B_BL="└" B_BR="┘" B_H="─" B_V="┃"
            B_TM="─" B_BM="─" B_LM="┠" B_RM="┨"
            ;;
        *)
            B_TL="╔" B_TR="╗" B_BL="╚" B_BR="╝" B_H="═" B_V="║"
            B_TM="═" B_BM="═" B_LM="╠" B_RM="╣"
            ;;
    esac
}

render_banner_display() {
    local banner_name="${1:-${CURRENT_BANNER:-ascii-name}}"
    local show_border="${2:-${BANNER_BORDER_ENABLED:-true}}"
    local border_style="${3:-${BANNER_BORDER_STYLE:-cyber-box}}"
    local show_tagline="${4:-true}"

    local RST="\033[0m"
    local cols
    cols=$(tput cols 2>/dev/null || echo 80)

    local idx
    idx=$(_banner_name_to_index "$banner_name" 2>/dev/null || echo 0)
    _get_banner_gradient "$idx" 2>/dev/null
    get_active_banner "$banner_name"

    local max_w=0 line_w bline
    for bline in "${ACTIVE_BANNER_LINES[@]}"; do
        line_w=${#bline}
        [[ $line_w -gt $max_w ]] && max_w=$line_w
    done

    local _uname _tagline
    _uname=$(grep "^USERNAME=" "$HOME/.zorkos/user.conf" 2>/dev/null | cut -d= -f2)
    [[ -z "$_uname" ]] && _uname="Zork"
    _tagline="${_uname}'s Terminal — Beyond All Limits"
    local tag_len=${#_tagline}

    local content_w=$max_w
    [[ $tag_len -gt $content_w ]] && content_w=$tag_len

    echo ""

    if [[ "$show_border" == "true" ]]; then
        _get_border_chars "$border_style"

        local inner_w=$(( content_w + 4 ))
        local total_w=$(( inner_w + 2 ))
        if [[ $total_w -gt $(( cols - 2 )) ]]; then
            total_w=$(( cols - 2 ))
            [[ $total_w -lt 6 ]] && total_w=6
            inner_w=$(( total_w - 2 ))
        fi

        local left_margin=$(( (cols - total_w) / 2 ))
        [[ $left_margin -lt 0 ]] && left_margin=0
        local pad_l
        pad_l=$(printf '%*s' "$left_margin" '')

        _rbd_hline() {
            local _lc="$1" _rc="$2" _hi
            local _row_str="${_lc}"
            for ((_hi=0; _hi<inner_w; _hi++)); do _row_str+="${B_H}"; done
            _row_str+="${_rc}"
            if type gradient_text &>/dev/null && [[ ${#ACTIVE_BANNER_GRADIENT[@]} -gt 0 ]]; then
                printf "%s" "$pad_l"
                gradient_text "$_row_str" "${ACTIVE_BANNER_GRADIENT[@]}" 2>/dev/null
                echo
            else
                printf "%s\033[38;2;60;60;100m%s${RST}\n" "$pad_l" "$_row_str"
            fi
        }

        _rbd_content_row() {
            local _text="$1"
            local _tw=${#_text}

            if [[ $_tw -gt $inner_w ]]; then
                _text="${_text:0:$inner_w}"
                _tw=$inner_w
            fi

            local _pl=$(( (inner_w - _tw) / 2 ))
            local _pr=$(( inner_w - _pl - _tw ))

            local _row_str="${B_V}"
            local _si
            for ((_si=0; _si<_pl; _si++)); do _row_str+=" "; done
            _row_str+="${_text}"
            for ((_si=0; _si<_pr; _si++)); do _row_str+=" "; done
            _row_str+="${B_V}"

            if type gradient_text &>/dev/null && [[ ${#ACTIVE_BANNER_GRADIENT[@]} -gt 0 ]]; then
                printf "%s" "$pad_l"
                gradient_text "$_row_str" "${ACTIVE_BANNER_GRADIENT[@]}" 2>/dev/null
                echo
            else
                printf "%s\033[38;2;60;60;100m${B_V}${RST}" "$pad_l"
                printf '%*s' "$_pl" ''
                printf "\033[38;2;0;255;136m%s${RST}" "$_text"
                printf '%*s' "$_pr" ''
                printf "\033[38;2;60;60;100m${B_V}${RST}\n"
            fi
        }

        _rbd_empty_row() {
            local _row_str="${B_V}"
            local _si
            for ((_si=0; _si<inner_w; _si++)); do _row_str+=" "; done
            _row_str+="${B_V}"

            if type gradient_text &>/dev/null && [[ ${#ACTIVE_BANNER_GRADIENT[@]} -gt 0 ]]; then
                printf "%s" "$pad_l"
                gradient_text "$_row_str" "${ACTIVE_BANNER_GRADIENT[@]}" 2>/dev/null
                echo
            else
                printf "%s\033[38;2;60;60;100m${B_V}%*s${B_V}${RST}\n" "$pad_l" "$inner_w" ''
            fi
        }

        _rbd_hline "$B_TL" "$B_TR"

        _rbd_empty_row

        for bline in "${ACTIVE_BANNER_LINES[@]}"; do
            _rbd_content_row "$bline"
        done

        if [[ "$show_tagline" == "true" ]]; then
            _rbd_hline "$B_LM" "$B_RM"

            _rbd_content_row "$_tagline"
        fi

        _rbd_empty_row

        _rbd_hline "$B_BL" "$B_BR"

        unset -f _rbd_hline _rbd_content_row _rbd_empty_row

    else
        for bline in "${ACTIVE_BANNER_LINES[@]}"; do
            line_w=${#bline}
            local cx=$(( (cols - line_w) / 2 ))
            [[ $cx -lt 0 ]] && cx=0

            if type gradient_text &>/dev/null && [[ ${#ACTIVE_BANNER_GRADIENT[@]} -gt 0 ]]; then
                printf '%*s' "$cx" ''
                gradient_text "$bline" "${ACTIVE_BANNER_GRADIENT[@]}" 2>/dev/null
                echo
            else
                printf '%*s' "$cx" ''
                printf "\033[38;2;0;255;136m%s${RST}\n" "$bline"
            fi
        done

        if [[ "$show_tagline" == "true" ]]; then
            echo ""
            local tx=$(( (cols - tag_len) / 2 ))
            [[ $tx -lt 0 ]] && tx=0

            if type gradient_text &>/dev/null && [[ ${#ACTIVE_BANNER_GRADIENT[@]} -gt 0 ]]; then
                printf '%*s' "$tx" ''
                gradient_text "$_tagline" "${ACTIVE_BANNER_GRADIENT[@]}" 2>/dev/null
                echo
            else
                printf '%*s' "$tx" ''
                printf "\033[38;2;0;200;255m%s${RST}\n" "$_tagline"
            fi
        fi
    fi

    echo ""
}

preview_border_style() {
    local style="${1:-cyber-box}"
    local RST="\033[0m"
    local cols
    cols=$(tput cols 2>/dev/null || echo 80)

    _get_border_chars "$style"

    local demo_lines=("  SAMPLE BANNER  " "  ═════════════  ")
    local inner_w=25
    local total_w=$(( inner_w + 2 ))
    local left_margin=$(( (cols - total_w) / 2 ))
    [[ $left_margin -lt 0 ]] && left_margin=0
    local pad_l
    pad_l=$(printf '%*s' "$left_margin" '')

    local top_line="${B_TL}"
    local hi
    for ((hi=0; hi<inner_w; hi++)); do top_line+="${B_H}"; done
    top_line+="${B_TR}"
    printf "%s\033[38;2;0;200;255m%s${RST}\n" "$pad_l" "$top_line"

    for dline in "${demo_lines[@]}"; do
        local dw=${#dline}
        local dp_left=$(( (inner_w - dw) / 2 ))
        [[ $dp_left -lt 0 ]] && dp_left=0
        local dp_right=$(( inner_w - dp_left - dw ))
        [[ $dp_right -lt 0 ]] && dp_right=0
        printf "%s\033[38;2;0;200;255m${B_V}${RST}" "$pad_l"
        printf '%*s' "$dp_left" ''
        printf "\033[38;2;0;255;136m%s${RST}" "$dline"
        printf '%*s' "$dp_right" ''
        printf "\033[38;2;0;200;255m${B_V}${RST}\n"
    done

    local bot_line="${B_BL}"
    for ((hi=0; hi<inner_w; hi++)); do bot_line+="${B_H}"; done
    bot_line+="${B_BR}"
    printf "%s\033[38;2;0;200;255m%s${RST}\n" "$pad_l" "$bot_line"
}

preview_all_banners() {
    local RST="\033[0m"
    local cols
    cols=$(tput cols 2>/dev/null || echo 80)
    local i=0
    for bname in "${BANNER_NAMES[@]}"; do
        echo ""
        local title
        title=$(printf "[%02d] %s — %s" "$i" "$bname" "${BANNER_DESCRIPTIONS[$i]}")
        local tx=$(( (cols - ${#title}) / 2 ))
        [[ $tx -lt 0 ]] && tx=0
        printf '%*s' "$tx" ''
        printf "\033[1;38;2;255;220;0m%s${RST}\n" "$title"
        
        render_banner_display "$bname" "${BANNER_BORDER_ENABLED:-true}" "${BANNER_BORDER_STYLE:-cyber-box}" "false"
        
        printf "  \033[38;2;40;40;60m%s\033[0m\n" "$(printf '─%.0s' $(seq 1 50))"
        
        i=$((i + 1))
    done
}

preview_banner() {
    local style="${1:-ascii-name}"
    render_banner_display "$style" "${BANNER_BORDER_ENABLED:-true}" "${BANNER_BORDER_STYLE:-cyber-box}" "true"
}
