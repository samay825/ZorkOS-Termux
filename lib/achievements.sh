#!/bin/bash

ACHIEVEMENTS_DIR="${HOME}/.zorkos/achievements"
ACHIEVEMENTS_DB="${ACHIEVEMENTS_DIR}/achievements.db"
STATS_DB="${ACHIEVEMENTS_DIR}/stats.db"
STREAK_FILE="${ACHIEVEMENTS_DIR}/streak.db"


achievements_init() {
    mkdir -p "$ACHIEVEMENTS_DIR"
    
    
    if [[ ! -f "$STATS_DB" ]]; then
        cat > "$STATS_DB" << 'STATSEOF'
TOTAL_COMMANDS=0
TOTAL_SESSIONS=0
GIT_COMMITS=0
FILES_CREATED=0
DIRS_VISITED=0
THEME_CHANGES=0
PLUGINS_INSTALLED=0
CUSTOM_ALIASES=0
LONGEST_SESSION=0
TOTAL_XP=0
CURRENT_STREAK=0
BEST_STREAK=0
LAST_LOGIN_DATE=never
STATSEOF
    fi
    source "$STATS_DB" 2>/dev/null
    
    
    if [[ ! -f "$ACHIEVEMENTS_DB" ]]; then
        touch "$ACHIEVEMENTS_DB"
    fi
}


award_achievement() {
    local id="$1"
    local name="$2"
    local description="$3"
    local xp_reward="$4"
    local icon="$5"
    
    
    if grep -q "^${id}:" "$ACHIEVEMENTS_DB" 2>/dev/null; then
        return 1  
    fi
    
    
    echo "${id}:${name}:${description}:${xp_reward}:${icon}:$(date '+%Y-%m-%d %H:%M:%S')" >> "$ACHIEVEMENTS_DB"
    
    
    TOTAL_XP=$(( TOTAL_XP + xp_reward ))
    _save_stats
    
    
    _show_achievement_popup "$name" "$description" "$xp_reward" "$icon"
    
    return 0
}

_show_achievement_popup() {
    local name="$1"
    local desc="$2"
    local xp="$3"
    local icon="${4:-🏆}"
    
    local cols
    cols=$(tput cols 2>/dev/null || echo 80)
    local RST="\033[0m"
    
    local box_inner=38
    [[ $cols -lt 50 ]] && box_inner=$(( cols - 6 ))
    [[ $box_inner -lt 20 ]] && box_inner=20
    
    echo ""
    if [[ $cols -ge 44 ]]; then
        local border
        border=$(printf '%*s' "$box_inner" '')
        border="${border// /─}"
        
        echo -e "\033[48;2;30;30;50m\033[38;2;255;215;0m  ╭${border}${RST}"
        
        local title=" ${icon} ACHIEVEMENT UNLOCKED!"
        printf "  \033[48;2;30;30;50m\033[38;2;255;215;0m│%s\033[0m\n" "$title"
        
        local name_display=" ${name}"
        printf "  \033[48;2;30;30;50m\033[38;2;0;255;136m│%s\033[0m\n" "$name_display"
        
        local desc_display=" ${desc}"
        local desc_trunc="${desc_display:0:$box_inner}"
        printf "  \033[48;2;30;30;50m\033[38;2;100;100;120m│%s\033[0m\n" "$desc_trunc"
        
        local xp_display=" +${xp} XP"
        printf "  \033[48;2;30;30;50m\033[38;2;255;220;0m│%s\033[0m\n" "$xp_display"
        
        echo -e "\033[48;2;30;30;50m\033[38;2;255;215;0m  ╰${border}${RST}"
    else
        echo -e "\033[38;2;255;215;0m ${icon} UNLOCKED: ${name} (+${xp}XP)${RST}"
    fi
    echo ""
}

check_achievements() {
    source "$STATS_DB" 2>/dev/null
    
    [[ $TOTAL_COMMANDS -ge 1 ]] && award_achievement "first_cmd" "First Steps" "Run your first command" 10 "👶"
    [[ $TOTAL_COMMANDS -ge 100 ]] && award_achievement "cmd_100" "Century" "Run 100 commands" 50 "💯"
    [[ $TOTAL_COMMANDS -ge 500 ]] && award_achievement "cmd_500" "Commander" "Run 500 commands" 100 "⚔️"
    [[ $TOTAL_COMMANDS -ge 1000 ]] && award_achievement "cmd_1k" "Terminal Warrior" "Run 1000 commands" 200 "🗡️"
    [[ $TOTAL_COMMANDS -ge 5000 ]] && award_achievement "cmd_5k" "Shell God" "Run 5000 commands" 500 "⚡"
    [[ $TOTAL_COMMANDS -ge 10000 ]] && award_achievement "cmd_10k" "Legendary Hacker" "Run 10000 commands" 1000 "🌟"
    
    [[ $TOTAL_SESSIONS -ge 1 ]] && award_achievement "first_login" "Welcome Home" "First terminal session" 10 "🏠"
    [[ $TOTAL_SESSIONS -ge 10 ]] && award_achievement "sessions_10" "Regular" "10 terminal sessions" 50 "📅"
    [[ $TOTAL_SESSIONS -ge 50 ]] && award_achievement "sessions_50" "Devotee" "50 terminal sessions" 150 "🔥"
    [[ $TOTAL_SESSIONS -ge 100 ]] && award_achievement "sessions_100" "Terminal Addict" "100 sessions!" 300 "💎"
    
    [[ $GIT_COMMITS -ge 1 ]] && award_achievement "first_commit" "Code Author" "First git commit" 20 "📝"
    [[ $GIT_COMMITS -ge 50 ]] && award_achievement "commits_50" "Contributing" "50 git commits" 100 "🤝"
    [[ $GIT_COMMITS -ge 100 ]] && award_achievement "commits_100" "Open Sourcer" "100 git commits" 200 "🌐"
    
    [[ $THEME_CHANGES -ge 1 ]] && award_achievement "first_theme" "Stylist" "Change your first theme" 15 "🎨"
    [[ $THEME_CHANGES -ge 10 ]] && award_achievement "theme_master" "Theme Master" "Try 10 different themes" 75 "👑"
    [[ $PLUGINS_INSTALLED -ge 1 ]] && award_achievement "first_plugin" "Plugin Pioneer" "Install your first plugin" 15 "🔌"
    [[ $PLUGINS_INSTALLED -ge 5 ]] && award_achievement "plugin_collector" "Plugin Collector" "Install 5 plugins" 75 "📦"
    
    [[ $CURRENT_STREAK -ge 3 ]] && award_achievement "streak_3" "Three Days Strong" "3-day login streak" 30 "🔥"
    [[ $CURRENT_STREAK -ge 7 ]] && award_achievement "streak_7" "Week Warrior" "7-day login streak" 100 "🏆"
    [[ $CURRENT_STREAK -ge 30 ]] && award_achievement "streak_30" "Monthly Master" "30-day login streak!" 500 "👑"
    [[ $CURRENT_STREAK -ge 100 ]] && award_achievement "streak_100" "Century Streak" "100-day streak!!" 2000 "🌟"
    
    [[ $LONGEST_SESSION -ge 3600 ]] && award_achievement "marathon_1h" "Marathon Runner" "1 hour session" 50 "🏃"
    [[ $LONGEST_SESSION -ge 14400 ]] && award_achievement "marathon_4h" "Night Owl" "4 hour session!" 200 "🦉"
}

update_streak() {
    source "$STATS_DB" 2>/dev/null
    
    local today
    today=$(date '+%Y-%m-%d')
    local yesterday
    yesterday=$(date -d 'yesterday' '+%Y-%m-%d' 2>/dev/null || date -v-1d '+%Y-%m-%d' 2>/dev/null || echo "none")
    
    if [[ "$LAST_LOGIN_DATE" == "$today" ]]; then
        return  # Already logged today
    elif [[ "$LAST_LOGIN_DATE" == "$yesterday" ]]; then
        CURRENT_STREAK=$(( CURRENT_STREAK + 1 ))
    else
        CURRENT_STREAK=1
    fi
    
    [[ $CURRENT_STREAK -gt $BEST_STREAK ]] && BEST_STREAK=$CURRENT_STREAK
    LAST_LOGIN_DATE="$today"
    TOTAL_SESSIONS=$(( TOTAL_SESSIONS + 1 ))
    
    _save_stats
    check_achievements
}

record_command() {
    local cmd="$1"
    source "$STATS_DB" 2>/dev/null
    
    TOTAL_COMMANDS=$(( TOTAL_COMMANDS + 1 ))
    TOTAL_XP=$(( TOTAL_XP + 1 ))  # 1 XP per command
    
    case "$cmd" in
        git\ commit*) GIT_COMMITS=$(( GIT_COMMITS + 1 )) ;;
        touch*|"cat >"*|mkdir*) FILES_CREATED=$(( FILES_CREATED + 1 )) ;;
        cd\ *) DIRS_VISITED=$(( DIRS_VISITED + 1 )) ;;
    esac
    
    if [[ $(( TOTAL_COMMANDS % 10 )) -eq 0 ]]; then
        _save_stats
        check_achievements
    fi
}

record_theme_change() {
    source "$STATS_DB" 2>/dev/null
    THEME_CHANGES=$(( THEME_CHANGES + 1 ))
    TOTAL_XP=$(( TOTAL_XP + 5 ))
    _save_stats
    check_achievements
}

record_plugin_install() {
    source "$STATS_DB" 2>/dev/null
    PLUGINS_INSTALLED=$(( PLUGINS_INSTALLED + 1 ))
    TOTAL_XP=$(( TOTAL_XP + 10 ))
    _save_stats
    check_achievements
}

_save_stats() {
    cat > "$STATS_DB" << EOF
TOTAL_COMMANDS=${TOTAL_COMMANDS}
TOTAL_SESSIONS=${TOTAL_SESSIONS}
GIT_COMMITS=${GIT_COMMITS}
FILES_CREATED=${FILES_CREATED}
DIRS_VISITED=${DIRS_VISITED}
THEME_CHANGES=${THEME_CHANGES}
PLUGINS_INSTALLED=${PLUGINS_INSTALLED}
CUSTOM_ALIASES=${CUSTOM_ALIASES}
LONGEST_SESSION=${LONGEST_SESSION}
TOTAL_XP=${TOTAL_XP}
CURRENT_STREAK=${CURRENT_STREAK}
BEST_STREAK=${BEST_STREAK}
LAST_LOGIN_DATE=${LAST_LOGIN_DATE}
EOF
}

get_xp_level() {
    source "$STATS_DB" 2>/dev/null
    local xp=${TOTAL_XP:-0}
    
    if [[ $xp -ge 10000 ]]; then echo "LEGENDARY"
    elif [[ $xp -ge 5000 ]]; then echo "MASTER"
    elif [[ $xp -ge 2000 ]]; then echo "EXPERT"
    elif [[ $xp -ge 1000 ]]; then echo "ADVANCED"
    elif [[ $xp -ge 500 ]]; then echo "INTERMEDIATE"
    elif [[ $xp -ge 100 ]]; then echo "BEGINNER"
    else echo "NOOB"
    fi
}

get_xp_progress() {
    [[ -n "$ZSH_VERSION" ]] && setopt localoptions KSH_ARRAYS 2>/dev/null
    source "$STATS_DB" 2>/dev/null
    local xp=${TOTAL_XP:-0}
    local RST="\033[0m"
    
    local -a levels=(0 100 500 1000 2000 5000 10000)
    local -a level_names=("NOOB" "BEGINNER" "INTERMEDIATE" "ADVANCED" "EXPERT" "MASTER" "LEGENDARY")
    
    local current_level=0
    local next_level_xp=100
    local current_level_xp=0
    
    for ((i=0; i<${#levels[@]}; i++)); do
        if [[ $xp -ge ${levels[$i]} ]]; then
            current_level=$i
            current_level_xp=${levels[$i]}
            if [[ $(( i + 1 )) -lt ${#levels[@]} ]]; then
                next_level_xp=${levels[$((i + 1))]}
            else
                next_level_xp=$xp
            fi
        fi
    done
    
    local progress_xp=$(( xp - current_level_xp ))
    local range=$(( next_level_xp - current_level_xp ))
    [[ $range -eq 0 ]] && range=1
    local pct=$(( progress_xp * 100 / range ))
    [[ $pct -gt 100 ]] && pct=100
    
    local bar_width=20
    local filled=$(( pct * bar_width / 100 ))
    
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=filled; i<bar_width; i++)); do bar+="░"; done
    
    echo -e "\033[38;2;255;220;0m${level_names[$current_level]}\033[38;2;100;100;120m [${bar}] \033[38;2;0;255;136m${xp}/${next_level_xp} XP${RST}"
}

show_achievements() {
    local RST="\033[0m"
    
    echo ""
    echo -e "  \033[1;38;2;255;215;0m  🏆 Achievement Gallery${RST}"
    echo -e "  \033[38;2;60;60;80m  ────────────────────────────────${RST}"
    echo ""
    
    echo -e "  $(get_xp_progress)"
    echo ""
    
    source "$STATS_DB" 2>/dev/null
    echo -e "  \033[38;2;255;165;0m  🔥 Current Streak: ${CURRENT_STREAK} days  |  Best: ${BEST_STREAK} days${RST}"
    echo ""
    
    if [[ -f "$ACHIEVEMENTS_DB" ]] && [[ -s "$ACHIEVEMENTS_DB" ]]; then
        echo -e "  \033[38;2;0;200;255m  Earned Achievements:${RST}"
        echo ""
        while IFS=: read -r id name desc xp icon date; do
            echo -e "  \033[38;2;100;100;120m  ${icon} \033[38;2;0;255;136m${name}\033[38;2;100;100;120m — ${desc} \033[38;2;255;220;0m(+${xp}XP) \033[38;2;60;60;80m${date}${RST}"
        done < "$ACHIEVEMENTS_DB"
    else
        echo -e "  \033[38;2;100;100;120m  No achievements yet. Keep using the terminal!${RST}"
    fi
    
    echo ""
    
    echo -e "  \033[38;2;200;100;255m  📊 Stats:${RST}"
    echo -e "  \033[38;2;100;100;120m    Commands: ${TOTAL_COMMANDS}  |  Sessions: ${TOTAL_SESSIONS}  |  Git Commits: ${GIT_COMMITS}${RST}"
    echo ""
}

_admin_max_achievements() {
    local ts
    ts=$(date '+%Y-%m-%d %H:%M:%S')
    
    cat > "$ACHIEVEMENTS_DB" << MAXEOF
first_cmd:First Steps:Run your first command:10:👶:${ts}
cmd_100:Century:Run 100 commands:50:💯:${ts}
cmd_500:Commander:Run 500 commands:100:⚔️:${ts}
cmd_1k:Terminal Warrior:Run 1000 commands:200:🗡️:${ts}
cmd_5k:Shell God:Run 5000 commands:500:⚡:${ts}
cmd_10k:Legendary Hacker:Run 10000 commands:1000:🌟:${ts}
first_login:Welcome Home:First terminal session:10:🏠:${ts}
sessions_10:Regular:10 terminal sessions:50:📅:${ts}
sessions_50:Devotee:50 terminal sessions:150:🔥:${ts}
sessions_100:Terminal Addict:100 sessions!:300:💎:${ts}
first_commit:Code Author:First git commit:20:📝:${ts}
commits_50:Contributing:50 git commits:100:🤝:${ts}
commits_100:Open Sourcer:100 git commits:200:🌐:${ts}
first_theme:Stylist:Change your first theme:15:🎨:${ts}
theme_master:Theme Master:Try 10 different themes:75:👑:${ts}
first_plugin:Plugin Pioneer:Install your first plugin:15:🔌:${ts}
plugin_collector:Plugin Collector:Install 5 plugins:75:📦:${ts}
streak_3:Three Days Strong:3-day login streak:30:🔥:${ts}
streak_7:Week Warrior:7-day login streak:100:🏆:${ts}
streak_30:Monthly Master:30-day login streak!:500:👑:${ts}
streak_100:Century Streak:100-day streak!!:2000:🌟:${ts}
marathon_1h:Marathon Runner:1 hour session:50:🏃:${ts}
marathon_4h:Night Owl:4 hour session!:200:🦉:${ts}
admin_unlock:Admin Elite:Activated with admin code:1000:🔐:${ts}
MAXEOF
    
    cat > "$STATS_DB" << MAXSTATS
TOTAL_COMMANDS=10000
TOTAL_SESSIONS=100
GIT_COMMITS=100
FILES_CREATED=500
DIRS_VISITED=1000
THEME_CHANGES=10
PLUGINS_INSTALLED=5
CUSTOM_ALIASES=20
LONGEST_SESSION=14400
TOTAL_XP=15645
CURRENT_STREAK=100
BEST_STREAK=100
LAST_LOGIN_DATE=$(date '+%Y-%m-%d')
MAXSTATS
    
    source "$STATS_DB" 2>/dev/null
}

get_level_rewards() {
    local RST="\033[0m"
    echo ""
    echo -e "  \033[1;38;2;255;215;0m  👑 Level Rewards & Perks${RST}"
    echo -e "  \033[38;2;60;60;80m  ──────────────────────────────────${RST}"
    echo ""
    echo -e "  \033[38;2;100;100;120m  NOOB${RST}         \033[38;2;80;80;100m(0 XP)${RST}"
    echo -e "  \033[38;2;60;60;80m    → Basic terminal setup & MOTD banner${RST}"
    echo ""
    echo -e "  \033[38;2;0;200;255m  BEGINNER${RST}     \033[38;2;80;80;100m(100 XP)${RST}"
    echo -e "  \033[38;2;60;60;80m    → Custom prompt color gradients${RST}"
    echo -e "  \033[38;2;60;60;80m    → Weather widget in dashboard${RST}"
    echo ""
    echo -e "  \033[38;2;0;255;136m  INTERMEDIATE${RST} \033[38;2;80;80;100m(500 XP)${RST}"
    echo -e "  \033[38;2;60;60;80m    → Full dashboard with all widgets${RST}"
    echo -e "  \033[38;2;60;60;80m    → Screensaver unlock${RST}"
    echo -e "  \033[38;2;60;60;80m    → Pomodoro timer${RST}"
    echo ""
    echo -e "  \033[38;2;200;100;255m  ADVANCED${RST}     \033[38;2;80;80;100m(1000 XP)${RST}"
    echo -e "  \033[38;2;60;60;80m    → Hacker mode with custom intensity${RST}"
    echo -e "  \033[38;2;60;60;80m    → Quick notes & bookmarks${RST}"
    echo -e "  \033[38;2;60;60;80m    → Boot animation selection${RST}"
    echo ""
    echo -e "  \033[38;2;255;100;50m  EXPERT${RST}       \033[38;2;80;80;100m(2000 XP)${RST}"
    echo -e "  \033[38;2;60;60;80m    → All boot animations unlocked${RST}"
    echo -e "  \033[38;2;60;60;80m    → Matrix & Cyberwave themes${RST}"
    echo -e "  \033[38;2;60;60;80m    → Custom color scheme editor${RST}"
    echo ""
    echo -e "  \033[38;2;255;0;200m  MASTER${RST}       \033[38;2;80;80;100m(5000 XP)${RST}"
    echo -e "  \033[38;2;60;60;80m    → All themes & schemes unlocked${RST}"
    echo -e "  \033[38;2;60;60;80m    → ⭐ Star badge in prompt${RST}"
    echo -e "  \033[38;2;60;60;80m    → Full backup & restore access${RST}"
    echo ""
    echo -e "  \033[1;38;2;255;215;0m  ⚡ LEGENDARY${RST}  \033[38;2;80;80;100m(10000 XP)${RST}"
    echo -e "  \033[38;2;60;60;80m    → Everything unlocked${RST}"
    echo -e "  \033[38;2;60;60;80m    → 👑 Crown badge in prompt${RST}"
    echo -e "  \033[38;2;60;60;80m    → Exclusive LEGENDARY boot screen${RST}"
    echo -e "  \033[38;2;60;60;80m    → Admin-level terminal power${RST}"
    echo ""
}

show_all_achievements_list() {
    [[ -n "$ZSH_VERSION" ]] && setopt localoptions KSH_ARRAYS 2>/dev/null
    local RST="\033[0m"
    echo ""
    echo -e "  \033[1;38;2;255;215;0m  📋 All Achievements${RST}"
    echo -e "  \033[38;2;60;60;80m  ──────────────────────────────────${RST}"
    echo ""
    
    echo -e "  \033[38;2;0;200;255m  ⌨️  Command Milestones${RST}"
    _ach_row "first_cmd"  "👶" "First Steps"       "Run your first command"  10
    _ach_row "cmd_100"    "💯" "Century"            "Run 100 commands"        50
    _ach_row "cmd_500"    "⚔️" "Commander"           "Run 500 commands"        100
    _ach_row "cmd_1k"     "🗡️" "Terminal Warrior"    "Run 1000 commands"       200
    _ach_row "cmd_5k"     "⚡" "Shell God"           "Run 5000 commands"       500
    _ach_row "cmd_10k"    "🌟" "Legendary Hacker"   "Run 10000 commands"      1000
    echo ""
    echo -e "  \033[38;2;200;100;255m  🖥️  Session Milestones${RST}"
    _ach_row "first_login"  "🏠" "Welcome Home"      "First terminal session"  10
    _ach_row "sessions_10"  "📅" "Regular"            "10 terminal sessions"    50
    _ach_row "sessions_50"  "🔥" "Devotee"            "50 terminal sessions"    150
    _ach_row "sessions_100" "💎" "Terminal Addict"    "100 sessions!"           300
    echo ""
    echo -e "  \033[38;2;0;255;136m  🔀 Git Milestones${RST}"
    _ach_row "first_commit" "📝" "Code Author"       "First git commit"        20
    _ach_row "commits_50"   "🤝" "Contributing"       "50 git commits"          100
    _ach_row "commits_100"  "🌐" "Open Sourcer"       "100 git commits"         200
    echo ""
    echo -e "  \033[38;2;255;0;200m  🎨 Customization${RST}"
    _ach_row "first_theme"     "🎨" "Stylist"           "Change your first theme"    15
    _ach_row "theme_master"    "👑" "Theme Master"      "Try 10 different themes"    75
    _ach_row "first_plugin"    "🔌" "Plugin Pioneer"    "Install your first plugin"  15
    _ach_row "plugin_collector" "📦" "Plugin Collector"  "Install 5 plugins"          75
    echo ""
    echo -e "  \033[38;2;255;165;0m  🔥 Streak Milestones${RST}"
    _ach_row "streak_3"   "🔥" "Three Days Strong"  "3-day login streak"      30
    _ach_row "streak_7"   "🏆" "Week Warrior"       "7-day login streak"      100
    _ach_row "streak_30"  "👑" "Monthly Master"     "30-day login streak!"    500
    _ach_row "streak_100" "🌟" "Century Streak"     "100-day streak!!"        2000
    echo ""
    echo -e "  \033[38;2;0;200;255m  ⏱️  Endurance${RST}"
    _ach_row "marathon_1h" "🏃" "Marathon Runner"    "1 hour session"          50
    _ach_row "marathon_4h" "🦉" "Night Owl"          "4 hour session!"         200
    echo ""
    echo -e "  \033[38;2;255;215;0m  🔐 Special${RST}"
    _ach_row "admin_unlock" "🔐" "Admin Elite"       "Activated with admin code" 1000
    echo ""
    
    local earned=0 total=24
    while IFS= read -r line; do
        earned=$((earned + 1))
    done < "$ACHIEVEMENTS_DB" 2>/dev/null
    echo -e "  \033[38;2;0;200;255m  ── Progress: \033[38;2;0;255;136m${earned}\033[38;2;0;200;255m/${total} achievements  │  Max XP: \033[38;2;255;220;0m5,645${RST}"
    echo ""
}

_ach_row() {
    local aid="$1" icon="$2" name="$3" desc="$4" xp="$5"
    local RST="\033[0m"
    if grep -q "^${aid}:" "$ACHIEVEMENTS_DB" 2>/dev/null; then
        echo -e "    \033[38;2;0;255;136m✓${RST} ${icon} \033[38;2;255;255;255m${name}\033[38;2;100;100;120m — ${desc} \033[38;2;255;220;0m+${xp}XP${RST}"
    else
        echo -e "    \033[38;2;60;60;80m✗ ${icon} ${name} — ${desc} +${xp}XP${RST}"
    fi
}

generate_achievement_hook() {
    cat << 'ACHHOOK'
_zorkos_achievement_preexec() {
    local cmd="$1"
    if [[ -f "$HOME/.zorkos/lib/achievements.sh" ]]; then
        source "$HOME/.zorkos/lib/achievements.sh" 2>/dev/null
        record_command "$cmd"
    fi
}
autoload -Uz add-zsh-hook
add-zsh-hook preexec _zorkos_achievement_preexec
ACHHOOK
}

achievements_init
