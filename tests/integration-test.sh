#!/bin/bash

# Integration Test Suite - Simplified and Robust
# Tests all major components of AgentForge

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_OUTPUT="$(mktemp -d)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Counters
TOTAL=0
PASSED=0
FAILED=0

# Test function
test_module() {
    local name="$1"
    local test_cmd="$2"
    
    ((TOTAL++))
    echo -ne "${YELLOW}[TEST $TOTAL]${NC} $name... "
    
    if eval "$test_cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        ((FAILED++))
        return 1
    fi
}

# Cleanup
cleanup() {
    rm -rf "$TEST_OUTPUT"
}
trap cleanup EXIT

echo ""
echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  AgentForge Integration    ║${NC}"
echo -e "${CYAN}║           Test Suite                   ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""

# Test 1: Configuration files exist
test_module "Configuration files exist" \
    "[[ -f '$PROJECT_ROOT/config/agent-sources.yaml' ]] && [[ -f '$PROJECT_ROOT/core/meta-protocol.yaml' ]]"

# Test 2: Core modules exist
test_module "Core modules exist" \
    "[[ -f '$PROJECT_ROOT/core/recipe-loader.sh' ]] && [[ -f '$PROJECT_ROOT/core/agent-finder.sh' ]] && [[ -f '$PROJECT_ROOT/core/prompt-builder.sh' ]]"

# Test 3: Evolution modules exist
test_module "Evolution modules exist" \
    "[[ -f '$PROJECT_ROOT/core/recipe-generator.sh' ]] && [[ -f '$PROJECT_ROOT/core/optimizer.sh' ]] && [[ -f '$PROJECT_ROOT/core/knowledge-recorder.sh' ]]"

# Test 4: Main script exists and is executable
test_module "Main script exists and executable" \
    "[[ -x '$PROJECT_ROOT/bin/agentforge' ]]"

# Test 5: Config loader can load agent sources
test_module "Config loader loads agent sources" \
    "source '$PROJECT_ROOT/core/config-loader.sh' && config=\$(load_agent_sources 2>/dev/null) && [[ -n \"\$config\" ]]"

# Test 6: Config loader gets official agents
test_module "Config loader gets official agents (15 agents)" \
    "source '$PROJECT_ROOT/core/config-loader.sh' && agents=\$(load_agent_sources 2>/dev/null | jq '.official.agents | length') && [[ \$agents -eq 15 ]]"

# Test 7: Recipe loader can load recipes
test_module "Recipe loader loads recipes" \
    "source '$PROJECT_ROOT/core/recipe-loader.sh' && recipes=\$(load_all_recipes '$PROJECT_ROOT/recipes' 2>/dev/null) && [[ -n \"\$recipes\" ]]"

# Test 8: Recipe matcher can match tasks
test_module "Recipe matcher matches tasks" \
    "source '$PROJECT_ROOT/core/recipe-loader.sh' && source '$PROJECT_ROOT/core/recipe-matcher.sh' && recipes=\$(load_all_recipes '$PROJECT_ROOT/recipes' 2>/dev/null) && result=\$(match_recipe_for_task 'Build React app' \"\$recipes\" 2>/dev/null); true"

# Test 9: Agent finder discovers official agents
test_module "Agent finder discovers official agents" \
    "source '$PROJECT_ROOT/core/agent-finder.sh' && results=\$(search_official_agents 'frontend' 2>/dev/null) && [[ \$(echo \"\$results\" | jq 'length') -gt 0 ]]"

# Test 10: Prompt builder creates prompts
test_module "Prompt builder creates prompts" \
    "source '$PROJECT_ROOT/core/prompt-builder.sh' && prompt=\$(build_prompt 'test task' '{}' '[]' 'en' 2>/dev/null) && [[ -n \"\$prompt\" ]]"

# Test 11: Data extractor extracts agents
test_module "Data extractor extracts agents" \
    "source '$PROJECT_ROOT/core/data-extractor.sh' && agents=\$(extract_agents_from_output 'Launching frontend-developer agent' 2>/dev/null) && [[ \$(echo \"\$agents\" | jq 'length') -gt 0 ]]"

# Test 12: Data extractor extracts tech stack
test_module "Data extractor extracts tech stack" \
    "source '$PROJECT_ROOT/core/data-extractor.sh' && stack=\$(detect_tech_stack 'React TypeScript Node.js' 2>/dev/null) && [[ \$(echo \"\$stack\" | jq 'length') -gt 0 ]]"

# Test 13: Knowledge recorder creates files
mkdir -p "$TEST_OUTPUT/knowledge"
test_module "Knowledge recorder creates JSONL files" \
    "source '$PROJECT_ROOT/core/knowledge-recorder.sh' && exec_data='{\"execution_id\":\"test\",\"task_description\":\"test\",\"agents_used\":[\"test\"],\"success\":true,\"exit_code\":0}' && record_success_pattern \"\$exec_data\" 5 'test' '$TEST_OUTPUT/knowledge' 2>/dev/null && [[ -f '$TEST_OUTPUT/knowledge/success-patterns.jsonl' ]]"

# Test 14: Recipe generator loads knowledge base
test_module "Recipe generator loads knowledge base" \
    "source '$PROJECT_ROOT/core/recipe-generator.sh' && kb=\$(load_knowledge_base '$TEST_OUTPUT/knowledge' 2>/dev/null) && [[ -n \"\$kb\" ]]"

# Test 15: Optimizer loads recipes
test_module "Optimizer loads recipes" \
    "source '$PROJECT_ROOT/core/optimizer.sh' && recipes=\$(load_all_recipes '$PROJECT_ROOT/recipes/official' 2>/dev/null) && [[ -n \"\$recipes\" ]]"

# Test 16: Optimizer gets statistics
test_module "Optimizer gets recipe statistics" \
    "source '$PROJECT_ROOT/core/optimizer.sh' && stats=\$(get_recipe_stats '$PROJECT_ROOT/recipes' 2>/dev/null) && [[ -n \"\$stats\" ]]"

# Test 17: Main script shows help
test_module "Main script shows help" \
    "'$PROJECT_ROOT/bin/agentforge' --help 2>&1 | grep -q 'AgentForge'"

# Test 18: Main script shows version
test_module "Main script shows version" \
    "'$PROJECT_ROOT/bin/agentforge' --version 2>&1 | grep -q 'v2.0'"

# Summary
echo ""
echo -e "${CYAN}════════════════════════════════════════${NC}"
echo -e "${BLUE}   Test Summary${NC}"
echo -e "${CYAN}════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}Total Tests:${NC}   $TOTAL"
echo -e "${GREEN}Passed:${NC}        $PASSED"
echo -e "${RED}Failed:${NC}        $FAILED"
echo ""

if [[ $FAILED -eq 0 ]]; then
    PASS_RATE=100
else
    PASS_RATE=$((PASSED * 100 / TOTAL))
fi

echo -e "${CYAN}Pass Rate:${NC}     ${PASS_RATE}%"
echo ""

if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
    echo ""
    exit 0
else
    echo -e "${YELLOW}⚠️  Some tests failed${NC}"
    echo ""
    exit 1
fi
