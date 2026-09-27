import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import HRMS_API from "../services/hrmsApi";
import {
  LockKeyhole,
  Mail,
  Eye,
  EyeOff,
  ShieldCheck,
  FileCheck2,
  SearchCheck,
  BadgeCheck,
  Sparkles,
  ArrowRight,
} from "lucide-react";

export default function Login() {
  const navigate = useNavigate();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [remember, setRemember] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const handleLogin = async (e) => {
    e.preventDefault();
    setError("");

    if (!email.trim() || !password.trim()) {
      setError("Please enter your email and password.");
      return;
    }

    setLoading(true);

    try {
      const res = await HRMS_API.post("/employee/auth/login", {
        email: email.trim(),
        password,
      });

      const data = res.data || {};

      const user =
        data.user ||
        data.employee ||
        data.data?.user ||
        data.data?.employee ||
        {};

      const token =
        data.token ||
        data.access_token ||
        data.data?.token ||
        data.data?.access_token;

      if (!token) {
        throw new Error("Authentication token was not returned by the server.");
      }

      // Store only the authenticated employee's identity.
      localStorage.setItem("token", token);
      localStorage.setItem("role", "EMPLOYEE");
      localStorage.setItem("email", user.email || email.trim());
      localStorage.setItem(
        "name",
        user.name || user.fullName || user.full_name || "Employee"
      );

      if (user.id != null) {
        localStorage.setItem("employeeId", String(user.id));
      }

      if (user.employeeCode || user.employee_code) {
        localStorage.setItem(
          "employeeCode",
          String(user.employeeCode || user.employee_code)
        );
      }

      if (user.department) {
        localStorage.setItem("department", String(user.department));
      }

      // Keep the existing dashboard route.
      window.location.href = "/dashboard";
    } catch (err) {
      console.error("Employee login failed:", err);

      const message =
        err.response?.data?.message ||
        err.response?.data?.error ||
        err.message ||
        "Unable to sign in. Please check your email and password.";

      setError(message);
    } finally {
      setLoading(false);
    }
  };

  const features = [
    {
      icon: ShieldCheck,
      title: "Secure verification",
      text: "Controlled review workflow",
    },
    {
      icon: FileCheck2,
      title: "Document tracking",
      text: "Live status for every file",
    },
    {
      icon: SearchCheck,
      title: "Background checks",
      text: "Simple guided submission",
    },
    {
      icon: BadgeCheck,
      title: "HRMS connected",
      text: "Your employee profile stays linked",
    },
  ];

  return (
    <div className="hrms-login-page">
      {/* Background */}
      <div className="hrms-grid" />

      <div className="hrms-orb hrms-orb-one" />
      <div className="hrms-orb hrms-orb-two" />
      <div className="hrms-orb hrms-orb-three" />

      {/* Medium floating particles */}
      <div className="hrms-particle particle-one" />
      <div className="hrms-particle particle-two" />
      <div className="hrms-particle particle-three" />
      <div className="hrms-particle particle-four" />

      {/* Brand */}
      <header className="hrms-brand">
        <div className="hrms-brand-icon">
          <span>H</span>
        </div>

        <div>
          <div className="hrms-brand-name">HRMS</div>
          <div className="hrms-brand-subtitle">
            EMPLOYEE VERIFICATION
          </div>
        </div>
      </header>

      <main className="hrms-login-content">

        {/* LEFT */}
        <section className="hrms-hero">

          <div className="hrms-eyebrow">
            <Sparkles size={18} strokeWidth={2.2} />
            <span>SECURE EMPLOYEE WORKSPACE</span>
          </div>

          <h1>
            Verify once.
            <br />
            <span>Stay confident.</span>
          </h1>

          <p className="hrms-description">
            Complete your employment verification, submit documents and
            track every approval from one secure portal.
          </p>

          <div className="hrms-feature-grid">
            {features.map((feature, index) => {
              const Icon = feature.icon;

              return (
                <div className="hrms-feature-card" key={index}>
                  <div className="hrms-feature-icon">
                    <Icon size={24} strokeWidth={2} />
                  </div>

                  <div className="hrms-feature-content">
                    <div className="hrms-feature-title">
                      {feature.title}
                    </div>

                    <div className="hrms-feature-text">
                      {feature.text}
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </section>

        {/* RIGHT LOGIN */}
        <section className="hrms-login-card">

          <div className="hrms-card-top">
            <div className="hrms-lock-box">
              <LockKeyhole size={28} strokeWidth={2.1} />
            </div>

            <div className="hrms-status">
              <span />
              System operational
            </div>
          </div>

          <div className="hrms-card-heading">
            <div className="hrms-card-eyebrow">
              EMPLOYEE PORTAL
            </div>

            <h2>Welcome back</h2>

            <p>Sign in to continue your verification.</p>
          </div>

          <form onSubmit={handleLogin}>

            {/* EMAIL */}
            <div className="hrms-field-group">
              <label htmlFor="email">Email address</label>

              <div className="hrms-input-wrap">
                <Mail className="hrms-input-icon" size={20} />

                <input
                  id="email"
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="Enter your email address"
                  autoComplete="email"
                />
              </div>
            </div>

            {/* PASSWORD */}
            <div className="hrms-field-group">
              <label htmlFor="password">Password</label>

              <div className="hrms-input-wrap">
                <LockKeyhole className="hrms-input-icon" size={20} />

                <input
                  id="password"
                  type={showPassword ? "text" : "password"}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="Enter your password"
                  autoComplete="current-password"
                />

                <button
                  type="button"
                  className="hrms-eye-btn"
                  onClick={() => setShowPassword(!showPassword)}
                  aria-label={
                    showPassword ? "Hide password" : "Show password"
                  }
                >
                  {showPassword ? (
                    <EyeOff size={19} />
                  ) : (
                    <Eye size={19} />
                  )}
                </button>
              </div>
            </div>

            {/* OPTIONS */}
            <div className="hrms-login-options">

              <label className="hrms-remember">
                <input
                  type="checkbox"
                  checked={remember}
                  onChange={(e) => setRemember(e.target.checked)}
                />

                <span className="hrms-custom-checkbox">
                  {remember && "✓"}
                </span>

                <span>Remember me</span>
              </label>

              <button
                type="button"
                className="hrms-forgot"
                onClick={() => setError("Password reset is currently unavailable.")}
              >
                Forgot password?
              </button>

            </div>

            {error && (
              <div className="hrms-error">
                {error}
              </div>
            )}

            {/* LOGIN */}
            <button
              type="submit"
              className="hrms-login-button"
              disabled={loading}
            >
              <span>
                {loading ? "Signing in..." : "Login to Portal"}
              </span>

              {!loading && <ArrowRight size={21} />}
            </button>

          </form>

          <div className="hrms-security-note">
            <ShieldCheck size={17} />
            <span>
              Your session is protected by HRMS security controls.
            </span>
          </div>

        </section>
      </main>

      <style>{`
        * {
          box-sizing: border-box;
        }

        html,
        body,
        #root {
          margin: 0;
          min-height: 100%;
          width: 100%;
        }

        body {
          font-family:
            Inter,
            ui-sans-serif,
            system-ui,
            -apple-system,
            BlinkMacSystemFont,
            "Segoe UI",
            sans-serif;
          background: #050510;
        }

        button,
        input {
          font: inherit;
        }

        .hrms-login-page {
          position: relative;
          min-height: 100vh;
          overflow: hidden;
          color: #ffffff;
          background:
            radial-gradient(
              circle at 7% 10%,
              rgba(98, 35, 190, 0.16),
              transparent 24%
            ),
            radial-gradient(
              circle at 96% 85%,
              rgba(105, 34, 205, 0.15),
              transparent 25%
            ),
            #05050f;
        }

        .hrms-grid {
          position: absolute;
          inset: 0;
          pointer-events: none;
          opacity: 0.42;

          background-image:
            linear-gradient(
              rgba(139, 92, 246, 0.075) 1px,
              transparent 1px
            ),
            linear-gradient(
              90deg,
              rgba(139, 92, 246, 0.075) 1px,
              transparent 1px
            );

          background-size: 54px 54px;

          mask-image: linear-gradient(
            to bottom,
            black,
            rgba(0,0,0,.75)
          );
        }

        .hrms-orb {
          position: absolute;
          border-radius: 999px;
          pointer-events: none;
          filter: blur(1px);
        }

        .hrms-orb-one {
          width: 500px;
          height: 500px;
          top: -230px;
          left: -100px;
          background:
            radial-gradient(
              circle,
              rgba(88, 42, 180, 0.31),
              rgba(48, 19, 99, 0.18) 58%,
              transparent 72%
            );
        }

        .hrms-orb-two {
          width: 420px;
          height: 420px;
          right: -180px;
          bottom: -180px;
          background:
            radial-gradient(
              circle,
              rgba(104, 39, 204, 0.29),
              rgba(53, 19, 103, 0.14) 58%,
              transparent 73%
            );
        }

        .hrms-orb-three {
          width: 180px;
          height: 180px;
          right: 5%;
          top: 13%;
          background:
            radial-gradient(
              circle,
              rgba(88, 44, 220, 0.20),
              transparent 68%
            );
        }

        .hrms-particle {
          position: absolute;
          width: 38px;
          height: 38px;
          border-radius: 50%;
          background:
            radial-gradient(
              circle at 35% 30%,
              rgba(255,255,255,.85),
              rgba(161,112,255,.45) 16%,
              rgba(94,45,205,.24) 44%,
              transparent 72%
            );
          border: 1px solid rgba(180,145,255,.28);
          box-shadow:
            0 0 20px rgba(137,87,255,.48),
            inset 0 0 12px rgba(255,255,255,.16);
          animation: hrms-float 5s ease-in-out infinite;
          z-index: 2;
        }

        .particle-one {
          left: 4%;
          top: 78%;
        }

        .particle-two {
          left: 45%;
          top: 44%;
          width: 32px;
          height: 32px;
          animation-delay: -1.4s;
        }

        .particle-three {
          right: 8%;
          top: 28%;
          width: 34px;
          height: 34px;
          animation-delay: -2.1s;
        }

        .particle-four {
          right: 37%;
          bottom: 9%;
          width: 30px;
          height: 30px;
          animation-delay: -3s;
        }

        @keyframes hrms-float {
          0%,
          100% {
            transform: translate3d(0, 0, 0);
          }

          50% {
            transform: translate3d(0, -13px, 0);
          }
        }

        .hrms-brand {
          position: relative;
          z-index: 10;
          display: flex;
          align-items: center;
          gap: 14px;
          padding: 42px 0 0 4.5vw;
        }

        .hrms-brand-icon {
          width: 58px;
          height: 58px;
          display: grid;
          place-items: center;
          border-radius: 17px;

          background:
            linear-gradient(
              145deg,
              #7c3aed,
              #8b5cf6 48%,
              #9333ea
            );

          box-shadow:
            0 12px 35px rgba(105, 55, 235, 0.34),
            inset 0 1px 0 rgba(255,255,255,.22);
        }

        .hrms-brand-icon span {
          font-size: 30px;
          font-weight: 800;
        }

        .hrms-brand-name {
          font-size: 21px;
          font-weight: 800;
          letter-spacing: -0.3px;
        }

        .hrms-brand-subtitle {
          margin-top: 3px;
          font-size: 10px;
          letter-spacing: 1.5px;
          color: #9275d5;
          font-weight: 700;
        }

        .hrms-login-content {
          position: relative;
          z-index: 5;
          width: min(1240px, 91vw);
          margin: 105px auto 70px;
          display: grid;
          grid-template-columns: minmax(0, 1.08fr) minmax(480px, .92fr);
          gap: 80px;
          align-items: center;
        }

        .hrms-hero {
          padding-left: 22px;
        }

        .hrms-eyebrow {
          display: flex;
          align-items: center;
          gap: 10px;
          margin-bottom: 28px;
          color: #a875ff;
          font-size: 13px;
          font-weight: 800;
          letter-spacing: 1.1px;
        }

        .hrms-eyebrow svg {
          filter: drop-shadow(0 0 9px rgba(159, 98, 255, .7));
        }

        .hrms-hero h1 {
          margin: 0;
          font-size: clamp(52px, 5vw, 76px);
          line-height: .99;
          letter-spacing: -4px;
          font-weight: 800;
        }

        .hrms-hero h1 span {
          color: #a259ff;
          background:
            linear-gradient(
              100deg,
              #934cff,
              #b46bff 55%,
              #7b3ff0
            );
          -webkit-background-clip: text;
          background-clip: text;
          -webkit-text-fill-color: transparent;
        }

        .hrms-description {
          max-width: 690px;
          margin: 28px 0 42px;
          color: #a7a5c4;
          font-size: 17px;
          line-height: 1.7;
        }

        .hrms-feature-grid {
          width: 100%;
          max-width: 700px;
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 14px;
        }

        .hrms-feature-card {
          min-height: 100px;
          display: flex;
          align-items: center;
          gap: 17px;
          padding: 18px 20px;
          border-radius: 17px;
          border: 1px solid rgba(145, 113, 218, .18);
          background:
            linear-gradient(
              145deg,
              rgba(20, 17, 36, .82),
              rgba(10, 9, 22, .68)
            );
          box-shadow:
            inset 0 1px 0 rgba(255,255,255,.035);
          transition: .25s ease;
        }

        .hrms-feature-card:hover {
          transform: translateY(-2px);
          border-color: rgba(153, 94, 255, .42);
          box-shadow:
            0 14px 35px rgba(73, 31, 145, .18);
        }

        .hrms-feature-icon {
          flex: 0 0 48px;
          width: 48px;
          height: 48px;
          display: grid;
          place-items: center;
          border-radius: 14px;
          color: #b16aff;
          background:
            linear-gradient(
              145deg,
              rgba(110, 47, 205, .31),
              rgba(65, 29, 128, .25)
            );
          border: 1px solid rgba(155, 94, 255, .2);
        }

        .hrms-feature-title {
          color: #f5f2ff;
          font-size: 14px;
          font-weight: 750;
          margin-bottom: 6px;
        }

        .hrms-feature-text {
          color: #777395;
          font-size: 12px;
          line-height: 1.4;
        }

        .hrms-login-card {
          width: 100%;
          padding: 42px 46px 34px;
          border-radius: 26px;
          border: 1px solid rgba(148, 116, 218, .27);

          background:
            linear-gradient(
              145deg,
              rgba(17, 16, 30, .94),
              rgba(10, 9, 20, .94)
            );

          box-shadow:
            0 30px 80px rgba(0, 0, 0, .48),
            inset 0 1px 0 rgba(255,255,255,.035);

          backdrop-filter: blur(22px);
        }

        .hrms-card-top {
          display: flex;
          align-items: center;
          justify-content: space-between;
          margin-bottom: 31px;
        }

        .hrms-lock-box {
          width: 58px;
          height: 58px;
          display: grid;
          place-items: center;
          border-radius: 17px;
          color: #fff;

          background:
            linear-gradient(
              145deg,
              #8b3ffc,
              #9d4edd
            );

          box-shadow:
            0 14px 32px rgba(113, 47, 225, .36);
        }

        .hrms-status {
          display: flex;
          align-items: center;
          gap: 9px;
          padding: 9px 15px;
          border-radius: 999px;
          color: #38e5a1;
          font-size: 12px;
          font-weight: 700;
          border: 1px solid rgba(25, 211, 139, .28);
          background: rgba(14, 78, 57, .13);
        }

        .hrms-status span {
          width: 7px;
          height: 7px;
          border-radius: 50%;
          background: #36e39e;
          box-shadow: 0 0 10px #36e39e;
        }

        .hrms-card-eyebrow {
          color: #a96aff;
          font-size: 11px;
          font-weight: 800;
          letter-spacing: 1.7px;
          margin-bottom: 12px;
        }

        .hrms-card-heading h2 {
          margin: 0;
          color: #f8f7ff;
          font-size: 37px;
          line-height: 1.1;
          letter-spacing: -1.5px;
        }

        .hrms-card-heading p {
          margin: 10px 0 32px;
          color: #77748f;
          font-size: 15px;
        }

        .hrms-field-group {
          margin-bottom: 22px;
        }

        .hrms-field-group label {
          display: block;
          margin-bottom: 9px;
          color: #aaa7bd;
          font-size: 13px;
          font-weight: 700;
        }

        .hrms-input-wrap {
          position: relative;
          width: 100%;
        }

        .hrms-input-icon {
          position: absolute;
          z-index: 2;
          left: 17px;
          top: 50%;
          transform: translateY(-50%);
          color: #74718c;
          pointer-events: none;
        }

        .hrms-input-wrap input {
          width: 100%;
          height: 59px;
          padding: 0 48px 0 51px;
          border-radius: 14px;
          outline: none;

          color: #f4f1ff;
          background: #11101b;

          border: 1px solid rgba(129, 110, 181, .25);

          font-size: 14px;
          transition: .2s ease;
        }

        .hrms-input-wrap input::placeholder {
          color: #5e5a72;
        }

        .hrms-input-wrap input:focus {
          border-color: #8748ed;
          box-shadow:
            0 0 0 3px rgba(132, 69, 237, .11),
            0 0 25px rgba(111, 53, 209, .10);
        }

        .hrms-eye-btn {
          position: absolute;
          right: 14px;
          top: 50%;
          transform: translateY(-50%);
          width: 34px;
          height: 34px;
          display: grid;
          place-items: center;
          border: 0;
          background: transparent;
          color: #817c9a;
          cursor: pointer;
          border-radius: 8px;
        }

        .hrms-eye-btn:hover {
          color: #b77aff;
          background: rgba(139, 92, 246, .08);
        }

        .hrms-login-options {
          display: flex;
          align-items: center;
          justify-content: space-between;
          margin: 3px 0 27px;
        }

        .hrms-remember {
          display: flex;
          align-items: center;
          gap: 9px;
          color: #858198;
          font-size: 13px;
          cursor: pointer;
          user-select: none;
        }

        .hrms-remember input {
          position: absolute;
          opacity: 0;
          pointer-events: none;
        }

        .hrms-custom-checkbox {
          width: 17px;
          height: 17px;
          display: grid;
          place-items: center;
          border-radius: 4px;
          border: 1px solid #625b75;
          color: white;
          font-size: 12px;
          font-weight: 900;
          background: #100f1b;
        }

        .hrms-remember input:checked + .hrms-custom-checkbox {
          border-color: #9b52ff;
          background: #873eea;
          box-shadow: 0 0 13px rgba(137, 62, 234, .38);
        }

        .hrms-forgot {
          border: 0;
          background: transparent;
          padding: 0;
          color: #a96aff;
          font-size: 13px;
          cursor: pointer;
        }

        .hrms-forgot:hover {
          color: #c18cff;
          text-decoration: underline;
        }

        .hrms-error {
          margin: -10px 0 16px;
          padding: 11px 13px;
          border-radius: 10px;
          color: #ff9fae;
          background: rgba(185, 35, 68, .10);
          border: 1px solid rgba(235, 79, 106, .20);
          font-size: 12px;
        }

        .hrms-login-button {
          width: 100%;
          height: 61px;
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 12px;

          border: 0;
          border-radius: 14px;

          color: #fff;
          font-size: 15px;
          font-weight: 800;

          cursor: pointer;

          background:
            linear-gradient(
              100deg,
              #7036e9,
              #8845f4 48%,
              #9a48ee
            );

          box-shadow:
            0 17px 38px rgba(113, 52, 226, .28);

          transition:
            transform .2s ease,
            box-shadow .2s ease,
            opacity .2s ease;
        }

        .hrms-login-button:hover:not(:disabled) {
          transform: translateY(-2px);
          box-shadow:
            0 21px 45px rgba(119, 53, 232, .39);
        }

        .hrms-login-button:active:not(:disabled) {
          transform: translateY(0);
        }

        .hrms-login-button:disabled {
          opacity: .65;
          cursor: not-allowed;
        }

        .hrms-security-note {
          display: flex;
          justify-content: center;
          align-items: center;
          gap: 7px;
          margin-top: 27px;
          color: #656177;
          font-size: 11px;
        }

        .hrms-security-note svg {
          color: #20d59a;
        }

        @media (max-width: 1050px) {
          .hrms-login-content {
            grid-template-columns: 1fr;
            max-width: 720px;
            gap: 50px;
            margin-top: 75px;
          }

          .hrms-hero {
            padding-left: 0;
          }

          .hrms-login-card {
            max-width: 650px;
            margin: auto;
          }
        }

        @media (max-width: 650px) {
          .hrms-brand {
            padding: 25px 22px 0;
          }

          .hrms-brand-icon {
            width: 50px;
            height: 50px;
            border-radius: 14px;
          }

          .hrms-login-content {
            width: calc(100% - 32px);
            margin: 55px auto 40px;
          }

          .hrms-hero h1 {
            font-size: 47px;
            letter-spacing: -2.8px;
          }

          .hrms-description {
            font-size: 15px;
          }

          .hrms-feature-grid {
            grid-template-columns: 1fr;
          }

          .hrms-login-card {
            padding: 30px 22px 27px;
            border-radius: 21px;
          }

          .hrms-card-heading h2 {
            font-size: 31px;
          }

          .hrms-card-top {
            margin-bottom: 26px;
          }

          .hrms-login-options {
            gap: 15px;
          }

          .hrms-particle {
            display: none;
          }
        }
      `}</style>
    </div>
  );
}
