#!/bin/bash
#
# KrakenSDR Backend Verification Script
# Checks if all components are running correctly
#

KRAKEN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "═══════════════════════════════════════════════════════════"
echo "           KrakenSDR Backend Verification"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check 1: Heimdall DAQ processes
echo "1. Checking Heimdall DAQ processes..."
if pgrep -f "rtl_daq.out" > /dev/null; then
    echo -e "   ${GREEN}✓${NC} rtl_daq.out is running"
else
    echo -e "   ${RED}✗${NC} rtl_daq.out is NOT running"
fi

if pgrep -f "rebuffer.out" > /dev/null; then
    echo -e "   ${GREEN}✓${NC} rebuffer.out is running"
else
    echo -e "   ${RED}✗${NC} rebuffer.out is NOT running"
fi

if pgrep -f "iq_server.out" > /dev/null; then
    echo -e "   ${GREEN}✓${NC} iq_server.out is running"
else
    echo -e "   ${RED}✗${NC} iq_server.out is NOT running"
fi

echo ""

# Check 2: DOA web interface
echo "2. Checking KrakenSDR DOA web interface..."
if pgrep -f "app.py" > /dev/null; then
    echo -e "   ${GREEN}✓${NC} Web interface (app.py) is running"
else
    echo -e "   ${RED}✗${NC} Web interface is NOT running"
fi

echo ""

# Check 3: Web servers
echo "3. Checking web servers..."
if lsof -i :8080 > /dev/null 2>&1; then
    echo -e "   ${GREEN}✓${NC} Port 8080 (Main UI) is listening"
else
    echo -e "   ${RED}✗${NC} Port 8080 is NOT listening"
fi

if lsof -i :8081 > /dev/null 2>&1; then
    echo -e "   ${GREEN}✓${NC} Port 8081 (Data server) is listening"
else
    echo -e "   ${RED}✗${NC} Port 8081 is NOT listening"
fi

echo ""

# Check 4: HTTP response
echo "4. Checking HTTP responses..."
if curl -s -I http://localhost:8080 | grep -q "200\|302"; then
    echo -e "   ${GREEN}✓${NC} Main UI responds at http://localhost:8080"
else
    echo -e "   ${RED}✗${NC} Main UI not responding"
fi

if curl -s -I http://localhost:8081 | grep -q "200\|302\|404"; then
    echo -e "   ${GREEN}✓${NC} Data server responds at http://localhost:8081"
else
    echo -e "   ${RED}✗${NC} Data server not responding"
fi

echo ""

# Check 5: RTL-SDR hardware
echo "5. Checking RTL-SDR hardware..."
rtl_count=$(rtl_test 2>&1 | grep -c "Found")
if [ "$rtl_count" -gt 0 ]; then
    echo -e "   ${GREEN}✓${NC} RTL-SDR devices detected: $rtl_count"
    rtl_test 2>&1 | grep "Found" | head -5
else
    echo -e "   ${YELLOW}⚠${NC} No RTL-SDR devices detected (may be in use)"
fi

echo ""

# Check 6: Log files
echo "6. Checking log files..."
if [ -f "$KRAKEN_DIR/krakensdr_doa/_share/logs/krakensdr_doa/ui.log" ]; then
    echo -e "   ${GREEN}✓${NC} UI log exists"
    echo "   Last 3 lines:"
    tail -3 "$KRAKEN_DIR/krakensdr_doa/_share/logs/krakensdr_doa/ui.log" | sed 's/^/     /'
else
    echo -e "   ${YELLOW}⚠${NC} UI log not found yet"
fi

echo ""

# Check 7: Kernel parameters
echo "7. Checking kernel real-time parameters..."
rt_runtime=$(sysctl -n kernel.sched_rt_runtime_us 2>/dev/null)
if [ "$rt_runtime" = "-1" ]; then
    echo -e "   ${GREEN}✓${NC} Real-time scheduling enabled (kernel.sched_rt_runtime_us=-1)"
else
    echo -e "   ${YELLOW}⚠${NC} Real-time scheduling: $rt_runtime (expected: -1)"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "                    Summary"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "If all checks are green, KrakenSDR backend is running correctly."
echo "Access the web interface at: http://localhost:8080"
echo ""
echo "To view live logs:"
echo "  tail -f $KRAKEN_DIR/krakensdr_doa/_share/logs/krakensdr_doa/ui.log"
echo ""
echo "To stop KrakenSDR:"
echo "  cd $KRAKEN_DIR && ./kraken_max_util stop"
echo ""

