# 空調設備通知系統

這是一個基於 Node-RED 的智能家居空調設備監控和通知系統，可以監控5個空調設備的狀態變化，並通過多種方式發送通知。

## 📋 監控設備清單

1. **加濕器** (`humidifier.rdi_640hhchu_shi_ji`)
2. **全熱交換器** (`fan.kpi_253hwquan_re_jiao_huan_qi_air_speed`)
3. **客廳冷氣** (`climate.ke_ting_leng_qi`)
4. **主臥冷氣** (`climate.zhu_wo_leng_qi`)
5. **次臥冷氣** (`climate.ci_wo_leng_qi`)

## 🔔 支援的通知方式

- **NotifyHelper** - Home Assistant 內建通知服務
- **Synology Chat** - 群暉聊天室 Webhook 通知
- **Telegram** - Telegram Bot 訊息通知

## 📁 文件說明

- `aircon-notification-flow.json` - Node-RED 主要流程配置文件
- `device-mapping.json` - 設備名稱和狀態對應配置
- `notification-config.js` - 通知服務詳細配置
- `README-aircon-notifications.md` - 本說明文檔

## 🚀 安裝步驟

### 1. 系統環境

**Home Assistant 環境**：樹莓派 4B
- 建議使用 Home Assistant OS 或 Home Assistant Supervised
- 確保樹莓派有穩定的網路連接
- 建議使用高品質的 SD 卡（Class 10 或更高）

**Node-RED 安裝選項**：

#### 選項 A：在樹莓派上安裝 Node-RED（推薦）
```bash
# 在樹莓派上安裝 Node-RED
bash <(curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered)

# 設定開機自動啟動
sudo systemctl enable nodered.service

# 啟動 Node-RED
sudo systemctl start nodered.service
```

#### 選項 B：使用 Home Assistant Add-on
如果您使用 Home Assistant OS，可以直接安裝 Node-RED Add-on：
1. 進入 Home Assistant → 設定 → 附加元件
2. 搜尋並安裝 "Node-RED"
3. 啟動 Add-on

### 2. 前置需求

確保您已安裝以下 Node-RED 節點：

```bash
# Home Assistant 節點
npm install node-red-contrib-home-assistant-websocket

# Telegram 節點
npm install node-red-contrib-telegrambot

# HTTP 請求節點（通常已內建）
```

**樹莓派特殊注意事項**：
- 如果遇到權限問題，可能需要使用 `sudo npm install`
- 建議定期更新 Node.js 版本以獲得最佳性能

### 2. 導入流程

1. 打開 Node-RED 編輯器
2. 點擊右上角的選單 → 導入
3. 選擇 `aircon-notification-flow.json` 文件
4. 點擊「導入」按鈕

### 3. 配置 Home Assistant 連接

#### 樹莓派 Home Assistant 連接配置

1. 雙擊任一個「狀態監控」節點
2. 點擊「Server」旁的編輯按鈕
3. 配置您的樹莓派 Home Assistant 連接資訊：

**如果 Node-RED 安裝在同一台樹莓派上**：
- **Base URL**: `http://localhost:8123` 或 `http://127.0.0.1:8123`
- **Access Token**: 在 Home Assistant 中生成長期存取權杖

**如果 Node-RED 安裝在其他設備上**：
- **Base URL**: `http://樹莓派IP:8123`（例如：`http://192.168.1.100:8123`）
- **Access Token**: 在 Home Assistant 中生成長期存取權杖

**生成 Access Token 步驟**：
1. 登入樹莓派上的 Home Assistant
2. 點擊左下角的用戶名
3. 滾動到「長期存取權杖」區域
4. 點擊「建立權杖」
5. 輸入權杖名稱（例如：Node-RED Aircon Notifications）
6. 複製生成的權杖並保存好

### 4. 配置通知服務

#### NotifyHelper 配置

1. 雙擊「NotifyHelper 發送」節點
2. 確認服務名稱為 `notify.notify`（或您的實際服務名稱）
3. 如需要，可修改通知內容格式

#### Synology Chat 配置

1. 在 Synology Chat 中創建 Incoming Webhook
2. 雙擊「Synology Chat 發送」節點
3. 將 URL 替換為您的 Webhook URL
4. 格式：`https://your-synology-ip:5001/webapi/entry.cgi?api=SYNO.Chat.External&method=incoming&version=2&token=YOUR_TOKEN`

#### Telegram 配置

1. 創建 Telegram Bot：
   - 與 @BotFather 對話
   - 使用 `/newbot` 命令創建新 Bot
   - 獲取 Bot Token

2. 獲取 Chat ID：
   - 與您的 Bot 對話，發送任意訊息
   - 訪問：`https://api.telegram.org/botYOUR_BOT_TOKEN/getUpdates`
   - 從回應中找到 `chat.id`

3. 雙擊「Telegram 發送」節點
4. 點擊「Bot」旁的編輯按鈕
5. 輸入您的 Bot Token

## ⚙️ 自定義配置

### 修改設備名稱

編輯 `device-mapping.json` 文件中的 `friendlyName` 欄位：

```json
{
  "devices": {
    "climate.ke_ting_leng_qi": {
      "friendlyName": "客廳冷氣",  // 修改這裡
      "location": "客廳"
    }
  }
}
```

### 調整通知內容

在「狀態處理器」節點中修改訊息格式：

```javascript
const message = {
    title: `${deviceName}狀態變更`,
    fullMessage: `${statusIcon} ${deviceName}已${stateName}\n時間：${timestamp}\n設備：${entityId}`
};
```

### 設置靜音時間

在 `notification-config.js` 中配置：

```javascript
quietHours: {
    enabled: true,
    start: '23:00',  // 開始時間
    end: '07:00'     // 結束時間
}
```

## 🔧 功能特色

### 防重複通知

系統會記住每個設備的上次通知狀態，避免重複發送相同的通知。

### 狀態圖示

- 🟢 開啟/運行
- 🔴 關閉
- 🟡 其他狀態
- ⚠️ 無法連接
- ❓ 未知狀態

### 錯誤處理

包含完整的錯誤捕獲和日誌記錄功能。

## 📊 監控和除錯

### 查看通知日誌

1. 在 Node-RED 中點擊「除錯」標籤
2. 查看「通知日誌」和「錯誤日誌」的輸出

### 測試通知

您可以手動觸發設備狀態變化來測試通知：

1. 在 Home Assistant 中手動開關設備
2. 觀察 Node-RED 除錯面板的輸出
3. 檢查各通知平台是否收到訊息

## 🛠️ 故障排除

### 常見問題

**Q: 沒有收到通知？**
A: 檢查以下項目：
- Home Assistant 連接是否正常
- 設備實體 ID 是否正確
- 通知服務配置是否正確
- 查看 Node-RED 除錯日誌

**Q: 收到重複通知？**
A: 系統有防重複機制，如果仍收到重複通知，請檢查「狀態處理器」節點的邏輯。

**Q: Telegram 通知失敗？**
A: 確認：
- Bot Token 正確
- Chat ID 正確
- Bot 有發送訊息的權限

**Q: Synology Chat 通知失敗？**
A: 確認：
- Webhook URL 正確
- Synology Chat 服務正在運行
- 網路連接正常

## 📝 自定義擴展

### 添加新設備

1. 在流程中複製一個現有的監控節點
2. 修改實體 ID
3. 在「狀態處理器」中添加設備名稱對應
4. 更新 `device-mapping.json`

### 添加新通知服務

1. 添加新的 HTTP 請求或服務調用節點
2. 在「訊息格式化器」中添加新的輸出
3. 配置相應的訊息格式

## 📞 技術支援

如果您在使用過程中遇到問題，請檢查：

1. Node-RED 日誌
2. Home Assistant 日誌
3. 網路連接狀態
4. 各服務的 API 配額限制

---

**注意**: 請記得定期備份您的 Node-RED 流程配置，並妥善保管各種 API 金鑰和權杖。
