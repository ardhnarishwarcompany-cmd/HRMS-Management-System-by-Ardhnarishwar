import { useEffect, useRef, useState } from "react";
import { toast } from "react-toastify";
import Navbar from "../components/Navbar";
import Sidebar from "../components/sidebar";
import HRMS_API from "../services/hrmsApi";

const TYPES = ["Aadhaar Card", "PAN Card", "Address Proof", "Graduation (if any)", "Post Graduation (if any)", "Education Certificate", "Previous Employment Proof", "Experience Letter", "Bank Details", "Other"];

function MyVerification() {
  const [docs, setDocs] = useState([]);
  const [type, setType] = useState(TYPES[0]);
  const [file, setFile] = useState(null);
  const [customName, setCustomName] = useState("");
  const [loading, setLoading] = useState(true);
  const [uploading, setUploading] = useState(false);
  const inputRef = useRef(null);

  const load = async () => {
    try {
      const res = await HRMS_API.get("/employee/verification");
      setDocs(res.data?.documents || []);
    } catch (error) { toast.error(error.response?.data?.message || "Unable to load documents"); }
    finally { setLoading(false); }
  };
  useEffect(() => { load(); }, []);

  const submit = async () => {
    if (!file) return toast.error("Please choose a document");
    if (type === "Other" && !customName.trim()) return toast.error("Enter the document name");
    const data = new FormData();
    data.append("doc_type", type === "Other" ? customName.trim() : type);
    data.append("file", file);
    try {
      setUploading(true);
      const res = await HRMS_API.post("/employee/verification", data, { headers: { "Content-Type": "multipart/form-data" } });
      toast.success(res.data?.message || "Document submitted for verification");
      setFile(null);
      setCustomName("");
      if (inputRef.current) inputRef.current.value = "";
      load();
    } catch (error) { toast.error(error.response?.data?.message || "Document upload failed"); }
    finally { setUploading(false); }
  };

  return <>
    <Navbar /><Sidebar />
    <main className="employee-content">
      <div className="simple-page-heading"><div><div className="hero-kicker dark"><span /> DOCUMENT VERIFICATION</div><h1>My Verification</h1><p>Submit the documents required for employee verification. Every submission goes to the Super Admin review queue.</p></div></div>
      <section className="employee-panel upload-panel">
        <div className="panel-heading"><div><h2>Submit a Document</h2><p>Accepted formats: PDF, JPG, PNG, WEBP, DOC, DOCX · Maximum 10 MB</p></div></div>
        <div className="upload-form-grid">
          <label>Document type<select value={type} onChange={(e) => setType(e.target.value)}>{TYPES.map((t) => <option key={t}>{t}</option>)}</select></label>
          {type === "Other" && <label>Document name<input value={customName} onChange={(e) => setCustomName(e.target.value)} placeholder="Enter document name" /></label>}
          <label>Document file<div className="file-picker" onClick={() => inputRef.current?.click()}><span>↥</span><div><b>{file?.name || "Choose a file"}</b><small>{file ? `${(file.size / 1024 / 1024).toFixed(2)} MB` : "Click to browse"}</small></div></div><input ref={inputRef} type="file" accept=".pdf,.png,.jpg,.jpeg,.webp,.doc,.docx" hidden onChange={(e) => setFile(e.target.files?.[0] || null)} /></label>
        </div>
        <button className="primary-btn upload-btn" onClick={submit} disabled={uploading}>{uploading ? "Submitting…" : "Submit for Super Admin Verification →"}</button>
      </section>

      <section className="employee-panel recent-panel">
        <div className="panel-heading"><div><h2>My Submitted Documents</h2><p>Track the status of your verification documents.</p></div></div>
        {loading ? <div className="evs-loading">Loading documents…</div> : docs.length ? <div className="recent-table"><div className="recent-head"><span>DOCUMENT</span><span>SUBMITTED</span><span>STATUS</span></div>{docs.map((d) => <div className="recent-row" key={d.id}><div><b>{d.doc_type}</b><small>Document #{d.id}</small></div><span>{d.created_at ? new Date(d.created_at).toLocaleDateString() : "—"}</span><span className={`mini-status ${String(d.status || "Pending").toLowerCase()}`}>{d.status || "Pending"}</span></div>)}</div> : <div className="empty-state"><div>▤</div><b>No verification documents yet</b><span>Your first document submission will appear here.</span></div>}
      </section>
    </main>
  </>;
}
export default MyVerification;
