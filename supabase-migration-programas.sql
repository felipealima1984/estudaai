-- ============================================================
-- Estuda.AI — Migration: Programas de Estudo
-- Substitui o conceito de frente fixa (cacd/dir) por programas
-- dinâmicos definidos pelo usuário.
--
-- Execute no SQL Editor do Supabase APÓS as migrations anteriores.
-- ============================================================

-- ============================================================
-- 1. TABELA DE PROGRAMAS DE ESTUDO
-- ============================================================
create table if not exists programas (
  id            text primary key,
  user_id       uuid not null references auth.users(id) on delete cascade,
  nome          text not null,
  tipo          text not null check (tipo in ('concurso','graduacao','posgraduacao','livre')),
  instituicao   text,
  ano           text,
  ativo         boolean not null default false,
  criado_em     timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

alter table programas enable row level security;
create policy "programas_own" on programas for all using (auth.uid() = user_id);

create index if not exists idx_programas_user on programas(user_id);

create trigger trg_programas_atualizado
  before update on programas
  for each row execute function set_atualizado_em();

-- ============================================================
-- 2. ADICIONAR programa_id EM materias
--    Mantém frente por compatibilidade, sem o check restritivo.
-- ============================================================

-- Remover o check antigo que limitava a ('cacd','dir')
alter table materias drop constraint if exists materias_frente_check;

-- Adicionar coluna programa_id
alter table materias
  add column if not exists programa_id text references programas(id) on delete set null;

-- Índice
create index if not exists idx_materias_programa on materias(programa_id);

-- ============================================================
-- 3. ADICIONAR programa_ativo_id EM preferencias
--    Substitui periodo_ativo_id como referência de contexto ativo.
-- ============================================================
alter table preferencias
  add column if not exists programa_ativo_id text references programas(id) on delete set null;

-- ============================================================
-- 4. ATUALIZAR materiais_salvos
--    Adicionar programa_id para substituir frente fixa.
-- ============================================================
alter table materiais_salvos
  add column if not exists programa_id text references programas(id) on delete set null;

-- ============================================================
-- 5. ATUALIZAR historico
--    programa_id para rastrear qual programa gerou a atividade.
-- ============================================================
alter table historico
  add column if not exists programa_id text references programas(id) on delete set null;

-- ============================================================
-- 6. INSERIR PROGRAMAS PADRÃO PARA USUÁRIOS EXISTENTES
--    Converte frente 'cacd' → programa concurso CACD 2027
--    e 'dir' → programa graduação Direito para cada usuário.
--
--    Só executa se a tabela materias tiver registros existentes.
-- ============================================================
do $$
declare
  u record;
  prog_cacd_id text;
  prog_dir_id  text;
begin
  for u in select distinct user_id from materias loop
    -- Criar programa CACD se usuário tiver matérias 'cacd'
    if exists (select 1 from materias where user_id = u.user_id and frente = 'cacd') then
      prog_cacd_id := 'prog-cacd-' || replace(u.user_id::text, '-', '');
      insert into programas (id, user_id, nome, tipo, instituicao, ano, ativo)
      values (prog_cacd_id, u.user_id, 'CACD 2027', 'concurso', 'CESPE/UnB', '2027', true)
      on conflict (id) do nothing;

      update materias
      set programa_id = prog_cacd_id
      where user_id = u.user_id and frente = 'cacd' and programa_id is null;
    end if;

    -- Criar programa Direito se usuário tiver matérias 'dir'
    if exists (select 1 from materias where user_id = u.user_id and frente = 'dir') then
      prog_dir_id := 'prog-dir-' || replace(u.user_id::text, '-', '');
      insert into programas (id, user_id, nome, tipo, instituicao, ano, ativo)
      values (prog_dir_id, u.user_id, 'Direito — Nova Roma', 'graduacao', 'Faculdade Nova Roma', '4º Período', false)
      on conflict (id) do nothing;

      update materias
      set programa_id = prog_dir_id
      where user_id = u.user_id and frente = 'dir' and programa_id is null;
    end if;
  end loop;
end;
$$;

-- ============================================================
-- RESUMO DAS MUDANÇAS
-- ============================================================
-- programas        → nova tabela: cada usuário define seus programas
-- materias.frente  → mantido (sem check restritivo) + novo campo programa_id
-- preferencias     → novo campo programa_ativo_id
-- materiais_salvos → novo campo programa_id
-- historico        → novo campo programa_id
-- periodos         → sem mudança (continua vinculado a matérias de graduação)
