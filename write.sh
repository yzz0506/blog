#!/bin/bash

cd "$(dirname "$0")"
echo "🔄 正在同步云端最新数据..."
git pull origin main
DATA_FILE="data.js"
IMG_DIR="imgs"

# 确保图片文件夹存在
mkdir -p "$IMG_DIR"

clear
echo "================================================="
echo "           MAC 博客写作终端 v3.1 (画廊版)"
echo "================================================="
echo ""

# 1. 输入内容
read -e -p "[内容]: " content

if [ -z "$content" ]; then
    echo "内容为空，退出。"
    exit 1
fi
# 防崩坏处理
content=${content//\"/\'}

# 2. 图片处理 (缓冲版)
echo ""
echo "-------------------------------------------------"
echo "提示: 请一张一张地拖入图片。"
echo "如果不加图了，直接按回车即可。"
echo "-------------------------------------------------"

# 初始化图片缓冲区和计数器
img_buffer=""
img_count=0

while true; do
    read -e -p "[图片] 拖入文件 (直接回车结束): " raw_img_path
    
    # 如果用户直接回车，停止循环
    if [ -z "$raw_img_path" ]; then
        break
    fi

    # 清理路径
    img_path=$(echo "$raw_img_path" | sed "s/'//g" | sed 's/\\ / /g')
    img_path=$(echo "$img_path" | xargs)

    if [ -f "$img_path" ]; then
        # 生成新文件名
        extension="${img_path##*.}"
        new_filename="$(date +%Y%m%d%H%M%S)_$RANDOM.$extension"
        
        # 复制
        cp "$img_path" "$IMG_DIR/$new_filename"
        
        echo "✅ 已添加: $new_filename"
        
        # 修改点：暂存图片标签，不加 <br>，暂时不写入 content
        img_buffer="$img_buffer<img src='$IMG_DIR/$new_filename'>"
        ((img_count++))
    else
        echo "⚠️  刚才那个不是有效文件，已跳过。"
    fi
done

# === 核心修改逻辑 ===
if [ $img_count -eq 1 ]; then
    # 如果只有一张图，按旧方式（换行+大图）
    content="$content<br>$img_buffer"
elif [ $img_count -gt 1 ]; then
    # 如果有多张图，包裹进 gallery 容器（横向滚动）
    content="$content<div class='gallery'>$img_buffer</div>"
fi
# ==================

echo "-------------------------------------------------"

# 3. 输入颜色
read -e -p "[颜色 (w=白 r=红 b=蓝 g=绿) 默认白]: " color
if [ -z "$color" ]; then color="w"; fi

# 4. 输入分类
read -e -p "[分类 默认日常]: " tag
if [ -z "$tag" ]; then tag="daily"; fi
if [[ $tag != \#* ]]; then tag="#$tag"; fi

# 5. 获取时间
current_time=$(date "+%Y-%m-%d %H:%M")

# 6. 生成并写入
js_line="add(\"$current_time\", \"$content\", \"$color\", \"$tag\");"
echo "$js_line" >> "$DATA_FILE"

echo ""
echo "✅ 写入成功！"