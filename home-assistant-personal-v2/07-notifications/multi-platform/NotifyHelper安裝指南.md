# 📱 NotifyHelper 安裝和配置指南

## 🎯 什麼是 NotifyHelper？

NotifyHelper 是一個 Home Assistant 自定義整合，由 kukuxx 開發，它可以：
- 同時向一個人的所有行動裝置發送通知
- 在自定義 Lovelace 卡片上顯示通知
- 支援多人專屬通知卡片配置

## 📋 安裝前準備

### 確認您有以下項目：
- ✅ Home Assistant 正在運行
- ✅ HACS 已安裝並配置
- ✅ 至少一個 person 實體已設定
- ✅ 至少一個行動裝置已連接（Home Assistant Companion App）

---

## 🚀 安裝步驟

### 方法一：透過 HACS 安裝（推薦）

1. **打開 HACS**
   ```
   Home Assistant → HACS → 整合
   ```

2. **搜尋 NotifyHelper**
   - 點擊右上角的「⋮」選單
   - 選擇「自定義存儲庫」
   - 輸入：`https://github.com/kukuxx/HA-NotifyHelper`
   - 類別選擇：「Integration」
   - 點擊「新增」

3. **安裝整合**
   - 搜尋 "NotifyHelper"
   - 點擊「下載」
   - 等待下載完成

4. **重啟 Home Assistant**
   ```
   設定 → 系統 → 重新啟動
   ```

### 方法二：手動安裝

1. **下載檔案**
   - 前往：https://github.com/kukuxx/HA-NotifyHelper
   - 下載最新版本的 ZIP 檔案

2. **解壓縮並複製**
   ```
   解壓縮後，將 custom_components/notifyhelper 資料夾
   複製到您的 Home Assistant 配置目錄下的 custom_components 資料夾
   ```

3. **重啟 Home Assistant**

---

## ⚙️ 配置整合

### 1. 新增整合
```
設定 → 裝置與服務 → 新增整合 → 搜尋 "NotifyHelper"
```

### 2. 配置設定
在設定畫面中：
- **URL**：可選，指定預設 URL
- **其他設定**：根據需要調整

### 3. 確認安裝成功
前往「開發者工具」→「服務」，搜尋 `notify.notify_person`
如果看到此服務，表示安裝成功！

---

## 🔧 在 Node-RED 中使用

### 正確的服務調用格式：

```json
{
    "domain": "notify",
    "service": "notify_person",
    "data": {
        "title": "標題",
        "message": "訊息內容",
        "targets": ["person.ming"]
    }
}
```

### 重要參數說明：

- **service**: 必須是 `notify_person`
- **targets**: 必須是陣列格式，包含 person 實體 ID
- **title**: 通知標題
- **message**: 通知內容

---

## 📱 支援的功能

### 基本通知
```yaml
service: notify.notify_person
data:
  title: "測試通知"
  message: "這是一條測試訊息"
  targets:
    - person.you
```

### 帶圖片的通知
```yaml
service: notify.notify_person
data:
  title: "圖片通知"
  message: "這是帶圖片的通知"
  targets:
    - person.you
  data:
    image: /local/icon.png
```

### iOS 和 Android 分別設定
```yaml
service: notify.notify_person
data:
  title: "平台專屬通知"
  message: "不同平台不同設定"
  targets:
    - person.you
  data:
    ios:
      image: /local/ios_icon.png
      push:
        sound:
          name: custom_sound.wav
          volume: 0.3
    android:
      image: /local/android_icon.png
```

---

## 🛠️ 故障排除

### ❌ 找不到 notify.notify_person 服務
**解決方案**：
1. 確認 NotifyHelper 已正確安裝
2. 檢查 Home Assistant 日誌是否有錯誤
3. 重啟 Home Assistant
4. 確認整合已在「裝置與服務」中啟用

### ❌ 通知沒有發送
**解決方案**：
1. 確認 person 實體存在且正確
2. 確認該 person 有關聯的行動裝置
3. 檢查 Home Assistant Companion App 是否正常運作
4. 查看 Home Assistant 日誌中的錯誤訊息

### ❌ targets 參數錯誤
**解決方案**：
- 確保 targets 是陣列格式：`["person.ming"]`
- 不要使用字串格式：`"person.ming"`
- 確認 person 實體 ID 正確

---

## 📊 在我們的空調通知系統中的應用

在我們的 Node-RED 流程中，NotifyHelper 節點配置如下：

```json
{
    "action": "notify.notify_person",
    "data": {
        "message": "訊息內容",
        "title": "通知標題", 
        "targets": ["person.ming"]
    }
}
```

### 修改 person 實體
如果您的 person 實體不是 `person.ming`，請在流程中修改：

1. 雙擊「NotifyHelper通知」節點
2. 在 data 欄位中找到 `"targets": ["person.ming"]`
3. 將 `person.ming` 改為您的實際 person 實體 ID
4. 點擊「完成」並部署

---

## 🎉 完成！

現在您的 NotifyHelper 已經正確配置，可以接收空調設備的狀態變化通知了！

### 測試通知
您可以在 Node-RED 中點擊測試按鈕，或在 Home Assistant 的開發者工具中手動調用服務來測試通知功能。

---

## 📚 更多資源

- **官方 GitHub**：https://github.com/kukuxx/HA-NotifyHelper
- **Home Assistant 社群**：https://community.home-assistant.io/
- **HACS 文檔**：https://hacs.xyz/

如果您遇到任何問題，建議先查看 Home Assistant 的日誌，通常會有詳細的錯誤訊息幫助您診斷問題。
