# CONTEXT.md

> Purpose: This file gives any AI assistant (Claude, Claude Code, or another model) everything it needs to understand this project in one read, without re-explaining history. Read this first, then `PROJECT_STATE.md` for current status, then `CHANGELOG.md` only if deeper history is needed.

---

## Project Goal

Build a production-grade AI-powered WhatsApp chatbot using:
- **OpenWA** (self-hosted, open-source WhatsApp API gateway) instead of Meta's official WhatsApp Business API
- **n8n** for workflow orchestration
- A **knowledge base** (company FAQs, product info, policies from CSV/DOCX files) queried via a vector store
- **Persistent per-customer conversation history**
- An **AI Agent** (LLM-based) that combines KB retrieval + conversation history to answer customer queries on WhatsApp

The bot should behave like an intelligent, context-aware customer support agent — not a static FAQ bot.

---

## Why OpenWA Instead of Meta's Official API

- Self-hosted, no vendor lock-in, no per-message costs from Meta
- Full control over infrastructure and data
- REST API + webhook model similar in spirit to Meta's Cloud API, so the integration pattern (webhook in, HTTP send out) is familiar

---

## Owner's Environment (Important Constraints)

- Owner (Sadat) already runs **6 Docker containers** for a separate, unrelated project ("project-a"), including:
  - **2 PostgreSQL instances** (different purposes)
  - **1 n8n instance**
- This new project (**whatsapp-bot-openwa**) must **coexist cleanly** with that existing infrastructure — not disrupt it.
- Decision: new project gets its **own root directory and its own `docker-compose.yml`**. 
- **CRITICAL:** This project deliberately avoids running duplicate PostgreSQL and n8n containers. It interfaces with the existing instances via a **shared Docker network** (`shared-network`) created manually by the owner.

---

## Finalized Architecture Decisions

| Decision | Choice | Reasoning |
|---|---|---|
| WhatsApp gateway | OpenWA (self-hosted) | Already decided by owner |
| Workflow engine | n8n | Owner already has n8n experience/instance |
| Vector store | **PostgreSQL + pgvector** (not Qdrant) | Knowledge base expected to stay under ~5,000 documents; avoids adding another Docker image; reuses Postgres expertise already on hand |
| Conversation history storage | **PostgreSQL** | Persistent, queryable, easy to back up |
| Project isolation | Separate root dir (`whatsapp-bot-openwa/`), separate `docker-compose.yml`, **shared Docker network** for cross-project communication | Keeps projects independently manageable while still able to talk to existing n8n/Postgres |
| Database security | **Isolated DB user strategy**: separate database + separate PostgreSQL user for the bot; strong unique passwords | Prevents one project's compromised credentials from exposing another project's data, even on a shared Postgres instance |
| n8n workflows | **Three workflows** (see below) | Clean separation of concerns: ingestion vs. logging vs. live chat handling |

> Note: Earlier discussion explored Qdrant as a dedicated vector DB. Final decision is **pgvector on PostgreSQL**, conditional on the KB staying under ~5,000 documents. If the KB grows significantly beyond that, revisit Qdrant.

---

## The Three n8n Workflows

1. **KB Ingestion** (scheduled — weekly or monthly)
   - Reads CSV/DOCX files from local storage (`data/kb/`)
   - Chunks text, generates embeddings, stores/updates vectors in PostgreSQL (pgvector)

2. **WhatsApp Message Handler** (main bot, triggered by OpenWA webhook)
   - Receives incoming WhatsApp message via OpenWA webhook
   - Fetches recent conversation history for that customer (PostgreSQL)
   - Queries the knowledge base (pgvector similarity search)
   - AI Agent combines both into a response
   - Sends reply back via OpenWA REST API
   - Logs the exchange to conversation history

3. **Inline Conversation Logger**
   - Persists every message exchange (user message + bot reply) to PostgreSQL, keyed by `chatId`
   - Ensures conversation history survives restarts/crashes

---

## OpenWA API Reference (confirmed from OpenWA's own docs)

- **Send message:** `POST /api/sessions/{sessionId}/messages/send-text` with body `{ chatId, text }`, header `X-API-Key: <operator-role key>`
- **Incoming webhook payload:**
  ```json
  {
    "event": "message.received",
    "timestamp": "...",
    "sessionId": "...",
    "idempotencyKey": "...",
    "deliveryId": "...",
    "data": { "id": "...", "chatId": "...", "from": "...", "body": "...", "type": "text", "timestamp": 1234567890 }
  }