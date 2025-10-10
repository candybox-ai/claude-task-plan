# Claude Agent Dispatch

[简体中文](./docs/README_zh.md) | **English**

A command-line agent dispatch tool for Claude Code that intelligently selects and coordinates agents to complete your tasks. Transform vague requests into successful executions through smart agent orchestration and rigorous workflow management.

## 🎯 Features

- **6-Step Rigorous Process**: Requirement clarification → Standard definition → Feasibility assessment → Risk evaluation → Execution monitoring → Delivery verification
- **Intelligent Agent Dispatch**: Automatically selects and schedules optimal professional agents
- **95% Success Rate**: Double confirmation mechanism with risk control
- **Bilingual Support**: Full support for English and Chinese
- **Global Access**: Works in any directory, any terminal window

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

Claude will automatically:
1. 📝 **Clarify** your requirements
2. ✅ **Define** success criteria
3. 🔍 **Plan** the execution strategy
4. ⚠️ **Assess** potential risks
5. 🚀 **Execute** with agent coordination
6. ✨ **Verify** complete delivery

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

### Configuration
No additional configuration is currently required. The tool works out of the box with intelligent language detection and default settings.

## 📚 Examples

See the [examples](./examples/) directory for detailed use cases:
- [Web Development](./examples/web-development.md)
- [Data Analysis](./examples/data-analysis.md)

## 🤝 Contributing

We welcome contributions! Feel free to:
- Report bugs and suggest features via [GitHub Issues](https://github.com/candybox-ai/claude-agent-dispatch/issues)
- Submit pull requests with improvements
- Share your usage examples and feedback

### Development Setup
```bash
git clone https://github.com/candybox-ai/claude-agent-dispatch.git
cd claude-agent-dispatch
chmod +x bin/claude-agent-dispatch
```

## 📄 License

MIT License - see the [LICENSE](./LICENSE) file for details.

## 🆘 Support

- 📖 [Documentation](./docs/)
- 🐛 [Report Issues](https://github.com/candybox-ai/claude-agent-dispatch/issues)
- 💬 [Discussions](https://github.com/candybox-ai/claude-agent-dispatch/discussions)
- 🌟 [Star the Project](https://github.com/candybox-ai/claude-agent-dispatch)

## 🏷️ Version

Current Version: v1.0.0

---

Made with ❤️ for the Claude Code community