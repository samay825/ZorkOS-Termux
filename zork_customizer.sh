#!/bin/bash
# scripted by zork ! mei chahrah ho tum yeh source code se kuch sikho !
# copy krke tumhare coding skills mei koi badlav nahi ayega !
# optimized by ai ! 


VERSION="2.0.0"
BUILD_DATE="2026-02-16"
AUTHOR="Zork"

ZORKOS_HOME="${HOME}/.zorkos"
ZORKOS_LIB="${ZORKOS_HOME}/lib"
ZORKOS_ASSETS="${ZORKOS_HOME}/assets"
ZORKOS_CONFIGS="${ZORKOS_HOME}/configs"
ZORKOS_THEMES="${ZORKOS_HOME}/themes"
ZORKOS_CONF="${ZORKOS_HOME}/zorkos.conf"
OMZ_DIR="${HOME}/.oh-my-zsh"
TERMUX_DIR="${HOME}/.termux"

source "${ZORKOS_LIB}/gradient_engine.sh" 2>/dev/null
source "${ZORKOS_LIB}/responsive.sh" 2>/dev/null
source "${ZORKOS_LIB}/animations.sh" 2>/dev/null
source "${ZORKOS_LIB}/plugin_manager.sh" 2>/dev/null
source "${ZORKOS_LIB}/backup_restore.sh" 2>/dev/null
source "${ZORKOS_LIB}/zshrc_generator.sh" 2>/dev/null
source "${ZORKOS_LIB}/auth_system.sh" 2>/dev/null || true
source "${ZORKOS_LIB}/weather.sh" 2>/dev/null
source "${ZORKOS_LIB}/screensaver.sh" 2>/dev/null
source "${ZORKOS_LIB}/achievements.sh" 2>/dev/null
source "${ZORKOS_LIB}/pomodoro.sh" 2>/dev/null
source "${ZORKOS_LIB}/quick_notes.sh" 2>/dev/null
source "${ZORKOS_LIB}/bookmarks.sh" 2>/dev/null
source "${ZORKOS_LIB}/dashboard.sh" 2>/dev/null
source "${ZORKOS_LIB}/hacker_mode.sh" 2>/dev/null
source "${ZORKOS_LIB}/name_banner.sh" 2>/dev/null
source "${ZORKOS_LIB}/banners.sh" 2>/dev/null

CURRENT_THEME="zork-2026"
CURRENT_COLOR_SCHEME="zork-default"
BOOT_ANIMATION="default"
SOUND_ENABLED=false
BOOT_SOUND_FILE="sound.mp3"
MOTD_ENABLED=true
CURRENT_BANNER="ascii-name"
BANNER_BORDER_ENABLED=true
BANNER_BORDER_STYLE="cyber-box"

load_config() {
    [[ -f "$ZORKOS_CONF" ]] && source "$ZORKOS_CONF"
}

save_config() {
    cat > "$ZORKOS_CONF" << EOF
# ZorkOS Configuration - Auto-generated
CURRENT_THEME="${CURRENT_THEME}"
CURRENT_COLOR_SCHEME="${CURRENT_COLOR_SCHEME}"
BOOT_ANIMATION="${BOOT_ANIMATION}"
SOUND_ENABLED=${SOUND_ENABLED}
BOOT_SOUND_FILE="${BOOT_SOUND_FILE}"
MOTD_ENABLED=${MOTD_ENABLED}
CURRENT_BANNER="${CURRENT_BANNER}"
BANNER_BORDER_ENABLED=${BANNER_BORDER_ENABLED}
BANNER_BORDER_STYLE="${BANNER_BORDER_STYLE}"
EOF
}

load_config

COLS=$(tput cols 2>/dev/null || echo 80)
ROWS=$(tput lines 2>/dev/null || echo 24)
BOX_W=$(( COLS > 72 ? 70 : COLS - 2 ))
MARGIN=$(( (COLS - BOX_W) / 2 ))
PAD=$(printf '%*s' "$MARGIN" "")

RST="\033[0m"

show_banner() {
    clear
    echo ""
    
    if type render_banner_display &>/dev/null && [[ -n "$CURRENT_BANNER" ]]; then
        render_banner_display "$CURRENT_BANNER" "${BANNER_BORDER_ENABLED:-true}" "${BANNER_BORDER_STYLE:-cyber-box}" "false"
    elif type get_active_banner &>/dev/null && [[ -n "$CURRENT_BANNER" ]]; then
        local _bidx
        _bidx=$(_banner_name_to_index "$CURRENT_BANNER" 2>/dev/null || echo 0)
        _get_banner_gradient "$_bidx" 2>/dev/null
        get_active_banner "$CURRENT_BANNER"
        for line in "${ACTIVE_BANNER_LINES[@]}"; do
            if [[ ${#ACTIVE_BANNER_GRADIENT[@]} -gt 0 ]]; then
                gradient_text "$line" "${ACTIVE_BANNER_GRADIENT[@]}"
            else
                gradient_text "$line" "${GRADIENT_ZORK[@]}"
            fi
            echo
        done
    else
        get_responsive_banner
        for line in "${RESPONSIVE_BANNER[@]}"; do
            gradient_text "$line" "${GRADIENT_ZORK[@]}"
            echo
        done
    fi
    
    echo ""
    local _uname
    _uname=$(grep "^USERNAME=" "$HOME/.zorkos/user.conf" 2>/dev/null | cut -d= -f2)
    [[ -z "$_uname" ]] && _uname="$AUTHOR"

    
    local _by_line="BY ${_uname}"
    gradient_text "  ${_by_line}" "${ACTIVE_BANNER_GRADIENT[@]:-${GRADIENT_AURORA[@]}}" 2>/dev/null || echo -e "  \033[38;2;100;100;120m${_by_line}${RST}"
    echo ""

    local tagline
    tagline=$(get_responsive_tagline 2>/dev/null || echo "⚡ ${_uname}'s Terminal — v${VERSION} ⚡")
    gradient_text "  ${tagline}" "${GRADIENT_AURORA[@]}"
    echo ""
    draw_responsive_separator "─"
    echo ""
}

menu_item() {
    local num="$1"
    local label="$2"
    local icon="$3"
    local color_r="$4"
    local color_g="$5"
    local color_b="$6"
    
    printf "${PAD}\033[38;2;60;60;80m  [\033[1;38;2;0;255;136m%s\033[0;38;2;60;60;80m] \033[38;2;%d;%d;%dm%s %s${RST}\n" "$num" "$color_r" "$color_g" "$color_b" "$icon" "$label"
}

section_header() {
    local title="$1"
    echo ""
    gradient_text "  ═══ ${title} ═══" "${GRADIENT_ZORK[@]}"
    echo ""
}

draw_sep() {
    gradient_line "─" "${GRADIENT_ZORK[@]}"
}

prompt_input() {
    local msg="$1"
    echo ""
    printf "${PAD}\033[38;2;40;40;60m  ╭─\033[38;2;0;200;255m⟫ \033[1;38;2;0;255;200m%s\033[0m\n" "$msg"
    printf "${PAD}\033[38;2;40;40;60m  ╰─\033[38;2;0;255;136m▸ \033[0m"
}

prompt_confirm() {
    local msg="$1"
    echo ""
    printf "${PAD}\033[38;2;40;40;60m  ╭─\033[38;2;255;220;0m⚡⟫ \033[1;38;2;255;220;0m%s\033[0m\n" "$msg"
    printf "${PAD}\033[38;2;40;40;60m  ╰─\033[38;2;0;255;136m▸ \033[38;2;100;100;120m(y/N) \033[0m"
}

prompt_text() {
    local label="$1"
    local hint="$2"
    echo ""
    printf "${PAD}\033[38;2;40;40;60m  ╭─\033[38;2;200;100;255m⟫ \033[1;38;2;200;100;255m%s\033[0m" "$label"
    [[ -n "$hint" ]] && printf "\033[38;2;80;80;100m  (%s)\033[0m" "$hint"
    echo ""
    printf "${PAD}\033[38;2;40;40;60m  ╰─\033[38;2;0;255;136m▸ \033[0m"
}

prompt_password() {
    local label="$1"
    echo ""
    printf "${PAD}\033[38;2;40;40;60m  ╭─\033[38;2;255;60;60m🔒⟫ \033[1;38;2;255;180;100m%s\033[0m\n" "$label"
    printf "${PAD}\033[38;2;40;40;60m  ╰─\033[38;2;255;220;0m▸ \033[0m"
}

msg_ok() { echo -e "  \033[38;2;0;255;136m✓ $1${RST}"; }
msg_warn() { echo -e "  \033[38;2;255;220;0m⚠ $1${RST}"; }
msg_err() { echo -e "  \033[38;2;255;60;60m✗ $1${RST}"; }
msg_info() { echo -e "  \033[38;2;0;200;255mℹ $1${RST}"; }
msg_wait() { echo -e "  \033[38;2;200;100;255m⏳ $1${RST}"; }

pause() {
    echo ""
    echo -ne "${PAD}\033[38;2;40;40;60m  ╶─\033[38;2;100;100;140m⟫ \033[38;2;80;80;110mPress any key to continue\033[38;2;40;40;60m ─╴${RST}"
    read -n1 -s
    echo ""
}

main_menu() {
    show_banner
    
    section_header "Main Menu"
    
    menu_item "01" "Full Setup (Fresh Install)" "🚀" 0 255 136
    menu_item "02" "Theme Selector" "🎨" 0 200 255
    menu_item "03" "Color Scheme" "🌈" 200 100 255
    menu_item "04" "Font Manager" "🔤" 255 165 0
    menu_item "05" "Plugin Manager" "" 0 255 200
    menu_item "06" "Shell Switcher" "🐚" 255 220 0
    menu_item "07" "Boot Animation" "✨" 255 0 200
    menu_item "08" "Banner / MOTD" "📋" 80 180 255
    menu_item "09" "Backup / Restore" "💾" 0 255 136
    menu_item "10" "Sound Settings" "🔊" 200 200 255
    menu_item "11" "System Info" "" 100 200 255
    menu_item "12" "Advanced Config" "⚙️ " 180 180 200
    menu_item "13" "Update ZorkOS" "📡" 0 200 200
    menu_item "14" "Uninstall" "🗑️ " 255 100 100
    echo ""
    draw_sep
    section_header "Power Features"
    menu_item "15" "Terminal Security" "🔐" 255 50 50
    menu_item "16" "System Dashboard" "📊" 0 255 200
    menu_item "17" "Achievements / XP" "🏆" 255 215 0
    menu_item "18" "Pomodoro Timer" "🍅" 255 100 50
    menu_item "19" "Quick Notes" "📝" 100 200 255
    menu_item "20" "Dir Bookmarks" "📌" 200 100 255
    menu_item "21" "Hacker Mode" "💀" 0 255 0
    menu_item "22" "Screensaver" "🌙" 100 100 255
    menu_item "23" "Weather Widget" "🌤️ " 255 180 50
    menu_item "00" "Exit" "⏻ " 100 100 120
    
    echo ""
    draw_sep
    
    prompt_input "Select"
    read -r choice
    
    case "$choice" in
        1|01) full_setup ;;
        2|02) theme_menu ;;
        3|03) color_menu ;;
        4|04) font_menu ;;
        5|05) plugin_menu ;;
        6|06) shell_menu ;;
        7|07) boot_menu ;;
        8|08) banner_menu ;;
        9|09) backup_menu ;;
        10)   sound_menu ;;
        11)   system_info ;;
        12)   advanced_menu ;;
        13)   update_zorkos ;;
        14)   full_uninstall; main_menu ;;
        15)   auth_menu ;;
        16)   dashboard_menu ;;
        17)   achievements_menu ;;
        18)   pomodoro_menu ;;
        19)   notes_menu ;;
        20)   bookmarks_menu ;;
        21)   hacker_menu ;;
        22)   screensaver_menu ;;
        23)   weather_menu ;;
        0|00) goodbye ;;
        *)    main_menu ;;
    esac
}

full_setup() {
    show_banner
    section_header "Full Setup — Fresh Install"
    
    msg_info "This will install everything from scratch."
    msg_info "Packages, Oh-My-Zsh, themes, plugins, fonts, colors — everything."
    prompt_confirm "Continue with Full Setup?"
    read -r confirm
    [[ "$confirm" != "y" ]] && [[ "$confirm" != "Y" ]] && { main_menu; return; }
    
    create_backup
    
    echo ""
    
    msg_wait "Updating system packages..."
    apt update -y && apt upgrade -y 2>/dev/null
    msg_ok "System updated"
    
    msg_wait "Installing essential packages..."
    pkg install -y zsh git curl wget figlet toilet ruby ncurses-utils bc jq python openssl termux-api 2>/dev/null
    msg_ok "Packages installed"
    
    msg_wait "Installing lolcat..."
    gem install lolcat 2>/dev/null
    msg_ok "Lolcat installed"
    
    msg_wait "Installing modern CLI tools..."
    pkg install -y eza bat fd ripgrep fzf 2>/dev/null
    msg_ok "Modern CLI tools installed"
    
    msg_wait "Installing Oh-My-Zsh..."
    if [[ ! -d "${OMZ_DIR}" ]]; then
        git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "${OMZ_DIR}" 2>/dev/null
    else
        msg_warn "Oh-My-Zsh already installed, skipping..."
    fi
    msg_ok "Oh-My-Zsh ready"
    
    msg_wait "Installing ZorkOS theme..."
    mkdir -p "${OMZ_DIR}/custom/themes"
    cp "${ZORKOS_THEMES}/zork-2026.zsh-theme" "${OMZ_DIR}/custom/themes/" 2>/dev/null
    cp "${ZORKOS_THEMES}"/*.zsh-theme "${OMZ_DIR}/themes/" 2>/dev/null
    msg_ok "Themes installed"
    
    msg_wait "Installing recommended plugins..."
    install_recommended
    msg_ok "Plugins installed"
    
    msg_wait "Installing FiraCode Nerd Font..."
    mkdir -p "${TERMUX_DIR}"
    curl -fLo "${TERMUX_DIR}/font.ttf" \
        "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf" 2>/dev/null
    msg_ok "Nerd Font installed"
    
    msg_wait "Applying Zork color scheme..."
    cp "${ZORKOS_CONFIGS}/colors-zork-default.properties" "${TERMUX_DIR}/colors.properties" 2>/dev/null
    msg_ok "Color scheme applied"
    
    msg_wait "Configuring Termux properties..."
    cp "${ZORKOS_CONFIGS}/termux.properties" "${TERMUX_DIR}/termux.properties" 2>/dev/null
    msg_ok "Termux properties configured"
    
    msg_wait "Generating optimized .zshrc..."
    write_zshrc "zork-2026" "default"
    msg_ok ".zshrc generated"
    
    msg_wait "Setting ZSH as default shell..."
    chsh -s zsh 2>/dev/null
    msg_ok "Default shell: ZSH"
    
    msg_wait "Installing 'zork' command..."
    install_zork_command
    msg_ok "'zork' command installed"
    
    echo "default" > "${ZORKOS_HOME}/boot_style"
    
    CURRENT_THEME="zork-2026"
    CURRENT_COLOR_SCHEME="zork-default"
    save_config
    
    echo ""
    draw_sep
    echo ""
    msg_ok "ZorkOS Full Setup Complete!"
    msg_info "Restart Termux to see the magic."
    echo ""
    local _uname
    _uname=$(grep "^USERNAME=" "$HOME/.zorkos/user.conf" 2>/dev/null | cut -d= -f2)
    [[ -z "$_uname" ]] && _uname="Zork"
    gradient_text "  ${_uname}'s Terminal — ZorkOS v${VERSION}" "${GRADIENT_ZORK[@]}"
    echo ""
    
    termux-reload-settings 2>/dev/null
    pause
    main_menu
}

install_zork_command() {
    local zork_bin="${PREFIX}/bin/zork"
    cat > "$zork_bin" << 'ZORKBIN'
#!/bin/bash
# ZorkOS Quick Launcher
exec bash "$HOME/.zorkos/zork_customizer.sh" "$@"
ZORKBIN
    chmod +x "$zork_bin"
}

theme_menu() {
    show_banner
    section_header "Theme Selector"
    
    msg_info "Current theme: \033[1;38;2;0;255;136m${CURRENT_THEME}${RST}"
    echo ""
    
    menu_item "01" "ZorkOS 2026 (Recommended)" "★" 0 255 136
    menu_item "02" "Agnoster" "◆" 0 200 255
    menu_item "03" "Robbyrussell (Classic)" "◆" 200 100 255
    menu_item "04" "Fino-time" "◆" 255 165 0
    menu_item "05" "Bira" "◆" 0 255 200
    menu_item "06" "Candy" "◆" 255 100 200
    menu_item "07" "Gnzh" "◆" 255 220 0
    menu_item "08" "Refined" "◆" 100 200 255
    menu_item "09" "Steeef" "◆" 200 200 200
    menu_item "10" "Avit" "◆" 180 255 180
    menu_item "11" "Browse All Themes" "🔍" 200 200 255
    menu_item "12" "Random Theme" "🎲" 255 0 200
    menu_item "00" "← Back" "◀" 100 100 120
    
    prompt_input "Select theme"
    read -r tc
    
    local new_theme=""
    case "$tc" in
        1|01) new_theme="zork-2026" ;;
        2|02) new_theme="agnoster" ;;
        3|03) new_theme="robbyrussell" ;;
        4|04) new_theme="fino-time" ;;
        5|05) new_theme="bira" ;;
        6|06) new_theme="candy" ;;
        7|07) new_theme="gnzh" ;;
        8|08) new_theme="refined" ;;
        9|09) new_theme="steeef" ;;
        10)   new_theme="avit" ;;
        11)   browse_themes; return ;;
        12)   random_theme; return ;;
        0|00) main_menu; return ;;
        *)    theme_menu; return ;;
    esac
    
    if [[ -n "$new_theme" ]]; then
        apply_theme "$new_theme"
    fi
    
    pause
    theme_menu
}

apply_theme() {
    local theme="$1"
    msg_wait "Applying theme: ${theme}..."
    
    CURRENT_THEME="$theme"
    save_config
    
    if [[ -f ~/.zshrc ]]; then
        sed -i "s/^ZSH_THEME=.*/ZSH_THEME=\"${theme}\"/" ~/.zshrc
    else
        write_zshrc "$theme" "$BOOT_ANIMATION"
    fi
    
    msg_ok "Theme applied: ${theme}"
    msg_info "Restart shell or run 'source ~/.zshrc' to see changes"
}

browse_themes() {
    show_banner
    section_header "All Available Themes"
    
    local theme_dir="${OMZ_DIR}/themes"
    local idx=1
    local -a all_themes=()
    
    for f in "$theme_dir"/*.zsh-theme; do
        local name=$(basename "$f" .zsh-theme)
        all_themes+=("$name")
        printf "  \033[38;2;60;60;80m[%3d] \033[38;2;0;200;255m%s${RST}\n" "$idx" "$name"
        idx=$((idx + 1))
    done
    
    local custom_dir="${OMZ_DIR}/custom/themes"
    if [[ -d "$custom_dir" ]]; then
        for f in "$custom_dir"/*.zsh-theme; do
            [[ ! -f "$f" ]] && continue
            local name=$(basename "$f" .zsh-theme)
            all_themes+=("$name")
            printf "  \033[38;2;60;60;80m[%3d] \033[38;2;0;255;136m%s \033[38;2;255;220;0m★ custom${RST}\n" "$idx" "$name"
            idx=$((idx + 1))
        done
    fi
    
    prompt_input "Enter number or theme name (0=back)"
    read -r sel
    
    [[ "$sel" == "0" ]] && { theme_menu; return; }
    
    if [[ "$sel" =~ ^[0-9]+$ ]] && [[ $sel -le ${#all_themes[@]} ]] && [[ $sel -gt 0 ]]; then
        apply_theme "${all_themes[$((sel - 1))]}"
    else
        apply_theme "$sel"
    fi
    
    pause
    theme_menu
}

random_theme() {
    local theme_dir="${OMZ_DIR}/themes"
    local -a themes=()
    for f in "$theme_dir"/*.zsh-theme; do
        themes+=($(basename "$f" .zsh-theme))
    done
    
    local count=${#themes[@]}
    local random_idx=$(( RANDOM % count ))
    local chosen="${themes[$random_idx]}"
    
    msg_info "Random theme selected: ${chosen}"
    apply_theme "$chosen"
    
    pause
    theme_menu
}

color_menu() {
    show_banner
    section_header "Color Scheme Selector"
    
    msg_info "Current scheme: \033[1;38;2;0;255;136m${CURRENT_COLOR_SCHEME}${RST}"
    echo ""
    
    menu_item "01" "Zork Signature (Default)" "🎨" 0 255 136
    menu_item "02" "Cyber Neon" "🎨" 0 230 255
    menu_item "03" "Blood Matrix" "🎨" 255 0 0
    menu_item "04" "Ocean Depth" "🎨" 0 100 255
    menu_item "05" "Aurora Borealis" "🎨" 0 255 127
    menu_item "06" "Sunset Blaze" "🎨" 255 94 77
    menu_item "07" "Custom RGB Input" "✏️ " 200 200 200
    menu_item "00" "← Back" "◀" 100 100 120
    
    prompt_input "Select scheme"
    read -r cc
    
    local scheme=""
    case "$cc" in
        1|01) scheme="zork-default" ;;
        2|02) scheme="cyber-neon" ;;
        3|03) scheme="blood-matrix" ;;
        4|04) scheme="ocean-depth" ;;
        5|05) scheme="aurora" ;;
        6|06) scheme="sunset" ;;
        7|07) custom_color_input; return ;;
        0|00) main_menu; return ;;
        *)    color_menu; return ;;
    esac
    
    if [[ -n "$scheme" ]]; then
        apply_color_scheme "$scheme"
    fi
    
    pause
    color_menu
}

apply_color_scheme() {
    local scheme="$1"
    local src="${ZORKOS_CONFIGS}/colors-${scheme}.properties"
    
    if [[ ! -f "$src" ]]; then
        msg_err "Color scheme file not found: ${src}"
        return 1
    fi
    
    mkdir -p "${TERMUX_DIR}"
    cp "$src" "${TERMUX_DIR}/colors.properties"
    
    CURRENT_COLOR_SCHEME="$scheme"
    save_config
    
    termux-reload-settings 2>/dev/null
    
    msg_ok "Color scheme applied: ${scheme}"
}

custom_color_input() {
    show_banner
    section_header "Custom Color Input"
    
    msg_info "Enter hex colors for your custom scheme"
    echo ""
    
    local bg fg cursor
    prompt_text "Background" "e.g. #0D0D1A"
    read -r bg
    prompt_text "Foreground" "e.g. #E6E6FF"
    read -r fg
    prompt_text "Cursor Color" "e.g. #00FF88"
    read -r cursor
    
    bg="${bg:-#0D0D1A}"
    fg="${fg:-#E6E6FF}"
    cursor="${cursor:-#00FF88}"
    
    cat > "${TERMUX_DIR}/colors.properties" << EOF
# ZorkOS Custom Color Scheme
# Made by Zork

background=${bg}
foreground=${fg}
cursor=${cursor}

color0=${bg}
color7=${fg}
color15=#FFFFFF
EOF
    
    termux-reload-settings 2>/dev/null
    msg_ok "Custom colors applied!"
    
    pause
    color_menu
}

font_menu() {
    show_banner
    section_header "Font Manager"
    
    menu_item "01" "FiraCode Nerd Font (Recommended)" "🔤" 0 255 136
    menu_item "02" "JetBrainsMono Nerd Font" "🔤" 0 200 255
    menu_item "03" "Hack Nerd Font" "🔤" 200 100 255
    menu_item "04" "MesloLGS Nerd Font" "🔤" 255 165 0
    menu_item "05" "CascadiaCode Nerd Font" "🔤" 0 255 200
    menu_item "06" "SourceCodePro Nerd Font" "🔤" 255 220 0
    menu_item "07" "UbuntuMono Nerd Font" "🔤" 255 100 200
    menu_item "08" "DejaVuSansMono Nerd Font" "🔤" 80 180 255
    menu_item "00" "← Back" "◀" 100 100 120
    
    prompt_input "Select font"
    read -r fc
    
    local font_url=""
    local font_name=""
    case "$fc" in
        1|01) font_name="FiraCode"; font_url="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf" ;;
        2|02) font_name="JetBrainsMono"; font_url="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFont-Regular.ttf" ;;
        3|03) font_name="Hack"; font_url="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/HackNerdFont-Regular.ttf" ;;
        4|04) font_name="MesloLGS"; font_url="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/L/Regular/MesloLGLNerdFont-Regular.ttf" ;;
        5|05) font_name="CascadiaCode"; font_url="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/CascadiaCode/Regular/CaskaydiaCoveNerdFont-Regular.ttf" ;;
        6|06) font_name="SourceCodePro"; font_url="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/SourceCodePro/Regular/SauceCodeProNerdFont-Regular.ttf" ;;
        7|07) font_name="UbuntuMono"; font_url="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/UbuntuMono/Regular/UbuntuMonoNerdFont-Regular.ttf" ;;
        8|08) font_name="DejaVuSansMono"; font_url="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DejaVuSansMono/Regular/DejaVuSansMNerdFont-Regular.ttf" ;;
        0|00) main_menu; return ;;
        *)    font_menu; return ;;
    esac
    
    if [[ -n "$font_url" ]]; then
        msg_wait "Downloading ${font_name} Nerd Font..."
        mkdir -p "${TERMUX_DIR}"
        curl -fLo "${TERMUX_DIR}/font.ttf" "$font_url" 2>/dev/null
        
        if [[ $? -eq 0 ]]; then
            termux-reload-settings 2>/dev/null
            msg_ok "Font installed: ${font_name}"
        else
            msg_err "Failed to download font"
        fi
    fi
    
    pause
    font_menu
}

plugin_menu() {
    show_banner
    section_header "Plugin Manager"
    
    menu_item "01" "Install Recommended Plugins" "⚡" 0 255 136
    menu_item "02" "List All Plugins" "📋" 0 200 255
    menu_item "03" "Install External Plugin" "📥" 200 100 255
    menu_item "04" "Enable Plugin" "✓" 0 255 200
    menu_item "05" "Disable Plugin" "✗" 255 60 60
    menu_item "06" "Install Syntax Highlighting" "🎨" 255 220 0
    menu_item "07" "Install Auto-suggestions" "💡" 255 165 0
    menu_item "08" "Install Completions Pack" "" 80 180 255
    menu_item "09" "Rebuild .zshrc plugins" "🔄" 200 200 200
    menu_item "00" "← Back" "◀" 100 100 120
    
    prompt_input "Select"
    read -r pc
    
    case "$pc" in
        1|01) install_recommended; pause; plugin_menu ;;
        2|02) list_plugins; pause; plugin_menu ;;
        3|03)
            prompt_text "Plugin Name" "github shortname"
            read -r pname
            install_external_plugin "$pname"
            enable_plugin "$pname"
            pause
            plugin_menu
            ;;
        4|04)
            prompt_text "Plugin to Enable"
            read -r pname
            enable_plugin "$pname"
            pause
            plugin_menu
            ;;
        5|05)
            prompt_text "Plugin to Disable"
            read -r pname
            disable_plugin "$pname"
            pause
            plugin_menu
            ;;
        6|06) install_external_plugin "zsh-syntax-highlighting"; enable_plugin "zsh-syntax-highlighting"; pause; plugin_menu ;;
        7|07) install_external_plugin "zsh-autosuggestions"; enable_plugin "zsh-autosuggestions"; pause; plugin_menu ;;
        8|08) install_external_plugin "zsh-completions"; enable_plugin "zsh-completions"; pause; plugin_menu ;;
        9|09)
            write_zshrc "$CURRENT_THEME" "$BOOT_ANIMATION"
            msg_ok ".zshrc rebuilt with current plugins"
            pause
            plugin_menu
            ;;
        0|00) main_menu ;;
        *)    plugin_menu ;;
    esac
}

shell_menu() {
    show_banner
    section_header "Shell Switcher"
    
    local current_shell
    current_shell=$(basename "$SHELL" 2>/dev/null || echo "unknown")
    msg_info "Current shell: \033[1;38;2;0;255;136m${current_shell}${RST}"
    echo ""
    
    menu_item "01" "Switch to ZSH" "🐚" 0 255 136
    menu_item "02" "Switch to Bash" "🐚" 255 165 0
    menu_item "03" "Install ZSH" "📥" 0 200 255
    menu_item "00" "← Back" "◀" 100 100 120
    
    prompt_input "Select"
    read -r sc
    
    case "$sc" in
        1|01) chsh -s zsh 2>/dev/null; msg_ok "Shell set to ZSH"; pause; shell_menu ;;
        2|02) chsh -s bash 2>/dev/null; msg_ok "Shell set to Bash"; pause; shell_menu ;;
        3|03) pkg install -y zsh 2>/dev/null; msg_ok "ZSH installed"; pause; shell_menu ;;
        0|00) main_menu ;;
        *)    shell_menu ;;
    esac
}

boot_menu() {
    show_banner
    section_header "Boot Animation Selector"
    
    msg_info "Current boot style: \033[1;38;2;0;255;136m${BOOT_ANIMATION}${RST}"
    echo ""
    
    menu_item "01" "Default (Logo + Loading)" "✨" 0 255 136
    menu_item "02" "Matrix Rain" "✨" 0 200 0
    menu_item "03" "Cyber Grid" "✨" 0 200 255
    menu_item "04" "Hexagonal" "✨" 200 100 255
    menu_item "05" "DNA Helix" "✨" 255 0 200
    menu_item "06" "Glitch" "✨" 255 60 60
    menu_item "07" "Particle Explosion" "✨" 255 165 0
    menu_item "08" "Minimal (Logo only)" "✨" 200 200 200
    menu_item "09" "None (Fastest)" "✨" 100 100 120
    menu_item "10" "Preview Animation" "▶" 255 220 0
    menu_item "00" "← Back" "◀" 100 100 120
    
    prompt_input "Select"
    read -r bc
    
    local style=""
    case "$bc" in
        1|01) style="default" ;;
        2|02) style="matrix" ;;
        3|03) style="cyber" ;;
        4|04) style="hex" ;;
        5|05) style="dna" ;;
        6|06) style="glitch" ;;
        7|07) style="particle" ;;
        8|08) style="minimal" ;;
        9|09) style="none" ;;
        10)
            prompt_text "Preview Style" "matrix/cyber/hex/dna/glitch/particle/minimal"
            read -r preview_style
            full_boot_sequence "${preview_style:-default}"
            pause
            boot_menu
            return
            ;;
        0|00) main_menu; return ;;
        *)    boot_menu; return ;;
    esac
    
    if [[ -n "$style" ]]; then
        BOOT_ANIMATION="$style"
        echo "$style" > "${ZORKOS_HOME}/boot_style"
        save_config
        msg_ok "Boot animation set: ${style}"
    fi
    
    pause
    boot_menu
}

banner_menu() {
    show_banner
    section_header "Banner / MOTD Settings"
    
    local motd_status border_status
    [[ "$MOTD_ENABLED" == true ]] && motd_status="ON" || motd_status="OFF"
    [[ "$BANNER_BORDER_ENABLED" == true ]] && border_status="ON" || border_status="OFF"
    msg_info "MOTD Status: \033[1;38;2;0;255;136m${motd_status}${RST}"
    msg_info "Active Banner: \033[1;38;2;255;220;0m${CURRENT_BANNER:-ascii-name}${RST}"
    msg_info "Border: \033[1;38;2;0;200;255m${border_status}${RST}  Style: \033[1;38;2;200;100;255m${BANNER_BORDER_STYLE:-cyber-box}${RST}"
    echo ""
    
    menu_item "01" "Toggle MOTD (${motd_status})" "📋" 0 255 136
    menu_item "02" "Preview MOTD" "▶" 0 200 255
    menu_item "03" "Regenerate MOTD" "🔄" 200 100 255
    echo ""
    draw_sep
    msg_info "Banner Switcher"
    menu_item "04" "Switch Banner Style" "🎨" 255 0 200
    menu_item "05" "Preview All Banners" "👁️ " 200 100 255
    menu_item "06" "Preview Current Banner" "🖼️ " 255 165 0
    echo ""
    draw_sep
    msg_info "Border Settings"
    menu_item "07" "Toggle Border (${border_status})" "🔲" 0 200 255
    menu_item "08" "Change Border Style" "✨" 200 100 255
    menu_item "09" "Preview All Border Styles" "👁️ " 0 255 200
    menu_item "00" "← Back" "◀" 100 100 120
    
    prompt_input "Select"
    read -r bmc
    
    case "$bmc" in
        1|01)
            if [[ "$MOTD_ENABLED" == true ]]; then
                MOTD_ENABLED=false
                msg_ok "MOTD disabled"
            else
                MOTD_ENABLED=true
                msg_ok "MOTD enabled"
            fi
            save_config
            pause
            banner_menu
            ;;
        2|02)
            echo ""
            source "${ZORKOS_ASSETS}/motd.sh"
            pause
            banner_menu
            ;;
        3|03)
            msg_ok "MOTD regenerated"
            pause
            banner_menu
            ;;
        4|04)
            banner_switch_menu
            ;;
        5|05)
            clear
            echo ""
            section_header "All Available Banners"
            if type preview_all_banners &>/dev/null; then
                preview_all_banners
            else
                msg_err "Banner engine not loaded"
            fi
            pause
            banner_menu
            ;;
        6|06)
            clear
            echo ""
            section_header "Current Banner: ${CURRENT_BANNER:-ascii-name}"
            if type preview_banner &>/dev/null; then
                preview_banner "${CURRENT_BANNER:-ascii-name}"
            else
                msg_err "Banner engine not loaded"
            fi
            pause
            banner_menu
            ;;
        7|07)
            if [[ "$BANNER_BORDER_ENABLED" == true ]]; then
                BANNER_BORDER_ENABLED=false
                msg_ok "Border disabled"
            else
                BANNER_BORDER_ENABLED=true
                msg_ok "Border enabled"
            fi
            save_config
            if type render_banner_display &>/dev/null; then
                render_banner_display "${CURRENT_BANNER:-ascii-name}" "$BANNER_BORDER_ENABLED" "${BANNER_BORDER_STYLE:-cyber-box}" "true"
            fi
            pause
            banner_menu
            ;;
        8|08)
            border_style_menu
            ;;
        9|09)
            clear
            echo ""
            section_header "All Border Styles — Preview"
            if type preview_border_style &>/dev/null; then
                local bsi=0
                for bsname in "${BORDER_STYLE_NAMES[@]}"; do
                    echo ""
                    printf "  \033[1;38;2;255;220;0m[%02d] %s\033[0m  \033[38;2;100;100;120m— %s\033[0m\n" "$((bsi + 1))" "$bsname" "${BORDER_STYLE_DESCRIPTIONS[$bsi]:-}"
                    echo ""
                    preview_border_style "$bsname"
                    echo ""
                    bsi=$((bsi + 1))
                done
            else
                msg_err "Border engine not loaded"
            fi
            pause
            banner_menu
            ;;
        0|00) main_menu ;;
        *)    banner_menu ;;
    esac
}

border_style_menu() {
    show_banner
    section_header "Choose Border Style"
    
    msg_info "Current: \033[1;38;2;255;220;0m${BANNER_BORDER_STYLE:-cyber-box}${RST}"
    echo ""
    
    local bsi=0
    if [[ ${#BORDER_STYLE_NAMES[@]} -gt 0 ]]; then
        for bsname in "${BORDER_STYLE_NAMES[@]}"; do
            local marker="  "
            [[ "$bsname" == "${BANNER_BORDER_STYLE:-cyber-box}" ]] && marker="▸ "
            local num
            printf -v num "%02d" "$((bsi + 1))"
            
            if [[ "$bsname" == "${BANNER_BORDER_STYLE:-cyber-box}" ]]; then
                printf "  \033[38;2;60;60;80m  [\033[1;38;2;255;220;0m%s\033[0;38;2;60;60;80m] \033[1;38;2;0;255;200m%s%s \033[38;2;100;100;120m— %s \033[38;2;0;255;136m✓${RST}\n" "$num" "$marker" "$bsname" "${BORDER_STYLE_DESCRIPTIONS[$bsi]:-}"
            else
                printf "  \033[38;2;60;60;80m  [\033[1;38;2;0;255;136m%s\033[0;38;2;60;60;80m] \033[38;2;0;200;255m%s%s \033[38;2;100;100;120m— %s${RST}\n" "$num" "$marker" "$bsname" "${BORDER_STYLE_DESCRIPTIONS[$bsi]:-}"
            fi
            bsi=$((bsi + 1))
        done
    fi
    
    echo ""
    menu_item "00" "← Back" "◀" 100 100 120
    
    prompt_input "Select Border"
    read -r bsc
    
    case "$bsc" in
        0|00) banner_menu ;;
        *)
            if [[ "$bsc" =~ ^[0-9]+$ ]]; then
                local sel=$((10#$bsc - 1))
                if [[ $sel -ge 0 ]] && [[ $sel -lt ${#BORDER_STYLE_NAMES[@]} ]]; then
                    BANNER_BORDER_STYLE="${BORDER_STYLE_NAMES[$sel]}"
                    BANNER_BORDER_ENABLED=true
                    save_config
                    msg_ok "Border style: \033[1;38;2;255;220;0m${BANNER_BORDER_STYLE}${RST}"
                    echo ""
                    if type render_banner_display &>/dev/null; then
                        render_banner_display "${CURRENT_BANNER:-ascii-name}" "true" "$BANNER_BORDER_STYLE" "true"
                    fi
                    pause
                    banner_menu
                else
                    msg_err "Invalid selection"
                    pause
                    border_style_menu
                fi
            else
                msg_err "Enter a number"
                pause
                border_style_menu
            fi
            ;;
    esac
}

banner_switch_menu() {
    show_banner
    section_header "Switch Banner Style"
    
    msg_info "Current: \033[1;38;2;255;220;0m${CURRENT_BANNER:-ascii-name}${RST}"
    echo ""
    
    local i=0
    if [[ ${#BANNER_NAMES[@]} -gt 0 ]]; then
        for bname in "${BANNER_NAMES[@]}"; do
            local marker="  "
            [[ "$bname" == "${CURRENT_BANNER:-ascii-name}" ]] && marker="▸ "
            local num
            printf -v num "%02d" "$((i + 1))"
            
            local _bidx=$i
            local _r=0 _g=255 _b=136
            local _first_color=""
            case "$_bidx" in
                0) _first_color="${BANNER_GRADIENT_0[0]:-}" ;;
                1) _first_color="${BANNER_GRADIENT_1[0]:-}" ;;
                2) _first_color="${BANNER_GRADIENT_2[0]:-}" ;;
                3) _first_color="${BANNER_GRADIENT_3[0]:-}" ;;
                4) _first_color="${BANNER_GRADIENT_4[0]:-}" ;;
                5) _first_color="${BANNER_GRADIENT_5[0]:-}" ;;
                6) _first_color="${BANNER_GRADIENT_6[0]:-}" ;;
                7) _first_color="${BANNER_GRADIENT_7[0]:-}" ;;
                8) _first_color="${BANNER_GRADIENT_8[0]:-}" ;;
                9) _first_color="${BANNER_GRADIENT_9[0]:-}" ;;
                10) _first_color="${BANNER_GRADIENT_10[0]:-}" ;;
            esac
            if [[ -n "$_first_color" ]]; then
                _r="${_first_color%%,*}"
                local _rest="${_first_color#*,}"
                _g="${_rest%%,*}"
                _b="${_rest#*,}"
            fi
            
            if [[ "$bname" == "${CURRENT_BANNER:-ascii-name}" ]]; then
                printf "  \033[38;2;60;60;80m  [\033[1;38;2;255;220;0m%s\033[0;38;2;60;60;80m] \033[1;38;2;%d;%d;%dm%s%s \033[38;2;100;100;120m— %s \033[38;2;0;255;136m✓${RST}\n" "$num" "$_r" "$_g" "$_b" "$marker" "$bname" "${BANNER_DESCRIPTIONS[$i]:-}"
            else
                printf "  \033[38;2;60;60;80m  [\033[1;38;2;0;255;136m%s\033[0;38;2;60;60;80m] \033[38;2;%d;%d;%dm%s%s \033[38;2;100;100;120m— %s${RST}\n" "$num" "$_r" "$_g" "$_b" "$marker" "$bname" "${BANNER_DESCRIPTIONS[$i]:-}"
            fi
            i=$((i + 1))
        done
    fi
    
    echo ""
    menu_item "00" "← Back" "◀" 100 100 120
    
    prompt_input "Select Banner"
    read -r bsc
    
    case "$bsc" in
        0|00) banner_menu ;;
        *)
            if [[ "$bsc" =~ ^[0-9]+$ ]]; then
                local sel=$((10#$bsc - 1))
                if [[ $sel -ge 0 ]] && [[ $sel -lt ${#BANNER_NAMES[@]} ]]; then
                    CURRENT_BANNER="${BANNER_NAMES[$sel]}"
                    save_config
                    msg_ok "Banner changed to: \033[1;38;2;255;220;0m${CURRENT_BANNER}${RST}"
                    echo ""
                    if type preview_banner &>/dev/null; then
                        preview_banner "$CURRENT_BANNER"
                    fi
                    pause
                    banner_menu
                else
                    msg_err "Invalid banner number"
                    pause
                    banner_switch_menu
                fi
            else
                msg_err "Enter a number"
                pause
                banner_switch_menu
            fi
            ;;
    esac
}

set_terminal_lock() {
    prompt_password "Create Lock Password"
    read -s new_pass
    echo
    prompt_password "Confirm Password"
    read -s confirm_pass
    echo
    
    if [[ "$new_pass" != "$confirm_pass" ]]; then
        msg_err "Passwords don't match!"
        return
    fi
    
    local pass_hash
    pass_hash=$(echo -n "$new_pass" | sha256sum | cut -d' ' -f1)
    echo "$pass_hash" > "${ZORKOS_HOME}/.lock_hash"
    
    local lock_code="#ZORKOS_LOCK_START
clear
_zork_lock_check() {
    local stored_hash
    stored_hash=\$(cat \"\$HOME/.zorkos/.lock_hash\" 2>/dev/null)
    [[ -z \"\$stored_hash\" ]] && return 0
    
    local attempt=1
    while [[ \$attempt -le 3 ]]; do
        echo -e \"\n\033[38;2;0;255;136m  ╭─── 🔒 SECURE TERMINAL ───────────────\"
        echo -e \"  │  \033[38;2;255;60;60mAuthentication Required\033[0m\"
        echo -e \"  ╰───────────────────────────────────────\033[0m\"
        echo -ne \"  \033[38;2;0;200;255m[Attempt \$attempt/3] Password: \033[0m\"
        read -s pass_input
        echo
        local input_hash
        input_hash=\$(echo -n \"\$pass_input\" | sha256sum | cut -d' ' -f1)
        if [[ \"\$input_hash\" == \"\$stored_hash\" ]]; then
            echo -e \"  \033[38;2;0;255;136m✓ ACCESS GRANTED\033[0m\"
            sleep 0.5
            clear
            return 0
        else
            echo -e \"  \033[38;2;255;60;60m✗ ACCESS DENIED\033[0m\"
            attempt=\$((attempt + 1))
        fi
    done
    echo -e \"  \033[38;2;255;60;60m⚠ Too many failed attempts. Exiting.\033[0m\"
    sleep 1
    exit 1
}
_zork_lock_check
#ZORKOS_LOCK_END"

    for rcfile in ~/.zshrc ~/.bashrc; do
        if [[ -f "$rcfile" ]]; then
            sed -i '/#ZORKOS_LOCK_START/,/#ZORKOS_LOCK_END/d' "$rcfile"
            local tmp=$(mktemp)
            echo "$lock_code" > "$tmp"
            cat "$rcfile" >> "$tmp"
            mv "$tmp" "$rcfile"
        fi
    done
    
    msg_ok "Terminal lock configured with hashed password!"
}

remove_terminal_lock() {
    for rcfile in ~/.zshrc ~/.bashrc; do
        [[ -f "$rcfile" ]] && sed -i '/#ZORKOS_LOCK_START/,/#ZORKOS_LOCK_END/d' "$rcfile"
    done
    rm -f "${ZORKOS_HOME}/.lock_hash"
    msg_ok "Terminal lock removed"
}

backup_menu() {
    show_banner
    section_header "Backup & Restore"
    
    menu_item "01" "Create Backup" "💾" 0 255 136
    menu_item "02" "List Backups" "📋" 0 200 255
    menu_item "03" "Restore Backup" "🔄" 200 100 255
    menu_item "00" "← Back" "◀" 100 100 120
    
    prompt_input "Select"
    read -r bkc
    
    case "$bkc" in
        1|01) create_backup; pause; backup_menu ;;
        2|02) list_backups; pause; backup_menu ;;
        3|03)
            list_backups
            prompt_text "Restore Backup" "enter backup name"
            read -r bname
            restore_backup "$bname"
            pause
            backup_menu
            ;;
        0|00) main_menu ;;
        *)    backup_menu ;;
    esac
}

sound_toggle() {
    if [[ "$SOUND_ENABLED" == true ]]; then
        SOUND_ENABLED=false
        msg_ok "Sound: OFF"
    else
        SOUND_ENABLED=true
        msg_ok "Sound: ON"
    fi
    save_config
}

sound_menu() {
    show_banner
    section_header "Sound Settings"

    local RST="\033[0m"
    local CYN="\033[38;2;0;200;255m"
    local GRN="\033[38;2;0;255;136m"
    local YLW="\033[38;2;255;220;0m"
    local DIM="\033[38;2;100;100;120m"

    local snd_status="OFF"
    local snd_clr="\033[38;2;255;60;60m"
    if [[ "$SOUND_ENABLED" == true ]]; then
        snd_status="ON"
        snd_clr="\033[38;2;0;255;136m"
    fi

    echo ""
    echo -e "  ${DIM}  Status:     ${snd_clr}${snd_status}${RST}"
    echo -e "  ${DIM}  Active:     ${YLW}${BOOT_SOUND_FILE}${RST}"
    echo ""
    draw_sep

    local snd_dir="${ZORKOS_HOME}/bootsound"
    local sounds=()
    local idx=1

    if [[ -d "$snd_dir" ]]; then
        while IFS= read -r f; do
            sounds+=("$(basename "$f")")
        done < <(find "$snd_dir" -maxdepth 1 -type f -name '*.mp3' 2>/dev/null | sort)
    fi

    echo ""
    menu_item "01" "Toggle Sound ON/OFF" "🔊" 200 200 255
    echo ""

    if [[ ${#sounds[@]} -gt 0 ]]; then
        echo -e "  ${CYN}  ── Available Boot Sounds ──${RST}"
        echo ""
        for ((i=0; i<${#sounds[@]}; i++)); do
            local num=$(printf "%02d" $((i + 2)))
            local sfile="${sounds[$i]}"
            local marker=""
            if [[ "$sfile" == "$BOOT_SOUND_FILE" ]]; then
                marker=" \033[38;2;0;255;136m◄ active${RST}"
            fi
            echo -e "  ${CYN}  [${num}]${RST}  ${YLW}${sfile}${RST}${marker}"
        done
    else
        echo -e "  ${DIM}  No .mp3 files in bootsound/${RST}"
    fi

    echo ""
    menu_item "00" "Back" "↩" 100 100 120
    echo ""
    draw_sep

    prompt_input "Select"
    read -r schoice

    case "$schoice" in
        0|00) main_menu ;;
        1|01)
            sound_toggle
            pause; sound_menu ;;
        *)
            local sidx=$((schoice - 2))
            if [[ $sidx -ge 0 && $sidx -lt ${#sounds[@]} ]]; then
                BOOT_SOUND_FILE="${sounds[$sidx]}"
                SOUND_ENABLED=true
                save_config
                msg_ok "Boot sound set to: ${BOOT_SOUND_FILE}"
                msg_ok "Sound: ON"
                if type _play_mp3 &>/dev/null; then
                    _play_mp3 "${snd_dir}/${BOOT_SOUND_FILE}"
                    msg_info "Playing preview..."
                fi
            else
                msg_warn "Invalid option"
            fi
            pause; sound_menu ;;
    esac
}

system_info() {
    show_banner
    section_header "System Information"
    
    echo -e "  \033[38;2;0;200;255m  ZorkOS\033[38;2;60;60;80m ──────────────────────────────${RST}"
    echo -e "  \033[38;2;100;100;120m  Version    \033[38;2;0;255;136m${VERSION}${RST}"
    echo -e "  \033[38;2;100;100;120m  Build      \033[38;2;0;255;136m${BUILD_DATE}${RST}"
    echo -e "  \033[38;2;100;100;120m  Author     \033[38;2;0;255;136m${AUTHOR}${RST}"
    echo -e "  \033[38;2;100;100;120m  Theme      \033[38;2;0;200;255m${CURRENT_THEME}${RST}"
    echo -e "  \033[38;2;100;100;120m  Colors     \033[38;2;200;100;255m${CURRENT_COLOR_SCHEME}${RST}"
    echo -e "  \033[38;2;100;100;120m  Boot       \033[38;2;255;165;0m${BOOT_ANIMATION}${RST}"
    echo -e "  \033[38;2;100;100;120m  Sound      \033[38;2;255;220;0m${SOUND_ENABLED}${RST}  \033[38;2;100;100;120m[\033[38;2;200;200;255m${BOOT_SOUND_FILE}\033[38;2;100;100;120m]${RST}"
    echo ""
    echo -e "  \033[38;2;255;0;200m  System\033[38;2;60;60;80m ──────────────────────────────${RST}"
    echo -e "  \033[38;2;100;100;120m  OS         \033[38;2;0;255;136m$(uname -o 2>/dev/null || echo 'N/A')${RST}"
    echo -e "  \033[38;2;100;100;120m  Kernel     \033[38;2;0;255;136m$(uname -r 2>/dev/null | cut -d'-' -f1)${RST}"
    echo -e "  \033[38;2;100;100;120m  Arch       \033[38;2;0;255;136m$(uname -m 2>/dev/null)${RST}"
    echo -e "  \033[38;2;100;100;120m  Shell      \033[38;2;0;200;255m$(basename "$SHELL" 2>/dev/null)${RST}"
    echo -e "  \033[38;2;100;100;120m  Terminal   \033[38;2;0;200;255m${TERM}${RST}"
    echo -e "  \033[38;2;100;100;120m  Columns    \033[38;2;255;165;0m${COLS}${RST}"
    echo -e "  \033[38;2;100;100;120m  Lines      \033[38;2;255;165;0m${ROWS}${RST}"
    echo -e "  \033[38;2;100;100;120m  User       \033[38;2;255;220;0m$(whoami 2>/dev/null)${RST}"
    echo -e "  \033[38;2;100;100;120m  Home       \033[38;2;200;100;255m${HOME}${RST}"
    echo -e "  \033[38;2;100;100;120m  Packages   \033[38;2;80;180;255m$(dpkg --list 2>/dev/null | wc -l || echo '?')${RST}"
    echo ""
    
    echo -e "  \033[38;2;0;255;200m  Resources\033[38;2;60;60;80m ─────────────────────────────${RST}"
    echo -e "  \033[38;2;100;100;120m  Memory    \033[38;2;200;100;255m$(free -h 2>/dev/null | awk '/Mem:/{print $3 "/" $2}' || echo 'N/A')${RST}"
    echo -e "  \033[38;2;100;100;120m  Disk      \033[38;2;255;0;200m$(df -h / 2>/dev/null | awk 'NR==2{print $3 "/" $2}' || echo 'N/A')${RST}"
    echo -e "  \033[38;2;100;100;120m  CPU       \033[38;2;255;165;0m$(nproc 2>/dev/null || echo '?') cores${RST}"
    echo ""
    
    pause
    main_menu
}

advanced_menu() {
    show_banner
    section_header "Advanced Configuration"
    
    menu_item "01" "Edit .zshrc manually" "📝" 0 255 136
    menu_item "02" "Regenerate .zshrc" "🔄" 0 200 255
    menu_item "03" "Edit Termux properties" "📝" 200 100 255
    menu_item "04" "Install FIGlet fonts" "🔤" 255 165 0
    menu_item "05" "Clear ZorkOS cache" "🧹" 255 60 60
    menu_item "06" "Reset to defaults" "⚠️ " 255 220 0
    menu_item "07" "Export config" "📤" 0 255 200
    menu_item "08" "Import config" "📥" 80 180 255
    menu_item "00" "← Back" "◀" 100 100 120
    
    prompt_input "Select"
    read -r ac
    
    case "$ac" in
        1|01) nano ~/.zshrc 2>/dev/null || vi ~/.zshrc; advanced_menu ;;
        2|02) write_zshrc "$CURRENT_THEME" "$BOOT_ANIMATION"; msg_ok ".zshrc regenerated"; pause; advanced_menu ;;
        3|03) nano "${TERMUX_DIR}/termux.properties" 2>/dev/null; advanced_menu ;;
        4|04)
            msg_wait "Installing FIGlet fonts..."
            pkg install -y figlet toilet 2>/dev/null
            msg_ok "FIGlet ready"
            pause
            advanced_menu
            ;;
        5|05)
            rm -rf "${ZORKOS_HOME}/cache" 2>/dev/null
            mkdir -p "${ZORKOS_HOME}/cache"
            msg_ok "Cache cleared"
            pause
            advanced_menu
            ;;
        6|06)
            prompt_confirm "Reset everything to defaults?"
            read -r confirm
            if [[ "$confirm" == "y" ]] || [[ "$confirm" == "Y" ]]; then
                create_backup
                CURRENT_THEME="zork-2026"
                CURRENT_COLOR_SCHEME="zork-default"
                BOOT_ANIMATION="default"
                SOUND_ENABLED=false
                MOTD_ENABLED=true
                save_config
                write_zshrc "zork-2026" "default"
                apply_color_scheme "zork-default"
                msg_ok "Reset to defaults (backup saved)"
            fi
            pause
            advanced_menu
            ;;
        7|07)
            local export_path="${HOME}/zorkos_config_export.tar.gz"
            tar -czf "$export_path" -C "$HOME" .zorkos 2>/dev/null
            msg_ok "Config exported: ${export_path}"
            pause
            advanced_menu
            ;;
        8|08)
            prompt_text "Config Archive Path" "path to .tar.gz"
            read -r import_path
            if [[ -f "$import_path" ]]; then
                tar -xzf "$import_path" -C "$HOME" 2>/dev/null
                load_config
                msg_ok "Config imported!"
            else
                msg_err "File not found: ${import_path}"
            fi
            pause
            advanced_menu
            ;;
        0|00) main_menu ;;
        *)    advanced_menu ;;
    esac
}

update_zorkos() {
    show_banner
    section_header "Update ZorkOS"
    
    local REPO_URL="https://github.com/samay825/ZorkOS-Termux.git"
    # Use Termux-compatible temp directory ($TMPDIR or $PREFIX/tmp, NOT /tmp)
    local _tmpbase="${TMPDIR:-${PREFIX}/tmp}"
    [[ ! -d "$_tmpbase" ]] && _tmpbase="/data/data/com.termux/files/usr/tmp"
    [[ ! -d "$_tmpbase" ]] && mkdir -p "$_tmpbase" 2>/dev/null
    local UPDATE_DIR="${_tmpbase}/zorkos-update-$$"
    
    msg_info "Current version: v${VERSION}"
    msg_info "Repo: github.com/samay825/ZorkOS-Termux"
    echo ""
    
    prompt_confirm "Check for updates & install?"
    read -r confirm
    [[ "$confirm" != "y" ]] && [[ "$confirm" != "Y" ]] && { main_menu; return; }
    
    echo ""
    
    if ! command -v git &>/dev/null; then
        msg_err "Git not installed! Installing..."
        pkg install -y git 2>/dev/null
        if ! command -v git &>/dev/null; then
            msg_err "Git install failed. Cannot update."
            pause; main_menu; return
        fi
    fi
    
    # ── Internet connectivity check ──
    msg_wait "Checking internet connection..."
    local _net_ok=false
    local _net_err=""
    
    # Method 1: curl (most reliable on Termux)
    if command -v curl &>/dev/null; then
        if curl -sS --connect-timeout 8 --max-time 12 -o /dev/null "https://github.com" 2>/dev/null; then
            _net_ok=true
        fi
    fi
    
    # Method 2: wget fallback
    if [[ "$_net_ok" == "false" ]] && command -v wget &>/dev/null; then
        if wget -q --spider --timeout=8 "https://github.com" 2>/dev/null; then
            _net_ok=true
        fi
    fi
    
    # Method 3: ping fallback (may not work without root on some devices)
    if [[ "$_net_ok" == "false" ]]; then
        if ping -c 1 -W 5 github.com &>/dev/null 2>&1; then
            _net_ok=true
        fi
    fi
    
    if [[ "$_net_ok" == "false" ]]; then
        msg_err "No internet connection detected!"
        msg_info "Troubleshooting tips:"
        echo -e "  ${DIM}  1. Check WiFi/Mobile Data is ON${RST}"
        echo -e "  ${DIM}  2. Try: ${WHITE}curl -v https://github.com${DIM} to debug${RST}"
        echo -e "  ${DIM}  3. If on restricted network, try a VPN${RST}"
        echo -e "  ${DIM}  4. Run: ${WHITE}pkg install resolv-conf${DIM} to fix DNS${RST}"
        pause; main_menu; return
    fi
    msg_ok "Internet connection OK"
    echo ""
    
    # ── Clone with retry and visible errors ──
    msg_wait "Cloning latest version..."
    rm -rf "$UPDATE_DIR" 2>/dev/null
    local _clone_ok=false
    local _clone_err=""
    local _attempt
    
    for _attempt in 1 2 3; do
        _clone_err=$(git clone --depth=1 "$REPO_URL" "$UPDATE_DIR" 2>&1)
        if [[ $? -eq 0 ]]; then
            _clone_ok=true
            break
        fi
        rm -rf "$UPDATE_DIR" 2>/dev/null
        if [[ $_attempt -lt 3 ]]; then
            msg_warn "Clone attempt ${_attempt} failed, retrying in 3s..."
            sleep 3
        fi
    done
    
    if [[ "$_clone_ok" == "false" ]]; then
        msg_err "Failed to fetch updates after 3 attempts."
        msg_err "Git error: ${_clone_err}"
        echo ""
        msg_info "Possible fixes:"
        echo -e "  ${DIM}  1. Check internet: ${WHITE}curl https://github.com${RST}"
        echo -e "  ${DIM}  2. Fix DNS: ${WHITE}echo 'nameserver 8.8.8.8' > \$PREFIX/etc/resolv.conf${RST}"
        echo -e "  ${DIM}  3. Fix SSL: ${WHITE}pkg install ca-certificates${RST}"
        echo -e "  ${DIM}  4. Fix storage: check free space with ${WHITE}df -h${RST}"
        rm -rf "$UPDATE_DIR" 2>/dev/null
        pause; main_menu; return
    fi
    
    local REMOTE_VERSION=""
    if [[ -f "${UPDATE_DIR}/zork_customizer.sh" ]]; then
        REMOTE_VERSION=$(grep '^VERSION=' "${UPDATE_DIR}/zork_customizer.sh" 2>/dev/null | head -1 | cut -d'"' -f2)
    fi
    
    if [[ -z "$REMOTE_VERSION" ]]; then
        msg_warn "Could not detect remote version"
        REMOTE_VERSION="unknown"
    fi
    
    echo ""
    msg_info "Installed: v${VERSION}"
    msg_info "Latest:    v${REMOTE_VERSION}"
    echo ""
    
    if [[ "$REMOTE_VERSION" == "$VERSION" ]]; then
        msg_ok "You're already on the latest version!"
        echo ""
        prompt_confirm "Force re-install anyway?"
        read -r force
        if [[ "$force" != "y" ]] && [[ "$force" != "Y" ]]; then
            rm -rf "$UPDATE_DIR" 2>/dev/null
            pause; main_menu; return
        fi
    fi
    
    echo ""
    msg_wait "Creating backup before update..."
    if type create_backup &>/dev/null; then
        create_backup
    else
        cp -r "${ZORKOS_HOME}" "${ZORKOS_HOME}.bak.$(date +%Y%m%d%H%M%S)" 2>/dev/null
        msg_ok "Backup saved"
    fi
    
    echo ""
    msg_wait "Updating ZorkOS modules..."
    
    for _lib in gradient_engine animations plugin_manager backup_restore zshrc_generator responsive auth_system weather screensaver achievements pomodoro quick_notes bookmarks dashboard hacker_mode name_banner banners; do
        if [[ -f "${UPDATE_DIR}/lib/${_lib}.sh" ]]; then
            cp "${UPDATE_DIR}/lib/${_lib}.sh" "${ZORKOS_HOME}/lib/" 2>/dev/null
        fi
    done
    msg_ok "17 modules updated"
    
    msg_wait "Updating themes..."
    if [[ -d "${UPDATE_DIR}/themes" ]]; then
        cp "${UPDATE_DIR}/themes/"*.zsh-theme "${HOME}/.oh-my-zsh/themes/" 2>/dev/null
        cp "${UPDATE_DIR}/themes/"*.zsh-theme "${ZORKOS_HOME}/themes/" 2>/dev/null
        mkdir -p "${HOME}/.oh-my-zsh/custom/themes" 2>/dev/null
        cp "${UPDATE_DIR}/themes/zork-2026.zsh-theme" "${HOME}/.oh-my-zsh/custom/themes/" 2>/dev/null
    fi
    msg_ok "Themes updated"
    
    msg_wait "Updating configs..."
    if [[ -d "${UPDATE_DIR}/configs" ]]; then
        cp "${UPDATE_DIR}/configs/"* "${ZORKOS_HOME}/configs/" 2>/dev/null
    fi
    msg_ok "Configs updated"
    
    msg_wait "Updating assets..."
    if [[ -f "${UPDATE_DIR}/assets/motd.sh" ]]; then
        cp "${UPDATE_DIR}/assets/motd.sh" "${ZORKOS_HOME}/assets/" 2>/dev/null
    fi
    if [[ -d "${UPDATE_DIR}/bootsound" ]]; then
        cp "${UPDATE_DIR}/bootsound/"*.mp3 "${ZORKOS_HOME}/bootsound/" 2>/dev/null
    fi
    msg_ok "Assets updated"
    
    msg_wait "Updating customizer..."
    if [[ -f "${UPDATE_DIR}/zork_customizer.sh" ]]; then
        cp "${UPDATE_DIR}/zork_customizer.sh" "${ZORKOS_HOME}/zork_customizer.sh" 2>/dev/null
        chmod +x "${ZORKOS_HOME}/zork_customizer.sh" 2>/dev/null
    fi
    msg_ok "Customizer updated"
    
    msg_wait "Regenerating .zshrc..."
    source "${ZORKOS_HOME}/lib/zshrc_generator.sh" 2>/dev/null
    if type write_zshrc &>/dev/null; then
        write_zshrc "${CURRENT_THEME:-zork-2026}" "${BOOT_ANIMATION:-default}"
        msg_ok ".zshrc regenerated"
    else
        msg_warn ".zshrc not regenerated — do it manually from Advanced Config"
    fi
    
    rm -rf "$UPDATE_DIR" 2>/dev/null
    
    echo ""
    draw_sep
    echo ""
    msg_ok "ZorkOS updated to v${REMOTE_VERSION}!"
    msg_info "Restart Termux to apply all changes."
    echo ""
    gradient_text "  ⚡ Update Complete — ZorkOS v${REMOTE_VERSION} ⚡" "${GRADIENT_ZORK[@]}" 2>/dev/null
    echo ""
    
    pause
    main_menu
}

auth_menu() {
    show_banner
    section_header "Terminal Security"
    
    local auth_status="DISABLED"
    [[ -f "${ZORKOS_HOME}/auth/auth.conf" ]] && source "${ZORKOS_HOME}/auth/auth.conf"
    [[ "${AUTH_ENABLED}" == "true" ]] && auth_status="ENABLED"
    msg_info "Auth Status: \033[1;38;2;0;255;136m${auth_status}${RST}"
    echo ""
    
    menu_item "01" "Enable/Disable Auth" "🔐" 0 255 136
    menu_item "02" "Create New User" "👤" 0 200 255
    menu_item "03" "Change Password" "🔑" 200 100 255
    menu_item "04" "List Users" "📋" 255 165 0
    menu_item "05" "Delete User" "🗑️ " 255 60 60
    menu_item "06" "Configure Idle Lock" "⏰" 255 220 0
    menu_item "07" "View Login Log" "📜" 100 200 255
    menu_item "08" "Login Screen Preview" "👁️ " 255 0 200
    echo ""
    draw_sep
    msg_info "Terminal Lock"
    menu_item "09" "Set Lock Password" "🔒" 0 255 136
    menu_item "10" "Remove Lock" "🔓" 255 60 60
    menu_item "00" "← Back" "◀" 100 100 120
    
    prompt_input "Select"
    read -r ac
    
    case "$ac" in
        1|01)
            mkdir -p "${ZORKOS_HOME}/auth"
            local conf="${ZORKOS_HOME}/auth/auth.conf"
            if [[ "${AUTH_ENABLED}" == "true" ]]; then
                sed -i 's/AUTH_ENABLED=.*/AUTH_ENABLED=false/' "$conf" 2>/dev/null
                AUTH_ENABLED="false"
                msg_ok "Auth DISABLED"
            else
                [[ ! -f "$conf" ]] && echo -e "AUTH_ENABLED=true\nIDLE_LOCK=false\nIDLE_TIMEOUT=300\nMAX_ATTEMPTS=5\nLOCKOUT_TIME=300" > "$conf"
                sed -i 's/AUTH_ENABLED=.*/AUTH_ENABLED=true/' "$conf" 2>/dev/null
                AUTH_ENABLED="true"
                rm -f "${ZORKOS_HOME}/auth/session" 2>/dev/null
                msg_ok "Auth ENABLED"
                if [[ ! -f "${ZORKOS_HOME}/auth/users.db" ]] || [[ ! -s "${ZORKOS_HOME}/auth/users.db" ]]; then
                    if type _auth_first_time_setup &>/dev/null; then
                        _auth_first_time_setup
                    else
                        prompt_text "Admin Username" "first user"
                        read -r _ftu_user
                        prompt_password "Password"
                        read -rs _ftu_pass
                        echo ""
                        if type auth_create_user &>/dev/null; then
                            auth_create_user "$_ftu_user" "$_ftu_pass" "admin"
                        else
                            msg_err "Auth system not loaded. Re-install ZorkOS."
                        fi
                    fi
                fi
            fi
            if type write_zshrc &>/dev/null; then
                write_zshrc "${CURRENT_THEME:-zork-2026}" "${BOOT_ANIMATION:-default}"
                msg_ok ".zshrc regenerated — change active on next terminal open"
            fi
            pause; auth_menu ;;
        2|02)
            prompt_text "Username" "new user"
            read -r newuser
            prompt_password "Password"
            read -rs newpass
            echo ""
            auth_create_user "$newuser" "$newpass"
            pause; auth_menu ;;
        3|03)
            prompt_text "Username"
            read -r chuser
            auth_change_password "$chuser"
            pause; auth_menu ;;
        4|04)
            auth_list_users
            pause; auth_menu ;;
        5|05)
            auth_list_users
            prompt_text "Delete User" "username"
            read -r deluser
            auth_delete_user "$deluser"
            pause; auth_menu ;;
        6|06)
            local conf="${ZORKOS_HOME}/auth/auth.conf"
            [[ -f "$conf" ]] && source "$conf"
            if [[ "${IDLE_LOCK}" == "true" ]]; then
                sed -i 's/IDLE_LOCK=.*/IDLE_LOCK=false/' "$conf"
                msg_ok "Idle lock DISABLED"
            else
                sed -i 's/IDLE_LOCK=.*/IDLE_LOCK=true/' "$conf"
                msg_ok "Idle lock ENABLED (timeout: ${IDLE_TIMEOUT:-300}s)"
            fi
            pause; auth_menu ;;
        7|07)
            auth_view_log
            pause; auth_menu ;;
        8|08)
            if type auth_login_preview &>/dev/null; then
                auth_login_preview
            else
                msg_err "Auth preview not available. Re-install ZorkOS."
                pause
            fi
            auth_menu ;;
        9|09)
            set_terminal_lock
            pause; auth_menu ;;
        10)
            remove_terminal_lock
            pause; auth_menu ;;
        0|00) main_menu ;;
        *)    auth_menu ;;
    esac
}

dashboard_menu() {
    show_banner
    section_header "System Dashboard"
    
    menu_item "01" "Full Dashboard" "📊" 0 255 136
    menu_item "02" "Live Monitor (5s)" "📈" 0 200 255
    menu_item "03" "Compact View" "📋" 200 100 255
    menu_item "00" "← Back" "◀" 100 100 120
    
    prompt_input "Select"
    read -r dc
    
    case "$dc" in
        1|01) clear; system_dashboard; pause; dashboard_menu ;;
        2|02) system_dashboard_live ;;
        3|03) clear; echo ""; dashboard_compact; echo ""; pause; dashboard_menu ;;
        0|00) main_menu ;;
        *)    dashboard_menu ;;
    esac
}

achievements_menu() {
    show_banner
    section_header "Achievements & XP"
    
    local xp_info _is_admin
    xp_info=$(get_xp_progress)
    _is_admin=$(grep "^ADMIN_MODE=true" "$HOME/.zorkos/user.conf" 2>/dev/null)
    echo -e "  ${xp_info}"
    [[ -n "$_is_admin" ]] && echo -e "  \033[38;2;255;215;0m  🔐 Admin Elite — All Perks Active${RST}"
    echo ""
    
    menu_item "01" "View All Achievements" "🏆" 255 215 0
    menu_item "02" "XP Stats & Level" "⭐" 0 255 136
    menu_item "03" "Level Rewards & Perks" "👑" 255 0 200
    menu_item "04" "Streak Info" "🔥" 255 100 50
    menu_item "05" "Reset Stats" "🔄" 255 60 60
    menu_item "00" "← Back" "◀" 100 100 120
    
    prompt_input "Select"
    read -r xc
    
    case "$xc" in
        1|01) clear; show_all_achievements_list; pause; achievements_menu ;;
        2|02)
            clear
            echo ""
            section_header "XP & Level"
            local stats_db="${ZORKOS_HOME}/achievements/stats.db"
            if [[ -f "$stats_db" ]]; then
                source "$stats_db"
                local level
                level=$(get_xp_level)
                echo ""
                echo -e "  \033[38;2;255;215;0m  ⚡ Level: ${level}${RST}"
                echo -e "  \033[38;2;0;255;136m  💎 Total XP: ${TOTAL_XP:-0}${RST}"
                echo ""
                echo -e "  \033[38;2;60;60;80m  ──────────────────────────────${RST}"
                echo -e "  \033[38;2;0;200;255m  ⌨️  Commands Run: ${TOTAL_COMMANDS:-0}${RST}"
                echo -e "  \033[38;2;200;100;255m  🖥️  Sessions: ${TOTAL_SESSIONS:-0}${RST}"
                echo -e "  \033[38;2;0;255;136m  🔀 Git Commits: ${GIT_COMMITS:-0}${RST}"
                echo -e "  \033[38;2;255;0;200m  🎨 Themes Changed: ${THEME_CHANGES:-0}${RST}"
                echo -e "  \033[38;2;255;165;0m  🔌 Plugins Installed: ${PLUGINS_INSTALLED:-0}${RST}"
                echo -e "  \033[38;2;255;100;50m  🔥 Current Streak: ${CURRENT_STREAK:-0} days${RST}"
                echo -e "  \033[38;2;255;220;0m  🏅 Best Streak: ${BEST_STREAK:-0} days${RST}"
                echo -e "  \033[38;2;0;200;255m  ⏱️  Longest Session: $(( ${LONGEST_SESSION:-0} / 60 )) min${RST}"
                echo ""
                get_xp_progress
            else
                msg_warn "No stats recorded yet. Use your terminal to earn XP!"
            fi
            pause; achievements_menu ;;
        3|03) clear; get_level_rewards; pause; achievements_menu ;;
        4|04)
            clear
            echo ""
            section_header "Streak Tracker"
            update_streak
            local stats_db="${ZORKOS_HOME}/achievements/stats.db"
            [[ -f "$stats_db" ]] && source "$stats_db"
            echo ""
            echo -e "  \033[38;2;255;100;50m  🔥 Current Streak: ${CURRENT_STREAK:-0} days${RST}"
            echo -e "  \033[38;2;255;215;0m  🏅 Best Streak: ${BEST_STREAK:-0} days${RST}"
            echo -e "  \033[38;2;0;200;255m  📅 Last Active: ${LAST_LOGIN_DATE:-never}${RST}"
            echo ""
            echo -e "  \033[38;2;60;60;80m  ── Streak Rewards ──${RST}"
            echo -e "  \033[38;2;100;100;120m    3 days  → +30 XP  🔥 Three Days Strong${RST}"
            echo -e "  \033[38;2;100;100;120m    7 days  → +100 XP 🏆 Week Warrior${RST}"
            echo -e "  \033[38;2;100;100;120m   30 days  → +500 XP 👑 Monthly Master${RST}"
            echo -e "  \033[38;2;100;100;120m  100 days  → +2000 XP 🌟 Century Streak${RST}"
            echo ""
            pause; achievements_menu ;;
        5|05)
            prompt_confirm "Reset ALL stats and achievements?"
            read -r confirm
            if [[ "$confirm" == "y" ]]; then
                rm -f "${ZORKOS_HOME}/achievements/stats.db"
                rm -f "${ZORKOS_HOME}/achievements/achievements.db"
                msg_ok "Stats reset!"
            fi
            pause; achievements_menu ;;
        0|00) main_menu ;;
        *)    achievements_menu ;;
    esac
}

pomodoro_menu() {
    show_banner
    section_header "Pomodoro Timer"
    
    msg_info "Focus sessions with XP rewards!"
    echo ""
    
    menu_item "01" "Start Pomodoro (25min)" "🍅" 255 100 50
    menu_item "02" "Quick Timer (custom)" "⏱️ " 0 200 255
    menu_item "03" "View Stats" "📊" 0 255 136
    menu_item "00" "← Back" "◀" 100 100 120
    
    prompt_input "Select"
    read -r pc
    
    case "$pc" in
        1|01) clear; pomodoro_start; pause; pomodoro_menu ;;
        2|02)
            prompt_text "Timer Duration" "minutes"
            read -r mins
            [[ "$mins" =~ ^[0-9]+$ ]] && { clear; pomodoro_quick "$mins"; } || msg_err "Invalid number"
            pause; pomodoro_menu ;;
        3|03) clear; pomodoro_stats; pause; pomodoro_menu ;;
        0|00) main_menu ;;
        *)    pomodoro_menu ;;
    esac
}

notes_menu() {
    show_banner
    section_header "Quick Notes"
    
    menu_item "01" "Add Note" "📝" 0 255 136
    menu_item "02" "List Notes" "📋" 0 200 255
    menu_item "03" "Search Notes" "🔍" 200 100 255
    menu_item "04" "View Tags" "🏷️ " 255 165 0
    menu_item "05" "Delete Note" "🗑️ " 255 60 60
    menu_item "06" "Clear All" "💥" 255 0 0
    menu_item "00" "← Back" "◀" 100 100 120
    
    prompt_input "Select"
    read -r nc
    
    case "$nc" in
        1|01)
            prompt_text "New Note" "use #tag, ! priority"
            read -r note_text
            note_add "$note_text"
            pause; notes_menu ;;
        2|02) echo ""; note_list; pause; notes_menu ;;
        3|03)
            prompt_text "Search Notes" "keyword"
            read -r query
            note_search "$query"
            pause; notes_menu ;;
        4|04) echo ""; note_tags; pause; notes_menu ;;
        5|05)
            note_list
            prompt_text "Delete Note" "note ID"
            read -r nid
            note_delete "$nid"
            pause; notes_menu ;;
        6|06) note_clear; pause; notes_menu ;;
        0|00) main_menu ;;
        *)    notes_menu ;;
    esac
}

bookmarks_menu() {
    show_banner
    section_header "Directory Bookmarks"
    
    menu_item "01" "Save Current Dir" "📌" 0 255 136
    menu_item "02" "List Bookmarks" "📋" 0 200 255
    menu_item "03" "Jump to Bookmark" "🚀" 200 100 255
    menu_item "04" "FZF Bookmark Jump" "🔍" 255 165 0
    menu_item "05" "Delete Bookmark" "🗑️ " 255 60 60
    menu_item "00" "← Back" "◀" 100 100 120
    
    prompt_input "Select"
    read -r bc
    
    case "$bc" in
        1|01)
            prompt_text "Bookmark Name" "Enter=auto"
            read -r bname
            if [[ -n "$bname" ]]; then
                bm_save "$bname"
            else
                bm_save
            fi
            pause; bookmarks_menu ;;
        2|02) echo ""; bm_list; pause; bookmarks_menu ;;
        3|03)
            bm_list
            prompt_text "Jump to Bookmark" "name"
            read -r jname
            bm_go "$jname"
            msg_info "Now in: $(pwd)"
            pause; bookmarks_menu ;;
        4|04) bm_fzf; pause; bookmarks_menu ;;
        5|05)
            bm_list
            prompt_text "Delete Bookmark" "name"
            read -r dname
            bm_delete "$dname"
            pause; bookmarks_menu ;;
        0|00) main_menu ;;
        *)    bookmarks_menu ;;
    esac
}

hacker_menu() {
    show_banner
    section_header "Hacker Mode"
    
    hacker_mode_status
    echo ""
    
    menu_item "01" "Activate Hacker Mode" "💀" 0 255 0
    menu_item "02" "Deactivate Hacker Mode" "🔄" 255 220 0
    menu_item "03" "Custom Intensity" "🎚️ " 0 200 255
    menu_item "00" "← Back" "◀" 100 100 120
    
    prompt_input "Select"
    read -r hc
    
    case "$hc" in
        1|01) hacker_mode_on; pause; hacker_menu ;;
        2|02) hacker_mode_off; pause; hacker_menu ;;
        3|03)
            prompt_text "Green Intensity" "50-255"
            read -r intensity
            [[ "$intensity" =~ ^[0-9]+$ ]] && hacker_mode_intensity "$intensity" || msg_err "Invalid number"
            pause; hacker_menu ;;
        0|00) main_menu ;;
        *)    hacker_menu ;;
    esac
}

screensaver_menu() {
    show_banner
    section_header "Screensaver"
    
    local ss_conf="${ZORKOS_HOME}/screensaver.conf"
    local current_style="matrix" current_timeout=300 ss_enabled=false
    [[ -f "$ss_conf" ]] && source "$ss_conf"
    msg_info "Style: ${current_style} | Timeout: ${current_timeout}s | Enabled: ${ss_enabled}"
    echo ""
    
    menu_item "01" "Preview Matrix Rain" "🟩" 0 255 0
    menu_item "02" "Preview Digital Clock" "🕐" 0 200 255
    menu_item "03" "Preview Starfield" "⭐" 255 215 0
    menu_item "04" "Preview Pipes" "🔧" 200 100 255
    menu_item "05" "Set Active Style" "🎨" 255 165 0
    menu_item "06" "Set Timeout" "⏰" 255 220 0
    menu_item "07" "Enable/Disable" "⚡" 0 255 136
    menu_item "00" "← Back" "◀" 100 100 120
    
    prompt_input "Select"
    read -r sc
    
    case "$sc" in
        1|01) clear; run_screensaver "matrix"; screensaver_menu ;;
        2|02) clear; run_screensaver "clock"; screensaver_menu ;;
        3|03) clear; run_screensaver "starfield"; screensaver_menu ;;
        4|04) clear; run_screensaver "pipes"; screensaver_menu ;;
        5|05)
            prompt_text "Screensaver Style" "matrix/clock/starfield/pipes"
            read -r new_style
            [[ -f "$ss_conf" ]] && sed -i "s/current_style=.*/current_style=${new_style}/" "$ss_conf" || echo "current_style=${new_style}" >> "$ss_conf"
            msg_ok "Screensaver style: ${new_style}"
            pause; screensaver_menu ;;
        6|06)
            prompt_text "Screensaver Timeout" "seconds"
            read -r new_timeout
            [[ -f "$ss_conf" ]] && sed -i "s/current_timeout=.*/current_timeout=${new_timeout}/" "$ss_conf" || echo "current_timeout=${new_timeout}" >> "$ss_conf"
            msg_ok "Timeout: ${new_timeout}s"
            pause; screensaver_menu ;;
        7|07)
            if [[ "$ss_enabled" == "true" ]]; then
                sed -i 's/ss_enabled=.*/ss_enabled=false/' "$ss_conf" 2>/dev/null
                msg_ok "Screensaver DISABLED"
            else
                [[ ! -f "$ss_conf" ]] && echo -e "current_style=matrix\ncurrent_timeout=300\nss_enabled=true" > "$ss_conf"
                sed -i 's/ss_enabled=.*/ss_enabled=true/' "$ss_conf" 2>/dev/null
                msg_ok "Screensaver ENABLED"
            fi
            pause; screensaver_menu ;;
        0|00) main_menu ;;
        *)    screensaver_menu ;;
    esac
}

weather_menu() {
    show_banner
    section_header "Weather Widget"
    
    menu_item "01" "Current Weather" "🌤️ " 255 180 50
    menu_item "02" "Weather in Prompt" "📊" 0 200 255
    menu_item "03" "Refresh Cache" "🔄" 0 255 136
    menu_item "00" "← Back" "◀" 100 100 120
    
    prompt_input "Select"
    read -r wc
    
    case "$wc" in
        1|01) clear; echo ""; weather_full_display; pause; weather_menu ;;
        2|02)
            msg_info "Weather is auto-shown in your prompt (right side)"
            msg_info "It updates every 30 minutes via cache"
            pause; weather_menu ;;
        3|03)
            rm -f "${ZORKOS_HOME}/cache/weather.cache"
            fetch_weather
            msg_ok "Weather cache refreshed!"
            pause; weather_menu ;;
        0|00) main_menu ;;
        *)    weather_menu ;;
    esac
}
goodbye() {
    clear
    echo ""
    
    get_responsive_bye_banner
    for line in "${RESPONSIVE_BYE_BANNER[@]}"; do
        gradient_text "$line" "${GRADIENT_ZORK[@]}"
        echo
    done
    
    echo ""
    local bye_tag _uname_bye
    _uname_bye=$(grep "^USERNAME=" "$HOME/.zorkos/user.conf" 2>/dev/null | cut -d= -f2)
    [[ -z "$_uname_bye" ]] && _uname_bye="Zork"
    bye_tag="See you next time, ${_uname_bye}! 👋"
    gradient_text "  ${bye_tag}" "${GRADIENT_AURORA[@]}"
    echo ""
    echo ""
    
    exit 0
}

handle_cli_args() {
    case "$1" in
        theme)
            if [[ -n "$2" ]]; then
                apply_theme "$2"
            else
                theme_menu
            fi
            ;;
        color|colors)
            if [[ -n "$2" ]]; then
                apply_color_scheme "$2"
            else
                color_menu
            fi
            ;;
        plugin|plugins)
            plugin_menu
            ;;
        boot)
            if [[ -n "$2" ]]; then
                BOOT_ANIMATION="$2"
                echo "$2" > "${ZORKOS_HOME}/boot_style"
                save_config
                msg_ok "Boot animation: $2"
            else
                boot_menu
            fi
            ;;
        sound)
            case "$2" in
                on)  SOUND_ENABLED=true; save_config; msg_ok "Sound: ON" ;;
                off) SOUND_ENABLED=false; save_config; msg_ok "Sound: OFF" ;;
                set)
                    if [[ -n "$3" ]]; then
                        BOOT_SOUND_FILE="$3"; save_config
                        msg_ok "Boot sound: $3"
                    else
                        msg_warn "Usage: zork sound set <filename.mp3>"
                    fi ;;
                *)   sound_menu ;;
            esac
            ;;
        info|status)
            system_info
            ;;
        backup)
            create_backup
            ;;
        restore)
            if [[ -n "$2" ]]; then
                restore_backup "$2"
            else
                backup_menu
            fi
            ;;
        update)
            update_zorkos
            ;;
        config)
            advanced_menu
            ;;
        uninstall)
            full_uninstall
            ;;
        dash|dashboard)
            clear; system_dashboard
            ;;
        dashlive)
            system_dashboard_live
            ;;
        hack|hacker)
            case "$2" in
                on)  hacker_mode_on ;;
                off) hacker_mode_off ;;
                *)   hacker_mode_toggle ;;
            esac
            ;;
        pomo|pomodoro)
            case "$2" in
                quick) pomodoro_quick "${3:-10}" ;;
                stats) pomodoro_stats ;;
                *)     pomodoro_start ;;
            esac
            ;;
        note|notes)
            shift
            note "$@"
            ;;
        bm|bookmark|bookmarks)
            shift
            bm "$@"
            ;;
        achievements|xp)
            case "$2" in
                stats) 
                    local stats_db="${ZORKOS_HOME}/achievements/stats.db"
                    [[ -f "$stats_db" ]] && source "$stats_db"
                    echo -e "  \033[38;2;255;215;0m  Level: $(get_xp_level) | XP: ${TOTAL_XP:-0} | Streak: ${CURRENT_STREAK:-0}d${RST}"
                    ;;
                rewards|perks) get_level_rewards ;;
                list|all) show_all_achievements_list ;;
                *) show_all_achievements_list ;;
            esac
            ;;
        screensaver|ss)
            run_screensaver "${2:-matrix}"
            ;;
        weather)
            case "$2" in
                refresh) rm -f "${ZORKOS_HOME}/cache/weather.cache"; fetch_weather ;;
                *)       weather_full_display ;;
            esac
            ;;
        auth)
            auth_menu
            ;;
        login)
            auth_login_screen
            ;;
        logout)
            auth_logout
            ;;
        help|--help|-h)
            local _hcmd
            _hcmd=$(grep "^CMD_NAME=" "$HOME/.zorkos/user.conf" 2>/dev/null | cut -d= -f2)
            [[ -z "$_hcmd" ]] && _hcmd="zork"
            echo -e "\n\033[1;38;2;0;255;136m  ZorkOS v${VERSION} — Command Reference${RST}\n"
            echo -e "  \033[38;2;0;200;255m── Core ──${RST}"
            echo -e "  \033[38;2;0;200;255m${_hcmd}\033[38;2;100;100;120m               Open main menu${RST}"
            echo -e "  \033[38;2;0;200;255m${_hcmd} theme\033[38;2;100;100;120m [name]  Switch ZSH theme${RST}"
            echo -e "  \033[38;2;0;200;255m${_hcmd} color\033[38;2;100;100;120m [name]  Switch color scheme${RST}"
            echo -e "  \033[38;2;0;200;255m${_hcmd} plugin\033[38;2;100;100;120m        Plugin manager${RST}"
            echo -e "  \033[38;2;0;200;255m${_hcmd} boot\033[38;2;100;100;120m [style]  Set boot animation${RST}"
            echo -e "  \033[38;2;0;200;255m${_hcmd} sound\033[38;2;100;100;120m [on|off] Toggle sounds${RST}"
            echo -e "  \033[38;2;0;200;255m${_hcmd} info\033[38;2;100;100;120m          System information${RST}"
            echo -e "  \033[38;2;0;200;255m${_hcmd} backup\033[38;2;100;100;120m        Create backup${RST}"
            echo -e "  \033[38;2;0;200;255m${_hcmd} restore\033[38;2;100;100;120m [id]  Restore backup${RST}"
            echo -e "  \033[38;2;0;200;255m${_hcmd} config\033[38;2;100;100;120m        Advanced config${RST}"
            echo -e "  \033[38;2;0;200;255m${_hcmd} update\033[38;2;100;100;120m        Check updates${RST}"
            echo -e "  \033[38;2;0;200;255m${_hcmd} uninstall\033[38;2;100;100;120m     Remove ZorkOS${RST}"
            echo ""
            echo -e "  \033[38;2;255;0;200m── Power Features ──${RST}"
            echo -e "  \033[38;2;0;200;255m${_hcmd} dash\033[38;2;100;100;120m          System dashboard${RST}"
            echo -e "  \033[38;2;0;200;255m${_hcmd} dashlive\033[38;2;100;100;120m      Live monitor${RST}"
            echo -e "  \033[38;2;0;200;255m${_hcmd} hack\033[38;2;100;100;120m [on|off] Hacker mode${RST}"
            echo -e "  \033[38;2;0;200;255m${_hcmd} pomo\033[38;2;100;100;120m          Pomodoro timer${RST}"
            echo -e "  \033[38;2;0;200;255m${_hcmd} pomo quick\033[38;2;100;100;120m N  Quick N-min timer${RST}"
            echo -e "  \033[38;2;0;200;255m${_hcmd} pomo stats\033[38;2;100;100;120m    Pomodoro stats${RST}"
            echo -e "  \033[38;2;0;200;255m${_hcmd} note add\033[38;2;100;100;120m MSG  Add a note${RST}"
            echo -e "  \033[38;2;0;200;255m${_hcmd} note list\033[38;2;100;100;120m     List notes${RST}"
            echo -e "  \033[38;2;0;200;255m${_hcmd} bm save\033[38;2;100;100;120m [n]   Bookmark dir${RST}"
            echo -e "  \033[38;2;0;200;255m${_hcmd} bm go\033[38;2;100;100;120m NAME    Jump to bookmark${RST}"
            echo -e "  \033[38;2;0;200;255m${_hcmd} xp\033[38;2;100;100;120m            All achievements${RST}"
            echo -e "  \033[38;2;0;200;255m${_hcmd} xp stats\033[38;2;100;100;120m      XP summary${RST}"
            echo -e "  \033[38;2;0;200;255m${_hcmd} xp rewards\033[38;2;100;100;120m    Level perks${RST}"
            echo -e "  \033[38;2;0;200;255m${_hcmd} ss\033[38;2;100;100;120m [style]    Screensaver${RST}"
            echo -e "  \033[38;2;0;200;255m${_hcmd} weather\033[38;2;100;100;120m       Weather display${RST}"
            echo -e "  \033[38;2;0;200;255m${_hcmd} auth\033[38;2;100;100;120m          Auth settings${RST}"
            echo -e "  \033[38;2;0;200;255m${_hcmd} login\033[38;2;100;100;120m         Login screen${RST}"
            echo -e "  \033[38;2;0;200;255m${_hcmd} help\033[38;2;100;100;120m          Show this help${RST}"
            echo ""
            ;;
        *)
            main_menu
            ;;
    esac
}

if [[ $# -gt 0 ]]; then
    handle_cli_args "$@"
else
    main_menu
fi
