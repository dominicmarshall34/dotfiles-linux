#!/bin/bash

# Bluetooth Device Connection Script
# Connects to specific Bluetooth devices by name

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Device names to search for (case insensitive)
DEVICE_NAMES=("MX Anywhere 2" "Keychron")

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

# Function to check if bluetoothctl is available
check_bluetooth() {
    if ! command -v bluetoothctl &> /dev/null; then
        print_error "bluetoothctl is not installed. Please install bluez-utils package."
        exit 1
    fi

    # Check if bluetooth service is running
    if ! systemctl is-active --quiet bluetooth; then
        print_warning "Bluetooth service is not running. Starting it..."
        sudo systemctl start bluetooth
        sleep 2
    fi
}

# Function to enable bluetooth adapter
enable_bluetooth() {
    print_status "Enabling Bluetooth adapter..."
    echo "power on" | bluetoothctl > /dev/null 2>&1
    echo "agent on" | bluetoothctl > /dev/null 2>&1
    echo "default-agent" | bluetoothctl > /dev/null 2>&1
    sleep 2
    print_success "Bluetooth adapter enabled"
}

# Function to find device MAC address by name (case insensitive)
find_device_mac() {
    local device_name="$1"
    local mac_address

    # Get list of paired devices and search case-insensitively
    mac_address=$(echo "paired-devices" | bluetoothctl | grep -i "$device_name" | head -1 | awk '{print $2}')

    if [[ -n "$mac_address" ]]; then
        echo "$mac_address"
        return 0
    else
        return 1
    fi
}

# Function to connect to a device
connect_device() {
    local device_name="$1"
    local mac_address

    print_status "Searching for device: $device_name"

    if mac_address=$(find_device_mac "$device_name"); then
        print_status "Found device: $device_name ($mac_address)"

        # Check if already connected
        if echo "info $mac_address" | bluetoothctl | grep -q "Connected: yes"; then
            print_success "$device_name is already connected"
            return 0
        fi

        print_status "Connecting to $device_name..."
        if echo "connect $mac_address" | bluetoothctl | grep -q "Connection successful"; then
            print_success "Connected to $device_name"
            return 0
        else
            print_error "Failed to connect to $device_name"
            return 1
        fi
    else
        print_warning "Device '$device_name' not found in paired devices"
        print_status "Available paired devices:"
        echo "paired-devices" | bluetoothctl | grep "Device" || print_warning "No paired devices found"
        return 1
    fi
}

# Function to scan for new devices (optional)
scan_for_devices() {
    print_status "Scanning for new devices (10 seconds)..."
    echo "scan on" | bluetoothctl > /dev/null 2>&1
    sleep 10
    echo "scan off" | bluetoothctl > /dev/null 2>&1
    print_success "Scan complete"
}

# Main function
main() {
    echo
    print_status "Starting Bluetooth device connection..."
    print_status "Looking for devices: ${DEVICE_NAMES[*]}"
    echo

    check_bluetooth
    enable_bluetooth

    local connected_count=0
    local total_devices=${#DEVICE_NAMES[@]}

    # Try to connect to each device
    for device_name in "${DEVICE_NAMES[@]}"; do
        if connect_device "$device_name"; then
            ((connected_count++))
        fi
        echo
    done

    # Summary
    if [[ $connected_count -eq $total_devices ]]; then
        print_success "All devices connected successfully! ($connected_count/$total_devices)"
    elif [[ $connected_count -gt 0 ]]; then
        print_warning "Some devices connected ($connected_count/$total_devices)"
    else
        print_error "No devices could be connected"
        echo
        print_status "Troubleshooting tips:"
        echo "  1. Make sure devices are turned on and in pairing mode"
        echo "  2. Try running with --scan to discover new devices"
        echo "  3. Check if devices are already paired with another system"
    fi

    echo
    print_status "Bluetooth connection attempt completed"
}

# Show help if requested
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    echo "Bluetooth Device Connection Script"
    echo
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -h, --help    Show this help message"
    echo "  --scan        Scan for new devices before connecting"
    echo
    echo "This script will:"
    echo "  1. Enable the Bluetooth adapter"
    echo "  2. Search for paired devices matching:"
    for device in "${DEVICE_NAMES[@]}"; do
        echo "     - $device"
    done
    echo "  3. Connect to found devices"
    echo
    echo "Note: Devices must already be paired. Use your system's Bluetooth"
    echo "      settings or bluetoothctl to pair new devices first."
    echo
    exit 0
fi

# Handle scan option
if [[ "$1" == "--scan" ]]; then
    check_bluetooth
    enable_bluetooth
    scan_for_devices
    echo
fi

# Run the main connection process
main