# 🚀 GitHub 仓库创建和推送指南

由于网络连接问题，请按以下步骤手动完成：

## 步骤1: 在GitHub创建仓库

1. **访问**: https://github.com/new

2. **填写信息**:
   - **Repository name**: `claude-task-plan`
   - **Description**: `An intelligent task planning and execution tool for Claude Code CLI with 95% success guarantee`
   - **Visibility**: ✅ Public
   - **Initialize**: ❌ 不要勾选任何初始化选项

3. **点击**: "Create repository"

## 步骤2: 推送本地代码

创建仓库后，在项目目录运行：

### 方法A: 使用个人访问令牌 (推荐)

1. **创建个人访问令牌**:
   - 访问: https://github.com/settings/tokens
   - 点击 "Generate new token (classic)"
   - 选择权限: `repo` (完整仓库权限)
   - 点击 "Generate token"
   - **复制并保存令牌** (只显示一次!)

2. **推送代码**:
```bash
git push -u origin main
```
   - **Username**: `candybox-ai`
   - **Password**: `你刚创建的个人访问令牌`

### 方法B: 使用SSH (如果已配置)

```bash
git remote set-url origin git@github.com:candybox-ai/claude-task-plan.git
git push -u origin main
```

### 方法C: 使用GitHub CLI (如果网络正常)

```bash
gh auth login
gh repo create claude-task-plan --public --source=. --push
```

## 步骤3: 验证创建成功

推送成功后访问: https://github.com/candybox-ai/claude-task-plan

应该能看到：
- ✅ README.md (中英文文档)
- ✅ bin/claude-task-plan (主脚本)
- ✅ scripts/install.sh (安装脚本)
- ✅ examples/ (示例文档)
- ✅ LICENSE (MIT许可)

## 🎯 后续优化 (可选)

### 1. 设置GitHub Pages
- 进入仓库 Settings → Pages
- Source: Deploy from a branch
- Branch: main / docs

### 2. 添加标签和主题
- 进入仓库主页
- 点击齿轮图标 ⚙️
- 添加主题: `cli-tool` `claude` `task-planning` `ai-agent`

### 3. 创建Release
```bash
gh release create v1.0.0 --title "Claude Task Plan v1.0.0" --notes "Initial release with bilingual support and 6-step workflow"
```

## 🆘 如果遇到问题

1. **权限错误**: 确保个人访问令牌有 `repo` 权限
2. **网络问题**: 尝试使用VPN或更换网络
3. **认证失败**: 重新生成个人访问令牌

---

**项目地址**: https://github.com/candybox-ai/claude-task-plan

**安装命令**:
```bash
curl -fsSL https://raw.githubusercontent.com/candybox-ai/claude-task-plan/main/scripts/install.sh | bash
```