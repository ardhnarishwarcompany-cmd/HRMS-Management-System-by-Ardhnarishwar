import { useClientAuth } from "../../context/ClientAuthContext";

// Modules that are always available regardless of Master Control settings
const ALWAYS_ON = [
  "OVERVIEW",
  "PROPOSALS",
  "SOP_LIBRARY",
  "LEAVE_APPROVALS",
  "OFFER_LETTERS",
 ];

const EMPLOYEE_HIDDEN = new Set([
  "EMPLOYEE_MANAGEMENT", "EMPLOYEE_SEARCH", "INTERVIEW_TRACKER", "PERFORMANCE_REPORT",
  "FINANCE_DASHBOARD", "INVENTORY", "ASSETS", "TAX", "AUDIT_LOGS",
]);

export default function FeatureGuard({ featureKey, children }) {
  const { enabledFeatures, client } = useClientAuth();
  const isEmployee = client?.role === "CLIENT_EMPLOYEE";

  if (isEmployee && EMPLOYEE_HIDDEN.has(featureKey)) return null;

  if (ALWAYS_ON.includes(featureKey)) return children;
  if (!enabledFeatures?.includes(featureKey)) return null;

  return children;
}
