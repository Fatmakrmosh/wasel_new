-- WASEL: shared platform settings for manager-controlled announcements.
-- Apply this migration in the Supabase SQL editor before using the announcement manager UI.

create table if not exists public.app_settings (
  key text primary key,
  value_text text not null default '',
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users(id)
);

alter table public.app_settings enable row level security;

create policy "authenticated users can read app settings"
on public.app_settings
for select
to authenticated
using (true);

create or replace function public.admin_update_app_setting(
  setting_key text,
  setting_value text
)
returns public.app_settings
language plpgsql
security definer
set search_path = public
as $$
declare
  caller_role text;
  result_row public.app_settings;
begin
  select lower(coalesce(role, '')) into caller_role
  from public.profiles
  where id = auth.uid();

  if caller_role <> 'admin' then
    raise exception 'Only an admin can update app settings';
  end if;

  insert into public.app_settings(key, value_text, updated_at, updated_by)
  values (setting_key, setting_value, now(), auth.uid())
  on conflict (key) do update
    set value_text = excluded.value_text,
        updated_at = excluded.updated_at,
        updated_by = excluded.updated_by
  returning * into result_row;

  return result_row;
end;
$$;

revoke all on function public.admin_update_app_setting(text, text) from public;
grant execute on function public.admin_update_app_setting(text, text) to authenticated;

grant select on public.app_settings to authenticated;

insert into public.app_settings(key, value_text)
values
  ('announcement_title_ar', 'واصل معك دائماً'),
  ('announcement_body_ar', 'كل خدماتك في تطبيق واحد')
on conflict (key) do nothing;
