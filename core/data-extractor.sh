#!/bin/bash

# Data Extractor Module
# Extracts structured data from Claude execution logs and output

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
_EXTRACTOR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TECH_KEYWORDS_FILE="${TECH_KEYWORDS_FILE:-$_EXTRACTOR_DIR/../config/tech-keywords.json}"

# Utility functions
print_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1" >&2; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1" >&2; }
print_info() { echo -e "${BLUE}[INFO]${NC} $1" >&2; }

# ============================================================================
# Agent Detection Functions
# ============================================================================

# Extract agent names from Claude output/logs
# Usage: extract_agents_from_output <output_text>
# Returns: JSON array of agent names
extract_agents_from_output() {
    local output="$1"

    # Pattern 1: Look for agent invocations in logs
    # Example: "Launching frontend-developer agent..."
    # Example: "Using agent: python-pro"
    # Example: "Task tool with subagent_type: data-scientist"

    local agents=$(echo "$output" | \
        grep -iE '(agent|subagent_type|launching|using agent)' | \
        grep -oE '(frontend-developer|backend-developer|data-scientist|python-pro|typescript-pro|devops-engineer|security-auditor|database-optimizer|cloud-architect|ai-engineer|ml-engineer|test-automator|code-reviewer|debugger|performance-engineer)' | \
        sort -u | \
        jq -R . | jq -s .)

    echo "$agents"
}

# Extract agent names from JSON output (--output-format json)
# Usage: extract_agents_from_json <json_output>
# Returns: JSON array of agent names
extract_agents_from_json() {
    local json_output="$1"

    # Try to extract from tool_uses or agent fields
    local agents=$(echo "$json_output" | \
        jq -r '
            [
                .. |
                objects |
                select(has("subagent_type") or has("agent") or has("agent_name")) |
                (.subagent_type // .agent // .agent_name)
            ] | unique
        ' 2>/dev/null || echo "[]")

    echo "$agents"
}

# ============================================================================
# Tech Stack Detection Functions
# ============================================================================

# Load tech keywords from config file
# Usage: load_tech_keywords
# Returns: JSON array of tech keywords
load_tech_keywords() {
    if [[ -f "$TECH_KEYWORDS_FILE" ]]; then
        cat "$TECH_KEYWORDS_FILE"
    else
        print_warning "Tech keywords file not found: $TECH_KEYWORDS_FILE" >&2
        echo "[]"
    fi
}

# Detect technology stack from text
# Usage: detect_tech_stack <text>
# Returns: JSON array of detected technologies
detect_tech_stack() {
    local text="$1"
    local keywords=$(load_tech_keywords)

    # Check if keywords loaded successfully
    if [[ $(echo "$keywords" | jq 'type' 2>/dev/null) != "array" ]]; then
        print_warning "Failed to load tech keywords, returning empty array" >&2
        echo "[]"
        return
    fi

    # Convert text to lowercase for matching
    local text_lower=$(echo "$text" | tr '[:upper:]' '[:lower:]')

    # Match technologies using patterns from keywords file
    local detected=$(echo "$keywords" | jq --arg text "$text_lower" '
        [
            .[] |
            select((.pattern // "") != "" and ($text | test(.pattern; "i"))) |
            {
                name: .name,
                category: .category,
                related: (.related // [])
            }
        ] | unique_by(.name)
    ' 2>/dev/null || echo "[]")

    echo "$detected"
}

# ============================================================================
# Execution Steps Tracking
# ============================================================================

# Extract execution steps from output
# Usage: extract_execution_steps <output_text>
# Returns: JSON array of execution steps with timing
extract_execution_steps() {
    local output="$1"

    # Look for step markers in output
    # Common patterns:
    # - "Step 1: Requirement Clarification"
    # - "【需求澄清阶段】"
    # - "[STEP 1]"

    local steps="[]"
    local step_count=0

    # Pattern 1: English step markers
    while IFS= read -r line; do
        if [[ "$line" =~ [Ss]tep[[:space:]]*([0-9]+)[[:space:]]*[:：] ]]; then
            local step_num="${BASH_REMATCH[1]}"
            local step_name=$(echo "$line" | sed -E 's/.*[Ss]tep[[:space:]]*[0-9]+[[:space:]]*[:：][[:space:]]*(.*)/\1/' | sed 's/】.*//')

            steps=$(echo "$steps" | jq --arg num "$step_num" --arg name "$step_name" '. += [{
                step: ($num | tonumber),
                name: $name,
                status: "completed"
            }]')
            ((step_count++))
        fi
    done <<< "$output"

    # Pattern 2: Chinese step markers (【...阶段】)
    while IFS= read -r line; do
        if [[ "$line" =~ 【([^】]+阶段)】 ]]; then
            local step_name="${BASH_REMATCH[1]}"
            ((step_count++))

            steps=$(echo "$steps" | jq --arg num "$step_count" --arg name "$step_name" '. += [{
                step: ($num | tonumber),
                name: $name,
                status: "completed"
            }]')
        fi
    done <<< "$output"

    echo "$steps"
}

# ============================================================================
# Metrics Collection
# ============================================================================

# Extract performance metrics
# Usage: extract_metrics <output_text> <start_time> <end_time>
# Returns: JSON object with metrics
extract_metrics() {
    local output="$1"
    local start_time="$2"
    local end_time="$3"

    # Calculate execution time
    local duration=0
    if [[ -n "$start_time" ]] && [[ -n "$end_time" ]]; then
        duration=$((end_time - start_time))
    fi

    # Count files created/modified
    local files_created=$(echo "$output" | grep -c "Created file:" || echo "0")
    local files_modified=$(echo "$output" | grep -c "Modified file:" || echo "0")

    # Detect test results
    local tests_passed=$(echo "$output" | grep -oE '[0-9]+ (test[s]?|spec[s]?) passed' | grep -oE '[0-9]+' | head -1 || echo "null")
    local tests_failed=$(echo "$output" | grep -oE '[0-9]+ (test[s]?|spec[s]?) failed' | grep -oE '[0-9]+' | head -1 || echo "null")

    # Build metrics JSON
    local metrics=$(jq -n \
        --arg duration "$duration" \
        --arg files_created "$files_created" \
        --arg files_modified "$files_modified" \
        --arg tests_passed "$tests_passed" \
        --arg tests_failed "$tests_failed" \
        '{
            execution_time_seconds: ($duration | tonumber),
            files_created: ($files_created | tonumber),
            files_modified: ($files_modified | tonumber),
            tests_passed: (if $tests_passed == "null" then null else ($tests_passed | tonumber) end),
            tests_failed: (if $tests_failed == "null" then null else ($tests_failed | tonumber) end)
        }')

    echo "$metrics"
}

# ============================================================================
# Error Detection
# ============================================================================

# Detect errors and failures in output
# Usage: detect_errors <output_text>
# Returns: JSON array of detected errors
detect_errors() {
    local output="$1"

    local errors="[]"

    # Pattern 1: Error messages
    while IFS= read -r line; do
        if [[ "$line" =~ [Ee]rror:|ERROR:|✗ ]]; then
            errors=$(echo "$errors" | jq --arg msg "$line" '. += [{
                type: "error",
                message: $msg
            }]')
        fi
    done <<< "$output"

    # Pattern 2: Warning messages
    while IFS= read -r line; do
        if [[ "$line" =~ [Ww]arning:|WARNING:|⚠ ]]; then
            errors=$(echo "$errors" | jq --arg msg "$line" '. += [{
                type: "warning",
                message: $msg
            }]')
        fi
    done <<< "$output"

    echo "$errors"
}

# ============================================================================
# High-level Extraction Function
# ============================================================================

# Extract all data from Claude execution
# Usage: extract_execution_data <output_text> [json_output] [start_time] [end_time]
# Returns: Complete structured JSON with all extracted data
extract_execution_data() {
    local output_text="$1"
    local json_output="${2:-}"
    local start_time="${3:-$(date +%s)}"
    local end_time="${4:-$(date +%s)}"

    print_info "📊 Extracting execution data..." >&2

    # Extract agents
    local agents="[]"
    if [[ -n "$json_output" ]]; then
        agents=$(extract_agents_from_json "$json_output")
    fi

    # If no agents from JSON, try from text output
    if [[ $(echo "$agents" | jq 'length') -eq 0 ]]; then
        agents=$(extract_agents_from_output "$output_text")
    fi

    local agent_count=$(echo "$agents" | jq 'length')
    print_info "   Found $agent_count agent(s)" >&2

    # Detect tech stack
    local tech_stack=$(detect_tech_stack "$output_text")
    local tech_count=$(echo "$tech_stack" | jq 'length')
    print_info "   Detected $tech_count technology(ies)" >&2

    # Extract execution steps
    local steps=$(extract_execution_steps "$output_text")
    local step_count=$(echo "$steps" | jq 'length')
    print_info "   Tracked $step_count step(s)" >&2

    # Extract metrics
    local metrics=$(extract_metrics "$output_text" "$start_time" "$end_time")
    print_info "   Collected performance metrics" >&2

    # Detect errors
    local errors=$(detect_errors "$output_text")
    local error_count=$(echo "$errors" | jq 'length')
    if [[ $error_count -gt 0 ]]; then
        print_warning "   Found $error_count error(s)/warning(s)" >&2
    fi

    # Build complete extraction result
    local result=$(jq -n \
        --argjson agents "$agents" \
        --argjson tech_stack "$tech_stack" \
        --argjson steps "$steps" \
        --argjson metrics "$metrics" \
        --argjson errors "$errors" \
        --arg timestamp "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
        '{
            extraction_timestamp: $timestamp,
            agents_used: $agents,
            tech_stack: $tech_stack,
            execution_steps: $steps,
            metrics: $metrics,
            errors: $errors
        }')

    print_success "✨ Data extraction complete" >&2
    echo "$result"
}

# ============================================================================
# Log File Management
# ============================================================================

# Save execution data to log file
# Usage: save_execution_log <execution_id> <data_json> [log_dir]
# Returns: Path to saved log file
save_execution_log() {
    local execution_id="$1"
    local data_json="$2"
    local log_dir="${3:-$_EXTRACTOR_DIR/../logs/executions}"

    # Create log directory if not exists
    mkdir -p "$log_dir"

    local log_file="$log_dir/${execution_id}.json"

    # Save to file
    echo "$data_json" | jq . > "$log_file"

    print_success "💾 Saved execution log: $log_file" >&2
    echo "$log_file"
}

# Generate unique execution ID
# Usage: generate_execution_id
# Returns: Unique execution ID (timestamp-hash)
generate_execution_id() {
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local random=$(echo $RANDOM | md5 | cut -c1-8)
    echo "${timestamp}-${random}"
}

# ============================================================================
# Main Entry Point (for testing)
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being run directly (not sourced)

    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════╗"
    echo "║    Data Extractor - Test Mode         ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"

    # Test with sample output
    sample_output="Task execution started...

Step 1: Requirement Clarification
Understanding the requirements for building a React application.

【需求确认与成功标准定义】
Defining success criteria for the project.

Using agent: frontend-developer
Launching typescript-pro agent...

Created file: src/App.tsx
Created file: src/components/Header.tsx
Modified file: package.json

Tech stack: React, TypeScript, Vite

15 tests passed
2 tests failed

Error: Type mismatch in component props
Warning: Deprecated API usage detected

Task completed successfully!"

    print_info "Testing data extraction with sample output..." >&2
    echo "" >&2

    # Extract data
    start_time=$(($(date +%s) - 120))  # Simulate 2 minutes ago
    end_time=$(date +%s)

    result=$(extract_execution_data "$sample_output" "" "$start_time" "$end_time")

    echo "" >&2
    echo -e "${CYAN}═══════════════════════════════════════${NC}" >&2
    echo -e "${BLUE}   Extraction Result${NC}" >&2
    echo -e "${CYAN}═══════════════════════════════════════${NC}" >&2
    echo "$result" | jq .

    # Test saving
    echo "" >&2
    execution_id=$(generate_execution_id)
    print_info "Testing log save with ID: $execution_id" >&2

    log_file=$(save_execution_log "$execution_id" "$result")

    echo "" >&2
    echo -e "${GREEN}════════════════════════════════════════${NC}" >&2
    echo -e "${BLUE}   Test Complete!${NC}" >&2
    echo -e "${GREEN}════════════════════════════════════════${NC}" >&2
fi
