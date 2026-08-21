-- ══════════════════════════════════════════════════════════════
-- MOBILE HOME VENTAS · Preparación de la base de datos Supabase
--
-- Cómo usarlo (una sola vez):
--   1. Entra a tu proyecto en https://supabase.com
--   2. Menú lateral → "SQL Editor" → "New query"
--   3. Pega TODO este archivo y presiona "Run"
--
-- Qué crea:
--   • Tabla site_data: guarda el inventario y los ajustes
--     (cualquiera puede LEER, solo usuarios con sesión pueden ESCRIBIR)
--   • Bucket de Storage "fotos": guarda las fotos de las casas
-- ══════════════════════════════════════════════════════════════

-- Tabla única con todo el contenido del sitio (mismo formato que data.js)
create table if not exists public.site_data (
  id bigint primary key,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.site_data enable row level security;

drop policy if exists "lectura publica" on public.site_data;
create policy "lectura publica"
  on public.site_data for select
  using (true);

drop policy if exists "escritura autenticada" on public.site_data;
create policy "escritura autenticada"
  on public.site_data for all
  to authenticated
  using (true)
  with check (true);

-- Fila inicial vacía (el panel la llena al publicar)
insert into public.site_data (id, data)
values (1, '{}'::jsonb)
on conflict (id) do nothing;

-- Bucket público para las fotos de las casas
insert into storage.buckets (id, name, public)
values ('fotos', 'fotos', true)
on conflict (id) do nothing;

drop policy if exists "fotos lectura publica" on storage.objects;
create policy "fotos lectura publica"
  on storage.objects for select
  using (bucket_id = 'fotos');

drop policy if exists "fotos subir autenticado" on storage.objects;
create policy "fotos subir autenticado"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'fotos');

drop policy if exists "fotos reemplazar autenticado" on storage.objects;
create policy "fotos reemplazar autenticado"
  on storage.objects for update
  to authenticated
  using (bucket_id = 'fotos');

drop policy if exists "fotos borrar autenticado" on storage.objects;
create policy "fotos borrar autenticado"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'fotos');

-- ══════════════════════════════════════════════════════════════
-- Si la parte de "storage" da un error de permisos en tu proyecto,
-- créalo desde la interfaz: Storage → New bucket → nombre "fotos",
-- marcar "Public bucket". Las políticas se agregan en Storage →
-- Policies (lectura para todos, escritura para "authenticated").
-- ══════════════════════════════════════════════════════════════

-- ÚLTIMO PASO (fuera de SQL): crea tu usuario del panel.
-- Authentication → Users → "Add user" → escribe tu correo y una
-- contraseña, marcando "Auto Confirm User". Con ese correo y esa
-- contraseña entrarás a admin.html.
