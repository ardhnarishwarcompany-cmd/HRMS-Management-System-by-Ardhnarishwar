import { useState } from "react";
import toast from "react-hot-toast";
import { useNavigate } from "react-router-dom";

import API from "../../api/axios";
import { useEmployeeAuth } from "../../context/EmployeeAuthContext";
import OtpLogin from "../../components/OtpLogin";
import heroImage from "../../assets/hero.png";
import ardhnarishwarLogo from "../../assets/ardhnarishwar-logo.png";

function Icon({ type, size = 22 }) {
  const common = {
    width: size,
    height: size,
    viewBox: "0 0 24 24",
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round",
    strokeLinejoin: "round",
  };

  if (type === "mail") {
    return (
      <svg {...common}>
        <rect x="3" y="5" width="18" height="14" rx="2" />
        <path d="m3 7 9 6 9-6" />
      </svg>
    );
  }

  if (type === "lock") {
    return (
      <svg {...common}>
        <rect x="4" y="10" width="16" height="11" rx="2" />
        <path d="M8 10V7a4 4 0 0 1 8 0v3" />
      </svg>
    );
  }

  if (type === "eye") {
    return (
      <svg {...common}>
        <path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7S2 12 2 12Z" />
        <circle cx="12" cy="12" r="3" />
      </svg>
    );
  }

  if (type === "eyeOff") {
    return (
      <svg {...common}>
        <path d="m3 3 18 18" />
        <path d="M10.6 5.1A10.8 10.8 0 0 1 12 5c7 0 10 7 10 7a17 17 0 0 1-3.2 4.2" />
        <path d="M6.6 6.6A17 17 0 0 0 2 12s3 7 10 7a10 10 0 0 0 4.3-1" />
        <path d="M9.9 9.9a3 3 0 0 0 4.2 4.2" />
      </svg>
    );
  }

  if (type === "login") {
    return (
      <svg {...common}>
        <path d="M10 17l5-5-5-5" />
        <path d="M15 12H3" />
        <path d="M21 3v18" />
      </svg>
    );
  }

  if (type === "calendar") {
    return (
      <svg {...common}>
        <rect x="3" y="4" width="18" height="17" rx="3" />
        <path d="M8 2v4M16 2v4M3 9h18" />
        <path d="M8 13h.01M12 13h.01M16 13h.01M8 17h.01M12 17h.01" />
      </svg>
    );
  }

  if (type === "task") {
    return (
      <svg {...common}>
        <rect x="4" y="3" width="16" height="18" rx="3" />
        <path d="M8 8h8M8 12h8M8 16h5" />
        <path d="m15 16 1.5 1.5L20 14" />
      </svg>
    );
  }

  if (type === "user") {
    return (
      <svg {...common}>
        <circle cx="12" cy="8" r="4" />
        <path d="M4 21c.8-4 3.5-6 8-6s7.2 2 8 6" />
      </svg>
    );
  }

  if (type === "pay") {
    return (
      <svg {...common}>
        <rect x="3" y="5" width="18" height="14" rx="3" />
        <path d="M3 9h18M7 14h4" />
      </svg>
    );
  }

  return null;
}

function FloatingCard({ type, title, value, className }) {
  return (
    <div className={`hero-float-card ${className}`}>
      <div className={`hero-float-icon hero-icon-${type}`}>
        <Icon type={type} size={22} />
      </div>

      <div>
        <div className="hero-float-title">{title}</div>
        <div className="hero-float-value">{value}</div>
      </div>
    </div>
  );
}

export default function Login() {
  const navigate = useNavigate();
  const { login } = useEmployeeAuth();

  const [mode, setMode] = useState("password");
  const [loading, setLoading] = useState(false);
  const [showPass, setShowPass] = useState(false);
  const [remember, setRemember] = useState(false);

  const [form, setForm] = useState({
    email: "",
    password: "",
  });

  const handleChange = (e) => {
    setForm((prev) => ({
      ...prev,
      [e.target.name]: e.target.value,
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    try {
      setLoading(true);

      const res = await API.post("/employee/auth/login", form);

      login(res.data);

      toast.success("Login successful");

      navigate("/dashboard");
    } catch (err) {
      const message =
        err?.response?.data?.message || "Login failed";

      toast.error(message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="reference-login">

      {/* BACKGROUND */}
      <div className="reference-bg reference-bg-one" />
      <div className="reference-bg reference-bg-two" />
      <div className="reference-bg reference-bg-three" />

      {/* subtle floating particles */}
      <div className="login-particle particle-1" />
      <div className="login-particle particle-2" />
      <div className="login-particle particle-3" />
      <div className="login-particle particle-4" />

      {/* FINAL HRMS BRAND HEADER */}
<header className="hrms-login-header-final">
  <div className="hrms-login-brand-final">
    <div className="hrms-login-logo-final">
      <img
        src={ardhnarishwarLogo}
        alt="Ardhnarishwar HRMS"
      />
    </div>

    <div className="hrms-login-copy-final">
      <div className="hrms-login-name-final">
        ARDHNARISHWAR
      </div>
      <div className="hrms-login-subtitle-final">
        HRMS Employee Portal
      </div>
    </div>
  </div>

  <div className="hrms-login-status-final">
    <span></span>
    All systems operational
  </div>
</header>

      {/* MAIN */}
      <main className="reference-main">

        {/* LEFT */}
        <section className="reference-left">

          <div className="reference-badge">
            <span className="badge-dot" />
            EMPLOYEE PORTAL
          </div>

          <h1 className="reference-title">
            Your Work Matters,
            <span>We Make It Easier.</span>
          </h1>

          <p className="reference-description">
            Access your tasks, leave, payslips and more — all in one
            place. Stay connected, stay productive.
          </p>

          {/* HERO VISUAL */}
          <div className="hero-visual">

            <div className="hero-glow" />

            <div className="hero-window">
              <div className="hero-window-shine" />

              <img
                src={heroImage}
                alt="Employee working"
                className="hero-person"
              />
            </div>

            {/* 3D FLOATING CARDS */}
            <FloatingCard
              type="pay"
              title="Good Morning,"
              value="Employee!"
              className="float-greeting"
            />

            <FloatingCard
              type="task"
              title="Your Tasks"
              value="3 pending"
              className="float-task"
            />

            <FloatingCard
              type="calendar"
              title="Leave Balance"
              value="14 days"
              className="float-leave"
            />

            {/* floating 3D mini icons */}
            <div className="hero-orbit orbit-one">
              <div className="orbit-icon">
                <Icon type="calendar" size={23} />
              </div>
            </div>

            <div className="hero-orbit orbit-two">
              <div className="orbit-icon purple">
                <Icon type="task" size={22} />
              </div>
            </div>

            <div className="hero-orbit orbit-three">
              <div className="orbit-icon orange">
                <Icon type="user" size={22} />
              </div>
            </div>

          </div>

          {/* FEATURE ICONS */}
          <div className="feature-row">

            <div className="feature-item">
              <div className="feature-icon feature-blue">
                <Icon type="pay" size={25} />
              </div>
              <span>View<br />Payslips</span>
            </div>

            <div className="feature-divider" />

            <div className="feature-item">
              <div className="feature-icon feature-green">
                <Icon type="calendar" size={25} />
              </div>
              <span>Apply<br />Leave</span>
            </div>

            <div className="feature-divider" />

            <div className="feature-item">
              <div className="feature-icon feature-purple">
                <Icon type="task" size={25} />
              </div>
              <span>Track<br />Tasks</span>
            </div>

            <div className="feature-divider" />

            <div className="feature-item">
              <div className="feature-icon feature-orange">
                <Icon type="user" size={25} />
              </div>
              <span>Manage<br />Profile</span>
            </div>

          </div>

          {/* BLUE 3D INFO BAR */}
          <div className="workplace-bar">

            <div className="workplace-main-icon">
              <Icon type="task" size={28} />
            </div>

            <div className="workplace-copy">
              <strong>Better Workplace</strong>
              <span>Smart HR. Happy Employees.</span>
            </div>

            <div className="workplace-stat">
              <strong>100%</strong>
              <span>Transparency</span>
            </div>

            <div className="workplace-stat">
              <strong>24/7</strong>
              <span>Support</span>
            </div>

            <div className="workplace-stat">
              <strong>Secure</strong>
              <span>Data</span>
            </div>

          </div>

        </section>

        {/* RIGHT LOGIN CARD */}
        <section className="login-section">

          <div className="login-card">

            <div className="login-card-glow" />

            <div className="login-card-content">

              <div className="login-heading">

                <div className="login-heading-icon">
                  <div className="login-heading-icon-inner">
                    <Icon type="user" size={30} />
                  </div>
                </div>

                <div>
                  <h2>Employee Login</h2>
                  <p>Welcome back! Please sign in to your account.</p>
                </div>

              </div>

              {/* LOGIN METHOD */}
              <div className="login-tabs">

                <button
                  type="button"
                  className={mode === "password" ? "active" : ""}
                  onClick={() => setMode("password")}
                >
                  Password
                </button>

                <button
                  type="button"
                  className={mode === "otp" ? "active" : ""}
                  onClick={() => setMode("otp")}
                >
                  OTP Login
                </button>

              </div>

              {mode === "otp" ? (

                <div className="otp-reference-wrap">

                  <OtpLogin
                    portal="employee"
                    variant="glass"
                    onSuccess={(data) => {
                      login(data);
                      navigate("/dashboard");
                    }}
                  />

                </div>

              ) : (

                <form
                  className="reference-form"
                  onSubmit={handleSubmit}
                >

                  {/* EMAIL */}
                  <div className="reference-field">

                    <label>Email Address</label>

                    <div className="reference-input-wrap">

                      <span className="reference-input-icon">
                        <Icon type="mail" size={21} />
                      </span>

                      <input
                        type="email"
                        name="email"
                        required
                        autoComplete="email"
                        value={form.email}
                        onChange={handleChange}
                        placeholder="Enter your email address"
                      />

                    </div>

                  </div>

                  {/* PASSWORD */}
                  <div className="reference-field">

                    <label>Password</label>

                    <div className="reference-input-wrap">

                      <span className="reference-input-icon">
                        <Icon type="lock" size={21} />
                      </span>

                      <input
                        type={showPass ? "text" : "password"}
                        name="password"
                        required
                        autoComplete="current-password"
                        value={form.password}
                        onChange={handleChange}
                        placeholder="Enter your password"
                      />

                      <button
                        type="button"
                        className="password-eye"
                        onClick={() =>
                          setShowPass((v) => !v)
                        }
                        aria-label={
                          showPass
                            ? "Hide password"
                            : "Show password"
                        }
                      >
                        <Icon
                          type={
                            showPass
                              ? "eyeOff"
                              : "eye"
                          }
                          size={20}
                        />
                      </button>

                    </div>

                  </div>

                  {/* REMEMBER */}
                  <div className="remember-row">

                    <label className="remember-label">

                      <input
                        type="checkbox"
                        checked={remember}
                        onChange={(e) =>
                          setRemember(e.target.checked)
                        }
                      />

                      <span className="custom-checkbox">
                        {remember && "✓"}
                      </span>

                      Remember me

                    </label>
</div>

                  {/* SIGN IN */}
                  <button
                    type="submit"
                    disabled={loading}
                    className="reference-signin"
                  >

                    <span className="signin-shine" />

                    {loading ? (
                      <>
                        <span className="button-spinner" />
                        Signing in...
                      </>
                    ) : (
                      <>
                        <Icon type="login" size={22} />
                        Sign In
                      </>
                    )}

                  </button>

                </form>

              )}

              {/* NO GOOGLE LOGIN */}
              <div className="login-help">

                <span className="help-icon">
                  ?
                </span>

                <span>
                  Need help? Contact your HR administrator.
                </span>

              </div>

            </div>

          </div>

        </section>

      </main>

      {/* BOTTOM MARQUEE */}
      <footer className="reference-footer">

        <div className="footer-feature">
          <Icon type="task" size={23} />
          <span>Tasks & EOD Reports</span>
        </div>

        <div className="footer-feature">
          <Icon type="task" size={23} />
          <span>Targets & Performance</span>
        </div>

        <div className="footer-feature">
          <Icon type="calendar" size={23} />
          <span>Leave Management</span>
        </div>

        <div className="footer-feature">
          <Icon type="pay" size={23} />
          <span>Payslips & Compensation</span>
        </div>

        <div className="footer-feature">
          <Icon type="lock" size={23} />
          <span>Role-based Access</span>
        </div>

        <div className="footer-feature">
          <Icon type="calendar" size={23} />
          <span>One-tap Attendance</span>
        </div>

      </footer>

    </div>
  );
}
