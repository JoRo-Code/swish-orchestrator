#!/bin/bash

# Swish Play Buddy - Health Check Script

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_header() {
    echo -e "${BLUE}$1${NC}"
}

# Function to check service health
check_service() {
    local service_name=$1
    local url=$2
    local port=$3
    
    # Check if port is open
    if ! lsof -i :$port > /dev/null 2>&1; then
        print_error "$service_name is not running (port $port not open)"
        return 1
    fi
    
    # Check HTTP health endpoint
    if curl -s -f "$url" > /dev/null 2>&1; then
        print_status "$service_name is healthy ✅"
        return 0
    else
        print_warning "$service_name is running but health check failed ⚠️"
        return 1
    fi
}

print_header "🏥 Swish Play Buddy - Health Check"
echo ""

# Check each service
check_service "User Service (Node.js)" "http://localhost:3001/health" 3001
check_service "Payment Service (Go)" "http://localhost:3002/health" 3002
check_service "Transaction Service (Python)" "http://localhost:3003/health" 3003

# Check frontend (no health endpoint, just port)
if lsof -i :5173 > /dev/null 2>&1; then
    print_status "Frontend (React) is running on port 5173 ✅"
elif lsof -i :8080 > /dev/null 2>&1; then
    print_status "Frontend (React) is running on port 8080 ✅"
elif lsof -i :8081 > /dev/null 2>&1; then
    print_status "Frontend (React) is running on port 8081 ✅"
elif lsof -i :8082 > /dev/null 2>&1; then
    print_status "Frontend (React) is running on port 8082 ✅"
else
    print_error "Frontend (React) is not running"
fi

echo ""
print_header "📊 Port Status"
echo "Port 3001 (User Service):    $(lsof -i :3001 > /dev/null 2>&1 && echo "✅ Open" || echo "❌ Closed")"
echo "Port 3002 (Payment Service): $(lsof -i :3002 > /dev/null 2>&1 && echo "✅ Open" || echo "❌ Closed")"
echo "Port 3003 (Transaction Service): $(lsof -i :3003 > /dev/null 2>&1 && echo "✅ Open" || echo "❌ Closed")"
echo "Port 5173 (Frontend):        $(lsof -i :5173 > /dev/null 2>&1 && echo "✅ Open" || echo "❌ Closed")"
echo "Port 8080 (Frontend Alt):    $(lsof -i :8080 > /dev/null 2>&1 && echo "✅ Open" || echo "❌ Closed")"

echo ""
print_header "🔗 Service URLs"
echo "Frontend:     http://localhost:$(lsof -i :5173 > /dev/null 2>&1 && echo "5173" || lsof -i :8080 > /dev/null 2>&1 && echo "8080" || lsof -i :8081 > /dev/null 2>&1 && echo "8081" || lsof -i :8082 > /dev/null 2>&1 && echo "8082" || echo "N/A")"
echo "User Service: http://localhost:3001"
echo "Payment:      http://localhost:3002"
echo "Transactions: http://localhost:3003"
