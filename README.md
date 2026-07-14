# whatsapp-bot-openwa

AI-powered WhatsApp customer support chatbot built on **OpenWA** (self-hosted WhatsApp API gateway) and **n8n** (workflow automation), with a knowledge-base-backed AI Agent and persistent per-customer conversation history.

> For full project context, architecture decisions, and working agreements, see [`CONTEXT.md`](./CONTEXT.md).
> For current progress, see [`PROJECT_STATE.md`](./PROJECT_STATE.md).
> For a dated history of changes, see [`CHANGELOG.md`](./CHANGELOG.md).

---

## What This Project Does

- Replaces Meta's official WhatsApp Business API with **OpenWA**, a self-hosted, open-source gateway
- Uses **n8n** to orchestrate three workflows:
  1. Scheduled ingestion of a company knowledge base (CSV/DOCX → vector store)
  2. A main message handler that answers customer queries using an AI Agent (LLM + knowledge base + conversation history)
  3. Persistent logging of every conversation exchange
- Stores knowledge base vectors and conversation history in **PostgreSQL** (with `pgvector`)
- Designed to coexist safely alongside other Docker projects on the same host, via isolated database users and a shared Docker network

---

## Project Structure

```
whatsapp-bot-openwa/
├── docker-compose.yml       # Infrastructure: OpenWA, PostgreSQL usage, networking
├── .env / .env.example      # Environment variables
├── data/
│   ├── kb/                  # Knowledge base source files (CSV/DOCX)
│   ├── openwa/               # OpenWA persistent session data
│   └── n8n/                  # n8n persistent data
├── scripts/
│   ├── init-db.sql           # Isolated DB user/database setup
│   ├── setup.sh               # One-shot bootstrap script
│   └── backup.sh
├── n8n/workflows/            # Exported n8n workflow JSONs
├── docs/                     # Setup, API reference, troubleshooting, architecture docs
├── config/                    # Service-specific env configs
├── logs/
├── CONTEXT.md
├── PROJECT_STATE.md
└── CHANGELOG.md
```

---

## Status

This project is in the **setup / pre-implementation stage**. See [`PROJECT_STATE.md`](./PROJECT_STATE.md) for the current phase and next steps.

---

## Git Workflow

- Two branches only: `dev` (development) and `main` (production-ready).
- No feature branches.
- Commit convention: `[TYPE] Description` — e.g. `[SETUP]`, `[FEATURE]`, `[FIX]`, `[DOCS]`.

---

## Setup

Detailed setup instructions will live in `docs/SETUP.md` once infrastructure files are generated (Phase 2).