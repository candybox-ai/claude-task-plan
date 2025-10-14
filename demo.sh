#!/bin/bash

# AgentForge Demo
# Showcases the Recipe system, agent discovery, and prompt building

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  AgentForge v2.0 Demo     ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""

# ============================================================================
# Demo 1: List Available Recipes
# ============================================================================

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📚 Demo 1: Available Recipes${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

source core/recipe-loader.sh 2>/dev/null

recipes=$(load_all_recipes "recipes/official" 2>/dev/null)
recipe_count=$(echo "$recipes" | jq 'length')

echo -e "${YELLOW}Found $recipe_count official Recipes:${NC}"
echo ""

echo "$recipes" | jq -r '.[] | "  📋 " + .name + " (v" + .version + ")\n     Category: " + .category + "\n     Keywords: " + (.triggers.keywords[0:3] | join(", ")) + "\n"'

echo ""
read -p "Press Enter to continue..."
echo ""

# ============================================================================
# Demo 2: Recipe Matching
# ============================================================================

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🎯 Demo 2: Recipe Matching${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

source core/recipe-matcher.sh 2>/dev/null

test_tasks=(
    "Build a REST API with authentication"
    "Deploy my app to Kubernetes with CI/CD"
    "Create an iOS app with SwiftUI"
    "Build a React dashboard with charts"
)

for task in "${test_tasks[@]}"; do
    echo -e "${YELLOW}Task:${NC} \"$task\""

    matched=$(match_recipe_for_task "$task" "$recipes" 2>/dev/null)

    recipe_name=$(echo "$matched" | jq -r '.name // "General Workflow"')
    confidence=$(echo "$matched" | jq -r '.confidence // 0')

    echo -e "${GREEN}  ✓ Matched:${NC} $recipe_name (confidence: $confidence)"
    echo ""
done

echo ""
read -p "Press Enter to continue..."
echo ""

# ============================================================================
# Demo 3: Agent Discovery
# ============================================================================

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🔍 Demo 3: Agent Discovery (4-Tier)${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

source core/agent-finder.sh 2>/dev/null

test_searches=(
    "backend"
    "react"
    "kubernetes"
    "mobile"
)

echo -e "${YELLOW}Searching official agents...${NC}"
echo ""

for search_term in "${test_searches[@]}"; do
    echo -e "${CYAN}Search:${NC} \"$search_term\""

    results=$(search_official_agents "$search_term" 2>/dev/null)
    count=$(echo "$results" | jq 'length')

    if [[ "$count" -gt 0 ]]; then
        echo "$results" | jq -r '.[] | "  🤖 " + .name + " - " + .description'
    else
        echo -e "  ${YELLOW}No exact matches, would search GitHub/Community${NC}"
    fi
    echo ""
done

echo ""
read -p "Press Enter to continue..."
echo ""

# ============================================================================
# Demo 4: Prompt Building
# ============================================================================

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📝 Demo 4: Enhanced Prompt Generation${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

source core/prompt-builder.sh 2>/dev/null

task="Build a REST API for user management with JWT authentication"
matched_recipe=$(match_recipe_for_task "$task" "$recipes" 2>/dev/null)
recipe_name=$(echo "$matched_recipe" | jq -r '.name')

echo -e "${YELLOW}Task:${NC} \"$task\""
echo -e "${GREEN}Matched Recipe:${NC} $recipe_name"
echo ""

agents='[{"name":"backend-developer","priority":1},{"name":"security-auditor","priority":2}]'

prompt=$(build_prompt "$task" "$matched_recipe" "$agents" "en" 2>/dev/null)

echo -e "${YELLOW}Generated Prompt Preview (first 500 chars):${NC}"
echo -e "${BLUE}─────────────────────────────────────────${NC}"
echo "$prompt" | head -c 500
echo "..."
echo -e "${BLUE}─────────────────────────────────────────${NC}"
echo ""

prompt_length=$(echo "$prompt" | wc -c | tr -d ' ')
echo -e "${CYAN}Full prompt length: $prompt_length characters${NC}"
echo ""

echo ""
read -p "Press Enter to continue..."
echo ""

# ============================================================================
# Demo 5: Recipe Statistics
# ============================================================================

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📊 Demo 5: Recipe Collection Statistics${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

source core/optimizer.sh 2>/dev/null

stats=$(get_recipe_stats "recipes" 2>/dev/null)

echo "$stats" | jq -r '
"Total Recipes: " + (.total_recipes | tostring) + "\n" +
"\nBy Category:" +
(
  .by_category | to_entries | map(
    "\n  • " + .key + ": " + (.value | tostring)
  ) | join("")
) +
"\n\nTotal Usage: " + (.total_usage | tostring) + " executions"
'

echo ""

# ============================================================================
# Demo Complete
# ============================================================================

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✨ Demo Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}Key Features Demonstrated:${NC}"
echo -e "  ✅ Recipe YAML loading and parsing"
echo -e "  ✅ Intelligent task-to-Recipe matching"
echo -e "  ✅ 4-tier agent discovery system"
echo -e "  ✅ Enhanced prompt generation with Recipe context"
echo -e "  ✅ Recipe collection statistics"
echo ""
echo -e "${YELLOW}Try it yourself:${NC}"
echo -e "  ${BLUE}./bin/agentforge \"Build a mobile app with Flutter\"${NC}"
echo ""
echo -e "${CYAN}Documentation:${NC} README.md"
echo -e "${CYAN}Recipes:${NC} recipes/official/"
echo -e "${CYAN}Tests:${NC} bash tests/integration-test.sh"
echo ""
