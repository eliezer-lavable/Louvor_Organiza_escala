-- =============================================
-- TEAMS TABLE: Replace public with authenticated
-- =============================================
DROP POLICY IF EXISTS "Allow public read access on teams" ON teams;
DROP POLICY IF EXISTS "Allow public insert on teams" ON teams;
DROP POLICY IF EXISTS "Allow public update on teams" ON teams;
DROP POLICY IF EXISTS "Allow public delete on teams" ON teams;

CREATE POLICY "Authenticated users can view teams" ON teams
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Admins can insert teams" ON teams
  FOR INSERT TO authenticated WITH CHECK (has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can update teams" ON teams
  FOR UPDATE TO authenticated USING (has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can delete teams" ON teams
  FOR DELETE TO authenticated USING (has_role(auth.uid(), 'admin'));

-- =============================================
-- SCHEDULES TABLE: Replace public with authenticated
-- =============================================
DROP POLICY IF EXISTS "Allow public read access on schedules" ON schedules;
DROP POLICY IF EXISTS "Allow public insert on schedules" ON schedules;
DROP POLICY IF EXISTS "Allow public update on schedules" ON schedules;
DROP POLICY IF EXISTS "Allow public delete on schedules" ON schedules;

CREATE POLICY "Authenticated users can view schedules" ON schedules
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Admins can insert schedules" ON schedules
  FOR INSERT TO authenticated WITH CHECK (has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can update schedules" ON schedules
  FOR UPDATE TO authenticated USING (has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can delete schedules" ON schedules
  FOR DELETE TO authenticated USING (has_role(auth.uid(), 'admin'));

-- =============================================
-- TEAM_MEMBERS TABLE: Replace public with authenticated
-- =============================================
DROP POLICY IF EXISTS "Allow public read access on team_members" ON team_members;
DROP POLICY IF EXISTS "Allow public insert on team_members" ON team_members;
DROP POLICY IF EXISTS "Allow public delete on team_members" ON team_members;

CREATE POLICY "Authenticated users can view team_members" ON team_members
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Admins can insert team_members" ON team_members
  FOR INSERT TO authenticated WITH CHECK (has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can delete team_members" ON team_members
  FOR DELETE TO authenticated USING (has_role(auth.uid(), 'admin'));

-- =============================================
-- SCHEDULE_MEMBERS TABLE: Replace public with authenticated
-- =============================================
DROP POLICY IF EXISTS "Allow public read on schedule_members" ON schedule_members;
DROP POLICY IF EXISTS "Allow public insert on schedule_members" ON schedule_members;
DROP POLICY IF EXISTS "Allow public delete on schedule_members" ON schedule_members;

CREATE POLICY "Authenticated users can view schedule_members" ON schedule_members
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Admins can insert schedule_members" ON schedule_members
  FOR INSERT TO authenticated WITH CHECK (has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can delete schedule_members" ON schedule_members
  FOR DELETE TO authenticated USING (has_role(auth.uid(), 'admin'));

-- =============================================
-- MEMBER_AVAILABILITY TABLE: Replace public with authenticated
-- =============================================
DROP POLICY IF EXISTS "Allow public insert on member_availability" ON member_availability;
DROP POLICY IF EXISTS "Allow public delete on member_availability" ON member_availability;

CREATE POLICY "Admins can insert member_availability" ON member_availability
  FOR INSERT TO authenticated WITH CHECK (
    has_role(auth.uid(), 'admin') OR 
    EXISTS (SELECT 1 FROM members m WHERE m.id = member_availability.member_id AND m.user_id = auth.uid())
  );

CREATE POLICY "Admins can delete member_availability" ON member_availability
  FOR DELETE TO authenticated USING (
    has_role(auth.uid(), 'admin') OR 
    EXISTS (SELECT 1 FROM members m WHERE m.id = member_availability.member_id AND m.user_id = auth.uid())
  );