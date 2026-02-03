import Foundation

enum MessageSender {
    case user
    case ai
}

struct Message: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let sender: MessageSender
    let timestamp: Date
    var isStreaming: Bool = false
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id && lhs.content == rhs.content && lhs.isStreaming == rhs.isStreaming
    }
}
