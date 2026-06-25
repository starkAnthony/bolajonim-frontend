# Bolajonim — Full Work Checklist

Use this list **top to bottom**. Check off items as you finish them.

**Legend**
- ✅ Done
- 🔄 Partial (works but needs testing or polish)
- ⬜ To do

**Last updated:** 2026-06-23

---

## Phase 1 — Auth & onboarding (parent)

- ✅ 1.1 Start screen loads (logo, Kirish, Ro‘yxatdan o‘tish)
- ✅ 1.2 Parent signup with phone only
- ✅ 1.3 Parent signup with email only
- ✅ 1.4 Parent signup with phone + email
- ✅ 1.5 Duplicate ID / phone / email blocked
- ✅ 1.6 Login with phone
- ✅ 1.7 Login with email
- ✅ 1.8 Login with user ID (no @ in email field)
- ✅ 1.9 Enter key submits login from password field
- ✅ 1.10 Wrong password shows clear Uzbek error
- ✅ 1.11 Logout (Profile → Chiqish → confirm → start screen)
- 🔄 1.12 Forgot password (phone or email + new password; OTP later)

---

## Phase 2 — Child setup & first login path

- ✅ 2.1 New parent with no child → goes to Child Setup
- ✅ 2.2 Parent profile loads on child setup (name, phone, email)
- ✅ 2.3 Register child saves to database
- ✅ 2.4 Child appears on Profile screen
- ✅ 2.5 Parent with existing child → skips Child Setup → Home
- ✅ 2.6 Multiple children (add second child / switch child)
- ✅ 2.7 Run `bolajonim_schema.sql` on database (BLJ_* tables + sample data)

> DB script: `bolajonim-backend/taskhub-cmn-cmn/src/main/resources/sql/bolajonim_schema.sql`

---

## Phase 3 — Parent home (real API)

- ✅ 3.1 Home loads from `GET /api/v1/flut200/home`
- ✅ 3.2 Home shows error message if backend is down
- ✅ 3.3 Latest announcement card on home (from `/home` API; full E’lonlar list still mock → 4.1)
- ✅ 3.4 Upcoming event card on home (same `/home` API)
- ✅ 3.5 Today report preview on home (`BLJ_DAILY_REPORT_B` seed in schema SQL)
- ✅ 3.6 Bottom navigation (Home / Jadval / Hisobot / Profil)
- ✅ 3.7 Switch between children on home

---

## Phase 4 — Replace mock screens with real API

Do in this order:

- ✅ **4.1 E’lonlar (announcements list)** — `GET /flut200/announcements`

- ✅ **4.2 Kunlik hisobot (daily reports)** — `GET /flut200/reports`

- ✅ **4.3 Davomat (attendance)** — `GET /flut200/attendance`

- ✅ **4.4 Ovqat (meals)** — `GET /flut200/meals`

- 🔄 **4.5 Jadval (schedule)** — `GET /flut200/schedule` (static daily plan, no live tracking)

- 🔄 **4.6 Galereya (gallery)** — `GET /flut200/gallery` (read-only; teacher upload later)

- 🔄 **4.7 Olib ketish (pickup)** — `GET /flut200/pickup` (read-only; parent save/add person later)

---

## Phase 5 — Profile & settings

- ✅ 5.1 Profile loads parent + children from API
- ✅ 5.2 Edit parent info (`PUT /flut200/profile`, `EditParentScreen`)
- ✅ 5.3 Edit child info (`PUT /flut200/child`, `EditChildScreen`)
- ✅ 5.4 Save child photo to backend (`POST/DELETE /flut200/child/photo`)
- ✅ 5.5 Language / notifications / privacy settings (`AppSettingsScreen`, local prefs)
- ✅ 5.6 Logout clears tokens and returns to start

---

## Phase 6 — Teacher & director (later)

- ✅ 6.1 Teacher signup API + screen (`POST /flut100/teacher/signUp`, invite code + group)
- ✅ 6.2 Director signup API + screen (`POST /flut100/director/signUp`, creates kindergarten + invite code)
- ✅ 6.3 Teacher login and role routing (`TEACHER` / `DIRECTOR` → staff nav)
- ✅ 6.4 Teacher home / class / reports (`GET/POST /flut300/*`)
- ✅ 6.5 Teacher messages (`GET /flut300/messages`)
- ✅ 6.6 Director dashboard (`GET /flut300/director/dashboard`)

---

## Phase 7 — Backend cleanup

- ✅ 7.1 Backend pushed to GitHub (`bolajonim-backend`)
- ⬜ 7.2 Remove secrets from committed config files
- 🔄 7.3 Replace Korean error messages with Uzbek/English
- ⬜ 7.4 Test prod profile (env vars, CORS for Vercel)
- ⬜ 7.5 Add Dockerfile for backend
- 🔄 7.6 Seed data for announcements and sample reports

---

## Phase 8 — Deploy to internet

- ⬜ 8.1 Push Flutter app to GitHub
- ⬜ 8.2 Deploy Flutter web to Vercel
- ⬜ 8.3 Deploy backend to Railway / Render / Fly.io
- ⬜ 8.4 Cloud MySQL database
- ⬜ 8.5 Point Vercel app to public backend URL
- ⬜ 8.6 CI: auto-build on git push

---

## Phase 9 — UX polish

- ✅ 9.1 Phone placeholder (format hint, not fake number)
- ✅ 9.2 Phone dashes while typing
- ✅ 9.3 Smooth Telefon / Email switcher on login
- ✅ 9.4 Same input height for phone and email on login
- ⬜ 9.5 Enter key on signup screen
- 🔄 9.6 Loading spinners on all API screens
- 🔄 9.7 Uzbek error messages everywhere

---

---

## Phase R — Structured Hisobot (reports roadmap)

### R1 — Structured reports (done)
- ✅ `REPORT_TYPE` + `BLJ_REPORT_SECTION_B` (daily + health table)
- ✅ Teacher create dialog (kunlik / sog'liq)
- ✅ Parent list + detail with sections
- ✅ Home “Bugungi hisobot” card (type badge + metrics)

### R2 — Photos + list cards (in progress)
- ⬜ Run `bolajonim_upgrade_report_photos.sql`
- 🔄 `BLJ_REPORT_PHOTO_B` + upload API (`POST /flut300/reports/photos`)
- 🔄 Teacher: attach photos when creating report
- 🔄 Parent list: cover thumbnail, type badge (no fake weather/comments)
- 🔄 Parent detail: photo grid

### R3 — Parent reply + comments
- ⬜ `BLJ_REPORT_COMMENT_B` (parent ↔ teacher thread per report)
- ⬜ Parent “Uydan bog'chaga” write flow (replace mock `ReportWriteScreen`)
- ⬜ Comment count on list cards (real data)
- ⬜ Teacher sees parent replies in messages or report detail

### R4 — Push notifications
- ⬜ `firebase_messaging` in Flutter + device token registration
- ⬜ Backend: notify parents on new report (`Flut300ServiceImpl.createReport`)
- ⬜ Respect app notification settings (sync to backend)

### R5 — Rich daily journal template (Kidsnote-style)
- ⬜ Daily template sections: ovqat, uyqu, kayfiyat, faoliyat
- ⬜ Weather picker on teacher form (real `WEATHER_CD`, not hardcoded `sunny`)
- ⬜ Optional: growth percentiles / BMI (advanced health)

---

## What to do next (recommended order)

Copy this short list when you start a session:

1. ⬜ Run `bolajonim_upgrade_report_photos.sql` (R2)
2. ⬜ Restart backend + hot restart Flutter
3. ⬜ Test: teacher creates report with photos → parent sees thumbnail + grid
4. ⬜ Phase R3: parent reply + comments
5. ⬜ Deploy when local demo works (Phase 8)

---

## Quick test script (manual)

Run through this with a fresh test user:

| Step | What to do | Done? |
|------|------------|-------|
| A | Sign up new parent | ⬜ |
| B | Login → should open Child Setup if no child | ⬜ |
| C | Register child → should land on Home | ⬜ |
| D | Open Profile → child shows real data | ⬜ |
| E | Open E’lonlar → real list (after task 4.1) | ⬜ |
| F | Logout → login again → skip Child Setup | ⬜ |

---

## Local run commands

**Backend** (folder: `bolajonim-backend`)

```powershell
.\gradlew :taskhub-cmn-api:bootRun
```

Runs on `http://localhost:8081`

**Flutter** (folder: `bolajonim_app`)

```powershell
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8081
```

---

## My notes

```
Test users:


Blockers:


This session I finished:


Next session goal:

```
