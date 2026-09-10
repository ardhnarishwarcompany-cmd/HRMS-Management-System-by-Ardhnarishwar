import { useEffect, useState} from "react";
import API from "../../api/axios";
import dayjs from "dayjs";
import toast from "react-hot-toast";
import { Plus, Calendar, Clock, Target, RefreshCw, TrendingUp, Flag, Timer } from "lucide-react";
const PRIORITY_CONFIG = {
  high: { label: "High", color: "bg-red-100 text-red-700" },
  medium: { label: "Medium", color: "bg-yellow-100 text-yellow-700" },
  low: { label: "Low", color: "bg-green-100 text-green-700" },
};

const TARGET_STATUS_CONFIG = {
  pending: { label: "Pending", color: "bg-gray-100 text-gray-700" },
  in_progress: { label: "In Progress", color: "bg-blue-100 text-blue-700" },
  completed: { label: "Completed", color: "bg-green-100 text-green-700" },
  overdue: { label: "Overdue", color: "bg-red-100 text-red-700" },
};

export default function MyTargets() {
  const [targets, setTargets] = useState([]);
  const [loading, setLoading] = useState(false);

  const loadData = async () => {
    try {
      setLoading(true);
      const res = await API.get("/employee/targets");
      setTargets(res.data.data || []);
    } catch (err) {
      console.error(err);
      toast.error("Failed to load targets");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const handleUpdateProgress = async (id, current, target) => {
    try {
      const newValue = Math.min(current + 1, target);

      await API.patch(`/employee/targets/progress/${id}`, {
        currentValue: newValue,
      });

      toast.success("Progress updated");
      loadData();
    } catch (err) {
      toast.error("Update failed");
    }
  };

  const getProgress = (t) =>
    Math.min(Math.round((t.current_value / t.target_value) * 100), 100);

  return (
    <div className="employee-targets-page">
      <div className="employee-content-max">
      <div className="employee-target-summary">
        <div className="employee-target-summary-card">
          <span className="employee-target-summary-icon"><Target size={18} /></span>
          <div><strong>{targets.length}</strong><small>Assigned targets</small></div>
        </div>
        <div className="employee-target-summary-card">
          <span className="employee-target-summary-icon is-green"><TrendingUp size={18} /></span>
          <div><strong>{targets.filter(t => getProgress(t) >= 100).length}</strong><small>Completed</small></div>
        </div>
        <div className="employee-target-summary-card">
          <span className="employee-target-summary-icon is-amber"><Timer size={18} /></span>
          <div><strong>{targets.filter(t => getProgress(t) < 100).length}</strong><small>In progress</small></div>
        </div>
        <button type="button" onClick={loadData} className="employee-target-refresh" disabled={loading}>
          <RefreshCw size={15} className={loading ? "animate-spin" : ""} /> Refresh
        </button>
      </div>

      <div className="employee-target-grid">
        {targets.map((t) => {
          const progress = getProgress(t);
          const priority = PRIORITY_CONFIG[t.priority];
          const status = TARGET_STATUS_CONFIG[t.status];

          const isOverdue =
            dayjs(t.deadline).isBefore(dayjs()) && t.status !== "completed";

          return (
            <div key={t.id} className={`employee-target-card ${t.status === "completed" ? "is-complete" : isOverdue ? "is-overdue" : ""}`}>
              <div className="employee-target-card-top">
                <span className={`employee-target-priority ${priority.color}`}><Flag size={12} /> {priority.label}</span>
                <span className={`employee-target-status ${status.color}`}>{isOverdue ? "Overdue" : status.label}</span>
              </div>

              <div className="employee-target-title-row">
                <div className="employee-target-title-icon"><Target size={17} /></div>
                <h3>{t.title}</h3>
              </div>

              <div className="employee-target-meta">
                <Calendar size={14} />
                {dayjs(t.deadline).format("MMM D, YYYY")}
              </div>

              <div className="employee-target-meta">
                <Clock size={14} />
                {Math.max(dayjs(t.deadline).diff(dayjs(), "day"), 0)} days left
              </div>

              <div className="employee-target-progress">
                <div className="employee-target-progress-head">
                  <span>
                    {t.current_value}/{t.target_value} {t.unit}
                  </span>
                  <span>{progress}%</span>
                </div>

                <div className="employee-target-progress-track"><div className="employee-target-progress-fill" style={{ width: `${progress}%` }} /></div>
              </div>

              <button onClick={() => handleUpdateProgress(t.id, t.current_value, t.target_value)} className="employee-target-update" disabled={progress >= 100}>
                <Plus size={14} />
                {progress >= 100 ? "Target completed" : "Update progress"}
              </button>
            </div>
          );
        })}

        {!targets.length && !loading && (
          <div className="employee-page-hero justify-center text-center"><div><h1>No targets assigned</h1><p>Your assigned goals will appear here.</p></div></div>
        )}
      </div>
      </div>
    </div>
  );
}
