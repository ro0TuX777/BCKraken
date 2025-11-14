#!/bin/bash
#
# KrakenSDR System Dependencies Installation Script
# Installs ONLY system packages required for building and running KrakenSDR
#

set -e  # Exit on error

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}KrakenSDR System Dependencies Installer${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}Please do NOT run this script as root${NC}"
    echo "Run it as a normal user. It will ask for sudo password when needed."
    exit 1
fi

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VER=$VERSION_ID
else
    echo -e "${RED}Cannot detect OS. This script supports Ubuntu/Debian.${NC}"
    exit 1
fi

echo -e "${GREEN}Detected OS: $OS $VER${NC}"
echo ""

# Update package list
echo -e "${BLUE}=== Updating package list ===${NC}"
sudo apt-get update

# Install build tools
echo -e "${BLUE}=== Installing build tools ===${NC}"
sudo apt-get install -y \
    build-essential \
    cmake \
    git \
    clang

echo -e "${GREEN}✓ Build tools installed${NC}"
echo ""

# Install libraries
echo -e "${BLUE}=== Installing required libraries ===${NC}"
sudo apt-get install -y \
    libusb-1.0-0-dev \
    libzmq3-dev \
    libfftw3-dev

echo -e "${GREEN}✓ Libraries installed${NC}"
echo ""

# Install Python
echo -e "${BLUE}=== Installing Python ===${NC}"
sudo apt-get install -y \
    python3 \
    python3-venv \
    python3-pip

echo -e "${GREEN}✓ Python installed${NC}"
echo ""

# Install Node.js
echo -e "${BLUE}=== Installing Node.js ===${NC}"
if ! command -v node &> /dev/null; then
    sudo apt-get install -y nodejs npm
    echo -e "${GREEN}✓ Node.js installed${NC}"
else
    echo -e "${GREEN}✓ Node.js already installed${NC}"
fi
echo ""

# Install RTL-SDR udev rules (if librtlsdr is built)
echo -e "${BLUE}=== Configuring RTL-SDR ===${NC}"
KRAKEN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$KRAKEN_DIR/librtlsdr/rtl-sdr.rules" ]; then
    echo "Installing udev rules..."
    sudo cp "$KRAKEN_DIR/librtlsdr/rtl-sdr.rules" /etc/udev/rules.d/
    
    echo "Blacklisting default RTL-SDR kernel driver..."
    if ! grep -q "blacklist dvb_usb_rtl28xxu" /etc/modprobe.d/blacklist-dvb_usb_rtl28xxu.conf 2>/dev/null; then
        echo 'blacklist dvb_usb_rtl28xxu' | sudo tee /etc/modprobe.d/blacklist-dvb_usb_rtl28xxu.conf
    fi
    
    echo "Reloading udev rules..."
    sudo udevadm control --reload-rules
    sudo udevadm trigger
    
    echo -e "${GREEN}✓ RTL-SDR configured${NC}"
else
    echo -e "${YELLOW}⚠ librtlsdr not built yet. Run build_all.sh first, then re-run this script.${NC}"
fi
echo ""

# Set kernel parameter for real-time scheduling
echo -e "${BLUE}=== Configuring kernel parameters ===${NC}"
echo "Setting kernel.sched_rt_runtime_us=-1 (required for Heimdall DAQ)..."
sudo sysctl -w kernel.sched_rt_runtime_us=-1

# Make it persistent
if ! grep -q "kernel.sched_rt_runtime_us" /etc/sysctl.conf 2>/dev/null; then
    echo 'kernel.sched_rt_runtime_us=-1' | sudo tee -a /etc/sysctl.conf
fi

echo -e "${GREEN}✓ Kernel parameters configured${NC}"
echo ""

# Summary
echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}✓ System Dependencies Installed!${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""
echo "Installed packages:"
echo "  - build-essential (gcc, g++, make)"
echo "  - cmake"
echo "  - git"
echo "  - clang"
echo "  - libusb-1.0-0-dev"
echo "  - libzmq3-dev"
echo "  - libfftw3-dev"
echo "  - python3, python3-venv, python3-pip"
echo "  - nodejs, npm"
echo ""
echo "Next steps:"
echo "1. Run ./build_all.sh to build KrakenSDR components"
echo "2. Run ./test_installation.sh to verify installation"
echo ""
echo -e "${YELLOW}NOTE: You may need to reboot for RTL-SDR driver changes to take effect.${NC}"
echo ""

