#!/bin/bash
# Linux/Mac startup script for DDoS Detection System
# Run: bash startup.sh [command]

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$PROJECT_DIR/backend"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}"
echo "===================================================="
echo "DDoS Detection & Mitigation System - Linux/Mac"
echo "===================================================="
echo -e "${NC}"

# Check Python
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}ERROR: Python 3 not found${NC}"
    exit 1
fi

# Create venv if needed
if [ ! -d "venv" ]; then
    echo -e "${YELLOW}Creating virtual environment...${NC}"
    python3 -m venv venv
fi

# Activate venv
source venv/bin/activate

# Install command
if [ "$1" = "install" ]; then
    echo -e "${YELLOW}Installing dependencies...${NC}"
    cd "$BACKEND_DIR"
    pip install --upgrade pip
    pip install -r requirements.txt
    cd "$PROJECT_DIR"
    echo -e "${GREEN}Dependencies installed${NC}"
    exit 0
fi

# Backend command
if [ "$1" = "backend" ] || [ -z "$1" ]; then
    echo -e "${YELLOW}Starting DDoS Detection Backend...${NC}"
    echo "API: http://localhost:8000"
    echo "Dashboard: file://$PROJECT_DIR/try/dashboard.html"
    echo ""
    cd "$BACKEND_DIR"
    uvicorn backend:app --reload --host 0.0.0.0 --port 8000
    exit 0
fi

# Simulator command
if [ "$1" = "simulator" ]; then
    ATTACK_TYPE="${2:-SYN_FLOOD}"
    DURATION="${3:-60}"
    echo -e "${YELLOW}Starting attack simulator...${NC}"
    echo "Attack Type: $ATTACK_TYPE"
    echo "Duration: ${DURATION}s"
    echo ""
    cd "$BACKEND_DIR"
    python3 -m simulator "$ATTACK_TYPE" "$DURATION"
    exit 0
fi

# Test command
if [ "$1" = "test" ]; then
    echo -e "${YELLOW}Running tests...${NC}"
    cd "$PROJECT_DIR"
    pytest tests/ -v --tb=short
    exit 0
fi

# Clean command
if [ "$1" = "clean" ]; then
    echo -e "${YELLOW}Cleaning up...${NC}"
    cd "$BACKEND_DIR"
    rm -f *.db *.db-wal *.db-shm
    rm -rf __pycache__
    find . -type d -name __pycache__ -exec rm -rf {} +
    echo -e "${GREEN}Cleanup complete${NC}"
    exit 0
fi

# Show usage
echo -e "${YELLOW}Usage:${NC}"
echo "  $0                              Start backend server"
echo "  $0 backend                      Start backend server"
echo "  $0 simulator [TYPE] [DURATION]  Run attack simulator"
echo "  $0 install                      Install dependencies"
echo "  $0 test                         Run tests"
echo "  $0 clean                        Clean up databases"
echo ""
echo -e "${YELLOW}Attack types:${NC}"
echo "  - SYN_FLOOD (default)"
echo "  - UDP_FLOOD"
echo "  - HTTP_FLOOD"
echo "  - PORT_SCAN"
echo "  - BOTNET"
echo "  - RANDOM"
echo ""
echo -e "${YELLOW}Example:${NC}"
echo "  $0 simulator SYN_FLOOD 60"
