-- ============================================================
--  Diagnostic Center — Supabase setup
--  Supabase Dashboard > SQL Editor me ye poora paste karke "Run" karo.
-- ============================================================

-- 1) Bill number ke liye sequence (INV-0001, INV-0002 ...)
create sequence if not exists bill_seq start 1;

-- 2) Patients table
create table if not exists patients (
  id            uuid primary key default gen_random_uuid(),
  bill_no       text not null default ('INV-' || lpad(nextval('bill_seq')::text, 4, '0')),
  date          date not null default current_date,
  customer_name text not null,
  age           int,
  sex           text,
  mobile        text,
  test_name     text,
  referred_by   text default '',
  address       text default '',
  total         numeric not null default 0,
  paid          numeric not null default 0,
  dues          numeric not null default 0,
  mode          text default 'Cash',
  payments      jsonb default '[]'::jsonb,
  status        text default 'Pending',
  report_status text not null default 'Report Pending', -- Report Pending | Report Generated | Report Send
  admin_payment_status text not null default 'Payment Pending', -- Payment Pending | Payment Received (admin only)
  created_by    text,
  created_at    timestamptz not null default now()
);

-- Live DB me column pehle se na ho to safely add (existing rows = Report Pending)
alter table patients
  add column if not exists report_status text not null default 'Report Pending';

alter table patients
  add column if not exists admin_payment_status text not null default 'Payment Pending';

create index if not exists patients_created_at_idx on patients (created_at desc);
create index if not exists patients_mobile_idx on patients (mobile);

-- 3) App users table (login + admin manage kar sake)
create table if not exists app_users (
  username text primary key,
  password text not null,
  role     text not null default 'user',
  name     text
);

-- 4) Default logins seed karo (admin + 5 staff)
insert into app_users (username, password, role, name) values
  ('admin', 'admin@123', 'admin', 'Administrator'),
  ('user1', 'user@123',  'user',  'Staff 1'),
  ('user2', 'user@123',  'user',  'Staff 2'),
  ('user3', 'user@123',  'user',  'Staff 3'),
  ('user4', 'user@123',  'user',  'Staff 4'),
  ('user5', 'user@123',  'user',  'Staff 5')
on conflict (username) do nothing;

-- 4b) Activity log table (kis user ne kya kiya — entry/edit/delete/due-clear)
create table if not exists activity (
  id           uuid primary key default gen_random_uuid(),
  created_at   timestamptz not null default now(),
  username     text,
  user_name    text,
  action       text,          -- entry | edit | delete | due_clear
  bill_no      text,
  patient_name text,
  detail       text,
  amount       numeric
);
create index if not exists activity_created_at_idx on activity (created_at desc);

-- 5) Row Level Security ON karo, aur anon key ko allow karo
--    (internal tool — link private rakhna. Baad me proper auth laga sakte ho.)
alter table patients  enable row level security;
alter table app_users enable row level security;

drop policy if exists "patients_all" on patients;
create policy "patients_all" on patients
  for all to anon, authenticated using (true) with check (true);

drop policy if exists "app_users_all" on app_users;
create policy "app_users_all" on app_users
  for all to anon, authenticated using (true) with check (true);

alter table activity enable row level security;
drop policy if exists "activity_all" on activity;
create policy "activity_all" on activity
  for all to anon, authenticated using (true) with check (true);

-- 6) Real-time updates ON karo (har staff ke phone pe live sync ke liye)
--    REPLICA IDENTITY FULL = update ke waqt purani values bhi milti hain
--    (due-clear detect karne ke liye zaroori).
alter table patients replica identity full;

do $$
begin
  if not exists (select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'patients') then
    alter publication supabase_realtime add table patients;
  end if;
  if not exists (select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'app_users') then
    alter publication supabase_realtime add table app_users;
  end if;
  if not exists (select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'activity') then
    alter publication supabase_realtime add table activity;
  end if;
end $$;

-- Done ✅
