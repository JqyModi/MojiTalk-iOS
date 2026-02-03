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

### 2.3 业务框架
- **极简登录**：支持游客模式进入，或简化的手机号/账号登录。
- **单场景模式**：默认提供一个万用对话场景，暂不实现复杂的场景切换系统。

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
