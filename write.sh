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
echo "           MAC 博客写作终端 v3.0 (无限图床版)"
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

# 2. 图片处理 (循环版)
echo ""
echo "-------------------------------------------------"
echo "提示: 请一张一张地拖入图片。"
echo "如果不加图了，直接按回车即可。"
echo "-------------------------------------------------"

while true; do
    read -e -p "[图片] 拖入文件 (直接回车结束): " raw_img_path
    
    # 如果用户直接回车，停止循环
    if [ -z "$raw_img_path" ]; then
        break
    fi

    # 清理路径 (处理拖拽产生的单引号和转义空格)
    # 这一步是为了让脚本能读懂 Mac 终端的路径格式
    img_path=$(echo "$raw_img_path" | sed "s/'//g" | sed 's/\\ / /g')
    
    # 去除首尾空格
    img_path=$(echo "$img_path" | xargs)

    if [ -f "$img_path" ]; then
        # 生成新文件名 (时间戳+随机秒数防止重名)
        extension="${img_path##*.}"
        # 使用 date +%N (纳秒) 甚至 $RANDOM 来确保两张图即使同一秒上传也不重名
        new_filename="$(date +%Y%m%d%H%M%S)_$RANDOM.$extension"
        
        # 复制
        cp "$img_path" "$IMG_DIR/$new_filename"
        
        echo "✅ 已添加: $new_filename"
        
        # 拼接 HTML 代码 (两张图之间加个换行)
        content="$content<br><img src='$IMG_DIR/$new_filename'>"
    else
        echo "⚠️  刚才那个不是有效文件，已跳过。"
    fi
done

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