-- Create enum for member roles/instruments
CREATE TYPE member_role AS ENUM ('vocal', 'guitarra', 'baixo', 'bateria', 'teclado', 'violao', 'tecnico_som', 'tecnico_imagem');

-- Create enum for schedule types
CREATE TYPE schedule_type AS ENUM ('normal', 'especial');

-- Create members table
CREATE TABLE public.members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  role member_role NOT NULL,
  phone TEXT,
  email TEXT,
  photo_url TEXT,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Create teams table
CREATE TABLE public.teams (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Create team_members junction table
CREATE TABLE public.team_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  team_id UUID REFERENCES public.teams(id) ON DELETE CASCADE NOT NULL,
  member_id UUID REFERENCES public.members(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(team_id, member_id)
);

-- Create songs table
CREATE TABLE public.songs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  artist TEXT,
  youtube_url TEXT,
  key TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Create schedules table
CREATE TABLE public.schedules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  schedule_date DATE NOT NULL,
  schedule_type schedule_type DEFAULT 'normal',
  team_id UUID REFERENCES public.teams(id) ON DELETE SET NULL,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Create schedule_songs junction table
CREATE TABLE public.schedule_songs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  schedule_id UUID REFERENCES public.schedules(id) ON DELETE CASCADE NOT NULL,
  song_id UUID REFERENCES public.songs(id) ON DELETE CASCADE NOT NULL,
  song_order INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(schedule_id, song_id)
);

-- Create member_availability table
CREATE TABLE public.member_availability (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id UUID REFERENCES public.members(id) ON DELETE CASCADE NOT NULL,
  schedule_id UUID REFERENCES public.schedules(id) ON DELETE CASCADE NOT NULL,
  available BOOLEAN DEFAULT true,
  confirmed BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(member_id, schedule_id)
);

-- Enable Row Level Security
ALTER TABLE public.members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.team_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.songs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.schedule_songs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.member_availability ENABLE ROW LEVEL SECURITY;

-- Create policies (public access for now, will add auth later)
CREATE POLICY "Allow public read access on members" ON public.members FOR SELECT USING (true);
CREATE POLICY "Allow public insert on members" ON public.members FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update on members" ON public.members FOR UPDATE USING (true);
CREATE POLICY "Allow public delete on members" ON public.members FOR DELETE USING (true);

CREATE POLICY "Allow public read access on teams" ON public.teams FOR SELECT USING (true);
CREATE POLICY "Allow public insert on teams" ON public.teams FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update on teams" ON public.teams FOR UPDATE USING (true);
CREATE POLICY "Allow public delete on teams" ON public.teams FOR DELETE USING (true);

CREATE POLICY "Allow public read access on team_members" ON public.team_members FOR SELECT USING (true);
CREATE POLICY "Allow public insert on team_members" ON public.team_members FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public delete on team_members" ON public.team_members FOR DELETE USING (true);

CREATE POLICY "Allow public read access on songs" ON public.songs FOR SELECT USING (true);
CREATE POLICY "Allow public insert on songs" ON public.songs FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update on songs" ON public.songs FOR UPDATE USING (true);
CREATE POLICY "Allow public delete on songs" ON public.songs FOR DELETE USING (true);

CREATE POLICY "Allow public read access on schedules" ON public.schedules FOR SELECT USING (true);
CREATE POLICY "Allow public insert on schedules" ON public.schedules FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update on schedules" ON public.schedules FOR UPDATE USING (true);
CREATE POLICY "Allow public delete on schedules" ON public.schedules FOR DELETE USING (true);

CREATE POLICY "Allow public read access on schedule_songs" ON public.schedule_songs FOR SELECT USING (true);
CREATE POLICY "Allow public insert on schedule_songs" ON public.schedule_songs FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public delete on schedule_songs" ON public.schedule_songs FOR DELETE USING (true);

CREATE POLICY "Allow public read access on member_availability" ON public.member_availability FOR SELECT USING (true);
CREATE POLICY "Allow public insert on member_availability" ON public.member_availability FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update on member_availability" ON public.member_availability FOR UPDATE USING (true);
CREATE POLICY "Allow public delete on member_availability" ON public.member_availability FOR DELETE USING (true);

-- Create function to update timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for timestamp updates
CREATE TRIGGER update_members_updated_at BEFORE UPDATE ON public.members
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_teams_updated_at BEFORE UPDATE ON public.teams
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_songs_updated_at BEFORE UPDATE ON public.songs
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_schedules_updated_at BEFORE UPDATE ON public.schedules
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_member_availability_updated_at BEFORE UPDATE ON public.member_availability
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();