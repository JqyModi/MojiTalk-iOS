import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    
    var body: some View {
        ZStack {
            // 1. Immersive Background
            LinearGradient(colors: [DesignSystem.Colors.primary, DesignSystem.Colors.secondary.opacity(0.8)], 
                           startPoint: .topLeading, 
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 2. Chat Stream
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(viewModel.messages) { message in
                                MessageBubbleView(message: message)
                                    .transition(.asymmetric(
                                        insertion: .scale(scale: 0.8, anchor: message.sender == .user ? .trailing : .leading).combined(with: .opacity),
                                        removal: .opacity
                                    ))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .padding(.bottom, 100)
                    }
                    .onChange(of: viewModel.messages) { _ in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // 3. Floating Smart Input
            VStack {
                Spacer()
                ControlPanel(inputText: $viewModel.inputText, onSend: {
                    viewModel.sendMessage()
                })
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }
}

struct MessageBubbleView: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.sender == .user { Spacer() }
            
            VStack(alignment: message.sender == .user ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(DesignSystem.Fonts.body(size: 17))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(message.sender == .user ? DesignSystem.Colors.accent.opacity(0.9) : .white.opacity(0.1))
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                            )
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    )
                    .foregroundColor(message.sender == .user ? .white : .white.opacity(0.9))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            }
            
            if message.sender == .ai { Spacer() }
        }
    }
}

struct ControlPanel: View {
    @Binding var inputText: String
    var onSend: () -> Void
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            // Input Field
            TextField("输入日语或中国语...", text: $inputText, axis: .vertical)
                .lineLimit(1...5)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .cornerRadius(25)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                )
                .font(.system(size: 16))
            
            // Send Button
            Button(action: onSend) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(inputText.isEmpty ? Color.gray.opacity(0.3) : DesignSystem.Colors.accent)
                    )
                    .shadow(color:DesignSystem.Colors.accent.opacity(inputText.isEmpty ? 0 : 0.3), radius: 10)
            }
            .disabled(inputText.isEmpty)
        }
        .padding(8)
        .background(.ultraThinMaterial)
        .cornerRadius(35)
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
            .preferredColorScheme(.dark)
    }
}
