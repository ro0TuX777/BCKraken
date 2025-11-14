# KrakenSDR Logs - Quick Reference Guide

## 📁 Log Location

**Directory:** `/home/dragos/rf-kit/kraken-sdr/kraken-logs/`

All KrakenSDR data is automatically saved to this directory when running the kraken executable or data logger.

## 📊 Log File Types

| File Pattern | Description | Data Type |
|-------------|-------------|-----------|
| `kraken-doa-YYYYMMDD.json` | Direction of Arrival | Bearing angles, confidence, DOA spectrum |
| `kraken-spectrum-YYYYMMDD.json` | Spectrum Analysis | Frequency ranges, power levels, VFO channels |
| `kraken-tdoa-YYYYMMDD.json` | TDOA Triangulation | Time differences, position estimates |
| `kraken-radar-YYYYMMDD.json` | Passive Radar | Target detections, range, velocity |
| `kraken-beamforming-YYYYMMDD.json` | Beamforming | Directional signal data |
| `kraken-status-YYYYMMDD.json` | System Status | Hardware status, RTL-SDR info |

## 🔍 Quick View Commands

### View Latest Entries

```bash
# Latest DOA (Direction of Arrival)
tail -5 kraken-sdr/kraken-logs/kraken-doa-*.json | jq .

# Latest Spectrum Analysis
tail -5 kraken-sdr/kraken-logs/kraken-spectrum-*.json | jq .

# Latest Radar Detections
tail -5 kraken-sdr/kraken-logs/kraken-radar-*.json | jq .

# Latest System Status
tail -5 kraken-sdr/kraken-logs/kraken-status-*.json | jq .
```

### Monitor Logs in Real-Time

```bash
# Watch DOA data as it comes in
tail -f kraken-sdr/kraken-logs/kraken-doa-*.json

# Watch spectrum data
tail -f kraken-sdr/kraken-logs/kraken-spectrum-*.json

# Watch all logs
tail -f kraken-sdr/kraken-logs/*.json
```

### Count Entries

```bash
# Count DOA entries today
wc -l kraken-sdr/kraken-logs/kraken-doa-$(date +%Y%m%d).json

# Count all entries in a file
wc -l kraken-sdr/kraken-logs/kraken-doa-20251010.json
```

### Search for Specific Data

```bash
# Find high-confidence DOA readings (confidence > 8)
jq 'select(.confidence > 8)' kraken-sdr/kraken-logs/kraken-doa-*.json

# Find signals on specific frequency (e.g., 146.52 MHz)
jq 'select(.frequency_hz > 146500000 and .frequency_hz < 146540000)' \
   kraken-sdr/kraken-logs/kraken-doa-*.json

# Find radar detections with high velocity
jq 'select(.velocity_mps > 50)' kraken-sdr/kraken-logs/kraken-radar-*.json

# Find spectrum data with signal detections
jq 'select(.vfo_channels[].signal_detected == true)' \
   kraken-sdr/kraken-logs/kraken-spectrum-*.json
```

## 📈 Data Analysis Examples

### Extract Bearing Data

```bash
# Get all bearings from today
jq -r '.bearing_degrees' kraken-sdr/kraken-logs/kraken-doa-$(date +%Y%m%d).json

# Get bearings with timestamps
jq -r '[."@timestamp", .bearing_degrees, .confidence] | @csv' \
   kraken-sdr/kraken-logs/kraken-doa-*.json
```

### Frequency Analysis

```bash
# List all detected frequencies
jq -r '.frequency_hz' kraken-sdr/kraken-logs/kraken-doa-*.json | sort -u

# Get frequency distribution
jq -r '.frequency_hz' kraken-sdr/kraken-logs/kraken-doa-*.json | \
   sort | uniq -c | sort -rn
```

### Power Level Statistics

```bash
# Get RSSI values
jq -r '.rssi_db' kraken-sdr/kraken-logs/kraken-doa-*.json

# Get spectrum power stats
jq '.power_stats' kraken-sdr/kraken-logs/kraken-spectrum-*.json
```

## 🎯 Specific Use Cases

### Find Strongest Signals

```bash
# Top 10 strongest signals by RSSI
jq -r '[."@timestamp", .frequency_hz, .rssi_db, .bearing_degrees] | @csv' \
   kraken-sdr/kraken-logs/kraken-doa-*.json | \
   sort -t, -k3 -rn | head -10
```

### Track Specific Station

```bash
# Find all data from a specific station ID
jq 'select(.station_id == "KrakenSDR-001")' \
   kraken-sdr/kraken-logs/kraken-doa-*.json
```

### Time-Based Queries

```bash
# Get data from specific time range (example: last hour)
jq --arg time "$(date -u -d '1 hour ago' +%Y-%m-%dT%H)" \
   'select(."@timestamp" > $time)' \
   kraken-sdr/kraken-logs/kraken-doa-*.json
```

## 📊 Export to CSV

### DOA Data to CSV

```bash
# Export DOA data with key fields
jq -r '[."@timestamp", .bearing_degrees, .confidence, .frequency_hz, .rssi_db] | @csv' \
   kraken-sdr/kraken-logs/kraken-doa-*.json > doa_export.csv
```

### Spectrum Data to CSV

```bash
# Export spectrum stats
jq -r '[."@timestamp", .frequency_range_hz.center, .power_stats.mean_dbm, .power_stats.max_dbm] | @csv' \
   kraken-sdr/kraken-logs/kraken-spectrum-*.json > spectrum_export.csv
```

## 🔧 Troubleshooting

### Check if Logs are Being Created

```bash
# List all log files with timestamps
ls -lht kraken-sdr/kraken-logs/

# Check latest modification time
stat kraken-sdr/kraken-logs/kraken-doa-*.json | grep Modify
```

### Verify Log Format

```bash
# Check if JSON is valid
jq empty kraken-sdr/kraken-logs/kraken-doa-*.json && echo "Valid JSON" || echo "Invalid JSON"

# Pretty print first entry
head -1 kraken-sdr/kraken-logs/kraken-doa-*.json | jq .
```

### Check Data Source

```bash
# Verify if using real hardware
jq -r '.data_source' kraken-sdr/kraken-logs/kraken-doa-*.json | sort -u

# Check RTL-SDR device count
jq -r '.rtl_sdr_devices_available' kraken-sdr/kraken-logs/kraken-doa-*.json | sort -u
```

## 📁 File Management

### Archive Old Logs

```bash
# Create archive directory
mkdir -p kraken-sdr/kraken-logs/archive

# Move logs older than 7 days
find kraken-sdr/kraken-logs/ -name "*.json" -mtime +7 \
   -exec mv {} kraken-sdr/kraken-logs/archive/ \;
```

### Compress Logs

```bash
# Compress old logs
gzip kraken-sdr/kraken-logs/archive/*.json

# Compress by date
tar -czf kraken-logs-$(date +%Y%m).tar.gz \
   kraken-sdr/kraken-logs/kraken-*-$(date +%Y%m)*.json
```

## 🚀 Integration with Elasticsearch

The logs are automatically picked up by Filebeat and sent to Elasticsearch.

**Filebeat Config:** `kraken-sdr/filebeat_kraken_simple.yml`

**Elasticsearch Indices:**
- `kraken-sdr-doa-default`
- `kraken-sdr-spectrum-default`
- `kraken-sdr-radar-default`

### Check Filebeat Status

```bash
# Check if Filebeat is running
sudo systemctl status filebeat

# View Filebeat logs
sudo journalctl -u filebeat -f
```

## 📊 Current Log Statistics

```bash
# Total size of all logs
du -sh kraken-sdr/kraken-logs/

# Count entries by type
for type in doa spectrum tdoa radar beamforming status; do
    count=$(cat kraken-sdr/kraken-logs/kraken-$type-*.json 2>/dev/null | wc -l)
    echo "$type: $count entries"
done
```

## 🎯 Quick Summary Script

Save this as `kraken-sdr/log_summary.sh`:

```bash
#!/bin/bash
echo "KrakenSDR Log Summary"
echo "===================="
echo ""
echo "Log Directory: $(pwd)/kraken-sdr/kraken-logs/"
echo "Total Files: $(ls kraken-sdr/kraken-logs/*.json 2>/dev/null | wc -l)"
echo "Total Size: $(du -sh kraken-sdr/kraken-logs/ | cut -f1)"
echo ""
echo "Entry Counts:"
for type in doa spectrum tdoa radar beamforming status; do
    count=$(cat kraken-sdr/kraken-logs/kraken-$type-*.json 2>/dev/null | wc -l)
    printf "  %-15s: %6d entries\n" "$type" "$count"
done
echo ""
echo "Latest Entries:"
echo "  DOA: $(tail -1 kraken-sdr/kraken-logs/kraken-doa-*.json 2>/dev/null | jq -r '."@timestamp"')"
echo "  Spectrum: $(tail -1 kraken-sdr/kraken-logs/kraken-spectrum-*.json 2>/dev/null | jq -r '."@timestamp"')"
```

Make it executable:
```bash
chmod +x kraken-sdr/log_summary.sh
./kraken-sdr/log_summary.sh
```

## 📚 Additional Resources

- **Main README:** `kraken-sdr/README.md`
- **Data Logger:** `kraken-sdr/kraken_data_logger.py`
- **Control Menu:** `kraken-sdr/kraken_menu`
- **Filebeat Config:** `kraken-sdr/filebeat_kraken_simple.yml`

