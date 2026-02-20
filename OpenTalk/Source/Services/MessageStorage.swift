import Foundation

class MessageStorage {
    static let shared = MessageStorage()
    private func getFileURL(for userId: String?) -> URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let name = userId != nil ? "chat_history_\(userId!).json" : "chat_history.json"
        return documentDirectory.appendingPathComponent(name)
    }
    
    func saveMessages(_ messages: [Message], for userId: String?) {
        do {
            let data = try JSONEncoder().encode(messages)
            let url = getFileURL(for: userId)
            try data.write(to: url)
            print("Chat history saved for \(userId ?? "guest") at: \(url.path)")
        } catch {
            print("Failed to save messages: \(error)")
        }
    }
    
    func loadMessages(for userId: String?) -> [Message]? {
        let url = getFileURL(for: userId)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            let messages = try JSONDecoder().decode([Message].self, from: data)
            return messages
        } catch {
            print("Failed to load messages: \(error)")
            return nil
        }
    }
    
    func clearHistory(for userId: String?) {
        let url = getFileURL(for: userId)
        try? FileManager.default.removeItem(at: url)
    }
}
