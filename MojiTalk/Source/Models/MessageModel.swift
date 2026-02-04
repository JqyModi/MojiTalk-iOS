import Foundation

enum MessageSender: String, Codable {
    case user
    case ai
}

struct Message: Identifiable, Equatable, Codable {
    var id: UUID = UUID()
    let content: String
    let sender: MessageSender
    let timestamp: Date
    var isStreaming: Bool = false
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id && lhs.content == rhs.content && lhs.isStreaming == rhs.isStreaming
    }
}
