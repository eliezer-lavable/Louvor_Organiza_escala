-- Add unique constraint to members.email to prevent duplicate entries
ALTER TABLE public.members ADD CONSTRAINT unique_member_email UNIQUE (email);
