# DOVA Company Wiki

Dedicated documentation wiki for **DOVA** (food supply marketplace).

| | |
|---|---|
| **Product** | DOVA |
| **Owner** | Dozer · DN Tech |
| **App repo** | [`dreamcraft17/dova`](https://github.com/dreamcraft17/dova) → local `dova/` |
| **This wiki** | `dova-company-wiki/` (**canonical** for DOVA docs) |
| **Company wiki mirror** | `company-wiki/docs/products/dova/` |
| **App local docs** | `dova/docs/` (gitignored in app repo; working copy) |

## Start here

| Doc | For |
|-----|-----|
| [00_INDEX.md](./00_INDEX.md) | Full index |
| [current-phase.md](./current-phase.md) | Current phase snapshot |
| [docs/CEO-PROGRESS-UPDATE.md](./docs/CEO-PROGRESS-UPDATE.md) | CEO update |
| [docs/PHASE-UPDATE-BD.md](./docs/PHASE-UPDATE-BD.md) | BD / non-tech update |
| [docs/CURRENT-IMPLEMENTATION.md](./docs/CURRENT-IMPLEMENTATION.md) | Implementation baseline |
| [docs/DOVA-RELEASE-READINESS-AUDIT.md](./docs/DOVA-RELEASE-READINESS-AUDIT.md) | Release readiness (~78%) |
| [PRD/](./PRD/) | PRD · SRS · SDD |

## Three-way sync

Docs should stay aligned across:

1. **`dova-company-wiki/`** — source of truth for published DOVA wiki pages  
2. **`company-wiki/docs/products/dova/`** — mirror inside the company knowledge base  
3. **`dova/docs/`** — local working docs next to the app (often with `DOVA_*` filenames)

```bash
# From anywhere in the monorepo workspace:
./dova-company-wiki/scripts/sync-docs.sh

# Or with an explicit direction:
./dova-company-wiki/scripts/sync-docs.sh from-wiki     # wiki → company-wiki + dova/docs
./dova-company-wiki/scripts/sync-docs.sh from-app      # dova/docs → wiki (+ company-wiki)
./dova-company-wiki/scripts/sync-docs.sh all           # same as default: from-wiki
```

Details: [SYNC.md](./SYNC.md).

## Layout

```
dova-company-wiki/
├── README.md              ← this file
├── SYNC.md                ← sync rules
├── 00_INDEX.md
├── current-phase.md
├── docs/                  ← living docs
├── PRD/                   ← specs
└── scripts/sync-docs.sh
```
