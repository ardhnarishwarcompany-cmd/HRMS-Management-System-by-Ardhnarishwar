import { Routes, Route, Navigate } from "react-router-dom";

import ProtectedRoute from "./ProtectedRoute";
import PublicRoute from "./PublicRoute";
import Login from "../pages/auth/Login";
import NotFound from "../pages/NotFound";
import SalesReports from "../pages/SalesReports";
import SalesCalls from "../pages/calls/SalesCalls";
import FieldSales from "../pages/fieldsales/FieldSales";
import WorkTarget from "../pages/worktarget/WorkAssignment";
import WorkAssignment from "../pages/work/MyAssignments";
import WorkPolicy from "../pages/workpolicy/WorkPolicy";
import PerformanceSheet from "../pages/performance/PerformanceSheet";
import EOD from "../pages/work/MyEOD";
import ComplaintList from "../pages/complaint/ComplaintList";
import ComplaintDetail from "../pages/complaint/ComplaintDetail";
import LeadList from "../pages/leads/LeadList";
import LeadDetails from "../pages/leads/LeadDetails";
import Services from "../pages/services/Services";
import Invoices from "../pages/invoices/Invoices";
import CreateInvoice from "../pages/invoices/CreateInvoice";
import InvoicePreview from "../pages/invoices/InvoicePreview";
import ServiceTemplate from "../pages/services/ServiceTemplate";
import SalesInventory from "../pages/inventory/SalesInventory";
import AddClient from "../pages/clients/AddClient";
import Proposals from "../pages/proposals/Proposals";
import CreateProposal from "../pages/proposals/CreateProposal";
import ProposalPreview from "../pages/proposals/ProposalPreview";
import ChatPage from "../pages/ChatPage";

export default function AppRoutes() {
  return (
    <Routes>
      <Route
        path="/login"
        element={
          <PublicRoute>
            <Login />
          </PublicRoute>
        }
      />

      {/* One protected route owns the SalesLayout. */}
      <Route element={<ProtectedRoute />}>
        <Route path="/sales-reports" element={<SalesReports />} />
        <Route path="/sales-calls" element={<SalesCalls />} />
        <Route path="/field-sales" element={<FieldSales />} />
        <Route path="/work-target" element={<WorkTarget />} />
        <Route path="/work-assignment" element={<WorkAssignment />} />
        <Route path="/performance" element={<PerformanceSheet />} />
        <Route path="/clients" element={<AddClient />} />
        <Route path="/services" element={<Services />} />
        <Route path="/services/:id" element={<ServiceTemplate />} />
        <Route path="/inventory" element={<SalesInventory />} />
        <Route path="/work-policy" element={<WorkPolicy />} />
        <Route path="/eod" element={<EOD />} />
        <Route path="/complaint" element={<ComplaintList />} />
        <Route path="/complaints/:id" element={<ComplaintDetail />} />
        <Route path="/leads" element={<LeadList />} />
        <Route path="/leads/:id" element={<LeadDetails />} />
        <Route path="/invoices" element={<Invoices />} />
        <Route path="/create-invoice" element={<CreateInvoice />} />
        <Route path="/invoice/:id" element={<InvoicePreview />} />
        <Route path="/proposals" element={<Proposals />} />
        <Route path="/proposals/create" element={<CreateProposal />} />
        <Route path="/proposals/:id" element={<ProposalPreview />} />
        <Route path="/chat" element={<ChatPage />} />
        <Route path="/" element={<Navigate to="/sales-reports" replace />} />
        <Route path="*" element={<NotFound />} />
      </Route>
    </Routes>
  );
}
