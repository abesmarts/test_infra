#!/bin/bash
set -e

echo "=== Cleanup Script for OpenTofu, Semaphore UI, and Docker Environment ==="

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}
print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}
print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 1. Destroy OpenTofu-managed resources
if [ -d "opentofu" ]; then
    print_status "Destroying OpenTofu-managed infrastructure..."
    cd opentofu
    if command -v tofu &> /dev/null; then
        tofu destroy -auto-approve || print_warning "OpenTofu destroy failed or nothing to destroy."
    elif command -v terraform &> /dev/null; then
        terraform destroy -auto-approve || print_warning "Terraform destroy failed or nothing to destroy."
    else
        print_warning "OpenTofu/Terraform not found; skipping destroy."
    fi
    cd ..
else
    print_warning "No opentofu/ directory found; skipping OpenTofu destroy."
fi

# 2. Stop and remove Semaphore UI containers and volumes
if [ -d "semaphore" ] && [ -f "semaphore/docker-compose.yml" ]; then
    print_status "Stopping and removing Semaphore UI containers and volumes..."
    cd semaphore
    docker-compose down -v || print_warning "docker-compose down failed or nothing to remove."
    cd ..
else
    print_warning "No semaphore/docker-compose.yml found; skipping Semaphore cleanup."
fi

# 3. Remove custom Docker networks created by OpenTofu (if any)
print_status "Looking for custom Docker networks to remove..."
NETWORK_NAME="vm-test-network"
if docker network ls --format '{{.Name}}' | grep -wq "$NETWORK_NAME"; then
    docker network rm "$NETWORK_NAME" && print_status "Removed Docker network $NETWORK_NAME."
else
    print_warning "Docker network $NETWORK_NAME not found; skipping."
fi

# 4. (Optional) Remove Docker images created for test VMs (uncomment if desired)
# print_status "Removing Docker images for test VMs (ubuntu:22.04)..."
# docker rmi ubuntu:22.04 || print_warning "Could not remove ubuntu:22.04 image (may be in use or not present)."

# 5. (Optional) Remove OpenTofu state and cache files
if [ -d "opentofu" ]; then
    print_status "Removing OpenTofu state and cache files..."
    rm -rf opentofu/.terraform opentofu/terraform.tfstate* opentofu/.terraform.lock.hcl
fi

print_status "Cleanup completed!"