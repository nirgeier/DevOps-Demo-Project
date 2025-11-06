#!/bin/bash

# Script to build Docker images for multiple platforms using binfmt

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Parse command line arguments
IMAGE_NAME="ghcr.io/nirgeier/devops-demo-project"
TAG="latest"

echo -e "${GREEN}Setting up binfmt for multi-platform builds...${NC}"

# Run binfmt to enable QEMU emulation for different architectures
docker run --privileged --rm tonistiigi/binfmt --install all

echo -e "${GREEN}binfmt setup complete.${NC}"

# Check if buildx is available
if ! docker buildx version > /dev/null 2>&1; then
    echo -e "${RED}Error: Docker Buildx is not available. Please install Docker Buildx.${NC}"
    exit 1
fi

echo -e "${GREEN}Creating multi-platform builder...${NC}"

# Create and use a new builder instance
docker buildx create --use --name multiplatform-builder || docker buildx use multiplatform-builder

echo -e "${GREEN}Building Docker image for multiple platforms...${NC}"

# Define platforms to build for
PLATFORMS="linux/amd64,linux/arm64"



# Build context is the parent directory (project root)
BUILD_CONTEXT="."

# Build and push the multi-platform image
docker buildx build \
    --platform $PLATFORMS \
    -t $IMAGE_NAME:$TAG \
    --push \
    -f docker/Dockerfile \
    $BUILD_CONTEXT

echo -e "${GREEN}Multi-platform Docker build completed successfully!${NC}"
echo -e "${YELLOW}Image pushed: $IMAGE_NAME:$TAG${NC}"