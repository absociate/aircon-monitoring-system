/**
 * 空調設備通知系統測試腳本
 * 用於測試各種通知服務是否正常工作
 */

const https = require('https');
const http = require('http');
const fs = require('fs');
const path = require('path');

// 載入配置
let config = {};
try {
    if (fs.existsSync('.env')) {
        const envContent = fs.readFileSync('.env', 'utf8');
        envContent.split('\n').forEach(line => {
            const [key, value] = line.split('=');
            if (key && value && !line.startsWith('#')) {
                process.env[key.trim()] = value.trim();
            }
        });
    }
    
    if (fs.existsSync('device-mapping.json')) {
        config = JSON.parse(fs.readFileSync('device-mapping.json', 'utf8'));
    }
} catch (error) {
    console.error('載入配置文件失敗:', error.message);
    process.exit(1);
}

// 測試資料
const testDevices = [
    {
        entityId: 'climate.ke_ting_leng_qi',
        friendlyName: '客廳冷氣',
        newState: 'cool',
        oldState: 'off'
    },
    {
        entityId: 'humidifier.rdi_640hhchu_shi_ji',
        friendlyName: '加濕器',
        newState: 'on',
        oldState: 'off'
    }
];

// 狀態圖示對應
const statusIcons = {
    'on': '🟢',
    'off': '🔴',
    'heat': '🔥',
    'cool': '❄️',
    'auto': '🔄',
    'dry': '💨',
    'fan_only': '🌪️'
};

// 生成測試訊息
function generateTestMessage(device) {
    const timestamp = new Date().toLocaleString('zh-TW', {
        timeZone: 'Asia/Taipei',
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
    });
    
    const statusIcon = statusIcons[device.newState] || '🟡';
    
    return {
        title: `${device.friendlyName}狀態變更 [測試]`,
        message: `${statusIcon} ${device.friendlyName}已${device.newState}\n時間：${timestamp}\n設備：${device.entityId}\n\n⚠️ 這是測試訊息`,
        statusIcon: statusIcon,
        timestamp: timestamp
    };
}

// 測試 Telegram 通知
async function testTelegram(message) {
    return new Promise((resolve, reject) => {
        const botToken = process.env.TELEGRAM_BOT_TOKEN;
        const chatId = process.env.TELEGRAM_CHAT_ID;
        
        if (!botToken || !chatId) {
            reject(new Error('Telegram 配置不完整：缺少 BOT_TOKEN 或 CHAT_ID'));
            return;
        }
        
        const telegramMessage = {
            chat_id: chatId,
            text: `<b>🧪 測試通知</b>\n\n${message.message}`,
            parse_mode: 'HTML'
        };
        
        const postData = JSON.stringify(telegramMessage);
        
        const options = {
            hostname: 'api.telegram.org',
            port: 443,
            path: `/bot${botToken}/sendMessage`,
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': Buffer.byteLength(postData)
            }
        };
        
        const req = https.request(options, (res) => {
            let data = '';
            res.on('data', (chunk) => {
                data += chunk;
            });
            res.on('end', () => {
                if (res.statusCode === 200) {
                    resolve('Telegram 測試成功');
                } else {
                    reject(new Error(`Telegram 測試失敗: ${res.statusCode} - ${data}`));
                }
            });
        });
        
        req.on('error', (error) => {
            reject(new Error(`Telegram 請求錯誤: ${error.message}`));
        });
        
        req.write(postData);
        req.end();
    });
}

// 測試 Synology Chat 通知
async function testSynologyChat(message) {
    return new Promise((resolve, reject) => {
        const webhookUrl = process.env.SYNOLOGY_CHAT_WEBHOOK;
        
        if (!webhookUrl || webhookUrl === 'YOUR_SYNOLOGY_CHAT_WEBHOOK_URL') {
            reject(new Error('Synology Chat 配置不完整：缺少 WEBHOOK_URL'));
            return;
        }
        
        const chatMessage = {
            text: `🧪 **測試通知**\n\n${message.message}`,
            username: 'Smart Home Test Bot',
            icon_emoji: message.statusIcon
        };
        
        const postData = JSON.stringify(chatMessage);
        const url = new URL(webhookUrl);
        
        const options = {
            hostname: url.hostname,
            port: url.port || (url.protocol === 'https:' ? 443 : 80),
            path: url.pathname + url.search,
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': Buffer.byteLength(postData)
            }
        };
        
        const protocol = url.protocol === 'https:' ? https : http;
        
        const req = protocol.request(options, (res) => {
            let data = '';
            res.on('data', (chunk) => {
                data += chunk;
            });
            res.on('end', () => {
                if (res.statusCode >= 200 && res.statusCode < 300) {
                    resolve('Synology Chat 測試成功');
                } else {
                    reject(new Error(`Synology Chat 測試失敗: ${res.statusCode} - ${data}`));
                }
            });
        });
        
        req.on('error', (error) => {
            reject(new Error(`Synology Chat 請求錯誤: ${error.message}`));
        });
        
        req.write(postData);
        req.end();
    });
}

// 測試 Home Assistant 連接
async function testHomeAssistant() {
    return new Promise((resolve, reject) => {
        const haUrl = process.env.HA_BASE_URL;
        const haToken = process.env.HA_ACCESS_TOKEN;
        
        if (!haUrl || !haToken) {
            reject(new Error('Home Assistant 配置不完整：缺少 BASE_URL 或 ACCESS_TOKEN'));
            return;
        }
        
        const url = new URL('/api/', haUrl);
        
        const options = {
            hostname: url.hostname,
            port: url.port || (url.protocol === 'https:' ? 443 : 80),
            path: url.pathname,
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${haToken}`,
                'Content-Type': 'application/json'
            }
        };
        
        const protocol = url.protocol === 'https:' ? https : http;
        
        const req = protocol.request(options, (res) => {
            let data = '';
            res.on('data', (chunk) => {
                data += chunk;
            });
            res.on('end', () => {
                if (res.statusCode === 200) {
                    resolve('Home Assistant 連接測試成功');
                } else {
                    reject(new Error(`Home Assistant 連接測試失敗: ${res.statusCode} - ${data}`));
                }
            });
        });
        
        req.on('error', (error) => {
            reject(new Error(`Home Assistant 請求錯誤: ${error.message}`));
        });
        
        req.end();
    });
}

// 主測試函數
async function runTests() {
    console.log('🧪 開始測試空調設備通知系統...\n');
    
    // 測試配置文件
    console.log('📋 檢查配置文件...');
    const requiredFiles = [
        'aircon-notification-flow.json',
        'device-mapping.json',
        'notification-config.js'
    ];
    
    for (const file of requiredFiles) {
        if (fs.existsSync(file)) {
            console.log(`✅ ${file} 存在`);
        } else {
            console.log(`❌ ${file} 不存在`);
        }
    }
    
    console.log('\n🔗 測試服務連接...');
    
    // 測試 Home Assistant 連接
    try {
        const haResult = await testHomeAssistant();
        console.log(`✅ ${haResult}`);
    } catch (error) {
        console.log(`❌ Home Assistant 測試失敗: ${error.message}`);
    }
    
    // 生成測試訊息
    const testMessage = generateTestMessage(testDevices[0]);
    
    // 測試 Telegram
    try {
        const telegramResult = await testTelegram(testMessage);
        console.log(`✅ ${telegramResult}`);
    } catch (error) {
        console.log(`❌ Telegram 測試失敗: ${error.message}`);
    }
    
    // 測試 Synology Chat
    try {
        const synologyResult = await testSynologyChat(testMessage);
        console.log(`✅ ${synologyResult}`);
    } catch (error) {
        console.log(`❌ Synology Chat 測試失敗: ${error.message}`);
    }
    
    console.log('\n🏁 測試完成！');
    console.log('\n💡 提示：');
    console.log('- 如果某項測試失敗，請檢查對應的配置');
    console.log('- 確保 .env 文件中的所有必要參數都已正確設置');
    console.log('- 檢查網路連接和防火牆設置');
}

// 執行測試
if (require.main === module) {
    runTests().catch(error => {
        console.error('測試執行錯誤:', error);
        process.exit(1);
    });
}

module.exports = {
    testTelegram,
    testSynologyChat,
    testHomeAssistant,
    generateTestMessage
};
