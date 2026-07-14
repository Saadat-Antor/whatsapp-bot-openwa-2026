# CHANGELOG.md

> Dated log of decisions, changes, and rationale. Newest entries at the top. Keep entries concise — full context lives in `CONTEXT.md`.

---

## [2026-07-14] — Phase 1: Foundation & Tracking Files
### Added
- Created project root directory structure: `whatsapp-bot-openwa/`
- Created `CONTEXT.md`, `PROJECT_STATE.md`, `CHANGELOG.md`

### Decisions Finalized (carried over from planning discussion)
- **Vector storage:** PostgreSQL + pgvector, not Qdrant — conditional on KB staying under ~5,000 documents. Avoids adding an extra Docker image and reuses existing Postgres expertise.
- **Conversation history:** PostgreSQL, persisted, queryable per `chatId`.
- **Project isolation:** Separate root directory and separate `docker-compose.yml` from the owner's existing "project-a" (6 containers, 2 Postgres instances, 1 n8n instance). Cross-project communication via a **shared Docker network**, created once and referenced by both projects' compose files.
- **Database security:** Isolated DB user strategy — separate database and separate PostgreSQL user per project, each scoped only to its own database, strong unique passwords. No shared superuser credentials across projects.
- **n8n workflows:** Three workflows — KB Ingestion (scheduled), WhatsApp Message Handler (main bot), Inline Conversation Logger.
- **Git strategy:** Two branches only — `dev` and `main`. No feature branches. Commit convention `[TYPE] Description` (`[SETUP]`, `[FEATURE]`, `[FIX]`, `[DOCS]`). Branch protection on `main` planned, deferred until both branches exist remotely.
- **Working agreement:** No code/files generated without explicit owner go-ahead at each step. Tracking files designed to minimize token overhead in future AI handoffs.

### Status
- Phase 1 in progress (this changelog + remaining tracking files)

### Next Steps
- [ ] Finish `.gitignore` and `README.md`
- [ ] Owner: initialize local git repo, create `dev` branch, push to GitHub
- [ ] Get go-ahead for Phase 2 (docker-compose.yml, env files, DB init scripts)


# CHANGELOG.md

> Dated log of decisions, changes, and rationale. Newest entries at the top. Keep entries concise — full context lives in `CONTEXT.md`.

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
- **Vector storage:** PostgreSQL + pgvector, not Qdrant.
- **Conversation history:** PostgreSQL, persisted, queryable per `chatId`.
- **Project isolation:** Separate root directory and separate `docker-compose.yml` from the owner's existing "project-a". Cross-project communication via a **shared Docker network**.
- **Database security:** Isolated DB user strategy.
- **n8n workflows:** Three workflows — KB Ingestion, WhatsApp Message Handler, Inline Conversation Logger.
- **Git strategy:** Two branches only — `dev` and `main`. No feature branches.
- **Working agreement:** No code/files generated without explicit owner go-ahead at each step.

# CHANGELOG.md

> Dated log of decisions, changes, and rationale. Newest entries at the top. Keep entries concise — full context lives in `CONTEXT.md`.

---

## [2026-07-15] — Phase 3: Knowledge Base Prep (Ongoing)
### Decisions Finalized
- **Format Scope:** Decided to strictly use CSV format for the initial V1 knowledge base ingestion. DOCX support is deferred to a future iteration to keep the initial n8n workflow lean and focused.

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

# CHANGELOG.md

> Dated log of decisions, changes, and rationale. Newest entries at the top. Keep entries concise — full context lives in `CONTEXT.md`.

---

## [2026-07-15] — Phase 3: Knowledge Base Prep
### Added
- `data/kb/customer_qnas.csv`: Mock QnA data file structured with standard fields (`Category`, `Question`, `Answer`, `Reference_URL`).
- `data/kb/product_info.csv`: Structured product catalog dataset for catalog lookups.
- `data/kb/order_data.csv`: Transactional mock data mapped by customer phone numbers to facilitate live order tracking tests.

### Removed
- `data/kb/kb_placeholder.csv`: Replaced by specific functional mock files.

### Decisions Finalized
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