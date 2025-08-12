# Swish Play Buddy - Orchestrator

A comprehensive orchestration system for the Swish Play Buddy polyglot microservices application. This orchestrator manages the startup, shutdown, and health monitoring of all services in the correct order with proper dependency management.

## 🏗️ Architecture Overview

Swish Play Buddy is a polyglot microservices application demonstrating modern distributed architecture:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │  User Service   │    │ Payment Service │    │Transaction Svc  │
│   (React)       │    │   (Node.js)     │    │     (Go)        │    │   (Python)      │
│   Port: 5173    │    │   Port: 3001    │    │   Port: 3002    │    │   Port: 3003    │
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │                       │
         └───────────────────────┼───────────────────────┼───────────────────────┘
                                 │                       │
                          HTTP REST APIs            HTTP REST APIs
```

## 🚀 Quick Start

### Prerequisites

Ensure you have the following installed:
- **Node.js** (v16 or higher) - For user service and frontend
- **Python 3** (v3.8 or higher) - For transaction service
- **Go** (v1.19 or higher) - For payment service

### One-Command Launch

```bash
./launch-app.sh
```

This single command will:
1. Check all prerequisites
2. Install all dependencies
3. Start all services in the correct order
4. Open the app in your browser automatically

### Manual Control

If you prefer manual control over the services:

```bash
# Start all services
./start-services.sh

# Check service health
./health-check.sh

# Stop all services
./stop-services.sh
```

## 📋 Scripts Reference

### `launch-app.sh`
**Purpose**: One-click application launcher
- Starts all services in background
- Automatically opens browser
- Provides quick feedback on startup status

**Usage**:
```bash
./launch-app.sh
```

### `start-services.sh`
**Purpose**: Comprehensive service startup with dependency management
- Checks prerequisites (Node.js, Python, Go)
- Installs/updates all dependencies
- Starts services in correct order
- Waits for each service to be ready before starting the next
- Provides detailed logging and status information

**Usage**:
```bash
./start-services.sh
```

**Features**:
- ✅ Automatic dependency installation
- ✅ Port conflict detection and cleanup
- ✅ Service health checking
- ✅ Detailed logging to `logs/` directory
- ✅ Graceful shutdown on Ctrl+C

### `stop-services.sh`
**Purpose**: Clean shutdown of all services
- Stops all services gracefully
- Cleans up processes and ports
- Removes temporary files

**Usage**:
```bash
./stop-services.sh
```

### `health-check.sh`
**Purpose**: Verify all services are running correctly
- Checks each service endpoint
- Reports service status
- Useful for monitoring and debugging

**Usage**:
```bash
./health-check.sh
```

## 🔧 Configuration

### Service Ports
- **Frontend (React)**: 5173 (or next available: 8080, 8081, 8082, 8083)
- **User Service (Node.js)**: 3001
- **Payment Service (Go)**: 3002
- **Transaction Service (Python)**: 3003

### Test Credentials
```
Phone: +46701234567
Password: password123
```

### Service URLs
- **Frontend**: http://localhost:5173
- **User Service**: http://localhost:3001
- **Payment Service**: http://localhost:3002
- **Transaction Service**: http://localhost:3003

### Health Check Endpoints
- **User Service**: `curl http://localhost:3001/health`
- **Payment Service**: `curl http://localhost:3002/health`
- **Transaction Service**: `curl http://localhost:3003/health`

## 📁 Directory Structure

```
swish-orchestrator/
├── README.md              # This file
├── launch-app.sh          # One-click launcher
├── start-services.sh      # Comprehensive service startup
├── stop-services.sh       # Service shutdown
├── health-check.sh        # Health monitoring
├── logs/                  # Service logs (auto-created)
│   ├── user-service.log
│   ├── payment-service.log
│   ├── transaction-service.log
│   └── frontend.log
└── (other config files)

../demo-user-service/      # Node.js user management service
../demo-payment-service/   # Go payment processing service
../demo-transaction-service/ # Python transaction service
../swish-play-buddy/       # React frontend application
```

## 🐛 Troubleshooting

### Common Issues

**Services won't start**
```bash
# Check if ports are already in use
lsof -i :3001 -i :3002 -i :3003 -i :5173

# Force cleanup
./stop-services.sh
```

**Frontend not loading**
```bash
# Check frontend logs
cat logs/frontend.log

# Try different port
cd ../swish-play-buddy
npm run dev -- --port 8080
```

**Python service issues**
```bash
# Recreate virtual environment
cd ../demo-transaction-service
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

**Node.js service issues**
```bash
# Reinstall dependencies
cd ../demo-user-service
rm -rf node_modules package-lock.json
npm install
```

**Go service issues**
```bash
# Clean and rebuild
cd ../demo-payment-service
go clean -cache
go mod tidy
```

### Log Files

All services log to the `logs/` directory:
- `user-service.log` - Node.js user service logs
- `payment-service.log` - Go payment service logs
- `transaction-service.log` - Python transaction service logs
- `frontend.log` - React frontend build/dev logs

### Port Conflicts

If you encounter port conflicts, the scripts will attempt to:
1. Kill existing processes on required ports
2. Find alternative ports for the frontend
3. Report which ports are being used

## 🔄 Development Workflow

### Starting Development
```bash
# Full startup with auto-browser launch
./launch-app.sh

# Or manual startup with detailed output
./start-services.sh
```

### Making Changes
1. Edit code in respective service directories
2. Services will auto-reload (Node.js, Python) or need restart (Go)
3. Frontend has hot-reload enabled

### Testing
```bash
# Check all services are healthy
./health-check.sh

# View logs for debugging
tail -f logs/user-service.log
tail -f logs/transaction-service.log
tail -f logs/payment-service.log
tail -f logs/frontend.log
```

### Stopping Development
```bash
# Clean shutdown
./stop-services.sh

# Or Ctrl+C if using start-services.sh directly
```

## 🛠️ Recent Fixes

### Floating-Point Precision Issues (Fixed)
The orchestrator now includes fixes for transaction amount precision issues:

- **User Service**: Added proper number validation and rounding in balance updates
- **Transaction Service**: Enhanced amount processing with explicit float conversion
- **Frontend**: Added client-side amount validation and cleaning

**Before**: Entering 100 kr might send 93 kr or entering 5000 kr might send 4999 kr
**After**: Exact amounts are processed correctly with proper precision handling

## 📊 Monitoring

### Service Status
```bash
# Quick health check
./health-check.sh

# Detailed process monitoring
ps aux | grep -E "(node|python|go).*(:3001|:3002|:3003)"

# Port monitoring
lsof -i :3001 -i :3002 -i :3003 -i :5173
```

### Performance Monitoring
```bash
# Monitor resource usage
top -p $(pgrep -f "node.*3001") -p $(pgrep -f "python.*main.py") -p $(pgrep -f "go.*main.go")
```

## 🤝 Contributing

When adding new services or modifying existing ones:

1. Update the appropriate startup script
2. Add health check endpoints
3. Update this README
4. Test the full startup/shutdown cycle
5. Ensure proper logging is implemented

## 📝 License

This orchestrator is part of the Swish Play Buddy project and follows the same licensing terms.
