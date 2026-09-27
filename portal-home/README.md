# Portal Hub (`portal-home/`)

एक single landing page जो सभी portals को cards की तरह दिखाता है — जैसा screenshot में
था वैसी ही dark header + orange accent + colourful icon-card grid style में। Admin
portal जान-बूझकर grid में नहीं है — उसका अपना अलग "Admin Login" button ऊपर/नीचे दिया
गया है, क्योंकि वह अलग frontend (`admin/`) है जैसा आपने माँगा था।

## Kaise chalayein
Yeh ek plain HTML/CSS/JS file hai — koi build step nahi chahiye.

1. Sabse pehle apne saare portals unke dev servers par (ya production build) chala lein —
   README.md (root) me diye gaye commands se: `admin`, `client`, `HR`, `IT`, `employee`,
   `Sales`, `AI-Robotics-Frontend`, `Smart-Attendance-Frontend`, `employee-verification-system`.
2. `portal-home/index.html` ko kisi bhi static server se serve karein, ya seedha
   double-click karke browser me kholein.
3. File ke bottom me `<script>` block ke andar `PORTALS` array me har card ka `url`
   apne actual ports/domains ke hisaab se set karein (default values README ke dev-port
   table se liye gaye hain: client 5175, HR 5176, IT 5177, employee 5178, Sales 5179).
   `ADMIN_URL` variable admin app (default 5174) ke liye hai.
4. Chaho to isi file ko Node backend se static serve kar do (root `/` route), taki
   ek hi domain se sab kuch open ho.

## Important — ismein kya guarantee nahi hai
Yeh hub page sirf **navigation layer** hai — har card ek naye tab me us portal ko kholta
hai. Iske peeche wale asli portals (HR, IT, AI interview, Smart Attendance, etc.) ka
runtime working — database connection, camera/mic access, Groq API key, MySQL/MongoDB —
un sabko aapke apne machine par MySQL/MongoDB chalu karke, `.env` files bhar ke, aur
har service ko README ke steps se start karke hi test kiya ja sakta hai. Main is sandbox
me MySQL/MongoDB ya live camera access nahi chala sakta, isliye end-to-end runtime ka
100% zero-error guarantee yahan se nahi diya ja sakta — lekin har frontend ka code,
build config, aur ab yeh naya hub page — sab structurally sahi aur ready-to-run hain.
