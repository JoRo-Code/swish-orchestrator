#!/bin/bash

# Swish Play Buddy - Polyglot Microservices Startup Script
# This script starts all services in the correct order with proper dependency management

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}$1${NC}"
}

# Function to check if a port is in use
check_port() {
    lsof -i :$1 > /dev/null 2>&1
}

# Function to wait for service to be ready
wait_for_service() {
    local port=$1
    local service_name=$2
    local max_attempts=30
    local attempt=1
    
    print_status "Waiting for $service_name to be ready on port $port..."
    
    while [ $attempt -le $max_attempts ]; do
        if check_port $port; then
            print_status "$service_name is ready!"
            return 0
        fi
        sleep 1
        attempt=$((attempt + 1))
    done
    
    print_error "$service_name failed to start on port $port"
    return 1
}

# Function to check prerequisites
check_prerequisites() {
    print_header "🔍 Checking prerequisites..."
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js is not installed. Please install Node.js first."
        exit 1
    fi
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is not installed. Please install Python 3 first."
        exit 1
    fi
    
    # Check Go
    if ! command -v go &> /dev/null; then
        print_error "Go is not installed. Please install Go first."
        exit 1
    fi
    
    print_status "All prerequisites are installed ✅"
}

# Function to setup Python virtual environment
setup_python_env() {
    print_status "Setting up Python virtual environment..."
    cd ../demo-transaction-service
    
    if [ ! -d "venv" ]; then
        print_status "Creating Python virtual environment..."
        python3 -m venv venv
    fi
    
    source venv/bin/activate
    pip install -r requirements.txt > /dev/null 2>&1
    cd ../swish-orchestrator
}

# Function to install dependencies
install_dependencies() {
    print_header "📦 Installing dependencies..."
    
    # User Service (Node.js)
    print_status "Installing User Service dependencies..."
    cd ../demo-user-service
    npm install > /dev/null 2>&1
    cd ../swish-orchestrator
    
    # Frontend (React)
    print_status "Installing Frontend dependencies..."
    cd ../swish-play-buddy
    npm install > /dev/null 2>&1
    cd ../swish-orchestrator
    
    # Payment Service (Go)
    print_status "Installing Go dependencies..."
    cd ../demo-payment-service
    go mod tidy > /dev/null 2>&1
    cd ../swish-orchestrator
    
    # Transaction Service (Python)
    setup_python_env
    
    print_status "All dependencies installed ✅"
}

# Function to cleanup existing processes
cleanup_processes() {
    print_header "🧹 Cleaning up existing processes..."
    
    pkill -f "node.*3001" 2>/dev/null || true
    pkill -f "python.*main.py" 2>/dev/null || true
    pkill -f "go.*main.go" 2>/dev/null || true
    pkill -f "vite.*dev" 2>/dev/null || true
    
    # Kill processes on specific ports
    lsof -ti:3001 | xargs kill -9 2>/dev/null || true
    lsof -ti:3002 | xargs kill -9 2>/dev/null || true
    lsof -ti:3003 | xargs kill -9 2>/dev/null || true
    lsof -ti:5173 | xargs kill -9 2>/dev/null || true
    lsof -ti:8080 | xargs kill -9 2>/dev/null || true
    
    sleep 2
    print_status "Cleanup completed ✅"
}

# Function to start services
start_services() {
    print_header "🚀 Starting Swish Play Buddy services..."
    
    # Start User Service (Node.js - port 3001)
    print_status "Starting User Service (Node.js) on port 3001..."
    cd ../demo-user-service
    node index.js > ../swish-orchestrator/logs/user-service.log 2>&1 &
    USER_SERVICE_PID=$!
    cd ../swish-orchestrator
    wait_for_service 3001 "User Service"
    
    # Start Payment Service (Go - port 3002)
    print_status "Starting Payment Service (Go) on port 3002..."
    cd ../demo-payment-service
    go run main.go > ../swish-orchestrator/logs/payment-service.log 2>&1 &
    PAYMENT_SERVICE_PID=$!
    cd ../swish-orchestrator
    wait_for_service 3002 "Payment Service"
    
    # Start Transaction Service (Python - port 3003)
    print_status "Starting Transaction Service (Python) on port 3003..."
    cd ../demo-transaction-service
    source venv/bin/activate
    python3 main.py > ../swish-orchestrator/logs/transaction-service.log 2>&1 &
    TRANSACTION_SERVICE_PID=$!
    cd ../swish-orchestrator
    wait_for_service 3003 "Transaction Service"
    
    # Start Frontend (React - port 5173 or next available)
    print_status "Starting Frontend (React)..."
    cd ../swish-play-buddy
    npm run dev > ../swish-orchestrator/logs/frontend.log 2>&1 &
    FRONTEND_PID=$!
    cd ../swish-orchestrator
    
    # Wait a bit for frontend to find available port
    sleep 5
    
    # Try to determine which port the frontend is using
    FRONTEND_PORT=""
    for port in 5173 8080 8081 8082 8083; do
        if check_port $port; then
            FRONTEND_PORT=$port
            break
        fi
    done
    
    if [ -n "$FRONTEND_PORT" ]; then
        print_status "Frontend is ready on port $FRONTEND_PORT!"
    else
        print_warning "Frontend port detection failed, check logs/frontend.log"
    fi
}

# Function to display service status
show_status() {
    print_header "📊 Service Status"
    echo ""
    echo "🌐 Polyglot Microservices Architecture:"
    echo "  📱 Frontend (React):      http://localhost:${FRONTEND_PORT:-5173}"
    echo "  👤 User Service (Node.js): http://localhost:3001"
    echo "  💳 Payment Service (Go):   http://localhost:3002"
    echo "  📊 Transaction Service (Python): http://localhost:3003"
    echo ""
    echo "🔐 Test Credentials:"
    echo "  Phone: +46701234567"
    echo "  Password: password123"
    echo ""
    echo "📋 Health Check URLs:"
    echo "  User Service:    curl http://localhost:3001/health"
    echo "  Payment Service: curl http://localhost:3002/health"
    echo "  Transaction Service: curl http://localhost:3003/health"
    echo ""
    echo "📝 Logs are available in the logs/ directory"
    echo ""
    print_status "All services are running! Press Ctrl+C to stop all services"
}

# Function to cleanup on exit
cleanup_on_exit() {
    echo ""
    print_header "🛑 Stopping all services..."
    
    kill $USER_SERVICE_PID 2>/dev/null || true
    kill $PAYMENT_SERVICE_PID 2>/dev/null || true
    kill $TRANSACTION_SERVICE_PID 2>/dev/null || true
    kill $FRONTEND_PID 2>/dev/null || true
    
    # Additional cleanup
    pkill -f "node.*3001" 2>/dev/null || true
    pkill -f "python.*main.py" 2>/dev/null || true
    pkill -f "go.*main.go" 2>/dev/null || true
    pkill -f "vite.*dev" 2>/dev/null || true
    
    print_status "All services stopped ✅"
    exit 0
}

# Main execution
main() {
    # Create logs directory
    mkdir -p logs
    
    # Set trap to cleanup on script exit
    trap cleanup_on_exit SIGINT SIGTERM
    
    print_header "🎯 Swish Play Buddy - Polyglot Microservices"
    print_header "   Node.js + Go + Python + React"
    echo ""
    
    check_prerequisites
    cleanup_processes
    install_dependencies
    start_services
    show_status
    
    # Wait for user to stop the script
    wait
}

# Run main function
main "$@"
