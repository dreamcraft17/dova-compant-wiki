#!/usr/bin/env bash
# Sync DOVA docs across:
#   1) dova-company-wiki/              (canonical)
#   2) company-wiki/docs/products/dova (company mirror)
#   3) dova/docs/                      (app-local working copy)
#
# Usage:
#   ./scripts/sync-docs.sh              # from-wiki
#   ./scripts/sync-docs.sh from-wiki
#   ./scripts/sync-docs.sh from-app
#   ./scripts/sync-docs.sh all

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WIKI_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKSPACE="$(cd "$WIKI_ROOT/.." && pwd)"

COMPANY_MIRROR="$WORKSPACE/company-wiki/docs/products/dova"
APP_DOCS="$WORKSPACE/dova/docs"

MODE="${1:-from-wiki}"

if [[ ! -d "$COMPANY_MIRROR" ]]; then
  echo "ERROR: company-wiki mirror missing: $COMPANY_MIRROR" >&2
  exit 1
fi

mkdir -p "$APP_DOCS" "$COMPANY_MIRROR"

# Pairs: "app-relative|wiki-relative"
# App paths are under dova/docs/; wiki paths under dova-company-wiki/
MAPPINGS=(
  "DOVA_CEO_PROGRESS_UPDATE.md|docs/CEO-PROGRESS-UPDATE.md"
  "DOVA_PHASE_UPDATE_BD.md|docs/PHASE-UPDATE-BD.md"
  "DOVA_MVP_PROGRESS_UPDATE.md|docs/MVP-PROGRESS-UPDATE.md"
  "Dova MVP Current Imlementation Status.md|docs/MVP-STATUS.md"
  "DOVA_API.md|docs/API.md"
  "DOVA_RUNBOOK.md|docs/RUNBOOK.md"
  "DOVA_SPEC_COMPLIANCE.md|docs/SPEC-COMPLIANCE.md"
  "CHANGELOG.md|docs/CHANGELOG.md"
  "BUG_FIXES.md|docs/BUG_FIXES.md"
  "DOVA_REPLY_PAYSTACK_AND_MIN_ORDER.md|docs/REPLY-PAYSTACK-AND-MIN-ORDER.md"
  "DOVA_REPLY_SUPPLIER_VERIFICATION_DOCS.md|docs/REPLY-SUPPLIER-VERIFICATION-DOCS.md"
  "DOVA_VPS_DEPLOY.md|docs/VPS-DEPLOY.md"
  "DOVA_VERCEL_DEPLOYMENT_OVERRIDE.md|docs/VERCEL-DEPLOYMENT-OVERRIDE.md"
  "DOVA_PRD_AGGRESSIVE_4W.md|PRD/dova-prd-aggressive-4w.md"
  "DOVA_SRS_AGGRESSIVE_4W.md|PRD/dova-srs-aggressive-4w.md"
  "DOVA_SDD_AGGRESSIVE_4W.md|PRD/dova-sdd-aggressive-4w.md"
  "DOVA_SUMMARY_4W.md|PRD/dova-summary-4w.md"
  "DOVA_TECH_STACK_MONOREPO.md|PRD/dova-tech-stack-monorepo.md"
)

copy_file() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  echo "  ✓ $(basename "$src") → $dest"
}

sync_wiki_tree_to_company() {
  echo "→ Mirror wiki → company-wiki/docs/products/dova/"
  rsync -a --delete \
    --exclude '.git' \
    --exclude 'scripts' \
    --exclude 'SYNC.md' \
    --exclude 'README.md' \
    --exclude 'PRODUCT.md' \
    --exclude 'local-aliases' \
    "$WIKI_ROOT/" "$COMPANY_MIRROR/"
  # Company wiki product folder keeps product overview as README.md
  if [[ -f "$WIKI_ROOT/PRODUCT.md" ]]; then
    cp "$WIKI_ROOT/PRODUCT.md" "$COMPANY_MIRROR/README.md"
    echo "  ✓ PRODUCT.md → company-wiki .../README.md"
  fi
  echo "  ✓ company-wiki mirror updated"
}

sync_wiki_to_app() {
  echo "→ Map wiki → dova/docs/ (mapped names)"
  for pair in "${MAPPINGS[@]}"; do
    local app_rel="${pair%%|*}"
    local wiki_rel="${pair##*|}"
    local src="$WIKI_ROOT/$wiki_rel"
    local dest="$APP_DOCS/$app_rel"
    if [[ -f "$src" ]]; then
      copy_file "$src" "$dest"
    fi
  done
  # Also copy current-phase with a clear local name
  if [[ -f "$WIKI_ROOT/current-phase.md" ]]; then
    copy_file "$WIKI_ROOT/current-phase.md" "$APP_DOCS/current-phase.md"
  fi
  # Living docs that only exist under wiki docs/ without DOVA_ alias
  for f in FEATURE-CATALOG.md CURRENT-IMPLEMENTATION.md DEMO-ACCOUNTS.md; do
    if [[ -f "$WIKI_ROOT/docs/$f" ]]; then
      copy_file "$WIKI_ROOT/docs/$f" "$APP_DOCS/$f"
    fi
  done
}

sync_app_to_wiki() {
  echo "→ Map dova/docs/ → wiki (mapped names)"
  for pair in "${MAPPINGS[@]}"; do
    local app_rel="${pair%%|*}"
    local wiki_rel="${pair##*|}"
    local src="$APP_DOCS/$app_rel"
    local dest="$WIKI_ROOT/$wiki_rel"
    if [[ -f "$src" ]]; then
      copy_file "$src" "$dest"
    fi
  done
  if [[ -f "$APP_DOCS/current-phase.md" ]]; then
    copy_file "$APP_DOCS/current-phase.md" "$WIKI_ROOT/current-phase.md"
  fi
  for f in FEATURE-CATALOG.md CURRENT-IMPLEMENTATION.md DEMO-ACCOUNTS.md; do
    if [[ -f "$APP_DOCS/$f" ]]; then
      copy_file "$APP_DOCS/$f" "$WIKI_ROOT/docs/$f"
    fi
  done
}

case "$MODE" in
  from-wiki|all)
    echo "Sync mode: $MODE (canonical = dova-company-wiki)"
    echo "Wiki root: $WIKI_ROOT"
    sync_wiki_tree_to_company
    sync_wiki_to_app
    echo "Done."
    ;;
  from-app)
    echo "Sync mode: from-app (pull from dova/docs, then mirror out)"
    echo "Wiki root: $WIKI_ROOT"
    sync_app_to_wiki
    sync_wiki_tree_to_company
    echo "Done."
    ;;
  *)
    echo "Usage: $0 [from-wiki|from-app|all]" >&2
    exit 1
    ;;
esac
