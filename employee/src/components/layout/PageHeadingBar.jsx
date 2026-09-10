import { useLocation } from "react-router-dom";
import {
  LayoutDashboard, ClipboardList, FileText, Target, BarChart3, BookOpen,
  Fingerprint, CalendarDays, WalletCards, MessageSquare, UserCircle2
} from "lucide-react";

const META = {
  "/dashboard": ["Dashboard", "HRMS Control Center", LayoutDashboard],
  "/assignments": ["My Assignments", "Track and manage your assigned work", ClipboardList],
  "/eod": ["My EOD", "Submit and review your daily work reports", FileText],
  "/targets": ["My Targets", "Track your work goals, progress and deadlines", Target],
  "/performance": ["Performance", "Review your performance and feedback", BarChart3],
  "/sops": ["SOP Library", "Company policies and standard operating procedures", BookOpen],
  "/attendance": ["Attendance", "Check in, check out and review your attendance", Fingerprint],
  "/leave": ["Leave Management", "Manage leave, holidays and overtime requests", CalendarDays],
  "/compensation": ["Compensation", "View salary benefits, reimbursements and rewards", WalletCards],
  "/chat": ["AI Chat", "Get quick answers about your HRMS and company policies", MessageSquare],
  "/profile": ["My Profile", "View and manage your employee profile", UserCircle2],
};

export default function PageHeadingBar() {
  const { pathname } = useLocation();
  const meta = META[pathname];
  if (!meta) return null;
  const [title, subtitle, Icon] = meta;
  // Assignments and EOD already have richer hero headers inside their pages.
  if (pathname === "/assignments" || pathname === "/eod") return null;
  return (
    <div className="employee-page-headingbar">
      <div className="employee-page-heading-icon"><Icon size={20} /></div>
      <div className="employee-page-heading-copy">
        <h1>{title}</h1>
        <p>{subtitle}</p>
      </div>
      <div className="employee-page-heading-accent" aria-hidden="true" />
    </div>
  );
}
