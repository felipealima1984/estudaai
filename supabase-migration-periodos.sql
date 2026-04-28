-- ============================================================
-- Estuda.AI — Migration: Períodos de Graduação (Direito)
-- Execute no SQL Editor do Supabase APÓS o schema inicial
-- ============================================================

-- TABELA DE PERÍODOS
create table if not exists periodos (
  id            text primary key,
  user_id       uuid not null references auth.users(id) on delete cascade,
  numero        int  not null check (numero between 1 and 10),
  descricao     text,                          -- ex: "4º Período — 2025.1"
  ativo         boolean not null default false, -- apenas um pode ser ativo por vez
  criado_em     timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

-- VINCULAR PERÍODO À MATÉRIA (coluna nova na tabela materias)
alter table materias
  add column if not exists periodo_id text references periodos(id) on delete set null;

-- RLS
alter table periodos enable row level security;
create policy "periodos_own" on periodos for all using (auth.uid() = user_id);

-- Índices
create index if not exists idx_periodos_user   on periodos(user_id);
create index if not exists idx_materias_periodo on materias(periodo_id);

-- Trigger atualizado_em
create trigger trg_periodos_atualizado
  before update on periodos
  for each row execute function set_atualizado_em();

-- GARANTIR APENAS UM PERÍODO ATIVO POR USUÁRIO
-- (função chamada ao ativar um período)
create or replace function ativar_periodo(p_id text, p_user uuid)
returns void language plpgsql as $$
begin
  update periodos set ativo = false where user_id = p_user;
  update periodos set ativo = true  where id = p_id and user_id = p_user;
end;
$$;

-- Salvar período ativo também em preferencias
alter table preferencias
  add column if not exists periodo_ativo_id text references periodos(id) on delete set null;
