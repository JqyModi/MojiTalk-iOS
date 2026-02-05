import Foundation

enum MessageSender: String, Codable {
    case user
    case ai
}

enum MessageType: String, Codable, Equatable {
    case text
    case audio
}

enum MessageStatus: String, Codable {
    case sending
    case sent
    case failed
}

struct Message: Identifiable, Equatable, Codable {
    var id: UUID = UUID()
    var content: String
    let sender: MessageSender
    let timestamp: Date
    var type: MessageType = .text
    var audioDuration: TimeInterval? = nil
    var isStreaming: Bool = false
    var status: MessageStatus = .sent
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id && lhs.content == rhs.content && lhs.isStreaming == rhs.isStreaming && lhs.type == rhs.type
    }
}
