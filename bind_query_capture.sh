#!/bin/bash

LOG_FILE="/var/log/named/queries.log"
OUTPUT_FILE="bind_queries_captured.log"
DURATION=60     # seconds
INTERVAL=5      # seconds

echo "Resetting log file..."
sudo truncate -s 0 "$LOG_FILE"
sudo truncate -s 0 "$OUTPUT_FILE"

echo "Capturing new DNS queries for $DURATION seconds"
echo "----------------------------------------------"

# Start tailing ONLY new lines
tail -n 0 -F "$LOG_FILE" >> "$OUTPUT_FILE" &
TAIL_PID=$!

elapsed=0
while [ $elapsed -lt $DURATION ]; do
    sleep "$INTERVAL"
    elapsed=$((elapsed + INTERVAL))
    lines=$(wc -l < "$OUTPUT_FILE")
    echo "[$elapsed / $DURATION sec] total queries captured: $lines"
done

# Stop tail
kill "$TAIL_PID" 2>/dev/null
wait "$TAIL_PID" 2>/dev/null

echo "Done."
echo "Final query count:"
wc -l "$OUTPUT_FILE"
