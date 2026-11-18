# Central de Chamados - P2

Aplicação multiplataforma desenvolvida em Flutter para gerenciamento de chamados de suporte (Help Desk). O sistema permite que cada usuário crie uma conta, faça login e gerencie seus próprios tickets de atendimento de forma simples e organizada.

---

## Funcionalidades Principais

- **Autenticação de usuários:**
  - Cadastro de nova conta com nome, e-mail e senha.
  - Login com e-mail e senha e tratamento de erros básicos (campos vazios, e-mail inválido, senha menor que 6 caracteres e credenciais incorretas).
  - Logout e redirecionamento automático conforme o estado da sessão.
  - Proteção de rotas: a tela principal (`/home`) só pode ser acessada por usuários autenticados.
- **Gerenciamento de Chamados (CRUD completo):**
  - **Criar:** abertura de novo chamado com título, categoria, prioridade e descrição.
  - **Listar:** exibição dos chamados do usuário logado ordenados do mais recente para o mais antigo.
  - **Editar:** atualização de informações, prioridade e status do chamado.
  - **Excluir:** remoção de chamados pelo usuário.

---

## Tecnologias Utilizadas

- **Flutter** e **Dart** (interface, navegação e lógica da aplicação)
- **Supabase** (`supabase_flutter`) para autenticação e banco de dados PostgreSQL
- **Material 3** para os componentes visuais

---

## Estrutura do Projeto

```text
lib/
├── main.dart
├── models/
│   └── ticket_model.dart
├── screens/
│   ├── login_screen.dart
│   ├── register_screen.dart
│   └── home_screen.dart
├── services/
│   ├── auth_service.dart
│   └── database_service.dart
└── widgets/
    └── ticket_form_dialog.dart
```

---

## Autenticação e Base de Dados

### Autenticação
A autenticação é gerenciada pela classe `AuthService` (`lib/services/auth_service.dart`) usando o **Supabase Auth** com e-mail e senha (`signUp`, `signInWithPassword` e `signOut`).  
Na inicialização e na geração de rotas em `lib/main.dart` (além da verificação em `HomeScreen`), o app checa `AuthService.isAuthenticated` para impedir que usuários não logados acessem a tela `/home`.

### Base de Dados
Os chamados são armazenados na tabela `tickets` no **PostgreSQL do Supabase** e manipulados pela classe `DatabaseService` (`lib/services/database_service.dart`) com o modelo `TicketModel`.  
Cada registro possui `user_id` vinculado ao usuário autenticado (`auth.users`) e políticas de **Row Level Security (RLS)** habilitadas, garantindo que cada usuário visualize, crie, edite e exclua apenas os seus próprios chamados.

---

## Como Executar o Projeto

### 1. Pré-requisitos
- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado
- Uma conta e projeto criado no [Supabase](https://supabase.com/)

### 2. Configurar o Banco de Dados (Supabase)
No **SQL Editor** do seu projeto Supabase, execute o script abaixo para criar a tabela `tickets`, habilitar o RLS e liberar as permissões para usuários autenticados:

```sql
create table if not exists public.tickets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  description text not null,
  category text not null default 'Suporte Técnico',
  priority text not null default 'Média',
  status text not null default 'Aberto',
  created_at timestamptz not null default now()
);

alter table public.tickets enable row level security;

grant usage on schema public to authenticated;
grant select, insert, update, delete on table public.tickets to authenticated;

create policy "Usuários podem ver seus próprios tickets"
  on public.tickets for select
  using (auth.uid() = user_id);

create policy "Usuários podem criar seus próprios tickets"
  on public.tickets for insert
  with check (auth.uid() = user_id);

create policy "Usuários podem atualizar seus próprios tickets"
  on public.tickets for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Usuários podem excluir seus próprios tickets"
  on public.tickets for delete
  using (auth.uid() = user_id);
```

*(Dica para testes: em **Authentication → Sign In / Providers → Email**, você pode desativar **Confirm email** caso queira testar o login logo após o cadastro sem confirmar por e-mail.)*

### 3. Configurar as chaves do Supabase
No arquivo `lib/main.dart`, informe a `url` e a `anonKey` (ou publishable key) do seu projeto Supabase em `Supabase.initialize(...)`.

### 4. Instalar dependências e rodar
No terminal, dentro da pasta do projeto:

```bash
flutter pub get
flutter run
```

Para executar em modo servidor web (ex.: Ubuntu Server):

```bash
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```
