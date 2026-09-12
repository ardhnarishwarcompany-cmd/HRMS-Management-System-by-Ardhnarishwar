# HRMS targeted bug-fix patch — 11 Sep 2026

Only the requested bugs were targeted; existing UI/design/features were preserved.

### Fixed
- Sales login 403: auth endpoint now bypasses the Sales portal-status guard; protected Sales APIs remain guarded.
- Client Work Assignment `path is not defined`: missing Node `path` import fixed.
- Employee Verification refresh/deep-link: hardened Apache SPA fallback `.htaccess` included.
- IT Bug Reporting null `.split()` crash fixed.
- Client Lead Assigner employee dropdown: all active client employees load when no department is selected.
- Super Admin Lead detail: edit/delete controls + secure backend endpoints.
- HR/Sales lead data: assigned employee display metadata included.
- Client chat: rooms are auto-created for active client employees so they appear immediately.
- Complaint role handling: Super Admin/Manager casing normalized.
- Super Admin Work Policies: surfaced in HR, Sales and Client policy feeds while preserving existing policy tables.
- Common mojibake currency/arrow/text corruption cleaned in application source.

### Deployment
1. Redeploy the updated `backend` first.
2. Build changed frontends with `npm install` then `npm run build`, and upload their `dist` folders.
3. EVS: upload `employee-verification-system/frontend/frontend/dist` including `.htaccess`.
4. Do not reset or delete the production database.
5. `node_modules` is intentionally excluded.
