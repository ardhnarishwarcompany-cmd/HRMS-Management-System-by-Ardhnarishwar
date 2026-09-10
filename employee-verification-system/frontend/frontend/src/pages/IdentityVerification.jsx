import { useEffect, useState } from "react";
import { toast } from "react-toastify";
import Navbar from "../components/Navbar";
import Sidebar from "../components/Sidebar";
import API from "../services/hrmsApi";

const pill = (value) => {
  const v = String(value || "Not Submitted");
  const cls = v === "Verified" ? "verified" : v === "Rejected" ? "rejected" : v.includes("Pending") ? "pending" : "not-started";
  return <span className={`mini-status ${cls}`}>{v}</span>;
};

export default function IdentityVerification() {
  const [employee, setEmployee] = useState(null);
  const [record, setRecord] = useState(null);
  const [form, setForm] = useState({ aadhaar_number: "", pan_number: "" });
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  const load = async () => {
    try {
      const r = await API.get("/employee/verification/identity");
      setEmployee(r.data?.employee || null);
      setRecord(r.data?.record || null);
    } catch (e) {
      console.error("Identity load failed", e);
      toast.error(e.response?.data?.message || "Unable to load identity details");
    }
    finally { setLoading(false); }
  };
  useEffect(() => { load(); }, []);

  const submit = async (e) => {
    e.preventDefault();
    if (!form.aadhaar_number.trim() && !form.pan_number.trim()) return toast.error("Enter Aadhaar or PAN");
    try {
      setSaving(true);
      await API.post("/employee/verification/identity", form);
      toast.success("Identity details sent to Super Admin for verification");
      setForm({ aadhaar_number: "", pan_number: "" });
      load();
    } catch (e) { toast.error(e.response?.data?.message || "Identity submission failed"); }
    finally { setSaving(false); }
  };

  return <><Navbar /><Sidebar /><main className="employee-content">
    <div className="simple-page-heading"><div><div className="hero-kicker dark"><span /> IDENTITY VERIFICATION</div><h1>Identity Details</h1><p>Submit your Aadhaar and PAN details securely. Super Admin will review and update the verification status.</p></div></div>
    {loading ? <div className="evs-loading">Loading identity details…</div> : <>
      <section className="employee-panel upload-panel">
        <div className="panel-heading"><div><h2>Submit Aadhaar / PAN</h2><p>Your numbers are masked after submission and only the verification status is shown here.</p></div><span className="status-badge in-progress">SUPER ADMIN REVIEW</span></div>
        <div className="profile-tags" style={{marginBottom:18}}><span>{employee?.name || "Employee"}</span><span>{employee?.employeeCode || "Employee ID"}</span><span>{employee?.department || "Department"}</span></div>
        <form onSubmit={submit} className="upload-form-grid">
          <label>Aadhaar Number<input inputMode="numeric" maxLength={12} value={form.aadhaar_number} onChange={e => setForm({...form, aadhaar_number:e.target.value.replace(/\D/g, "")})} placeholder="12 digit Aadhaar number" /></label>
          <label>PAN Number<input maxLength={10} value={form.pan_number} onChange={e => setForm({...form, pan_number:e.target.value.toUpperCase()})} placeholder="AAAAA9999A" /></label>
          <div><button className="primary-btn upload-btn" disabled={saving}>{saving ? "Submitting…" : "Submit for Super Admin Verification →"}</button></div>
        </form>
      </section>

      <section className="employee-panel recent-panel">
        <div className="panel-heading"><div><h2>Identity Verification Status</h2><p>Live status of the identity information submitted from your account.</p></div></div>
        <div className="detail-grid">
          <div><small>Aadhaar</small><b>{record?.aadhaar_masked || "Not Submitted"}</b>{pill(record?.aadhaar_status)}</div>
          <div><small>PAN</small><b>{record?.pan_masked || "Not Submitted"}</b>{pill(record?.pan_status)}</div>
          <div><small>Remarks</small><b>{record?.remarks || "No remarks yet"}</b></div>
          <div><small>Last Updated</small><b>{record?.updated_at ? new Date(record.updated_at).toLocaleString() : "—"}</b></div>
        </div>
      </section>
    </>}
  </main></>;
}
