#!/bin/bash

cd "$(dirname "$0")"
echo "🔄 正在同步云端最新数据..."
git pull origin main
DATA_FILE="data.js"
IMG_DIR="imgs"

mkdir -p "$IMG_DIR"

clear
echo "================================================="
echo "           MAC 博客写作终端 v3.2 (省流版)"
echo "================================================="
echo ""

# 1. 输入内容
read -e -p "[内容]: " content

if [ -z "$content" ]; then
    echo "内容为空，退出。"
    exit 1
fi
content=${content//\"/\'}

# 2. 图片处理 (缓冲版)
echo ""
echo "-------------------------------------------------"
echo "提示: 请一张一张地拖入图片。"
echo "如果不加图了，直接按回车即可。"
echo "-------------------------------------------------"

img_buffer=""
img_count=0

while true; do
    read -e -p "[图片] 拖入文件 (直接回车结束): " raw_img_path
    
    if [ -z "$raw_img_path" ]; then
        break
    fi

    img_path=$(echo "$raw_img_path" | sed "s/'//g" | sed 's/\\ / /g')
    img_path=$(echo "$img_path" | xargs)

    if [ -f "$img_path" ]; then
        extension="${img_path##*.}"
        new_filename="$(date +%Y%m%d%H%M%S)_$RANDOM.$extension"
        
        cp "$img_path" "$IMG_DIR/$new_filename"
        
        echo "✅ 已添加: $new_filename"
        
        # === 修改点：增加 loading='lazy' ===
        # 这样浏览器只有滚动到图片位置时才会下载图片，极省流量
        img_buffer="$img_buffer<img src='$IMG_DIR/$new_filename' loading='lazy'>"
        ((img_count++))
    else
        echo "⚠️  刚才那个不是有效文件，已跳过。"
    fi
done

if [ $img_count -eq 1 ]; then
    # 单图模式
    content="$content<br>$img_buffer"
elif [ $img_count -gt 1 ]; then
    # 画廊模式
    content="$content<div class='gallery'>$img_buffer</div>"
fi

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