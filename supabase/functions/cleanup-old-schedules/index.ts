import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Calculate the date 30 days ago
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    const cutoffDate = thirtyDaysAgo.toISOString().split("T")[0];

    console.log(`Cleaning up schedules older than ${cutoffDate}`);

    // First, get the schedule IDs to delete
    const { data: oldSchedules, error: fetchError } = await supabase
      .from("schedules")
      .select("id")
      .lt("schedule_date", cutoffDate);

    if (fetchError) {
      console.error("Error fetching old schedules:", fetchError.message);
      throw fetchError;
    }

    if (!oldSchedules || oldSchedules.length === 0) {
      console.log("No old schedules found to delete");
      return new Response(
        JSON.stringify({ message: "No old schedules to delete", deleted: 0 }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const scheduleIds = oldSchedules.map((s) => s.id);
    console.log(`Found ${scheduleIds.length} old schedules to delete`);

    // Delete related records first (foreign key constraints)
    // Delete schedule_members
    const { error: membersError } = await supabase
      .from("schedule_members")
      .delete()
      .in("schedule_id", scheduleIds);

    if (membersError) {
      console.error("Error deleting schedule_members:", membersError.message);
    }

    // Delete member_availability
    const { error: availabilityError } = await supabase
      .from("member_availability")
      .delete()
      .in("schedule_id", scheduleIds);

    if (availabilityError) {
      console.error("Error deleting member_availability:", availabilityError.message);
    }

    // Delete substitution_requests
    const { error: substitutionError } = await supabase
      .from("substitution_requests")
      .delete()
      .in("schedule_id", scheduleIds);

    if (substitutionError) {
      console.error("Error deleting substitution_requests:", substitutionError.message);
    }

    // Now delete the schedules
    const { error: deleteError } = await supabase
      .from("schedules")
      .delete()
      .in("id", scheduleIds);

    if (deleteError) {
      console.error("Error deleting schedules:", deleteError.message);
      throw deleteError;
    }

    console.log(`Successfully deleted ${scheduleIds.length} old schedules`);

    return new Response(
      JSON.stringify({
        message: "Old schedules cleaned up successfully",
        deleted: scheduleIds.length,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("Cleanup error:", error);
    const errorMessage = error instanceof Error ? error.message : "Unknown error";
    return new Response(
      JSON.stringify({ error: errorMessage }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
