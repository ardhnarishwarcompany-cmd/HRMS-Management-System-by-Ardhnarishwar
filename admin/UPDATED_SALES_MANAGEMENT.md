# Super Admin — Sales Management update

Added **Sales Management** under the Super Admin dashboard. It loads the Sales portal's shared database data in one screen:

- Sales / revenue and collections
- Leads and field-sales pipeline
- Calls and follow-ups
- Sales proposals and approval status
- Invoices
- Sales team
- Targets / assignments
- EOD reports
- Performance
- Inventory
- Services

Includes live refresh, search, status badges and CSV export. Proposal approvals remain available in the existing Proposals module.

The backend endpoint is `GET /api/super-admin/sales/overview` and is protected for SUPER_ADMIN.
