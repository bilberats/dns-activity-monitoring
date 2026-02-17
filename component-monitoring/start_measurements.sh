#!/bin/bash
# Start all measurements in DNS PC and monitorin PC for both external and internal measures simultaneously

INTERVAL=${1:-1}      # seconds between samples
DURATION=${2:-10}     # total duration
MEASURE_DIR=${3:-"/data"}

# Create directory for measurements
mkdir -p "$MEASURE_DIR/measures"

echo "Starting measurements at $(date +%s.%N)"

# May requires password for the first execution (depends on ssh configuration)
ssh thd@157.159.55.165 "cd ~/dns-activity-monitoring/component-monitoring && bash ./orchestrate_measures.sh $INTERVAL $DURATION $MEASURE_DIR" &

SSH_MEASUREMENTS_PID=$!

# Launch local power meter
python3 ./component-monitoring/yoctowatt_log_fast.py --seconds "$DURATION" --out "$MEASURE_DIR/measures/yoctowatt.csv" &

LOCAL_PID=$!

# Wait for both to finish
wait $SSH_MEASUREMENTS_PID
wait $LOCAL_PID

echo "Measurements completed at $(date +%s.%N)"