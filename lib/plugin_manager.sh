#!/bin/bash

ZORK_PLUGIN_DIR="${HOME}/.oh-my-zsh/custom/plugins"
ZORK_CONF_DIR="${HOME}/.zorkos"
ZORK_PLUGIN_CONF="${ZORK_CONF_DIR}/plugins.conf"

RST="\033[0m"

ensure_plugin_conf() {
    mkdir -p "$ZORK_CONF_DIR"
    [[ ! -f "$ZORK_PLUGIN_CONF" ]] && echo "git zsh-autosuggestions zsh-syntax-highlighting" > "$ZORK_PLUGIN_CONF"
}

get_enabled_plugins() {
    ensure_plugin_conf
    cat "$ZORK_PLUGIN_CONF" 2>/dev/null
}

declare -A EXTERNAL_PLUGINS
EXTERNAL_PLUGINS=(
    [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions.git"
    [zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
    [zsh-completions]="https://github.com/zsh-users/zsh-completions.git"
    [zsh-history-substring-search]="https://github.com/zsh-users/zsh-history-substring-search.git"
    [fast-syntax-highlighting]="https://github.com/zdharma-continuum/fast-syntax-highlighting.git"
    [zsh-autocomplete]="https://github.com/marlonrichert/zsh-autocomplete.git"
    [you-should-use]="https://github.com/MichaelAquilina/zsh-you-should-use.git"
    [fzf-tab]="https://github.com/Aloxaf/fzf-tab.git"
)

install_external_plugin() {
    local plugin_name="$1"
    local plugin_url="${EXTERNAL_PLUGINS[$plugin_name]}"
    
    if [[ -z "$plugin_url" ]]; then
        echo -e "  \033[38;2;255;60;60m✗ Unknown external plugin: ${plugin_name}${RST}"
        return 1
    fi
    
    local target="${ZORK_PLUGIN_DIR}/${plugin_name}"
    
    if [[ -d "$target" ]]; then
        echo -e "  \033[38;2;255;220;0m⚠ Plugin already installed: ${plugin_name}${RST}"
        return 0
    fi
    
    echo -e "  \033[38;2;0;200;255m⏳ Installing ${plugin_name}...${RST}"
    git clone --depth=1 "$plugin_url" "$target" 2>/dev/null
    
    if [[ $? -eq 0 ]]; then
        echo -e "  \033[38;2;0;255;136m✓ Installed: ${plugin_name}${RST}"
    else
        echo -e "  \033[38;2;255;60;60m✗ Failed to install: ${plugin_name}${RST}"
        return 1
    fi
}

enable_plugin() {
    local plugin_name="$1"
    ensure_plugin_conf
    
    local current
    current=$(cat "$ZORK_PLUGIN_CONF")
    
    if echo "$current" | grep -qw "$plugin_name"; then
        echo -e "  \033[38;2;255;220;0m⚠ Already enabled: ${plugin_name}${RST}"
        return
    fi
    
    echo "${current} ${plugin_name}" > "$ZORK_PLUGIN_CONF"
    echo -e "  \033[38;2;0;255;136m✓ Enabled: ${plugin_name}${RST}"
}

disable_plugin() {
    local plugin_name="$1"
    ensure_plugin_conf
    
    local current
    current=$(cat "$ZORK_PLUGIN_CONF")
    
    if ! echo "$current" | grep -qw "$plugin_name"; then
        echo -e "  \033[38;2;255;220;0m⚠ Not enabled: ${plugin_name}${RST}"
        return
    fi
    
    echo "$current" | sed "s/\b${plugin_name}\b//g" | tr -s ' ' > "$ZORK_PLUGIN_CONF"
    echo -e "  \033[38;2;255;60;60m✗ Disabled: ${plugin_name}${RST}"
}

list_plugins() {
    ensure_plugin_conf
    local enabled
    enabled=$(cat "$ZORK_PLUGIN_CONF")
    
    echo -e "\n  \033[1;38;2;0;255;136m═══ Bundled OhMyZsh Plugins ═══${RST}\n"
    
    local bundled_dir="${HOME}/.oh-my-zsh/plugins"
    if [[ -d "$bundled_dir" ]]; then
        local name
        for p in "$bundled_dir"/*/; do
            name=$(basename "$p")
            if echo "$enabled" | grep -qw "$name"; then
                echo -e "  \033[38;2;0;255;136m  ✓ ${name}${RST}"
            else
                echo -e "  \033[38;2;100;100;120m  ○ ${name}${RST}"
            fi
        done
    fi
    
    echo -e "\n  \033[1;38;2;200;100;255m═══ External Plugins ═══${RST}\n"
    
    local -a _ext_names
    if [[ -n "$ZSH_VERSION" ]]; then
        _ext_names=("${(k)EXTERNAL_PLUGINS[@]}")
    else
        _ext_names=("${!EXTERNAL_PLUGINS[@]}")
    fi
    
    local installed
    for name in "${_ext_names[@]}"; do
        installed=""
        [[ -d "${ZORK_PLUGIN_DIR}/${name}" ]] && installed="\033[38;2;0;255;136m [installed]"
        if echo "$enabled" | grep -qw "$name"; then
            echo -e "  \033[38;2;0;255;136m  ✓ ${name}${installed}${RST}"
        else
            echo -e "  \033[38;2;100;100;120m  ○ ${name}${installed}${RST}"
        fi
    done
    echo ""
}

install_recommended() {
    echo -e "\n  \033[1;38;2;0;255;136m⚡ Installing recommended plugins...${RST}\n"
    
    local recommended=(
        "zsh-autosuggestions"
        "zsh-syntax-highlighting"
        "zsh-completions"
        "fast-syntax-highlighting"
        "you-should-use"
    )
    
    for plugin in "${recommended[@]}"; do
        install_external_plugin "$plugin"
        enable_plugin "$plugin"
    done
    
    local bundled_recommended=(
        "git"
        "colored-man-pages"
        "command-not-found"
        "extract"
        "encode64"
        "jsontools"
        "sudo"
        "web-search"
        "copypath"
        "copyfile"
        "dirhistory"
        "history"
    )
    
    for plugin in "${bundled_recommended[@]}"; do
        enable_plugin "$plugin"
    done
    
    echo -e "\n  \033[1;38;2;0;255;136m✓ All recommended plugins installed!${RST}\n"
}

generate_plugins_line() {
    ensure_plugin_conf
    local plugins
    plugins=$(cat "$ZORK_PLUGIN_CONF" | tr '\n' ' ' | tr -s ' ' | sed 's/^ //;s/ $//')
    echo "plugins=(${plugins})"
}
