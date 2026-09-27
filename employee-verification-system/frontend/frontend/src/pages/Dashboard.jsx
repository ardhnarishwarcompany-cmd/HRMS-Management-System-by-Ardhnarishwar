import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { toast } from "react-toastify";
import Navbar from "../components/Navbar";
import Sidebar from "../components/sidebar";
import HRMS_API from "../services/hrmsApi";

const statusLabel = (value) => {
  const v = String(value || "").toLowerCase();
  if (v.includes("reject") || v.includes("attention")) return "Action Required";
  if (v.includes("verif") || v.includes("approved")) return "Verified";
  if (v.includes("progress") || v.includes("pending")) return "In Progress";
  return "Not Started";
};

function Dashboard() {
  const [profile, setProfile] = useState(null);
  const [docs, setDocs] = useState([]);
  const [loading, setLoading] = useState(true);

  const load = async () => {
    try {
      const [p, d] = await Promise.all([
        HRMS_API.get("/employee/profile"),
        HRMS_API.get("/employee/verification"),
      ]);
      setProfile(p.data?.data || null);
      setDocs(d.data?.documents || []);
      if (p.data?.data?.employee) {
        localStorage.setItem("name", p.data.data.employee.name || "Employee");
        localStorage.setItem("email", p.data.data.employee.email || "");
        localStorage.setItem("employeeId", String(p.data.data.employee.id));
        localStorage.setItem("department", p.data.data.employee.department || "");
      }
    } catch (error) {
      toast.error(error.response?.data?.message || "Unable to load verification dashboard");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(); }, []);

  const employee = profile?.employee;
  const verification = profile?.verification || {};
  const total = verification.documentsTotal || docs.length || 0;
  const verified = verification.documentsVerified || docs.filter((d) => d.status === "Verified").length;
  const pending = docs.filter((d) => d.status === "Pending").length;
  const rejected = docs.filter((d) => d.status === "Rejected").length;
  const overall = statusLabel(verification.overall);
  const progress = total ? Math.round((verified / total) * 100) : 0;

  return <>
    <Navbar />
    <Sidebar />
    <main className="employee-content">
      <div className="employee-hero">
        <div className="hero-copy">
          <div className="hero-kicker"><span /> EMPLOYEE VERIFICATION</div>
          <h1>Welcome, {employee?.name?.split(" ")[0] || "Employee"}.</h1>
          <p>Complete your employment verification and keep track of documents submitted for Super Admin review.</p>
          <div className="hero-pills">
            <span>♙ {employee?.employeeCode || "Employee"}</span>
            <span>▦ {employee?.department || "Department"}</span>
            <span>● {overall}</span>
          </div>
        </div>
        <div className="hero-visual"><div className="hero-ring"><span>✓</span></div><small>SECURE</small></div>
      </div>

      {loading ? <div className="evs-loading">Loading your verification workspace…</div> : <>
        <section className="employee-stats">
          <div className="employee-stat stat-accent"><div className="stat-icon">▣</div><small>TOTAL DOCUMENTS</small><strong>{total}</strong><span>Submitted for verification</span></div>
          <div className="employee-stat"><div className="stat-icon">✓</div><small>VERIFIED</small><strong>{verified}</strong><span>Approved documents</span></div>
          <div className="employee-stat"><div className="stat-icon">◷</div><small>PENDING</small><strong>{pending}</strong><span>Awaiting Super Admin review</span></div>
          <div className="employee-stat"><div className="stat-icon">!</div><small>ACTION REQUIRED</small><strong>{rejected}</strong><span>Needs your attention</span></div>
        </section>

        <section className="employee-main-grid">
          <div className="employee-panel">
            <div className="panel-heading"><div><h2>Verification Progress</h2><p>Your submitted documents and current review status.</p></div><span className={`status-badge ${overall.toLowerCase().replaceAll(" ", "-")}`}>{overall}</span></div>
            <div className="progress-track"><span style={{ width: `${progress}%` }} /></div>
            <div className="progress-meta"><b>{progress}% complete</b><span>{verified} of {total} documents verified</span></div>
            <div className="verification-list">
              <div><span className="list-icon">▤</span><div><b>Employment Documents</b><small>{total ? `${total} document${total > 1 ? "s" : ""} submitted` : "No documents submitted yet"}</small></div><strong>{total ? `${verified}/${total}` : "—"}</strong></div>
              <div><span className="list-icon">ID</span><div><b>Identity Verification</b><small>Aadhaar / PAN verification</small></div><strong>{statusLabel(verification.identity ? [verification.identity.aadhaar_status, verification.identity.pan_status].join(" ") : "")}</strong></div>
              <div><span className="list-icon">BG</span><div><b>Background Verification</b><small>Managed by Super Admin</small></div><strong>{statusLabel(verification.background?.[0]?.status)}</strong></div>
            </div>
          </div>

          <div className="employee-panel quick-panel">
            <div className="panel-heading"><div><h2>Quick Actions</h2><p>Manage your verification steps.</p></div></div>
            <Link to="/my-verification" className="employee-action"><span>↥</span><div><b>Submit Documents</b><small>Upload documents for verification</small></div><i>→</i></Link>
            <Link to="/profile" className="employee-action"><span>◉</span><div><b>My Profile</b><small>View your employee information</small></div><i>→</i></Link>
            <div className="admin-note"><span>✓</span><div><b>Super Admin Review</b><small>Every submitted document is routed to the Super Admin verification queue.</small></div></div>
          </div>
        </section>

        <section className="employee-panel recent-panel">
          <div className="panel-heading"><div><h2>Recent Submissions</h2><p>Latest documents submitted from your account.</p></div><Link to="/my-verification" className="outline-btn">View all →</Link></div>
          {docs.length ? <div className="recent-table"><div className="recent-head"><span>DOCUMENT</span><span>SUBMITTED</span><span>STATUS</span></div>{docs.slice(0, 5).map((d) => <div className="recent-row" key={d.id}><div><b>{d.doc_type}</b><small>Verification document #{d.id}</small></div><span>{d.created_at ? new Date(d.created_at).toLocaleDateString() : "—"}</span><span className={`mini-status ${String(d.status || "Pending").toLowerCase()}`}>{d.status || "Pending"}</span></div>)}</div> : <div className="empty-state"><div>▤</div><b>No documents submitted yet</b><span>Upload your required verification documents to start the process.</span><Link to="/my-verification" className="primary-btn">Submit a document</Link></div>}
        </section>
      </>}
    </main>
  </>;
}

export default Dashboard;
