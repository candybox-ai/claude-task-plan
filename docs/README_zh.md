# Claude Task Plan

[English](../README.md)

一个为 Claude Code CLI 设计的智能任务规划与执行工具，确保任务 100% 按期望完成，成功保障率达 95%。

## 🎯 功能特性

- **6步严谨流程**：需求澄清 → 标准定义 → 可行性评估 → 风险评估 → 执行监控 → 交付验证
- **智能Agent调度**：自动选择和调度最优的专业Agent
- **95%成功率**：双重确认机制，风险可控
- **双语支持**：完整支持中英文
- **全局可用**：任意目录、任意终端窗口都能使用

## 📦 安装

### 快速安装 (macOS/Linux)

```bash
curl -fsSL https://raw.githubusercontent.com/your-username/claude-task-plan/main/scripts/install.sh | bash
```

### 手动安装

1. 克隆仓库：
```bash
git clone https://github.com/your-username/claude-task-plan.git
cd claude-task-plan
```

2. 运行安装脚本：
```bash
chmod +x scripts/install.sh
./scripts/install.sh
```

## 🚀 使用方法

### 基本语法
```bash
claude-task-plan "任务描述"
```

### 使用示例

#### 软件开发
```bash
claude-task-plan "实现JWT用户认证功能"
claude-task-plan "构建React响应式仪表板"
claude-task-plan "优化数据库查询性能"
```

#### 数据分析
```bash
claude-task-plan "分析/data/user_behavior.csv中的用户行为数据，生成包含用户留存率、转化漏斗、用户画像的洞察报告，输出PDF格式"
claude-task-plan "基于/data/sales_data目录下的CSV文件创建交互式销售仪表板，包含营收趋势、地区业绩、实时KPI监控，使用Python和Plotly实现"
```

#### 运维部署
```bash
claude-task-plan "使用GitHub Actions搭建CI/CD流水线"
claude-task-plan "部署应用到Kubernetes集群"
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
export CLAUDE_TASK_PLAN_LANG=zh  # 强制中文
export CLAUDE_TASK_PLAN_LANG=en  # 强制英文
```

### 可选配置
在 `~/.claude-task-plan/config.yaml` 创建配置文件设置其他选项：
```yaml
# 目前仅支持超时设置
timeout: 7200   # 2小时（秒）
```

## 📚 示例

查看 [examples](../examples/) 目录了解详细用例：
- [Web开发](../examples/web-development.md)
- [数据分析](../examples/data-analysis_zh.md)

## 🤝 贡献

欢迎贡献！请查看我们的 [贡献指南](./CONTRIBUTING_zh.md) 了解详情。

### 开发环境设置
```bash
git clone https://github.com/your-username/claude-task-plan.git
cd claude-task-plan
chmod +x bin/claude-task-plan
```

## 📄 许可证

MIT 许可证 - 查看 [LICENSE](../LICENSE) 文件了解详情。

## 🆘 支持

- 📖 [文档](../docs/)
- 🐛 [报告问题](https://github.com/your-username/claude-task-plan/issues)
- 💬 [讨论](https://github.com/your-username/claude-task-plan/discussions)
- 🌟 [为项目点星](https://github.com/your-username/claude-task-plan)

## 🏷️ 版本

当前版本：v1.0.0

---

为 Claude Code 社区用 ❤️ 制作