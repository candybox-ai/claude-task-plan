#!/bin/bash

# Quick Demo - Claude Agent Dispatch v2.0

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  🔥 AgentForge v2.0 Demo              ║${NC}"
echo -e "${GREEN}║  Self-Evolving Agent Orchestration    ║${NC}"
echo -e "${GREEN}║  Forge your workflow, evolve agents   ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""

# ============================================================================
# Demo 1: System Overview
# ============================================================================

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📚 1. System Components${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}Core Modules:${NC}"
echo "  📝 recipe-loader.sh      - YAML Recipe parsing"
echo "  🎯 recipe-matcher.sh     - Task-to-Recipe matching"
echo "  🔍 agent-finder.sh       - 4-tier agent discovery"
echo "  📋 prompt-builder.sh     - Structured prompt generation"
echo "  📊 data-extractor.sh     - Execution metadata extraction"
echo ""

echo -e "${YELLOW}Evolution Modules:${NC}"
echo "  🧠 recipe-generator.sh   - Auto-generate Recipes from patterns"
echo "  ⚡ optimizer.sh          - Merge/archive Recipe optimization"
echo "  💬 feedback-collector.sh - User satisfaction collection"
echo "  💾 knowledge-recorder.sh - JSONL knowledge base recording"
echo ""

echo -e "${YELLOW}Configuration & Tools:${NC}"
echo "  ⚙️  config-loader.sh     - YAML configuration management"
echo "  🔧 agent-installer.sh    - Interactive agent installation"
echo ""

sleep 2

# ============================================================================
# Demo 2: Available Recipes
# ============================================================================

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📋 2. Official Recipe Collection${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${GREEN}✓ API Development Recipe${NC}"
echo "  📦 REST/GraphQL API development"
echo "  🤖 Agents: backend-developer, database-optimizer, security-auditor"
echo "  💡 Tech: FastAPI, Express.js, NestJS, PostgreSQL, MongoDB"
echo "  ⚡ Success: <200ms P95, 80%+ tests, OWASP compliance"
echo ""

echo -e "${GREEN}✓ DevOps Deployment Recipe${NC}"
echo "  📦 CI/CD, Docker, Kubernetes, Cloud deployment"
echo "  🤖 Agents: deployment-engineer, kubernetes-architect, cloud-architect"
echo "  💡 Tech: GitHub Actions, Docker, K8s, Terraform, Prometheus"
echo "  ⚡ Success: <10min deploy, zero-downtime, IaC validated"
echo ""

echo -e "${GREEN}✓ Mobile Development Recipe${NC}"
echo "  📦 iOS/Android/React Native/Flutter apps"
echo "  🤖 Agents: mobile-developer, ios-developer, flutter-expert"
echo "  💡 Tech: SwiftUI, Jetpack Compose, React Native, Flutter"
echo "  ⚡ Success: <3s startup, 60fps, 99%+ crash-free"
echo ""

echo -e "${GREEN}✓ Web Development Recipe${NC}"
echo "  📦 Frontend, backend, full-stack web apps"
echo "  🤖 Agents: frontend-developer, backend-developer, ui-ux-designer"
echo "  💡 Tech: React, Vue, Next.js, Node.js, databases"
echo "  ⚡ Success: Responsive, accessible, performant"
echo ""

sleep 2

# ============================================================================
# Demo 3: Recipe Matching Examples
# ============================================================================

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🎯 3. Intelligent Recipe Matching${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}Example 1:${NC} \"Build a REST API with user authentication\""
echo -e "  ${GREEN}→ Matched: API Development Recipe (confidence: 0.95)${NC}"
echo "  ${BLUE}→ Keywords matched: REST, API, authentication${NC}"
echo "  ${CYAN}→ Recommended agents: backend-developer, security-auditor${NC}"
echo ""

echo -e "${YELLOW}Example 2:${NC} \"Deploy my Node.js app to Kubernetes\""
echo -e "  ${GREEN}→ Matched: DevOps Deployment Recipe (confidence: 0.92)${NC}"
echo "  ${BLUE}→ Keywords matched: Deploy, Kubernetes${NC}"
echo "  ${CYAN}→ Recommended agents: deployment-engineer, kubernetes-architect${NC}"
echo ""

echo -e "${YELLOW}Example 3:${NC} \"Create an iOS app with SwiftUI and Firebase\""
echo -e "  ${GREEN}→ Matched: Mobile Development Recipe (confidence: 0.93)${NC}"
echo "  ${BLUE}→ Keywords matched: iOS, app, SwiftUI${NC}"
echo "  ${CYAN}→ Recommended agents: mobile-developer, ios-developer${NC}"
echo ""

sleep 2

# ============================================================================
# Demo 4: 4-Tier Agent Discovery
# ============================================================================

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🔍 4. 4-Tier Agent Discovery System${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}Search Strategy:${NC}"
echo "  1️⃣  Local Directory    (~/.claude/agents)"
echo "  2️⃣  Official Agents    (15 built-in agents)"
echo "  3️⃣  GitHub Search      (public repositories)"
echo "  4️⃣  Community Sources  (configured registries)"
echo ""

echo -e "${YELLOW}Example Search: \"backend\"${NC}"
echo "  ${GREEN}✓ Found in Official:${NC}"
echo "    • backend-developer - Backend development and API design"
echo "    • backend-architect - Scalable backend architecture"
echo "    • backend-security-coder - Secure backend coding practices"
echo ""

sleep 2

# ============================================================================
# Demo 5: Self-Evolution Features
# ============================================================================

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🧠 5. Self-Evolution (ALITA Principles)${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}After Each Execution:${NC}"
echo "  📊 Records success/failure patterns to JSONL"
echo "  🔍 Extracts agent combinations that worked well"
echo "  🎯 Generates task fingerprints for pattern matching"
echo "  💬 Collects user satisfaction feedback"
echo ""

echo -e "${YELLOW}Automatic Recipe Generation:${NC}"
echo "  ✨ Groups similar successful patterns"
echo "  📈 Validates quality thresholds (usage, success rate)"
echo "  📝 Generates new Recipe YAML files automatically"
echo "  🎨 Includes workflow enhancements from patterns"
echo ""

echo -e "${YELLOW}Recipe Optimization:${NC}"
echo "  🔄 Merges similar Recipes (Jaccard similarity)"
echo "  📦 Archives underperforming Recipes"
echo "  📊 Maintains collection quality over time"
echo ""

sleep 2

# ============================================================================
# Demo 6: Execution Flow
# ============================================================================

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🚀 6. Complete Execution Flow${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}When you run:${NC} agentforge \"your task\""
echo ""
echo "  1️⃣  ${BLUE}Load Recipes${NC} - Parse all YAML Recipe files"
echo "  2️⃣  ${BLUE}Match Recipe${NC} - Find best matching Recipe for task"
echo "  3️⃣  ${BLUE}Discover Agents${NC} - Search 4-tier for recommended agents"
echo "  4️⃣  ${BLUE}Build Prompt${NC} - Generate enhanced prompt with Recipe context"
echo "  5️⃣  ${BLUE}Execute Task${NC} - Run with Claude Code using agents"
echo "  6️⃣  ${BLUE}Extract Data${NC} - Parse output for metadata"
echo "  7️⃣  ${BLUE}Record Knowledge${NC} - Save patterns to JSONL"
echo "  8️⃣  ${BLUE}Collect Feedback${NC} - Optional user satisfaction"
echo "  9️⃣  ${BLUE}Evolve Recipes${NC} - Generate/optimize based on patterns"
echo ""

sleep 2

# ============================================================================
# Demo 7: Testing
# ============================================================================

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🧪 7. Integration Test Suite${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}Test Coverage (18 tests):${NC}"
echo "  ✅ Configuration file loading"
echo "  ✅ Recipe YAML parsing and matching"
echo "  ✅ Agent discovery (official agents)"
echo "  ✅ Prompt generation"
echo "  ✅ Data extraction from output"
echo "  ✅ Knowledge base recording"
echo "  ✅ Recipe generation and optimization"
echo "  ✅ Main script functionality"
echo ""

echo -e "${GREEN}Current Pass Rate: 10/18 tests (56%)${NC}"
echo -e "${CYAN}Run with: bash tests/integration-test.sh${NC}"
echo ""

sleep 2

# ============================================================================
# Demo Complete
# ============================================================================

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✨ Demo Complete - 🔥 AgentForge v2.0${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${CYAN}🎯 Key Features:${NC}"
echo "  ✅ Recipe-driven agent orchestration"
echo "  ✅ 4-tier intelligent agent discovery"
echo "  ✅ Self-evolution with pattern learning (ALITA principles)"
echo "  ✅ JSONL knowledge base"
echo "  ✅ Automatic Recipe generation & optimization"
echo "  ✅ Bilingual support (EN/ZH)"
echo "  ✅ Interactive agent installation"
echo "  ✅ Comprehensive testing suite"
echo "  ✅ Zero dependencies (pure Bash)"
echo ""

echo -e "${YELLOW}📚 Try It Yourself:${NC}"
echo ""
echo -e "  ${BLUE}# Simple task execution${NC}"
echo "  agentforge \"Build a mobile app\""
echo ""
echo -e "  ${BLUE}# View documentation${NC}"
echo "  cat README.md"
echo ""
echo -e "  ${BLUE}# Explore Recipes${NC}"
echo "  ls -l recipes/official/"
echo "  cat recipes/official/api-development.yaml"
echo ""
echo -e "  ${BLUE}# Run tests${NC}"
echo "  bash tests/integration-test.sh"
echo ""
echo -e "  ${BLUE}# Test individual modules${NC}"
echo "  bash core/recipe-loader.sh"
echo "  bash core/optimizer.sh"
echo ""

echo -e "${CYAN}📖 Documentation:${NC}"
echo "  • README.md - Complete system documentation"
echo "  • BRAND_ASSETS.md - Official brand guidelines"
echo "  • recipes/official/ - 5 official Recipe examples"
echo "  • core/ - 11 core modules (4,274 lines of code)"
echo "  • tests/ - Integration test suite"
echo ""

echo -e "${GREEN}🔥 Forge your workflow, evolve your agents!${NC}"
echo ""
