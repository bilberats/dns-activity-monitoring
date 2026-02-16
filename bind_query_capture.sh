#!/bin/bash

LOG_FILE="/var/log/named/client.log"
OUTPUT_FILE="data/logs/bind_queries_captured.log"
DURATION=${1:-60}     # seconds
INTERVAL=${2:-1}      # seconds

# Count lines at start
START_LINES=$(wc -l < "$LOG_FILE")
# Clear output file
sudo echo "" > "$OUTPUT_FILE"

echo "Starting line count: $START_LINES"
echo "Capturing new DNS queries for $DURATION seconds"
echo "----------------------------------------------"

elapsed=0
while [ $elapsed -lt $DURATION ]; do
    sleep "$INTERVAL"
    elapsed=$((elapsed + INTERVAL))

    CURRENT_LINES=$(wc -l < "$LOG_FILE")

    if [ "$CURRENT_LINES" -gt "$START_LINES" ]; then
        # Extract only new lines
        sudo sed -n "$((START_LINES + 1)),$CURRENT_LINES p" "$LOG_FILE" >> "$OUTPUT_FILE"
        START_LINES=$CURRENT_LINES
    fi

    TOTAL_CAPTURED=$(wc -l < "$OUTPUT_FILE" 2>/dev/null || echo 0)
    echo "[$elapsed / $DURATION sec] queries captured: $TOTAL_CAPTURED"
done

echo "Done."
echo "Final query count:"
wc -l "$OUTPUT_FILE"
