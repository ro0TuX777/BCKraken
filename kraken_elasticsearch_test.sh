#!/bin/bash

# KrakenSDR Elasticsearch Export Test
# Verifies data is flowing to Elasticsearch

echo "=========================================="
echo "    KrakenSDR Elasticsearch Export Test"
echo "=========================================="
echo ""

# Elasticsearch credentials
ES_HOST="https://172.18.18.20:9200"
ES_USER="filebeat-dragonos"
ES_PASS="KUX4hkxjwp9qhu2wjx"

echo "1. Testing Elasticsearch Connection:"
curl -u $ES_USER:$ES_PASS -k "$ES_HOST/_cluster/health?pretty" 2>/dev/null | head -10
echo ""

echo "2. Checking Filebeat Status:"
sudo systemctl status filebeat --no-pager -l | head -10
echo ""

echo "3. Generating Fresh KrakenSDR Data:"
cd /home/bc_test/Downloads/kraken-sdr
source kraken_env/bin/activate
python3 kraken_data_logger.py --generate-samples
echo ""

echo "4. Waiting for Filebeat to process data (10 seconds)..."
sleep 10
echo ""

echo "5. Verifying Data Streams in Elasticsearch:"

echo "   Direction of Arrival (DoA) Data:"
doa_count=$(curl -s -u $ES_USER:$ES_PASS -k "$ES_HOST/kraken-sdr-doa-default/_count" | grep -o '"count":[0-9]*' | cut -d':' -f2)
echo "     Count: $doa_count documents"

echo "   Spectrum Analysis Data:"
spectrum_count=$(curl -s -u $ES_USER:$ES_PASS -k "$ES_HOST/kraken-sdr-spectrum-default/_count" | grep -o '"count":[0-9]*' | cut -d':' -f2)
echo "     Count: $spectrum_count documents"

echo "   Passive Radar Data:"
radar_count=$(curl -s -u $ES_USER:$ES_PASS -k "$ES_HOST/kraken-sdr-radar-default/_count" | grep -o '"count":[0-9]*' | cut -d':' -f2)
echo "     Count: $radar_count documents"

echo "   System Status Data:"
status_count=$(curl -s -u $ES_USER:$ES_PASS -k "$ES_HOST/kraken-sdr-status-default/_count" | grep -o '"count":[0-9]*' | cut -d':' -f2)
echo "     Count: $status_count documents"

echo "   DAQ Logs:"
daq_count=$(curl -s -u $ES_USER:$ES_PASS -k "$ES_HOST/kraken-sdr-daq-default/_count" | grep -o '"count":[0-9]*' | cut -d':' -f2)
echo "     Count: $daq_count documents"
echo ""

echo "6. Sample Data Verification:"
echo "   Latest DoA Entry:"
curl -s -u $ES_USER:$ES_PASS -k "$ES_HOST/kraken-sdr-doa-default/_search?size=1&sort=@timestamp:desc&pretty" | grep -A 20 '"_source"' | head -15

echo ""
echo "7. Local Log Files:"
ls -la /home/bc_test/Downloads/kraken-sdr/kraken-logs/
echo ""

echo "8. Filebeat Log Check:"
sudo tail -5 /var/log/filebeat/filebeat 2>/dev/null || echo "   No filebeat logs found"
echo ""

# Calculate total documents
total_docs=$((${doa_count:-0} + ${spectrum_count:-0} + ${radar_count:-0} + ${status_count:-0} + ${daq_count:-0}))

echo "=========================================="
echo "    Export Status Summary"
echo "=========================================="
echo ""
echo "Total Documents in Elasticsearch: $total_docs"
echo ""

if [ $total_docs -gt 0 ]; then
    echo "✅ SUCCESS: KrakenSDR data is flowing to Elasticsearch!"
    echo ""
    echo "Data Streams Active:"
    [ ${doa_count:-0} -gt 0 ] && echo "  ✓ Direction Finding: $doa_count documents"
    [ ${spectrum_count:-0} -gt 0 ] && echo "  ✓ Spectrum Analysis: $spectrum_count documents"
    [ ${radar_count:-0} -gt 0 ] && echo "  ✓ Passive Radar: $radar_count documents"
    [ ${status_count:-0} -gt 0 ] && echo "  ✓ System Status: $status_count documents"
    [ ${daq_count:-0} -gt 0 ] && echo "  ✓ DAQ Logs: $daq_count documents"
    echo ""
    echo "Elasticsearch Indices:"
    echo "  • kraken-sdr-doa-default"
    echo "  • kraken-sdr-spectrum-default"
    echo "  • kraken-sdr-radar-default"
    echo "  • kraken-sdr-status-default"
    echo "  • kraken-sdr-daq-default"
else
    echo "⚠️  WARNING: No data found in Elasticsearch"
    echo ""
    echo "Troubleshooting steps:"
    echo "  1. Check Filebeat status: sudo systemctl status filebeat"
    echo "  2. Check Filebeat logs: sudo journalctl -u filebeat -f"
    echo "  3. Verify network connectivity to $ES_HOST"
    echo "  4. Generate more test data: python3 kraken_data_logger.py --generate-samples"
fi

echo ""
echo "=========================================="
