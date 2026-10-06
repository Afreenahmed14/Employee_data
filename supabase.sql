-- Run once in Supabase > SQL Editor. Replace the admin email first. Safe to re-run.
drop table if exists employees cascade;
drop table if exists admins cascade;
drop function if exists is_admin();

create table employees (
  id uuid primary key default gen_random_uuid(),
  name text not null, dob date not null, doj date not null,
  acc_number text not null check (acc_number ~ '^\d{9,18}$'),
  uan text not null check (uan ~ '^\d{12}$'),
  ifsc text not null check (ifsc ~ '^[A-Z]{4}0[A-Z0-9]{6}$'),
  phone text not null check (phone ~ '^\d{10}$'),
  email text not null check (email = lower(email)),
  emp_type text not null check (emp_type in ('Intern','Full-time')),
  work_mode text not null check (work_mode in ('Hybrid','WFO','WFH')),
  hybrid_days int check (hybrid_days between 1 and 5),
  aadhaar text check (aadhaar ~ '^\d{12}$'),
  designation text,
  package_amount numeric(12,2) check (package_amount >= 0),
  fixed_salary numeric(12,2) check (fixed_salary >= 0),
  resignation_date date,
  fixed_salary numeric(12,2) check (fixed_salary >= 0),
  employee_id text,
  laptop_model text,
  asset_issue text check (asset_issue in ('Yes','No')),
  asset_issue_desc text,
  photo_path text,
  created_at timestamptz default now()
);
create table admins (email text primary key);
insert into admins values ('admin@example.com');  -- <-- your admin login email

create function is_admin() returns boolean language sql security definer stable as
$$ select exists(select 1 from admins where email = auth.jwt()->>'email') $$;

alter table employees enable row level security;
alter table admins enable row level security;
-- Anyone can SUBMIT a record; only the admin can read or delete.
create policy "anyone can submit" on employees for insert to anon, authenticated with check (true);
create policy "admin read"        on employees for select using (is_admin());
create policy "admin delete"      on employees for delete using (is_admin());
alter publication supabase_realtime add table employees;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('photos', 'photos', false, 2097152, array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set file_size_limit = 2097152, allowed_mime_types = array['image/jpeg','image/png','image/webp'];
drop policy if exists "anyone can upload photo" on storage.objects;
drop policy if exists "admin photo read" on storage.objects;
drop policy if exists "admin photo delete" on storage.objects;
create policy "anyone can upload photo" on storage.objects for insert to anon, authenticated with check (bucket_id = 'photos');
create policy "admin photo read"   on storage.objects for select using (bucket_id = 'photos' and is_admin());
create policy "admin photo delete" on storage.objects for delete using (bucket_id = 'photos' and is_admin());
