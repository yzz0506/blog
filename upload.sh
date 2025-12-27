#!/bin/bash

# 1. 进入当前目录
cd "$(dirname "$0")"

clear
echo "================================================="
echo "           GitHub 同步终端 v3.1 (自动发布)"
echo "================================================="
echo ""

# 2. 检查本地状态
if [ -n "$(git status --porcelain)" ]; then 
  echo "💾 发现本地变动，正在提交..."
  git add .
  git commit -m "Update: $(date '+%Y-%m-%d %H:%M') [Auto-Sync]"
  echo "✅ 本地提交已完成。"
else
  echo "✅ 本地无新增内容，准备拉取云端..."
fi

echo "-------------------------------------------------"

# 3. 拉取云端
echo "🔄 正在与云端同步..."
if git pull origin main; then
    echo "✅ 同步完成"
else
    echo "❌ 拉取遇到冲突！请手动解决冲突后再试。"
    exit 1
fi

echo "-------------------------------------------------"

# 4. 推送
echo "📤 正在推送到 GitHub..."
if git push origin main; then
    echo ""
    echo "🎉 恭喜！博客已成功发布到线上。"
    echo "🔗 访问地址: https://blog.yuk1no.com (可能需要几分钟缓存刷新)"
else
    echo ""
    echo "❌ 推送失败，请检查网络设置。"
fi