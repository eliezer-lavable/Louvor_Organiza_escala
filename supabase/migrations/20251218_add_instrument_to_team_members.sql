-- Add instrument column to team_members
ALTER TABLE public.team_members
ADD COLUMN IF NOT EXISTS instrument text NULL;
