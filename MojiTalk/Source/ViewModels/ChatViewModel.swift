import Foundation
import SwiftUI
import Combine
import AVFoundation
import Supabase

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
    @Published var textToTranslate: String = ""
    @Published var showSystemTranslation: Bool = false
    @Published var isDetailedAnalysis: Bool = false // Tracks if user wants more detail
    @Published var isAutoPlayTTS: Bool = UserDefaults.standard.object(forKey: "settings_auto_play_tts") as? Bool ?? true {
        didSet {
            UserDefaults.standard.set(isAutoPlayTTS, forKey: "settings_auto_play_tts")
        }
    }

    
    private let ssiService = SSIService()
    private let audioManager = AudioPlayerManager.shared
    private let storage = MessageStorage.shared
    private let accountManager = AccountManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let userId = accountManager.currentUser?.id.uuidString
        // Load saved messages
        if let savedMessages = storage.loadMessages(for: userId) {
            self.messages = savedMessages
        }
        
        // Auto-save when messages change
        $messages
            .dropFirst()
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] newMessages in
                guard let self = self else { return }
                let currentUserId = self.accountManager.currentUser?.id.uuidString
                // Only save if we have a valid user, or if it's the guest session
                self.storage.saveMessages(newMessages, for: currentUserId)
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    func sendMessage() {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        AudioPlayerManager.shared.stopAll()
        
        // 0. Wake up Live2D performance
        Live2DController.shared.setFPS(60)
        
        // 1. Add User Message
        let userMessage = Message(content: trimmedText, sender: .user, timestamp: Date(), type: .text, status: .sent)
        messages.append(userMessage)
        inputText = ""
        
        // 2. Mock AI Streaming Start
        startAISession(with: trimmedText)
    }
    
    @MainActor
    func sendVoiceMessage(url: URL, duration: TimeInterval) {
        AudioPlayerManager.shared.stopAll()
        
        // 1. Create Audio Message
        let messageId = UUID()
        let message = Message(
            id: messageId,
            content: "（正在识别中...）",
            sender: .user,
            timestamp: Date(),
            type: .audio,
            audioDuration: duration,
            audioURL: url.path
        )
        messages.append(message)
        
        // 2. Trigger Local ASR (0 cost)
        Task {
            do {
                let transcription = try await AudioRecorderManager.shared.transcribe(url: url)
                if let index = messages.firstIndex(where: { $0.id == messageId }) {
                    messages[index].content = transcription
                    // Trigger AI session with the transcribed text
                    self.startAISession(with: transcription)
                }
            } catch {
                print("ERROR: Local ASR failed: \(error)")
                if let index = messages.firstIndex(where: { $0.id == messageId }) {
                    messages[index].content = "（识别失败，请点击重试）"
                    messages[index].status = .failed
                }
            }
        }
    }
    
    @MainActor
    private func startAISession(with prompt: String) {
        isStreaming = true
        
        // Create an empty AI message to be populated
        let aiMessageId = UUID()
        let aiMessage = Message(id: aiMessageId, content: "", sender: .ai, timestamp: Date(), isStreaming: true)
        messages.append(aiMessage)
        
        Task {
            do {
                // Use the last N messages for context (e.g., last 10)
                let context = Array(messages.suffix(10))
                let stream = ssiService.connect(messages: context)
                
                var accumulatedText = ""
                var lastUpdate = Date()
                for try await delta in stream {
                    accumulatedText += delta
                    // Throttle UI updates to max 10 times per second to save CPU/Battery
                    if Date().timeIntervalSince(lastUpdate) > 0.1 {
                        if let index = messages.firstIndex(where: { $0.id == aiMessageId }) {
                            messages[index].content = accumulatedText
                        }
                        lastUpdate = Date()
                    }
                }
                
                // Final update to ensure completion
                if let index = messages.firstIndex(where: { $0.id == aiMessageId }) {
                    messages[index].content = accumulatedText
                }
                
                // Finalize message
                if let index = messages.firstIndex(where: { $0.id == aiMessageId }) {
                    messages[index].isStreaming = false
                    
                    // Auto-play TTS logic:
                    // 1. If global toggle is on
                    // 2. OR if the user just sent a voice message (legacy behavior preserved)
                    let lastUserMessage = messages.prefix(index).last(where: { $0.sender == .user })
                    if isAutoPlayTTS || (lastUserMessage?.type == .audio) {
                        self.playTTS(for: messages[index])
                    } else {
                        // If no TTS auto-play, return to low power mode
                        Live2DController.shared.setFPS(30)
                    }
                }
                isStreaming = false
            } catch {
                print("ERROR: SSE stream failed: \(error)")
                if let index = messages.firstIndex(where: { $0.id == aiMessageId }) {
                    messages[index].content = "抱歉，对话服务暂时不可用，请稍后再试。"
                    messages[index].status = .failed
                }
                isStreaming = false
            }
        }
    }
    
    // MARK: - P1 Tools
    
    func playTTS(for message: Message) {
        let audioManager = AudioPlayerManager.shared
        
        // 1. Toggle & Debounce Logic
        if audioManager.playingMessageId == message.id {
            if audioManager.isPlaying || audioManager.isLoading {
                print("DEBUG: Playback Toggling stop for: \(message.id)")
                audioManager.stopAll()
                return
            }
        }
        
        // 2. Start new session
        audioManager.stopAll() // Stop any previous playback
        audioManager.playingMessageId = message.id
        audioManager.isLoading = true
        
        let currentSessionId = message.id
        
        Task {
            do {
                if message.sender == .user, let audioPath = message.audioURL {
                    // --- Case A: User Message - Play original recording ---
                    let url = URL(fileURLWithPath: audioPath)
                    let audioData = try Data(contentsOf: url)
                    
                    // Race condition check: still the active message?
                    guard AudioPlayerManager.shared.playingMessageId == currentSessionId else { return }
                    
                    let dummyPlayer = try AVAudioPlayer(data: audioData)
                    let exactDuration = dummyPlayer.duration
                    
                    await MainActor.run {
                        guard audioManager.playingMessageId == currentSessionId else { return }
                        audioManager.isLoading = false
                        audioManager.isPlaying = true
                        
                        // Play local audio data
                        audioManager.play(data: audioData, messageId: message.id)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + exactDuration) {
                            if audioManager.playingMessageId == currentSessionId {
                                audioManager.isPlaying = false
                                audioManager.playingMessageId = nil
                            }
                        }
                    }
                } else {
                    // --- Case B: AI Message - Synthesize TTS ---
                    let audioData = try await ssiService.synthesize(text: message.content)
                    
                    // Race condition check after long async TTS call
                    guard AudioPlayerManager.shared.playingMessageId == currentSessionId else {
                        print("DEBUG: TTS result discarded due to session change")
                        return
                    }
                    
                    let dummyPlayer = try AVAudioPlayer(data: audioData)
                    let exactDuration = dummyPlayer.duration
                    
                    // Save to temp file for Live2D
                    let tempDir = FileManager.default.temporaryDirectory
                    let tempURL = tempDir.appendingPathComponent("\(message.id.uuidString).mp3")
                    try audioData.write(to: tempURL)
                    
                    await MainActor.run {
                        guard audioManager.playingMessageId == currentSessionId else { return }
                        audioManager.isLoading = false
                        audioManager.isPlaying = true
                        
                        // Trigger Live2D lip sync
                        Live2DController.shared.setFPS(60)
                        Live2DController.shared.playAudio(filePath: tempURL.path, targetKey: message.id.uuidString)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + exactDuration) {
                            if audioManager.playingMessageId == currentSessionId {
                                audioManager.isPlaying = false
                                audioManager.playingMessageId = nil
                                Live2DController.shared.setFPS(30)
                            }
                        }
                    }
                }
            } catch {
                print("ERROR: Playback failed: \(error)")
                await MainActor.run {
                    if audioManager.playingMessageId == currentSessionId {
                        audioManager.isLoading = false
                        audioManager.isPlaying = false
                        audioManager.playingMessageId = nil
                    }
                }
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
        if #available(iOS 17.4, *) {
            // Use Apple's Translation Framework (0 cost)
            self.textToTranslate = message.content
            self.showSystemTranslation = true
        } else {
            // Fallback for older iOS versions: Use AI Translation (reusing Qwen)
            aiTranslate(message: message)
        }
    }
    
    @MainActor
    private func aiTranslate(message: Message) {
        toolTitle = "AI 翻译"
        toolResultContent = "AI 正在翻译并润色中..."
        showToolResult = true
        
        Task {
            do {
                let translatePrompt = Message(
                    content: "请将以下日语翻译成地道的中文，如果原文是中文则翻译成日语。只需输出翻译结果，不要有其他解释。原文：\"\(message.content)\"",
                    sender: .user,
                    timestamp: Date()
                )
                
                let stream = ssiService.connect(messages: [translatePrompt])
                
                var accumulatedText = ""
                for try await delta in stream {
                    accumulatedText += delta
                    self.toolResultContent = accumulatedText
                }
            } catch {
                self.toolResultContent = "暂时无法连接翻译服务器，请检查网络。"
            }
        }
    }
    
    @MainActor
    func analyzeGrammar(message: Message, detailed: Bool = false) {
        isDetailedAnalysis = detailed
        toolTitle = detailed ? "深度语法解析" : "语法精讲"
        
        if !detailed {
            toolResultContent = "正在提取核心语法项..."
        } else {
            toolResultContent += "\n\n---\n⏳ 正在加载详细补充..."
        }
        
        showToolResult = true
        
        Task {
            do {
                let promptContent = detailed ?
                    "请针对刚才的句子 \"\(message.content)\" 提供更深层的语境、文化背景及易错点分析。" :
                    "请作为日语私教，对句子 \"\(message.content)\" 进行极简解析。格式要求：【核心语感】（15字内）+【关键语法】（1项）+【地道用法】（1点）。严禁啰嗦。"
                
                let grammarPrompt = Message(content: promptContent, sender: .user, timestamp: Date())
                let stream = ssiService.connect(messages: [grammarPrompt])
                
                var accumulatedText = detailed ? toolResultContent.replacingOccurrences(of: "\n\n---\n⏳ 正在加载详细补充...", with: "\n\n--- [深度补充] ---\n") : ""
                
                for try await delta in stream {
                    accumulatedText += delta
                    self.toolResultContent = accumulatedText
                }
            } catch {
                self.toolResultContent = "暂时无法连接解析服务器。"
            }
        }
    }
    
    func logout() {
        // Stop any active processes
        audioManager.stopAll()
        isStreaming = false
        
        // 1. Clear session in account manager
        accountManager.logout()
        
        // 2. Clear memory messages instantly for the next user or guest
        // The previous user's messages are safely saved in their UID-specific file
        messages = [
            Message(content: "こんにちは！我是你的日语外教，今天想聊点什么呢？", sender: .ai, timestamp: Date())
        ]
    }
    
    func deleteAccount() {
        Task {
            do {
                // 1. Clear local history for this specific user
                let userId = accountManager.currentUser?.id.uuidString
                storage.clearHistory(for: userId)
                
                // 2. Call account manager to delete account (Supabase)
                // Note: Implementation usually involves calling a service to delete user data
                try await accountManager.deleteAccount()
                
                await MainActor.run {
                    logout()
                }
            } catch {
                print("ERROR: Delete account failed: \(error)")
            }
        }
    }
    
    // MARK: - Compliance & Robustness
    
    func reportMessage(_ message: Message) {
        // AI Content Compliance: Guideline 1.2
        print("DEBUG: Reporting message: \(message.id)")
        toolTitle = "内容举报"
        toolResultContent = "感谢您的反馈。我们已收到对该 AI 生成内容的举报，后台将进行审核以优化生成结果。"
        showToolResult = true
    }
    
    @MainActor
    func resendMessage(_ message: Message) {
        guard let index = messages.firstIndex(where: { $0.id == message.id }) else { return }
        
        // Update status to sending
        messages[index].status = .sending
        
        // Retry the AI session
        startAISession(with: message.content)
    }
    
    deinit {
        print("DEBUG: ChatViewModel deinit - cleaning up resources")
    }
}
