# MOJi会话 SwiftUI 重写计划 - TODO List

## 🔴 P0: 核心通信与基础 UI (对话闭环)
### 1. 基础架构与数据模型
- [x] 定义 `Message` 核心数据模型 (ID, 内容, 角色 [User/AI], 时间戳)
- [x] 搭建 `GlobalAppState` 状态管理 (基于 `@StateObject`)
- [x] 封装基础网络请求层 (Swift Concurrency)

### 2. 构建 SwiftUI 对话界面
- [x] 实现 `ChatView` 容器布局 (`ZStack` + `VStack`)
- [x] 实现消息流滚动视图 (`ScrollView` + `LazyVStack` + `ScrollViewReader` 自动滚动到底部)
- [x] 编写自定义消息气泡组件
    - [x] 用户气泡 (右侧, 品牌主色)
    - [x] AI 气泡 (左侧, 背景中色)
- [x] 编写底部交互输入栏
    - [x] 响应式 `TextField` (支持多行增长)
    - [x] 发送按钮逻辑

### 3. SSE 流式数据集成
- [x] 构建 `SSENetworkManager` (利用 `URLSession.bytes(from:delegate:)`)
- [x] 实现 SSE 事件流解析器
- [x] 实现界面的响应式更新 ( incremental content updates )
- [x] **[Refine]** 对接真实后端 SSE 接口 (阿里通义千问 Qwen)

---

## 🟡 P1: 交互增强与 AI 工具
### 4. 语音播放 (TTS)
- [x] 封装 `AudioPlayerManager` (基于 `AVFoundation`)
- [x] 点击消息气泡触发 TTS 获取逻辑 (当前为真实 API 触发)
    - [x] **[Atomic]** 调研对接 DashScope / OpenAI 实时的 TTS 接口 (已对接 Sambert-Zhichu)
    - [x] **[Atomic]** 实现语音合成数据流的二进制获取与本地缓存 (通过临时文件中转)
    - [x] **[Atomic]** 替换 `ChatViewModel.playTTS` 中的录音路径，改用真实合成的音频数据
- [x] 实现播放状态反馈 UI (小喇叭动画)
- [x] **[MVP 补漏]** 基础语音输入逻辑实现
    - [x] **[Atomic]** 录音结束后触发 ASR (语音转文字) 接口请求 (已对接 Paraformer)
    - [x] **[Atomic]** 在控制面板展示“语音识别中...”的中间状态
    - [x] **[Atomic]** 识别成功后自动填入输入框并触发 AI 会话

### 5. AI 辅助工具集
- [x] 接入现有“翻译”接口并展示结果
    - [x] **[Refine]** 对接真实翻译 API (利用 iOS 17.4+ 原生框架 / Qwen AI 降级)
- [x] 接入“语法解析”功能并实现结果展示弹窗
    - [x] **[Refine]** 对接真实语法分析 API (基于 Qwen SSE 流式解析实现)
- [x] **[Compliance]** 消息长按菜单支持“反馈/举报”AI 不当内容

---

## 🔵 P2: 角色系统与业务框架
### 6. Live2D 桥接集成 (P2 - 进展显著)
- [x] 创建 `Live2DView` 基础容器 (UIViewRepresentable UI层)
- [x] 调研并迁移 Live2D 核心实现 (集成 Core & Framework)
- [x] 建立模块化集成方案 (`MojiLive2D` Pod 模块)
    - [x] 完成多级头文件路径修正
    - [x] 解决 C++ 接口泄漏导致的 Swift 模块编译失败问题
    - [x] 修正真机/模拟器构建下的架构链接问题 (支持 M 芯片 Mac Rosetta 调试)
- [x] 搬运并重构 Objective-C++ Wrapper 桥接层
- [x] **实现真正的模型加载逻辑** (替换 Mock)
- [x] 实现口型同步 (Audio Power -> L2D Parameter)

### 7. 账号与会话管理 (Supabase 迁移中)
- [x] 实现基础登录 UI (包含账号输入与动画反馈)
- [x] **[P0] 集成 Supabase Auth SDK**
    - [x] 配置 Apple Login 认证提供商 (已完成 App ID、Key、Capabilities 及 Supabase 侧配置)
    - [x] 配置 Email OTP (邮箱验证码) 发送逻辑
- [x] **[P0] 真实用户信息收集与展示**
    - [x] 注册成功后自动在 `profiles` 表创建用户记录
    - [x] **[New]** 首次登录时随机分配一个头像并持久化至 Supabase Storage/Profile
    - [x] **[New]** 重构 `UserProfileView`：展示真实用户名、邮箱及生成的头像，替换 `Guest_User` 占位符
- [x] **[P1] 会话历史持久化优化**
    - [x] 基于 UID 分区存储本地历史，防止退出登录后数据丢失
    - [ ] 实现增量同步至 Supabase (Post-MVP)
- [x] 封装 `AccountManager` 处理 Token 持久化存储与过期检查逻辑 (7天有效期)
- [x] 实现对话历史的本地磁盘缓存 (`JSON Persistence`)
- [x] **[MVP 补漏]** 用户信息菜单 (头像/登出入口) - *User Feedback*
    - [x] 账号注销功能 (Delete Account) - *App Store Guideline 5.1.1(v)*
- [x] **[Compliance]** 登录页展示“隐私政策”与“用户协议”入口

---

## ⚪ P3: 优化与打磨 (UI/UX Refinement)
### 8. 视觉与交互体验
- [x] **[Transition]** 优化登录 -> 对话的转场动画
- [x] **[Dark Mode]** 全局深色模式适配自查 (LoginView / ChatView)
- [x] **[Keyboard]** 键盘弹出/收起的避让动画优化
- [x] **[Loading]** 统一 Loading 态设计 (避免生硬的转圈)
- [x] **[Compliance]** 检查 Info.plist 权限文案 (如 NSMicrophoneUsageDescription)
- [x] **[Assets]** 配置 Launch Screen (已生成设计稿)
- [x] **[Assets]** 制作并配置全尺寸 App Icon (已生成设计稿)

### 9. 鲁棒性与性能
- [x] **[Retry]** 消息发送失败/流断开的 UI 重试引导
- [x] 优化消息列表 (`LazyVStack`) 在长列表下的滚动性能
- [x] 弱网环境下的重试逻辑 UI 反馈 (已集成 exclamationmark 引导)

---

## 🔴 P0: 上线前体验优化 (Pre-Launch UX Polish)

### 12. 用户安全与引导
- [ ] **[Critical]** 账号注销二次确认弹窗
  - [ ] 在 `UserProfileView` 的"永久注销账户"按钮添加 Alert 确认
  - [ ] 警告文案："此操作将永久删除您的账号及所有对话记录，且无法恢复。确定要继续吗？"
  - [ ] 提供"取消"和"确认注销"两个选项

- [ ] **[Critical]** 对话页面首次使用引导
  - [ ] 实现蒙版式功能引导 (Onboarding Overlay)
  - [ ] 引导内容：
    - [ ] 点击消息气泡播放 TTS
    - [ ] 长按消息呼出翻译/语法分析菜单
    - [ ] 语音输入按钮使用方法
    - [ ] Live2D 角色交互说明
  - [ ] 使用 UserDefaults 记录是否已展示过引导

- [ ] **[High]** 登录页增强
  - [ ] 添加累计练习次数滚动数字展示 (参考截图设计)
    - [ ] 实现数字滚动动画效果
    - [ ] 数据来源：可以是固定数值或从后端获取全局统计
  - [ ] 添加帮助入口按钮 (右上角耳机图标)
    - [ ] 点击后弹出 Sheet 展示常见登录问题 FAQ
    - [ ] 包含"联系客服"入口 (邮箱或在线客服链接)
  - [ ] 优化欢迎文案动态切换
    - [ ] 实现多条欢迎语随机轮播 (如"Ready to learn!" / "欢迎使用可呆口语！")

### 13. 国际化支持 (i18n)
- [ ] **[High]** 配置多语言框架
  - [ ] 创建 `Localizable.xcstrings` 资源文件
  - [ ] 配置支持语言：简体中文、英文、日文、韩文

- [ ] **[High]** 翻译所有 UI 文案
  - [ ] 登录页 (LoginView)
    - [ ] 按钮文案、欢迎语、隐私协议链接
  - [ ] 对话页 (ChatView)
    - [ ] 输入框占位符、菜单项、错误提示
  - [ ] 设置页 (UserProfileView)
    - [ ] 设置项标题、描述、按钮文案
  - [ ] 工具结果页 (ToolResultView)
    - [ ] 标题、加载提示、错误信息
  - [ ] 系统提示与错误信息
    - [ ] 网络错误、TTS 失败、ASR 失败等

- [ ] **[Medium]** 布局适配测试
  - [ ] 测试长文本语言 (如德语) 的 UI 适配
  - [ ] 测试 RTL 语言 (如阿拉伯语，如果未来支持)

### 14. Live2D 交互体验优化 (Critical - 核心卖点)
**问题诊断**：Live2D 角色作为背景层展示，被消息列表严重遮挡，口型同步和动作表演几乎不可见，影响产品核心差异化体验。

- [ ] **[Critical]** 评估并选择最佳方案 (需与产品/设计讨论)
  - [ ] **方案 A - 固定分屏布局** (推荐指数: ⭐⭐⭐⭐)
    - 上半屏 40% 固定展示 Live2D，下半屏 60% 消息列表
    - 优点：Live2D 始终可见，适合展示完整角色
    - 缺点：消息列表空间受限，可能需要更频繁滚动
  
  - [ ] **方案 B - 高透明度消息气泡** (推荐指数: ⭐⭐)
    - 消息气泡使用 0.3-0.5 透明度的毛玻璃效果
    - 优点：实现简单，保持现有布局
    - 缺点：可读性下降，可能影响用户阅读体验
  
  - [ ] **方案 C - 智能动态收起** (推荐指数: ⭐⭐⭐⭐⭐)
    - AI 播放 TTS 时，自动将消息列表收起到底部 20%，突出 Live2D 表演
    - 用户可通过上滑手势展开完整消息列表
    - 优点：兼顾阅读和观赏，交互自然
    - 缺点：实现复杂度较高
  
  - [ ] **方案 D - 可拖动浮窗** (推荐指数: ⭐⭐⭐)
    - Live2D 以圆形/方形小窗口悬浮在消息列表上方
    - 支持拖动位置、缩放大小
    - 优点：灵活性高，用户可自定义
    - 缺点：可能遮挡消息内容，需要精细的交互设计
  
  - [ ] **方案 E - 专注模式切换** (推荐指数: ⭐⭐⭐)
    - 提供"专注模式"按钮，点击后全屏展示 Live2D
    - 暂停消息滚动，适合纯欣赏角色表演
    - 优点：适合特定场景 (如展示、截图)
    - 缺点：非默认模式，用户可能不会主动使用

- [ ] **[Critical]** 实现选定方案的原型
  - [ ] 编写 UI 代码
  - [ ] 测试不同屏幕尺寸的适配 (iPhone SE / 14 Pro Max)
  - [ ] 收集内部测试反馈

---

## 📦 P4: App Store 上架元数据准备
- [x] **法律文档发布**：已草拟隐私政策和用户协议 (见 docs/Legal)
- [x] **审核准备**：配置 App Store Connect 测试账号及审核备注
- [ ] **预览图制作**：
    - [ ] 6.5 英寸 (iPhone 14/13/12 Pro Max) 截图 (5张)
    - [ ] 5.5 英寸 (iPhone 8 Plus) 截图 (5张)
- [ ] **营销文案**：编写多语言 App 描述、关键词及技术支持 URL

## 🌟 P0: 真机体验优化 (Real Device Feedback)
### 10. 自动化与交互流程
- [x] **[Atomic]** 实现 `isAutoPlayEnabled` 全局开关逻辑与 Persistence 持久化
- [x] **[Atomic]** 在 `UserProfileView` 增加“自动播报”切换开关并支持滚动避免内容截断
- [x] **[Atomic]** 初始加载历史记录自动滚动到底部最新消息
- [x] **[Atomic]** 优化流式消息滚动算法，确保内容不被输入框遮挡 (针对 iPhone X 等机型)
- [x] **[Atomic]** 监听键盘弹起/收起事件，确保最新消息自动跟随键盘位移

### 11. 性能专项 (iPhone X 发热与卡顿)
- [x] **[Atomic]** 诊断优化 `ChatView` 启动白屏/卡顿问题 (优化 Live2D 异步加载策略)
- [x] **[Atomic]** 优化模型加载视觉过渡：增加毛玻璃占位图与平滑淡入动画
- [x] **[Atomic]** `Live2DView` 渲染性能优化：实现静止状态降帧（FPS Throttling）
- [x] **[Atomic]** 消息流更新频率节流：降低高频文本更新对 UI 渲染的冲击
- [x] **[Atomic]** 内存泄漏排查：修复了 MOJiMTKView/Renderer 中的 C++ 指针泄漏及 SSE 任务生命周期管理

