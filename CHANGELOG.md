# CHANGELOG.md

> Dated log of decisions, changes, and rationale. Newest entries at the top. Keep entries concise — full context lives in `CONTEXT.md`.

---

## [2026-07-15] — Phase 4: n8n Workflows (Combined)
### Added
- `n8n/workflows/whatsapp-bot-combined-workflow.json` — single n8n workflow file containing all three workflows as routed branches:
  - **KB Ingestion branch** (Schedule Trigger, weekly Mon 2am): routes `customer_qnas.csv`/`product_info.csv` through chunking + Google Gemini embeddings into pgvector (`kb_embeddings` table); routes `order_data.csv` directly into a relational `orders` table (exact-match lookups, not semantic search).
  - **Message Handler branch** (Webhook Trigger): filters incoming OpenWA events to text messages only, fetches conversation history, looks up the sender in `orders` to detect returning vs. new customers, merges all context into the AI Agent (which has the pgvector KB wired in as a tool), sends the reply via OpenWA, and logs the exchange — all in one branch.
- Three `n8n-nodes-base.switch` nodes used for routing: KB file type, incoming event filtering, and returning-vs-new customer context.

### Decisions Finalized
- **AI Provider:** Confirmed Google Gemini as the core model for embeddings and agentic operations (corrected from OpenAI).
- Order data is stored **relationally**, not embedded into the vector store — order lookups need exact phone-number matching, not semantic similarity.
- "Immediately fetch conversion data for returning customers" implemented as: on every incoming message, look up the sender's phone number in `orders` before the AI Agent responds; inject a returning/new customer context string either way.
- Conversation logging is inline in the message handler branch rather than a separate workflow, since it always follows immediately after sending the reply.

### Assumptions Needing Verification (see Setup Notes sticky note in the JSON)
- File paths assume `/data/kb/*.csv` inside the OpenWA/n8n container mount — adjust if different.

### Status
- Phase 4 workflow JSON generated, CSV columns verified against mock files, DB templates extended. 

### Next Steps
- [ ] Initialize database via `setup.sh` + `docker exec`
- [ ] Import workflow into n8n, wire up credentials (Gemini, Postgres, OpenWA API Key)
- [ ] Begin Phase 5: Testing & Validation

---

## [2026-07-15] — Phase 3: Knowledge Base Prep
*(... Content remains identical to previous state ...)*