import Foundation
import SwiftUI
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = [
        Message(content: "こんにちは！我是你的日语外教，今天想聊点什么呢？", sender: .ai, timestamp: Date())
    ]
    @Published var inputText: String = ""
    @Published var isStreaming: Bool = false
    @Published var selectedMessageForTools: Message? = nil
    @Published var showToolResult: Bool = false
    @Published var toolResultContent: String = ""
    @Published var toolTitle: String = ""
    
    private let ssiService = SSIService()
    private let audioManager = AudioPlayerManager.shared
    private let storage = MessageStorage.shared
    private let accountManager = AccountManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Load saved messages
        if let savedMessages = storage.loadMessages() {
            self.messages = savedMessages
        }
        
        // Auto-save when messages change
        $messages
            .dropFirst()
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] newMessages in
                self?.storage.saveMessages(newMessages)
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    func sendMessage() {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        // 1. Add User Message
        let userMessage = Message(content: trimmedText, sender: .user, timestamp: Date(), type: .text)
        messages.append(userMessage)
        inputText = ""
        
        // 2. Mock AI Streaming Start
        startAISession(with: trimmedText)
    }
    
    @MainActor
    func sendVoiceMessage(url: URL, duration: TimeInterval) {
        // 1. Create Audio Message
        let message = Message(
            content: "[语音消息] \(Int(duration))s",
            sender: .user,
            timestamp: Date(),
            type: .audio,
            audioDuration: duration
        )
        messages.append(message)
        
        // 2. Trigger AI Response (Mock ASR)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.startAISession(with: "（模拟语音转文字结果）语音消息已收到。")
        }
    }
    
    @MainActor
    private func startAISession(with prompt: String) {
        isStreaming = true
        
        // Create an empty AI message to be populated
        let aiMessageId = UUID()
        var aiMessage = Message(id: aiMessageId, content: "", sender: .ai, timestamp: Date(), isStreaming: true)
        messages.append(aiMessage)
        
        // Here we would normally call ssiService.connect(to: ...)
        // For MVP, we simulate the stream
        simulateStream(for: aiMessageId)
    }
    
    @MainActor
    private func simulateStream(for id: UUID) {
        let fullResponse = "这是一个流式回复测试。使用 SwiftUI 和 Combine 能够非常平滑地更新界面内容。"
        let words = fullResponse.map { String($0) }
        var currentText = ""
        
        for (index, char) in words.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                if let idx = self.messages.firstIndex(where: { $0.id == id }) {
                    currentText += char
                    self.messages[idx] = Message(id: id, content: currentText, sender: .ai, timestamp: self.messages[idx].timestamp, isStreaming: index < words.count - 1)
                    
                    if index == words.count - 1 {
                        self.isStreaming = false
                    }
                }
            }
        }
    }
    
    // MARK: - P1 Tools
    
    func playTTS(for message: Message) {
        print("DEBUG: playTTS triggered for: \(message.content)")
        
        // 1. 同步 UI 状态（控制气泡上的状态图标）
        AudioPlayerManager.shared.playingMessageId = message.id
        AudioPlayerManager.shared.isPlaying = true
        
        // 2. 触发 Live2D 口型同步播放
        // 依次尝试：Bundle资源 -> 沙盒资源 -> 系统测试音频
        let testPath = getTestAudioPath()
        
        if let path = testPath {
            print("DEBUG: Playing audio from \(path)")
            Live2DController.shared.playAudio(filePath: path, targetKey: message.id.uuidString)
            
            // 模拟播放时长 UI 回收（实际应对接播放完成回调）
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if AudioPlayerManager.shared.playingMessageId == message.id {
                    AudioPlayerManager.shared.isPlaying = false
                    AudioPlayerManager.shared.playingMessageId = nil
                }
            }
        } else {
            print("WARNING: No test audio found. Lip sync cannot be verified visually with sound.")
            // 纯 Mock 状态
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                AudioPlayerManager.shared.isPlaying = false
                AudioPlayerManager.shared.playingMessageId = nil
            }
        }
    }
    
    private func getTestAudioPath() -> String? {
        // 1. 尝试工程打包进去的资源
        if let path = Bundle.main.path(forResource: "test", ofType: "wav") { return path }
        
        // 2. 尝试 Sandbox Documents (手动放入验证)
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let testWav = docs?.appendingPathComponent("test.wav").path
        if let p = testWav, FileManager.default.fileExists(atPath: p) { return p }
        
        // 3. 兜底：如果是在模拟器，且本地有转换好的文件路径（硬编码仅供调试）
        let hardcodedPath = "/Users/modi/Documents/数据迁移/xcode/Project/MainApp/mojikaiwa-ios/MojiTalk/MojiTalk/Resources/Audio/test.wav"
        if FileManager.default.fileExists(atPath: hardcodedPath) { return hardcodedPath }
        
        return nil
    }
    
    func translate(message: Message) {
        toolTitle = "AI 翻译"
        toolResultContent = "正在翻译..."
        showToolResult = true
        
        // Mock translation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.toolResultContent = "这是对消息内容「\(message.content)」的 AI 翻译结果。通常这里会显示更加精准的日语->中文释义。"
        }
    }
    
    func analyzeGrammar(message: Message) {
        toolTitle = "语法解析"
        toolResultContent = "正在分析语法..."
        showToolResult = true
        
        // Mock grammar analysis
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.toolResultContent = "【语法点解析】\n1. 内容：\(message.content)\n2. 结构：名词+谓语\n3. 建议：这里使用了丁寧語，非常礼貌。"
        }
    }
    
    func logout() {
        accountManager.logout()
        // Clear local messages instantly for privacy
        messages = []
    }
}
