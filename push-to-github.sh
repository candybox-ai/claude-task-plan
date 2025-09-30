#!/bin/bash

# GitHub 推送脚本
# 使用方法: ./push-to-github.sh

echo "🚀 准备推送到 GitHub..."

# 检查是否在正确的目录
if [[ ! -f "bin/claude-task-plan" ]]; then
    echo "❌ 错误: 请在 claude-task-plan 项目根目录运行此脚本"
    exit 1
fi

# 显示仓库信息
echo "📁 仓库信息:"
git remote -v

echo ""
echo "📋 推送步骤:"
echo "1. 请先在 GitHub 上创建仓库: https://github.com/new"
echo "   - 仓库名: claude-task-plan"
echo "   - 设为 Public"
echo "   - 不要初始化任何文件"

echo ""
echo "2. 然后运行以下命令推送代码:"
echo ""
echo "   # 方法1: 使用 GitHub CLI (推荐)"
echo "   gh auth login"
echo "   git push -u origin main"
echo ""
echo "   # 方法2: 使用个人访问令牌"
echo "   # 访问: https://github.com/settings/tokens"
echo "   # 创建新令牌，然后:"
echo "   git push -u origin main"
echo "   # 输入用户名: candybox-ai"
echo "   # 输入密码: 你的个人访问令牌"
echo ""
echo "   # 方法3: 使用 SSH (如果已配置)"
echo "   git remote set-url origin git@github.com:candybox-ai/claude-task-plan.git"
echo "   git push -u origin main"

echo ""
echo "✅ 推送成功后，项目将在此链接可见:"
echo "   https://github.com/candybox-ai/claude-task-plan"

echo ""
echo "🎯 后续步骤:"
echo "- 设置 GitHub Pages 展示文档"
echo "- 创建 Release 标记 v1.0.0"
echo "- 添加项目主题和标签"