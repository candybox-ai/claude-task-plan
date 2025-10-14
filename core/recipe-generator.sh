#!/bin/bash

# Recipe Generator
# Automatically generates Recipe YAML files from successful execution patterns
# Analyzes JSONL knowledge base to identify common patterns

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

# ============================================================================
# Helper Functions
# ============================================================================

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

# ============================================================================
# Knowledge Base Loading
# ============================================================================

# Load all JSONL knowledge base files
load_knowledge_base() {
    local kb_dir="${1:-$PROJECT_ROOT/evolution/knowledge}"

    local success_patterns=""
    local failure_patterns=""
    local agent_combinations=""
    local task_fingerprints=""

    # Load each file if exists
    if [[ -f "$kb_dir/success-patterns.jsonl" ]]; then
        success_patterns=$(cat "$kb_dir/success-patterns.jsonl" | jq -s '.')
    else
        success_patterns="[]"
    fi

    if [[ -f "$kb_dir/failure-patterns.jsonl" ]]; then
        failure_patterns=$(cat "$kb_dir/failure-patterns.jsonl" | jq -s '.')
    else
        failure_patterns="[]"
    fi

    if [[ -f "$kb_dir/agent-combinations.jsonl" ]]; then
        agent_combinations=$(cat "$kb_dir/agent-combinations.jsonl" | jq -s '.')
    else
        agent_combinations="[]"
    fi

    if [[ -f "$kb_dir/task-fingerprints.jsonl" ]]; then
        task_fingerprints=$(cat "$kb_dir/task-fingerprints.jsonl" | jq -s '.')
    else
        task_fingerprints="[]"
    fi

    # Combine into single object
    jq -n \
        --argjson success "$success_patterns" \
        --argjson failure "$failure_patterns" \
        --argjson combinations "$agent_combinations" \
        --argjson fingerprints "$task_fingerprints" \
        '{
            success_patterns: $success,
            failure_patterns: $failure,
            agent_combinations: $combinations,
            task_fingerprints: $fingerprints
        }'
}

# ============================================================================
# Pattern Analysis
# ============================================================================

# Find successful patterns that can be converted to Recipes
# Criteria: high success rate, high satisfaction, sufficient usage
find_recipe_candidates() {
    local knowledge_base="$1"
    local min_usage="${2:-3}"      # Minimum usage count
    local min_success_rate="${3:-0.7}"  # Minimum 70% success rate
    local min_satisfaction="${4:-4.0}"  # Minimum satisfaction score

    # Group success patterns by task fingerprint (or recipe if no fingerprint)
    echo "$knowledge_base" | jq --argjson min_usage "$min_usage" \
        --argjson min_rate "$min_success_rate" \
        --argjson min_sat "$min_satisfaction" '
        # Create fingerprint lookup from task_fingerprints
        (.task_fingerprints | map({(.fingerprint): {keywords: .keywords, category: (.category // "general")}}) | add // {}) as $fp_lookup
        |
        # Group success patterns by fingerprint or recipe
        .success_patterns
        | group_by(.task_fingerprint // .recipe_used)
        | map({
            fingerprint: (.[0].task_fingerprint // .[0].recipe_used),
            keywords: (
                if (.[0].task_fingerprint and $fp_lookup[.[0].task_fingerprint])
                then $fp_lookup[.[0].task_fingerprint].keywords
                else []
                end
            ),
            tech_stack: (
                [.[].tech_stack // [] | .[] | .name] | unique
            ),
            category: (
                if (.[0].task_fingerprint and $fp_lookup[.[0].task_fingerprint])
                then $fp_lookup[.[0].task_fingerprint].category
                else "general"
                end
            ),
            usage_count: length,
            executions: map(.execution_id),
            avg_satisfaction: (
                [.[] | .satisfaction // 0]
                | if length > 0 then (add / length) else 0 end
            ),
            success_count: ([.[] | select(.success == true)] | length),
            failure_count: ([.[] | select(.success == true | not)] | length)
        })
        | map(. + {
            success_rate: (
                if .usage_count > 0
                then (.success_count / .usage_count)
                else 0
                end
            )
        })
        # Filter by criteria
        | map(select(
            .usage_count >= $min_usage and
            .success_rate >= $min_rate and
            .avg_satisfaction >= $min_sat
        ))
        # Sort by score (usage * success_rate * satisfaction)
        | map(. + {
            score: (.usage_count * .success_rate * (.avg_satisfaction / 5.0))
        })
        | sort_by(-.score)
    '
}

# ============================================================================
# Agent Analysis
# ============================================================================

# Find most successful agent combinations for a fingerprint
find_best_agent_combinations() {
    local knowledge_base="$1"
    local fingerprint="$2"

    # Get agent combinations from success patterns with this fingerprint
    echo "$knowledge_base" | jq --arg fp "$fingerprint" '
        .success_patterns
        | map(select(.task_fingerprint == $fp or .recipe_used == $fp))
        | group_by(.agents_used | sort | @json)
        | map({
            agents: (.[0].agents_used // []),
            usage_count: length,
            success_count: ([.[] | select(.success == true)] | length),
            avg_satisfaction: (
                [.[] | .satisfaction // 0]
                | if length > 0 then (add / length) else 0 end
            )
        })
        | map(. + {
            success_rate: (
                if .usage_count > 0
                then (.success_count / .usage_count)
                else 0
                end
            )
        })
        | map(. + {
            score: (.usage_count * .success_rate * (.avg_satisfaction / 5.0))
        })
        | sort_by(-.score)
        | .[0:5]  # Top 5 combinations
    '
}

# ============================================================================
# Recipe Generation
# ============================================================================

# Generate Recipe YAML from pattern data
generate_recipe_yaml() {
    local pattern_data="$1"
    local agent_data="$2"
    local output_path="$3"

    local fingerprint=$(echo "$pattern_data" | jq -r '.fingerprint')
    local keywords=$(echo "$pattern_data" | jq -c '.keywords')
    local tech_stack=$(echo "$pattern_data" | jq -c '.tech_stack')
    local category=$(echo "$pattern_data" | jq -r '.category // "general"')
    local usage_count=$(echo "$pattern_data" | jq -r '.usage_count')
    local success_rate=$(echo "$pattern_data" | jq -r '.success_rate')
    local avg_satisfaction=$(echo "$pattern_data" | jq -r '.avg_satisfaction')

    # Generate recipe name from keywords
    local recipe_name=$(echo "$keywords" | jq -r '.[0:3] | join("-")' | sed 's/[^a-zA-Z0-9-]/-/g' | tr '[:upper:]' '[:lower:]')

    # Extract top agents
    local top_agents=$(echo "$agent_data" | jq -c '.[0].agents // []')

    # Build keywords list (deduplicated)
    local keyword_list=$(echo "$keywords" | jq -r '.[] | "    - \"" + . + "\""' | sort -u)

    # Build tech stack as additional keywords
    local tech_keywords=$(echo "$tech_stack" | jq -r '.[] | "    - \"" + . + "\""' | sort -u)

    # Combine and deduplicate
    local all_keywords=$(echo -e "$keyword_list\n$tech_keywords" | sort -u)

    # Build agent recommendations
    local agent_recommendations=""
    local priority=1
    for agent in $(echo "$top_agents" | jq -r '.[]'); do
        agent_recommendations+="      - name: \"$agent\"
        priority: $priority
        required: $(if [[ $priority -eq 1 ]]; then echo "true"; else echo "false"; fi)
        reason: \"High success rate in similar tasks\"
        conditions: null

"
        priority=$((priority + 1))
    done

    # Generate YAML
    cat > "$output_path" <<EOF
# Auto-generated Recipe
# Generated from ${usage_count} successful executions
# Success rate: $(printf "%.0f%%" "$(echo "$success_rate * 100" | awk '{print $1}')")
# Average satisfaction: $(printf "%.1f/5.0" "$avg_satisfaction")

metadata:
  name: "$(echo "$recipe_name" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1')"
  version: "1.0.0"
  description: "Auto-generated from successful execution patterns"
  category: "$category"
  tags: $(echo "$keywords" | jq -c '.[0:5]')
  author: "agentforge-auto"
  created_at: "$(date +%Y-%m-%d)"
  updated_at: "$(date +%Y-%m-%d)"

# 触发条件
triggers:
  keywords:
$all_keywords

  patterns:
    - "$(echo "$keywords" | jq -r '.[0]' | sed 's/ /.*/g')"

# 工作流增强
workflow:
  step_1_clarification:
    priority_questions:
      - "请确认任务的具体需求和目标"
      - "是否有特定的技术栈偏好？"
      - "Are there any specific requirements or constraints?"

  step_2_criteria:
    success_criteria:
      functional:
        - "所有功能按预期工作"
        - "All features work as expected"

      technical:
        - "代码质量良好，符合最佳实践"
        - "Good code quality and best practices"

      quality:
        - "测试通过"
        - "Tests passing"

    quality_indicators:
      - "✅ 代码可读性"
      - "✅ 适当的错误处理"
      - "✅ 文档完整"

  step_3_assessment:
    recommended_agents:
$agent_recommendations

    tech_stack_recommendations:
      primary:
$(echo "$tech_stack" | jq -r '.[] | "        - \"" + . + "\""')

  step_4_risks:
    common_risks:
      - risk: "需求理解偏差"
        probability: "中"
        impact: "高"
        mitigation: "充分沟通和确认需求"
        detection: "交付结果与预期不符"

  step_5_execution:
    key_milestones:
      - milestone: "需求确认完成"
        checkpoint: "所有疑问已解决"
      - milestone: "核心功能完成"
        checkpoint: "主要功能可演示"
      - milestone: "测试通过"
        checkpoint: "所有测试通过"

  step_6_verification:
    verification_checklist:
      functionality:
        - "✅ 功能完整"
        - "✅ 符合需求"

      code_quality:
        - "✅ 代码规范"
        - "✅ 适当注释"

      testing:
        - "✅ 测试覆盖"

# 统计数据（基于历史数据）
stats:
  usage_count: $usage_count
  success_count: $(echo "$pattern_data" | jq -r '.success_count')
  failure_count: $(echo "$pattern_data" | jq -r '.failure_count')
  success_rate: $(printf "%.2f" "$success_rate")
  avg_satisfaction: $(printf "%.2f" "$avg_satisfaction")
  avg_execution_time: null
  last_used: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  total_feedback: $usage_count

# 进化历史
evolution_history:
  - version: "1.0.0"
    date: "$(date +%Y-%m-%d)"
    changes: "Auto-generated from ${usage_count} successful executions"

# 元数据
meta:
  schema_version: "1.0"
  derived_from: "$fingerprint"
  confidence: $(awk "BEGIN {printf \"%.2f\", $success_rate * $avg_satisfaction / 5.0}")
  maintainer: "agentforge-auto"
  license: "MIT"
  auto_generated: true
  source_executions: $(echo "$pattern_data" | jq -c '.executions')
EOF

    print_success "Generated Recipe: $output_path"
    echo "$output_path"
}

# ============================================================================
# Main Recipe Generation Workflow
# ============================================================================

# Generate recipes from knowledge base
generate_recipes() {
    local kb_dir="${1:-$PROJECT_ROOT/evolution/knowledge}"
    local output_dir="${2:-$PROJECT_ROOT/recipes/learned}"
    local min_usage="${3:-3}"
    local min_success_rate="${4:-0.7}"
    local min_satisfaction="${5:-4.0}"

    print_info "Loading knowledge base from: $kb_dir" >&2

    # Load knowledge base
    local knowledge_base=$(load_knowledge_base "$kb_dir")

    # Check if we have any data
    local total_patterns=$(echo "$knowledge_base" | jq '.task_fingerprints | length')
    if [[ "$total_patterns" -eq 0 ]]; then
        print_warning "No task fingerprints found in knowledge base" >&2
        echo "[]"
        return 0
    fi

    print_info "Found $total_patterns task fingerprints in knowledge base" >&2

    # Find recipe candidates
    print_info "Analyzing patterns (min_usage=$min_usage, min_success_rate=$min_success_rate, min_satisfaction=$min_satisfaction)..." >&2
    local candidates=$(find_recipe_candidates "$knowledge_base" "$min_usage" "$min_success_rate" "$min_satisfaction")

    local candidate_count=$(echo "$candidates" | jq 'length')
    print_info "Found $candidate_count recipe candidates" >&2

    if [[ "$candidate_count" -eq 0 ]]; then
        print_warning "No patterns meet the criteria for Recipe generation" >&2
        echo "[]"
        return 0
    fi

    # Create output directory
    mkdir -p "$output_dir"

    # Generate recipes
    local generated_recipes="[]"
    local index=0

    while [[ $index -lt $candidate_count ]]; do
        local pattern=$(echo "$candidates" | jq ".[$index]")
        local fingerprint=$(echo "$pattern" | jq -r '.fingerprint')

        print_info "Generating Recipe for pattern: $fingerprint" >&2

        # Find best agent combinations
        local agent_data=$(find_best_agent_combinations "$knowledge_base" "$fingerprint")

        # Generate recipe filename
        local recipe_name=$(echo "$pattern" | jq -r '.keywords[0:3] | join("-")' | sed 's/[^a-zA-Z0-9-]/-/g' | tr '[:upper:]' '[:lower:]')
        local output_path="$output_dir/${recipe_name}.yaml"

        # Generate YAML
        local generated_file=$(generate_recipe_yaml "$pattern" "$agent_data" "$output_path" 2>&1)

        # Add to list
        generated_recipes=$(echo "$generated_recipes" | jq --arg file "$generated_file" '. + [$file]')

        index=$((index + 1))
    done

    print_success "Generated $candidate_count Recipes in: $output_dir" >&2
    echo "$generated_recipes"
}

# ============================================================================
# Recipe Statistics
# ============================================================================

# Get statistics about recipe generation potential
get_generation_stats() {
    local kb_dir="${1:-$PROJECT_ROOT/evolution/knowledge}"

    local knowledge_base=$(load_knowledge_base "$kb_dir")

    local total_fingerprints=$(echo "$knowledge_base" | jq '.task_fingerprints | length')
    local total_successes=$(echo "$knowledge_base" | jq '.success_patterns | length')
    local total_failures=$(echo "$knowledge_base" | jq '.failure_patterns | length')
    local total_combinations=$(echo "$knowledge_base" | jq '.agent_combinations | length')

    # Find candidates with different thresholds
    local candidates_strict=$(find_recipe_candidates "$knowledge_base" 5 0.8 4.5 | jq 'length')
    local candidates_normal=$(find_recipe_candidates "$knowledge_base" 3 0.7 4.0 | jq 'length')
    local candidates_relaxed=$(find_recipe_candidates "$knowledge_base" 2 0.6 3.5 | jq 'length')

    jq -n \
        --argjson total_fp "$total_fingerprints" \
        --argjson total_succ "$total_successes" \
        --argjson total_fail "$total_failures" \
        --argjson total_comb "$total_combinations" \
        --argjson cand_strict "$candidates_strict" \
        --argjson cand_normal "$candidates_normal" \
        --argjson cand_relaxed "$candidates_relaxed" \
        '{
            total_fingerprints: $total_fp,
            total_success_patterns: $total_succ,
            total_failure_patterns: $total_fail,
            total_agent_combinations: $total_comb,
            recipe_candidates: {
                strict: $cand_strict,
                normal: $cand_normal,
                relaxed: $cand_relaxed
            }
        }'
}

# ============================================================================
# Test Mode
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    print_info "Recipe Generator - Test Mode"
    echo ""

    # Check if knowledge base exists
    KB_DIR="$PROJECT_ROOT/evolution/knowledge"
    if [[ ! -d "$KB_DIR" ]]; then
        print_error "Knowledge base directory not found: $KB_DIR"
        exit 1
    fi

    # Show statistics
    print_info "📊 Knowledge Base Statistics:"
    stats=$(get_generation_stats "$KB_DIR")
    echo "$stats" | jq '.'
    echo ""

    # Generate recipes
    print_info "🏗️  Generating Recipes..."
    echo ""
    generated=$(generate_recipes "$KB_DIR" "$PROJECT_ROOT/recipes/learned" 3 0.7 4.0)
    echo ""

    # Show results
    count=$(echo "$generated" | jq 'length')
    if [[ "$count" -gt 0 ]]; then
        print_success "✨ Generated $count Recipe(s):"
        echo "$generated" | jq -r '.[]'
    else
        print_warning "No Recipes generated (insufficient data or patterns don't meet criteria)"
    fi

    echo ""
    print_success "Recipe Generator test complete!"
fi
