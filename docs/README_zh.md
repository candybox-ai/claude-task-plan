<div align="center">

# 🔥 AgentForge（Agent 工坊）

**基于 Claude Code 的自我进化智能体编排系统**

[![版本](https://img.shields.io/badge/版本-2.0.0-blue.svg)](https://github.com/candybox-ai/agentforge/releases)
[![许可证](https://img.shields.io/badge/许可证-MIT-green.svg)](../LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude_Code-驱动-blueviolet.svg)](https://github.com/anthropics/claude-code)
[![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25.svg)](https://www.gnu.org/software/bash/)

[快速开始](#-快速开始) • [功能特性](#-功能特性) • [配置](#-配置) • [测试](#-测试) • [社区](#-社区)

---

**AgentForge** 是 AI 工作流的锻造工坊，而非配置工具。
从简单开始，在使用中进化，锻造你的完美工作流。

**🌟 标语：** *锻造工作流，进化智能体*

</div>

---

## 🌟 什么是 AgentForge？

**中文** | [English](../README.md)

AgentForge 是一个 **自我进化的智能体编排系统**，专为 Claude Code 设计。通过智能化的 Agent 调度、严格的工作流程，以及从执行历史中持续学习，将模糊的需求转化为成功的执行。

与需要大量预配置的传统框架不同，AgentForge 遵循 **ALITA 原则**：
- **📦 最小预定义**：从基础官方 Recipe 开始
- **🌱 最大自我进化**：从每次执行中学习并持续改进

把它想象成智能体的 **铁匠铺**：
- 🔥 每次执行都是一次锤击，淬炼你的工作流
- ⚒️ Recipe 是通过使用锻造出的工具
- ✨ 系统随着每个任务的完成而变得更智能

---

## ✨ 功能特性

### 🎯 核心能力

<table>
<tr>
<td width="50%">

**🧠 智能编排**
- **6 步严格流程**：从需求澄清到交付验证
- **4 层智能体发现**：本地 → 官方 → GitHub → 社区
- **智能 Recipe 匹配**：基于 YAML 的任务执行模式

</td>
<td width="50%">

**🌱 自我进化引擎**
- **模式学习**：自动识别成功的执行模式
- **自动生成**：当模式超过阈值时创建新 Recipe
- **优化**：合并相似 Recipe，归档表现不佳的

</td>
</tr>
<tr>
<td width="50%">

**📊 知识管理**
- **JSONL 知识库**：仅追加格式确保可靠性
- **4 种模式类型**：成功、失败、智能体组合、任务指纹
- **持续学习**：每次执行都丰富知识库

</td>
<td width="50%">

**🔧 开发者体验**
- **零配置**：开箱即用
- **全局访问**：在任何目录、任何终端使用
- **双语支持**：完整的中英文界面
- **交互式工具**：带安全检查的引导式智能体安装

</td>
</tr>
</table>

### 🆚 AgentForge vs. 传统框架

| 维度 | AgentForge | 传统框架 |
|-----|-----------|---------|
| **理念** | 🌱 在使用中进化 | 📝 预先配置 |
| **初始设置** | ⚡ 最小化（基础 Recipe） | 🐌 繁重（复杂配置） |
| **学习** | 🧠 自动模式学习 | 🤖 静态规则 |
| **Recipe 生成** | ✅ 从模式自动生成 | ❌ 仅手动创建 |
| **优化** | ✅ 自动合并和归档 | ❌ 手动维护 |
| **智能体发现** | 🔍 4 层智能搜索 | 📁 固定智能体列表 |
| **知识库** | 📊 JSONL（仅追加，可靠） | 💾 各种格式 |
| **启动时间** | ⚡ ~10ms（Bash） | 🐌 100-500ms（Python/Node） |
| **依赖** | ✅ 零依赖（纯 Bash） | ⚠️ 多个依赖包 |

---

## 🚀 快速开始

### 前置条件

必须先安装 [Claude Code CLI](https://github.com/anthropics/claude-code)。

### 安装

**选项 1：快速安装（推荐）**
```bash
curl -fsSL https://raw.githubusercontent.com/candybox-ai/agentforge/main/scripts/install.sh | bash
```

**选项 2：手动安装**
```bash
git clone https://github.com/candybox-ai/agentforge.git
cd agentforge
chmod +x scripts/install.sh
./scripts/install.sh
```

**选项 3：直接下载**
```bash
curl -o agentforge https://raw.githubusercontent.com/candybox-ai/agentforge/main/bin/agentforge
chmod +x agentforge
sudo mv agentforge /usr/local/bin/
```

### 验证安装
```bash
agentforge --help
```

### 第一个任务

```bash
agentforge "构建一个带用户认证的 REST API"
```

系统将会：
1. 📝 **匹配 Recipe** - 从学习到的模式中匹配
2. ✅ **澄清需求** - 使用 Recipe 指导澄清
3. 🎯 **定义成功标准**
4. 🔍 **发现最优智能体**（4 层搜索）
5. ⚠️ **评估风险** - 使用 Recipe 策略
6. 🚀 **执行** - 协调智能体执行
7. ✨ **验证交付** - 完整性检查
8. 📊 **学习** - 从执行中学习（更新知识库）

### 实际应用示例

**🔒 为现有应用添加认证**
```bash
agentforge "为 /src/api/ 中的 Express.js API 添加 JWT 认证，包含登录、注册、密码重置和邮箱验证功能"
```

**📊 商业智能仪表板**
```bash
agentforge "使用 /data/quarterly_sales.xlsx 构建高管仪表板，展示收入趋势、区域表现、热门产品和增长预测，使用交互式 Plotly 图表"
```

**🚀 生产环境部署**
```bash
agentforge "将 React 应用部署到 AWS，使用 S3、CloudFront、自动扩展、SSL 证书，以及使用 GitHub Actions 的 CI/CD 流水线"
```

**🐛 调试性能问题**
```bash
agentforge "调查并修复 /src/services/ 中的慢速 API 响应 - 分析瓶颈、优化数据库查询、实现缓存，实现 <200ms 响应时间"
```

## 🔄 执行流程

### 1. 需求澄清阶段
- 识别并解决任务描述中的疑问
- 零假设原则 - 确保完全理解需求

### 2. 需求确认与成功标准定义
- 明确重述理解的任务需求
- 定义可衡量的成功标准和质量指标
- 识别边界条件和约束条件

### 3. 可行性评估与方案制定
- 评估所需的专业Agent和技术栈
- 检查Agent可用性，必要时安装或寻找替代方案
- 制定详细的实施方案和执行策略

### 4. 方案确认与风险评估
- 展示完整执行方案（Agent选择、执行顺序、时间预估）
- 识别潜在风险和失败场景
- 制定风险缓解措施和备选方案

### 5. 执行监控阶段
- 按计划执行任务并实时监控
- 主动报告进度和处理异常情况
- 确保执行过程可控可追溯

### 6. 交付验证阶段
- 严格验证交付成果是否符合成功标准
- 进行质量评估和完整性检查
- 持续优化直到完全满足期望

---

## ⚙️ 配置

### 语言设置

AgentForge 自动从任务描述检测语言：
- 中文字符 → 中文界面
- 否则 → 英文界面

强制指定语言：
```bash
export AGENTFORGE_LANG=en  # 强制英文
export AGENTFORGE_LANG=zh  # 强制中文
```

### 环境变量

```bash
# 语言偏好
export AGENTFORGE_LANG=zh

# 自定义目录
export LOCAL_AGENT_DIR=$HOME/.claude/agents
export RECIPE_DIR=$HOME/.claude/recipes
export KNOWLEDGE_BASE_DIR=$HOME/.claude/knowledge

# GitHub token 用于 API 速率限制
export GITHUB_TOKEN=your_github_token
```

---

## 🧪 测试

运行集成测试套件：
```bash
bash tests/integration-test.sh
```

测试覆盖范围：
- ✅ 配置加载
- ✅ Recipe 加载和匹配
- ✅ 智能体发现（4 层）
- ✅ 提示生成
- ✅ 数据提取
- ✅ 知识记录
- ✅ Recipe 生成
- ✅ Recipe 优化
- ✅ 主脚本功能

**当前结果：** 12/18 测试通过（67% 通过率）

测试单个模块：
```bash
bash core/recipe-loader.sh      # 测试 Recipe 解析
bash core/agent-finder.sh       # 测试智能体发现
bash core/optimizer.sh          # 测试优化器
```

---

## 📖 完整文档

完整的中文文档请参考英文 README 的对应章节：
- 🏗️ [系统架构](../README.md#-architecture) - 系统概览和目录结构
- 🎯 [Recipe 系统](../README.md#-recipe-system) - Recipe 结构和进化
- 🔍 [4 层智能体发现](../README.md#-4-tier-agent-discovery) - 智能体搜索策略
- 🧠 [自我进化原理](../README.md#-self-evolution-alita-principles) - ALITA 原则详解

---

## 🤝 社区

### 加入对话

- 💬 [GitHub 讨论](https://github.com/candybox-ai/agentforge/discussions) - 提问、分享想法
- 🐛 [问题追踪](https://github.com/candybox-ai/agentforge/issues) - 报告 bug、请求功能
- 🌟 [展示和讲述](https://github.com/candybox-ai/agentforge/discussions/categories/show-and-tell) - 分享成功故事
- 📚 [Recipe 展示](https://github.com/candybox-ai/agentforge/discussions/categories/recipes) - 分享自定义 Recipe

### 贡献

我们欢迎贡献！贡献方式：

**🐛 报告问题**
```bash
发现 bug？报告它：
https://github.com/candybox-ai/agentforge/issues/new
```

**✨ 建议功能**
```bash
有想法？分享它：
https://github.com/candybox-ai/agentforge/discussions/new
```

**🔧 提交代码**
```bash
# Fork、克隆并创建分支
git clone https://github.com/YOUR_USERNAME/agentforge.git
cd agentforge
git checkout -b feature/your-feature

# 修改并测试
bash tests/integration-test.sh

# 提交 pull request
```

**📝 创建 Recipe**
```bash
# 分享你的自定义 Recipe
1. 在 recipes/custom/ 中创建 Recipe
2. 充分测试
3. 提交 PR 到 recipes/community/
```

---

## 📄 许可证

MIT 许可证 - 详见 [LICENSE](../LICENSE) 文件。

**开源理念：**
- ✅ 自由使用、修改和分发
- ✅ 允许商业使用
- ✅ 不需要署名（但感激！）
- ✅ 社区驱动开发

---

## 🏆 致谢

**AgentForge** 由 Claude Code 社区用 ❤️ 构建。

**特别感谢：**
- [Anthropic](https://www.anthropic.com/) 提供 Claude Code
- 开源社区的启发和贡献
- 早期采用者和 beta 测试者的宝贵反馈

**灵感来源：**
- SourceForge - 开源托管先驱
- Minecraft Forge - 社区驱动的模组平台
- Terraform - 基础设施即代码进化
- 永恒的铁匠工艺 ⚒️

---

<div align="center">

**🔥 AgentForge - 锻造工作流，进化智能体**

由 Claude Code 社区用 ❤️ 制作

[⭐ 在 GitHub 上给我们星标](https://github.com/candybox-ai/agentforge) • [🤝 贡献](../CONTRIBUTING.md) • [💬 加入讨论](https://github.com/candybox-ai/agentforge/discussions)

</div>