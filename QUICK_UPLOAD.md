# 🚀 快速上傳指南

## 📋 步驟（複製並執行）

請**打開 Terminal 應用程式**，然後複製以下命令並執行：

### 第一步：進入專案目錄
```bash
cd /Users/charlie.ppy/Documents/GitHub/HKHikingApp
```

### 第二步：初始化 Git（如果還沒初始化）
```bash
git init
```

### 第三步：添加所有文件
```bash
git add .
```

### 第四步：提交代碼
```bash
git commit -m "Initial commit: 香港行山路線 App"
```

### 第五步：連接到 GitHub 倉庫
```bash
git remote add origin https://github.com/Charlieppy2/HKHikingApp.git
```

### 第六步：推送到 GitHub
```bash
git branch -M main
git push -u origin main
```

## ⚠️ 如果遇到問題

### 問題 1: "remote origin already exists"
解決方法：
```bash
git remote remove origin
git remote add origin https://github.com/Charlieppy2/HKHikingApp.git
```

### 問題 2: 需要認證
- 如果是第一次，GitHub 可能會要求輸入用戶名和密碼
- 密碼請使用 **Personal Access Token**（不是 GitHub 密碼）
- 獲取 Token：GitHub Settings → Developer settings → Personal access tokens

### 問題 3: 倉庫已有內容
```bash
git pull origin main --allow-unrelated-histories
git push -u origin main
```

## ✅ 成功後

您應該會看到：
```
✅ 已上傳到 GitHub！
📱 查看: https://github.com/Charlieppy2/HKHikingApp
```

然後可以在瀏覽器打開該鏈接查看您的代碼！

## 📝 或者使用腳本

也可以直接執行腳本：
```bash
cd /Users/charlie.ppy/Documents/GitHub/HKHikingApp
chmod +x UPLOAD_TO_GITHUB.sh
./UPLOAD_TO_GITHUB.sh
```

