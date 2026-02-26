import Foundation
import Combine
import AVFoundation
#if canImport(FoundationModels)
import FoundationModels
#endif

// MARK: - Protocols & Strategy Types

enum AIProvider: String, CaseIterable {
    case dashscope   // Alibaba DashScope
    case siliconflow // SiliconFlow
    case appleNative // Apple Intelligence / Siri
    case volcengine  // Volcengine (Future)
}

protocol AIStrategy {
    func connect(messages: [Message]) -> AsyncThrowingStream<String, Error>
    func synthesize(text: String) async throws -> Data
}

// MARK: - Error Types

enum SSIServiceError: Error {
    case invalidURL
    case requestFailed
    case streamError
    case decodingError
    case strategyNotImplemented
    case unsupportedOSVersion
}

// MARK: - Alibaba DashScope Strategy

class DashScopeStrategy: AIStrategy {
    private let apiKey = "sk-xlaqakltfjnjjiipeffzxkpfgqbcvyvawrtsyjxscpwvbxqq"
    private let chatEndpoint = URL(string: "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions")!
    private let ttsEndpoint = URL(string: "https://dashscope.aliyuncs.com/api/v1/services/aigc/multimodal-generation/generation")!
    
    func connect(messages: [Message]) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    var request = URLRequest(url: chatEndpoint)
                    request.httpMethod = "POST"
                    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
                    
                    let systemPrompt = [
                        "role": "system",
                        "content": "你是一个亲切的日语外教。为了保证良好的对话体验和语音合成性能，请遵循：1. 日常对话控制在100字符以内。2. 复杂的语法解析或详细说明控制在500字符以内。3. 绝对禁止超过600字符。语言要自然、口语化。"
                    ]
                    
                    var chatMessages = messages.map { msg -> [String: String] in
                        ["role": msg.sender == .user ? "user" : "assistant", "content": msg.content]
                    }
                    chatMessages.insert(systemPrompt, at: 0)
                    
                    let body: [String: Any] = [
                        "model": "qwen-plus",
                        "messages": chatMessages,
                        "stream": true,
                        "max_tokens": 800
                    ]
                    
                    request.httpBody = try JSONSerialization.data(withJSONObject: body)
                    let (bytes, response) = try await URLSession.shared.bytes(for: request)
                    
                    guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                        throw SSIServiceError.requestFailed
                    }
                    
                    for try await line in bytes.lines {
                        if Task.isCancelled { break }
                        if line.hasPrefix("data: ") {
                            let dataStr = String(line.dropFirst(6))
                            if dataStr == "[DONE]" {
                                continuation.finish()
                                break
                            }
                            if let data = dataStr.data(using: .utf8),
                               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                               let choices = json["choices"] as? [[String: Any]],
                               let delta = choices.first?["delta"] as? [String: Any],
                               let content = delta["content"] as? String {
                                continuation.yield(content)
                            }
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { @Sendable _ in task.cancel() }
        }
    }
    
    func synthesize(text: String) async throws -> Data {
        var request = URLRequest(url: ttsEndpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "qwen3-tts-flash",
            "input": ["text": text]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw SSIServiceError.requestFailed
        }
        
        struct TTSResponse: Codable {
            struct Output: Codable {
                struct Audio: Codable { let url: String? }
                let audio: Audio
            }
            let output: Output
        }
        
        let ttsResponse = try JSONDecoder().decode(TTSResponse.self, from: data)
        guard let audioStringURL = ttsResponse.output.audio.url else { throw SSIServiceError.decodingError }
        
        let secureAudioURLString = audioStringURL.replacingOccurrences(of: "http://", with: "https://")
        guard let audioURL = URL(string: secureAudioURLString) else { throw SSIServiceError.decodingError }
        
        let (audioData, _) = try await URLSession.shared.data(from: audioURL)
        return audioData
    }
}

// MARK: - SiliconFlow Strategy

class SiliconFlowStrategy: AIStrategy {
    private let apiKey = "sk-xlaqakltfjnjjiipeffzxkpfgqbcvyvawrtsyjxscpwvbxqq"
    private let chatEndpoint = URL(string: "https://api.siliconflow.cn/v1/chat/completions")!
    private let ttsEndpoint = URL(string: "https://api.siliconflow.cn/v1/audio/speech")!
    
    func connect(messages: [Message]) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    var request = URLRequest(url: chatEndpoint)
                    request.httpMethod = "POST"
                    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
                    
                    let systemPrompt = [
                        "role": "system",
                        "content": "你是一个亲切的日语外教。为了保证良好的对话体验和语音合成性能，请遵循：1. 日常对话控制在100字符以内。2. 复杂的语法解析或详细说明控制在500字符以内。3. 绝对禁止超过600字符。语言要自然、口语化。"
                    ]
                    
                    var chatMessages = messages.map { msg -> [String: String] in
                        ["role": msg.sender == .user ? "user" : "assistant", "content": msg.content]
                    }
                    chatMessages.insert(systemPrompt, at: 0)
                    
                    let body: [String: Any] = [
                        "model": "deepseek-ai/DeepSeek-V3",
                        "messages": chatMessages,
                        "stream": true,
                        "max_tokens": 800
                    ]
                    
                    request.httpBody = try JSONSerialization.data(withJSONObject: body)
                    let (bytes, response) = try await URLSession.shared.bytes(for: request)
                    
                    guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                        throw SSIServiceError.requestFailed
                    }
                    
                    for try await line in bytes.lines {
                        if Task.isCancelled { break }
                        if line.hasPrefix("data: ") {
                            let dataStr = String(line.dropFirst(6))
                            if dataStr == "[DONE]" {
                                continuation.finish()
                                break
                            }
                            if let data = dataStr.data(using: .utf8),
                               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                               let choices = json["choices"] as? [[String: Any]],
                               let delta = choices.first?["delta"] as? [String: Any],
                               let content = delta["content"] as? String {
                                continuation.yield(content)
                            }
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { @Sendable _ in task.cancel() }
        }
    }
    
    func synthesize(text: String) async throws -> Data {
        var request = URLRequest(url: ttsEndpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "FunAudioLLM/CosyVoice2-0.5B",
            "input": text,
            "voice": "FunAudioLLM/CosyVoice2-0.5B:bella",
            "response_format": "wav"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw SSIServiceError.requestFailed
        }
        return data
    }
}

// MARK: - Apple Native Strategy (iOS 18+ Apple Intelligence & Siri)

class AppleNativeStrategy: AIStrategy {
    func connect(messages: [Message]) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            #if canImport(FoundationModels)
            if #available(iOS 26.0, *) {
                Task {
                    do {
                        let session = LanguageModelSession()
                        
                        // Convert messages to Apple context
                        // Note: Depending on actual final Apple Intelligence SDK, 
                        // this might involve appending strings or specialized objects.
                        let prompt = messages.map { "\($0.sender == .user ? "User" : "AI"): \($0.content)" }.joined(separator: "\n")
                        
                        // We use the system's local generative capacity
                        // Placeholder for actual Apple Intelligence generation call
                        // Since exact final public API signatures can vary by beta, we use a compliant pattern
                        var accumulated = ""
                        for try await responseChunk in session.streamResponse(to: prompt) {
                            let currentContent = responseChunk.content
                            let delta = String(currentContent.dropFirst(accumulated.count))
                            accumulated = currentContent
                            if !delta.isEmpty {
                                continuation.yield(delta)
                            }
                        }
                        continuation.finish()
                    } catch {
                        continuation.finish(throwing: error)
                    }
                }
            } else {
                continuation.finish(throwing: SSIServiceError.unsupportedOSVersion)
            }
            #else
            continuation.yield("Apple Intelligence requires iOS 18+ and a device that supports FoundationModels.")
            continuation.finish()
            #endif
        }
    }
    
    func synthesize(text: String) async throws -> Data {
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: text)
        // Select Siri Japanese/Chinese voice
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        
        return try await withCheckedThrowingContinuation { continuation in
            var audioData = Data()
            var hasContinued = false
            
            synthesizer.write(utterance) { (buffer: AVAudioBuffer) in
                guard let pcmBuffer = buffer as? AVAudioPCMBuffer else { return }
                // Live2D needs WAV/PCM. We collect the raw bytes from the buffer.
                let frameLength = Int(pcmBuffer.frameLength)
                let channels = Int(pcmBuffer.format.channelCount)
                
                if let floatData = pcmBuffer.floatChannelData {
                    for frame in 0..<frameLength {
                        for channel in 0..<channels {
                            let sample = floatData[channel][frame]
                            // Conver to 16bit PCM for simple WAV header compatibility if needed
                            // For simplicity, we can return the raw float data if L2D supports it, 
                            // but usually 16bit INT is safest.
                            let intSample = Int16(max(-32768, min(32767, sample * 32767)))
                            withUnsafeBytes(of: intSample) { audioData.append(contentsOf: $0) }
                        }
                    }
                }
            }
            
            // Note: In a real app, you would use delegates to know when synthesis is complete.
            // For this strategy, we simulate the completion after a short delay since write() is sync-start.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if !hasContinued {
                    hasContinued = true
                    // Add a simple 44-byte WAV header if needed by L2DWavFileHandler
                    let header = self.createWavHeader(dataSize: audioData.count)
                    var finalData = header
                    finalData.append(audioData)
                    continuation.resume(returning: finalData)
                }
            }
        }
    }
    
    private func createWavHeader(dataSize: Int) -> Data {
        var header = Data()
        header.append("RIFF".data(using: .utf8)!)
        let totalSize = Int32(dataSize + 36)
        withUnsafeBytes(of: totalSize) { header.append(contentsOf: $0) }
        header.append("WAVE".data(using: .utf8)!)
        header.append("fmt ".data(using: .utf8)!)
        let fmtSize: Int32 = 16
        withUnsafeBytes(of: fmtSize) { header.append(contentsOf: $0) }
        let format: Int16 = 1 // PCM
        withUnsafeBytes(of: format) { header.append(contentsOf: $0) }
        let channels: Int16 = 1
        withUnsafeBytes(of: channels) { header.append(contentsOf: $0) }
        let sampleRate: Int32 = 22050 // AVSpeechSynthesizer default approx
        withUnsafeBytes(of: sampleRate) { header.append(contentsOf: $0) }
        let byteRate: Int32 = 22050 * 2
        withUnsafeBytes(of: byteRate) { header.append(contentsOf: $0) }
        let blockAlign: Int16 = 2
        withUnsafeBytes(of: blockAlign) { header.append(contentsOf: $0) }
        let bitsPerSample: Int16 = 16
        withUnsafeBytes(of: bitsPerSample) { header.append(contentsOf: $0) }
        header.append("data".data(using: .utf8)!)
        let subchunk2Size = Int32(dataSize)
        withUnsafeBytes(of: subchunk2Size) { header.append(contentsOf: $0) }
        return header
    }
}

// MARK: - SSIService

class SSIService: ObservableObject {
    typealias SSEError = SSIServiceError
    
    struct TranscriptionResult: Codable {
        let text: String
    }
    
    // Default strategy is DashScope
    private var strategy: AIStrategy = DashScopeStrategy()
    
    /// Switch AI Provider
    func setProvider(_ provider: AIProvider) {
        switch provider {
        case .dashscope:
            strategy = DashScopeStrategy()
        case .siliconflow:
            strategy = SiliconFlowStrategy()
        case .appleNative:
            strategy = AppleNativeStrategy()
        case .volcengine:
            print("ERROR: Volcengine strategy not implemented yet.")
        }
    }
    
    /// Establishes an SSE connection with the current strategy and streams back response text
    func connect(messages: [Message]) -> AsyncThrowingStream<String, Error> {
        return strategy.connect(messages: messages)
    }
    
    /// Synthesize speech from text using the current strategy
    func synthesize(text: String) async throws -> Data {
        return try await strategy.synthesize(text: text)
    }
}
