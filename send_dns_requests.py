import socket
import time
import struct
import random
import sys
import ssl
import http.client
from urllib.parse import urlparse
import dns.message
import dns.rdatatype
import httpx


DNS_PORT = 53
DOT_PORT = 853

def build_dns_query(domain):
    tid = random.randint(0, 65535)
    flags = 0x0100
    qdcount = 1

    header = struct.pack("!HHHHHH", tid, flags, qdcount, 0, 0, 0)

    question = b""
    for part in domain.split("."):
        question += struct.pack("B", len(part)) + part.encode()
    question += b"\x00"
    question += struct.pack("!HH", 1, 1)  # A / IN

    return header + question

# ---------------- UDP ----------------
def send_udp(server, domain, interval, duration):
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    query = build_dns_query(domain)
    end = time.time() + duration
    count = 0

    while time.time() < end:
        sock.sendto(query, (server, DNS_PORT))
        count += 1
        time.sleep(interval)

    sock.close()
    return count

# ---------------- DoT ----------------
def send_dot(server, domain, interval, duration):
    context = ssl._create_unverified_context()
    conn = http.client.HTTPSConnection(
        server,
        DOT_PORT,
        context=context
    )
    raw_query = build_dns_query(domain)
    query = struct.pack("!H", len(raw_query)) + raw_query

    end = time.time() + duration
    count = 0

    while time.time() < end:
        with socket.create_connection((server, DOT_PORT)) as tcp:
            with context.wrap_socket(tcp, server_hostname=server) as tls:
                tls.sendall(query)
                tls.recv(4096)
                count += 1
        time.sleep(interval)

    return count

# ---------------- DoH ----------------
def send_doh(url, domain, interval, duration, verify_tls=False):
    query = dns.message.make_query(domain, dns.rdatatype.A).to_wire()

    parsed = urlparse(url)
    if not parsed.scheme.startswith("https") or not parsed.hostname:
        raise ValueError("Invalid DoH URL. Expected https://host/dns-query")

    end_time = time.time() + duration
    count = 0

    print(f"Sending DoH requests to {url}")

    # httpx client with HTTP/2
    with httpx.Client(http2=True, verify=verify_tls) as client:
        while time.time() < end_time:
            try:
                resp = client.post(
                    url,
                    content=query,
                    headers={
                        "Content-Type": "application/dns-message",
                        "Accept": "application/dns-message"
                    },
                    timeout=10.0
                )
                resp.raise_for_status()  # Raise on HTTP errors
                count += 1
            except Exception as e:
                print(f"Request failed: {e}")
            time.sleep(interval)

    return count


# ---------------- Main ----------------
if __name__ == "__main__":
    if len(sys.argv) != 6:
        print("Usage:")
        print("  python3 send_dns_requests.py <udp|dot|doh> <server/url> <domain> <interval> <duration>")
        sys.exit(1)

    mode = sys.argv[1].lower()
    target = sys.argv[2]
    domain = sys.argv[3]
    interval = float(sys.argv[4])
    duration = float(sys.argv[5])

    if mode == "udp":
        count = send_udp(target, domain, interval, duration)
    elif mode == "dot":
        count = send_dot(target, domain, interval, duration)
    elif mode == "doh":
        target = target if target.startswith("http") else "https://" + target
        target = target.rstrip("/") + "/dns-query"
        count = send_doh(target, domain, interval, duration)
    else:
        print("Invalid mode: use udp, dot, or doh")
        sys.exit(1)

    print(f"Sent {count} DNS requests via {mode.upper()}")
