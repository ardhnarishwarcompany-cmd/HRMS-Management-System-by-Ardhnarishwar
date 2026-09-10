import usePrompt from "../../hooks/usePrompt";
import { useEffect, useMemo, useState, useCallback } from "react";
import ExportButton from "../../components/common/ExportButton";
import { StatCard } from "../../components/common/Premium";
import axios from "axios";
import {
  FileCheck2, Upload, Trash2, CheckCircle2, XCircle, ExternalLink,
  ShieldCheck, UserRound, Search, BriefcaseBusiness, Clock3, Eye, RefreshCw, ClipboardCheck,
} from "lucide-react";
import toast from "react-hot-toast";

const BASE_URL = import.meta.env.VITE_API_BASE_URL || "http://localhost:5000/api";
const FILE_BASE = BASE_URL.replace(/\/api\/?$/, "");

const DOC_TYPES = [
  "Aadhaar Card", "PAN Card", "Passport", "Driving License", "Voter ID",
  "Graduation (if any)", "Post Graduation (if any)", "Education Certificate",
  "Experience Letter", "Relieving Letter", "Salary Slip", "Bank Details",
  "Bank Statement", "Address Proof", "Photo", "Other",
];

const STATUS_TONE = {
  Pending: "bg-amber-50 text-amber-700 border-amber-100",
  Verified: "bg-emerald-50 text-emerald-700 border-emerald-100",
  Rejected: "bg-red-50 text-red-700 border-red-100",
  "Not Submitted": "bg-slate-100 text-slate-500 border-slate-200",
  "In Progress": "bg-blue-50 text-blue-700 border-blue-100",
};

const normalizeFileUrl = (value) => {
  if (!value) return "";
  if (/^https?:\/\//i.test(value)) return value;
  const clean = String(value).replace(/\\/g, "/").replace(/^\/+/, "");
  return `${FILE_BASE}/${clean.startsWith("uploads/") ? clean : `uploads/${clean}`}`;
};

const statusFromDocs = (docs, names) => {
  const rows = docs.filter((d) => names.some((n) => String(d.doc_type || "").toLowerCase() === n.toLowerCase()));
  if (!rows.length) return "Not Submitted";
  if (rows.some((d) => d.status === "Rejected")) return "Rejected";
  if (rows.every((d) => d.status === "Verified")) return "Verified";
  return "Pending";
};

function StatusPill({ value }) {
  return <span className={`inline-flex items-center gap-1 rounded-full border px-2.5 py-1 text-[11px] font-bold ${STATUS_TONE[value] || STATUS_TONE["Not Submitted"]}`}>
    {value === "Verified" ? <CheckCircle2 size={12} /> : value === "Rejected" ? <XCircle size={12} /> : value === "Pending" ? <Clock3 size={12} /> : null}
    {value || "Not Submitted"}
  </span>;
}

export default function VerificationPortal() {
  const { ask, PromptDialog } = usePrompt();
  const token = localStorage.getItem("hrms_admin_token");
  const headers = { Authorization: `Bearer ${token}` };

  const [docs, setDocs] = useState([]);
  const [employees, setEmployees] = useState([]);
  const [overview, setOverview] = useState([]);
  const [counts, setCounts] = useState({ pending: 0, verified: 0, rejected: 0 });
  const [backgrounds, setBackgrounds] = useState([]);
  const [filter, setFilter] = useState("");
  const [search, setSearch] = useState("");
  const [saving, setSaving] = useState(false);
  const [loading, setLoading] = useState(true);
  const [viewer, setViewer] = useState(null);
  const [form, setForm] = useState({ employee_id: "", doc_type: "Aadhaar Card", file: null, custom_name: "" });
  const [bgForm, setBgForm] = useState({ employee_id: "", previous_company: "", hr_email: "", feedback: "", rehire_eligible: "Unknown", criminal_record: "Unknown" });

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const [d, e, o, b] = await Promise.allSettled([
        axios.get(`${BASE_URL}/verification${filter ? `?status=${encodeURIComponent(filter)}` : ""}`, { headers }),
        axios.get(`${BASE_URL}/super-admin/employees`, { headers }),
        axios.get(`${BASE_URL}/verification/employee-overview`, { headers }),
        axios.get(`${BASE_URL}/verification/background`, { headers }),
      ]);
      if (d.status === "fulfilled") {
        setDocs(d.value.data.documents || []);
        setCounts(d.value.data.counts || {});
      }
      if (e.status === "fulfilled") {
        const raw = e.value.data;
        const list = Array.isArray(raw) ? raw : raw?.employees || raw?.data?.rows || raw?.data || raw?.rows || [];
        setEmployees(Array.isArray(list) ? list : []);
      }
      if (o.status === "fulfilled") setOverview(o.value.data?.employees || []);
      if (b.status === "fulfilled") setBackgrounds(b.value.data?.backgrounds || []);
      if ([d, e, o, b].every((r) => r.status === "rejected")) toast.error("Unable to load verification workspace");
    } finally { setLoading(false); }
  }, [filter]);

  useEffect(() => { load(); }, [load]);

  const uploadDoc = async () => {
    if (!form.employee_id || !form.file) return toast.error("Select employee and document file");
    setSaving(true);
    try {
      const fd = new FormData();
      fd.append("employee_id", form.employee_id);
      fd.append("employee_name", employees.find((e) => String(e.id) === String(form.employee_id))?.name || "");
      fd.append("doc_type", form.doc_type === "Other" ? form.custom_name.trim() : form.doc_type);
      fd.append("file", form.file);
      await axios.post(`${BASE_URL}/verification`, fd, { headers });
      setForm({ employee_id: "", doc_type: "Aadhaar Card", file: null, custom_name: "" });
      const input = document.getElementById("verif-file-input");
      if (input) input.value = "";
      toast.success("Document uploaded for verification");
      await load();
    } catch (e) { toast.error(e.response?.data?.message || "Upload failed"); }
    finally { setSaving(false); }
  };

  const createBackground = async (event) => {
    event.preventDefault();
    if (!bgForm.employee_id) return toast.error("Select an employee");
    try {
      await axios.post(`${BASE_URL}/verification/background`, bgForm, { headers });
      setBgForm({ employee_id: "", previous_company: "", hr_email: "", feedback: "", rehire_eligible: "Unknown", criminal_record: "Unknown" });
      toast.success("Background check created — Pending");
      await load();
    } catch (e) { toast.error(e.response?.data?.message || "Could not create background check"); }
  };

  const reviewBackground = async (id, action) => {
    let remarks = "";
    if (action === "reject") {
      remarks = await ask({ title: "Reject background check", label: "Reason", required: true, multiline: true, submitText: "Reject", danger: true });
      if (remarks === null) return;
    }
    try {
      await axios.put(`${BASE_URL}/verification/background/${id}`, { action, remarks }, { headers });
      toast.success(action === "verify" ? "Background check verified" : action === "start" ? "Background check started" : "Background check rejected");
      await load();
    } catch (e) { toast.error(e.response?.data?.message || "Background update failed"); }
  };

  const review = async (id, status) => {
    let remarks = null;
    if (status === "Rejected") {
      remarks = await ask({ title: "Reject document", label: "Reason for rejection", required: true, multiline: true, submitText: "Reject", danger: true });
      if (remarks === null) return;
    }
    try {
      await axios.put(`${BASE_URL}/verification/${id}/review`, { status, remarks }, { headers });
      toast.success(`Document ${status.toLowerCase()}`);
      await load();
    } catch (e) { toast.error(e.response?.data?.message || "Review failed"); }
  };

  const del = async (id) => {
    if (!confirm("Delete this document?")) return;
    try { await axios.delete(`${BASE_URL}/verification/${id}`, { headers }); await load(); } catch (e) { toast.error(e.response?.data?.message || "Delete failed"); }
  };

  const filteredOverview = useMemo(() => {
    const q = search.trim().toLowerCase();
    return overview.filter((e) => !q || [e.name, e.email, e.department, e.employeeCode].some((x) => String(x || "").toLowerCase().includes(q)));
  }, [overview, search]);

  return <>
    <div className="p-6 space-y-6 bg-slate-50 min-h-full">
      <section className="relative overflow-hidden rounded-[28px] bg-gradient-to-br from-[#17112e] via-[#3c1761] to-[#5b21b6] p-7 text-white shadow-2xl shadow-violet-200/50">
        <div className="absolute -right-12 -top-20 h-64 w-64 rounded-full bg-fuchsia-400/20 blur-2xl" />
        <div className="absolute right-28 bottom-[-90px] h-52 w-52 rounded-full bg-indigo-300/20 blur-3xl" />
        <div className="absolute right-10 top-10 h-24 w-24 rotate-12 rounded-3xl border border-white/20 bg-white/10 backdrop-blur-md" />
        <div className="relative z-10 flex flex-wrap items-center justify-between gap-6">
          <div>
            <div className="mb-2 inline-flex items-center gap-2 rounded-full border border-fuchsia-300/30 bg-fuchsia-300/10 px-3 py-1 text-[11px] font-bold tracking-[.16em] text-fuchsia-100"><ShieldCheck size={13} /> EMPLOYEE VERIFICATION</div>
            <h1 className="text-3xl font-black tracking-tight">Verification Control Center</h1>
            <p className="mt-2 max-w-2xl text-sm text-violet-100">Review employee documents, identity status and background checks. Every employee submission routes here for Super Admin approval.</p>
            <div className="mt-5 flex flex-wrap gap-2 text-xs font-semibold"><span className="rounded-full bg-white/10 px-3 py-1.5">{overview.length} Employees</span><span className="rounded-full bg-white/10 px-3 py-1.5">{counts.pending || 0} Pending Documents</span><span className="rounded-full bg-white/10 px-3 py-1.5">{backgrounds.filter((b) => b.status === "Pending").length} Background Checks</span></div>
          </div>
          <div className="relative hidden h-32 w-32 md:block">
            <div className="absolute inset-3 rounded-full border border-fuchsia-200/30" /><div className="absolute inset-6 rounded-full border border-violet-200/40" /><div className="absolute inset-10 flex items-center justify-center rounded-2xl bg-white/15 shadow-xl backdrop-blur-md"><ClipboardCheck size={28} /></div>
          </div>
        </div>
      </section>

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
        <StatCard label="Pending" value={counts.pending ?? 0} tone="amber" icon={Upload} />
        <StatCard label="Verified" value={counts.verified ?? 0} tone="green" icon={CheckCircle2} />
        <StatCard label="Rejected" value={counts.rejected ?? 0} tone="red" icon={XCircle} />
      </div>

      <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
        <div className="mb-4 flex flex-wrap items-center justify-between gap-3"><div><h2 className="text-base font-extrabold text-slate-900">Employee Verification Status</h2><p className="text-xs text-slate-500">Live document-level status for every employee.</p></div><div className="flex items-center gap-2"><div className="relative"><Search className="absolute left-3 top-2.5 text-slate-400" size={15} /><input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Search employee…" className="w-56 rounded-xl border border-slate-200 py-2 pl-9 pr-3 text-sm outline-none focus:border-violet-400" /></div><button onClick={load} className="rounded-xl border border-slate-200 p-2 text-slate-600 hover:bg-slate-50"><RefreshCw size={16} className={loading ? "animate-spin" : ""} /></button></div></div>
        <div className="overflow-auto rounded-xl border border-slate-100"><table className="min-w-[1180px] w-full text-sm"><thead className="bg-slate-50 text-left text-[11px] uppercase tracking-wider text-slate-500"><tr>{["Employee", "Identity", "Graduation", "Post Graduation", "Bank Details", "Documents", "Background", "Overall"].map((h) => <th key={h} className="px-4 py-3">{h}</th>)}</tr></thead><tbody className="divide-y divide-slate-100">
          {filteredOverview.map((e) => <tr key={e.id} className="hover:bg-violet-50/30"><td className="px-4 py-3"><div className="flex items-center gap-3"><div className="h-10 w-10 overflow-hidden rounded-xl bg-violet-100 text-violet-700 flex items-center justify-center font-extrabold">{e.profile_image ? <img src={normalizeFileUrl(e.profile_image)} alt="" className="h-full w-full object-cover" /> : e.name?.slice(0, 1).toUpperCase()}</div><div><b className="text-slate-900">{e.name}</b><div className="text-[11px] text-slate-400">{e.department || "—"} · {e.employeeCode || "—"}</div></div></div></td><td className="px-4 py-3"><StatusPill value={e.identity_status} /></td><td className="px-4 py-3"><StatusPill value={e.graduation_status} /></td><td className="px-4 py-3"><StatusPill value={e.post_graduation_status} /></td><td className="px-4 py-3"><StatusPill value={e.bank_status} /></td><td className="px-4 py-3"><StatusPill value={e.documents_status} /></td><td className="px-4 py-3"><StatusPill value={e.background_status} /></td><td className="px-4 py-3"><StatusPill value={e.overall_status} /></td></tr>)}
          {!filteredOverview.length && <tr><td colSpan="8" className="px-4 py-10 text-center text-slate-400">No employee verification data found.</td></tr>}
        </tbody></table></div>
      </section>

      <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
        <div className="mb-4 flex items-center gap-3"><div className="flex h-10 w-10 items-center justify-center rounded-xl bg-violet-100 text-violet-700"><Upload size={19} /></div><div><h2 className="text-base font-extrabold text-slate-900">Upload / Add Verification Document</h2><p className="text-xs text-slate-500">Admin uploads can be used when a document is received offline.</p></div></div>
        <div className="grid grid-cols-1 gap-3 md:grid-cols-4"><select className="rounded-xl border border-slate-200 px-3 py-2.5 text-sm" value={form.employee_id} onChange={(e) => setForm({ ...form, employee_id: e.target.value })}><option value="">Select employee *</option>{employees.map((e) => <option key={e.id} value={e.id}>{e.name}</option>)}</select><select className="rounded-xl border border-slate-200 px-3 py-2.5 text-sm" value={form.doc_type} onChange={(e) => setForm({ ...form, doc_type: e.target.value })}>{DOC_TYPES.map((t) => <option key={t}>{t}</option>)}</select>{form.doc_type === "Other" && <input className="rounded-xl border border-slate-200 px-3 py-2.5 text-sm" placeholder="Enter document name" value={form.custom_name} onChange={(e) => setForm({ ...form, custom_name: e.target.value })} />}<input id="verif-file-input" className="rounded-xl border border-slate-200 px-3 py-2 text-sm" type="file" onChange={(e) => setForm({ ...form, file: e.target.files?.[0] || null })} /></div>
        <button className="mt-4 inline-flex items-center gap-2 rounded-xl bg-slate-900 px-4 py-2.5 text-sm font-bold text-white hover:bg-violet-700 disabled:opacity-50" disabled={saving} onClick={uploadDoc}><Upload size={15} />{saving ? "Uploading…" : "Upload Document"}</button>
      </section>

      <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
        <div className="mb-5 flex items-center gap-3"><div className="flex h-10 w-10 items-center justify-center rounded-xl bg-amber-100 text-amber-700"><BriefcaseBusiness size={19} /></div><div><h2 className="text-base font-extrabold text-slate-900">Background Check</h2><p className="text-xs text-slate-500">Super Admin starts and completes background verification from this form.</p></div></div>
        <form onSubmit={createBackground} className="grid grid-cols-1 gap-3 md:grid-cols-3"><select required className="rounded-xl border border-slate-200 px-3 py-2.5 text-sm" value={bgForm.employee_id} onChange={(e) => setBgForm({ ...bgForm, employee_id: e.target.value })}><option value="">Select employee *</option>{employees.map((e) => <option key={e.id} value={e.id}>{e.name} · {e.department || "Department"}</option>)}</select><input className="rounded-xl border border-slate-200 px-3 py-2.5 text-sm" placeholder="Previous company" value={bgForm.previous_company} onChange={(e) => setBgForm({ ...bgForm, previous_company: e.target.value })} /><input type="email" className="rounded-xl border border-slate-200 px-3 py-2.5 text-sm" placeholder="Previous HR email" value={bgForm.hr_email} onChange={(e) => setBgForm({ ...bgForm, hr_email: e.target.value })} /><select className="rounded-xl border border-slate-200 px-3 py-2.5 text-sm" value={bgForm.rehire_eligible} onChange={(e) => setBgForm({ ...bgForm, rehire_eligible: e.target.value })}><option>Unknown</option><option>Yes</option><option>No</option></select><select className="rounded-xl border border-slate-200 px-3 py-2.5 text-sm" value={bgForm.criminal_record} onChange={(e) => setBgForm({ ...bgForm, criminal_record: e.target.value })}><option>Unknown</option><option>No</option><option>Yes</option></select><textarea className="rounded-xl border border-slate-200 px-3 py-2.5 text-sm md:col-span-1" rows="2" placeholder="Background check notes / feedback" value={bgForm.feedback} onChange={(e) => setBgForm({ ...bgForm, feedback: e.target.value })} /><div className="md:col-span-3"><button className="inline-flex items-center gap-2 rounded-xl bg-gradient-to-r from-violet-600 to-indigo-600 px-5 py-2.5 text-sm font-bold text-white shadow-lg shadow-violet-200"><ClipboardCheck size={16} /> Submit Background Check</button></div></form>
        <div className="mt-6 overflow-auto rounded-xl border border-slate-100"><table className="min-w-[950px] w-full text-sm"><thead className="bg-slate-50 text-left text-[11px] uppercase text-slate-500"><tr>{["Employee", "Previous Company", "HR Email", "Rehire", "Criminal", "Feedback", "Status", "Actions"].map((h) => <th key={h} className="px-4 py-3">{h}</th>)}</tr></thead><tbody className="divide-y divide-slate-100">{backgrounds.map((b) => <tr key={b.id}><td className="px-4 py-3 font-semibold">{b.employee_name}</td><td className="px-4 py-3">{b.previous_company || "—"}</td><td className="px-4 py-3">{b.hr_email || "—"}</td><td className="px-4 py-3">{b.rehire_eligible || "Unknown"}</td><td className="px-4 py-3">{b.criminal_record || "Unknown"}</td><td className="max-w-[260px] px-4 py-3 text-slate-500">{b.feedback || "—"}</td><td className="px-4 py-3"><StatusPill value={b.status} /></td><td className="px-4 py-3"><div className="flex gap-2">{b.status === "Pending" && <button title="Start" onClick={() => reviewBackground(b.id, "start")} className="rounded-lg bg-blue-50 p-2 text-blue-600"><Clock3 size={15} /></button>}{(b.status === "Pending" || b.status === "In Progress") && <><button title="Verify" onClick={() => reviewBackground(b.id, "verify")} className="rounded-lg bg-emerald-50 p-2 text-emerald-600"><CheckCircle2 size={15} /></button><button title="Reject" onClick={() => reviewBackground(b.id, "reject")} className="rounded-lg bg-red-50 p-2 text-red-600"><XCircle size={15} /></button></>}</div></td></tr>)}{!backgrounds.length && <tr><td colSpan="8" className="px-4 py-8 text-center text-slate-400">No background checks created yet.</td></tr>}</tbody></table></div>
      </section>

      <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
        <div className="mb-4 flex flex-wrap items-center justify-between gap-3"><div><h2 className="text-base font-extrabold text-slate-900">Document Review Queue</h2><p className="text-xs text-slate-500">View the actual uploaded document before approving it.</p></div><div className="flex items-center gap-2">{["", "Pending", "Verified", "Rejected"].map((s) => <button key={s || "all"} onClick={() => setFilter(s)} className={`rounded-lg px-3 py-1.5 text-xs font-bold ${filter === s ? "bg-slate-900 text-white" : "border border-slate-200 bg-white text-slate-600"}`}>{s || "All"}</button>)}<ExportButton data={docs} filename="verification-documents" /></div></div>
        <div className="overflow-auto rounded-xl border border-slate-100"><table className="min-w-[1000px] w-full text-sm"><thead className="bg-slate-50 text-left text-[11px] uppercase text-slate-500"><tr>{["Employee", "Document", "File", "Status", "Remarks", "Reviewed By", "Actions"].map((h) => <th key={h} className="px-4 py-3">{h}</th>)}</tr></thead><tbody className="divide-y divide-slate-100">{docs.map((d) => { const url = normalizeFileUrl(d.file_url || d.file_path); return <tr key={d.id}><td className="px-4 py-3 font-semibold text-slate-900">{d.employee_name}</td><td className="px-4 py-3">{d.doc_type}</td><td className="px-4 py-3">{url ? <button onClick={() => setViewer({ ...d, url })} className="inline-flex items-center gap-1.5 font-semibold text-violet-600 hover:underline"><Eye size={14} /> View</button> : <span className="text-slate-300">No file</span>}</td><td className="px-4 py-3"><StatusPill value={d.status} /></td><td className="px-4 py-3 text-slate-500">{d.remarks || "—"}</td><td className="px-4 py-3 text-slate-500">{d.verified_by || "—"}</td><td className="px-4 py-3"><div className="flex items-center gap-2">{d.status === "Pending" && <><button onClick={() => review(d.id, "Verified")} title="Verify" className="rounded-lg bg-emerald-50 p-2 text-emerald-600"><CheckCircle2 size={16} /></button><button onClick={() => review(d.id, "Rejected")} title="Reject" className="rounded-lg bg-red-50 p-2 text-red-600"><XCircle size={16} /></button></>} {d.status !== "Pending" && <button onClick={() => review(d.id, "Pending")} className="text-xs font-bold text-slate-500">Reopen</button>}<button onClick={() => del(d.id)} className="rounded-lg p-2 text-slate-300 hover:text-red-500"><Trash2 size={15} /></button></div></td></tr>; })}{!docs.length && <tr><td colSpan="7" className="px-4 py-8 text-center text-slate-400">No documents {filter ? `with status "${filter}"` : "uploaded yet"}.</td></tr>}</tbody></table></div>
      </section>
    </div>

    {viewer && <div className="fixed inset-0 z-[100] flex items-center justify-center bg-slate-950/70 p-4" onClick={() => setViewer(null)}><div className="flex h-[92vh] w-full max-w-6xl flex-col overflow-hidden rounded-2xl bg-white shadow-2xl" onClick={(e) => e.stopPropagation()}><div className="flex items-center justify-between border-b px-5 py-3"><div><b className="text-slate-900">{viewer.doc_type}</b><span className="ml-2 text-xs text-slate-400">{viewer.employee_name}</span></div><div className="flex gap-2"><a href={viewer.url} target="_blank" rel="noreferrer" className="inline-flex items-center gap-1.5 rounded-lg border px-3 py-2 text-xs font-bold"><ExternalLink size={14} /> Open / Download</a><button onClick={() => setViewer(null)} className="rounded-lg bg-slate-900 px-3 py-2 text-xs font-bold text-white">Close</button></div></div><div className="flex-1 bg-slate-100 p-3">{viewer.url ? ( /\.(png|jpe?g|webp)(\?|$)/i.test(viewer.url) ? <img src={viewer.url} alt={viewer.doc_type} className="mx-auto h-full max-w-full object-contain" onError={(e) => { e.currentTarget.style.display = "none"; }} /> : /\.pdf(\?|$)/i.test(viewer.url) ? <object data={viewer.url} type="application/pdf" className="h-full w-full rounded-xl bg-white"><div className="flex h-full items-center justify-center text-sm text-slate-500">PDF preview unavailable. Use Open / Download above.</div></object> : <div className="flex h-full flex-col items-center justify-center gap-3 rounded-xl bg-white text-center"><div className="text-sm font-bold text-slate-800">This file type cannot be previewed in the browser.</div><a href={viewer.url} target="_blank" rel="noreferrer" className="rounded-lg bg-violet-600 px-4 py-2 text-sm font-bold text-white">Open / Download Document</a></div>) : <div className="flex h-full items-center justify-center text-sm text-red-500">Document file URL is missing.</div>}</div></div></div>}
    <PromptDialog />
  </>;
}
