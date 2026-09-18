-- ============================================================
--  ADD Admin Payment Status (SAFE for live data)
--  Staff ne patient se paisa liya → admin ne staff se liya ya nahi
--  Existing rows = "Payment Pending" — koi data delete nahi hoga
--  Supabase > SQL Editor me Run karo, PHIR Vercel pe deploy.
-- ============================================================

alter table patients
  add column if not exists admin_payment_status text not null default 'Payment Pending';

update patients
set admin_payment_status = 'Payment Pending'
where admin_payment_status is null or admin_payment_status = '';

-- Done ✅
-- Options: 'Payment Pending' | 'Payment Received'
-- Sirf admin UI me dikhega / change hoga
