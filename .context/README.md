# KrakenSDR Complete Software Collection - Terminal Operation

## Overview
This directory contains a comprehensive collection of documentation for setting up and operating KrakenSDR via terminal/command-line interface ONLY. All operations are designed for maximum utilization through CLI scripts and automation, with Elasticsearch integration for data analysis.

## Quick Start - Terminal Only
1. **Read the [Software Collection Overview](software-collection-overview.md)** for complete ecosystem understanding
2. **Follow the [Terminal Installation Guide](installation-guide.md)** for command-line setup
3. **Use the [Button Interfaces](terminal-button-interfaces.md)** for easy menu-driven control
4. **Use the [Terminal Scripts](terminal-max-utilization-scripts.md)** for automation
5. **Review individual feature guides** for detailed CLI implementation

## Document Structure

### Core Documentation
- **[README.md](README.md)** - This file, master index and roadmap
- **[Software Collection Overview](software-collection-overview.md)** - Complete software ecosystem overview
- **[Installation Guide](installation-guide.md)** - Step-by-step installation instructions
- **[Comparison: Pluto vs KrakenSDR](comparison-pluto-vs-kraken.md)** - Integration analysis

### Feature-Specific Guides
- **[Core DAQ and DSP](feature-core-daq-dsp.md)** - Terminal-based DAQ and DSP operation
- **[Direction Finding](feature-direction-finding.md)** - CLI direction finding capabilities
- **[GNU Radio Integration](feature-gnu-radio-integration.md)** - Command-line GNU Radio applications
- **[Passive Radar](feature-passive-radar.md)** - Terminal-based aircraft and drone detection
- **[Terminal Scripts](terminal-max-utilization-scripts.md)** - Complete CLI automation scripts
- **[Button Interfaces](terminal-button-interfaces.md)** - **NEW** - Menu-driven button interfaces

## Implementation Roadmap

### Phase 1: Foundation (Week 1-2)
**Goal**: Basic KrakenSDR terminal operation and maximum utilization setup

**Tasks**:
1. **Hardware Setup**
   - Connect KrakenSDR to computing platform
   - Install antenna array (temporary setup for testing)
   - Verify power and USB connectivity

2. **Core Software Installation**
   - Install Heimdall DAQ firmware via CLI ([Installation Guide](installation-guide.md))
   - Install DoA DSP software with terminal interface
   - Configure JSON configuration files

3. **Initial Testing**
   - Verify 5-channel operation via CLI
   - Test basic direction finding through terminal
   - Confirm all VFOs operational

**Success Criteria**:
- [ ] `kraken_max_util status` shows all systems running
- [ ] All 5 VFOs processing signals simultaneously
- [ ] Terminal-based direction finding operational
- [ ] System stable for continuous operation

### Phase 2: Integration (Week 3-4)
**Goal**: Integrate with existing Elasticsearch infrastructure

**Tasks**:
1. **Elasticsearch Integration**
   - Set up data pipeline to Elasticsearch
   - Configure index templates for KrakenSDR data
   - Implement real-time data streaming

2. **GNU Radio Integration**
   - Install KrakenSDR GNU Radio block
   - Test multi-channel GNU Radio operation
   - Develop basic custom flowgraphs

3. **Data Format Unification**
   - Design unified schema for Pluto + KrakenSDR data
   - Implement data transformation scripts
   - Test data correlation and fusion

**Success Criteria**:
- [ ] KrakenSDR data flowing to Elasticsearch via CLI scripts
- [ ] Terminal queries showing direction finding data
- [ ] GNU Radio command-line integration operational
- [ ] All data streams unified in Elasticsearch

### Phase 3: Advanced Features (Week 5-6)
**Goal**: Enable advanced capabilities and maximum simultaneous utilization

**Tasks**:
1. **Direction Finding Optimization**
   - Calibrate antenna array via CLI tools
   - Optimize algorithms for your environment
   - Implement automated calibration scripts

2. **Maximum Utilization Setup**
   - Configure all 5 VFOs for simultaneous operation
   - Enable passive radar with direction finding
   - Set up automated scanning and classification

3. **Passive Radar Setup**
   - Configure passive radar processing via terminal
   - Test aircraft/drone detection through CLI
   - Optimize for local illumination sources

**Success Criteria**:
- [ ] Accurate direction finding (±5° or better) on all VFOs
- [ ] All scanning methods operational simultaneously
- [ ] Passive radar detecting aircraft via terminal output
- [ ] All data streams integrated in Elasticsearch

### Phase 4: Automation and Optimization (Week 7-8)
**Goal**: Automated operation and performance optimization

**Tasks**:
1. **Workflow Automation**
   - Develop automated scanning procedures
   - Implement alert systems
   - Create scheduled maintenance tasks

2. **Performance Optimization**
   - Optimize for real-time operation
   - Implement load balancing
   - Tune system parameters

3. **Advanced Analytics**
   - Develop custom Kibana dashboards
   - Implement machine learning for signal classification
   - Create automated reporting

**Success Criteria**:
- [ ] Fully automated operation
- [ ] Real-time performance maintained
- [ ] Advanced analytics operational
- [ ] System ready for production use

## Key Software Components

### Essential Downloads
1. **Heimdall DAQ Firmware**
   - Repository: https://github.com/krakenrf/heimdall_daq_fw
   - Purpose: Multi-channel data acquisition
   - Installation: See [Installation Guide](installation-guide.md)

2. **KrakenSDR DoA DSP**
   - Repository: https://github.com/krakenrf/krakensdr_doa
   - Purpose: Direction finding and signal processing
   - Installation: See [Core DAQ and DSP Guide](feature-core-daq-dsp.md)

3. **Android Direction Finding App**
   - Download: Google Play Store (search "KrakenSDR")
   - Purpose: Mobile direction finding and mapping
   - Setup: See [Mobile Integration Guide](feature-mobile-cloud-integration.md)

4. **GNU Radio Integration Block**
   - Repository: Part of krakensdr_doa
   - Purpose: Custom GNU Radio applications
   - Setup: See [GNU Radio Integration Guide](feature-gnu-radio-integration.md)

### Supporting Tools
1. **Array Calculator**: Google Spreadsheet for antenna geometry
2. **Calibration Tools**: Phase and amplitude calibration utilities
3. **Performance Monitors**: System health and accuracy tools
4. **Elasticsearch Integration**: Data pipeline and visualization

## Hardware Requirements

### Minimum Configuration
- **KrakenSDR**: 5-channel coherent SDR unit
- **Computing**: Raspberry Pi 4 (4GB RAM) or equivalent
- **Antennas**: 5 identical antennas for coherent array
- **Cables**: 5 matched coaxial cables
- **Power**: 5V/3A power supply for KrakenSDR

### Recommended Configuration
- **Computing**: Orange Pi 5B or x86 PC (for passive radar)
- **Storage**: NVMe SSD for high-speed data access
- **Network**: Gigabit Ethernet for data transfer
- **Timing**: GPS module for precise synchronization
- **Reference**: 10 MHz external reference oscillator

### Professional Configuration
- **Computing**: High-performance multi-core workstation
- **Storage**: RAID SSD array for redundancy
- **Network**: Dedicated network infrastructure
- **Timing**: GPS disciplined oscillator
- **Antennas**: Professional-grade antenna array

## Frequency Coverage Analysis

### KrakenSDR Coverage
- **Range**: 24 MHz to 1.766 GHz
- **Channels**: 5 coherent channels
- **Bandwidth**: Up to 2.4 MHz per channel
- **Applications**: Direction finding, passive radar, beamforming

### Pluto SDR Coverage (for comparison)
- **Range**: 325 MHz to 3.8 GHz
- **Channels**: 1 Tx, 1 Rx
- **Bandwidth**: Up to 56 MHz
- **Applications**: Wideband analysis, signal intelligence

### Combined Coverage Strategy
- **Low Frequencies (24-325 MHz)**: KrakenSDR only
- **Overlap (325 MHz-1.766 GHz)**: Both systems (complementary)
- **High Frequencies (1.766-3.8 GHz)**: Pluto SDR only

## Data Integration Strategy

### Elasticsearch Schema Design
```json
{
  "mappings": {
    "properties": {
      "timestamp": {"type": "date"},
      "device_type": {"type": "keyword"},
      "device_id": {"type": "keyword"},
      "frequency": {"type": "long"},
      "signal_data": {
        "properties": {
          "power": {"type": "float"},
          "bandwidth": {"type": "long"},
          "modulation": {"type": "keyword"}
        }
      },
      "direction_finding": {
        "properties": {
          "bearing": {"type": "float"},
          "confidence": {"type": "float"},
          "algorithm": {"type": "keyword"}
        }
      },
      "location": {
        "properties": {
          "receiver": {"type": "geo_point"},
          "transmitter": {"type": "geo_point"}
        }
      }
    }
  }
}
```

### Data Pipeline Architecture
```
KrakenSDR → DoA DSP → JSON → Elasticsearch → Kibana
                   ↓
              GNU Radio → Custom Processing → Elasticsearch
                   ↓
              Mobile App → GPS Data → Elasticsearch
```

## Troubleshooting Quick Reference

### Common Issues and Solutions

#### Installation Problems
- **USB Permission Errors**: Install udev rules, add user to dialout group
- **Dependency Issues**: Use virtual environments, check Python version
- **Build Failures**: Install development packages, check compiler version

#### Runtime Problems
- **High CPU Usage**: Reduce sample rate, optimize processing parameters
- **Network Issues**: Check firewall, verify port availability
- **Calibration Problems**: Verify antenna array geometry, check cable lengths

#### Performance Issues
- **Real-time Constraints**: Use dedicated cores, optimize scheduling
- **Memory Problems**: Increase swap, optimize buffer sizes
- **Storage Issues**: Use high-speed storage, implement data rotation

### Diagnostic Commands
```bash
# System status
systemctl status kraken-daq
systemctl status elasticsearch

# Hardware verification
lsusb | grep -i kraken
dmesg | grep -i kraken

# Network testing
curl http://localhost:8080/api/status
curl http://localhost:9200/_cluster/health

# Performance monitoring
htop
iostat -x 1
```

## Support and Resources

### Official Resources
- **KrakenRF Website**: https://www.krakenrf.com/
- **Documentation**: https://github.com/krakenrf/krakensdr_docs
- **Forums**: Community support and discussion
- **Discord**: Real-time chat support

### Community Resources
- **GitHub Issues**: Bug reports and feature requests
- **Reddit**: r/RTLSDR and related communities
- **YouTube**: Tutorial videos and demonstrations
- **Blogs**: Technical articles and case studies

### Professional Support
- **Commercial Support**: Available from KrakenRF
- **Consulting Services**: System integration and optimization
- **Training**: Workshops and certification programs
- **Custom Development**: Specialized applications and features

## Next Steps

1. **Start with Phase 1** of the implementation roadmap
2. **Follow the [Installation Guide](installation-guide.md)** for detailed setup instructions
3. **Review feature-specific guides** as you implement each component
4. **Join the community** for support and collaboration
5. **Document your experience** to help others

## Contributing

If you develop improvements, custom integrations, or find issues:
1. Document your changes and configurations
2. Share with the community through forums or GitHub
3. Consider contributing back to the open-source projects
4. Help others with similar implementations

---

**Note**: This documentation is based on the latest available information about KrakenSDR software and capabilities. Always refer to official repositories and documentation for the most current information.
