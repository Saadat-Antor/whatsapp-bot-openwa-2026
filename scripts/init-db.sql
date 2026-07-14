-- =============================================================================
-- scripts/init-db.sql
-- Run this on your EXISTING PostgreSQL instance to create an isolated
-- database and user for the whatsapp-bot-openwa project.
-- =============================================================================

-- 1. Create the isolated user (replace with your secure password)
CREATE USER openwa_bot_user WITH PASSWORD 'your_secure_password_here';

-- 2. Create the dedicated database owned by the new user
CREATE DATABASE openwa_bot_db OWNER openwa_bot_user;

-- 3. Connect to the new database
\c openwa_bot_db

-- 4. Enable the pgvector extension (required for the knowledge base)
CREATE EXTENSION IF NOT EXISTS vector;

-- 5. Lock down access: revoke default public access and explicitly grant to our user
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO openwa_bot_user;