#!/bin/bash

# Swish Play Buddy - Quick Launch Script
# This script starts all services and opens the app in your browser

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

print_header "🚀 Launching Swish Play Buddy..."

# Start all services in the background
print_status "Starting all services..."
./start-services.sh > /dev/null 2>&1 &
START_PID=$!

# Wait for services to be ready
print_status "Waiting for services to start..."
sleep 15

# Try to find which port the frontend is using
FRONTEND_PORT=""
for port in 8080 8081 8082 5173; do
    if lsof -i :$port > /dev/null 2>&1; then
        FRONTEND_PORT=$port
        break
    fi
done

if [ -n "$FRONTEND_PORT" ]; then
    print_status "Opening Swish Play Buddy in your browser..."
    print_status "Frontend URL: http://localhost:$FRONTEND_PORT"
    
    # Open in browser (works on macOS, Linux, and Windows)
    if command -v open > /dev/null 2>&1; then
        # macOS
        open "http://localhost:$FRONTEND_PORT"
    elif command -v xdg-open > /dev/null 2>&1; then
        # Linux
        xdg-open "http://localhost:$FRONTEND_PORT"
    elif command -v start > /dev/null 2>&1; then
        # Windows
        start "http://localhost:$FRONTEND_PORT"
    else
        print_status "Please open http://localhost:$FRONTEND_PORT in your browser"
    fi
    
    echo ""
    print_header "🎉 Swish Play Buddy is ready!"
    echo ""
    echo "🔐 Test Credentials:"
    echo "  Phone: +46701234567"
    echo "  Password: password123"
    echo ""
    echo "📊 Service URLs:"
    echo "  Frontend: http://localhost:$FRONTEND_PORT"
    echo "  User Service: http://localhost:3001"
    echo "  Payment Service: http://localhost:3002"
    echo "  Transaction Service: http://localhost:3003"
    echo ""
    echo "🛑 To stop all services, run: ./stop-services.sh"
    echo "🏥 To check service health, run: ./health-check.sh"
    
else
    echo "❌ Frontend failed to start. Check logs/frontend.log for details."
    echo "💡 Try running ./start-services.sh manually for more detailed output."
fi
