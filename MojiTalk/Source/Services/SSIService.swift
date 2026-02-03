import Foundation
import Combine

class SSIService: ObservableObject {
    enum SSEError: Error {
        case invalidURL
        case requestFailed
        case streamError
    }
    
    /// Establishes an SSE connection and streams back the response text
    func connect(to url: URL) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    var request = URLRequest(url: url)
                    request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
                    request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
                    
                    let (bytes, response) = try await URLSession.shared.bytes(for: request)
                    
                    guard let httpResponse = response as? HTTPURLResponse,
                          (200...299).contains(httpResponse.statusCode) else {
                        continuation.finish(throwing: SSEError.requestFailed)
                        return
                    }
                    
                    for try await line in bytes.lines {
                        // Very basic parser for "data: ..." format
                        if line.hasPrefix("data: ") {
                            let data = String(line.dropFirst(6))
                            if data == "[DONE]" {
                                continuation.finish()
                                break
                            }
                            continuation.yield(data)
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
