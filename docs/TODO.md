# MOJi会话 SwiftUI 重写计划 - TODO List

## 🔴 P0: 核心通信与基础 UI (对话闭环)
### 1. 基础架构与数据模型
- [ ] 定义 `Message` 核心数据模型 (ID, 内容, 角色 [User/AI], 时间戳)
- [ ] 搭建 `GlobalAppState` 状态管理 (基于 `@StateObject`)
- [ ] 封装基础网络请求层 (Swift Concurrency)

### 2. 构建 SwiftUI 对话界面
- [ ] 实现 `ChatView` 容器布局 (`ZStack` + `VStack`)
- [ ] 实现消息流滚动视图 (`ScrollView` + `LazyVStack` + `ScrollViewReader` 自动滚动到底部)
- [ ] 编写自定义消息气泡组件
    - [ ] 用户气泡 (右侧, 品牌主色)
    - [ ] AI 气泡 (左侧, 背景中色)
- [ ] 编写底部交互输入栏
    - [ ] 响应式 `TextField` (支持多行增长)
    - [ ] 发送按钮逻辑

### 3. SSE 流式数据集成
- [ ] 构建 `SSENetworkManager` (利用 `URLSession.bytes(from:delegate:)`)
- [ ] 实现 SSE 事件流解析器
- [ ] 实现界面的响应式更新 ( incremental content updates )

---

## 🟡 P1: 交互增强与 AI 工具
### 4. 语音播放 (TTS)
- [ ] 封装 `AudioPlayerManager` (基于 `AVFoundation`)
- [ ] 点击消息气泡触发 TTS 获取逻辑
- [ ] 实现播放状态反馈 UI (小喇叭动画)

### 5. AI 辅助工具集
- [ ] 实现消息长按菜单 (`contextMenu`)
- [ ] 接入现有“翻译”接口并展示结果
- [ ] 接入“语法解析”功能并实现结果展示弹窗

---

## 🔵 P2: 角色系统与业务框架
### 6. Live2D 桥接集成
- [ ] 创建 `Live2DView` (实现 `UIViewRepresentable`)
- [ ] 集成现有的 Live2D Native SDK 核心库
- [ ] 实现基础 idle 动画加载
- [ ] 实现简单的口型同步 (Lip-Sync) 映射

### 7. 账号与会话管理
- [ ] 实现极简登录/注册 UI (SwiftUI 风格)
- [ ] 封装 `AccountManager` 处理 Token 存储与有效期
- [ ] 实现对话历史的本地缓存或按需加载

---

## ⚪ P3: 优化与打磨
### 8. 性能与体验优化
- [ ] 打磨界面转场动画 (Transition)
- [ ] 适配 Dark Mode 全局色值
- [ ] 优化大数据量下的消息流渲染性能 (List 优化)
- [ ] 弱网环境下的重试逻辑 UI 反馈
