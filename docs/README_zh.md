# Claude Agent Dispatch

**中文** | [English](../README.md)

专为 Claude Code 设计的命令行 Agent 调度工具，智能选择和协调 Agent 完成任务。通过智能 Agent 编排和严谨工作流管理，将模糊需求转化为成功执行。

## 🎯 功能特性

- **6步严谨流程**：需求澄清 → 标准定义 → 可行性评估 → 风险评估 → 执行监控 → 交付验证
- **智能Agent调度**：自动选择和调度最优的专业Agent
- **95%成功率**：双重确认机制，风险可控
- **双语支持**：完整支持中英文
- **全局可用**：任意目录、任意终端窗口都能使用

## 📦 安装

**前置要求：** 需要先安装 [Claude Code CLI](https://github.com/anthropics/claude-code)。

### 方式1：快速安装（推荐）
```bash
curl -fsSL https://raw.githubusercontent.com/candybox-ai/claude-agent-dispatch/main/scripts/install.sh | bash
```

### 方式2：手动安装
```bash
# 克隆并安装
git clone https://github.com/candybox-ai/claude-agent-dispatch.git
cd claude-agent-dispatch
chmod +x scripts/install.sh
./scripts/install.sh
```

### 方式3：直接下载
```bash
# 仅下载脚本文件
curl -o claude-agent-dispatch https://raw.githubusercontent.com/candybox-ai/claude-agent-dispatch/main/bin/claude-agent-dispatch
chmod +x claude-agent-dispatch
sudo mv claude-agent-dispatch /usr/local/bin/
```

### 验证安装
```bash
claude-agent-dispatch --help
# 应该显示使用说明
```

## 🚀 使用方法

### 快速开始
```bash
claude-agent-dispatch "任务描述"
```

Claude将自动：
1. 📝 **澄清** 你的需求
2. ✅ **定义** 成功标准
3. 🔍 **规划** 执行策略
4. ⚠️ **评估** 潜在风险
5. 🚀 **执行** 智能调度
6. ✨ **验证** 完整交付

### 实际应用示例

**🔒 为现有应用添加认证**
```bash
claude-agent-dispatch "为/src/api/目录下的Express.js API添加JWT认证，包含登录、注册、密码重置和邮箱验证功能"
```

**📊 商业智能仪表板**
```bash
claude-agent-dispatch "使用/data/quarterly_sales.xlsx构建高管仪表板，展示营收趋势、地区业绩、热销产品和增长预测，使用交互式Plotly图表"
```

**🚀 生产环境部署**
```bash
claude-agent-dispatch "将React应用部署到AWS，使用S3、CloudFront、自动扩展、SSL证书，并通过GitHub Actions建立CI/CD流水线"
```

**🐛 调试性能问题**
```bash
claude-agent-dispatch "调查并修复/src/services/目录下API响应缓慢问题 - 分析瓶颈、优化数据库查询、实现缓存，达到<200ms响应时间"
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

## 🛠️ 配置

### 语言设置
工具会自动检测任务描述中的语言（包含中文字符 → 中文界面，否则 → 英文界面）。

强制指定语言：
```bash
export CLAUDE_AGENT_DISPATCH_LANG=zh  # 强制中文
export CLAUDE_AGENT_DISPATCH_LANG=en  # 强制英文
```

### 配置
当前无需额外配置。工具具备智能语言检测功能，开箱即用。

## 📚 示例

查看 [examples](../examples/) 目录了解详细用例：
- [Web开发](../examples/web-development_zh.md)
- [数据分析](../examples/data-analysis_zh.md)

## 🤝 贡献

欢迎贡献！你可以：
- 通过 [GitHub Issues](https://github.com/candybox-ai/claude-agent-dispatch/issues) 报告问题和建议功能
- 提交改进的拉取请求
- 分享你的使用示例和反馈

### 开发环境设置
```bash
git clone https://github.com/candybox-ai/claude-agent-dispatch.git
cd claude-agent-dispatch
chmod +x bin/claude-agent-dispatch
```

## 📄 许可证

MIT 许可证 - 查看 [LICENSE](../LICENSE) 文件了解详情。

## 🆘 支持

- 📖 [文档](../docs/)
- 🐛 [报告问题](https://github.com/candybox-ai/claude-agent-dispatch/issues)
- 💬 [讨论](https://github.com/candybox-ai/claude-agent-dispatch/discussions)
- 🌟 [为项目点星](https://github.com/candybox-ai/claude-agent-dispatch)

## 🏷️ 版本

当前版本：v1.0.0

---

为 Claude Code 社区用 ❤️ 制作