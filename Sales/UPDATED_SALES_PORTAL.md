# Updated HRMS Sales Portal

## Included
- Admin-style responsive sidebar, topbar, profile menu and mobile drawer.
- Sales-focused navigation: Dashboard, Leads, Clients, Calls, Proposals, Invoices, Reports, Field Sales, Services, Inventory, Targets, Assignments, Policy, Performance, EOD, Complaints and Chat.
- Proposal workflow connected to the shared backend: create/edit draft -> submit -> Super Admin approval/return -> client view -> client accept/reject.
- Proposal PDF download now uses the authenticated backend PDF endpoint for reliable downloads.
- Existing Sales business logic and routes are preserved.

## Production build
The archive contains source code. Build on the deployment machine with:

```bash
npm install
npm run build
```

Upload the generated `dist/` contents to the Sales domain's public folder.

`VITE_API_BASE_URL` in `.env.production` is already set to the unified HRMS backend domain supplied with this project.
