# KrakenSDR Passive Radar Capabilities

## Overview
KrakenSDR's passive radar functionality enables detection and tracking of aircraft, drones, and other moving objects using existing radio transmissions as illumination sources, without requiring dedicated radar transmitters.

## Passive Radar Principles

### Basic Concept
- **Illumination Sources**: Uses existing radio transmissions (FM, TV, cellular)
- **Bistatic Operation**: Separate transmitter and receiver locations
- **Target Detection**: Objects reflect and scatter radio signals
- **Doppler Processing**: Moving target indication through frequency shifts

### Advantages Over Active Radar
- **Covert Operation**: No transmitted signals to detect
- **Cost Effective**: Uses existing infrastructure
- **Wide Area Coverage**: Multiple illumination sources
- **Interference Resistant**: Diverse signal sources

### Technical Challenges
- **Signal Processing**: Complex algorithms for weak signal detection
- **Computational Requirements**: High-performance processing needed
- **Calibration**: Precise timing and phase alignment
- **Environmental Factors**: Multipath and interference management

## KrakenSDR Passive Radar Implementation

### Hardware Configuration
- **Reference Channel**: Direct signal from illumination source
- **Surveillance Channels**: Array of 4 channels for target detection
- **Coherent Operation**: Phase-locked channels for accurate processing
- **High Dynamic Range**: Handle strong direct signals and weak reflections

### Signal Processing Chain

#### Reference Signal Processing
- **Direct Path Cancellation**: Remove direct signal from surveillance channels
- **Adaptive Filtering**: Dynamic interference suppression
- **Signal Conditioning**: Optimize reference signal quality
- **Synchronization**: Maintain timing alignment

#### Surveillance Processing
- **Cross-correlation**: Compare surveillance and reference signals
- **Range Calculation**: Time delay measurement
- **Doppler Processing**: Frequency shift analysis
- **Target Detection**: Threshold-based detection algorithms

#### Advanced Processing
- **CFAR Detection**: Constant False Alarm Rate processing
- **Track Formation**: Connect detections over time
- **Multi-target Handling**: Simultaneous multiple target tracking
- **Clutter Suppression**: Ground clutter and interference rejection

### Supported Illumination Sources

#### FM Radio Stations
- **Frequency Range**: 88-108 MHz
- **Advantages**: Strong signals, wide coverage
- **Range Capability**: Up to 150+ km
- **Resolution**: Good range resolution

#### Digital TV (DVB-T)
- **Frequency Range**: VHF/UHF TV bands
- **Advantages**: High power, good coverage
- **Range Capability**: 100+ km
- **Resolution**: Excellent range and Doppler resolution

#### Cellular Base Stations
- **Frequency Range**: Various cellular bands
- **Advantages**: Dense network coverage
- **Range Capability**: 10-50 km
- **Resolution**: Good for urban environments

#### Other Sources
- **DAB Radio**: Digital audio broadcasting
- **WiFi**: Short-range applications
- **Satellite Signals**: GPS, communication satellites
- **Custom Transmitters**: Dedicated illumination sources

## System Performance

### Detection Capabilities

#### Aircraft Detection
- **Range**: Up to 200+ km (depending on illumination source)
- **Altitude**: Ground level to 40,000+ feet
- **Size**: Commercial aircraft to small general aviation
- **Velocity**: 50-1000+ km/h

#### Drone Detection
- **Range**: 1-20 km (depending on size and illumination)
- **Size**: Small consumer drones to large commercial UAVs
- **Velocity**: Hovering to 100+ km/h
- **Challenges**: Small radar cross-section

#### Other Targets
- **Vehicles**: Large trucks and cars on highways
- **Ships**: Maritime targets in coastal areas
- **Weather**: Precipitation and atmospheric phenomena
- **Birds**: Large flocks and individual large birds

### Accuracy and Resolution

#### Range Resolution
- **FM Radio**: ~1-3 km
- **DVB-T**: ~100-500 m
- **Cellular**: ~300-1000 m
- **Factors**: Signal bandwidth and processing

#### Doppler Resolution
- **Velocity Accuracy**: ±1-5 km/h
- **Minimum Detectable Velocity**: ~10 km/h
- **Factors**: Integration time and signal quality

#### Position Accuracy
- **Single Site**: Range and bearing only
- **Multi-site**: Triangulation for position
- **Accuracy**: 100m to several km depending on geometry

## Software Implementation

### Core Processing Software
- **Repository**: https://github.com/krakenrf/krakensdr_doa
- **Integration**: Part of main KrakenSDR software suite
- **Requirements**: High-performance PC recommended
- **Languages**: Python, C++ for performance-critical sections

### Processing Algorithms

#### Cross-correlation Processing
```python
# Simplified passive radar processing
def passive_radar_processing(reference, surveillance):
    # Cross-correlation for range-Doppler map
    range_doppler_map = np.zeros((range_bins, doppler_bins))
    
    for doppler_bin in range(doppler_bins):
        # Apply Doppler shift to reference
        shifted_ref = apply_doppler_shift(reference, doppler_bin)
        
        # Cross-correlate with surveillance
        correlation = np.correlate(surveillance, shifted_ref, mode='full')
        range_doppler_map[:, doppler_bin] = correlation
    
    return range_doppler_map
```

#### Target Detection
- **CFAR Processing**: Adaptive threshold detection
- **Peak Detection**: Local maxima identification
- **Track Association**: Connect detections over time
- **False Alarm Mitigation**: Reduce spurious detections

#### Performance Optimization
- **GPU Acceleration**: CUDA/OpenCL for FFT operations
- **Parallel Processing**: Multi-core CPU utilization
- **Memory Management**: Efficient buffer handling
- **Real-time Operation**: Optimized for live processing

### Configuration Parameters

#### Signal Processing
- **Integration Time**: 1-10 seconds typical
- **Range Gates**: 100-1000 range bins
- **Doppler Bins**: 64-512 frequency bins
- **Threshold Settings**: Detection sensitivity

#### Hardware Settings
- **Sample Rate**: 2.4 MSPS typical
- **Gain Settings**: Optimize for dynamic range
- **Frequency**: Match illumination source
- **Antenna Configuration**: Optimize for coverage

## Deployment Considerations

### Site Selection
- **Illumination Coverage**: Strong illumination signals
- **Target Area**: Expected target locations
- **Interference**: Minimize local interference
- **Infrastructure**: Power and network connectivity

### Antenna Configuration
- **Reference Antenna**: High-gain directional toward transmitter
- **Surveillance Array**: Wide coverage for target area
- **Separation**: Adequate baseline for resolution
- **Height**: Optimize for coverage and multipath

### Environmental Factors
- **Terrain**: Hills and buildings affect coverage
- **Weather**: Atmospheric effects on propagation
- **Interference**: Local RF environment
- **Multipath**: Reflections from buildings and terrain

## Integration with KrakenSDR Ecosystem

### Web Interface Integration
- **Real-time Display**: Range-Doppler maps and tracks
- **Configuration**: Parameter adjustment through web UI
- **Monitoring**: Performance and status indicators
- **Data Export**: Track data and raw measurements

### GNU Radio Integration
- **Custom Processing**: Advanced algorithm development
- **Real-time Operation**: Live GNU Radio flowgraphs
- **Research Applications**: Algorithm testing and development
- **Performance Optimization**: Efficient implementations

### Data Export and Analysis

#### Elasticsearch Integration
```json
{
  "timestamp": "2024-01-01T12:00:00Z",
  "target_id": "track_001",
  "detection": {
    "range": 25.5,
    "bearing": 45.0,
    "velocity": 250.0,
    "rcs": -20.0
  },
  "illumination": {
    "source": "FM_101.5",
    "frequency": 101500000,
    "power": 50000
  },
  "quality": {
    "snr": 15.2,
    "confidence": 0.85
  }
}
```

#### Visualization
- **Kibana Dashboards**: Real-time track display
- **Geographic Plots**: Target positions on maps
- **Performance Metrics**: Detection statistics
- **Historical Analysis**: Track playback and analysis

## Advanced Features

### Multi-static Operation
- **Multiple Sites**: Coordinated passive radar network
- **Data Fusion**: Combined measurements for improved accuracy
- **Coverage Enhancement**: Fill coverage gaps
- **Redundancy**: Improved reliability and availability

### Machine Learning Integration
- **Target Classification**: Automatic target type identification
- **Clutter Rejection**: AI-based interference suppression
- **Performance Optimization**: Adaptive parameter tuning
- **Anomaly Detection**: Unusual target behavior identification

### Real-time Alerting
- **Threshold Monitoring**: Automatic alert generation
- **Integration**: External systems and databases
- **Notification**: Email, SMS, and API notifications
- **Escalation**: Tiered alert procedures

## Performance Optimization

### Computational Requirements
- **CPU**: Multi-core processor (8+ cores recommended)
- **Memory**: 16+ GB RAM for real-time operation
- **Storage**: SSD for high-speed data access
- **GPU**: Optional for acceleration

### Real-time Processing
- **Latency**: Minimize processing delays
- **Throughput**: Handle continuous data streams
- **Reliability**: Robust operation under load
- **Scalability**: Handle increasing data rates

### System Tuning
- **Buffer Sizes**: Optimize for latency vs. throughput
- **Thread Allocation**: Efficient CPU utilization
- **Memory Management**: Prevent memory leaks
- **I/O Optimization**: Efficient data handling

## Troubleshooting and Maintenance

### Common Issues
- **Weak Illumination**: Poor reference signal quality
- **High Clutter**: Ground clutter and interference
- **Calibration Drift**: Phase and timing errors
- **Performance Degradation**: System overload

### Diagnostic Tools
- **Signal Quality Monitoring**: Reference and surveillance signal health
- **Performance Metrics**: Processing load and timing
- **Calibration Verification**: Phase and timing checks
- **Environmental Monitoring**: Interference and propagation conditions

## Next Steps for Implementation
1. Assess illumination sources in target area
2. Design antenna configuration for passive radar
3. Install and configure processing software
4. Calibrate system for optimal performance
5. Integrate with Elasticsearch data pipeline
6. Develop custom analysis and alerting
7. Optimize for real-time operation
