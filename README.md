# 5G Network Slicing Implementation

A containerized implementation of 5G network slicing using Open5GS, srsRAN, and GNU Radio. This project demonstrates dynamic network slice allocation for different user equipment (UEs) based on Quality of Service (QoS) requirements.

## Features

- **Multi-Slice Network Architecture**: Implements multiple network slices with distinct QoS profiles
- **Containerized Deployment**: All components run in isolated Docker containers for easy deployment
- **Real-time Radio Interface**: GNU Radio-based software-defined radio (SDR) implementation
- **Dynamic UE Assignment**: Automatic assignment of UEs to appropriate network slices
- **Comprehensive Logging**: Full logging infrastructure for debugging and monitoring
- **3GPP Compliant**: Based on 3GPP Release 15/16 specifications

## Architecture

The system consists of the following components:

### 5G Core Network (5GC)

- **NRF** (Network Repository Function): Service discovery
- **AUSF** (Authentication Server Function): Authentication
- **UDM/UDR** (Unified Data Management/Repository): Subscriber data management
- **AMF** (Access and Mobility Management Function): Access control
- **SMF** (Session Management Function): Session management
- **PCF** (Policy Control Function): Policy enforcement
- **NSSF** (Network Slice Selection Function): Slice selection
- **UPF** (User Plane Function): Data plane forwarding

### Radio Access Network (RAN)

- **gNB** (Next Generation NodeB): 5G base station
- **UE Simulators**: Three user equipment instances

### Supporting Infrastructure

- **GNU Radio Broker**: Handles RF signal processing and multiplexing
- **MongoDB**: Subscriber database

## Network Topology

```
┌─────────────────────────────────────────────────────────────┐
│                    5G Core Network                          │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐   │
│  │ NRF  │ │ AUSF │ │ UDM/ │ │ AMF  │ │ SMF  │ │ PCF/ │   │
│  │      │ │      │ │ UDR  │ │      │ │      │ │ NSSF │   │
│  └──────┘ └──────┘ └──────┘ └──────┘ └──────┘ └──────┘   │
│                          │                                  │
│                      ┌───────┐                             │
│                      │  UPF  │ (Data Plane)                │
│                      └───────┘                             │
└──────────────────────────┬──────────────────────────────────┘
                           │
                    ┌──────┴──────┐
                    │     gNB     │ (Base Station)
                    └──────┬──────┘
                           │
         ┌────────┬────────┴────────┬────────┐
         │        │                 │        │
    ┌────▼───┐ ┌─▼─────┐ ┌────────▼──┐ ┌───▼────────┐
    │  UE1   │ │  UE2  │ │    UE3    │ │   GNU      │
    │(Slice1)│ │(Slice2)│ │  (Slice3) │ │   Radio    │
    └────────┘ └───────┘ └───────────┘ └────────────┘
```

## Prerequisites

- **Docker**: Version 20.10 or higher
- **Docker Compose**: Version 2.0 or higher
- **Operating System**: Linux (Ubuntu 20.04+, Debian 11+) or macOS with Docker Desktop
- **System Resources**:
  - Minimum 8GB RAM
  - 4 CPU cores
  - 20GB free disk space
- **Network Requirements**: Kernel support for TUN/TAP devices

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/5g-network-slicing.git
cd 5g-network-slicing
```

### 2. Build Docker Images

Build all required Docker images in the correct order:

```bash
# Base image (contains common dependencies)
docker build -f dockerimages/Dockerfile -t baseimage:nova .

# 5G Core image
docker build -f dockerimages/Dockerfile.5GC -t 5gcimg:nova .

# gNB (base station) image
docker build -f dockerimages/Dockerfile.gnb -t gnb:nova .

# GNU Radio broker image
docker build -f dockerimages/Dockerfile.GNU -t gnu:nova .

# UE (user equipment) image
docker build -f dockerimages/Dockerfile.UE -t ue:nova .
```

### 3. Start the Infrastructure

```bash
docker compose up -d
```

Verify all containers are running:

```bash
docker ps
```

You should see 6 containers: `5GCORECONT-2`, `GNUCONT-2`, `GNBCONT-2`, `UECONT-2`, `UE2CONT-2`, `UE3CONT-2`.

## Usage

### Starting the Network

Follow these steps in order to start the 5G network:

#### Step 1: Start the 5G Core Network

```bash
docker exec -it 5GCORECONT-2 bash
cd /usr/local/bin
./core-start.sh
```

**Expected Output**: Logs indicating all Network Functions (NFs) are running successfully.

#### Step 2: Start the GNU Radio Broker

```bash
docker exec -it GNUCONT-2 bash
cd /app
./start_broker.sh
```

**Expected Output**: Broker initialization and ready status.

#### Step 3: Start the gNB (Base Station)

```bash
docker exec -it GNBCONT-2 bash
cd /usr/local/bin
./gnb-start.sh
```

**Expected Output**:

- gNB initialization
- Connection to 5G Core established
- Corresponding logs in the Core container

#### Step 4: Start User Equipment (UEs)

Start each UE individually:

```bash
# UE 1
docker exec -it UECONT-2 bash
cd /usr/local/bin
./ue-start.sh

# UE 2 (in a new terminal)
docker exec -it UE2CONT-2 bash
cd /usr/local/bin
./ue-start.sh

# UE 3 (in a new terminal)
docker exec -it UE3CONT-2 bash
cd /usr/local/bin
./ue-start.sh
```

**Expected Output**:

- UE registration and authentication
- IP address assignment
- Each UE connected to its designated network slice with appropriate subnet

### Network Slice Configuration

The system supports three distinct network slices:

| Slice   | SST | DNN       | IP Subnet    | QoS Profile | Use Case                         |
| ------- | --- | --------- | ------------ | ----------- | -------------------------------- |
| Slice 1 | 1   | internet1 | 10.45.1.0/24 | 5QI: 9      | eMBB (Enhanced Mobile Broadband) |
| Slice 2 | 1   | internet2 | 10.45.2.0/24 | 5QI: 7      | Voice/Video Streaming            |
| Slice 3 | 1   | internet3 | 10.45.3.0/24 | 5QI: 5      | Low-latency Applications         |

### Monitoring and Logs

#### View Container Logs

```bash
# 5G Core logs
docker exec -it 5GCORECONT-2 tail -f /opt/open5gs/install/var/log/open5gs/amf.log

# gNB logs
docker exec -it GNBCONT-2 tail -f /tmp/gnb.log

# UE logs
docker exec -it UECONT-2 tail -f /tmp/ue.log
```

#### Persistent Logs

Logs are stored in the `logs/` directory:

- `logs/open5gs/`: 5G Core Network Function logs
- `logs/srsran/`: gNB and UE logs, including packet captures

#### Network Metrics

```bash
# View UE metrics
cat logs/srsran/ue_metrics.csv

# Analyze packet capture
wireshark logs/srsran/gnb_mac.pcap
```

## Testing

### Verify Network Slice Assignment

Check that each UE is assigned to the correct slice:

```bash
docker exec -it UECONT-2 ip addr show tun_srsue
docker exec -it UE2CONT-2 ip addr show tun_srsue
docker exec -it UE3CONT-2 ip addr show tun_srsue
```

Each should show different IP addresses from different subnets (10.45.1.x, 10.45.2.x, 10.45.3.x).

### Test Connectivity

```bash
# From UE1
docker exec -it UECONT-2 ping -I tun_srsue -c 4 google.com
```

## Configuration

### Modifying Network Slices

Edit the subscriber configuration in [scripts/core-start.sh](scripts/core-start.sh) to adjust slice parameters:

- **AMBR** (Aggregate Maximum Bit Rate): Modify `ambrMbps` parameter
- **5QI** (5G QoS Identifier): Change the `fiveQi` value
- **ARP** (Allocation and Retention Priority): Adjust `arpPriorityLevel`

### UE Configuration

UE parameters are configured in:

- [configs/srsran/ue1.conf](configs/srsran/ue1.conf)
- [configs/srsran/ue2.conf](configs/srsran/ue2.conf)
- [configs/srsran/ue3.conf](configs/srsran/ue3.conf)

### Core Network Configuration

5G Core NF configurations are in `configs/open5gs/`:

- [amf.yaml](configs/open5gs/amf.yaml): AMF configuration
- [smf.yaml](configs/open5gs/smf.yaml): SMF and UPF configuration
- [nssf.yaml](configs/open5gs/nssf.yaml): Network slice configuration
- And others...

## Cleanup

### Stop All Services

```bash
docker compose down
```

### Remove All Data and Logs

```bash
rm -rf logs/open5gs/*
rm -rf logs/srsran/*
```

### Remove Docker Images

```bash
docker rmi baseimage:nova 5gcimg:nova gnb:nova gnu:nova ue:nova
```

## Performance Considerations

- **Latency**: Typical end-to-end latency: 10-50ms depending on slice configuration
- **Throughput**: Varies by slice; eMBB slice can support up to 100 Mbps
- **Scalability**: Current configuration supports up to 3 concurrent UEs; can be extended
- **Resource Usage**: Each container consumes approximately 500MB-1GB RAM

## Troubleshooting

### Containers Won't Start

```bash
# Check kernel modules
sudo modprobe tun

# Verify Docker privileges
docker info | grep -i privilege
```

### UE Registration Fails

1. Check that the 5G Core is fully initialized
2. Verify subscriber data in MongoDB:
   ```bash
   docker exec -it 5GCORECONT-2 mongosh
   use open5gs
   db.subscribers.find().pretty()
   ```
3. Check AMF logs for authentication errors

### No Network Connectivity

- Verify IP forwarding is enabled in containers
- Check UPF routing table
- Ensure `ogstun` interface is up in the Core container

### GNU Radio Broker Issues

```bash
# Restart the broker
docker restart GNUCONT-2
docker exec -it GNUCONT-2 bash
cd /app
./start_broker.sh
```

## References

- [Open5GS Documentation](https://open5gs.org/)
- [srsRAN Project](https://www.srsran.com/)
- [GNU Radio](https://www.gnuradio.org/)
- [3GPP Specifications](https://www.3gpp.org/)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

For questions and support, please open an issue in the GitHub repository.
