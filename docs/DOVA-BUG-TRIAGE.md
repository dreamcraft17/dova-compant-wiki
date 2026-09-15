# DOVA — Bug Triage (All Features)

> **Status:** Active · **Last updated:** 2026-08-28 · **Author:** Dozer · [@dreamcraft17](https://github.com/dreamcraft17)  
> **Repo HEAD:** `9e37a8a` · **Environment:** Production (`dova.dntech.id` / `api.dova.dntech.id`)  
> **Method:** AI bug triage pipeline — deterministic fingerprint + classification + QA routing

This document summarizes triage status for **all DOVA MVP modules**: automated coverage, manual UAT gaps, regression fingerprints, and backlog tickets requiring human approval before execution.

**Related:** [TEST-CASES.md](./TEST-CASES.md) · [UAT-BUG-FIXES.md](./UAT-BUG-FIXES.md) · [DOVA-API-QA-POSTMAN.md](./DOVA-API-QA-POSTMAN.md) · [DOVA-RELEASE-READINESS-AUDIT.md](./DOVA-RELEASE-READINESS-AUDIT.md) · [GUIDE.md](./GUIDE.md)

---

## Summary

| Metric | Value |
|--------|-------|
| MVP features | **10 modules** · ~67 API routes |
| Unit tests | **151/151 pass** (`npm run test`, 2026-08-28) |
| Global coverage | **~52%** (QA target: 80%) |
| Historical UAT bugs | **14 fixed** · **0 open P0/P1** |
| Production smoke (latest log) | **PASS** — **29+10** neg (2026-08-28) |
| Manual UAT not yet run | **Admin (ADM-01–07)**, **Feedback (FEED-01–10)**, **Mobile ops (OPS-04)** |

**Triage verdict:** Core journey (register → OTP → cart → order → pay init → supplier → admin API) is **stable**. Main risks: **manual QA gaps**, **smoke not yet re-verified on prod after latest deploy**, and **env dependencies** (SMTP Gmail App Password, Paystack live).

---

## Production URLs

| Service | URL |
|---------|-----|
| Storefront | https://dova.dntech.id |
| API | https://api.dova.dntech.id/api/v1 |
| Health | https://api.dova.dntech.id/api/v1/health |

---

## Feature matrix — triage status

| Module | Routes / pages | Auto test | Smoke | Manual UAT | Status |
|--------|----------------|-----------|-------|------------|--------|
| **1. Auth & roles** | 10 API + 6 pages | ✅ Strong | ✅ Partial | ✅ PASS | 🟢 Low risk |
| **2. Catalog** | 3 API + 2 pages | ✅ | ✅ | ✅ PASS | 🟢 Low risk |
| **3. Cart & slot** | 4 API + 1 page | ✅ + regressions | ✅ | ✅ PASS | 🟢 Low risk |
| **4. Checkout & min order** | 1 API + 2 pages | ✅ | ✅ | ✅ PASS | 🟢 Low risk |
| **5. Payments** | 5 API + verify page | ✅ mock + HMAC | ✅ init only | ⚠️ PAY-03 live | 🟡 Medium |
| **6. Supplier** | 11 API + 2 pages | ✅ CRUD/fulfillment | ✅ partial | ✅ PASS | 🟢 Low risk |
| **7. Admin** | 14 API + 1 page | ✅ incl. delete user | ✅ + DELETE | ❌ Not tested | 🟡 Medium |
| **8. Feedback board** | 13 API + 5 pages | ✅ 6 unit | ✅ GET only | ❌ Not tested | 🟡 Medium |
| **9. Public / contact** | 2 API + 4 pages | ✅ | ✅ | Partial | 🟢 Low risk |
| **10. Ops / health** | health, migrate, PM2 | ✅ env-guard | ✅ | ⚠️ OPS-04 mobile | 🟡 Medium |

---

## Component ownership (routing)

| Component | Primary path | Owner |
|-----------|--------------|-------|
| Auth | `apps/backend/src/app.service.ts`, `apps/frontend/src/pages/auth/*` | Backend + Frontend |
| Commerce | cart, orders, payments | Backend |
| Supplier | `supplier.tsx`, `/suppliers/*` | Fullstack |
| Admin | `admin.tsx`, `AdminUserModal.tsx` | Fullstack |
| Feedback | `feedback.service.ts`, `pages/feedback/*` | Backend |
| Ops | VPS env, PM2, migrations | Dozer (deploy) |

---

## Per-module — fingerprint & classification

### 1. Auth & roles

| Fingerprint | Anchor | Category | Severity | Status |
|-------------|--------|----------|----------|--------|
| `a1b2-auth-401-unverified` | Login before OTP verify | Application (by design) | Minor | ✅ Expected |
| `c3d4-auth-smtp-535` | `[Mail] SMTP send failed: auth failed` | Environment | Major | ⚠️ Ops — Gmail App Password |
| `e5f6-auth-register-blocked` | Signup rejected, email provider not configured | Environment | Critical | Guard prod OK |
| `g7h8-auth-forgot-nosmoke` | `/auth/forgot-password` not in smoke | Test gap | Minor | ✅ Fixed — smoke 24–26 |

**Regression:** BUG-002/003 (Bearer token), forgot/reset password unit tests ✅

---

### 2. Catalog & search

| Fingerprint | Issue | Status |
|-------------|-------|--------|
| `cat-001-meat-vegetables` | Chicken in Vegetables filter | ✅ Fixed BUG-001 |
| `cat-006-wrong-image` | Wrong Farm Milk image | ✅ Fixed BUG-006 |
| `cat-500-invalid-uuid` | Invalid product id → 500 | ✅ Fixed PROD-01 → 404 |

---

### 3. Cart & delivery slot

| Fingerprint | Issue | Status |
|-------------|-------|--------|
| `cart-004-no-slot` | Add without delivery slot | ✅ Fixed BUG-CART-004 |
| `cart-005-over-stock` | Qty > stock | ✅ Fixed BUG-CART-005 |
| `cart-011-badge-kg` | Cart badge counted kg not line items | ✅ Fixed BUG-011 |

---

### 4. Checkout & minimum order

| Fingerprint | Issue | Status |
|-------------|-------|--------|
| `chk-007-dup-pkey` | `order_items_pkey` duplicate | ✅ Fixed BUG-007 |
| `chk-min-delivery-5000` | Checkout delivery < ₦5,000 | ✅ Tested |
| `chk-min-pickup-3000` | Checkout pickup < ₦3,000 | ✅ Tested |

---

### 5. Payments (Paystack)

| Fingerprint | Issue | Category | Priority |
|-------------|-------|----------|----------|
| `pay-002-dup-ref` | Duplicate payment reference | — | ✅ Fixed |
| `pay-webhook-no-sig` | Webhook without HMAC | Security | ✅ Rejected by design |
| `pay-live-card-unverified` | PAY-03 live card not UAT'd | Test gap | **P1** |
| `pay-webhook-smoke-missing` | Webhook not in smoke script | Test gap | P2 |

---

### 6. Supplier portal

| Fingerprint | Issue | Status |
|-------------|-------|--------|
| `sup-008-all-products` | View other supplier's products | ✅ Fixed BUG-008 |
| `sup-003-deleted-visible` | Deleted product still visible | ✅ Fixed |
| `sup-approve-42p08` | Postgres cast on approve | ✅ Fixed BF-017 |

**Gap:** Multipart upload not in production smoke.

---

### 7. Admin panel

| Fingerprint | Issue | Category | Priority |
|-------------|-------|----------|----------|
| `adm-not-uat` | ADM-01–07 not manually UAT'd | Test gap | **P1** |
| `adm-delete-new` | DELETE user (`8fb5b5e`) | Needs smoke re-run | P0 after deploy |
| `adm-ui-no-rtl` | `AdminUserModal`, `admin.tsx` no component test | Test gap | P2 |

**Smoke coverage (latest code, not yet verified in prod log):**

- DELETE pending user (no orders) → 200
- NEG-08: customer token → 403
- NEG-09: admin self-delete → 400

---

### 8. Feedback board (native)

| Fingerprint | Issue | Category | Priority |
|-------------|-------|----------|----------|
| `feed-not-uat` | FEED-01–10 not manual | Test gap | **P1** |
| `feed-smoke-get-only` | Smoke only `GET /feedback/posts` | Test gap | P2 |
| `feed-vote-dup` | Double vote | — | ✅ Unit tested |

---

### 9. Public & contact

| Fingerprint | Status |
|-------------|--------|
| `contact-persist` | ✅ Smoke POST + admin GET |
| `pub-mobile-layout` | ⚠️ OPS-04 pending | P2 |

---

### 10. Ops & infrastructure

| Fingerprint | Issue | Category | Priority |
|-------------|-------|----------|----------|
| `ops-smoke-stale` | Log smoke 23+7; code 26+9 | Test gap | **P0** re-run |
| `ops-migration-007` | Password reset migration | Ops | ✅ if migrated |
| `ops-doc-drift` | TEST-CASES.md test count | Docs | Trivial | ✅ Fixed |

---

## Regression watch — dedup registry

If fingerprint matches a **closed** ticket, **reopen as regression** and raise priority.

| Bug ID | Fingerprint prefix | Reopen if |
|--------|-------------------|-----------|
| BUG-002/003 | `auth-401-cart-crossorigin` | Cart/add 401 despite logged in |
| BUG-007 | `checkout-order_items_pkey` | Duplicate key on checkout |
| BUG-008 | `supplier-wrong-product-list` | Supplier sees another's SKUs |
| PROD-01 | `products-invalid-uuid-500` | `GET /products/not-uuid` → 500 |
| BF-017 | `supplier-approve-42P08` | Approve supplier Postgres error |

Full history: [UAT-BUG-FIXES.md](./UAT-BUG-FIXES.md)

---

## Open backlog — suggested tickets (human approval)

| ID | Title | Category | Severity | Priority | Action |
|----|-------|----------|----------|----------|--------|
| **TRI-001** | Re-run `smoke:production` after deploy `8fb5b5e` | Test gap | Major | **P0** | Run + save log |
| **TRI-002** | UAT Admin ADM-01–07 manual on production | Test gap | Major | **P1** | QA checklist |
| **TRI-003** | UAT Feedback FEED-01–10 | Test gap | Major | **P1** | QA checklist |
| **TRI-004** | Smoke: forgot-password + reset-password | Test gap | Minor | P2 | ✅ Done |
| **TRI-005** | Postman doc: `/auth/forgot-password`, `/auth/reset-password` | Docs | Trivial | P2 | ✅ Done |
| **TRI-006** | Paystack live card PAY-03 | Test gap | Major | P1 | 1× manual transaction |
| **TRI-007** | Mobile smoke OPS-04 | Test gap | Minor | P2 | Browser phone |
| **TRI-008** | Playwright E2E checkout + admin (QA-GAP-05) | Test gap | Minor | P2 | Scaffold |
| **TRI-009** | Frontend page RTL tests | Test gap | Minor | P3 | AdminUserModal, checkout |
| **TRI-010** | Coverage 52% → 80% | Tech debt | Minor | P3 | Incremental |

### Not code bugs (ops / env)

| Issue | Remediation |
|-------|-------------|
| SMTP `535 BadCredentials` | Set `SMTP_PASS` = Gmail App Password 16 char (not login password) |
| User stuck pending register | Admin → Users → Delete account (shipped `5488101` / `8fb5b5e`) |
| Smoke OTP fails | Set `DOVA_QA_FIXED_OTP` on server + `SMOKE_OTP_CODE` locally — see [ENV-SETUP.md](./ENV-SETUP.md) |

---

## Smoke vs unit — gap map

| Endpoint group | Unit | Smoke | Manual UAT |
|----------------|------|-------|------------|
| Auth register / OTP / login | ✅ | ✅ | ✅ |
| Auth forgot / reset | ✅ | ✅ | ❌ |
| Cart / checkout / order | ✅ | ✅ | ✅ |
| Payment initialize | ✅ | ✅ | Partial |
| Payment webhook | ✅ | ❌ | ❌ |
| Supplier CRUD | ✅ | Partial | ✅ |
| Admin CRUD + delete | ✅ | ✅ (latest code) | ❌ |
| Feedback full CRUD | ✅ | GET only | ❌ |

```
Automated well  ████████████░░░░░░░░  ~60%
Manual only     ░░░░░░░░░░░░████████  Admin UI, Feedback UI, Mobile
Not covered     ░░░░░░░░░░░░░░░░████  E2E browser, forgot-password smoke
```

---

## Severity × priority (reference)

| Severity | Definition | DOVA examples |
|----------|------------|---------------|
| **Critical** | System unusable, data loss, no workaround | All payments fail, signup blocked without SMTP |
| **Major** | Core feature broken, workaround exists | Admin delete fails, checkout error |
| **Minor** | Non-core, cosmetic + functional | Sort doesn't persist, tooltip clip |
| **Trivial** | Cosmetic only | Label typo |

| Priority | Example SLA |
|----------|-------------|
| **P0** | Same day — blocks release/prod |
| **P1** | This sprint |
| **P2** | Next sprint |
| **P3** | Backlog |

---

## Immediate actions (P0–P1)

### P0 — After deploy `8fb5b5e`

```bash
# Local (needs OTP env)
SMOKE_OTP_CODE=123456 npm run smoke:production

# VPS deploy
cd ~/dova && git pull && npm ci && npm run build && pm2 restart dova-api dova-web --update-env
```

Log saved to `tests/smoke-production-latest.log`.

### P1 — Manual UAT

| Module | Test IDs | URL |
|--------|----------|-----|
| Admin | ADM-01–07 | https://dova.dntech.id/admin |
| Feedback | FEED-01–10 | https://dova.dntech.id/feedback |
| Payment live | PAY-03 | Checkout → Paystack test/live card |

Scenario details: [TEST-CASES.md](./TEST-CASES.md)

---

## Running automated checks

```bash
npm run test              # 151 unit tests
npm run test:coverage     # coverage report (~52% global)
npm run smoke:production  # production API (needs SMOKE_OTP_CODE)
npm run smoke:week4       # health + contact persist
```

Demo accounts: admin `admin@dova.local` / `admin1234` · supplier `supplier@dova.local` / `supplier1234`

---

## Document changelog

| Date | Change |
|------|--------|
| 2026-08-28 | TRI-004/005 closed — forgot/reset smoke + Postman; TEST-CASES count 151; full English |
