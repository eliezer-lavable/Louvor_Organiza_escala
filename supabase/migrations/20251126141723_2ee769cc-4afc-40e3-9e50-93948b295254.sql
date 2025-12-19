-- Criar enum para roles
CREATE TYPE public.app_role AS ENUM ('admin', 'member');

-- Criar tabela de roles de usuários (segurança crítica)
CREATE TABLE public.user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  role app_role NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, role)
);

-- Adicionar coluna user_id na tabela members para vincular
ALTER TABLE public.members ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL UNIQUE;

-- Criar tabela de perfis
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  member_id UUID REFERENCES public.members(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Habilitar RLS
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Função security definer para verificar role (evita recursão RLS)
CREATE OR REPLACE FUNCTION public.has_role(_user_id UUID, _role app_role)
RETURNS BOOLEAN
LANGUAGE SQL
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles
    WHERE user_id = _user_id AND role = _role
  )
$$;

-- Função para criar perfil automaticamente ao registrar
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_member_id UUID;
BEGIN
  -- Buscar member_id pelo email
  SELECT id INTO v_member_id
  FROM public.members
  WHERE LOWER(email) = LOWER(NEW.email)
  LIMIT 1;

  -- Criar perfil
  INSERT INTO public.profiles (id, member_id)
  VALUES (NEW.id, v_member_id);

  -- Se encontrou um membro, atribuir role 'member' e vincular user_id
  IF v_member_id IS NOT NULL THEN
    INSERT INTO public.user_roles (user_id, role)
    VALUES (NEW.id, 'member');
    
    UPDATE public.members
    SET user_id = NEW.id
    WHERE id = v_member_id;
  END IF;

  RETURN NEW;
END;
$$;

-- Trigger para executar a função ao criar usuário
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- RLS Policies para user_roles (apenas leitura própria e admins podem gerenciar)
CREATE POLICY "Users can view their own roles"
  ON public.user_roles FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can manage all roles"
  ON public.user_roles FOR ALL
  TO authenticated
  USING (public.has_role(auth.uid(), 'admin'));

-- RLS Policies para profiles
CREATE POLICY "Users can view their own profile"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Admins can view all profiles"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (public.has_role(auth.uid(), 'admin'));

-- Atualizar políticas de member_availability para membros poderem ver e confirmar
DROP POLICY IF EXISTS "Allow public read access on member_availability" ON public.member_availability;
DROP POLICY IF EXISTS "Allow public update on member_availability" ON public.member_availability;

CREATE POLICY "Members can view their own availability"
  ON public.member_availability FOR SELECT
  TO authenticated
  USING (
    public.has_role(auth.uid(), 'admin') OR
    EXISTS (
      SELECT 1 FROM public.members m
      WHERE m.id = member_availability.member_id
      AND m.user_id = auth.uid()
    )
  );

CREATE POLICY "Members can update their own availability"
  ON public.member_availability FOR UPDATE
  TO authenticated
  USING (
    public.has_role(auth.uid(), 'admin') OR
    EXISTS (
      SELECT 1 FROM public.members m
      WHERE m.id = member_availability.member_id
      AND m.user_id = auth.uid()
    )
  );

-- Trigger para atualizar updated_at em profiles
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();