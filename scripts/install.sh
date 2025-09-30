#!/bin/bash

# Claude Agent Dispatch Installation Script
# Supports macOS and Linux

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_info() {
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

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unknown"
    fi
}

# Check if Claude CLI is installed
check_claude_cli() {
    if ! command -v claude &> /dev/null; then
        print_error "Claude CLI is not installed or not in PATH"
        print_info "Please install Claude CLI first: https://github.com/anthropics/claude-code"
        exit 1
    fi
    print_success "Claude CLI found: $(which claude)"
}

# Install to appropriate directory
install_script() {
    local os=$(detect_os)
    local install_dir=""

    if [[ "$os" == "macos" ]]; then
        if [[ -d "/opt/homebrew/bin" ]]; then
            install_dir="/opt/homebrew/bin"
        elif [[ -d "/usr/local/bin" ]]; then
            install_dir="/usr/local/bin"
        else
            install_dir="$HOME/.local/bin"
        fi
    elif [[ "$os" == "linux" ]]; then
        if [[ -d "/usr/local/bin" ]]; then
            install_dir="/usr/local/bin"
        else
            install_dir="$HOME/.local/bin"
        fi
    else
        print_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi

    # Create directory if it doesn't exist
    if [[ ! -d "$install_dir" ]]; then
        print_info "Creating directory: $install_dir"
        mkdir -p "$install_dir"
    fi

    # Copy script
    local script_path="$install_dir/claude-agent-dispatch"
    cp bin/claude-agent-dispatch "$script_path"
    chmod +x "$script_path"

    print_success "Installed claude-agent-dispatch to: $script_path"

    # Check if directory is in PATH
    if [[ ":$PATH:" != *":$install_dir:"* ]]; then
        print_warning "Directory $install_dir is not in your PATH"
        print_info "Add this line to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
        echo "export PATH=\"$install_dir:\$PATH\""
    fi
}

# Create config directory (optional for future use)
create_config() {
    local config_dir="$HOME/.claude-agent-dispatch"
    if [[ ! -d "$config_dir" ]]; then
        mkdir -p "$config_dir"
        print_info "Created config directory: $config_dir"
        print_info "No configuration files needed - tool works out of the box!"
    fi
}

# Verify installation
verify_installation() {
    if command -v claude-agent-dispatch &> /dev/null; then
        print_success "Installation verified! claude-agent-dispatch is ready to use"
        print_info "Try: claude-agent-dispatch \"Implement user authentication\""
    else
        print_warning "Installation may not be complete. You might need to restart your terminal or update your PATH"
    fi
}

# Main installation process
main() {
    print_info "Starting Claude Agent Dispatch installation..."

    # Check prerequisites
    check_claude_cli

    # Install script
    install_script

    # Create config
    create_config

    # Verify installation
    verify_installation

    print_success "Installation complete!"
    print_info "Documentation: https://github.com/your-username/claude-agent-dispatch"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi