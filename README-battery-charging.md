# 🔋 智能充電電池管理系統

## 📋 系統概述

這是一個專為您的HS300智能插座設計的充電電池管理系統，支援牧田BL1041B和ENELOOP充電電池的智能充電管理。

### 🎯 主要功能

- ✅ **手動充電自動管理**：檢測手動開啟，自動計時關閉
- ✅ **定期維護充電**：根據電池特性自動維護
- ✅ **多重通知系統**：NotifyHelper、Synology Chat、Telegram
- ✅ **安全保護機制**：防止過度充電和重複啟動
- ✅ **可配置參數**：充電時間和維護週期可調整

### 🔌 支援設備

| 電池類型 | 插座位置 | 實體ID | 充電時間 | 維護週期 |
|---------|---------|--------|---------|---------|
| 牧田BL1041B | HS300 2-4插座 | `media_player.volume_set` | 90分鐘 | 30天 |
| ENELOOP 3號 | HS300 2-5插座 | `switch.tp_link_power_strip_eb2f_cha_shang_5` | 240分鐘 | 60天 |
| ENELOOP 4號 | HS300 2-6插座 | `switch.tp_link_power_strip_eb2f_cha_shang_6` | 210分鐘 | 60天 |

---

## 🚀 安裝步驟

### 1️⃣ 安裝Home Assistant輔助實體

將 `battery-helpers.yaml` 的內容添加到您的 Home Assistant 配置中：

```bash
# 方法一：添加到 configuration.yaml
cat battery-helpers.yaml >> configuration.yaml

# 方法二：創建單獨的 helpers.yaml 文件
cp battery-helpers.yaml config/helpers.yaml
```

然後在 `configuration.yaml` 中添加：
```yaml
# 如果使用單獨的 helpers.yaml 文件
homeassistant:
  packages: !include_dir_named packages/
```

### 2️⃣ 重啟Home Assistant

```bash
# 重啟Home Assistant以載入新的輔助實體
sudo systemctl restart home-assistant@homeassistant
```

### 3️⃣ 導入Node-RED流程

1. **打開Node-RED編輯器**
   ```
   http://樹莓派IP:1880
   ```

2. **導入流程文件**
   - 點擊右上角選單 → 導入
   - 選擇 `battery-charging-flow.json` 文件
   - 點擊「導入」

3. **配置Home Assistant連接**
   - 雙擊任一個節點
   - 點擊「Server」旁的編輯按鈕
   - 配置連接資訊：
     - **Base URL**: `http://localhost:8123`（同台樹莓派）
     - **Access Token**: 從HA用戶設定中生成

### 4️⃣ 載入配置文件

在Node-RED中添加一個初始化節點來載入配置：

1. 拖拽一個「inject」節點到工作區
2. 設定為「inject once after 0.1 seconds」
3. 連接到一個「function」節點
4. 在function節點中貼入以下代碼：

```javascript
// 載入電池充電配置
const fs = require('fs');
const path = require('path');

try {
    // 讀取配置文件
    const configPath = path.join(__dirname, 'battery-config.js');
    delete require.cache[require.resolve(configPath)];
    const config = require(configPath);
    
    // 設定全域變數
    global.set('batteryChargingConfig', config);
    
    node.status({fill:"green", shape:"dot", text:"配置已載入"});
    msg.payload = "電池充電配置已成功載入";
} catch (error) {
    node.status({fill:"red", shape:"ring", text:"配置載入失敗"});
    msg.payload = "配置載入失敗: " + error.message;
}

return msg;
```

---

## ⚙️ 配置說明

### 🔧 基本設定

在Home Assistant中，您可以透過以下實體控制系統：

#### 系統開關
- `input_boolean.battery_management_enabled` - 電池管理系統總開關
- `input_boolean.battery_auto_maintenance` - 自動維護充電開關
- `input_boolean.battery_charging_notifications` - 充電通知開關

#### 個別電池控制
- `input_boolean.makita_charging_enabled` - 牧田電池充電管理
- `input_boolean.eneloop_aa_charging_enabled` - ENELOOP 3號電池充電管理
- `input_boolean.eneloop_aaa_charging_enabled` - ENELOOP 4號電池充電管理

#### 充電時間設定
- `input_number.makita_charging_time` - 牧田電池充電時間（30-180分鐘）
- `input_number.eneloop_aa_charging_time` - ENELOOP 3號充電時間（60-360分鐘）
- `input_number.eneloop_aaa_charging_time` - ENELOOP 4號充電時間（60-300分鐘）

#### 維護週期設定
- `input_number.makita_maintenance_cycle` - 牧田電池維護週期（7-90天）
- `input_number.eneloop_maintenance_cycle` - ENELOOP電池維護週期（14-120天）

### 📱 通知設定

編輯 `battery-config.js` 中的通知配置：

```javascript
const notificationConfig = {
    notifyHelper: {
        enabled: true,
        service: 'notify.notify',
        targets: ['person.your_name'], // 修改為您的person實體
        priority: 'normal'
    },
    synologyChat: {
        enabled: true,
        service: 'notify.synology_chat_bot_3', // 修改為您的服務名稱
        username: 'Battery Manager',
        channel: '#smart-home'
    },
    telegram: {
        enabled: true,
        service: 'notify.telegram', // 修改為您的服務名稱
        parseMode: 'HTML'
    }
};
```

---

## 🎮 使用方法

### 📱 手動充電

1. **開始充電**：手動開啟對應的智能插座
2. **自動管理**：系統自動檢測並啟動計時器
3. **通知提醒**：收到充電開始通知
4. **自動關閉**：達到設定時間後自動關閉插座
5. **完成通知**：收到充電完成通知

### 🔄 維護充電

系統每日早上8點自動檢查：
- 計算距離上次充電的天數
- 如果超過維護週期，自動開啟充電
- 發送維護充電通知
- 執行完整充電流程

### 📊 狀態監控

在Home Assistant中查看：
- `sensor.makita_days_since_charge` - 牧田電池距離上次充電天數
- `sensor.eneloop_aa_days_since_charge` - ENELOOP 3號距離上次充電天數
- `sensor.eneloop_aaa_days_since_charge` - ENELOOP 4號距離上次充電天數

---

## 🛡️ 安全機制

### ⏰ 充電時間保護
- 每種電池都有最大充電時間限制
- 達到上限自動停止並發送安全通知

### 🔄 重複啟動防護
- 檢測是否已有計時器運行
- 避免重複啟動造成的問題

### 🌙 靜音時間
- 晚上22:00到早上07:00為靜音時間
- 僅緊急通知（錯誤、安全停止）會發送

### 📱 多重通知
- 同時發送到多個通知平台
- 確保重要訊息不會遺漏

---

## 🔧 故障排除

### ❌ 配置未載入
**症狀**：系統無反應，無通知
**解決方案**：
1. 檢查 `battery-config.js` 文件路徑
2. 確認Node-RED有讀取權限
3. 重新部署流程

### ❌ 通知未發送
**症狀**：充電正常但無通知
**解決方案**：
1. 檢查通知服務配置
2. 確認Home Assistant通知服務正常
3. 檢查靜音時間設定

### ❌ 插座無法控制
**症狀**：計時器正常但插座未關閉
**解決方案**：
1. 確認實體ID正確
2. 檢查Home Assistant連接
3. 測試手動控制插座

### ❌ 維護充電未觸發
**症狀**：超過維護週期但未自動充電
**解決方案**：
1. 檢查系統開關狀態
2. 確認維護充電開關已啟用
3. 檢查定時觸發器設定

---

## 📈 進階功能

### 🎛️ 自訂充電模式

您可以在 `battery-config.js` 中添加自訂模式：

```javascript
// 快速充電模式
const quickChargeMode = {
    makita: { chargingTime: 60 },      // 1小時快充
    eneloop_aa: { chargingTime: 180 }, // 3小時快充
    eneloop_aaa: { chargingTime: 150 } // 2.5小時快充
};
```

### 📊 充電統計

系統自動記錄：
- 上次充電時間
- 充電次數統計
- 維護充電記錄

### 🌡️ 溫度監控（可選）

如果您有溫度感測器，可以啟用溫度監控：

```javascript
const systemConfig = {
    safety: {
        temperatureMonitoring: true,
        maxTemperature: 45 // 攝氏度
    }
};
```

---

## 📞 技術支援

如果您遇到問題：

1. **檢查日誌**：查看Node-RED和Home Assistant日誌
2. **測試連接**：確認所有服務正常運行
3. **重新部署**：嘗試重新導入流程
4. **重啟服務**：重啟Node-RED和Home Assistant

---

## 🔄 更新說明

### v1.0.0 (初始版本)
- 基本充電管理功能
- 多重通知系統
- 安全保護機制
- 維護充電功能
