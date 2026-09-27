module.exports = {
  apps: [{
    name: "ardhnarishwar-hrms",
    script: "./server.js",
    env: { NODE_ENV: "production", PORT: 5000 },
    error_file: "./logs/err.log",
    out_file: "./logs/out.log"
  }]
};
