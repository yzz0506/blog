#!/bin/bash

# 1. 进入当前目录
cd "$(dirname "$0")"

clear
echo "================================================="
echo "           GitHub 同步终端 (安全版 v2.0)"
echo "================================================="

# 2. 【关键修改】先检查并在本地提交！
if [ -n "$(git status --porcelain)" ]; then 
  echo "💾 正在保存本地修改..."
  git add .
  git commit -m "Update: $(date '+%Y-%m-%d %H:%M')"
else
  echo "✅ 本地没有新修改，准备拉取..."
fi

# 3. 拉取云端
echo "🔄 正在与云端同步..."
if git pull origin main; then
    echo "✅ 同步完成"
else
    echo "❌ 拉取遇到冲突！请手动打开文件解决冲突。"
    exit 1
fi

# 4. 推送
echo "📤 正在推送到 GitHub..."
if git push origin main; then
    echo ""
    echo "🎉 发布成功！"
else
    echo ""
    echo "❌ 推送失败，请检查网络或报错信息。"
fi