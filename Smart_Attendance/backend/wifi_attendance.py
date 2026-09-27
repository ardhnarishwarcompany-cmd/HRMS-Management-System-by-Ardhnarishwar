import socket
from database import companies_col


def get_server_local_ip() -> str | None:
    """Detect the server local IP address."""
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:
        return "127.0.0.1"


def is_office_ip(client_ip: str, company_id: str = None) -> tuple[bool, str]:
    """
    Two-layer check to verify the client is on the company's authorized office WiFi.

    Layer 1 — Localhost (127.0.0.1 or ::1 or matching server IP):
        Requests from local test machine or server browser are allowed.

    Layer 2 — Dynamic Company Subnet check:
        Checks against all configured office subnets in the company's active profile.
    """
    server_ip = get_server_local_ip() or "127.0.0.1"

    # Fetch authorized subnets for the company
    authorized_subnets = []
    if company_id:
        company = companies_col.find_one({"company_id": company_id})
        if company:
            locations = company.get("office_locations", [])
            for loc in locations:
                subnet = loc.get("wifi_subnet")
                if subnet and subnet.strip():
                    authorized_subnets.append(subnet.strip())

    # Layer 1: Localhost / Server machine
    if not client_ip or client_ip in ("127.0.0.1", "::1", "localhost"):
        return True, f"Verified on Local Office Network ({server_ip})"

    # If client IP matches server IP directly
    if client_ip == server_ip:
        return True, f"Verified on Server Network ({server_ip})"

    if not authorized_subnets:
        # Default local subnet fallback
        authorized_subnets = ["192.168.29", "192.168.1", "10.0.0", "172.16.0"]

    # Layer 2: Subnet check
    client_subnet = ".".join(client_ip.split(".")[:3])
    server_subnet = ".".join(server_ip.split(".")[:3])

    if client_subnet in authorized_subnets:
        return True, f"Authorized Office WiFi verified (IP: {client_ip} on Subnet {client_subnet}.*)"

    # Also allow if client and server are on the same local subnet
    if client_subnet == server_subnet:
        return True, f"Matching Local Office Subnet ({client_subnet}.*) verified"

    return False, f"Device IP ({client_ip}) is not connected to company's authorized office WiFi subnets ({', '.join(authorized_subnets)})"


def get_client_real_ip(request) -> str:
    """Extract the real client IP from request headers."""
    forwarded = request.headers.get("X-Forwarded-For", "")
    if forwarded:
        return forwarded.split(",")[0].strip()
    real = request.headers.get("X-Real-IP", "")
    if real:
        return real.strip()
    return request.remote_addr or "127.0.0.1"
