# CONTEXT.md

> Purpose: This file gives any AI assistant (Claude, Claude Code, or another model) everything it needs to understand this project in one read, without re-explaining history. Read this first, then `PROJECT_STATE.md` for current status, then `CHANGELOG.md` only if deeper history is needed.

---

## Project Goal

Build a production-grade AI-powered WhatsApp chatbot using:
- **OpenWA** (self-hosted, open-source WhatsApp API gateway) instead of Meta's official WhatsApp Business API
- **n8n** for workflow orchestration
- A **knowledge base** (company FAQs, product catalogs, and live order tracking sheets via CSV) queried via a vector store and database lookups
- **Persistent per-customer conversation history**
- An **AI Agent** (LLM-based) that combines KB retrieval + conversation history + order lookups to answer customer queries on WhatsApp

The bot should behave like an intelligent, context-aware customer support agent — not a static FAQ bot.

---

## Finalized Architecture Decisions

| Decision | Choice | Reasoning |
|---|---|---|
| WhatsApp gateway | OpenWA (self-hosted) | Already decided by owner |
| Workflow engine | n8n | Owner already has n8n experience/instance |
| LLM & Embeddings Model | **Google Gemini** | Core AI provider for generating vectors and driving the chat agent |
| Vector store | **PostgreSQL + pgvector** (not Qdrant) | Knowledge base expected to stay under ~5,000 documents; avoids adding another Docker image; reuses Postgres expertise already on hand |
| Knowledge Base Format | **CSV Dataset Set** | Uses three specialized mock files (`customer_qnas.csv`, `product_info.csv`, `order_data.csv`) |
| Conversation history storage | **PostgreSQL** | Persistent, queryable, easy to back up |
| Project isolation | Separate root dir (`whatsapp-bot-openwa/`), separate `docker-compose.yml`, **shared Docker network** for cross-project communication | Keeps projects independently manageable while still able to talk to existing n8n/Postgres |
| Database security | **Isolated DB user strategy**: separate database + separate PostgreSQL user for the bot; strong unique passwords | Prevents one project's compromised credentials from exposing another project's data |
| n8n workflows | **Combined Workflow** | A single JSON file using `switch` nodes to route KB ingestion vs. Webhook handling vs. Inline Conversation Logging |

---

## Repository & Git Workflow

- **Two-branch strategy only** — `dev` and `main`. No feature branches.
- Owner works on `dev`; merges to `main` when stable.
- Commit convention: `[TYPE] Description`, e.g. `[SETUP]`, `[FEATURE]`, `[FIX]`, `[DOCS]`.
- Tracking files (`CONTEXT.md`, `PROJECT_STATE.md`, `CHANGELOG.md`) are updated automatically by the AI after each phase to maintain strict project state awareness.

---

## Working Agreement With the Owner

- **Do not write code or create files without explicit permission at each step.** The owner prefers a deliberate, step-by-step pace and gives explicit go-aheads.
- Architecture decisions should be finalized and agreed upon **before** implementation begins.
- After code/files are generated, always provide the **exact git commands + commit message** for that step.