-- ============================================================
--  ADD Report Status field (SAFE for live data)
--  Supabase > SQL Editor me ye Run karo.
--  Existing rows auto "Report Pending" ho jayengi — data delete nahi hoga.
-- ============================================================

alter table patients
  add column if not exists report_status text not null default 'Report Pending';

-- Agar pehle se null rows hon to unko bhi pending set kar do
update patients
set report_status = 'Report Pending'
where report_status is null or report_status = '';

-- Done ✅
-- Options: 'Report Pending' | 'Report Generated' | 'Report Send'
