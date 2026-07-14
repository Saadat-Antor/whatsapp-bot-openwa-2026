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