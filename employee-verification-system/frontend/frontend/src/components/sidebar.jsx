import { NavLink } from "react-router-dom";
import { useEffect, useState } from "react";

const Item = ({ to, icon, children, onClick }) => <NavLink to={to} className={({ isActive }) => isActive ? "active" : ""} onClick={onClick}><span className="side-icon">{icon}</span>{children}</NavLink>;

function Sidebar() {
  const [open, setOpen] = useState(false);
  useEffect(() => {
    const toggle = () => setOpen((v) => !v);
    window.addEventListener("toggle-sidebar", toggle);
    return () => window.removeEventListener("toggle-sidebar", toggle);
  }, []);
  return <>
    <div className={`sidebar-overlay ${open ? "show" : ""}`} onClick={() => setOpen(false)} />
    <aside className={`sidebar employee-sidebar ${open ? "open" : ""}`}>
      <div className="sidebar-brand">
        <img src="/logo.png" alt="Ardhnarishwar" />
        <div><b>ARDHNARISHWAR</b><small>Employee Verification</small></div>
      </div>
      <div className="side-section">Workspace</div>
      <Item to="/dashboard" icon="⌂" onClick={() => setOpen(false)}>Dashboard</Item>
      <Item to="/my-verification" icon="▣" onClick={() => setOpen(false)}>My Verification</Item>
      <Item to="/verification-status" icon="✓" onClick={() => setOpen(false)}>Verification Status</Item>
      <div className="side-section">Verification</div>
      <Item to="/identity-verification" icon="ID" onClick={() => setOpen(false)}>Identity Details</Item>
      <Item to="/background-verification" icon="BG" onClick={() => setOpen(false)}>Background Verification</Item>
      <div className="side-section">Account</div>
      <Item to="/profile" icon="◉" onClick={() => setOpen(false)}>My Profile</Item>
      <div className="sidebar-bottom"><span>SECURE PORTAL</span><small>Employee access · HRMS connected</small></div>
    </aside>
  </>;
}
export default Sidebar;
