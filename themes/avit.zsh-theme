# vim:ft=zsh ts=2 sw=2 sts=2
# ╔══════════════════════════════════════════════════════════════════╗
# ║  AVIT 2026 — Time-Since-Commit Powerhouse                      ║
# ║  Truecolor | Git aging | Deep status | Exec time               ║
# ║  Enhanced by Zork | 2026 Edition                                ║
# ╚══════════════════════════════════════════════════════════════════╝

setopt PROMPT_SUBST

# ─── Truecolor Helpers ───
_av_rgb() { echo -n "%{\033[38;2;$1;$2;$3m%}"; }
_av_rst() { echo -n "%{\033[0m%}"; }

# ─── User@Host (SSH / sudo only) ───
_av_userhost() {
    local me=""
    if [[ -n $SSH_CONNECTION ]]; then
        me="%n@%m"
    elif [[ $LOGNAME != $USERNAME ]]; then
        me="%n"
    fi
    [[ -n $me ]] && echo -n "$(_av_rgb 0 220 200)${me}$(_av_rst):"
}

# ─── Time Since Commit (aging color gradient) ───
_av_time_since_commit() {
    local last_commit now seconds
    last_commit=$(command git -c log.showSignature=false log --format='%at' -1 2>/dev/null) || return
    now=$(date +%s)
    seconds=$(( now - last_commit ))

    local minutes=$(( seconds / 60 ))
    local hours=$(( minutes / 60 ))
    local days=$(( hours / 24 ))
    local years=$(( days / 365 ))

    local age r g b
    if [[ $years -gt 0 ]]; then
        age="${years}y$(( days % 365 ))d"
        r=255; g=60; b=60  # Red — ancient
    elif [[ $days -gt 0 ]]; then
        age="${days}d$(( hours % 24 ))h"
        r=255; g=160; b=0  # Orange — stale
    elif [[ $hours -gt 0 ]]; then
        age="${hours}h$(( minutes % 60 ))m"
        r=255; g=220; b=0  # Yellow — aging
    else
        age="${minutes}m"
        r=0; g=255; b=136  # Green — fresh
    fi

    echo -n "$(_av_rgb $r $g $b)⏱ ${age}$(_av_rst)"
}

# ─── Git Info ───
_av_git_info() {
    (( $+commands[git] )) || return
    [[ "$(command git rev-parse --is-inside-work-tree 2>/dev/null)" == "true" ]] || return
    local branch
    branch=$(command git symbolic-ref --short HEAD 2>/dev/null || command git describe --tags --always 2>/dev/null)
    [[ -z "$branch" ]] && return

    local dirty="" staged="" untracked=""
    [[ -n $(command git diff --name-only 2>/dev/null) ]] && dirty="✗"
    [[ -n $(command git diff --cached --name-only 2>/dev/null) ]] && staged="✚"
    [[ -n $(command git ls-files --others --exclude-standard 2>/dev/null) ]] && untracked="◒"

    local sc="0;200;255"
    if [[ -n "$dirty" ]]; then
        sc="255;200;0"
    elif [[ -n "$staged" ]]; then
        sc="0;255;200"
    fi

    echo -n "$(_av_rgb 0 200 100) $(_av_rgb ${sc})${branch}$(_av_rst)"
    [[ -n "$dirty" ]] && echo -n " $(_av_rgb 255 80 80)${dirty}$(_av_rst)"
    [[ -n "$staged" ]] && echo -n " $(_av_rgb 0 255 200)${staged}$(_av_rst)"
    [[ -n "$untracked" ]] && echo -n " $(_av_rgb 200 100 255)${untracked}$(_av_rst)"
}

# ─── Git Status Counters ───
_av_git_status() {
    (( $+commands[git] )) || return
    [[ "$(command git rev-parse --is-inside-work-tree 2>/dev/null)" == "true" ]] || return
    local st=""
    local added modified deleted renamed unmerged
    added=$(command git diff --cached --numstat 2>/dev/null | wc -l)
    modified=$(command git diff --numstat 2>/dev/null | wc -l)
    deleted=$(command git diff --cached --diff-filter=D --name-only 2>/dev/null | wc -l)
    renamed=$(command git diff --cached --diff-filter=R --name-only 2>/dev/null | wc -l)
    unmerged=$(command git diff --diff-filter=U --name-only 2>/dev/null | wc -l)

    [[ $added -gt 0 ]] && st+="$(_av_rgb 0 200 100)✚${added} "
    [[ $modified -gt 0 ]] && st+="$(_av_rgb 255 200 0)⚑${modified} "
    [[ $deleted -gt 0 ]] && st+="$(_av_rgb 255 80 80)✖${deleted} "
    [[ $renamed -gt 0 ]] && st+="$(_av_rgb 80 140 255)▴${renamed} "
    [[ $unmerged -gt 0 ]] && st+="$(_av_rgb 0 220 220)§${unmerged} "
    [[ -n "$st" ]] && echo -n "${st}$(_av_rst)"
}

# ─── Top Line ───
_av_topline() {
    local cols=${COLUMNS:-80}
    local w=$(( cols * 55 / 100 ))
    local line=""
    line+="$(_av_rgb 100 60 200)╭"
    local i; for (( i=0; i<w; i++ )); do line+="─"; done
    line+="●$(_av_rst)"
    echo -n "$line"
}

# ─── Vline ───
_av_vline() { echo -n "$(_av_rgb 100 60 200)│$(_av_rst) "; }

# ─── Gradient Arrows ───
_av_arrows() {
    echo -n "$(_av_rgb 100 60 200)╰"
    echo -n "$(_av_rgb 120 80 220)──"
    echo -n "%(!.$(_av_rgb 255 80 80)#.$(_av_rgb 140 100 255)▶)"
    echo -n "$(_av_rgb 180 60 255)▶"
    echo -n "$(_av_rgb 220 0 255)▶"
    echo -n "$(_av_rst) "
}

# ─── Exec Time Hook ───
_av_preexec() { _AV_START=$EPOCHSECONDS; _AV_CMD_RAN=1; }
_av_precmd() {
    local ec=$?
    [[ -n "$_AV_CMD_RAN" ]] && _AV_LAST_EXIT=$ec
    unset _AV_CMD_RAN
    if [[ -n "$_AV_START" ]]; then
        _AV_ELAPSED=$(( EPOCHSECONDS - _AV_START ))
    else
        _AV_ELAPSED=0
    fi
    unset _AV_START
}

_AV_LAST_EXIT=0
autoload -Uz add-zsh-hook
add-zsh-hook preexec _av_preexec
add-zsh-hook precmd _av_precmd
precmd_functions=(_av_precmd ${(@)precmd_functions:#_av_precmd})

# ─── Prompts ───
PROMPT='$(_av_topline)
$(_av_vline)$(_av_userhost)$(_av_rgb 80 140 255)%B%3~%b$(_av_rst)$(_av_git_info)
$(_av_arrows)'

RPROMPT='$(
    local parts=""
    # Return status
    [[ ${_AV_LAST_EXIT:-0} -ne 0 ]] && parts+="$(_av_rgb 255 80 80)⍵ ${_AV_LAST_EXIT}$(_av_rst) "
    # Exec time
    if [[ $_AV_ELAPSED -gt 2 ]]; then
        local t=$_AV_ELAPSED
        if [[ $t -gt 60 ]]; then
            parts+="$(_av_rgb 80 80 100) $(( t/60 ))m$(( t%60 ))s$(_av_rst) "
        else
            parts+="$(_av_rgb 80 80 100) ${t}s$(_av_rst) "
        fi
    fi
    # Time since commit + git status
    parts+="$(_av_time_since_commit) $(_av_git_status)"
    echo -n "$parts"
)'

PS2='$(_av_rgb 100 60 200)│$(_av_rgb 180 60 255) ◀ $(_av_rst)'
SPROMPT="$(_av_rgb 255 180 0) %R$(_av_rst) → $(_av_rgb 140 100 255)%r$(_av_rst)? [y/n] "

# Vi mode indicator
MODE_INDICATOR="$(_av_rgb 255 200 0)❮$(_av_rgb 200 160 0)❮❮$(_av_rst)"

export LS_COLORS='di=1;38;2;80;140;255:ln=1;38;2;200;100;255:so=1;38;2;0;200;180:pi=1;38;2;255;200;0:ex=1;38;2;0;255;136:*.tar=1;38;2;255;60;60:*.zip=1;38;2;255;60;60:*.py=1;38;2;0;255;136:*.js=1;38;2;255;220;0:*.sh=1;38;2;140;100;255'
export GREP_COLORS='mt=1;38;2;255;200;0'
