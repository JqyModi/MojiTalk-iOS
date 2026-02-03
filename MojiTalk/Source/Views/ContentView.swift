import SwiftUI

struct ContentView: View {
    @State private var messages: [Message] = [
        Message(content: "こんにちは！我是你的日语外教，今天想聊点什么呢？", sender: .ai, timestamp: Date())
    ]
    @State private var inputText: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 消息列表区
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(messages) { message in
                                MessageBubble(message: message)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: messages) { _ in
                        withAnimation {
                            proxy.scrollTo(messages.last?.id, anchor: .bottom)
                        }
                    }
                }
                
                Divider()
                
                // 输入区
                HStack(alignment: .bottom, spacing: 12) {
                    TextField("输入日语或中文...", text: $inputText)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .frame(minHeight: 40)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(inputText.isEmpty ? Color.gray : Color.blue)
                            .clipShape(Circle())
                    }
                    .disabled(inputText.isEmpty)
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .navigationTitle("MojiTalk")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func sendMessage() {
        let newUserMsg = Message(content: inputText, sender: .user, timestamp: Date())
        messages.append(newUserMsg)
        inputText = ""
        
        // 模拟 AI 回复响应
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let aiMsg = Message(content: "收到！让我们开始练习吧。", sender: .ai, timestamp: Date())
            messages.append(aiMsg)
        }
    }
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.sender == .user { Spacer() }
            
            Text(message.content)
                .padding(12)
                .background(message.sender == .user ? Color.blue : Color(.systemGray5))
                .foregroundColor(message.sender == .user ? .white : .primary)
                .cornerRadius(16)
                .frame(maxWidth: 280, alignment: message.sender == .user ? .trailing : .leading)
            
            if message.sender == .ai { Spacer() }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
