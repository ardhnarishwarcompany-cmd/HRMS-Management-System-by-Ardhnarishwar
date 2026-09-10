import EmployeeNavbar from "./EmployeeNavbar";
import PageHeadingBar from "./PageHeadingBar";

/**
 * Shared Employee Portal shell.
 * The sidebar + top bar are mounted once here so every protected page
 * has the exact same navigation chrome, including AI Chat.
 */
export default function EmployeeLayout({ children }) {
  return (
    <div className="employee-app-shell">
      <EmployeeNavbar />
      <div className="employee-app-content"><PageHeadingBar />{children}</div>
    </div>
  );
}
