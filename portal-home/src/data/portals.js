export const PORTALS = [
  {
    key: "employee",
    name: "Employee Self-Service",
    category: "core",
    badge: "CORE",
    desc: "Self-service check-in, leave requests, payslip access, work assignments & profile.",
    accentColor: "#3b82f6",
    gradient: "linear-gradient(135deg, #3b82f6, #1d4ed8)",
    shadowDark: "rgba(59, 130, 246, 0.4)",
    shadowLight: "rgba(37, 99, 235, 0.2)",
    badgeStyleDark: "bg-blue-500/15 text-blue-400 border-blue-500/30",
    badgeStyleLight: "bg-blue-100 text-blue-700 border-blue-200",
    btnBg: "linear-gradient(135deg, #2563eb, #1d4ed8)"
  },
  {
    key: "hr",
    name: "HR & Workforce",
    category: "core",
    badge: "CORE",
    desc: "Employee onboarding, leave approvals, policy enforcement & workforce records.",
    accentColor: "#a855f7",
    gradient: "linear-gradient(135deg, #a855f7, #7e22ce)",
    shadowDark: "rgba(168, 85, 247, 0.4)",
    shadowLight: "rgba(147, 51, 234, 0.2)",
    badgeStyleDark: "bg-purple-500/15 text-purple-400 border-purple-500/30",
    badgeStyleLight: "bg-purple-100 text-purple-700 border-purple-200",
    btnBg: "linear-gradient(135deg, #9333ea, #7e22ce)"
  },
  {
    key: "it",
    name: "IT & Dev Operations",
    category: "core",
    badge: "CORE",
    desc: "Asset allocations, IT support tickets, developer tasks, timesheets & deliverables.",
    accentColor: "#06b6d4",
    gradient: "linear-gradient(135deg, #06b6d4, #0e7490)",
    shadowDark: "rgba(6, 182, 212, 0.4)",
    shadowLight: "rgba(14, 116, 144, 0.2)",
    badgeStyleDark: "bg-cyan-500/15 text-cyan-400 border-cyan-500/30",
    badgeStyleLight: "bg-cyan-100 text-cyan-700 border-cyan-200",
    btnBg: "linear-gradient(135deg, #0891b2, #0e7490)"
  },
  {
    key: "sales",
    name: "Sales & Proposals",
    category: "business",
    badge: "BUSINESS",
    desc: "Lead tracking, sales targets, proposal generation, client calls & revenue reports.",
    accentColor: "#f59e0b",
    gradient: "linear-gradient(135deg, #f59e0b, #b45309)",
    shadowDark: "rgba(245, 158, 11, 0.4)",
    shadowLight: "rgba(217, 119, 6, 0.2)",
    badgeStyleDark: "bg-amber-500/15 text-amber-400 border-amber-500/30",
    badgeStyleLight: "bg-amber-100 text-amber-800 border-amber-200",
    btnBg: "linear-gradient(135deg, #d97706, #b45309)"
  },
  {
    key: "client",
    name: "Client Portal",
    category: "business",
    badge: "BUSINESS",
    desc: "Client project oversight, invoice management, deliverables & lead approvals.",
    accentColor: "#10b981",
    gradient: "linear-gradient(135deg, #10b981, #047857)",
    shadowDark: "rgba(16, 185, 129, 0.4)",
    shadowLight: "rgba(5, 150, 105, 0.2)",
    badgeStyleDark: "bg-emerald-500/15 text-emerald-400 border-emerald-500/30",
    badgeStyleLight: "bg-emerald-100 text-emerald-800 border-emerald-200",
    btnBg: "linear-gradient(135deg, #059669, #047857)"
  },
  {
    key: "aiRobotics",
    name: "AI Robo Interview",
    category: "ai",
    badge: "AI TOOL",
    desc: "Autonomous AI-conducted candidate video interviews with automated evaluation.",
    accentColor: "#8b5cf6",
    gradient: "linear-gradient(135deg, #8b5cf6, #5b21b6)",
    shadowDark: "rgba(139, 92, 246, 0.4)",
    shadowLight: "rgba(124, 58, 237, 0.2)",
    badgeStyleDark: "bg-purple-500/15 text-purple-300 border-purple-500/30",
    badgeStyleLight: "bg-purple-100 text-purple-800 border-purple-200",
    btnBg: "linear-gradient(135deg, #7c3aed, #5b21b6)"
  },
  {
    key: "smartAttendance",
    name: "Smart Attendance & AI",
    category: "ai",
    badge: "AI TOOL",
    desc: "Smart tools to boost productivity, automate tasks & enhance efficiency.",
    accentColor: "#ec4899",
    gradient: "linear-gradient(135deg, #ec4899, #be185d)",
    shadowDark: "rgba(236, 72, 153, 0.4)",
    shadowLight: "rgba(219, 39, 119, 0.2)",
    badgeStyleDark: "bg-pink-500/15 text-pink-300 border-pink-500/30",
    badgeStyleLight: "bg-pink-100 text-pink-800 border-pink-200",
    btnBg: "linear-gradient(135deg, #db2777, #be185d)"
  },
  {
    key: "evs",
    name: "Employee Verification",
    category: "ai",
    badge: "SECURITY",
    desc: "Data protection, secure access, monitoring & compliance.",
    accentColor: "#2563eb",
    gradient: "linear-gradient(135deg, #2563eb, #1e40af)",
    shadowDark: "rgba(37, 99, 235, 0.4)",
    shadowLight: "rgba(29, 78, 216, 0.2)",
    badgeStyleDark: "bg-blue-500/15 text-blue-300 border-blue-500/30",
    badgeStyleLight: "bg-blue-100 text-blue-800 border-blue-200",
    btnBg: "linear-gradient(135deg, #1d4ed8, #1e40af)"
  }
];

export function resolveUrl(key) {
  if (window.HRMS_PORTAL_CONFIG && typeof window.HRMS_PORTAL_CONFIG.getUrl === 'function') {
    return window.HRMS_PORTAL_CONFIG.getUrl(key);
  }
  return "#";
}
