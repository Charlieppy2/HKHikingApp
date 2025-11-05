# 📤 上傳到 GitHub 指南

## 🚀 快速上傳

### 方法 1: 使用腳本（推薦）

在終端執行：

```bash
cd /Users/charlie.ppy/Documents/GitHub/HKHikingApp
chmod +x UPLOAD_TO_GITHUB.sh
./UPLOAD_TO_GITHUB.sh
```

### 方法 2: 手動執行命令

```bash
# 1. 進入專案目錄
cd /Users/charlie.ppy/Documents/GitHub/HKHikingApp

# 2. 初始化 git（如果還沒初始化）
git init

# 3. 添加所有文件
git add .

# 4. 提交
git commit -m "Initial commit: 香港行山路線 App"

# 5. 連接到遠程倉庫
git remote add origin https://github.com/Charlieppy2/HKHikingApp.git

# 6. 推送到 GitHub
git branch -M main
git push -u origin main
```

## ⚠️ 注意事項

1. **確認 GitHub 倉庫已創建**: 確保 https://github.com/Charlieppy2/HKHikingApp 已存在且為空倉庫

2. **認證問題**: 如果推送時需要認證，請：
   - 使用 Personal Access Token（推薦）
   - 或在 GitHub 設定 SSH key

3. **如果倉庫不為空**: 如果遠程倉庫已有內容，使用：
   ```bash
   git pull origin main --allow-unrelated-histories
   git push -u origin main
   ```

## 📝 後續更新

之後如有更新，使用：

```bash
git add .
git commit -m "更新描述"
git push
```

## 🔗 相關鏈接

- GitHub 倉庫: https://github.com/Charlieppy2/HKHikingApp
- 專案文檔: 查看 README.md

