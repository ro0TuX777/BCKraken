#!/bin/bash
# One-time permission fix for KrakenSDR files
# Some files may be owned by root from previous runs with sudo

echo "Fixing KrakenSDR file permissions..."
echo "This requires sudo access."
echo ""

sudo chown -R $USER:$USER /home/dragos/rf-kit/kraken-sdr/krakensdr_doa/_share/
sudo chown -R $USER:$USER /home/dragos/rf-kit/kraken-sdr/heimdall_daq_fw/Firmware/_data_control/ 2>/dev/null || true

echo ""
echo "✅ Permissions fixed!"
echo "You can now run the KrakenSDR desktop icon without issues."

