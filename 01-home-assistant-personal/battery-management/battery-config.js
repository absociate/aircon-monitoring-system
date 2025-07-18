/**
 * 智能充電電池管理系統配置
 * 用於 Node-RED 的充電電池自動化管理
 */

// 充電電池配置
const batteryConfig = {
    // 牧田充電電池配置
    makita: {
        entityId: 'media_player.volume_set',
        friendlyName: '牧田BL1041B充電電池',
        batteryType: 'lithium-ion',
        location: 'HS300 2-4插座',
        chargingTime: 90, // 分鐘 (1.5小時)
        maintenanceCycle: 30, // 天 (每月維護)
        maxChargingTime: 180, // 安全上限 (3小時)
        description: '牧田18V鋰離子充電電池',
        icon: '🔋',
        color: '#FF6B35'
    },
    
    // ENELOOP 3號電池配置
    eneloop_aa: {
        entityId: 'switch.tp_link_power_strip_eb2f_cha_shang_5',
        friendlyName: 'ENELOOP 3號充電電池',
        batteryType: 'ni-mh',
        location: 'HS300 2-5插座',
        chargingTime: 240, // 分鐘 (4小時)
        maintenanceCycle: 60, // 天 (每2個月維護)
        maxChargingTime: 360, // 安全上限 (6小時)
        description: 'ENELOOP AA鎳氫充電電池',
        icon: '🔋',
        color: '#4CAF50'
    },
    
    // ENELOOP 4號電池配置
    eneloop_aaa: {
        entityId: 'switch.tp_link_power_strip_eb2f_cha_shang_6',
        friendlyName: 'ENELOOP 4號充電電池',
        batteryType: 'ni-mh',
        location: 'HS300 2-6插座',
        chargingTime: 210, // 分鐘 (3.5小時)
        maintenanceCycle: 60, // 天 (每2個月維護)
        maxChargingTime: 300, // 安全上限 (5小時)
        description: 'ENELOOP AAA鎳氫充電電池',
        icon: '🔋',
        color: '#2196F3'
    }
};

// 通知配置
const notificationConfig = {
    // NotifyHelper 配置
    notifyHelper: {
        enabled: true,
        service: 'notify.notify',
        targets: ['person.ming'], // 根據您的person實體調整
        priority: 'normal'
    },
    
    // Synology Chat 配置
    synologyChat: {
        enabled: true,
        service: 'notify.synology_chat_bot_3',
        username: 'Battery Manager',
        channel: '#smart-home'
    },
    
    // Telegram 配置
    telegram: {
        enabled: true,
        service: 'notify.telegram',
        parseMode: 'HTML'
    }
};

// 訊息模板
const messageTemplates = {
    chargingStarted: {
        title: '🔋 充電開始',
        message: '{{icon}} {{batteryName}} 開始充電\n📍 位置：{{location}}\n⏱️ 預計充電時間：{{chargingTime}}分鐘\n🕐 開始時間：{{timestamp}}'
    },
    
    chargingCompleted: {
        title: '✅ 充電完成',
        message: '{{icon}} {{batteryName}} 充電完成\n📍 位置：{{location}}\n⏱️ 充電時長：{{actualTime}}分鐘\n🕐 完成時間：{{timestamp}}'
    },
    
    maintenanceCharging: {
        title: '🔄 維護充電',
        message: '{{icon}} {{batteryName}} 開始維護充電\n📍 位置：{{location}}\n📅 距離上次充電：{{daysSinceLastCharge}}天\n⏱️ 預計充電時間：{{chargingTime}}分鐘'
    },
    
    chargingError: {
        title: '⚠️ 充電異常',
        message: '{{icon}} {{batteryName}} 充電異常\n📍 位置：{{location}}\n❌ 錯誤：{{error}}\n🕐 時間：{{timestamp}}'
    },
    
    safetyStop: {
        title: '🛡️ 安全停止',
        message: '{{icon}} {{batteryName}} 達到安全時間上限，自動停止充電\n📍 位置：{{location}}\n⏱️ 充電時長：{{actualTime}}分鐘\n🕐 停止時間：{{timestamp}}'
    }
};

// 系統設定
const systemConfig = {
    // 定期檢查時間 (每日早上8點)
    maintenanceCheckTime: '08:00',
    
    // 靜音時間段 (避免夜間通知)
    quietHours: {
        enabled: true,
        start: '22:00',
        end: '07:00'
    },
    
    // 安全設定
    safety: {
        maxConcurrentCharging: 2, // 最多同時充電數量
        emergencyStopEnabled: true,
        temperatureMonitoring: false // 如果有溫度感測器可啟用
    },
    
    // 資料儲存設定
    storage: {
        useHomeAssistantHelpers: true, // 使用HA的input_datetime
        contextStorageKey: 'batteryChargingData'
    }
};

// 狀態圖示對應
const statusIcons = {
    charging: '🔋',
    completed: '✅',
    maintenance: '🔄',
    error: '⚠️',
    safety: '🛡️',
    idle: '💤'
};

// 電池類型特性
const batteryCharacteristics = {
    'lithium-ion': {
        selfDischargeRate: 0.025, // 每月2.5%
        memoryEffect: false,
        optimalChargeRange: [20, 80], // 最佳充電範圍
        cycleLife: 1000
    },
    'ni-mh': {
        selfDischargeRate: 0.004, // 每月0.4% (低自放電型)
        memoryEffect: false, // ENELOOP無記憶效應
        optimalChargeRange: [0, 100],
        cycleLife: 2100
    }
};

// 工具函數
const utils = {
    // 格式化訊息
    formatMessage: function(template, data) {
        let message = template;
        Object.keys(data).forEach(key => {
            const regex = new RegExp(`{{${key}}}`, 'g');
            message = message.replace(regex, data[key] || '');
        });
        return message;
    },
    
    // 檢查是否在靜音時間
    isQuietHours: function() {
        if (!systemConfig.quietHours.enabled) return false;
        
        const now = new Date();
        const currentTime = now.getHours() * 100 + now.getMinutes();
        const startTime = parseInt(systemConfig.quietHours.start.replace(':', ''));
        const endTime = parseInt(systemConfig.quietHours.end.replace(':', ''));
        
        if (startTime > endTime) {
            // 跨日情況 (如 22:00 到 07:00)
            return currentTime >= startTime || currentTime <= endTime;
        } else {
            return currentTime >= startTime && currentTime <= endTime;
        }
    },
    
    // 計算充電時間 (分鐘轉換為小時分鐘格式)
    formatChargingTime: function(minutes) {
        const hours = Math.floor(minutes / 60);
        const mins = minutes % 60;
        if (hours > 0) {
            return `${hours}小時${mins}分鐘`;
        }
        return `${mins}分鐘`;
    },
    
    // 獲取當前時間戳
    getCurrentTimestamp: function() {
        return new Date().toLocaleString('zh-TW', {
            timeZone: 'Asia/Taipei',
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit'
        });
    }
};

// 導出配置
module.exports = {
    batteryConfig,
    notificationConfig,
    messageTemplates,
    systemConfig,
    statusIcons,
    batteryCharacteristics,
    utils
};

// 如果在 Node-RED 環境中，將配置設置為全域變數
if (typeof global !== 'undefined' && global.get) {
    global.set('batteryChargingConfig', {
        batteryConfig,
        notificationConfig,
        messageTemplates,
        systemConfig,
        statusIcons,
        batteryCharacteristics,
        utils
    });
}
