# Ardhnarishwar HRMS — VPS Production Release

This release is prepared for a VPS deployment with **one Node.js backend + one MySQL database**.
The browser uses only HTTPS live domains. EVS, AI Robo Interview and Smart Attendance are served by the unified Node backend.

## Live portal routing

| Portal | Live URL |
|---|---|
| Super Admin | https://ardhnarishwar-admin.hrms.recruweb.com |
| Client | https://ardhnarishwar-client.hrms.recruweb.com |
| HR | https://ardhnarishwar-hr.hrms.recruweb.com |
| IT | https://ardhnarishwar-it.hrms.recruweb.com |
| Sales | https://ardhnarishwar-sales.hrms.recruweb.com |
| Employee | https://ardhnarishwar-employee.hrms.recruweb.com |
| Employee Verification | https://ardhnarishwar-emp-verification.hrms.recruweb.com |
| AI Robo Interview | https://ardhnarishwar-hrms-backend.recruweb.com/api/hr-robo/ |
| Smart Attendance | https://ardhnarishwar-hrms-backend.recruweb.com/api/smart-attendance/ |
| Unified Backend | https://ardhnarishwar-hrms-backend.recruweb.com |

## Architecture

- `backend/` — canonical Node.js/Express backend, Socket.IO and MySQL.
- `admin/`, `client/`, `HR/`, `IT/`, `Sales/`, `employee/` — React/Vite portals.
- `employee-verification-system/frontend/frontend/` — EVS React portal.
- `backend/modules/evs/` — native EVS API.
- `backend/modules/hrRobo/` — native AI interview API + interview UI.
- `backend/modules/attendance/` — native Smart Attendance API + UI.
- `portal-home/` — portal hub source/configuration.
- `nginx/ardhnarishwar-hrms.conf` — VPS reverse-proxy/static-host configuration.
- `ecosystem.config.cjs` — PM2 configuration for the single backend process.

## Database

The production `.env` is configured for the VPS MySQL database shown in the supplied deployment settings. `DB_HOST=127.0.0.1` is an internal server database connection, not a browser URL.

Do not expose `.env` publicly or commit it to Git.

## Important

The frontend `dist/` directories included in this release are the existing production builds with their API/live-domain references patched to the current backend hostname. The local development URLs were removed from all production frontend configuration and bundles.

For a clean rebuild on the VPS, use Node.js 20+ and run `npm ci && npm run build` in each frontend. Network access is required for npm package installation.
