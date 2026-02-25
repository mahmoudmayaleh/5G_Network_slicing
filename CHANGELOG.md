# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-25

### Added

- Initial release of 5G Network Slicing implementation
- Open5GS-based 5G Core Network with all essential NFs (NRF, AUSF, UDM/UDR, AMF, SMF, PCF, NSSF, UPF)
- srsRAN-based gNB and UE implementations
- GNU Radio-based software-defined radio interface
- Support for 3 distinct network slices (eMBB, Voice/Video, Low-latency)
- Docker-based containerized deployment
- Comprehensive documentation (README, Architecture, Deployment guides)
- Automated startup scripts for all components
- Network slice selection based on subscriber profiles
- QoS differentiation per slice (5QI, AMBR, ARP)
- MongoDB-based subscriber database
- Persistent logging infrastructure
- Configuration files for all network functions
- Multi-UE scenario support (3 concurrent UEs)

### Features

- Dynamic network slice assignment
- Separate IP subnets per slice (10.45.1.0/24, 10.45.2.0/24, 10.45.3.0/24)
- ZeroMQ-based RF signal multiplexing
- Container networking with isolated core and RAN networks
- TUN/TAP interface support for user plane
- 3GPP-compliant 5G-AKA authentication
- Session establishment with PDU session support
- Policy control and enforcement

### Documentation

- Professional README with setup and usage instructions
- Detailed architecture documentation
- Quick deployment guide
- Contributing guidelines
- MIT License

## [Unreleased]

### Planned

- Automated testing framework
- CI/CD pipeline integration
- Performance benchmarking tools
- Web-based monitoring dashboard
- Additional slice types (URLLC, mMTC)
- Real SDR hardware integration support
- Kubernetes deployment manifests
- Enhanced logging and monitoring
- Network analytics dashboard
