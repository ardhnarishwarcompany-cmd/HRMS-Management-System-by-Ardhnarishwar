# 🌐 Global Attendance Management System

**Enterprise Multi-Tenant Global Workforce Platform**

[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/downloads/)
[![Flask 3.0](https://img.shields.io/badge/framework-Flask%203.0-green.svg)](https://flask.palletsprojects.com/)
[![MongoDB](https://img.shields.io/badge/database-MongoDB-brightgreen.svg)](https://www.mongodb.com/)
[![Docker Ready](https://img.shields.io/badge/deployment-Docker%20%7C%20Compose-blue.svg)](https://www.docker.com/)
[![Tests](https://img.shields.io/badge/tests-33%20passed-success.svg)](./tests)

An enterprise-grade, multi-tenant global attendance platform featuring biometric Face AI recognition, cryptographically rotating dynamic tokens, office Wi-Fi subnet fencing, GPS satellite geofence tracking, full IANA global timezone resolution, and strict tenant data isolation.

---

## 🚀 Quick Start (Local Development)

### 1. Requirements
- Python 3.10 or higher
- (Optional) MongoDB instance (if not present, an embedded MongoDB mock engine bootstraps automatically)

### 2. Install Dependencies
```bash
pip install -r requirements.txt
```

### 3. Run Development Server
```bash
# Option A: Root Launcher
python run_app.py

# Option B: Windows Batch Launcher
run_app.bat
```
Navigate to: **[http://127.0.0.1:5000](http://127.0.0.1:5000)**

---

## 🔑 Default Platform Credentials & Portal Paths

| Role | Canonical URL | Default Identifier / Email | Default Password |
| :--- | :--- | :--- | :--- |
| **Super Admin** | `/admin/dashboard` | `superadmin@ardhnarishwar.com` | `superadmin123` |
| **Workspace Admin** | `/workspace/dashboard` | *Company Admin Mobile/Email* | *Set upon workspace registration* |
| **Employee Portal** | `/employee/portal` | *Employee ID* | *Set upon onboarding* |

*Unauthenticated visits to `/` or any protected URL automatically route to `/login?redirectTo=...`.*

---

## 🐳 Production Deployment Options

### Option 1: Docker & Docker Compose (Recommended)
Deploy the full stack (App + MongoDB with persistent storage volume) in seconds:
```bash
# Build and run containers in background
docker-compose up -d --build

# Inspect container health
docker-compose ps

# View live production logs
docker-compose logs -f web
```
The platform will be live at `http://<your-server-ip>:5000`.

---

### Option 2: 1-Click Cloud PaaS Deployment (Render / Railway / Heroku)

#### Render Deployment:
1. Push this repository to your GitHub account.
2. In the [Render Dashboard](https://dashboard.render.com), click **New +** $\to$ **Blueprint**.
3. Select your repository. Render will automatically detect `render.yaml` and configure:
   - Python environment with Gunicorn WSGI.
   - All environment variables and port routing.
4. Supply your free MongoDB Atlas connection URI under `MONGO_URI`.
5. Click **Apply** to deploy live to production with free SSL.

#### Railway / Heroku Deployment:
- The included `Procfile` is automatically recognized:
  ```procfile
  web: gunicorn --chdir backend app:app --bind 0.0.0.0:$PORT --workers 4 --threads 2 --timeout 120
  ```

---

### Option 3: Production Linux VPS (Ubuntu / Debian / RHEL)

#### 1. System Dependencies & Virtual Environment
```bash
sudo apt update && sudo apt install -y python3-pip python3-venv libgl1 libglib2.0-0 nginx
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

#### 2. Systemd Service Configuration
Create `/etc/systemd/system/attendance.service`:
```ini
[Unit]
Description=Global Attendance Management System WSGI Server
After=network.target

[Service]
User=www-data
WorkingDirectory=/var/www/smart-attendance
Environment="PATH=/var/www/smart-attendance/venv/bin"
Environment="HOST=127.0.0.1"
Environment="PORT=5000"
ExecStart=/var/www/smart-attendance/venv/bin/gunicorn --chdir backend app:app --bind 127.0.0.1:5000 --workers 4 --threads 2

[Install]
WantedBy=multi-user.target
```
Enable and start the service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable attendance
sudo systemctl start attendance
```

#### 3. Nginx Reverse Proxy & SSL
Create `/etc/nginx/sites-available/attendance`:
```nginx
server {
    listen 80;
    server_name attendance.yourdomain.com;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```
Enable with `sudo ln -s /etc/nginx/sites-available/attendance /etc/nginx/sites-enabled/` and obtain free SSL via `sudo certbot --nginx -d attendance.yourdomain.com`.

---

### Option 4: Production Windows Server (Waitress WSGI)
For native Windows Server deployments without Docker:
```bash
python run_production.py
```
Waitress will serve high-concurrency requests across 8 worker threads on port `5000`.

---

## 🏛️ Core Architectural Highlights

1. **Multi-Tenant Global Isolation**:
   - Each company operates under strict cryptographic separation (`company_id`).
   - Cross-tenant data access is blocked at the gateway (`403 Cross-Tenant Forbidden`).
2. **Comprehensive IANA Timezone Engine**:
   - Hierarchical resolution: $\text{Employee} \to \text{Branch} \to \text{Company Default} \to \text{"Asia/Kolkata" / "UTC"}$.
   - Shift grace periods, late-ins, and half-day rules evaluated in local branch time.
   - Dual timestamp telemetry: Local time + Timezone badge displayed alongside normalized UTC timestamps.
3. **Multi-Modal Biometric & Geolocation Verification**:
   - 📸 **Local Face AI Recognition**: Runs OpenCV Haar/deep cascade models with zero cloud biometric leakage.
   - 🔢 **Dynamic Cryptographic Code**: 60-second self-rotating tokens with anti-replay guarantees.
   - 📶 **Office Wi-Fi Subnet Matching**: IP CIDR validation ensuring on-premise presence.
   - 📍 **Satellite GPS Radar**: Haversine distance geofencing with configurable perimeter tolerance.
4. **Resilient Offline Mode & Auto-Sync**:
   - In-app IndexedDB storage preserves offline check-ins during network drops.
   - Auto-synchronizes queued attendance punches when connectivity is restored.

---

## 🧪 Automated Testing Suite

Run the full automated test suite (33 test cases covering route guards, multi-tenancy, Face AI, and timezone resolution):
```bash
python -m pytest tests/
```

---

## 📄 License
Enterprise Commercial License. © 2026 Global Attendance Management System. All rights reserved.
