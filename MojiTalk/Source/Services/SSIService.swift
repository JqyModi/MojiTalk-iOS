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
    
    private let apiKey = "sk-6c772637b2a84fb8a8206e86806a9d66"
    private let chatEndpoint = URL(string: "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions")!
    private let asrEndpoint = URL(string: "https://dashscope.aliyuncs.com/compatible-mode/v1/audio/transcriptions")!
    private let ttsEndpoint = URL(string: "https://dashscope.aliyuncs.com/api/v1/services/audio/tts/text-to-speech")!
    
    /// Establishes an SSE connection with DashScope and streams back the response text
    func connect(messages: [Message]) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    var request = URLRequest(url: chatEndpoint)
                    request.httpMethod = "POST"
                    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
                    request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
                    
                    let chatMessages = messages.map { msg -> [String: String] in
                        ["role": msg.sender == .user ? "user" : "assistant", "content": msg.content]
                    }
                    
                    let body: [String: Any] = [
                        "model": "qwen-plus",
                        "messages": chatMessages,
                        "stream": true
                    ]
                    
                    request.httpBody = try JSONSerialization.data(withJSONObject: body)
                    
                    let (bytes, response) = try await URLSession.shared.bytes(for: request)
                    
                    guard let httpResponse = response as? HTTPURLResponse,
                          (200...299).contains(httpResponse.statusCode) else {
                        continuation.finish(throwing: SSEError.requestFailed)
                        return
                    }
                    
                    for try await line in bytes.lines {
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
        }
    }
    
    /// Transcribe audio file to text using ASR
    func transcribe(audioURL: URL) async throws -> String {
        print("DEBUG: Starting transcription for \(audioURL.path)")
        var request = URLRequest(url: asrEndpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        // File part
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.m4a\"\r\n".data(using: .utf8)!)
        // Using generic audio/mp4 for m4a/aac
        body.append("Content-Type: audio/mp4\r\n\r\n".data(using: .utf8)!)
        body.append(try Data(contentsOf: audioURL))
        body.append("\r\n".data(using: .utf8)!)
        
        // Model part
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        body.append("whisper-1".data(using: .utf8)!) // Using standard OpenAI model name for compatibility
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        let (data, response) = try await URLSession.shared.upload(for: request, from: body)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("DEBUG: ASR Response Status Code: \(httpResponse.statusCode)")
            if let responseBody = String(data: data, encoding: .utf8) {
                print("DEBUG: ASR Response Body: \(responseBody)")
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw SSEError.requestFailed
            }
        }
        
        if let result = try? JSONDecoder().decode(TranscriptionResult.self, from: data) {
            return result.text
        } else {
            // Fallback for different response formats
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let text = json["text"] as? String {
                return text
            }
            throw SSEError.decodingError
        }
    }
    
    /// Synthesize speech from text using TTS
    func synthesize(text: String) async throws -> Data {
        var request = URLRequest(url: ttsEndpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "sambert-zhichu-v1", // Stable TTS model
            "input": ["text": text],
            "parameters": [
                "volume": 50,
                "sample_rate": 16000,
                "format": "mp3"
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw SSEError.requestFailed
        }
        
        // For REST (non-SSE), it returns binary audio data
        return data
    }
}
