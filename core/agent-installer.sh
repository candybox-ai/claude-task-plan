#!/bin/bash

# Agent Installer Module
# Interactive installation interface for Claude Code agents
# Supports installation from multiple sources with user confirmation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Configuration
INSTALL_DIR="${LOCAL_AGENT_DIR:-$HOME/.claude/agents}"
BACKUP_DIR="${BACKUP_DIR:-$HOME/.claude/agents/.backup}"
TEMP_DIR="${TEMP_DIR:-/tmp/claude-agent-install}"

# Utility functions
print_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1" >&2; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1" >&2; }
print_info() { echo -e "${BLUE}[INFO]${NC} $1" >&2; }

# ============================================================================
# Language Detection
# ============================================================================

detect_language() {
    if [[ "${LANG:-}" =~ zh|cn|CN ]]; then
        echo "zh"
    else
        echo "en"
    fi
}

# ============================================================================
# Installation Prerequisites
# ============================================================================

# Check if installation prerequisites are met
check_prerequisites() {
    local missing_tools=()

    # Check for required tools
    if ! command -v git &>/dev/null; then
        missing_tools+=("git")
    fi

    if ! command -v jq &>/dev/null; then
        missing_tools+=("jq")
    fi

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        print_info "Please install these tools before continuing"
        return 1
    fi

    # Ensure directories exist
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$BACKUP_DIR"
    mkdir -p "$TEMP_DIR"

    return 0
}

# ============================================================================
# User Confirmation
# ============================================================================

# Prompt user for confirmation (yes/no)
# Usage: confirm_action "Question?" [default_yes]
# Returns: 0 for yes, 1 for no
confirm_action() {
    local prompt="$1"
    local default="${2:-no}"
    local lang=$(detect_language)

    local yn_prompt
    if [[ "$default" == "yes" ]]; then
        yn_prompt="(Y/n)"
    else
        yn_prompt="(y/N)"
    fi

    if [[ "$lang" == "zh" ]]; then
        echo -e "${CYAN}${prompt}${NC} ${yn_prompt}: " >&2
    else
        echo -e "${CYAN}${prompt}${NC} ${yn_prompt}: " >&2
    fi

    read -r response

    # Handle default
    if [[ -z "$response" ]]; then
        [[ "$default" == "yes" ]] && return 0 || return 1
    fi

    # Check response
    if [[ "$response" =~ ^[Yy] ]]; then
        return 0
    else
        return 1
    fi
}

# Display installation preview
display_install_preview() {
    local agent_name="$1"
    local source_type="$2"
    local source_url="$3"
    local lang=$(detect_language)

    echo ""
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    if [[ "$lang" == "zh" ]]; then
        echo -e "${BLUE}   Agent 安装预览${NC}"
    else
        echo -e "${BLUE}   Agent Installation Preview${NC}"
    fi
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo ""
    if [[ "$lang" == "zh" ]]; then
        echo -e "${YELLOW}Agent 名称:${NC} $agent_name"
        echo -e "${YELLOW}来源类型:${NC} $source_type"
        echo -e "${YELLOW}来源URL:${NC} $source_url"
        echo -e "${YELLOW}安装目录:${NC} $INSTALL_DIR/$agent_name"
    else
        echo -e "${YELLOW}Agent Name:${NC} $agent_name"
        echo -e "${YELLOW}Source Type:${NC} $source_type"
        echo -e "${YELLOW}Source URL:${NC} $source_url"
        echo -e "${YELLOW}Install Location:${NC} $INSTALL_DIR/$agent_name"
    fi
    echo ""
}

# ============================================================================
# Agent Installation Methods
# ============================================================================

# Install agent from official Claude Code repository
install_from_official() {
    local agent_name="$1"
    local lang=$(detect_language)

    print_info "Installing from official repository: $agent_name"

    # Claude Code agents are built-in, just verify they're available
    if claude --list-agents 2>/dev/null | grep -q "^$agent_name$"; then
        print_success "Agent '$agent_name' is available (built-in)"
        return 0
    fi

    # If not built-in, might need to be enabled via configuration
    print_warning "Agent '$agent_name' not found in Claude Code"
    if [[ "$lang" == "zh" ]]; then
        print_info "某些 Agent 可能需要通过 Claude Code 设置启用"
    else
        print_info "Some agents may need to be enabled in Claude Code settings"
    fi

    return 1
}

# Install agent from GitHub repository
install_from_github() {
    local agent_name="$1"
    local repo_url="$2"
    local lang=$(detect_language)

    print_info "Installing from GitHub: $repo_url"

    local install_path="$INSTALL_DIR/$agent_name"

    # Check if already exists
    if [[ -d "$install_path" ]]; then
        print_warning "Agent directory already exists: $install_path"
        if confirm_action "Overwrite existing installation?" "no"; then
            # Backup existing installation
            local backup_path="$BACKUP_DIR/${agent_name}_$(date +%Y%m%d_%H%M%S)"
            mv "$install_path" "$backup_path"
            print_info "Backed up to: $backup_path"
        else
            print_warning "Installation cancelled"
            return 1
        fi
    fi

    # Clone repository
    print_info "Cloning repository..."
    if git clone "$repo_url" "$install_path" 2>&1; then
        print_success "Successfully cloned repository"

        # Check for installation script
        if [[ -f "$install_path/install.sh" ]]; then
            print_info "Found installation script"
            if confirm_action "Run installation script?" "yes"; then
                (cd "$install_path" && bash install.sh)
            fi
        fi

        # Check for package dependencies
        if [[ -f "$install_path/package.json" ]]; then
            print_info "Found package.json"
            if confirm_action "Install npm dependencies?" "yes"; then
                (cd "$install_path" && npm install)
            fi
        fi

        print_success "Agent installed successfully: $install_path"
        return 0
    else
        print_error "Failed to clone repository"
        return 1
    fi
}

# Install agent from local path or archive
install_from_local() {
    local agent_name="$1"
    local source_path="$2"
    local lang=$(detect_language)

    print_info "Installing from local source: $source_path"

    if [[ ! -e "$source_path" ]]; then
        print_error "Source path does not exist: $source_path"
        return 1
    fi

    local install_path="$INSTALL_DIR/$agent_name"

    # Handle different source types
    if [[ -d "$source_path" ]]; then
        # Directory - copy
        cp -r "$source_path" "$install_path"
        print_success "Copied agent directory"
    elif [[ -f "$source_path" ]]; then
        # File - extract if archive
        case "$source_path" in
            *.tar.gz|*.tgz)
                mkdir -p "$install_path"
                tar -xzf "$source_path" -C "$install_path"
                print_success "Extracted tar.gz archive"
                ;;
            *.zip)
                mkdir -p "$install_path"
                unzip -q "$source_path" -d "$install_path"
                print_success "Extracted zip archive"
                ;;
            *)
                print_error "Unsupported file type: $source_path"
                return 1
                ;;
        esac
    fi

    print_success "Agent installed: $install_path"
    return 0
}

# ============================================================================
# Interactive Installation Wizard
# ============================================================================

# Interactive menu for selecting installation source
select_installation_source() {
    local agent_name="$1"
    local search_results="$2"  # JSON with available sources
    local lang=$(detect_language)

    echo ""
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    if [[ "$lang" == "zh" ]]; then
        echo -e "${BLUE}   Agent 安装向导${NC}"
        echo -e "${BLUE}   Agent: $agent_name${NC}"
    else
        echo -e "${BLUE}   Agent Installation Wizard${NC}"
        echo -e "${BLUE}   Agent: $agent_name${NC}"
    fi
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo ""

    # Parse available sources
    local official_available=$(echo "$search_results" | jq -r '.official // false')
    local github_results=$(echo "$search_results" | jq -r '.github // []')
    local github_count=$(echo "$github_results" | jq 'length')

    local options=()
    local option_num=1

    # Official source
    if [[ "$official_available" == "true" ]]; then
        options+=("official")
        if [[ "$lang" == "zh" ]]; then
            echo -e "${YELLOW}$option_num)${NC} 从官方仓库安装（推荐）"
        else
            echo -e "${YELLOW}$option_num)${NC} Install from official repository (recommended)"
        fi
        ((option_num++))
    fi

    # GitHub sources
    if [[ "$github_count" -gt 0 ]]; then
        for ((i=0; i<github_count; i++)); do
            local repo=$(echo "$github_results" | jq -r ".[$i]")
            local repo_name=$(echo "$repo" | jq -r '.fullName')
            local repo_stars=$(echo "$repo" | jq -r '.stars')
            local repo_desc=$(echo "$repo" | jq -r '.description // "No description"')

            options+=("github:$i")
            echo -e "${YELLOW}$option_num)${NC} GitHub: $repo_name (⭐ $repo_stars)"
            echo -e "   ${repo_desc:0:70}..."
            ((option_num++))
        done
    fi

    # Manual option
    options+=("manual")
    if [[ "$lang" == "zh" ]]; then
        echo -e "${YELLOW}$option_num)${NC} 手动输入 URL 或路径"
    else
        echo -e "${YELLOW}$option_num)${NC} Enter URL or path manually"
    fi
    ((option_num++))

    # Cancel option
    options+=("cancel")
    if [[ "$lang" == "zh" ]]; then
        echo -e "${YELLOW}$option_num)${NC} 取消安装"
    else
        echo -e "${YELLOW}$option_num)${NC} Cancel installation"
    fi

    echo ""
    if [[ "$lang" == "zh" ]]; then
        echo -e "${CYAN}请选择安装来源 (1-$option_num):${NC} "
    else
        echo -e "${CYAN}Select installation source (1-$option_num):${NC} "
    fi
    read -r selection

    # Validate selection
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [[ "$selection" -lt 1 ]] || [[ "$selection" -gt ${#options[@]} ]]; then
        print_error "Invalid selection"
        return 1
    fi

    local selected_option="${options[$((selection-1))]}"

    case "$selected_option" in
        official)
            install_from_official "$agent_name"
            ;;
        github:*)
            local github_index="${selected_option#github:}"
            local repo=$(echo "$github_results" | jq -r ".[$github_index]")
            local repo_url=$(echo "$repo" | jq -r '.url')
            display_install_preview "$agent_name" "GitHub" "$repo_url"
            if confirm_action "Proceed with installation?" "yes"; then
                install_from_github "$agent_name" "$repo_url"
            fi
            ;;
        manual)
            echo -e "${CYAN}Enter repository URL or local path:${NC} "
            read -r source_input
            if [[ "$source_input" =~ ^https?:// ]] || [[ "$source_input" =~ ^git@ ]]; then
                display_install_preview "$agent_name" "Git" "$source_input"
                if confirm_action "Proceed with installation?" "yes"; then
                    install_from_github "$agent_name" "$source_input"
                fi
            elif [[ -e "$source_input" ]]; then
                display_install_preview "$agent_name" "Local" "$source_input"
                if confirm_action "Proceed with installation?" "yes"; then
                    install_from_local "$agent_name" "$source_input"
                fi
            else
                print_error "Invalid URL or path: $source_input"
                return 1
            fi
            ;;
        cancel)
            print_warning "Installation cancelled"
            return 1
            ;;
    esac
}

# ============================================================================
# Batch Installation
# ============================================================================

# Install multiple agents interactively
install_agents_batch() {
    local agent_list="$1"  # JSON array of agents with search results
    local lang=$(detect_language)

    check_prerequisites || return 1

    local agent_count=$(echo "$agent_list" | jq 'length')
    print_info "Installing $agent_count agent(s)"

    local installed=0
    local failed=0

    for ((i=0; i<agent_count; i++)); do
        local agent=$(echo "$agent_list" | jq -r ".[$i]")
        local agent_name=$(echo "$agent" | jq -r '.name')
        local search_results=$(echo "$agent" | jq -r '.search_results // {}')

        echo ""
        echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        print_info "Installing agent $((i+1))/$agent_count: $agent_name"
        echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

        if select_installation_source "$agent_name" "$search_results"; then
            ((installed++))
        else
            ((failed++))
        fi
    done

    echo ""
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    if [[ "$lang" == "zh" ]]; then
        echo -e "${BLUE}   安装总结${NC}"
    else
        echo -e "${BLUE}   Installation Summary${NC}"
    fi
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo -e "${GREEN}✅ Successful:${NC} $installed"
    echo -e "${RED}❌ Failed:${NC} $failed"
    echo ""
}

# ============================================================================
# Main Entry Point (for testing)
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════╗"
    echo "║    Agent Installer - Test Mode        ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"

    # Test agent list
    test_agents='[
        {
            "name": "test-agent",
            "search_results": {
                "official": true,
                "github": [
                    {
                        "fullName": "example/test-agent",
                        "url": "https://github.com/example/test-agent",
                        "stars": 42,
                        "description": "A test agent for demonstration"
                    }
                ]
            }
        }
    ]'

    print_info "Testing interactive installation with test agent"
    echo ""

    install_agents_batch "$test_agents"

    echo ""
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo -e "${BLUE}   Test Complete!${NC}"
    echo -e "${GREEN}════════════════════════════════════════${NC}"
fi
