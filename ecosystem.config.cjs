/**
 * PM2 production process for the unified HRMS backend.
 * Frontends are static Vite builds served by Nginx.
 * EVS, HR Robo and Smart Attendance are native Node modules under /api.
 */
module.exports = {
  apps: [
    {
      name: "ardhnarishwar-hrms-backend",
      cwd: "./backend",
      script: "server.js",
      env: {
        NODE_ENV: "production",
        PORT: 5000,
      },
      instances: 1,
      exec_mode: "fork",
      max_memory_restart: "768M",
      autorestart: true,
      time: true,
      kill_timeout: 5000,
      listen_timeout: 10000,
      restart_delay: 2000,
    },
  ],
};
