-- Add instrument column to schedule_members and create member_instruments table
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

ALTER TABLE public.schedule_members
  ADD COLUMN IF NOT EXISTS instrument text;

CREATE TABLE IF NOT EXISTS public.member_instruments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id uuid NOT NULL REFERENCES public.members(id) ON DELETE CASCADE,
  instrument text NOT NULL,
  created_at timestamptz DEFAULT now()
);
