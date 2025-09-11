# KrakenSDR Core DAQ and DSP Components - Terminal Operation

## Overview
The foundation of KrakenSDR operations consists of two primary components that handle data acquisition and digital signal processing for all scanning and analysis methods. All operations are controlled via command-line interface and configuration files.

## Heimdall DAQ Firmware

### Purpose
- Heart of KrakenSDR signal acquisition
- Manages multi-channel coherent data streams from the SDR
- Essential for all KrakenSDR methods including spectrum sweep, wideband scanning, passive radar, and DoA
- Operates as background daemon with CLI control

### Key Features
- Captures, synchronizes, and manages data from all five SDR channels
- Coherent multi-channel sampling with clock alignment
- Channel calibration and gain control via command-line tools
- Tested on Raspberry Pi 4/5, Orange Pi 5B, and x86 platforms
- Command-line installation and configuration scripts

### Technical Specifications
- Frequency Range: 24 MHz to 1.766 GHz
- Channels: 5 coherent channels
- Sample Rate: Up to 2.4 MSPS per channel
- Coherent Bandwidth: Up to 2.4 MHz

### Installation Methods
1. **Command-Line Install Scripts**: Automated terminal-based installation
2. **Manual Build**: From source with make/cmake
3. **Package Installation**: APT/YUM packages where available

### Terminal Installation Commands
```bash
# Clone and build Heimdall DAQ
git clone https://github.com/krakenrf/heimdall_daq_fw.git
cd heimdall_daq_fw
mkdir build && cd build
cmake ..
make -j$(nproc)
sudo make install

# Install as system service
sudo cp ../scripts/heimdall-daq.service /etc/systemd/system/
sudo systemctl enable heimdall-daq
sudo systemctl start heimdall-daq
```

### Repository and Documentation
- **GitHub**: https://github.com/krakenrf/heimdall_daq_fw
- **CLI Documentation**: Command-line usage and configuration
- **Terminal Setup Guide**: Installation and configuration via CLI

## KrakenSDR DoA DSP

### Purpose
- Implements digital signal processing for Direction of Arrival (DoA)
- Processes acquired data for passive radar and multi-frequency analysis
- Core algorithms for all direction finding and spectrum analysis

### Key Features
- **Direction Finding Algorithms**:
  - MUSIC (Multiple Signal Classification)
  - Bartlett beamforming
  - Capon (MVDR) beamforming
  - MEMS-based algorithms
- **Multi-modal Processing**:
  - Direction finding
  - Passive radar
  - Beamforming and interferometry
  - Multi-frequency analysis
- **Operational Modes**:
  - Local processing
  - Remote operation via SSH
  - Distributed DAQ/DSP split
  - Command-line control and automation

### Scanning Methods Supported
1. **Wideband Scanning**: Rapid monitoring/spectrum sweep
2. **Multi-VFO Concurrent Scanning**: Multiple simultaneous channels
3. **Direction of Arrival Estimation**: Real-time bearing calculation
4. **Passive Radar**: Object/aircraft/drone detection
5. **Foxhound/Radio Fox Hunt**: Transmitter localization
6. **GSM/P25 Trunked System DF**: Digital system integration
7. **Asset/Beacon Tracking**: With external transmitters

### System Requirements
- **Minimum**: Raspberry Pi 4 (4GB RAM recommended)
- **Recommended**: Orange Pi 5B or modern x86 PC
- **For Passive Radar**: High-performance PC (resource-intensive)

### Terminal Installation and Configuration
```bash
# Clone and install DoA DSP
git clone https://github.com/krakenrf/krakensdr_doa.git
cd krakensdr_doa
pip3 install -r requirements.txt

# Configure via JSON files
cp settings.json.example settings.json
nano settings.json  # Edit configuration

# Run DoA processing
python3 kraken_doa_cli.py --config settings.json --mode max_utilization
```

### Repository and Documentation
- **GitHub**: https://github.com/krakenrf/krakensdr_doa
- **Installation**: Command-line scripts and package managers
- **Configuration**: JSON configuration files and CLI parameters

## Integration Architecture

### Modular Design
- DAQ and DSP can run on same device or be distributed
- Remote control capabilities for headless operation
- API endpoints for external integration
- Real-time data streaming capabilities

### Data Flow
1. **RF Input** → Heimdall DAQ (5 channels)
2. **Raw Samples** → DoA DSP Processing
3. **Processed Data** → CLI Output/Log Files/APIs
4. **Results** → Terminal Display/File Export/Elasticsearch integration

### Calibration Requirements
- **Phase Calibration**: Essential for coherent operation
- **Gain Calibration**: Per-channel amplitude matching
- **Array Geometry**: Precise antenna positioning
- **Temperature Compensation**: For long-term stability

## Performance Characteristics

### Real-time Capabilities
- Live spectrum analysis
- Real-time direction finding
- Concurrent multi-frequency monitoring
- Low-latency processing pipeline

### Accuracy Specifications
- **Direction Finding**: ±1-5° (depending on SNR and array geometry)
- **Frequency Resolution**: Down to 1 Hz
- **Dynamic Range**: >60 dB
- **Sensitivity**: Comparable to commercial DF systems

## Development and Customization

### CLI and API Access
- Command-line configuration tools
- JSON configuration files
- REST API for automation scripts
- File-based data output
- External integration via scripts and APIs

### Custom Algorithm Integration
- Plugin architecture for custom DSP
- GNU Radio block integration
- Python/C++ development support
- Real-time processing framework

## Troubleshooting and Optimization

### Common Issues
- USB bandwidth limitations
- Clock synchronization problems
- Thermal management
- Power supply requirements

### Performance Tuning
- Sample rate optimization
- Buffer size configuration
- CPU affinity settings
- Memory allocation tuning

## Terminal-Based Maximum Utilization Configuration

### Multi-VFO Configuration File
```json
{
  "max_utilization_mode": true,
  "vfo_config": {
    "vfo_1": {
      "frequency": 146520000,
      "bandwidth": 25000,
      "mode": "DF_CONTINUOUS",
      "algorithm": "MUSIC",
      "gain": 20
    },
    "vfo_2": {
      "frequency": 462675000,
      "bandwidth": 12500,
      "mode": "DF_SCAN",
      "algorithm": "Bartlett",
      "gain": 25
    },
    "vfo_3": {
      "frequency": 155340000,
      "bandwidth": 25000,
      "mode": "DF_PRIORITY",
      "algorithm": "Capon",
      "gain": 30
    },
    "vfo_4": {
      "frequency": 101500000,
      "bandwidth": 200000,
      "mode": "PASSIVE_RADAR_REF",
      "gain": 15
    },
    "vfo_5": {
      "frequency": "AUTO_SCAN",
      "bandwidth": 25000,
      "mode": "DISCOVERY",
      "algorithm": "MEMS",
      "gain": "AUTO"
    }
  },
  "processing": {
    "beamforming": true,
    "passive_radar": true,
    "signal_classification": true,
    "track_correlation": true
  },
  "output": {
    "elasticsearch": true,
    "file_logging": true,
    "real_time_stream": true
  }
}
```

### Command-Line Operation
```bash
# Start maximum utilization mode
kraken_doa_cli --config max_utilization.json --daemon

# Monitor all channels
kraken_monitor --all-channels --output terminal

# Control individual VFOs
kraken_vfo --vfo 1 --frequency 146.520e6 --algorithm MUSIC
kraken_vfo --vfo 2 --scan-mode priority --frequencies priority_list.txt

# Passive radar control
kraken_radar --illuminator FM_101.5 --surveillance-channels 2,3,4,5

# Export data
kraken_export --format elasticsearch --index kraken-data --real-time
```

## Next Steps for Implementation
1. Install via command-line scripts
2. Configure JSON settings files
3. Set up systemd services for daemon operation
4. Calibrate antenna array via CLI tools
5. Integrate with Elasticsearch via terminal scripts
