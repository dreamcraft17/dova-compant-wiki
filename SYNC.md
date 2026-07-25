# DOVA docs — three-way sync

Keep these three trees aligned whenever DOVA docs change.

| Location | Role | Git |
|----------|------|-----|
| `dova-company-wiki/` | **Canonical** published wiki for DOVA | Own repo (this folder) |
| `company-wiki/docs/products/dova/` | Mirror in DN Tech company wiki | `company-wiki` |
| `dova/docs/` | Local working copy next to the app | **gitignored** in `dova` |

```
                    ┌─────────────────────┐
                    │  dova-company-wiki  │  ← prefer edit here for published docs
                    └──────────┬──────────┘
                               │
              sync-docs.sh     │
                 ┌─────────────┴─────────────┐
                 ▼                           ▼
   company-wiki/docs/products/dova     dova/docs/ (aliases)
```

## How to sync

From the workspace root (`dozer/`):

```bash
./dova-company-wiki/scripts/sync-docs.sh
```

### Modes

| Mode | What it does |
|------|----------------|
| `from-wiki` (default) | Canonical wiki → company-wiki mirror **and** `dova/docs` (mapped names) |
| `from-app` | Pull mapped files from `dova/docs` into canonical wiki, then push to company-wiki |
| `all` | Alias of `from-wiki` |

### Typical workflow

1. Edit docs in **`dova-company-wiki/`** (or edit a note under `dova/docs/` if you’re mid-coding).  
2. Run `./dova-company-wiki/scripts/sync-docs.sh from-wiki` (or `from-app` if you edited `dova/docs` first).  
3. Commit & push:
   - `dova-company-wiki` (this repo)
   - `company-wiki` (mirror path only)
   - App repo usually **does not** commit `docs/` (gitignored)

## Filename map (`dova/docs` ↔ wiki)

App-local docs often use a `DOVA_` prefix. The sync script maps these both ways:

| `dova/docs/` (local) | `dova-company-wiki/` |
|----------------------|----------------------|
| `DOVA_CEO_PROGRESS_UPDATE.md` | `docs/CEO-PROGRESS-UPDATE.md` |
| `DOVA_PHASE_UPDATE_BD.md` | `docs/PHASE-UPDATE-BD.md` |
| `DOVA_MVP_PROGRESS_UPDATE.md` | `docs/MVP-PROGRESS-UPDATE.md` |
| `Dova MVP Current Imlementation Status.md` | `docs/MVP-STATUS.md` |
| `DOVA MVP PROGRESS UPDATE.md` | `docs/MVP-PROGRESS-UPDATE.md` (same content family) |
| `DOVA_API.md` | `docs/API.md` |
| `DOVA_RUNBOOK.md` | `docs/RUNBOOK.md` |
| `DOVA_SPEC_COMPLIANCE.md` | `docs/SPEC-COMPLIANCE.md` |
| `CHANGELOG.md` | `docs/CHANGELOG.md` |
| `BUG_FIXES.md` | `docs/BUG_FIXES.md` |
| `DOVA_REPLY_PAYSTACK_AND_MIN_ORDER.md` | `docs/REPLY-PAYSTACK-AND-MIN-ORDER.md` |
| `DOVA_REPLY_SUPPLIER_VERIFICATION_DOCS.md` | `docs/REPLY-SUPPLIER-VERIFICATION-DOCS.md` |
| `DOVA_VPS_DEPLOY.md` | `docs/VPS-DEPLOY.md` |
| `DOVA_VERCEL_DEPLOYMENT_OVERRIDE.md` | `docs/VERCEL-DEPLOYMENT-OVERRIDE.md` |
| `DOVA_PRD_AGGRESSIVE_4W.md` | `PRD/dova-prd-aggressive-4w.md` |
| `DOVA_SRS_AGGRESSIVE_4W.md` | `PRD/dova-srs-aggressive-4w.md` |
| `DOVA_SDD_AGGRESSIVE_4W.md` | `PRD/dova-sdd-aggressive-4w.md` |
| `DOVA_SUMMARY_4W.md` | `PRD/dova-summary-4w.md` |
| `DOVA_TECH_STACK_MONOREPO.md` | `PRD/dova-tech-stack-monorepo.md` |

`00_INDEX.md` is **not** synced (each location keeps its own index).

Unmapped files in `dova/docs/` are **left alone** (not deleted) on `from-wiki`.

## Rule of thumb

- **Publishing / sharing with BD or CEO** → edit in `dova-company-wiki`, sync, then push wiki repos.  
- **Quick local note while coding** → edit `dova/docs`, then `sync-docs.sh from-app`.  
- Always sync before telling someone “docs are up to date.”
