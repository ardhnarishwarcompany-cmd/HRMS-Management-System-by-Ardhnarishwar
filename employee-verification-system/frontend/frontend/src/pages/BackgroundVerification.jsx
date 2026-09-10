import { useEffect, useState } from "react";
import { toast } from "react-toastify";
import Navbar from "../components/Navbar";
import Sidebar from "../components/Sidebar";
import API from "../services/hrmsApi";

const statusClass = (s) => String(s || "Pending").toLowerCase().replaceAll(" ", "-");

export default function BackgroundVerification() {
  const [employee, setEmployee] = useState(null);
  const [cases, setCases] = useState([]);
  const [form, setForm] = useState({ previous_company:"", hr_email:"", rehire_eligible:"Unknown", criminal_record:"Unknown", feedback:"" });
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  const load = async () => {
    try { const r = await API.get("/employee/verification/background"); setEmployee(r.data?.employee); setCases(r.data?.backgrounds || []); }
    catch (e) { toast.error(e.response?.data?.message || "Unable to load background verification"); }
    finally { setLoading(false); }
  };
  useEffect(() => { load(); }, []);

  const submit = async (e) => {
    e.preventDefault();
    if (!form.previous_company.trim()) return toast.error("Previous company is required");
    try { setSaving(true); await API.post("/employee/verification/background", form); toast.success("Background details submitted to Super Admin"); setForm({ previous_company:"", hr_email:"", rehire_eligible:"Unknown", criminal_record:"Unknown", feedback:"" }); load(); }
    catch (e) { toast.error(e.response?.data?.message || "Background submission failed"); }
    finally { setSaving(false); }
  };

  return <><Navbar /><Sidebar /><main className="employee-content">
    <div className="simple-page-heading"><div><div className="hero-kicker dark"><span /> BACKGROUND VERIFICATION</div><h1>Background Verification</h1><p>Provide your previous employment verification information. The Super Admin completes the final background check.</p></div></div>
    {loading ? <div className="evs-loading">Loading background verification…</div> : <>
      <section className="employee-panel upload-panel">
        <div className="panel-heading"><div><h2>Background Details Form</h2><p>These details are sent directly to the Super Admin verification queue.</p></div><span className="status-badge in-progress">EMPLOYEE SUBMISSION</span></div>
        <form onSubmit={submit} className="upload-form-grid">
          <label>Employee<input value={`${employee?.name || "Employee"} · ${employee?.department || "Department"}`} readOnly /></label>
          <label>Previous Company *<input value={form.previous_company} onChange={e=>setForm({...form,previous_company:e.target.value})} placeholder="Previous company name" /></label>
          <label>Previous HR Email<input type="email" value={form.hr_email} onChange={e=>setForm({...form,hr_email:e.target.value})} placeholder="hr@previouscompany.com" /></label>
          <label>Rehire Eligible<select value={form.rehire_eligible} onChange={e=>setForm({...form,rehire_eligible:e.target.value})}><option>Unknown</option><option>Yes</option><option>No</option></select></label>
          <label>Criminal Record<select value={form.criminal_record} onChange={e=>setForm({...form,criminal_record:e.target.value})}><option>Unknown</option><option>No</option><option>Yes</option></select></label>
          <label>Additional Notes<textarea rows="3" value={form.feedback} onChange={e=>setForm({...form,feedback:e.target.value})} placeholder="Any information you want the verification team to know" /></label>
          <div><button className="primary-btn upload-btn" disabled={saving}>{saving ? "Submitting…" : "Submit Background Details →"}</button></div>
        </form>
      </section>
      <section className="employee-panel recent-panel">
        <div className="panel-heading"><div><h2>Background Verification Status</h2><p>Super Admin review progress appears here automatically.</p></div></div>
        {cases.length ? <div className="recent-table"><div className="recent-head"><span>PREVIOUS COMPANY</span><span>SUBMITTED</span><span>STATUS</span></div>{cases.map(c=><div className="recent-row" key={c.id}><div><b>{c.previous_company}</b><small>{c.hr_email || "No HR email provided"}</small></div><span>{c.created_at ? new Date(c.created_at).toLocaleDateString() : "—"}</span><span className={`mini-status ${statusClass(c.status)}`}>{c.status}</span></div>)}</div> : <div className="empty-state"><div>BG</div><b>No background verification submitted</b><span>Submit your previous company details to start the process.</span></div>}
      </section>
    </>}
  </main></>;
}
