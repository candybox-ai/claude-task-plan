#!/bin/bash

# Agent Finder Module
# Discovers and locates available Claude Code agents using 4-tier search strategy

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Configuration
_FINDER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_AGENT_DIR="${LOCAL_AGENT_DIR:-$HOME/.claude/agents}"
AGENT_SOURCES_FILE="${AGENT_SOURCES_FILE:-$_FINDER_DIR/../config/agent-sources.yaml}"
CACHE_FILE="${CACHE_FILE:-$_FINDER_DIR/../cache/agent-search-cache.json}"
CACHE_TTL=${CACHE_TTL:-86400}  # 24 hours

# Utility functions
print_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1" >&2; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1" >&2; }
print_info() { echo -e "${BLUE}[INFO]${NC} $1" >&2; }

# ============================================================================
# Tier 1: Local Agent Discovery
# ============================================================================

# List all locally installed agents
# Usage: list_local_agents
# Returns: JSON array of agent info
list_local_agents() {
    print_info "🔍 Searching local agents in: $LOCAL_AGENT_DIR" >&2

    if [[ ! -d "$LOCAL_AGENT_DIR" ]]; then
        print_warning "Local agent directory not found: $LOCAL_AGENT_DIR" >&2
        echo "[]"
        return 1
    fi

    local agents="[]"
    local count=0

    # Search for agent definition files or directories
    # Agents might be stored as:
    # - Subdirectories with config files
    # - Individual agent files
    # - Package manager installations

    while IFS= read -r agent_path; do
        [[ -z "$agent_path" ]] && continue

        local agent_name=$(basename "$agent_path")

        # Extract agent metadata if available
        local description="N/A"
        local version="N/A"

        # Try to read metadata from common locations
        if [[ -f "$agent_path/agent.json" ]]; then
            description=$(jq -r '.description // "N/A"' "$agent_path/agent.json" 2>/dev/null)
            version=$(jq -r '.version // "N/A"' "$agent_path/agent.json" 2>/dev/null)
        elif [[ -f "$agent_path/package.json" ]]; then
            description=$(jq -r '.description // "N/A"' "$agent_path/package.json" 2>/dev/null)
            version=$(jq -r '.version // "N/A"' "$agent_path/package.json" 2>/dev/null)
        fi

        agents=$(echo "$agents" | jq --arg name "$agent_name" \
            --arg path "$agent_path" \
            --arg desc "$description" \
            --arg ver "$version" \
            '. += [{
                name: $name,
                path: $path,
                description: $desc,
                version: $ver,
                source: "local",
                available: true
            }]')

        ((count++))
    done < <(find "$LOCAL_AGENT_DIR" -maxdepth 2 -type d -not -path "$LOCAL_AGENT_DIR" 2>/dev/null || true)

    print_success "Found $count local agent(s)" >&2
    echo "$agents"
}

# Check if a specific agent is installed locally
# Usage: is_agent_installed <agent_name>
# Returns: 0 if installed, 1 if not
is_agent_installed() {
    local agent_name="$1"

    # Check in local agent directory
    if [[ -d "$LOCAL_AGENT_DIR/$agent_name" ]] || \
       [[ -d "$LOCAL_AGENT_DIR/${agent_name}-agent" ]] || \
       [[ -f "$LOCAL_AGENT_DIR/$agent_name" ]]; then
        return 0
    fi

    # Check if callable via claude command
    if claude --list-agents 2>/dev/null | grep -q "^$agent_name$"; then
        return 0
    fi

    return 1
}

# ============================================================================
# Tier 2: Official Repository Search
# ============================================================================

# Search Claude Code official agent repository
# Usage: search_official_agents <agent_name>
# Returns: JSON array of official agent results
search_official_agents() {
    local agent_name="$1"

    print_info "🔍 Searching official Claude Code agents..." >&2

    # Known official agents from Claude Code
    # This list should be kept up-to-date or fetched from official source
    local official_agents='[
        {"name": "frontend-developer", "category": "development", "url": "anthropic/claude-code"},
        {"name": "backend-developer", "category": "development", "url": "anthropic/claude-code"},
        {"name": "python-pro", "category": "language", "url": "anthropic/claude-code"},
        {"name": "typescript-pro", "category": "language", "url": "anthropic/claude-code"},
        {"name": "data-scientist", "category": "analysis", "url": "anthropic/claude-code"},
        {"name": "devops-engineer", "category": "operations", "url": "anthropic/claude-code"},
        {"name": "security-auditor", "category": "security", "url": "anthropic/claude-code"},
        {"name": "database-optimizer", "category": "database", "url": "anthropic/claude-code"},
        {"name": "cloud-architect", "category": "cloud", "url": "anthropic/claude-code"},
        {"name": "ai-engineer", "category": "ai", "url": "anthropic/claude-code"},
        {"name": "ml-engineer", "category": "ml", "url": "anthropic/claude-code"},
        {"name": "test-automator", "category": "testing", "url": "anthropic/claude-code"},
        {"name": "code-reviewer", "category": "quality", "url": "anthropic/claude-code"},
        {"name": "debugger", "category": "debugging", "url": "anthropic/claude-code"},
        {"name": "performance-engineer", "category": "performance", "url": "anthropic/claude-code"}
    ]'

    # Search for matching agents
    local results=$(echo "$official_agents" | jq --arg name "$agent_name" '
        [
            .[] |
            select(.name | test($name; "i"))
        ]
    ')

    local count=$(echo "$results" | jq 'length')
    print_info "Found $count official agent(s)" >&2

    echo "$results"
}

# ============================================================================
# Tier 3: Community & GitHub Search
# ============================================================================

# Search GitHub for Claude Code agents
# Usage: search_github_agents <agent_name>
# Returns: JSON array of GitHub search results
search_github_agents() {
    local agent_name="$1"

    print_info "🔍 Searching GitHub for agents..." >&2

    # Check if gh CLI is available
    if ! command -v gh &>/dev/null; then
        print_warning "GitHub CLI (gh) not found, skipping GitHub search" >&2
        echo "[]"
        return 1
    fi

    # Search GitHub repositories
    local search_query="claude-code agent $agent_name"

    local results=$(gh search repos "$search_query" \
        --limit 5 \
        --json fullName,description,url,stars \
        2>/dev/null || echo "[]")

    local count=$(echo "$results" | jq 'length')
    print_info "Found $count GitHub result(s)" >&2

    echo "$results"
}

# Search community curated agent lists
# Usage: search_community_agents <agent_name>
# Returns: JSON array of community agent results
search_community_agents() {
    local agent_name="$1"

    print_info "🔍 Searching community agent lists..." >&2

    # Known awesome lists and community resources
    # This should be configurable via agent-sources.yaml
    local community_sources='[
        {"name": "awesome-claude-code", "url": "https://github.com/awesome/claude-code-agents"},
        {"name": "claude-code-hub", "url": "https://github.com/community/claude-agents"}
    ]'

    # For now, return empty array (to be implemented with web scraping)
    print_info "Community search not fully implemented yet" >&2
    echo "[]"
}

# ============================================================================
# Multi-tier Agent Search
# ============================================================================

# Find agents using all available tiers
# Usage: find_agents <agent_names_array>
# Returns: JSON object with availability report
find_agents() {
    local agent_names="$1"  # JSON array of agent names

    print_info "🔍 Searching for agents across all tiers..." >&2
    echo "" >&2

    local results='{"found": [], "missing": [], "search_results": []}'

    # Process each agent name
    while IFS= read -r agent_name; do
        [[ -z "$agent_name" ]] && continue

        print_info "Searching for: $agent_name" >&2

        # Tier 1: Check local installation
        if is_agent_installed "$agent_name"; then
            print_success "✅ Found locally: $agent_name" >&2

            results=$(echo "$results" | jq --arg name "$agent_name" '
                .found += [{
                    name: $name,
                    source: "local",
                    available: true,
                    action: "none"
                }]
            ')
        else
            print_warning "❌ Not found locally: $agent_name" >&2

            # Tier 2: Search official repository
            local official=$(search_official_agents "$agent_name")

            if [[ $(echo "$official" | jq 'length') -gt 0 ]]; then
                print_success "📦 Found in official repository" >&2

                results=$(echo "$results" | jq --arg name "$agent_name" --argjson official "$official" '
                    .missing += [{
                        name: $name,
                        source: "official",
                        available: true,
                        action: "install",
                        install_source: $official[0]
                    }]
                ')
            else
                # Tier 3: Search GitHub
                local github=$(search_github_agents "$agent_name")

                if [[ $(echo "$github" | jq 'length') -gt 0 ]]; then
                    print_warning "🔍 Found on GitHub (requires user confirmation)" >&2

                    results=$(echo "$results" | jq --arg name "$agent_name" --argjson github "$github" '
                        .missing += [{
                            name: $name,
                            source: "github",
                            available: true,
                            action: "install_confirm",
                            search_results: $github
                        }]
                    ')
                else
                    print_error "❌ Not found anywhere" >&2

                    results=$(echo "$results" | jq --arg name "$agent_name" '
                        .missing += [{
                            name: $name,
                            source: "none",
                            available: false,
                            action: "manual_search"
                        }]
                    ')
                fi
            fi
        fi

        echo "" >&2
    done < <(echo "$agent_names" | jq -r '.[]')

    print_success "Search complete" >&2
    echo "$results"
}

# ============================================================================
# Agent Recommendation Functions
# ============================================================================

# Get recommended agents for a task category
# Usage: recommend_agents_for_category <category>
# Returns: JSON array of recommended agents
recommend_agents_for_category() {
    local category="$1"

    # Default recommendations by category
    case "$category" in
        "web-development"|"frontend")
            echo '[
                {"name": "frontend-developer", "priority": 1, "reason": "Specialized in frontend frameworks"},
                {"name": "typescript-pro", "priority": 2, "reason": "Type-safe development"}
            ]' | jq .
            ;;
        "backend"|"api")
            echo '[
                {"name": "backend-developer", "priority": 1, "reason": "API and backend services"},
                {"name": "database-optimizer", "priority": 2, "reason": "Database operations"}
            ]' | jq .
            ;;
        "data-analysis"|"analytics")
            echo '[
                {"name": "data-scientist", "priority": 1, "reason": "Data analysis and visualization"},
                {"name": "python-pro", "priority": 2, "reason": "Python data tools"}
            ]' | jq .
            ;;
        "devops"|"deployment")
            echo '[
                {"name": "devops-engineer", "priority": 1, "reason": "Deployment and operations"},
                {"name": "cloud-architect", "priority": 2, "reason": "Cloud infrastructure"}
            ]' | jq .
            ;;
        *)
            echo '[]' | jq .
            ;;
    esac
}

# ============================================================================
# Display Functions
# ============================================================================

# Display agent search results in a user-friendly format
# Usage: display_agent_results <results_json>
display_agent_results() {
    local results="$1"

    local found_count=$(echo "$results" | jq '.found | length')
    local missing_count=$(echo "$results" | jq '.missing | length')

    echo -e "${CYAN}═══════════════════════════════════════${NC}" >&2
    echo -e "${BLUE}   Agent Availability Report${NC}" >&2
    echo -e "${CYAN}═══════════════════════════════════════${NC}" >&2
    echo "" >&2

    # Display found agents
    if [[ $found_count -gt 0 ]]; then
        echo -e "${GREEN}✅ Available Locally ($found_count):${NC}" >&2
        echo "$results" | jq -r '.found[] | "   • \(.name) (\(.source))"' >&2
        echo "" >&2
    fi

    # Display missing agents
    if [[ $missing_count -gt 0 ]]; then
        echo -e "${YELLOW}📦 Needs Installation ($missing_count):${NC}" >&2
        echo "$results" | jq -r '.missing[] | "   • \(.name) - \(.action) from \(.source)"' >&2
        echo "" >&2
    fi
}

# ============================================================================
# Main Entry Point (for testing)
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being run directly (not sourced)

    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════╗"
    echo "║    Agent Finder - Test Mode           ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"

    # Test with sample agent names
    test_agents='["frontend-developer", "python-pro", "nonexistent-agent", "data-scientist"]'

    print_info "Testing agent discovery with: $test_agents" >&2
    echo "" >&2

    results=$(find_agents "$test_agents")

    echo "" >&2
    display_agent_results "$results"

    echo "" >&2
    echo -e "${CYAN}═══════════════════════════════════════${NC}" >&2
    echo -e "${BLUE}   Full Results (JSON)${NC}" >&2
    echo -e "${CYAN}═══════════════════════════════════════${NC}" >&2
    echo "$results" | jq .

    echo "" >&2
    echo -e "${GREEN}════════════════════════════════════════${NC}" >&2
    echo -e "${BLUE}   Test Complete!${NC}" >&2
    echo -e "${GREEN}════════════════════════════════════════${NC}" >&2
fi
