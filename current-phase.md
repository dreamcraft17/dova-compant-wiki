# DOVA — Current Phase

| | |
|---|---|
| **Product** | DOVA — food supply marketplace (Nigeria / NGN / Paystack) |
| **Repository** | [`dreamcraft17/dova`](https://github.com/dreamcraft17/dova) |
| **HEAD** | `b17e2a5` · **Tag:** `v0.5.2` |
| **Document date** | 27 August 2026 |
| **Owner** | Dozer |
| **Phase** | **🚀 Soft launch live (staging)** |

> **Release audit:** [docs/DOVA-RELEASE-READINESS-AUDIT.md](./docs/DOVA-RELEASE-READINESS-AUDIT.md) — **100% soft launch**

---

## One-line status

**Soft launch is live** at [dova.dntech.id](https://dova.dntech.id). **127** tests green · full API smoke pass · Paystack initialized on staging.

| Live now | Post soft-launch |
|----------|------------------|
| Staging storefront + API | `dovachain.com` domain cutover |
| Customer / supplier / admin flows | Playwright E2E suite |
| Paystack payment initialize | ≥10 completed live card txs (CEO demo) |
| Automated API smoke (`smoke:staging`) | Mobile browser spot-check |

---

## Staging URLs

| Service | URL |
|---------|-----|
| Storefront | https://dova.dntech.id |
| API health | https://api.dova.dntech.id/api/v1/health |

**Demo:** admin `admin@dova.local` / `admin1234` · supplier `supplier@dova.local` / `supplier1234`

---

## Verify release

```bash
npm run smoke:staging
API_URL=https://api.dova.dntech.id/api/v1 npm run smoke:week4
```

Log: `dova/tests/smoke-staging-latest.log`

---

*Last updated: 27 August 2026*
