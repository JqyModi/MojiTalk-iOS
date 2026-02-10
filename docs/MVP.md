# MOJi会话 (SwiftUI 重写版) MVP 定义文档

## 1. MVP 核心目标
利用 SwiftUI 重新构建 MOJi 会话的核心体验，优先实现“高效、沉浸、简洁”的日语 AI 对话闭环，摒弃辅助性功能，建立现代化的声明式 UI 架构。

---

## 2. 核心功能范围 (Scope)

### 2.1 AI 对话闭环 (The "Must-Have")
这是应用最核心的灵魂，包含：
- **声明式聊天界面**：
  - 使用 `ScrollView` + `LazyVStack` 实现平滑的消息流。
  - 聊天气泡设计：区分用户（右侧）与 AI（左侧）。
  - 支持文本流式显示（SSE 实现），确保响应感。
- **多模态输入**：
  - 文本输入框：支持自动换行与发送。
  - 基础语音输入：简化的录音发送（MVP 阶段可先实现 UI 占位或简单的文件上传）。
- **AI 响应工具**：
  - 点击消息气泡：触发 TTS 语音播放。
  - 长按/二级菜单：仅保留 **“翻译”** 与 **“语法解析”** 两大刚需功能。

### 2.2 虚拟角色系统 (Interactive Character)
- **Live2D 载体**：使用 `UIViewRepresentable` 桥接现有的 Live2D Native SDK。
- **基础反馈**：
  - 角色空闲 (Idle) 动画。
  - 语音播放时的同步口型 (Lip-sync) 基础实现。

### 2.3 业务框架 (Identity & Management)
- **专业登录体系**：
  - **Apple 登录**：集成 Sign in with Apple，满足上架强制性要求。
  - **邮箱验证码登录 (Email OTP)**：通过专业服务（Supabase）发送 6 位数验证码，0 成本实现高到达率的邮箱验证。
  - **用户信息收集**：利用分析工具或后端数据库记录 UID、注册时间及基本统计数据。
- **单场景模式**：默认提供一个万用对话场景，暂不实现复杂的场景切换系统。

#### 2.4 合规与上架必备 (App Store Compliance)
必须满足 Apple 审核底线要求：
- **账号注销 (Account Deletion)**：App 内提供永久删除账号入口。
- **内容安全 (UGC/AI Content)**：针对 AI 生成内容，必须提供 **“举报”或“屏蔽”** 机制 (Guideline 1.2)。
- **法律合规 (Legal)**：
  - 提供真实可用的 **Privacy Policy** 与 **Terms of Use** 在线文档。
  - 麦克风、存储等权限必须包含具体的业务用途描述。
- **元数据组件 (Metadata)**：
  - 高清 App Icon (1024x1024)。
  - 针对 6.5" 和 5.5" 屏幕的 App 预览截图。
  - 审核测试账号 (需提前配置好对话数据)。

---

## 3. 技术方案 (Technical Focus)

### 3.1 架构选择
- **MVVM 模式**：深度结合 SwiftUI 的 `@StateObject` 和 `@Published`。
- **Combine 框架**：用于处理服务端推送流 (SSE) 和 UI 状态订阅。
- **Swift Concurrency (Async/Await)**：全面取代闭包回调，处理网络请求和异步任务。

### 3.2 模块重构计划
- **Network Layer**：使用 `URLSession` 的 `bytes(from:delegate:)` 重新实现 SSE 客户端。
- **Live2D Renderer**：封装一个高度可复用的 SwiftUI `Live2DView` 组件。
- **Audio Service**：基于 `AVFoundation` 的轻量级音频管理。

---

## 4. 暂不包含的功能 (Post-MVP)
为了确保重写进度，以下功能在 MVP 阶段**不予实现**：
- **口语册模块**：场景化课程目录暂缓。
- **复杂会员系统**：内购 (IAP) 逻辑暂缓。
- **深度个性化设置**：如多波段等个性化音频调整。
- **全多语言支持**：初版仅支持中文/日语界面。

---

## 5. 项目路线图 (Milestone)
1. **Phase 1**: 搭建 SwiftUI 基础架构与聊天界面布局。
2. **Phase 2**: 集成 SSE 通信，实现流式文本回复。
3. **Phase 3**: 桥接 Live2D SDK 并实现基础展示。
4. **Phase 4**: 集成 TTS 语音与翻译辅助工具。
5. **Phase 5**: 冒烟测试与真机性能调优。
