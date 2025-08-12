#!/bin/bash

# Swish Play Buddy - Stop All Services Script

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_header() {
    echo -e "${BLUE}$1${NC}"
}

print_header "🛑 Stopping Swish Play Buddy Services"

# Kill processes by name patterns
print_status "Stopping services by process name..."
pkill -f "node.*3001" 2>/dev/null || true
pkill -f "python.*main.py" 2>/dev/null || true
pkill -f "go.*main.go" 2>/dev/null || true
pkill -f "vite.*dev" 2>/dev/null || true

# Kill processes on specific ports
print_status "Stopping services by port..."
lsof -ti:3001 | xargs kill -9 2>/dev/null || true
lsof -ti:3002 | xargs kill -9 2>/dev/null || true
lsof -ti:3003 | xargs kill -9 2>/dev/null || true
lsof -ti:5173 | xargs kill -9 2>/dev/null || true
lsof -ti:8080 | xargs kill -9 2>/dev/null || true
lsof -ti:8081 | xargs kill -9 2>/dev/null || true
lsof -ti:8082 | xargs kill -9 2>/dev/null || true

print_status "All services stopped ✅"
