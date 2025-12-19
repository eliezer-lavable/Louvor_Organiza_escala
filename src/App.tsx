import { Toaster } from "@/components/ui/toaster";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import Index from "./pages/Index";
import Auth from "./pages/Auth";
import MemberArea from "./pages/MemberArea";
import Dashboard from "./pages/Dashboard";
import Members from "./pages/Members";
import Teams from "./pages/Teams";
import Schedules from "./pages/Schedules";
import CalendarView from "./pages/CalendarView";
import AvailabilityReport from "./pages/AvailabilityReport";
import AdminSubstitutions from "./pages/AdminSubstitutions";
import NotFound from "./pages/NotFound";
import { DashboardLayout } from "./components/DashboardLayout";
import { ProtectedRoute } from "./components/ProtectedRoute";

const queryClient = new QueryClient();

const App = () => (
  <QueryClientProvider client={queryClient}>
    <TooltipProvider>
      <Toaster />
      <Sonner />
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<Index />} />
          <Route path="/auth" element={<Auth />} />
          <Route 
            path="/member-area" 
            element={
              <ProtectedRoute>
                <DashboardLayout>
                  <MemberArea />
                </DashboardLayout>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/dashboard" 
            element={
              <ProtectedRoute requireAdmin>
                <DashboardLayout>
                  <Dashboard />
                </DashboardLayout>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/members" 
            element={
              <ProtectedRoute requireAdmin>
                <DashboardLayout>
                  <Members />
                </DashboardLayout>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/teams" 
            element={
              <ProtectedRoute requireAdmin>
                <DashboardLayout>
                  <Teams />
                </DashboardLayout>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/schedules" 
            element={
              <ProtectedRoute requireAdmin>
                <DashboardLayout>
                  <Schedules />
                </DashboardLayout>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/calendar" 
            element={
              <ProtectedRoute requireAdmin>
                <DashboardLayout>
                  <CalendarView />
                </DashboardLayout>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/availability-report" 
            element={
              <ProtectedRoute requireAdmin>
                <DashboardLayout>
                  <AvailabilityReport />
                </DashboardLayout>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/substitutions" 
            element={
              <ProtectedRoute requireAdmin>
                <DashboardLayout>
                  <AdminSubstitutions />
                </DashboardLayout>
              </ProtectedRoute>
            } 
          />
          {/* ADD ALL CUSTOM ROUTES ABOVE THE CATCH-ALL "*" ROUTE */}
          <Route path="*" element={<NotFound />} />
        </Routes>
      </BrowserRouter>
    </TooltipProvider>
  </QueryClientProvider>
);

export default App;
