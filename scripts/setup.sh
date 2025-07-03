#!/bin/bash
set -e

echo "=== OpenTofu, Semaphore UI, and Ansible Setup with Docker ==="
echo "Setting up environment on macOS Apple Silicon..."

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    print_status "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
    source ~/.zshrc
else
    print_status "Homebrew already installed"
fi

# Update Homebrew
print_status "Updating Homebrew..."
brew update

# Install required packages
print_status "Installing required packages..."
brew install opentofu ansible jq git curl wget

# Check if Docker Desktop is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker Desktop is not installed or not running."
    print_status "Please install Docker Desktop from https://www.docker.com/products/docker-desktop/"
    print_status "After installation start Docker Desktop and run this script again."
    exit 1
fi

# checking if docker is runnig 
if ! docker info &> /dev/null; then
    print_error "Docker is not running. Going to run."
    # start Docker Desktop
    open -a Docker
    exit 1
fi 



print_status "Docker is running successfully"

# Generate SSH keys if not present
if [ ! -f ~/.ssh/id_rsa ]; then
    print_status "Generating SSH keys..."
    ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
else
    print_status "SSH keys already exist"
fi

# Create necessary directories for project structure
print_status "Creating project directories..."
cd ..
# (Optional) Set permissions on inventory scripts if needed
# chmod +x ansible/inventory/your_inventory_script.py

# Start Semaphore UI with MySQL backend using Docker Compose
print_status "Starting Semaphore UI with MySQL backend..."
cd semaphore
if [ ! -f docker-compose.yml ]; then
    print_warning "No docker-compose.yml found in semaphore/. Please add your Semaphore Compose file here."
    exit 1
fi
docker-compose up -d
cd ..

# Wait for services to start
print_status "Waiting for Semaphore services to initialize..."
sleep 30

# (Optional) Initialize MySQL tables for Semaphore state storage
if docker ps --format '{{.Names}}' | grep -q 'semaphore_mysql_1'; then
    print_status "Initializing MySQL database tables for Semaphore..."
    if [ -f semaphore/init-mysql.sql ]; then
        docker exec -i semaphore_mysql_1 mysql -u semaphore -psemaphore semaphore < semaphore/init-mysql.sql
    else
        print_warning "init-mysql.sql not found; skipping MySQL table initialization."
    fi
else
    print_warning "Semaphore MySQL container not detected; skipping MySQL table initialization."
fi

# Initialize OpenTofu
print_status "Initializing OpenTofu..."
cd opentofu
tofu init
cd ..

print_status "Setup completed successfully!"
echo ""
echo "=== Access Information ==="
echo "Semaphore UI: http://localhost:3000"
echo "Username: admin"
echo "Password: semaphorepassword"
echo ""
echo "=== Next Steps ==="
echo "1. Access Semaphore UI and configure your project"
echo "2. Add SSH keys to the Key Store"
echo "3. Create inventories and task templates"
echo "4. Run your first CI/CD pipeline"
echo ""
echo "=== Useful Commands ==="
echo "View Semaphore logs: cd semaphore && docker-compose logs -f"
echo "Check Docker containers: docker ps"