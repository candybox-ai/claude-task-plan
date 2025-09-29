# Claude Task Plan

[中文](./docs/README_zh.md)

An intelligent task planning and execution tool for Claude Code CLI that ensures 100% task completion with 95% success guarantee.

## 🎯 Features

- **6-Step Rigorous Process**: Requirement clarification → Standard definition → Feasibility assessment → Risk evaluation → Execution monitoring → Delivery verification
- **Intelligent Agent Dispatch**: Automatically selects and schedules optimal professional agents
- **95% Success Rate**: Double confirmation mechanism with risk control
- **Bilingual Support**: Full support for English and Chinese
- **Global Access**: Works in any directory, any terminal window

## 📦 Installation

### Quick Install (macOS/Linux)

```bash
curl -fsSL https://raw.githubusercontent.com/your-username/claude-task-plan/main/scripts/install.sh | bash
```

### Manual Install

1. Clone the repository:
```bash
git clone https://github.com/your-username/claude-task-plan.git
cd claude-task-plan
```

2. Run the installation script:
```bash
chmod +x scripts/install.sh
./scripts/install.sh
```

## 🚀 Usage

### Basic Syntax
```bash
claude-task-plan "your task description"
```

### Examples

#### Software Development
```bash
claude-task-plan "Implement user authentication with JWT"
claude-task-plan "Build a responsive dashboard with React"
claude-task-plan "Optimize database queries for better performance"
```

#### Data Analysis
```bash
claude-task-plan "Analyze user behavior data in /data/user_logs/ directory, generate insights report with retention analysis, conversion funnel, and user segmentation in PDF format"
claude-task-plan "Create interactive sales dashboard from /data/sales.json with revenue trends, regional performance, and real-time KPI monitoring using Python and Plotly"
```

#### DevOps & Infrastructure
```bash
claude-task-plan "Set up CI/CD pipeline with GitHub Actions"
claude-task-plan "Deploy application to Kubernetes cluster"
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
Set your preferred language:
```bash
export CLAUDE_TASK_PLAN_LANG=en  # or zh for Chinese
```

### Configuration
Create a config file at `~/.claude-task-plan/config.yaml`:
```yaml
language: auto  # auto, en, zh
timeout: 7200   # 2 hours in seconds
```

## 📚 Examples

See the [examples](./examples/) directory for detailed use cases:
- [Web Development](./examples/web-development.md)
- [Data Analysis](./examples/data-analysis.md)

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](./docs/CONTRIBUTING.md) for details.

### Development Setup
```bash
git clone https://github.com/your-username/claude-task-plan.git
cd claude-task-plan
chmod +x bin/claude-task-plan
```

## 📄 License

MIT License - see the [LICENSE](./LICENSE) file for details.

## 🆘 Support

- 📖 [Documentation](./docs/)
- 🐛 [Report Issues](https://github.com/your-username/claude-task-plan/issues)
- 💬 [Discussions](https://github.com/your-username/claude-task-plan/discussions)
- 🌟 [Star the Project](https://github.com/your-username/claude-task-plan)

## 🏷️ Version

Current Version: v1.0.0

---

Made with ❤️ for the Claude Code community