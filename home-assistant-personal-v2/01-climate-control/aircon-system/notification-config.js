/**
 * 空調設備通知系統配置
 * 用於 Node-RED 的通知服務配置
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
    webhookUrl: process.env.SYNOLOGY_CHAT_WEBHOOK || 'YOUR_SYNOLOGY_CHAT_WEBHOOK_URL',
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
    botToken: process.env.TELEGRAM_BOT_TOKEN || 'YOUR_TELEGRAM_BOT_TOKEN',
    chatId: process.env.TELEGRAM_CHAT_ID || 'YOUR_TELEGRAM_CHAT_ID',
    parseMode: 'HTML',
    disableNotification: false,
    
    // 訊息模板
    messageTemplate: {
        text: '<b>{{statusIcon}} {{deviceName}}</b>\n\n' +
              '狀態：{{newState}}\n' +
              '位置：{{location}}\n' +
              '時間：{{timestamp}}\n' +
              '設備ID：<code>{{entityId}}</code>',
        parse_mode: 'HTML',
        disable_notification: false
    },
    
    // 按鈕配置（可選）
    inlineKeyboard: {
        enabled: false,
        buttons: [
            [
                { text: '查看詳情', callback_data: 'device_details_{{entityId}}' },
                { text: '關閉通知', callback_data: 'mute_{{entityId}}' }
            ]
        ]
    }
};

// 狀態圖示對應
const statusIcons = {
    'on': '🟢',
    'off': '🔴',
    'heat': '🔥',
    'cool': '❄️',
    'auto': '🔄',
    'dry': '💨',
    'fan_only': '🌪️',
    'low': '🟢',
    'medium': '🟡',
    'high': '🔴',
    'unavailable': '⚠️',
    'unknown': '❓'
};

// 狀態顏色對應（用於 Synology Chat 等支援顏色的平台）
const statusColors = {
    'on': '#28a745',
    'off': '#dc3545',
    'heat': '#fd7e14',
    'cool': '#007bff',
    'auto': '#6f42c1',
    'dry': '#20c997',
    'fan_only': '#6c757d',
    'unavailable': '#ffc107',
    'unknown': '#6c757d'
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
    const currentTime = now.toTimeString().slice(0, 5); // HH:MM 格式
    const start = notificationFilters.quietHours.start;
    const end = notificationFilters.quietHours.end;
    
    if (start <= end) {
        return currentTime >= start && currentTime <= end;
    } else {
        return currentTime >= start || currentTime <= end;
    }
}

// 檢查是否應該發送通知
function shouldNotify(entityId, newState, oldState) {
    // 檢查是否在靜音時間
    if (isQuietHours()) {
        return false;
    }
    
    // 檢查是否為忽略的狀態變化
    const ignoreChange = notificationFilters.ignoreStateChanges.some(rule => 
        rule.from === oldState && rule.to === newState
    );
    
    if (ignoreChange) {
        return false;
    }
    
    // 檢查是否為需要通知的狀態
    if (!notificationFilters.notifyOnlyFor.includes(newState)) {
        return false;
    }
    
    return true;
}

// 導出配置
module.exports = {
    notifyHelperConfig,
    synologyChatConfig,
    telegramConfig,
    statusIcons,
    statusColors,
    notificationFilters,
    formatMessage,
    isQuietHours,
    shouldNotify
};

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
        shouldNotify
    });
}
