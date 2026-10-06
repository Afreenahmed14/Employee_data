-- Run once in Supabase > SQL Editor (keeps existing data).
alter table employees
  add column if not exists employee_id text,
  add column if not exists laptop_model text,
  add column if not exists asset_issue text check (asset_issue in ('Yes','No')),
  add column if not exists asset_issue_desc text;
