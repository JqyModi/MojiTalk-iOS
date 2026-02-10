import SwiftUI
import Translation

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var showUserProfile = false
    
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
            
            // 3. Chat Stream
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(viewModel.messages) { message in
                            MessageBubbleView(
                                message: message,
                                onTranslate: { viewModel.translate(message: message) },
                                onAnalyze: { 
                                    viewModel.selectedMessageForTools = message
                                    viewModel.analyzeGrammar(message: message) 
                                },
                                onPlay: { viewModel.playTTS(for: message) },
                                onReport: { viewModel.reportMessage(message) },
                                onRetry: { viewModel.resendMessage(message) }
                            )
                            .id(message.id) // Ensure explicit ID for scrolling
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.8, anchor: message.sender == .user ? .trailing : .leading).combined(with: .opacity),
                                removal: .opacity
                            ))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 100) // Large top padding to avoid being under the floating header
                    .padding(.bottom, 120) // Bottom padding for input panel
                }
                .scrollDismissesKeyboard(.interactively)
                .unifiedKeyboardDismiss()
                .onChange(of: viewModel.messages) { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: viewModel.isStreaming) { isStreaming in
                    if isStreaming {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            .ignoresSafeArea(.container, edges: .top) // Fill up to the very top
            
            // 4. Floating Header (User Profile)
            VStack {
                HStack {
                    Spacer()
                    Button(action: { showUserProfile = true }) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 18, weight: .bold)) // Smaller icon
                            .foregroundColor(.white.opacity(0.9))
                            .padding(12) // Smaller padding
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 10)
                    }
                    .padding(.trailing, 20)
                }
                Spacer()
            }
            .padding(.top, 10) // Small adjustment above safe area
            
            // 3. Floating Smart Input
            VStack {
                Spacer()
                ControlPanel(
                    inputText: $viewModel.inputText,
                    onSend: { viewModel.sendMessage() },
                    onVoiceSend: { url, duration in
                        viewModel.sendVoiceMessage(url: url, duration: duration)
                    }
                )
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $viewModel.showToolResult) {
            ToolResultView(
                title: viewModel.toolTitle,
                content: viewModel.toolResultContent,
                showMoreButton: !viewModel.isDetailedAnalysis && viewModel.toolTitle == "语法精讲",
                onMore: {
                    if let msg = viewModel.selectedMessageForTools {
                        viewModel.analyzeGrammar(message: msg, detailed: true)
                    }
                }
            )
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showUserProfile) {
            UserProfileView(onLogout: {
                viewModel.logout()
                showUserProfile = false
            })
            .presentationDetents([.fraction(0.5)])
        }
        .applyTranslation(isPresented: $viewModel.showSystemTranslation, text: viewModel.textToTranslate)
    }
}

// MARK: - Compatibility Extensions
extension View {
    @ViewBuilder
    func applyTranslation(isPresented: Binding<Bool>, text: String) -> some View {
        if #available(iOS 17.4, *) {
            self.translationPresentation(isPresented: isPresented, text: text)
        } else {
            self
        }
    }
}

struct MessageBubbleView: View {
    let message: Message
    @ObservedObject private var audioManager = AudioPlayerManager.shared
    var onTranslate: (() -> Void)? = nil
    var onAnalyze: (() -> Void)? = nil
    var onPlay: (() -> Void)? = nil
    var onReport: (() -> Void)? = nil
    var onRetry: (() -> Void)? = nil
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.sender == .user { Spacer() }
            
            VStack(alignment: message.sender == .user ? .trailing : .leading, spacing: 4) {
                HStack(alignment: .bottom, spacing: 8) {
                    if message.sender == .ai {
                        playbackIcon
                    }
                    
                    if message.sender == .user && message.status == .failed {
                        Button(action: { onRetry?() }) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 20))
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Group {
                        if message.type == .audio {
                            audioContent
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(message.sender == .user ? DesignSystem.Colors.accent.opacity(0.9) : .white.opacity(0.1))
                                )
                                .foregroundColor(.white)
                        } else {
                            textContent
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(message.sender == .user ? DesignSystem.Colors.accent.opacity(0.9) : Color.white.opacity(0.1))
                                        .background(
                                            ZStack {
                                                if message.sender == .ai {
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .fill(.ultraThinMaterial)
                                                }
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                                            }
                                        )
                                )
                                .foregroundColor(message.sender == .user ? .white : .white.opacity(0.9))
                        }
                    }
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .onTapGesture {
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
                        
                        Divider()
                        
                        Button(role: .destructive, action: { onReport?() }) {
                            Label("反馈内容问题", systemImage: "exclamationmark.bubble")
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
                onPlay?()
            }) {
                ZStack {
                    if audioManager.playingMessageId == message.id && audioManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: audioManager.playingMessageId == message.id && audioManager.isPlaying ? "speaker.wave.2.fill" : "speaker.wave.2")
                            .font(.system(size: 14))
                            .foregroundColor(DesignSystem.Colors.accent)
                    }
                }
                .frame(width: 32, height: 32)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .scaleEffect(audioManager.playingMessageId == message.id && audioManager.isPlaying ? 1.2 : 1.0)
            }
            .buttonStyle(.plain)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: audioManager.playingMessageId)
            .animation(.spring(), value: audioManager.isLoading)
        }
    }
    
    @ViewBuilder
    private var audioContent: some View {
        HStack(spacing: 6) {
            if audioManager.playingMessageId == message.id && audioManager.isLoading {
                ProgressView()
                    .scaleEffect(0.6)
                    .frame(width: 14)
            } else {
                Image(systemName: "waveform")
                    .opacity(audioManager.playingMessageId == message.id && audioManager.isPlaying ? 0.5 : 1.0)
                    .animation(audioManager.playingMessageId == message.id && audioManager.isPlaying ? Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .default, value: audioManager.isPlaying)
            }
            Text(String(format: "%ds", Int(message.audioDuration ?? 0)))
                .font(.caption)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }
    
    private var textContent: some View {
        Text(message.content)
            .font(DesignSystem.Fonts.body(size: 17))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
    }
}

struct ToolResultView: View {
    let title: String
    let content: String
    var showMoreButton: Bool = false
    var onMore: (() -> Void)? = nil
    
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
                VStack(alignment: .leading, spacing: 16) {
                    Text(content)
                        .font(DesignSystem.Fonts.body(size: 16))
                        .lineSpacing(8)
                        .foregroundColor(.white.opacity(0.9))
                    
                    if showMoreButton {
                        Button(action: { onMore?() }) {
                            HStack {
                                Text("查看详细解析")
                                Image(systemName: "chevron.down.circle")
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(DesignSystem.Colors.accent)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(DesignSystem.Colors.accent.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(.top, 8)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom, 20)
            
            Spacer()
        }
        .padding(24)
        .background(DesignSystem.Colors.primary.ignoresSafeArea())
    }
}

struct ControlPanel: View {
    @Binding var inputText: String
    var onSend: () -> Void
    var onVoiceSend: (URL, TimeInterval) -> Void
    
    @StateObject private var audioRecorder = AudioRecorderManager.shared
    @State private var isRecording = false
    @State private var recordStartTime: Date?
    @State private var currentRecordingURL: URL?
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            // Voice Button
            if inputText.isEmpty {
                Button(action: {}) {
                    Image(systemName: isRecording ? "waveform.circle.fill" : "mic.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(isRecording ? .red : .white.opacity(0.8))
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(isRecording ? 0.2 : 0.1))
                        .clipShape(Circle())
                        .scaleEffect(isRecording ? 1.2 : 1.0)
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if !isRecording {
                                startRecording()
                            }
                        }
                        .onEnded { _ in
                            stopRecording()
                        }
                )
                .animation(.spring(), value: isRecording)
            }
            
            // Input Field
            TextField(isRecording ? "正在录音..." : "输入日语或中国语...", text: $inputText, axis: .vertical)
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
                .disabled(isRecording)
            
            // Send Button
            if !inputText.isEmpty {
                Button(action: onSend) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(DesignSystem.Colors.accent)
                        )
                        .shadow(color: DesignSystem.Colors.accent.opacity(0.3), radius: 10)
                }
                .transition(.scale)
            }
        }
        .padding(8)
        .background(.ultraThinMaterial)
        .cornerRadius(35)
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        .onAppear {
            audioRecorder.requestPermission()
        }
    }
    
    private func startRecording() {
        isRecording = true
        recordStartTime = Date()
        currentRecordingURL = audioRecorder.startRecording()
    }
    
    private func stopRecording() {
        isRecording = false
        audioRecorder.stopRecording()
        
        if let startTime = recordStartTime, let audioURL = currentRecordingURL {
            let duration = Date().timeIntervalSince(startTime)
            if duration > 1.0 { // Minimum duration
                onVoiceSend(audioURL, duration)
            }
        }
        recordStartTime = nil
        currentRecordingURL = nil
    }
}

struct UserProfileView: View {
    var onLogout: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background
            DesignSystem.Colors.primary
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Handle indicator
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 40, height: 4)
                    .padding(.top, 10)
                
                // Profile Info
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(DesignSystem.Colors.accent.opacity(0.1))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "person.fill")
                            .font(.system(size: 36))
                            .foregroundColor(DesignSystem.Colors.accent)
                    }
                    
                    VStack(spacing: 12) {
                        Text("Guest_User")
                            .font(DesignSystem.Fonts.heading(size: 20))
                            .foregroundColor(.white)
                        
                        Text("当前账号")
                            .font(DesignSystem.Fonts.body(size: 14))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                .padding(.top, 10)
                
                Spacer()
                
                // Logout Button
                Button(action: onLogout) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("退出登录")
                    }
                    .font(DesignSystem.Fonts.heading(size: 16))
                    .foregroundColor(DesignSystem.Colors.primary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.9)) // High contrast for danger/logout or use accent?
                    // Re-reading UI/UX: Accent is for core CTA. Logout is usually destructive.
                    // Let's use a subtle style for logout to look "Premium" but clear.
                    // Or keep it consistent with Login button style but maybe different color?
                    // Let's use Color.red for destructive but styled nicely.
                    // Actually, let's use a glass outline for a cleaner look or just a solid white/accent.
                    // User requested consistency. Login button is Accent background.
                    // Let's make this one Red background for clarity, or Dark Grey.
                    // Let's go with a specialized 'Destructive' style.
                    .background(Color(hex: "ef4444")) // Lucide Red-500 equivalent
                    .cornerRadius(20)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
                
                // Copyright / Version
                Text("MOJiTalk MVP v0.2")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.2))
                    .padding(.bottom, 10)
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
            .preferredColorScheme(.dark)
    }
}
