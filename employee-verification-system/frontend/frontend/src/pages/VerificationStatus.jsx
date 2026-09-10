import { useEffect, useState } from "react";
import { toast } from "react-toastify";
import Navbar from "../components/Navbar";
import Sidebar from "../components/Sidebar";
import API from "../services/hrmsApi";

const badge = (status) => {
  const s = String(status || "Not Submitted");
  const cls = s === "Verified" || s === "Fully Verified" ? "verified" : s === "Rejected" || s === "Action Required" ? "rejected" : s === "Pending" || s === "Pending Approval" || s === "In Progress" ? "pending" : "not-started";
  return <span className={`mini-status ${cls}`}>{s}</span>;
};

export default function VerificationStatus() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const load = async () => { try { const r = await API.get("/employee/verification/status"); setData(r.data); } catch(e) { toast.error(e.response?.data?.message || "Unable to load verification status"); } finally { setLoading(false); } };
  useEffect(()=>{load(); const t=setInterval(load,15000); return ()=>clearInterval(t);},[]);
  const s = data?.statuses || {};
  const detailItems = [
    ["Documents", s.documents, "Employment & education documents"],
    ["Identity Details", s.identity, "Aadhaar / PAN verification"],
    ["Graduation", s.graduation, "Graduation document"],
    ["Post Graduation", s.postGraduation, "Post-graduation document"],
    ["Bank Details", s.bank, "Bank details / statement"],
    ["Background Verification", s.background, "Super Admin background review"],
  ];
  return <><Navbar/><Sidebar/><main className="employee-content">
    <div className="simple-page-heading"><div><div className="hero-kicker dark"><span/> VERIFICATION STATUS</div><h1>Verification Status Dashboard</h1><p>Live progress across your documents, identity details and background verification.</p></div></div>
    {loading ? <div className="evs-loading">Loading verification data…</div> : <>
      <section className="employee-stats">
        <div className="employee-stat stat-accent"><div className="stat-icon">✓</div><small>OVERALL STATUS</small><strong className="status-text-small">{s.overall || "Not Started"}</strong><span>Current verification stage</span></div>
        <div className="employee-stat"><div className="stat-icon">▤</div><small>DOCUMENTS</small><strong className="status-text-small">{s.documents || "Not Submitted"}</strong><span>Employment documents</span></div>
        <div className="employee-stat"><div className="stat-icon">ID</div><small>IDENTITY</small><strong className="status-text-small">{s.identity || "Not Submitted"}</strong><span>Aadhaar / PAN</span></div>
        <div className="employee-stat"><div className="stat-icon">BG</div><small>BACKGROUND</small><strong className="status-text-small">{s.background || "Not Submitted"}</strong><span>Super Admin review</span></div>
      </section>
      <section className="employee-panel recent-panel">
        <div className="panel-heading"><div><h2>Verification Checklist</h2><p>Your live status by verification category.</p></div>{badge(s.overall)}</div>
        <div className="verification-list">
          {detailItems.map(([title, status, desc]) => (
            <div key={title}><span className="list-icon">{title === "Identity Details" ? "ID" : title === "Background Verification" ? "BG" : "✓"}</span><div><b>{title}</b><small>{desc}</small></div><strong>{badge(status)}</strong></div>
          ))}
        </div>
      </section>
      <section className="employee-panel recent-panel">
        <div className="panel-heading"><div><h2>Employee Information</h2><p>Verification account linked to your HRMS profile.</p></div></div>
        <div className="detail-grid"><div><small>Name</small><b>{data?.employee?.name || "—"}</b></div><div><small>Employee Code</small><b>{data?.employee?.employeeCode || "—"}</b></div><div><small>Department</small><b>{data?.employee?.department || "—"}</b></div><div><small>Email</small><b>{data?.employee?.email || "—"}</b></div></div>
      </section>
    </>}
  </main></>;
}
