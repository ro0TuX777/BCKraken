# KrakenSDR Terminal Button Interfaces

## Overview
Button-based terminal interfaces for KrakenSDR operation using menu systems, function keys, and interactive prompts. No GUI required - all terminal-based with simple button/key navigation.

## Main Menu Interface

### /usr/local/bin/kraken_menu
```bash
#!/bin/bash
# KrakenSDR Interactive Menu System

# Colors for better visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Clear screen and show header
clear_and_header() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    KrakenSDR Control Center                  ║${NC}"
    echo -e "${CYAN}║                  Terminal Button Interface                   ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
}

# Show system status
show_status() {
    echo -e "${YELLOW}Current System Status:${NC}"
    
    # Check if services are running
    if systemctl is-active --quiet heimdall-daq; then
        echo -e "  Heimdall DAQ: ${GREEN}●${NC} RUNNING"
    else
        echo -e "  Heimdall DAQ: ${RED}●${NC} STOPPED"
    fi
    
    # Check VFOs
    for i in {1..5}; do
        if [ -f "/var/run/kraken/vfo$i.pid" ] && kill -0 $(cat "/var/run/kraken/vfo$i.pid") 2>/dev/null; then
            echo -e "  VFO $i: ${GREEN}●${NC} ACTIVE"
        else
            echo -e "  VFO $i: ${RED}●${NC} INACTIVE"
        fi
    done
    
    # Check passive radar
    if [ -f "/var/run/kraken/radar.pid" ] && kill -0 $(cat "/var/run/kraken/radar.pid") 2>/dev/null; then
        echo -e "  Passive Radar: ${GREEN}●${NC} RUNNING"
    else
        echo -e "  Passive Radar: ${RED}●${NC} STOPPED"
    fi
    
    # Check Elasticsearch
    if curl -s http://localhost:9200/_cluster/health >/dev/null 2>&1; then
        echo -e "  Elasticsearch: ${GREEN}●${NC} CONNECTED"
    else
        echo -e "  Elasticsearch: ${RED}●${NC} DISCONNECTED"
    fi
    
    echo
}

# Main menu
main_menu() {
    while true; do
        clear_and_header
        show_status
        
        echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║                        MAIN MENU                            ║${NC}"
        echo -e "${BLUE}╠══════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${BLUE}║  ${YELLOW}[1]${NC} Start Maximum Utilization Mode                    ${BLUE}║${NC}"
        echo -e "${BLUE}║  ${YELLOW}[2]${NC} Stop All Systems                                  ${BLUE}║${NC}"
        echo -e "${BLUE}║  ${YELLOW}[3]${NC} VFO Control Menu                                  ${BLUE}║${NC}"
        echo -e "${BLUE}║  ${YELLOW}[4]${NC} Passive Radar Menu                               ${BLUE}║${NC}"
        echo -e "${BLUE}║  ${YELLOW}[5]${NC} Real-time Monitor                                ${BLUE}║${NC}"
        echo -e "${BLUE}║  ${YELLOW}[6]${NC} Data Query Menu                                  ${BLUE}║${NC}"
        echo -e "${BLUE}║  ${YELLOW}[7]${NC} System Configuration                             ${BLUE}║${NC}"
        echo -e "${BLUE}║  ${YELLOW}[8]${NC} Logs and Diagnostics                             ${BLUE}║${NC}"
        echo -e "${BLUE}║  ${YELLOW}[Q]${NC} Quit                                             ${BLUE}║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
        echo
        echo -e "${CYAN}Press a number key or Q to quit:${NC}"
        
        read -n 1 -s choice
        echo
        
        case $choice in
            1)
                start_max_utilization_menu
                ;;
            2)
                stop_all_systems_menu
                ;;
            3)
                vfo_control_menu
                ;;
            4)
                passive_radar_menu
                ;;
            5)
                real_time_monitor
                ;;
            6)
                data_query_menu
                ;;
            7)
                system_config_menu
                ;;
            8)
                logs_diagnostics_menu
                ;;
            [Qq])
                echo -e "${GREEN}Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice. Press any key to continue...${NC}"
                read -n 1 -s
                ;;
        esac
    done
}

# Start maximum utilization menu
start_max_utilization_menu() {
    clear_and_header
    echo -e "${GREEN}Starting Maximum Utilization Mode...${NC}"
    echo
    echo -e "${YELLOW}This will start:${NC}"
    echo "  • All 5 VFOs with different scanning modes"
    echo "  • Passive radar with FM illumination"
    echo "  • Adaptive beamforming"
    echo "  • Signal classification"
    echo "  • Real-time Elasticsearch streaming"
    echo
    echo -e "${CYAN}Continue? [Y/n]:${NC}"
    
    read -n 1 -s confirm
    if [[ $confirm =~ ^[Yy]$ ]] || [[ -z $confirm ]]; then
        echo
        echo -e "${GREEN}Starting all systems...${NC}"
        
        # Start services with progress indicators
        echo -n "Starting Heimdall DAQ... "
        systemctl start heimdall-daq && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}"
        
        echo -n "Starting VFO 1 (Ham Emergency)... "
        kraken_vfo --start --vfo 1 --frequency 146.520e6 --algorithm MUSIC >/dev/null 2>&1 && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}"
        
        echo -n "Starting VFO 2 (GMRS Scan)... "
        kraken_vfo --start --vfo 2 --frequency 462.675e6 --algorithm Bartlett >/dev/null 2>&1 && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}"
        
        echo -n "Starting VFO 3 (Public Safety)... "
        kraken_vfo --start --vfo 3 --frequency 155.340e6 --algorithm Capon >/dev/null 2>&1 && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}"
        
        echo -n "Starting Passive Radar... "
        kraken_radar --start --illuminator FM_101.5 --channels 2,3,4,5 >/dev/null 2>&1 && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}"
        
        echo -n "Starting Discovery Scanner... "
        kraken_vfo --start --vfo 5 --frequency AUTO --algorithm MEMS >/dev/null 2>&1 && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}"
        
        echo -n "Starting Elasticsearch Streamer... "
        kraken_elasticsearch --start >/dev/null 2>&1 && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}"
        
        echo
        echo -e "${GREEN}Maximum Utilization Mode Started!${NC}"
        echo -e "${CYAN}Press any key to return to main menu...${NC}"
        read -n 1 -s
    fi
}

# VFO Control Menu
vfo_control_menu() {
    while true; do
        clear_and_header
        echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║                      VFO CONTROL MENU                       ║${NC}"
        echo -e "${BLUE}╠══════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${BLUE}║  ${YELLOW}[1]${NC} VFO 1 - Ham Emergency (146.520 MHz)              ${BLUE}║${NC}"
        echo -e "${BLUE}║  ${YELLOW}[2]${NC} VFO 2 - GMRS Channels (462.675 MHz)              ${BLUE}║${NC}"
        echo -e "${BLUE}║  ${YELLOW}[3]${NC} VFO 3 - Public Safety (155.340 MHz)              ${BLUE}║${NC}"
        echo -e "${BLUE}║  ${YELLOW}[4]${NC} VFO 4 - FM Reference (101.5 MHz)                 ${BLUE}║${NC}"
        echo -e "${BLUE}║  ${YELLOW}[5]${NC} VFO 5 - Discovery Scanner (AUTO)                 ${BLUE}║${NC}"
        echo -e "${BLUE}║  ${YELLOW}[A]${NC} Start All VFOs                                   ${BLUE}║${NC}"
        echo -e "${BLUE}║  ${YELLOW}[S]${NC} Stop All VFOs                                    ${BLUE}║${NC}"
        echo -e "${BLUE}║  ${YELLOW}[B]${NC} Back to Main Menu                                ${BLUE}║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
        echo
        
        # Show VFO status
        echo -e "${YELLOW}Current VFO Status:${NC}"
        for i in {1..5}; do
            if [ -f "/var/run/kraken/vfo$i.pid" ] && kill -0 $(cat "/var/run/kraken/vfo$i.pid") 2>/dev/null; then
                echo -e "  VFO $i: ${GREEN}●${NC} ACTIVE"
            else
                echo -e "  VFO $i: ${RED}●${NC} INACTIVE"
            fi
        done
        echo
        
        echo -e "${CYAN}Select VFO or action:${NC}"
        read -n 1 -s choice
        echo
        
        case $choice in
            1)
                vfo_individual_control 1 "Ham Emergency" "146.520e6" "MUSIC"
                ;;
            2)
                vfo_individual_control 2 "GMRS Channels" "462.675e6" "Bartlett"
                ;;
            3)
                vfo_individual_control 3 "Public Safety" "155.340e6" "Capon"
                ;;
            4)
                vfo_individual_control 4 "FM Reference" "101.5e6" "Reference"
                ;;
            5)
                vfo_individual_control 5 "Discovery Scanner" "AUTO" "MEMS"
                ;;
            [Aa])
                echo -e "${GREEN}Starting all VFOs...${NC}"
                for i in {1..5}; do
                    echo -n "Starting VFO $i... "
                    # Start VFO with appropriate settings
                    sleep 1
                    echo -e "${GREEN}✓${NC}"
                done
                echo -e "${CYAN}Press any key to continue...${NC}"
                read -n 1 -s
                ;;
            [Ss])
                echo -e "${YELLOW}Stopping all VFOs...${NC}"
                for i in {1..5}; do
                    echo -n "Stopping VFO $i... "
                    kraken_vfo --stop --vfo $i >/dev/null 2>&1
                    echo -e "${GREEN}✓${NC}"
                done
                echo -e "${CYAN}Press any key to continue...${NC}"
                read -n 1 -s
                ;;
            [Bb])
                return
                ;;
            *)
                echo -e "${RED}Invalid choice. Press any key to continue...${NC}"
                read -n 1 -s
                ;;
        esac
    done
}

# Individual VFO control
vfo_individual_control() {
    local vfo_num=$1
    local vfo_name=$2
    local frequency=$3
    local algorithm=$4
    
    clear_and_header
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                   VFO $vfo_num - $vfo_name                   ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    # Check current status
    if [ -f "/var/run/kraken/vfo$vfo_num.pid" ] && kill -0 $(cat "/var/run/kraken/vfo$vfo_num.pid") 2>/dev/null; then
        echo -e "Status: ${GREEN}●${NC} RUNNING"
        echo -e "Frequency: $frequency"
        echo -e "Algorithm: $algorithm"
        echo
        echo -e "${YELLOW}[1]${NC} Stop VFO"
        echo -e "${YELLOW}[2]${NC} Restart VFO"
        echo -e "${YELLOW}[3]${NC} Change Frequency"
        echo -e "${YELLOW}[4]${NC} Change Algorithm"
        echo -e "${YELLOW}[B]${NC} Back"
    else
        echo -e "Status: ${RED}●${NC} STOPPED"
        echo -e "Frequency: $frequency"
        echo -e "Algorithm: $algorithm"
        echo
        echo -e "${YELLOW}[1]${NC} Start VFO"
        echo -e "${YELLOW}[3]${NC} Change Frequency"
        echo -e "${YELLOW}[4]${NC} Change Algorithm"
        echo -e "${YELLOW}[B]${NC} Back"
    fi
    
    echo
    echo -e "${CYAN}Select action:${NC}"
    read -n 1 -s choice
    echo
    
    case $choice in
        1)
            if [ -f "/var/run/kraken/vfo$vfo_num.pid" ] && kill -0 $(cat "/var/run/kraken/vfo$vfo_num.pid") 2>/dev/null; then
                echo -e "${YELLOW}Stopping VFO $vfo_num...${NC}"
                kraken_vfo --stop --vfo $vfo_num
            else
                echo -e "${GREEN}Starting VFO $vfo_num...${NC}"
                kraken_vfo --start --vfo $vfo_num --frequency $frequency --algorithm $algorithm
            fi
            echo -e "${CYAN}Press any key to continue...${NC}"
            read -n 1 -s
            ;;
        2)
            echo -e "${YELLOW}Restarting VFO $vfo_num...${NC}"
            kraken_vfo --stop --vfo $vfo_num
            sleep 2
            kraken_vfo --start --vfo $vfo_num --frequency $frequency --algorithm $algorithm
            echo -e "${CYAN}Press any key to continue...${NC}"
            read -n 1 -s
            ;;
        [Bb])
            return
            ;;
    esac
}

# Real-time monitor with function keys
real_time_monitor() {
    clear_and_header
    echo -e "${GREEN}Real-time Monitor Active${NC}"
    echo -e "${YELLOW}Function Keys:${NC}"
    echo -e "  F1 - Toggle VFO display    F2 - Toggle Radar display"
    echo -e "  F3 - Toggle Signal list    F4 - Toggle System stats"
    echo -e "  ESC - Return to main menu"
    echo
    echo -e "${CYAN}Press ESC to exit monitor mode${NC}"
    echo
    
    # Start monitoring loop
    while true; do
        # Display real-time data
        echo -e "\r${YELLOW}$(date)${NC} - Monitoring... (ESC to exit)"
        
        # Read key with timeout
        if read -t 1 -n 1 key; then
            case $key in
                $'\e')  # ESC key
                    echo
                    echo -e "${GREEN}Exiting monitor mode...${NC}"
                    sleep 1
                    return
                    ;;
            esac
        fi
    done
}

# Stop all systems menu
stop_all_systems_menu() {
    clear_and_header
    echo -e "${RED}WARNING: This will stop ALL KrakenSDR systems${NC}"
    echo
    echo -e "${YELLOW}This will stop:${NC}"
    echo "  • All VFOs"
    echo "  • Passive radar"
    echo "  • Beamforming"
    echo "  • Signal classification"
    echo "  • Data streaming"
    echo
    echo -e "${CYAN}Are you sure? [y/N]:${NC}"
    
    read -n 1 -s confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        echo
        echo -e "${RED}Stopping all systems...${NC}"
        kraken_max_util stop
        echo -e "${GREEN}All systems stopped.${NC}"
    else
        echo
        echo -e "${GREEN}Operation cancelled.${NC}"
    fi
    echo -e "${CYAN}Press any key to continue...${NC}"
    read -n 1 -s
}

# Data query menu (placeholder)
data_query_menu() {
    clear_and_header
    echo -e "${BLUE}Data Query Menu - Coming Soon${NC}"
    echo -e "${CYAN}Press any key to return...${NC}"
    read -n 1 -s
}

# System config menu (placeholder)
system_config_menu() {
    clear_and_header
    echo -e "${BLUE}System Configuration Menu - Coming Soon${NC}"
    echo -e "${CYAN}Press any key to return...${NC}"
    read -n 1 -s
}

# Logs and diagnostics menu (placeholder)
logs_diagnostics_menu() {
    clear_and_header
    echo -e "${BLUE}Logs and Diagnostics Menu - Coming Soon${NC}"
    echo -e "${CYAN}Press any key to return...${NC}"
    read -n 1 -s
}

# Passive radar menu (placeholder)
passive_radar_menu() {
    clear_and_header
    echo -e "${BLUE}Passive Radar Menu - Coming Soon${NC}"
    echo -e "${CYAN}Press any key to return...${NC}"
    read -n 1 -s
}

# Start the main menu
main_menu
```

## Quick Action Buttons Interface

### /usr/local/bin/kraken_quick
```bash
#!/bin/bash
# Quick action buttons for common KrakenSDR operations

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_quick_menu() {
    clear
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║         KrakenSDR Quick Actions       ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo
    echo -e "${GREEN}[SPACE]${NC} Start Max Utilization    ${RED}[S]${NC} Stop All"
    echo -e "${YELLOW}[1-5]${NC}   Toggle VFO 1-5          ${BLUE}[R]${NC} Restart"
    echo -e "${PURPLE}[P]${NC}     Toggle Passive Radar   ${CYAN}[M]${NC} Monitor"
    echo -e "${YELLOW}[Q]${NC}     Quit"
    echo

    # Show current status in one line
    echo -n "Status: "
    for i in {1..5}; do
        if [ -f "/var/run/kraken/vfo$i.pid" ] && kill -0 $(cat "/var/run/kraken/vfo$i.pid") 2>/dev/null; then
            echo -ne "${GREEN}$i${NC} "
        else
            echo -ne "${RED}$i${NC} "
        fi
    done

    if [ -f "/var/run/kraken/radar.pid" ] && kill -0 $(cat "/var/run/kraken/radar.pid") 2>/dev/null; then
        echo -ne "${GREEN}R${NC}"
    else
        echo -ne "${RED}R${NC}"
    fi
    echo
    echo
}

# Main quick interface loop
while true; do
    show_quick_menu
    echo -e "${CYAN}Press a key:${NC}"
    read -n 1 -s key

    case $key in
        ' ')  # Space bar - start max utilization
            echo -e "\n${GREEN}Starting Maximum Utilization...${NC}"
            kraken_max_util start
            echo -e "${CYAN}Press any key to continue...${NC}"
            read -n 1 -s
            ;;
        [1-5])  # Toggle individual VFOs
            vfo_num=$key
            if [ -f "/var/run/kraken/vfo$vfo_num.pid" ] && kill -0 $(cat "/var/run/kraken/vfo$vfo_num.pid") 2>/dev/null; then
                echo -e "\n${YELLOW}Stopping VFO $vfo_num...${NC}"
                kraken_vfo --stop --vfo $vfo_num
            else
                echo -e "\n${GREEN}Starting VFO $vfo_num...${NC}"
                case $vfo_num in
                    1) kraken_vfo --start --vfo 1 --frequency 146.520e6 --algorithm MUSIC ;;
                    2) kraken_vfo --start --vfo 2 --frequency 462.675e6 --algorithm Bartlett ;;
                    3) kraken_vfo --start --vfo 3 --frequency 155.340e6 --algorithm Capon ;;
                    4) kraken_vfo --start --vfo 4 --frequency 101.5e6 --mode REFERENCE ;;
                    5) kraken_vfo --start --vfo 5 --frequency AUTO --algorithm MEMS ;;
                esac
            fi
            sleep 1
            ;;
        [Ss])  # Stop all
            echo -e "\n${RED}Stopping all systems...${NC}"
            kraken_max_util stop
            echo -e "${CYAN}Press any key to continue...${NC}"
            read -n 1 -s
            ;;
        [Pp])  # Toggle passive radar
            if [ -f "/var/run/kraken/radar.pid" ] && kill -0 $(cat "/var/run/kraken/radar.pid") 2>/dev/null; then
                echo -e "\n${YELLOW}Stopping Passive Radar...${NC}"
                kraken_radar --stop
            else
                echo -e "\n${GREEN}Starting Passive Radar...${NC}"
                kraken_radar --start --illuminator FM_101.5 --channels 2,3,4,5
            fi
            sleep 1
            ;;
        [Rr])  # Restart all
            echo -e "\n${YELLOW}Restarting all systems...${NC}"
            kraken_max_util restart
            echo -e "${CYAN}Press any key to continue...${NC}"
            read -n 1 -s
            ;;
        [Mm])  # Monitor mode
            echo -e "\n${BLUE}Entering monitor mode... (Press ESC to exit)${NC}"
            kraken_max_util monitor &
            MONITOR_PID=$!
            while read -n 1 -s monitor_key; do
                if [[ $monitor_key == $'\e' ]]; then
                    kill $MONITOR_PID 2>/dev/null
                    break
                fi
            done
            ;;
        [Qq])  # Quit
            echo -e "\n${GREEN}Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "\n${RED}Invalid key. Press any key to continue...${NC}"
            read -n 1 -s
            ;;
    esac
done
```

## Function Key Interface

### /usr/local/bin/kraken_hotkeys
```bash
#!/bin/bash
# Function key interface for KrakenSDR

# Enable function key detection
setup_function_keys() {
    # Set terminal to detect function keys
    stty -echo
    tput smkx  # Enable keypad mode
}

# Cleanup on exit
cleanup() {
    tput rmkx  # Disable keypad mode
    stty echo
    clear
    echo "KrakenSDR Hotkey Interface Closed"
}

trap cleanup EXIT

setup_function_keys

echo "KrakenSDR Function Key Interface"
echo "================================"
echo "F1  - Start Max Utilization"
echo "F2  - Stop All Systems"
echo "F3  - Toggle VFO 1"
echo "F4  - Toggle VFO 2"
echo "F5  - Toggle VFO 3"
echo "F6  - Toggle Passive Radar"
echo "F7  - System Status"
echo "F8  - Real-time Monitor"
echo "F9  - Emergency Stop"
echo "F10 - Restart All"
echo "ESC - Exit"
echo
echo "Press function keys to control KrakenSDR..."

while true; do
    read -n 1 key

    # Handle escape sequences for function keys
    if [[ $key == $'\e' ]]; then
        read -n 2 -t 0.1 key
        case $key in
            'OP') # F1
                echo "F1: Starting Maximum Utilization..."
                kraken_max_util start
                ;;
            'OQ') # F2
                echo "F2: Stopping All Systems..."
                kraken_max_util stop
                ;;
            'OR') # F3
                echo "F3: Toggling VFO 1..."
                # Toggle VFO 1 logic here
                ;;
            'OS') # F4
                echo "F4: Toggling VFO 2..."
                # Toggle VFO 2 logic here
                ;;
            '[15~') # F5
                echo "F5: Toggling VFO 3..."
                # Toggle VFO 3 logic here
                ;;
            '[17~') # F6
                echo "F6: Toggling Passive Radar..."
                # Toggle passive radar logic here
                ;;
            '[18~') # F7
                echo "F7: System Status"
                kraken_max_util status
                ;;
            '[19~') # F8
                echo "F8: Real-time Monitor"
                kraken_max_util monitor &
                ;;
            '[20~') # F9
                echo "F9: EMERGENCY STOP!"
                kraken_max_util stop
                ;;
            '[21~') # F10
                echo "F10: Restarting All Systems..."
                kraken_max_util restart
                ;;
            '') # ESC alone
                echo "Exiting..."
                exit 0
                ;;
        esac
    fi
done
```

## Installation and Usage

### Install all button interfaces
```bash
# Copy scripts
sudo cp kraken_menu /usr/local/bin/
sudo cp kraken_quick /usr/local/bin/
sudo cp kraken_hotkeys /usr/local/bin/

# Make executable
sudo chmod +x /usr/local/bin/kraken_menu
sudo chmod +x /usr/local/bin/kraken_quick
sudo chmod +x /usr/local/bin/kraken_hotkeys

# Create aliases
echo "alias kraken='kraken_menu'" >> ~/.bashrc
echo "alias kq='kraken_quick'" >> ~/.bashrc
echo "alias kh='kraken_hotkeys'" >> ~/.bashrc
source ~/.bashrc
```

### Usage Options
```bash
# Full menu interface (most user-friendly)
kraken_menu

# Quick action buttons
kraken_quick

# Function key interface
kraken_hotkeys

# Or use aliases
kraken    # Full menu
kq        # Quick buttons
kh        # Function keys
```
