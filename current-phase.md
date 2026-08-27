# DOVA — Current Phase

| | |
|---|---|
| **Product** | DOVA — food supply marketplace (Nigeria / NGN / Paystack) |
| **Repository** | [`dreamcraft17/dova`](https://github.com/dreamcraft17/dova) |
| **HEAD** | `54c3009` · **v0.5.0** (soft-launch prep) |
| **Document date** | 27 August 2026 |
| **Owner** | Dozer |
| **Audience** | Engineering + business stakeholders |
| **Phase** | **Staging live → Paystack live + soft-launch go/no-go** |

> **Full technical status:** [docs/STATUS-LENGKAP.md](./docs/STATUS-LENGKAP.md)  
> **Release audit:** [docs/DOVA-RELEASE-READINESS-AUDIT.md](./docs/DOVA-RELEASE-READINESS-AUDIT.md) (~78% overall)  
> **BD / non-tech one-pager:** [docs/PHASE-UPDATE-BD.md](./docs/PHASE-UPDATE-BD.md)

---

## One-line status

**MVP codebase complete.** Staging live at [dova.dntech.id](https://dova.dntech.id). **121** unit tests green. Login-loop fix shipped (`fc177d6`). Soft launch pending Paystack live proof + manual QA execution.

| Done in code + staging | Still open (ops / business) |
|------------------------|-----------------------------|
| Auth + roles + Remember Me | Paystack LIVE keys + ≥10 txs |
| Catalog / cart / checkout | Manual QA (Postman + UI) — not recorded |
| Paystack (mock + test mode wired) | Soft-launch go/no-go sign-off |
| Supplier + admin dashboards | Production domain (`dovachain.com`) |
| Admin user management (v0.5.0) | VPS deploy verify (`fc177d6`+) |
| Native feedback board | |
| Staging VPS (PM2) live | |
| Min order pickup ₦3k / delivery ₦5k | |
| 121 unit tests + CI | |

---

## Staging URLs

| Service | URL |
|---------|-----|
| Storefront | https://dova.dntech.id |
| API health | https://api.dova.dntech.id/api/v1/health |

---

## Commerce rules

| Rule | Value |
|------|-------|
| Currency | ₦ (NGN) |
| Min order — pickup | ₦3,000 |
| Min order — delivery | ₦5,000 |
| Under-min message | “Add ₦X more to qualify for checkout.” |

---

## Demo accounts

| Role | Email | Password |
|------|-------|----------|
| Admin | `admin@dova.local` | `admin1234` |
| Supplier | `supplier@dova.local` | `supplier1234` |

---

## Current phase — next actions

1. Deploy latest API + web on VPS (`fc177d6` login fix, `54c3009` QA docs).  
2. Configure **Paystack live/test** keys + webhook on VPS.  
3. Run `npm run db:migrate` after deploy (migrations through `006`).  
4. QA runs Postman smoke ([DOVA-API-QA-POSTMAN.md](./docs/DOVA-API-QA-POSTMAN.md)) + UI ([TEST-CASES.md](./docs/TEST-CASES.md)).  
5. Run `npm run smoke:week4` against staging API — save output.  
6. Complete **≥10** Paystack test txs.  
7. Soft-launch go/no-go with business owners.

### Verified (August 2026)

- [x] Unit tests **121/121** pass (`npm run test:unit`) — verified 3× on 2026-08-27
- [x] Staging live — `dova.dntech.id` + `api.dova.dntech.id`
- [x] Native feedback board (replaced FeedLog)
- [x] Admin user management shipped (`52530da`)
- [x] Supplier approve/reject Postgres fix (`00c8601`)
- [x] Login loop fix — Bearer over stale cookie (`fc177d6`)

### Go / no-go checklist

- [x] Official staging URL  
- [ ] Customer pay → view order (Paystack live)  
- [ ] Supplier register → approve → fulfill (on staging with real DB)  
- [ ] ≥10 Paystack test txs  
- [x] Admin approvals on staging  
- [ ] Contact / support channel agreed  
- [ ] Mobile smoke on staging  
- [ ] Soft launch date approved  

---

## Documentation

Shared docs live in this wiki folder ([00_INDEX.md](./00_INDEX.md)).  
App repo keeps `docs/` **gitignored** locally; mirror updates here for the team.
