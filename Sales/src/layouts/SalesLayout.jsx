import { useState } from "react";
import { NavLink, useLocation, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import {
  LayoutDashboard, Users, UserPlus, PhoneCall, FileText, Receipt,
  Target, ClipboardList, TrendingUp, MapPin, Boxes, BriefcaseBusiness,
  BookOpen, MessageSquare, AlertCircle, LogOut, Menu, X, ChevronDown,
  Bell, Search, UserRound, BarChart3, CalendarCheck, PackageSearch,
  Handshake, PanelLeftClose, PanelLeftOpen
} from "lucide-react";

const NAV = [
  { label: "Dashboard", to: "/sales-reports", icon: LayoutDashboard },
  { label: "Leads & Pipeline", to: "/leads", icon: UserPlus },
  { label: "Clients", to: "/clients", icon: Users },
  { label: "Calls & Follow-ups", to: "/sales-calls", icon: PhoneCall },
  { label: "Proposals", to: "/proposals", icon: Handshake, badge: "Sales" },
  { label: "Invoices", to: "/invoices", icon: Receipt },
  { label: "Sales Reports", to: "/sales-reports", icon: BarChart3 },
  { label: "Field Sales", to: "/field-sales", icon: MapPin },
  { label: "Services", to: "/services", icon: BriefcaseBusiness },
  { label: "Inventory", to: "/inventory", icon: Boxes },
  { label: "Targets", to: "/work-target", icon: Target },
  { label: "My Assignments", to: "/work-assignment", icon: ClipboardList },
  { label: "Work Policy", to: "/work-policy", icon: BookOpen },
  { label: "Performance", to: "/performance", icon: TrendingUp },
  { label: "EOD Reports", to: "/eod", icon: CalendarCheck },
  { label: "Complaints", to: "/complaint", icon: AlertCircle },
  { label: "Team Chat", to: "/chat", icon: MessageSquare },
];

function Sidebar({ open, collapsed, setOpen, setCollapsed }) {
  const { auth, logout } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const doLogout = () => {
    logout();
    navigate("/login", { replace: true });
  };

  return (
    <>
      {open && <button aria-label="Close menu" onClick={() => setOpen(false)} className="fixed inset-0 z-40 bg-slate-950/50 lg:hidden" />}
      <aside className={`fixed inset-y-0 left-0 z-50 flex flex-col bg-[#10162b] text-white shadow-2xl transition-all duration-300 lg:static ${open ? "translate-x-0" : "-translate-x-full lg:translate-x-0"} ${collapsed ? "lg:w-[78px]" : "lg:w-[268px]"} w-[286px]`}>
        <div className="flex h-16 shrink-0 items-center border-b border-white/10 px-4">
          <div className="flex min-w-0 flex-1 items-center gap-3">
            <div className="flex h-10 w-10 shrink-0 items-center justify-center overflow-hidden rounded-xl bg-white shadow-lg">
              <img src="/logo.jpeg" alt="Recruweb" className="h-full w-full object-contain" />
            </div>
            {!collapsed && <div className="min-w-0"><div className="truncate text-sm font-bold">Sales Portal</div><div className="truncate text-[10px] uppercase tracking-[.18em] text-white/40">HRMS Workspace</div></div>}
          </div>
          <button onClick={() => setOpen(false)} className="rounded-lg p-2 text-white/50 hover:bg-white/10 lg:hidden"><X size={18}/></button>
        </div>

        <div className="flex min-h-0 flex-1 flex-col border-b border-white/10 p-3">
          {!collapsed && <div className="mb-2 shrink-0 px-2 text-[10px] font-bold uppercase tracking-[.18em] text-white/35">Sales workspace</div>}
          <nav className="min-h-0 flex-1 space-y-1 overflow-y-auto overscroll-contain pr-1 pb-2">
            {NAV.map(({ label, to, icon: Icon, badge }) => {
              const active = location.pathname === to || (to === "/leads" && location.pathname.startsWith("/leads/")) || (to === "/proposals" && location.pathname.startsWith("/proposals")) || (to === "/invoices" && location.pathname.startsWith("/invoice"));
              return <NavLink key={to} to={to} onClick={() => setOpen(false)} title={collapsed ? label : undefined} className={`group flex items-center gap-3 rounded-lg border px-3 py-2.5 text-[13px] font-medium transition-all ${active ? "border-[#7c8cf5]/40 bg-gradient-to-r from-[#4f63f0]/30 to-[#7c8cf5]/10 text-white shadow-[inset_0_1px_0_rgba(255,255,255,.12)]" : "border-transparent text-white/60 hover:bg-white/[.07] hover:text-white"}`}>
                <Icon size={18} className={`shrink-0 ${active ? "text-indigo-200" : "text-white/50 group-hover:text-white"}`} />
                {!collapsed && <><span className="min-w-0 flex-1 truncate">{label}</span>{badge && active && <span className="rounded-full bg-indigo-400/15 px-1.5 py-0.5 text-[9px] font-bold text-indigo-200">{badge}</span>}</>}
              </NavLink>;
            })}
          </nav>
        </div>

        <div className="shrink-0 border-t border-white/10 bg-[#10162b] p-3">
          <div className={`mb-2 flex items-center gap-3 rounded-xl bg-white/[.05] p-2.5 ${collapsed ? "justify-center" : ""}`}>
            <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-gradient-to-br from-indigo-500 to-violet-500"><UserRound size={17}/></div>
            {!collapsed && <div className="min-w-0"><div className="truncate text-xs font-semibold">{auth?.user?.name || auth?.user?.email || "Sales User"}</div><div className="truncate text-[10px] text-white/40">Sales Executive</div></div>}
          </div>
          <button onClick={doLogout} title={collapsed ? "Logout" : undefined} className={`flex w-full items-center gap-3 rounded-lg px-3 py-2.5 text-xs font-semibold text-rose-200/80 transition hover:bg-rose-500/10 hover:text-rose-100 ${collapsed ? "justify-center" : ""}`}><LogOut size={17}/>{!collapsed && "Logout"}</button>
        </div>
      </aside>
    </>
  );
}

function Topbar({ setOpen, collapsed, setCollapsed }) {
  const { auth } = useAuth();
  const [profileOpen, setProfileOpen] = useState(false);
  const navigate = useNavigate();
  return <header className="relative z-30 flex h-16 shrink-0 items-center justify-between border-b border-slate-200 bg-white px-4 shadow-sm sm:px-6">
    <div className="flex min-w-0 items-center gap-3">
      <button onClick={() => setOpen(true)} className="rounded-lg p-2 text-slate-600 hover:bg-slate-100 lg:hidden"><Menu size={21}/></button>
      <button onClick={() => setCollapsed(v => !v)} className="hidden rounded-lg p-2 text-slate-500 hover:bg-slate-100 lg:block" title={collapsed ? "Expand sidebar" : "Collapse sidebar"}>{collapsed ? <PanelLeftOpen size={20}/> : <PanelLeftClose size={20}/>}</button>
      <div className="min-w-0"><h1 className="truncate text-sm font-bold text-slate-900 sm:text-base">Sales Control Center</h1><p className="hidden text-[11px] text-slate-400 sm:block">Manage pipeline, clients, proposals and revenue</p></div>
    </div>
    <div className="flex items-center gap-1 sm:gap-2">
      <div className="hidden items-center gap-2 rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 md:flex"><Search size={15} className="text-slate-400"/><span className="text-xs text-slate-400">Search workspace</span></div>
      <div className="relative"><button className="relative rounded-xl p-2.5 text-slate-500 hover:bg-slate-100"><Bell size={19}/><span className="absolute right-2 top-2 h-1.5 w-1.5 rounded-full bg-rose-500"/></button></div>
      <div className="relative"><button onClick={() => setProfileOpen(v => !v)} className="flex items-center gap-2 rounded-xl p-1.5 hover:bg-slate-100"><div className="flex h-9 w-9 items-center justify-center rounded-full bg-gradient-to-br from-indigo-500 to-violet-500 text-white"><UserRound size={17}/></div><span className="hidden max-w-28 truncate text-xs font-semibold text-slate-700 sm:block">{auth?.user?.name || auth?.user?.email || "Sales User"}</span><ChevronDown size={14} className="hidden text-slate-400 sm:block"/></button>{profileOpen && <><button className="fixed inset-0 z-40 cursor-default" onClick={() => setProfileOpen(false)}/><div className="absolute right-0 top-12 z-50 w-56 rounded-2xl border border-slate-200 bg-white p-2 shadow-xl"><div className="border-b border-slate-100 px-3 py-2"><div className="text-xs font-bold text-slate-800">{auth?.user?.name || "Sales User"}</div><div className="truncate text-[11px] text-slate-400">{auth?.user?.email || ""}</div></div><button onClick={() => {setProfileOpen(false); navigate("/sales-reports")}} className="mt-1 flex w-full items-center gap-2 rounded-xl px-3 py-2 text-xs font-medium text-slate-600 hover:bg-slate-50"><LayoutDashboard size={15}/> Dashboard</button></div></>}</div>
    </div>
  </header>;
}

export default function SalesLayout({ children }) {
  const [open, setOpen] = useState(false);
  const [collapsed, setCollapsed] = useState(false);
  return <div className="flex h-screen overflow-hidden bg-[#f7f8fb]"><Sidebar open={open} collapsed={collapsed} setOpen={setOpen} setCollapsed={setCollapsed}/><div className="flex min-w-0 flex-1 flex-col overflow-hidden"><Topbar setOpen={setOpen} collapsed={collapsed} setCollapsed={setCollapsed}/><main className="flex-1 overflow-y-auto overflow-x-hidden p-3 sm:p-5 lg:p-6">{children}</main></div></div>;
}
