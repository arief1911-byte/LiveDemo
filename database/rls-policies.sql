create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select coalesce((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin', false);
$$;

alter table public.employees enable row level security;
alter table public.reports enable row level security;
alter table public.activities enable row level security;
alter table public.attendance enable row level security;

drop policy if exists employees_select on public.employees;
create policy employees_select on public.employees for select to authenticated
using (user_id = auth.uid() or public.is_admin());

drop policy if exists employees_update on public.employees;
create policy employees_update on public.employees for update to authenticated
using (user_id = auth.uid() or public.is_admin())
with check (user_id = auth.uid() or public.is_admin());

drop policy if exists reports_select on public.reports;
create policy reports_select on public.reports for select to authenticated
using (public.is_admin() or exists (
  select 1 from public.employees e
  where e.id = reports.employee_id and e.user_id = auth.uid()
));

drop policy if exists reports_insert on public.reports;
create policy reports_insert on public.reports for insert to authenticated
with check (public.is_admin() or exists (
  select 1 from public.employees e
  where e.id = reports.employee_id and e.user_id = auth.uid()
));

drop policy if exists reports_update on public.reports;
create policy reports_update on public.reports for update to authenticated
using (public.is_admin() or exists (
  select 1 from public.employees e
  where e.id = reports.employee_id and e.user_id = auth.uid()
))
with check (public.is_admin() or exists (
  select 1 from public.employees e
  where e.id = reports.employee_id and e.user_id = auth.uid()
));

drop policy if exists reports_delete on public.reports;
create policy reports_delete on public.reports for delete to authenticated using (public.is_admin());

drop policy if exists activities_select on public.activities;
create policy activities_select on public.activities for select to authenticated
using (public.is_admin() or exists (
  select 1 from public.reports r join public.employees e on e.id=r.employee_id
  where r.id=activities.report_id and e.user_id=auth.uid()
));

drop policy if exists activities_insert on public.activities;
create policy activities_insert on public.activities for insert to authenticated
with check (public.is_admin() or exists (
  select 1 from public.reports r join public.employees e on e.id=r.employee_id
  where r.id=activities.report_id and e.user_id=auth.uid()
));

drop policy if exists activities_update on public.activities;
create policy activities_update on public.activities for update to authenticated
using (public.is_admin() or exists (
  select 1 from public.reports r join public.employees e on e.id=r.employee_id
  where r.id=activities.report_id and e.user_id=auth.uid()
))
with check (public.is_admin() or exists (
  select 1 from public.reports r join public.employees e on e.id=r.employee_id
  where r.id=activities.report_id and e.user_id=auth.uid()
));

drop policy if exists activities_delete on public.activities;
create policy activities_delete on public.activities for delete to authenticated
using (public.is_admin() or exists (
  select 1 from public.reports r join public.employees e on e.id=r.employee_id
  where r.id=activities.report_id and e.user_id=auth.uid()
));

drop policy if exists attendance_select on public.attendance;
create policy attendance_select on public.attendance for select to authenticated
using (public.is_admin() or exists (
  select 1 from public.reports r join public.employees e on e.id=r.employee_id
  where r.id=attendance.report_id and e.user_id=auth.uid()
));

drop policy if exists attendance_insert on public.attendance;
create policy attendance_insert on public.attendance for insert to authenticated
with check (public.is_admin() or exists (
  select 1 from public.reports r join public.employees e on e.id=r.employee_id
  where r.id=attendance.report_id and e.user_id=auth.uid()
));

drop policy if exists attendance_update on public.attendance;
create policy attendance_update on public.attendance for update to authenticated
using (public.is_admin() or exists (
  select 1 from public.reports r join public.employees e on e.id=r.employee_id
  where r.id=attendance.report_id and e.user_id=auth.uid()
))
with check (public.is_admin() or exists (
  select 1 from public.reports r join public.employees e on e.id=r.employee_id
  where r.id=attendance.report_id and e.user_id=auth.uid()
));

drop policy if exists attendance_delete on public.attendance;
create policy attendance_delete on public.attendance for delete to authenticated
using (public.is_admin() or exists (
  select 1 from public.reports r join public.employees e on e.id=r.employee_id
  where r.id=attendance.report_id and e.user_id=auth.uid()
));

-- First admin:
-- Create a user in Supabase Authentication, then run:
-- update auth.users
-- set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || '{"role":"admin"}'::jsonb
-- where id = 'YOUR-AUTH-USER-UUID';
