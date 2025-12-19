-- Criar tabela para relacionar escalas com membros individuais
CREATE TABLE public.schedule_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  schedule_id UUID NOT NULL REFERENCES public.schedules(id) ON DELETE CASCADE,
  member_id UUID NOT NULL REFERENCES public.members(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE(schedule_id, member_id)
);

-- Enable RLS
ALTER TABLE public.schedule_members ENABLE ROW LEVEL SECURITY;

-- Policies para schedule_members
CREATE POLICY "Allow public read on schedule_members"
  ON public.schedule_members FOR SELECT
  USING (true);

CREATE POLICY "Allow public insert on schedule_members"
  ON public.schedule_members FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Allow public delete on schedule_members"
  ON public.schedule_members FOR DELETE
  USING (true);

-- Criar tabela para substituições
CREATE TABLE public.substitution_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  schedule_id UUID NOT NULL REFERENCES public.schedules(id) ON DELETE CASCADE,
  requesting_member_id UUID NOT NULL REFERENCES public.members(id) ON DELETE CASCADE,
  substitute_member_id UUID NOT NULL REFERENCES public.members(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Enable RLS para substitution_requests
ALTER TABLE public.substitution_requests ENABLE ROW LEVEL SECURITY;

-- Policies para substitution_requests
CREATE POLICY "Members can view their substitution requests"
  ON public.substitution_requests FOR SELECT
  USING (
    requesting_member_id IN (SELECT id FROM members WHERE user_id = auth.uid())
    OR substitute_member_id IN (SELECT id FROM members WHERE user_id = auth.uid())
    OR has_role(auth.uid(), 'admin'::app_role)
  );

CREATE POLICY "Members can create substitution requests"
  ON public.substitution_requests FOR INSERT
  WITH CHECK (
    requesting_member_id IN (SELECT id FROM members WHERE user_id = auth.uid())
  );

CREATE POLICY "Substitute members can update requests"
  ON public.substitution_requests FOR UPDATE
  USING (
    substitute_member_id IN (SELECT id FROM members WHERE user_id = auth.uid())
    OR has_role(auth.uid(), 'admin'::app_role)
  );

-- Trigger para updated_at
CREATE TRIGGER update_substitution_requests_updated_at
  BEFORE UPDATE ON public.substitution_requests
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- Indexes para performance
CREATE INDEX idx_schedule_members_schedule ON public.schedule_members(schedule_id);
CREATE INDEX idx_schedule_members_member ON public.schedule_members(member_id);
CREATE INDEX idx_substitution_requests_schedule ON public.substitution_requests(schedule_id);
CREATE INDEX idx_substitution_requests_requesting ON public.substitution_requests(requesting_member_id);
CREATE INDEX idx_substitution_requests_substitute ON public.substitution_requests(substitute_member_id);