#!/bin/bash

# Linux Configuration Installer
# This script installs specific Linux configurations to ~/.config

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration paths
CONFIG_DIR="$HOME/.config"  # Target config directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# List of directories to install
CONFIG_DIRS=("ghostty" "waybar" "hypr")

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

# Function to check if required directories exist
check_config_dirs() {
    print_status "Checking for configuration directories..."
    
    missing_dirs=()
    
    for dir in "${CONFIG_DIRS[@]}"; do
        if [[ ! -d "$SCRIPT_DIR/$dir" ]]; then
            missing_dirs+=("$dir")
        fi
    done
    
    if [[ ${#missing_dirs[@]} -gt 0 ]]; then
        print_error "Missing required configuration directories:"
        for dir in "${missing_dirs[@]}"; do
            echo "  - $dir"
        done
        exit 1
    fi
    
    print_success "All required configuration directories found"
}

# Function to handle existing configurations
handle_existing_configs() {
    local existing_dirs=()
    
    # Check which directories already exist
    for dir in "${CONFIG_DIRS[@]}"; do
        if [[ -d "$CONFIG_DIR/$dir" ]]; then
            existing_dirs+=("$dir")
        fi
    done
    
    if [[ ${#existing_dirs[@]} -gt 0 ]]; then
        print_warning "Found existing configuration directories:"
        for dir in "${existing_dirs[@]}"; do
            echo "  - $CONFIG_DIR/$dir"
        done
        
        echo -n "Do you want to overwrite them? (y/N): "
        read -r response
        
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            print_status "Installation cancelled"
            exit 0
        fi
        
        # Remove only the specific directories we're installing
        for dir in "${existing_dirs[@]}"; do
            print_status "Removing existing $dir configuration..."
            rm -rf "$CONFIG_DIR/$dir"
        done
        print_success "Existing configurations removed"
    else
        print_status "No existing configurations found for: ${CONFIG_DIRS[*]}"
    fi
}

# Function to ensure config directory exists
ensure_config_dir() {
    if [[ ! -d "$CONFIG_DIR" ]]; then
        print_status "Creating configuration directory..."
        mkdir -p "$CONFIG_DIR"
        print_success "Configuration directory created"
    else
        print_status "Configuration directory already exists"
    fi
}

# Function to copy configuration files
copy_config_files() {
    print_status "Copying configuration directories..."
    
    # Copy each directory
    for dir in "${CONFIG_DIRS[@]}"; do
        print_status "Copying $dir..."
        cp -r "$SCRIPT_DIR/$dir" "$CONFIG_DIR/"
        print_success "$dir copied successfully"
    done
    
    print_success "All configuration directories copied successfully"
}

# Function to set proper permissions
set_permissions() {
    print_status "Setting proper permissions..."
    
    # Set permissions only for the directories we installed
    for dir in "${CONFIG_DIRS[@]}"; do
        chmod -R 755 "$CONFIG_DIR/$dir"
    done
    
    print_success "Permissions set successfully"
}

# Function to verify installation
verify_installation() {
    print_status "Verifying installation..."
    
    local failed=0
    
    # Check if directories were copied successfully
    for dir in "${CONFIG_DIRS[@]}"; do
        if [[ -d "$CONFIG_DIR/$dir" ]]; then
            print_success "Directory $dir found in $CONFIG_DIR"
        else
            print_error "Installation failed: Directory $dir not found in $CONFIG_DIR"
            failed=1
        fi
    done
    
    if [[ $failed -eq 1 ]]; then
        exit 1
    fi
    
    print_success "Installation verified: All directories are present"
}

# Main installation function
main() {
    echo
    print_status "Starting Linux configuration installation..."
    print_status "This will install: ${CONFIG_DIRS[*]}"
    echo
    
    # Check if we're in the right directory
    local missing=0
    for dir in "${CONFIG_DIRS[@]}"; do
        if [[ ! -d "$SCRIPT_DIR/$dir" ]]; then
            missing=1
            break
        fi
    done
    
    if [[ $missing -eq 1 ]]; then
        print_error "This script must be run from the directory containing your configuration directories (${CONFIG_DIRS[*]})"
        exit 1
    fi
    
    # Perform installation steps
    check_config_dirs
    handle_existing_configs
    ensure_config_dir
    copy_config_files
    set_permissions
    verify_installation
    
    echo
    print_success "Linux configuration installed successfully!"
    echo
    print_status "Installed configurations:"
    for dir in "${CONFIG_DIRS[@]}"; do
        echo "  - $dir"
    done
    echo
    print_status "Next steps:"
    echo "  1. Reload or restart your window manager or desktop environment"
    echo "  2. Verify your configuration files are loaded properly"
    echo
    print_status "Enjoy your new Linux setup! 🚀"
}

# Show help if requested
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    echo "Linux Configuration Installer"
    echo
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -h, --help    Show this help message"
    echo
    echo "This script will:"
    echo "  1. Check for existing configurations in ~/.config"
    echo "  2. Copy only the following directories to ~/.config:"
    for dir in "${CONFIG_DIRS[@]}"; do
        echo "     - $dir"
    done
    echo "  3. Set proper permissions"
    echo "  4. Verify the installation"
    echo
    echo "Note: This script only modifies the specific subdirectories listed above."
    echo "      Other contents of ~/.config will not be affected."
    echo
    exit 0
fi

# Run the main installation
main
