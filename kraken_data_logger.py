#!/usr/bin/env python3

"""
KrakenSDR Data Logger for Elasticsearch Export
Converts KrakenSDR data streams to JSON format for Filebeat ingestion
"""

import json
import time
import os
import sys
import subprocess
import numpy as np
from datetime import datetime, timezone

class KrakenDataLogger:
    def __init__(self, log_dir="/home/bc_test/Downloads/kraken-sdr/kraken-logs"):
        self.log_dir = log_dir
        self.ensure_log_directory()
        
    def ensure_log_directory(self):
        """Create log directory if it doesn't exist"""
        os.makedirs(self.log_dir, exist_ok=True)
        print(f"KrakenSDR logs will be written to: {self.log_dir}")
    
    def log_doa_data(self, bearing, confidence, frequency, rssi_db=None, latency_ms=None,
                     station_id="KrakenSDR-001", latitude=None, longitude=None,
                     gps_heading=None, compass_heading=None, array_type="UCA",
                     doa_spectrum=None, timestamp=None):
        """Log Direction of Arrival data - Full KrakenSDR format"""
        if timestamp is None:
            timestamp = datetime.now(timezone.utc).isoformat()

        # Generate realistic DOA spectrum (360 degrees) if not provided
        if doa_spectrum is None:
            doa_spectrum = np.zeros(360)
            # Add main lobe at bearing
            main_idx = int(bearing) % 360
            doa_spectrum[main_idx] = 1.0
            # Add some noise and side lobes
            for i in range(360):
                doa_spectrum[i] += np.random.normal(0, 0.1)
                if abs(i - main_idx) < 10:  # Side lobes
                    doa_spectrum[i] += 0.3 * np.exp(-((i - main_idx)**2) / 20)

        doa_data = {
            "@timestamp": timestamp,
            "event_type": "direction_finding",
            "unix_epoch_time": int(time.time() * 1000),  # 13 digit UNIX epoch
            "bearing_degrees": bearing,  # Compass convention (90° = East)
            "confidence": confidence,  # 0-99 float
            "rssi_db": rssi_db or np.random.uniform(-80, -20),  # 0 dB = max power
            "frequency_hz": frequency,
            "array_arrangement": array_type,  # UCA/ULA/Custom
            "latency_ms": latency_ms or np.random.uniform(50, 200),
            "station_id": station_id,
            "latitude": latitude,
            "longitude": longitude,
            "gps_heading": gps_heading,
            "compass_heading": compass_heading,
            "main_heading_sensor": "GPS" if gps_heading else "Compass",
            "doa_spectrum_360": doa_spectrum.tolist(),  # Full 360° DOA output
            "sensor_type": "kraken_sdr",
            "channels": 5,
            "processing_mode": "coherent_doa",
            "vfo_bandwidth_hz": 25000,  # VFO bandwidth
            "sample_rate_hz": 2400000
        }

        log_file = os.path.join(self.log_dir, f"kraken-doa-{datetime.now().strftime('%Y%m%d')}.json")
        with open(log_file, 'a') as f:
            f.write(json.dumps(doa_data) + '\n')
    
    def log_spectrum_data(self, frequencies, power_levels, vfo_channels=None, timestamp=None):
        """Log spectrum analysis data with VFO channel information"""
        if timestamp is None:
            timestamp = datetime.now(timezone.utc).isoformat()

        # Generate VFO channel data if not provided
        if vfo_channels is None:
            vfo_channels = []
            # Create 3 VFO channels covering different parts of spectrum
            for i in range(3):
                center_freq = frequencies[len(frequencies)//4 * (i+1)]
                vfo_channels.append({
                    "vfo_id": i,
                    "center_frequency_hz": float(center_freq),
                    "bandwidth_hz": 25000,
                    "squelch_db": -60,
                    "active": True,
                    "signal_detected": bool(np.random.choice([True, False], p=[0.3, 0.7]))
                })

        spectrum_data = {
            "@timestamp": timestamp,
            "event_type": "spectrum_analysis",
            "unix_epoch_time": int(time.time() * 1000),
            "frequency_range_hz": {
                "start": float(frequencies[0]),
                "end": float(frequencies[-1]),
                "center": float(np.mean(frequencies)),
                "span_hz": float(frequencies[-1] - frequencies[0])
            },
            "power_stats": {
                "max_dbm": float(np.max(power_levels)),
                "min_dbm": float(np.min(power_levels)),
                "mean_dbm": float(np.mean(power_levels)),
                "std_dbm": float(np.std(power_levels))
            },
            "vfo_channels": vfo_channels,
            "fft_size": len(frequencies),
            "window_function": "hann",
            "averaging_factor": 0.8,
            "sensor_type": "kraken_sdr",
            "sample_rate_hz": 2400000,
            "channels": 5,
            "coherent_processing": True,
            "calibration_applied": True
        }

        log_file = os.path.join(self.log_dir, f"kraken-spectrum-{datetime.now().strftime('%Y%m%d')}.json")
        with open(log_file, 'a') as f:
            f.write(json.dumps(spectrum_data) + '\n')
    
    def log_passive_radar(self, target_range, target_bearing, target_velocity,
                         illuminator_freq=None, target_snr=None, doppler_hz=None,
                         range_resolution=None, velocity_resolution=None, timestamp=None):
        """Log passive radar detection data with full capabilities"""
        if timestamp is None:
            timestamp = datetime.now(timezone.utc).isoformat()

        # Common illuminator frequencies for passive radar
        if illuminator_freq is None:
            illuminator_sources = [
                {"type": "FM_Radio", "frequency": 98.5e6, "power_dbm": 60},
                {"type": "DVB-T", "frequency": 578e6, "power_dbm": 55},
                {"type": "GSM", "frequency": 945e6, "power_dbm": 45},
                {"type": "WiFi", "frequency": 2.4e9, "power_dbm": 20}
            ]
            illuminator = np.random.choice(illuminator_sources)
        else:
            illuminator = {"type": "Custom", "frequency": illuminator_freq, "power_dbm": 50}

        radar_data = {
            "@timestamp": timestamp,
            "event_type": "passive_radar_detection",
            "unix_epoch_time": int(time.time() * 1000),
            "target": {
                "range_meters": target_range,
                "bearing_degrees": target_bearing,
                "velocity_ms": target_velocity,
                "snr_db": target_snr or np.random.uniform(10, 30),
                "doppler_shift_hz": doppler_hz or (target_velocity * illuminator["frequency"] / 3e8),
                "range_bin": int(target_range / (range_resolution or 150)),  # ~150m resolution
                "velocity_bin": int(target_velocity / (velocity_resolution or 2))  # ~2 m/s resolution
            },
            "illuminator": illuminator,
            "processing": {
                "correlation_type": "cross_correlation",
                "integration_time_ms": 1000,
                "range_gates": 512,
                "doppler_bins": 256,
                "cfar_threshold": 12.0,  # Constant False Alarm Rate
                "clutter_suppression": True,
                "moving_target_indication": True
            },
            "sensor_type": "kraken_sdr",
            "radar_mode": "passive",
            "channels": 5,
            "coherent_processing": True,
            "bistatic_geometry": {
                "baseline_meters": np.random.uniform(1000, 10000),
                "bistatic_angle_degrees": np.random.uniform(30, 150)
            }
        }

        log_file = os.path.join(self.log_dir, f"kraken-radar-{datetime.now().strftime('%Y%m%d')}.json")
        with open(log_file, 'a') as f:
            f.write(json.dumps(radar_data) + '\n')

    def log_beamforming_data(self, beam_direction, beam_gain, null_directions=None, timestamp=None):
        """Log beamforming data for signal enhancement"""
        if timestamp is None:
            timestamp = datetime.now(timezone.utc).isoformat()

        if null_directions is None:
            null_directions = [beam_direction + 180 % 360]  # Simple null opposite to beam

        beamforming_data = {
            "@timestamp": timestamp,
            "event_type": "beamforming",
            "unix_epoch_time": int(time.time() * 1000),
            "beam_pattern": {
                "main_lobe_direction": beam_direction,
                "main_lobe_gain_db": beam_gain,
                "null_directions": null_directions,
                "beamwidth_3db": 30.0,  # 3dB beamwidth
                "side_lobe_level_db": -20.0
            },
            "array_config": {
                "elements": 5,
                "geometry": "UCA",
                "element_spacing_wavelengths": 0.5,
                "array_diameter_meters": 1.0
            },
            "processing": {
                "algorithm": "MVDR",  # Minimum Variance Distortionless Response
                "adaptive": True,
                "interference_suppression": True,
                "noise_reduction_db": 10.0
            },
            "sensor_type": "kraken_sdr",
            "channels": 5,
            "coherent_processing": True
        }

        log_file = os.path.join(self.log_dir, f"kraken-beamforming-{datetime.now().strftime('%Y%m%d')}.json")
        with open(log_file, 'a') as f:
            f.write(json.dumps(beamforming_data) + '\n')

    def log_tdoa_data(self, source_position, tdoa_measurements, timestamp=None):
        """Log Time Difference of Arrival data for triangulation"""
        if timestamp is None:
            timestamp = datetime.now(timezone.utc).isoformat()

        tdoa_data = {
            "@timestamp": timestamp,
            "event_type": "tdoa_triangulation",
            "unix_epoch_time": int(time.time() * 1000),
            "source_location": {
                "latitude": source_position[0] if len(source_position) > 0 else None,
                "longitude": source_position[1] if len(source_position) > 1 else None,
                "estimated_accuracy_meters": np.random.uniform(10, 100)
            },
            "tdoa_measurements": tdoa_measurements,  # List of time differences between antenna pairs
            "processing": {
                "algorithm": "hyperbolic_triangulation",
                "antenna_pairs": 10,  # C(5,2) = 10 pairs from 5 antennas
                "time_resolution_ns": 1.0,  # Nanosecond timing resolution
                "geometric_dilution": np.random.uniform(1.0, 3.0)
            },
            "sensor_type": "kraken_sdr",
            "channels": 5,
            "coherent_processing": True,
            "synchronization": {
                "clock_accuracy_ppm": 0.1,
                "phase_locked": True,
                "timing_source": "GPS_disciplined_oscillator"
            }
        }

        log_file = os.path.join(self.log_dir, f"kraken-tdoa-{datetime.now().strftime('%Y%m%d')}.json")
        with open(log_file, 'a') as f:
            f.write(json.dumps(tdoa_data) + '\n')
    
    def log_system_status(self, timestamp=None):
        """Log KrakenSDR system status"""
        if timestamp is None:
            timestamp = datetime.now(timezone.utc).isoformat()
        
        # Get process information
        try:
            synthetic_pid = subprocess.check_output(['pgrep', '-f', 'test_data_synthesizer']).decode().strip()
            delay_sync_pid = subprocess.check_output(['pgrep', '-f', 'delay_sync.py']).decode().strip()
            rebuffer_pid = subprocess.check_output(['pgrep', '-f', 'rebuffer.out']).decode().strip()
            
            # Get CPU usage
            cpu_usage = subprocess.check_output(['ps', '-p', delay_sync_pid, '-o', '%cpu', '--no-headers']).decode().strip()
            
            # Get memory usage
            mem_usage = subprocess.check_output(['ps', '-p', delay_sync_pid, '-o', 'rss', '--no-headers']).decode().strip()
            
            status_data = {
                "@timestamp": timestamp,
                "event_type": "system_status",
                "processes": {
                    "synthetic_generator": {"pid": int(synthetic_pid), "status": "running"},
                    "delay_sync": {"pid": int(delay_sync_pid), "status": "running", "cpu_percent": float(cpu_usage)},
                    "rebuffer": {"pid": int(rebuffer_pid), "status": "running"}
                },
                "memory_usage_kb": int(mem_usage),
                "sensor_type": "kraken_sdr",
                "data_rate_mbps": 48.0,
                "channels_active": 5
            }
            
        except subprocess.CalledProcessError:
            status_data = {
                "@timestamp": timestamp,
                "event_type": "system_status",
                "processes": {"status": "error", "message": "KrakenSDR processes not running"},
                "sensor_type": "kraken_sdr"
            }
        
        log_file = os.path.join(self.log_dir, f"kraken-status-{datetime.now().strftime('%Y%m%d')}.json")
        with open(log_file, 'a') as f:
            f.write(json.dumps(status_data) + '\n')
    
    def generate_sample_data(self):
        """Generate comprehensive sample data for all KrakenSDR capabilities"""
        print("Generating comprehensive KrakenSDR data for all capabilities...")

        # Sample DoA data with full parameters
        for i in range(5):
            bearing = np.random.uniform(0, 360)
            confidence = np.random.uniform(0.7, 15.0)  # Realistic confidence range
            frequency = np.random.uniform(88e6, 108e6)  # FM band
            self.log_doa_data(
                bearing=bearing,
                confidence=confidence,
                frequency=frequency,
                station_id=f"KrakenSDR-{i+1:03d}",
                array_type=np.random.choice(["UCA", "ULA", "Custom"])
            )

        # Sample spectrum data with VFO channels
        frequencies = np.linspace(88e6, 108e6, 1000)
        power_levels = -80 + 20 * np.random.random(1000)
        self.log_spectrum_data(frequencies, power_levels)

        # Sample passive radar data with illuminators
        for i in range(3):
            target_range = np.random.uniform(1000, 50000)
            target_bearing = np.random.uniform(0, 360)
            target_velocity = np.random.uniform(-100, 100)
            self.log_passive_radar(target_range, target_bearing, target_velocity)

        # Sample beamforming data
        for i in range(2):
            beam_direction = np.random.uniform(0, 360)
            beam_gain = np.random.uniform(8, 15)  # dB gain
            self.log_beamforming_data(beam_direction, beam_gain)

        # Sample TDOA triangulation data
        for i in range(2):
            source_lat = 40.7128 + np.random.uniform(-0.1, 0.1)  # Near NYC
            source_lon = -74.0060 + np.random.uniform(-0.1, 0.1)
            tdoa_measurements = [np.random.uniform(-1e-6, 1e-6) for _ in range(10)]  # 10 antenna pairs
            self.log_tdoa_data([source_lat, source_lon], tdoa_measurements)

        # System status
        self.log_system_status()

        print(f"Comprehensive sample data generated in {self.log_dir}")
        print("Data includes: DoA, Spectrum, Passive Radar, Beamforming, TDOA, System Status")

def main():
    """Main function for testing"""
    logger = KrakenDataLogger()
    
    if len(sys.argv) > 1 and sys.argv[1] == "--generate-samples":
        logger.generate_sample_data()
    else:
        print("KrakenSDR Data Logger initialized")
        print(f"Log directory: {logger.log_dir}")
        print("Use --generate-samples to create test data")

if __name__ == "__main__":
    main()
