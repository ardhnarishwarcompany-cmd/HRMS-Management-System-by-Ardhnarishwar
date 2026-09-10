# Employee Portal UI / Feature Update

- Super Admin inspired fixed sidebar + top navigation is retained on all protected pages, including AI Chat.
- AI Chat now has the same Employee Portal shell and a polished HR assistant interface.
- AI Chat frontend uses POST /api/ai-chat/ask and the backend prioritizes employee-specific live data for salary, attendance, leave, assignments and profile questions.
- My Assignments redesigned into polished responsive cards with progress, status, due date, priority and full-detail modal.
- My EOD redesigned into responsive report cards with detailed View modal and improved Submit/Edit form.
- SOP downloads now use the authenticated API download endpoint when available, with legacy sop_versions fallback support in the backend.
- Employee profile update now tolerates older DB schemas and can add missing optional profile columns automatically.
- Employee avatar upload now handles missing avatar columns and has an image-load fallback in the UI.

Run locally:
  npm install
  npm run dev
