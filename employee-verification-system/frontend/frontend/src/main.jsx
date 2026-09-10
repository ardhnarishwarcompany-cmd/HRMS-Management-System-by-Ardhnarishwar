import React, {useEffect, useState} from "react";
import { createRoot } from "react-dom/client";
import { BrowserRouter, Routes, Route, Navigate, NavLink, useLocation, useNavigate } from "react-router-dom";
import {
  LayoutDashboard, FileCheck2, ClipboardCheck, ShieldCheck, UserRound, IdCard,
  SearchCheck, LogOut, Bell, Sun, Moon, ChevronRight, Upload, CheckCircle2,
  Clock3, AlertCircle, FileText, Landmark, GraduationCap, BriefcaseBusiness,
  ArrowUpRight, Download, Printer, RefreshCw, Eye, XCircle, Check, Sparkles,
  Menu, X, LockKeyhole, Mail, ArrowRight, BadgeCheck, CircleUserRound
} from "lucide-react";
import "./styles.css";

const demoEmployee = {
  id: "EMP-10003",
  name: "suhani",
  email: "advay708@gmail.com",
  department: "Sales",
  designation: "Sales Manager",
  phone: "4547886999",
  joiningDate: "09/08/2026",
  status: "Active",
  memberSince: "09/08/2026"
};

const initialData = {
  documents: [
    {id:1,name:"Aadhaar Card",category:"Identity",status:"Verified",updated:"10 Sep 2026",file:"aadhaar-card.pdf"},
    {id:2,name:"PAN Card",category:"Identity",status:"Verified",updated:"10 Sep 2026",file:"pan-card.pdf"},
    {id:3,name:"Graduation Certificate",category:"Education",status:"Verified",updated:"09 Sep 2026",file:"graduation.pdf"},
    {id:4,name:"Post Graduation Certificate",category:"Education",status:"Pending",updated:"09 Sep 2026",file:"post-graduation.pdf"},
    {id:5,name:"Bank Details",category:"Banking",status:"Verified",updated:"09 Sep 2026",file:"bank-details.pdf"},
    {id:6,name:"Experience Letter",category:"Employment",status:"Verified",updated:"08 Sep 2026",file:"experience-letter.pdf"}
  ],
  identity: {
    aadhaar: "XXXX XXXX 4821",
    pan: "ABCDE1234F",
    status: "Verified",
    submittedOn: "10 Sep 2026",
    remarks: "Identity details verified by Super Admin."
  },
  background: {
    status: "In Progress",
    employer: "Previous Organization",
    designation: "Team Supervisor",
    from: "01/2025",
    to: "07/2026",
    reason: "Career progression",
    contact: "HR Department",
    notes: "Verification request submitted for review."
  },
  profilePhoto: ""
};

function loadData(){
  try { return JSON.parse(localStorage.getItem("evpData")) || initialData; }
  catch { return initialData; }
}
function saveData(data){ localStorage.setItem("evpData", JSON.stringify(data)); }

function App(){
  const [data,setData] = useState(loadData());
  const [theme,setTheme] = useState(localStorage.getItem("evpTheme") || "light");
  useEffect(()=>{ saveData(data); },[data]);
  useEffect(()=>{ document.documentElement.dataset.theme=theme; localStorage.setItem("evpTheme",theme); },[theme]);

  const updateData = (patch) => setData(d => ({...d,...patch}));
  return <Routes>
    <Route path="/login" element={<Login/>}/>
    <Route element={<ProtectedLayout theme={theme} setTheme={setTheme}/>}>
      <Route path="/dashboard" element={<Dashboard data={data}/>}/>
      <Route path="/my-verification" element={<MyVerification data={data} setData={updateData}/>}/>
      <Route path="/verification-status" element={<VerificationStatus data={data}/>}/>
      <Route path="/identity-details" element={<IdentityDetails data={data} setData={updateData}/>}/>
      <Route path="/background-verification" element={<BackgroundVerification data={data} setData={updateData}/>}/>
      <Route path="/profile" element={<Profile data={data} setData={updateData}/>}/>
      <Route path="*" element={<Navigate to="/dashboard" replace/>}/>
    </Route>
  </Routes>
}

function Login(){
  const navigate=useNavigate();
  const [email,setEmail]=useState("advay708@gmail.com");
  const [password,setPassword]=useState("employee123");
  const [show,setShow]=useState(false);
  const submit=(e)=>{e.preventDefault();localStorage.setItem("evpAuth","1");navigate("/dashboard");};
  return <div className="login-shell">
    <div className="login-orb orb-a"/><div className="login-orb orb-b"/>
    <div className="login-brand">
      <div className="brand-mark large">H</div>
      <div><b>HRMS</b><span>EMPLOYEE VERIFICATION</span></div>
    </div>
    <div className="login-grid">
      <section className="login-intro">
        <div className="eyebrow"><Sparkles size={14}/> SECURE EMPLOYEE WORKSPACE</div>
        <h1>Verify once.<br/><em>Stay confident.</em></h1>
        <p>Complete your employment verification, submit documents and track every approval from one secure portal.</p>
        <div className="login-feature-grid">
          <MiniFeature icon={<ShieldCheck/>} title="Secure verification" text="Controlled review workflow"/>
          <MiniFeature icon={<FileCheck2/>} title="Document tracking" text="Live status for every file"/>
          <MiniFeature icon={<SearchCheck/>} title="Background checks" text="Simple guided submission"/>
          <MiniFeature icon={<BadgeCheck/>} title="HRMS connected" text="Your employee profile stays linked"/>
        </div>
      </section>
      <form className="login-card" onSubmit={submit}>
        <div className="login-card-top"><div className="login-icon"><LockKeyhole/></div><span className="status-pill success"><i/> System operational</span></div>
        <div className="login-heading"><span className="section-kicker">EMPLOYEE PORTAL</span><h2>Welcome back</h2><p>Sign in to continue your verification.</p></div>
        <label>Email address</label>
        <div className="input-wrap"><Mail/><input value={email} onChange={e=>setEmail(e.target.value)} type="email" required/></div>
        <label>Password</label>
        <div className="input-wrap"><LockKeyhole/><input value={password} onChange={e=>setPassword(e.target.value)} type={show?"text":"password"} required/><button type="button" className="input-action" onClick={()=>setShow(!show)}>{show?"Hide":"Show"}</button></div>
        <div className="login-row"><label className="check"><input type="checkbox"/> Remember me</label><a href="#!" onClick={e=>e.preventDefault()}>Forgot password?</a></div>
        <button className="primary-btn login-btn">Login to Portal <ArrowRight size={18}/></button>
        <div className="demo-box"><b>Demo account</b><span>{email}</span><small>Password: employee123</small></div>
        <p className="login-foot"><ShieldCheck size={14}/> Your session is protected by HRMS security controls.</p>
      </form>
    </div>
  </div>
}
function MiniFeature({icon,title,text}){return <div className="mini-feature"><div className="mini-icon">{icon}</div><div><b>{title}</b><span>{text}</span></div></div>}

function ProtectedLayout({theme,setTheme}){
  const navigate=useNavigate(); const location=useLocation(); const [mobile,setMobile]=useState(false);
  const logout=()=>{localStorage.removeItem("evpAuth");navigate("/login");};
  if(!localStorage.getItem("evpAuth")) return <Navigate to="/login" replace/>;
  const links=[
    {to:"/dashboard",label:"Dashboard",icon:<LayoutDashboard/>},
    {to:"/my-verification",label:"My Verification",icon:<FileCheck2/>},
    {to:"/verification-status",label:"Verification Status",icon:<ClipboardCheck/>},
  ];
  const verification=[
    {to:"/identity-details",label:"Identity Details",icon:<IdCard/>},
    {to:"/background-verification",label:"Background Verification",icon:<SearchCheck/>},
  ];
  return <div className="app-shell">
    <header className="topbar">
      <button className="mobile-menu" onClick={()=>setMobile(!mobile)}>{mobile?<X/>:<Menu/>}</button>
      <div className="top-brand"><div className="brand-mark">H</div><div><b>Employee Verification Portal</b><span>HRMS · Secure verification workspace</span></div></div>
      <div className="top-actions"><span className="online-dot"/> <span className="top-user">{demoEmployee.name}<small>{demoEmployee.email}</small></span><button className="icon-btn" onClick={()=>setTheme(theme==="light"?"dark":"light")}>{theme==="light"?<Moon/>:<Sun/>}</button><button className="icon-btn bell"><Bell/><i/></button><button className="logout-btn" onClick={logout}><LogOut/> Logout</button></div>
    </header>
    <aside className={"sidebar "+(mobile?"open":"")}>
      <div className="side-profile"><div className="avatar side-avatar">{demoEmployee.name[0].toUpperCase()}</div><div><b>ARDHNARISHWAR</b><span>Employee Verification</span></div></div>
      <nav>
        <div className="nav-label">WORKSPACE</div>
        {links.map(l=><SideLink key={l.to} {...l} close={()=>setMobile(false)}/>)}
        <div className="nav-label">VERIFICATION</div>
        {verification.map(l=><SideLink key={l.to} {...l} close={()=>setMobile(false)}/>)}
        <div className="nav-label">ACCOUNT</div>
        <SideLink to="/profile" label="My Profile" icon={<UserRound/>} close={()=>setMobile(false)}/>
      </nav>
      <div className="secure-card"><div><ShieldCheck/><b>SECURE PORTAL</b></div><span>Employee access · HRMS connected</span></div>
    </aside>
    <main className="main-content">{/* page content */}<OutletShim/></main>
  </div>
}
function SideLink({to,label,icon,close}){return <NavLink to={to} onClick={close} className={({isActive})=>"side-link "+(isActive?"active":"")}>{icon}<span>{label}</span><ChevronRight className="nav-arrow"/></NavLink>}
function OutletShim(){ return <Routes><Route path="/dashboard" element={<Dashboard data={loadData()}/>}/><Route path="/my-verification" element={<MyVerification data={loadData()} setData={p=>{const d=loadData();const n={...d,...p};saveData(n);window.dispatchEvent(new Event("storage"));location.reload()}}/>}/><Route path="/verification-status" element={<VerificationStatus data={loadData()}/>}/><Route path="/identity-details" element={<IdentityDetails data={loadData()} setData={p=>{const d=loadData();saveData({...d,...p});location.reload()}}/>}/><Route path="/background-verification" element={<BackgroundVerification data={loadData()} setData={p=>{const d=loadData();saveData({...d,...p});location.reload()}}/>}/><Route path="/profile" element={<Profile data={loadData()} setData={p=>{const d=loadData();saveData({...d,...p});location.reload()}}/>}/></Routes> }

function PageHero({eyebrow,title,subtitle,children,icon=<ShieldCheck/>}){
 return <section className="hero"><div className="hero-content"><div className="eyebrow light"><span className="pulse"/> {eyebrow}</div><h1>{title}</h1><p>{subtitle}</p>{children}</div><div className="hero-art"><div className="ring r1"/><div className="ring r2"/><div className="hero-icon">{icon}</div><span>SECURE</span></div></section>
}
function StatCard({label,value,caption,icon,tone=""}){return <div className={"stat-card "+tone}><div><span>{label}</span><strong>{value}</strong><small>{caption}</small></div><div className="stat-icon">{icon}</div><div className="stat-corner"/></div>}
function StatusPill({status}){const s=status.toLowerCase(); return <span className={"status-pill "+(s.includes("verified")?"success":s.includes("pending")||s.includes("progress")?"warning":s.includes("rejected")||s.includes("required")?"danger":"neutral")}><i/>{status}</span>}
function SectionTitle({kicker,title,sub,action}){return <div className="section-title"><div><span className="section-kicker">{kicker}</span><h2>{title}</h2>{sub&&<p>{sub}</p>}</div>{action}</div>}

function Dashboard({data}){
 const verified=data.documents.filter(x=>x.status==="Verified").length, pending=data.documents.filter(x=>x.status==="Pending").length;
 const total=data.documents.length, progress=total?Math.round(verified/total*100):0;
 return <div className="page">
  <PageHero eyebrow="EMPLOYEE VERIFICATION" title={`Welcome, ${demoEmployee.name}.`} subtitle="Complete your employment verification and keep track of documents submitted for Super Admin review." icon={<Check/>}>
   <div className="hero-tags"><span><UserRound/> {demoEmployee.id}</span><span><BriefcaseBusiness/> {demoEmployee.department}</span><span><Clock3/> {pending?"In Progress":"Verified"}</span></div>
  </PageHero>
  <div className="stats-grid four"><StatCard label="TOTAL DOCUMENTS" value={total} caption="Submitted for verification" icon={<FileText/>}/><StatCard label="VERIFIED" value={verified} caption="Approved documents" icon={<CheckCircle2/>} tone="green"/><StatCard label="PENDING" value={pending} caption="Awaiting Super Admin review" icon={<Clock3/>} tone="orange"/><StatCard label="ACTION REQUIRED" value={data.documents.filter(x=>x.status==="Rejected").length} caption="Needs your attention" icon={<AlertCircle/>} tone="red"/></div>
  <div className="two-col">
   <section className="panel"><SectionTitle kicker="OVERVIEW" title="Verification Progress" sub="Your submitted documents and current review status." action={<StatusPill status={pending?"In Progress":"Verified"}/>}/>
    <div className="progress-head"><b>{progress}% complete</b><span>{verified} of {total} documents verified</span></div><div className="progress"><i style={{width:`${progress}%`}}/></div>
    <div className="check-list"><CheckRow icon={<FileText/>} title="Employment Documents" text={`${total} documents submitted`} value={`${verified}/${total}`}/><CheckRow icon={<IdCard/>} title="Identity Verification" text="Aadhaar / PAN verification" value={data.identity.status}/><CheckRow icon={<SearchCheck/>} title="Background Verification" text="Previous employment review" value={data.background.status}/></div>
   </section>
   <section className="panel"><SectionTitle kicker="SHORTCUTS" title="Quick Actions" sub="Manage your verification steps."/>
    <ActionRow icon={<Upload/>} title="Submit Documents" text="Upload documents for verification" to="/my-verification"/><ActionRow icon={<UserRound/>} title="My Profile" text="View your employee information" to="/profile"/><ActionRow icon={<SearchCheck/>} title="Background Verification" text="Submit previous employment details" to="/background-verification"/>
   </section>
  </div>
 </div>
}
function CheckRow({icon,title,text,value}){return <div className="check-row"><div className="row-icon">{icon}</div><div><b>{title}</b><span>{text}</span></div><strong>{value}</strong></div>}
function ActionRow({icon,title,text,to}){const navigate=useNavigate();return <button className="action-row" onClick={()=>navigate(to)}><div className="row-icon purple">{icon}</div><div><b>{title}</b><span>{text}</span></div><ArrowUpRight/></button>}

function MyVerification({data,setData}){
 const [file,setFile]=useState(null); const [type,setType]=useState("Other"); const [custom,setCustom]=useState("");
 const submit=(e)=>{e.preventDefault(); if(!file)return; const name=type==="Other"?custom||"Other Document":type; setData({documents:[...data.documents,{id:Date.now(),name,category:type==="Other"?"Other":type,status:"Pending",updated:"Just now",file:file.name}]});setFile(null);e.target.reset();alert("Document submitted successfully.");};
 return <div className="page">
  <PageHero eyebrow="DOCUMENT VERIFICATION" title="My Verification" subtitle="Upload your employment and education documents. Every submission is routed to Super Admin for review." icon={<FileCheck2/>}/>
  <section className="panel upload-panel"><SectionTitle kicker="NEW SUBMISSION" title="Upload Document" sub="PDF, JPG or PNG · Maximum 10 MB"/>
   <form className="upload-grid" onSubmit={submit}><div className="field"><label>Document type</label><select value={type} onChange={e=>setType(e.target.value)}><option>Aadhaar Card</option><option>PAN Card</option><option>Graduation</option><option>Post Graduation</option><option>Bank Details</option><option>Experience Letter</option><option>Other</option></select></div>{type==="Other"&&<div className="field"><label>Document name</label><input value={custom} onChange={e=>setCustom(e.target.value)} placeholder="Enter document name"/></div>}<div className="field file-field"><label>Select file</label><label className="dropzone"><Upload/><b>{file?file.name:"Choose or drag your file here"}</b><span>Click to browse from your computer</span><input type="file" accept=".pdf,.jpg,.jpeg,.png" onChange={e=>setFile(e.target.files?.[0])}/></label></div><button className="primary-btn" type="submit"><Upload/> Submit for Verification</button></form>
  </section>
  <section className="panel"><SectionTitle kicker="SUBMISSIONS" title="My Documents" sub={`${data.documents.length} documents in your verification workspace.`}/><div className="table-wrap"><table><thead><tr><th>DOCUMENT</th><th>CATEGORY</th><th>FILE</th><th>UPDATED</th><th>STATUS</th><th>ACTION</th></tr></thead><tbody>{data.documents.map(d=><tr key={d.id}><td><div className="table-doc"><div className="row-icon"><FileText/></div><b>{d.name}</b></div></td><td>{d.category}</td><td><button className="link-btn"><Eye/> View</button></td><td>{d.updated}</td><td><StatusPill status={d.status}/></td><td><button className="icon-only"><Download/></button></td></tr>)}</tbody></table></div></section>
 </div>
}

function VerificationStatus({data}){
 const verified=data.documents.filter(d=>d.status==="Verified").length, pending=data.documents.filter(d=>d.status==="Pending").length, rejected=data.documents.filter(d=>d.status==="Rejected").length;
 const overall=rejected?"Action Required":(pending||data.background.status!=="Verified"||data.identity.status!=="Verified")?"In Progress":"Fully Verified";
 return <div className="page">
  <PageHero eyebrow="VERIFICATION STATUS" title="Verification Status Dashboard" subtitle="Live progress across your documents, identity details and background verification." icon={<ClipboardCheck/>}/>
  <div className="stats-grid four"><StatCard label="OVERALL STATUS" value={overall} caption="Current verification stage" icon={<ShieldCheck/>}/><StatCard label="DOCUMENTS" value={rejected?"Rejected":pending?"In Progress":"Verified"} caption={`${verified} approved documents`} icon={<FileCheck2/>}/><StatCard label="IDENTITY" value={data.identity.status} caption="Aadhaar / PAN" icon={<IdCard/>}/><StatCard label="BACKGROUND" value={data.background.status} caption="Super Admin review" icon={<SearchCheck/>}/></div>
  <section className="panel"><SectionTitle kicker="LIVE CHECKLIST" title="Verification Checklist" sub="Your live status by verification category." action={<StatusPill status={overall}/>}/>
   <div className="big-check"><CheckRow icon={<FileText/>} title="Documents" text="Uploaded employment and education documents" value={pending?`${pending} Pending`:rejected?"Rejected":"Verified"}/><CheckRow icon={<IdCard/>} title="Identity Details" text="Aadhaar and PAN submitted for Super Admin approval" value={data.identity.status}/><CheckRow icon={<SearchCheck/>} title="Background Verification" text="Previous employment details and Super Admin review" value={data.background.status}/></div>
  </section>
  <section className="panel"><SectionTitle kicker="EMPLOYEE INFORMATION" title="Linked HRMS Profile" sub="Verification account linked to your HRMS employee record."/><div className="info-grid">{Object.entries({Employee:demoEmployee.name,"Employee Code":demoEmployee.id,Department:demoEmployee.department,Designation:demoEmployee.designation,Email:demoEmployee.email,"Joining Date":demoEmployee.joiningDate}).map(([k,v])=><div className="info-item" key={k}><span>{k}</span><b>{v}</b></div>)}</div></section>
 </div>
}

function IdentityDetails({data,setData}){
 const [aadhaar,setAadhaar]=useState(data.identity.aadhaar.replace(/X/g,"")); const [pan,setPan]=useState(data.identity.pan);
 const submit=e=>{e.preventDefault();setData({identity:{aadhaar:aadhaar||"Not provided",pan:pan||"Not provided",status:"Pending",submittedOn:"10 Sep 2026",remarks:"Submitted for Super Admin approval."}});alert("Identity details submitted for verification.");};
 return <div className="page"><PageHero eyebrow="IDENTITY VERIFICATION" title="Aadhaar / PAN Verification" subtitle="Submit your identity details securely for Super Admin review." icon={<IdCard/>}/>
 <section className="panel"><SectionTitle kicker="IDENTITY DETAILS" title="Submit Identity Information" sub="Enter accurate details exactly as shown on your documents."/>
 <form className="form-grid" onSubmit={submit}><div className="field"><label>Aadhaar number</label><input value={aadhaar} onChange={e=>setAadhaar(e.target.value)} maxLength="12" placeholder="12 digit Aadhaar number"/></div><div className="field"><label>PAN number</label><input value={pan} onChange={e=>setPan(e.target.value.toUpperCase())} maxLength="10" placeholder="ABCDE1234F"/></div><div className="form-actions"><button className="primary-btn"><ShieldCheck/> Submit for Verification</button></div></form></section>
 <section className="panel"><SectionTitle kicker="VERIFICATION RECORD" title="Current Identity Status" sub="Latest identity submission linked to your account."/><div className="identity-summary"><div className="identity-card"><IdCard/><span>Aadhaar</span><b>{data.identity.aadhaar}</b></div><div className="identity-card"><BadgeCheck/><span>PAN</span><b>{data.identity.pan}</b></div><div className="identity-card status-card"><Clock3/><span>Status</span><StatusPill status={data.identity.status}/></div></div><div className="remark-box"><b>Review remark</b><span>{data.identity.remarks}</span></div></section>
 </div>
}

function BackgroundVerification({data,setData}){
 const [form,setForm]=useState(data.background);
 const change=e=>setForm({...form,[e.target.name]:e.target.value});
 const submit=e=>{e.preventDefault();setData({background:{...form,status:"Pending",notes:"Background verification form submitted for Super Admin review."}});alert("Background verification submitted.");};
 return <div className="page"><PageHero eyebrow="BACKGROUND CHECK" title="Background Verification" subtitle="Provide previous employment information so the Super Admin can initiate and review your background check." icon={<SearchCheck/>}/>
 <section className="panel"><SectionTitle kicker="BACKGROUND CHECK FORM" title="Previous Employment Details" sub="Fill in the details below. You can update them before final review."/>
 <form className="form-grid three" onSubmit={submit}><div className="field"><label>Previous employer</label><input name="employer" value={form.employer} onChange={change} placeholder="Company name"/></div><div className="field"><label>Designation</label><input name="designation" value={form.designation} onChange={change} placeholder="Your designation"/></div><div className="field"><label>Employment contact</label><input name="contact" value={form.contact} onChange={change} placeholder="HR / official contact"/></div><div className="field"><label>From</label><input name="from" value={form.from} onChange={change} placeholder="MM/YYYY"/></div><div className="field"><label>To</label><input name="to" value={form.to} onChange={change} placeholder="MM/YYYY"/></div><div className="field"><label>Reason for leaving</label><input name="reason" value={form.reason} onChange={change} placeholder="Reason"/></div><div className="field full"><label>Additional notes</label><textarea name="notes" value={form.notes||""} onChange={change} placeholder="Any information helpful for verification..."/></div><div className="form-actions full"><button className="primary-btn"><SearchCheck/> Submit Background Check</button></div></form></section>
 <section className="panel"><SectionTitle kicker="CURRENT CHECK" title="Background Verification Status" sub="This status is shared with the Super Admin verification dashboard."/><div className="bg-status"><div className="bg-main"><div className="row-icon purple"><SearchCheck/></div><div><b>{form.employer||"Previous employment"}</b><span>{form.designation||"Employment details"} · {form.from} — {form.to}</span></div></div><StatusPill status={data.background.status}/></div></section>
 </div>
}

function Profile({data,setData}){
 const [preview,setPreview]=useState(data.profilePhoto||"");
 const upload=e=>{const f=e.target.files?.[0];if(!f)return;const reader=new FileReader();reader.onload=()=>{setPreview(reader.result);setData({profilePhoto:reader.result})};reader.readAsDataURL(f)};
 return <div className="page">
 <section className="profile-hero"><div className="profile-avatar-wrap">{preview?<img src={preview} className="profile-photo"/>:<div className="profile-photo placeholder"><CircleUserRound/></div>}<label className="photo-upload"><Upload/><input type="file" accept="image/*" onChange={upload}/></label></div><div className="profile-main"><span className="section-kicker light">EMPLOYEE PROFILE</span><h2>{demoEmployee.name}</h2><p>{demoEmployee.email}</p><div className="profile-tags"><span>EMPLOYEE</span><span>{demoEmployee.department}</span><span>{demoEmployee.designation}</span></div></div><div className="profile-active"><i/> Active account</div></section>
 <section className="panel"><SectionTitle kicker="HRMS RECORD" title="Employee Details" sub="Information linked to your HRMS account."/><div className="info-grid profile-info">{Object.entries({"EMPLOYEE CODE":demoEmployee.id,"DEPARTMENT":demoEmployee.department,"DESIGNATION":demoEmployee.designation,"JOINING DATE":demoEmployee.joiningDate,"EMAIL":demoEmployee.email,"PHONE":demoEmployee.phone,"ACCOUNT STATUS":demoEmployee.status,"MEMBER SINCE":demoEmployee.memberSince}).map(([k,v])=><div className="info-item" key={k}><span>{k}</span><b>{v}</b></div>)}</div></section>
 <section className="panel security-panel"><div className="row-icon purple"><ShieldCheck/></div><div><b>Verification account secured</b><span>Your profile photo is stored locally in this demo build and can be connected to your HRMS API/storage when deployed.</span></div><StatusPill status="Active"/></section>
 </div>
}

createRoot(document.getElementById("root")).render(<BrowserRouter><App/></BrowserRouter>);
