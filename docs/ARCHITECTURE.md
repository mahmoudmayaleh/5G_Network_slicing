# Architecture Documentation

## System Overview

This document provides detailed architectural information about the 5G Network Slicing implementation.

## Component Architecture

### 1. 5G Core Network (5GC)

The 5G Core follows the Service-Based Architecture (SBA) defined by 3GPP.

#### Control Plane Functions

**Network Repository Function (NRF)**

- Service discovery and registration
- Maintains service profiles of all NFs
- Enables NF-to-NF communication

**Authentication Server Function (AUSF)**

- Handles UE authentication
- Validates subscriber credentials
- Supports 5G-AKA authentication

**Unified Data Management (UDM) / Unified Data Repository (UDR)**

- Stores subscriber profiles
- Manages subscription data
- Handles authentication credentials

**Access and Mobility Management Function (AMF)**

- Connection and reachability management
- Mobility management
- Access authentication and authorization
- Location services

**Session Management Function (SMF)**

- Session establishment, modification, and release
- UE IP address allocation
- DHCP functions
- Selection and control of UPF

**Policy Control Function (PCF)**

- Policy rules provision
- QoS control
- Charging control

**Network Slice Selection Function (NSSF)**

- Selects appropriate network slice instance
- Determines allowed NSSAI (Network Slice Selection Assistance Information)

#### User Plane Function

**User Plane Function (UPF)**

- Packet routing and forwarding
- QoS handling
- Traffic usage reporting
- Interface to Data Network (DN)

### 2. Radio Access Network (RAN)

**Next Generation NodeB (gNB)**

- PHY/MAC/RLC/PDCP/RRC layers
- Connection to 5GC via N2 (control) and N3 (user) interfaces
- Radio resource management
- Scheduling and resource allocation

**User Equipment (UE)**

- Simulated mobile devices
- Each UE configured with unique IMSI and security keys
- Supports different network slice requirements

### 3. GNU Radio Broker

**Purpose**: Software-defined radio interface simulation

**Functionality**:

- Signal multiplexing/demultiplexing
- Handles multiple UE connections
- ZeroMQ-based communication
- Supports configurable sample rates and bandwidth

## Network Interfaces

| Interface | Description | Components            |
| --------- | ----------- | --------------------- |
| N1        | UE to AMF   | Control signaling     |
| N2        | gNB to AMF  | Control plane         |
| N3        | gNB to UPF  | User plane data       |
| N4        | SMF to UPF  | Control of user plane |
| Uu        | UE to gNB   | Radio interface       |

## Network Slicing Architecture

### Slice Configuration

Each network slice is characterized by:

- **S-NSSAI** (Single Network Slice Selection Assistance Information)
  - SST (Slice/Service Type)
  - SD (Slice Differentiator)
- **DNN** (Data Network Name)
- **QoS Profile** (5QI, ARP, AMBR)

### Supported Slices

#### Slice 1: Enhanced Mobile Broadband (eMBB)

```yaml
SST: 1
DNN: internet1
Subnet: 10.45.1.0/24
5QI: 9 (delay-tolerant, high throughput)
AMBR: 50 Mbps
Use Case: High-speed data access, video streaming
```

#### Slice 2: Voice and Video Services

```yaml
SST: 1
DNN: internet2
Subnet: 10.45.2.0/24
5QI: 7 (conversational voice)
AMBR: 30 Mbps
Use Case: VoIP, video calls
```

#### Slice 3: Low-Latency Communications

```yaml
SST: 1
DNN: internet3
Subnet: 10.45.3.0/24
5QI: 5 (mission critical)
AMBR: 20 Mbps
Use Case: Real-time applications, IoT control
```

## Data Flow

### Registration Flow

```
UE → gNB → AMF → AUSF → UDM
         ↓
    (Authentication)
         ↓
    AMF → NSSF (Slice Selection)
         ↓
    AMF → NRF (Discovery)
         ↓
    Registration Complete
```

### Session Establishment Flow

```
UE → AMF → SMF
         ↓
    SMF → PCF (Policy)
         ↓
    SMF → UDM (Subscription)
         ↓
    SMF → UPF (N4: Session Setup)
         ↓
    PDU Session Established
         ↓
    gNB ← SMF (N2: QoS)
    gNB → UPF (N3: User Data Path)
```

### User Data Flow

```
UE ↔ gNB (via GNU Radio) ↔ UPF ↔ Internet
```

## Container Architecture

### Container Network Layout

**Core Network (192.168.50.0/24)**

- 192.168.50.2: 5G Core container (all NFs)
- 192.168.50.3: gNB container

**RAN Network (192.168.60.0/24)**

- 192.168.60.2: UE1 container
- 192.168.60.3: gNB container
- 192.168.60.4: UE2 container
- 192.168.60.5: UE3 container
- 192.168.60.6: GNU Radio broker

### Resource Allocation

Each container is configured with:

- **Privileged mode**: Required for TUN/TAP device creation
- **NET_ADMIN capability**: Network configuration
- **SYS_MODULE capability**: Kernel module loading
- **IP forwarding enabled**: Packet routing
- **Shared volumes**: Configuration and logs

## Security Considerations

### Authentication

- **5G-AKA (Authentication and Key Agreement)**
- K (Subscriber key): Stored in UDM
- OPc (Operator variant algorithm configuration): Pre-shared
- IMSI: Unique subscriber identifier

### Encryption

- **NAS (Non-Access Stratum)**: Encrypted between UE and AMF
- **RRC (Radio Resource Control)**: Encrypted between UE and gNB

### Network Isolation

- Separate Docker networks for core and RAN
- Network namespace isolation
- Container-level security

## Performance Metrics

### Latency Targets

| Slice Type  | Target Latency | Typical Latency |
| ----------- | -------------- | --------------- |
| eMBB        | < 100ms        | 30-50ms         |
| Voice/Video | < 50ms         | 20-30ms         |
| Low-Latency | < 10ms         | 10-15ms         |

### Throughput Capacity

- eMBB slice: Up to 100 Mbps
- Voice/Video slice: Up to 50 Mbps
- Low-latency slice: Up to 30 Mbps

### Scalability

- Current: 3 concurrent UEs
- Scalable to: 10+ UEs with resource adjustments
- Bottlenecks: GNU Radio processing, container resources

## Configuration Files

### Core Network

- **AMF**: Controls access, mobility, and slice selection
  - File: `configs/open5gs/amf.yaml`
  - Key parameters: PLMN, TAC, slice configurations

- **SMF**: Manages sessions and UPF
  - File: `configs/open5gs/smf.yaml`
  - Key parameters: DNN, subnet pools, DNS

- **NSSF**: Network slice selection
  - File: `configs/open5gs/nssf.yaml`
  - Key parameters: S-NSSAI mappings

### RAN

- **gNB Configuration**
  - File: `configs/srsran/gnb.yaml`
  - Key parameters: RF settings, cell configuration, slicing support

- **UE Configuration**
  - Files: `configs/srsran/ue1.conf`, `ue2.conf`, `ue3.conf`
  - Key parameters: IMSI, K, OPc, preferred S-NSSAI

## Monitoring and Debugging

### Log Files

- AMF logs: `/opt/open5gs/install/var/log/open5gs/amf.log`
- SMF logs: `/opt/open5gs/install/var/log/open5gs/smf.log`
- gNB logs: `/tmp/gnb.log`
- UE logs: `/tmp/ue.log`

### Packet Captures

- MAC layer: `logs/srsran/gnb_mac.pcap`
- Analyze with Wireshark for debugging

### Metrics

- UE metrics: `logs/srsran/ue_metrics.csv`
- Includes: RSRP, RSRQ, throughput, latency

## Troubleshooting Guide

### Common Issues

1. **MongoDB connection failures**
   - Check if MongoDB is running
   - Verify port 27017 is accessible

2. **UE registration failures**
   - Verify subscriber data in MongoDB
   - Check AMF logs for authentication errors
   - Ensure correct IMSI/K/OPc in UE config

3. **No data connectivity**
   - Verify UPF has created `ogstun` interface
   - Check IP forwarding is enabled
   - Verify routing table in UPF

4. **GNU Radio broker issues**
   - Check ZeroMQ ports are not in use
   - Verify network connectivity between containers
   - Restart broker if needed

## Future Enhancements

- [ ] Support for additional slice types (URLLC, mMTC)
- [ ] Integration with real SDR hardware
- [ ] Web-based monitoring dashboard
- [ ] Horizontal scaling with Kubernetes
- [ ] Advanced QoS enforcement
- [ ] Inter-slice mobility support
- [ ] Network analytics and ML-based optimization

## References

1. 3GPP TS 23.501: System architecture for 5G
2. 3GPP TS 23.502: Procedures for 5G System
3. 3GPP TS 28.541: Network Slice Management
4. Open5GS Documentation: https://open5gs.org/
5. srsRAN Documentation: https://docs.srsran.com/
