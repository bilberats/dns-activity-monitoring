#!/bin/bash

MONITORING_INTERVAL=${1:-1}      # seconds between samples
DURATION=${2:-60}     # total duration
QUERIES_INTERVAL=${3:-1}      # seconds between query count updates
PROTOCOL=${4:-"udp"}  # protocols to monitor (space-separated)
MEASURE_NAME=${5:-"dns_activity_monitoring"}  # name for measurements
MEASURE_IDLE=${6:-0}  # whether to perform idle measurements (1 for yes, 0 for no)

# Create directory for measurements
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
MEASURE_DIR="data/${MEASURE_NAME}_${TIMESTAMP}"
mkdir -p "$MEASURE_DIR"
ssh thd@157.159.55.165 "cd ~/dns-activity-monitoring && mkdir -p $MEASURE_DIR"

# Start all scripts from both servers
ssh thd@157.159.55.165 "cd ~/dns-activity-monitoring && bash ./start_dns_logs_monitoring.sh $MONITORING_INTERVAL $DURATION $MEASURE_DIR" &
SSH_PID=$!

bash ./component-monitoring/start_measurements.sh $MONITORING_INTERVAL $DURATION $MEASURE_DIR &
LOCAL_MEASUREMENTS_PID=$!

echo "QUERYS_INTERVAL: $QUERIES_INTERVAL seconds, PROTOCOL: $PROTOCOL, MEASURE_IDLE: $MEASURE_IDLE"

if [ "$MEASURE_IDLE" -eq 0 ]; then
    python3 send_dns_requests.py $PROTOCOL 157.159.55.165 example.com $QUERIES_INTERVAL $DURATION &
    LOCAL_REQUESTS_PID=$!
fi

# Wait for scripts to finish
wait $SSH_PID
wait $LOCAL_MEASUREMENTS_PID
wait $LOCAL_REQUESTS_PID

echo "Measurements completed at $(date +%s.%N)"