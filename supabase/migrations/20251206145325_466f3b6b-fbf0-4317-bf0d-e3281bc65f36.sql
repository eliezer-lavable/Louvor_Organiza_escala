-- Remove public RLS policies on members table
DROP POLICY IF EXISTS "Allow public read access on members" ON members;
DROP POLICY IF EXISTS "Allow public insert on members" ON members;
DROP POLICY IF EXISTS "Allow public update on members" ON members;
DROP POLICY IF EXISTS "Allow public delete on members" ON members;

-- Create secure RLS policies for members table
-- Admins can do everything
CREATE POLICY "Admins manage members"
ON members FOR ALL
TO authenticated
USING (has_role(auth.uid(), 'admin'))
WITH CHECK (has_role(auth.uid(), 'admin'));

-- Authenticated members can view all members (needed for team views)
CREATE POLICY "Authenticated users can view members"
ON members FOR SELECT
TO authenticated
USING (true);

-- Members can update their own record (for photo upload)
CREATE POLICY "Members can update own record"
ON members FOR UPDATE
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());