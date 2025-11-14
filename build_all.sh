#!/bin/bash
#
# KrakenSDR Build Script - Portable Installation
# Builds all components from source using local dependencies
#

set -e  # Exit on error

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}KrakenSDR Portable Build Script${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

# Get the absolute path of kraken-sdr directory
KRAKEN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo -e "${GREEN}Build directory: $KRAKEN_DIR${NC}"
echo ""

# Step 1: Build librtlsdr
echo -e "${BLUE}=== Step 1: Building librtlsdr ===${NC}"
cd "$KRAKEN_DIR/librtlsdr"

# Check if already built
if [ -f "build/src/librtlsdr.a" ]; then
    echo -e "${GREEN}✓ librtlsdr already built (skipping - use --rebuild to force)${NC}"
else
    if [ ! -d "build" ]; then
        mkdir build
    fi

    cd build
    cmake ../ -DINSTALL_UDEV_RULES=ON
    make -j$(nproc)

    echo -e "${GREEN}✓ librtlsdr built successfully${NC}"
fi
echo ""

# Step 2: Build KFR
echo -e "${BLUE}=== Step 2: Building KFR DSP Library ===${NC}"
cd "$KRAKEN_DIR/kfr"

# Check if already built
if [ -f "build/lib/libkfr_capi.so" ]; then
    echo -e "${GREEN}✓ KFR already built (skipping - use --rebuild to force)${NC}"
else
    if [ ! -d "build" ]; then
        mkdir build
    fi

    cd build

    # Check architecture
    ARCH=$(uname -m)
    if [ "$ARCH" = "x86_64" ]; then
        echo "Building for x86_64 with SIMD optimizations (this takes 3-4 minutes)..."
        cmake -DENABLE_CAPI_BUILD=ON -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=Release ..
    else
        echo "Building for ARM..."
        cmake -DENABLE_CAPI_BUILD=ON -DCMAKE_BUILD_TYPE=Release ..
    fi

    make -j$(nproc)

    echo -e "${GREEN}✓ KFR built successfully${NC}"
fi
echo ""

# Step 3: Copy libraries to Heimdall _daq_core
echo -e "${BLUE}=== Step 3: Copying libraries to Heimdall ===${NC}"
cd "$KRAKEN_DIR/heimdall_daq_fw/Firmware/_daq_core"

# Copy librtlsdr
cp "$KRAKEN_DIR/librtlsdr/build/src/librtlsdr.a" .
cp "$KRAKEN_DIR/librtlsdr/include/rtl-sdr.h" .
cp "$KRAKEN_DIR/librtlsdr/include/rtl-sdr_export.h" .

echo -e "${GREEN}✓ Libraries copied${NC}"
echo ""

# Step 4: Build Heimdall DAQ
echo -e "${BLUE}=== Step 4: Building Heimdall DAQ ===${NC}"
cd "$KRAKEN_DIR/heimdall_daq_fw/Firmware/_daq_core"

make clean
make

echo -e "${GREEN}✓ Heimdall DAQ built successfully${NC}"
echo ""

# Step 5: Verify binaries
echo -e "${BLUE}=== Step 5: Verifying binaries ===${NC}"
cd "$KRAKEN_DIR/heimdall_daq_fw/Firmware/_daq_core"

if [ -f "rtl_daq.out" ] && [ -f "rebuffer.out" ] && [ -f "decimate.out" ] && [ -f "iq_server.out" ]; then
    echo -e "${GREEN}✓ All binaries present:${NC}"
    ls -lh *.out
else
    echo -e "${YELLOW}⚠ Some binaries missing!${NC}"
    ls -lh *.out 2>/dev/null || echo "No binaries found"
fi
echo ""

# Step 6: Install Python dependencies
echo -e "${BLUE}=== Step 6: Installing Python dependencies ===${NC}"
cd "$KRAKEN_DIR"

if [ ! -d "kraken_env" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv kraken_env
fi

source kraken_env/bin/activate

echo "Installing Python packages..."
pip install --quiet scipy matplotlib pandas orjson requests pyargus
pip install --quiet dash werkzeug plotly quart quart_compress dash-bootstrap-components dash_devices

echo -e "${GREEN}✓ Python dependencies installed${NC}"
deactivate
echo ""

# Step 7: Install Node.js dependencies
echo -e "${BLUE}=== Step 7: Installing Node.js dependencies ===${NC}"
cd "$KRAKEN_DIR/krakensdr_doa/_nodejs"

if [ ! -d "node_modules" ]; then
    npm install --silent
    echo -e "${GREEN}✓ Node.js dependencies installed${NC}"
else
    echo -e "${GREEN}✓ Node.js dependencies already installed${NC}"
fi
echo ""

# Summary
echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}✓ Build Complete!${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""
echo "Next steps:"
echo "1. Run ./test_installation.sh to verify"
echo "2. Configure heimdall_daq_fw/Firmware/daq_chain_config.ini"
echo "3. Start the system with krakensdr_doa/util/kraken_doa_start.sh"
echo ""

