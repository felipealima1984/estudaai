-- ============================================================
-- Estuda.AI — Schema Supabase
-- Execute no SQL Editor do seu projeto Supabase
-- ============================================================

-- Habilitar extensão UUID (já vem ativa no Supabase, mas por segurança)
create extension if not exists "pgcrypto";

-- ============================================================
-- MATÉRIAS
-- ============================================================
create table if not exists materias (
  id           text primary key,
  user_id      uuid not null references auth.users(id) on delete cascade,
  nome         text not null,
  frente       text not null check (frente in ('cacd','dir')),
  topicos_n1   text[] not null default '{}',
  topicos_n2   text[] not null default '{}',
  topicos_n3   text[] not null default '{}',
  criado_em    timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

-- ============================================================
-- HISTORINHAS SALVAS
-- ============================================================
create table if not exists historinhas (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references auth.users(id) on delete cascade,
  materia_id   text references materias(id) on delete set null,
  unidade      text,
  texto        text not null,
  criado_em    timestamptz not null default now()
);

-- ============================================================
-- MATERIAIS DE ESTUDO (PDF/texto gerados)
-- ============================================================
create table if not exists materiais_salvos (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references auth.users(id) on delete cascade,
  materia_id   text references materias(id) on delete set null,
  mat_nome     text,
  frente       text,
  unidade      text,
  tipo         text not null check (tipo in ('historinha','flashcards','questoes')),
  conteudo_raw text not null,
  criado_em    timestamptz not null default now()
);

-- ============================================================
-- STATS (um registro por usuário)
-- ============================================================
create table if not exists stats (
  user_id      uuid primary key references auth.users(id) on delete cascade,
  historinhas  int not null default 0,
  questoes     int not null default 0,
  acertos      int not null default 0,
  tentativas   int not null default 0,
  redacoes     int not null default 0,
  atualizado_em timestamptz not null default now()
);

-- ============================================================
-- HISTÓRICO DE ATIVIDADES
-- ============================================================
create table if not exists historico (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references auth.users(id) on delete cascade,
  tipo         text not null,
  frente       text,
  detalhe      text,
  criado_em    timestamptz not null default now()
);

-- ============================================================
-- PREFERÊNCIAS DO USUÁRIO (theme, api_key cifrada)
-- ============================================================
create table if not exists preferencias (
  user_id      uuid primary key references auth.users(id) on delete cascade,
  theme        text not null default 'dark',
  anthropic_key text,
  atualizado_em timestamptz not null default now()
);

-- ============================================================
-- ROW LEVEL SECURITY — cada usuário só vê seus próprios dados
-- ============================================================
alter table materias          enable row level security;
alter table historinhas       enable row level security;
alter table materiais_salvos  enable row level security;
alter table stats             enable row level security;
alter table historico         enable row level security;
alter table preferencias      enable row level security;

-- Policies: usuário só acessa seus registros
create policy "materias_own"         on materias          for all using (auth.uid() = user_id);
create policy "historinhas_own"      on historinhas       for all using (auth.uid() = user_id);
create policy "materiais_own"        on materiais_salvos  for all using (auth.uid() = user_id);
create policy "stats_own"            on stats             for all using (auth.uid() = user_id);
create policy "historico_own"        on historico         for all using (auth.uid() = user_id);
create policy "preferencias_own"     on preferencias      for all using (auth.uid() = user_id);

-- ============================================================
-- TRIGGER: atualizar atualizado_em automaticamente
-- ============================================================
create or replace function set_atualizado_em()
returns trigger language plpgsql as $$
begin
  new.atualizado_em = now();
  return new;
end;
$$;

create trigger trg_materias_atualizado
  before update on materias
  for each row execute function set_atualizado_em();

create trigger trg_preferencias_atualizado
  before update on preferencias
  for each row execute function set_atualizado_em();

create trigger trg_stats_atualizado
  before update on stats
  for each row execute function set_atualizado_em();

-- ============================================================
-- ÍNDICES
-- ============================================================
create index if not exists idx_materias_user      on materias(user_id);
create index if not exists idx_historinhas_user   on historinhas(user_id);
create index if not exists idx_materiais_user     on materiais_salvos(user_id);
create index if not exists idx_historico_user     on historico(user_id, criado_em desc);
