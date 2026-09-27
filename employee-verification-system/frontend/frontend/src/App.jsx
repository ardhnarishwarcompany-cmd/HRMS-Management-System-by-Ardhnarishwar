import { BrowserRouter, Routes, Route } from "react-router-dom";

import Login from "./pages/Login";
import Dashboard from "./pages/Dashboard";
import Employees from "./pages/Employees";
import Documents from "./pages/Documents";
import Reports from "./pages/Reports";
import Profile from "./pages/Profile";
import MyVerification from "./pages/MyVerification";
import AuditLogs from "./pages/AuditLogs";

import IdentityVerification from "./pages/IdentityVerification";
import InternationalVerification from "./pages/InternationalVerification";
import VerificationStatus from "./pages/VerificationStatus";
import BackgroundVerification from "./pages/BackgroundVerification";
import VerifyPage from "./pages/VerifyPage";

import ProtectedRoute from "./components/ProtectedRoute";
import SmokeCursor from "./components/SmokeCursor";

const guard = (el) => <ProtectedRoute>{el}</ProtectedRoute>;

function App() {
  return (
    <BrowserRouter>
      <SmokeCursor color={[258, 88, 74]} />
      <Routes>
        <Route path="/" element={<Login />} />

        {/* Public - opened from the verification email link */}
        <Route path="/verify/:token" element={<VerifyPage />} />

        <Route path="/dashboard" element={guard(<Dashboard />)} />

        <Route path="/employees" element={guard(<Employees />)} />

        <Route path="/documents" element={guard(<Documents />)} />
        <Route path="/my-verification" element={guard(<MyVerification />)} />

        <Route path="/reports" element={guard(<Reports />)} />

        <Route path="/profile" element={guard(<Profile />)} />

        <Route path="/audit-logs" element={guard(<AuditLogs />)} />

        <Route
          path="/identity-verification"
          element={guard(<IdentityVerification />)}
        />

        <Route
          path="/international-verification"
          element={guard(<InternationalVerification />)}
        />

        <Route
          path="/verification-status"
          element={guard(<VerificationStatus />)}
        />

        <Route
          path="/background-verification"
          element={guard(<BackgroundVerification />)}
        />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
