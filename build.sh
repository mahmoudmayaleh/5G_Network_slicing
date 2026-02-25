#!/usr/bin/env bash
# Build script for 5G Network Slicing Docker images

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}5G Network Slicing - Docker Build${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not running${NC}"
    exit 1
fi

# Build base image
echo -e "${YELLOW}[1/5] Building base image...${NC}"
docker build -f dockerimages/Dockerfile -t baseimage:nova . || {
    echo -e "${RED}Failed to build base image${NC}"
    exit 1
}
echo -e "${GREEN}✓ Base image built successfully${NC}"
echo ""

# Build 5G Core image
echo -e "${YELLOW}[2/5] Building 5G Core image...${NC}"
docker build -f dockerimages/Dockerfile.5GC -t 5gcimg:nova . || {
    echo -e "${RED}Failed to build 5G Core image${NC}"
    exit 1
}
echo -e "${GREEN}✓ 5G Core image built successfully${NC}"
echo ""

# Build gNB image
echo -e "${YELLOW}[3/5] Building gNB image...${NC}"
docker build -f dockerimages/Dockerfile.gnb -t gnb:nova . || {
    echo -e "${RED}Failed to build gNB image${NC}"
    exit 1
}
echo -e "${GREEN}✓ gNB image built successfully${NC}"
echo ""

# Build GNU Radio image
echo -e "${YELLOW}[4/5] Building GNU Radio image...${NC}"
docker build -f dockerimages/Dockerfile.GNU -t gnu:nova . || {
    echo -e "${RED}Failed to build GNU Radio image${NC}"
    exit 1
}
echo -e "${GREEN}✓ GNU Radio image built successfully${NC}"
echo ""

# Build UE image
echo -e "${YELLOW}[5/5] Building UE image...${NC}"
docker build -f dockerimages/Dockerfile.UE -t ue:nova . || {
    echo -e "${RED}Failed to build UE image${NC}"
    exit 1
}
echo -e "${GREEN}✓ UE image built successfully${NC}"
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}All images built successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Next steps:"
echo "1. Start containers: docker compose up -d"
echo "2. Follow the deployment guide in docs/DEPLOYMENT.md"
echo ""

# Show built images
echo "Built images:"
docker images | grep -E "baseimage|5gcimg|gnb|gnu|ue" | grep nova
