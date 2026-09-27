# Fixes applied - Backend

1. Client lead upload:
   - Corrected unified-auth role scoping so CLIENT_EMPLOYEE is never treated as a client admin merely because req.client is attached.
   - Added Excel extension and 10 MB validation.
   - Preserved tenant validation and employee assignment checks.

2. Client Employee Chat:
   - Added tenant-scoped employee conversation listing for the Client portal.
   - Added tenant/participant-scoped message retrieval.
   - Added Client Admin reply support to employee conversations.
   - Existing employee-to-client chat endpoints remain available.

3. Upload middleware:
   - Added a 10 MB multer file-size limit.
