# RELEASE STATUS — 18 SEP 2026

## Prepared
- Production API base: https://ardhnarishwar-hrms-backend.recruweb.com
- Portal DNS URLs updated to the current DNS names supplied in the deployment screenshots.
- Database settings in `backend/.env` updated to the supplied VPS MySQL database.
- SMTP settings updated to the supplied Gmail SMTP configuration.
- CORS allow-list updated for all seven live portal origins.
- EVS, AI Robo and Smart Attendance point to the unified backend.
- Local browser-facing API URLs removed from production frontend source/configuration.
- Existing production `dist/` bundles patched to the new backend hostname.
- PM2 config fixed to run the actual `backend/server.js`.
- Nginx production configuration included.
- Production verification script passes.
- Backend JavaScript syntax check passes.

## Important deployment note
The package has been statically/syntax verified here, but a real VPS runtime smoke test cannot be performed until the DNS records, MySQL service, SSL certificates and VPS process are actually running. The supplied live hostnames were not externally reachable from this environment at package time, so no claim is made that the new VPS is already online.

After upload, follow `VPS_DEPLOYMENT.md` in order.

## 18-Sep-2026 portal-domain update

Added dedicated production routing for:
- `https://ardhnarishwar-ai.hr-robo.recruweb.com`
- `https://ardhnarishwar-smart-attendance.recruweb.com`

Both origins were added to backend `CORS_ORIGINS`. AI Robotics serves its React `dist`; Smart Attendance is fronted by Nginx and routed to the unified Node `/api/smart-attendance/` module so it continues using the same HRMS database/backend.
