import { useState } from "react";
import { Navigate } from "react-router-dom";
import { toast } from "react-toastify";
import HRMS_API from "../services/hrmsApi";
import "../styles/login-premium.css";

const saveSession = (payload, identifier) => {
  const user = payload.user || payload.employee || {};
  const token = payload.token || payload.access_token;
  localStorage.setItem("token", token);
  localStorage.setItem("role", "EMPLOYEE");
  localStorage.setItem("email", user.email || identifier);
  localStorage.setItem("name", user.name || "Employee");
  if (user.id) localStorage.setItem("employeeId", String(user.id));
  if (user.employeeCode) localStorage.setItem("employeeCode", user.employeeCode);
  if (user.department) localStorage.setItem("department", user.department);
};

function Login() {
  const [mode, setMode] = useState("password");
  const [identifier, setIdentifier] = useState("");
  const [password, setPassword] = useState("");
  const [otp, setOtp] = useState("");
  const [otpSent, setOtpSent] = useState(false);
  const [loading, setLoading] = useState(false);
  const [otpLoading, setOtpLoading] = useState(false);

  if (localStorage.getItem("token")) return <Navigate to="/dashboard" replace />;

  const loginPassword = async () => {
    if (!identifier.trim() || !password) {
      toast.error("Please enter your employee email and password");
      return;
    }
    try {
      setLoading(true);
      const res = await HRMS_API.post("/employee/auth/login", {
        email: identifier.trim(),
        password,
      });
      saveSession(res.data, identifier.trim());
      toast.success("Employee login successful");
      window.location.href = "/dashboard";
    } catch (error) {
      toast.error(error.response?.data?.message || "Only active employees can sign in");
    } finally {
      setLoading(false);
    }
  };

  const requestOtp = async () => {
    if (!identifier.trim()) {
      toast.error("Enter your registered employee email or phone number");
      return;
    }
    try {
      setOtpLoading(true);
      const res = await HRMS_API.post("/otp-auth/request", {
        portal: "employee",
        identifier: identifier.trim(),
      });
      setOtpSent(true);
      toast.success(res.data.message || "OTP sent to your registered contact");
    } catch (error) {
      toast.error(error.response?.data?.message || "Unable to send OTP");
    } finally {
      setOtpLoading(false);
    }
  };

  const verifyOtp = async () => {
    if (!/^\d{6}$/.test(otp.trim())) {
      toast.error("Enter the 6-digit OTP");
      return;
    }
    try {
      setOtpLoading(true);
      const res = await HRMS_API.post("/otp-auth/verify", {
        portal: "employee",
        identifier: identifier.trim(),
        otp: otp.trim(),
      });
      saveSession(res.data, identifier.trim());
      toast.success("Employee login successful");
      window.location.href = "/dashboard";
    } catch (error) {
      toast.error(error.response?.data?.message || "Invalid or expired OTP");
    } finally {
      setOtpLoading(false);
    }
  };

  const handleKey = (e) => {
    if (e.key !== "Enter") return;
    if (mode === "password") loginPassword();
    else if (otpSent) verifyOtp();
    else requestOtp();
  };

  return (
    <div className="login-container" onKeyDown={handleKey}>
      <div className="login-grid" aria-hidden="true" />
      <div className="login-orb login-orb-one" />
      <div className="login-orb login-orb-two" />
      <div className="login-stars" />

      <div className="login-top-brand">
        <img src="/logo.png" alt="Ardhnarishwar" className="login-logo" />
        <div>
          <div className="login-brand-name">ARDHNARISHWAR</div>
          <div className="login-brand-sub">Employee Verification Portal</div>
        </div>
      </div>

      <div className="login-frame">
        <div className="login-shell">
          <section className="login-brand-panel">
            <div>
              <div className="login-eyebrow"><span /> SECURE EMPLOYEE PORTAL</div>
              <h1>Verify your<br /><span>employment.</span></h1>
              <p className="login-brand-copy">
                Submit your verification documents securely and track every verification step from one trusted workspace.
              </p>

              <div className="login-feature-list">
                <div className="login-feature"><b>✓</b><div><strong>Document verification</strong><span>Submit required employment documents</span></div></div>
                <div className="login-feature"><b>✓</b><div><strong>Identity &amp; background checks</strong><span>Complete verification securely</span></div></div>
                <div className="login-feature"><b>✓</b><div><strong>Super Admin review</strong><span>Your submissions go to the verification team</span></div></div>
              </div>
            </div>

            <div className="login-floating-card login-float-one"><span className="float-dot">✓</span><div><b>Document submitted</b><small>Waiting for verification</small></div></div>
            <div className="login-floating-card login-float-two"><span className="float-ring">↗</span><div><b>Verification secure</b><small>Protected employee access</small></div></div>
            <div className="login-brand-foot">Authorized employees only · Secure verification workspace</div>
          </section>

          <section className="login-card">
            <div className="login-card-icon">EV</div>
            <h2>Welcome back</h2>
            <p className="login-sub">Sign in to your Employee Verification Portal</p>

            <div className="login-tabs">
              <button className={mode === "password" ? "active" : ""} onClick={() => { setMode("password"); setOtpSent(false); }}>Password</button>
              <button className={mode === "otp" ? "active" : ""} onClick={() => setMode("otp")}>Login with OTP</button>
            </div>

            <label htmlFor="employee-identifier">Employee email / registered phone</label>
            <div className="login-input-wrap"><span>✉</span><input id="employee-identifier" type="text" placeholder="name@company.com" value={identifier} onChange={(e) => setIdentifier(e.target.value)} autoComplete="username" /></div>

            {mode === "password" ? (
              <>
                <label htmlFor="employee-password">Password</label>
                <div className="login-input-wrap"><span>⌑</span><input id="employee-password" type="password" placeholder="Enter your password" value={password} onChange={(e) => setPassword(e.target.value)} autoComplete="current-password" /></div>
                <button className="login-submit" onClick={loginPassword} disabled={loading}>{loading ? "Signing in…" : <>Login as Employee <span>→</span></>}</button>
              </>
            ) : (
              <>
                {!otpSent ? (
                  <button className="login-submit" onClick={requestOtp} disabled={otpLoading}>{otpLoading ? "Sending OTP…" : <>Send OTP <span>→</span></>}</button>
                ) : (
                  <>
                    <label htmlFor="employee-otp">6-digit OTP</label>
                    <div className="login-input-wrap"><span>✦</span><input id="employee-otp" inputMode="numeric" maxLength={6} placeholder="Enter OTP" value={otp} onChange={(e) => setOtp(e.target.value.replace(/\D/g, ""))} autoComplete="one-time-code" /></div>
                    <button className="login-submit" onClick={verifyOtp} disabled={otpLoading}>{otpLoading ? "Verifying…" : <>Verify &amp; Login <span>→</span></>}</button>
                    <button className="otp-resend" onClick={requestOtp} disabled={otpLoading}>Resend OTP</button>
                  </>
                )}
              </>
            )}

            <div className="login-security-note"><span>▣</span><div><b>Employee access only</b><small>Any department employee with an active HRMS account can use this portal. Verification submissions are sent to the Super Admin for review.</small></div></div>
          </section>
        </div>
      </div>
    </div>
  );
}

export default Login;
