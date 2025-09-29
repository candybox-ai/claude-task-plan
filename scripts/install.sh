#!/bin/bash

# Claude Task Plan Installation Script
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
    local script_path="$install_dir/claude-task-plan"
    cp bin/claude-task-plan "$script_path"
    chmod +x "$script_path"

    print_success "Installed claude-task-plan to: $script_path"

    # Check if directory is in PATH
    if [[ ":$PATH:" != *":$install_dir:"* ]]; then
        print_warning "Directory $install_dir is not in your PATH"
        print_info "Add this line to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
        echo "export PATH=\"$install_dir:\$PATH\""
    fi
}

# Create config directory
create_config() {
    local config_dir="$HOME/.claude-task-plan"
    if [[ ! -d "$config_dir" ]]; then
        mkdir -p "$config_dir"
        print_info "Created config directory: $config_dir"
    fi

    # Create default config if it doesn't exist
    local config_file="$config_dir/config.yaml"
    if [[ ! -f "$config_file" ]]; then
        cat > "$config_file" << EOF
# Claude Task Plan Configuration
language: auto  # auto, en, zh
timeout: 7200   # 2 hours in seconds
EOF
        print_info "Created default config: $config_file"
    fi
}

# Verify installation
verify_installation() {
    if command -v claude-task-plan &> /dev/null; then
        print_success "Installation verified! claude-task-plan is ready to use"
        print_info "Try: claude-task-plan \"Implement user authentication\""
    else
        print_warning "Installation may not be complete. You might need to restart your terminal or update your PATH"
    fi
}

# Main installation process
main() {
    print_info "Starting Claude Task Plan installation..."

    # Check prerequisites
    check_claude_cli

    # Install script
    install_script

    # Create config
    create_config

    # Verify installation
    verify_installation

    print_success "Installation complete!"
    print_info "Documentation: https://github.com/your-username/claude-task-plan"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi