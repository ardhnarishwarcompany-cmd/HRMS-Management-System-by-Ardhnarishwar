# HRMS — Ardhnarishwar Human Resource Management System

A multi-portal HRMS platform. **One Node.js/Express backend** powers **six React + Vite portals**, and **three independent Python services** provide Employee Verification, Smart Attendance and AI Robo Interviews.

Repository: <https://github.com/Ahaan99/HRMS_PROJECTs>

---

## Table of Contents

1. [Architecture](#1-architecture)
2. [Prerequisites](#2-prerequisites)
3. [Clone the repository](#3-clone-the-repository)
4. [Database setup](#4-database-setup)
5. [Backend setup (Node.js)](#5-backend-setup-nodejs)
6. [Frontend portals setup](#6-frontend-portals-setup)
7. [Python services setup](#7-python-services-setup)
8. [Default logins](#8-default-logins)
9. [Production build & deploy](#9-production-build--deploy)
10. [Environment variable reference](#10-environment-variable-reference)
11. [Project structure](#11-project-structure)
12. [Troubleshooting](#12-troubleshooting)
13. [Security checklist](#13-security-checklist)

---

## 1. Architecture

| # | Service | Folder | Tech | Dev port |
|---|---------|--------|------|----------|
| 1 | Backend API (all portals) | `backend/` | Node.js 20, Express 5, MySQL (mysql2), Socket.IO | `5000` |
| 2 | Super Admin portal | `admin/` | React 19, Vite, Tailwind | `5174` |
| 3 | Client portal | `client/` | React 19, Vite, Tailwind v4 | `5175` |
| 4 | HR portal | `HR/` | React, Vite, Tailwind | `5176` |
| 5 | IT portal | `IT/` | React, Vite, Tailwind | `5177` |
| 6 | Employee portal | `employee/` | React, Vite, Tailwind | `5178` |
| 7 | Sales portal | `Sales/` | React, Vite, Tailwind | `5179` |
| 8 | Employee Verification (EVS) backend | `employee-verification-system/employee-verification-backend/` | Python FastAPI, PyMySQL | `8000` |
| 9 | EVS frontend | `employee-verification-system/frontend/frontend/` | React, Vite | `5173` |
| 10 | AI Robo Interview | `HR_robo/` | Python FastAPI, Groq, SQLite | `8001` |
| 11 | Smart Attendance | `smart-Attendance-main/.../Smart_Attendance/backend/` | Python Flask, face_recognition, MySQL/MongoDB | `5050` |

The Node backend also exposes a gateway (`/api/evs/*`, `/api/hr-robo/*`, `/api/smart-attendance/*`) that proxies to the Python services, so frontends only ever talk to port `5000`.

---

## 2. Prerequisites

Install the following before you start:

| Tool | Version | Notes |
|------|---------|-------|
| Node.js | 20 LTS or newer | <https://nodejs.org> |
| npm | 10+ | ships with Node |
| MySQL | 8.0+ | local server or remote host |
| Python | 3.10 – 3.12 | only for the three Python services |
| Git | any recent | |
| (optional) MongoDB | 6+ | Smart Attendance can use MySQL instead |
| (optional) Ollama | latest | powers the admin chatbot; falls back gracefully if absent |

---

## 3. Clone the repository

```bash
git clone https://github.com/Ahaan99/HRMS_PROJECTs.git
cd HRMS_PROJECTs
```

---

## 4. Database setup

1. Start MySQL and create the two databases:

   ```sql
   CREATE DATABASE hrms_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   CREATE DATABASE employee_verification CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```

2. Create a user (or reuse `root`) with full rights on both databases.

3. **No manual schema import is needed.** On first start the Node backend runs `initDb`, creates all tables and seeds the Super Admin plus master data. The EVS backend creates its own tables on boot.

---

## 5. Backend setup (Node.js)

```bash
cd backend
npm install
copy .env.production.example .env      # Windows
# cp .env.production.example .env      # macOS / Linux
```

Edit `backend/.env` — minimum required values:

```env
PORT=5000
NODE_ENV=development

DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=hrms_db

JWT_SECRET=change-me-to-a-long-random-string
SUPER_ADMIN_EMAIL=admin@hrms.com
SUPER_ADMIN_PASSWORD=admin123

# Email (Gmail: use an App Password, not your login password)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=you@gmail.com
EMAIL_PASS=your_app_password

# Python service URLs used by the gateway
EVS_SERVICE_URL=http://localhost:8000
HR_ROBO_SERVICE_URL=http://localhost:8001
SMART_ATTENDANCE_SERVICE_URL=http://localhost:5050
```

Run it:

```bash
npm run dev      # nodemon, auto-reload
# or
npm start        # plain node
```

You should see `Server running on port 5000` followed by table-creation and seed logs. Verify with <http://localhost:5000/api/health> (or any `/api/...` route).

---

## 6. Frontend portals setup

Every portal follows the same three steps. Repeat for `admin`, `client`, `HR`, `IT`, `employee`, `Sales`.

```bash
cd admin                 # <- change folder per portal
npm install
copy .env.production.example .env
```

Set the API URL in the portal's `.env`:

```env
VITE_API_BASE_URL=http://localhost:5000/api
VITE_UPLOADS_BASE_URL=http://localhost:5000/uploads
# client portal only:
VITE_API_SOCKET_URL=http://localhost:5000
# HR portal only:
VITE_AI_ROBO_URL=http://localhost:8001
```

Start the dev server:

```bash
npm run dev
```

Vite prints the local URL (ports listed in the Architecture table). Open the portal at `/login`.

> Tip: run each portal in its own terminal, or use a tool such as `concurrently` to start them together.

---

## 7. Python services setup

### 7.1 Employee Verification System (EVS) — port 8000

```bash
cd employee-verification-system/employee-verification-backend
python -m venv venv
venv\Scripts\activate            # Windows   (source venv/bin/activate on macOS/Linux)
pip install -r requirements.txt
```

Create `.env`:

```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=employee_verification
HRMS_DB_NAME=hrms_db
HRMS_SSO_KEY=hrms-evs-sso-2026        # must equal EVS_SSO_KEY in backend/.env
EVS_JWT_SECRET=change-me
```

```bash
uvicorn main:app --reload --port 8000
```

EVS frontend: `cd employee-verification-system/frontend/frontend && npm install && npm run dev`.

### 7.2 AI Robo Interview — port 8001

```bash
cd HR_robo
python -m venv venv && venv\Scripts\activate
pip install -r requirements.txt
```

Create `.env`:

```env
GROQ_API_KEY=your_groq_api_key
DATABASE_URL=sqlite:///./hr_robo.db
HRMS_SYNC_KEY=change-me
```

```bash
uvicorn backend.app:app --reload --port 8001
```

### 7.3 Smart Attendance — port 5050

```bash
cd smart-Attendance-main/smart-Attendance-main/Smart_Attendance/Smart_Attendance/backend
python -m venv venv && venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env
```

Fill in `MYSQL_*` (or `MONGO_URI`), `SECRET_KEY`, and the office geofence (`OFFICE_LAT`, `OFFICE_LNG`, `OFFICE_RADIUS`). Then:

```bash
python app.py
```

> `face_recognition` needs `dlib`. On Windows install CMake + Visual Studio Build Tools first, or use a prebuilt wheel.

---

## 8. Default logins

Seeded on first backend start. **Change every one of these before going live.**

| Portal | Email | Password |
|--------|-------|----------|
| Super Admin | `admin@hrms.com` | `admin123` |
| Manager (HR) | `manager@hrms.com` | `123` |
| Team Lead | `tl@hrms.com` | `123` |
| Smart Attendance admin | phone `9999999999` | `admin123` |

Employees, clients, IT and sales users are created from the Super Admin portal.

---

## 9. Production build & deploy

1. **Backend**

   ```bash
   cd backend && npm ci --omit=dev
   # set NODE_ENV=production and CORS_ORIGINS=https://portal1,https://portal2,... in .env
   pm2 start ../ecosystem.config.cjs      # runs hrms-backend (+ smart-attendance)
   ```

2. **Each portal** — set `VITE_API_BASE_URL=https://your-backend-domain/api` in `.env.production`, then:

   ```bash
   npm ci && npm run build
   ```

   Upload the generated `dist/` folder to the portal's (sub)domain. Each portal needs an SPA fallback (`.htaccess` / nginx `try_files $uri /index.html`).

3. **Reverse proxy** — nginx/Apache proxies `/api` and `/socket.io` to `:5000`. HTTPS is required (camera + GPS APIs only work on secure origins).

4. **Python services** — run under systemd/pm2/supervisor with the `.env` values from section 7; set `OTP_DEBUG` unset and `HRMS_SSO_KEY == EVS_SSO_KEY`.

See `DEPLOYMENT.md` for the full Hostinger/VPS walkthrough.

---

## 10. Environment variable reference

### `backend/.env`

| Variable | Purpose |
|----------|---------|
| `PORT`, `NODE_ENV` | server port / mode |
| `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME` | MySQL connection |
| `JWT_SECRET` | signs all portal tokens |
| `SUPER_ADMIN_EMAIL`, `SUPER_ADMIN_PASSWORD` | seeded admin |
| `EMAIL_HOST`, `EMAIL_PORT`, `EMAIL_USER`, `EMAIL_PASS`, `EMAIL_FROM` | Email System (nodemailer) |
| `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, `TWILIO_PHONE` | OTP via SMS |
| `OLLAMA_URL`, `OLLAMA_MODEL` | admin chatbot |
| `EVS_SSO_KEY` | HMAC key for EVS single sign-on |
| `EVS_SERVICE_URL`, `HR_ROBO_SERVICE_URL`, `SMART_ATTENDANCE_SERVICE_URL` | gateway targets |
| `CORS_ORIGINS` | comma-separated allowed origins (prod) |

### Portals (`*/.env`)

`VITE_API_BASE_URL`, `VITE_UPLOADS_BASE_URL`, `VITE_API_SOCKET_URL` (client), `VITE_AI_ROBO_URL` (HR).

`.env` files are git-ignored; `.env.production.example` files are committed as templates.

---

## 11. Project structure

```
HRMS_PROJECTs/
├── backend/                      Node/Express API, 38 feature modules, initDb + seeders
│   ├── config/                   db.js, env.js, initDb.js, seed*.js
│   ├── middleware/               JWT protect(), portal auth, tenant, audit
│   └── modules/                  superAdmin/, client/, hr/, it/, sales/, employee/, gateway/, proposals/ ...
├── admin/                        Super Admin portal
├── client/                       Client portal
├── HR/                           HR portal
├── IT/                           IT portal
├── employee/                     Employee portal
├── Sales/                        Sales portal
├── employee-verification-system/ EVS FastAPI backend + React frontend
├── HR_robo/                      AI Robo Interview (FastAPI + Groq)
├── smart-Attendance-main/        Face + geo attendance (Flask)
├── scripts/                      audit / check helper scripts
├── ecosystem.config.cjs          pm2 process file
├── DEPLOYMENT.md                 hosting walkthrough
└── README.md
```

---

## 12. Troubleshooting

| Symptom | Fix |
|---------|-----|
| `EADDRINUSE :5000` | another backend instance is running; stop it or change `PORT` |
| `ER_ACCESS_DENIED_ERROR` | wrong `DB_USER`/`DB_PASSWORD` in `backend/.env` |
| Portal shows *Network Error* | backend not running, or `VITE_API_BASE_URL` wrong (must end with `/api`) |
| *Failed to send email* | set `EMAIL_USER`/`EMAIL_PASS` (Gmail App Password) and restart the backend |
| IT login says *Invalid credentials* | employee must belong to the **IT** department; IT uses `/api/it/auth/login` |
| Blank page after login | clear `localStorage` for the portal and reload |
| CORS error in production | add the portal origin to `CORS_ORIGINS` |
| `dlib` build fails | install CMake + C++ build tools, or a prebuilt `dlib` wheel |

---

## 13. Security checklist

- [ ] Change all seeded passwords (section 8)
- [ ] Set a strong `JWT_SECRET`, `EVS_JWT_SECRET`, `HRMS_SYNC_KEY`
- [ ] `EVS_SSO_KEY` (Node) equals `HRMS_SSO_KEY` (EVS)
- [ ] `OTP_DEBUG` unset in production
- [ ] `CORS_ORIGINS` restricted to your portal domains
- [ ] HTTPS on every domain
- [ ] Never commit `.env` or `.env.production` files containing secrets (already git-ignored)

---

## License

Proprietary — Ardhnarishwar / Recruweb. All rights reserved.
