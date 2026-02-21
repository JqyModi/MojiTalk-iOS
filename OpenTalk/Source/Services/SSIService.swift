import Foundation
import Combine

class SSIService: ObservableObject {
    enum SSEError: Error {
        case invalidURL
        case requestFailed
        case streamError
        case decodingError
    }
    
    struct TranscriptionResult: Codable {
        let text: String
    }
    
    private let apiKey = "sk-xlaqakltfjnjjiipeffzxkpfgqbcvyvawrtsyjxscpwvbxqq"
    // migrated to SiliconFlow OpenAI Compatible Endpoint
    private let chatEndpoint = URL(string: "https://api.siliconflow.cn/v1/chat/completions")!
    // asrEndpoint is deprecated (will use iOS Native ASR instead)
    private let asrEndpoint = URL(string: "https://dashscope.aliyuncs.com/compatible-mode/v1/audio/transcriptions")!
    private let ttsEndpoint = URL(string: "https://api.siliconflow.cn/v1/audio/speech")!
    
    /// Establishes an SSE connection with DashScope and streams back the response text
    func connect(messages: [Message]) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    var request = URLRequest(url: chatEndpoint)
                    request.httpMethod = "POST"
                    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
                    request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
                    
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
                        "max_tokens": 800 // Safety buffer, though system prompt is primary
                    ]
                    
                    request.httpBody = try JSONSerialization.data(withJSONObject: body)
                    
                    let (bytes, response) = try await URLSession.shared.bytes(for: request)
                    
                    guard let httpResponse = response as? HTTPURLResponse,
                          (200...299).contains(httpResponse.statusCode) else {
                        continuation.finish(throwing: SSEError.requestFailed)
                        return
                    }
                    
                    for try await line in bytes.lines {
                        // Check for cancellation within the loop
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
            
            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }
    
    /// Synthesize speech from text using TTS
    func synthesize(text: String) async throws -> Data {
        print("DEBUG: Starting TTS synthesis for: \(text)")
        var request = URLRequest(url: ttsEndpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "fishaudio/fish-speech-1.5",
            "input": text,
            "voice": "fishaudio/fish-speech-1.5:alex",
            "response_format": "wav"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("DEBUG: TTS Response Status Code: \(httpResponse.statusCode)")
            if !(200...299).contains(httpResponse.statusCode) {
                 if let responseBody = String(data: data, encoding: .utf8) {
                    print("DEBUG: TTS Error Body: \(responseBody)")
                 }
                throw SSEError.requestFailed
            }
        }
        
        // OpenAI compatible /v1/audio/speech directly returns audio data bytes
        return data
    }
    
    /// Helper to create a simple GET request for downloading binary data
    private func requestWith(_ url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.cachePolicy = .useProtocolCachePolicy
        request.timeoutInterval = 30
        return request
    }
}
