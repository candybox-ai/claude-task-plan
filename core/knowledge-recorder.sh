#!/bin/bash

# Knowledge Recorder Module
# Records execution data to JSONL files for evolution system

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
_RECORDER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KNOWLEDGE_DIR="${KNOWLEDGE_DIR:-$_RECORDER_DIR/../evolution/knowledge}"

# Utility functions
print_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1" >&2; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1" >&2; }
print_info() { echo -e "${BLUE}[INFO]${NC} $1" >&2; }

# Ensure knowledge directory exists
mkdir -p "$KNOWLEDGE_DIR"

# ============================================================================
# JSONL Append Functions
# ============================================================================

# Append a record to a JSONL file
# Usage: append_to_jsonl <file_path> <json_record>
append_to_jsonl() {
    local file_path="$1"
    local json_record="$2"

    # Ensure file exists
    touch "$file_path"

    # Validate JSON
    if ! echo "$json_record" | jq . > /dev/null 2>&1; then
        print_error "Invalid JSON record" >&2
        return 1
    fi

    # Append as single line
    echo "$json_record" | jq -c . >> "$file_path"
}

# ============================================================================
# Success Pattern Recording
# ============================================================================

# Record a successful execution pattern
# Usage: record_success_pattern <execution_data> <feedback_data>
record_success_pattern() {
    local execution_data="$1"
    local feedback_data="$2"

    local file="$KNOWLEDGE_DIR/success-patterns.jsonl"

    # Build success pattern record
    local pattern=$(jq -n \
        --argjson exec "$execution_data" \
        --argjson feedback "$feedback_data" \
        --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
        '{
            timestamp: $ts,
            execution_id: $exec.execution_id,
            task_fingerprint: ($exec.task_description | @base64),
            agents_used: $exec.agents_used,
            tech_stack: $exec.tech_stack,
            success: true,
            satisfaction: $feedback.satisfaction,
            execution_time: $exec.metrics.execution_time_seconds,
            recipe_used: $exec.recipe_used
        }')

    append_to_jsonl "$file" "$pattern"
    print_success "📝 Recorded success pattern to $file" >&2
}

# ============================================================================
# Failure Pattern Recording
# ============================================================================

# Record a failure execution pattern
# Usage: record_failure_pattern <execution_data> <feedback_data>
record_failure_pattern() {
    local execution_data="$1"
    local feedback_data="$2"

    local file="$KNOWLEDGE_DIR/failure-patterns.jsonl"

    # Build failure pattern record
    local pattern=$(jq -n \
        --argjson exec "$execution_data" \
        --argjson feedback "$feedback_data" \
        --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
        '{
            timestamp: $ts,
            execution_id: $exec.execution_id,
            task_fingerprint: ($exec.task_description | @base64),
            agents_used: $exec.agents_used,
            tech_stack: $exec.tech_stack,
            success: false,
            errors: $exec.errors,
            failure_reason: $feedback.comments,
            recipe_used: $exec.recipe_used
        }')

    append_to_jsonl "$file" "$pattern"
    print_warning "📝 Recorded failure pattern to $file" >&2
}

# ============================================================================
# Agent Combination Recording
# ============================================================================

# Record agent combination usage
# Usage: record_agent_combination <agents_array> <success> <satisfaction>
record_agent_combination() {
    local agents="$1"
    local success="$2"
    local satisfaction="${3:-null}"

    local file="$KNOWLEDGE_DIR/agent-combinations.jsonl"

    # Build combination record
    local record=$(jq -n \
        --argjson agents "$agents" \
        --arg success "$success" \
        --arg satisfaction "$satisfaction" \
        --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
        '{
            timestamp: $ts,
            agents: $agents,
            success: ($success == "true"),
            satisfaction: (if $satisfaction == "null" then null else ($satisfaction | tonumber) end),
            combination_hash: ($agents | sort | join("-") | @base64)
        }')

    append_to_jsonl "$file" "$record"
    print_info "📊 Recorded agent combination" >&2
}

# ============================================================================
# Task Fingerprint Recording
# ============================================================================

# Record task fingerprint with metadata
# Usage: record_task_fingerprint <task_description> <keywords> <recipe_matched>
record_task_fingerprint() {
    local task="$1"
    local keywords="$2"
    local recipe="${3:-null}"

    local file="$KNOWLEDGE_DIR/task-fingerprints.jsonl"

    # Generate fingerprint
    local fingerprint=$(echo -n "$task" | md5 | cut -c1-16)

    # Build fingerprint record
    local record=$(jq -n \
        --arg task "$task" \
        --arg fingerprint "$fingerprint" \
        --argjson keywords "$keywords" \
        --arg recipe "$recipe" \
        --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
        '{
            timestamp: $ts,
            fingerprint: $fingerprint,
            task_description: $task,
            keywords: $keywords,
            recipe_matched: (if $recipe == "null" then null else $recipe end)
        }')

    append_to_jsonl "$file" "$record"
    print_info "🔑 Recorded task fingerprint: $fingerprint" >&2
}

# ============================================================================
# Query Functions
# ============================================================================

# Query similar successful patterns
# Usage: query_success_patterns <task_fingerprint> [limit]
query_success_patterns() {
    local fingerprint="$1"
    local limit="${2:-5}"

    local file="$KNOWLEDGE_DIR/success-patterns.jsonl"

    if [[ ! -f "$file" ]]; then
        echo "[]"
        return
    fi

    # Search for similar fingerprints
    local results=$(cat "$file" | \
        jq -s --arg fp "$fingerprint" --arg limit "$limit" '
            [
                .[] |
                select(.task_fingerprint == $fp)
            ] |
            sort_by(-.satisfaction) |
            limit($limit | tonumber; .[])
        ')

    echo "$results"
}

# Count total records in knowledge base
# Usage: count_knowledge_records
count_knowledge_records() {
    local total=0

    for file in success-patterns failure-patterns agent-combinations task-fingerprints; do
        local path="$KNOWLEDGE_DIR/${file}.jsonl"
        if [[ -f "$path" ]]; then
            local count=$(wc -l < "$path" | tr -d ' ')
            echo "  ${file}: $count records" >&2
            total=$((total + count))
        fi
    done

    echo "  Total: $total records" >&2
}

# ============================================================================
# Complete Recording Workflow
# ============================================================================

# Record complete execution with feedback
# Usage: record_execution <execution_data> <feedback_data>
record_execution() {
    local execution_data="$1"
    local feedback_data="$2"

    print_info "📝 Recording execution to knowledge base..." >&2

    # Extract key information
    local success=$(echo "$feedback_data" | jq -r '.success // false')
    local satisfaction=$(echo "$feedback_data" | jq -r '.satisfaction // null')
    local agents=$(echo "$execution_data" | jq -c '.agents_used // []')

    # Record pattern (success or failure)
    if [[ "$success" == "true" ]]; then
        record_success_pattern "$execution_data" "$feedback_data"
    else
        record_failure_pattern "$execution_data" "$feedback_data"
    fi

    # Record agent combination
    if [[ $(echo "$agents" | jq 'length') -gt 0 ]]; then
        record_agent_combination "$agents" "$success" "$satisfaction"
    fi

    # Record task fingerprint
    local task=$(echo "$execution_data" | jq -r '.task_description // "N/A"')
    local keywords=$(echo "$execution_data" | jq -c '.task_keywords // []')
    local recipe=$(echo "$execution_data" | jq -r '.recipe_used // null')

    record_task_fingerprint "$task" "$keywords" "$recipe"

    print_success "✨ Knowledge recording complete" >&2
}

# ============================================================================
# Main Entry Point (for testing)
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════╗"
    echo "║   Knowledge Recorder - Test Mode      ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"

    # Test data
    test_execution='{
        "execution_id": "test-123",
        "task_description": "Build a React app with TypeScript",
        "task_keywords": ["react", "typescript", "app"],
        "agents_used": ["frontend-developer", "typescript-pro"],
        "tech_stack": [{"name": "React"}, {"name": "TypeScript"}],
        "metrics": {"execution_time_seconds": 120},
        "errors": [],
        "recipe_used": "web-development"
    }'

    test_feedback='{
        "success": true,
        "satisfaction": 5,
        "comments": "Great work!"
    }'

    print_info "Testing execution recording..." >&2
    record_execution "$test_execution" "$test_feedback"

    echo "" >&2
    echo -e "${BLUE}Knowledge Base Statistics:${NC}" >&2
    count_knowledge_records

    echo "" >&2
    echo -e "${GREEN}════════════════════════════════════════${NC}" >&2
    echo -e "${BLUE}   Test Complete!${NC}" >&2
    echo -e "${GREEN}════════════════════════════════════════${NC}" >&2
fi
