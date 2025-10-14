# 🔧 AgentForge 工程迁移清单

**项目更名：** Claude Agent Dispatch → AgentForge
**执行日期：** 2025-10-14

---

## 📋 完整更新清单

### 1. 主要可执行文件 (2 files)

- [ ] **bin/claude-agent-dispatch** → **bin/agentforge**
  - [x] 重命名文件
  - [ ] 更新内部环境变量（CLAUDE_AGENT_DISPATCH_LANG → AGENTFORGE_LANG）
  - [ ] 更新帮助文本
  - [ ] 更新错误消息
  - [ ] 创建向后兼容的符号链接

- [ ] **bin/claude-agent-dispatch.v1.backup**
  - [ ] 决定保留或删除

### 2. 核心模块 (2 files)

- [ ] **core/recipe-generator.sh**
  - [ ] 更新项目名引用
  - [ ] 更新 URL 引用

- [ ] **core/feedback-collector.sh**
  - [ ] 更新项目名引用

### 3. Recipe 文件 (5 files)

- [ ] **recipes/official/api-development.yaml**
- [ ] **recipes/official/devops-deployment.yaml**
- [ ] **recipes/official/mobile-development.yaml**
- [ ] **recipes/official/web-development.yaml**
- [ ] **recipes/official/data-analysis.yaml**

  每个文件需要更新：
  - [ ] metadata.project 字段
  - [ ] URL 引用
  - [ ] 示例命令

### 4. 配置文件 (5 files)

- [ ] **config/settings.yaml**
  - [ ] 项目名配置
  - [ ] 环境变量名

- [ ] **config/agent-sources.yaml**
  - [ ] URL 引用

- [ ] **recipes/meta/templates/basic.yaml**
  - [ ] 模板中的项目名

- [ ] **recipes/meta/schema-v1.json**
  - [ ] Schema 中的项目引用

- [ ] **core/meta-protocol.yaml**
  - [ ] 协议中的项目名

### 5. 测试文件 (1 file)

- [ ] **tests/integration-test.sh**
  - [ ] 命令引用（claude-agent-dispatch → agentforge）
  - [ ] 环境变量名
  - [ ] 测试输出消息

### 6. 安装和演示脚本 (3 files)

- [ ] **scripts/install.sh**
  - [ ] GitHub URL 引用
  - [ ] 安装路径
  - [ ] 帮助消息

- [ ] **demo.sh**
  - [ ] 项目名引用
  - [ ] 命令示例

- [ ] **quick-demo.sh**
  - [x] 已更新（之前完成）

### 7. 文档文件 (12+ files)

#### 主要文档
- [x] **README.md** - 已更新
- [x] **docs/README_zh.md** - 已更新

#### 示例文档 (4 files)
- [ ] **examples/web-development.md**
- [ ] **examples/web-development_zh.md**
- [ ] **examples/data-analysis.md**
- [ ] **examples/data-analysis_zh.md**

  需要更新：
  - [ ] 命令示例
  - [ ] GitHub URL

#### Recipe 文档
- [ ] **recipes/README.md**
  - [ ] 项目名引用
  - [ ] 命令示例

#### 设计和进度文档
- [ ] **DESIGN.md**
  - [ ] 项目名和描述

- [ ] **SESSION_SUMMARY.md**
  - [ ] 历史记录（可选更新）

- [ ] **PROGRESS_REPORT.md**
  - [ ] 项目名引用

- [ ] **TEST_RESULTS.md**
  - [ ] 测试输出中的项目名

- [ ] **COMPARISON_SUPERCLAUDE.md**
  - [ ] 项目名引用
  - [ ] GitHub URL

### 8. 缓存和日志文件 (可选)

- [ ] **cache/recipe-cache.json**
  - [ ] 清空或更新项目名引用

- [ ] **logs/executions/example-execution.json**
  - [ ] 示例中的项目名

### 9. Git 配置

- [ ] **.git/config**
  - [ ] Remote URL（在 GitHub 更名后自动更新）

---

## 🔄 环境变量迁移

### 旧变量 → 新变量

```bash
# 语言设置
CLAUDE_AGENT_DISPATCH_LANG → AGENTFORGE_LANG

# 未来可能的变量
CLAUDE_AGENT_DISPATCH_DIR → AGENTFORGE_DIR
CLAUDE_AGENT_DISPATCH_CONFIG → AGENTFORGE_CONFIG
```

### 向后兼容策略

在代码中同时检查新旧变量：
```bash
LANG="${AGENTFORGE_LANG:-${CLAUDE_AGENT_DISPATCH_LANG:-en}}"
```

---

## 📦 文件系统变更

### 1. 文件重命名

```bash
# 主脚本
bin/claude-agent-dispatch → bin/agentforge

# 可选：保留旧名称作为符号链接（向后兼容）
bin/claude-agent-dispatch → bin/agentforge (symlink)
```

### 2. 安装位置

**系统安装后的位置：**
```bash
# 旧位置（保留兼容性）
/usr/local/bin/claude-agent-dispatch → /usr/local/bin/agentforge (symlink)

# 新位置
/usr/local/bin/agentforge
```

---

## 🌐 GitHub 仓库迁移

### Step 1: 更新仓库设置

在 GitHub 网站上操作：

1. **重命名仓库**
   - 进入 Settings → General
   - Repository name: `claude-agent-dispatch` → `agentforge`
   - GitHub 会自动设置重定向

2. **更新描述**
   ```
   🔥 AgentForge - Self-Evolving Agent Orchestration for Claude Code | Forge your workflow, evolve your agents
   ```

3. **更新 Topics/Tags**
   ```
   agentforge
   claude-code
   agent-orchestration
   self-evolution
   ai-agents
   workflow-automation
   recipe-system
   bash
   alita-principles
   ```

4. **更新 About 链接**
   - Website: https://github.com/candybox-ai/agentforge
   - （未来）https://agentforge.dev

### Step 2: 本地仓库更新

```bash
# 更新 remote URL
git remote set-url origin git@github.com:candybox-ai/agentforge.git

# 或者（HTTPS）
git remote set-url origin https://github.com/candybox-ai/agentforge.git

# 验证
git remote -v
```

---

## 🔗 URL 引用更新

需要在代码中更新的 URL 模式：

### GitHub URL

**旧格式：**
```
https://github.com/candybox-ai/claude-agent-dispatch
https://raw.githubusercontent.com/candybox-ai/claude-agent-dispatch/main/
```

**新格式：**
```
https://github.com/candybox-ai/agentforge
https://raw.githubusercontent.com/candybox-ai/agentforge/main/
```

### 安装脚本 URL

**旧：**
```bash
curl -fsSL https://raw.githubusercontent.com/candybox-ai/claude-agent-dispatch/main/scripts/install.sh | bash
```

**新：**
```bash
curl -fsSL https://raw.githubusercontent.com/candybox-ai/agentforge/main/scripts/install.sh | bash
```

---

## 🧪 测试计划

### 1. 单元测试

```bash
# 测试主脚本
./bin/agentforge --help
./bin/agentforge --version

# 测试向后兼容（如果保留）
./bin/claude-agent-dispatch --help
```

### 2. 集成测试

```bash
# 运行完整测试套件
bash tests/integration-test.sh

# 测试 Recipe 加载
./bin/agentforge --list-recipes

# 测试环境变量
AGENTFORGE_LANG=zh ./bin/agentforge --help
```

### 3. 安装测试

```bash
# 测试新安装脚本
curl -fsSL https://raw.githubusercontent.com/candybox-ai/agentforge/main/scripts/install.sh | bash

# 验证安装
which agentforge
agentforge --version
```

---

## ⚠️ 重要注意事项

### 向后兼容性

**保留：**
- [x] 符号链接 `claude-agent-dispatch` → `agentforge`
- [x] 环境变量回退检查
- [x] GitHub 自动重定向（更名后 GitHub 提供）

**废弃通知：**
```bash
if [[ "$0" == *"claude-agent-dispatch"* ]]; then
    echo "⚠️  Warning: 'claude-agent-dispatch' is deprecated."
    echo "   Please use 'agentforge' instead."
    echo "   Learn more: https://github.com/candybox-ai/agentforge"
fi
```

### 破坏性变更检查

**无破坏性变更：**
- ✅ 主要功能保持不变
- ✅ Recipe 格式保持兼容
- ✅ API 接口不变（命令行参数）

**需要用户操作：**
- ⚠️ 更新自定义脚本中的命令名
- ⚠️ 更新环境变量名（可选，有回退）
- ⚠️ 更新书签和文档链接

---

## 📢 发布公告模板

### GitHub Release Notes

```markdown
# 🔥 v2.0.0 - Welcome to AgentForge!

## 🎉 Major Update: Project Renamed

**Claude Agent Dispatch** is now **AgentForge**!

### Why AgentForge?

AgentForge embodies our core philosophy: your workflows are **forged through usage**, not just configured. Like a blacksmith's forge, the system becomes stronger with every execution.

### What's Changed

- ✅ New name: `agentforge` (was: `claude-agent-dispatch`)
- ✅ New branding: 🔥 AgentForge - Forge your workflow, evolve your agents
- ✅ Complete README redesign
- ✅ Comprehensive brand guidelines

### What Stays the Same

- ✅ All features and functionality
- ✅ Recipe format and compatibility
- ✅ ALITA principles (Minimal Predefined, Maximum Self-Evolution)
- ✅ Your knowledge base and generated Recipes

### Migration Guide

**Simple update:**
```bash
# Install new version
curl -fsSL https://raw.githubusercontent.com/candybox-ai/agentforge/main/scripts/install.sh | bash

# Start using new command
agentforge "your task"
```

**For existing users:**
- Old command `claude-agent-dispatch` will continue to work (symlink)
- Update your scripts to use `agentforge` for future compatibility
- See [ENGINEERING_MIGRATION_CHECKLIST.md] for details

### Thank You!

Thank you for being part of our journey. Let's forge amazing workflows together! 🔥

[Full Changelog](https://github.com/candybox-ai/agentforge/blob/main/BRANDING_UPGRADE_SUMMARY.md)
```

---

## ✅ Final Checklist

在发布前确认：

- [ ] 所有文件已更新并测试
- [ ] GitHub 仓库已重命名
- [ ] 本地 git remote 已更新
- [ ] 集成测试全部通过
- [ ] 文档已更新且链接有效
- [ ] 安装脚本已测试
- [ ] 向后兼容性已验证
- [ ] Release notes 已准备
- [ ] 社区公告已准备

---

## 🚀 执行顺序

**推荐执行顺序：**

1. **第一阶段：本地代码更新**
   - 更新所有源代码文件
   - 更新配置文件
   - 更新文档
   - 本地测试

2. **第二阶段：提交到 Git**
   - Commit 所有更改
   - Push 到 main 分支

3. **第三阶段：GitHub 更名**
   - 在 GitHub 上重命名仓库
   - 更新仓库设置
   - 本地更新 remote URL

4. **第四阶段：验证和发布**
   - 验证所有链接
   - 运行完整测试
   - 创建 Release
   - 发布公告

---

<div align="center">

**准备好开始迁移了吗？让我们开始锻造！🔥**

</div>
