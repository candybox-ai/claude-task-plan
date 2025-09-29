# 数据分析示例

本文档展示如何使用 `claude-task-plan` 进行各种数据分析任务，并正确指定数据源。

## 示例1：用户行为分析

```bash
claude-task-plan "分析/data/user_logs/目录下的用户行为数据CSV文件，包含字段：user_id、timestamp、action、page_url。生成综合洞察报告，包含用户留存分析、转化漏斗、用户分群。使用Python pandas和matplotlib输出PDF格式可视化报告。"
```

**预期执行流程：**
1. **需求澄清**：Claude询问具体分析目标、时间周期、用户细分要求
2. **需求确认**：定义成功标准（留存率指标、漏斗转化率等）
3. **方案制定**：选择Agent（data-scientist、python-pro、data-engineer）
4. **风险评估**：识别数据质量问题、缺失值处理方案
5. **执行监控**：加载数据、执行分析、创建可视化
6. **交付验证**：验证统计显著性和业务洞察

## 示例2：销售仪表板创建

```bash
claude-task-plan "基于/data/sales.json创建交互式销售仪表板，数据格式为{date, region, product, revenue, quantity}。构建实时KPI监控，包含营收趋势、地区业绩对比、产品分析。使用Python、Plotly和Streamlit构建Web界面。"
```

**关键Agent使用：**
- `data-scientist`：执行统计分析和趋势识别
- `python-pro`：实现数据处理和计算逻辑
- `frontend-developer`：创建交互式仪表板界面
- `data-engineer`：搭建数据管道和实时更新

## 示例3：金融风险分析

```bash
claude-task-plan "分析/data/portfolio.xlsx中的金融投资组合数据，包含sheets：stocks、bonds、options。计算风险价值(VaR)、投资组合优化、相关性分析。使用Python scipy和numpy进行蒙特卡洛模拟，生成风险评估报告。"
```

**复杂工作流程：**
- Excel表格数据验证和清洗
- 统计建模和风险计算
- 投资组合优化算法
- 蒙特卡洛模拟实现
- 专业金融报告生成

## 示例4：机器学习模型开发

```bash
claude-task-plan "使用客户数据/data/customers.csv构建预测模型，特征包括：age、income、purchase_history、demographics。预测客户流失概率。包含特征工程、模型选择、超参数调优、性能评估。输出模型文件和评估报告。"
```

**流程重点：**
- 探索性数据分析和特征工程
- 模型选择和交叉验证
- 超参数优化
- 模型可解释性和业务洞察

## 示例5：时间序列预测

```bash
claude-task-plan "使用历史数据/data/traffic_logs.csv预测网站流量，字段包含：timestamp、page_views、unique_visitors、bounce_rate。创建30天预测，包含置信区间。使用ARIMA、Prophet或LSTM模型。生成预测报告和模型对比建议。"
```

## 数据分析最佳实践

### 1. 始终指定数据源
- **文件路径**：`/data/filename.csv`、`/path/to/database.db`
- **数据库连接**：包含连接详情或配置文件
- **API接口**：指定数据源API和认证信息

### 2. 定义数据结构
- **列名称**：列出重要字段及其含义
- **数据类型**：指定数值、分类、日期时间字段
- **数据质量**：说明已知问题或缺失值情况

### 3. 明确分析目标
- **指标**：具体要生成的KPI或洞察
- **输出格式**：PDF报告、交互式仪表板、CSV结果
- **可视化**：需要的图表和图形类型

### 4. 技术偏好
- **工具**：Python/R、pandas/dplyr、matplotlib/seaborn
- **基础设施**：本地处理、云平台、数据库
- **性能**：内存需求、处理时间约束

## 常见成功标准

- ✅ 数据质量验证和清洗完成
- ✅ 发现结果的统计显著性验证
- ✅ 可视化清晰且信息丰富
- ✅ 业务洞察具有可操作性
- ✅ 创建可重现的分析流程
- ✅ 提供文档和代码注释

## 错误预防提示

❌ **不要这样做**：`"分析销售数据"`
✅ **应该这样做**：`"分析/data/sales.csv中的销售数据并进行营收预测"`

❌ **不要这样做**：`"创建仪表板"`
✅ **应该这样做**：`"基于/data/metrics.json创建实时更新仪表板"`

❌ **不要这样做**：`"构建机器学习模型"`
✅ **应该这样做**：`"使用/data/customers.csv构建准确率>85%的客户流失预测模型"`