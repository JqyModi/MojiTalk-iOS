import Foundation

/// Basic Network Service using Swift Concurrency
actor NetworkService {
    static let shared = NetworkService()
    
    private init() {}
    
    enum NetworkError: Error {
        case invalidURL
        case requestFailed
        case decodingFailed
        case unknown
    }
    
    /// Basic GET request
    func get<T: Decodable>(url: URL) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.requestFailed
        }
        
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return decodedData
        } catch {
            throw NetworkError.decodingFailed
        }
    }
    
    // Placeholder for other methods (POST, etc.)
}
