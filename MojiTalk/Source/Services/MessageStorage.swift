import Foundation

class MessageStorage {
    static let shared = MessageStorage()
    private let fileName = "chat_history.json"
    
    private var fileURL: URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentDirectory.appendingPathComponent(fileName)
    }
    
    func saveMessages(_ messages: [Message]) {
        do {
            let data = try JSONEncoder().encode(messages)
            try data.write(to: fileURL)
            print("Chat history saved to: \(fileURL.path)")
        } catch {
            print("Failed to save messages: \(error)")
        }
    }
    
    func loadMessages() -> [Message]? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        do {
            let data = try Data(contentsOf: fileURL)
            let messages = try JSONDecoder().decode([Message].self, from: data)
            return messages
        } catch {
            print("Failed to load messages: \(error)")
            return nil
        }
    }
    
    func clearHistory() {
        try? FileManager.default.removeItem(at: fileURL)
    }
}
