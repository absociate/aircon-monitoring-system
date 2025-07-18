# 🏠 空調三系統 GitHub 同步指南

## 📋 專案概述
這是一個基於 Node-RED 的智能家居空調設備監控和通知系統，包含：
- 5個空調設備監控（加濕器、全熱交換器、3台冷氣）
- 多重通知系統（NotifyHelper、Synology Chat、Telegram）
- 完整的配置和安裝腳本

## 🚀 GitHub 同步方案

### 方案一：專用倉庫（推薦）
建立一個專門的空調系統倉庫，便於管理和同步。

#### 1️⃣ 建立新倉庫
```bash
# 在 GitHub 上建立新倉庫：aircon-monitoring-system
# 然後在本地執行：

cd c:\Users\absoc\Documents\augment-projects\Lab
git init
git remote add origin https://github.com/YOUR_USERNAME/aircon-monitoring-system.git
```

#### 2️⃣ 準備同步檔案清單
以下檔案建議同步到 GitHub：

**核心檔案：**
- `README-aircon-notifications.md` - 主要說明文檔
- `aircon-notification-complete.json` - 最新完整流程
- `device-mapping.json` - 設備配置對應
- `notification-config.js` - 通知服務配置

**安裝和配置：**
- `install-aircon-notifications.sh` - Linux/Mac 安裝腳本
- `install-aircon-notifications.bat` - Windows 安裝腳本
- `test-notifications.js` - 測試腳本

**說明文檔：**
- `快速使用指南.md`
- `修正版使用指南.md`
- `增強版使用指南.md`

#### 3️⃣ 建立 .gitignore
```gitignore
# 環境變數檔案（包含敏感資訊）
.env
.env.local
.env.production

# Node.js
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# 個人配置檔案
config.local.js
secrets.json

# 系統檔案
.DS_Store
Thumbs.db

# IDE 檔案
.vscode/
.idea/
*.swp
*.swo

# 日誌檔案
logs/
*.log
```

#### 4️⃣ 建立環境變數範例檔案
```bash
# 複製現有配置為範例檔案
cp notification-config.js notification-config.example.js
```

### 方案二：在現有 Lab 倉庫中建立子目錄
如果您想保持在現有的 Lab 倉庫中：

#### 1️⃣ 建立專用目錄結構
```
Lab/
├── aircon-system/
│   ├── README.md
│   ├── flows/
│   │   ├── aircon-notification-complete.json
│   │   ├── aircon-notification-enhanced.json
│   │   └── aircon-notification-fixed.json
│   ├── config/
│   │   ├── device-mapping.json
│   │   ├── notification-config.js
│   │   └── notification-config.example.js
│   ├── scripts/
│   │   ├── install-aircon-notifications.sh
│   │   ├── install-aircon-notifications.bat
│   │   └── test-notifications.js
│   └── docs/
│       ├── 快速使用指南.md
│       ├── 修正版使用指南.md
│       └── 增強版使用指南.md
```

## 🔧 同步設定步驟

### 1️⃣ 初始化 Git（如果尚未設定）
```bash
cd c:\Users\absoc\Documents\augment-projects\Lab
git init
git remote add origin https://github.com/YOUR_USERNAME/aircon-monitoring-system.git
```

### 2️⃣ 建立分支策略
```bash
# 建立開發分支
git checkout -b aircon-system-dev

# 建立公司同步分支
git checkout -b company-sync
```

### 3️⃣ 設定同步腳本
建立自動同步腳本，方便在家裡和公司之間同步。

## 📱 公司環境設定

### 1️⃣ 在公司電腦上複製專案
```bash
# 複製倉庫
git clone https://github.com/YOUR_USERNAME/aircon-monitoring-system.git
cd aircon-monitoring-system

# 或者如果使用現有 Lab 倉庫
git clone https://github.com/YOUR_USERNAME/Lab.git
cd Lab/aircon-system
```

### 2️⃣ 安裝依賴
```bash
# 執行安裝腳本
./install-aircon-notifications.sh  # Linux/Mac
# 或
install-aircon-notifications.bat   # Windows
```

### 3️⃣ 配置環境
```bash
# 複製配置範例
cp notification-config.example.js notification-config.js
# 編輯配置檔案，填入公司環境的設定
```

## 🔄 日常同步工作流程

### 在家裡（推送更新）
```bash
# 提交變更
git add .
git commit -m "更新空調系統配置"
git push origin main
```

### 在公司（拉取更新）
```bash
# 拉取最新變更
git pull origin main

# 如果有衝突，解決後再提交
git add .
git commit -m "解決衝突並更新公司環境配置"
git push origin main
```

## 🛡️ 安全注意事項

1. **敏感資訊保護**
   - 絕對不要提交包含密碼、Token 的檔案
   - 使用 `.gitignore` 排除敏感檔案
   - 建立 `.example` 範例檔案

2. **公司網路考量**
   - 確認公司允許存取 GitHub
   - 如需要，設定 VPN 連線
   - 考慮使用 SSH 金鑰認證

3. **版本控制最佳實踐**
   - 定期提交小的變更
   - 使用有意義的提交訊息
   - 建立不同分支處理實驗性功能

## 📞 支援和疑難排解

如果遇到同步問題：
1. 檢查網路連線和 GitHub 存取權限
2. 確認 Git 配置正確
3. 檢查是否有檔案衝突需要解決
4. 參考 Git 官方文檔或尋求技術支援
