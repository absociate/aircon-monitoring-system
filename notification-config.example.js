/**
 * 空調設備通知系統配置範例
 * 用於 Node-RED 的通知服務配置
 * 
 * 使用說明：
 * 1. 複製此檔案為 notification-config.js
 * 2. 填入您的實際配置值
 * 3. 確保 notification-config.js 已加入 .gitignore
 */

// NotifyHelper 配置
const notifyHelperConfig = {
    enabled: true,
    service: 'notify.notify', // 根據您的 Home Assistant 配置調整
    defaultPriority: 'normal',
    defaultSound: 'default',
    
    // 訊息模板
    messageTemplate: {
        title: '{{deviceName}}狀態變更',
        message: '{{statusIcon}} {{deviceName}}已{{newState}}\n時間：{{timestamp}}\n位置：{{location}}'
    },
    
    // 優先級設定
    priorityMapping: {
        'on': 'normal',
        'off': 'normal',
        'unavailable': 'high',
        'unknown': 'high'
    }
};

// Synology Chat 配置
const synologyChatConfig = {
    enabled: true,
    webhookUrl: 'https://your-synology-nas.com:5001/webapi/entry.cgi?api=SYNO.Chat.External&method=chatbot&version=2&token=YOUR_WEBHOOK_TOKEN',
    username: 'Home Assistant',
    channel: '#smart-home',
    iconEmoji: ':house:',
    
    // 訊息模板
    messageTemplate: {
        text: '{{statusIcon}} *{{deviceName}}* 已{{newState}}\n📍 位置：{{location}}\n🕐 時間：{{timestamp}}',
        username: 'Smart Home Bot',
        icon_emoji: '{{statusIcon}}'
    },
    
    // HTTP 請求配置
    httpConfig: {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        timeout: 5000
    }
};

// Telegram 配置
const telegramConfig = {
    enabled: true,
    botToken: 'YOUR_TELEGRAM_BOT_TOKEN', // 從 @BotFather 獲取
    chatId: 'YOUR_TELEGRAM_CHAT_ID', // 您的 Telegram Chat ID
    parseMode: 'HTML',
    disableNotification: false,
    
    // 訊息模板
    messageTemplate: {
        text: '{{statusIcon}} <b>{{deviceName}}</b> 已{{newState}}\n📍 位置：{{location}}\n🕐 時間：{{timestamp}}',
        parse_mode: 'HTML',
        disable_notification: false
    },
    
    // API 配置
    apiConfig: {
        baseUrl: 'https://api.telegram.org/bot',
        timeout: 10000,
        retries: 3
    }
};

// 狀態圖示對應
const statusIcons = {
    // 基本狀態
    'on': '🟢',
    'off': '🔴',
    'unavailable': '⚠️',
    'unknown': '❓',
    
    // 空調模式
    'heat': '🔥',
    'cool': '❄️',
    'auto': '🔄',
    'dry': '💨',
    'fan_only': '🌪️',
    
    // 風扇速度
    'low': '🌬️',
    'medium': '💨',
    'high': '🌪️',
    
    // 其他設備
    'humidifier': '💧',
    'dehumidifier': '🌵',
    'ventilation': '🌀'
};

// 狀態顏色對應（用於 UI 顯示）
const statusColors = {
    'on': '#4CAF50',
    'off': '#F44336',
    'heat': '#FF5722',
    'cool': '#2196F3',
    'auto': '#FF9800',
    'dry': '#9C27B0',
    'fan_only': '#607D8B',
    'unavailable': '#FFC107',
    'unknown': '#9E9E9E'
};

// 通知過濾規則
const notificationFilters = {
    // 忽略的狀態變化
    ignoreStateChanges: [
        { from: 'unknown', to: 'unavailable' },
        { from: 'unavailable', to: 'unknown' }
    ],
    
    // 靜音時間段（24小時制）
    quietHours: {
        enabled: true,
        start: '23:00',
        end: '07:00'
    },
    
    // 重複通知防護（秒）
    duplicateProtection: 60,
    
    // 僅在特定狀態變化時通知
    notifyOnlyFor: [
        'on', 'off', 'heat', 'cool', 'auto', 'unavailable'
    ]
};

// 訊息格式化函數
function formatMessage(template, data) {
    let message = template;
    
    // 替換所有模板變數
    Object.keys(data).forEach(key => {
        const regex = new RegExp(`{{${key}}}`, 'g');
        message = message.replace(regex, data[key] || '');
    });
    
    return message;
}

// 檢查是否在靜音時間
function isQuietHours() {
    if (!notificationFilters.quietHours.enabled) {
        return false;
    }
    
    const now = new Date();
    const currentTime = now.getHours() * 100 + now.getMinutes();
    
    const startTime = parseInt(notificationFilters.quietHours.start.replace(':', ''));
    const endTime = parseInt(notificationFilters.quietHours.end.replace(':', ''));
    
    if (startTime > endTime) {
        // 跨日情況（如 23:00 到 07:00）
        return currentTime >= startTime || currentTime <= endTime;
    } else {
        // 同日情況
        return currentTime >= startTime && currentTime <= endTime;
    }
}

// 檢查是否應該發送通知
function shouldNotify(fromState, toState) {
    // 檢查是否在忽略清單中
    const ignored = notificationFilters.ignoreStateChanges.some(rule => 
        rule.from === fromState && rule.to === toState
    );
    
    if (ignored) {
        return false;
    }
    
    // 檢查是否在允許的狀態清單中
    if (notificationFilters.notifyOnlyFor.length > 0) {
        return notificationFilters.notifyOnlyFor.includes(toState);
    }
    
    return true;
}

// 環境變數配置（用於敏感資訊）
const envConfig = {
    // Home Assistant
    HA_URL: process.env.HA_URL || 'http://localhost:8123',
    HA_TOKEN: process.env.HA_TOKEN || 'YOUR_HOME_ASSISTANT_TOKEN',
    
    // Synology Chat
    SYNOLOGY_CHAT_WEBHOOK: process.env.SYNOLOGY_CHAT_WEBHOOK || 'YOUR_SYNOLOGY_CHAT_WEBHOOK_URL',
    
    // Telegram
    TELEGRAM_BOT_TOKEN: process.env.TELEGRAM_BOT_TOKEN || 'YOUR_TELEGRAM_BOT_TOKEN',
    TELEGRAM_CHAT_ID: process.env.TELEGRAM_CHAT_ID || 'YOUR_TELEGRAM_CHAT_ID',
    
    // 其他設定
    NODE_ENV: process.env.NODE_ENV || 'development',
    LOG_LEVEL: process.env.LOG_LEVEL || 'info'
};

// 匯出配置（如果在 Node.js 環境中）
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        notifyHelperConfig,
        synologyChatConfig,
        telegramConfig,
        statusIcons,
        statusColors,
        notificationFilters,
        formatMessage,
        isQuietHours,
        shouldNotify,
        envConfig
    };
}

// 如果在 Node-RED 環境中，將配置設置為全域變數
if (typeof global !== 'undefined' && global.get) {
    global.set('airconNotificationConfig', {
        notifyHelperConfig,
        synologyChatConfig,
        telegramConfig,
        statusIcons,
        statusColors,
        notificationFilters,
        formatMessage,
        isQuietHours,
        shouldNotify,
        envConfig
    });
}

// 配置驗證函數
function validateConfig() {
    const errors = [];
    
    // 檢查必要的配置
    if (telegramConfig.enabled && !envConfig.TELEGRAM_BOT_TOKEN.startsWith('YOUR_')) {
        if (!envConfig.TELEGRAM_BOT_TOKEN || envConfig.TELEGRAM_BOT_TOKEN === 'YOUR_TELEGRAM_BOT_TOKEN') {
            errors.push('Telegram Bot Token 未設定');
        }
    }
    
    if (synologyChatConfig.enabled && !envConfig.SYNOLOGY_CHAT_WEBHOOK.startsWith('YOUR_')) {
        if (!envConfig.SYNOLOGY_CHAT_WEBHOOK || envConfig.SYNOLOGY_CHAT_WEBHOOK === 'YOUR_SYNOLOGY_CHAT_WEBHOOK_URL') {
            errors.push('Synology Chat Webhook URL 未設定');
        }
    }
    
    return {
        isValid: errors.length === 0,
        errors: errors
    };
}

// 如果直接執行此檔案，進行配置驗證
if (typeof require !== 'undefined' && require.main === module) {
    const validation = validateConfig();
    if (validation.isValid) {
        console.log('✅ 配置驗證通過');
    } else {
        console.log('❌ 配置驗證失敗:');
        validation.errors.forEach(error => console.log(`  - ${error}`));
    }
}
