import { useEffect, useMemo, useRef, useState } from "react";
import { NavLink, useLocation, useNavigate } from "react-router-dom";
import { useEmployeeAuth } from "../../context/EmployeeAuthContext";
import {
  Bell,
  CalendarDays,
  ClipboardList,
  FileText,
  Fingerprint,
  LayoutDashboard,
  LogOut,
  Menu,
  Palmtree,
  Target,
  UserCircle2,
  WalletCards,
  X,
  BarChart3,
  BookOpen,
  MessageSquare,
  ChevronRight,
  CheckCheck,
} from "lucide-react";
import {
  fetchNotifications,
  markNotificationRead,
  markAllNotificationsRead,
} from "../../api/notifications.js";

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

function timeAgo(dateStr) {
  const diffMs = Date.now() - new Date(dateStr).getTime();
  const mins = Math.floor(diffMs / 60000);
  if (mins < 1) return "just now";
  if (mins < 60) return `${mins}m ago`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `${hrs}h ago`;
  const days = Math.floor(hrs / 24);
  return `${days}d ago`;
}

export default function EmployeeNavbar() {
  const navigate = useNavigate();
  const { pathname } = useLocation();
  const { employee, logout } = useEmployeeAuth();
  const [mobileOpen, setMobileOpen] = useState(false);
  const [notifOpen, setNotifOpen] = useState(false);
  const [notifications, setNotifications] = useState([]);
  const [unreadCount, setUnreadCount] = useState(0);
  const [loadingNotifs, setLoadingNotifs] = useState(false);
  const pollRef = useRef(null);

  useEffect(() => {
    document.body.classList.add("employee-shell-active");
    return () => document.body.classList.remove("employee-shell-active");
  }, []);

  useEffect(() => {
    setMobileOpen(false);
    setNotifOpen(false);
  }, [pathname]);

  const loadNotifications = async () => {
    try {
      setLoadingNotifs(true);
      const res = await fetchNotifications();
      setNotifications(res.data?.data || []);
      setUnreadCount(res.data?.unreadCount || 0);
    } catch (err) {
      console.error("Failed to load notifications", err);
    } finally {
      setLoadingNotifs(false);
    }
  };

  useEffect(() => {
    loadNotifications();
    pollRef.current = setInterval(loadNotifications, 30000);
    return () => clearInterval(pollRef.current);
  }, []);

  const handleBellClick = () => {
    setNotifOpen((open) => !open);
  };

  const handleNotifClick = async (n) => {
    if (!n.isRead) {
      try {
        await markNotificationRead(n.id);
        setNotifications((prev) =>
          prev.map((item) => (item.id === n.id ? { ...item, isRead: 1 } : item))
        );
        setUnreadCount((c) => Math.max(0, c - 1));
      } catch (err) {
        console.error("Failed to mark notification read", err);
      }
    }
    if (n.link) {
      setNotifOpen(false);
      navigate(n.link);
    }
  };

  const handleMarkAllRead = async () => {
    try {
      await markAllNotificationsRead();
      setNotifications((prev) => prev.map((item) => ({ ...item, isRead: 1 })));
      setUnreadCount(0);
    } catch (err) {
      console.error("Failed to mark all read", err);
    }
  };

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
        <div className="employee-brand employee-brand-fixed">
          <div className="employee-brand-logo employee-brand-logo-fixed">
            <img
              src="/logo.jpeg"
              alt="Ardhnarishwar HRMS"
            />
          </div>

          <div className="employee-brand-copy employee-brand-copy-fixed">
            <div className="employee-brand-name employee-brand-name-fixed">
              ARDHNARISHWAR
            </div>

            <div className="employee-brand-subtitle employee-brand-subtitle-fixed">
              HRMS Employee<br />
              Portal
            </div>
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
          <div className="employee-notif-wrap" style={{ position: "relative" }}>
            <button
              className="employee-icon-btn employee-notification-btn"
              onClick={handleBellClick}
              aria-label="Notifications"
              title="Notifications"
            >
              <Bell size={20} />
              {unreadCount > 0 && (
                <span className="employee-notification-dot" />
              )}
            </button>

            {notifOpen && (
              <>
                <div className="employee-popover-backdrop" onClick={() => setNotifOpen(false)} />
                <div
                  className="employee-notif-panel"
                  style={{
                    position: "absolute",
                    right: 0,
                    top: "calc(100% + 10px)",
                    width: "340px",
                    maxHeight: "420px",
                    overflowY: "auto",
                    background: "var(--card-bg, #fff)",
                    border: "1px solid rgba(0,0,0,0.08)",
                    borderRadius: "12px",
                    boxShadow: "0 12px 32px rgba(0,0,0,0.15)",
                    zIndex: 50,
                  }}
                >
                  <div
                    style={{
                      display: "flex",
                      justifyContent: "space-between",
                      alignItems: "center",
                      padding: "12px 14px",
                      borderBottom: "1px solid rgba(0,0,0,0.06)",
                    }}
                  >
                    <strong style={{ fontSize: "14px" }}>Notifications</strong>
                    {unreadCount > 0 && (
                      <button
                        onClick={handleMarkAllRead}
                        style={{
                          display: "flex",
                          alignItems: "center",
                          gap: "4px",
                          fontSize: "12px",
                          background: "none",
                          border: "none",
                          cursor: "pointer",
                          color: "#4f46e5",
                        }}
                      >
                        <CheckCheck size={14} /> Mark all read
                      </button>
                    )}
                  </div>

                  {loadingNotifs && (
                    <div style={{ padding: "16px", fontSize: "13px", opacity: 0.7 }}>
                      Loading...
                    </div>
                  )}

                  {!loadingNotifs && notifications.length === 0 && (
                    <div style={{ padding: "24px 14px", fontSize: "13px", opacity: 0.6, textAlign: "center" }}>
                      No notifications yet
                    </div>
                  )}

                  {!loadingNotifs &&
                    notifications.map((n) => (
                      <div
                        key={n.id}
                        onClick={() => handleNotifClick(n)}
                        style={{
                          padding: "12px 14px",
                          borderBottom: "1px solid rgba(0,0,0,0.05)",
                          cursor: "pointer",
                          background: n.isRead ? "transparent" : "rgba(79,70,229,0.06)",
                        }}
                      >
                        <div style={{ display: "flex", justifyContent: "space-between", gap: "8px" }}>
                          <strong style={{ fontSize: "13px" }}>{n.title}</strong>
                          {!n.isRead && (
                            <span
                              style={{
                                width: "8px",
                                height: "8px",
                                borderRadius: "50%",
                                background: "#4f46e5",
                                flexShrink: 0,
                                marginTop: "4px",
                              }}
                            />
                          )}
                        </div>
                        {n.message && (
                          <div style={{ fontSize: "12.5px", opacity: 0.75, marginTop: "4px" }}>
                            {n.message}
                          </div>
                        )}
                        <div style={{ fontSize: "11px", opacity: 0.5, marginTop: "6px" }}>
                          {timeAgo(n.createdAt)}
                        </div>
                      </div>
                    ))}
                </div>
              </>
            )}
          </div>

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
