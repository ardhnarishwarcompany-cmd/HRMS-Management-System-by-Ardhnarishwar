import { useEffect, useRef, useState } from "react";
import { toast } from "react-toastify";
import Navbar from "../components/Navbar";
import Sidebar from "../components/sidebar";
import HRMS_API from "../services/hrmsApi";

const apiOrigin = (import.meta.env.VITE_HRMS_API_URL || "http://localhost:5000/api").replace(/\/api\/?$/, "");
const avatarUrl = (value) => {
  if (!value) return "";
  if (/^https?:\/\//i.test(value)) return value;
  const clean = String(value).replace(/\\/g, "/").replace(/^\/+/, "");
  return `${apiOrigin}/${clean.startsWith("uploads/") ? clean : `uploads/profile/${clean}`}`;
};

function Profile() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [photo, setPhoto] = useState(null);
  const [uploading, setUploading] = useState(false);
  const inputRef = useRef(null);

  const load = async () => {
    try { const r = await HRMS_API.get("/employee/profile"); setData(r.data?.data); }
    catch (e) { toast.error(e.response?.data?.message || "Unable to load profile"); }
    finally { setLoading(false); }
  };
  useEffect(() => { load(); }, []);

  const e = data?.employee || {};
  const initials = (e.name || localStorage.getItem("name") || "Employee").split(" ").map((x) => x[0]).join("").slice(0, 2).toUpperCase();
  const currentAvatar = avatarUrl(e.avatar);

  const uploadPhoto = async () => {
    if (!photo) return toast.error("Choose a profile image first");
    try {
      setUploading(true);
      const fd = new FormData();
      fd.append("photo", photo);
      await HRMS_API.post("/employee/profile/avatar", fd, { headers: { "Content-Type": "multipart/form-data" } });
      toast.success("Profile photo updated");
      setPhoto(null);
      if (inputRef.current) inputRef.current.value = "";
      await load();
    } catch (error) { toast.error(error.response?.data?.message || "Photo upload failed"); }
    finally { setUploading(false); }
  };

  const logout = () => { localStorage.clear(); window.location.href = "/"; };

  return <>
    <Navbar /><Sidebar />
    <main className="employee-content">
      <div className="simple-page-heading"><div><div className="hero-kicker dark"><span /> ACCOUNT</div><h1>My Profile</h1><p>Manage your employee identity, profile photo and HRMS-linked information.</p></div></div>
      {loading ? <div className="evs-loading">Loading profile…</div> : <>
        <section className="profile-card-new profile-card-premium">
          <div className="profile-avatar-wrap"><div className="profile-avatar-new profile-avatar-photo">{currentAvatar ? <img src={currentAvatar} alt={e.name || "Employee"} /> : initials}</div><button type="button" className="profile-camera" onClick={() => inputRef.current?.click()} title="Change profile photo"><span>✦</span></button></div>
          <div className="profile-main"><div className="profile-kicker">EMPLOYEE PROFILE</div><h2>{e.name || "Employee"}</h2><p>{e.email || "—"}</p><div className="profile-tags"><span>EMPLOYEE</span><span>{e.department || "Department not set"}</span><span>{e.designation || "Employee"}</span></div><div className="profile-photo-actions"><input ref={inputRef} type="file" accept="image/png,image/jpeg,image/webp" hidden onChange={(ev) => setPhoto(ev.target.files?.[0] || null)} /><button type="button" className="outline-btn" onClick={() => inputRef.current?.click()}>Choose Photo</button>{photo && <span>{photo.name}</span>}<button type="button" className="primary-btn" disabled={!photo || uploading} onClick={uploadPhoto}>{uploading ? "Uploading…" : "Upload Photo"}</button></div></div>
          <div className="profile-status"><span /> Active account</div>
        </section>

        <section className="employee-panel profile-details"><div className="panel-heading"><div><h2>Employee Details</h2><p>Information linked to your HRMS account.</p></div></div><div className="detail-grid"><div><small>Employee Code</small><b>{e.employeeCode || "—"}</b></div><div><small>Department</small><b>{e.department || "—"}</b></div><div><small>Designation</small><b>{e.designation || "—"}</b></div><div><small>Joining Date</small><b>{e.joiningDate ? new Date(e.joiningDate).toLocaleDateString() : "—"}</b></div><div><small>Email</small><b>{e.email || "—"}</b></div><div><small>Phone</small><b>{e.phone || "—"}</b></div><div><small>Account Status</small><b>{e.isActive ? "Active" : "Inactive"}</b></div><div><small>Member Since</small><b>{e.memberSince ? new Date(e.memberSince).toLocaleDateString() : "—"}</b></div></div></section>

        <section className="employee-panel profile-verification-mini"><div><div className="panel-heading"><div><h2>Verification Snapshot</h2><p>Your latest verification state.</p></div></div><div className="profile-mini-grid"><div><small>Overall</small><b>{data?.verification?.overall === "verified" ? "Verified" : data?.verification?.overall === "attention" ? "Action Required" : data?.verification?.overall === "in_progress" ? "In Progress" : "Not Started"}</b></div><div><small>Documents</small><b>{data?.verification?.documentsVerified || 0} / {data?.verification?.documentsTotal || 0} verified</b></div><div><small>Identity</small><b>{data?.verification?.identity?.aadhaar_status || "Not Submitted"}</b></div></div></div></section>

        <section className="employee-panel session-card"><div><h2>Secure Session</h2><p>You are signed in as an employee. Sign out when using a shared computer.</p></div><button className="danger-btn" onClick={logout}>Sign Out</button></section>
      </>}
    </main>
  </>;
}
export default Profile;
