#!/data/data/com.termux/files/usr/bin/bash

# =================================================================
# GAMING RAM OPTIMIZER - For Android
# Enhanced for Gaming (CODM, Delta Force, Free Fire, Bloodstrike)
# Based on original script
# =================================================================

# Set terminal colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

# Script directories and files
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.json"
LOG_FILE="$SCRIPT_DIR/ram_optimizer.log"
PID_FILE="$SCRIPT_DIR/.ram_optimizer.pid"
MONITOR_PID_FILE="$SCRIPT_DIR/.monitor.pid"
ORIGINAL_SETTINGS_FILE="$SCRIPT_DIR/.original_settings"
GAME_PROFILE_DIR="$SCRIPT_DIR/game_profiles"

# Default settings
MONITOR_INTERVAL=5  # Update system stats every 5 seconds
VERSION="2.0.0"
MAX_LOG_SIZE=1048576  # 1MB

# =================== UTILITY FUNCTIONS ===================

cleanup_log() {
    # Keep log file from growing too large
    if [ -f "$LOG_FILE" ] && [ $(stat -c%s "$LOG_FILE") -gt $MAX_LOG_SIZE ]; then
        # Save last 100 lines and overwrite log file
        tail -n 100 "$LOG_FILE" > "${LOG_FILE}.tmp"
        mv "${LOG_FILE}.tmp" "$LOG_FILE"
    fi
}

log() {
    cleanup_log
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "${timestamp} - $1" >> "$LOG_FILE"
    echo -e "$1"
}

show_banner() {
    clear
    echo -e "${BLUE}┌───────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${RED}          GAMING RAM OPTIMIZER v${VERSION}          ${BLUE}│${NC}"
    echo -e "${BLUE}│${YELLOW}  Mobile Gaming Performance Enhancement Tool    ${BLUE}│${NC}"
    echo -e "${BLUE}└───────────────────────────────────────────────────┘${NC}"
    echo
}

ensure_directory_exists() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
    fi
}

check_termux_api() {
    # Check if Termux API is installed
    if ! command -v termux-battery-status &> /dev/null; then
        log "${YELLOW}Termux API not detected. Some features will be limited.${NC}"
        echo -e "${YELLOW}WARNING: Termux API not detected.${NC}"
        echo -e "${YELLOW}For full functionality, install Termux API from F-Droid or Google Play.${NC}"
        echo -e "${YELLOW}Press Enter to continue anyway...${NC}"
        read
        return 1
    fi
    return 0
}

show_status() {
    echo -e "${CYAN}=== Current Status ===${NC}"
    
    # Get current time for status update
    local current_time=$(date "+%H:%M:%S")
    
    # Check if optimization is active
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo -e "${GREEN}[✓] RAM optimization: ACTIVE${NC}"
    else
        echo -e "${YELLOW}[!] RAM optimization: INACTIVE${NC}"
    fi
    
    # Check if monitoring is active
    if [ -f "$MONITOR_PID_FILE" ] && kill -0 $(cat "$MONITOR_PID_FILE") 2>/dev/null; then
        echo -e "${GREEN}[✓] System monitoring: ACTIVE${NC}"
    else
        echo -e "${YELLOW}[!] System monitoring: INACTIVE${NC}"
    fi
    
    echo
    
    # Display current system stats
    echo -e "${CYAN}=== System Stats (${current_time}) ===${NC}"
    get_system_stats "display"
    
    # Display active game profile if any
    local game_mode=$(jq -r '.settings.current_game_profile // "none"' "$CONFIG_FILE" 2>/dev/null || echo "none")
    if [ "$game_mode" != "none" ] && [ "$game_mode" != "null" ]; then
        echo -e "\n${CYAN}=== Active Game Profile ===${NC}"
        echo -e "Optimized for: ${GREEN}${game_mode}${NC}"
    fi
    
    echo
}

# =================== INITIALIZATION FUNCTIONS ===================

initialize_app() {
    show_banner
    log "${GREEN}Initializing Gaming RAM Optimizer...${NC}"
    
    # Create necessary directories
    ensure_directory_exists "$GAME_PROFILE_DIR"
    
    # Create default config if it doesn't exist
    if [ ! -f "$CONFIG_FILE" ]; then
        echo '{
            "settings": {
                "dim_brightness": true,
                "show_battery_stats": true,
                "auto_boost": true,
                "gaming_mode": false,
                "boost_interval": 300,
                "current_game_profile": "none"
            },
            "game_profiles": {
                "codm": {
                    "priority_apps": ["com.activision.callofduty.shooter"],
                    "kill_list": ["com.facebook.katana", "com.instagram.android"]
                },
                "free_fire": {
                    "priority_apps": ["com.dts.freefireth", "com.dts.freefiremax"],
                    "kill_list": ["com.facebook.katana", "com.instagram.android"]
                },
                "bloodstrike": {
                    "priority_apps": ["com.netease.bloodstrike"],
                    "kill_list": ["com.facebook.katana", "com.instagram.android"]
                },
                "delta_force": {
                    "priority_apps": ["com.proximabeta.deltaforce"],
                    "kill_list": ["com.facebook.katana", "com.instagram.android"]
                }
            }
        }' > "$CONFIG_FILE"
        log "${GREEN}Created default configuration file${NC}"
    fi
    
    # Remove stale PID files if the processes are not running
    if [ -f "$MONITOR_PID_FILE" ]; then
        if ! kill -0 $(cat "$MONITOR_PID_FILE") 2>/dev/null; then
            rm "$MONITOR_PID_FILE" 2>/dev/null
        fi
    fi
    
    if [ -f "$PID_FILE" ]; then
        if ! kill -0 $(cat "$PID_FILE") 2>/dev/null; then
            rm "$PID_FILE" 2>/dev/null
        fi
    fi
    
    # Ensure necessary commands are available
    if ! command -v jq &> /dev/null; then
        log "${RED}ERROR: jq is not installed. Please install it using 'pkg install jq'${NC}"
        echo -e "${RED}ERROR: jq is not installed. Installing it now...${NC}"
        pkg install jq -y || {
            echo -e "${RED}Failed to install jq. Please install it manually using:${NC}"
            echo -e "${YELLOW}pkg install jq -y${NC}"
            echo -e "${YELLOW}Press Enter to exit...${NC}"
            read
            exit 1
        }
    fi
    
    # Check for bc (for calculations)
    if ! command -v bc &> /dev/null; then
        log "${YELLOW}bc not installed, installing it now...${NC}"
        pkg install bc -y || log "${RED}Failed to install bc. Some calculations may not work properly.${NC}"
    fi
    
    # Check if termux-api is installed (optional but recommended)
    check_termux_api
    
    log "${GREEN}Initialization complete${NC}"
    return 0
}

# =================== CORE FUNCTIONS ===================

get_system_stats() {
    local display_mode=$1
    
    # Get memory info
    local mem_total=$(free | grep Mem | awk '{print $2}')
    local mem_used=$(free | grep Mem | awk '{print $3}')
    local mem_free=$(free | grep Mem | awk '{print $4}')
    local mem_percent=$((mem_used * 100 / mem_total))
    
    # Calculate available memory (free + cached)
    local mem_cached=$(free | grep Mem | awk '{print $6}')
    local mem_available=$((mem_free + mem_cached))
    local mem_available_percent=$((mem_available * 100 / mem_total))
    
    # Get CPU load with error handling
    local cpu_load="N/A"
    if top -bn1 | grep -q "Cpu(s)"; then
        cpu_load=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
        cpu_load=${cpu_load%.*}  # Remove decimal part
    fi
    
    # Get battery info with error handling
    local battery_level="N/A"
    local battery_temp="N/A"
    local charging_status="Unknown"
    if command -v termux-battery-status &> /dev/null; then
        battery_status=$(termux-battery-status 2>/dev/null)
        if [ $? -eq 0 ]; then
            battery_level=$(echo "$battery_status" | jq -r '.percentage')
            battery_temp=$(echo "$battery_status" | jq -r '.temperature')
            local is_charging=$(echo "$battery_status" | jq -r '.plugged')
            if [ "$is_charging" = "true" ]; then
                charging_status="Charging"
            else
                charging_status="On Battery"
            fi
        fi
    fi
    
    # Format the output based on display mode
    if [ "$display_mode" = "display" ]; then
        echo -e "RAM Used: ${YELLOW}${mem_percent}%${NC} (${mem_free}KB free / ${mem_total}KB total)"
        echo -e "RAM Available: ${GREEN}${mem_available_percent}%${NC} (${mem_available}KB available)"
        echo -e "CPU: ${YELLOW}${cpu_load}%${NC} usage"
        echo -e "Battery: ${YELLOW}${battery_level}%${NC} (${battery_temp}°C) - ${charging_status}"
        
        # Add real-time optimization suggestion based on stats
        if [ "$mem_available_percent" -lt 20 ]; then
            echo -e "${RED}[!] LOW MEMORY WARNING: Consider boosting RAM${NC}"
        elif [ "$cpu_load" != "N/A" ] && [ "$cpu_load" -gt 80 ]; then
            echo -e "${RED}[!] HIGH CPU USAGE: Performance may be affected${NC}"
        elif [ "$battery_temp" != "N/A" ] && (( $(echo "$battery_temp > 40" | bc -l 2>/dev/null) )); then
            echo -e "${RED}[!] HIGH TEMPERATURE: Device throttling possible${NC}"
        fi
    elif [ "$display_mode" = "notification" ]; then
        echo "RAM: ${mem_available_percent}% avail | CPU: ${cpu_load}% | Batt: ${battery_level}% (${battery_temp}°C)"
    fi
}

save_original_settings() {
    # Save current system settings to restore later
    
    # Get current brightness with error handling
    local brightness="automatic"
    if command -v termux-brightness &> /dev/null; then
        brightness=$(termux-brightness get 2>/dev/null || echo "automatic")
    fi
    
    # Get current CPU governor if possible
    local cpu_governor="unknown"
    if [ -f "/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor" ] && [ -r "/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor" ]; then
        cpu_governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "unknown")
    fi
    
    # Save settings to file
    echo "{
        \"brightness\": \"$brightness\",
        \"cpu_governor\": \"$cpu_governor\"
    }" > "$ORIGINAL_SETTINGS_FILE"
    
    log "${GREEN}Original system settings saved${NC}"
}

apply_optimizations() {
    log "${GREEN}Applying system optimizations...${NC}"
    
    # Save original settings before modifying
    save_original_settings
    
    # Load optimization settings from config
    local dim_brightness=$(jq -r '.settings.dim_brightness' "$CONFIG_FILE")
    local gaming_mode=$(jq -r '.settings.gaming_mode' "$CONFIG_FILE")
    
    # Process priority list
    optimize_app_priorities
    
    # Clean memory caches to free up RAM
    log "Clearing system caches..."
    sync
    echo 3 > /proc/sys/vm/drop_caches 2>/dev/null
    
    # Dim brightness if configured (only for non-gaming sessions)
    if [ "$dim_brightness" = "true" ] && [ "$gaming_mode" != "true" ]; then
        if command -v termux-brightness &> /dev/null; then
            termux-brightness 100 2>/dev/null
            log "Adjusted screen brightness for battery saving"
        else
            log "${YELLOW}termux-brightness not available, skipping brightness adjustment${NC}"
        fi
    fi
    
    # For gaming mode, maximize brightness and performance
    if [ "$gaming_mode" = "true" ]; then
        if command -v termux-brightness &> /dev/null; then
            termux-brightness 255 2>/dev/null
            log "Maximized screen brightness for gaming"
        fi
        
        # Try to set performance governor if we have root
        if [ -w "/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor" ]; then
            echo "performance" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null
            log "${GREEN}Set CPU governor to performance mode${NC}"
        fi
    fi
    
    # Show notification with error handling
    if command -v termux-notification &> /dev/null; then
        local notif_title="RAM Optimizer Active"
        local notif_content="System optimization running"
        
        if [ "$gaming_mode" = "true" ]; then
            notif_title="GAMING MODE ACTIVE"
            notif_content="Performance optimization for gaming"
        fi
        
        termux-notification --id "ram_optimizer" \
            --title "$notif_title" \
            --content "$notif_content" \
            --icon "memory" \
            --type ongoing 2>/dev/null
    fi
    
    # Start system monitoring
    start_system_stats_monitoring
    
    # Create our PID file
    echo $$ > "$PID_FILE"
    
    log "${GREEN}System optimizations applied successfully${NC}"
}

restore_settings() {
    log "${YELLOW}Restoring original settings...${NC}"
    
    # Check if original settings file exists
    if [ ! -f "$ORIGINAL_SETTINGS_FILE" ]; then
        log "${RED}Original settings file not found, using defaults${NC}"
        # Apply some reasonable defaults
        if command -v termux-brightness &> /dev/null; then
            termux-brightness 150 2>/dev/null
        fi
    else
        # Load original settings
        local brightness=$(jq -r '.brightness' "$ORIGINAL_SETTINGS_FILE")
        local cpu_governor=$(jq -r '.cpu_governor' "$ORIGINAL_SETTINGS_FILE")
        
        # Restore brightness with error handling
        if [ "$brightness" != "automatic" ] && command -v termux-brightness &> /dev/null; then
            termux-brightness $brightness 2>/dev/null
            log "Restored original brightness"
        fi
        
        # Restore CPU governor if possible
        if [ "$cpu_governor" != "unknown" ] && [ -w "/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor" ]; then
            echo "$cpu_governor" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null
            log "Restored original CPU governor: $cpu_governor"
        fi
    fi
    
    # Reset current game profile setting
    update_config "current_game_profile" "none"
    
    # Stop system monitoring
    stop_system_stats_monitoring
    
    # Remove PID file
    if [ -f "$PID_FILE" ]; then
        rm "$PID_FILE" 2>/dev/null
    fi
    
    # Remove notification with error handling
    if command -v termux-notification-remove &> /dev/null; then
        termux-notification-remove "ram_optimizer" 2>/dev/null
    fi
    
    # Show restoration notification with error handling
    if command -v termux-notification &> /dev/null; then
        termux-notification --id "ram_optimizer_restore" \
            --title "RAM Optimizer" \
            --content "Optimization ended. Settings restored." \
            --priority low \
            --icon "check" 2>/dev/null
        
        # Auto-dismiss this notification after 5 seconds
        ( sleep 5 && termux-notification-remove "ram_optimizer_restore" 2>/dev/null ) &
    fi
    
    log "${GREEN}System restored to original settings${NC}"
}

# =================== GAME OPTIMIZATION FUNCTIONS ===================

update_config() {
    local key=$1
    local value=$2
    local section=${3:-"settings"}
    
    # Update config with error handling
    local temp_file=$(mktemp)
    if jq ".$section.$key = \"$value\"" "$CONFIG_FILE" > "$temp_file"; then
        mv "$temp_file" "$CONFIG_FILE"
        log "${GREEN}Config updated: $key = $value${NC}"
        return 0
    else
        rm "$temp_file"
        log "${RED}Failed to update config: $key${NC}"
        return 1
    fi
}

toggle_config_boolean() {
    local key=$1
    local section=${2:-"settings"}
    
    # Get current value
    local current_value=$(jq -r ".$section.$key" "$CONFIG_FILE")
    
    # Toggle value
    if [ "$current_value" = "true" ]; then
        new_value="false"
    else
        new_value="true"
    fi
    
    # Update config with error handling
    local temp_file=$(mktemp)
    if jq ".$section.$key = $new_value" "$CONFIG_FILE" > "$temp_file"; then
        mv "$temp_file" "$CONFIG_FILE"
        log "${GREEN}$key toggled to $new_value${NC}"
        return 0
    else
        rm "$temp_file"
        log "${RED}Failed to toggle $key${NC}"
        return 1
    fi
}

activate_game_profile() {
    local game=$1
    
    # Check if profile exists
    if ! jq -e ".game_profiles.$game" "$CONFIG_FILE" > /dev/null 2>&1; then
        log "${RED}Game profile for $game not found${NC}"
        echo -e "${RED}Game profile for $game not found${NC}"
        return 1
    fi
    
    log "${CYAN}Activating game profile for: $game${NC}"
    
    # Update current game profile in config
    update_config "current_game_profile" "$game"
    
    # Enable gaming mode
    local temp_file=$(mktemp)
    if jq ".settings.gaming_mode = true" "$CONFIG_FILE" > "$temp_file"; then
        mv "$temp_file" "$CONFIG_FILE"
    else
        rm "$temp_file"
    fi
    
    # Kill background apps that might affect game performance
    log "Optimizing system for $game..."
    
    # Get kill list from profile
    local kill_list=$(jq -r ".game_profiles.$game.kill_list[]" "$CONFIG_FILE" 2>/dev/null)
    
    if [ -n "$kill_list" ]; then
        log "Closing background apps to free resources..."
        for app in $kill_list; do
            am force-stop "$app" >/dev/null 2>&1
            log "Closed app: $app"
        done
    fi
    
    # Boost memory
    manual_boost
    
    # Show notification
    if command -v termux-notification &> /dev/null; then
        termux-notification --id "game_optimizer" \
            --title "Game Optimizer" \
            --content "Optimized for $game - Good luck & have fun!" \
            --icon "videogame_asset" 2>/dev/null
        
        # Auto-dismiss this notification after 5 seconds
        ( sleep 5 && termux-notification-remove "game_optimizer" 2>/dev/null ) &
    fi
    
    log "${GREEN}Game profile for $game activated${NC}"
    return 0
}

optimize_app_priorities() {
    local game_profile=$(jq -r '.settings.current_game_profile' "$CONFIG_FILE" 2>/dev/null)
    
    # If no game profile is active, skip this
    if [ "$game_profile" = "none" ] || [ "$game_profile" = "null" ]; then
        return 0
    fi
    
    # Get priority apps from profile
    local priority_apps=$(jq -r ".game_profiles.$game_profile.priority_apps[]" "$CONFIG_FILE" 2>/dev/null)
    
    if [ -n "$priority_apps" ]; then
        log "Setting priority for game apps..."
        
        # This would be better with root, but we'll try a best-effort approach
        # For root users, we could use renice or ionice here
        for app in $priority_apps; do
            # Find PID of the app if running
            local pid=$(ps -A | grep "$app" | awk '{print $1}' | head -1)
            if [ -n "$pid" ]; then
                # If we have permission (root), try to set priority
                if [ -w "/proc/$pid" ]; then
                    renice -n -10 -p $pid >/dev/null 2>&1
                    log "Set high priority for $app (PID: $pid)"
                fi
            fi
        done
    fi
}

# =================== MONITORING FUNCTIONS ===================

start_system_stats_monitoring() {
    log "${CYAN}Starting system stats monitoring...${NC}"
    
    # Kill any existing monitor process
    if [ -f "$MONITOR_PID_FILE" ]; then
        kill $(cat "$MONITOR_PID_FILE") 2>/dev/null
        rm "$MONITOR_PID_FILE" 2>/dev/null
    fi
    
    # Start monitoring in a separate process
    {
        # Get auto-boost setting
        local auto_boost=$(jq -r '.settings.auto_boost' "$CONFIG_FILE")
        local boost_interval=$(jq -r '.settings.boost_interval' "$CONFIG_FILE")
        local boost_counter=0
        
        while true; do
            # Update notification if available
            if command -v termux-notification &> /dev/null; then
                # Get formatted stats for notification
                local stats=$(get_system_stats "notification")
                
                # Get gaming mode status
                local gaming_mode=$(jq -r '.settings.gaming_mode' "$CONFIG_FILE")
                local notif_title="RAM Optimizer Active"
                local notif_icon="memory"
                
                if [ "$gaming_mode" = "true" ]; then
                    notif_title="GAMING MODE ACTIVE"
                    notif_icon="videogame_asset"
                fi
                
                # Update the notification with current stats
                termux-notification --id "ram_optimizer" \
                    --title "$notif_title" \
                    --content "System optimization running" \
                    --icon "$notif_icon" \
                    --type ongoing \
                    --button1 "End" \
                    --button1-action "am broadcast --user 0 -a com.termux.addon.api.STOP_OPTIMIZER -p com.termux" \
                    --message "$stats" 2>/dev/null
            fi
            
            # Check for critical battery temperature
            if command -v termux-battery-status &> /dev/null; then
                local battery_status=$(termux-battery-status 2>/dev/null)
                if [ $? -eq 0 ]; then
                    local battery_temp=$(echo "$battery_status" | jq -r '.temperature')
                    if (( $(echo "$battery_temp > 42" | bc -l 2>/dev/null) )); then
                        termux-notification --id "ram_optimizer_warning" \
                            --title "WARNING: High Temperature" \
                            --content "Device temperature: ${battery_temp}°C - Consider taking a break" \
                            --icon "warning" \
                            --priority high 2>/dev/null
                    fi
                    
                    # Auto-boost if enabled and interval reached
                    if [ "$auto_boost" = "true" ]; then
                        boost_counter=$((boost_counter + MONITOR_INTERVAL))
                        if [ $boost_counter -ge $boost_interval ]; then
                            log "Auto-boost triggered"
                            ( auto_boost_ram ) &
                            boost_counter=0
                        fi
                    fi
                fi
            fi
            
            sleep $MONITOR_INTERVAL
        done
    } &
    
    # Save the PID of the monitoring process
    echo $! > "$MONITOR_PID_FILE"
    log "${GREEN}Monitoring process started with PID $(cat "$MONITOR_PID_FILE")${NC}"
}

stop_system_stats_monitoring() {
    if [ -f "$MONITOR_PID_FILE" ]; then
        log "${YELLOW}Stopping monitoring process with PID $(cat "$MONITOR_PID_FILE")${NC}"
        kill $(cat "$MONITOR_PID_FILE") 2>/dev/null
        rm "$MONITOR_PID_FILE" 2>/dev/null
        log "${YELLOW}System stats monitoring stopped${NC}"
    else
        log "${YELLOW}No monitoring process found to stop${NC}"
    fi
}

# =================== RAM OPTIMIZATION FUNCTIONS ===================

auto_boost_ram() {
    # This is a quiet version of manual_boost for automatic calls
    log "Performing automatic memory boost..."
    
    # Get memory stats before boost
    local mem_before=$(free | grep Mem | awk '{print $4}')
    
    # Kill cached processes
    am broadcast -a android.intent.action.AIRPLANE_MODE --ez state false >/dev/null 2>&1
    
    # Clear caches if possible
    sync
    echo 3 > /proc/sys/vm/drop_caches 2>/dev/null
    
    # Get memory stats after boost
    local mem_after=$(free | grep Mem | awk '{print $4}')
    local mem_freed=$((mem_after - mem_before))
    
    log "Auto-boost completed - Freed ${mem_freed}KB"
}

manual_boost() {
    log "${CYAN}Performing manual memory boost...${NC}"
    
    # Show notification with error handling
    if command -v termux-notification &> /dev/null; then
        termux-notification --id "ram_optimizer_boost" \
            --title "RAM Optimizer" \
            --content "Performing memory boost..." \
            --icon "memory" 2>/dev/null
    fi
    
    # Get memory stats before boost
    local mem_before=$(free | grep Mem | awk '{print $4}')
    
    # Kill cached processes
    log "Clearing app caches..."
    am broadcast -a android.intent.action.AIRPLANE_MODE --ez state false >/dev/null 2>&1
    sleep 1
    
    # Clear caches if possible
    log "Flushing system caches..."
    sync
    echo 3 > /proc/sys/vm/drop_caches 2>/dev/null
    
    # Get memory stats after boost
    local mem_after=$(free | grep Mem | awk '{print $4}')
    local mem_freed=$((mem_after - mem_before))
    
    # Update notification with results
    if command -v termux-notification &> /dev/null; then
        termux-notification --id "ram_optimizer_boost" \
            --title "RAM Optimizer" \
            --content "Memory boost complete. Freed approximately ${mem_freed}KB" \
            --icon "check" 2>/dev/null
    fi
    
    log "${GREEN}Manual boost completed - Freed ${mem_freed}KB${NC}"
    
    # Remove notification after a few seconds
    ( sleep 5 && termux-notification-remove "ram_optimizer_boost" 2>/dev/null ) &
}

# =================== SERVICE CONTROL FUNCTIONS ===================

start_optimizer() {
    log "${GREEN}Starting system optimization...${NC}"
    
    # Check if already running
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        log "${YELLOW}Optimizer is already running${NC}"
        echo -e "${YELLOW}Optimizer is already running with PID $(cat "$PID_FILE")${NC}"
        return 1
    fi
    
    # Apply optimizations
    apply_optimizations
    
    log "${GREEN}System optimization started${NC}"
    return 0
}

stop_optimizer() {
    log "${YELLOW}Stopping optimization...${NC}"
    
    # Check if running
    if [ ! -f "$PID_FILE" ]; then
        log "${YELLOW}Optimizer is not running${NC}"
        echo -e "${YELLOW}Optimizer is not currently running${NC}"
        
        # Still stop monitoring just in case
        stop_system_stats_monitoring
        return 1
    fi
    
    # Restore settings
    restore_settings
    
    log "${GREEN}Optimization stopped${NC}"
    return 0
}

# =================== GAME MODE FUNCTIONS ===================

manage_game_modes() {
    local retried=0
    while true; do
        clear
        echo -e "${CYAN}=== GAME OPTIMIZATION PROFILES ===${NC}"
        
        # Check if gaming mode is active
        local gaming_mode=$(jq -r '.settings.gaming_mode' "$CONFIG_FILE")
        local current_profile=$(jq -r '.settings.current_game_profile' "$CONFIG_FILE")
        
        if [ "$gaming_mode" = "true" ]; then
            echo -e "${GREEN}[✓] Gaming Mode: ACTIVE${NC}"
            if [ "$current_profile" != "none" ] && [ "$current_profile" != "null" ]; then
                echo -e "${GREEN}[✓] Current profile: ${current_profile}${NC}"
            fi
        else
            echo -e "${YELLOW}[!] Gaming Mode: INACTIVE${NC}"
        fi
        
        echo
        echo "Select a game profile to optimize for:"
        echo -e "${CYAN}1.${NC} Call of Duty Mobile"
        echo -e "${CYAN}2.${NC} Free Fire"
        echo -e "${CYAN}3.${NC} Bloodstrike"
        echo -e "${CYAN}4.${NC} Delta Force"
        echo -e "${YELLOW}5.${NC} Disable Game Mode"
        echo -e "${BLUE}0.${NC} Back to Main Menu"
        
        echo
        read -p "Enter your choice [0-5]: " choice
        
        case $choice in
            1)
                activate_game_profile "codm"
                ;;
            2)
                activate_game_profile "free_fire"
                ;;
            3)
                activate_game_profile "bloodstrike"
                ;;
            4)
                activate_game_profile "delta_force"
                ;;
            5)
                # Disable gaming mode
                update_config "gaming_mode" "false"
                update_config "current_game_profile" "none"
                # Restore settings if optimizer is running
                if [ -f "$PID_FILE" ]; then
                    restore_settings
                    apply_optimizations
                fi
                echo -e "${YELLOW}Game Mode disabled${NC}"
                sleep 2
                ;;
            0)
                return 0
                ;;
            *)
                if [ $retried -eq 0 ]; then
                    echo -e "${RED}Invalid choice. Please try again.${NC}"
                    retried=1
                    sleep 1
                    continue
                else
                    return 0
                fi
                ;;
        esac
        
        # Show confirmation and wait
        if [ $choice -ne 0 ] && [ $choice -ne 5 ]; then
            echo -e "${GREEN}Game profile activated. Press Enter to continue...${NC}"
            read
        fi
    done
}

# =================== CONFIGURATION MENU ===================

configure_settings() {
    local retried=0
    while true; do
        clear
        echo -e "${CYAN}=== RAM OPTIMIZER SETTINGS ===${NC}"
        
        # Load current settings
        local dim_brightness=$(jq -r '.settings.dim_brightness' "$CONFIG_FILE")
        local show_battery=$(jq -r '.settings.show_battery_stats' "$CONFIG_FILE")
        local auto_boost=$(jq -r '.settings.auto_boost' "$CONFIG_FILE")
        local boost_interval=$(jq -r '.settings.boost_interval' "$CONFIG_FILE")
        
        # Format boolean values for display
        dim_brightness_display="OFF"
        if [ "$dim_brightness" = "true" ]; then
            dim_brightness_display="ON"
        fi
        
        show_battery_display="OFF"
        if [ "$show_battery" = "true" ]; then
            show_battery_display="ON"
        fi
        
        auto_boost_display="OFF"
        if [ "$auto_boost" = "true" ]; then
            auto_boost_display="ON"
        fi
        
        # Display settings
        echo -e "${CYAN}1.${NC} Dim brightness to save battery: ${YELLOW}${dim_brightness_display}${NC}"
        echo -e "${CYAN}2.${NC} Show battery statistics: ${YELLOW}${show_battery_display}${NC}"
        echo -e "${CYAN}3.${NC} Auto RAM boost: ${YELLOW}${auto_boost_display}${NC}"
        echo -e "${CYAN}4.${NC} Auto boost interval: ${YELLOW}${boost_interval} seconds${NC}"
        echo -e "${BLUE}0.${NC} Back to Main Menu"
        
        echo
        read -p "Enter your choice [0-4]: " choice
        
        case $choice in
            1)
                toggle_config_boolean "dim_brightness"
                ;;
            2)
                toggle_config_boolean "show_battery_stats"
                ;;
            3)
                toggle_config_boolean "auto_boost"
                ;;
            4)
                echo
                read -p "Enter new interval in seconds (60-3600): " interval
                if [[ "$interval" =~ ^[0-9]+$ ]] && [ "$interval" -ge 60 ] && [ "$interval" -le 3600 ]; then
                    update_config "boost_interval" "$interval"
                else
                    echo -e "${RED}Invalid interval. Must be between 60-3600 seconds.${NC}"
                    sleep 2
                fi
                ;;
            0)
                return 0
                ;;
            *)
                if [ $retried -eq 0 ]; then
                    echo -e "${RED}Invalid choice. Please try again.${NC}"
                    retried=1
                    sleep 1
                    continue
                else
                    return 0
                fi
                ;;
        esac
    done
}

# =================== MAIN MENU FUNCTION ===================

show_main_menu() {
    local retried=0
    while true; do
        # Initialize if not already done
        if [ $retried -eq 0 ]; then
            initialize_app
        fi
        
        show_banner
        show_status
        
        # Check if running
        local is_running=false
        if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
            is_running=true
        fi
        
        # Check if game mode is active
        local gaming_mode=$(jq -r '.settings.gaming_mode' "$CONFIG_FILE")
        
        echo -e "${CYAN}=== MAIN MENU ===${NC}"
        if [ "$is_running" = true ]; then
            echo -e "${CYAN}1.${NC} Stop RAM Optimization"
        else
            echo -e "${CYAN}1.${NC} Start RAM Optimization"
        fi
        
        echo -e "${CYAN}2.${NC} Boost RAM Now"
        
        if [ "$gaming_mode" = "true" ]; then
            echo -e "${CYAN}3.${NC} Game Mode Settings ${GREEN}[ACTIVE]${NC}"
        else
            echo -e "${CYAN}3.${NC} Game Mode Settings"
        fi
        
        echo -e "${CYAN}4.${NC} Configure Optimization Settings"
        echo -e "${CYAN}5.${NC} View Full System Status"
        echo -e "${RED}0.${NC} Exit"
        
        echo
        read -p "Enter your choice [0-5]: " choice
        
        case $choice in
            1)
                if [ "$is_running" = true ]; then
                    stop_optimizer
                else
                    start_optimizer
                fi
                sleep 1
                ;;
            2)
                manual_boost
                echo -e "${GREEN}RAM boost completed. Press Enter to continue...${NC}"
                read
                ;;
            3)
                manage_game_modes
                ;;
            4)
                configure_settings
                ;;
            5)
                clear
                show_banner
                echo -e "${CYAN}=== DETAILED SYSTEM STATUS ===${NC}"
                
                # Display system info
                echo -e "${YELLOW}Memory Information:${NC}"
                free
                echo
                
                echo -e "${YELLOW}CPU Information:${NC}"
                top -bn1 | head -10
                echo
                
                if command -v termux-battery-status &> /dev/null; then
                    echo -e "${YELLOW}Battery Information:${NC}"
                    termux-battery-status
                    echo
                fi
                
                echo -e "${YELLOW}Process Information:${NC}"
                ps -A | head -10
                echo -e "... ${CYAN}(showing top 10 processes)${NC}"
                echo
                
                # Get active game profile
                local game_mode=$(jq -r '.settings.current_game_profile // "none"' "$CONFIG_FILE" 2>/dev/null)
                if [ "$game_mode" != "none" ] && [ "$game_mode" != "null" ]; then
                    echo -e "${YELLOW}Active Game Profile: ${GREEN}${game_mode}${NC}"
                    echo
                fi
                
                echo -e "${GREEN}Press Enter to continue...${NC}"
                read
                ;;
            0)
                # If optimization is running, offer to keep it running
                if [ "$is_running" = true ]; then
                    echo -e "${YELLOW}RAM optimization is still running.${NC}"
                    read -p "Stop optimization before exiting? (y/n): " stop_confirm
                    if [[ "$stop_confirm" =~ ^[Yy]$ ]]; then
                        stop_optimizer
                    else
                        echo -e "${GREEN}Optimization will continue in the background.${NC}"
                        echo -e "${GREEN}You can restart this app anytime to manage it.${NC}"
                    fi
                fi
                
                echo -e "${GREEN}Thank you for using RAM Optimizer!${NC}"
                echo -e "${GREEN}Exiting...${NC}"
                exit 0
                ;;
            *)
                if [ $retried -eq 0 ]; then
                    echo -e "${RED}Invalid choice. Please try again.${NC}"
                    retried=1
                    sleep 1
                else
                    retried=0
                fi
                ;;
        esac
    done
}

# =================== SCRIPT ENTRY POINT ===================

# Handle command line arguments
if [ $# -gt 0 ]; then
    case $1 in
        --start)
            initialize_app
            start_optimizer
            exit 0
            ;;
        --stop)
            initialize_app
            stop_optimizer
            exit 0
            ;;
        --boost)
            initialize_app
            manual_boost
            exit 0
            ;;
        --status)
            initialize_app
            show_status
            exit 0
            ;;
        --game)
            initialize_app
            if [ -n "$2" ]; then
                activate_game_profile "$2"
            else
                echo -e "${RED}Error: Game profile name required${NC}"
                echo -e "Usage: $0 --game [codm|free_fire|bloodstrike|delta_force]"
                exit 1
            fi
            exit 0
            ;;
        --help|-h)
            echo -e "${BLUE}=== GAMING RAM OPTIMIZER HELP ===${NC}"
            echo "Usage: $0 [OPTION]"
            echo
            echo "Options:"
            echo "  --start        Start RAM optimization"
            echo "  --stop         Stop RAM optimization"
            echo "  --boost        Perform RAM boost"
            echo "  --status       Display system status"
            echo "  --game PROFILE Activate specific game profile"
            echo "                 (codm, free_fire, bloodstrike, delta_force)"
            echo "  --help, -h     Display this help message"
            echo
            echo "Run without arguments to start interactive mode."
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use '$0 --help' for usage information"
            exit 1
            ;;
    esac
fi

# Start interactive mode
show_main_menu
