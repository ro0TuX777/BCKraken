# BCKraken

**KrakenSDR RF Signal Analysis and Direction Finding Tool**

A comprehensive software suite for KrakenSDR hardware providing RF signal analysis, direction finding, passive radar, and spectrum monitoring capabilities with an intuitive terminal-based interface.

## 🚀 Features

- **Direction of Arrival (DoA)** - Precise RF signal direction finding
- **Passive Radar Detection** - Monitor and track aircraft and vehicles
- **Spectrum Analysis** - Real-time RF spectrum monitoring and analysis
- **Multi-VFO Control** - Simultaneous monitoring of multiple frequencies
- **Beamforming** - Advanced signal processing for enhanced detection
- **TDOA Analysis** - Time Difference of Arrival calculations
- **Live Data Streaming** - Real-time data visualization and monitoring
- **Desktop Integration** - Professional desktop icon and launcher
- **Comprehensive Logging** - Detailed system and operation logs
- **Web Interface** - Browser-based control and visualization

## 📋 Quick Start

### Prerequisites

- **Hardware**: KrakenSDR 5-channel coherent RTL-SDR
- **OS**: Ubuntu/Debian Linux (tested on Ubuntu 20.04+)
- **Python**: 3.8+ with pip
- **Dependencies**: RTL-SDR libraries, Node.js, various Python packages

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/ro0TuX777/BCKraken.git
   cd BCKraken
   ```

2. **Run the automated installation:**
   ```bash
   chmod +x install_system_deps.sh
   ./install_system_deps.sh
   ```

3. **Build all components:**
   ```bash
   chmod +x build_all.sh
   ./build_all.sh
   ```

4. **Verify installation:**
   ```bash
   ./test_installation.sh
   ```

### Quick Launch

**Terminal Interface:**
```bash
./kraken_menu
```

**Web Interface:**
```bash
./launch_kraken_web.sh
```

**Maximum Utilization Mode:**
```bash
./start_kraken_system.sh
```

## 🔧 Configuration

### Hardware Setup
- Connect KrakenSDR to USB 3.0 port
- Attach appropriate antennas to all 5 channels
- Ensure adequate power supply (2A+ recommended)

### Software Configuration
- **Frequency Settings**: Configure in `kraken_menu` → VFO Control
- **DoA Parameters**: Adjust in web interface settings
- **Logging**: Configure in `filebeat_kraken_simple.yml`

## 🖥️ Desktop Integration

Create desktop launcher:
```bash
./create-desktop-icon.sh
```

The application includes a professional desktop icon that launches the KrakenSDR Control Center with full terminal interface access.

## 📖 Documentation

- **Installation Guide**: `README_INSTALLATION.md`
- **View Logs**: `VIEW_LOGS.md`
- **Portability Plan**: `PORTABILITY_PLAN.md`
- **Desktop Icon Setup**: `DESKTOP_ICON_CREATION_GUIDE.md`

## 🛠️ Advanced Usage

### System Control Scripts
- `start_kraken_system.sh` - Launch full system
- `kill_all_kraken.sh` - Emergency stop all processes
- `verify_kraken.sh` - System health check
- `fix_permissions.sh` - Repair file permissions

### Data Analysis
- Real-time spectrum analysis
- Direction finding with bearing calculations
- Passive radar target tracking
- Multi-frequency monitoring
- Data export and logging

## 🤝 Contributing

Contributions and improvements are welcome. Please ensure:
- Code follows existing style conventions
- Documentation is updated for new features
- Testing is performed on target hardware

## 📄 License

This project is provided as-is for educational and research purposes.

## 🔗 Related Projects

- **KrakenSDR Hardware**: https://www.krakenrf.com/
- **RTL-SDR**: https://www.rtl-sdr.com/
- **GNU Radio**: https://www.gnuradio.org/

---

**Powered by RF Analysis Specialists**
