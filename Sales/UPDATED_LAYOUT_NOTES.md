# Sales Portal UI Fix – Sidebar Only + Chat

## Changes
- Removed the legacy horizontal quick-navigation strip from the application flow.
- All Sales modules are now available from the left Sales sidebar only.
- Protected pages use the Admin-style SalesLayout with sidebar + topbar.
- Team Chat is constrained to the available viewport so it no longer stretches the page or breaks the layout.
- Chat send/Enter behavior and the existing `/automation/chatbot/message` API remain intact.

## Build
```bash
npm install
npm run build
```
Upload the newly generated `dist/` folder to the Sales portal document root.
