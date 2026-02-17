#!/bin/bash

ZORK_BACKUP_DIR="${HOME}/.zorkos/backups"
RST="\033[0m"

create_backup() {
    local timestamp
    timestamp=$(date "+%Y%m%d_%H%M%S")
    local backup_path="${ZORK_BACKUP_DIR}/${timestamp}"
    
    mkdir -p "$backup_path"
    
    echo -e "  \033[38;2;0;200;255m⏳ Creating backup: ${timestamp}${RST}"
    
    [[ -f ~/.zshrc ]] && cp ~/.zshrc "${backup_path}/zshrc.bak"
    [[ -f ~/.bashrc ]] && cp ~/.bashrc "${backup_path}/bashrc.bak"
    
    [[ -f ~/.termux/colors.properties ]] && cp ~/.termux/colors.properties "${backup_path}/colors.properties.bak"
    [[ -f ~/.termux/termux.properties ]] && cp ~/.termux/termux.properties "${backup_path}/termux.properties.bak"
    [[ -f ~/.termux/font.ttf ]] && cp ~/.termux/font.ttf "${backup_path}/font.ttf.bak"
    
    [[ -d ~/.zorkos ]] && cp -r ~/.zorkos/plugins.conf "${backup_path}/plugins.conf.bak" 2>/dev/null
    [[ -f ~/.zorkos/zorkos.conf ]] && cp ~/.zorkos/zorkos.conf "${backup_path}/zorkos.conf.bak"
    
    [[ -d ~/.oh-my-zsh/custom/themes ]] && cp -r ~/.oh-my-zsh/custom/themes "${backup_path}/custom_themes" 2>/dev/null
    
    echo -e "  \033[38;2;0;255;136m✓ Backup created: ${backup_path}${RST}"
    echo "$timestamp" >> "${ZORK_BACKUP_DIR}/history.log"
}

list_backups() {
    echo -e "\n  \033[1;38;2;0;255;136m═══ Available Backups ═══${RST}\n"
    
    if [[ ! -d "$ZORK_BACKUP_DIR" ]] || [[ -z "$(ls -A "$ZORK_BACKUP_DIR" 2>/dev/null)" ]]; then
        echo -e "  \033[38;2;255;220;0m⚠ No backups found${RST}"
        return
    fi
    
    local idx=1
    local name files
    for d in "$ZORK_BACKUP_DIR"/*/; do
        name=$(basename "$d")
        files=$(ls "$d" 2>/dev/null | wc -l)
        echo -e "  \033[38;2;0;200;255m  [${idx}] \033[38;2;0;255;136m${name} \033[38;2;100;100;120m(${files} files)${RST}"
        idx=$((idx + 1))
    done
    echo ""
}

restore_backup() {
    local backup_name="$1"
    local backup_path="${ZORK_BACKUP_DIR}/${backup_name}"
    
    if [[ ! -d "$backup_path" ]]; then
        echo -e "  \033[38;2;255;60;60m✗ Backup not found: ${backup_name}${RST}"
        return 1
    fi
    
    echo -e "  \033[38;2;255;220;0m⚠ Restoring from: ${backup_name}${RST}"
    
    [[ -f "${backup_path}/zshrc.bak" ]] && cp "${backup_path}/zshrc.bak" ~/.zshrc
    [[ -f "${backup_path}/bashrc.bak" ]] && cp "${backup_path}/bashrc.bak" ~/.bashrc
    [[ -f "${backup_path}/colors.properties.bak" ]] && cp "${backup_path}/colors.properties.bak" ~/.termux/colors.properties
    [[ -f "${backup_path}/termux.properties.bak" ]] && cp "${backup_path}/termux.properties.bak" ~/.termux/termux.properties
    [[ -f "${backup_path}/font.ttf.bak" ]] && cp "${backup_path}/font.ttf.bak" ~/.termux/font.ttf
    [[ -f "${backup_path}/plugins.conf.bak" ]] && cp "${backup_path}/plugins.conf.bak" ~/.zorkos/plugins.conf
    [[ -f "${backup_path}/zorkos.conf.bak" ]] && cp "${backup_path}/zorkos.conf.bak" ~/.zorkos/zorkos.conf
    
    echo -e "  \033[38;2;0;255;136m✓ Backup restored! Reload terminal to apply.${RST}"
    termux-reload-settings 2>/dev/null
}

full_uninstall() {
    echo -e "\n  \033[1;38;2;255;60;60m⚠ FULL UNINSTALL${RST}"
    echo -e "  \033[38;2;255;220;0mThis will remove all ZorkOS customizations.${RST}"
    echo -ne "  \033[38;2;0;200;255mContinue? (y/N): ${RST}"
    read -r confirm
    
    if [[ "$confirm" != "y" ]] && [[ "$confirm" != "Y" ]]; then
        echo -e "  \033[38;2;0;255;136m✓ Cancelled.${RST}"
        return
    fi
    
    create_backup
    
    echo -e "  \033[38;2;0;200;255m⏳ Removing ZorkOS...${RST}"
    
    rm -f ~/.oh-my-zsh/custom/themes/zork-2026.zsh-theme 2>/dev/null
    
    if [[ -f ~/.oh-my-zsh/templates/zshrc.zsh-template ]]; then
        cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
    fi
    
    rm -f ~/.termux/colors.properties 2>/dev/null
    
    sed -i '/zorkos/d' ~/.zshrc 2>/dev/null
    sed -i '/zork_motd/d' ~/.zshrc 2>/dev/null
    
    rm -f "$PREFIX/bin/zork" 2>/dev/null
    
    echo -e "  \033[38;2;0;255;136m✓ ZorkOS uninstalled. Backup saved.${RST}"
    echo -e "  \033[38;2;100;100;120m  Config dir preserved at ~/.zorkos${RST}"
    
    termux-reload-settings 2>/dev/null
}
