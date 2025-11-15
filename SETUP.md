# Aegis Shield - Complete Setup Guide

## Overview

Aegis Shield is a comprehensive DDoS detection and prevention system with:
- **Frontend**: Next.js dashboard with real-time visualization
- **Backend**: FastAPI with River ML, Redis, SQLite, Prometheus
- **Protection**: Nginx rate limiting, IPTables blocking, ML-based detection

## Architecture

```
┌─────────────────┐
│   Kali Linux    │  (Attack Simulation)
│   VirtualBox    │
└────────┬────────┘
         │
         │ DDoS Attack
         ▼
┌─────────────────┐
│   Nginx Gateway │  (Rate Limiting)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   FastAPI       │  (ML Detection)
│   Backend       │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌────────┐ ┌────────┐
│ Redis  │ │ SQLite │
│        │ │ (WAL)  │
└────────┘ └────────┘
    │
    ▼
┌─────────────────┐
│   IPTables      │  (IP Blocking)
└─────────────────┘
```

## Prerequisites

### System Requirements
- **OS**: Kali Linux (VirtualBox)
- **Python**: 3.10+
- **Node.js**: 18+
- **Redis**: Latest
- **Nginx**: Latest (optional)
- **Root/Admin**: Required for packet capture and iptables

### Software Installation

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Python and pip
sudo apt install python3 python3-pip python3-venv -y

# Install Node.js (if not installed)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Install Redis
sudo apt install redis-server -y
sudo systemctl enable redis-server
sudo systemctl start redis-server

# Install Nginx (optional)
sudo apt install nginx -y
```

## Backend Setup

### 1. Navigate to Backend Directory

```bash
cd backend
```

### 2. Create Virtual Environment

```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

### 4. Configure Environment

```bash
cp .env.example .env
# Edit .env with your settings
```

Key settings:
- `CAPTURE_INTERFACE`: Your network interface (e.g., `eth0`, `enp0s3`)
- `ADMIN_SECRET_KEY`: Strong secret key for admin API
- `REDIS_HOST`: Redis server address

### 5. Create Directories

```bash
mkdir -p db models logs
```

### 6. Start Backend

```bash
# Development
python main.py

# Or with uvicorn
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

Backend will be available at: `http://localhost:8000`

## Frontend Setup

### 1. Navigate to Project Root

```bash
cd ..  # Back to project root
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Configure Environment

Create `.env.local`:
```env
NEXT_PUBLIC_API_URL=http://localhost:8000
```

### 4. Start Frontend

```bash
npm run dev
```

Frontend will be available at: `http://localhost:3000`

## Nginx Configuration (Optional)

### 1. Copy Configuration

```bash
sudo cp backend/nginx.conf /etc/nginx/sites-available/aegis-shield
sudo ln -s /etc/nginx/sites-available/aegis-shield /etc/nginx/sites-enabled/
```

### 2. Test and Reload

```bash
sudo nginx -t
sudo systemctl reload nginx
```

## Running the System

### 1. Start Redis

```bash
sudo systemctl start redis-server
# Or manually
redis-server
```

### 2. Start Backend (with sudo for packet capture)

```bash
cd backend
source venv/bin/activate
sudo python main.py  # Requires root for packet capture
```

### 3. Start Frontend

```bash
npm run dev
```

### 4. Access Dashboard

Open browser: `http://localhost:3000`

## Attack Simulation

### From Kali Linux VM

1. Install attack tools:
```bash
sudo apt install hping3 nmap -y
```

2. Simulate DDoS attack:
```bash
# SYN flood attack
sudo hping3 -S -p 80 --flood 192.168.1.100

# UDP flood
sudo hping3 --udp -p 80 --flood 192.168.1.100

# Multiple IPs (distributed)
for i in {1..10}; do
  sudo hping3 -S -p 80 --flood 192.168.1.100 &
done
```

Replace `192.168.1.100` with your target IP.

## Monitoring

### Prometheus Metrics

Access at: `http://localhost:9090/metrics`

### Health Check

```bash
curl http://localhost:8000/health
```

### API Documentation

FastAPI docs: `http://localhost:8000/docs`

## Troubleshooting

### Backend Issues

1. **Permission Denied for Packet Capture**
   - Run with `sudo`
   - Or system will use simulated data

2. **Redis Connection Error**
   - Check Redis is running: `redis-cli ping`
   - Verify `REDIS_HOST` in `.env`

3. **Database Errors**
   - Check `db/` directory exists and is writable
   - Verify SQLite path in `.env`

### Frontend Issues

1. **Cannot Connect to Backend**
   - Verify `NEXT_PUBLIC_API_URL` in `.env.local`
   - Check backend is running on port 8000
   - Check CORS settings in backend

2. **WebSocket Connection Failed**
   - Verify WebSocket endpoint: `ws://localhost:8000/api/v1/ws`
   - Check firewall settings

### IPTables Issues

1. **Cannot Block IPs**
   - Run backend with `sudo`
   - Check iptables is installed
   - Verify chain creation in logs

## Production Deployment

1. Set `DEBUG=false` in backend `.env`
2. Use systemd service for auto-start
3. Configure Nginx with SSL
4. Set up Redis persistence
5. Configure Prometheus scraping
6. Set strong `ADMIN_SECRET_KEY`
7. Enable firewall rules
8. Set up log rotation

## Development Notes

- Backend runs on port 8000
- Frontend runs on port 3000
- Prometheus metrics on port 9090
- Redis default port 6379
- WebSocket: `ws://localhost:8000/api/v1/ws`

## Next Steps

1. Configure your network interface in `.env`
2. Set up attack simulation from Kali Linux
3. Monitor dashboard for real-time updates
4. Test IP blocking functionality
5. Configure admin whitelist
6. Set up Prometheus alerts

## Support

For issues or questions, check:
- Backend logs: `backend/logs/`
- Frontend console: Browser DevTools
- System logs: `journalctl -u aegis-shield`

