# MojiTalk (MOJi说) UI/UX 设计方案 - Pro Max 版

## 1. 设计理念 (Design Philosophy)
MojiTalk 的设计旨在打破传统学习软件的沉稳感，通过 **“情感化设计 (Emotional Design)”** 和 **“极简主义 (Minimalism)”** 的结合，创造一个温和、专业且具有呼吸感的口语练习环境。

### 核心关键词
- **Fluid (流畅)**: 动效衔接自然，无断层。
- **Immersive (沉浸)**: Live2D 角色与对话流深度融合。
- **Modern (现代)**: 采用毛玻璃 (Glassmorphism) 与悬浮层级感。

---

## 2. 视觉规范 (Visual Identity)

### 2.1 色彩体系 (Brand Palette)
- **Primary (活力蓝)**: `#007AFF` (适配 iOS 系统蓝，增强原生感)
- **Secondary (柔和粉)**: `#FF2D55` (用于心动、奖励、Live2D 交互提示)
- **Background (深邃黑)**: `#000000` (Dark Mode 采用纯黑，利用 OLED 屏幕优势)
- **Card (悬浮灰)**: `#1C1C1E` (搭配 0.8 透明度实现毛玻璃效果)
- **Accent (渐变色)**: `linear-gradient(135deg, #007AFF 0%, #00C6FF 100%)`

### 2.2 字体规范 (Typography)
- **主字体**: `System Rounded` (iOS 原生圆形字体，更亲切)
- **辅助字体**: `Avenir Next` (对话内容展示，极具可读性)
- **日文显示**: `Hiragino Sans` (确保日语汉字与假名的优美)

---

## 3. 页面布局与交互 (Interface & Interaction)

### 3.1 核心对话流 (Chat Streaming)
- **布局**: 对话流占据屏幕底部 60%，顶部 40% 留给 Live2D 模型。
- **气泡动效**: 
  - 消息进入时采用 **Elastic Bounce (弹性跳跃)** 效果。
  - AI 文本生成时采用 **Smooth Streaming (顺滑流式更新)**，避免闪烁。
- **辅助操作**: 气泡侧边仅显示极简图标（翻译、解析），长按呼出二级渐变菜单。

### 3.2 Live2D 角色容器 (Character Container)
- **环境融合**: 背景采用 **Mesh Gradient (网格渐变)**，颜色随对话情感动态调整（如 AI 夸奖时变暖色）。
- **感官联动**: 
  - 点击角色触发互动动效。
  - 语音播放时，根据音高 (Pitch) 动态调整背景光晕的呼吸率。

### 3.3 输入系统 (Smart Input)
- **毛玻璃控制面板**: 底部输入区域采用 40pt 半径的圆角胶囊设计。
- **微交互**: 
  - 录音键长按时产生向外扩散的波纹动效。
  - 文本框随字符数自适应增高，并带有平滑的伸缩动画。

---

## 4. UX 细节清单 (UX Audit Checklist)
- [ ] **触感反馈 (Haptics)**: 发送成功、AI 回复开始、录音开始均有差异化的震动提示。
- [ ] **转场动画**: 页面切换采用内容缩放 (Scale Transition) 与 模糊淡入 (Blur Dissolve)。
- [ ] **空状态设计**: 首次进入时，Live2D 角色带有招手动作及文字云引导。
- [ ] **夜间优化**: 关闭所有刺眼的纯白色背景，采用多级深灰色层级。

---

## 5. 设计稿预览 (Mockup Suggestion)
建议主色调：`Deep Navy` 主题配合 `Neon Blue` 描边，营造一种“深夜书房”或“虚拟教室”的高级感。
