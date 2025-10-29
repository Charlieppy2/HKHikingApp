# 🥾 香港行山路線 App

一個為香港行山愛好者設計的 iOS 應用程式，提供完整的路線管理、GPS 追蹤和打卡記錄功能。

## ✨ 功能特色

### 📍 路線推薦
- 整合康文署行山路線數據
- 根據難度、距離、時間篩選路線
- 附近路線推薦
- 詳細路線資訊和地圖顯示

### ⛰️ 難度分級
- 1-5 星難度評級系統
- 視覺化難度顯示（顏色和星級）
- 詳細難度說明和建議

### 🗺️ GPS 追蹤
- 實時 GPS 位置追蹤
- 路線記錄和回放
- 距離、時間、速度統計
- 海拔高度追蹤

### 📸 打卡記錄
- 起點、中途點、終點打卡
- 照片記錄功能
- 時間戳和位置標記

## 🛠️ 技術架構

### 技術棧
- **SwiftUI**: 現代 UI 框架
- **MapKit**: 地圖顯示和導航
- **CoreLocation**: GPS 追蹤服務
- **Combine**: 響應式數據流
- **MVVM**: 架構模式

### API 整合
- **康文署設施資料 API**: 路線數據來源
- **MapKit API**: 地圖服務（免費）

## 📂 專案結構

```
HKHikingApp/
├── HKHikingApp/
│   ├── HKHikingApp.swift      # App 入口
│   ├── Models/
│   │   ├── Trail.swift         # 路線模型
│   │   ├── Difficulty.swift    # 難度等級
│   │   ├── Coordinate.swift    # 座標模型
│   │   ├── CheckIn.swift       # 打卡模型
│   │   └── TrackRecord.swift   # 追蹤記錄模型
│   ├── Views/
│   │   ├── ContentView.swift   # 主視圖
│   │   ├── TrailListView.swift # 路線列表
│   │   ├── TrailDetailView.swift # 路線詳情
│   │   └── TrackingView.swift  # GPS 追蹤視圖
│   └── Services/
│       ├── TrailService.swift  # 路線數據服務
│       └── LocationService.swift # GPS 追蹤服務
├── README.md
└── .gitignore
```

## 🚀 開始使用

### 環境要求
- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

### 設置步驟

1. **克隆專案**
```bash
git clone https://github.com/Charlieppy2/HKHikingApp.git
cd HKHikingApp
```

2. **打開專案**
- 使用 Xcode 打開專案
- 或創建新的 Xcode 專案並導入文件

3. **設置權限**
在 `Info.plist` 中添加以下權限說明：
- `NSLocationWhenInUseUsageDescription`: "需要位置權限以使用 GPS 追蹤功能"
- `NSLocationAlwaysUsageDescription`: "需要後台位置權限以持續追蹤路線"
- `NSCameraUsageDescription`: "需要相機權限以記錄行山照片"

4. **API 設置**
- 獲取康文署 API 訪問權限（如需要）
- 更新 `TrailService.swift` 中的 API URL

5. **運行專案**
- 選擇目標設備或模擬器
- 點擊運行按鈕（⌘R）

## 📱 功能說明

### 路線瀏覽
- 瀏覽所有行山路線
- 按難度、地區篩選
- 搜索路線名稱
- 查看路線詳情、地圖、設施和建議

### GPS 追蹤
- 開始追蹤：點擊「開始追蹤」開始記錄路線
- 實時統計：查看距離、時間、速度
- 暫停/恢復：暫停追蹤後可恢復
- 結束追蹤：保存追蹤記錄

### 打卡功能
- 在起點、中途點、終點打卡
- 添加照片和備註
- 記錄位置和時間

## 🔐 權限說明

### 位置權限
- **使用時**: 在地圖上顯示位置、開始追蹤時使用
- **始終**: 後台持續追蹤時需要（可選）

### 相機權限
- 拍照打卡時需要

### 相冊權限
- 選擇已拍照片時需要

## 🗺️ 數據來源

### 路線數據
- **康文署設施資料**: 官方行山路線資訊
- **data.gov.hk**: 香港政府開放數據

### 地圖服務
- **MapKit**: Apple 地圖服務（免費使用）

## 📊 開發計劃

### ✅ 已完成
- [x] 專案結構設置
- [x] 數據模型設計
- [x] 路線列表和詳情
- [x] GPS 追蹤基礎功能
- [x] 地圖顯示

### 🚧 進行中
- [ ] 康文署 API 整合
- [ ] 打卡功能完善
- [ ] 歷史記錄管理
- [ ] 數據持久化（Core Data）

### 📝 待開發
- [ ] 路線分享功能
- [ ] 社交功能（分享路線、挑戰）
- [ ] 統計分析（總行山時間、距離）
- [ ] 成就系統
- [ ] 天氣整合
- [ ] 裝備清單

## 🤝 貢獻

歡迎提交 Issue 和 Pull Request！

## 📄 許可證

MIT License

## 👨‍💻 作者

Charlieppy2

## 🙏 致謝

- 康文署提供的路線數據
- 香港政府開放數據平台
- Apple MapKit 地圖服務

---

**享受行山，安全第一！** 🥾⛰️

