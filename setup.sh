#!/bin/bash

# Doris Docker Cluster Setup Script
# This script checks and creates necessary directories for the Doris cluster

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check and create directory
check_and_create_dir() {
    local dir_path="$1"
    local description="$2"
    
    if [ -d "$dir_path" ]; then
        print_success "$description already exists: $dir_path"
    else
        print_warning "$description does not exist, creating: $dir_path"
        mkdir -p "$dir_path"
        if [ $? -eq 0 ]; then
            print_success "Created $description: $dir_path"
        else
            print_error "Failed to create $description: $dir_path"
            return 1
        fi
    fi
}

# Main setup function
setup_doris_cluster() {
    print_status "Starting Doris Docker Cluster setup..."
    echo
    
    # Check if docker-compose.yml exists
    if [ ! -f "docker-compose.yml" ]; then
        print_error "docker-compose.yml not found! Please run this script from the doris-docker directory."
        exit 1
    fi
    
    print_status "Checking and creating FE (Frontend) directories..."
    
    # FE1 directories and files
    check_and_create_dir "fe1" "FE1 main directory"
    check_and_create_dir "fe1/conf" "FE1 config directory"
    check_and_create_dir "fe1/doris-meta" "FE1 metadata directory"
    check_and_create_dir "fe1/log" "FE1 log directory"
    
    # FE2 directories and files
    check_and_create_dir "fe2" "FE2 main directory"
    check_and_create_dir "fe2/conf" "FE2 config directory"
    check_and_create_dir "fe2/doris-meta" "FE2 metadata directory"
    check_and_create_dir "fe2/log" "FE2 log directory"
    
    # FE3 directories and files
    check_and_create_dir "fe3" "FE3 main directory"
    check_and_create_dir "fe3/conf" "FE3 config directory"
    check_and_create_dir "fe3/doris-meta" "FE3 metadata directory"
    check_and_create_dir "fe3/log" "FE3 log directory"
    
    echo
    print_status "Checking and creating BE (Backend) directories..."
    
    # BE1 directories and files
    check_and_create_dir "be1" "BE1 main directory"
    check_and_create_dir "be1/conf" "BE1 config directory"
    check_and_create_dir "be1/storage" "BE1 storage directory"
    check_and_create_dir "be1/log" "BE1 log directory"
    
    # BE2 directories and files
    check_and_create_dir "be2" "BE2 main directory"
    check_and_create_dir "be2/conf" "BE2 config directory"
    check_and_create_dir "be2/storage" "BE2 storage directory"
    check_and_create_dir "be2/log" "BE2 log directory"
    
    # BE3 directories and files
    check_and_create_dir "be3" "BE3 main directory"
    check_and_create_dir "be3/conf" "BE3 config directory"
    check_and_create_dir "be3/storage" "BE3 storage directory"
    check_and_create_dir "be3/log" "BE3 log directory"
    
    echo
    print_status "Setting proper permissions..."
    
    # Set permissions for directories
    chmod -R 755 fe1 fe2 fe3 be1 be2 be3 2>/dev/null || print_warning "Could not set permissions (this is normal on some systems)"
    
    echo
    print_success "Doris cluster directory setup completed successfully!"
    echo
    print_status "Next steps:"
    echo "  1. Ensure configuration files exist in the conf directories"
    echo "  2. Start the cluster with: docker-compose up -d"
    echo "  3. Check cluster status with: docker-compose ps"
    echo "  4. Access Web UI at: http://localhost:8030"
    echo
}

# Function to validate setup
validate_setup() {
    print_status "Validating cluster directory setup..."
    echo
    
    local errors=0
    
    # Check required directories
    required_dirs=(
        "fe1" "fe1/conf" "fe1/doris-meta" "fe1/log"
        "fe2" "fe2/conf" "fe2/doris-meta" "fe2/log"
        "fe3" "fe3/conf" "fe3/doris-meta" "fe3/log"
        "be1" "be1/conf" "be1/storage" "be1/log"
        "be2" "be2/conf" "be2/storage" "be2/log"
        "be3" "be3/conf" "be3/storage" "be3/log"
    )
    
    for dir in "${required_dirs[@]}"; do
        if [ -d "$dir" ]; then
            print_success "✓ $dir/"
        else
            print_error "✗ $dir/"
            ((errors++))
        fi
    done
    
    echo
    if [ $errors -eq 0 ]; then
        print_success "All required directories are present!"
        print_status "The cluster directories are ready."
    else
        print_error "Found $errors missing directories."
        print_status "Run './setup.sh' to create missing directories."
    fi
    echo
}

# Function to clean up (for development/testing)
cleanup() {
    print_warning "This will remove all Doris data and logs but preserve configuration files!"
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Stopping containers..."
        docker-compose down 2>/dev/null || true
        
        print_status "Removing data and log directories (preserving conf directories)..."
        # Remove specific directories but keep conf
        rm -rf fe1/doris-meta fe1/log
        rm -rf fe2/doris-meta fe2/log
        rm -rf fe3/doris-meta fe3/log
        rm -rf be1/storage be1/log
        rm -rf be2/storage be2/log
        rm -rf be3/storage be3/log
        
        print_success "Cleanup completed! Configuration files preserved."
    else
        print_status "Cleanup cancelled."
    fi
}

# Main script logic
case "${1:-setup}" in
    setup)
        setup_doris_cluster
        ;;
    validate)
        validate_setup
        ;;
    cleanup)
        cleanup
        ;;
    help|--help|-h)
        echo "Doris Docker Cluster Setup Script"
        echo
        echo "Usage: $0 [command]"
        echo
        echo "Commands:"
        echo "  setup      Create all necessary directories (default)"
        echo "  validate   Check if all required directories exist"
        echo "  cleanup    Remove data and log directories (preserves conf directories)"
        echo "  help       Show this help message"
        echo
        ;;
    *)
        print_error "Unknown command: $1"
        echo "Use '$0 help' to see available commands."
        exit 1
        ;;
esac
