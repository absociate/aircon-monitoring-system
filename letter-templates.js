// 3D字母展开图模板
// 每个字母包含详细的展开图数据

const letterTemplates = {
    'A': {
        // 主要面的路径
        frontPath: 'M50 180 L100 20 L150 180 M75 120 L125 120',
        // 侧面条带定义
        sideStrips: [
            { start: [50, 180], end: [100, 20], width: 25 },
            { start: [100, 20], end: [150, 180], width: 25 },
            { start: [75, 120], end: [125, 120], width: 25 }
        ],
        // 胶水标签位置
        glueTabs: [
            { x: 50, y: 180, direction: 'left' },
            { x: 150, y: 180, direction: 'right' },
            { x: 100, y: 20, direction: 'top' }
        ]
    },
    
    'B': {
        frontPath: 'M50 20 L50 180 L120 180 Q140 180 140 160 Q140 140 120 140 L50 140 M50 140 Q140 140 140 100 Q140 20 120 20 L50 20',
        sideStrips: [
            { start: [50, 20], end: [50, 180], width: 25 },
            { start: [50, 180], end: [120, 180], width: 25 },
            { start: [120, 180], end: [140, 160], width: 25 },
            { start: [140, 160], end: [140, 140], width: 25 },
            { start: [140, 140], end: [120, 140], width: 25 },
            { start: [120, 140], end: [50, 140], width: 25 },
            { start: [50, 140], end: [140, 140], width: 25 },
            { start: [140, 140], end: [140, 100], width: 25 },
            { start: [140, 100], end: [140, 20], width: 25 },
            { start: [140, 20], end: [120, 20], width: 25 },
            { start: [120, 20], end: [50, 20], width: 25 }
        ],
        glueTabs: [
            { x: 50, y: 20, direction: 'left' },
            { x: 50, y: 180, direction: 'left' },
            { x: 140, y: 100, direction: 'right' }
        ]
    },

    'C': {
        frontPath: 'M140 40 Q120 20 90 20 Q50 20 50 60 L50 140 Q50 180 90 180 Q120 180 140 160',
        sideStrips: [
            { start: [140, 40], end: [120, 20], width: 25 },
            { start: [120, 20], end: [90, 20], width: 25 },
            { start: [90, 20], end: [50, 20], width: 25 },
            { start: [50, 20], end: [50, 60], width: 25 },
            { start: [50, 60], end: [50, 140], width: 25 },
            { start: [50, 140], end: [50, 180], width: 25 },
            { start: [50, 180], end: [90, 180], width: 25 },
            { start: [90, 180], end: [120, 180], width: 25 },
            { start: [120, 180], end: [140, 160], width: 25 }
        ],
        glueTabs: [
            { x: 140, y: 40, direction: 'right' },
            { x: 50, y: 100, direction: 'left' },
            { x: 140, y: 160, direction: 'right' }
        ]
    },

    'D': {
        frontPath: 'M50 20 L50 180 L110 180 Q150 180 150 140 L150 60 Q150 20 110 20 L50 20',
        sideStrips: [
            { start: [50, 20], end: [50, 180], width: 25 },
            { start: [50, 180], end: [110, 180], width: 25 },
            { start: [110, 180], end: [150, 180], width: 25 },
            { start: [150, 180], end: [150, 140], width: 25 },
            { start: [150, 140], end: [150, 60], width: 25 },
            { start: [150, 60], end: [150, 20], width: 25 },
            { start: [150, 20], end: [110, 20], width: 25 },
            { start: [110, 20], end: [50, 20], width: 25 }
        ],
        glueTabs: [
            { x: 50, y: 100, direction: 'left' },
            { x: 150, y: 100, direction: 'right' },
            { x: 100, y: 20, direction: 'top' },
            { x: 100, y: 180, direction: 'bottom' }
        ]
    },

    'E': {
        frontPath: 'M50 20 L50 180 L140 180 M50 100 L120 100 M50 20 L140 20',
        sideStrips: [
            { start: [50, 20], end: [50, 180], width: 25 },
            { start: [50, 180], end: [140, 180], width: 25 },
            { start: [50, 100], end: [120, 100], width: 25 },
            { start: [50, 20], end: [140, 20], width: 25 }
        ],
        glueTabs: [
            { x: 50, y: 100, direction: 'left' },
            { x: 140, y: 20, direction: 'right' },
            { x: 140, y: 180, direction: 'right' },
            { x: 120, y: 100, direction: 'right' }
        ]
    },

    'F': {
        frontPath: 'M50 20 L50 180 M50 100 L120 100 M50 20 L140 20',
        sideStrips: [
            { start: [50, 20], end: [50, 180], width: 25 },
            { start: [50, 100], end: [120, 100], width: 25 },
            { start: [50, 20], end: [140, 20], width: 25 }
        ],
        glueTabs: [
            { x: 50, y: 100, direction: 'left' },
            { x: 140, y: 20, direction: 'right' },
            { x: 120, y: 100, direction: 'right' }
        ]
    },

    'G': {
        frontPath: 'M140 40 Q120 20 90 20 Q50 20 50 60 L50 140 Q50 180 90 180 Q120 180 140 160 L140 120 L110 120',
        sideStrips: [
            { start: [140, 40], end: [120, 20], width: 25 },
            { start: [120, 20], end: [90, 20], width: 25 },
            { start: [90, 20], end: [50, 20], width: 25 },
            { start: [50, 20], end: [50, 60], width: 25 },
            { start: [50, 60], end: [50, 140], width: 25 },
            { start: [50, 140], end: [50, 180], width: 25 },
            { start: [50, 180], end: [90, 180], width: 25 },
            { start: [90, 180], end: [120, 180], width: 25 },
            { start: [120, 180], end: [140, 160], width: 25 },
            { start: [140, 160], end: [140, 120], width: 25 },
            { start: [140, 120], end: [110, 120], width: 25 }
        ],
        glueTabs: [
            { x: 140, y: 40, direction: 'right' },
            { x: 50, y: 100, direction: 'left' },
            { x: 110, y: 120, direction: 'bottom' }
        ]
    },

    'H': {
        frontPath: 'M50 20 L50 180 M150 20 L150 180 M50 100 L150 100',
        sideStrips: [
            { start: [50, 20], end: [50, 180], width: 25 },
            { start: [150, 20], end: [150, 180], width: 25 },
            { start: [50, 100], end: [150, 100], width: 25 }
        ],
        glueTabs: [
            { x: 50, y: 100, direction: 'left' },
            { x: 150, y: 100, direction: 'right' },
            { x: 100, y: 100, direction: 'top' }
        ]
    },

    'I': {
        frontPath: 'M75 20 L125 20 M100 20 L100 180 M75 180 L125 180',
        sideStrips: [
            { start: [75, 20], end: [125, 20], width: 25 },
            { start: [100, 20], end: [100, 180], width: 25 },
            { start: [75, 180], end: [125, 180], width: 25 }
        ],
        glueTabs: [
            { x: 100, y: 20, direction: 'top' },
            { x: 100, y: 180, direction: 'bottom' },
            { x: 75, y: 100, direction: 'left' },
            { x: 125, y: 100, direction: 'right' }
        ]
    },

    'J': {
        frontPath: 'M120 20 L120 140 Q120 180 80 180 Q50 180 50 160',
        sideStrips: [
            { start: [120, 20], end: [120, 140], width: 25 },
            { start: [120, 140], end: [120, 180], width: 25 },
            { start: [120, 180], end: [80, 180], width: 25 },
            { start: [80, 180], end: [50, 180], width: 25 },
            { start: [50, 180], end: [50, 160], width: 25 }
        ],
        glueTabs: [
            { x: 120, y: 20, direction: 'top' },
            { x: 50, y: 160, direction: 'left' }
        ]
    }
};

// 生成更精确的展开图
function generatePreciseUnfoldedLetter(letter, size, thickness) {
    const template = letterTemplates[letter];
    if (!template) {
        return generateBasicUnfoldedLetter(letter, size, thickness);
    }

    const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
    svg.setAttribute('width', '800');
    svg.setAttribute('height', '600');
    svg.setAttribute('viewBox', '0 0 800 600');

    // 添加样式
    const defs = document.createElementNS('http://www.w3.org/2000/svg', 'defs');
    const style = document.createElementNS('http://www.w3.org/2000/svg', 'style');
    style.textContent = `
        .letter-face { fill: none; stroke: #000; stroke-width: 2; }
        .fold-line { fill: none; stroke: #666; stroke-width: 1; stroke-dasharray: 5,5; }
        .glue-tab { fill: #ffeb3b; stroke: #000; stroke-width: 1; opacity: 0.7; }
        .label-text { font-family: Arial; font-size: 12px; text-anchor: middle; fill: #333; }
        .cut-line { fill: none; stroke: #000; stroke-width: 2; }
        .side-strip { fill: #f0f0f0; stroke: #000; stroke-width: 1; }
    `;
    defs.appendChild(style);
    svg.appendChild(defs);

    const scale = size / 200;

    // 正面
    const frontGroup = document.createElementNS('http://www.w3.org/2000/svg', 'g');
    frontGroup.setAttribute('transform', `translate(50, 50) scale(${scale})`);
    
    const frontPath = document.createElementNS('http://www.w3.org/2000/svg', 'path');
    frontPath.setAttribute('d', template.frontPath);
    frontPath.setAttribute('class', 'letter-face');
    frontGroup.appendChild(frontPath);

    const frontLabel = document.createElementNS('http://www.w3.org/2000/svg', 'text');
    frontLabel.setAttribute('x', '100');
    frontLabel.setAttribute('y', '220');
    frontLabel.setAttribute('class', 'label-text');
    frontLabel.textContent = '正面';
    frontGroup.appendChild(frontLabel);

    svg.appendChild(frontGroup);

    // 背面（镜像）
    const backGroup = document.createElementNS('http://www.w3.org/2000/svg', 'g');
    backGroup.setAttribute('transform', `translate(350, 50) scale(${-scale}, ${scale})`);
    
    const backPath = document.createElementNS('http://www.w3.org/2000/svg', 'path');
    backPath.setAttribute('d', template.frontPath);
    backPath.setAttribute('class', 'letter-face');
    backGroup.appendChild(backPath);

    const backLabel = document.createElementNS('http://www.w3.org/2000/svg', 'text');
    backLabel.setAttribute('x', '-100');
    backLabel.setAttribute('y', '220');
    backLabel.setAttribute('class', 'label-text');
    backLabel.textContent = '背面';
    backGroup.appendChild(backLabel);

    svg.appendChild(backGroup);

    // 侧面条带
    template.sideStrips.forEach((strip, index) => {
        const stripGroup = createSideStrip(strip, index, scale, thickness);
        stripGroup.setAttribute('transform', `translate(${50 + (index % 4) * 180}, ${350 + Math.floor(index / 4) * 100})`);
        svg.appendChild(stripGroup);
    });

    // 胶水标签
    template.glueTabs.forEach((tab, index) => {
        const tabElement = createGlueTab(tab, scale);
        svg.appendChild(tabElement);
    });

    return svg;
}

// 创建侧面条带
function createSideStrip(strip, index, scale, thickness) {
    const group = document.createElementNS('http://www.w3.org/2000/svg', 'g');
    
    const length = Math.sqrt(
        Math.pow(strip.end[0] - strip.start[0], 2) + 
        Math.pow(strip.end[1] - strip.start[1], 2)
    ) * scale;
    
    const rect = document.createElementNS('http://www.w3.org/2000/svg', 'rect');
    rect.setAttribute('x', '0');
    rect.setAttribute('y', '0');
    rect.setAttribute('width', length);
    rect.setAttribute('height', thickness);
    rect.setAttribute('class', 'side-strip');
    group.appendChild(rect);

    // 胶水标签
    const topTab = document.createElementNS('http://www.w3.org/2000/svg', 'rect');
    topTab.setAttribute('x', length / 2 - 10);
    topTab.setAttribute('y', -10);
    topTab.setAttribute('width', '20');
    topTab.setAttribute('height', '10');
    topTab.setAttribute('class', 'glue-tab');
    group.appendChild(topTab);

    const bottomTab = document.createElementNS('http://www.w3.org/2000/svg', 'rect');
    bottomTab.setAttribute('x', length / 2 - 10);
    bottomTab.setAttribute('y', thickness);
    bottomTab.setAttribute('width', '20');
    bottomTab.setAttribute('height', '10');
    bottomTab.setAttribute('class', 'glue-tab');
    group.appendChild(bottomTab);

    // 标签
    const label = document.createElementNS('http://www.w3.org/2000/svg', 'text');
    label.setAttribute('x', length / 2);
    label.setAttribute('y', thickness + 25);
    label.setAttribute('class', 'label-text');
    label.textContent = `侧面 ${index + 1}`;
    group.appendChild(label);

    return group;
}

// 创建胶水标签
function createGlueTab(tab, scale) {
    const group = document.createElementNS('http://www.w3.org/2000/svg', 'g');
    
    const x = tab.x * scale + 50;
    const y = tab.y * scale + 50;
    
    const tabRect = document.createElementNS('http://www.w3.org/2000/svg', 'rect');
    tabRect.setAttribute('x', x - 10);
    tabRect.setAttribute('y', y - 5);
    tabRect.setAttribute('width', '20');
    tabRect.setAttribute('height', '10');
    tabRect.setAttribute('class', 'glue-tab');
    group.appendChild(tabRect);

    const tabText = document.createElementNS('http://www.w3.org/2000/svg', 'text');
    tabText.setAttribute('x', x);
    tabText.setAttribute('y', y + 2);
    tabText.setAttribute('class', 'label-text');
    tabText.setAttribute('style', 'font-size: 8px;');
    tabText.textContent = '胶';
    group.appendChild(tabText);

    return group;
}

// 导出函数
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { letterTemplates, generatePreciseUnfoldedLetter };
}
