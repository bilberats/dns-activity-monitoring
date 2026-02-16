#!/bin/bash

INTERVAL=${1:-1}
DURATION=${2:-60}

echo "Starting DNS monitoring for $DURATION seconds..."
echo "-----------------------------------------"

sudo bash bind_query_capture.sh $DURATION $INTERVAL &
sudo bash dns_activity_logger.sh $DURATION &

echo "Monitoring in progress..."
wait
echo "DNS monitoring completed."