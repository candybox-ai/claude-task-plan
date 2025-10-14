# 🔥 v2.0.0 Release 创建指南

## 📍 快速链接

**直接访问创建页面**：
```
https://github.com/candybox-ai/agentforge/releases/new
```

---

## 📝 表单填写内容（复制即用）

### 1️⃣ Choose a tag
```
v2.0.0
```
然后点击 **"Create new tag: v2.0.0 on publish"**

### 2️⃣ Target
保持默认：`main` 分支

### 3️⃣ Release title
```
🔥 v2.0.0 - Welcome to AgentForge!
```

### 4️⃣ Describe this release

**复制以下完整内容到描述框**：

---

## 🎉 Major Update: Project Renamed

**Claude Agent Dispatch** is now **AgentForge**!

### Why AgentForge?

AgentForge embodies our core philosophy: your workflows are **forged through usage**, not just configured. Like a blacksmith's forge, the system becomes stronger with every execution.

### What's New

- ✅ **New Brand Identity**
  - Name: AgentForge
  - Tagline: "Forge your workflow, evolve your agents"
  - Logo: 🔥 AgentForge

- ✅ **Complete Documentation Redesign**
  - Modern, professional README (869 lines)
  - Comprehensive brand guidelines
  - Mermaid diagrams and comparison tables
  - Bilingual documentation (EN/ZH)

- ✅ **Critical Bug Fixes**
  - Fixed regex syntax errors in data-extractor.sh
  - Fixed jq type checking and pattern matching
  - Fixed integration test issues
  - Test pass rate: 67% (12/18 tests passing)

- ✅ **Backward Compatibility**
  - Old command still works (with deprecation warning)
  - Environment variables support both old and new names
  - Recipe format unchanged
  - Zero breaking changes

### Installation

**For New Users:**
```bash
# Install
curl -fsSL https://raw.githubusercontent.com/candybox-ai/agentforge/main/scripts/install.sh | bash

# Use
agentforge "your task"
```

**Quick Start:**
```bash
# Example: Build a REST API
agentforge "Build a REST API with user authentication"

# Example: Deploy to cloud
agentforge "Deploy my React app to AWS with CI/CD"

# Example: Data analysis
agentforge "Analyze sales data and create a dashboard"
```

### Migration Guide

**For Existing Users:**
- ✅ Your existing Recipes and knowledge base work without changes
- ✅ Update scripts to use `agentforge` instead of `claude-agent-dispatch`
- ✅ Old command still works but will show deprecation warning
- ✅ Update environment variables (optional):
  ```bash
  # Old (still works)
  export CLAUDE_AGENT_DISPATCH_LANG=zh

  # New (recommended)
  export AGENTFORGE_LANG=zh
  ```

**Local Git Repository Update:**
```bash
# Update your remote URL
git remote set-url origin https://github.com/candybox-ai/agentforge.git

# Verify
git remote -v
```

### What Stays the Same

- ✅ All features and functionality
- ✅ Recipe format and compatibility
- ✅ ALITA principles (Minimal Predefined, Maximum Self-Evolution)
- ✅ 4-tier agent discovery system
- ✅ JSONL knowledge base
- ✅ Zero dependencies (pure Bash)
- ✅ ~10ms startup time

### Key Features

🧠 **Intelligent Orchestration**
- 6-step rigorous workflow (from requirement clarification to delivery validation)
- 4-tier agent discovery (Local → Official → GitHub → Community)
- Smart Recipe matching based on task patterns

🌱 **Self-Evolution Engine**
- Automatic pattern learning from execution history
- Auto-generate new Recipes when patterns exceed thresholds
- Recipe optimization (merge similar, archive underperforming)

📊 **Knowledge Management**
- JSONL knowledge base (append-only, reliable)
- 4 pattern types: success, failure, agent combinations, task fingerprints
- Continuous learning from every execution

### Resources

- 📖 [Complete Documentation](https://github.com/candybox-ai/agentforge)
- 🎨 [Brand Guidelines](https://github.com/candybox-ai/agentforge/blob/main/BRAND_ASSETS.md)
- 🔧 [Migration Checklist](https://github.com/candybox-ai/agentforge/blob/main/ENGINEERING_MIGRATION_CHECKLIST.md)
- 📝 [Engineering Report](https://github.com/candybox-ai/agentforge/blob/main/ENGINEERING_COMPLETION_REPORT.md)
- 🔍 [Comparison with SuperClaude](https://github.com/candybox-ai/agentforge/blob/main/COMPARISON_SUPERCLAUDE.md)

### Statistics

- **Files Changed**: 42 files
- **Code Added**: +6,498 lines
- **Code Removed**: -1,512 lines
- **Net Change**: +4,986 lines
- **Documentation**: 9 new analysis and report documents
- **Backward Compatibility**: 100% ✅

### Thank You!

Thank you for being part of our journey. Let's forge amazing workflows together! 🔥

**Full Changelog**: https://github.com/candybox-ai/agentforge/compare/6c6211c...09d43c7

---

