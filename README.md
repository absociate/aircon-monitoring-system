# 🏠🏢 智能自動化系統集合

這個倉庫包含三個主要的自動化系統，分別用於不同的環境和用途。

## 📁 專案結構

```
Lab/
├── 01-home-assistant-personal/     # 🏠 家裡的 Home Assistant
├── 02-home-assistant-office/      # 🏢 公司的 Home Assistant  
├── 03-lab-management-system/      # 🔬 公司的實驗管理系統
├── shared-tools/                 # 🛠️ 共用工具
└── archive/                      # 📦 歸檔檔案
```

---

## 🏠 01-home-assistant-personal

**家裡的 Home Assistant 系統**

### 🌡️ aircon-system - 空調三系統
- 監控 5 個空調設備（加濕器、全熱交換器、3台冷氣）
- 多重通知系統（NotifyHelper、Synology Chat、Telegram）
- 智能溫度和模式控制

### 🔋 battery-management - 電池管理
- ENELOOP 電池充電管理
- 安全時間控制和監控
- 充電狀態通知

### 🔔 notifications - 通知系統
- NotifyHelper 配置
- 多平台通知整合
- 自定義通知規則

---

## 🏢 02-home-assistant-office

**公司的 Home Assistant 系統**

### 🏢 office-automation - 辦公室自動化
- 會議室環境控制
- 照明和空調自動化
- 工作時間排程

### 📊 meeting-room-control - 會議室控制
- 會議室預約系統
- 環境自動調節
- 使用狀態監控

---

## 🔬 03-lab-management-system

**公司的實驗管理系統**

### 🔬 equipment-monitoring - 設備監控
- 實驗設備狀態監控
- 溫度、濕度、壓力感測
- 異常警報系統

### 📈 data-collection - 資料收集
- 實驗資料自動收集
- 資料庫整合
- 即時資料分析

### 📋 reporting - 報告系統
- 自動報告生成
- 資料視覺化
- 定期報告發送

---

## 🛠️ shared-tools

**跨專案共用工具**

### 🔄 sync-scripts - 同步腳本
- GitHub 同步工具
- 多環境部署腳本
- 配置管理工具

### 📝 templates - 範本檔案
- Node-RED 流程範本
- 配置檔案範本
- 文檔範本

### ⚙️ utilities - 實用工具
- 通用函數庫
- 資料處理工具
- 測試工具

---

## 🚀 快速開始

### 🏠 家裡環境設定
```bash
cd 01-home-assistant-personal/aircon-system
# 參考 README-aircon-notifications.md
```

### 🏢 公司環境設定
```bash
cd 02-home-assistant-office
# 參考各子目錄的 README.md
```

### 🔬 實驗室系統設定
```bash
cd 03-lab-management-system
# 參考各子目錄的 README.md
```

---

## 🔄 同步和部署

### 使用同步腳本
```bash
# Windows
shared-tools\sync-scripts\sync-aircon-system.bat

# Linux/Mac
shared-tools/sync-scripts/sync-aircon-system.sh
```

### 環境間同步
- **家裡 → GitHub**：推送更新
- **GitHub → 公司**：拉取更新
- **配置隔離**：各環境獨立配置

---

## 🛡️ 安全和隱私

### 敏感資訊保護
- ✅ `.gitignore` 保護配置檔案
- ✅ 環境變數分離
- ✅ 範例檔案提供參考

### 權限管理
- 🔒 Private 倉庫
- 🔑 個人存取權杖
- 🏠 家庭網路隔離

---

## 📞 支援和文檔

### 各系統詳細文檔
- 📖 每個子目錄都有詳細的 README.md
- 🚀 快速開始指南
- 🔧 故障排除指南

### 聯繫方式
- 📧 透過 GitHub Issues 回報問題
- 💬 使用 Discussions 討論功能
- 📝 查看 Wiki 獲取更多資訊

---

## 🎯 專案管理建議

### 使用 Augment NEW CHAT 分類
- **🏠 家庭自動化**：處理家裡 HA 相關問題
- **🏢 辦公室系統**：處理公司 HA 和辦公自動化
- **🔬 實驗管理**：處理實驗室設備和資料系統
- **🛠️ 工具開發**：處理共用工具和腳本開發

### 版本控制策略
- `main` 分支：穩定版本
- `dev` 分支：開發版本
- `feature/*` 分支：新功能開發
- `hotfix/*` 分支：緊急修復

---

## 📊 專案狀態

| 系統 | 狀態 | 最後更新 | 版本 |
|------|------|----------|------|
| 🏠 家庭 HA | ✅ 運行中 | 2024-01 | v2.1 |
| 🏢 辦公 HA | 🚧 開發中 | 2024-01 | v1.0 |
| 🔬 實驗管理 | 📋 規劃中 | 2024-01 | v0.1 |

---

## 🎉 貢獻指南

1. **Fork** 此倉庫
2. **建立** 功能分支
3. **提交** 變更
4. **推送** 到分支
5. **建立** Pull Request

感謝您的貢獻！🙏
