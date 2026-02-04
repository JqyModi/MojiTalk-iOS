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
            
            // 2. Live2D Layer (Background Character)
            Live2DView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(0.6) // Blend with background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 3. Chat Stream
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(viewModel.messages) { message in
                                MessageBubbleView(
                                    message: message,
                                    onTranslate: { viewModel.translate(message: message) },
                                    onAnalyze: { viewModel.analyzeGrammar(message: message) },
                                    onPlay: { viewModel.playTTS(for: message) }
                                )
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
        .sheet(isPresented: $viewModel.showToolResult) {
            ToolResultView(title: viewModel.toolTitle, content: viewModel.toolResultContent)
                .presentationDetents([.medium])
        }
    }
}

struct MessageBubbleView: View {
    let message: Message
    @ObservedObject private var audioManager = AudioPlayerManager.shared
    var onTranslate: (() -> Void)? = nil
    var onAnalyze: (() -> Void)? = nil
    var onPlay: (() -> Void)? = nil
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.sender == .user { Spacer() }
            
            VStack(alignment: message.sender == .user ? .trailing : .leading, spacing: 4) {
                HStack(alignment: .bottom, spacing: 8) {
                    if message.sender == .ai {
                        playbackIcon
                    }
                    
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
                        .onTapGesture {
                            // 点击文字也可以触发播放
                            onPlay?()
                        }
                        .contextMenu {
                            Button(action: { onTranslate?() }) {
                                Label("翻译", systemImage: "character.book.closed")
                            }
                            Button(action: { onAnalyze?() }) {
                                Label("语法分析", systemImage: "text.magnifyingglass")
                            }
                            Button(action: { UIPasteboard.general.string = message.content }) {
                                Label("复制", systemImage: "doc.on.doc")
                            }
                        }
                }
            }
            
            if message.sender == .ai { Spacer() }
        }
    }
    
    @ViewBuilder
    private var playbackIcon: some View {
        if message.sender == .ai && !message.content.isEmpty {
            Button(action: {
                print("DEBUG: Speaker icon tapped for \(message.id)")
                onPlay?()
            }) {
                Image(systemName: audioManager.playingMessageId == message.id ? "speaker.wave.2.fill" : "speaker.wave.2")
                    .font(.system(size: 14))
                    .foregroundColor(DesignSystem.Colors.accent)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .scaleEffect(audioManager.playingMessageId == message.id ? 1.2 : 1.0)
            }
            .buttonStyle(.plain)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: audioManager.playingMessageId)
        }
    }
}

struct ToolResultView: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(title)
                    .font(DesignSystem.Fonts.heading(size: 20))
                Spacer()
                Image(systemName: "sparkles")
                    .foregroundColor(DesignSystem.Colors.accent)
            }
            
            ScrollView {
                Text(content)
                    .font(DesignSystem.Fonts.body(size: 16))
                    .lineSpacing(6)
            }
            
            Spacer()
        }
        .padding(24)
        .background(DesignSystem.Colors.primary.ignoresSafeArea())
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
