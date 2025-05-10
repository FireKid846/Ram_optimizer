#!/data/data/com.termux/files/usr/bin/bash

# =================================================================
# SIMPLIFIED RAM OPTIMIZER - For Android
# Based on original by FireKid846
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

# Default settings
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
    echo -e "${BLUE}│${RED}        SIMPLIFIED RAM OPTIMIZER v${VERSION}        ${BLUE}│${NC}"
    echo -e "${BLUE}│${YELLOW}      Battery & Display Management Tool        ${BLUE}│${NC}"
    echo -e "${BLUE}└───────────────────────────────────────────────────┘${NC}"
    echo
}

show_status() {
    echo -e "${CYAN}=== Current Status ===${NC}"
    
    # Check if monitoring is active
    if [ -f "$MONITOR_PID_FILE" ] && kill -0 $(cat "$MONITOR_PID_FILE") 2>/dev/null; then
        echo -e "${GREEN}[✓] System monitoring: ACTIVE${NC}"
    else
        echo -e "${YELLOW}[!] System monitoring: INACTIVE${NC}"
    fi
    
    echo
    
    # Display current system stats
    echo -e "${CYAN}=== System Stats ===${NC}"
    get_system_stats "display"
    echo
}

# =================== INITIALIZATION FUNCTIONS ===================

initialize_app() {
    show_banner
    log "${GREEN}Initializing Simplified RAM Optimizer...${NC}"
    
    # Create default config if it doesn't exist
    if [ ! -f "$CONFIG_FILE" ]; then
        echo '{
            "settings": {
                "dim_brightness": true,
                "show_battery_stats": true
            }
        }' > "$CONFIG_FILE"
        log "${GREEN}Created default configuration file${NC}"
    fi
    
    # Remove stale PID files if the processes are not running
    if [ -f "$MONITOR_PID_FILE" ]; then
        if ! kill -0 $(cat "$MONITOR_PID_FILE") 2>/dev/null; then
            rm "$MONITOR_PID_FILE"
        fi
    fi
    
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
    
    # Get current brightness
    local brightness=$(termux-brightness get 2>/dev/null || echo "automatic")
    
    # Save brightness setting to file
    echo "{
        \"brightness\": \"$brightness\"
    }" > "$ORIGINAL_SETTINGS_FILE"
    
    log "${GREEN}Original display settings saved${NC}"
}

apply_display_settings() {
    log "${GREEN}Applying display optimization...${NC}"
    
    # Save original settings before modifying
    save_original_settings
    
    # Load optimization settings from config
    local dim_brightness=$(jq -r '.settings.dim_brightness' "$CONFIG_FILE")
    
    # Dim brightness
    if [ "$dim_brightness" = "true" ]; then
        termux-brightness 100
        log "Adjusted screen brightness"
    fi
    
    # Show notification
    termux-notification --id "ram_optimizer" \
        --title "RAM Optimizer Active" \
        --content "Display optimization active" \
        --icon "memory" \
        --type ongoing
    
    # Start system monitoring
    start_system_stats_monitoring
    
    log "${GREEN}Display settings applied successfully${NC}"
}

restore_settings() {
    log "${YELLOW}Restoring original settings...${NC}"
    
    # Check if original settings file exists
    if [ ! -f "$ORIGINAL_SETTINGS_FILE" ]; then
        log "${RED}Original settings file not found, using defaults${NC}"
        # Apply some reasonable defaults
        termux-brightness 150
    else
        # Load original settings
        local brightness=$(jq -r '.brightness' "$ORIGINAL_SETTINGS_FILE")
        
        # Restore brightness
        if [ "$brightness" != "automatic" ]; then
            termux-brightness $brightness
        fi
        
        log "Original settings restored from saved values"
    fi
    
    # Stop system monitoring
    stop_system_stats_monitoring
    
    # Remove notification
    termux-notification-remove "ram_optimizer"
    
    # Show restoration notification
    termux-notification --id "ram_optimizer_restore" \
        --title "RAM Optimizer" \
        --content "Optimization ended. Settings restored." \
        --priority low \
        --icon "check"
    
    log "${GREEN}System restored to original settings${NC}"
}

# =================== MONITORING FUNCTIONS ===================

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
            # Get formatted stats for notification
            local stats=$(get_system_stats "notification")
            
            # Update the notification with current stats
            termux-notification --id "ram_optimizer" \
                --title "RAM Optimizer Active" \
                --content "Display optimization active" \
                --icon "memory" \
                --type ongoing \
                --button1 "End" \
                --button1-action "am broadcast --user 0 -a com.termux.addon.api.STOP -p com.termux" \
                --message "$stats"
            
            # Check for critical battery temperature
            local battery_temp=$(termux-battery-status | jq -r '.temperature')
            if (( $(echo "$battery_temp > 42" | bc -l) )); then
                termux-notification --id "ram_optimizer_warning" \
                    --title "WARNING: High Temperature" \
                    --content "Device temperature: ${battery_temp}°C - Consider taking a break" \
                    --icon "warning" \
                    --priority high
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

# =================== MANUAL FUNCTIONS ===================

manual_boost() {
    log "${CYAN}Performing manual memory boost...${NC}"
    
    # Show notification
    termux-notification --id "ram_optimizer_boost" \
        --title "RAM Optimizer" \
        --content "Performing memory boost..." \
        --icon "memory"
    
    # Get memory stats before boost
    local mem_before=$(free | grep Mem | awk '{print $4}')
    
    # Force garbage collection (lightweight method)
    log "Triggering memory cleanup"
    am broadcast -a android.intent.action.AIRPLANE_MODE --ez state false >/dev/null 2>&1
    sleep 1
    
    # Get memory stats after boost
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

# =================== SERVICE CONTROL FUNCTIONS ===================

start_optimizer() {
    log "${GREEN}Starting display optimization...${NC}"
    
    # Apply display settings
    apply_display_settings
    
    log "${GREEN}Display optimization started${NC}"
}

stop_optimizer() {
    log "${YELLOW}Stopping optimization...${NC}"
    
    # Restore settings
    restore_settings
    
    log "${GREEN}Optimization stopped${NC}"
}

# =================== CONFIGURATION FUNCTIONS ===================

edit_settings() {
    echo -e "${CYAN}=== Edit Settings ===${NC}"
    
    # Display current settings
    echo -e "Current settings:"
    echo -e "1. Dim Brightness: $(jq -r '.settings.dim_brightness' "$CONFIG_FILE")"
    echo -e "2. Show Battery Stats: $(jq -r '.settings.show_battery_stats' "$CONFIG_FILE")"
    echo
    
    echo -e "${YELLOW}Enter the number of the setting to toggle:${NC}"
    read setting_number
    
    case $setting_number in
        1)
            toggle_setting "dim_brightness" "Dim Brightness"
            ;;
        2)
            toggle_setting "show_battery_stats" "Show Battery Stats"
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
    echo -e "${CYAN}=== SIMPLIFIED RAM OPTIMIZER HELP ===${NC}"
    echo
    echo -e "${GREEN}Usage: ./simplified_ram_optimizer.sh [options]${NC}"
    echo
    echo -e "${YELLOW}Options:${NC}"
    echo "  --start       Start display optimization"
    echo "  --stop        Stop display optimization"
    echo "  --status      Show current status"
    echo "  --boost       Perform a manual memory boost"
    echo "  --help        Show this help message"
    echo
    echo -e "${YELLOW}Interactive Menu Commands:${NC}"
    echo "  1. Start Display Optimization"
    echo "  2. Stop Display Optimization"
    echo "  3. Show Status"
    echo "  4. Perform Manual Boost"
    echo "  5. Edit Settings"
    echo "  6. Exit"
    echo
    echo -e "${MAGENTA}Features:${NC}"
    echo "  * Display brightness management"
    echo "  * System statistics monitoring"
    echo "  * Battery temperature monitoring"
    echo "  * Basic memory optimization"
    echo
}

show_menu() {
    while true; do
        show_banner
        echo -e "${CYAN}=== MAIN MENU ===${NC}"
        echo -e "${GREEN}1.${NC} Start Display Optimization"
        echo -e "${GREEN}2.${NC} Stop Display Optimization"
        echo -e "${GREEN}3.${NC} Show Status"
        echo -e "${GREEN}4.${NC} Perform Manual Boost"
        echo -e "${GREEN}5.${NC} Edit Settings"
        echo -e "${GREEN}6.${NC} Exit"
        echo
        echo -e "${YELLOW}Enter your choice:${NC}"
        read choice
        
        case $choice in
            1)
                start_optimizer
                echo -e "${YELLOW}Press Enter to continue...${NC}"
                read
                ;;
            2)
                stop_optimizer
                echo -e "${YELLOW}Press Enter to continue...${NC}"
                read
                ;;
            3)
                show_status
                echo -e "${YELLOW}Press Enter to continue...${NC}"
                read
                ;;
            4)
                manual_boost
                echo -e "${YELLOW}Press Enter to continue...${NC}"
                read
                ;;
            5)
                edit_settings
                echo -e "${YELLOW}Press Enter to continue...${NC}"
                read
                ;;
            6)
                echo -e "${GREEN}Thank you for using Simplified RAM Optimizer!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option. Press Enter to continue...${NC}"
                read
                ;;
        esac
    done
}

# =================== MAIN SCRIPT ===================

# Process command line arguments
case "$1" in
    --start)
        initialize_app && start_optimizer
        ;;
    --stop)
        stop_optimizer
        ;;
    --status)
        initialize_app && show_status
        ;;
    --boost)
        manual_boost
        ;;
    --help)
        show_help
        ;;
    *)
        # No arguments, launch interactive menu
        initialize_app && show_menu
        ;;
esac

exit 0
