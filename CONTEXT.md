# Contexto do Sistema LouvorApp - Vale Church Lavras

## Visão Geral
Este é um sistema completo de gestão para o ministério de louvor da Vale Church Lavras. Desenvolvido com tecnologias modernas web, permite organizar membros, equipes, escalas de cultos e repertório musical de forma eficiente.

## Tecnologias Utilizadas
- **Frontend**: React 18 + TypeScript + Vite
- **UI Framework**: shadcn/ui + Tailwind CSS + Radix UI
- **Backend**: Supabase (PostgreSQL + Auth + Storage)
- **Estado**: TanStack Query (React Query)
- **Roteamento**: React Router DOM
- **Formulários**: React Hook Form + Zod
- **Datas**: date-fns (com locale pt-BR)
- **Ícones**: Lucide React
- **Build Tool**: Vite
- **Package Manager**: npm/pnpm/bun

## Estrutura do Banco de Dados

### Tabelas Principais
- **members**: Membros do ministério (nome, papel/instrumento, contato, foto)
- **teams**: Equipes de louvor
- **team_members**: Relacionamento muitos-para-muitos entre equipes e membros
- **schedules**: Escalas de cultos (título, data, tipo: normal/especial, equipe)
- **schedule_songs**: Músicas associadas às escalas (com ordem)
- **songs**: Repertório musical (título, artista, link YouTube, tom, notas)
- **member_availability**: Disponibilidade dos membros para escalas
- **member_date_blocks**: Bloqueios de agenda (indisponibilidades)
- **substitution_requests**: Solicitações de substituição
- **admin_notifications**: Notificações enviadas pelos admins
- **notification_recipients**: Destinatários das notificações
- **user_roles**: Controle de permissões (admin/member)

### Enums
- **member_role**: vocal, guitarra, baixo, bateria, teclado, violao, tecnico_som, tecnico_imagem
- **schedule_type**: normal, especial

## Funcionalidades Principais

### Área Administrativa (requer role 'admin')
- **Dashboard**: Visão geral com estatísticas (membros, equipes, escalas)
- **Gerenciamento de Membros**: CRUD completo, upload de fotos, gestão de credenciais
- **Gerenciamento de Equipes**: CRUD, associação de membros
- **Gerenciamento de Escalas**: CRUD, associação de músicas e equipes
- **Calendário**: Visualização mensal das escalas
- **Relatório de Disponibilidade**: Análise de disponibilidade dos membros
- **Substituições**: Aprovação/rejeição de pedidos de substituição
- **Notificações**: Envio de mensagens para membros selecionados

### Área do Membro
- **Minhas Escalas**: Visualização das escalas em que está escalado
- **Calendário Pessoal**: Agenda com escalas e bloqueios
- **Disponibilidade**: Confirmação de presença em escalas
- **Bloqueios de Agenda**: Cadastro de períodos de indisponibilidade
- **Solicitações de Substituição**: Pedir substituto para escalas
- **Notificações**: Recebimento de mensagens dos admins

## Estrutura de Arquivos

### src/
- **components/**: Componentes reutilizáveis
  - ui/: Componentes base do shadcn/ui
  - Dialogs para CRUD (AddMemberDialog, EditScheduleDialog, etc.)
  - DashboardLayout, AppSidebar, ProtectedRoute
- **pages/**: Páginas da aplicação
  - Index: Landing page
  - Auth: Login
  - Dashboard: Admin dashboard
  - Members, Teams, Schedules: CRUD pages
  - MemberArea: Área pessoal do membro
  - CalendarView, AvailabilityReport, AdminSubstitutions
- **integrations/supabase/**: Cliente e tipos do Supabase
- **hooks/**: Custom hooks (use-toast, use-mobile)
- **lib/**: Utilitários

### supabase/
- **migrations/**: Scripts SQL de criação/alteração das tabelas
- **functions/**: Edge functions (create-member-user, cleanup-old-schedules)
- **config.toml**: Configuração do projeto Supabase

## Autenticação e Autorização
- **Supabase Auth**: Autenticação baseada em email/senha
- **Row Level Security (RLS)**: Políticas de segurança nas tabelas
- **user_roles**: Controle de permissões (admin vs member)
- **ProtectedRoute**: Componente que verifica autenticação e permissões

## Funcionalidades Específicas
- **Confirmação de Disponibilidade**: Membros podem confirmar presença em escalas
- **Sistema de Substituições**: Membros podem solicitar substitutos, admins aprovam
- **Bloqueios de Agenda**: Membros podem marcar períodos de indisponibilidade
- **Repertório Musical**: Cadastro de músicas com links do YouTube
- **Notificações**: Sistema de mensagens dos admins para membros
- **Upload de Fotos**: Membros podem ter fotos de perfil
- **Calendário Integrado**: Visualização mensal das escalas

## Fluxos de Usuário

### Novo Membro
1. Admin cadastra membro no sistema
2. Admin cria credenciais de acesso
3. Membro recebe email com link de ativação
4. Membro faz login e configura foto e bloqueios de agenda

### Criação de Escala
1. Admin cria escala com data, título e tipo
2. Sistema sugere membros disponíveis baseado na equipe
3. Admin confirma a escala
4. Membros recebem notificação e podem confirmar disponibilidade

### Solicitação de Substituição
1. Membro solicita substituto para uma escala
2. Admin recebe notificação
3. Admin aprova/rejeita ou sugere outro membro
4. Novo membro é escalado automaticamente

## Considerações Técnicas
- **Responsivo**: Interface adaptável para desktop e mobile
- **Offline-first**: Funciona sem conexão (exceto operações que requerem backend)
- **Performance**: Otimizado com lazy loading e caching do React Query
- **Acessibilidade**: Componentes acessíveis com Radix UI
- **Type Safety**: TypeScript em todo o projeto
- **SEO**: Meta tags configuradas para compartilhamento

## Deploy e Ambiente
- **Desenvolvimento**: `npm run dev` ou `pnpm dev`
- **Build**: `npm run build`
- **Preview**: `npm run preview`
- **Deploy**: Via Lovable.dev ou plataformas compatíveis com Vite
- **Variáveis de Ambiente**: VITE_SUPABASE_URL, VITE_SUPABASE_PUBLISHABLE_KEY

## Próximas Melhorias Potenciais
- Integração com Google Calendar
- Notificações push
- App mobile nativo
- Relatórios avançados
- Integração com plataformas de música (Spotify, YouTube)
- Backup automático de dados
- API para integrações externas

## Contato
Sistema desenvolvido para Vale Church Lavras
Email: [contato da igreja]
Versão: 1.0.0
Última atualização: Dezembro 2024