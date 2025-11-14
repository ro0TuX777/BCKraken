#!/bin/bash
# KrakenSDR Full System Launcher
# Starts the complete KrakenSDR DOA system (DAQ firmware + web interface) and opens browser

KRAKEN_BASE="/home/dragos/rf-kit/kraken-sdr"
KRAKEN_DIR="$KRAKEN_BASE/krakensdr_doa"
WEB_PORT=8080
WEB_URL="http://localhost:${WEB_PORT}"
MAX_WAIT=60  # Maximum seconds to wait for web interface to start

# Function to check if web interface is running
check_web_service() {
    ss -tlnp 2>/dev/null | grep -q ":${WEB_PORT} "
    return $?
}

# Function to check if DAQ firmware is running
check_daq_running() {
    pgrep -f "heimdall_daq" >/dev/null 2>&1
    return $?
}

# Function to wait for web service to be ready
wait_for_web_service() {
    local count=0
    while [ $count -lt $MAX_WAIT ]; do
        if check_web_service; then
            return 0
        fi
        sleep 1
        count=$((count + 1))
    done
    return 1
}

# Check if web interface is already running
if check_web_service; then
    notify-send "KrakenSDR" "Web interface already running. Opening browser..." -i network-wireless
    xdg-open "$WEB_URL"
    exit 0
fi

# Check if system is starting up
if check_daq_running; then
    notify-send "KrakenSDR" "System is starting up, please wait..." -i network-wireless
    if wait_for_web_service; then
        notify-send "KrakenSDR" "✅ Web interface ready! Opening browser..." -i network-wireless
        xdg-open "$WEB_URL"
        exit 0
    else
        notify-send "KrakenSDR" "⚠️ Web interface taking longer than expected..." -u normal
        xdg-open "$WEB_URL"
        exit 0
    fi
fi

# System not running, need to start it
notify-send "KrakenSDR" "Starting KrakenSDR DOA system...\n\nA password prompt will appear." -i dialog-password -t 5000

# Change to KrakenSDR DOA directory
cd "$KRAKEN_DIR" || {
    notify-send "KrakenSDR" "❌ Error: Cannot find KrakenSDR directory!" -u critical
    zenity --error --text="KrakenSDR directory not found!\n\nPath: $KRAKEN_DIR" --title="KrakenSDR Error" 2>/dev/null
    exit 1
}

# Check if gui_run.sh exists
if [ ! -f "gui_run.sh" ]; then
    notify-send "KrakenSDR" "❌ Error: gui_run.sh not found!" -u critical
    zenity --error --text="Cannot find KrakenSDR startup script!\n\nPath: $KRAKEN_DIR/gui_run.sh" --title="KrakenSDR Error" 2>/dev/null
    exit 1
fi

# Create log directory
mkdir -p "_share/logs/krakensdr_doa"

# Start the full KrakenSDR system using gui_run.sh
# This starts: DAQ firmware, PHP server, Node.js middleware, and Python web interface
echo "Starting KrakenSDR DOA system..."
notify-send "KrakenSDR" "Starting DAQ firmware and web interface..." -i network-wireless

# Run gui_run.sh with sudo in background, redirect output to log
# Use pkexec for GUI password prompt, or fallback to terminal sudo
HELPER_SCRIPT="$KRAKEN_BASE/start_kraken_system.sh"

if command -v pkexec >/dev/null 2>&1; then
    # Use pkexec (GUI password prompt) with helper script
    pkexec "$HELPER_SCRIPT" &
elif command -v gksudo >/dev/null 2>&1; then
    # Fallback to gksudo if available
    gksudo "$HELPER_SCRIPT" &
else
    # Last resort: open a terminal for sudo
    notify-send "KrakenSDR" "Opening terminal for password..." -i dialog-password
    x-terminal-emulator -e "bash -c 'sudo $HELPER_SCRIPT; echo Press Enter to close...; read'" &
fi

# Wait for web service to be ready
notify-send "KrakenSDR" "Waiting for web interface to start (this may take up to 60 seconds)..." -i network-wireless

if wait_for_web_service; then
    # Service is ready, open browser
    sleep 2  # Give it a moment to fully initialize
    notify-send "KrakenSDR" "✅ KrakenSDR DOA system started! Opening browser..." -i network-wireless
    xdg-open "$WEB_URL"
else
    # Service failed to start within timeout
    notify-send "KrakenSDR" "⚠️ Web interface not ready yet, but opening browser anyway..." -u normal
    zenity --warning --text="KrakenSDR system is starting but the web interface\nis taking longer than expected.\n\nThe browser will open now, but you may need to\nrefresh the page in a few moments.\n\nURL: $WEB_URL\n\nCheck logs at:\n$KRAKEN_DIR/_share/logs/krakensdr_doa/gui_run.log" --title="KrakenSDR Starting" 2>/dev/null &
    xdg-open "$WEB_URL"
fi

