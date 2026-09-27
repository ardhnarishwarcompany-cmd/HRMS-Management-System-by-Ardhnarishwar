# VPS DEPLOYMENT — ARDHNARISHWAR HRMS

## 1. DNS

The current portal DNS records shown in the supplied DNS screenshots resolve to the VPS IP `200.141.14.25`:

- ardhnarishwar-admin.hrms.recruweb.com
- ardhnarishwar-client.hrms.recruweb.com
- ardhnarishwar-it.hrms.recruweb.com
- ardhnarishwar-sales.hrms.recruweb.com
- ardhnarishwar-hr.hrms.recruweb.com
- ardhnarishwar-emp-verification.hrms.recruweb.com
- ardhnarishwar-employee.hrms.recruweb.com

The backend hostname used by this release is `ardhnarishwar-hrms-backend.recruweb.com`, matching the existing production configuration in the project. If that A record is not already present, create it pointing to the same VPS IP before enabling HTTPS.

## 2. Server packages

Ubuntu/Debian example:

```bash
sudo apt update
sudo apt install -y nginx mysql-client curl
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
sudo npm install -g pm2
```

## 3. Upload

Upload the release to:

```text
/var/www/ardhnarishwar-hrms
```

Expected folders:

```text
/var/www/ardhnarishwar-hrms/
  backend/
  admin/
  client/
  HR/
  IT/
  Sales/
  employee/
  employee-verification-system/frontend/frontend/
  portal-home/
  nginx/
  ecosystem.config.cjs
```

## 4. Backend

```bash
cd /var/www/ardhnarishwar-hrms/backend
npm ci --omit=dev --no-audit --no-fund
```

The included `backend/.env` contains the production database, SMTP, JWT, CORS, EVS, Groq and Smart Attendance settings supplied for this deployment.

Start with PM2 from the project root:

```bash
cd /var/www/ardhnarishwar-hrms
pm2 start ecosystem.config.cjs
pm2 save
pm2 startup
```

Check:

```bash
pm2 status
pm2 logs ardhnarishwar-hrms-backend --lines 100
```

## 5. Database

The existing VPS database is configured in `backend/.env`.

If the database already contains HRMS tables/data, do not blindly import `hrms_db.sql`.

If the database is new, import the supplied schema first:

```bash
mysql -h 127.0.0.1 -u YOUR_DB_USER -p YOUR_DB_NAME < /var/www/ardhnarishwar-hrms/hrms_db.sql
```

Then start the backend. Its existing initialization/seed code will complete the tables/master data required by the application.

## 6. Frontends

The release already contains patched `dist/` folders. Nginx can serve them directly.

For future clean builds:

```bash
cd /var/www/ardhnarishwar-hrms/admin && npm ci && npm run build
cd /var/www/ardhnarishwar-hrms/client && npm ci && npm run build
cd /var/www/ardhnarishwar-hrms/HR && npm ci && npm run build
cd /var/www/ardhnarishwar-hrms/IT && npm ci && npm run build
cd /var/www/ardhnarishwar-hrms/Sales && npm ci && npm run build
cd /var/www/ardhnarishwar-hrms/employee && npm ci && npm run build
cd /var/www/ardhnarishwar-hrms/employee-verification-system/frontend/frontend && npm ci && npm run build
```

## 7. Nginx

Copy the included configuration:

```bash
sudo cp /var/www/ardhnarishwar-hrms/nginx/ardhnarishwar-hrms.conf /etc/nginx/sites-available/ardhnarishwar-hrms.conf
sudo ln -sf /etc/nginx/sites-available/ardhnarishwar-hrms.conf /etc/nginx/sites-enabled/ardhnarishwar-hrms.conf
sudo nginx -t
sudo systemctl reload nginx
```

Then issue certificates:

```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx \
  -d ardhnarishwar-hrms-backend.recruweb.com \
  -d ardhnarishwar-admin.hrms.recruweb.com \
  -d ardhnarishwar-client.hrms.recruweb.com \
  -d ardhnarishwar-it.hrms.recruweb.com \
  -d ardhnarishwar-sales.hrms.recruweb.com \
  -d ardhnarishwar-hr.hrms.recruweb.com \
  -d ardhnarishwar-emp-verification.hrms.recruweb.com \
  -d ardhnarishwar-employee.hrms.recruweb.com
```

## 8. Smoke tests

Backend:

```bash
curl -I https://ardhnarishwar-hrms-backend.recruweb.com/
curl -I https://ardhnarishwar-hrms-backend.recruweb.com/api/health
curl -I https://ardhnarishwar-hrms-backend.recruweb.com/api/evs/health
curl -I https://ardhnarishwar-hrms-backend.recruweb.com/api/hr-robo/health
curl -I https://ardhnarishwar-hrms-backend.recruweb.com/api/smart-attendance/health
```

Portals:

```text
https://ardhnarishwar-admin.hrms.recruweb.com
https://ardhnarishwar-client.hrms.recruweb.com
https://ardhnarishwar-hr.hrms.recruweb.com
https://ardhnarishwar-it.hrms.recruweb.com
https://ardhnarishwar-sales.hrms.recruweb.com
https://ardhnarishwar-employee.hrms.recruweb.com
https://ardhnarishwar-emp-verification.hrms.recruweb.com
```

## 9. Browser/security checks

- All portal API calls use HTTPS production URLs.
- CORS is allow-listed for the live portal domains.
- Socket.IO is proxied through Nginx over HTTPS/WSS.
- Uploads are served from the backend domain.
- EVS verification emails use the live EVS frontend URL.
- AI Robo and Smart Attendance are served by the same backend, so no browser-facing port 8000/8001/5050 is required.
- `OTP_DEBUG=0` is set for production.
