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
    private var cancellables = Set<AnyCancellable>()
    
    @MainActor
    func sendMessage() {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        // 1. Add User Message
        let userMessage = Message(content: trimmedText, sender: .user, timestamp: Date())
        messages.append(userMessage)
        inputText = ""
        
        // 2. Mock AI Streaming Start
        startAISession(with: trimmedText)
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
        // Mocking a TTS URL
        // In reality, this would call a TTS API
        print("Playing TTS for: \(message.content)")
        // For now, we just toggle the playing state in the manager for UI feedback
        // AudioPlayerManager.shared.playAudio(from: URL(string: "...")!, messageId: message.id)
        
        // Mock feedback
        AudioPlayerManager.shared.playingMessageId = message.id
        AudioPlayerManager.shared.isPlaying = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            AudioPlayerManager.shared.isPlaying = false
            AudioPlayerManager.shared.playingMessageId = nil
        }
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
}
