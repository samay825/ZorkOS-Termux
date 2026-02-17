# vim:ft=zsh ts=2 sw=2 sts=2
# ╔══════════════════════════════════════════════════════════════════╗
# ║  AGNOSTER 2026 — Advanced Powerline Theme for Termux            ║
# ║  Truecolor gradients | Git deep status | Battery | XP Level     ║
# ║  Exec time | Exit code | VirtualEnv | Jobs | Responsive         ║
# ║  Enhanced by Zork | 2026 Edition                                ║
# ╚══════════════════════════════════════════════════════════════════╝

# ─── Truecolor Helpers ───
_ag_rgb()    { echo -n "%{\033[38;2;$1;$2;$3m%}"; }
_ag_bg_rgb() { echo -n "%{\033[48;2;$1;$2;$3m%}"; }
_ag_rst()    { echo -n "%{\033[0m%}"; }

# ─── Powerline / Nerd Font Glyphs ───
() {
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    AG_SEP=$'\ue0b0'          # 
    AG_SEP_THIN=$'\ue0b1'     # 
    AG_SEP_R=$'\ue0b2'        # 
    AG_BRANCH=$'\ue0a0'       # 
    AG_CORNER_TL="╭"
    AG_CORNER_BL="╰"
    AG_DASH="─"
    AG_DOT="●"
    AG_VLINE="│"
}

# ─── State ───
AG_CURRENT_BG='NONE'
AG_CURRENT_BG_RGB=""

# ─── Truecolor Segment Builder ───
ag_segment() {
    local bg_r=$1 bg_g=$2 bg_b=$3
    local fg_r=$4 fg_g=$5 fg_b=$6
    shift 6
    local content="$*"

    if [[ "$AG_CURRENT_BG" != 'NONE' ]]; then
        echo -n "$(_ag_bg_rgb $bg_r $bg_g $bg_b)$(_ag_rgb ${=AG_CURRENT_BG_RGB})${AG_SEP}$(_ag_rgb $fg_r $fg_g $fg_b) "
    else
        echo -n "$(_ag_bg_rgb $bg_r $bg_g $bg_b)$(_ag_rgb $fg_r $fg_g $fg_b) "
    fi

    AG_CURRENT_BG="$bg_r;$bg_g;$bg_b"
    AG_CURRENT_BG_RGB="$bg_r $bg_g $bg_b"
    [[ -n "$content" ]] && echo -n "$content"
}

ag_end() {
    if [[ "$AG_CURRENT_BG" != 'NONE' ]]; then
        echo -n " $(_ag_rst)$(_ag_rgb ${=AG_CURRENT_BG_RGB})${AG_SEP}$(_ag_rst)"
    fi
    AG_CURRENT_BG='NONE'
    AG_CURRENT_BG_RGB=""
}

# ─── Top Gradient Line ───
_ag_top_line() {
    local cols=${COLUMNS:-80}
    local seg_len=$(( cols * 55 / 100 ))
    [[ $seg_len -lt 10 ]] && seg_len=10
    [[ $seg_len -gt 50 ]] && seg_len=50
    local line=""
    line+="$(_ag_rgb 60 60 100)${AG_CORNER_TL}"
    local i g b
    for ((i=0; i<seg_len; i++)); do
        g=$(( 60 + i * 195 / seg_len ))
        [[ $g -gt 255 ]] && g=255
        b=$(( 180 - i * 120 / seg_len ))
        [[ $b -lt 60 ]] && b=60
        line+="%{\033[38;2;30;${g};${b}m%}${AG_DASH}"
    done
    line+="$(_ag_rgb 0 255 136)${AG_DOT}"
    line+="$(_ag_rst)"
    echo -n "$line"
}

_ag_vline() {
    echo -n "$(_ag_rgb 60 60 100)${AG_VLINE}$(_ag_rst)"
}

# ─── Gradient Arrows (Purple Variant) ───
_ag_arrows() {
    echo -n "$(_ag_rgb 60 60 100)${AG_CORNER_BL}"
    echo -n "$(_ag_rgb 80 80 140)${AG_DASH}${AG_DASH}"
    echo -n "$(_ag_rgb 100 100 255)❯"
    echo -n "$(_ag_rgb 140 80 255)❯"
    echo -n "$(_ag_rgb 200 60 255)❯"
    echo -n "$(_ag_rst) "
}

# ─── Status (error/root/jobs) ───
_ag_status() {
    local -a symbols
    [[ $RETVAL -ne 0 ]] && symbols+=("$(_ag_rgb 255 80 80)✘ ${RETVAL}")
    [[ $UID -eq 0 ]] && symbols+=("$(_ag_rgb 255 220 0)⚡")
    [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+=("$(_ag_rgb 0 200 255)⚙")
    [[ -n "$symbols" ]] && ag_segment 40 10 10   255 100 100 "${(j: :)symbols}"
}

# ─── Time ───
_ag_time() {
    ag_segment 22 22 42   100 160 220 " %T"
}

# ─── User ───
_ag_user() {
    if [[ $UID -eq 0 ]]; then
        ag_segment 80 10 10   255 180 180 "⚡ %n"
    else
        ag_segment 10 40 30   0 220 136 " %n"
    fi
}

# ─── Directory ───
_ag_dir() {
    ag_segment 16 30 65   80 180 255 " %3~"
}

# ─── Git (deep status) ───
_ag_git() {
    (( $+commands[git] )) || return
    [[ "$(command git rev-parse --is-inside-work-tree 2>/dev/null)" == "true" ]] || return

    local branch dirty staged untracked ahead behind stashed mode
    branch=$(command git symbolic-ref --short HEAD 2>/dev/null) || \
    branch="◈ $(command git describe --exact-match --tags HEAD 2>/dev/null)" || \
    branch="➦ $(command git rev-parse --short HEAD 2>/dev/null)"

    [[ -n $(command git diff --name-only 2>/dev/null) ]] && dirty=" ✗"
    [[ -n $(command git diff --cached --name-only 2>/dev/null) ]] && staged=" ✚"
    [[ -n $(command git ls-files --others --exclude-standard 2>/dev/null) ]] && untracked=" ?"

    local ab
    ab=$(command git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)
    if [[ -n "$ab" ]]; then
        local a=$(echo "$ab" | cut -f1)
        local b=$(echo "$ab" | cut -f2)
        [[ $a -gt 0 ]] && ahead=" ↑${a}"
        [[ $b -gt 0 ]] && behind=" ↓${b}"
    fi

    local stash_count
    stash_count=$(command git stash list 2>/dev/null | wc -l)
    [[ $stash_count -gt 0 ]] && stashed=" ≡${stash_count}"

    local repo_path
    repo_path=$(command git rev-parse --git-dir 2>/dev/null)
    [[ -e "${repo_path}/BISECT_LOG" ]] && mode=" ‹B›"
    [[ -e "${repo_path}/MERGE_HEAD" ]] && mode=" ‹M›"
    [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" ]] && mode=" ‹R›"

    local bg_r bg_g bg_b fg_r fg_g fg_b
    if [[ -n "$dirty" ]]; then
        bg_r=70; bg_g=50; bg_b=0; fg_r=255; fg_g=200; fg_b=0
    elif [[ -n "$staged" ]]; then
        bg_r=0; bg_g=50; bg_b=50; fg_r=0; fg_g=255; fg_b=200
    else
        bg_r=10; bg_g=50; bg_b=10; fg_r=0; fg_g=255; fg_b=100
    fi

    ag_segment $bg_r $bg_g $bg_b  $fg_r $fg_g $fg_b "${AG_BRANCH} ${branch}${dirty}${staged}${untracked}${ahead}${behind}${stashed}${mode}"
}

# ─── VirtualEnv ───
_ag_venv() {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        ag_segment 40 10 60   200 100 255 " $(basename $VIRTUAL_ENV)"
    elif [[ -n "$CONDA_DEFAULT_ENV" ]]; then
        ag_segment 40 10 60   200 100 255 "🐍 ${CONDA_DEFAULT_ENV}"
    fi
}

# ─── Battery (rprompt, cached) ───
_ag_battery() {
    local cache_file="${HOME}/.zorkos/cache/.battery_cache"
    local now=${EPOCHSECONDS:-$(date +%s)}
    local cached_time=0 cached_pct=""

    if [[ -f "$cache_file" ]]; then
        cached_time=$(head -1 "$cache_file" 2>/dev/null || echo 0)
        cached_pct=$(tail -1 "$cache_file" 2>/dev/null | cut -d'|' -f2)
    fi

    if [[ $(( now - cached_time )) -gt 60 ]] && command -v termux-battery-status &>/dev/null; then
        local bat_json pct
        bat_json=$(timeout 3 termux-battery-status 2>/dev/null)
        pct=$(echo "$bat_json" | grep -o '"percentage":[0-9]*' | grep -o '[0-9]*' 2>/dev/null)
        if [[ -n "$pct" ]]; then
            cached_pct="$pct"
            echo -e "${now}\nbat|${pct}" > "$cache_file" 2>/dev/null
        fi
    fi

    if [[ -n "$cached_pct" ]] && [[ "$cached_pct" =~ ^[0-9]+$ ]]; then
        local icon fg_r fg_g fg_b
        if [[ $cached_pct -le 15 ]]; then icon=""; fg_r=255; fg_g=60; fg_b=60
        elif [[ $cached_pct -le 40 ]]; then icon=""; fg_r=255; fg_g=200; fg_b=0
        elif [[ $cached_pct -le 70 ]]; then icon=""; fg_r=200; fg_g=255; fg_b=0
        else icon=""; fg_r=0; fg_g=255; fg_b=136
        fi
        echo -n "$(_ag_rgb $fg_r $fg_g $fg_b)${icon} ${cached_pct}%%$(_ag_rst)"
    fi
}

# ─── XP Badge (rprompt) ───
_ag_xp() {
    local sf="${HOME}/.zorkos/achievements/stats.db"
    [[ -f "$sf" ]] || return
    local xp=$(grep "^TOTAL_XP=" "$sf" 2>/dev/null | cut -d= -f2)
    [[ -z "$xp" || $xp -lt 100 ]] && return
    local lv ic
    if [[ $xp -ge 10000 ]]; then lv="LGD"; ic="🌟"
    elif [[ $xp -ge 5000 ]]; then lv="MST"; ic="👑"
    elif [[ $xp -ge 2000 ]]; then lv="EXP"; ic="⚔️"
    elif [[ $xp -ge 1000 ]]; then lv="ADV"; ic="🔷"
    elif [[ $xp -ge 500 ]]; then lv="INT"; ic="🔶"
    else lv="BEG"; ic="🔰"
    fi
    echo -n "$(_ag_rgb 255 215 0)${ic}${lv}$(_ag_rst)"
}

# ─── Hooks ───
_ag_preexec() { _AG_CMD_START=$EPOCHSECONDS; _AG_CMD_RAN=1; }
_ag_precmd() {
    local ec=$?
    [[ -n "$_AG_CMD_RAN" ]] && RETVAL=$ec || RETVAL=0
    unset _AG_CMD_RAN
    if [[ -n "$_AG_CMD_START" ]]; then
        _AG_EXEC_TIME=$(( EPOCHSECONDS - _AG_CMD_START ))
    else
        _AG_EXEC_TIME=0
    fi
    unset _AG_CMD_START
}

RETVAL=0
autoload -Uz add-zsh-hook
add-zsh-hook preexec _ag_preexec
add-zsh-hook precmd _ag_precmd

# ─── Build Left Prompt ───
_ag_build() {
    AG_CURRENT_BG='NONE'
    AG_CURRENT_BG_RGB=""
    _ag_status
    _ag_time
    _ag_user
    _ag_dir
    _ag_venv
    _ag_git
    ag_end
}

# ─── Build Right Prompt ───
_ag_build_r() {
    if [[ $_AG_EXEC_TIME -gt 2 ]]; then
        local t=$_AG_EXEC_TIME ts
        if [[ $t -gt 3600 ]]; then ts=$(printf "%dh%dm" $(( t/3600 )) $(( (t%3600)/60 )))
        elif [[ $t -gt 60 ]]; then ts=$(printf "%dm%ds" $(( t/60 )) $(( t%60 )))
        else ts=$(printf "%ds" $t)
        fi
        echo -n "$(_ag_rgb 100 100 140) ${ts}$(_ag_rst) "
    fi
    _ag_battery
    echo -n " "
    _ag_xp
    echo -n " "
    echo -n "$(_ag_rgb 50 50 70)${AG_SEP_R}$(_ag_bg_rgb 22 22 38)$(_ag_rgb 80 100 140)  %D{%a %d %b} $(_ag_rst)"
}

# ─── Prompts ───
setopt PROMPT_SUBST

PROMPT='
$(_ag_top_line)
$(_ag_vline)$(_ag_build)
$(_ag_arrows)'

RPROMPT='$(_ag_build_r)'

PS2='$(_ag_rgb 60 60 100) ${AG_VLINE}  $(_ag_rgb 140 80 255)…❯ $(_ag_rst)'
SPROMPT="$(_ag_rgb 255 180 0)  Correct $(_ag_rgb 255 60 60)%R$(_ag_rst) → $(_ag_rgb 0 255 136)%r$(_ag_rst)? $(_ag_rgb 100 100 120)[y/n/a/e]$(_ag_rst) "

# ─── LS Colors ───
export LS_COLORS='di=1;38;2;80;180;255:ln=1;38;2;200;100;255:so=1;38;2;255;0;200:pi=1;38;2;255;220;0:ex=1;38;2;0;255;136:bd=1;38;2;255;165;0:cd=1;38;2;255;100;100:su=1;38;2;255;0;0:sg=1;38;2;255;69;0:tw=1;48;2;0;80;0;38;2;0;255;136:ow=1;38;2;0;255;200:*.tar=1;38;2;255;60;60:*.zip=1;38;2;255;60;60:*.jpg=1;38;2;255;0;200:*.png=1;38;2;255;0;200:*.mp3=1;38;2;0;255;200:*.py=1;38;2;0;255;136:*.js=1;38;2;255;220;0:*.sh=1;38;2;0;255;136'
