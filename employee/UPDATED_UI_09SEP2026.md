# Employee Portal UI update — 09 Sep 2026

- Shared fixed sidebar + top navbar remains on every protected route, including AI Chat.
- Added consistent internal page heading bars to Dashboard, Targets, Performance, SOP, Attendance, Leave, Compensation, AI Chat and Profile.
- Improved Targets and SOP Library visual hierarchy and card spacing.
- Assignment detail modal now has a close button, constrained height and internal scrolling; modal stack is above the fixed topbar.
- Shared modal stacking/scroll hardening prevents the fixed topbar from covering the first/last parts of dialogs.
- SOP frontend now handles JSON error responses returned inside blob downloads.
- Backend SOP download supports legacy `sop_versions` rows and falls back to bundled SOP templates when an old file path is missing.
