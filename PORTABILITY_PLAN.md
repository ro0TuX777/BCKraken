# KrakenSDR Portability Conversion Plan

## Goal
Make the entire KrakenSDR installation portable so that copying `rf-kit/` to another machine requires only installing system packages, not rebuilding everything.

## Current State

### External Dependencies (NOT portable)
```
/home/dragos/librtlsdr/          # Custom RTL-SDR library
/home/dragos/kfr/                # KFR DSP library
/usr/local/lib/libkfr_capi.so    # Installed KFR library
/usr/include/kfr/capi.h          # KFR header
```

### Inside rf-kit/ (Portable)
```
/home/dragos/rf-kit/kraken-sdr/
├── heimdall_daq_fw/             # DAQ firmware (binaries built)
├── krakensdr_doa/               # DOA application
├── kraken_env/                  # Python venv (portable)
├── kraken_data_logger.py        # Mock data generator
└── kraken_menu                  # Menu system
```

## Conversion Steps

### Step 1: Move External Dependencies into rf-kit/

```bash
# Move librtlsdr
mv /home/dragos/librtlsdr /home/dragos/rf-kit/kraken-sdr/

# Move kfr
mv /home/dragos/kfr /home/dragos/rf-kit/kraken-sdr/
```

**Result:**
```
/home/dragos/rf-kit/kraken-sdr/
├── librtlsdr/                   # Custom RTL-SDR library (source + build)
├── kfr/                         # KFR DSP library (source + build)
├── heimdall_daq_fw/
├── krakensdr_doa/
└── kraken_env/
```

### Step 2: Update Heimdall Makefile for Local Libraries

**File:** `heimdall_daq_fw/Firmware/_daq_core/Makefile`

**Changes needed:**
1. Update KFR library path to use local build
2. Ensure librtlsdr.a is copied from local build

**Before:**
```makefile
decimate_x86: sh_mem_util.c iq_header.c log.c ini.c fir_decimate.c
	$(CC) $(CFLAGS) -c fir_decimate.c -o fir_decimate.o
	$(CC) $(CFLAGS) fir_decimate.o sh_mem_util.o log.o ini.o iq_header.o -o decimate.out -lrt -lkfr_capi
```

**After:**
```makefile
KFR_LIB_PATH = ../../../../kfr/build/lib

decimate_x86: sh_mem_util.c iq_header.c log.c ini.c fir_decimate.c
	$(CC) $(CFLAGS) -c fir_decimate.c -o fir_decimate.o
	$(CC) $(CFLAGS) fir_decimate.o sh_mem_util.o log.o ini.o iq_header.o -o decimate.out -lrt -L$(KFR_LIB_PATH) -lkfr_capi -Wl,-rpath,$(KFR_LIB_PATH)
```

### Step 3: Create Build Script

**File:** `kraken-sdr/build_all.sh`

This script will:
1. Build librtlsdr
2. Build KFR
3. Copy libraries to heimdall_daq_fw
4. Build Heimdall DAQ

### Step 4: Create System Dependencies Installation Script

**File:** `kraken-sdr/install_system_deps.sh`

This script will install ONLY system packages:
- build-essential
- cmake
- git
- libusb-1.0-0-dev
- libzmq3-dev
- clang
- nodejs
- python3-venv

### Step 5: Update .gitignore

Add to `.gitignore`:
```
# Build artifacts
librtlsdr/build/
kfr/build/
heimdall_daq_fw/Firmware/_daq_core/*.o
heimdall_daq_fw/Firmware/_daq_core/*.out

# Python
kraken_env/
__pycache__/
*.pyc

# Node.js
krakensdr_doa/_nodejs/node_modules/

# Data
data/
*.log
```

### Step 6: Create Deployment README

**File:** `kraken-sdr/README.md`

Complete instructions for:
1. System requirements
2. Installation on new machine
3. Building from source
4. Running the system
5. Troubleshooting

## Verification Steps

After conversion, test portability:

1. **Backup current installation:**
   ```bash
   cp -r /home/dragos/rf-kit /tmp/rf-kit-backup
   ```

2. **Simulate fresh deployment:**
   ```bash
   # On same machine, different location
   cp -r /home/dragos/rf-kit /tmp/test-deployment
   cd /tmp/test-deployment/kraken-sdr
   ./install_system_deps.sh
   ./build_all.sh
   ./test_installation.sh
   ```

3. **Verify all tests pass**

4. **Test on different machine** (if available)

## Benefits of Portable Structure

✅ **Easy Deployment:** Copy rf-kit/ to any machine, run 2 scripts
✅ **Version Control:** All dependencies tracked in git
✅ **Reproducible:** Same build on any machine
✅ **Self-Contained:** No system-wide library pollution
✅ **Multiple Instances:** Can have multiple rf-kit/ installations
✅ **Offline Capable:** No internet needed after initial clone

## Estimated Time

- Step 1 (Move files): 1 minute
- Step 2 (Update Makefile): 5 minutes
- Step 3 (Build script): 10 minutes
- Step 4 (System deps script): 5 minutes
- Step 5 (Update .gitignore): 2 minutes
- Step 6 (README): 15 minutes
- Testing: 10 minutes

**Total: ~50 minutes**

## Next Actions

1. Execute Step 1 (move files)
2. Update Makefile
3. Create build scripts
4. Test everything
5. Document in logger.md

