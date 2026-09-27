# Ardhnarishwar HRMS — 10 Production Portal Domains

Create an **A record to the VPS public IP** for each hostname below:

1. `ardhnarishwar-admin.hrms.recruweb.com` — Admin
2. `ardhnarishwar-client.hrms.recruweb.com` — Client
3. `ardhnarishwar-hr.hrms.recruweb.com` — HR
4. `ardhnarishwar-it.hrms.recruweb.com` — IT
5. `ardhnarishwar-sales.hrms.recruweb.com` — Sales
6. `ardhnarishwar-employee.hrms.recruweb.com` — Employee
7. `ardhnarishwar-emp-verification.hrms.recruweb.com` — Employee Verification
8. `ardhnarishwar-hrms-backend.recruweb.com` — Unified Backend/API
9. `ardhnarishwar-ai.hr-robo.recruweb.com` — AI Robotics / HR Robo
10. `ardhnarishwar-smart-attendance.recruweb.com` — Smart Attendance

The last two are the newly added dedicated live portals requested for the DNS setup.

## Important architecture

- AI Robotics frontend is served directly from `AI-Robotics-Frontend/dist`.
- AI Robotics API uses the unified backend at `https://ardhnarishwar-hrms-backend.recruweb.com/api/hr-robo`.
- Smart Attendance uses the unified Node backend route `/api/smart-attendance/*`; it does **not** start a second database/server.
- `127.0.0.1` in backend Nginx/DB settings is internal VPS-only communication and is not a browser-facing URL.
- Do not create browser links to localhost.

## SSL after DNS resolves

Run Certbot for all public hosts, for example:

`sudo certbot --nginx -d ardhnarishwar-hrms-backend.recruweb.com -d ardhnarishwar-admin.hrms.recruweb.com -d ardhnarishwar-client.hrms.recruweb.com -d ardhnarishwar-hr.hrms.recruweb.com -d ardhnarishwar-it.hrms.recruweb.com -d ardhnarishwar-sales.hrms.recruweb.com -d ardhnarishwar-employee.hrms.recruweb.com -d ardhnarishwar-emp-verification.hrms.recruweb.com -d ardhnarishwar-ai.hr-robo.recruweb.com -d ardhnarishwar-smart-attendance.recruweb.com`
