# KrakenSDR Complete Terminal Installation Guide

## Overview
This guide provides step-by-step terminal-only instructions for installing and configuring the complete KrakenSDR software ecosystem for maximum utilization. All operations are performed via command-line interface with no GUI dependencies.

## Prerequisites

### Hardware Requirements
- **KrakenSDR Unit**: 5-channel coherent SDR
- **Computing Platform**: 
  - Raspberry Pi 4/5 (4GB+ RAM) or Orange Pi 5B
  - Alternative: x86 PC (recommended for passive radar)
- **Antennas**: 5 identical antennas for coherent array
- **Cables**: 5 matched coaxial cables
- **Power Supply**: 5V/3A for KrakenSDR
- **Network**: Ethernet or WiFi connectivity

### Software Prerequisites
- **Operating System**: Ubuntu 20.04+ or Raspberry Pi OS
- **Python**: 3.8+
- **Git**: For source code management
- **Network Access**: For downloading packages and updates

### Optional Components
- **GPS Module**: For precise timing and location
- **External Reference**: 10 MHz reference oscillator
- **Android Device**: For mobile direction finding
- **Cloud Account**: For KrakenSDR Pro Cloud Mapper

## Phase 1: Core System Installation

### Step 1: Heimdall DAQ Firmware

#### Option A: Command-Line Installation (Recommended)
```bash
# Update system first
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y git cmake build-essential libusb-1.0-0-dev pkg-config
sudo apt install -y python3-dev python3-pip python3-numpy python3-scipy

# Clone and build Heimdall DAQ
git clone https://github.com/krakenrf/heimdall_daq_fw.git
cd heimdall_daq_fw
mkdir build && cd build
cmake ..
make -j$(nproc)
sudo make install

# Configure udev rules
sudo cp ../udev/99-kraken.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
```

#### Option B: Systemd Service Setup
```bash
# Create systemd service file
sudo tee /etc/systemd/system/heimdall-daq.service << EOF
[Unit]
Description=KrakenSDR Heimdall DAQ Service
After=network.target

[Service]
Type=simple
User=pi
WorkingDirectory=/home/pi/heimdall_daq_fw
ExecStart=/usr/local/bin/heimdall_daq
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
sudo systemctl daemon-reload
sudo systemctl enable heimdall-daq.service
sudo systemctl start heimdall-daq.service

# Check status
sudo systemctl status heimdall-daq.service
```

#### Option C: Manual Installation
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y git cmake build-essential libusb-1.0-0-dev pkg-config

# Clone and build
git clone https://github.com/krakenrf/heimdall_daq_fw.git
cd heimdall_daq_fw
mkdir build && cd build
cmake ..
make -j$(nproc)
sudo make install

# Configure udev rules
sudo cp ../udev/99-kraken.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
```

### Step 2: KrakenSDR DoA DSP Software

#### Installation
```bash
# Clone repository
git clone https://github.com/krakenrf/krakensdr_doa.git
cd krakensdr_doa

# Install Python dependencies
pip3 install -r requirements.txt

# Install additional packages
sudo apt install -y python3-pip python3-numpy python3-scipy python3-matplotlib

# Configure settings
cp settings.json.example settings.json
# Edit settings.json for your configuration
```

#### Configuration
```json
{
  "center_freq": 146520000,
  "sample_rate": 2400000,
  "fft_size": 1024,
  "decimation": 1,
  "gain": [20, 20, 20, 20, 20],
  "array_config": {
    "type": "UCA",
    "radius": 0.5,
    "elements": 5
  }
}
```

### Step 3: Maximum Utilization Configuration

#### Create Configuration Files
```bash
# Create main configuration directory
sudo mkdir -p /etc/kraken
sudo chown $USER:$USER /etc/kraken

# Create maximum utilization config
cat > /etc/kraken/max_utilization.json << EOF
{
  "mode": "MAX_UTILIZATION",
  "vfo_config": {
    "vfo_1": {
      "frequency": 146520000,
      "bandwidth": 25000,
      "mode": "DF_CONTINUOUS",
      "algorithm": "MUSIC",
      "gain": 20,
      "priority": "HIGH"
    },
    "vfo_2": {
      "frequency": 462675000,
      "bandwidth": 12500,
      "mode": "DF_SCAN",
      "algorithm": "Bartlett",
      "gain": 25,
      "scan_list": [462550000, 462575000, 462600000, 462625000, 462650000, 462675000, 462700000, 462725000]
    },
    "vfo_3": {
      "frequency": 155340000,
      "bandwidth": 25000,
      "mode": "DF_PRIORITY",
      "algorithm": "Capon",
      "gain": 30,
      "scan_range": [154000000, 156000000]
    },
    "vfo_4": {
      "frequency": 101500000,
      "bandwidth": 200000,
      "mode": "PASSIVE_RADAR_REF",
      "gain": 15,
      "illuminator_type": "FM_BROADCAST"
    },
    "vfo_5": {
      "frequency": "AUTO_SCAN",
      "bandwidth": 25000,
      "mode": "DISCOVERY",
      "algorithm": "MEMS",
      "gain": "AUTO",
      "scan_speed": "FAST"
    }
  },
  "processing": {
    "beamforming": true,
    "passive_radar": true,
    "signal_classification": true,
    "track_correlation": true,
    "concurrent_algorithms": true
  },
  "output": {
    "elasticsearch": {
      "enabled": true,
      "host": "localhost",
      "port": 9200,
      "index_prefix": "kraken",
      "real_time": true
    },
    "file_logging": {
      "enabled": true,
      "path": "/var/log/kraken",
      "rotation": "daily"
    },
    "terminal_output": true
  }
}
EOF
```

#### Start Maximum Utilization Mode
```bash
# Start DoA DSP in maximum utilization mode
cd krakensdr_doa
python3 kraken_doa_cli.py --config /etc/kraken/max_utilization.json --daemon

# Verify all VFOs are active
kraken_status --all-vfos

# Monitor real-time output
tail -f /var/log/kraken/kraken_doa.log

# Check Elasticsearch integration
curl http://localhost:9200/kraken-*/_search?pretty | head -50
```

## Phase 2: GNU Radio Integration

### GNU Radio Installation
```bash
# Install GNU Radio
sudo apt install -y gnuradio gnuradio-dev

# Install KrakenSDR GNU Radio block
cd krakensdr_doa/gnuradio
mkdir build && cd build
cmake ..
make -j$(nproc)
sudo make install
sudo ldconfig

# Test installation
python3 -c "import gnuradio.krakensdr; print('KrakenSDR block installed successfully')"
```

### Example Flowgraph
```python
#!/usr/bin/env python3
from gnuradio import gr, blocks
from gnuradio.krakensdr import krakensdr_source

class KrakenTest(gr.top_block):
    def __init__(self):
        gr.top_block.__init__(self)
        
        # KrakenSDR source
        self.kraken = krakensdr_source(
            sample_rate=2400000,
            center_freq=146520000,
            gain=[20, 20, 20, 20, 20]
        )
        
        # File sinks for each channel
        for i in range(5):
            sink = blocks.file_sink(gr.sizeof_gr_complex, f"channel_{i}.dat")
            self.connect((self.kraken, i), sink)

if __name__ == '__main__':
    tb = KrakenTest()
    tb.start()
    input("Press Enter to stop...")
    tb.stop()
    tb.wait()
```

## Phase 3: Terminal Control Scripts

### Create Control Scripts
```bash
# Create kraken control script
sudo tee /usr/local/bin/kraken_control << 'EOF'
#!/bin/bash

case "$1" in
    start)
        echo "Starting KrakenSDR maximum utilization mode..."
        systemctl start heimdall-daq
        systemctl start kraken-dsp
        python3 /home/pi/krakensdr_doa/kraken_doa_cli.py --config /etc/kraken/max_utilization.json --daemon
        ;;
    stop)
        echo "Stopping KrakenSDR services..."
        systemctl stop kraken-dsp
        systemctl stop heimdall-daq
        ;;
    status)
        echo "=== KrakenSDR Status ==="
        systemctl status heimdall-daq --no-pager -l
        systemctl status kraken-dsp --no-pager -l
        kraken_status --all-vfos
        ;;
    monitor)
        echo "=== Real-time Monitoring ==="
        tail -f /var/log/kraken/kraken_doa.log
        ;;
    *)
        echo "Usage: $0 {start|stop|status|monitor}"
        exit 1
        ;;
esac
EOF

sudo chmod +x /usr/local/bin/kraken_control
```

## Phase 4: Cloud Integration

### KrakenSDR Pro Cloud Mapper Setup
1. Create account at KrakenRF Pro Cloud Mapper
2. Generate API key for device registration
3. Configure local system for cloud connectivity
4. Test data upload and visualization

### Cloud Configuration
```bash
# Install cloud client
pip3 install krakensdr-cloud-client

# Configure credentials
cat > ~/.kraken_cloud_config << EOF
{
  "api_key": "your_api_key_here",
  "device_id": "kraken_001",
  "upload_interval": 30,
  "data_types": ["bearings", "spectrum", "tracks"]
}
EOF

# Start cloud client
python3 -m krakensdr_cloud_client
```

## Phase 5: Elasticsearch Integration

### Elasticsearch Setup
```bash
# Install Elasticsearch
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list
sudo apt update && sudo apt install elasticsearch

# Configure Elasticsearch
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch

# Install Kibana for visualization
sudo apt install kibana
sudo systemctl enable kibana
sudo systemctl start kibana
```

### KrakenSDR to Elasticsearch Bridge
```python
#!/usr/bin/env python3
import json
import time
from elasticsearch import Elasticsearch
from websocket import WebSocketApp

class KrakenElasticsearchBridge:
    def __init__(self):
        self.es = Elasticsearch([{'host': 'localhost', 'port': 9200}])
        self.ws_url = "ws://localhost:8080/ws"
        
    def on_message(self, ws, message):
        data = json.loads(message)
        
        # Transform KrakenSDR data for Elasticsearch
        doc = {
            'timestamp': time.time(),
            'frequency': data.get('frequency'),
            'bearing': data.get('bearing'),
            'confidence': data.get('confidence'),
            'signal_strength': data.get('signal_strength'),
            'device_id': 'kraken_001'
        }
        
        # Index in Elasticsearch
        self.es.index(
            index=f"kraken-data-{time.strftime('%Y-%m')}",
            body=doc
        )
    
    def start(self):
        ws = WebSocketApp(self.ws_url, on_message=self.on_message)
        ws.run_forever()

if __name__ == '__main__':
    bridge = KrakenElasticsearchBridge()
    bridge.start()
```

## Phase 6: Advanced Configuration

### Antenna Array Calibration
```bash
# Run calibration procedure
cd krakensdr_doa
python3 calibration_tool.py --array-type UCA --frequency 146520000

# Verify calibration
python3 verify_calibration.py --test-signal 146520000
```

### Performance Optimization
```bash
# CPU optimization
echo 'performance' | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Memory optimization
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf

# Network optimization
echo 'net.core.rmem_max = 134217728' | sudo tee -a /etc/sysctl.conf
echo 'net.core.wmem_max = 134217728' | sudo tee -a /etc/sysctl.conf

# Apply changes
sudo sysctl -p
```

### Security Configuration
```bash
# Configure firewall
sudo ufw enable
sudo ufw allow 8080/tcp  # Web interface
sudo ufw allow 22/tcp    # SSH
sudo ufw allow from 192.168.1.0/24  # Local network

# Configure HTTPS (optional)
sudo apt install nginx certbot
# Configure SSL certificate and reverse proxy
```

## Phase 7: Integration Testing

### Basic Functionality Test
```bash
# Test DAQ functionality
kraken_control status

# Test all VFOs
kraken_vfo --test-all

# Test direction finding on specific frequency
kraken_df --frequency 146.520e6 --algorithm MUSIC --duration 30

# Test passive radar
kraken_radar --illuminator FM_101.5 --test-mode

# Check Elasticsearch data flow
curl http://localhost:9200/kraken-*/_count
```

### Performance Verification
```bash
# Monitor system resources
htop

# Check data flow
tail -f /var/log/kraken/daq.log
tail -f /var/log/kraken/dsp.log

# Verify Elasticsearch integration
curl http://localhost:9200/kraken-data-*/_search?pretty
```

## Troubleshooting

### Common Issues
1. **USB Permission Errors**: Check udev rules installation
2. **High CPU Usage**: Reduce sample rate or processing complexity
3. **Network Connectivity**: Verify firewall and network configuration
4. **Calibration Problems**: Check antenna array geometry
5. **Web Interface Not Loading**: Check service status and logs

### Diagnostic Commands
```bash
# Check service status
sudo systemctl status kraken-daq
sudo systemctl status elasticsearch

# View logs
journalctl -u kraken-daq -f
tail -f /var/log/elasticsearch/elasticsearch.log

# Test hardware
lsusb | grep -i kraken
dmesg | grep -i kraken

# Network diagnostics
netstat -tlnp | grep 8080
curl -I http://localhost:8080
```

### Performance Tuning
```bash
# Monitor performance
iostat -x 1
sar -u 1
free -h

# Optimize for real-time
echo -1 | sudo tee /proc/sys/kernel/sched_rt_runtime_us
chrt -f 99 python3 kraken_doa_start.py
```

## Next Steps
1. Complete basic installation and testing
2. Configure antenna array and calibration
3. Integrate with existing Elasticsearch infrastructure
4. Develop custom applications and workflows
5. Optimize performance for specific use cases
6. Implement monitoring and alerting
7. Plan for scaling and redundancy
