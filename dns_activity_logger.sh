#!/bin/bash
DURATION=${1:-60}

timeout $DURATION tcpdump -n -l udp port 53 > data/logs/dns_udp.log &
timeout $DURATION tcpdump -n -l tcp port 53 > data/logs/dns_tcp.log &
timeout $DURATION tcpdump -n -l tcp port 443 > data/logs/dns_doh.log &

wait
echo "DNS monitoring complete."
