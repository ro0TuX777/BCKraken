# 📤 KrakenSDR Data Export Guide

## 🔍 Current Data Available

Your KrakenSDR system generates 6 types of data streams:

### 📁 Local JSON Files (kraken-logs/)
- **kraken-doa-20250911.json** - Direction of Arrival data
- **kraken-radar-20250911.json** - Passive radar detections  
- **kraken-spectrum-20250911.json** - Spectrum analysis data
- **kraken-beamforming-20250911.json** - Beamforming data
- **kraken-tdoa-20250911.json** - Time Difference of Arrival data
- **kraken-status-20250911.json** - System status data

## 📤 Export Methods

### 1️⃣ **ELASTICSEARCH (Already Active)**
```bash
# Data automatically streams to:
URL: https://172.18.18.20:9200
Username: filebeat-dragonos
Password: KUX4hkxjwp9qhu2wjx

# Indices created:
- kraken-sdr-doa-default
- kraken-sdr-radar-default  
- kraken-sdr-spectrum-default
- kraken-sdr-beamforming-default
- kraken-sdr-tdoa-default
- kraken-sdr-status-default
```

### 2️⃣ **Copy Local Files**
```bash
# Copy all data to USB drive
sudo cp -r kraken-logs/ /media/usb/kraken-data-$(date +%Y%m%d)/

# Copy to network location
scp -r kraken-logs/ user@server:/path/to/destination/

# Create compressed archive
tar -czf kraken-data-$(date +%Y%m%d).tar.gz kraken-logs/
```

### 3️⃣ **Export from Elasticsearch**
```bash
# Export all data from Elasticsearch
curl -u filebeat-dragonos:KUX4hkxjwp9qhu2wjx -k \
  "https://172.18.18.20:9200/kraken-sdr-*/_search?size=10000" \
  -o kraken_elasticsearch_export.json

# Export specific data type (e.g., direction finding)
curl -u filebeat-dragonos:KUX4hkxjwp9qhu2wjx -k \
  "https://172.18.18.20:9200/kraken-sdr-doa-*/_search?size=10000" \
  -o kraken_doa_export.json
```

### 4️⃣ **Real-time Streaming**
```bash
# Stream data to remote server via netcat
tail -f kraken-logs/kraken-doa-*.json | nc remote-server 9999

# Stream to MQTT broker
tail -f kraken-logs/kraken-doa-*.json | mosquitto_pub -t kraken/doa -l

# Stream to syslog
tail -f kraken-logs/kraken-doa-*.json | logger -t kraken-doa
```

## 🎯 Quick Export Commands

### **Export Everything (Recommended)**
```bash
# Create complete backup
./kraken_menu
# Go to option 6 (Data Query & Analysis)
# Select option 4 (Export Data Summary)

# Or manually:
mkdir kraken-export-$(date +%Y%m%d_%H%M%S)
cp -r kraken-logs/ kraken-export-$(date +%Y%m%d_%H%M%S)/
cp filebeat_kraken_simple.yml kraken-export-$(date +%Y%m%d_%H%M%S)/
tar -czf kraken-complete-$(date +%Y%m%d_%H%M%S).tar.gz kraken-export-$(date +%Y%m%d_%H%M%S)/
```

### **Send via Email**
```bash
# Compress and email
tar -czf kraken-data.tar.gz kraken-logs/
echo "KrakenSDR data attached" | mail -s "KrakenSDR Export" -a kraken-data.tar.gz recipient@email.com
```

### **Upload to Cloud**
```bash
# Upload to Google Drive (with gdrive tool)
gdrive upload kraken-data.tar.gz

# Upload to AWS S3
aws s3 cp kraken-logs/ s3://your-bucket/kraken-data/ --recursive

# Upload via SCP
scp -r kraken-logs/ user@remote-server:/backup/kraken/
```

## 📊 Data Formats

### **JSON Structure Example**
```json
{
  "@timestamp": "2025-09-11T17:08:00.000Z",
  "frequency_hz": 146520000,
  "bearing_degrees": 45.2,
  "confidence": 0.89,
  "station_id": "kraken-001",
  "data_type": "doa"
}
```

### **CSV Conversion**
```bash
# Convert JSON to CSV
jq -r '[.["@timestamp"], .frequency_hz, .bearing_degrees, .confidence] | @csv' \
  kraken-logs/kraken-doa-*.json > kraken-doa.csv
```

## 🔄 Automated Export

### **Cron Job for Regular Export**
```bash
# Add to crontab (crontab -e)
0 */6 * * * cd /home/bc_test/Downloads/kraken-sdr && tar -czf /backup/kraken-$(date +\%Y\%m\%d_\%H\%M).tar.gz kraken-logs/
```

### **Real-time Sync**
```bash
# Continuous sync to remote server
rsync -av --delete kraken-logs/ user@server:/remote/kraken-data/
```

## 🎮 Using the Menu System

1. **Run:** `./kraken_menu`
2. **Select:** Option 6 (Data Query & Analysis)
3. **Choose:**
   - Option 1: Show Latest Detections
   - Option 2: Check Elasticsearch Status  
   - Option 4: Export Data Summary

## 📈 Data Analysis Tools

### **View Data Statistics**
```bash
# Count records per file
for file in kraken-logs/*.json; do 
  echo "$(basename $file): $(wc -l < $file) records"
done

# Show data size
du -sh kraken-logs/

# Show latest detections
tail -5 kraken-logs/kraken-doa-*.json | jq .
```

### **Filter Data**
```bash
# Get high-confidence detections only
jq 'select(.confidence > 0.8)' kraken-logs/kraken-doa-*.json

# Get specific frequency range
jq 'select(.frequency_hz >= 144000000 and .frequency_hz <= 148000000)' kraken-logs/kraken-doa-*.json
```

## 🚀 Ready to Export!

Choose your preferred method above and start exporting your KrakenSDR data!
