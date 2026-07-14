#!/bin/bash
# =============================================================================
# scripts/setup.sh
# Bootstrap script to prepare the local environment for whatsapp-bot-openwa
# =============================================================================

echo "🚀 Setting up whatsapp-bot-openwa environment..."

# 1. Create necessary directories for Docker volumes
echo "📁 Creating data and log directories..."
mkdir -p data/kb
mkdir -p data/openwa
mkdir -p data/n8n
mkdir -p logs

# 2. Set permissive access for the containers (can be tightened later)
echo "🔒 Setting directory permissions..."
chmod -R 755 data
chmod -R 755 logs

# 3. Ensure .env file exists
if [ ! -f .env ]; then
    echo "📄 Creating .env from .env.example..."
    if [ -f .env.example ]; then
        cp .env.example .env
        echo "⚠️  Action Required: Please update the .env file with your specific credentials."
    else
        echo "❌ .env.example not found. Skipping .env creation."
    fi
else
    echo "✅ .env already exists."
fi

# 4. Generate the database initialization script
echo "⚙️  Generating init-db.sql from template..."
if [ -f .env ] && [ -f scripts/init-db.template.sql ]; then
    # Extract the password from .env (ignoring comments)
    DB_PASSWORD=$(grep -v '^#' .env | grep -E '^OPENWA_DB_PASSWORD=' | cut -d '=' -f2 | tr -d '"' | tr -d "'")
    
    if [ -n "$DB_PASSWORD" ]; then
        sed "s/__DB_PASSWORD__/$DB_PASSWORD/g" scripts/init-db.template.sql > scripts/init-db.sql
        echo "✅ scripts/init-db.sql generated successfully (ignored by git)."
    else
        echo "⚠️  OPENWA_DB_PASSWORD not found in .env. Please add it and re-run setup.sh."
    fi
else
    echo "⚠️  Could not generate init-db.sql (missing .env or template)."
fi

echo "======================================================================="
echo "✅ Setup script complete."
echo "Reminder: Ensure you have manually created the shared network via:"
echo "docker network create shared-network"
echo "======================================================================="