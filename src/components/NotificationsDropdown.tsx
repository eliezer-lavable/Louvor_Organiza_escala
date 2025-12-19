import { useState, useEffect } from "react";
import { useToast } from "@/hooks/use-toast";
import { AdminMessagePopup } from "@/components/AdminMessagePopup";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Badge } from "@/components/ui/badge";
import { Bell, Calendar, UserMinus, Clock, MessageSquare } from "lucide-react";
import { format, differenceInDays } from "date-fns";
import { ptBR } from "date-fns/locale";
import { useNavigate } from "react-router-dom";


export function NotificationsDropdown() {
  type Notification = {
    id: string;
    type: "upcoming_schedule" | "substitution_request" | "pending_confirmation" | "admin_message";
    title: string;
    description: string;
    date?: string;
    scheduleId?: string;
    recipientId?: string;
  };

  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [open, setOpen] = useState(false);
  const [adminPopup, setAdminPopup] = useState<{title: string, description: string, recipientId: string} | null>(null);
  const navigate = useNavigate();
  const { toast } = useToast();

  useEffect(() => {
    loadNotifications();
    // eslint-disable-next-line
  }, []);

  const loadNotifications = async () => {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return;

    const { data: profile } = await supabase
      .from("profiles")
      .select("member_id")
      .eq("id", user.id)
      .single();

    if (!profile?.member_id) return;

    const notificationsList: Notification[] = [];

    // 1. Admin notifications (unread)
    const { data: adminNotifications } = await supabase
      .from("notification_recipients")
      .select(`
        id,
        read_at,
        notification:admin_notifications(id, title, message, created_at)
      `)
      .eq("member_id", profile.member_id)
      .is("read_at", null);

    adminNotifications?.forEach((item: any) => {
      if (item.notification) {
        notificationsList.push({
          id: `admin-${item.notification.id}`,
          type: "admin_message",
          title: item.notification.title,
          description: item.notification.message,
          date: item.notification.created_at,
          recipientId: item.id,
        });
      }
    });

    // 2. Pending substitution requests received
    const { data: pendingRequests } = await supabase
      .from("substitution_requests")
      .select(`
        id,
        schedule:schedules(id, title, schedule_date),
        requesting_member:members!substitution_requests_requesting_member_id_fkey(name)
      `)
      .eq("substitute_member_id", profile.member_id)
      .eq("status", "pending");

    pendingRequests?.forEach((req: any) => {
      notificationsList.push({
        id: `sub-${req.id}`,
        type: "substitution_request",
        title: "Solicitação de Substituição",
        description: `${req.requesting_member?.name} solicitou que você o substitua em "${req.schedule?.title}"`,
        date: req.schedule?.schedule_date,
        scheduleId: req.schedule?.id,
      });
    });

    // 3. Get member's teams
    const { data: memberTeams } = await supabase
      .from("team_members")
      .select("team_id")
      .eq("member_id", profile.member_id);

    const teamIds = memberTeams?.map(mt => mt.team_id) || [];

    if (teamIds.length > 0) {
      // 4. Upcoming schedules (next 7 days)
      const today = new Date();
      const nextWeek = new Date();
      nextWeek.setDate(nextWeek.getDate() + 7);

      const { data: upcomingSchedules } = await supabase
        .from("schedules")
        .select("id, title, schedule_date")
        .in("team_id", teamIds)
        .gte("schedule_date", today.toISOString().split("T")[0])
        .lte("schedule_date", nextWeek.toISOString().split("T")[0])
        .order("schedule_date");

      // Check which schedules member hasn't confirmed yet
      for (const schedule of upcomingSchedules || []) {
        const { data: availability } = await supabase
          .from("member_availability")
          .select("confirmed")
          .eq("schedule_id", schedule.id)
          .eq("member_id", profile.member_id)
          .maybeSingle();

        const daysUntil = differenceInDays(new Date(schedule.schedule_date), today);

        if (!availability?.confirmed) {
          notificationsList.push({
            id: `confirm-${schedule.id}`,
            type: "pending_confirmation",
            title: "Confirmação Pendente",
            description: `Confirme sua presença para "${schedule.title}"`,
            date: schedule.schedule_date,
            scheduleId: schedule.id,
          });
        } else if (daysUntil <= 3 && daysUntil >= 0) {
          notificationsList.push({
            id: `upcoming-${schedule.id}`,
            type: "upcoming_schedule",
            title: daysUntil === 0 ? "Escala Hoje!" : `Escala em ${daysUntil} dia${daysUntil > 1 ? "s" : ""}`,
            description: schedule.title,
            date: schedule.schedule_date,
            scheduleId: schedule.id,
          });
        }
      }
    }

    // Sort by date (admin messages first, then by date)
    notificationsList.sort((a, b) => {
      if (a.type === "admin_message" && b.type !== "admin_message") return -1;
      if (b.type === "admin_message" && a.type !== "admin_message") return 1;
      if (!a.date) return 1;
      if (!b.date) return -1;
      return new Date(b.date).getTime() - new Date(a.date).getTime();
    });

    setNotifications(notificationsList);
    // Se houver admin_message não lida, exibir toast de alerta
    const adminMsg = notificationsList.find(n => n.type === "admin_message");
    if (adminMsg) {
      toast({
        title: "Nova mensagem",
        description: adminMsg.title,
        variant: "default",
      });
    }
  };

  const getIcon = (type: Notification["type"]) => {
    switch (type) {
      case "admin_message":
        return <MessageSquare className="h-4 w-4 text-primary" />;
      case "substitution_request":
        return <UserMinus className="h-4 w-4 text-orange-500" />;
      case "upcoming_schedule":
        return <Calendar className="h-4 w-4 text-blue-500" />;
      case "pending_confirmation":
        return <Clock className="h-4 w-4 text-yellow-500" />;
    }
  };

  const handleNotificationClick = async (notification: Notification) => {
    if (notification.type === "admin_message" && notification.recipientId) {
      setAdminPopup({
        title: notification.title,
        description: notification.description,
        recipientId: notification.recipientId,
      });
      return;
    }
    setOpen(false);
    navigate("/minha-area");
  };

  return (
    <>
      {adminPopup && (
        <AdminMessagePopup
          title={adminPopup.title}
          description={adminPopup.description}
          onClose={async () => {
            // Marcar como lida ao fechar popup
            await supabase
              .from("notification_recipients")
              .update({ read_at: new Date().toISOString() })
              .eq("id", adminPopup.recipientId);
            setNotifications((prev) => prev.filter((n) => !(n.type === "admin_message" && n.recipientId === adminPopup.recipientId)));
            setAdminPopup(null);
          }}
        />
      )}
      <DropdownMenu open={open} onOpenChange={setOpen}>
        <DropdownMenuTrigger asChild>
          <Button variant="ghost" size="icon" className="relative">
            <Bell className="h-5 w-5" />
            {notifications.length > 0 && (
              <Badge
                variant="destructive"
                className="absolute -top-1 -right-1 h-5 w-5 flex items-center justify-center p-0 text-xs"
              >
                {notifications.length}
              </Badge>
            )}
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end" className="w-80">
          <div className="p-2 font-semibold border-b">Notificações</div>
          <ScrollArea className="h-[300px]">
            {notifications.length === 0 ? (
              <div className="p-4 text-center text-muted-foreground">
                Nenhuma notificação
              </div>
            ) : (
              <div className="py-1">
                {notifications.map((notification) => (
                  <button
                    key={notification.id}
                    className="w-full p-3 hover:bg-muted text-left flex gap-3 border-b last:border-0"
                    onClick={() => handleNotificationClick(notification)}
                  >
                    <div className="mt-0.5">{getIcon(notification.type)}</div>
                    <div className="flex-1 min-w-0">
                      <p className="font-medium text-sm">{notification.title}</p>
                      <p className="text-sm text-muted-foreground line-clamp-2">
                        {notification.description}
                      </p>
                      {notification.date && (
                        <p className="text-xs text-muted-foreground mt-1">
                          {format(new Date(notification.date), "d 'de' MMM, HH:mm", { locale: ptBR })}
                        </p>
                      )}
                    </div>
                  </button>
                ))}
              </div>
            )}
          </ScrollArea>
        </DropdownMenuContent>
      </DropdownMenu>
    </>
  );
}