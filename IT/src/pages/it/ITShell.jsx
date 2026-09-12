import { useEffect, useMemo, useState } from "react";
import { NavLink, Outlet, useLocation, useNavigate } from "react-router-dom";
import {
  Bell, Cake, ChevronDown, ChevronRight, ClipboardList, CalendarCheck,
  Timer, GitPullRequest, Flag, BarChart3, Bug, Rocket, BookOpen, Video,
  FileBarChart, Code2, MessageSquare, Fingerprint, Award, ScrollText,
  Target, Briefcase, FileText, MessageCircleWarning, LayoutDashboard,
  LogOut, Search, TrendingUp, X, Moon, Sun, Menu, PanelLeftClose, PanelLeftOpen
} from "lucide-react";
import { getTodayBirthdays, markNotificationsRead } from "../../services/notificationService";
import ThemeToggle from "../../components/common/ThemeToggle";
import ErrorBoundary from "../../components/common/ErrorBoundary";
import { useHrAuth } from "../../context/HrAuthContext";

export const IT_MENU_ITEMS = [
  ["Task Assignment", "/it/tasks", ClipboardList],
  ["Daily Work Submission", "/it/daily-work", CalendarCheck],
  ["Timesheet", "/it/timesheet", Timer],
  ["Code Review Status", "/it/code-reviews", GitPullRequest],
  ["Project Milestone Tracker", "/it/milestones", Flag],
  ["Performance Reporting", "/it/performance-report", BarChart3],
  ["Bug Reporting", "/it/bugs", Bug],
  ["Feature Deployment Log", "/it/deployments", Rocket],
  ["SOP Management", "/it/sop", BookOpen],
  ["Video Documentation", "/it/videos", Video],
  ["Project Reports", "/it/project-reports", FileBarChart],
  ["Source Code", "/it/source-code", Code2],
  ["Chat", "/chat", MessageSquare],
  ["Automated Attendance", "/attendance", Fingerprint],
  ["Performance", "/my-performance", Award],
  ["Work Policy", "/work-policy", ScrollText],
  ["My Targets", "/my-targets", Target],
  ["My assignments", "/my-assignments", Briefcase],
  ["EOD", "/my-eod", FileText],
  ["Complaint box", "/complaint", MessageCircleWarning],
];

function ITSidebar({ collapsed, mobileOpen, onClose }) {
  const navigate = useNavigate();
  const location = useLocation();

  return (
    <>
      {mobileOpen && <button aria-label="Close menu" onClick={onClose} className="it-sidebar-overlay" />}
      <aside className={`it-sidebar ${collapsed ? "is-collapsed" : ""} ${mobileOpen ? "is-mobile-open" : ""}`}>
        <div className="it-brand" onClick={() => navigate("/dashboard")} role="button" tabIndex={0}>
          <img src="/logo.jpeg" alt="Ardhnarishwar logo" />
          {!collapsed && <div><strong>ARDHNARISHWAR</strong><span>HRMS IT PANEL</span></div>}
        </div>

        <div className="it-sidebar-section">WORKSPACE</div>
        <NavLink to="/dashboard" end className={({ isActive }) => `it-nav-link ${isActive ? "active" : ""}`} onClick={onClose}>
          <LayoutDashboard size={18} /><span>Dashboard</span><ChevronDown className="it-nav-chevron" size={15} />
        </NavLink>
        <NavLink to="/dashboard" end className="it-subnav-link" onClick={onClose}>
          <span className="it-subnav-dot" /> <span>Overview</span>
        </NavLink>

        <div className="it-sidebar-section">IT FEATURES</div>
        <div className="it-sidebar-scroll">
          {IT_MENU_ITEMS.map(([title, path, Icon]) => {
            const active = location.pathname === path || (path !== "/dashboard" && location.pathname.startsWith(`${path}/`));
            return (
              <NavLink key={path} to={path} onClick={onClose} className={`it-feature-link ${active ? "active" : ""}`}>
                <Icon size={17} /><span>{title}</span>
              </NavLink>
            );
          })}
        </div>
      </aside>
    </>
  );
}

function ITTopbar({ collapsed, setCollapsed, onMobileMenu, notifications, openNotifications }) {
  const { employee, logout } = useHrAuth();
  const navigate = useNavigate();
  const stored = useMemo(() => {
    try { return JSON.parse(localStorage.getItem("hrms_it_User") || "{}"); } catch { return {}; }
  }, []);
  const user = employee || stored || {};
  const displayName = user.name || "Demo User";
  const displayEmail = user.email || "demo@hrms.com";
  const initial = displayName.charAt(0).toUpperCase();

  const handleLogout = () => { logout(); navigate("/"); };

  return (
    <header className={`it-topbar ${collapsed ? "content-collapsed" : ""}`}>
      <div className="it-topbar-inner">
        <button className="it-mobile-menu" onClick={onMobileMenu} aria-label="Open sidebar"><Menu size={21} /></button>
        <button className="it-collapse-btn" onClick={() => setCollapsed(v => !v)} aria-label="Toggle sidebar">
          {collapsed ? <PanelLeftOpen size={19} /> : <PanelLeftClose size={19} />}
        </button>
        <div className="it-search">
          <Search size={18} /><input placeholder="Search IT features..." aria-label="Search IT features" />
        </div>
        <div className="it-top-actions">
          <ThemeToggle />
          <button className="it-icon-btn" onClick={openNotifications} aria-label="Notifications">
            <Bell size={18} />
            {notifications.length > 0 && <span className="it-notification-dot" />}
          </button>
          <button className="it-user-box" onClick={() => navigate("/dashboard")}>
            <span className="it-avatar">{initial}</span>
            <span className="it-user-copy"><strong>{displayName}</strong><small>{displayEmail}</small></span>
            <ChevronDown size={15} />
          </button>
          <button className="it-logout" onClick={handleLogout}><LogOut size={15} /><span>Logout</span></button>
        </div>
      </div>
    </header>
  );
}

export function ITLayout() {
  const [collapsed, setCollapsed] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);
  const [notifications, setNotifications] = useState([]);
  const [openNotifications, setOpenNotifications] = useState(false);

  useEffect(() => {
    getTodayBirthdays().then(res => setNotifications(res?.data?.data || [])).catch(() => {});
  }, []);

  const toggleNotifications = async () => {
    setOpenNotifications(v => !v);
    try {
      await markNotificationsRead();
      setNotifications(prev => prev.map(n => ({ ...n, is_read: 1 })));
    } catch {}
  };

  return (
    <div className="it-app-shell">
      <ITSidebar collapsed={collapsed} mobileOpen={mobileOpen} onClose={() => setMobileOpen(false)} />
      <ITTopbar
        collapsed={collapsed}
        setCollapsed={setCollapsed}
        onMobileMenu={() => setMobileOpen(true)}
        notifications={notifications}
        openNotifications={toggleNotifications}
      />

      {openNotifications && (
        <>
          <button className="it-notification-overlay" onClick={() => setOpenNotifications(false)} aria-label="Close notifications" />
          <aside className="it-notification-panel">
            <div className="it-notification-head"><div><strong>Today&apos;s Birthdays</strong><small>Notifications & updates</small></div><button onClick={() => setOpenNotifications(false)}><X size={18} /></button></div>
            <div className="it-notification-body">
              {notifications.length === 0 ? <p className="it-empty">No birthdays today</p> : notifications.map(n => <div className="it-birthday" key={n.id}><Cake size={17} /><strong>{n.name}</strong></div>)}
            </div>
          </aside>
        </>
      )}

      <main className={`it-main ${collapsed ? "content-collapsed" : ""}`}>
        <ErrorBoundary>
          <Outlet />
        </ErrorBoundary>
      </main>
    </div>
  );
}

export default function ITShell({ title, subtitle, icon: Icon, action, children }) {
  return (
    <div className="it-page">
      <div className="it-page-heading">
        <div>
          <h1>{Icon && <Icon size={24} />}{title}</h1>
          {subtitle && <p>{subtitle}</p>}
        </div>
        {action}
      </div>
      {children}
    </div>
  );
}
