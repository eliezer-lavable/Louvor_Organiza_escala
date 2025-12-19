-- Criar função para verificar se o usuário é ministro
CREATE OR REPLACE FUNCTION public.is_ministro()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.members m
    WHERE m.user_id = auth.uid()
      AND m.role = 'ministro'
  )
$$;

-- Atualizar políticas RLS da tabela songs
-- Remover políticas antigas de modificação pública
DROP POLICY IF EXISTS "Allow public insert on songs" ON public.songs;
DROP POLICY IF EXISTS "Allow public update on songs" ON public.songs;
DROP POLICY IF EXISTS "Allow public delete on songs" ON public.songs;

-- Criar novas políticas restritas a ministros
CREATE POLICY "Ministros podem inserir músicas"
ON public.songs
FOR INSERT
TO authenticated
WITH CHECK (public.is_ministro());

CREATE POLICY "Ministros podem atualizar músicas"
ON public.songs
FOR UPDATE
TO authenticated
USING (public.is_ministro());

CREATE POLICY "Ministros podem deletar músicas"
ON public.songs
FOR DELETE
TO authenticated
USING (public.is_ministro());