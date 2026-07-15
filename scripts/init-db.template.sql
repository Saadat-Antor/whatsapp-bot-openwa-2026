-- =============================================================================
-- scripts/init-db.template.sql
-- DO NOT RUN DIRECTLY. This is a template. 
-- Run setup.sh to generate the actual init-db.sql file.
-- =============================================================================

-- 1. Create the isolated user
CREATE USER openwa_bot_user WITH PASSWORD '__DB_PASSWORD__';

-- 2. Create the dedicated database owned by the new user
CREATE DATABASE openwa_bot_db OWNER openwa_bot_user;

-- 3. Connect to the new database
\c openwa_bot_db

-- 4. Enable the pgvector extension (required for the knowledge base)
CREATE EXTENSION IF NOT EXISTS vector;

-- 5. Lock down access: revoke default public access and explicitly grant to our user
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO openwa_bot_user;

-- =============================================================================
-- 6. Create application tables (knowledge base, orders, conversations)
-- =============================================================================

-- Table: kb_embeddings
-- Stores chunked knowledge base content with pgvector embeddings
-- Used for semantic search in the AI Agent
CREATE TABLE IF NOT EXISTS kb_embeddings (
  id SERIAL PRIMARY KEY,
  content TEXT NOT NULL,
  metadata JSONB DEFAULT '{}',
  embedding vector(1536),  -- OpenAI text-embedding-3-small produces 1536-dim vectors
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index on embedding for fast vector similarity search
CREATE INDEX IF NOT EXISTS idx_kb_embeddings_embedding ON kb_embeddings USING ivfflat (embedding vector_cosine_ops)
  WITH (lists = 100);

-- Table: orders
-- Relational storage of customer order data (exact lookups by phone number)
-- Columns derived from order_data.csv: OrderID, CustomerPhone, Status, TotalAmount, ItemsOrdered, TrackingNumber
CREATE TABLE IF NOT EXISTS orders (
  id SERIAL PRIMARY KEY,
  order_id VARCHAR(50) NOT NULL,
  customer_phone VARCHAR(20) NOT NULL,
  status VARCHAR(50),
  total_amount DECIMAL(10, 2),
  items_ordered TEXT,
  tracking_number VARCHAR(100),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(order_id, customer_phone)
);

-- Index for fast lookups by phone number (used by the "returning customer" detection)
CREATE INDEX IF NOT EXISTS idx_orders_customer_phone ON orders(customer_phone);

-- Table: conversations
-- Persistent per-customer conversation history
-- Every user message + bot reply gets logged here
CREATE TABLE IF NOT EXISTS conversations (
  id SERIAL PRIMARY KEY,
  chat_id VARCHAR(100) NOT NULL,
  from_number VARCHAR(20),
  session_id VARCHAR(100),
  user_message TEXT,
  bot_reply TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for fast queries by chat_id (used to fetch conversation history)
CREATE INDEX IF NOT EXISTS idx_conversations_chat_id ON conversations(chat_id);
CREATE INDEX IF NOT EXISTS idx_conversations_created_at ON conversations(created_at);

-- =============================================================================
-- 7. Grant permissions to openwa_bot_user on all tables
-- =============================================================================
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO openwa_bot_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO openwa_bot_user;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO openwa_bot_user;