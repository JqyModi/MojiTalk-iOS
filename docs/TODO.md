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
- [ ] **[Refine]** 对接真实后端 SSE 接口 (当前为 Local Mock)

---

## 🟡 P1: 交互增强与 AI 工具
### 4. 语音播放 (TTS)
- [x] 封装 `AudioPlayerManager` (基于 `AVFoundation`)
- [x] 点击消息气泡触发 TTS 获取逻辑
- [x] 实现播放状态反馈 UI (小喇叭动画)
- [x] **[MVP 补漏]** 基础语音输入 (录音按钮与文件发送模拟)

### 5. AI 辅助工具集
- [x] 实现消息长按菜单 (`contextMenu`)
- [x] 接入现有“翻译”接口并展示结果
    - [ ] **[Refine]** 对接真实翻译 API (当前为 Delay Mock)
- [x] 接入“语法解析”功能并实现结果展示弹窗
    - [ ] **[Refine]** 对接真实语法分析 API (当前为 Delay Mock)
- [x] **[Compliance]** 消息长按菜单支持“反馈/举报”AI 不当内容

---

## 🔵 P2: 角色系统与业务框架
### 6. Live2D 桥接集成 (P2 - 进展显著)
- [x] 创建 `Live2DView` 基础容器 (UIViewRepresentable UI层)
- [x] 调研并迁移 Live2D 核心实现 (集成 Core & Framework)
- [x] 建立模块化集成方案 (`MojiLive2D` Pod 模块)
    - [x] 完成多级头文件路径修正
    - [x] 解决 C++ 接口泄漏导致的 Swift 模块编译失败问题
    - [x] 修正真机构建下的沙盒权限与架构链接问题
- [x] 搬运并重构 Objective-C++ Wrapper 桥接层
- [x] **实现真正的模型加载逻辑** (替换 Mock)
- [x] 实现口型同步 (Audio Power -> L2D Parameter)

### 7. 账号与会话管理 (已完成真实实现)
- [x] 实现完整登录 UI (包含账号密码输入与动画反馈)
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
- [ ] **[Assets]** 配置 Launch Screen (启动图)
- [ ] **[Assets]** 制作并配置全尺寸 App Icon

### 9. 鲁棒性与性能
- [x] **[Retry]** 消息发送失败/流断开的 UI 重试引导
- [ ] 优化消息列表 (`LazyVStack`) 在长列表下的滚动性能
- [ ] 弱网环境下的重试逻辑 UI 反馈

---

## 📦 P4: App Store 上架元数据准备
- [ ] **法律文档发布**：将隐私政策和用户协议部署至静态网页
- [ ] **审核准备**：配置 App Store Connect 测试账号及审核备注
- [ ] **预览图制作**：
    - [ ] 6.5 英寸 (iPhone 14/13/12 Pro Max) 截图 (5张)
    - [ ] 5.5 英寸 (iPhone 8 Plus) 截图 (5张)
- [ ] **营销文案**：编写多语言 App 描述、关键词及技术支持 URL
