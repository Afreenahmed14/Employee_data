-- Run once in Supabase > SQL Editor if you already created the tables (keeps your existing data).
alter table employees
  add column if not exists aadhaar text check (aadhaar ~ '^\d{12}$'),
  add column if not exists designation text,
  add column if not exists package_amount numeric(12,2) check (package_amount >= 0);
