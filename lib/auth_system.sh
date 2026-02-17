#!/bin/bash

ZORKOS_AUTH_DIR="${HOME}/.zorkos/auth"
ZORKOS_AUTH_DB="${ZORKOS_AUTH_DIR}/users.db"
ZORKOS_SESSION="${ZORKOS_AUTH_DIR}/session"
ZORKOS_AUTH_LOG="${ZORKOS_AUTH_DIR}/auth.log"
ZORKOS_AUTH_CONF="${ZORKOS_AUTH_DIR}/auth.conf"
MAX_LOGIN_ATTEMPTS=5
LOCKOUT_SECONDS=300
IDLE_LOCK_SECONDS=600  # 10 min idle = auto-lock

auth_init() {
    mkdir -p "$ZORKOS_AUTH_DIR"
    touch "$ZORKOS_AUTH_LOG"
    
    if [[ ! -f "$ZORKOS_AUTH_CONF" ]]; then
        cat > "$ZORKOS_AUTH_CONF" << 'AUTHCONF'
AUTH_ENABLED=false
IDLE_LOCK=false
IDLE_LOCK_SECONDS=600
MAX_ATTEMPTS=5
LOCKOUT_SECONDS=300
LOGIN_BANNER=true
BIOMETRIC_FALLBACK=false
AUTHCONF
    fi
    source "$ZORKOS_AUTH_CONF" 2>/dev/null
}

_hash_password() {
    local password="$1"
    local salt="$2"
    echo -n "${salt}:${password}" | sha256sum | cut -d' ' -f1
}

_gen_salt() {
    head -c 16 /dev/urandom 2>/dev/null | xxd -p 2>/dev/null || \
    cat /proc/sys/kernel/random/uuid 2>/dev/null | tr -d '-' | head -c 32 || \
    date +%s%N | sha256sum | head -c 32
}

_auth_log() {
    local event="$1"
    local user="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ${event} | user=${user}" >> "$ZORKOS_AUTH_LOG"
}

auth_create_user() {
    local username="$1"
    local password="$2"
    local role="${3:-user}"  # user or admin
    
    auth_init
    
    if [[ -f "$ZORKOS_AUTH_DB" ]] && grep -q "^${username}:" "$ZORKOS_AUTH_DB" 2>/dev/null; then
        echo -e "  \033[38;2;255;60;60m✗ User '${username}' already exists${RST}"
        return 1
    fi
    
    local salt
    salt=$(_gen_salt)
    local hash
    hash=$(_hash_password "$password" "$salt")
    local created
    created=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "${username}:${salt}:${hash}:${role}:${created}:never:0:0" >> "$ZORKOS_AUTH_DB"
    
    _auth_log "USER_CREATED" "$username"
    echo -e "  \033[38;2;0;255;136m✓ User '${username}' created (${role})${RST}"
    return 0
}

auth_verify() {
    local username="$1"
    local password="$2"
    
    [[ ! -f "$ZORKOS_AUTH_DB" ]] && return 1
    
    local user_line
    user_line=$(grep "^${username}:" "$ZORKOS_AUTH_DB" 2>/dev/null)
    [[ -z "$user_line" ]] && return 1
    
    local salt hash stored_hash
    salt=$(echo "$user_line" | cut -d':' -f2)
    stored_hash=$(echo "$user_line" | cut -d':' -f3)
    hash=$(_hash_password "$password" "$salt")
    
    [[ "$hash" == "$stored_hash" ]] && return 0 || return 1
}

_check_lockout() {
    local username="$1"
    local lockfile="${ZORKOS_AUTH_DIR}/.lockout_${username}"
    
    if [[ -f "$lockfile" ]]; then
        local lock_time
        lock_time=$(cat "$lockfile")
        local now
        now=$(date +%s)
        local elapsed=$(( now - lock_time ))
        
        if [[ $elapsed -lt $LOCKOUT_SECONDS ]]; then
            local remaining=$(( LOCKOUT_SECONDS - elapsed ))
            echo -e "  \033[38;2;255;60;60m✗ Account locked. Try again in ${remaining}s\033[0m"
            return 1
        else
            rm -f "$lockfile"
            rm -f "${ZORKOS_AUTH_DIR}/.attempts_${username}"
        fi
    fi
    return 0
}

_record_fail() {
    local username="$1"
    local attempts_file="${ZORKOS_AUTH_DIR}/.attempts_${username}"
    local count=0
    
    [[ -f "$attempts_file" ]] && count=$(cat "$attempts_file")
    count=$((count + 1))
    echo "$count" > "$attempts_file"
    
    if [[ $count -ge $MAX_LOGIN_ATTEMPTS ]]; then
        date +%s > "${ZORKOS_AUTH_DIR}/.lockout_${username}"
        _auth_log "ACCOUNT_LOCKED" "$username"
        echo -e "  \033[38;2;255;60;60m⚠ Account locked for ${LOCKOUT_SECONDS}s after ${MAX_LOGIN_ATTEMPTS} failed attempts\033[0m"
    fi
    
    return $count
}

_create_session() {
    local username="$1"
    local session_id
    session_id=$(_gen_salt)
    
    cat > "$ZORKOS_SESSION" << EOF
SESSION_USER=${username}
SESSION_ID=${session_id}
SESSION_START=$(date +%s)
SESSION_LAST_ACTIVE=$(date +%s)
EOF
    
    if [[ -f "$ZORKOS_AUTH_DB" ]]; then
        local now
        now=$(date '+%Y-%m-%d %H:%M:%S')
        local old_line new_line
        old_line=$(grep "^${username}:" "$ZORKOS_AUTH_DB")
        local login_count
        login_count=$(echo "$old_line" | cut -d':' -f7)
        login_count=$(( login_count + 1 ))
        local xp
        xp=$(echo "$old_line" | cut -d':' -f8)
        xp=$(( xp + 10 ))  # +10 XP per login
        
        new_line=$(echo "$old_line" | awk -F: -v now="$now" -v lc="$login_count" -v xp="$xp" \
            '{OFS=":"; $6=now; $7=lc; $8=xp; print}')
        sed -i "s|^${username}:.*|${new_line}|" "$ZORKOS_AUTH_DB"
    fi
    
    rm -f "${ZORKOS_AUTH_DIR}/.attempts_${username}"
    
    _auth_log "LOGIN_SUCCESS" "$username"
    export ZORKOS_USER="$username"
}

auth_logout() {
    if [[ -f "$ZORKOS_SESSION" ]]; then
        source "$ZORKOS_SESSION"
        _auth_log "LOGOUT" "$SESSION_USER"
        rm -f "$ZORKOS_SESSION"
    fi
    unset ZORKOS_USER
}

auth_check_session() {
    if [[ -f "$ZORKOS_SESSION" ]]; then
        source "$ZORKOS_SESSION"
        
        if [[ "$IDLE_LOCK" == "true" ]]; then
            local now
            now=$(date +%s)
            local idle=$(( now - SESSION_LAST_ACTIVE ))
            if [[ $idle -gt $IDLE_LOCK_SECONDS ]]; then
                _auth_log "IDLE_LOCK" "$SESSION_USER"
                rm -f "$ZORKOS_SESSION"
                return 1
            fi
        fi
        
        export ZORKOS_USER="$SESSION_USER"
        return 0
    fi
    return 1
}

auth_touch_session() {
    if [[ -f "$ZORKOS_SESSION" ]]; then
        sed -i "s/^SESSION_LAST_ACTIVE=.*/SESSION_LAST_ACTIVE=$(date +%s)/" "$ZORKOS_SESSION"
    fi
}

auth_get_xp() {
    local username="${1:-$ZORKOS_USER}"
    [[ ! -f "$ZORKOS_AUTH_DB" ]] && echo 0 && return
    local xp
    xp=$(grep "^${username}:" "$ZORKOS_AUTH_DB" | cut -d':' -f8)
    echo "${xp:-0}"
}

auth_add_xp() {
    local username="${1:-$ZORKOS_USER}"
    local amount="${2:-1}"
    
    [[ ! -f "$ZORKOS_AUTH_DB" ]] && return
    [[ -z "$username" ]] && return
    
    local old_line
    old_line=$(grep "^${username}:" "$ZORKOS_AUTH_DB")
    [[ -z "$old_line" ]] && return
    
    local old_xp
    old_xp=$(echo "$old_line" | cut -d':' -f8)
    local new_xp=$(( old_xp + amount ))
    
    local new_line
    new_line=$(echo "$old_line" | awk -F: -v xp="$new_xp" '{OFS=":"; $8=xp; print}')
    sed -i "s|^${username}:.*|${new_line}|" "$ZORKOS_AUTH_DB"
}

auth_get_level() {
    local xp
    xp=$(auth_get_xp "$1")
    
    if [[ $xp -ge 10000 ]]; then echo "LEGENDARY"
    elif [[ $xp -ge 5000 ]]; then echo "MASTER"
    elif [[ $xp -ge 2000 ]]; then echo "EXPERT"
    elif [[ $xp -ge 1000 ]]; then echo "ADVANCED"
    elif [[ $xp -ge 500 ]]; then echo "INTERMEDIATE"
    elif [[ $xp -ge 100 ]]; then echo "BEGINNER"
    else echo "NOOB"
    fi
}

auth_get_level_color() {
    local level
    level=$(auth_get_level "$1")
    case "$level" in
        LEGENDARY)    echo "255;215;0" ;;
        MASTER)       echo "255;0;200" ;;
        EXPERT)       echo "200;100;255" ;;
        ADVANCED)     echo "0;200;255" ;;
        INTERMEDIATE) echo "0;255;136" ;;
        BEGINNER)     echo "255;220;0" ;;
        *)            echo "100;100;120" ;;
    esac
}


_auth_matrix_rain() {
    local rows cols i r c intensity g char
    rows=$(tput lines 2>/dev/null || echo 24)
    cols=$(tput cols 2>/dev/null || echo 80)
    local char_pool="01ZORKzork.:;|/\\"
    
    for ((i=0; i<100; i++)); do
        r=$(( RANDOM % rows + 1 ))
        c=$(( RANDOM % cols + 1 ))
        intensity=$(( RANDOM % 4 ))
        char="${char_pool:$(( RANDOM % ${#char_pool} )):1}"
        case $intensity in
            0) printf "\033[%d;%dH\033[38;2;0;22;0m%s" "$r" "$c" "$char" ;;
            1) printf "\033[%d;%dH\033[38;2;0;50;6m%s" "$r" "$c" "$char" ;;
            2) printf "\033[%d;%dH\033[38;2;0;85;12m%s" "$r" "$c" "$char" ;;
            3) printf "\033[%d;%dH\033[38;2;0;130;25m%s" "$r" "$c" "$char" ;;
        esac
    done
}

_auth_matrix_drip() {
    local rows cols num_drops i c len j g char r_pos
    rows=$(tput lines 2>/dev/null || echo 24)
    cols=$(tput cols 2>/dev/null || echo 80)
    local char_pool="012345789ZORK|.:;"
    num_drops=$(( cols / 4 ))
    [[ $num_drops -gt 18 ]] && num_drops=18
    
    for ((i=0; i<num_drops; i++)); do
        c=$(( RANDOM % cols + 1 ))
        len=$(( RANDOM % (rows / 2) + 3 ))
        for ((j=0; j<len; j++)); do
            r_pos=$(( j + 1 ))
            [[ $r_pos -gt $rows ]] && break
            char="${char_pool:$(( RANDOM % ${#char_pool} )):1}"
            if [[ $j -eq $(( len - 1 )) ]]; then
                printf "\033[%d;%dH\033[1;38;2;170;255;170m%s" "$r_pos" "$c" "$char"
            else
                g=$(( 12 + j * 30 / len ))
                printf "\033[%d;%dH\033[38;2;0;%d;0m%s" "$r_pos" "$c" "$g" "$char"
            fi
        done
        sleep 0.006
    done
}

_auth_scan_lines() {
    local rows cols i sg
    rows=$(tput lines 2>/dev/null || echo 24)
    cols=$(tput cols 2>/dev/null || echo 80)
    
    for ((i=1; i<=rows; i++)); do
        if (( i % 2 == 0 )); then
            sg=$(( 2 + RANDOM % 5 ))
            printf "\033[%d;1H\033[48;2;%d;%d;%dm%*s\033[0m" "$i" "$sg" "$sg" $(( sg + 3 )) "$cols" ""
        fi
    done
}

_auth_spinner() {
    local msg="$1" duration="${2:-1.5}" row="$3" col="$4"
    local -a frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local -a colors=(
        "255;0;100" "255;0;180" "200;0;255" "140;0;255"
        "80;0;255" "0;80;255" "0;180;255" "0;255;220"
        "0;255;140" "100;255;0"
    )
    local total_iters=15
    local i f_idx c_idx
    for ((i=0; i<total_iters; i++)); do
        f_idx=$(( i % ${#frames[@]} ))
        c_idx=$(( i % ${#colors[@]} ))
        printf "\033[%d;%dH\033[1;38;2;%sm%s \033[38;2;170;170;190m%s    " "$row" "$col" "${colors[$c_idx]}" "${frames[$f_idx]}" "$msg"
        sleep 0.065
    done
}

_auth_progress_bar() {
    local msg="$1" row="$2" col="$3" width="${4:-26}"
    local i j pct jr jg jb r g b
    for ((i=0; i<=width; i++)); do
        pct=$(( i * 100 / width ))
        if [[ $pct -lt 25 ]]; then
            r=255; g=$(( pct * 4 )); b=0
        elif [[ $pct -lt 50 ]]; then
            r=$(( 255 - (pct-25)*6 )); g=255; b=0
        elif [[ $pct -lt 75 ]]; then
            r=0; g=255; b=$(( (pct-50)*10 ))
        else
            r=0; g=$(( 255 - (pct-75)*2 )); b=255
        fi
        
        printf "\033[%d;%dH\033[38;2;45;45;65m %s \033[0m[" "$row" "$col" "$msg"
        
        for ((j=0; j<i; j++)); do
            local jp=$(( j * 100 / width ))
            if [[ $jp -lt 33 ]]; then
                jr=255; jg=$(( 50 + jp*3 )); jb=$(( jp * 4 ))
            elif [[ $jp -lt 66 ]]; then
                jr=$(( 255 - (jp-33)*5 )); jg=255; jb=$(( 130 + (jp-33)*2 ))
            else
                jr=0; jg=$(( 255 - (jp-66)*2 )); jb=255
            fi
            printf "\033[1;38;2;%d;%d;%dm█" "$jr" "$jg" "$jb"
        done
        
        for ((j=i; j<width; j++)); do
            printf "\033[38;2;20;20;35m░"
        done
        
        printf "\033[38;2;45;45;65m] \033[1;38;2;%d;%d;%dm%3d%%" "$r" "$g" "$b" "$pct"
        sleep 0.022
    done
}

_auth_glitch_text() {
    local text="$1" row="$2" col="$3" iterations="${4:-6}"
    local glitch_chars='!@#$%^&*<>?/|~'
    local len=${#text}
    local i j rand_char gr gg gb
    
    for ((i=0; i<iterations; i++)); do
        printf "\033[%d;%dH" "$row" "$col"
        for ((j=0; j<len; j++)); do
            if [[ $(( RANDOM % 3 )) -eq 0 ]]; then
                rand_char="${glitch_chars:$(( RANDOM % ${#glitch_chars} )):1}"
                gr=$(( RANDOM % 256 )); gg=$(( RANDOM % 60 )); gb=$(( RANDOM % 256 ))
                printf "\033[38;2;%d;%d;%dm%s" "$gr" "$gg" "$gb" "$rand_char"
            else
                printf "\033[1;38;2;0;255;200m%s" "${text:$j:1}"
            fi
        done
        sleep 0.045
    done
    printf "\033[%d;%dH\033[1;38;2;0;255;200m%s\033[0m" "$row" "$col" "$text"
}

_auth_type_text() {
    local text="$1" row="$2" col="$3" color="${4:-38;2;0;255;180}"
    local i
    printf "\033[%d;%dH" "$row" "$col"
    for ((i=0; i<${#text}; i++)); do
        printf "\033[%sm%s" "$color" "${text:$i:1}"
        sleep 0.016
    done
}

_auth_gradient_border() {
    local row="$1" col="$2" width="$3" char="${4:-─}"
    local i pct r g b
    printf "\033[%d;%dH" "$row" "$col"
    for ((i=0; i<width; i++)); do
        pct=$(( i * 100 / (width > 0 ? width : 1) ))
        if [[ $pct -lt 20 ]]; then
            r=0; g=$(( 100 + pct*5 )); b=$(( 200 + pct*2 ))
        elif [[ $pct -lt 40 ]]; then
            r=0; g=$(( 200 + (pct-20)*2 )); b=$(( 255 - (pct-20)*5 ))
        elif [[ $pct -lt 60 ]]; then
            r=$(( (pct-40)*8 )); g=255; b=$(( 150 - (pct-40)*5 ))
        elif [[ $pct -lt 80 ]]; then
            r=$(( 160 + (pct-60)*4 )); g=$(( 255 - (pct-60)*4 )); b=$(( 50 + (pct-60)*8 ))
        else
            r=$(( 255 - (pct-80)*5 )); g=$(( 175 - (pct-80)*4 )); b=$(( 210 + (pct-80)*2 ))
        fi
        printf "\033[38;2;%d;%d;%dm%s" "$r" "$g" "$b" "$char"
    done
}

_auth_draw_neon_box() {
    local bx="$1" by="$2" bw="$3" bh="$4" r1="${5:-0}" g1="${6:-255}" b1="${7:-200}"
    local i fade
    
    _auth_gradient_border "$by" "$bx" $(( bw + 4 )) "▄"
    
    printf "\033[%d;%dH\033[38;2;%d;%d;%dm  ╔" $(( by + 1 )) "$bx" "$r1" "$g1" "$b1"
    for ((i=0; i<bw; i++)); do printf "═"; done
    printf "╗"
    
    for ((i=2; i<bh; i++)); do
        fade=$(( g1 - i * 3 ))
        [[ $fade -lt 70 ]] && fade=70
        printf "\033[%d;%dH\033[38;2;%d;%d;%dm  ║" $(( by + i )) "$bx" "$r1" "$fade" "$b1"
        printf "\033[%d;%dH\033[38;2;%d;%d;%dm║" $(( by + i )) $(( bx + bw + 3 )) "$r1" "$fade" "$b1"
    done
    
    printf "\033[%d;%dH\033[38;2;%d;%d;%dm  ╚" $(( by + bh )) "$bx" "$r1" "$g1" "$b1"
    for ((i=0; i<bw; i++)); do printf "═"; done
    printf "╝"
    
    _auth_gradient_border $(( by + bh + 1 )) "$bx" $(( bw + 4 )) "▀"
}

_auth_shield_art() {
    local row="$1" col="$2"
    local -a shield=(
        "       ╔══════════╗       "
        "      ╔╝ ░▒▓████▓▒░╚╗      "
        "     ╔╝  ▓████████▓  ╚╗     "
        "     ║  ▓███▀▀▀███▓  ║     "
        "     ║  ▓██  ᐊ  ██▓  ║     "
        "     ║  ▓███▄▄▄███▓  ║     "
        "     ╚╗  ▓██████▓  ╔╝     "
        "      ╚╗  ▒▓██▓▒  ╔╝      "
        "       ╚╗  ░▓▓░  ╔╝       "
        "        ╚╗  ▒  ╔╝        "
        "         ╚════╝         "
    )
    local i line sr sg sb
    for ((i=0; i<${#shield[@]}; i++)); do
        line="${shield[$i]}"
        sr=$(( i * 22 ))
        sg=$(( 255 - i * 14 ))
        sb=$(( 180 + i * 7 ))
        [[ $sr -gt 255 ]] && sr=255
        [[ $sg -lt 80 ]] && sg=80
        [[ $sb -gt 255 ]] && sb=255
        printf "\033[%d;%dH\033[1;38;2;%d;%d;%dm%s" $(( row + i )) "$col" "$sr" "$sg" "$sb" "$line"
    done
}

_auth_hex_background() {
    local rows cols i j hr hg hb
    rows=$(tput lines 2>/dev/null || echo 24)
    cols=$(tput cols 2>/dev/null || echo 80)
    
    for ((i=1; i<=rows; i++)); do
        for ((j=1; j<=cols; j+=6)); do
            hr=$(( 3 + (i * j) % 10 ))
            hg=$(( 5 + (i + j) % 14 ))
            hb=$(( 10 + (i * 3 + j) % 20 ))
            if (( i % 3 == 0 )); then
                printf "\033[%d;%dH\033[38;2;%d;%d;%dm+" "$i" "$j" "$hr" "$hg" "$hb"
            elif (( i % 3 == 1 )); then
                printf "\033[%d;%dH\033[38;2;%d;%d;%dm." "$i" $(( j + 3 )) "$hr" "$hg" "$hb"
            else
                printf "\033[%d;%dH\033[38;2;%d;%d;%dm:" "$i" "$j" "$hr" "$hg" "$hb"
            fi
        done
    done
}

_auth_particle_burst() {
    local center_r="$1" center_c="$2" unused_c="${3:-0;255;136}" count="${4:-22}"
    local i dr dc pr pc char
    local char_pool="*+.oO@#"
    
    for ((i=0; i<count; i++)); do
        dr=$(( RANDOM % 10 - 5 ))
        dc=$(( RANDOM % 20 - 10 ))
        pr=$(( center_r + dr ))
        pc=$(( center_c + dc ))
        [[ $pr -lt 1 ]] && pr=1
        [[ $pc -lt 1 ]] && pc=1
        char="${char_pool:$(( RANDOM % ${#char_pool} )):1}"
        local p_r=$(( RANDOM % 100 + 155 ))
        local p_g=$(( RANDOM % 255 ))
        local p_b=$(( RANDOM % 100 + 155 ))
        printf "\033[%d;%dH\033[1;38;2;%d;%d;%dm%s" "$pr" "$pc" "$p_r" "$p_g" "$p_b" "$char"
        sleep 0.005
    done
}

_auth_screen_shake() {
    local iters="${1:-3}"
    local i
    for ((i=0; i<iters; i++)); do
        printf "\033[1;1H"; sleep 0.025
        printf "\033[1;2H"; sleep 0.025
        printf "\033[1;0H"; sleep 0.025
    done
    printf "\033[1;1H"
}

_auth_warning_stripes() {
    local row="$1" col="$2" width="$3"
    local i
    printf "\033[%d;%dH" "$row" "$col"
    for ((i=0; i<width; i++)); do
        if (( i % 4 < 2 )); then
            printf "\033[48;2;180;140;0;38;2;10;10;10m/"
        else
            printf "\033[48;2;10;10;10;38;2;180;140;0m/"
        fi
    done
    printf "\033[0m"
}

_auth_access_granted_anim() {
    local row="$1" col="$2" text="ACCESS GRANTED"
    local i
    for ((i=0; i<3; i++)); do
        printf "\033[%d;%dH\033[1;48;2;0;65;30;38;2;0;255;136m  ✓ %s  \033[0m" "$row" "$col" "$text"
        sleep 0.1
        printf "\033[%d;%dH\033[1;48;2;0;0;0;38;2;0;70;45m  ✓ %s  \033[0m" "$row" "$col" "$text"
        sleep 0.06
    done
    printf "\033[%d;%dH\033[1;48;2;0;45;22;38;2;0;255;136m  ✓ %s  \033[0m" "$row" "$col" "$text"
}

_auth_access_denied_anim() {
    local row="$1" col="$2" text="ACCESS DENIED"
    local i
    for ((i=0; i<4; i++)); do
        printf "\033[%d;%dH\033[1;48;2;65;0;0;38;2;255;60;60m  ✗ %s  \033[0m" "$row" "$col" "$text"
        sleep 0.07
        printf "\033[%d;%dH\033[1;48;2;0;0;0;38;2;70;12;12m  ✗ %s  \033[0m" "$row" $(( col + (i%2) )) "$text"
        sleep 0.04
    done
    printf "\033[%d;%dH\033[1;48;2;30;0;0;38;2;255;60;60m  ✗ %s  \033[0m" "$row" "$col" "$text"
}

_auth_biometric_scan() {
    local row="$1" col="$2" width="${3:-28}"
    local i j sr sg sb
    for ((i=0; i<2; i++)); do
        for ((j=0; j<width; j++)); do
            sr=$(( 0 + j * 7 ))
            sg=$(( 180 + j * 2 ))
            sb=$(( 240 - j * 4 ))
            [[ $sr -gt 220 ]] && sr=220
            [[ $sg -gt 255 ]] && sg=255
            [[ $sb -lt 100 ]] && sb=100
            printf "\033[%d;%dH\033[1;38;2;%d;%d;%dm━" "$row" $(( col + j )) "$sr" "$sg" "$sb"
            sleep 0.008
        done
        sleep 0.04
        printf "\033[%d;%dH%*s" "$row" "$col" "$width" ""
    done
    for ((j=0; j<width; j++)); do
        sr=$(( 0 + j * 5 ))
        sg=$(( 160 + j * 2 ))
        sb=$(( 200 - j * 3 ))
        [[ $sr -gt 180 ]] && sr=180
        [[ $sg -gt 255 ]] && sg=255
        [[ $sb -lt 100 ]] && sb=100
        printf "\033[%d;%dH\033[38;2;%d;%d;%dm━" "$row" $(( col + j )) "$sr" "$sg" "$sb"
    done
}

_auth_dna_spinner() {
    local row="$1" col="$2" duration="${3:-1}"
    local total_frames=14
    local i si idx
    
    for ((i=0; i<total_frames; i++)); do
        printf "\033[%d;%dH" "$row" "$col"
        for ((si=0; si<18; si++)); do
            idx=$(( (si + i) % 10 ))
            if [[ $idx -lt 3 ]]; then
                printf "\033[1;38;2;0;255;200m~"
            elif [[ $idx -lt 5 ]]; then
                printf "\033[1;38;2;200;0;255m|"
            elif [[ $idx -lt 8 ]]; then
                printf "\033[1;38;2;255;0;180m~"
            else
                printf "\033[1;38;2;0;180;255m|"
            fi
        done
        printf "\033[0m"
        sleep 0.05
    done
}

_auth_hologram_flicker() {
    local row="$1" col="$2" text="$3" color="${4:-0;255;200}"
    local i
    for ((i=0; i<5; i++)); do
        printf "\033[%d;%dH\033[1;38;2;%sm%s\033[0m" "$row" "$col" "$color" "$text"
        sleep 0.06
        printf "\033[%d;%dH\033[2;38;2;%sm%s\033[0m" "$row" "$col" "$color" "$text"
        sleep 0.03
    done
    printf "\033[%d;%dH\033[1;38;2;%sm%s\033[0m" "$row" "$col" "$color" "$text"
}

_auth_radar_pulse() {
    local row="$1" col="$2"
    local -a frames=(
        "    .    "
        "   .·.   "
        "  .·:·.  "
        " .·:*:·. "
        ".·:*@*:·."
        " .·:*:·. "
        "  .·:·.  "
        "   .·.   "
        "    .    "
    )
    local i fr fg fb
    for ((i=0; i<${#frames[@]}; i++)); do
        fr=$(( i * 30 ))
        fg=$(( 200 + i * 6 ))
        fb=$(( 255 - i * 10 ))
        [[ $fr -gt 255 ]] && fr=255
        [[ $fg -gt 255 ]] && fg=255
        [[ $fb -lt 100 ]] && fb=100
        printf "\033[%d;%dH\033[38;2;%d;%d;%dm%s\033[0m" $(( row )) "$col" "$fr" "$fg" "$fb" "${frames[$i]}"
        sleep 0.06
    done
}

auth_login_preview() {
    local _saved_auth_enabled="$AUTH_ENABLED"
    local _saved_max_attempts="$MAX_LOGIN_ATTEMPTS"
    AUTH_ENABLED="true"
    MAX_LOGIN_ATTEMPTS=1
    
    local RST="\033[0m"
    local cols rows bw bx by ti
    clear
    
    cols=$(tput cols 2>/dev/null || echo 80)
    rows=$(tput lines 2>/dev/null || echo 24)
    tput civis 2>/dev/null
    
    _auth_hex_background
    _auth_matrix_drip
    _auth_scan_lines
    
    bw=52
    [[ $cols -lt 60 ]] && bw=$(( cols - 8 ))
    [[ $bw -lt 32 ]] && bw=32
    bx=$(( (cols - bw - 4) / 2 ))
    [[ $bx -lt 1 ]] && bx=1
    by=$(( (rows - 26) / 2 ))
    [[ $by -lt 1 ]] && by=1
    
    _auth_draw_neon_box "$bx" "$by" "$bw" 24 0 255 200
    
    local _clr=$(( by + 2 ))
    while [[ $_clr -lt $(( by + 24 )) ]]; do
        printf "\033[%d;%dH\033[0m%*s" "$_clr" $(( bx + 3 )) "$bw" ""
        _clr=$(( _clr + 1 ))
    done
    
    local title_row=$(( by + 2 ))
    local title="SECURE TERMINAL"
    local title_col=$(( bx + 3 + (bw - ${#title}) / 2 ))
    [[ $title_col -lt $(( bx + 4 )) ]] && title_col=$(( bx + 4 ))
    _auth_glitch_text "$title" "$title_row" "$title_col" 8
    
    local sub="Authentication Required"
    if [[ ${#sub} -gt $(( bw - 2 )) ]]; then
        sub="${sub:0:$(( bw - 2 ))}"
    fi
    local sub_col=$(( bx + 3 + (bw - ${#sub}) / 2 ))
    [[ $sub_col -lt $(( bx + 4 )) ]] && sub_col=$(( bx + 4 ))
    _auth_type_text "$sub" $(( title_row + 1 )) "$sub_col" "3;38;2;100;100;140"
    
    _auth_biometric_scan $(( title_row + 2 )) $(( bx + 4 )) $(( bw - 4 ))
    
    local attempt_row=$(( title_row + 3 ))
    printf "\033[%d;%dH\033[1;38;2;0;255;200m[Preview Mode]" "$attempt_row" $(( bx + 3 + (bw - 14) / 2 ))
    
    local field_row=$(( attempt_row + 2 ))
    local _fld_top=$(( bw - 16 ))
    local _fld_bot=$(( bw - 5 ))
    [[ $_fld_top -lt 2 ]] && _fld_top=2
    [[ $_fld_bot -lt 2 ]] && _fld_bot=2
    printf "\033[%d;%dH\033[38;2;0;150;190m    ┌─ \033[1;38;2;0;255;255mUSERNAME \033[0;38;2;0;150;190m" "$field_row" "$bx"
    for ((ti=0; ti<_fld_top; ti++)); do printf "─"; done
    printf "┐"
    printf "\033[%d;%dH\033[38;2;0;150;190m    │ \033[1;38;2;0;255;180m❯\033[0m \033[38;2;100;100;120m(preview)" $(( field_row + 1 )) "$bx"
    printf "\033[%d;%dH\033[38;2;0;150;190m    └" $(( field_row + 2 )) "$bx"
    for ((ti=0; ti<_fld_bot; ti++)); do printf "─"; done
    printf "┘"
    
    local pass_row=$(( field_row + 3 ))
    printf "\033[%d;%dH\033[38;2;150;50;210m    ┌─ \033[1;38;2;200;100;255mPASSWORD \033[0;38;2;150;50;210m" "$pass_row" "$bx"
    for ((ti=0; ti<_fld_top; ti++)); do printf "─"; done
    printf "┐"
    printf "\033[%d;%dH\033[38;2;150;50;210m    │ \033[1;38;2;200;80;255m❯\033[0m \033[38;2;100;100;120m(preview)" $(( pass_row + 1 )) "$bx"
    printf "\033[%d;%dH\033[38;2;150;50;210m    └" $(( pass_row + 2 )) "$bx"
    for ((ti=0; ti<_fld_bot; ti++)); do printf "─"; done
    printf "┘"
    
    local info_row=$(( pass_row + 4 ))
    printf "\033[%d;%dH\033[38;2;100;100;140m    This is how your login screen will look" "$info_row" "$bx"
    printf "\033[%d;%dH\033[38;2;100;100;140m    Press any key to return..." $(( info_row + 1 )) "$bx"
    
    tput cnorm 2>/dev/null
    printf "\033[0m"
    read -rsn1
    
    AUTH_ENABLED="$_saved_auth_enabled"
    MAX_LOGIN_ATTEMPTS="$_saved_max_attempts"
    clear
}

auth_login_screen() {
    auth_init
    
    source "$ZORKOS_AUTH_CONF" 2>/dev/null
    [[ "$AUTH_ENABLED" != "true" ]] && return 0
    
    if auth_check_session; then
        return 0
    fi
    
    if [[ ! -f "$ZORKOS_AUTH_DB" ]] || [[ ! -s "$ZORKOS_AUTH_DB" ]]; then
        _auth_first_time_setup
        return $?
    fi
    
    local RST="\033[0m"
    local attempt=1
    local cols rows bw bx by ti input_col
    
    while true; do
        clear
        
        cols=$(tput cols 2>/dev/null || echo 80)
        rows=$(tput lines 2>/dev/null || echo 24)
        tput civis 2>/dev/null
        
        _auth_hex_background        # Subtle grid pattern
        _auth_matrix_drip           # Matrix rain columns
        _auth_scan_lines            # CRT scan line overlay
        
        bw=52
        [[ $cols -lt 60 ]] && bw=$(( cols - 8 ))
        [[ $bw -lt 32 ]] && bw=32
        bx=$(( (cols - bw - 4) / 2 ))
        [[ $bx -lt 1 ]] && bx=1
        by=$(( (rows - 26) / 2 ))
        [[ $by -lt 1 ]] && by=1
        
        _auth_draw_neon_box "$bx" "$by" "$bw" 24 0 255 200
        
        local _clr=$(( by + 2 ))
        while [[ $_clr -lt $(( by + 24 )) ]]; do
            printf "\033[%d;%dH\033[0m%*s" "$_clr" $(( bx + 3 )) "$bw" ""
            _clr=$(( _clr + 1 ))
        done
        
        local title_row=$(( by + 2 ))
        local title="SECURE TERMINAL"
        local title_col=$(( bx + 3 + (bw - ${#title}) / 2 ))
        [[ $title_col -lt $(( bx + 4 )) ]] && title_col=$(( bx + 4 ))
        
        _auth_glitch_text "$title" "$title_row" "$title_col" 8
        
        local sub="Authentication Required"
        if [[ ${#sub} -gt $(( bw - 2 )) ]]; then
            sub="${sub:0:$(( bw - 2 ))}"
        fi
        local sub_col=$(( bx + 3 + (bw - ${#sub}) / 2 ))
        [[ $sub_col -lt $(( bx + 4 )) ]] && sub_col=$(( bx + 4 ))
        _auth_type_text "$sub" $(( title_row + 1 )) "$sub_col" "3;38;2;100;100;140"
        
        _auth_biometric_scan $(( title_row + 2 )) $(( bx + 4 )) $(( bw - 4 ))
        
        local attempt_row=$(( title_row + 3 ))
        local attempt_text="[Attempt ${attempt}/${MAX_LOGIN_ATTEMPTS}]"
        local attempt_col=$(( bx + 3 + (bw - ${#attempt_text}) / 2 ))
        if [[ $attempt -le 2 ]]; then
            printf "\033[%d;%dH\033[1;38;2;0;255;200m%s" "$attempt_row" "$attempt_col" "$attempt_text"
        elif [[ $attempt -le 4 ]]; then
            printf "\033[%d;%dH\033[1;38;2;255;200;0m%s" "$attempt_row" "$attempt_col" "$attempt_text"
        else
            printf "\033[%d;%dH\033[1;5;38;2;255;50;50m%s" "$attempt_row" "$attempt_col" "$attempt_text"
        fi
        
        local dec_row=$(( attempt_row + 1 ))
        local dec_w=$(( bw - 2 ))
        printf "\033[%d;%dH\033[38;2;0;160;200m▐" "$dec_row" $(( bx + 3 ))
        printf "\033[38;2;25;25;45m"
        for ((ti=0; ti<dec_w; ti++)); do printf "░"; done
        printf "\033[38;2;0;160;200m▌"
        
        local field_row=$(( attempt_row + 2 ))
        local _fld_top=$(( bw - 16 ))
        local _fld_bot=$(( bw - 5 ))
        [[ $_fld_top -lt 2 ]] && _fld_top=2
        [[ $_fld_bot -lt 2 ]] && _fld_bot=2
        printf "\033[%d;%dH\033[38;2;0;150;190m    ┌─ \033[1;38;2;0;255;255mUSERNAME \033[0;38;2;0;150;190m" "$field_row" "$bx"
        for ((ti=0; ti<_fld_top; ti++)); do printf "─"; done
        printf "┐"
        printf "\033[%d;%dH\033[38;2;0;150;190m    │ \033[1;38;2;0;255;180m❯\033[0m " $(( field_row + 1 )) "$bx"
        printf "\033[%d;%dH\033[38;2;0;150;190m    └" $(( field_row + 2 )) "$bx"
        for ((ti=0; ti<_fld_bot; ti++)); do printf "─"; done
        printf "┘"
        
        tput cnorm 2>/dev/null
        input_col=$(( bx + 10 ))
        printf "\033[%d;%dH\033[1;38;2;220;220;255m" $(( field_row + 1 )) "$input_col"
        read -r login_user
        tput civis 2>/dev/null
        
        if ! _check_lockout "$login_user"; then
            _auth_warning_stripes $(( field_row + 4 )) $(( bx + 4 )) $(( bw - 4 ))
            _auth_hologram_flicker $(( field_row + 5 )) $(( bx + 6 )) "ACCOUNT LOCKED" "255;50;50"
            tput cnorm 2>/dev/null
            sleep 2
            continue
        fi
        
        local pass_row=$(( field_row + 3 ))
        printf "\033[%d;%dH\033[38;2;150;50;210m    ┌─ \033[1;38;2;200;100;255mPASSWORD \033[0;38;2;150;50;210m" "$pass_row" "$bx"
        for ((ti=0; ti<_fld_top; ti++)); do printf "─"; done
        printf "┐"
        printf "\033[%d;%dH\033[38;2;150;50;210m    │ \033[1;38;2;200;80;255m❯\033[0m " $(( pass_row + 1 )) "$bx"
        printf "\033[%d;%dH\033[38;2;150;50;210m    └" $(( pass_row + 2 )) "$bx"
        for ((ti=0; ti<_fld_bot; ti++)); do printf "─"; done
        printf "┘"
        
        tput cnorm 2>/dev/null
        printf "\033[%d;%dH\033[1;38;2;220;220;255m" $(( pass_row + 1 )) "$input_col"
        read -s login_pass
        echo ""
        tput civis 2>/dev/null
        
        local verify_row=$(( pass_row + 4 ))
        
        _auth_dna_spinner "$verify_row" $(( bx + 5 )) 1
        
        _auth_spinner "Authenticating" "1.0" "$verify_row" $(( bx + 5 ))
        
        local bar_width=$(( bw - 18 ))
        [[ $bar_width -lt 14 ]] && bar_width=14
        [[ $bar_width -gt 28 ]] && bar_width=28
        _auth_progress_bar "VERIFY" $(( verify_row + 1 )) $(( bx + 5 )) "$bar_width"
        
        local result_row=$(( verify_row + 3 ))
        
        if auth_verify "$login_user" "$login_pass"; then
            _create_session "$login_user"
            
            local level xp level_color
            level=$(auth_get_level "$login_user")
            xp=$(auth_get_xp "$login_user")
            level_color=$(auth_get_level_color "$login_user")
            
            _auth_access_granted_anim "$result_row" $(( bx + 5 ))
            
            _auth_particle_burst "$result_row" $(( bx + bw / 2 )) "0;255;136" 18
            
            printf "\033[%d;%dH" $(( result_row + 2 )) $(( bx + 5 ))
            local welcome="Welcome back, ${login_user}!"
            local wi wr wg wb
            for ((wi=0; wi<${#welcome}; wi++)); do
                wr=$(( 0 + wi * 6 ))
                wg=$(( 200 + wi * 2 ))
                wb=$(( 255 - wi * 4 ))
                [[ $wr -gt 255 ]] && wr=255
                [[ $wg -gt 255 ]] && wg=255
                [[ $wb -lt 80 ]] && wb=80
                printf "\033[1;38;2;%d;%d;%dm%s" "$wr" "$wg" "$wb" "${welcome:$wi:1}"
            done
            
            printf "\033[%d;%dH\033[1;38;2;%sm  ⚔  %s  |  %s XP\033[0m" \
                $(( result_row + 3 )) $(( bx + 5 )) "$level_color" "$level" "$xp"
            
            printf "\033[%d;%dH\033[38;2;45;45;65m  Session: %s\033[0m" \
                $(( result_row + 4 )) $(( bx + 5 )) "$(date '+%H:%M:%S')"
            
            sleep 1.5
            tput cnorm 2>/dev/null
            clear
            return 0
        else
            _auth_access_denied_anim "$result_row" $(( bx + 5 ))
            _auth_screen_shake 3
            
            local fi
            for ((fi=0; fi<2; fi++)); do
                printf "\033[1;1H\033[48;2;45;0;0m%*s\033[0m" "$cols" ""
                printf "\033[%d;1H\033[48;2;45;0;0m%*s\033[0m" "$rows" "$cols" ""
                sleep 0.05
                printf "\033[1;1H\033[48;2;0;0;0m%*s\033[0m" "$cols" ""
                printf "\033[%d;1H\033[48;2;0;0;0m%*s\033[0m" "$rows" "$cols" ""
                sleep 0.04
            done
            
            _record_fail "$login_user"
            _auth_log "LOGIN_FAILED" "$login_user"
            
            if [[ $attempt -ge 4 ]]; then
                _auth_hologram_flicker $(( result_row + 2 )) $(( bx + 5 )) "  THREAT LEVEL: CRITICAL" "255;0;0"
            elif [[ $attempt -ge 2 ]]; then
                _auth_hologram_flicker $(( result_row + 2 )) $(( bx + 5 )) "  THREAT LEVEL: ELEVATED" "255;150;0"
            fi
            
            attempt=$((attempt + 1))
            if [[ $attempt -gt $MAX_LOGIN_ATTEMPTS ]]; then
                _auth_type_text "SYSTEM LOCKOUT INITIATED..." $(( result_row + 3 )) $(( bx + 5 )) "1;38;2;255;0;0"
                _auth_warning_stripes $(( result_row + 4 )) $(( bx + 4 )) $(( bw - 4 ))
                tput cnorm 2>/dev/null
                sleep 2
                exit 1
            fi
            sleep 1.5
        fi
    done
}

_auth_first_time_setup() {
    local RST="\033[0m"
    clear
    
    local cols rows
    cols=$(tput cols 2>/dev/null || echo 80)
    rows=$(tput lines 2>/dev/null || echo 24)
    tput civis 2>/dev/null
    
    _auth_hex_background
    _auth_matrix_rain
    _auth_scan_lines
    
    local bw=52
    [[ $cols -lt 60 ]] && bw=$(( cols - 8 ))
    [[ $bw -lt 34 ]] && bw=34
    local bx=$(( (cols - bw - 4) / 2 ))
    [[ $bx -lt 1 ]] && bx=1
    local by=$(( (rows - 26) / 2 ))
    [[ $by -lt 1 ]] && by=1
    
    _auth_draw_neon_box "$bx" "$by" "$bw" 24 200 0 255
    
    local _clr=$(( by + 2 ))
    while [[ $_clr -lt $(( by + 24 )) ]]; do
        printf "\033[%d;%dH\033[0m%*s" "$_clr" $(( bx + 3 )) "$bw" ""
        _clr=$(( _clr + 1 ))
    done
    
    local title="FIRST TIME SETUP"
    local title_col=$(( bx + 3 + (bw - ${#title}) / 2 ))
    [[ $title_col -lt $(( bx + 4 )) ]] && title_col=$(( bx + 4 ))
    _auth_glitch_text "$title" $(( by + 2 )) "$title_col" 6
    
    local sub="Create Your Admin Account"
    if [[ ${#sub} -gt $(( bw - 2 )) ]]; then
        sub="${sub:0:$(( bw - 2 ))}"
    fi
    local sub_col=$(( bx + 3 + (bw - ${#sub}) / 2 ))
    [[ $sub_col -lt $(( bx + 4 )) ]] && sub_col=$(( bx + 4 ))
    _auth_type_text "$sub" $(( by + 3 )) "$sub_col" "1;38;2;200;100;255"
    
    _auth_biometric_scan $(( by + 4 )) $(( bx + 4 )) $(( bw - 4 ))
    
    _auth_gradient_border $(( by + 5 )) $(( bx + 4 )) $(( bw - 4 )) "━"
    
    local field_row=$(( by + 6 ))
    local ti
    local _fld_top=$(( bw - 16 ))
    local _fld_bot=$(( bw - 5 ))
    [[ $_fld_top -lt 2 ]] && _fld_top=2
    [[ $_fld_bot -lt 2 ]] && _fld_bot=2
    printf "\033[%d;%dH\033[38;2;0;150;190m    ┌─ \033[1;38;2;0;255;255mUSERNAME \033[0;38;2;0;150;190m" "$field_row" "$bx"
    for ((ti=0; ti<_fld_top; ti++)); do printf "─"; done
    printf "┐"
    printf "\033[%d;%dH\033[38;2;0;150;190m    │ \033[1;38;2;0;255;180m❯\033[0m " $(( field_row + 1 )) "$bx"
    printf "\033[%d;%dH\033[38;2;0;150;190m    └" $(( field_row + 2 )) "$bx"
    for ((ti=0; ti<_fld_bot; ti++)); do printf "─"; done
    printf "┘"
    
    tput cnorm 2>/dev/null
    local input_col=$(( bx + 10 ))
    printf "\033[%d;%dH\033[1;38;2;220;220;255m" $(( field_row + 1 )) "$input_col"
    read -r new_user
    tput civis 2>/dev/null
    
    [[ -z "$new_user" ]] && { tput cnorm 2>/dev/null; echo -e "\n  \033[38;2;255;60;60m  ✗ Username cannot be empty${RST}"; sleep 1; _auth_first_time_setup; return $?; }
    
    local pass_row=$(( field_row + 3 ))
    printf "\033[%d;%dH\033[38;2;150;50;210m    ┌─ \033[1;38;2;200;100;255mPASSWORD \033[0;38;2;150;50;210m" "$pass_row" "$bx"
    for ((ti=0; ti<_fld_top; ti++)); do printf "─"; done
    printf "┐"
    printf "\033[%d;%dH\033[38;2;150;50;210m    │ \033[1;38;2;200;80;255m❯\033[0m " $(( pass_row + 1 )) "$bx"
    printf "\033[%d;%dH\033[38;2;150;50;210m    └" $(( pass_row + 2 )) "$bx"
    for ((ti=0; ti<_fld_bot; ti++)); do printf "─"; done
    printf "┘"
    
    tput cnorm 2>/dev/null
    printf "\033[%d;%dH\033[1;38;2;220;220;255m" $(( pass_row + 1 )) "$input_col"
    read -s new_pass
    echo ""
    tput civis 2>/dev/null
    
    local conf_row=$(( pass_row + 3 ))
    printf "\033[%d;%dH\033[38;2;180;140;0m    ┌─ \033[1;38;2;255;220;0mCONFIRM \033[0;38;2;180;140;0m" "$conf_row" "$bx"
    for ((ti=0; ti<_fld_top+1; ti++)); do printf "─"; done
    printf "┐"
    printf "\033[%d;%dH\033[38;2;180;140;0m    │ \033[1;38;2;255;200;0m❯\033[0m " $(( conf_row + 1 )) "$bx"
    printf "\033[%d;%dH\033[38;2;180;140;0m    └" $(( conf_row + 2 )) "$bx"
    for ((ti=0; ti<_fld_bot; ti++)); do printf "─"; done
    printf "┘"
    
    tput cnorm 2>/dev/null
    printf "\033[%d;%dH\033[1;38;2;220;220;255m" $(( conf_row + 1 )) "$input_col"
    read -s confirm_pass
    echo ""
    tput civis 2>/dev/null
    
    local result_row=$(( conf_row + 3 ))
    
    if [[ "$new_pass" != "$confirm_pass" ]]; then
        _auth_access_denied_anim "$result_row" $(( bx + 5 ))
        _auth_hologram_flicker $(( result_row + 1 )) $(( bx + 5 )) "Passwords don't match!" "255;50;50"
        tput cnorm 2>/dev/null
        sleep 1.5
        _auth_first_time_setup
        return $?
    fi
    
    if [[ ${#new_pass} -lt 4 ]]; then
        _auth_access_denied_anim "$result_row" $(( bx + 5 ))
        _auth_hologram_flicker $(( result_row + 1 )) $(( bx + 5 )) "Min 4 characters required!" "255;50;50"
        tput cnorm 2>/dev/null
        sleep 1.5
        _auth_first_time_setup
        return $?
    fi
    
    _auth_dna_spinner "$result_row" $(( bx + 5 )) 1
    
    _auth_spinner "Creating admin account" "1.0" "$result_row" $(( bx + 5 ))
    
    local bar_w=$(( bw - 18 ))
    [[ $bar_w -lt 14 ]] && bar_w=14
    [[ $bar_w -gt 26 ]] && bar_w=26
    _auth_progress_bar "SETUP" $(( result_row + 1 )) $(( bx + 5 )) "$bar_w"
    
    auth_create_user "$new_user" "$new_pass" "admin"
    _create_session "$new_user"
    
    sed -i 's/AUTH_ENABLED=.*/AUTH_ENABLED=true/' "$ZORKOS_AUTH_CONF"
    
    _auth_access_granted_anim $(( result_row + 3 )) $(( bx + 5 ))
    _auth_particle_burst $(( result_row + 3 )) $(( bx + bw / 2 )) "0;255;136" 20
    
    printf "\033[%d;%dH" $(( result_row + 5 )) $(( bx + 5 ))
    local welcome="Welcome to ZorkOS, ${new_user}!"
    local wi wr wg wb
    for ((wi=0; wi<${#welcome}; wi++)); do
        wr=$(( wi * 8 ))
        wg=$(( 180 + wi * 3 ))
        wb=$(( 255 - wi * 4 ))
        [[ $wr -gt 255 ]] && wr=255
        [[ $wg -gt 255 ]] && wg=255
        [[ $wb -lt 80 ]] && wb=80
        printf "\033[1;38;2;%d;%d;%dm%s" "$wr" "$wg" "$wb" "${welcome:$wi:1}"
    done
    
    _auth_hologram_flicker $(( result_row + 6 )) $(( bx + 5 )) "  Admin Elite Status Unlocked!" "255;215;0"
    
    tput cnorm 2>/dev/null
    sleep 2
    clear
    return 0
}

auth_change_password() {
    local username="${1:-$ZORKOS_USER}"
    local RST="\033[0m"
    
    echo -ne "  \033[38;2;0;200;255m  Current password: ${RST}"
    read -s old_pass
    echo ""
    
    if ! auth_verify "$username" "$old_pass"; then
        echo -e "  \033[38;2;255;60;60m  ✗ Wrong password${RST}"
        return 1
    fi
    
    echo -ne "  \033[38;2;0;200;255m  New password: ${RST}"
    read -s new_pass
    echo ""
    echo -ne "  \033[38;2;0;200;255m  Confirm new password: ${RST}"
    read -s confirm_pass
    echo ""
    
    if [[ "$new_pass" != "$confirm_pass" ]]; then
        echo -e "  \033[38;2;255;60;60m  ✗ Passwords don't match${RST}"
        return 1
    fi
    
    local salt
    salt=$(_gen_salt)
    local hash
    hash=$(_hash_password "$new_pass" "$salt")
    
    local old_line
    old_line=$(grep "^${username}:" "$ZORKOS_AUTH_DB")
    local new_line
    new_line=$(echo "$old_line" | awk -F: -v salt="$salt" -v hash="$hash" '{OFS=":"; $2=salt; $3=hash; print}')
    
    sed -i "s|^${username}:.*|${new_line}|" "$ZORKOS_AUTH_DB"
    
    _auth_log "PASSWORD_CHANGED" "$username"
    echo -e "  \033[38;2;0;255;136m  ✓ Password changed successfully${RST}"
}

auth_list_users() {
    [[ ! -f "$ZORKOS_AUTH_DB" ]] && { echo "  No users found."; return; }
    
    local RST="\033[0m"
    echo ""
    printf "  \033[38;2;0;200;255m%-12s %-8s %-20s %-6s %-8s${RST}\n" "Username" "Role" "Last Login" "Logins" "XP"
    echo "  ──────────────────────────────────────────────────────────"
    
    local level level_color
    while IFS=: read -r user salt hash role created last_login logins xp; do
        level=$(auth_get_level "$user")
        level_color=$(auth_get_level_color "$user")
        printf "  \033[38;2;0;255;136m%-12s \033[38;2;200;100;255m%-8s \033[38;2;100;100;120m%-20s \033[38;2;255;220;0m%-6s \033[38;2;${level_color}m%-8s${RST}\n" \
            "$user" "$role" "$last_login" "$logins" "${xp}(${level})"
    done < "$ZORKOS_AUTH_DB"
    echo ""
}

auth_delete_user() {
    local username="$1"
    [[ ! -f "$ZORKOS_AUTH_DB" ]] && return 1
    
    sed -i "/^${username}:/d" "$ZORKOS_AUTH_DB"
    _auth_log "USER_DELETED" "$username"
    echo -e "  \033[38;2;0;255;136m✓ User '${username}' deleted${RST}"
}

auth_view_log() {
    if [[ -f "$ZORKOS_AUTH_LOG" ]]; then
        echo ""
        echo -e "  \033[38;2;0;200;255m  Recent Auth Events:${RST}"
        echo ""
        tail -20 "$ZORKOS_AUTH_LOG" | while read -r line; do
            echo -e "  \033[38;2;100;100;120m  ${line}\033[0m"
        done
    else
        echo "  No auth log found."
    fi
}

auth_init
