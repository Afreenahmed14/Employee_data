-- Run once in Supabase > SQL Editor so the admin dashboard can EDIT employees.
-- (Create already works; delete/read policies already exist.)
drop policy if exists "admin update" on employees;
create policy "admin update" on employees for update using (is_admin()) with check (is_admin());
