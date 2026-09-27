import { useState } from "react";
import { NavLink, useLocation } from "react-router-dom";
import {
  BarChart3, Phone, MapPin, Target, ClipboardList, BookOpen, FileText,
  TrendingUp, AlertCircle, Users, Boxes, Package, UserPlus, Handshake,
  Receipt, MessageSquare, LayoutDashboard, Menu, X, ChevronLeft, ChevronRight,
  LogOut,
} from "lucide-react";
import { useAuth } from "../../context/AuthContext";

const sections = [
  {
    title: "Overview",
    items: [{ to: "/sales-reports", label: "Sales Reports", icon: BarChart3 }],
  },
  {
    title: "Sales & Clients",
    items: [
      { to: "/leads", label: "Leads", icon: Users },
      { to: "/clients", label: "Clients", icon: UserPlus },
      { to: "/sales-calls", label: "Calls", icon: Phone },
      { to: "/field-sales", label: "Field Sales / BDE", icon: MapPin },
      { to: "/proposals", label: "Proposals", icon: Handshake },
      { to: "/invoices", label: "Invoices", icon: Receipt },
      { to: "/services", label: "Services", icon: Boxes },
      { to: "/inventory", label: "Inventory", icon: Package },
    ],
  },
  {
    title: "Work Management",
    items: [
      { to: "/work-target", label: "Work Target", icon: Target },
      { to: "/work-assignment", label: "Work Assignment", icon: ClipboardList },
      { to: "/work-policy", label: "Policy", icon: BookOpen },
      { to: "/eod", label: "EOD", icon: FileText },
      { to: "/performance", label: "Performance", icon: TrendingUp },
      { to: "/complaint", label: "Complaints", icon: AlertCircle },
      { to: "/chat", label: "Chat", icon: MessageSquare },
    ],
  },
];

export default function SalesSidebar() {
  const [open, setOpen] = useState(false);
  const [collapsed, setCollapsed] = useState(false);
  const location = useLocation();
  const { logout } = useAuth();

  const closeMobile = () => setOpen(false);
  const handleLogout = () => {
    logout();
    closeMobile();
  };

  return (
    <>
      <button
        type="button"
        onClick={() => setOpen(true)}
        className="fixed left-4 top-4 z-[80] rounded-xl bg-slate-950 p-2.5 text-white shadow-lg md:hidden"
        aria-label="Open sales navigation"
      >
        <Menu size={21} />
      </button>

      {open && (
        <button
          aria-label="Close navigation overlay"
          onClick={closeMobile}
          className="fixed inset-0 z-[70] bg-slate-950/50 backdrop-blur-sm md:hidden"
        />
      )}

      <aside
        className={`fixed inset-y-0 left-0 z-[75] flex w-[270px] flex-col border-r border-slate-800 bg-[#0b1220] text-slate-200 shadow-2xl transition-transform duration-300 md:translate-x-0 ${
          open ? "translate-x-0" : "-translate-x-full"
        } ${collapsed ? "md:w-[84px]" : ""}`}
      >
        <div className="flex h-[76px] items-center gap-3 border-b border-slate-800 px-4">
          <img src="/logo.jpeg" alt="Recruweb" className="h-10 w-10 rounded-xl bg-white object-contain p-1" />
          {!collapsed && (
            <div className="min-w-0 flex-1">
              <div className="truncate text-base font-extrabold text-white">Recruweb</div>
              <div className="text-[10px] font-semibold uppercase tracking-[0.18em] text-slate-500">Sales Portal</div>
            </div>
          )}
          <button onClick={closeMobile} className="rounded-lg p-2 text-slate-400 hover:bg-slate-800 hover:text-white md:hidden">
            <X size={19} />
          </button>
        </div>

        <div className="flex-1 overflow-y-auto px-3 py-4 sidebar-scroll">
          {sections.map((section) => (
            <div key={section.title} className="mb-5">
              {!collapsed && (
                <div className="mb-2 px-3 text-[10px] font-bold uppercase tracking-[0.18em] text-slate-500">
                  {section.title}
                </div>
              )}
              <div className="space-y-1">
                {section.items.map(({ to, label, icon: Icon }) => {
                  const active = location.pathname === to || location.pathname.startsWith(`${to}/`);
                  return (
                    <NavLink
                      key={to}
                      to={to}
                      onClick={closeMobile}
                      title={collapsed ? label : undefined}
                      className={`group flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-semibold transition-all ${
                        active
                          ? "bg-white text-slate-950 shadow-lg shadow-black/20"
                          : "text-slate-400 hover:bg-slate-800 hover:text-white"
                      } ${collapsed ? "justify-center" : ""}`}
                    >
                      <Icon size={18} strokeWidth={2.2} />
                      {!collapsed && <span className="truncate">{label}</span>}
                    </NavLink>
                  );
                })}
              </div>
            </div>
          ))}
        </div>

        <div className="border-t border-slate-800 p-3">
          <button
            onClick={handleLogout}
            title={collapsed ? "Logout" : undefined}
            className={`flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-semibold text-rose-300 transition hover:bg-rose-500/10 hover:text-rose-200 ${collapsed ? "justify-center" : ""}`}
          >
            <LogOut size={18} />
            {!collapsed && "Logout"}
          </button>
          <button
            onClick={() => setCollapsed((v) => !v)}
            className="mt-2 hidden w-full items-center justify-center rounded-xl border border-slate-800 py-2 text-slate-500 hover:bg-slate-800 hover:text-white md:flex"
            title={collapsed ? "Expand sidebar" : "Collapse sidebar"}
          >
            {collapsed ? <ChevronRight size={17} /> : <ChevronLeft size={17} />}
          </button>
        </div>
      </aside>
    </>
  );
}
