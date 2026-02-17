#!/bin/bash

INTERVAL=${1:-1}
DURATION=${2:-60}
MEASURE_DIR=${3:-"/data"}

echo "Starting DNS monitoring for $DURATION seconds..."
echo "-----------------------------------------"

# Create logs directory if it doesn't exist
mkdir -p "$MEASURE_DIR/logs"

sudo bash bind_query_capture.sh $DURATION $INTERVAL $MEASURE_DIR &
sudo bash dns_activity_logger.sh $DURATION $MEASURE_DIR &

echo "Monitoring in progress..."
wait
echo "DNS monitoring completed."