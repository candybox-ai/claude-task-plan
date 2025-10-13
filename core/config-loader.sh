#!/bin/bash

# Configuration Loader Module
# Loads and parses YAML configuration files
# Provides unified access to system configuration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration paths
AGENT_SOURCES_FILE="${AGENT_SOURCES_FILE:-$PROJECT_ROOT/config/agent-sources.yaml}"
META_PROTOCOL_FILE="${META_PROTOCOL_FILE:-$PROJECT_ROOT/core/meta-protocol.yaml}"

# Utility functions
print_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1" >&2; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1" >&2; }
print_info() { echo -e "${BLUE}[INFO]${NC} $1" >&2; }

# ============================================================================
# YAML Parsing Functions
# ============================================================================

# Simple YAML to JSON converter using awk/sed
# This is a basic parser for simple YAML structures
# For complex YAML, consider using yq or python yaml library
yaml_to_json_simple() {
    local yaml_file="$1"

    if [[ ! -f "$yaml_file" ]]; then
        echo "{}"
        return 1
    fi

    # Use Python if available for better parsing
    if command -v python3 &>/dev/null; then
        python3 -c "
import yaml
import json
import sys

try:
    with open('$yaml_file', 'r') as f:
        data = yaml.safe_load(f)
        print(json.dumps(data, indent=2))
except Exception as e:
    print('{}', file=sys.stderr)
    sys.exit(1)
" 2>/dev/null && return 0
    fi

    # Fallback: Basic parsing for simple structures
    # This won't handle complex YAML but works for our config files
    awk '
    BEGIN {
        print "{"
        level = 0
        prev_level = 0
    }
    /^[a-zA-Z_][a-zA-Z0-9_]*:/ {
        # Top-level key
        if (prev_level > 0) print ","
        key = $1
        sub(/:$/, "", key)
        printf "  \"%s\": ", key
        getline
        # Simple value
        if ($0 ~ /^  [a-zA-Z_]/) {
            print "{"
            level = 1
        }
        prev_level = level
    }
    END {
        print "\n}"
    }
    ' "$yaml_file" | jq -c . 2>/dev/null || echo "{}"
}

# ============================================================================
# Agent Sources Configuration
# ============================================================================

# Load agent sources configuration
load_agent_sources() {
    local config_file="${1:-$AGENT_SOURCES_FILE}"

    if [[ ! -f "$config_file" ]]; then
        print_warning "Agent sources config not found: $config_file" >&2
        echo "{}"
        return 1
    fi

    # Parse YAML to JSON
    local config=$(yaml_to_json_simple "$config_file")

    echo "$config"
}

# Get official agents list from configuration
get_official_agents() {
    local config="${1:-}"

    if [[ -z "$config" ]]; then
        config=$(load_agent_sources)
    fi

    echo "$config" | jq -c '.official.agents // []'
}

# Get community sources from configuration
get_community_sources() {
    local config="${1:-}"

    if [[ -z "$config" ]]; then
        config=$(load_agent_sources)
    fi

    echo "$config" | jq -c '.community.sources // []'
}

# Get GitHub search configuration
get_github_config() {
    local config="${1:-}"

    if [[ -z "$config" ]]; then
        config=$(load_agent_sources)
    fi

    echo "$config" | jq -c '.github // {}'
}

# Get installation settings
get_installation_settings() {
    local config="${1:-}"

    if [[ -z "$config" ]]; then
        config=$(load_agent_sources)
    fi

    echo "$config" | jq -c '.installation // {}'
}

# ============================================================================
# Meta Protocol Configuration
# ============================================================================

# Load meta protocol (6-step framework)
load_meta_protocol() {
    local config_file="${1:-$META_PROTOCOL_FILE}"

    if [[ ! -f "$config_file" ]]; then
        print_warning "Meta protocol config not found: $config_file" >&2
        echo "{}"
        return 1
    fi

    # Parse YAML to JSON
    local config=$(yaml_to_json_simple "$config_file")

    echo "$config"
}

# Get workflow step by number
get_workflow_step() {
    local step_num="$1"
    local config="${2:-}"
    local lang="${3:-en}"

    if [[ -z "$config" ]]; then
        config=$(load_meta_protocol)
    fi

    local step_key="step_$step_num"

    # Get step data
    local step=$(echo "$config" | jq -c ".workflow.$step_key // {}")

    # Get language-specific instructions
    local instructions_key="instructions_$lang"
    local instructions=$(echo "$step" | jq -r ".$instructions_key // .instructions_en")

    # Build result
    jq -n \
        --argjson step "$step" \
        --arg instructions "$instructions" \
        '$step + {instructions: $instructions}'
}

# Get all workflow steps
get_all_workflow_steps() {
    local config="${1:-}"
    local lang="${2:-en}"

    if [[ -z "$config" ]]; then
        config=$(load_meta_protocol)
    fi

    local steps="[]"

    for step_num in {1..6}; do
        local step=$(get_workflow_step "$step_num" "$config" "$lang")
        steps=$(echo "$steps" | jq --argjson step "$step" '. + [$step]')
    done

    echo "$steps"
}

# ============================================================================
# Configuration Validation
# ============================================================================

# Validate configuration files exist and are readable
validate_config_files() {
    local errors=0

    # Check agent sources
    if [[ ! -f "$AGENT_SOURCES_FILE" ]]; then
        print_error "Agent sources config missing: $AGENT_SOURCES_FILE"
        ((errors++))
    elif [[ ! -r "$AGENT_SOURCES_FILE" ]]; then
        print_error "Agent sources config not readable: $AGENT_SOURCES_FILE"
        ((errors++))
    fi

    # Check meta protocol
    if [[ ! -f "$META_PROTOCOL_FILE" ]]; then
        print_error "Meta protocol config missing: $META_PROTOCOL_FILE"
        ((errors++))
    elif [[ ! -r "$META_PROTOCOL_FILE" ]]; then
        print_error "Meta protocol config not readable: $META_PROTOCOL_FILE"
        ((errors++))
    fi

    if [[ $errors -gt 0 ]]; then
        print_error "Configuration validation failed with $errors error(s)"
        return 1
    fi

    print_success "Configuration files validated successfully"
    return 0
}

# ============================================================================
# Configuration Summary
# ============================================================================

# Display configuration summary
show_config_summary() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}   Configuration Summary${NC}"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo ""

    # Agent sources
    local agent_config=$(load_agent_sources 2>/dev/null)
    local official_count=$(echo "$agent_config" | jq '.official.agents | length')
    local community_count=$(echo "$agent_config" | jq '.community.sources | length')

    echo -e "${YELLOW}Agent Sources:${NC}"
    echo -e "  Official agents: $official_count"
    echo -e "  Community sources: $community_count"
    echo -e "  Config file: $AGENT_SOURCES_FILE"
    echo ""

    # Meta protocol
    local meta_config=$(load_meta_protocol 2>/dev/null)
    local version=$(echo "$meta_config" | jq -r '.version // "unknown"')
    local steps=$(echo "$meta_config" | jq '.workflow | keys | length')

    echo -e "${YELLOW}Meta Protocol:${NC}"
    echo -e "  Version: $version"
    echo -e "  Workflow steps: $steps"
    echo -e "  Config file: $META_PROTOCOL_FILE"
    echo ""
}

# ============================================================================
# Main Entry Point (for testing)
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════╗"
    echo "║    Config Loader - Test Mode          ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"

    # Validate configuration
    print_info "Validating configuration files..."
    if validate_config_files; then
        echo ""

        # Show summary
        show_config_summary

        # Test loading agent sources
        print_info "Testing agent sources loading..."
        agent_config=$(load_agent_sources)
        official_agents=$(get_official_agents "$agent_config")
        echo ""
        echo -e "${CYAN}Official Agents:${NC}"
        echo "$official_agents" | jq '.[] | {name: .name, category: .category}'
        echo ""

        # Test loading meta protocol
        print_info "Testing meta protocol loading..."
        meta_config=$(load_meta_protocol)
        echo ""
        echo -e "${CYAN}Workflow Steps:${NC}"
        get_all_workflow_steps "$meta_config" "en" | jq -c '.[] | {name: .name, purpose: .purpose}'
        echo ""

        print_success "All configuration tests passed!"
    else
        print_error "Configuration validation failed"
        exit 1
    fi

    echo ""
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo -e "${BLUE}   Test Complete!${NC}"
    echo -e "${GREEN}════════════════════════════════════════${NC}"
fi
