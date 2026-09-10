import { useEffect, useState } from "react";
import {
  Bell,
  LogOut,
  TrendingUp,
  ChevronRight,
  X,
  ClipboardList,
  CalendarCheck,
  Timer,
  GitPullRequest,
  Flag,
  BarChart3,
  Bug,
  Rocket,
  BookOpen,
  Video,
  FileBarChart,
  Code2,
  MessageSquare,
  Fingerprint,
  Award,
  ScrollText,
  Target,
  Briefcase,
  FileText,
  MessageCircleWarning,
  Cake,
} from "lucide-react";
import { useNavigate } from "react-router-dom";
import {
  getTodayBirthdays,
  markNotificationsRead,
} from "../../services/notificationService";

export default function ITDashboard() {
  const navigate = useNavigate();
  const [notifications, setNotifications] = useState([]);
  const [openDropdown, setOpenDropdown] = useState(false);

  const user = JSON.parse(localStorage.getItem("hrms_it_User") || "{}");
  const unread = notifications.filter((n) => !n.is_read).length;

  const handleLogout = () => {
    localStorage.removeItem("hrms_it_Token");
    localStorage.removeItem("hrms_it_User");
    window.location.href = "/";
  };

  const menuItems = [
    {
      title: "Task Assignment",
      path: "/it/tasks",
      icon: ClipboardList,
      gradient: "from-purple-500 to-fuchsia-500",
    },
    {
      title: "Daily Work Submission",
      path: "/it/daily-work",
      icon: CalendarCheck,
      gradient: "from-emerald-500 to-teal-500",
    },
    {
      title: "Timesheet",
      path: "/it/timesheet",
      icon: Timer,
      gradient: "from-violet-500 to-purple-600",
    },
    {
      title: "Code Review Status",
      path: "/it/code-reviews",
      icon: GitPullRequest,
      gradient: "from-sky-500 to-blue-600",
    },
    {
      title: "Project Milestone Tracker",
      path: "/it/milestones",
      icon: Flag,
      gradient: "from-orange-500 to-amber-500",
    },
    {
      title: "Performance Reporting",
      desc: "Your tasks, hours, merged PRs and bugs at a glance",
      path: "/it/performance-report",
      icon: BarChart3,
      gradient: "from-indigo-500 to-purple-600",
    },
    {
      title: "Bug Reporting",
      path: "/it/bugs",
      icon: Bug,
      gradient: "from-rose-500 to-red-500",
    },
    {
      title: "Feature Deployment Log",
      path: "/it/deployments",
      icon: Rocket,
      gradient: "from-pink-500 to-fuchsia-600",
    },
    {
      title: "SOP Management",
      path: "/it/sop",
      icon: BookOpen,
      gradient: "from-blue-500 to-indigo-600",
    },
    {
      title: "Video Documentation",
      path: "/it/videos",
      icon: Video,
      gradient: "from-rose-500 to-pink-600",
    },
    {
      title: "Project Reports",
      path: "/it/project-reports",
      icon: FileBarChart,
      gradient: "from-emerald-500 to-green-600",
    },
    {
      title: "Source Code",
      path: "/it/source-code",
      icon: Code2,
      gradient: "from-slate-600 to-slate-800",
    },
    {
      title: "Chat",
      path: "/chat",
      icon: MessageSquare,
      gradient: "from-cyan-500 to-sky-600",
    },
    {
      title: "Automated Attendance",
      path: "/attendance",
      icon: Fingerprint,
      gradient: "from-teal-500 to-emerald-600",
    },
    {
      title: "Performance",
      desc: "Your HR performance reviews and ratings",
      path: "/my-performance",
      icon: Award,
      gradient: "from-amber-500 to-orange-600",
    },
    {
      title: "Work Policy",
      path: "/work-policy",
      icon: ScrollText,
      gradient: "from-indigo-500 to-blue-600",
    },
    {
      title: "My Targets",
      path: "/my-targets",
      icon: Target,
      gradient: "from-fuchsia-500 to-purple-600",
    },
    {
      title: "My assignments",
      path: "/my-assignments",
      icon: Briefcase,
      gradient: "from-blue-500 to-cyan-500",
    },
    {
      title: "EOD",
      path: "/my-eod",
      icon: FileText,
      gradient: "from-emerald-500 to-lime-600",
    },
    {
      title: "Complaint box",
      path: "/complaint",
      icon: MessageCircleWarning,
      gradient: "from-red-500 to-rose-600",
    },
  ];

  const fetchNotifications = async () => {
    try {
      const res = await getTodayBirthdays();
      setNotifications(res?.data?.data || []);
    } catch (err) {
      console.log(err);
    }
  };

  useEffect(() => {
    fetchNotifications();
  }, []);

  const openNotifications = async () => {
    setOpenDropdown(!openDropdown);
    try {
      await markNotificationsRead();
      setNotifications((prev) => prev.map((n) => ({ ...n, is_read: 1 })));
    } catch (err) {
      console.log(err);
    }
  };

  const today = new Date().toLocaleDateString("en-IN", {
    weekday: "long",
    day: "numeric",
    month: "long",
    year: "numeric",
  });

  return (
    <div className="it-dashboard-page">
      <section className="it-overview-hero">
        <div className="it-hero-grid" />
        <div className="it-hero-content">
          <div>
            <p className="it-hero-date">{today}</p>
            <h2>Welcome back, {user.name || "User"}</h2>
            <p>Here&apos;s what&apos;s happening in your IT workspace today.</p>
            <div className="it-hero-badges">
              <span>⌘ {menuItems.length} Modules</span><span>♧ {unread} Alerts</span>
            </div>
          </div>
          <button onClick={() => navigate("/it/performance-report")} className="it-hero-action"><TrendingUp size={16}/> Performance</button>
        </div>
      </section>

      <section className="it-section-head"><div><h2>IT Features</h2><p>Manage your IT workspace from the available modules.</p></div><span>{menuItems.length} of {menuItems.length}</span></section>
      <main className="it-feature-grid">
        {menuItems.map((item) => { const Icon = item.icon; return (
          <button key={item.path} onClick={() => navigate(item.path)} className="it-feature-card">
            <ChevronRight size={16} className="it-card-arrow"/>
            <div className={`it-feature-icon bg-gradient-to-br ${item.gradient}`}><Icon size={22}/></div>
            <div><h3>{item.title}</h3><p>{item.desc || `Manage your ${item.title.toLowerCase()} easily`}</p></div>
          </button>
        ); })}
      </main>
    </div>
  );
}
