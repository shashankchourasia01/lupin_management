# Diagnostic Center — Deploy Guide (asli link ke liye)

Ye 2 files use hongi:
- `supabase-setup.sql` — database banane ke liye
- `index.html` — poora app (ek hi file)

Total time: ~10 minute. Sab free tier me ho jayega.

---

## STEP 1 — Supabase project banao (database)

1. https://supabase.com par jao → **Sign in** (GitHub se ho jayega) → **New project**.
2. Project name (kuch bhi), ek strong **database password** set karo, region **Mumbai/Singapore** choose karo → **Create**.
3. Project ban jaaye (1-2 min), phir left menu me **SQL Editor** kholo.
4. `supabase-setup.sql` ka **poora content** copy karke waha paste karo → **Run** dabao.
   - "Success" aana chahiye. Isse `patients` + `app_users` tables ban jaayengi aur 6 default logins seed ho jaayenge.

## STEP 2 — API keys nikaalo

1. Left menu → **Project Settings** (gear icon) → **API**.
2. Do cheezein copy karni hain:
   - **Project URL** (jaise `https://abcd1234.supabase.co`)
   - **anon public** key (lambi key, "anon"/"public" wali — service_role NAHI)

## STEP 3 — index.html me keys daalo

`index.html` ko kisi text editor me kholo, upar ye 2 lines dhundo:

```js
window.SUPABASE_URL = "YOUR_SUPABASE_URL";
window.SUPABASE_ANON_KEY = "YOUR_SUPABASE_ANON_KEY";
```

Inko apni values se replace karo, jaise:

```js
window.SUPABASE_URL = "https://abcd1234.supabase.co";
window.SUPABASE_ANON_KEY = "eyJhbGciOi...long-key...";
```

Save karo.

## STEP 4 — Online deploy karke LINK lo (koi ek chuno)

### Option A — Netlify Drop (sabse aasaan, drag & drop)
1. `index.html` aur `sw.js` dono ko **ek folder** me rakho (jaise "diagnostic").
2. https://app.netlify.com/drop kholo.
3. Us **poore folder** ko us page par **drag & drop** kar do (sirf index.html nahi — dono files chahiye, notifications ke liye).
4. Bas — turant ek live link mil jayega (jaise `https://random-name.netlify.app`).
5. Chaaho to Netlify me site ka naam badal lo.

### Option B — Vercel (GitHub se, updates aasaan)
1. `index.html` + `sw.js` ko ek GitHub repo me daalo.
2. https://vercel.com → **Add New Project** → repo import → **Deploy**.
3. Live link mil jayega.

## STEP 5 — Staff ko link do

- Wahi ek link sabhi 5 staff + admin apne phone me kholenge.
- Home screen par "Add to Home screen" kar lo — app jaisa lagega.
- Sabka data ek hi database me jaata hai, sabko same records dikhte hain. ✅

---

## Default logins
- Admin: `admin` / `admin@123`  (full rights: edit, delete, dashboard, activity log, manage users)
- Staff: `user1` … `user5` / `user@123`  (entry + due clear)

**Pehli baar login karte hi passwords change kar lena** (Admin → Users tab → "Password").

---

## Zaroori security note (seedhi baat)
- Login is app me client-side hai aur `anon` key browser me hoti hai. Iska matlab: ye ek **internal tool** hai — link ko **private** rakhna (public jagah share mat karna).
- Chhote center ke internal use ke liye ye theek hai. Agar aur strong security chahiye (proper Supabase Auth + row-level rules, ya passwords ko hash karna), to bata dena — main us version me upgrade kar dunga.
- Real patient data hai, to Supabase ka **auto-backup** on rakhna aur database password kisi ke saath share mat karna.

## Chhoti baatein
- Bill number Supabase khud auto-badhata hai (INV-0001, INV-0002...).
- **Real-time ON hai** — kisi bhi staff ki nayi entry ya due-clear sabke phone pe apne aap dikh jaata hai, refresh ki zaroorat nahi. (SQL me realtime enable ho jaata hai; agar tumne pehle wala SQL run kar liya tha, to `supabase-setup.sql` dobara Run kar do — safe hai, sab idempotent hai.)
- Header me chhota dot: **hara = live sync on**, **peela = connect ho raha hai**.
- Records tab me **↻ Refresh** button bhi hai (manual reload ke liye), par normally zaroorat nahi padegi.

## Notifications (nayi entry + due-clear)
- **In-app alert:** app khuli ho to upar ek toast dikh jayega ("New patient entry" / "Due cleared") — ye har device pe apne aap chalta hai.
- **Phone notification:** pehli baar login pe upar 🔔 "Enable" button aayega — tap karke "Allow" karo. Uske baad app khuli/background me ho tab bhi phone pe alert aayega.
  - **Android (Chrome):** achha chalta hai. Iske liye `sw.js` file zaroori hai (isliye dono files deploy karo).
  - **iPhone (Safari):** notification tabhi milega jab site ko **"Add to Home Screen"** karke install kiya ho (iOS 16.4+). Warna sirf in-app toast chalega.
- Apni khud ki entry/due-clear pe khud ko notification nahi aata (sirf doosron ki activity pe) — spam se bachne ke liye.
- **App poori band ho (background me bhi nahi)** tab bhi notification chahiye — wo agla upgrade hai (push server). Bata dena to laga dunga.

## Activity Log (admin only)
- Admin ke bottom menu me naya **🕑 Activity** tab hai.
- Isme har action ek jagah dikhega: **entry, edit, delete, due-clear** — kis din, kis time, kis user ne kiya, patient/bill, aur detail.
- Filter: action-wise (Entries / Dues / Edits / Deletes) + user-wise. Live update hota hai. **Export** button se CSV bhi milega.
- Ye tab dobara SQL run karne ke baad hi chalega (naya `activity` table isi se banta hai) — isliye `supabase-setup.sql` ek baar phir Run kar dena.
