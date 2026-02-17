#!/bin/bash
DURATION=${1:-60}
MEASURE_DIR=${2:-"/data"}


timeout $DURATION tcpdump -n -l udp port 53 > $MEASURE_DIR/logs/dns_udp.log &
timeout $DURATION tcpdump -n -l tcp port 853 > $MEASURE_DIR/logs/dns_tcp.log &
timeout $DURATION tcpdump -n -l tcp port 443 > $MEASURE_DIR/logs/dns_doh.log &

wait
echo "DNS monitoring complete."
