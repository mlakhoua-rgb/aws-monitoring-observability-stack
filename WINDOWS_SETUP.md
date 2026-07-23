# Windows Setup Guide

**Quick Start Guide for Running the Monitoring Stack on Windows**

## Prerequisites Check

### 1. Check if Docker is Installed

Open PowerShell and run:
```powershell
docker --version
docker compose version
```

**Expected output:**
```
Docker version 24.x.x, build xxxxx
Docker Compose version v2.x.x
```

### 2. If Docker is Not Installed

Download and install Docker Desktop for Windows:
- **Download:** https://www.docker.com/products/docker-desktop/
- **Requirements:** Windows 10 64-bit (Pro, Enterprise, or Education) or Windows 11
- **Enable WSL 2:** Docker Desktop will prompt you to enable WSL 2 during installation

### 3. Verify Docker Desktop is Running

- Look for the Docker icon in your system tray (bottom-right corner)
- It should say "Docker Desktop is running"
- If not, launch Docker Desktop from the Start menu

## Running the Monitoring Stack

### Step 1: Navigate to Project Directory

```powershell
# Navigate to where you cloned the repository
cd C:\path\to\aws-monitoring-observability-stack

# Verify you're in the right directory
ls docker-compose.yml
```

### Step 2: Start the Stack

**Option A: Docker Compose V2 (Recommended)**
```powershell
docker compose up -d
```

**Option B: Docker Compose V1 (Legacy)**
```powershell
docker-compose up -d
```

### Step 3: Verify Services are Running

```powershell
# Check running containers
docker compose ps

# Expected output:
# NAME                    STATUS              PORTS
# prometheus              Up 10 seconds       0.0.0.0:9090->9090/tcp
# grafana                 Up 10 seconds       0.0.0.0:3000->3000/tcp
# blackbox-exporter       Up 10 seconds       0.0.0.0:9115->9115/tcp
# alertmanager            Up 10 seconds       0.0.0.0:9093->9093/tcp
# node-exporter           Up 10 seconds       0.0.0.0:9100->9100/tcp
```

### Step 4: Access the Dashboards

Open your browser and navigate to:

| Service | URL | Credentials |
|---------|-----|-------------|
| **Grafana** | http://localhost:3000 | admin / admin |
| **Prometheus** | http://localhost:9090 | None |
| **AlertManager** | http://localhost:9093 | None |

### Step 5: View the GitHub Monitoring Dashboard

1. Open Grafana: http://localhost:3000
2. Login with `admin` / `admin`
3. Click "Skip" or set a new password
4. Navigate to: **Dashboards** → **Browse** → **GitHub Services Monitoring**
5. Watch real-time monitoring of GitHub services!

## Troubleshooting

### Issue 1: `docker-compose` Command Not Found

**Solution:** Use the new syntax without hyphen:
```powershell
docker compose up -d
```

### Issue 2: Port Already in Use

**Error:** `Bind for 0.0.0.0:3000 failed: port is already allocated`

**Solution:** Stop the conflicting service or change the port:

```powershell
# Find what's using the port
netstat -ano | findstr :3000

# Kill the process (replace PID with actual process ID)
taskkill /PID <PID> /F

# Or edit docker-compose.yml to use different ports
```

### Issue 3: Docker Desktop Not Running

**Error:** `error during connect: This error may indicate that the docker daemon is not running`

**Solution:**
1. Launch Docker Desktop from the Start menu
2. Wait for it to fully start (icon in system tray should be steady)
3. Try the command again

### Issue 4: WSL 2 Not Enabled

**Error:** `WSL 2 installation is incomplete`

**Solution:**
1. Open PowerShell as Administrator
2. Run:
   ```powershell
   wsl --install
   ```
3. Restart your computer
4. Launch Docker Desktop again

### Issue 5: Firewall Blocking Access

**Error:** Can't access http://localhost:3000

**Solution:**
1. Open Windows Defender Firewall
2. Click "Allow an app through firewall"
3. Add Docker Desktop and allow private networks
4. Restart Docker Desktop

### Issue 6: Containers Failing to Start

**Check logs:**
```powershell
# View all logs
docker compose logs

# View specific service logs
docker compose logs grafana
docker compose logs prometheus
```

**Common fixes:**
```powershell
# Stop all services
docker compose down

# Remove volumes and restart fresh
docker compose down -v
docker compose up -d
```

## Useful Commands

### View Logs
```powershell
# Follow all logs
docker compose logs -f

# Follow specific service
docker compose logs -f grafana

# Last 50 lines
docker compose logs --tail=50
```

### Stop Services
```powershell
# Stop all services (keeps data)
docker compose stop

# Stop and remove containers (keeps data)
docker compose down

# Stop and remove everything including volumes (deletes data)
docker compose down -v
```

### Restart Services
```powershell
# Restart all services
docker compose restart

# Restart specific service
docker compose restart grafana
```

### Check Resource Usage
```powershell
# See CPU/Memory usage
docker stats

# See disk usage
docker system df
```

## Performance Tips for Windows

### 1. Allocate More Resources to Docker

1. Open Docker Desktop
2. Go to **Settings** → **Resources**
3. Increase:
   - **CPUs:** At least 2 cores
   - **Memory:** At least 4GB
   - **Disk:** At least 20GB
4. Click **Apply & Restart**

### 2. Use WSL 2 Backend (Recommended)

1. Open Docker Desktop
2. Go to **Settings** → **General**
3. Enable "Use the WSL 2 based engine"
4. Click **Apply & Restart**

### 3. Store Project in WSL 2 Filesystem

For better performance, clone the repository in WSL:

```powershell
# Open WSL
wsl

# Clone in WSL filesystem
cd ~
git clone https://github.com/mlakhoua-rgb/aws-monitoring-observability-stack.git
cd aws-monitoring-observability-stack

# Run docker compose
docker compose up -d
```

## Alternative: Using Docker Desktop GUI

If you prefer a graphical interface:

1. Open Docker Desktop
2. Go to the **Containers** tab
3. Click **Create Container**
4. Navigate to the project folder containing `docker-compose.yml`
5. Click **Start** to run the stack
6. Monitor containers from the GUI

## Next Steps

Once the stack is running:

1. Access Grafana: http://localhost:3000
2. View the GitHub monitoring dashboard
3. Explore Prometheus: http://localhost:9090
4. Check alerts: http://localhost:9093

**Customize for your needs:**
- Edit `prometheus/prometheus.yml` to add your own endpoints
- Modify `grafana/dashboards/github_monitoring.json` to customize the dashboard
- Add alert rules in `prometheus/alerts/github_alerts.yml`

## Getting Help

### Check Docker Desktop Logs
1. Click Docker icon in system tray
2. Select "Troubleshoot"
3. View logs

### System Information
```powershell
# Docker version
docker --version
docker compose version

# System info
docker info

# Windows version
winver
```

### Community Support
- **GitHub Issues:** https://github.com/mlakhoua-rgb/aws-monitoring-observability-stack/issues
- **Docker Forums:** https://forums.docker.com/
- **Stack Overflow:** Tag with `docker`, `docker-compose`, `windows`

## Common Windows-Specific Notes

### File Paths
- Windows uses backslashes (`\`) but Docker uses forward slashes (`/`)
- Docker Compose handles this automatically
- If editing docker-compose.yml, use forward slashes in volume paths

### Line Endings
- Windows uses CRLF (`\r\n`)
- Linux uses LF (`\n`)
- Git may convert line endings automatically
- If you encounter issues, configure Git:
  ```powershell
  git config --global core.autocrlf true
  ```

### Permissions
- You may need to run PowerShell as Administrator for some commands
- Right-click PowerShell → "Run as Administrator"

---

**Ready to Monitor!**

Once everything is running, you'll have a complete monitoring stack tracking GitHub services in real-time. Use this as a template to monitor your own services!

For more details, see [GITHUB_MONITORING_GUIDE.md](./GITHUB_MONITORING_GUIDE.md)
