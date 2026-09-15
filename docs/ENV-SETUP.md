# DOVA — Environment Variables (Server Setup)

Guide for filling in `.env` when deploying or moving to a new server.

**Raw templates:** `tests/vps-backend.env.example`, `tests/vps-frontend.env.example`

---

## File locations

| Service | Path on server |
|---------|----------------|
| Backend | `apps/backend/.env` |
| Frontend | `apps/frontend/.env.local` |
| Root (optional) | `.env` — migrate/seed scripts also read this file |

Script `scripts/load-env.js` reads **root `.env`** then **`apps/backend/.env`** (the latter overrides).

---

## Backend — `apps/backend/.env`

### Required

```env
NODE_ENV=production
PORT=4201

USE_IN_MEMORY=false
JWT_SECRET=REPLACE_with_openssl_rand_hex_32
ADMIN_PASSWORD=admin1234
SUPPLIER_PASSWORD=supplier1234

DATABASE_URL=postgresql://dova:REPLACE_DB_PASSWORD@127.0.0.1:5432/dova
# Supabase (pooler) — append ?sslmode=require at end of URL
# DATABASE_URL=postgresql://postgres.PROJECT_REF:REPLACE_PASSWORD@aws-0-REGION.pooler.supabase.com:5432/postgres?sslmode=require

FRONTEND_URL=https://dova.dntech.id
CROSS_SITE_COOKIES=true

PAYSTACK_SECRET_KEY=sk_test_REPLACE
PAYSTACK_CURRENCY=NGN
PAYSTACK_CALLBACK_URL=https://dova.dntech.id/checkout/verify
```

| Variable | Description |
|----------|-------------|
| `PORT` | Internal API port (PM2/nginx proxy here). Match nginx config. |
| `JWT_SECRET` | Generate new: `openssl rand -hex 32` |
| `DATABASE_URL` | Postgres on new server (Supabase: use connection string + `?sslmode=require`) |
| `FRONTEND_URL` | Public storefront URL (no trailing slash) |
| `CROSS_SITE_COOKIES` | `true` if frontend & API are on different subdomains/domains |
| `ADMIN_PASSWORD` / `SUPPLIER_PASSWORD` | Demo account passwords; used by seed & bootstrap |
| `PAYSTACK_SECRET_KEY` | Paystack secret key (test: `sk_test_...`, live: `sk_live_...`) |
| `PAYSTACK_CALLBACK_URL` | Checkout verify page on frontend |

### Optional

```env
# Only if Redis is actually running — if not, DO NOT set (backend falls back without Redis)
# REDIS_URL=redis://127.0.0.1:6379

# PAYSTACK_CHANNELS=card,bank,ussd,bank_transfer
```

### Required for customer registration (production, since v0.5.4)

**Option B — Gmail (DOVA official):**

```env
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=officialdovachain@gmail.com
SMTP_PASS=xxxx xxxx xxxx xxxx
EMAIL_FROM=DOVA <officialdovachain@gmail.com>
SUPPORT_EMAIL=officialdovachain@gmail.com
```

`SMTP_PASS` = Google **App Password** (not login password). Create at: Google Account → Security → 2-Step Verification ON → App passwords.

**Option A — Resend + domain (alternative):**

```env
RESEND_API_KEY=re_REPLACE
EMAIL_FROM=DOVA <noreply@dova.dntech.id>
SUPPORT_EMAIL=support@dova.dntech.id
```

Without SMTP **or** Resend + `EMAIL_FROM`, customer signup is rejected in production.

### Optional — automated smoke QA

```env
DOVA_QA_FIXED_OTP=123456
```

Only for email pattern `qa.softlaunch.*@example.com`. Set the same value when running `SMOKE_OTP_CODE=123456 npm run smoke:production`.

### Generate secret

```bash
openssl rand -hex 32
```

---

## Frontend — `apps/frontend/.env.local`

### Required (VPS / self-hosted Next.js)

```env
NEXT_PUBLIC_API_URL=https://api.dova.dntech.id/api/v1
NEXT_PUBLIC_PAYSTACK_PUBLIC_KEY=pk_test_REPLACE
```

| Variable | Description |
|----------|-------------|
| `NEXT_PUBLIC_API_URL` | API base URL + `/api/v1` |
| `NEXT_PUBLIC_PAYSTACK_PUBLIC_KEY` | Paystack public key (pair with `PAYSTACK_SECRET_KEY`) |

> **Important:** `NEXT_PUBLIC_*` variables are embedded at **`npm run build`**. After changing `.env.local`, rebuild the frontend.

### Deploy on Vercel

Set the same variables in **Project Settings → Environment Variables** (not `.env.local` on VPS).

---

## Supabase PostgreSQL

If DB uses **Supabase** (not local Postgres on VPS):

1. In Supabase Dashboard → **Settings → Database** → copy **Connection string** (**Transaction pooler** mode, port `5432`).
2. Paste into `DATABASE_URL` in `apps/backend/.env`.
3. **Required** — append SSL at end of URL:

```env
DATABASE_URL=postgresql://postgres.xxxxx:PASSWORD@aws-0-ap-northeast-2.pooler.supabase.com:5432/postgres?sslmode=require
```

4. Set `USE_IN_MEMORY=false`.
5. Run migrate + seed **from server** (or locally with same env):

```bash
npm run db:migrate
npm run db:reset-logins
```

Passwords with special characters (`!`, `@`, `#`) are safe in `.env` without quotes. Do not commit `.env` files to git.

**Security:** do not share connection strings in chat/issues — rotate password in Supabase if leaked.

---

Update in [Paystack Dashboard](https://dashboard.paystack.com):

| Setting | Value |
|---------|-------|
| **Webhook URL** | `POST https://api.dova.dntech.id/api/v1/payments/webhook` |
| **Event** | `charge.success` |
| **Callback** | Handled via `PAYSTACK_CALLBACK_URL` / backend env |

Replace `api.dova.dntech.id` if API hostname differs.

---

## After `.env` is ready

Run from **repo root** (`~/dova` or `/var/www/dntech/dova`), not only from `apps/backend` — package `dova-shared` must be built first.

```bash
cd ~/dova   # or /var/www/dntech/dova

npm install
npm run db:migrate
npm run db:seed           # fix image_url + demo data

# Build all (shared → backend → frontend)
npm run build

pm2 restart dova-backend dova-frontend --update-env
```

If building per workspace:

```bash
npm run build -w dova-shared
npm run build -w dova-backend
npm run build -w dova-frontend
```

---

## Demo login (default)

| Role | Email | Password |
|------|-------|----------|
| Admin | `admin@dova.local` | value of `ADMIN_PASSWORD` (default `admin1234`) |
| Supplier | `supplier@dova.local` | value of `SUPPLIER_PASSWORD` (default `supplier1234`) |

Reset demo passwords to env:

```bash
npm run db:reset-logins
```

---

## Server migration checklist

- [ ] New Postgres + `DATABASE_URL`
- [ ] New `JWT_SECRET`
- [ ] `FRONTEND_URL` & `NEXT_PUBLIC_API_URL` match new domain
- [ ] `PAYSTACK_CALLBACK_URL` + Paystack webhook updated
- [ ] Remove `REDIS_URL` if new server has **no** Redis
- [ ] DNS + SSL nginx for FE & API
- [ ] `npm run build` frontend after final `.env.local`
- [ ] `pm2 restart ... --update-env`
- [ ] Test: `/api/v1/health`, admin login, Paystack test checkout

---

## Full example (staging dntech.id)

### `apps/backend/.env`

```env
NODE_ENV=production
PORT=4201

USE_IN_MEMORY=false
JWT_SECRET=a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456
ADMIN_PASSWORD=admin1234
SUPPLIER_PASSWORD=supplier1234

DATABASE_URL=postgresql://dova:STRONG_PASSWORD@127.0.0.1:5432/dova

FRONTEND_URL=https://dova.dntech.id
CROSS_SITE_COOKIES=true

PAYSTACK_SECRET_KEY=sk_test_XXXXXXXXXXXXXXXX
PAYSTACK_CURRENCY=NGN
PAYSTACK_CALLBACK_URL=https://dova.dntech.id/checkout/verify
```

### `apps/frontend/.env.local`

```env
NEXT_PUBLIC_API_URL=https://api.dova.dntech.id/api/v1
NEXT_PUBLIC_PAYSTACK_PUBLIC_KEY=pk_test_XXXXXXXXXXXXXXXX
```

**Do not commit `.env` / `.env.local` files containing secrets to git.**
