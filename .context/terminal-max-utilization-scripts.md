# KrakenSDR Terminal Maximum Utilization Scripts

## Overview
Complete collection of terminal scripts to maximize KrakenSDR utilization with all scanning methods, direction finding, passive radar, and Elasticsearch integration running simultaneously.

## Master Control Script

### /usr/local/bin/kraken_max_util
```bash
#!/bin/bash
# KrakenSDR Maximum Utilization Control Script

KRAKEN_CONFIG="/etc/kraken/max_utilization.json"
KRAKEN_LOG="/var/log/kraken"
KRAKEN_PID="/var/run/kraken"

# Create directories if they don't exist
sudo mkdir -p $KRAKEN_LOG $KRAKEN_PID
sudo chown $USER:$USER $KRAKEN_LOG $KRAKEN_PID

start_max_utilization() {
    echo "Starting KrakenSDR Maximum Utilization Mode..."
    
    # Start Heimdall DAQ
    echo "Starting Heimdall DAQ..."
    systemctl start heimdall-daq
    sleep 2
    
    # Start all VFOs simultaneously
    echo "Starting all 5 VFOs..."
    python3 /home/pi/krakensdr_doa/scripts/start_vfo.py --vfo 1 --freq 146.520e6 --mode DF --algorithm MUSIC &
    echo $! > $KRAKEN_PID/vfo1.pid
    
    python3 /home/pi/krakensdr_doa/scripts/start_vfo.py --vfo 2 --freq 462.675e6 --mode SCAN --algorithm Bartlett &
    echo $! > $KRAKEN_PID/vfo2.pid
    
    python3 /home/pi/krakensdr_doa/scripts/start_vfo.py --vfo 3 --freq 155.340e6 --mode PRIORITY --algorithm Capon &
    echo $! > $KRAKEN_PID/vfo3.pid
    
    # Start passive radar (VFO 4 + reference)
    echo "Starting passive radar..."
    python3 /home/pi/krakensdr_doa/scripts/passive_radar.py --illuminator FM_101.5 --surveillance-channels 2,3,4,5 &
    echo $! > $KRAKEN_PID/radar.pid
    
    # Start discovery scanner (VFO 5)
    echo "Starting discovery scanner..."
    python3 /home/pi/krakensdr_doa/scripts/discovery_scan.py --range 24e6:1766e6 --step 25e3 &
    echo $! > $KRAKEN_PID/discovery.pid
    
    # Start beamforming processor
    echo "Starting adaptive beamforming..."
    python3 /home/pi/krakensdr_doa/scripts/beamforming.py --adaptive --nulling &
    echo $! > $KRAKEN_PID/beamform.pid
    
    # Start signal classification
    echo "Starting signal classification..."
    python3 /home/pi/krakensdr_doa/scripts/signal_classifier.py --all-channels &
    echo $! > $KRAKEN_PID/classifier.pid
    
    # Start Elasticsearch streamer
    echo "Starting Elasticsearch data stream..."
    python3 /home/pi/krakensdr_doa/scripts/elasticsearch_streamer.py --real-time &
    echo $! > $KRAKEN_PID/elasticsearch.pid
    
    echo "All systems started. Use 'kraken_max_util status' to monitor."
}

stop_max_utilization() {
    echo "Stopping KrakenSDR Maximum Utilization Mode..."
    
    # Kill all processes
    for pidfile in $KRAKEN_PID/*.pid; do
        if [ -f "$pidfile" ]; then
            pid=$(cat "$pidfile")
            if kill -0 "$pid" 2>/dev/null; then
                echo "Stopping process $pid..."
                kill "$pid"
            fi
            rm -f "$pidfile"
        fi
    done
    
    # Stop systemd services
    systemctl stop heimdall-daq
    
    echo "All systems stopped."
}

status_max_utilization() {
    echo "=== KrakenSDR Maximum Utilization Status ==="
    echo
    
    # Check systemd services
    echo "--- Core Services ---"
    systemctl is-active heimdall-daq && echo "Heimdall DAQ: RUNNING" || echo "Heimdall DAQ: STOPPED"
    
    # Check VFO processes
    echo
    echo "--- VFO Status ---"
    for i in {1..5}; do
        if [ -f "$KRAKEN_PID/vfo$i.pid" ]; then
            pid=$(cat "$KRAKEN_PID/vfo$i.pid")
            if kill -0 "$pid" 2>/dev/null; then
                echo "VFO $i: RUNNING (PID: $pid)"
            else
                echo "VFO $i: STOPPED"
            fi
        else
            echo "VFO $i: NOT STARTED"
        fi
    done
    
    # Check passive radar
    echo
    echo "--- Passive Radar ---"
    if [ -f "$KRAKEN_PID/radar.pid" ]; then
        pid=$(cat "$KRAKEN_PID/radar.pid")
        if kill -0 "$pid" 2>/dev/null; then
            echo "Passive Radar: RUNNING (PID: $pid)"
        else
            echo "Passive Radar: STOPPED"
        fi
    else
        echo "Passive Radar: NOT STARTED"
    fi
    
    # Check other processes
    echo
    echo "--- Additional Processing ---"
    for process in discovery beamform classifier elasticsearch; do
        if [ -f "$KRAKEN_PID/$process.pid" ]; then
            pid=$(cat "$KRAKEN_PID/$process.pid")
            if kill -0 "$pid" 2>/dev/null; then
                echo "$process: RUNNING (PID: $pid)"
            else
                echo "$process: STOPPED"
            fi
        else
            echo "$process: NOT STARTED"
        fi
    done
    
    # Check Elasticsearch connectivity
    echo
    echo "--- Elasticsearch Status ---"
    if curl -s http://localhost:9200/_cluster/health >/dev/null; then
        echo "Elasticsearch: CONNECTED"
        echo "Kraken indices: $(curl -s http://localhost:9200/_cat/indices/kraken-* | wc -l)"
    else
        echo "Elasticsearch: DISCONNECTED"
    fi
}

monitor_real_time() {
    echo "=== Real-time KrakenSDR Monitoring ==="
    echo "Press Ctrl+C to exit"
    echo
    
    # Monitor all log files simultaneously
    tail -f $KRAKEN_LOG/*.log 2>/dev/null &
    TAIL_PID=$!
    
    # Monitor system resources
    while true; do
        clear
        echo "=== KrakenSDR Real-time Status $(date) ==="
        echo
        
        # CPU and Memory
        echo "--- System Resources ---"
        echo "CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)%"
        echo "Memory: $(free | grep Mem | awk '{printf "%.1f%%", $3/$2 * 100.0}')"
        echo "Load: $(uptime | awk -F'load average:' '{print $2}')"
        echo
        
        # Active signals
        echo "--- Active Signals ---"
        if [ -f "/tmp/kraken_signals.txt" ]; then
            head -10 /tmp/kraken_signals.txt
        else
            echo "No signal data available"
        fi
        
        sleep 5
    done
    
    # Cleanup on exit
    kill $TAIL_PID 2>/dev/null
}

case "$1" in
    start)
        start_max_utilization
        ;;
    stop)
        stop_max_utilization
        ;;
    restart)
        stop_max_utilization
        sleep 3
        start_max_utilization
        ;;
    status)
        status_max_utilization
        ;;
    monitor)
        monitor_real_time
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|monitor}"
        echo
        echo "Commands:"
        echo "  start   - Start maximum utilization mode (all VFOs, passive radar, etc.)"
        echo "  stop    - Stop all KrakenSDR processes"
        echo "  restart - Restart all processes"
        echo "  status  - Show status of all components"
        echo "  monitor - Real-time monitoring display"
        exit 1
        ;;
esac
```

## Individual Component Scripts

### VFO Control Script (/usr/local/bin/kraken_vfo)
```bash
#!/bin/bash
# Individual VFO control

VFO_NUM=$2
FREQUENCY=$4
MODE=$6
ALGORITHM=$8

case "$1" in
    --start)
        echo "Starting VFO $VFO_NUM on $FREQUENCY with $ALGORITHM"
        python3 /home/pi/krakensdr_doa/scripts/vfo_control.py \
            --vfo $VFO_NUM \
            --frequency $FREQUENCY \
            --mode $MODE \
            --algorithm $ALGORITHM \
            --daemon
        ;;
    --stop)
        echo "Stopping VFO $VFO_NUM"
        pkill -f "vfo_control.py.*--vfo $VFO_NUM"
        ;;
    --status)
        if pgrep -f "vfo_control.py.*--vfo $VFO_NUM" >/dev/null; then
            echo "VFO $VFO_NUM: RUNNING"
        else
            echo "VFO $VFO_NUM: STOPPED"
        fi
        ;;
    *)
        echo "Usage: $0 --start --vfo N --frequency FREQ --mode MODE --algorithm ALG"
        echo "       $0 --stop --vfo N"
        echo "       $0 --status --vfo N"
        ;;
esac
```

### Passive Radar Control (/usr/local/bin/kraken_radar)
```bash
#!/bin/bash
# Passive radar control

case "$1" in
    --start)
        ILLUMINATOR=$3
        CHANNELS=$5
        echo "Starting passive radar with illuminator $ILLUMINATOR"
        python3 /home/pi/krakensdr_doa/scripts/passive_radar.py \
            --illuminator $ILLUMINATOR \
            --surveillance-channels $CHANNELS \
            --daemon
        ;;
    --stop)
        echo "Stopping passive radar"
        pkill -f "passive_radar.py"
        ;;
    --status)
        if pgrep -f "passive_radar.py" >/dev/null; then
            echo "Passive Radar: RUNNING"
            echo "Targets detected: $(tail -1 /tmp/radar_targets.txt | wc -l)"
        else
            echo "Passive Radar: STOPPED"
        fi
        ;;
    *)
        echo "Usage: $0 --start --illuminator SOURCE --channels CH_LIST"
        echo "       $0 --stop"
        echo "       $0 --status"
        ;;
esac
```

### Elasticsearch Integration (/usr/local/bin/kraken_elasticsearch)
```bash
#!/bin/bash
# Elasticsearch integration control

ES_HOST="localhost:9200"
INDEX_PREFIX="kraken"

case "$1" in
    --start)
        echo "Starting Elasticsearch data streaming..."
        python3 /home/pi/krakensdr_doa/scripts/elasticsearch_streamer.py \
            --host $ES_HOST \
            --index-prefix $INDEX_PREFIX \
            --real-time \
            --daemon
        ;;
    --stop)
        echo "Stopping Elasticsearch streaming"
        pkill -f "elasticsearch_streamer.py"
        ;;
    --status)
        if pgrep -f "elasticsearch_streamer.py" >/dev/null; then
            echo "Elasticsearch Streamer: RUNNING"
            echo "Documents indexed today: $(curl -s http://$ES_HOST/kraken-*/_count | jq .count)"
        else
            echo "Elasticsearch Streamer: STOPPED"
        fi
        ;;
    --query)
        QUERY=$2
        echo "Querying Elasticsearch for: $QUERY"
        curl -s "http://$ES_HOST/kraken-*/_search?q=$QUERY&pretty" | head -50
        ;;
    *)
        echo "Usage: $0 --start"
        echo "       $0 --stop"
        echo "       $0 --status"
        echo "       $0 --query SEARCH_TERM"
        ;;
esac
```

## Installation Commands
```bash
# Make all scripts executable
sudo chmod +x /usr/local/bin/kraken_max_util
sudo chmod +x /usr/local/bin/kraken_vfo
sudo chmod +x /usr/local/bin/kraken_radar
sudo chmod +x /usr/local/bin/kraken_elasticsearch

# Create log directories
sudo mkdir -p /var/log/kraken /var/run/kraken
sudo chown $USER:$USER /var/log/kraken /var/run/kraken

# Test installation
kraken_max_util status
```

## Usage Examples
```bash
# Start everything
kraken_max_util start

# Monitor real-time
kraken_max_util monitor

# Control individual components
kraken_vfo --start --vfo 1 --frequency 146.520e6 --mode DF --algorithm MUSIC
kraken_radar --start --illuminator FM_101.5 --channels 2,3,4,5
kraken_elasticsearch --start

# Query data
kraken_elasticsearch --query "frequency:146520000"

# Stop everything
kraken_max_util stop
```
