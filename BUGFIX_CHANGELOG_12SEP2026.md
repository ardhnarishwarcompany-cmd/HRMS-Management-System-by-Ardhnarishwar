# Bugfix changelog — 12 Sep 2026

This build only touches the files listed below. No other feature, route, or
workflow was modified. **This is a source-code delivery** — after unzipping,
run the normal build for each app (`npm install && npm run build` inside
`admin/`, `IT/`, `Sales/`, etc.) and redeploy, since the `dist/` folders in
this zip were only patched where a byte-level fix was possible (see items 1
and 3) and are otherwise stale.

## 1. Super Admin → IT Daily Work showed employee number instead of name
- `admin/src/pages/dashboard/WorkReportSystem.jsx` — the employee cell now
  also reads the `employee` field the backend actually returns (a name
  string), instead of only checking `employee_name`/`employeeName` and
  falling back straight to the numeric `employee_id`.
- Also hand-patched directly into `admin/dist/assets/index-gnBRyo7u.js` so it
  takes effect even before a rebuild.

## 2. IT portal → Bug Reporting page going blank / breaking
- `IT/src/pages/it/TaskAssignment.jsx` — the `initials()` helper could crash
  with "Cannot read properties of null (reading 'split')" if an assignee
  name was `null`. Hardened with a `String(name || "")` guard.
- Added `IT/src/components/common/ErrorBoundary.jsx` and wrapped the IT
  portal's main content area (`IT/src/pages/it/ITShell.jsx`) with it, so a
  future null/undefined data crash on any IT page shows a small recoverable
  "Something went wrong — Try again" message instead of a blank white page.

## 3. Candidate Management / Joined Candidates / Interview Scheduling → CTC showing "â†'" garbled text
- The CTC column (`current_ctc → expected_ctc`) uses a real "→" arrow
  character in `admin/src/components/Interview/AdminInterviewTable.jsx`
  (source file itself is correctly UTF‑8 encoded).
- The previously built `admin/dist/assets/index-gnBRyo7u.js` had that arrow
  double‑encoded (mojibake) baked into the bundle. Patched the exact bytes
  directly in the built file so the arrow now renders correctly without
  waiting for a rebuild. A fresh `npm run build` of `admin/` will also
  produce the correct output going forward.

## 4. Lead Assigner → added Edit / Delete under a three-dot menu
- `admin/src/pages/leads/LeadAssigner.jsx` — every uploaded batch card now
  has a "⋮" button with **Edit** (rename the batch) and **Delete** (removes
  the batch and all its leads, with a confirmation prompt).
- Backend: added matching endpoints in
  `backend/modules/superAdmin/leads/lead.route.js` /
  `lead.controller.js` / `lead.service.js`:
  - `PUT  /super-admin/leads/batches/:id` — rename a batch
  - `DELETE /super-admin/leads/batches/:id` — delete a batch + its leads
  (Existing routes for individual lead update/delete are untouched.)

## 5. IT portal → client chat couldn't be opened / messages wouldn't send
- Root cause: `backend/modules/chat/chat.controller.js` → `startConversation`
  required the staff member starting the chat to belong to the `HR`
  department specifically. IT-portal staff (a different department) were
  always rejected with "Selected HR member is not available", so the
  conversation was never created and sending a message then failed too.
- Fixed to accept **any active employee** (HR, IT, or otherwise) starting a
  client conversation, matching how the feature already works for HR.

## 6. Sales portal → Leads & Pipeline showing blank Name/Phone
- Root cause: `backend/modules/superAdmin/leads/lead.controller.js` →
  `uploadLeads` only recognized Excel column headers named exactly
  `"Full Name"` and `"Mobile No."`. Any sheet using a different header
  (e.g. "Name", "Candidate Name", "Phone", "Contact Number", etc.) produced
  `undefined` for both fields, which is why previously imported batches show
  blank names/phone numbers in the Sales portal table.
- Fixed to match a list of common header variants, case-insensitively.
- **Note:** this fixes all *future* uploads. Batches already imported with
  blank names (as in the reported screenshot) have `NULL` stored in the
  database already and will need to be re-uploaded from the original sheet
  to backfill — there's no way to recover the original name/phone values
  from inside the app since they were never saved.
