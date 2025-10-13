#!/bin/bash

# Recipe Matcher Module
# Intelligently matches user tasks to appropriate Recipes

set -e

# Source recipe loader if not already loaded
if ! declare -f load_recipe &>/dev/null; then
    _MATCHER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "$_MATCHER_DIR/recipe-loader.sh"
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
CONFIDENCE_THRESHOLD=${CONFIDENCE_THRESHOLD:-0.6}
MAX_ALTERNATIVES=${MAX_ALTERNATIVES:-3}

# ============================================================================
# Task Analysis Functions
# ============================================================================

# Extract keywords from task description
# Usage: extract_task_keywords <task_description>
extract_task_keywords() {
    local task="$1"

    # Convert to lowercase for matching
    local task_lower=$(echo "$task" | tr '[:upper:]' '[:lower:]')

    # Extract potential keywords (simplified approach)
    # Remove common words and extract meaningful terms
    echo "$task_lower" | \
        sed 's/[^a-z0-9\u4e00-\u9fa5 ]/ /g' | \
        tr ' ' '\n' | \
        grep -v '^$' | \
        grep -vE '^(a|an|the|is|are|was|were|be|been|have|has|had|do|does|did|will|would|could|should|can|may|might|must|我|是|的|了|在|和|与|或)$' | \
        sort -u
}

# Generate task fingerprint (hash)
# Usage: generate_task_fingerprint <task_description>
generate_task_fingerprint() {
    local task="$1"
    echo -n "$task" | md5 | cut -c1-16
}

# ============================================================================
# Recipe Matching Functions
# ============================================================================

# Match recipes by keywords
# Usage: match_by_keywords <task_description> <recipes_json>
# Returns: JSON array with match scores
match_by_keywords() {
    local task="$1"
    local recipes="$2"

    local task_keywords=$(extract_task_keywords "$task" | tr '\n' '|' | sed 's/|$//')

    # Use jq to do all the matching
    echo "$recipes" | jq --arg keywords "$task_keywords" '
        [
            .[] |
            . as $recipe |
            ($recipe.triggers.keywords // [] | map(ascii_downcase) | join("|")) as $recipe_kw |
            (
                ($keywords | split("|")) as $task_kw_arr |
                $task_kw_arr | map(
                    . as $kw |
                    if ($recipe_kw | test($kw; "i")) then 1 else 0 end
                ) | add
            ) as $match_count |
            if $match_count > 0 then
                $recipe + {keyword_score: $match_count}
            else
                empty
            end
        ]
    '
}

# Match recipes by regex patterns
# Usage: match_by_patterns <task_description> <recipes_json>
# Returns: JSON array with pattern match flags
match_by_patterns() {
    local task="$1"
    local recipes="$2"

    # Use jq to do all the pattern matching
    echo "$recipes" | jq --arg task "$task" '
        [
            .[] |
            . as $recipe |
            (
                ($recipe.triggers.patterns // []) | map(
                    . as $pattern |
                    if ($task | test($pattern; "i")) then 1 else 0 end
                ) | add // 0
            ) as $pattern_matches |
            if $pattern_matches > 0 then
                $recipe + {pattern_matches: $pattern_matches}
            else
                empty
            end
        ]
    '
}

# Calculate confidence score for each recipe match
# Usage: calculate_confidence <task> <matched_recipes_json>
# Returns: JSON array with confidence scores
calculate_confidence() {
    local task="$1"
    local matches="$2"

    # Confidence calculation factors:
    # - keyword_score: number of matched keywords (weight: 0.3)
    # - pattern_matches: number of matched patterns (weight: 0.4)
    # - recipe confidence: inherent recipe confidence (weight: 0.2)
    # - usage stats: success rate (weight: 0.1)

    echo "$matches" | jq '[
        .[] |
        {
            file: .file,
            metadata: .metadata,
            meta: .meta,
            stats: .stats,
            keyword_score: (.keyword_score // 0),
            pattern_matches: (.pattern_matches // 0),
            confidence: (
                ((.keyword_score // 0) * 0.03) +
                ((.pattern_matches // 0) * 0.4) +
                ((.meta.confidence // 0.5) * 0.2) +
                ((.stats.success_rate // 0) * 0.1)
            ) | (. * 100 | round / 100)
        }
    ] | sort_by(-.confidence)'
}

# Find matching recipes for a task
# Usage: find_matching_recipes <task_description> <recipes_json>
# Returns: JSON array of matched recipes with scores
find_matching_recipes() {
    local task="$1"
    local recipes="$2"

    print_info "🔍 Analyzing task and matching recipes..." >&2

    # Step 1: Keyword filtering
    local keyword_matches=$(match_by_keywords "$task" "$recipes")
    local keyword_count=$(echo "$keyword_matches" | jq 'length')
    print_info "   Found $keyword_count recipes by keywords" >&2

    # Step 2: Pattern matching
    local pattern_matches=$(match_by_patterns "$task" "$recipes")
    local pattern_count=$(echo "$pattern_matches" | jq 'length')
    print_info "   Found $pattern_count recipes by patterns" >&2

    # Step 3: Merge results
    local merged=$(echo "$keyword_matches" | jq --argjson patterns "$pattern_matches" '
        . as $keywords |
        $patterns |
        reduce .[] as $p (
            $keywords;
            . as $current |
            if any($current[]; .file == $p.file) then
                [.[] | if .file == $p.file then . + $p else . end]
            else
                . + [$p]
            end
        )
    ')

    # Step 4: Calculate confidence
    local scored=$(calculate_confidence "$task" "$merged")

    # Step 5: Filter by threshold
    local filtered=$(echo "$scored" | jq --arg threshold "$CONFIDENCE_THRESHOLD" '
        [.[] | select(.confidence >= ($threshold | tonumber))]
    ')

    local final_count=$(echo "$filtered" | jq 'length')
    print_success "✨ Found $final_count matching recipes" >&2

    echo "$filtered"
}

# ============================================================================
# User Selection Functions
# ============================================================================

# Display recipe match results
# Usage: display_recipe_matches <matches_json>
display_recipe_matches() {
    local matches="$1"
    local count=$(echo "$matches" | jq 'length')

    if [[ $count -eq 0 ]]; then
        echo -e "${YELLOW}No matching recipes found.${NC}" >&2
        return 1
    fi

    echo "" >&2
    echo -e "${CYAN}═══════════════════════════════════════${NC}" >&2
    echo -e "${BLUE}   📦 Found $count Matching Recipe(s)${NC}" >&2
    echo -e "${CYAN}════════════════════════════════════════${NC}" >&2
    echo "" >&2

    local index=1
    echo "$matches" | jq -c ".[] | select(.confidence >= $CONFIDENCE_THRESHOLD)" | head -n "$MAX_ALTERNATIVES" | while IFS= read -r match; do
        local name=$(echo "$match" | jq -r '.metadata.name')
        local version=$(echo "$match" | jq -r '.metadata.version')
        local description=$(echo "$match" | jq -r '.metadata.description')
        local confidence=$(echo "$match" | jq -r '.confidence')
        local success_rate=$(echo "$match" | jq -r '.stats.success_rate // 0')
        local usage_count=$(echo "$match" | jq -r '.stats.usage_count // 0')

        # Format confidence as percentage
        local conf_pct=$(echo "$confidence * 100" | bc | xargs printf "%.0f")
        local success_pct=$(echo "$success_rate * 100" | bc | xargs printf "%.0f")

        # Determine if this is recommended (highest confidence)
        local is_recommended=""
        if [[ $index -eq 1 ]]; then
            is_recommended=" ${GREEN}[推荐]${NC}"
        fi

        echo -e "   ${MAGENTA}[$index]${NC} ${BLUE}$name${NC} (v$version)${is_recommended}" >&2
        echo -e "       📝 $description" >&2
        echo -e "       🎯 置信度: ${conf_pct}%" >&2

        if [[ $usage_count -gt 0 ]]; then
            echo -e "       📊 成功率: ${success_pct}% | 使用: ${usage_count}次" >&2
        else
            echo -e "       📊 尚未使用" >&2
        fi

        echo "" >&2
        ((index++))
    done
}

# Prompt user to select a recipe
# Usage: prompt_recipe_selection <matches_json>
# Returns: Selected recipe JSON or empty string
prompt_recipe_selection() {
    local matches="$1"
    local count=$(echo "$matches" | jq 'length')

    if [[ $count -eq 0 ]]; then
        return 1
    fi

    # If only one match, auto-select
    if [[ $count -eq 1 ]]; then
        print_success "✅ Auto-selected the only matching recipe" >&2
        echo "$matches" | jq '.[0]'
        return 0
    fi

    # Display matches
    display_recipe_matches "$matches"

    # Prompt for selection
    local max_show=$(( count < MAX_ALTERNATIVES ? count : MAX_ALTERNATIVES ))
    echo -e "${CYAN}Select a recipe:${NC}" >&2
    echo -e "  [1-$max_show] Use numbered recipe" >&2
    echo -e "  [Enter] Use recommended (1)" >&2
    echo -e "  [n] Skip recipe, use adaptive mode" >&2
    echo "" >&2

    read -p "Your choice: " choice >&2

    # Handle choice
    if [[ -z "$choice" ]]; then
        choice=1
    fi

    if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le $max_show ]]; then
        echo "$matches" | jq ".[$((choice-1))]"
        return 0
    elif [[ "$choice" == "n" || "$choice" == "N" ]]; then
        echo ""
        return 1
    else
        print_error "Invalid selection" >&2
        echo ""
        return 1
    fi
}

# ============================================================================
# High-level Matching Workflow
# ============================================================================

# Complete matching workflow
# Usage: match_recipe_for_task <task_description> <recipes_json>
# Returns: Selected recipe JSON or empty string
match_recipe_for_task() {
    local task="$1"
    local recipes="$2"

    # Generate task fingerprint
    local fingerprint=$(generate_task_fingerprint "$task")
    print_info "🔑 Task fingerprint: $fingerprint" >&2

    # Find matches
    local matches=$(find_matching_recipes "$task" "$recipes")

    # Check if any matches found
    local match_count=$(echo "$matches" | jq 'length')

    if [[ $match_count -eq 0 ]]; then
        echo "" >&2
        print_warning "❌ No recipes matched this task" >&2
        print_info "💡 Will use adaptive mode (base workflow)" >&2
        echo ""
        return 1
    fi

    # Prompt for selection
    local selected=$(prompt_recipe_selection "$matches")

    if [[ -n "$selected" ]]; then
        local recipe_name=$(echo "$selected" | jq -r '.metadata.name')
        local recipe_file=$(echo "$selected" | jq -r '.file')
        print_success "✅ Selected: $recipe_name" >&2
        print_info "📄 File: $recipe_file" >&2
        echo "$selected"
        return 0
    else
        print_info "⏭️  Using adaptive mode" >&2
        echo ""
        return 1
    fi
}

# ============================================================================
# Main Entry Point (for testing)
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being run directly (not sourced)

    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════╗"
    echo "║    Recipe Matcher - Test Mode         ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"

    # Load recipes
    RECIPE_DIR="${RECIPE_DIR:-$(dirname "$0")/../recipes}"
    print_info "Loading recipes from: $RECIPE_DIR" >&2

    recipes=$(load_all_recipes "$RECIPE_DIR" 2>&1)
    recipe_count=$(echo "$recipes" | jq 'length')
    print_success "Loaded $recipe_count recipes" >&2

    echo "" >&2
    echo "════════════════════════════════════════" >&2

    # Test cases
    test_cases=(
        "使用 React 和 TypeScript 构建一个待办事项应用"
        "分析 sales_data.csv 并生成可视化报告"
        "Deploy my Next.js app to Vercel with CI/CD"
        "Create a REST API with FastAPI and PostgreSQL"
        "完全不相关的任务测试"
    )

    for test_task in "${test_cases[@]}"; do
        echo "" >&2
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" >&2
        echo -e "${BLUE}Test Task:${NC} $test_task" >&2
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" >&2

        # Simulate user selecting option 1 automatically
        selected=$(echo "1" | match_recipe_for_task "$test_task" "$recipes" 2>&1 >/dev/null)

        echo "" >&2
        sleep 1
    done

    echo "" >&2
    echo -e "${GREEN}════════════════════════════════════════${NC}" >&2
    echo -e "${BLUE}   Test Complete!${NC}" >&2
    echo -e "${GREEN}════════════════════════════════════════${NC}" >&2
fi
