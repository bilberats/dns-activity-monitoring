#!/bin/bash
# This script starts multiple measurements for different configurations.

# Define configurations
MONITORING_INTERVAL=${1:-1}      # seconds between samples
DURATION=${2:-60}     # total duration

QPS_CONFIG=(1 10 100 500 1000)      # queries per second
PROTOCOLS=("udp" "dot" "doh")  # protocols to monitor

# First measures is idle (no queries)
bash start.sh $MONITORING_INTERVAL $DURATION 0 "idle" "idle" 1

for PROTOCOL in "${PROTOCOLS[@]}"; do
    for QPS in "${QPS_CONFIG[@]}"; do
        sleep 10  # wait a bit before starting the next measurement
        MEASURE_NAME="${DURATION}s_${PROTOCOL}_${QPS}qps"
        INTERVAL=$(awk "BEGIN {print 1/$QPS}")
        bash start.sh $MONITORING_INTERVAL $DURATION $INTERVAL $PROTOCOL $MEASURE_NAME
    done
done