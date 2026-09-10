import { useEffect, useMemo, useState } from "react";
import { NavLink, useLocation, useNavigate } from "react-router-dom";
import { useEmployeeAuth } from "../../context/EmployeeAuthContext";
import { useTheme } from "../../context/ThemeContext";
import {
  Bell,
  CalendarDays,
  ClipboardList,
  FileText,
  Fingerprint,
  LayoutDashboard,
  LogOut,
  Menu,
  Moon,
  Palmtree,
  Sun,
  Target,
  UserCircle2,
  WalletCards,
  X,
  BarChart3,
  BookOpen,
  MessageSquare,
  ChevronRight,
} from "lucide-react";

const NAV_ITEMS = [
  { to: "/dashboard", label: "Dashboard", icon: LayoutDashboard },
  { to: "/assignments", label: "My Assignments", icon: ClipboardList },
  { to: "/eod", label: "My EOD", icon: FileText },
  { to: "/targets", label: "My Targets", icon: Target },
  { to: "/performance", label: "Performance", icon: BarChart3 },
  { to: "/sops", label: "SOP Library", icon: BookOpen },
  { to: "/attendance", label: "Attendance", icon: Fingerprint },
  { to: "/leave", label: "Leave Management", icon: CalendarDays },
  { to: "/compensation", label: "Compensation", icon: WalletCards },
  { to: "/chat", label: "AI Chat", icon: MessageSquare },
  { to: "/profile", label: "My Profile", icon: UserCircle2 },
];

const SunIcon = ({ size = 18, ...props }) => <Sun size={size} {...props} />;
const MoonIcon = ({ size = 18, ...props }) => <Moon size={size} {...props} />;

export default function EmployeeNavbar() {
  const navigate = useNavigate();
  const { pathname } = useLocation();
  const { employee, logout } = useEmployeeAuth();
  const { resolved, setTheme } = useTheme();
  const [mobileOpen, setMobileOpen] = useState(false);
  const [themeOpen, setThemeOpen] = useState(false);

  useEffect(() => {
    document.body.classList.add("employee-shell-active");
    return () => document.body.classList.remove("employee-shell-active");
  }, []);

  useEffect(() => {
    setMobileOpen(false);
    setThemeOpen(false);
  }, [pathname]);

  const pageTitle = useMemo(() => {
    const found = NAV_ITEMS.find((item) => item.to === pathname);
    return found?.label || "Dashboard";
  }, [pathname]);

  const initials = (employee?.name || "Employee")
    .split(" ")
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0]?.toUpperCase())
    .join("") || "E";

  const handleLogout = () => {
    logout();
    navigate("/login");
  };

  return (
    <>
      <aside className="employee-sidebar" aria-label="Employee navigation">
        <div className="employee-brand">
          <div className="employee-brand-logo">
            <img src="/logo.jpeg" alt="ArdhnariShwar" />
          </div>
          <div className="employee-brand-copy">
            <div className="employee-brand-name">ARDHNARISHWAR</div>
            <div className="employee-brand-subtitle">Employee Portal</div>
          </div>
        </div>

        <div className="employee-nav-scroll">
          <div className="employee-nav-label">WORKSPACE</div>
          <nav className="employee-nav-list">
            {NAV_ITEMS.map(({ to, label, icon: Icon }) => (
              <NavLink
                key={to}
                to={to}
                className={({ isActive }) =>
                  `employee-nav-link ${isActive ? "is-active" : ""}`
                }
              >
                <Icon size={18} strokeWidth={1.9} />
                <span>{label}</span>
                <ChevronRight className="employee-nav-arrow" size={15} />
              </NavLink>
            ))}
          </nav>
        </div>

        <div className="employee-sidebar-footer">
          <button className="employee-sidebar-profile" onClick={() => navigate("/profile")}>
            <span className="employee-avatar employee-avatar-small">{initials}</span>
            <span className="employee-sidebar-profile-copy">
              <strong>{employee?.name || "Employee"}</strong>
              <small>{employee?.department || "Employee"}</small>
            </span>
            <ChevronRight size={15} />
          </button>
        </div>
      </aside>

      <div className={`employee-mobile-drawer ${mobileOpen ? "is-open" : ""}`}>
        <div className="employee-mobile-overlay" onClick={() => setMobileOpen(false)} />
        <aside className="employee-mobile-panel">
          <div className="employee-mobile-panel-head">
            <div className="employee-brand-copy">
              <div className="employee-brand-name">ARDHNARISHWAR</div>
              <div className="employee-brand-subtitle">Employee Portal</div>
            </div>
            <button className="employee-icon-btn" onClick={() => setMobileOpen(false)} aria-label="Close menu">
              <X size={20} />
            </button>
          </div>
          <div className="employee-nav-label">WORKSPACE</div>
          <nav className="employee-nav-list">
            {NAV_ITEMS.map(({ to, label, icon: Icon }) => (
              <NavLink
                key={to}
                to={to}
                className={({ isActive }) => `employee-nav-link ${isActive ? "is-active" : ""}`}
              >
                <Icon size={18} />
                <span>{label}</span>
              </NavLink>
            ))}
          </nav>
        </aside>
      </div>

      <header className="employee-topbar">
        <div className="employee-topbar-left">
          <button
            className="employee-mobile-menu employee-icon-btn"
            onClick={() => setMobileOpen(true)}
            aria-label="Open menu"
          >
            <Menu size={21} />
          </button>
          <div>
            <div className="employee-page-title">{pageTitle}</div>
            <div className="employee-breadcrumb">Employee Workspace</div>
          </div>
        </div>

        <div className="employee-topbar-right">
          <div className="employee-theme-wrap">
            <button
              className="employee-icon-btn"
              onClick={() => setThemeOpen((open) => !open)}
              aria-label="Change theme"
              title="Change theme"
            >
              {resolved === "dark" ? <MoonIcon /> : <SunIcon />}
            </button>
            {themeOpen && (
              <>
                <div className="employee-popover-backdrop" onClick={() => setThemeOpen(false)} />
                <div className="employee-theme-menu">
                  <button onClick={() => { setTheme("light"); setThemeOpen(false); }}>
                    <SunIcon /> Light
                  </button>
                  <button onClick={() => { setTheme("dark"); setThemeOpen(false); }}>
                    <MoonIcon /> Dark
                  </button>
                </div>
              </>
            )}
          </div>

          <button className="employee-icon-btn employee-notification-btn" aria-label="Notifications" title="Notifications">
            <Bell size={20} />
            <span className="employee-notification-dot" />
          </button>

          <button className="employee-user-block" onClick={() => navigate("/profile")}>
            <span className="employee-avatar">{initials}</span>
            <span className="employee-user-copy">
              <strong>{employee?.name || "Employee"}</strong>
              <small>{employee?.email || employee?.department || "Employee"}</small>
            </span>
          </button>

          <button className="employee-logout-btn" onClick={handleLogout}>
            <LogOut size={17} />
            <span>Logout</span>
          </button>
        </div>
      </header>
    </>
  );
}
