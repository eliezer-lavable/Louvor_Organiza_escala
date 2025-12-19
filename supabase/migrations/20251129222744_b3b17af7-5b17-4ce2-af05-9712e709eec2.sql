-- Remover tabelas de repertório/músicas
DROP TABLE IF EXISTS public.schedule_songs CASCADE;
DROP TABLE IF EXISTS public.songs CASCADE;

-- Criar tabela de bloqueios de datas para membros
CREATE TABLE public.member_date_blocks (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  member_id UUID NOT NULL REFERENCES public.members(id) ON DELETE CASCADE,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  reason TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  CONSTRAINT valid_date_range CHECK (end_date >= start_date)
);

-- Enable RLS
ALTER TABLE public.member_date_blocks ENABLE ROW LEVEL SECURITY;

-- RLS Policies para member_date_blocks
CREATE POLICY "Admins podem visualizar todos os bloqueios"
  ON public.member_date_blocks
  FOR SELECT
  USING (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Membros podem visualizar seus próprios bloqueios"
  ON public.member_date_blocks
  FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM public.members m
    WHERE m.id = member_date_blocks.member_id
      AND m.user_id = auth.uid()
  ));

CREATE POLICY "Membros podem criar seus próprios bloqueios"
  ON public.member_date_blocks
  FOR INSERT
  WITH CHECK (EXISTS (
    SELECT 1 FROM public.members m
    WHERE m.id = member_date_blocks.member_id
      AND m.user_id = auth.uid()
  ));

CREATE POLICY "Membros podem atualizar seus próprios bloqueios"
  ON public.member_date_blocks
  FOR UPDATE
  USING (EXISTS (
    SELECT 1 FROM public.members m
    WHERE m.id = member_date_blocks.member_id
      AND m.user_id = auth.uid()
  ));

CREATE POLICY "Membros podem deletar seus próprios bloqueios"
  ON public.member_date_blocks
  FOR DELETE
  USING (EXISTS (
    SELECT 1 FROM public.members m
    WHERE m.id = member_date_blocks.member_id
      AND m.user_id = auth.uid()
  ));

CREATE POLICY "Admins podem gerenciar todos os bloqueios"
  ON public.member_date_blocks
  FOR ALL
  USING (has_role(auth.uid(), 'admin'::app_role));

-- Trigger para atualizar updated_at
CREATE TRIGGER update_member_date_blocks_updated_at
  BEFORE UPDATE ON public.member_date_blocks
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- Criar índices para melhor performance
CREATE INDEX idx_member_date_blocks_member_id ON public.member_date_blocks(member_id);
CREATE INDEX idx_member_date_blocks_dates ON public.member_date_blocks(start_date, end_date);