# Claude Agent Dispatch 2.0 - 设计文档

> 基于 ALITA 思想的自我进化 Agent 调度系统

## 🎯 核心理念

### ALITA 三原则在本项目中的应用

| ALITA 原则 | 我们的实现 |
|-----------|----------|
| **最小预定义** | 核心只保留基础6步骤框架 + Agent发现能力 |
| **最大自我进化** | Recipe 自动生成、优化和淘汰机制 |
| **MCP 机制** | Recipe = Agent 组合配方 + 执行策略 |

## 🏗️ 系统架构

```
┌─────────────────────────────────────────────────────────────┐
│                     用户任务输入                              │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│            任务指纹生成 & Recipe 匹配引擎                      │
│  • 关键词提取                                                │
│  • 相似度计算（关键词 + Claude语义）                          │
│  • Recipe 推荐（置信度排序）                                  │
└────────────────────┬────────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
        ▼                         ▼
   找到Recipe                  无Recipe
        │                         │
        │                         ▼
        │              ┌───────────────────┐
        │              │  自适应模式        │
        │              │  基础框架 + 通用   │
        │              │  Agent推荐         │
        │              └─────────┬─────────┘
        │                        │
        └────────────┬───────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                 Agent 发现 & 安装                            │
│  1. 本地已安装 (~/.claude/agents/)                           │
│  2. 官方仓库 (GitHub)                                        │
│  3. 社区精选                                                 │
│  4. 全网搜索 (需用户确认)                                     │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              Prompt 构建 & Claude 执行                        │
│  基础框架 + Recipe增强 + Agent指令 → claude "$prompt"        │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                  执行数据提取                                 │
│  • claude --output-format json                              │
│  • 日志分析 (Agent、技术栈、步骤)                            │
│  • 指标收集 (时间、成功率)                                    │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                用户反馈 (延迟可选)                            │
│  • 立即反馈 (1分钟)                                          │
│  • 延迟反馈 (claude-agent-dispatch feedback <id>)           │
│  • 跳过反馈                                                  │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                  自我进化引擎                                │
│  • 记录成功模式 (Agent组合、技术栈)                          │
│  • 生成新Recipe (满意度>=4 + 成功)                           │
│  • 优化现有Recipe (每10次触发优化提示)                       │
│  • 归档未使用Recipe (90天)                                   │
└─────────────────────────────────────────────────────────────┘
```

## 📁 目录结构

```
~/.claude-agent-dispatch/
├── config/
│   ├── settings.yaml                # 用户配置
│   ├── agent-sources.yaml           # Agent 来源定义
│   └── tech-keywords.json           # 技术栈关键词词典
│
├── core/
│   ├── meta-protocol.yaml           # 基础6步骤框架
│   ├── functions.sh                 # 核心功能函数
│   ├── data-extractor.sh            # 数据提取模块
│   └── recipe-matcher.sh            # Recipe 匹配引擎
│
├── recipes/
│   ├── meta/
│   │   ├── agent-registry.json      # Agent 能力索引
│   │   ├── schema-v1.json           # Recipe schema
│   │   └── templates/               # Recipe 模板
│   ├── official/                    # 官方预置
│   │   ├── web-development.yaml     # ✅ 已创建
│   │   └── data-analysis.yaml       # ✅ 已创建
│   ├── generated/                   # 自动生成
│   └── custom/                      # 用户自定义
│
├── evolution/
│   ├── knowledge/
│   │   ├── success-patterns.jsonl
│   │   ├── agent-combinations.jsonl
│   │   ├── failure-patterns.jsonl
│   │   └── task-fingerprints.jsonl
│   ├── metrics/
│   │   ├── recipe-stats.json
│   │   └── agent-performance.json
│   └── pending-optimizations.json
│
├── cache/
│   ├── agent-search-cache.json
│   └── task-keywords-cache.json
│
└── logs/
    ├── executions/
    │   └── [execution-id].json      # ✅ 示例已创建
    └── feedback/
        └── pending/
```

## 🔑 核心组件

### 1. Recipe 系统

**作用**：任务执行的知识库和策略集合

**组成**：
- **Triggers**: 关键词 + 正则模式匹配
- **Workflow**: 6步骤的增强指令
- **Agents**: 推荐的 Agent 组合
- **Risks**: 风险评估和缓解措施
- **Stats**: 使用统计和性能数据

**示例**：`recipes/official/web-development.yaml`

### 2. Agent 发现系统

**四层搜索策略**：

```bash
1. 本地 (~/.claude/agents/)
   ↓ 未找到
2. 官方仓库 (git pull)
   ↓ 未找到
3. 社区精选 (curated list)
   ↓ 未找到
4. 全网搜索 (GitHub/awesome-lists) ← 需用户确认
```

**安装策略**：
- 默认：询问用户
- 可配置：自动安装 (`agents.auto_install: true`)

### 3. 数据提取器

**提取内容**：
- **Agents Used**: 从 `--output-format json` 或日志分析
- **Tech Stack**: 关键词匹配 + Claude 增强
- **Steps Info**: 步骤追踪和时长
- **Metrics**: 性能指标、测试结果

**输出**：结构化 JSON 日志

### 4. 进化引擎

**进化维度**：
1. **Agent 组合优化**: 记录成功的 Agent 搭配
2. **模式识别**: 相似任务自动匹配历史 Recipe
3. **失败预防**: 学习失败模式，提前规避

**触发条件**：
- 每次执行后：记录数据
- 每10次执行：提示可优化
- 手动触发：`claude-agent-dispatch --evolve`

**优化操作**：
- 合并相似 Recipe
- 归档未使用 Recipe (90天)
- 更新 Agent 推荐优先级
- 生成进化报告

### 5. 反馈系统

**三种模式**：

1. **立即反馈** (默认10秒提示)
   ```bash
   成功? (y/n): y
   满意度 (1-5): 5
   ```

2. **延迟反馈**
   ```bash
   claude-agent-dispatch feedback <execution-id>
   ```

3. **跳过反馈**
   - 不影响系统运行
   - 但无法贡献进化数据

## 🔄 工作流程示例

### 场景：首次遇到 Svelte 任务

```bash
$ claude-agent-dispatch "使用 Svelte 构建待办事项应用"

🔍 分析任务...
   关键词: Svelte, 应用, 前端

📦 匹配 Recipes...
   ❌ 未找到 Svelte 专用 Recipe
   ✅ 找到相似: web-development.yaml (置信度: 0.65)

🤖 评估 Agent 需求...
   本地匹配:
   ✅ frontend-developer (通用前端框架)
   ⚠️  无 Svelte 专家

🔍 搜索 Svelte Agent...
   GitHub: ❌ 未找到

💡 建议策略:
   使用 frontend-developer (支持现代框架)
   Recipe 中增加 Svelte 特定指令

执行? (Y/n): y

[执行任务...]

✅ 任务完成！
💬 现在提供反馈? (1=是, 2=稍后, 3=跳过): 1
成功? (y/n): y
满意度 (1-5): 5

🧬 自我进化:
   ✨ 生成新 Recipe: svelte-app-v1.0.yaml
   📊 记录: frontend-developer 可处理 Svelte
   💾 保存到 recipes/generated/

下次遇到 Svelte 任务，将直接使用此 Recipe！
```

### 场景：Recipe 冲突选择

```bash
$ claude-agent-dispatch "分析销售数据并生成图表"

🔍 匹配 Recipes...
📦 找到 2 个匹配:

   [1] data-analysis (confidence: 0.88, 成功率: 92%, 使用: 56次)  [推荐]
   [2] web-development (confidence: 0.70, 成功率: 87%, 使用: 120次)

选择 Recipe (1-2) 或按回车使用推荐 [1]: ← 用户按回车

✅ 使用 Recipe: data-analysis.yaml
🤖 推荐 Agents: data-scientist, python-pro

[执行任务...]
```

## 📊 配置选项

关键配置 (`config/settings.yaml`):

```yaml
agents:
  auto_install: false              # 默认询问
  search.scope: [official, community, github]

evolution:
  mode: aggressive                 # 激进进化
  auto_generate.enabled: true
  optimization.min_usage: 5

matching:
  algorithm: hybrid                # 混合匹配
  confidence_threshold: 0.6

interaction:
  feedback_mode: delayed           # 延迟反馈
  show_evolution_insights: true
```

## 🎓 设计决策

### 已确认的技术方案

1. **数据提取**: JSON输出 + Claude分析日志
2. **相似度匹配**: 关键词初筛 + Claude确认
3. **数据存储**: JSONL (增长后可升级 SQLite)
4. **Recipe生成**: 自动重试3次 + 模板降级
5. **冲突解决**: 用户选择 (显示推荐)
6. **反馈方式**: 延迟反馈 (默认)
7. **优化执行**: 用户主动触发

### 技术限制与解决方案

| 限制 | 解决方案 |
|------|----------|
| Bash 无语义分析 | 调用 Claude API |
| 黑盒执行难以提取数据 | `--output-format json` + 日志分析 |
| 复杂数据查询 | 初期 JSONL，增长后 SQLite |
| Recipe 生成不稳定 | 自动重试 + 模板降级 |

## 🚀 实现路线图

### Phase 1: 基础框架 (1-2天)
- [x] 目录结构
- [x] 配置系统示例
- [x] Recipe 示例 (2个)
- [x] Schema 定义
- [x] 文档

### Phase 2: 核心功能 (3-4天)
- [ ] Recipe 匹配引擎
- [ ] 数据提取器
- [ ] Agent 发现系统
- [ ] Prompt 构建

### Phase 3: 进化系统 (2-3天)
- [ ] JSONL 数据记录
- [ ] Recipe 生成逻辑
- [ ] 优化算法
- [ ] 反馈系统

### Phase 4: Agent 搜索 (2-3天)
- [ ] 本地/官方搜索
- [ ] 社区/全网搜索
- [ ] 安装交互

### Phase 5: 集成测试 (1-2天)
- [ ] 端到端测试
- [ ] 文档更新
- [ ] 示例补充

## 📈 成功指标

1. **Recipe 覆盖率**: 80% 的任务有匹配 Recipe
2. **自动化率**: 70% 的 Recipe 自动生成
3. **成功率**: 整体任务成功率 > 85%
4. **用户满意度**: 平均满意度 > 4.0/5.0
5. **进化速度**: 每50次执行产生1个优化

## 🔮 未来扩展

### Phase 6: 高级功能
- 语义搜索 (embedding)
- 社区 Recipe Hub
- Recipe 版本控制
- A/B 测试不同策略

### Phase 7: 企业功能
- 团队 Recipe 共享
- 权限管理
- 审计日志
- 自定义 Agent 集成

---

**当前状态**: Phase 1 完成，准备进入 Phase 2

**下一步**: 实现 Recipe 匹配引擎

**文档版本**: 2.0-alpha
**最后更新**: 2025-01-11
