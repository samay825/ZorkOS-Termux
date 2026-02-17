#!/bin/bash

POMODORO_DIR="${HOME}/.zorkos/pomodoro"
POMODORO_LOG="${POMODORO_DIR}/sessions.log"
POMODORO_STATE="${POMODORO_DIR}/current.state"

WORK_DURATION=1500    # 25 min
SHORT_BREAK=300       # 5 min
LONG_BREAK=900        # 15 min
POMODOROS_FOR_LONG=4  # Long break every 4 pomodoros

pomodoro_init() {
    mkdir -p "$POMODORO_DIR"
    [[ ! -f "$POMODORO_LOG" ]] && touch "$POMODORO_LOG"
}

_format_time() {
    local seconds=$1
    printf "%02d:%02d" $(( seconds / 60 )) $(( seconds % 60 ))
}

_pomodoro_countdown() {
    local duration=$1
    local label="$2"
    local color_r="$3"
    local color_g="$4"
    local color_b="$5"
    
    local cols rows
    cols=$(tput cols 2>/dev/null || echo 80)
    rows=$(tput lines 2>/dev/null || echo 24)
    local cy=$(( rows / 2 - 3 ))
    local RST="\033[0m"
    
    tput civis 2>/dev/null
    
    local start_time
    start_time=$(date +%s)
    local remaining=$duration
    
    local now elapsed pct time_str lx tx bar_width filled bx i gr gg gb _pname _pbrand
    while [[ $remaining -gt 0 ]]; do
        if [[ -n "$ZSH_VERSION" ]]; then
            read -t 1 -k 1 key 2>/dev/null && [[ "$key" == "q" || "$key" == "Q" ]] && break
        else
            read -t 1 -n 1 key 2>/dev/null && [[ "$key" == "q" || "$key" == "Q" ]] && break
        fi
        
        now=$(date +%s)
        elapsed=$(( now - start_time ))
        remaining=$(( duration - elapsed ))
        [[ $remaining -lt 0 ]] && remaining=0
        
        pct=$(( elapsed * 100 / duration ))
        [[ $pct -gt 100 ]] && pct=100
        
        time_str=$(_format_time $remaining)
        
        clear
        
        lx=$(( (cols - ${#label}) / 2 ))
        printf "\033[%d;%dH\033[1;38;2;%d;%d;%dm%s${RST}" $cy $lx "$color_r" "$color_g" "$color_b" "$label"
        
        tx=$(( (cols - ${#time_str} * 2) / 2 ))
        printf "\033[%d;%dH\033[1;38;2;%d;%d;%dm%s${RST}" $(( cy + 2 )) "$tx" "$color_r" "$color_g" "$color_b" "$time_str"
        
        bar_width=$(( cols - 10 ))
        [[ $bar_width -gt 60 ]] && bar_width=60
        filled=$(( pct * bar_width / 100 ))
        bx=$(( (cols - bar_width - 4) / 2 ))
        
        printf "\033[%d;%dH" $(( cy + 4 )) "$bx"
        printf "\033[38;2;60;60;80m["
        for ((i=0; i<filled; i++)); do
            gr=$(( color_r * i / bar_width ))
            gg=$(( color_g * i / bar_width ))
            gb=$(( color_b * i / bar_width ))
            printf "\033[38;2;%d;%d;%dm█" "$gr" "$gg" "$gb"
        done
        for ((i=filled; i<bar_width; i++)); do
            printf "\033[38;2;30;30;40m░"
        done
        printf "\033[38;2;60;60;80m] \033[38;2;100;100;120m%3d%%${RST}" "$pct"
        
        printf "\033[%d;%dH\033[38;2;60;60;80mPress 'q' to cancel${RST}" $(( cy + 6 )) $(( (cols - 19) / 2 ))
        
        _pname=$(grep "^USERNAME=" "$HOME/.zorkos/user.conf" 2>/dev/null | cut -d= -f2)
        [[ -z "$_pname" ]] && _pname="Zork"
        _pbrand="${_pname}'s Terminal"
        printf "\033[%d;%dH\033[38;2;40;40;60m%s${RST}" $(( rows - 1 )) $(( (cols - ${#_pbrand}) / 2 )) "$_pbrand"
    done
    
    tput cnorm 2>/dev/null
    
    if [[ $remaining -le 0 ]]; then
        termux-notification --sound --title "🍅 ZorkOS Pomodoro" --content "${label} complete!" 2>/dev/null
        printf '\a'
        return 0
    else
        return 1  # Cancelled
    fi
}

pomodoro_start() {
    pomodoro_init
    
    local session=1
    local total_completed=0
    
    if [[ -f "$POMODORO_STATE" ]]; then
        source "$POMODORO_STATE"
    fi
    
    clear
    
    while true; do
        echo -e "\n  \033[38;2;0;255;136m  🍅 Pomodoro #${session} — WORK TIME\033[0m\n"
        sleep 1
        
        if _pomodoro_countdown $WORK_DURATION "🍅 FOCUS TIME — Pomodoro #${session}" 255 60 60; then
            total_completed=$((total_completed + 1))
            
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Pomodoro #${session} completed (${WORK_DURATION}s)" >> "$POMODORO_LOG"
            
            if [[ -f "${HOME}/.zorkos/lib/achievements.sh" ]]; then
                source "${HOME}/.zorkos/lib/achievements.sh" 2>/dev/null
                TOTAL_XP=$(( TOTAL_XP + 25 ))
                _save_stats 2>/dev/null
            fi
            
            clear
            echo -e "\n  \033[38;2;0;255;136m  ✓ Pomodoro #${session} complete! (+25 XP)\033[0m"
            
            if [[ $(( total_completed % POMODOROS_FOR_LONG )) -eq 0 ]]; then
                echo -e "  \033[38;2;0;200;255m  ☕ Long break time (15 min)\033[0m\n"
                sleep 2
                _pomodoro_countdown $LONG_BREAK "☕ LONG BREAK" 0 200 255 || break
            else
                echo -e "  \033[38;2;0;255;200m  ☕ Short break (5 min)\033[0m\n"
                sleep 2
                _pomodoro_countdown $SHORT_BREAK "☕ SHORT BREAK" 0 255 200 || break
            fi
            
            session=$((session + 1))
            
            echo "session=${session}" > "$POMODORO_STATE"
            echo "total_completed=${total_completed}" >> "$POMODORO_STATE"
            
            clear
            echo -e "\n  \033[38;2;255;220;0m  Break over! Ready for next pomodoro?\033[0m"
            echo -ne "  \033[38;2;0;200;255m  Continue? (y/n): \033[0m"
            read -r cont
            [[ "$cont" != "y" && "$cont" != "Y" ]] && break
        else
            break
        fi
    done
    
    clear
    echo -e "\n  \033[38;2;0;255;136m  🍅 Pomodoro Session Summary\033[0m"
    echo -e "  \033[38;2;100;100;120m  Completed: ${total_completed} pomodoros\033[0m"
    echo -e "  \033[38;2;100;100;120m  Total focus: $(( total_completed * WORK_DURATION / 60 )) minutes\033[0m"
    echo ""
    
    rm -f "$POMODORO_STATE"
}

pomodoro_quick() {
    local minutes="${1:-25}"
    local seconds=$(( minutes * 60 ))
    local label="⏱ Timer: ${minutes} min"
    
    _pomodoro_countdown $seconds "$label" 0 200 255
    
    clear
    echo -e "\n  \033[38;2;0;255;136m  ✓ Timer complete!\033[0m\n"
}

pomodoro_stats() {
    local RST="\033[0m"
    echo ""
    echo -e "  \033[38;2;255;60;60m  🍅 Pomodoro Statistics${RST}"
    echo -e "  \033[38;2;60;60;80m  ─────────────────────────${RST}"
    
    if [[ -f "$POMODORO_LOG" ]]; then
        local total
        total=$(wc -l < "$POMODORO_LOG")
        local today
        today=$(grep "$(date '+%Y-%m-%d')" "$POMODORO_LOG" 2>/dev/null | wc -l)
        local week
        week=$(grep "$(date '+%Y-%m')" "$POMODORO_LOG" 2>/dev/null | wc -l)
        
        echo -e "  \033[38;2;100;100;120m  Today:     \033[38;2;0;255;136m${today} pomodoros${RST}"
        echo -e "  \033[38;2;100;100;120m  This month:\033[38;2;0;200;255m${week} pomodoros${RST}"
        echo -e "  \033[38;2;100;100;120m  All time:  \033[38;2;200;100;255m${total} pomodoros${RST}"
        echo -e "  \033[38;2;100;100;120m  Focus time:\033[38;2;255;220;0m$(( total * 25 )) minutes${RST}"
    else
        echo -e "  \033[38;2;100;100;120m  No sessions recorded yet${RST}"
    fi
    echo ""
}

pomodoro_init
