# PROJECT_STATE.md

> Snapshot of current progress. Update this file after every meaningful step. Read `CONTEXT.md` first if you need background on *why* decisions were made.

**Last updated:** 2026-07-15

---

## Legend
✅ Done · 🔄 In Progress · ⏳ Pending · ❌ Blocked

---

## Phase 1 — Foundation & Tracking Files
- ✅ Directory structure finalized (`whatsapp-bot-openwa/`)
- ✅ `CONTEXT.md` created
- ✅ `PROJECT_STATE.md` created (this file)
- ✅ `CHANGELOG.md` created
- ✅ `.gitignore` created
- ✅ `README.md` created

## Phase 2 — Infrastructure Setup
- ✅ `docker-compose.yml` (OpenWA + PostgreSQL usage, shared network config)
- ✅ `.env` / `.env.example`
- ✅ `scripts/init-db.template.sql` & `scripts/setup.sh` (secure DB init pattern)
- ✅ Shared Docker network created and verified between this project and existing `project-a` containers
- ✅ Run DB initialization on existing Postgres container

## Phase 3 — Knowledge Base Prep
- ✅ Confirm CSV column structures with owner
- ✅ Create `customer_qnas.csv` with mock data
- ✅ Create `product_info.csv` with mock data
- ✅ Create `order_data.csv` with mock data
- ✅ DOCX support deferred to future phase

## Phase 4 — n8n Workflows
- ✅ Combined workflow JSON generated: `n8n/workflows/whatsapp-bot-combined-workflow.json`
  - ✅ KB Ingestion branch (Schedule Trigger, weekly) — routes embed vs. relational data via Switch
  - ✅ Message Handler branch (Webhook Trigger) — filters event type, fetches history, detects returning/new customer, AI Agent w/ pgvector tool, sends reply
  - ✅ Conversation logging — inline in Message Handler branch (no separate workflow needed)
- 🔄 CSV column assumptions used in the workflow need owner verification (see sticky note inside the JSON)
- ⏳ Confirm/create `kb_embeddings`, `orders`, `conversations` Postgres tables (may need to extend `init-db.template.sql`)
- ⏳ Import workflow into n8n and wire up credentials (OpenAI, Postgres, OpenWA API Key)

## Phase 5 — Testing & Validation
- ⏳ OpenWA session creation + QR scan test
- ⏳ KB ingestion manual test (verify vectors land in pgvector, orders land in relational table)
- ⏳ End-to-end message flow test (incl. returning-customer context injection)
- ⏳ Isolated DB user permission test (confirm no cross-project access)

## Phase 6 — Git & Documentation Wrap-up
- ⏳ First commit to `dev` branch
- ⏳ Push `dev` to GitHub
- ⏳ Push `main` to GitHub
- ⏳ Enable branch protection on `main`
- ⏳ Merge `dev` → `main` once stable

---

## Current Blockers
None.

## Immediate Next Step
Owner to verify CSV column assumptions in the workflow JSON and confirm whether `kb_embeddings`, `orders`, and `conversations` tables already exist from Phase 2's `init-db.template.sql`, or need to be added.

## Key Open Questions (Owner Input Needed)
- Do the assumed CSV column names match the real `product_info.csv` and `order_data.csv` files?
- Were `kb_embeddings`, `orders`, and `conversations` tables included in the Phase 2 DB init script, or do they still need to be created?