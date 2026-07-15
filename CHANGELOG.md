# CHANGELOG.md

> Dated log of decisions, changes, and rationale. Newest entries at the top. Keep entries concise — full context lives in `CONTEXT.md`.

---

## [2026-07-15] — Phase 4: n8n Workflows (Combined)
### Added
- `n8n/workflows/whatsapp-bot-combined-workflow.json` — single n8n workflow file containing all three workflows as routed branches:
  - **KB Ingestion branch** (Schedule Trigger, weekly Mon 2am): routes `customer_qnas.csv`/`product_info.csv` through chunking + OpenAI embeddings into pgvector (`kb_embeddings` table); routes `order_data.csv` directly into a relational `orders` table (exact-match lookups, not semantic search).
  - **Message Handler branch** (Webhook Trigger): filters incoming OpenWA events to text messages only, fetches conversation history, looks up the sender in `orders` to detect returning vs. new customers, merges all context into the AI Agent (which has the pgvector KB wired in as a tool), sends the reply via OpenWA, and logs the exchange — all in one branch.
- Three `n8n-nodes-base.switch` nodes used for routing: KB file type, incoming event filtering, and returning-vs-new customer context.

### Decisions Finalized
- Order data is stored **relationally**, not embedded into the vector store — order lookups need exact phone-number matching, not semantic similarity.
- "Immediately fetch conversion data for returning customers" implemented as: on every incoming message, look up the sender's phone number in `orders` before the AI Agent responds; inject a returning/new customer context string either way.
- Conversation logging is inline in the message handler branch rather than a separate workflow, since it always follows immediately after sending the reply.

### Assumptions Needing Verification (see Setup Notes sticky note in the JSON)
- CSV column names for `product_info.csv` and `order_data.csv` are assumed (not yet confirmed against the real mock files).
- Postgres tables `kb_embeddings`, `orders`, `conversations` are assumed to exist — need to confirm they're covered by `init-db.template.sql`, or add them.
- File paths assume `/data/kb/*.csv` inside the OpenWA/n8n container mount — adjust if different.

### Status
- Phase 4 workflow JSON generated, not yet imported/tested in a live n8n instance.

### Next Steps
- [ ] Owner: confirm/adjust CSV column assumptions
- [ ] Confirm `kb_embeddings`, `orders`, `conversations` tables exist (extend `init-db.template.sql` if not)
- [ ] Import workflow into n8n, wire up credentials (OpenAI, Postgres, OpenWA API Key)
- [ ] Begin Phase 5: Testing & Validation

---

## [2026-07-15] — Phase 3: Knowledge Base Prep
### Added
- `data/kb/customer_qnas.csv`: Mock QnA data file structured with standard fields (`Category`, `Question`, `Answer`, `Reference_URL`).
- `data/kb/product_info.csv`: Structured product catalog dataset for catalog lookups.
- `data/kb/order_data.csv`: Transactional mock data mapped by customer phone numbers to facilitate live order tracking tests.

### Removed
- `data/kb/kb_placeholder.csv`: Replaced by specific functional mock files.

### Decisions Finalized
- **Format Scope:** Decided to strictly use CSV format for the initial V1 knowledge base ingestion. DOCX support is deferred to a future iteration to keep the initial n8n workflow lean and focused.
- **Expanded Scope:** Expanded initial CSV structures to include dedicated product catalog tables and order tracking datasets to allow complex agent routing.

---

## [2026-07-15] — Phase 2: Infrastructure Setup
### Added
- Updated `docker-compose.yml` to securely map the `OPENWA_API_KEY` from the `.env` file into the OpenWA container environment, replacing auto-generated credentials.
- `docker-compose.yml` and `.env.example`: Configured to use a shared Docker network (`shared-network`) to route to the owner's existing PostgreSQL and n8n containers, avoiding duplicate instances.
- `scripts/init-db.template.sql`: SQL template to create an isolated database (`openwa_bot_db`), a restricted user, and enable the `pgvector` extension.
- `scripts/setup.sh`: Bash script to bootstrap local volume directories, set permissions, and securely generate `init-db.sql` using environment variables.

### Status
- Phase 2 infrastructure deployment and verification complete.

---

## [2026-07-14] — Phase 1: Foundation & Tracking Files
### Added
- Created project root directory structure: `whatsapp-bot-openwa/`
- Created `CONTEXT.md`, `PROJECT_STATE.md`, `CHANGELOG.md`, `.gitignore`, and `README.md`

### Decisions Finalized (carried over from planning discussion)
- **Vector storage:** PostgreSQL + pgvector, not Qdrant — conditional on KB staying under ~5,000 documents. Avoids adding an extra Docker image and reuses existing Postgres expertise.
- **Conversation history:** PostgreSQL, persisted, queryable per `chatId`.
- **Project isolation:** Separate root directory and separate `docker-compose.yml` from the owner's existing "project-a" (6 containers, 2 Postgres instances, 1 n8n instance). Cross-project communication via a **shared Docker network**, created once and referenced by both projects' compose files.
- **Database security:** Isolated DB user strategy — separate database and separate PostgreSQL user per project, each scoped only to its own database, strong unique passwords. No shared superuser credentials across projects.
- **n8n workflows:** Three workflows — KB Ingestion (scheduled), WhatsApp Message Handler (main bot), Inline Conversation Logger.
- **Git strategy:** Two branches only — `dev` and `main`. No feature branches. Commit convention `[TYPE] Description` (`[SETUP]`, `[FEATURE]`, `[FIX]`, `[DOCS]`). Branch protection on `main` planned, deferred until both branches exist remotely.
- **Working agreement:** No code/files generated without explicit owner go-ahead at each step. Tracking files designed to minimize token overhead in future AI handoffs.

### Status
- Phase 1 complete.

## [2026-07-15] — Phase 4: CSV Column Verification & Schema Updates
### Updates (Post-generation verification)
- Verified real CSV files against workflow assumptions:
  - `customer_qnas.csv`: ✅ exact match (Category, Question, Answer, Reference_URL)
  - `product_info.csv`: ❌ updated workflow (was: product_name, sku, availability → actual: ProductID, Name, Category, Description, Price, StockStatus)
  - `order_data.csv`: ❌ updated workflow (was: phone_number, order_id, quantity → actual: OrderID, CustomerPhone, Status, TotalAmount, ItemsOrdered, TrackingNumber)
- Updated all CSV-parsing and DB-upsert nodes in the workflow to use actual column names
- **Extended `scripts/init-db.template.sql`** with full table schemas:
  - `kb_embeddings` (pgvector, with ivfflat index)
  - `orders` (relational, indexed on customer_phone for fast returning-customer detection)
  - `conversations` (conversation history, indexed on chat_id)
  - Grants all privileges to `openwa_bot_user`

### Status
- Phase 4 now complete and verified
- Workflow ready to import into n8n
- Database schema ready to run via `setup.sh`

---