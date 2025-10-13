#!/bin/bash

# Prompt Builder Module
# Constructs enhanced prompts by combining base framework + Recipe + Agent recommendations

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
_BUILDER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
META_PROTOCOL_FILE="${META_PROTOCOL_FILE:-$_BUILDER_DIR/../core/meta-protocol.yaml}"

# Utility functions
print_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1" >&2; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1" >&2; }
print_info() { echo -e "${BLUE}[INFO]${NC} $1" >&2; }

# ============================================================================
# Base Framework Loading
# ============================================================================

# Load base 6-step framework
# Usage: load_base_framework <language>
# Returns: Base workflow text
load_base_framework() {
    local lang="${1:-en}"

    if [[ "$lang" == "zh" ]]; then
        cat <<'EOF'
请按照以下步骤执行，确保任务100%按期望完成：

1. 【需求澄清阶段】
   如果对任务描述有任何疑问或需要更多信息，请先提问解决疑问。
   不要假设任何细节，确保完全理解任务要求。

2. 【需求确认与成功标准定义】
   澄清疑问后，请：
   - 明确重述理解的任务需求
   - 详细定义"成功完成"的具体标准
   - 确定可衡量的交付成果和质量指标
   - 识别潜在的边界条件和约束
   - 等待我确认需求理解和成功标准

3. 【可行性评估与方案制定】
   需求确认后，进行：
   - 评估所需的专业Agent类型和技术栈
   - 检查Agent可用性，如不可用则搜索安装或寻找替代方案
   - 分析技术可行性和资源需求
   - 制定详细的实施方案和执行策略
   - 设计并行/串行的最优调度策略

4. 【方案确认与风险评估】
   方案制定后：
   - 展示完整的执行方案（Agent选择、执行顺序、时间预估）
   - 识别潜在风险点和失败场景
   - 制定风险缓解措施和备选方案
   - 确保方案100%可执行且能达成目标
   - 等待最终方案确认

5. 【执行监控阶段】
   方案确认后开始执行：
   - 按计划调度和执行各Agent任务
   - 实时监控执行进度和状态
   - 主动报告关键节点和异常情况
   - 遇到问题时立即启动风险缓解措施
   - 确保执行过程可控可追溯

6. 【交付验证阶段】
   执行完成后严格验证：
   - 对照成功标准逐项检查交付成果
   - 验证结果是否100%符合期望需求
   - 进行质量评估和完整性检查
   - 如不满足标准，分析根因并重新优化
   - 直到完全满足期望才视为任务完成

目标：生成完全符合我期望的高质量结果。
EOF
    else
        cat <<'EOF'
Please execute following steps to ensure 100% task completion as expected:

1. 【Requirement Clarification】
   If there are any questions or need more information about task description, ask questions first.
   Don't assume any details, ensure complete understanding of requirements.

2. 【Requirement Confirmation & Success Criteria Definition】
   After clarification, please:
   - Clearly restate understood task requirements
   - Define specific standards for "successful completion"
   - Determine measurable deliverables and quality indicators
   - Identify potential boundary conditions and constraints
   - Wait for confirmation of requirement understanding and success criteria

3. 【Feasibility Assessment & Solution Design】
   After requirement confirmation, proceed with:
   - Evaluate required professional agent types and tech stack
   - Check agent availability, search/install if unavailable, or find alternatives
   - Analyze technical feasibility and resource requirements
   - Develop detailed implementation plan and execution strategy
   - Design optimal parallel/serial scheduling strategy

4. 【Solution Confirmation & Risk Assessment】
   After solution design:
   - Display complete execution plan (agent selection, sequence, time estimation)
   - Identify potential risks and failure scenarios
   - Develop risk mitigation measures and backup plans
   - Ensure solution is 100% executable and can achieve goals
   - Wait for final solution confirmation

5. 【Execution Monitoring】
   After solution confirmation, start execution:
   - Schedule and execute agent tasks according to plan
   - Monitor execution progress and status in real-time
   - Proactively report key milestones and exceptions
   - Immediately activate risk mitigation when problems occur
   - Ensure execution process is controllable and traceable

6. 【Delivery Verification】
   After execution completion, strictly verify:
   - Check deliverables against success criteria item by item
   - Verify if results 100% meet expected requirements
   - Conduct quality assessment and completeness check
   - If standards not met, analyze root cause and re-optimize
   - Consider task complete only when expectations are fully satisfied

Goal: Generate high-quality results that completely meet your expectations.
EOF
    fi
}

# ============================================================================
# Recipe Enhancement Functions
# ============================================================================

# Extract workflow enhancements from Recipe
# Usage: extract_recipe_workflow <recipe_json> <language>
# Returns: Recipe-specific workflow enhancements
extract_recipe_workflow() {
    local recipe="$1"
    local lang="${2:-en}"

    # Check if recipe has workflow section
    if [[ $(echo "$recipe" | jq 'has("workflow")') != "true" ]]; then
        echo ""
        return
    fi

    # Extract relevant workflow enhancements
    local enhancements=""

    # Step 3 enhancements (recommended agents)
    local agents=$(echo "$recipe" | jq -r '.workflow.step_3_assessment.recommended_agents // [] |
        map("   - " + .name + " (优先级: " + (.priority | tostring) + ") - " + .reason) |
        join("\n")')

    if [[ -n "$agents" && "$agents" != "null" ]]; then
        if [[ "$lang" == "zh" ]]; then
            enhancements="${enhancements}\n\n【推荐 Agent】：\n${agents}"
        else
            enhancements="${enhancements}\n\n【Recommended Agents】:\n${agents}"
        fi
    fi

    # Step 4 enhancements (risk points)
    local risks=$(echo "$recipe" | jq -r '.workflow.step_4_risks.common_risks // [] |
        map("   - " + .) |
        join("\n")')

    if [[ -n "$risks" && "$risks" != "null" ]]; then
        if [[ "$lang" == "zh" ]]; then
            enhancements="${enhancements}\n\n【常见风险】：\n${risks}"
        else
            enhancements="${enhancements}\n\n【Common Risks】:\n${risks}"
        fi
    fi

    echo -e "$enhancements"
}

# ============================================================================
# Agent Recommendations Functions
# ============================================================================

# Build agent recommendation section
# Usage: build_agent_recommendations <agents_json> <language>
# Returns: Formatted agent recommendations text
build_agent_recommendations() {
    local agents="$1"
    local lang="${2:-en}"

    # Check if agents array is empty
    if [[ $(echo "$agents" | jq 'length') -eq 0 ]]; then
        echo ""
        return
    fi

    local recommendations=""

    if [[ "$lang" == "zh" ]]; then
        recommendations="

════════════════════════════════════════
推荐使用以下 Agent 完成此任务：
════════════════════════════════════════
"
    else
        recommendations="

════════════════════════════════════════
Recommended Agents for this task:
════════════════════════════════════════
"
    fi

    # Format each agent
    while IFS= read -r agent; do
        local name=$(echo "$agent" | jq -r '.name')
        local priority=$(echo "$agent" | jq -r '.priority // "N/A"')
        local reason=$(echo "$agent" | jq -r '.reason // "N/A"')
        local required=$(echo "$agent" | jq -r '.required // false')

        local required_marker=""
        if [[ "$required" == "true" ]]; then
            if [[ "$lang" == "zh" ]]; then
                required_marker=" [必需]"
            else
                required_marker=" [Required]"
            fi
        fi

        recommendations="${recommendations}
${priority}. ${name}${required_marker}
   ${reason}
"
    done < <(echo "$agents" | jq -c '.[]')

    if [[ "$lang" == "zh" ]]; then
        recommendations="${recommendations}
════════════════════════════════════════
"
    else
        recommendations="${recommendations}
════════════════════════════════════════
"
    fi

    echo "$recommendations"
}

# ============================================================================
# Prompt Construction Functions
# ============================================================================

# Build complete enhanced prompt
# Usage: build_prompt <task_description> <recipe_json> <agents_json> <language>
# Returns: Complete prompt text
build_prompt() {
    local task="$1"
    local recipe="${2:-{}}"
    local agents="${3:-[]}"
    local lang="${4:-en}"

    print_info "🏗️  Building enhanced prompt..." >&2

    # 1. Start with task description
    local prompt=""
    if [[ "$lang" == "zh" ]]; then
        prompt="任务描述：${task}\n\n"
    else
        prompt="Task Description: ${task}\n\n"
    fi

    # 2. Add agent recommendations if available
    local agent_section=$(build_agent_recommendations "$agents" "$lang")
    if [[ -n "$agent_section" ]]; then
        prompt="${prompt}${agent_section}\n"
        print_info "   ✅ Added agent recommendations" >&2
    fi

    # 3. Add base framework
    local framework=$(load_base_framework "$lang")
    prompt="${prompt}${framework}\n"
    print_info "   ✅ Added base 6-step framework" >&2

    # 4. Add Recipe enhancements if available
    if [[ "$recipe" != "{}" ]] && [[ $(echo "$recipe" | jq 'type') == "object" ]]; then
        local recipe_enhancements=$(extract_recipe_workflow "$recipe" "$lang")
        if [[ -n "$recipe_enhancements" ]]; then
            prompt="${prompt}${recipe_enhancements}\n"
            print_info "   ✅ Added Recipe-specific enhancements" >&2
        fi
    fi

    # 5. Add Recipe metadata as context
    if [[ "$recipe" != "{}" ]] && [[ $(echo "$recipe" | jq 'has("metadata")') == "true" ]]; then
        local recipe_name=$(echo "$recipe" | jq -r '.metadata.name // "N/A"')
        local recipe_desc=$(echo "$recipe" | jq -r '.metadata.description // "N/A"')

        if [[ "$lang" == "zh" ]]; then
            prompt="${prompt}\n\n[使用 Recipe: ${recipe_name}]
[描述: ${recipe_desc}]\n"
        else
            prompt="${prompt}\n\n[Using Recipe: ${recipe_name}]
[Description: ${recipe_desc}]\n"
        fi

        print_info "   ✅ Added Recipe metadata" >&2
    fi

    print_success "✨ Prompt construction complete" >&2

    echo -e "$prompt"
}

# Detect language from task description
# Usage: detect_language <task_description>
# Returns: "zh" or "en"
detect_language() {
    local task="$1"

    # Check for Chinese characters
    if [[ "$task" =~ [一-龯] ]]; then
        echo "zh"
    else
        echo "en"
    fi
}

# ============================================================================
# Main Entry Point (for testing)
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being run directly (not sourced)

    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════╗"
    echo "║    Prompt Builder - Test Mode         ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"

    # Test Case 1: English task with agents
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" >&2
    echo -e "${BLUE}Test 1: English task with agents${NC}" >&2
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" >&2

    test_task_en="Build a React application with TypeScript and user authentication"
    test_agents_en='[
        {"name": "frontend-developer", "priority": 1, "reason": "Specialized in React development", "required": true},
        {"name": "typescript-pro", "priority": 2, "reason": "Type-safe development support", "required": false}
    ]'

    prompt_en=$(build_prompt "$test_task_en" "{}" "$test_agents_en" "en")

    echo "" >&2
    echo -e "${YELLOW}Generated Prompt (first 500 chars):${NC}" >&2
    echo "$prompt_en" | head -c 500
    echo -e "\n..." >&2

    # Test Case 2: Chinese task with Recipe
    echo "" >&2
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" >&2
    echo -e "${BLUE}Test 2: Chinese task with Recipe${NC}" >&2
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" >&2

    test_task_zh="分析销售数据并生成可视化报告"
    test_recipe_zh='{
        "metadata": {
            "name": "Data Analysis",
            "description": "数据分析和可视化工作流"
        },
        "workflow": {
            "step_3_assessment": {
                "recommended_agents": [
                    {"name": "data-scientist", "priority": 1, "reason": "数据分析专家", "required": true},
                    {"name": "python-pro", "priority": 2, "reason": "Python 工具支持", "required": false}
                ]
            },
            "step_4_risks": {
                "common_risks": [
                    "数据格式不兼容",
                    "缺失值处理",
                    "可视化性能问题"
                ]
            }
        }
    }'

    prompt_zh=$(build_prompt "$test_task_zh" "$test_recipe_zh" "[]" "zh")

    echo "" >&2
    echo -e "${YELLOW}Generated Prompt (first 500 chars):${NC}" >&2
    echo "$prompt_zh" | head -c 500
    echo -e "\n..." >&2

    echo "" >&2
    echo -e "${GREEN}════════════════════════════════════════${NC}" >&2
    echo -e "${BLUE}   Test Complete!${NC}" >&2
    echo -e "${GREEN}════════════════════════════════════════${NC}" >&2
fi
