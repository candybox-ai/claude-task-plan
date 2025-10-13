# Claude Agent Dispatch

[中文](./docs/README_zh.md) | **English**

A self-evolving agent orchestration system for Claude Code that intelligently coordinates specialized agents using learned patterns. Transform vague requests into successful executions through smart agent dispatch, rigorous workflows, and continuous learning from execution history.

## 🎯 Features

### Core Capabilities
- **6-Step Rigorous Process**: Requirement clarification → Success criteria → Feasibility assessment → Risk evaluation → Execution monitoring → Delivery verification
- **Intelligent Agent Dispatch**: 4-tier agent discovery (Local → Official → GitHub → Community)
- **Recipe System**: YAML-based task execution patterns with workflow enhancements
- **Self-Evolution**: Automatically learns from successful executions and generates new Recipes
- **Knowledge Base**: JSONL format for recording patterns, agent combinations, and task fingerprints
- **Interactive Installation**: Guided agent installation with safety confirmations
- **Bilingual Support**: Full support for English and Chinese
- **Global Access**: Works in any directory, any terminal window

### Self-Evolution (ALITA Principles)
- **Minimal Predefined**: Start with basic official Recipes
- **Maximum Self-Evolution**: Learn from every execution and improve over time
- **Pattern Learning**: Automatically identifies successful execution patterns
- **Recipe Generation**: Creates new Recipes when patterns exceed quality thresholds
- **Recipe Optimization**: Merges similar Recipes and archives underperforming ones

## 🏗️ Architecture

### System Components

```
claude-agent-dispatch/
├── bin/
│   └── claude-agent-dispatch       # Main entry point
├── core/
│   ├── recipe-loader.sh            # Recipe YAML parsing
│   ├── recipe-matcher.sh           # Task-to-Recipe matching
│   ├── agent-finder.sh             # 4-tier agent discovery
│   ├── prompt-builder.sh           # Structured prompt generation
│   ├── data-extractor.sh           # Execution data extraction
│   ├── recipe-generator.sh         # Automatic Recipe generation
│   ├── optimizer.sh                # Recipe optimization
│   ├── feedback-collector.sh       # User feedback collection
│   ├── knowledge-recorder.sh       # JSONL data recording
│   ├── config-loader.sh            # Configuration management
│   └── agent-installer.sh          # Interactive agent installation
├── recipes/
│   ├── official/                   # Official Recipe collection
│   │   ├── api-development.yaml
│   │   ├── devops-deployment.yaml
│   │   ├── mobile-development.yaml
│   │   └── web-development.yaml
│   ├── generated/                  # Auto-generated Recipes
│   └── custom/                     # User-created Recipes
├── config/
│   └── agent-sources.yaml          # Agent source configuration
└── evolution/
    └── knowledge/                  # Knowledge base (JSONL)
        ├── success-patterns.jsonl
        ├── failure-patterns.jsonl
        ├── agent-combinations.jsonl
        └── task-fingerprints.jsonl
```

### Execution Flow

1. **Task Input** → User provides task description
2. **Recipe Matching** → Finds best matching Recipe from collection
3. **Workflow Enhancement** → Applies Recipe's 6-step process enhancements
4. **Agent Discovery** → Searches for recommended agents (4-tier)
5. **Prompt Building** → Generates structured prompt with context
6. **Execution** → Runs task with coordinated agents
7. **Data Extraction** → Extracts execution metadata
8. **Knowledge Recording** → Records patterns to JSONL knowledge base
9. **Feedback Collection** → Gathers user satisfaction (optional)
10. **Recipe Evolution** → Generates/optimizes Recipes based on patterns

### Recipe System

Recipes are YAML files that define:
- **Metadata**: Name, version, description, category, tags
- **Triggers**: Keywords and patterns for matching tasks
- **Workflow Enhancements**: Specific guidance for each of the 6 steps
  - Step 1: Priority questions for clarification
  - Step 2: Success criteria and quality indicators
  - Step 3: Recommended agents and tech stack
  - Step 4: Risk assessment and mitigation strategies
  - Step 5: Execution milestones and progress tracking
  - Step 6: Verification checklists
- **Stats**: Usage count, success rate, satisfaction scores

Example Recipe structure:
```yaml
metadata:
  name: "API Development"
  category: "backend"
  tags: ["api", "rest", "graphql"]

triggers:
  keywords: ["API", "REST", "endpoint"]
  patterns: ["develop.*api", "build.*service"]

workflow:
  step_3_assessment:
    recommended_agents:
      - name: "backend-developer"
        priority: 1
        required: true
      - name: "database-optimizer"
        priority: 2
```

## 📦 Installation

**Prerequisites:** [Claude Code CLI](https://github.com/anthropics/claude-code) must be installed first.

### Option 1: Quick Install (Recommended)
```bash
curl -fsSL https://raw.githubusercontent.com/candybox-ai/claude-agent-dispatch/main/scripts/install.sh | bash
```

### Option 2: Manual Installation
```bash
# Clone and install
git clone https://github.com/candybox-ai/claude-agent-dispatch.git
cd claude-agent-dispatch
chmod +x scripts/install.sh
./scripts/install.sh
```

### Option 3: Direct Download
```bash
# Download just the script
curl -o claude-agent-dispatch https://raw.githubusercontent.com/candybox-ai/claude-agent-dispatch/main/bin/claude-agent-dispatch
chmod +x claude-agent-dispatch
sudo mv claude-agent-dispatch /usr/local/bin/
```

### Verify Installation
```bash
claude-agent-dispatch --help
# Should display usage information
```

## 🚀 Usage

### Quick Start
```bash
claude-agent-dispatch "your task description"
```

The system will:
1. 📝 **Match Recipe** from learned patterns
2. ✅ **Clarify** your requirements with Recipe guidance
3. 🎯 **Define** success criteria
4. 🔍 **Discover** optimal agents (4-tier search)
5. ⚠️ **Assess** risks with Recipe strategies
6. 🚀 **Execute** with agent coordination
7. ✨ **Verify** complete delivery
8. 📊 **Learn** from execution (update knowledge base)

### Advanced Commands

**List available Recipes:**
```bash
claude-agent-dispatch --list-recipes
```

**Show Recipe statistics:**
```bash
claude-agent-dispatch --recipe-stats
```

**Generate new Recipes from patterns:**
```bash
claude-agent-dispatch --generate-recipes
```

**Optimize Recipe collection:**
```bash
claude-agent-dispatch --optimize-recipes
```

**View knowledge base statistics:**
```bash
claude-agent-dispatch --knowledge-stats
```

**Interactive agent installation:**
```bash
claude-agent-dispatch --install-agents
```

**Force specific language:**
```bash
claude-agent-dispatch --lang en "your task"
claude-agent-dispatch --lang zh "你的任务"
```

### Real-World Examples

**🔒 Add Authentication to Existing App**
```bash
claude-agent-dispatch "Add JWT authentication to my Express.js API in /src/api/ with login, register, password reset, and email verification features"
```

**📊 Business Intelligence Dashboard**
```bash
claude-agent-dispatch "Build executive dashboard using /data/quarterly_sales.xlsx showing revenue trends, regional performance, top products, and growth forecasts with interactive Plotly charts"
```

**🚀 Production Deployment**
```bash
claude-agent-dispatch "Deploy React app to AWS with S3, CloudFront, auto-scaling, SSL certificates, and CI/CD pipeline using GitHub Actions"
```

**🐛 Debug Performance Issues**
```bash
claude-agent-dispatch "Investigate and fix slow API responses in /src/services/ - analyze bottlenecks, optimize database queries, implement caching, and achieve <200ms response time"
```

## 🔄 Execution Flow

### 1. Requirement Clarification
- Identifies and resolves any ambiguities in task description
- Zero assumption principle - ensures complete understanding

### 2. Requirement Confirmation & Success Criteria Definition
- Clearly restates understood requirements
- Defines measurable success criteria and quality indicators
- Identifies boundary conditions and constraints

### 3. Feasibility Assessment & Solution Design
- Evaluates required professional agents and tech stack
- Checks agent availability, installs if needed, or finds alternatives
- Creates detailed implementation plan and execution strategy

### 4. Solution Confirmation & Risk Assessment
- Displays complete execution plan (agent selection, sequence, timing)
- Identifies potential risks and failure scenarios
- Develops risk mitigation measures and backup plans

### 5. Execution Monitoring
- Executes tasks according to plan with real-time monitoring
- Reports progress and handles exceptions proactively
- Ensures controllable and traceable execution process

### 6. Delivery Verification
- Strictly validates deliverables against success criteria
- Performs quality assessment and completeness check
- Continues optimization until expectations are fully met

## 🛠️ Configuration

### Language Settings
The tool automatically detects language from your task description (Chinese characters → Chinese interface, otherwise → English).

To force a specific language:
```bash
export CLAUDE_AGENT_DISPATCH_LANG=en  # Force English
export CLAUDE_AGENT_DISPATCH_LANG=zh  # Force Chinese
```

### Agent Sources Configuration
Edit `config/agent-sources.yaml` to customize agent sources:
```yaml
official:
  agents:
    - name: "backend-developer"
      category: "backend"
      description: "Backend development and API design"
    # ... 15 official agents

community:
  sources:
    - name: "claude-dev-community"
      url: "https://github.com/claude-dev-community"
    # ... community sources

github:
  enabled: true
  search_topics: ["claude-agent", "ai-agent"]
```

### Environment Variables
```bash
# Language preference
export CLAUDE_AGENT_DISPATCH_LANG=en

# Custom agent installation directory
export LOCAL_AGENT_DIR=$HOME/.claude/agents

# Custom Recipe directory
export RECIPE_DIR=$HOME/.claude/recipes

# Knowledge base directory
export KNOWLEDGE_BASE_DIR=$HOME/.claude/knowledge
```

## 🧪 Testing

Run the integration test suite:
```bash
bash tests/integration-test.sh
```

The test suite validates:
- Configuration file loading
- Recipe loading and matching
- Agent discovery system
- Prompt generation
- Data extraction
- Knowledge recording
- Recipe generation and optimization
- Main script functionality

Current test results: 10/18 tests passing (56% pass rate)

## 📚 Examples

See the [examples](./examples/) directory for detailed use cases:
- [Web Development](./examples/web-development.md)
- [Data Analysis](./examples/data-analysis.md)

### Official Recipes

The system includes these official Recipes:
- **API Development** (`api-development.yaml`): REST/GraphQL API development with database optimization and security
- **DevOps Deployment** (`devops-deployment.yaml`): CI/CD, containerization, Kubernetes, cloud deployment
- **Mobile Development** (`mobile-development.yaml`): iOS/Android/React Native/Flutter app development
- **Web Development** (`web-development.yaml`): Frontend, backend, full-stack web applications

## 📖 Module Documentation

### Core Modules

**recipe-loader.sh** (230 lines)
- Loads and parses Recipe YAML files
- Validates Recipe structure
- Provides Recipe collection interface

**recipe-matcher.sh** (280 lines)
- Matches tasks to Recipes using keyword and pattern matching
- Calculates confidence scores
- Returns best matching Recipe or general workflow

**agent-finder.sh** (350 lines)
- 4-tier agent discovery: Local → Official → GitHub → Community
- Searches by name, keyword, category, description
- Returns agent metadata with installation information

**prompt-builder.sh** (320 lines)
- Generates structured prompts with Recipe context
- Includes 6-step workflow instructions
- Supports bilingual prompt generation

**data-extractor.sh** (280 lines)
- Extracts execution metadata from Claude output
- Identifies agents used, tech stack, success/failure
- Calculates execution time and generates fingerprints

### Evolution Modules

**recipe-generator.sh** (515 lines)
- Automatically generates Recipe YAML from successful patterns
- Groups patterns by task fingerprint
- Validates quality thresholds (usage, success rate, satisfaction)

**optimizer.sh** (435 lines)
- Merges similar Recipes using Jaccard similarity
- Archives underperforming Recipes
- Maintains Recipe collection quality

**feedback-collector.sh** (240 lines)
- Interactive feedback collection (satisfaction, comments)
- Updates Recipe statistics
- Bilingual interface

**knowledge-recorder.sh** (310 lines)
- Records execution data to JSONL files
- Maintains 4 knowledge files: success-patterns, failure-patterns, agent-combinations, task-fingerprints
- Append-only format for reliability

### Configuration & Installation

**config-loader.sh** (342 lines)
- Loads YAML configuration files
- Python-first YAML parsing with awk fallback
- Provides unified configuration interface

**agent-installer.sh** (456 lines)
- Interactive agent installation wizard
- Multi-source support (official, GitHub, local)
- Safety confirmations and automatic backups

## 🤝 Contributing

We welcome contributions! Feel free to:
- Report bugs and suggest features via [GitHub Issues](https://github.com/candybox-ai/claude-agent-dispatch/issues)
- Submit pull requests with improvements
- Share your usage examples and feedback
- Create custom Recipes and share them with the community

### Development Setup
```bash
git clone https://github.com/candybox-ai/claude-agent-dispatch.git
cd claude-agent-dispatch

# Make scripts executable
chmod +x bin/claude-agent-dispatch
chmod +x core/*.sh
chmod +x tests/*.sh

# Run tests
bash tests/integration-test.sh

# Test individual modules
bash core/recipe-loader.sh
bash core/optimizer.sh
bash core/config-loader.sh
```

### Creating Custom Recipes

1. Create a YAML file in `recipes/custom/`:
```yaml
metadata:
  name: "Your Recipe Name"
  version: "1.0.0"
  category: "your-category"

triggers:
  keywords: ["keyword1", "keyword2"]

workflow:
  step_3_assessment:
    recommended_agents:
      - name: "agent-name"
        priority: 1
```

2. Test your Recipe:
```bash
claude-agent-dispatch "task matching your keywords"
```

## 📄 License

MIT License - see the [LICENSE](./LICENSE) file for details.

## 🏷️ Version

**Current Version: v2.0.0**

### What's New in v2.0.0
- ✨ Recipe system with YAML-based workflow enhancements
- 🧠 Self-evolution with automatic pattern learning
- 📊 Knowledge base in JSONL format
- 🔍 4-tier agent discovery system
- 🤖 Automatic Recipe generation from patterns
- ⚡ Recipe optimization (merge and archive)
- 🎯 Interactive agent installation
- 📈 Comprehensive testing suite

### Changelog
- **v2.0.0** (2025-10-13): Self-evolution, Recipe system, knowledge base, 4-tier agent discovery
- **v1.0.0** (2025-01-10): Initial release with 6-step rigorous process

---

Made with ❤️ for the Claude Code community | [Documentation](./docs/) | [Examples](./examples/) | [Recipes](./recipes/)