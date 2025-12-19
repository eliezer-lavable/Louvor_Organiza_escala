# Documentação detalhada da estrutura do LouvorApp

> **Projeto:** `c:\Users\Base-HOme\Documents\LouvorApp\louvor-organiza`
> **Tecnologias:** React + TypeScript, Vite, Tailwind CSS, Supabase, React‑Query, React‑Router, shadcn/ui (componentes UI reutilizáveis).

---

## 1️⃣ Visão geral da árvore de arquivos

```
louvor-organiza/
│
├─ index.html / index1.html                ← HTML de entrada (Vite)
├─ package.json / pnpm-lock.yaml            ← Gerenciamento de dependências
├─ vite.config.ts                           ← Configuração do Vite
├─ tailwind.config.ts                      ← Configuração do Tailwind
├─ tsconfig*.json                           ← Configurações do TypeScript
│
├─ public/
│   └─ robots.txt
│
├─ src/
│   ├─ App.tsx                              ← Raiz da aplicação (rotas, providers)
│   ├─ main.tsx                             ← Bootstrap do React
│   ├─ App.css / index.css                  ← Estilos globais
│   ├─ assets/                               ← Imagens, ícones etc.
│   │
│   ├─ components/                           ← **Componentes de UI da aplicação**
│   │   ├─ AddMemberDialog.tsx               ← Dialogo para criar membro
│   │   ├─ AddScheduleDialog.tsx              ← Dialogo para criar escala
│   │   ├─ AddTeamDialog.tsx                  │
│   │   ├─ AdminMessagePopup.tsx              │
│   │   ├─ AdminNotificationReadStatus.tsx    │
│   │   ├─ AppSidebar.tsx                    │
│   │   ├─ ColorPicker.tsx                    │
│   │   ├─ DashboardLayout.tsx                │
│   │   ├─ EditMemberDialog.tsx               │
│   │   ├─ EditScheduleDialog.tsx             │
│   │   ├─ EditTeamDialog.tsx                  │
│   │   ├─ ManageDateBlocksDialog.tsx          │
│   │   ├─ ManageMemberCredentialsDialog.tsx │
│   │   ├─ ManageTeamMembersDialog.tsx         │
│   │   ├─ MemberCalendar.tsx                  │
│   │   ├─ MemberPhotoUpload.tsx              │
│   │   ├─ NavLink.tsx                        │
│   │   ├─ NotificationsDropdown.tsx          │
│   │   ├─ ProtectedRoute.tsx                  │
│   │   ├─ RequestSubstitutionDialog.tsx      │
│   │   ├─ SendNotificationDialog.tsx          │
│   │   ├─ SubstitutionRequestsSection.tsx    │
│   │   ├─ ThemeToggle.tsx                    │
│   │   └─ ui/                               ← **Componentes UI genéricos (shadcn)**
│   │        ├─ accordion.tsx
│   │        ├─ alert-dialog.tsx
│   │        ├─ button.tsx
│   │        ├─ card.tsx
│   │        ├─ dialog.tsx
│   │        ├─ dropdown‑menu.tsx
│   │        ├─ input.tsx
│   │        ├─ label.tsx
│   │        ├─ toast.tsx
│   │        └─ … (mais 30+ componentes)
│   │
│   ├─ hooks/                                 ← **Hooks customizados**
│   │   ├─ use-mobile.tsx                     │ Detecta breakpoint mobile
│   │   └─ use-toast.tsx                      │ Wrapper para shadcn toast
│   │
│   ├─ integrations/
│   │   └─ supabase/
│   │        └─ client.ts                     ← Instância configurada do Supabase
│   │
│   ├─ lib/
│   │   └─ utils.ts                           ← Função `cn` (clsx + tailwind‑merge)
│   │
│   ├─ pages/                                 ← **Páginas (rotas)**
│   │   ├─ AdminSubstitutions.tsx             ← Tela de gerenciamento de substituições (admin)
│   │   ├─ Auth.tsx                           │ Tela de login / registro
│   │   ├─ AvailabilityReport.tsx              │ Relatório de disponibilidade dos membros
│   │   ├─ CalendarView.tsx                   │ Visão de calendário de escalas
│   │   ├─ Dashboard.tsx                      │ Dashboard principal (estatísticas)
│   │   ├─ Index.tsx                          │ Página inicial (landing)
│   │   ├─ MemberArea.tsx                     │ Área do membro (lista de escalas, fotos, etc.)
│   │   ├─ Members.tsx                         │ Listagem e gerenciamento de membros
│   │   ├─ NotFound.tsx                       │ 404 – rota não encontrada
│   │   ├─ Schedules.tsx                      │ CRUD de escalas
│   │   └─ Teams.tsx                          │ CRUD de equipes
│   │
│   └─ service-worker.js                      ← PWA service‑worker
│
└─ supabase/
    ├─ config.toml                            ← Configuração do Supabase CLI
    ├─ functions/
    │   ├─ cleanup-old-schedules/              │ Função server‑less para limpar escalas antigas
    │   └─ create-member-user/                 │ Cria usuário de login ao cadastrar membro
    └─ migrations/                            │ Scripts SQL de migração do banco
```

---

## 2️⃣ Componentes principais e suas responsabilidades

| Componente | Arquivo | Função / Uso na UI |
|------------|---------|--------------------|
| **AddMemberDialog** | `components/AddMemberDialog.tsx` | Dialog modal para cadastrar novo membro, opcionalmente cria login (Supabase Function `create-member-user`). |
| **AddScheduleDialog** | `components/AddScheduleDialog.tsx` | Modal para criar nova escala de louvor. |
| **AddTeamDialog** | `components/AddTeamDialog.tsx` | Modal para cadastrar equipe (time). |
| **AdminMessagePopup** | `components/AdminMessagePopup.tsx` | Exibe mensagens de admin (ex.: sucesso/erro). |
| **AdminNotificationReadStatus** | `components/AdminNotificationReadStatus.tsx` | Badge que indica número de notificações não lidas (usado no Dashboard). |
| **AppSidebar** | `components/AppSidebar.tsx` | Barra lateral com navegação entre rotas protegidas. |
| **ColorPicker** | `components/ColorPicker.tsx` | Picker de cores usado na customização de tema. |
| **DashboardLayout** | `components/DashboardLayout.tsx` | Layout que envolve as páginas internas (header, sidebar, content). |
| **EditMemberDialog**, **EditScheduleDialog**, **EditTeamDialog** | `components/*Dialog.tsx` | Modais de edição para membros, escalas e equipes. |
| **ManageDateBlocksDialog** | `components/ManageDateBlocksDialog.tsx` | Gerencia blocos de datas (ex.: feriados). |
| **ManageMemberCredentialsDialog** | `components/ManageMemberCredentialsDialog.tsx` | Permite alterar credenciais de login de um membro. |
| **ManageTeamMembersDialog** | `components/ManageTeamMembersDialog.tsx` | Adiciona/remova membros de uma equipe. |
| **MemberCalendar** | `components/MemberCalendar.tsx` | Exibe calendário de compromissos de um membro. |
| **MemberPhotoUpload** | `components/MemberPhotoUpload.tsx` | Upload de foto usando Supabase storage. |
| **NavLink** | `components/NavLink.tsx` | Link estilizado usado na sidebar. |
| **NotificationsDropdown** | `components/NotificationsDropdown.tsx` | Dropdown que lista notificações recentes. |
| **ProtectedRoute** | `components/ProtectedRoute.tsx` | Wrapper de rota que verifica autenticação e, opcionalmente, permissão de admin. |
| **RequestSubstitutionDialog** | `components/RequestSubstitutionDialog.tsx` | Dialog para solicitar substituição de membro em escala. |
| **SendNotificationDialog** | `components/SendNotificationDialog.tsx` | Dialog para enviar notificação push a membros. |
| **SubstitutionRequestsSection** | `components/SubstitutionRequestsSection.tsx` | Seção que lista solicitações de substituição pendentes. |
| **ThemeToggle** | `components/ThemeToggle.tsx` | Botão que alterna entre tema claro e escuro (usa `ColorPicker`). |
| **ui/** | `components/ui/*` | Biblioteca de componentes reutilizáveis (botões, cards, dialogs, toast, etc.) baseada em **shadcn/ui**. Cada arquivo contém um componente estilizado que pode ser importado em qualquer parte da aplicação. |

---

## 3️⃣ Páginas (rotas) e arquivos associados

| Rota (path) | Arquivo | Descrição da página |
|--------------|---------|---------------------|
| `/` | `pages/Index.tsx` | Tela inicial (landing) – apresenta o app e redireciona ao login ou dashboard. |
| `/auth` | `pages/Auth.tsx` | Tela de autenticação (login / registro). |
| `/member-area` | `pages/MemberArea.tsx` | Área do membro – mostra escalas, disponibilidade e foto. |
| `/dashboard` | `pages/Dashboard.tsx` | Dashboard geral com estatísticas de membros, equipes e escalas; inclui `AdminNotificationReadStatus`. |
| `/members` | `pages/Members.tsx` | Listagem e gerenciamento de membros (CRUD). Usa diálogos `AddMemberDialog`, `EditMemberDialog`, etc. |
| `/teams` | `pages/Teams.tsx` | Gerenciamento de equipes (CRUD). |
| `/schedules` | `pages/Schedules.tsx` | Gerenciamento de escalas (CRUD). |
| `/calendar` | `pages/CalendarView.tsx` | Visão de calendário com todas as escalas programadas. |
| `/availability-report` | `pages/AvailabilityReport.tsx` | Relatório de disponibilidade dos membros (ex.: quem está livre). |
| `/substitutions` | `pages/AdminSubstitutions.tsx` | Área administrativa para aprovar/rejeitar solicitações de substituição. |
| `*` (catch‑all) | `pages/NotFound.tsx` | Página 404 – rota não encontrada. |

Todas as rotas acima são **envolvidas** por `<ProtectedRoute>` (e, quando necessário, `requireAdmin`) dentro de `App.tsx`. O layout usado é `DashboardLayout`.

---

## 4️⃣ Hooks customizados

| Hook | Arquivo | Propósito |
|------|---------|-----------|
| `use-mobile` | `hooks/use-mobile.tsx` | Detecta se a viewport está em modo mobile (breakpoint). |
| `use-toast` | `hooks/use-toast.tsx` | Wrapper que expõe a função `toast` do shadcn UI, facilitando chamadas de notificação. |

---

## 5️⃣ Utilitários e integração externa

| Utilitário | Arquivo | Função |
|------------|---------|--------|
| `cn` (class‑names) | `lib/utils.ts` | Concatena classes usando `clsx` + `tailwind‑merge` (evita conflitos). |
| Supabase client | `integrations/supabase/client.ts` | Instância configurada do Supabase (auth, storage, RPC). |
| Supabase Functions | `supabase/functions/create-member-user/` | Função server‑less que cria usuário de login ao cadastrar membro. |
| Supabase Functions | `supabase/functions/cleanup-old-schedules/` | Limpa escalas antigas (cron). |
| Migrations SQL | `supabase/migrations/*.sql` | Estrutura do banco (tabelas `members`, `teams`, `schedules`, etc.). |

---

## 6️⃣ Arquivo de entrada da aplicação

- **`src/App.tsx`** – Define o `QueryClientProvider`, `TooltipProvider`, `Toaster` (Sonner), `BrowserRouter` e todas as rotas. Cada rota que requer autenticação usa `<ProtectedRoute>` que, por sua vez, renderiza `<DashboardLayout>` (sidebar + header).

---

## 7️⃣ Fluxo típico de uso

1. **Usuário abre a aplicação** → `index.html` carrega o bundle gerado por Vite. 
2. **React monta** `src/main.tsx` → renderiza `<App />`. 
3. **Rota `/auth`** → `Auth.tsx` realiza login via Supabase. 
4. **Após login**, o usuário é redirecionado para `/dashboard` (ou outra rota). 
5. **Dashboard** (`Dashboard.tsx`) consulta estatísticas usando `supabase.from(...).select(..., { count: "exact", head: true })`. 
6. **Ações de CRUD** (ex.: adicionar membro) são feitas através dos *dialogs* (`AddMemberDialog`, `EditMemberDialog`, etc.) que chamam a API Supabase e, opcionalmente, a Function `create-member-user`. 
7. **Notificações** são disparadas via `use-toast` e exibidas pelos componentes `Toast`/`Sonner`. 
8. **Admin** tem rotas protegidas por `requireAdmin` que exibem telas como `AdminSubstitutions`. 

---

## 8️⃣ Como localizar rapidamente um recurso

| Recurso | Onde encontrar |
|---------|-----------------|
| **Componente UI reutilizável** | `src/components/ui/` (ex.: `button.tsx`, `dialog.tsx`). |
| **Dialog de criação/edição** | `src/components/*Dialog.tsx`. |
| **Funções de API Supabase** | `src/integrations/supabase/client.ts` + chamadas `supabase.from(...)` espalhadas nos componentes e páginas. |
| **Hooks customizados** | `src/hooks/`. |
| **Funções server‑less** | `supabase/functions/`. |
| **Migrations do banco** | `supabase/migrations/`. |

---

## 9️⃣ Pontos de extensão futuros

- **Adicionar novos hooks** (ex.: `use-permissions` para controle granular). 
- **Criar componentes UI adicionais** em `components/ui/` seguindo o padrão `shadcn`. 
- **Expandir a camada de serviços** (`src/services/`) para abstrair chamadas Supabase e facilitar testes. 
- **Implementar PWA offline** usando o `service-worker.js` já presente. 

---

## 📚 Resumo rápido

- **`src/`** contém toda a lógica front‑end (React + TS). 
- **`components/`** = UI da aplicação (dialogs, layout, sidebars, etc.). 
- **`components/ui/`** = biblioteca de componentes genéricos (shadcn). 
- **`pages/`** = rotas do React‑Router, cada uma mapeada a um arquivo TSX. 
- **`hooks/`** = hooks reutilizáveis. 
- **`integrations/supabase/`** = cliente Supabase. 
- **`supabase/`** = backend server‑less (functions + migrations). 

Com esse mapa, você pode navegar rapidamente pelo código, entender a responsabilidade de cada arquivo e localizar onde cada funcionalidade está implementada. Boa codificação!
