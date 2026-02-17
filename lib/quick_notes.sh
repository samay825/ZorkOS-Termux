#!/bin/bash

NOTES_DIR="${HOME}/.zorkos/notes"
NOTES_INDEX="${NOTES_DIR}/.index"

notes_init() {
    mkdir -p "$NOTES_DIR"
    [[ ! -f "$NOTES_INDEX" ]] && echo "0" > "$NOTES_INDEX"
}

_next_note_id() {
    local current
    current=$(cat "$NOTES_INDEX" 2>/dev/null || echo 0)
    local next=$(( current + 1 ))
    echo "$next" > "$NOTES_INDEX"
    echo "$next"
}

note_add() {
    local content="$*"
    notes_init
    
    if [[ -z "$content" ]]; then
        echo -ne "  \033[38;2;0;200;255m  📝 Note: \033[0m"
        read -r content
    fi
    
    [[ -z "$content" ]] && { echo -e "  \033[38;2;255;60;60m✗ Empty note${RST}"; return 1; }
    
    local id
    id=$(_next_note_id)
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local tag="general"
    
    if [[ "$content" =~ \#([a-zA-Z0-9_]+) ]]; then
        if [[ -n "$ZSH_VERSION" ]]; then
            tag="${match[1]}"
        else
            tag="${BASH_REMATCH[1]}"
        fi
    fi
    
    local priority="normal"
    [[ "$content" == "!"* ]] && priority="high" && content="${content:1}"
    [[ "$content" == "!!"* ]] && priority="urgent" && content="${content:2}"
    
    cat >> "${NOTES_DIR}/notes.db" << EOF
${id}|${timestamp}|${tag}|${priority}|${content}
EOF
    
    local priority_icon="📝"
    [[ "$priority" == "high" ]] && priority_icon="⚠️"
    [[ "$priority" == "urgent" ]] && priority_icon="🔴"
    
    echo -e "  \033[38;2;0;255;136m✓ ${priority_icon} Note #${id} saved [${tag}]\033[0m"
}

note_list() {
    local filter="${1:-}"
    local RST="\033[0m"
    notes_init
    
    [[ ! -f "${NOTES_DIR}/notes.db" ]] && { echo -e "  \033[38;2;100;100;120mNo notes yet. Use 'note add <text>' to create one.${RST}"; return; }
    
    echo ""
    echo -e "  \033[1;38;2;0;200;255m  📋 Quick Notes${RST}"
    echo -e "  \033[38;2;60;60;80m  ──────────────────────────────────${RST}"
    echo ""
    
    local count=0
    local priority_color priority_icon
    while IFS='|' read -r id timestamp tag priority content; do
        [[ -z "$id" ]] && continue
        
        if [[ -n "$filter" ]] && [[ "$tag" != "$filter" ]]; then
            continue
        fi
        
        priority_color="100;100;120"
        priority_icon="  "
        case "$priority" in
            high)   priority_color="255;220;0"; priority_icon="⚠️" ;;
            urgent) priority_color="255;60;60"; priority_icon="🔴" ;;
            normal) priority_color="0;255;136"; priority_icon="📝" ;;
        esac
        
        printf "  \033[38;2;60;60;80m  #%-4s \033[38;2;%sm%s %s \033[38;2;100;100;120m[%s] \033[38;2;60;60;80m%s${RST}\n" \
            "$id" "$priority_color" "$priority_icon" "$content" "$tag" "$timestamp"
        count=$((count + 1))
    done < "${NOTES_DIR}/notes.db"
    
    echo ""
    echo -e "  \033[38;2;100;100;120m  Total: ${count} notes${RST}"
    echo ""
}

note_search() {
    local query="$1"
    local RST="\033[0m"
    
    [[ -z "$query" ]] && { echo -e "  \033[38;2;255;60;60mUsage: note search <query>${RST}"; return 1; }
    [[ ! -f "${NOTES_DIR}/notes.db" ]] && { echo "  No notes found."; return; }
    
    echo ""
    echo -e "  \033[38;2;0;200;255m  🔍 Search: '${query}'${RST}"
    echo ""
    
    grep -i "$query" "${NOTES_DIR}/notes.db" | while IFS='|' read -r id timestamp tag priority content; do
        printf "  \033[38;2;60;60;80m  #%-4s \033[38;2;0;255;136m%s \033[38;2;100;100;120m[%s] \033[38;2;60;60;80m%s${RST}\n" \
            "$id" "$content" "$tag" "$timestamp"
    done
    echo ""
}

note_delete() {
    local id="$1"
    
    [[ -z "$id" ]] && { echo -e "  \033[38;2;255;60;60mUsage: note delete <id>\033[0m"; return 1; }
    [[ ! -f "${NOTES_DIR}/notes.db" ]] && return 1
    
    if grep -q "^${id}|" "${NOTES_DIR}/notes.db"; then
        sed -i "/^${id}|/d" "${NOTES_DIR}/notes.db"
        echo -e "  \033[38;2;0;255;136m✓ Note #${id} deleted\033[0m"
    else
        echo -e "  \033[38;2;255;60;60m✗ Note #${id} not found\033[0m"
    fi
}

note_clear() {
    echo -ne "  \033[38;2;255;220;0m  Delete ALL notes? (y/N): \033[0m"
    read -r confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        > "${NOTES_DIR}/notes.db"
        echo "0" > "$NOTES_INDEX"
        echo -e "  \033[38;2;0;255;136m✓ All notes cleared\033[0m"
    fi
}

note_tags() {
    [[ ! -f "${NOTES_DIR}/notes.db" ]] && { echo "  No notes."; return; }
    
    echo ""
    echo -e "  \033[38;2;0;200;255m  🏷 Tags:${RST}"
    awk -F'|' '{print $3}' "${NOTES_DIR}/notes.db" | sort | uniq -c | sort -rn | while read -r count tag; do
        echo -e "  \033[38;2;100;100;120m    #${tag} \033[38;2;0;255;136m(${count})\033[0m"
    done
    echo ""
}

note() {
    notes_init
    case "$1" in
        add|a)    shift; note_add "$@" ;;
        list|ls)  shift; note_list "$@" ;;
        search|s) shift; note_search "$@" ;;
        delete|d|rm) shift; note_delete "$@" ;;
        clear)    note_clear ;;
        tags|t)   note_tags ;;
        *)
            if [[ -n "$1" ]]; then
                note_add "$@"
            else
                note_list
            fi
            ;;
    esac
}

notes_init
