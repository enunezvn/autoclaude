#!/bin/bash

# Auto Claude Startup Script
# This script checks dependencies and starts Auto Claude Desktop UI

set -e

echo "🚀 Starting Auto Claude..."
echo ""

# Get the script's directory (Auto-Claude root)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Check if Docker is running
echo "✓ Checking Docker..."
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker is not running"
    echo "   Please start Docker Desktop and try again"
    exit 1
fi
echo "  Docker is running"

# Check if FalkorDB container is running
echo ""
echo "✓ Checking FalkorDB (Memory Layer)..."
if ! docker ps --format '{{.Names}}' | grep -q "auto-claude-falkordb"; then
    echo "  FalkorDB not running, starting it..."
    docker-compose up -d falkordb
    echo "  Waiting for FalkorDB to be ready..."
    sleep 3
else
    echo "  FalkorDB is running"
fi

# Check if Python venv exists
echo ""
echo "✓ Checking Python environment..."
if [ ! -d "auto-claude/.venv" ]; then
    echo "❌ Error: Python virtual environment not found"
    echo "   Run: cd auto-claude && uv venv && uv pip install -r requirements.txt"
    exit 1
fi
echo "  Python environment exists"

# Check if node_modules exists in UI
echo ""
echo "✓ Checking Desktop UI dependencies..."
if [ ! -d "auto-claude-ui/node_modules" ]; then
    echo "❌ Error: Desktop UI dependencies not installed"
    echo "   Run: cd auto-claude-ui && npm install"
    exit 1
fi
echo "  Desktop UI dependencies installed"

# Check if UI is built
echo ""
echo "✓ Checking Desktop UI build..."
if [ ! -d "auto-claude-ui/out" ]; then
    echo "⚠️  Desktop UI not built, building now..."
    cd auto-claude-ui
    npm run build
    cd ..
else
    echo "  Desktop UI is built"
fi

# Start the application
echo ""
echo "✓ All checks passed!"
echo ""
echo "🎉 Launching Auto Claude Desktop UI..."
echo ""

cd auto-claude-ui
npm run start
