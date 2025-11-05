#!/bin/bash

# 上傳 HKHikingApp 到 GitHub

cd /Users/charlie.ppy/Documents/GitHub/HKHikingApp

# 初始化 git（如果還沒初始化）
if [ ! -d ".git" ]; then
    git init
fi

# 添加所有文件
git add .

# 提交
git commit -m "Initial commit: 香港行山路線 App"

# 連接到遠程倉庫
git remote remove origin 2>/dev/null
git remote add origin https://github.com/Charlieppy2/HKHikingApp.git

# 推送到 GitHub
git branch -M main
git push -u origin main

echo "✅ 已上傳到 GitHub！"
echo "📱 查看: https://github.com/Charlieppy2/HKHikingApp"

