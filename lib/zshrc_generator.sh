#!/bin/bash

ZORK_CONF_DIR="${HOME}/.zorkos"

generate_zshrc() {
    local theme="${1:-zork-2026}"
    local plugins_line="${2:-plugins=(git zsh-autosuggestions zsh-syntax-highlighting colored-man-pages command-not-found extract sudo history)}"
    local boot_style="${3:-default}"
    
    cat << 'ZSHRC_EOF'

export PATH="$HOME/bin:$HOME/.local/bin:$PREFIX/bin:$PATH"

export ZSH="$HOME/.oh-my-zsh"

ZSHRC_EOF

    echo "ZSH_THEME=\"${theme}\""
    echo ""
    
    cat << 'ZSHRC_EOF2'
ZORKOS_DIR="$HOME/.zorkos"
if [[ -f "$ZORKOS_DIR/lib/auth_system.sh" ]] && [[ "$ZORKOS_AUTHED" != "1" ]]; then
    source "$ZORKOS_DIR/lib/auth_system.sh"
    if [[ -f "$HOME/.zorkos/auth/auth.conf" ]]; then
        source "$HOME/.zorkos/auth/auth.conf"
        if [[ "${AUTH_ENABLED}" == "true" ]]; then
            rm -f "$HOME/.zorkos/auth/session" 2>/dev/null
            auth_login_screen
            export ZORKOS_AUTHED=1
        fi
    fi
fi

if [[ "$ZORKOS_BOOTED" != "1" ]]; then
    export ZORKOS_BOOTED=1
    [[ -n "$ZSH_VERSION" ]] && setopt NO_MONITOR NO_NOTIFY 2>/dev/null
    [[ -f "$ZORKOS_DIR/zorkos.conf" ]] && source "$ZORKOS_DIR/zorkos.conf"
    [[ -f "$ZORKOS_DIR/lib/gradient_engine.sh" ]] && source "$ZORKOS_DIR/lib/gradient_engine.sh"
    [[ -f "$ZORKOS_DIR/lib/responsive.sh" ]] && source "$ZORKOS_DIR/lib/responsive.sh"
    [[ -f "$ZORKOS_DIR/lib/name_banner.sh" ]] && source "$ZORKOS_DIR/lib/name_banner.sh"
    [[ -f "$ZORKOS_DIR/lib/banners.sh" ]] && source "$ZORKOS_DIR/lib/banners.sh"
    if [[ -f "$ZORKOS_DIR/lib/animations.sh" ]]; then
        source "$ZORKOS_DIR/lib/animations.sh"
        if type full_boot_sequence &>/dev/null; then
            BOOT_STYLE=$(cat "$ZORKOS_DIR/boot_style" 2>/dev/null || echo "default")
            full_boot_sequence "$BOOT_STYLE"
        else
            clear
            printf "\n\n  \033[1;38;2;0;255;136m⚡ ZorkOS v2.0 ⚡\033[0m\n"
            printf "  \033[38;2;0;200;255m[ Terminal Expert — 2026 Edition ]\033[0m\n\n"
            sleep 1
        fi
    else
        clear
        printf "\n\n  \033[1;38;2;0;255;136m⚡ ZorkOS v2.0 ⚡\033[0m\n"
        printf "  \033[38;2;255;220;0m⚠ Boot engine missing — run installer to fix\033[0m\n\n"
        sleep 1
    fi
fi

CASE_SENSITIVE="false"
HYPHEN_INSENSITIVE="true"
COMPLETION_WAITING_DOTS="%F{yellow}…%f"
DISABLE_UNTRACKED_FILES_DIRTY="true"
HIST_STAMPS="yyyy-mm-dd"

HISTSIZE=50000
SAVEHIST=50000
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY

ZSHRC_EOF2

    echo "${plugins_line}"
    echo ""
    
    cat << 'ZSHRC_EOF3'
if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
    source $ZSH/oh-my-zsh.sh
else
    echo -e "\033[38;2;255;220;0m⚠ Oh-My-Zsh not found at $ZSH\033[0m"
    echo -e "\033[38;2;100;100;120m  Fix: git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh\033[0m"
    autoload -Uz compinit && compinit -d ~/.zcompdump 2>/dev/null
    PROMPT='%F{green}%n%f %F{blue}%~%f %F{cyan}❯%f '
    RPROMPT='%F{240}%*%f'
fi

if ! type gradient_text &>/dev/null; then
    [[ -f "$ZORKOS_DIR/lib/gradient_engine.sh" ]] && source "$ZORKOS_DIR/lib/gradient_engine.sh"
fi
if ! type get_size_class &>/dev/null; then
    [[ -f "$ZORKOS_DIR/lib/responsive.sh" ]] && source "$ZORKOS_DIR/lib/responsive.sh"
fi
if ! type _banner_char &>/dev/null; then
    [[ -f "$ZORKOS_DIR/lib/name_banner.sh" ]] && source "$ZORKOS_DIR/lib/name_banner.sh"
fi
if ! type get_active_banner &>/dev/null; then
    [[ -f "$ZORKOS_DIR/lib/banners.sh" ]] && source "$ZORKOS_DIR/lib/banners.sh"
fi

if [[ -f "$ZORKOS_DIR/assets/motd.sh" ]] && [[ "$ZORKOS_MOTD_SHOWN" != "1" ]]; then
    export ZORKOS_MOTD_SHOWN=1
    source "$ZORKOS_DIR/assets/motd.sh"
fi

if [[ "$ZORKOS_WELCOME_SHOWN" != "1" ]]; then
    export ZORKOS_WELCOME_SHOWN=1
    _zork_uname=$(grep "^USERNAME=" "$HOME/.zorkos/user.conf" 2>/dev/null | cut -d= -f2)
    [[ -z "$_zork_uname" ]] && _zork_uname=$(whoami 2>/dev/null || echo "User")
    _zork_ucmd=$(grep "^CMD_NAME=" "$HOME/.zorkos/user.conf" 2>/dev/null | cut -d= -f2)
    [[ -z "$_zork_ucmd" ]] && _zork_ucmd="zork"
    _zork_cols=${COLUMNS:-$(tput cols 2>/dev/null || echo 60)}
    _zork_sep_len=$(( _zork_cols - 6 ))
    [[ $_zork_sep_len -gt 56 ]] && _zork_sep_len=56
    [[ $_zork_sep_len -lt 16 ]] && _zork_sep_len=16

    echo ""
    printf "  \033[38;2;0;100;80m╭"
    for ((_si=0; _si<_zork_sep_len; _si++)); do
        _sg=$(( 80 + _si * 175 / _zork_sep_len ))
        [[ $_sg -gt 255 ]] && _sg=255
        printf "\033[38;2;0;%d;%dm─" "$_sg" "$(( 80 + _si * 50 / _zork_sep_len ))"
    done
    printf "\033[38;2;0;255;136m╮\033[0m\n"

    printf "  \033[38;2;0;120;80m│\033[0m \033[1;38;2;0;255;200m⚡\033[0m \033[1;38;2;0;255;136mWelcome back, \033[1;38;2;0;200;255m%s\033[0m\n" "$_zork_uname"

    printf "  \033[38;2;0;120;80m│\033[0m \033[38;2;80;80;110m   %s  •  zsh %s\033[0m\n" "$(date '+%a %d %b %Y, %H:%M')" "${ZSH_VERSION:-?}"

    printf "  \033[38;2;0;80;60m├"
    for ((_si=0; _si<_zork_sep_len; _si++)); do printf "\033[38;2;30;50;40m╌"; done
    printf "\033[0m\n"

    if [[ $_zork_cols -ge 50 ]]; then
        printf "  \033[38;2;0;120;80m│\033[0m \033[38;2;60;60;80m   \033[38;2;255;220;0m%s\033[38;2;60;60;80m ─── main menu    \033[38;2;255;220;0m%s help\033[38;2;60;60;80m ─── commands\033[0m\n" "$_zork_ucmd" "$_zork_ucmd"
        printf "  \033[38;2;0;120;80m│\033[0m \033[38;2;60;60;80m   \033[38;2;0;200;255m%s dash\033[38;2;60;60;80m ── dashboard  \033[38;2;200;100;255m%s hack\033[38;2;60;60;80m ── hacker mode\033[0m\n" "$_zork_ucmd" "$_zork_ucmd"
    else
        printf "  \033[38;2;0;120;80m│\033[0m \033[38;2;255;220;0m %s\033[38;2;60;60;80m → menu  \033[38;2;255;220;0m%s help\033[38;2;60;60;80m → cmds\033[0m\n" "$_zork_ucmd" "$_zork_ucmd"
    fi

    printf "  \033[38;2;0;100;80m╰"
    for ((_si=0; _si<_zork_sep_len; _si++)); do
        _sg=$(( 80 + _si * 175 / _zork_sep_len ))
        [[ $_sg -gt 255 ]] && _sg=255
        printf "\033[38;2;0;%d;%dm─" "$_sg" "$(( 80 + _si * 50 / _zork_sep_len ))"
    done
    printf "\033[38;2;0;255;136m╯\033[0m\n"
    echo ""

    sleep 5
    clear
    if type render_banner_display &>/dev/null && [[ -n "$CURRENT_BANNER" ]]; then
        render_banner_display "$CURRENT_BANNER" "${BANNER_BORDER_ENABLED:-true}" "${BANNER_BORDER_STYLE:-cyber-box}" "true"
    elif type get_active_banner &>/dev/null && [[ -n "$CURRENT_BANNER" ]]; then
        local _sb_idx
        _sb_idx=$(_banner_name_to_index "$CURRENT_BANNER" 2>/dev/null || echo 0)
        _get_banner_gradient "$_sb_idx" 2>/dev/null
        get_active_banner "$CURRENT_BANNER"
        echo ""
        for _sb_line in "${ACTIVE_BANNER_LINES[@]}"; do
            if type gradient_text &>/dev/null && [[ ${#ACTIVE_BANNER_GRADIENT[@]} -gt 0 ]]; then
                gradient_text "  $_sb_line" "${ACTIVE_BANNER_GRADIENT[@]}" 2>/dev/null
            else
                echo -e "  \033[38;2;0;255;136m${_sb_line}\033[0m"
            fi
            echo
        done
        echo ""
        local _sb_uname
        _sb_uname=$(grep "^USERNAME=" "$HOME/.zorkos/user.conf" 2>/dev/null | cut -d= -f2)
        [[ -z "$_sb_uname" ]] && _sb_uname="Zork"
        if type gradient_text &>/dev/null; then
            gradient_text "  ${_sb_uname}'s Terminal — Beyond All Limits" "${ACTIVE_BANNER_GRADIENT[@]}" 2>/dev/null
        else
            echo -e "  \033[38;2;0;200;255m${_sb_uname}'s Terminal — Beyond All Limits\033[0m"
        fi
        echo ""
    elif type show_startup_banner &>/dev/null; then
        show_startup_banner "$_zork_ucmd"
    fi
    [[ -n "$ZSH_VERSION" ]] && setopt MONITOR NOTIFY 2>/dev/null
fi

export LANG=en_US.UTF-8
export EDITOR='nano'
export VISUAL='nano'

alias cls='clear'
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias mkdir='mkdir -p'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -color=auto'
alias myip='curl -s ifconfig.me'
alias ports='netstat -tulpn 2>/dev/null || ss -tulpn'
alias update='pkg update && pkg upgrade -y'
alias install='pkg install -y'
alias search='pkg search'
alias pyfind='find . -name "*.py"'
alias glog='git log --oneline --graph --decorate --all'
alias gst='git status -sb'
alias gcm='git commit -m'
alias gd='git diff'
alias ga='git add'
alias gp='git push'
alias gl='git pull'

if command -v eza &>/dev/null; then
    alias ls='eza --icons --color=always --group-directories-first'
    alias ll='eza -alh --icons --color=always --group-directories-first'
    alias la='eza -a --icons --color=always --group-directories-first'
    alias lt='eza -aT --icons --color=always --group-directories-first --level=2'
    alias l.='eza -d .* --icons --color=always'
fi

if command -v bat &>/dev/null; then
    alias cat='bat --style=auto'
fi


ex() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2)  tar xjf "$1"    ;;
            *.tar.gz)   tar xzf "$1"    ;;
            *.tar.xz)   tar xJf "$1"    ;;
            *.bz2)      bunzip2 "$1"    ;;
            *.rar)      unrar x "$1"    ;;
            *.gz)       gunzip "$1"     ;;
            *.tar)      tar xf "$1"     ;;
            *.tbz2)     tar xjf "$1"    ;;
            *.tgz)      tar xzf "$1"    ;;
            *.zip)      unzip "$1"      ;;
            *.Z)        uncompress "$1" ;;
            *.7z)       7z x "$1"       ;;
            *.xz)       unxz "$1"       ;;
            *)          echo "'$1' cannot be extracted via ex()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

mkcd() { mkdir -p "$1" && cd "$1"; }

bak() { cp "$1" "$1.bak.$(date +%Y%m%d_%H%M%S)"; }

export LESS_TERMCAP_mb=$'\e[1;38;2;255;0;200m'
export LESS_TERMCAP_md=$'\e[1;38;2;0;255;136m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[48;2;30;30;50m\e[38;2;0;200;255m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[38;2;200;100;255m'

bindkey '^[[A' history-substring-search-up 2>/dev/null
bindkey '^[[B' history-substring-search-down 2>/dev/null
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#555580'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

if [[ -n "$ZSH_HIGHLIGHT_STYLES" ]] 2>/dev/null; then
    ZSH_HIGHLIGHT_STYLES[default]='fg=#e6e6ff'
    ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#ff3c3c'
    ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#b43cff,bold'
    ZSH_HIGHLIGHT_STYLES[alias]='fg=#00ff88,bold'
    ZSH_HIGHLIGHT_STYLES[builtin]='fg=#00e6ff,bold'
    ZSH_HIGHLIGHT_STYLES[function]='fg=#00ff88'
    ZSH_HIGHLIGHT_STYLES[command]='fg=#00ff88,bold'
    ZSH_HIGHLIGHT_STYLES[precommand]='fg=#ffdc00,bold'
    ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#ff00c8'
    ZSH_HIGHLIGHT_STYLES[path]='fg=#5078ff,underline'
    ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#ffdc00'
    ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#ffdc00'
    ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#ffa500'
    ZSH_HIGHLIGHT_STYLES[globbing]='fg=#ff00c8'
    ZSH_HIGHLIGHT_STYLES[redirection]='fg=#00e6ff'
    ZSH_HIGHLIGHT_STYLES[comment]='fg=#555580,italic'
fi

_zork_cmd_name=$(grep "^CMD_NAME=" "$HOME/.zorkos/user.conf" 2>/dev/null | cut -d= -f2)
_zork_cmd_name="${_zork_cmd_name:-zork}"

zork() {
    if [[ -f "$HOME/.zorkos/zork_customizer.sh" ]]; then
        bash "$HOME/.zorkos/zork_customizer.sh" "$@"
    else
        echo -e "\033[38;2;255;60;60m✗ ZorkOS customizer not found. Reinstall with the installer script.\033[0m"
    fi
}

if [[ "$_zork_cmd_name" != "zork" ]] && [[ -n "$_zork_cmd_name" ]]; then
    eval "${_zork_cmd_name}() { zork \"\$@\"; }"
fi

if ! type auth_verify &>/dev/null; then
    [[ -f "$ZORKOS_DIR/lib/auth_system.sh" ]] && source "$ZORKOS_DIR/lib/auth_system.sh"
fi

if [[ -f "$ZORKOS_DIR/lib/achievements.sh" ]]; then
    source "$ZORKOS_DIR/lib/achievements.sh"
    achievements_init
    update_streak
    eval "$(generate_achievement_hook)"
fi

if [[ -f "$ZORKOS_DIR/lib/screensaver.sh" ]]; then
    source "$ZORKOS_DIR/lib/screensaver.sh"
    if [[ -f "$HOME/.zorkos/screensaver.conf" ]]; then
        source "$HOME/.zorkos/screensaver.conf"
        if [[ "${ss_enabled}" == "true" ]]; then
            eval "$(generate_screensaver_hook)"
        fi
    fi
fi

if [[ -f "$ZORKOS_DIR/lib/bookmarks.sh" ]]; then
    source "$ZORKOS_DIR/lib/bookmarks.sh"
fi

if [[ -f "$ZORKOS_DIR/lib/quick_notes.sh" ]]; then
    source "$ZORKOS_DIR/lib/quick_notes.sh"
fi

if [[ -f "$ZORKOS_DIR/lib/weather.sh" ]]; then
    source "$ZORKOS_DIR/lib/weather.sh"
    (fetch_weather &>/dev/null &)
fi

if [[ -f "$ZORKOS_DIR/lib/hacker_mode.sh" ]]; then
    source "$ZORKOS_DIR/lib/hacker_mode.sh"
    if [[ -f "$HOME/.zorkos/hacker_mode.conf" ]]; then
        source "$HOME/.zorkos/hacker_mode.conf"
        [[ "${HACKER_ACTIVE}" == "true" ]] && _hacker_colors
    fi
fi

if [[ -f "$ZORKOS_DIR/lib/dashboard.sh" ]]; then
    source "$ZORKOS_DIR/lib/dashboard.sh"
fi

if [[ -f "$ZORKOS_DIR/lib/pomodoro.sh" ]]; then
    source "$ZORKOS_DIR/lib/pomodoro.sh"
fi

ZSHRC_EOF3
}

write_zshrc() {
    local theme="${1:-zork-2026}"
    local boot_style="${2:-default}"
    
    local plugins_line
    if [[ -f "${ZORK_CONF_DIR}/plugins.conf" ]]; then
        local plugins
        plugins=$(cat "${ZORK_CONF_DIR}/plugins.conf" | tr '\n' ' ' | tr -s ' ' | sed 's/^ //;s/ $//')
        plugins_line="plugins=(${plugins})"
    else
        plugins_line="plugins=(git zsh-autosuggestions zsh-syntax-highlighting colored-man-pages command-not-found extract sudo history)"
    fi
    
    local _lock_code=""
    if [[ -f ~/.zshrc ]] && grep -q '#ZORKOS_LOCK_START' ~/.zshrc 2>/dev/null; then
        _lock_code=$(sed -n '/#ZORKOS_LOCK_START/,/#ZORKOS_LOCK_END/p' ~/.zshrc)
    fi
    
    generate_zshrc "$theme" "$plugins_line" "$boot_style" > ~/.zshrc
    
    if [[ -n "$_lock_code" ]]; then
        local _tmp
        _tmp=$(mktemp)
        echo "$_lock_code" > "$_tmp"
        cat ~/.zshrc >> "$_tmp"
        mv "$_tmp" ~/.zshrc
    fi
    
    echo -e "  \033[38;2;0;255;136m✓ .zshrc generated with theme: ${theme}${RST}"
}
