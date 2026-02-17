# vim:ft=zsh ts=2 sw=2 sts=2
# ╔══════════════════════════════════════════════════════════════════╗
# ║  BIRA 2026 — 3-Line Box Theme                                  ║
# ║  Truecolor | Powerline | Git deep | Venv | Kube | Exec time    ║
# ║  Enhanced by Zork | 2026 Edition                                ║
# ╚══════════════════════════════════════════════════════════════════╝

setopt PROMPT_SUBST

# ─── Truecolor Helpers ───
_bi_rgb() { echo -n "%{\033[38;2;$1;$2;$3m%}"; }
_bi_bg()  { echo -n "%{\033[48;2;$1;$2;$3m%}"; }
_bi_rst() { echo -n "%{\033[0m%}"; }

# ─── Top Line ───
_bi_topline() {
    local cols=${COLUMNS:-80}
    local w=$(( cols * 55 / 100 ))
    local line=""
    line+="$(_bi_rgb 0 200 180)╭"
    local i; for (( i=0; i<w; i++ )); do line+="─"; done
    line+="●$(_bi_rst)"
    echo -n "$line"
}

# ─── Vertical Connector ───
_bi_vline() { echo -n "$(_bi_rgb 0 200 180)│$(_bi_rst) "; }

# ─── User@Host ───
_bi_userhost() {
    local uc
    if [[ $UID -eq 0 ]]; then
        uc="255;80;80"
    else
        uc="0;255;180"
    fi
    echo -n "$(_bi_rgb ${uc})%B%n$(_bi_rst)$(_bi_rgb 80 80 120)@$(_bi_rst)$(_bi_rgb 0 200 255)%m$(_bi_rst) "
}

# ─── Directory ───
_bi_dir() {
    echo -n "$(_bi_rgb 80 140 255)%B %~ %b$(_bi_rst) "
}

# ─── Git (deep) ───
_bi_git() {
    (( $+commands[git] )) || return
    [[ "$(command git rev-parse --is-inside-work-tree 2>/dev/null)" == "true" ]] || return
    local branch
    branch=$(command git symbolic-ref --short HEAD 2>/dev/null || command git describe --tags --always 2>/dev/null)
    [[ -z "$branch" ]] && return

    local dirty="" staged="" untracked="" ahead="" behind=""
    [[ -n $(command git diff --name-only 2>/dev/null) ]] && dirty="✗"
    [[ -n $(command git diff --cached --name-only 2>/dev/null) ]] && staged="✚"
    [[ -n $(command git ls-files --others --exclude-standard 2>/dev/null) ]] && untracked="?"

    local ab
    ab=$(command git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)
    if [[ -n "$ab" ]]; then
        ahead=${ab%%$'\t'*}
        behind=${ab##*$'\t'}
    fi

    local state_color="0;200;255"
    [[ -n "$dirty" ]] && state_color="255;200;0"
    [[ -n "$staged" && -z "$dirty" ]] && state_color="0;255;200"

    local info=""
    info+="$(_bi_rgb 200 160 0)‹$(_bi_rgb ${state_color}) ${branch}"
    [[ -n "$dirty" ]] && info+=" $(_bi_rgb 255 80 80)${dirty}"
    [[ -n "$staged" ]] && info+=" $(_bi_rgb 0 255 200)${staged}"
    [[ -n "$untracked" ]] && info+=" $(_bi_rgb 200 100 255)${untracked}"
    [[ "$ahead" -gt 0 ]] 2>/dev/null && info+=" $(_bi_rgb 0 200 255)⬆${ahead}"
    [[ "$behind" -gt 0 ]] 2>/dev/null && info+=" $(_bi_rgb 255 100 100)⬇${behind}"
    info+=" $(_bi_rgb 200 160 0)›"
    info+="$(_bi_rst) "
    echo -n "$info"
}

# ─── Virtual Env ───
_bi_venv() {
    [[ -n "$VIRTUAL_ENV" ]] || return
    local name="${VIRTUAL_ENV:t}"
    echo -n "$(_bi_rgb 0 200 100)‹${name}›$(_bi_rst) "
}

# ─── Conda Env ───
_bi_conda() {
    [[ -n "$CONDA_DEFAULT_ENV" ]] || return
    echo -n "$(_bi_rgb 80 200 80)‹🐍${CONDA_DEFAULT_ENV}›$(_bi_rst) "
}

# ─── Kube Context ───
_bi_kube() {
    (( $+commands[kubectl] )) || return
    [[ "${plugins[@]}" =~ 'kube-ps1' ]] || return
    local ctx
    ctx=$(command kubectl config current-context 2>/dev/null)
    [[ -n "$ctx" ]] || return
    echo -n "$(_bi_rgb 100 140 255)‹☸ ${ctx}›$(_bi_rst) "
}

# ─── Gradient Arrows ───
_bi_arrows() {
    echo -n "$(_bi_rgb 0 200 180)╰"
    echo -n "$(_bi_rgb 0 220 160)──"
    echo -n "%(!.$(_bi_rgb 255 80 80)#.$(_bi_rgb 0 255 180)❯)"
    echo -n "$(_bi_rgb 0 220 200)❯"
    echo -n "$(_bi_rgb 0 180 255)❯"
    echo -n "$(_bi_rst) "
}

# ─── Exec Time ───
_bi_preexec() { _BI_START=$EPOCHSECONDS; _BI_CMD_RAN=1; }
_bi_precmd() {
    local ec=$?
    [[ -n "$_BI_CMD_RAN" ]] && _BI_LAST_EXIT=$ec
    unset _BI_CMD_RAN
    if [[ -n "$_BI_START" ]]; then
        _BI_ELAPSED=$(( EPOCHSECONDS - _BI_START ))
    else
        _BI_ELAPSED=0
    fi
    unset _BI_START
}

_BI_LAST_EXIT=0
autoload -Uz add-zsh-hook
add-zsh-hook preexec _bi_preexec
add-zsh-hook precmd _bi_precmd
precmd_functions=(_bi_precmd ${(@)precmd_functions:#_bi_precmd})

# ─── Prompts ───
PROMPT='$(_bi_topline)
$(_bi_vline)$(_bi_conda)$(_bi_venv)$(_bi_userhost)$(_bi_dir)$(_bi_git)$(_bi_kube)
$(_bi_arrows)'

RPROMPT='$(
    local parts=""
    # Return code
    if [[ ${_BI_LAST_EXIT:-0} -ne 0 ]]; then
        parts+="$(_bi_rgb 255 80 80)✘ ${_BI_LAST_EXIT}$(_bi_rst) "
    fi
    # Exec time
    if [[ $_BI_ELAPSED -gt 2 ]]; then
        local t=$_BI_ELAPSED
        if [[ $t -gt 60 ]]; then
            parts+="$(_bi_rgb 80 80 100) $(( t/60 ))m$(( t%60 ))s$(_bi_rst) "
        else
            parts+="$(_bi_rgb 80 80 100) ${t}s$(_bi_rst) "
        fi
    fi
    parts+="$(_bi_rgb 60 60 80)%T$(_bi_rst)"
    echo -n "$parts"
)'

PS2='$(_bi_rgb 0 200 180)│$(_bi_rgb 0 150 200) …❯ $(_bi_rst)'
SPROMPT="$(_bi_rgb 255 180 0) %R$(_bi_rst) → $(_bi_rgb 0 255 180)%r$(_bi_rst)? [y/n] "

export LS_COLORS='di=1;38;2;0;200;255:ln=1;38;2;200;100;255:so=1;38;2;0;200;180:pi=1;38;2;255;200;0:ex=1;38;2;0;255;136:*.tar=1;38;2;255;60;60:*.zip=1;38;2;255;60;60:*.py=1;38;2;0;255;136:*.js=1;38;2;255;220;0:*.sh=1;38;2;0;255;136'
