# AgentForge - Recipes

This directory contains Recipe files that define task-specific workflows and Agent coordination strategies for agentforge.

## 📁 Directory Structure

```
recipes/
├── meta/
│   ├── schema-v1.json           # Recipe schema definition
│   └── templates/
│       └── basic.yaml           # Basic recipe template
├── official/                    # Official recipes
│   ├── web-development.yaml     # Web application development
│   └── data-analysis.yaml       # Data analysis and visualization
├── generated/                   # Auto-generated recipes (will be created)
└── custom/                      # User custom recipes (optional)
```

## 🎯 What is a Recipe?

A **Recipe** is a YAML file that contains:

1. **Triggers**: Keywords and patterns that match specific types of tasks
2. **Workflow Enhancements**: Optimized instructions for each of the 6 steps
3. **Agent Recommendations**: Which agents to use and when
4. **Risk Assessments**: Common risks and mitigation strategies
5. **Success Criteria**: Quality indicators and verification checklists
6. **Statistics**: Usage data and performance metrics (auto-updated)

## 📄 Recipe Examples

### Example 1: Web Development Recipe

**File**: `official/web-development.yaml`

This comprehensive recipe handles:
- Frontend development (React/Vue/Angular)
- Backend API development (Express/FastAPI/Django)
- Full-stack applications
- Authentication and security
- Performance optimization
- Deployment

**Key Features**:
- 20+ trigger keywords
- Detailed questions for each step
- 7 recommended agents with priority ordering
- 6 common risk scenarios with mitigation
- Complete verification checklist
- Performance metrics (Lighthouse, Core Web Vitals)

**Usage**: Automatically matched when task description contains terms like "React", "API", "web app", "frontend", etc.

### Example 2: Data Analysis Recipe

**File**: `official/data-analysis.yaml`

Handles data analysis tasks including:
- Data loading and cleaning
- Exploratory analysis
- Statistical modeling
- Data visualization
- Report generation

**Key Features**:
- Python/pandas/numpy focused
- Jupyter Notebook workflow
- Data quality risk assessment
- Memory optimization strategies

## 🔧 Recipe Schema

All recipes follow a standard schema defined in `meta/schema-v1.json`. Key sections:

```yaml
metadata:          # Name, version, description, tags
triggers:          # Keywords and regex patterns
workflow:          # 6-step workflow enhancements
  step_1_clarification:
  step_2_criteria:
  step_3_assessment:
  step_4_risks:
  step_5_execution:
  step_6_verification:
stats:             # Usage statistics (auto-updated)
meta:              # Schema version, confidence, etc.
```

## 🚀 Creating Custom Recipes

### Method 1: Use the Template

Copy `meta/templates/basic.yaml` and fill in your specific requirements:

```bash
cp recipes/meta/templates/basic.yaml recipes/custom/my-recipe.yaml
# Edit my-recipe.yaml
```

### Method 2: Auto-Generation

When you successfully complete a task, agentforge can automatically generate a recipe:

```bash
$ agentforge "your task"
# ... task completes successfully ...
🧬 Generate Recipe for future use? (Y/n): y
✅ Recipe generated: recipes/generated/task-abc123-v1.0.yaml
```

## 📊 Recipe Evolution

Recipes automatically evolve based on usage:

### Version History

Each recipe maintains an evolution history:

```yaml
evolution_history:
  - version: "1.0.0"
    date: "2025-01-11"
    changes: "Initial version"
  - version: "2.0.0"
    date: "2025-01-15"
    changes: "Added security-auditor based on 100% success cases"
```

### Statistics Tracking

Usage stats are automatically updated:

```yaml
stats:
  usage_count: 45              # Times used
  success_count: 42            # Successful executions
  failure_count: 3             # Failed executions
  success_rate: 0.93           # 93% success rate
  avg_satisfaction: 4.6        # Average user rating (1-5)
  avg_execution_time: "42min"  # Average duration
  last_used: "2025-01-11T10:30:00Z"
```

### Optimization Triggers

Recipes are optimized when:
- Used >= 5 times (configurable)
- Success rate drops below threshold
- User satisfaction is consistently high
- Similar recipes are detected (can be merged)

## 🎨 Recipe Matching

When you run a task, agentforge:

1. **Keyword Filtering**: Quickly filters recipes by keywords
2. **Pattern Matching**: Checks regex patterns
3. **Confidence Scoring**: Calculates match confidence
4. **User Selection**: Shows top matches for user to choose

### Example Matching

```bash
$ agentforge "Build a React dashboard with charts"

🔍 Matching Recipes...
📦 Found 2 matching recipes:

   [1] web-development (confidence: 0.92, success: 95%, uses: 120)  [recommended]
   [2] data-analysis (confidence: 0.75, success: 88%, uses: 45)

Select Recipe (1-2) or press Enter for recommended [1]:
```

## 🔍 Recipe Validation

Validate a recipe file:

```bash
# Using yq (YAML processor)
yq eval-all '.' recipes/official/web-development.yaml

# Using JSON Schema (requires ajv-cli)
yq eval -o=json recipes/official/web-development.yaml | \
  ajv validate -s recipes/meta/schema-v1.json -d /dev/stdin
```

## 📝 Best Practices

### 1. Specific Triggers
Use specific keywords and patterns to avoid false matches:

```yaml
triggers:
  keywords:
    - "React"        # Good: specific framework
    - "web"          # Too broad, use patterns instead
  patterns:
    - "构建.*React"   # Better: context-aware
```

### 2. Conditional Agents
Use conditions to include agents only when needed:

```yaml
recommended_agents:
  - name: "ml-engineer"
    priority: 3
    required: false
    conditions: ["预测", "模型", "machine learning"]
```

### 3. Actionable Success Criteria
Make criteria measurable and verifiable:

```yaml
success_criteria:
  - "✅ Lighthouse Performance > 90"     # Good: measurable
  - "✅ Fast loading"                     # Bad: vague
```

### 4. Specific Risk Mitigation
Provide concrete steps for risk mitigation:

```yaml
common_risks:
  - risk: "CORS errors"
    mitigation: "Configure proxy in vite.config.ts: server.proxy"
    # vs
    mitigation: "Fix CORS"  # Too vague
```

## 📚 Additional Resources

- [Recipe Schema Documentation](meta/schema-v1.json)
- [Basic Template](meta/templates/basic.yaml)
- [Example Execution Log](../logs/executions/example-execution.json)
- [Configuration Guide](../config/settings.yaml)

## 🤝 Contributing Recipes

To contribute a recipe to the official collection:

1. Create your recipe using the template
2. Test it on at least 5 different tasks
3. Ensure success rate > 80%
4. Document edge cases and limitations
5. Submit a PR with your recipe + test results

## 🔄 Recipe Lifecycle

```
Create → Use → Collect Stats → Optimize → Archive (if unused)
   ↓                               ↓
Auto-generate              Merge similar recipes
```

Recipes that haven't been used in 90 days (configurable) are automatically archived but not deleted.

---

**Note**: This is a living system. Recipes continuously evolve based on real-world usage and feedback.
