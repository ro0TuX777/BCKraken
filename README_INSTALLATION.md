# KrakenSDR Installation Guide - Portable Version

## Overview

This is a **portable** KrakenSDR installation that includes all dependencies within the `kraken-sdr/` directory. You can copy this entire directory to another machine and it will work after installing only system packages.

## What's Included

```
kraken-sdr/
├── librtlsdr/              # Custom RTL-SDR library (source + builds)
├── kfr/                    # KFR DSP library (source + builds)
├── heimdall_daq_fw/        # Heimdall DAQ firmware
├── krakensdr_doa/          # KrakenSDR DOA application
├── kraken_env/             # Python virtual environment
├── build_all.sh            # Build script
├── install_system_deps.sh  # System dependencies installer
└── test_installation.sh    # Installation verification
```

## Quick Start (New Machine)

### 1. Install System Dependencies

```bash
cd kraken-sdr
./install_system_deps.sh
```

This installs:
- build-essential, cmake, git, clang
- libusb-1.0-0-dev, libzmq3-dev, libfftw3-dev
- python3, python3-venv, python3-pip
- nodejs, npm

### 2. Build All Components

```bash
./build_all.sh
```

This builds:
- Custom librtlsdr library
- KFR DSP library
- Heimdall DAQ firmware
- Python environment with all packages
- Node.js dependencies

### 3. Verify Installation

```bash
./test_installation.sh
```

Should show 28+ tests passing.

### 4. Run KrakenSDR

```bash
cd krakensdr_doa/util
./kraken_doa_start.sh
```

Access web interface at: `http://localhost:8080`

## Hardware Requirements

### Minimum
- **CPU:** x86_64 or ARM (Raspberry Pi 4+)
- **RAM:** 4GB
- **USB:** 5x RTL-SDR dongles (for full KrakenSDR)
- **OS:** Ubuntu 20.04+ or Debian 11+

### Recommended
- **CPU:** x86_64 with AVX2 support
- **RAM:** 8GB
- **USB:** USB 3.0 hub for 5x RTL-SDR devices

## RTL-SDR Device Configuration

### Serial Numbers
KrakenSDR expects RTL-SDR devices with serial numbers:
- 1000 (reference channel)
- 1001, 1002, 1003, 1004 (measurement channels)

### Set Serial Numbers
```bash
# For each device (unplug others first)
rtl_eeprom -d 0 -s 1000
rtl_eeprom -d 0 -s 1001
# ... etc
```

### Verify Devices
```bash
rtl_test
```

Should show 5 devices with serials 1000-1004.

## Configuration

### Heimdall DAQ Configuration
Edit `heimdall_daq_fw/Firmware/daq_chain_config.ini`:

```ini
[daq]
center_freq = 700000000    # Center frequency in Hz
sample_rate = 2400000      # Sample rate in Hz
gain = 0                   # Gain (0 = auto)
```

### KrakenSDR DOA Configuration
Edit `krakensdr_doa/settings.json` (created on first run):
- Antenna array configuration
- DOA algorithm settings
- Web interface port

## Troubleshooting

### RTL-SDR Not Detected

**Problem:** `rtl_test` shows no devices

**Solution:**
```bash
# Reload udev rules
sudo udevadm control --reload-rules
sudo udevadm trigger

# Reboot if needed
sudo reboot
```

### Build Errors

**Problem:** KFR build fails

**Solution:**
```bash
# Install clang
sudo apt-get install clang

# Rebuild
cd kfr
rm -rf build
mkdir build && cd build
cmake -DENABLE_CAPI_BUILD=ON -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=Release ..
make -j$(nproc)
```

### Python Package Conflicts

**Problem:** Dash/Plotly version conflicts

**Solution:**
```bash
# Recreate virtual environment
rm -rf kraken_env
python3 -m venv kraken_env
source kraken_env/bin/activate
pip install scipy matplotlib pandas orjson requests pyargus
pip install dash werkzeug plotly quart quart_compress dash-bootstrap-components dash_devices
```

### Permission Errors

**Problem:** Cannot access RTL-SDR devices

**Solution:**
```bash
# Add user to plugdev group
sudo usermod -a -G plugdev $USER

# Logout and login again
```

## Portability Notes

### What's Portable
✅ All source code
✅ Python virtual environment
✅ Build scripts
✅ Configuration files

### What's NOT Portable
❌ Compiled binaries (architecture-specific)
❌ System packages
❌ udev rules (need sudo to install)

### Deploying to New Machine

1. **Copy entire rf-kit/ directory:**
   ```bash
   scp -r rf-kit/ user@newmachine:/home/user/
   ```

2. **On new machine:**
   ```bash
   cd rf-kit/kraken-sdr
   ./install_system_deps.sh
   ./build_all.sh
   ./test_installation.sh
   ```

3. **Done!** System is ready to use.

## Architecture Differences

### x86_64 (Desktop/Laptop)
- Uses KFR with AVX2 SIMD optimizations
- Faster DSP processing
- Recommended for development

### ARM (Raspberry Pi)
- Uses NE10 library instead of KFR
- Optimized for ARM NEON
- Lower power consumption

The build scripts automatically detect architecture and build accordingly.

## Performance Tuning

### Real-Time Scheduling
Heimdall DAQ requires real-time scheduling:
```bash
sudo sysctl -w kernel.sched_rt_runtime_us=-1
```

This is automatically set by `install_system_deps.sh`.

### CPU Affinity
For best performance, pin processes to specific CPU cores:
```bash
taskset -c 0-3 ./rtl_daq.out
```

### USB Buffer Size
Increase USB buffer size for stability:
```bash
echo 128 | sudo tee /sys/module/usbcore/parameters/usbfs_memory_mb
```

## Development

### Rebuilding After Changes

**Heimdall DAQ:**
```bash
cd heimdall_daq_fw/Firmware/_daq_core
make clean && make
```

**Python code:**
```bash
# No rebuild needed, just restart
```

**Node.js:**
```bash
cd krakensdr_doa/_nodejs
npm install
```

### Adding Python Packages
```bash
source kraken_env/bin/activate
pip install <package>
deactivate
```

## References

- **Official KrakenSDR:** https://github.com/krakenrf
- **Heimdall DAQ:** https://github.com/krakenrf/heimdall_daq_fw
- **KrakenSDR DOA:** https://github.com/krakenrf/krakensdr_doa
- **Documentation:** https://docs.krakenrf.com

## Support

For issues specific to this portable installation, check:
1. `test_installation.sh` output
2. `.context/logger.md` for detailed installation history
3. Build logs in each component's build directory

For KrakenSDR-specific issues, see official documentation.

