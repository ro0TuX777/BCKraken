#!/bin/bash
# Kill all KrakenSDR processes

echo "Killing all KrakenSDR processes..."

sudo pkill -f "python.*app.py"
sudo pkill -f "php -S"
sudo pkill -f "node _nodejs"
sudo pkill -f "heimdall"
sudo pkill -f "daq_start"

echo "All KrakenSDR processes killed."
echo ""
echo "Checking for remaining processes..."
ps aux | grep -E "(heimdall|python.*app.py|php -S|node _nodejs)" | grep -v grep || echo "✓ No KrakenSDR processes running"

