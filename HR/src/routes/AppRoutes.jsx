import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import Login from "../pages/auth/Login";
import HRLayout from "../components/layout/HRLayout";
import HRDashboard from "../pages/dashboard/HRDashboard";
import InterviewManagement from "../pages/InterviewManagement/InterviewManagement";
import AIInterviews from "../pages/aiInterviews/AIInterviews";
import NewJoining from "../pages/joining/NewJoining";
import ChatPage from "../components/chat/ChatPage";
import AutomatedAttendance from "../pages/attendance/AutomatedAttendance";
import MyPerformance from "../pages/performance/PerformanceSheet";
import WorkAssignment from "../pages/workassignment/WorkAssignment";
import EODReport from "../pages/eodreport/EODReport";
import WorkPolicy from "../pages/workpolicy/WorkPolicy";
import SOPManagement from "../pages/sop/SOPManagement";
import WebFormsInbox from "../pages/webforms/WebFormsInbox";
import AdvancedSearch from "../pages/search/AdvancedSearch";
import WorkTarget from "../pages/worktarget/WorkTarget";
import ComplaintList from "../pages/complaint/ComplaintList";
import ComplaintDetail from "../pages/complaint/ComplaintDetail";
import LeadList from "../pages/leads/LeadList";
import LeadDetails from "../pages/leads/LeadDetails";
import MyTargets from "../pages/myTargets/MyTargets";
import MyAssignments from "../pages/work/MyAssignments";
import MyEOD from "../pages/work/MyEOD";
import MobileBottomNav from "../components/common/MobileBottomNav";
import { Home, MapPin, MessageSquare, Users, ClipboardList, FileText, Target, BookOpen, AlertCircle, UserPlus, CalendarCheck, BarChart3 } from "lucide-react";

export default function AppRoutes() {
  return <BrowserRouter><Routes>
    <Route path="/" element={<Login />} />
    <Route path="/login" element={<Login />} />
    <Route element={<HRLayout />}>
      <Route path="/dashboard" element={<HRDashboard />} />
      <Route path="/ai-interviews" element={<AIInterviews />} />
      <Route path="/new-joining" element={<NewJoining />} />
      <Route path="/chat" element={<ChatPage />} />
      <Route path="/my-performance" element={<MyPerformance />} />
      <Route path="/attendance" element={<AutomatedAttendance />} />
      <Route path="/work-assignment" element={<WorkAssignment />} />
      <Route path="/eod-report" element={<EODReport />} />
      <Route path="/work-policy" element={<WorkPolicy />} />
      <Route path="/sop-management" element={<SOPManagement />} />
      <Route path="/web-forms" element={<WebFormsInbox />} />
      <Route path="/advanced-search" element={<AdvancedSearch />} />
      <Route path="/work-target" element={<WorkTarget />} />
      <Route path="/complaint" element={<ComplaintList />} />
      <Route path="/complaints/:id" element={<ComplaintDetail />} />
      <Route path="/leads" element={<LeadList />} />
      <Route path="/leads/:id" element={<LeadDetails />} />
      <Route path="/my-targets" element={<MyTargets />} />
      <Route path="/my-assignments" element={<MyAssignments />} />
      <Route path="/my-eod" element={<MyEOD />} />
      <Route path="/interview-management" element={<InterviewManagement />} />
    </Route>
    <Route path="*" element={<Navigate to="/" replace />} />
  </Routes>
  <MobileBottomNav hideOn={["/"]}
    items={[
      {to:"/dashboard",label:"Home",icon:<Home size={20}/>},
      {to:"/attendance",label:"Attendance",icon:<MapPin size={20}/>},
      {to:"/leads",label:"Leads",icon:<Users size={20}/>},
      {to:"/chat",label:"Chat",icon:<MessageSquare size={20}/>}
    ]}
    moreItems={[
      {to:"/new-joining",label:"New Joining",icon:<UserPlus size={18}/>},
      {to:"/interview-management",label:"Interviews",icon:<CalendarCheck size={18}/>},
      {to:"/work-assignment",label:"Assignments",icon:<ClipboardList size={18}/>},
      {to:"/eod-report",label:"EOD Reports",icon:<FileText size={18}/>},
      {to:"/work-target",label:"Targets",icon:<Target size={18}/>},
      {to:"/work-policy",label:"Policies",icon:<BookOpen size={18}/>},
      {to:"/complaint",label:"Complaints",icon:<AlertCircle size={18}/>},
      {to:"/my-performance",label:"Performance",icon:<BarChart3 size={18}/>},
      {to:"/my-targets",label:"My Targets",icon:<Target size={18}/>},
      {to:"/my-assignments",label:"My Work",icon:<ClipboardList size={18}/>},
      {to:"/my-eod",label:"My EOD",icon:<FileText size={18}/>}
    ]}
  />
  </BrowserRouter>;
}
