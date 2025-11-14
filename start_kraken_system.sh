#!/bin/bash
# Helper script for starting KrakenSDR system with sudo
# This is called by pkexec from the desktop launcher

KRAKEN_BASE="/home/dragos/rf-kit/kraken-sdr"
KRAKEN_DIR="$KRAKEN_BASE/krakensdr_doa"
KRAKEN_ENV="$KRAKEN_BASE/kraken_env"
LOG_FILE="$KRAKEN_DIR/_share/logs/krakensdr_doa/gui_run.log"
UI_LOG="$KRAKEN_DIR/_share/logs/krakensdr_doa/ui.log"

echo "========================================" >> "$LOG_FILE"
echo "=== KrakenSDR System Startup Debug ===" >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"
echo "Timestamp: $(date)" >> "$LOG_FILE"
echo "User: $(whoami)" >> "$LOG_FILE"
echo "UID: $UID" >> "$LOG_FILE"
echo "HOME: $HOME" >> "$LOG_FILE"
echo "PATH: $PATH" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Change to KrakenSDR directory
echo "Changing to directory: $KRAKEN_DIR" >> "$LOG_FILE"
cd "$KRAKEN_DIR" || {
    echo "ERROR: Cannot change to directory: $KRAKEN_DIR" >> "$LOG_FILE"
    exit 1
}
echo "Current directory: $(pwd)" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Check if virtual environment exists
echo "Checking for virtual environment..." >> "$LOG_FILE"
if [ -d "$KRAKEN_ENV" ]; then
    echo "✓ Virtual environment found at: $KRAKEN_ENV" >> "$LOG_FILE"
    echo "  Activating virtual environment..." >> "$LOG_FILE"
    source "$KRAKEN_ENV/bin/activate"
    echo "  Virtual environment activated" >> "$LOG_FILE"
else
    echo "✗ WARNING: Virtual environment not found at: $KRAKEN_ENV" >> "$LOG_FILE"
fi
echo "" >> "$LOG_FILE"

# Show Python information
echo "Python Information:" >> "$LOG_FILE"
echo "  which python3: $(which python3)" >> "$LOG_FILE"
echo "  python3 version: $(python3 --version 2>&1)" >> "$LOG_FILE"
echo "  VIRTUAL_ENV: ${VIRTUAL_ENV:-not set}" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Test if dash_devices module is available
echo "Testing Python modules..." >> "$LOG_FILE"
if python3 -c "import dash_devices" 2>/dev/null; then
    echo "  ✓ dash_devices module found" >> "$LOG_FILE"
else
    echo "  ✗ ERROR: dash_devices module NOT found" >> "$LOG_FILE"
    echo "  This will cause the web interface to fail!" >> "$LOG_FILE"
fi

if python3 -c "import dash" 2>/dev/null; then
    echo "  ✓ dash module found" >> "$LOG_FILE"
else
    echo "  ✗ ERROR: dash module NOT found" >> "$LOG_FILE"
fi
echo "" >> "$LOG_FILE"

# Clear old UI log
echo "Clearing old UI log..." >> "$LOG_FILE"
echo "=== UI Log started at $(date) ===" > "$UI_LOG"
echo "" >> "$LOG_FILE"

# Start DAQ firmware first
echo "Starting DAQ firmware..." >> "$LOG_FILE"
DAQ_DIR="$KRAKEN_BASE/heimdall_daq_fw/Firmware"
if [ -d "$DAQ_DIR" ]; then
    echo "  DAQ directory found: $DAQ_DIR" >> "$LOG_FILE"
    cd "$DAQ_DIR" || {
        echo "  ERROR: Cannot change to DAQ directory" >> "$LOG_FILE"
        exit 1
    }
    echo "  Running daq_start_sm.sh..." >> "$LOG_FILE"
    env "PATH=$PATH" ./daq_start_sm.sh >> "$LOG_FILE" 2>&1
    echo "  DAQ firmware started" >> "$LOG_FILE"
    sleep 2
    cd "$KRAKEN_DIR" || exit 1
else
    echo "  WARNING: DAQ directory not found at: $DAQ_DIR" >> "$LOG_FILE"
    echo "  Continuing without DAQ firmware..." >> "$LOG_FILE"
fi
echo "" >> "$LOG_FILE"

# Run gui_run.sh
echo "Starting gui_run.sh..." >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

env "PATH=$PATH" bash gui_run.sh >> "$LOG_FILE" 2>&1

# Capture exit code
EXIT_CODE=$?
echo "" >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"
echo "gui_run.sh exited with code: $EXIT_CODE" >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"

