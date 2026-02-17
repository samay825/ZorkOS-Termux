#!/bin/bash

BOOKMARKS_FILE="${HOME}/.zorkos/bookmarks.db"

bookmarks_init() {
    mkdir -p "$(dirname "$BOOKMARKS_FILE")"
    [[ ! -f "$BOOKMARKS_FILE" ]] && touch "$BOOKMARKS_FILE"
}

bm_save() {
    local name="${1:-}"
    local dir="${2:-$(pwd)}"
    
    bookmarks_init
    
    if [[ -z "$name" ]]; then
        name=$(basename "$dir")
    fi
    
    sed -i "/^${name}|/d" "$BOOKMARKS_FILE" 2>/dev/null
    
    echo "${name}|${dir}|$(date '+%Y-%m-%d %H:%M')" >> "$BOOKMARKS_FILE"
    echo -e "  \033[38;2;0;255;136m✓ Bookmark '${name}' → ${dir}\033[0m"
}

bm_go() {
    local name="$1"
    
    bookmarks_init
    
    if [[ -z "$name" ]]; then
        echo -e "  \033[38;2;255;60;60mUsage: bm go <name>\033[0m"
        bm_list
        return 1
    fi
    
    local dir
    dir=$(grep "^${name}|" "$BOOKMARKS_FILE" 2>/dev/null | head -1 | cut -d'|' -f2)
    
    if [[ -n "$dir" ]] && [[ -d "$dir" ]]; then
        cd "$dir" || return 1
        echo -e "  \033[38;2;0;255;136m→ ${dir}\033[0m"
    else
        echo -e "  \033[38;2;255;60;60m✗ Bookmark '${name}' not found or dir doesn't exist\033[0m"
        return 1
    fi
}

bm_list() {
    bookmarks_init
    
    local RST="\033[0m"
    echo ""
    echo -e "  \033[1;38;2;0;200;255m  📁 Directory Bookmarks${RST}"
    echo -e "  \033[38;2;60;60;80m  ──────────────────────────────────${RST}"
    echo ""
    
    if [[ ! -s "$BOOKMARKS_FILE" ]]; then
        echo -e "  \033[38;2;100;100;120m  No bookmarks. Use 'bm save <name>' to add one.${RST}"
        echo ""
        return
    fi
    
    local idx=1
    local exists exists_color
    while IFS='|' read -r name dir date; do
        [[ -z "$name" ]] && continue
        
        exists="✓"
        [[ ! -d "$dir" ]] && exists="✗"
        
        exists_color="0;255;136"
        [[ "$exists" == "✗" ]] && exists_color="255;60;60"
        
        printf "  \033[38;2;60;60;80m  [%2d] \033[38;2;${exists_color}m${exists} \033[38;2;255;220;0m%-12s \033[38;2;0;200;255m%s \033[38;2;60;60;80m%s${RST}\n" \
            "$idx" "$name" "$dir" "$date"
        idx=$((idx + 1))
    done < "$BOOKMARKS_FILE"
    
    echo ""
}

bm_delete() {
    local name="$1"
    
    [[ -z "$name" ]] && { echo -e "  \033[38;2;255;60;60mUsage: bm delete <name>\033[0m"; return 1; }
    
    if grep -q "^${name}|" "$BOOKMARKS_FILE" 2>/dev/null; then
        sed -i "/^${name}|/d" "$BOOKMARKS_FILE"
        echo -e "  \033[38;2;0;255;136m✓ Bookmark '${name}' removed\033[0m"
    else
        echo -e "  \033[38;2;255;60;60m✗ Bookmark '${name}' not found\033[0m"
    fi
}

bm_fzf() {
    bookmarks_init
    
    if command -v fzf &>/dev/null && [[ -s "$BOOKMARKS_FILE" ]]; then
        local selected
        selected=$(awk -F'|' '{printf "%-12s  %s\n", $1, $2}' "$BOOKMARKS_FILE" | fzf --prompt="📁 Jump to: " --height=40%)
        
        if [[ -n "$selected" ]]; then
            local dir
            dir=$(echo "$selected" | awk '{print $2}')
            cd "$dir" 2>/dev/null && echo -e "  \033[38;2;0;255;136m→ ${dir}\033[0m"
        fi
    else
        bm_list
        echo -ne "  \033[38;2;0;200;255m  Enter bookmark name: \033[0m"
        read -r name
        bm_go "$name"
    fi
}

bm() {
    bookmarks_init
    case "$1" in
        save|s|add)   shift; bm_save "$@" ;;
        go|g|cd|j)    shift; bm_go "$@" ;;
        list|ls|l)    bm_list ;;
        delete|rm|d)  shift; bm_delete "$@" ;;
        fzf|f)        bm_fzf ;;
        *)
            if [[ -n "$1" ]]; then
                bm_go "$1"
            else
                bm_fzf
            fi
            ;;
    esac
}

generate_bookmark_functions() {
    cat << 'BMFUNC'
if [[ -f "$HOME/.zorkos/lib/bookmarks.sh" ]]; then
    source "$HOME/.zorkos/lib/bookmarks.sh"
fi
BMFUNC
}

bookmarks_init
