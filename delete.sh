#!/bin/bash
cd "$(dirname "$0")"
echo "🔄 正在同步云端最新数据..."
git pull origin main
clear
grep -n "add(" data.js
read -p "Line to delete: " n
sed -i "" "${n}d" data.js
echo "Done."