#!/bin/bash

WEATHER_CACHE="${HOME}/.zorkos/cache/weather.cache"
WEATHER_CACHE_TTL=1800  # 30 min cache

fetch_weather() {
    local city="${1:-}"
    local cache_dir
    cache_dir=$(dirname "$WEATHER_CACHE")
    mkdir -p "$cache_dir"
    
    if [[ -f "$WEATHER_CACHE" ]]; then
        local cache_age
        local now
        now=$(date +%s)
        local cache_time
        cache_time=$(stat -c %Y "$WEATHER_CACHE" 2>/dev/null || stat -f %m "$WEATHER_CACHE" 2>/dev/null || echo 0)
        cache_age=$(( now - cache_time ))
        
        if [[ $cache_age -lt $WEATHER_CACHE_TTL ]]; then
            cat "$WEATHER_CACHE"
            return 0
        fi
    fi
    
    local url="https://wttr.in/${city}?format=%c+%t+%h+%w&m"
    local weather
    weather=$(curl -s --max-time 5 "$url" 2>/dev/null)
    
    if [[ -n "$weather" ]] && [[ "$weather" != *"Unknown"* ]] && [[ "$weather" != *"Sorry"* ]]; then
        echo "$weather" > "$WEATHER_CACHE"
        echo "$weather"
    else
        echo "N/A"
    fi
}

weather_prompt_segment() {
    local weather
    weather=$(fetch_weather 2>/dev/null)
    
    if [[ "$weather" != "N/A" ]] && [[ -n "$weather" ]]; then
        local icon temp
        icon=$(echo "$weather" | awk '{print $1}')
        temp=$(echo "$weather" | awk '{print $2}')
        echo "${icon} ${temp}"
    fi
}

weather_full_display() {
    local city="${1:-}"
    local RST="\033[0m"
    
    echo ""
    echo -e "  \033[38;2;0;200;255m  ☁ Weather Report${RST}"
    echo -e "  \033[38;2;60;60;80m  ─────────────────────${RST}"
    
    local compact
    compact=$(fetch_weather "$city")
    echo -e "  \033[38;2;0;255;136m  ${compact}${RST}"
    
    echo ""
    
    local detail_url="https://wttr.in/${city}?format=%l:+%c+%C+%t+%f+(feels)+%h+humidity+%w+wind&m"
    local detail
    detail=$(curl -s --max-time 5 "$detail_url" 2>/dev/null)
    
    if [[ -n "$detail" ]] && [[ "$detail" != *"Unknown"* ]]; then
        echo -e "  \033[38;2;200;200;220m  ${detail}${RST}"
    fi
    
    echo ""
    
    local moon_url="https://wttr.in/?format=%m"
    local moon
    moon=$(curl -s --max-time 3 "$moon_url" 2>/dev/null)
    if [[ -n "$moon" ]]; then
        echo -e "  \033[38;2;255;220;0m  Moon: ${moon}${RST}"
    fi
    
    echo ""
}

weather_motd_line() {
    local weather
    weather=$(fetch_weather 2>/dev/null)
    
    if [[ "$weather" != "N/A" ]] && [[ -n "$weather" ]]; then
        echo -e "  \033[38;2;100;100;120m  Weather  \033[38;2;0;200;255m${weather}\033[0m"
    fi
}
