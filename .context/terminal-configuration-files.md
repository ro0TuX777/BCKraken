# KrakenSDR Terminal Configuration Files

## Overview
Complete collection of configuration files for terminal-based maximum utilization of KrakenSDR. All configurations are JSON-based and designed for command-line operation.

## Master Configuration File

### /etc/kraken/max_utilization.json
```json
{
  "system": {
    "mode": "MAX_UTILIZATION",
    "operation": "TERMINAL_ONLY",
    "log_level": "INFO",
    "log_path": "/var/log/kraken",
    "pid_path": "/var/run/kraken"
  },
  "hardware": {
    "sample_rate": 2400000,
    "coherent_channels": 5,
    "usb_buffer_size": 16384,
    "clock_source": "internal"
  },
  "vfo_config": {
    "vfo_1": {
      "frequency": 146520000,
      "bandwidth": 25000,
      "mode": "DF_CONTINUOUS",
      "algorithm": "MUSIC",
      "gain": 20,
      "priority": "HIGH",
      "squelch": -80,
      "auto_track": true,
      "description": "Ham Emergency Frequency"
    },
    "vfo_2": {
      "frequency": 462675000,
      "bandwidth": 12500,
      "mode": "DF_SCAN",
      "algorithm": "Bartlett",
      "gain": 25,
      "priority": "MEDIUM",
      "squelch": -75,
      "scan_list": [
        462550000, 462575000, 462600000, 462625000,
        462650000, 462675000, 462700000, 462725000
      ],
      "scan_speed": "FAST",
      "dwell_time": 100,
      "description": "GMRS Channels"
    },
    "vfo_3": {
      "frequency": 155340000,
      "bandwidth": 25000,
      "mode": "DF_PRIORITY",
      "algorithm": "Capon",
      "gain": 30,
      "priority": "HIGH",
      "squelch": -70,
      "scan_range": {
        "start": 154000000,
        "end": 156000000,
        "step": 12500
      },
      "priority_list": [
        155.340, 155.160, 155.220, 155.280,
        155.400, 155.460, 155.520, 155.580
      ],
      "description": "Public Safety"
    },
    "vfo_4": {
      "frequency": 101500000,
      "bandwidth": 200000,
      "mode": "PASSIVE_RADAR_REF",
      "gain": 15,
      "illuminator_type": "FM_BROADCAST",
      "illuminator_power": 50000,
      "illuminator_location": [40.7128, -74.0060],
      "coverage_radius": 150,
      "description": "FM Radio Reference"
    },
    "vfo_5": {
      "frequency": "AUTO_SCAN",
      "bandwidth": 25000,
      "mode": "DISCOVERY",
      "algorithm": "MEMS",
      "gain": "AUTO",
      "scan_speed": "FAST",
      "scan_range": {
        "start": 24000000,
        "end": 1766000000,
        "step": 25000
      },
      "skip_ranges": [
        [88000000, 108000000],
        [174000000, 216000000],
        [470000000, 890000000]
      ],
      "signal_threshold": -85,
      "description": "Full Band Discovery"
    }
  },
  "passive_radar": {
    "enabled": true,
    "reference_channel": 4,
    "surveillance_channels": [1, 2, 3, 5],
    "illuminators": {
      "FM_101_5": {
        "frequency": 101500000,
        "power": 50000,
        "location": [40.7128, -74.0060],
        "type": "FM_BROADCAST"
      },
      "DVB_T_CH21": {
        "frequency": 474000000,
        "power": 100000,
        "location": [40.7500, -73.9800],
        "type": "DVB_T"
      }
    },
    "processing": {
      "integration_time": 2.0,
      "range_bins": 512,
      "doppler_bins": 256,
      "cfar_threshold": 10.0,
      "min_target_velocity": 10.0
    }
  },
  "beamforming": {
    "enabled": true,
    "array_type": "UCA",
    "elements": 5,
    "radius": 0.5,
    "adaptive": true,
    "interference_nulling": true,
    "beam_directions": [0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330],
    "null_depth": -40
  },
  "signal_classification": {
    "enabled": true,
    "algorithms": ["modulation", "protocol", "emitter"],
    "confidence_threshold": 0.7,
    "update_interval": 1.0,
    "training_data": "/etc/kraken/ml_models/"
  },
  "tracking": {
    "enabled": true,
    "max_tracks": 100,
    "track_timeout": 30.0,
    "association_threshold": 5.0,
    "kalman_filter": true
  },
  "output": {
    "elasticsearch": {
      "enabled": true,
      "host": "localhost",
      "port": 9200,
      "index_prefix": "kraken",
      "index_rotation": "daily",
      "bulk_size": 100,
      "flush_interval": 5.0,
      "real_time": true
    },
    "file_logging": {
      "enabled": true,
      "base_path": "/var/log/kraken",
      "rotation": "daily",
      "max_size": "100MB",
      "compress": true,
      "formats": ["json", "csv"]
    },
    "terminal_output": {
      "enabled": true,
      "verbosity": "INFO",
      "real_time_display": true,
      "update_interval": 1.0
    },
    "api": {
      "enabled": true,
      "host": "0.0.0.0",
      "port": 8080,
      "authentication": false
    }
  },
  "performance": {
    "cpu_affinity": [2, 3, 4, 5],
    "thread_priority": "HIGH",
    "memory_limit": "4GB",
    "gpu_acceleration": false,
    "optimization": "REAL_TIME"
  }
}
```

## Individual Component Configurations

### VFO Configuration Template (/etc/kraken/vfo_template.json)
```json
{
  "vfo_id": 1,
  "frequency": 146520000,
  "bandwidth": 25000,
  "mode": "DF_CONTINUOUS",
  "algorithm": "MUSIC",
  "gain": 20,
  "squelch": -80,
  "processing": {
    "fft_size": 1024,
    "overlap": 0.5,
    "window": "hann",
    "integration_time": 1.0
  },
  "direction_finding": {
    "array_manifold": "/etc/kraken/array_manifold.json",
    "calibration": "/etc/kraken/calibration.json",
    "search_range": [0, 360],
    "search_step": 1.0,
    "confidence_threshold": 0.5
  },
  "output": {
    "bearing_update_rate": 10.0,
    "data_logging": true,
    "real_time_stream": true
  }
}
```

### Passive Radar Configuration (/etc/kraken/passive_radar.json)
```json
{
  "illuminator": {
    "type": "FM_BROADCAST",
    "frequency": 101500000,
    "bandwidth": 200000,
    "power": 50000,
    "location": [40.7128, -74.0060]
  },
  "reference_processing": {
    "channel": 4,
    "gain": 15,
    "filter_bandwidth": 200000,
    "adaptive_filtering": true
  },
  "surveillance_processing": {
    "channels": [1, 2, 3, 5],
    "gain": [20, 25, 30, 20],
    "beamforming": true,
    "clutter_suppression": true
  },
  "detection": {
    "range_resolution": 300.0,
    "doppler_resolution": 1.0,
    "max_range": 150000.0,
    "max_velocity": 1000.0,
    "cfar_type": "CA_CFAR",
    "false_alarm_rate": 1e-6
  },
  "tracking": {
    "enabled": true,
    "max_tracks": 50,
    "track_timeout": 10.0,
    "gate_size": 3.0
  }
}
```

### Elasticsearch Mapping Template (/etc/kraken/elasticsearch_mapping.json)
```json
{
  "mappings": {
    "properties": {
      "timestamp": {
        "type": "date",
        "format": "strict_date_optional_time||epoch_millis"
      },
      "device_id": {
        "type": "keyword"
      },
      "vfo_id": {
        "type": "integer"
      },
      "frequency": {
        "type": "long"
      },
      "signal": {
        "properties": {
          "power": {"type": "float"},
          "bandwidth": {"type": "long"},
          "modulation": {"type": "keyword"},
          "snr": {"type": "float"}
        }
      },
      "direction_finding": {
        "properties": {
          "bearing": {"type": "float"},
          "confidence": {"type": "float"},
          "algorithm": {"type": "keyword"},
          "elevation": {"type": "float"}
        }
      },
      "passive_radar": {
        "properties": {
          "target_id": {"type": "keyword"},
          "range": {"type": "float"},
          "velocity": {"type": "float"},
          "rcs": {"type": "float"},
          "illuminator": {"type": "keyword"}
        }
      },
      "location": {
        "properties": {
          "receiver": {"type": "geo_point"},
          "transmitter": {"type": "geo_point"}
        }
      },
      "classification": {
        "properties": {
          "type": {"type": "keyword"},
          "protocol": {"type": "keyword"},
          "confidence": {"type": "float"}
        }
      }
    }
  },
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0,
    "refresh_interval": "5s"
  }
}
```

## System Service Configuration

### Systemd Service File (/etc/systemd/system/kraken-max-util.service)
```ini
[Unit]
Description=KrakenSDR Maximum Utilization Service
After=network.target elasticsearch.service
Wants=elasticsearch.service

[Service]
Type=forking
User=pi
Group=pi
WorkingDirectory=/home/pi/krakensdr_doa
Environment=KRAKEN_CONFIG=/etc/kraken/max_utilization.json
Environment=PYTHONPATH=/home/pi/krakensdr_doa
ExecStart=/usr/local/bin/kraken_max_util start
ExecStop=/usr/local/bin/kraken_max_util stop
ExecReload=/usr/local/bin/kraken_max_util restart
PIDFile=/var/run/kraken/master.pid
Restart=always
RestartSec=10
TimeoutStartSec=60
TimeoutStopSec=30

[Install]
WantedBy=multi-user.target
```

## Logging Configuration

### Logrotate Configuration (/etc/logrotate.d/kraken)
```
/var/log/kraken/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 644 pi pi
    postrotate
        systemctl reload kraken-max-util
    endscript
}
```

### Rsyslog Configuration (/etc/rsyslog.d/50-kraken.conf)
```
# KrakenSDR logging
if $programname == 'kraken' then /var/log/kraken/kraken.log
& stop
```

## Installation Script

### setup_configs.sh
```bash
#!/bin/bash
# Setup all KrakenSDR configuration files

# Create directories
sudo mkdir -p /etc/kraken /var/log/kraken /var/run/kraken
sudo chown $USER:$USER /var/log/kraken /var/run/kraken

# Copy configuration files
sudo cp max_utilization.json /etc/kraken/
sudo cp vfo_template.json /etc/kraken/
sudo cp passive_radar.json /etc/kraken/
sudo cp elasticsearch_mapping.json /etc/kraken/

# Setup systemd service
sudo cp kraken-max-util.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable kraken-max-util

# Setup logging
sudo cp 50-kraken.conf /etc/rsyslog.d/
sudo cp kraken /etc/logrotate.d/
sudo systemctl restart rsyslog

# Set permissions
sudo chmod 644 /etc/kraken/*.json
sudo chmod 755 /usr/local/bin/kraken_*

echo "Configuration setup complete!"
echo "Start with: kraken_max_util start"
```
