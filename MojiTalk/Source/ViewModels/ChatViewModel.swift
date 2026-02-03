import Foundation
import SwiftUI
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = [
        Message(content: "こんにちは！我是你的日语外教，今天想聊点什么呢？", sender: .ai, timestamp: Date())
    ]
    @Published var inputText: String = ""
    @Published var isStreaming: Bool = false
    
    private let ssiService = SSIService()
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
}
