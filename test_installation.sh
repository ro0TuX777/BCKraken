#!/bin/bash
#
# KrakenSDR Installation Test Script
# Tests all components to verify installation
#

echo "========================================="
echo "KrakenSDR Installation Test"
echo "========================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
PASS=0
FAIL=0

# Function to test command
test_command() {
    local name="$1"
    local cmd="$2"
    
    echo -n "Testing $name... "
    if eval "$cmd" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((PASS++))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        ((FAIL++))
        return 1
    fi
}

# Function to test file exists
test_file() {
    local name="$1"
    local file="$2"
    
    echo -n "Testing $name... "
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓ PASS${NC} ($file)"
        ((PASS++))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC} ($file not found)"
        ((FAIL++))
        return 1
    fi
}

echo "=== System Dependencies ==="
test_command "GCC compiler" "gcc --version"
test_command "CMake" "cmake --version"
test_command "libusb" "pkg-config --exists libusb-1.0"
test_command "libzmq" "pkg-config --exists libzmq"
test_command "Node.js" "node --version"
test_command "Clang" "clang++ --version"
echo ""

echo "=== Local Libraries (Portable) ==="
test_file "librtlsdr source" "librtlsdr/CMakeLists.txt"
test_file "librtlsdr binary" "librtlsdr/build/src/librtlsdr.a"
test_file "KFR source" "kfr/CMakeLists.txt"
test_file "KFR library" "kfr/build/lib/libkfr_capi.so"
echo ""

echo "=== Heimdall DAQ Firmware ==="
test_file "rtl_daq binary" "heimdall_daq_fw/Firmware/_daq_core/rtl_daq.out"
test_file "rebuffer binary" "heimdall_daq_fw/Firmware/_daq_core/rebuffer.out"
test_file "decimate binary" "heimdall_daq_fw/Firmware/_daq_core/decimate.out"
test_file "iq_server binary" "heimdall_daq_fw/Firmware/_daq_core/iq_server.out"
test_file "DAQ config" "heimdall_daq_fw/Firmware/daq_chain_config.ini"
test_file "DAQ start script" "heimdall_daq_fw/Firmware/daq_start_sm.sh"
echo ""

echo "=== KrakenSDR DOA Application ==="
test_file "DOA Python code" "krakensdr_doa/_sdr/__init__.py"
test_file "DOA web interface" "krakensdr_doa/_ui/__init__.py"
test_file "Node.js package" "krakensdr_doa/_nodejs/package.json"
test_file "Node modules" "krakensdr_doa/_nodejs/node_modules/socket.io/package.json"
test_file "GUI run script" "krakensdr_doa/gui_run.sh"
echo ""

echo "=== Python Environment ==="
if [ -d "kraken_env" ]; then
    source kraken_env/bin/activate
    
    test_command "Python version" "python --version"
    test_command "NumPy" "python -c 'import numpy'"
    test_command "SciPy" "python -c 'import scipy'"
    test_command "Matplotlib" "python -c 'import matplotlib'"
    test_command "Pandas" "python -c 'import pandas'"
    test_command "Dash" "python -c 'import dash'"
    test_command "Plotly" "python -c 'import plotly'"
    test_command "PyArgus" "python -c 'import pyargus'"
    
    deactivate
else
    echo -e "${RED}✗ FAIL${NC} (kraken_env not found)"
    ((FAIL+=8))
fi
echo ""

echo "=== RTL-SDR Hardware ==="
# Check if RTL-SDR devices are detected
if command -v rtl_test &> /dev/null; then
    echo -n "Detecting RTL-SDR devices... "
    DEVICE_COUNT=$(timeout 3 rtl_test -t 2>&1 | grep -c "Found.*device")
    if [ "$DEVICE_COUNT" -ge 5 ]; then
        echo -e "${GREEN}✓ PASS${NC} (Found $DEVICE_COUNT devices)"
        ((PASS++))
    elif [ "$DEVICE_COUNT" -gt 0 ]; then
        echo -e "${YELLOW}⚠ WARNING${NC} (Found $DEVICE_COUNT devices, need 5 for KrakenSDR)"
        ((PASS++))
    else
        echo -e "${RED}✗ FAIL${NC} (No devices found)"
        ((FAIL++))
    fi
else
    echo -e "${RED}✗ FAIL${NC} (rtl_test command not found)"
    ((FAIL++))
fi
echo ""

echo "========================================="
echo "Test Results:"
echo -e "${GREEN}Passed: $PASS${NC}"
echo -e "${RED}Failed: $FAIL${NC}"
echo "========================================="

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed! Installation is complete.${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠ Some tests failed. Review the output above.${NC}"
    exit 1
fi

