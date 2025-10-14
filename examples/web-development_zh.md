# Web开发示例

本文档展示如何使用 `agentforge` 进行各种Web开发任务，包含具体的项目结构和需求。

## 示例1：React + Node.js 电商平台

### 任务描述
```bash
agentforge "构建完整的电商平台，使用React前端和Node.js后端。项目结构：/src/frontend（React组件）、/src/backend（Express API）、/src/database（MongoDB模式）。功能需求：产品目录与搜索/筛选、购物车、Stripe支付集成、用户认证（JWT）、产品管理后台。实现移动端/桌面端响应式设计。"
```

### Claude可能询问的问题（澄清阶段）
- "除了Stripe，还需要支持其他支付方式吗？"
- "需要库存管理功能还是仅展示产品？"
- "认证方式偏好 - 自定义JWT、Auth0还是Firebase Auth？"
- "React状态管理偏好 - Redux、Zustand还是Context API？"
- "部署目标 - Vercel、Netlify、AWS还是Docker容器？"

### 预期成功标准
- ✅ 完整的React前端，响应式设计（移动优先）
- ✅ RESTful API，包含完善的认证和授权
- ✅ 产品搜索与筛选（分类、价格范围、评分）
- ✅ 购物车持久化存储（localStorage + 数据库）
- ✅ Stripe支付集成，包含webhook处理
- ✅ 管理后台，支持产品CRUD操作
- ✅ Lighthouse性能评分95%+
- ✅ 安全审计通过（OWASP前10安全性合规）

### 可能使用的Agent
- `frontend-developer`：React组件、状态管理、响应式UI
- `backend-architect`：Express.js API设计、数据库模式
- `payment-integration`：Stripe结账流程和webhook实现
- `security-auditor`：认证安全和输入验证
- `performance-engineer`：打包优化和缓存策略

## 示例2：实时分析仪表板

### 任务描述
```bash
agentforge "为Web应用指标创建实时分析仪表板。技术栈：Next.js 14 + TypeScript，PostgreSQL数据库，WebSocket连接。数据源：/data/analytics/目录下的JSON文件，包含用户事件、页面浏览、转化数据。仪表板功能：实时访客计数器、转化漏斗可视化、用户地理分布图、性能指标图表。使用Docker Compose进行本地开发部署。"
```

### 预期交付成果
**阶段1：数据架构**
- PostgreSQL分析数据模式设计
- JSON文件到数据库的数据摄取管道
- WebSocket集成的实时事件处理
- 数据验证和清洗程序

**阶段2：前端开发**
- Next.js仪表板，使用TypeScript和Tailwind CSS
- 使用Chart.js或D3.js的交互式图表
- WebSocket连接的实时更新
- 移动端优化的响应式布局

**阶段3：DevOps与部署**
- 多容器部署的Docker Compose设置
- 开发/生产环境配置
- Jest和Cypress自动化测试管道
- 性能监控和错误跟踪设置

### 业务价值
- 实时洞察用户行为和系统性能
- 交互式可视化支持的数据驱动决策
- 支持高流量应用的可扩展架构

## 示例3：内容管理系统（CMS）

### 任务描述
```bash
agentforge "使用Strapi后端和Next.js前端构建无头CMS。项目位置：/projects/my-cms/，结构：/backend（Strapi API）、/frontend（Next.js站点）、/content（markdown文件）。功能：文章管理、媒体库、用户角色（管理员/编辑/作者）、SEO优化、多语言支持（中文/英文）。内容类型：博客文章、页面、产品描述。后端部署到Railway，前端部署到Vercel。"
```

### 详细工作流程
**1. 需求澄清**
- 内容建模需求和关系定义
- 用户权限级别和工作流审批流程
- SEO需求和社交媒体集成要求

**2. 后端开发**
- Strapi配置，包含自定义内容类型
- 用户角色和权限系统设置
- 媒体处理和图像优化
- Swagger/OpenAPI API文档

**3. 前端实现**
- Next.js静态站点生成（SSG）
- 内容页面的动态路由
- 元标签和结构化数据的SEO优化
- 多语言国际化（i18n）设置

**4. 集成与测试**
- 包含适当错误处理的API集成
- 编辑者内容预览功能
- 关键用户旅程自动化测试
- 性能优化和Core Web Vitals合规

## 示例4：渐进式Web应用（PWA）

### 任务描述
```bash
agentforge "将位于/src/my-app/的现有React应用转换为具有离线功能的渐进式Web应用。需求：用于缓存策略的service worker、用户参与推送通知、IndexedDB离线数据同步、移动设备优化的响应式设计。应用功能：任务管理、日历集成、文件共享。目标：可安装的PWA，Lighthouse PWA评分90+。"
```

### 技术实现
**Service Worker策略：**
- 静态资源缓存优先（CSS、JS、图片）
- API调用网络优先，离线回退
- 连接恢复时后台数据同步

**离线功能：**
- IndexedDB本地数据存储
- 同步操作冲突解决
- 离线UI指示器和消息提示

**PWA功能：**
- 包含适当图标和元数据的应用清单
- 安装提示和应用快捷方式
- 推送通知订阅和处理

## Web开发任务最佳实践

### 📋 任务描述指南

**❌ 过于泛泛：**
```bash
agentforge "构建一个网站"
```

**✅ 具体而完整：**
```bash
agentforge "使用Astro静态站点生成器在/projects/portfolio/构建作品集网站。功能：项目展示与筛选、markdown内容博客部分、邮件集成联系表单、深色/浅色主题切换。部署到Netlify，GitHub自动构建。优化Core Web Vitals和无障碍性（WCAG 2.1 AA合规）。"
```

### 🎯 包含这些详细信息

1. **技术栈**：具体框架、库和版本
2. **项目结构**：目录布局和文件组织
3. **功能需求**：详细的功能规格说明
4. **性能目标**：Lighthouse评分、加载时间、Core Web Vitals
5. **部署目标**：托管平台和CI/CD要求
6. **安全需求**：认证、数据验证、HTTPS

### 🚀 成功指标

- 代码遵循框架最佳实践和约定
- 响应式设计在各种设备尺寸下测试通过
- 达到性能基准（Lighthouse > 90）
- 解决安全漏洞（npm audit清洁）
- 无障碍性标准合规（WCAG 2.1）
- 跨浏览器兼容性验证

## 常见陷阱避免

❌ **技术需求模糊**："使用React构建"
✅ **具体技术栈**："使用React 18、TypeScript、Tailwind CSS和Vite构建"

❌ **无性能目标**："让它快一点"
✅ **可衡量目标**："实现Lighthouse评分>90和首次内容绘制<1.5秒"

❌ **缺少项目上下文**："添加认证"
✅ **明确集成**："为/api/auth/现有Express API添加JWT认证，包含密码重置功能"

❌ **无部署计划**："构建应用"
✅ **完整部署**："构建并部署到Vercel，包含GitHub自动集成和预览部署"