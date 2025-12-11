#!/bin/bash

# 1. 进入当前目录
cd "$(dirname "$0")"

clear
echo "================================================="
echo "           GitHub 同步终端"
echo "================================================="

# 2. 先把云端的新变化拉下来 (比如刚才生成的 CNAME)
#    这一步非常重要，防止冲突！
echo "🔄 正在拉取云端更新..."
git pull origin main

# 3. 检查有没有要上传的东西
if [ -z "$(git status --porcelain)" ]; then 
  echo "✅ 本地没有变化，已经是最新状态。"
  exit 0
fi

# 4. 添加、提交、推送
echo "📤 正在上传..."
git add .
git commit -m "Update: $(date '+%Y-%m-%d %H:%M')"
git push origin main

echo ""
echo "✅ 发布成功！"