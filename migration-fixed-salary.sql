-- Run once in Supabase > SQL Editor (keeps existing data).
alter table employees add column if not exists fixed_salary numeric(12,2) check (fixed_salary >= 0);
