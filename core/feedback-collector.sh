#!/bin/bash

# Feedback Collector Module
# Collects user feedback after task execution with three modes: immediate, delayed, optional

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
_FEEDBACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PENDING_FEEDBACK_DIR="${PENDING_FEEDBACK_DIR:-$_FEEDBACK_DIR/../logs/feedback/pending}"
COMPLETED_FEEDBACK_DIR="${COMPLETED_FEEDBACK_DIR:-$_FEEDBACK_DIR/../logs/feedback/completed}"
FEEDBACK_TIMEOUT=${FEEDBACK_TIMEOUT:-10}  # seconds

# Utility functions
print_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1" >&2; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1" >&2; }
print_info() { echo -e "${BLUE}[INFO]${NC} $1" >&2; }

# ============================================================================
# Feedback Collection Functions
# ============================================================================

# Prompt for immediate feedback
# Usage: collect_immediate_feedback <execution_id> <language>
# Returns: JSON feedback object
collect_immediate_feedback() {
    local execution_id="$1"
    local lang="${2:-en}"

    local feedback='{}'

    echo "" >&2
    echo -e "${CYAN}═══════════════════════════════════════${NC}" >&2

    if [[ "$lang" == "zh" ]]; then
        echo -e "${BLUE}   💬 任务完成反馈${NC}" >&2
        echo -e "${CYAN}═══════════════════════════════════════${NC}" >&2
        echo "" >&2

        # Success/Failure
        echo -ne "${YELLOW}任务是否成功完成? (y/n): ${NC}" >&2
        read -t "$FEEDBACK_TIMEOUT" -r success_input || success_input="skip"

        if [[ "$success_input" == "skip" ]]; then
            print_warning "超时，将记录为延迟反馈" >&2
            return 1
        fi

        local success="false"
        [[ "$success_input" =~ ^[Yy]$ ]] && success="true"

        feedback=$(echo "$feedback" | jq --arg success "$success" '. + {success: ($success | test("true"))}')

        # Satisfaction (only if successful)
        if [[ "$success" == "true" ]]; then
            echo -ne "${YELLOW}满意度评分 (1-5): ${NC}" >&2
            read -t "$FEEDBACK_TIMEOUT" -r satisfaction || satisfaction="skip"

            if [[ "$satisfaction" == "skip" ]]; then
                print_warning "超时，跳过满意度评分" >&2
                satisfaction="null"
            elif [[ "$satisfaction" =~ ^[1-5]$ ]]; then
                feedback=$(echo "$feedback" | jq --arg sat "$satisfaction" '. + {satisfaction: ($sat | tonumber)}')
            else
                feedback=$(echo "$feedback" | jq '. + {satisfaction: null}')
            fi
        fi

        # Comments
        echo -ne "${YELLOW}额外反馈 (回车跳过): ${NC}" >&2
        read -t "$FEEDBACK_TIMEOUT" -r comments || comments=""

        if [[ -n "$comments" ]]; then
            feedback=$(echo "$feedback" | jq --arg comments "$comments" '. + {comments: $comments}')
        fi

    else
        echo -e "${BLUE}   💬 Task Completion Feedback${NC}" >&2
        echo -e "${CYAN}═══════════════════════════════════════${NC}" >&2
        echo "" >&2

        # Success/Failure
        echo -ne "${YELLOW}Was the task completed successfully? (y/n): ${NC}" >&2
        read -t "$FEEDBACK_TIMEOUT" -r success_input || success_input="skip"

        if [[ "$success_input" == "skip" ]]; then
            print_warning "Timeout, will record as delayed feedback" >&2
            return 1
        fi

        local success="false"
        [[ "$success_input" =~ ^[Yy]$ ]] && success="true"

        feedback=$(echo "$feedback" | jq --arg success "$success" '. + {success: ($success | test("true"))}')

        # Satisfaction (only if successful)
        if [[ "$success" == "true" ]]; then
            echo -ne "${YELLOW}Satisfaction rating (1-5): ${NC}" >&2
            read -t "$FEEDBACK_TIMEOUT" -r satisfaction || satisfaction="skip"

            if [[ "$satisfaction" == "skip" ]]; then
                print_warning "Timeout, skipping satisfaction rating" >&2
                satisfaction="null"
            elif [[ "$satisfaction" =~ ^[1-5]$ ]]; then
                feedback=$(echo "$feedback" | jq --arg sat "$satisfaction" '. + {satisfaction: ($sat | tonumber)}')
            else
                feedback=$(echo "$feedback" | jq '. + {satisfaction: null}')
            fi
        fi

        # Comments
        echo -ne "${YELLOW}Additional comments (press Enter to skip): ${NC}" >&2
        read -t "$FEEDBACK_TIMEOUT" -r comments || comments=""

        if [[ -n "$comments" ]]; then
            feedback=$(echo "$feedback" | jq --arg comments "$comments" '. + {comments: $comments}')
        fi
    fi

    # Add metadata
    feedback=$(echo "$feedback" | jq --arg id "$execution_id" --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" '
        . + {
            execution_id: $id,
            feedback_timestamp: $ts,
            feedback_mode: "immediate"
        }
    ')

    echo "" >&2
    print_success "✅ 反馈已记录" >&2
    echo "$feedback"
}

# Prompt user for feedback mode selection
# Usage: prompt_feedback_mode <execution_id> <language>
# Returns: 0 for immediate, 1 for delayed, 2 for skip
prompt_feedback_mode() {
    local execution_id="$1"
    local lang="${2:-en}"

    echo "" >&2
    echo -e "${CYAN}═══════════════════════════════════════${NC}" >&2

    if [[ "$lang" == "zh" ]]; then
        echo -e "${BLUE}   💬 提供反馈${NC}" >&2
        echo -e "${CYAN}═══════════════════════════════════════${NC}" >&2
        echo "" >&2
        echo -e "${YELLOW}选择反馈方式：${NC}" >&2
        echo -e "  ${GREEN}[1]${NC} 立即提供反馈 (推荐)" >&2
        echo -e "  ${BLUE}[2]${NC} 稍后提供 (使用: agentforge feedback $execution_id)" >&2
        echo -e "  ${MAGENTA}[3]${NC} 跳过反馈" >&2
        echo "" >&2
        echo -ne "${YELLOW}您的选择 (默认: 1): ${NC}" >&2
    else
        echo -e "${BLUE}   💬 Provide Feedback${NC}" >&2
        echo -e "${CYAN}═══════════════════════════════════════${NC}" >&2
        echo "" >&2
        echo -e "${YELLOW}Choose feedback mode:${NC}" >&2
        echo -e "  ${GREEN}[1]${NC} Provide feedback now (recommended)" >&2
        echo -e "  ${BLUE}[2]${NC} Provide later (use: agentforge feedback $execution_id)" >&2
        echo -e "  ${MAGENTA}[3]${NC} Skip feedback" >&2
        echo "" >&2
        echo -ne "${YELLOW}Your choice (default: 1): ${NC}" >&2
    fi

    local choice=""
    read -t "$FEEDBACK_TIMEOUT" -r choice || choice="1"

    case "$choice" in
        1|"")
            return 0  # Immediate
            ;;
        2)
            return 1  # Delayed
            ;;
        3)
            return 2  # Skip
            ;;
        *)
            return 0  # Default to immediate
            ;;
    esac
}

# ============================================================================
# Delayed Feedback Functions
# ============================================================================

# Save pending feedback request
# Usage: save_pending_feedback <execution_id> <execution_data>
save_pending_feedback() {
    local execution_id="$1"
    local execution_data="$2"

    mkdir -p "$PENDING_FEEDBACK_DIR"

    local pending_file="$PENDING_FEEDBACK_DIR/${execution_id}.json"

    echo "$execution_data" | jq . > "$pending_file"

    print_success "💾 已保存待反馈记录: $pending_file" >&2
    echo "$pending_file"
}

# List all pending feedback requests
# Usage: list_pending_feedback
# Returns: JSON array of pending feedback IDs
list_pending_feedback() {
    if [[ ! -d "$PENDING_FEEDBACK_DIR" ]]; then
        echo "[]"
        return
    fi

    local pending="[]"

    while IFS= read -r file; do
        [[ -z "$file" ]] && continue

        local id=$(basename "$file" .json)
        local data=$(cat "$file")

        pending=$(echo "$pending" | jq --arg id "$id" --argjson data "$data" '. += [{
            execution_id: $id,
            task_description: $data.task_description,
            timestamp: $data.execution_timestamp
        }]')
    done < <(find "$PENDING_FEEDBACK_DIR" -name "*.json" 2>/dev/null || true)

    echo "$pending"
}

# Collect delayed feedback for a specific execution
# Usage: collect_delayed_feedback <execution_id> <language>
collect_delayed_feedback() {
    local execution_id="$1"
    local lang="${2:-en}"

    local pending_file="$PENDING_FEEDBACK_DIR/${execution_id}.json"

    if [[ ! -f "$pending_file" ]]; then
        print_error "Pending feedback not found for ID: $execution_id" >&2
        return 1
    fi

    # Load execution data
    local execution_data=$(cat "$pending_file")
    local task=$(echo "$execution_data" | jq -r '.task_description // "N/A"')

    echo "" >&2
    echo -e "${CYAN}═══════════════════════════════════════${NC}" >&2
    if [[ "$lang" == "zh" ]]; then
        echo -e "${BLUE}   💬 延迟反馈收集${NC}" >&2
        echo -e "${CYAN}═══════════════════════════════════════${NC}" >&2
        echo "" >&2
        echo -e "${YELLOW}任务:${NC} $task" >&2
    else
        echo -e "${BLUE}   💬 Delayed Feedback Collection${NC}" >&2
        echo -e "${CYAN}═══════════════════════════════════════${NC}" >&2
        echo "" >&2
        echo -e "${YELLOW}Task:${NC} $task" >&2
    fi

    # Collect feedback (same as immediate, but no timeout)
    local feedback=$(collect_immediate_feedback "$execution_id" "$lang")

    # Update feedback mode
    feedback=$(echo "$feedback" | jq '. + {feedback_mode: "delayed"}')

    # Move from pending to completed
    mkdir -p "$COMPLETED_FEEDBACK_DIR"
    local completed_file="$COMPLETED_FEEDBACK_DIR/${execution_id}.json"

    echo "$feedback" | jq . > "$completed_file"
    rm -f "$pending_file"

    print_success "✅ 反馈已保存" >&2
    echo "$feedback"
}

# ============================================================================
# Feedback Storage Functions
# ============================================================================

# Append feedback to knowledge base
# Usage: append_feedback_to_knowledge <feedback_json>
append_feedback_to_knowledge() {
    local feedback="$1"
    local knowledge_dir="$_FEEDBACK_DIR/../evolution/knowledge"

    mkdir -p "$knowledge_dir"

    # Determine which file to append to based on success
    local success=$(echo "$feedback" | jq -r '.success // false')

    if [[ "$success" == "true" ]]; then
        local file="$knowledge_dir/success-patterns.jsonl"
    else
        local file="$knowledge_dir/failure-patterns.jsonl"
    fi

    # Append as JSONL (one JSON object per line)
    echo "$feedback" | jq -c . >> "$file"

    print_info "📝 已追加到知识库: $file" >&2
}

# ============================================================================
# Main Workflow Functions
# ============================================================================

# Complete feedback workflow
# Usage: handle_feedback <execution_id> <execution_data> <language>
# Returns: Feedback JSON or empty string
handle_feedback() {
    local execution_id="$1"
    local execution_data="$2"
    local lang="${3:-en}"

    # Prompt for feedback mode
    prompt_feedback_mode "$execution_id" "$lang"
    local mode=$?

    case $mode in
        0)  # Immediate
            local feedback=$(collect_immediate_feedback "$execution_id" "$lang")
            if [[ $? -eq 0 ]] && [[ -n "$feedback" ]]; then
                append_feedback_to_knowledge "$feedback"
                echo "$feedback"
                return 0
            else
                # Timeout or error, fall back to delayed
                save_pending_feedback "$execution_id" "$execution_data"
                return 1
            fi
            ;;
        1)  # Delayed
            save_pending_feedback "$execution_id" "$execution_data"
            if [[ "$lang" == "zh" ]]; then
                print_info "使用以下命令稍后提供反馈:" >&2
                echo -e "${CYAN}  agentforge feedback $execution_id${NC}" >&2
            else
                print_info "Provide feedback later using:" >&2
                echo -e "${CYAN}  agentforge feedback $execution_id${NC}" >&2
            fi
            return 1
            ;;
        2)  # Skip
            if [[ "$lang" == "zh" ]]; then
                print_warning "已跳过反馈收集" >&2
            else
                print_warning "Feedback collection skipped" >&2
            fi
            return 2
            ;;
    esac
}

# ============================================================================
# Main Entry Point (for testing)
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being run directly (not sourced)

    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════╗"
    echo "║   Feedback Collector - Test Mode      ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"

    # Test Case 1: Immediate feedback
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" >&2
    echo -e "${BLUE}Test 1: Immediate feedback (simulated)${NC}" >&2
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" >&2

    test_execution_id="test-exec-$(date +%s)"
    test_execution_data='{
        "execution_id": "'$test_execution_id'",
        "task_description": "Build a React app",
        "execution_timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"
    }'

    # Simulate immediate feedback (will timeout and fall to delayed)
    print_info "Testing with timeout (will auto-select delayed mode)..." >&2
    FEEDBACK_TIMEOUT=2 handle_feedback "$test_execution_id" "$test_execution_data" "en"

    echo "" >&2
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" >&2
    echo -e "${BLUE}Test 2: List pending feedback${NC}" >&2
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" >&2

    pending=$(list_pending_feedback)
    echo "$pending" | jq .

    echo "" >&2
    echo -e "${GREEN}════════════════════════════════════════${NC}" >&2
    echo -e "${BLUE}   Test Complete!${NC}" >&2
    echo -e "${GREEN}════════════════════════════════════════${NC}" >&2
fi
