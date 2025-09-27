#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[*]${NC} $1"
}

print_error() {
    echo -e "${RED}[!]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

# Check if running with sudo
check_sudo() {
    if [ "$EUID" -ne 0 ]; then
        print_error "This script needs sudo privileges to install ydotool system-wide."
        print_status "Please run: sudo $0"
        exit 1
    fi
}

# Check if ydotool is already installed
check_existing() {
    if command -v ydotool >/dev/null 2>&1 && command -v ydotoold >/dev/null 2>&1; then
        print_warning "ydotool appears to be already installed at $(which ydotool)"
        read -p "Do you want to reinstall? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Skipping ydotool installation"
            setup_service_only
            exit 0
        fi
    fi
}

# Install build dependencies
install_dependencies() {
    print_status "Installing build dependencies..."
    apt-get update
    apt-get install -y build-essential cmake scdoc git
    print_success "Build dependencies installed"
}

# Build and install ydotool
build_ydotool() {
    print_status "Cloning ydotool repository..."

    # Create temp directory for building
    BUILD_DIR=$(mktemp -d)
    cd "$BUILD_DIR"

    git clone https://github.com/ReimuNotMoe/ydotool.git
    cd ydotool

    print_status "Building ydotool..."
    mkdir build && cd build
    cmake ..
    make -j$(nproc)

    print_status "Installing ydotool..."
    make install

    # Clean up build directory
    cd /
    rm -rf "$BUILD_DIR"

    print_success "ydotool installed successfully"
}

# Setup systemd service
setup_service() {
    print_status "Setting up ydotoold systemd service..."

    cat > /etc/systemd/system/ydotoold.service << 'EOF'
[Unit]
Description=Starts ydotoold Daemon
After=network.target

[Service]
Type=simple
Restart=always
RestartSec=3
ExecStartPre=/bin/sleep 2
ExecStartPre=/bin/rm -f /tmp/.ydotool_socket
ExecStart=/usr/local/bin/ydotoold --socket-path=/tmp/.ydotool_socket --socket-perm=0666
ExecReload=/usr/bin/kill -HUP $MAINPID
KillMode=process
TimeoutSec=180

[Install]
WantedBy=default.target
EOF

    print_status "Reloading systemd daemon..."
    systemctl daemon-reload

    print_status "Enabling ydotoold service..."
    systemctl enable ydotoold.service

    print_status "Starting ydotoold service..."
    systemctl start ydotoold.service

    # Give it a moment to start
    sleep 2

    # Check if service is running
    if systemctl is-active --quiet ydotoold.service; then
        print_success "ydotoold service is running"
    else
        print_error "Failed to start ydotoold service"
        print_status "Check status with: systemctl status ydotoold.service"
        exit 1
    fi
}

# Setup service only (if ydotool already installed)
setup_service_only() {
    print_status "Checking ydotoold service status..."

    if systemctl is-active --quiet ydotoold.service; then
        print_success "ydotoold service is already running"

        # Check if socket exists and has correct permissions
        if [ -S /tmp/.ydotool_socket ]; then
            SOCKET_PERMS=$(stat -c %a /tmp/.ydotool_socket)
            if [ "$SOCKET_PERMS" = "666" ]; then
                print_success "Socket permissions are correct"
            else
                print_warning "Socket permissions are $SOCKET_PERMS, should be 666"
                read -p "Do you want to restart the service with correct permissions? (y/N): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    setup_service
                fi
            fi
        else
            print_error "Socket /tmp/.ydotool_socket not found"
            setup_service
        fi
    else
        print_warning "ydotoold service is not running"
        setup_service
    fi
}

# Test ydotool
test_ydotool() {
    print_status "Testing ydotool..."

    # Switch to non-root user for testing if we're root
    if [ "$EUID" -eq 0 ] && [ -n "${SUDO_USER:-}" ]; then
        print_status "Testing as user $SUDO_USER..."
        if sudo -u "$SUDO_USER" bash -c 'echo "test" | ydotool type --file=-' >/dev/null 2>&1; then
            print_success "ydotool is working correctly!"
            print_status "You can now use ydotool to simulate keyboard input"
        else
            print_warning "ydotool test failed, but this might be normal in a non-graphical environment"
            print_status "Try running 'ydotool type hello' in a terminal with a text editor open"
        fi
    else
        if echo "test" | ydotool type --file=- >/dev/null 2>&1; then
            print_success "ydotool is working correctly!"
        else
            print_warning "ydotool test failed, but this might be normal in a non-graphical environment"
        fi
    fi
}

# Main installation flow
main() {
    echo "======================================"
    echo "     ydotool Installation Script      "
    echo "======================================"
    echo

    check_sudo
    check_existing

    print_status "Starting ydotool installation..."

    install_dependencies
    build_ydotool
    setup_service
    test_ydotool

    echo
    print_success "Installation complete!"
    print_status "ydotool has been installed and the daemon is running"
    print_status "The socket is at /tmp/.ydotool_socket with permissions 0666"
    echo
    print_status "You can manage the service with:"
    echo "  systemctl status ydotoold.service  # Check status"
    echo "  systemctl restart ydotoold.service # Restart daemon"
    echo "  systemctl stop ydotoold.service    # Stop daemon"
    echo
}

# Run main function
main "$@"