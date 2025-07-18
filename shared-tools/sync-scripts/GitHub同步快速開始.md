# 🚀 空調系統 GitHub 同步 - 快速開始

## 📍 您的專案位置
```
c:\Users\absoc\Documents\augment-projects\Lab
```

## ⚡ 立即開始（5分鐘設定）

### 步驟 1：在 GitHub 建立倉庫
1. 打開 [GitHub](https://github.com)
2. 點擊右上角的 **"+"** → **"New repository"**
3. 倉庫名稱：`aircon-monitoring-system`
4. 設為 **Private**（保護您的家庭設備資訊）
5. 點擊 **"Create repository"**

### 步驟 2：在家裡的電腦設定
打開 **PowerShell** 或 **命令提示字元**，執行：

```powershell
# 1. 進入您的專案目錄
cd c:\Users\absoc\Documents\augment-projects\Lab

# 2. 初始化 Git（如果尚未設定）
git init

# 3. 設定遠端倉庫（替換 YOUR_USERNAME 為您的 GitHub 用戶名）
git remote add origin https://github.com/YOUR_USERNAME/aircon-monitoring-system.git

# 4. 添加所有檔案
git add .

# 5. 第一次提交
git commit -m "初始化空調監控系統專案"

# 6. 推送到 GitHub
git push -u origin main
```

### 步驟 3：使用同步腳本
以後只需要雙擊執行：
```
sync-aircon-system.bat
```

## 🏢 在公司電腦設定

### 步驟 1：複製專案
```powershell
# 1. 選擇一個目錄（例如桌面）
cd C:\Users\您的用戶名\Desktop

# 2. 複製專案（替換 YOUR_USERNAME）
git clone https://github.com/YOUR_USERNAME/aircon-monitoring-system.git

# 3. 進入專案目錄
cd aircon-monitoring-system
```

### 步驟 2：設定配置
```powershell
# 複製配置範例
copy notification-config.example.js notification-config.js

# 用記事本編輯配置（填入公司環境的設定）
notepad notification-config.js
```

### 步驟 3：日常同步
雙擊執行：
```
sync-aircon-system.bat
```
選擇 **"2. 從 GitHub 拉取更新"**

## 🔄 日常使用流程

### 在家裡修改後：
1. 雙擊 `sync-aircon-system.bat`
2. 選擇 **"1. 推送更新到 GitHub"**
3. 輸入提交訊息（例如：更新冷氣設定）

### 在公司要使用時：
1. 雙擊 `sync-aircon-system.bat`
2. 選擇 **"2. 從 GitHub 拉取更新"**

## 🛡️ 安全提醒

### ✅ 已保護的資訊
- `.gitignore` 已設定，以下檔案不會上傳：
  - `.env` 檔案（環境變數）
  - `notification-config.js`（實際配置）
  - 任何包含密碼、Token 的檔案

### ⚠️ 注意事項
- 只上傳 `notification-config.example.js`（範例檔案）
- 實際的配置檔案只存在本地
- 在公司需要重新設定配置檔案

## 🆘 常見問題

### Q: 忘記 GitHub 用戶名怎麼辦？
A: 登入 GitHub 後，右上角頭像旁邊就是您的用戶名

### Q: 推送時要求輸入密碼？
A: 現在 GitHub 需要使用 Personal Access Token：
1. GitHub → Settings → Developer settings → Personal access tokens
2. 生成新的 Token
3. 使用 Token 作為密碼

### Q: 公司網路無法存取 GitHub？
A: 
1. 嘗試使用公司 VPN
2. 或使用手機熱點
3. 聯繫 IT 部門確認網路政策

### Q: 檔案衝突怎麼辦？
A: 同步腳本會自動處理大部分衝突，如果無法自動解決會提示您手動處理

## 📞 需要幫助？
如果遇到任何問題，可以：
1. 查看 `aircon-system-sync-guide.md` 詳細說明
2. 檢查 Git 狀態：`git status`
3. 查看提交歷史：`git log --oneline`

---

## 🎯 總結
設定完成後，您只需要：
- **在家裡**：修改 → 執行腳本 → 選擇推送
- **在公司**：執行腳本 → 選擇拉取 → 開始工作

就這麼簡單！🎉
