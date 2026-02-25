# Quick Deployment Guide

This guide provides streamlined instructions for deploying the 5G network slicing system.

## Prerequisites Check

Before starting, verify:

```bash
# Check Docker
docker --version  # Should be 20.10+

# Check Docker Compose
docker compose version  # Should be 2.0+

# Check available resources
free -h  # At least 8GB RAM
df -h    # At least 20GB free disk
```

## Quick Start (5 Minutes)

### 1. Clone and Navigate

```bash
git clone https://github.com/yourusername/5g-network-slicing.git
cd 5g-network-slicing
```

### 2. Build All Images (One Command)

```bash
# This builds all 5 images
docker build -f dockerimages/Dockerfile -t baseimage:nova . && \
docker build -f dockerimages/Dockerfile.5GC -t 5gcimg:nova . && \
docker build -f dockerimages/Dockerfile.gnb -t gnb:nova . && \
docker build -f dockerimages/Dockerfile.GNU -t gnu:nova . && \
docker build -f dockerimages/Dockerfile.UE -t ue:nova .
```

**Expected time**: 10-15 minutes depending on your internet connection

### 3. Start Containers

```bash
docker compose up -d
```

Verify all containers are running:

```bash
docker ps
```

You should see 6 containers running.

### 4. Start Services (Automated Script Method)

Open 4 terminal windows:

**Terminal 1 - Core Network:**

```bash
docker exec -it 5GCORECONT-2 bash
cd /usr/local/bin && ./core-start.sh
```

Wait for all NFs to start (~30 seconds)

**Terminal 2 - GNU Radio Broker:**

```bash
docker exec -it GNUCONT-2 bash
cd /app && ./start_broker.sh
```

Wait for "Broker ready" message

**Terminal 3 - gNB:**

```bash
docker exec -it GNBCONT-2 bash
cd /usr/local/bin && ./gnb-start.sh
```

Wait for "Connected to AMF" message

**Terminal 4 - UE1:**

```bash
docker exec -it UECONT-2 bash
cd /usr/local/bin && ./ue-start.sh
```

### 5. Verify Deployment

Check UE got an IP:

```bash
docker exec -it UECONT-2 ip addr show tun_srsue
```

Should show an IP like `10.45.1.2`

Test connectivity:

```bash
docker exec -it UECONT-2 ping -I tun_srsue -c 4 8.8.8.8
```

## Starting Additional UEs

**UE2:**

```bash
docker exec -it UE2CONT-2 bash
cd /usr/local/bin && ./ue-start.sh
# Should get IP from 10.45.2.0/24 subnet
```

**UE3:**

```bash
docker exec -it UE3CONT-2 bash
cd /usr/local/bin && ./ue-start.sh
# Should get IP from 10.45.3.0/24 subnet
```

## Verification Checklist

- [ ] All 6 containers running (`docker ps`)
- [ ] 5G Core started without errors
- [ ] GNU Radio broker running
- [ ] gNB connected to core
- [ ] UE1 registered and has IP
- [ ] UE1 can ping external addresses
- [ ] Each UE in different subnet

## Stopping the System

### Graceful Shutdown

1. Stop UEs (Ctrl+C in each UE terminal)
2. Stop gNB (Ctrl+C in gNB terminal)
3. Stop GNU Radio (Ctrl+C)
4. Stop Core (Ctrl+C)

### Container Cleanup

```bash
docker compose down
```

### Full Cleanup (Including Logs)

```bash
docker compose down
rm -rf logs/open5gs/*
rm -rf logs/srsran/*
```

## Troubleshooting Quick Fixes

### Containers won't start

```bash
# Enable TUN/TAP
sudo modprobe tun

# Restart Docker
sudo systemctl restart docker
docker compose up -d
```

### Build failures

```bash
# Clean Docker cache
docker system prune -af
docker volume prune -f

# Rebuild from scratch
docker build --no-cache -f dockerimages/Dockerfile -t baseimage:nova .
# ... repeat for other images
```

### UE won't register

```bash
# Check subscriber data
docker exec -it 5GCORECONT-2 mongosh
use open5gs
db.subscribers.find().pretty()
exit

# If empty, restart core to reload subscribers
docker restart 5GCORECONT-2
# Then restart core-start.sh
```

### Network issues

```bash
# Inside core container
docker exec -it 5GCORECONT-2 bash
ip link show ogstun  # Should be UP
ip addr show ogstun  # Should have 10.45.1.1, 10.45.2.1, 10.45.3.1
ip route             # Check routing
```

## Performance Tips

### Reduce Resource Usage

Edit [docker-compose.yaml](docker-compose.yaml) and add resource limits:

```yaml
services:
  core:
    # ... existing config
    deploy:
      resources:
        limits:
          cpus: "2"
          memory: 2G
```

### Improve Throughput

In GNU Radio flowgraph [flowgraphs/multi_ue_scenario.py](flowgraphs/multi_ue_scenario.py):

- Increase `samp_rate` for higher bandwidth
- Decrease `slow_down_ratio` for better performance

## Monitoring During Operation

### Watch Core Logs

```bash
docker exec -it 5GCORECONT-2 tail -f /opt/open5gs/install/var/log/open5gs/amf.log
```

### Watch gNB Logs

```bash
docker exec -it GNBCONT-2 tail -f /tmp/gnb.log
```

### Monitor UE Metrics

```bash
docker exec -it UECONT-2 cat /tmp/ue_metrics.csv
```

### Check Container Stats

```bash
docker stats
```

## Common Deployment Scenarios

### Scenario 1: Testing Single Slice

Start only UE1 for eMBB slice testing

### Scenario 2: Multi-Slice Testing

Start all 3 UEs and verify different slice assignments

### Scenario 3: Handover Testing

Stop and restart UEs to test re-registration

## Next Steps

- See [README.md](README.md) for detailed documentation
- See [ARCHITECTURE.md](docs/ARCHITECTURE.md) for system architecture
- See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines

## Getting Help

If you encounter issues:

1. Check logs in `logs/` directory
2. Review [ARCHITECTURE.md](docs/ARCHITECTURE.md) troubleshooting section
3. Open an issue on GitHub with logs and error messages
