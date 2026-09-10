import { Navigate, Outlet } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import SalesLayout from "../layouts/SalesLayout";

/**
 * Protects the Sales portal and owns the SalesLayout exactly once.
 * Child pages must render through <Outlet /> and must NOT wrap themselves
 * in another SalesLayout.
 */
export default function ProtectedRoute() {
  const { auth } = useAuth();

  if (!auth?.token) return <Navigate to="/login" replace />;

  return (
    <SalesLayout>
      <Outlet />
    </SalesLayout>
  );
}
