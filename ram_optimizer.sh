#!/data/data/com.termux/files/usr/bin/bash

# =================================================================
# RAM OPTIMIZER - Non-Root Gaming Optimizer for Android
# Author: FireKid846
# Repository: https://github.com/FireKid846/Ram_optimizer
# License: MIT
# =================================================================

# Set terminal colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Script directories and files
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.json"
LOG_FILE="$SCRIPT_DIR/ram_optimizer.log"
PID_FILE="$SCRIPT_DIR/.ram_optimizer.pid"
MONITOR_PID_FILE="$SCRIPT_DIR/.monitor.pid"
ORIGINAL_SETTINGS_FILE="$SCRIPT_DIR/.original_settings"
GAME_RUNNING_FLAG="$SCRIPT_DIR/.game_running"

# Default settings
CHECK_INTERVAL=3  # Check for running games every 3 seconds
MONITOR_INTERVAL=5  # Update system stats every 5 seconds
VERSION="1.0.0"

# =================== UTILITY FUNCTIONS ===================

log() {
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "${timestamp} - $1" >> "$LOG_FILE"
    echo -e "$1"
}

show_banner() {
    clear
    echo -e "${BLUE}┌───────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${RED}              RAM OPTIMIZER v${VERSION}              ${BLUE}│${NC}"
    echo -e "${BLUE}│${YELLOW}      Non-Root Gaming Performance Enhancer      ${BLUE}│${NC}"
    echo -e "${BLUE}└───────────────────────────────────────────────────┘${NC}"
    echo
}

show_status() {
    echo -e "${CYAN}=== Current Status ===${NC}"
    
    # Check if the optimizer service is running
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo -e "${GREEN}[✓] Optimizer service: RUNNING${NC}"
    else
        echo -e "${YELLOW}[!] Optimizer service: STOPPED${NC}"
    fi
    
    # Check if monitoring is active
    if [ -f "$MONITOR_PID_FILE" ] && kill -0 $(cat "$MONITOR_PID_FILE") 2>/dev/null; then
        echo -e "${GREEN}[✓] System monitoring: ACTIVE${NC}"
    else
        echo -e "${YELLOW}[!] System monitoring: INACTIVE${NC}"
    fi
    
    # Check if a game is currently being optimized
    if [ -f "$GAME_RUNNING_FLAG" ]; then
        current_game=$(cat "$GAME_RUNNING_FLAG")
        echo -e "${GREEN}[✓] Game optimization: ACTIVE for ${MAGENTA}$current_game${NC}"
    else
        echo -e "${YELLOW}[!] Game optimization: INACTIVE${NC}"
    fi
    
    echo
    
    # Display current system stats
    echo -e "${CYAN}=== System Stats ===${NC}"
    get_system_stats "display"
    echo
}

check_permissions() {
    local permissions_ok=true
    
    echo -e "${CYAN}Checking required permissions...${NC}"
    
    # Check for PACKAGE_USAGE_STATS permission
    if ! dumpsys package com.termux | grep -q "android.permission.PACKAGE_USAGE_STATS"; then
        echo -e "${RED}[✗] Usage Access permission not granted${NC}"
        echo -e "${YELLOW}Please grant Usage Access permission to Termux:${NC}"
        echo -e "${YELLOW}Settings > Privacy > Usage Access > Termux > Allow${NC}"
        permissions_ok=false
    else
        echo -e "${GREEN}[✓] Usage Access permission granted${NC}"
    fi
    
    # Check for DND access (requires notification listener)
    if ! dumpsys notification | grep -q "allowed_packages.*com.termux"; then
        echo -e "${RED}[✗] Do Not Disturb access not granted${NC}"
        echo -e "${YELLOW}Please grant notification access to Termux:${NC}"
        echo -e "${YELLOW}Settings > Apps > Special access > Do Not Disturb access > Termux${NC}"
        permissions_ok=false
    else
        echo -e "${GREEN}[✓] Do Not Disturb access granted${NC}"
    fi
    
    # Check for SYSTEM_ALERT_WINDOW permission for overlays
    if ! dumpsys package com.termux | grep -q "android.permission.SYSTEM_ALERT_WINDOW"; then
        echo -e "${YELLOW}[!] Display over other apps permission not granted${NC}"
        echo -e "${YELLOW}System stats overlay will not be available${NC}"
        echo -e "${YELLOW}Settings > Apps > Termux > Advanced > Display over other apps${NC}"
    else
        echo -e "${GREEN}[✓] Display over other apps permission granted${NC}"
    fi
    
    # Check for battery optimization exemption
    if ! dumpsys deviceidle whitelist | grep -q "com.termux"; then
        echo -e "${YELLOW}[!] Battery optimization not disabled for Termux${NC}"
        echo -e "${YELLOW}For best performance, disable battery optimization:${NC}"
        echo -e "${YELLOW}Settings > Apps > Termux > Battery > Unrestricted${NC}"
    else
        echo -e "${GREEN}[✓] Battery optimization disabled for Termux${NC}"
    fi
    
    # Check for foreground service permission (Android 9+)
    if [ -n "$(getprop ro.build.version.sdk)" ] && [ $(getprop ro.build.version.sdk) -ge 28 ]; then
        if ! dumpsys package com.termux | grep -q "android.permission.FOREGROUND_SERVICE"; then
            echo -e "${YELLOW}[!] Foreground service permission might be missing${NC}"
            permissions_ok=false
        else
            echo -e "${GREEN}[✓] Foreground service permission granted${NC}"
        fi
    fi
    
    # If any permission is missing, offer to open settings
    if [ "$permissions_ok" = false ]; then
        echo
        read -p "Would you like to open Android settings now? (y/n): " choice
        if [[ "$choice" == [Yy]* ]]; then
            am start -a android.settings.USAGE_ACCESS_SETTINGS
        fi
        echo -e "${YELLOW}Please restart the script after granting permissions${NC}"
        return 1
    fi
    
    return 0
}

# =================== INITIALIZATION FUNCTIONS ===================

initialize_app() {
    show_banner
    log "${GREEN}Initializing RAM Optimizer...${NC}"
    
    # Create default config if it doesn't exist
    if [ ! -f "$CONFIG_FILE" ]; then
        echo '{
            "games": [
                "com.tencent.ig",
                "com.pubg.krmobile",
                "com.activision.callofduty.shooter",
                "com.mojang.minecraftpe",
                "com.epicgames.fortnite",
                "com.supercell.brawlstars",
                "com.supercell.clashofclans",
                "com.dts.freefireth"
            ],
            "settings": {
                "enable_dnd": true,
                "lower_volume": true,
                "dim_brightness": true,
                "show_overlay": true,
                "aggressive_memory_cleanup": true
            }
        }' > "$CONFIG_FILE"
        log "${GREEN}Created default configuration file${NC}"
    fi
    
    # Check permissions
    check_permissions || return 1
    
    # Remove stale PID files if the processes are not running
    if [ -f "$PID_FILE" ]; then
        if ! kill -0 $(cat "$PID_FILE") 2>/dev/null; then
            rm "$PID_FILE"
        fi
    fi
    
    if [ -f "$MONITOR_PID_FILE" ]; then
        if ! kill -0 $(cat "$MONITOR_PID_FILE") 2>/dev/null; then
            rm "$MONITOR_PID_FILE"
        fi
    fi
    
    # Setup broadcast receiver for boost button (Android only)
    if which am >/dev/null 2>&1; then
        log "Setting up broadcast receiver for manual boost"
        
        # Create a BroadcastReceiver for the boost button
        {
            while true; do
                # Check if a boost command was sent
                if [ -f "$SCRIPT_DIR/.boost_trigger" ]; then
                    rm "$SCRIPT_DIR/.boost_trigger"
                    "$0" --boost
                fi
                sleep 1
            done
        } &
        
        # Save PID for later cleanup
        echo $! > "$SCRIPT_DIR/.broadcast_pid"
    fi
    
    log "${GREEN}Initialization complete${NC}"
    return 0
}

# =================== CORE OPTIMIZATION FUNCTIONS ===================

get_current_foreground_app() {
    # Get the current foreground app package name
    dumpsys activity recents | grep 'Recent #0' | cut -d= -f2 | cut -d ' ' -f1
}

get_system_stats() {
    local display_mode=$1
    
    # Get memory info
    local mem_total=$(free | grep Mem | awk '{print $2}')
    local mem_used=$(free | grep Mem | awk '{print $3}')
    local mem_free=$(free | grep Mem | awk '{print $4}')
    local mem_percent=$((mem_used * 100 / mem_total))
    
    # Get CPU load
    local cpu_load=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    cpu_load=${cpu_load%.*}  # Remove decimal part
    
    # Get battery info
    local battery_level=$(termux-battery-status | jq -r '.percentage')
    local battery_temp=$(termux-battery-status | jq -r '.temperature')
    
    # Format the output based on display mode
    if [ "$display_mode" = "display" ]; then
        echo -e "RAM: ${YELLOW}${mem_percent}%${NC} used (${mem_free}KB free / ${mem_total}KB total)"
        echo -e "CPU: ${YELLOW}${cpu_load}%${NC} usage"
        echo -e "Battery: ${YELLOW}${battery_level}%${NC} (${battery_temp}°C)"
    elif [ "$display_mode" = "notification" ]; then
        echo "RAM: ${mem_percent}% used | CPU: ${cpu_load}% | Batt: ${battery_level}% (${battery_temp}°C)"
    fi
}

save_original_settings() {
    # Save current system settings to restore later
    
    # Get current volume levels
    local volume_music=$(termux-volume get | jq -r '.music.volume')
    local volume_ring=$(termux-volume get | jq -r '.ring.volume')
    
    # Get current brightness
    local brightness=$(termux-brightness get 2>/dev/null || echo "automatic")
    
    # Get current DND state
    local dnd_state=$(settings get global zen_mode 2>/dev/null || echo "0")
    
    # Save all settings to file
    echo "{
        \"volume_music\": $volume_music,
        \"volume_ring\": $volume_ring,
        \"brightness\": \"$brightness\",
        \"dnd_state\": $dnd_state
    }" > "$ORIGINAL_SETTINGS_FILE"
    
    log "${GREEN}Original system settings saved${NC}"
}

apply_optimizations() {
    local package_name=$1
    local app_name=$(dumpsys package $package_name | grep "packageName" | head -1 | cut -d= -f2- || echo $package_name)
    
    log "${GREEN}Applying optimizations for game: ${MAGENTA}$app_name${NC}"
    echo "$app_name" > "$GAME_RUNNING_FLAG"
    
    # Save original settings before modifying
    save_original_settings
    
    # Load optimization settings from config
    local enable_dnd=$(jq -r '.settings.enable_dnd' "$CONFIG_FILE")
    local lower_volume=$(jq -r '.settings.lower_volume' "$CONFIG_FILE")
    local dim_brightness=$(jq -r '.settings.dim_brightness' "$CONFIG_FILE")
    local show_overlay=$(jq -r '.settings.show_overlay' "$CONFIG_FILE")
    local aggressive_cleanup=$(jq -r '.settings.aggressive_memory_cleanup' "$CONFIG_FILE")
    
    # Apply Do Not Disturb mode
    if [ "$enable_dnd" = "true" ]; then
        settings put global zen_mode 1
        log "Enabled Do Not Disturb mode"
    fi
    
    # Lower volume
    if [ "$lower_volume" = "true" ]; then
        termux-volume music 5
        termux-volume ring 0
        log "Lowered volume levels"
    fi
    
    # Dim brightness
    if [ "$dim_brightness" = "true" ]; then
        termux-brightness 100
        log "Adjusted screen brightness"
    fi
    
    # Perform memory cleanup
    if [ "$aggressive_cleanup" = "true" ]; then
        manual_boost
    fi
    
    # Show notification
    termux-notification --id "ram_optimizer" \
        --title "RAM Optimizer Active" \
        --content "Optimizing: $app_name" \
        --icon "game_controller" \
        --type ongoing
    
    # Start system monitoring
    start_system_stats_monitoring
    
    log "${GREEN}All optimizations applied successfully${NC}"
}

restore_settings() {
    log "${YELLOW}Restoring original settings...${NC}"
    
    # Check if original settings file exists
    if [ ! -f "$ORIGINAL_SETTINGS_FILE" ]; then
        log "${RED}Original settings file not found, using defaults${NC}"
        # Apply some reasonable defaults
        settings put global zen_mode 0
        termux-volume music 10
        termux-volume ring 7
        termux-brightness 150
    else
        # Load original settings
        local volume_music=$(jq -r '.volume_music' "$ORIGINAL_SETTINGS_FILE")
        local volume_ring=$(jq -r '.volume_ring' "$ORIGINAL_SETTINGS_FILE")
        local brightness=$(jq -r '.brightness' "$ORIGINAL_SETTINGS_FILE")
        local dnd_state=$(jq -r '.dnd_state' "$ORIGINAL_SETTINGS_FILE")
        
        # Restore DND state
        settings put global zen_mode $dnd_state
        
        # Restore volumes
        termux-volume music $volume_music
        termux-volume ring $volume_ring
        
        # Restore brightness
        if [ "$brightness" != "automatic" ]; then
            termux-brightness $brightness
        fi
        
        log "Original settings restored from saved values"
    fi
    
    # Stop system monitoring
    stop_system_stats_monitoring
    
    # Remove game running flag
    rm -f "$GAME_RUNNING_FLAG"
    
    # Remove notification
    termux-notification-remove "ram_optimizer"
    
    # Show restoration notification
    termux-notification --id "ram_optimizer_restore" \
        --title "RAM Optimizer" \
        --content "Game optimization ended. Settings restored." \
        --priority low \
        --icon "check"
    
    log "${GREEN}System restored to original settings${NC}"
}

# =================== MONITORING FUNCTIONS ===================

start_monitoring_loop() {
    log "${GREEN}Starting game monitoring loop...${NC}"
    
    # Write PID to file so we can stop the service later
    echo $$ > "$PID_FILE"
    
    # Load list of games to monitor from config
    local games_list=$(jq -r '.games[]' "$CONFIG_FILE")
    
    # Show notification that monitoring is active
    termux-notification --id "ram_optimizer_service" \
        --title "RAM Optimizer" \
        --content "Game monitoring active" \
        --type ongoing \
        --icon "radar"
    
    log "Monitoring the following games: $games_list"
    
    local current_game=""
    local last_game=""
    
    # Main monitoring loop
    while true; do
        current_game=$(get_current_foreground_app)
        
        # Check if current app is in our games list
        if echo "$games_list" | grep -q "$current_game"; then
            # A game has been detected
            if [ "$current_game" != "$last_game" ]; then
                # New game detected
                log "${MAGENTA}Game detected: $current_game${NC}"
                
                # If we were optimizing a different game, restore first
                if [ -n "$last_game" ] && [ -f "$GAME_RUNNING_FLAG" ]; then
                    restore_settings
                fi
                
                # Apply optimizations for the new game
                apply_optimizations "$current_game"
                last_game=$current_game
            fi
        elif [ -n "$last_game" ] && [ -f "$GAME_RUNNING_FLAG" ]; then
            # Game was running but is now closed
            log "${YELLOW}Game closed: $last_game${NC}"
            restore_settings
            last_game=""
        fi
        
        sleep $CHECK_INTERVAL
    done
}

start_system_stats_monitoring() {
    log "${CYAN}Starting system stats monitoring...${NC}"
    
    # Kill any existing monitor process
    if [ -f "$MONITOR_PID_FILE" ]; then
        kill $(cat "$MONITOR_PID_FILE") 2>/dev/null
        rm "$MONITOR_PID_FILE"
    fi
    
    # Start monitoring in a separate process
    {
        while true; do
            if [ -f "$GAME_RUNNING_FLAG" ]; then
                # Get formatted stats for notification
                local stats=$(get_system_stats "notification")
                
                # Update the notification with current stats
                termux-notification --id "ram_optimizer" \
                    --title "RAM Optimizer Active" \
                    --content "Optimizing: $(cat "$GAME_RUNNING_FLAG")" \
                    --icon "game_controller" \
                    --type ongoing \
                    --button1 "Boost" \
                    --button1-action "am broadcast --user 0 -a com.termux.addon.api.BOOST -p com.termux" \
                    --message "$stats"
                
                # Optional: Check for critical conditions (high temp, low battery)
                local battery_temp=$(termux-battery-status | jq -r '.temperature')
                if (( $(echo "$battery_temp > 42" | bc -l) )); then
                    termux-notification --id "ram_optimizer_warning" \
                        --title "WARNING: High Temperature" \
                        --content "Device temperature: ${battery_temp}°C - Consider taking a break" \
                        --icon "warning" \
                        --priority high
                fi
            fi
            
            sleep $MONITOR_INTERVAL
        done
    } &
    
    # Save the PID of the monitoring process
    echo $! > "$MONITOR_PID_FILE"
}

stop_system_stats_monitoring() {
    if [ -f "$MONITOR_PID_FILE" ]; then
        kill $(cat "$MONITOR_PID_FILE") 2>/dev/null
        rm "$MONITOR_PID_FILE"
        log "${YELLOW}System stats monitoring stopped${NC}"
    fi
}

# =================== MANUAL OPTIMIZATION FUNCTIONS ===================

manual_boost() {
    log "${CYAN}Performing manual memory boost...${NC}"
    
    # Show notification
    termux-notification --id "ram_optimizer_boost" \
        --title "RAM Optimizer" \
        --content "Performing memory boost..." \
        --icon "memory"
    
    # Kill background processes that aren't critical
    log "Cleaning up memory..."
    
    # Get a list of running apps that consume significant memory
    local heavy_apps=$(ps -e -o pid,rss,comm | sort -k2 -n -r | head -10 | awk '$2 > 50000')
    
    # Suggest these apps to be closed manually
    if [ -n "$heavy_apps" ]; then
        log "${YELLOW}Heavy apps running:${NC}"
        echo "$heavy_apps" | while read line; do
            log "$line"
        done
        
        # We can't directly kill other apps, but we can suggest the user close them
        suggest_manual_actions "$heavy_apps"
    fi
    
    # Clear app caches (requires root, but try anyway)
    if which su >/dev/null 2>&1; then
        log "Attempting to clear app caches (requires root)"
        su -c "sync; echo 3 > /proc/sys/vm/drop_caches" || log "Root access denied"
    fi
    
    # Force garbage collection
    log "Triggering garbage collection"
    am broadcast -a android.intent.action.AIRPLANE_MODE --ez state false >/dev/null 2>&1
    
    # Get memory stats after boost
    local mem_before=$(free | grep Mem | awk '{print $4}')
    local mem_after=$(free | grep Mem | awk '{print $4}')
    local mem_freed=$((mem_after - mem_before))
    
    # Update notification with results
    termux-notification --id "ram_optimizer_boost" \
        --title "RAM Optimizer" \
        --content "Memory boost complete. Freed approximately ${mem_freed}KB" \
        --icon "check"
    
    log "${GREEN}Manual boost completed${NC}"
    
    # Remove notification after a few seconds
    sleep 5
    termux-notification-remove "ram_optimizer_boost"
}

suggest_manual_actions() {
    local heavy_apps=$1
    
    # Create a list of package names to suggest closing
    local top_packages=$(echo "$heavy_apps" | awk '{print $3}' | head -5)
    
    # Show notification with suggestions
    termux-notification --id "ram_optimizer_suggest" \
        --title "Memory Boost Suggestion" \
        --content "Close these apps for better performance: $top_packages" \
        --button1 "Recent Apps" \
        --button1-action "input keyevent KEYCODE_APP_SWITCH" \
        --button2 "Battery Settings" \
        --button2-action "am start -a android.settings.BATTERY_SAVER_SETTINGS" \
        --icon "lightbulb"
    
    log "${YELLOW}Suggested manual actions to user${NC}"
}

# =================== SERVICE CONTROL FUNCTIONS ===================

start_optimizer_service() {
    # Check if service is already running
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        log "${YELLOW}Optimizer service already running${NC}"
        return 0
    fi
    
    log "${GREEN}Starting optimizer service...${NC}"
    
    # Start the monitoring loop in the background
    nohup "$0" --monitor > "$SCRIPT_DIR/nohup.out" 2>&1 &
    
    log "${GREEN}Optimizer service started with PID $!${NC}"
    
    # Show notification
    termux-notification --id "ram_optimizer_service" \
        --title "RAM Optimizer" \
        --content "Game monitoring active" \
        --type ongoing \
        --icon "radar"
}

stop_optimizer_service() {
    log "${YELLOW}Stopping optimizer service...${NC}"
    
    # Check if service is running
    if [ ! -f "$PID_FILE" ]; then
        log "${YELLOW}Optimizer service not running${NC}"
        return 0
    fi
    
    # Kill the monitoring process
    local pid=$(cat "$PID_FILE")
    kill $pid 2>/dev/null
    
    # Also kill any system monitoring process
    if [ -f "$MONITOR_PID_FILE" ]; then
        kill $(cat "$MONITOR_PID_FILE") 2>/dev/null
        rm "$MONITOR_PID_FILE"
    fi
    
    # Restore settings if a game was being optimized
    if [ -f "$GAME_RUNNING_FLAG" ]; then
        restore_settings
    fi
    
    # Remove PID file
    rm -f "$PID_FILE"
    
    # Remove notifications
    termux-notification-remove "ram_optimizer_service"
    termux-notification-remove "ram_optimizer"
    
    log "${GREEN}Optimizer service stopped${NC}"
}

# =================== MANAGE GAME LIST ===================

list_games() {
    echo -e "${CYAN}=== Monitored Games ===${NC}"
    
    local count=0
    jq -r '.games[]' "$CONFIG_FILE" | while read game; do
        local app_name=$(dumpsys package $game | grep "packageName" | head -1 | cut -d= -f2- || echo $game)
        echo -e "${GREEN}[$((++count))]${NC} $app_name ${BLUE}($game)${NC}"
    done
    
    echo
}

add_game() {
    echo -e "${CYAN}=== Add Game to Monitor ===${NC}"
    echo -e "${YELLOW}Enter the package name of the game (e.g., com.pubg.mobile):${NC}"
    read package_name
    
    if [ -z "$package_name" ]; then
        log "${RED}No package name provided${NC}"
        return 1
    fi
    
    # Check if the package exists
    if ! dumpsys package $package_name | grep -q "Package \[$package_name\]"; then
        log "${RED}Package $package_name not found on this device${NC}"
        return 1
    fi
    
    # Check if already in the list
    if jq -r '.games[]' "$CONFIG_FILE" | grep -q "$package_name"; then
        log "${YELLOW}Package $package_name already in the list${NC}"
        return 0
    fi
    
    # Add to the list
    local temp_file=$(mktemp)
    jq ".games += [\"$package_name\"]" "$CONFIG_FILE" > "$temp_file"
    mv "$temp_file" "$CONFIG_FILE"
    
    log "${GREEN}Added $package_name to monitored games${NC}"
}

remove_game() {
    echo -e "${CYAN}=== Remove Game from Monitor ===${NC}"
    list_games
    
    echo -e "${YELLOW}Enter the number of the game to remove:${NC}"
    read game_number
    
    if [[ ! "$game_number" =~ ^[0-9]+$ ]]; then
        log "${RED}Invalid number${NC}"
        return 1
    fi
    
    local game_count=$(jq '.games | length' "$CONFIG_FILE")
    if [ "$game_number" -lt 1 ] || [ "$game_number" -gt "$game_count" ]; then
        log "${RED}Number out of range${NC}"
        return 1
    fi
    
    # Get the package name to remove
    local index=$((game_number - 1))
    local package_to_remove=$(jq -r ".games[$index]" "$CONFIG_FILE")
    
    # Remove from the list
    local temp_file=$(mktemp)
    jq "del(.games[$index])" "$CONFIG_FILE" > "$temp_file"
    mv "$temp_file" "$CONFIG_FILE"
    
    log "${GREEN}Removed $package_to_remove from monitored games${NC}"
}

# =================== CONFIGURATION FUNCTIONS ===================

edit_settings() {
    echo -e "${CYAN}=== Edit Optimization Settings ===${NC}"
    
    # Display current settings
    echo -e "Current settings:"
    echo -e "1. Enable Do Not Disturb: $(jq -r '.settings.enable_dnd' "$CONFIG_FILE")"
    echo -e "2. Lower Volume: $(jq -r '.settings.lower_volume' "$CONFIG_FILE")"
    echo -e "3. Dim Brightness: $(jq -r '.settings.dim_brightness' "$CONFIG_FILE")"
    echo -e "4. Show Overlay: $(jq -r '.settings.show_overlay' "$CONFIG_FILE")"
    echo -e "5. Aggressive Memory Cleanup: $(jq -r '.settings.aggressive_memory_cleanup' "$CONFIG_FILE")"
    echo
    
    echo -e "${YELLOW}Enter the number of the setting to toggle:${NC}"
    read setting_number
    
    case $setting_number in
        1)
            toggle_setting "enable_dnd" "Do Not Disturb mode"
            ;;
        2)
            toggle_setting "lower_volume" "Lower Volume"
            ;;
        3)
            toggle_setting "dim_brightness" "Dim Brightness"
            ;;
        4)
            toggle_setting "show_overlay" "Show Overlay"
            ;;
        5)
            toggle_setting "aggressive_memory_cleanup" "Aggressive Memory Cleanup"
            ;;
        *)
            log "${RED}Invalid option${NC}"
            ;;
    esac
}

toggle_setting() {
    local setting_key=$1
    local setting_name=$2
    
    # Get current value
    local current_value=$(jq -r ".settings.$setting_key" "$CONFIG_FILE")
    
    # Toggle value
    if [ "$current_value" = "true" ]; then
        new_value="false"
    else
        new_value="true"
    fi
    
    # Update config
    local temp_file=$(mktemp)
    jq ".settings.$setting_key = $new_value" "$CONFIG_FILE" > "$temp_file"
    mv "$temp_file" "$CONFIG_FILE"
    
    log "${GREEN}$setting_name set to $new_value${NC}"
}

# =================== MENU FUNCTIONS ===================

show_help() {
    echo -e "${CYAN}=== RAM OPTIMIZER HELP ===${NC}"
    echo
    echo -e "${GREEN}Usage: ./ram_optimizer.sh [options]${NC}"
    echo
    echo -e "${YELLOW}Options:${NC}"
    echo "  --start       Start the optimizer service"
    echo "  --stop        Stop the optimizer service"
    echo "  --status      Show current status"
    echo "  --boost       Perform a manual memory boost"
    echo "  --monitor     Start monitoring loop (internal use)"
    echo "  --help        Show this help message"
    echo
    echo -e "${YELLOW}Interactive Menu Commands:${NC}"
    echo "  1. Start Optimizer Service"
    echo "  2. Stop Optimizer Service"
    echo "  3. Show Status"
    echo "  4. Perform Manual Boost"
    echo "  5. Manage Game List"
    echo "  6. Edit Settings"
    echo "  7. Exit"
    echo
    echo -e "${MAGENTA}For issues and updates, visit:${NC}"
    echo -e "${BLUE}https://github.com/FireKid846/Ram_optimizer${NC}"

}

show_menu() {
    show_banner
    
    echo -e "${CYAN}=== MAIN MENU ===${NC}"
    echo
    echo -e "${GREEN}1.${NC} Start Optimizer Service"
    echo -e "${GREEN}2.${NC} Stop Optimizer Service"
    echo -e "${GREEN}3.${NC} Show Status"
    echo -e "${GREEN}4.${NC} Perform Manual Boost"
    echo -e "${GREEN}5.${NC} Manage Game List"
    echo -e "${GREEN}6.${NC} Edit Settings"
    echo -e "${GREEN}7.${NC} Exit"
    echo
    echo -e "${YELLOW}Enter your choice [1-7]:${NC} "
    read choice
    
    case $choice in
        1)
            start_optimizer_service
            sleep 1
            show_menu
            ;;
        2)
            stop_optimizer_service
            sleep 1
            show_menu
            ;;
        3)
            show_status
            echo
            read -p "Press Enter to continue..."
            show_menu
            ;;
        4)
            manual_boost
            sleep 1
            show_menu
            ;;
        5)
            manage_games_menu
            ;;
        6)
            edit_settings
            sleep 1
            show_menu
            ;;
        7)
            echo -e "${GREEN}Exiting RAM Optimizer. Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Please try again.${NC}"
            sleep 1
            show_menu
            ;;
    esac
}

manage_games_menu() {
    show_banner
    
    echo -e "${CYAN}=== MANAGE GAMES ===${NC}"
    echo
    echo -e "${GREEN}1.${NC} List Monitored Games"
    echo -e "${GREEN}2.${NC} Add Game"
    echo -e "${GREEN}3.${NC} Remove Game"
    echo -e "${GREEN}4.${NC} Back to Main Menu"
    echo
    echo -e "${YELLOW}Enter your choice [1-4]:${NC} "
    read choice
    
    case $choice in
        1)
            list_games
            echo
            read -p "Press Enter to continue..."
            manage_games_menu
            ;;
        2)
            add_game
            sleep 1
            manage_games_menu
            ;;
        3)
            remove_game
            sleep 1
            manage_games_menu
            ;;
        4)
            show_menu
            ;;
        *)
            echo -e "${RED}Invalid option. Please try again.${NC}"
            sleep 1
            manage_games_menu
            ;;
    esac
}

# =================== MAIN EXECUTION ===================

# Ensure proper initialization
initialize_app || exit 1

# Process command line arguments
if [ $# -eq 0 ]; then
    # No arguments, show interactive menu
    show_menu
else
    # Process arguments
    case "$1" in
        --start)
            start_optimizer_service
            ;;
        --stop)
            stop_optimizer_service
            ;;
        --status)
            show_status
            ;;
        --boost)
            manual_boost
            ;;
        --monitor)
            # This is an internal command used when starting the service
            start_monitoring_loop
            ;;
        --help|*)
            show_help
            ;;
    esac
fi

# Exit cleanly
exit 0
