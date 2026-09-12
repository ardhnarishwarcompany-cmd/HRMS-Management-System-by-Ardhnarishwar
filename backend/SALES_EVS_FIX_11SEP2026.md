# Sales login + EVS refresh fixes

## Sales login
The Sales login endpoint now resolves the Sales department from the shared `departments` table by name and uses `SALES_DEPT_ID` only as a fallback. This avoids a 403 when the production database uses a different numeric department ID.

## EVS refresh
EVS is a React SPA using BrowserRouter. Hostinger must rewrite unknown paths such as `/dashboard` and `/profile` to `/index.html`. The production EVS `dist/.htaccess` and `public/.htaccess` now contain the SPA rewrite.

Deploy the EVS `dist` contents to `evs-hrms.recruweb.com/public_html/` including the hidden `.htaccess` file.
