#!/bin/bash
# Quick setup script for Bhikku Registry API

set -e

echo "🛕 Bhikku Registry API - Quick Setup"
echo "====================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if .env exists
if [ -f .env ]; then
    echo -e "${YELLOW}⚠️  .env file already exists${NC}"
    read -p "Do you want to overwrite it? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Skipping .env creation"
    else
        cp .env.example .env
        echo -e "${GREEN}✓${NC} Created .env from .env.example"
    fi
else
    cp .env.example .env
    echo -e "${GREEN}✓${NC} Created .env from .env.example"
fi

# Generate SECRET_KEY
echo ""
echo "Generating SECRET_KEY..."
if command -v openssl &> /dev/null; then
    SECRET_KEY=$(openssl rand -hex 32)
    # Update .env file
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/SECRET_KEY=.*/SECRET_KEY=$SECRET_KEY/" .env
    else
        # Linux
        sed -i "s/SECRET_KEY=.*/SECRET_KEY=$SECRET_KEY/" .env
    fi
    echo -e "${GREEN}✓${NC} Generated and saved SECRET_KEY"
else
    echo -e "${YELLOW}⚠️  openssl not found. Please manually update SECRET_KEY in .env${NC}"
fi

# Create alembic versions directory
echo ""
echo "Setting up Alembic..."
mkdir -p alembic/versions
echo -e "${GREEN}✓${NC} Created alembic/versions directory"

# Make start.sh executable
if [ -f start.sh ]; then
    chmod +x start.sh
    echo -e "${GREEN}✓${NC} Made start.sh executable"
fi

# Check for Docker
echo ""
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✓${NC} Docker is installed"
    
    read -p "Do you want to start with Docker? (Y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        echo ""
        echo "Starting Docker containers..."
        docker compose up -d --build
        
        echo ""
        echo "Waiting for database to be ready..."
        sleep 5
        
        echo "Running migrations..."
        docker compose exec -T api alembic upgrade head
        
        echo ""
        read -p "Do you want to seed initial data (roles)? (Y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
            docker compose exec -T api python -m app.db.seed
        fi
        
        echo ""
        echo -e "${GREEN}✓${NC} Setup complete!"
        echo ""
        echo "Your API is running at:"
        echo "  • API: http://localhost:8000"
        echo "  • Docs: http://localhost:8000/docs"
        echo "  • Health: http://localhost:8000/health"
    fi
else
    echo -e "${YELLOW}⚠️  Docker not found${NC}"
    echo ""
    echo "For local development without Docker:"
    echo "  1. Create a virtual environment: python -m venv .venv"
    echo "  2. Activate it: source .venv/bin/activate"
    echo "  3. Install dependencies: pip install -r requirements.txt"
    echo "  4. Run migrations: alembic upgrade head"
    echo "  5. Seed data: python -m app.db.seed"
    echo "  6. Start server: uvicorn app.main:app --reload"
fi

echo ""
echo -e "${GREEN}Setup complete!${NC}"
echo ""
echo "Next steps for Railway deployment:"
echo "  1. Review and update .env with your settings"
echo "  2. git add ."
echo "  3. git commit -m 'Initial setup'"
echo "  4. git push origin main"
echo "  5. Follow RAILWAY_DEPLOYMENT.md for deployment"
echo ""