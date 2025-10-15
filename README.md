# KrakenSDR - Direction Finding & Passive Radar for RF-Kit

KrakenSDR coherent RTL-SDR array for direction finding, passive radar, and spectrum analysis.

## Overview

This directory contains the KrakenSDR data logger and integration tools for the RF-Kit system. KrakenSDR uses 5 coherent RTL-SDR dongles for advanced RF applications including direction of arrival (DOA), TDOA triangulation, passive radar, and beamforming.

## Features

- **Direction Finding (DOA)** - Determine bearing of RF signals
- **TDOA Triangulation** - Locate signal sources using time difference of arrival
- **Passive Radar** - Detect objects using ambient RF signals
- **Beamforming** - Directional signal reception
- **Spectrum Analysis** - Wideband spectrum monitoring
- **Elasticsearch Integration** - Automatic data export via Filebeat

## Quick Start

### Using Control Panel (Recommended)

```bash
cd /home/dragos/rf-kit/control-panel
python3 control-panel.py
# Select Option 2 for Quick Scan (includes KrakenSDR)
# Select Option 9 to Export KrakenSDR Data
```

### Manual Operation

```bash
cd /home/dragos/rf-kit/kraken-sdr
python3 kraken_data_logger.py --duration 60
```

## Configuration

### Hardware Requirements

- **KrakenSDR**: 5x coherent RTL-SDR dongles
- **Antennas**: 5 antennas for direction finding array
- **USB**: High-quality USB 3.0 connection

### Data Output

**Log Directory:** `/home/dragos/rf-kit/kraken-sdr/kraken-logs/`

**File Types:**
- `kraken-doa-YYYYMMDD.json` - Direction of arrival data
- `kraken-tdoa-YYYYMMDD.json` - TDOA triangulation events
- `kraken-spectrum-YYYYMMDD.json` - Spectrum analysis
- `kraken-radar-YYYYMMDD.json` - Passive radar detections
- `kraken-beamforming-YYYYMMDD.json` - Beamforming data
- `kraken-status-YYYYMMDD.json` - System status

### Elasticsearch Indices

- `kraken-sdr-doa-default` - Direction of Arrival
- `kraken-sdr-spectrum-default` - Spectrum Analysis
- `kraken-sdr-radar-default` - Passive Radar

## Data Flow

```
KrakenSDR (5x RTL-SDR)
    ↓
kraken_data_logger.py
    ↓
JSON Files (kraken-logs/)
    ↓
Filebeat
    ↓
Elasticsearch
    ↓
Kibana Dashboard
```

## Files

### kraken_data_logger.py

Main data collection script for KrakenSDR.

**Usage:**
```bash
python3 kraken_data_logger.py --duration 60
```

**Features:**
- Collects REAL data from KrakenSDR hardware
- Generates DOA, TDOA, spectrum, radar, and beamforming events
- Automatic file rotation by date
- Appends to existing daily files

### Desktop Integration

- `KrakenSDRControlCenter.desktop` - Desktop launcher
- `create-desktop-icon.sh` - Desktop icon installer
- `Kraken.png` - Application icon

## Event Types

### Direction Finding (DOA)
- **Fields:** `bearing_degrees`, `frequency_hz`, `rssi_db`, `confidence`
- **Use Case:** Determine direction of RF signals

### TDOA Triangulation
- **Fields:** `latitude`, `longitude`, `accuracy_meters`, `frequency_hz`
- **Use Case:** Locate signal sources geographically

### Spectrum Analysis
- **Fields:** `frequency_hz`, `power_dbm`, `bandwidth_hz`
- **Use Case:** Monitor RF spectrum activity

### Passive Radar
- **Fields:** `range_meters`, `velocity_mps`, `azimuth_degrees`, `snr_db`
- **Use Case:** Detect moving objects using ambient RF

### Beamforming
- **Fields:** `beam_angle_degrees`, `gain_db`, `frequency_hz`
- **Use Case:** Directional signal reception

## Troubleshooting

### No RTL-SDR Devices Found

**Problem:** KrakenSDR not detected

**Solution:**
1. Check USB connection: `lsusb | grep RTL`
2. Verify 5 devices are connected
3. Check udev rules: `/etc/udev/rules.d/20-rtlsdr.rules`
4. Logout/login for permissions

### Data Not Appearing in Elasticsearch

**Problem:** JSON files created but not in Elasticsearch

**Solution:**
1. Restart Filebeat: `sudo systemctl restart filebeat`
2. Check Filebeat logs: `journalctl -u filebeat -n 50`
3. Verify Filebeat paths in `/etc/filebeat/filebeat.yml`

### Docker Container Issues

**Problem:** KrakenSDR Docker container not running

**Solution:**
```bash
docker ps -a | grep kraken
docker logs krakensdr
docker restart krakensdr
```

## Integration with RF-Kit

KrakenSDR is fully integrated with the RF-Kit control panel:
- Automatically started/stopped during scans
- Data exported to Elasticsearch
- Monitored in unified dashboard
- Logs accessible from control panel

For more information, see the [Control Panel README](../control-panel/README.md).

## Web Interface

KrakenSDR web interface (when running in Docker):
- **URL:** http://localhost:8080
- **Features:** Live DOA display, spectrum waterfall, configuration

## References

- **KrakenSDR Official:** https://www.krakenrf.com/
- **Documentation:** https://docs.krakenrf.com/
- **GitHub:** https://github.com/krakenrf

