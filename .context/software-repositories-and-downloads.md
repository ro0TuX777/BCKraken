# KrakenSDR Software Repositories and Downloads

## Quick Reference for All Required Software

This document provides direct links and download instructions for all software components needed for a complete KrakenSDR implementation.

## Core KrakenSDR Software

### 1. Heimdall DAQ Firmware
**Primary data acquisition software**
- **GitHub Repository**: https://github.com/krakenrf/heimdall_daq_fw
- **Latest Release**: https://github.com/krakenrf/heimdall_daq_fw/releases/latest
- **Prebuilt Images**: 
  - Raspberry Pi: https://github.com/krakenrf/heimdall_daq_fw/releases/latest/download/kraken_rpi_image.img.xz
  - Orange Pi: Check releases for latest Orange Pi images
- **Clone Command**: 
  ```bash
  git clone https://github.com/krakenrf/heimdall_daq_fw.git
  ```

### 2. KrakenSDR DoA DSP
**Direction finding and signal processing**
- **GitHub Repository**: https://github.com/krakenrf/krakensdr_doa
- **Latest Release**: https://github.com/krakenrf/krakensdr_doa/releases/latest
- **Clone Command**:
  ```bash
  git clone https://github.com/krakenrf/krakensdr_doa.git
  ```
- **Dependencies**: Listed in requirements.txt
- **Documentation**: https://github.com/krakenrf/krakensdr_docs

### 3. KrakenSDR Documentation
**Complete documentation and guides**
- **GitHub Repository**: https://github.com/krakenrf/krakensdr_docs
- **Wiki**: https://github.com/krakenrf/krakensdr_docs/wiki
- **Clone Command**:
  ```bash
  git clone https://github.com/krakenrf/krakensdr_docs.git
  ```

## Mobile Applications

### Android Direction Finding App
- **Google Play Store**: Search "KrakenSDR Direction Finding"
- **Direct APK**: Available from KrakenRF website
- **Source Code**: Check KrakenRF GitHub organization
- **Requirements**: Android 7.0+ (API level 24+)

## Cloud Services

### KrakenSDR Pro Cloud Mapper
- **Website**: https://pro.krakenrf.com/
- **Account Registration**: https://pro.krakenrf.com/register
- **API Documentation**: Available after registration
- **Pricing**: Check website for current pricing

## Development Tools and Utilities

### Array Calculator and Templates
- **Google Spreadsheet**: https://docs.google.com/spreadsheets/d/[spreadsheet-id]
- **Printable Templates**: Available in krakensdr_docs repository
- **Custom Calculator**: Part of krakensdr_doa repository

### GNU Radio Integration
- **Source**: Part of krakensdr_doa repository
- **Location**: `krakensdr_doa/gnuradio/`
- **Installation**: Build from source (see installation guide)

## System Dependencies

### Linux Packages (Ubuntu/Debian)
```bash
# Essential build tools
sudo apt install -y git cmake build-essential pkg-config

# USB and hardware support
sudo apt install -y libusb-1.0-0-dev libudev-dev

# Python development
sudo apt install -y python3-dev python3-pip python3-venv

# Scientific computing
sudo apt install -y python3-numpy python3-scipy python3-matplotlib

# GNU Radio (if needed)
sudo apt install -y gnuradio gnuradio-dev

# Web development
sudo apt install -y nodejs npm

# Database support
sudo apt install -y elasticsearch kibana
```

### Python Packages
```bash
# Core scientific packages
pip3 install numpy scipy matplotlib

# Signal processing
pip3 install pyaudio sounddevice

# Web and networking
pip3 install flask websocket-client requests

# Database integration
pip3 install elasticsearch

# GUI development
pip3 install tkinter pyqt5

# Optional: Jupyter for development
pip3 install jupyter notebook
```

## Third-party Integrations

### Elasticsearch
- **Download**: https://www.elastic.co/downloads/elasticsearch
- **Documentation**: https://www.elastic.co/guide/en/elasticsearch/reference/current/
- **Docker Image**: `docker pull elasticsearch:7.17.0`

### Kibana
- **Download**: https://www.elastic.co/downloads/kibana
- **Documentation**: https://www.elastic.co/guide/en/kibana/current/
- **Docker Image**: `docker pull kibana:7.17.0`

### GNU Radio
- **Website**: https://www.gnuradio.org/
- **Installation**: https://wiki.gnuradio.org/index.php/InstallingGR
- **Source**: https://github.com/gnuradio/gnuradio

## Hardware Drivers and Firmware

### USB Drivers
- **Linux**: Usually included in kernel
- **Windows**: Available from KrakenRF website
- **macOS**: Limited support, check compatibility

### Firmware Updates
- **Location**: Part of heimdall_daq_fw repository
- **Update Process**: Documented in installation guide
- **Version Check**: Available through web interface

## Development Resources

### IDEs and Editors
- **Visual Studio Code**: https://code.visualstudio.com/
- **PyCharm**: https://www.jetbrains.com/pycharm/
- **GNU Radio Companion**: Part of GNU Radio installation
- **Jupyter Lab**: `pip3 install jupyterlab`

### Version Control
- **Git**: https://git-scm.com/
- **GitHub Desktop**: https://desktop.github.com/
- **GitKraken**: https://www.gitkraken.com/

### Testing and Debugging
- **pytest**: `pip3 install pytest`
- **gdb**: `sudo apt install gdb`
- **valgrind**: `sudo apt install valgrind`
- **wireshark**: `sudo apt install wireshark`

## Container and Virtualization

### Docker Images
```bash
# Official Elasticsearch
docker pull elasticsearch:7.17.0

# Official Kibana
docker pull kibana:7.17.0

# Ubuntu base for custom builds
docker pull ubuntu:20.04

# GNU Radio
docker pull gnuradio/gnuradio:latest
```

### Virtual Machines
- **VirtualBox**: https://www.virtualbox.org/
- **VMware**: https://www.vmware.com/
- **QEMU**: https://www.qemu.org/

## Quick Download Script

```bash
#!/bin/bash
# KrakenSDR Software Collection Download Script

# Create directory structure
mkdir -p ~/kraken-software
cd ~/kraken-software

# Clone core repositories
echo "Downloading core KrakenSDR software..."
git clone https://github.com/krakenrf/heimdall_daq_fw.git
git clone https://github.com/krakenrf/krakensdr_doa.git
git clone https://github.com/krakenrf/krakensdr_docs.git

# Download prebuilt images
echo "Downloading prebuilt images..."
mkdir -p images
cd images
wget https://github.com/krakenrf/heimdall_daq_fw/releases/latest/download/kraken_rpi_image.img.xz
cd ..

# Install Python dependencies
echo "Installing Python dependencies..."
pip3 install -r krakensdr_doa/requirements.txt

# Install system dependencies (Ubuntu/Debian)
echo "Installing system dependencies..."
sudo apt update
sudo apt install -y git cmake build-essential libusb-1.0-0-dev pkg-config
sudo apt install -y python3-dev python3-pip python3-numpy python3-scipy python3-matplotlib

echo "Download complete! Check ~/kraken-software directory"
echo "Next steps:"
echo "1. Follow the installation guide in .context/installation-guide.md"
echo "2. Flash the Raspberry Pi image or build from source"
echo "3. Configure your antenna array"
echo "4. Start with basic direction finding tests"
```

## Verification Commands

### Check Downloads
```bash
# Verify repositories
ls -la ~/kraken-software/
git -C ~/kraken-software/heimdall_daq_fw log --oneline -5
git -C ~/kraken-software/krakensdr_doa log --oneline -5

# Check Python packages
pip3 list | grep -E "(numpy|scipy|matplotlib|elasticsearch)"

# Verify system packages
dpkg -l | grep -E "(cmake|libusb|python3-dev)"
```

### Update Commands
```bash
# Update repositories
cd ~/kraken-software/heimdall_daq_fw && git pull
cd ~/kraken-software/krakensdr_doa && git pull
cd ~/kraken-software/krakensdr_docs && git pull

# Update Python packages
pip3 install --upgrade -r ~/kraken-software/krakensdr_doa/requirements.txt

# Update system packages
sudo apt update && sudo apt upgrade
```

## Backup and Archive

### Create Software Archive
```bash
# Create complete software archive
tar -czf kraken-software-$(date +%Y%m%d).tar.gz ~/kraken-software/

# Create configuration backup
tar -czf kraken-config-$(date +%Y%m%d).tar.gz /etc/kraken/ ~/.kraken/
```

### Restore from Archive
```bash
# Restore software
tar -xzf kraken-software-YYYYMMDD.tar.gz -C ~/

# Restore configuration
sudo tar -xzf kraken-config-YYYYMMDD.tar.gz -C /
```

## License Information

### Open Source Licenses
- **Heimdall DAQ**: GPL v3
- **KrakenSDR DoA**: GPL v3
- **Documentation**: Creative Commons
- **GNU Radio**: GPL v3

### Commercial Licenses
- **KrakenSDR Pro**: Commercial license required
- **Cloud Services**: Subscription-based
- **Support**: Commercial support available

## Support and Updates

### Getting Help
1. **Documentation**: Check krakensdr_docs repository
2. **Issues**: Report bugs on GitHub
3. **Forums**: Community discussion
4. **Discord**: Real-time chat support

### Staying Updated
1. **Watch repositories**: Enable GitHub notifications
2. **Mailing lists**: Subscribe to announcements
3. **Social media**: Follow @krakenrf
4. **Release notes**: Check for breaking changes

---

**Note**: Always verify checksums and signatures when downloading software from the internet. Use official repositories and trusted sources only.
