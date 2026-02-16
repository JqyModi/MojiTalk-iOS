import SwiftUI

/// Animated rolling number display for statistics
struct RollingNumberView: View {
    @State private var displayedNumber: Int
    @State private var timer: Timer?
    
    let baseNumber: Int = Int.random(in: 100_000...150_000) // Random base around 100k
    
    init() {
        _displayedNumber = State(initialValue: Int.random(in: 100_000...150_000))
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Text("已累计产生")
                .font(DesignSystem.Fonts.body(size: 14))
                .foregroundColor(.white.opacity(0.6))
            
            Text(formattedNumber)
                .font(DesignSystem.Fonts.heading(size: 16))
                .foregroundColor(DesignSystem.Colors.accent)
                .monospacedDigit() // Ensures consistent width for smooth animation
                .contentTransition(.numericText())
            
            Text("次练习")
                .font(DesignSystem.Fonts.body(size: 14))
                .foregroundColor(.white.opacity(0.6))
        }
        .onAppear {
            startRolling()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var formattedNumber: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: displayedNumber)) ?? "\(displayedNumber)"
    }
    
    private func startRolling() {
        // Increment by random 1-20 every 3-5 seconds
        timer = Timer.scheduledTimer(withTimeInterval: Double.random(in: 3...5), repeats: true) { _ in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                displayedNumber += Int.random(in: 1...20)
            }
        }
    }
}

/// Animated welcome message carousel
struct WelcomeMessageView: View {
    @State private var currentIndex = 0
    @State private var timer: Timer?
    
    private let messages = [
        "Ready to learn!",
        "欢迎使用可呆口语！",
        "日本語を話しましょう！",
        "Let's practice together!",
        "一緒に頑張りましょう！"
    ]
    
    var body: some View {
        Text(messages[currentIndex])
            .font(DesignSystem.Fonts.heading(size: 18))
            .foregroundColor(.white.opacity(0.8))
            .id(currentIndex) // Force view recreation for animation
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            .onAppear {
                startCarousel()
            }
            .onDisappear {
                timer?.invalidate()
            }
    }
    
    private func startCarousel() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentIndex = (currentIndex + 1) % messages.count
            }
        }
    }
}

/// Help FAQ sheet
struct LoginHelpView: View {
    @Environment(\.dismiss) var dismiss
    
    private let faqs: [(question: String, answer: String)] = [
        (
            question: "收不到验证码怎么办？",
            answer: "1. 请检查邮箱地址是否正确\n2. 查看垃圾邮件文件夹\n3. 等待 1-2 分钟后重试\n4. 如仍未收到，请联系客服"
        ),
        (
            question: "Apple 登录失败？",
            answer: "1. 确保您的设备已登录 Apple ID\n2. 检查网络连接是否正常\n3. 在设置中允许 MOJiTalk 使用 Apple 登录\n4. 重启应用后重试"
        ),
        (
            question: "验证码过期了？",
            answer: "验证码有效期为 10 分钟。如果过期，请返回登录页重新获取新的验证码。"
        ),
        (
            question: "如何切换账号？",
            answer: "在个人中心点击"退出登录"，然后使用新的邮箱或 Apple ID 登录即可。"
        ),
        (
            question: "忘记注册邮箱？",
            answer: "如果您使用 Apple 登录，可以在 Apple ID 设置中查看关联的邮箱。如果使用邮箱注册，请尝试常用邮箱地址。"
        )
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.Colors.primary
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("登录帮助")
                                .font(DesignSystem.Fonts.heading(size: 28))
                                .foregroundColor(.white)
                            
                            Text("遇到登录问题？查看以下常见解决方案")
                                .font(DesignSystem.Fonts.body(size: 14))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.top, 20)
                        
                        // FAQ List
                        ForEach(Array(faqs.enumerated()), id: \.offset) { index, faq in
                            FAQItemView(question: faq.question, answer: faq.answer)
                        }
                        
                        // Contact Support
                        VStack(spacing: 16) {
                            Divider()
                                .background(Color.white.opacity(0.2))
                            
                            VStack(spacing: 12) {
                                Text("仍需帮助？")
                                    .font(DesignSystem.Fonts.heading(size: 18))
                                    .foregroundColor(.white)
                                
                                Button(action: {
                                    // Open email client
                                    if let url = URL(string: "mailto:support@mojikaiwa.com?subject=登录问题咨询") {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "envelope.fill")
                                        Text("联系客服")
                                    }
                                    .font(DesignSystem.Fonts.heading(size: 16))
                                    .foregroundColor(DesignSystem.Colors.primary)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(DesignSystem.Colors.accent)
                                    .cornerRadius(16)
                                }
                            }
                            .padding(.vertical, 12)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct FAQItemView: View {
    let question: String
    let answer: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundColor(DesignSystem.Colors.accent)
                    
                    Text(question)
                        .font(DesignSystem.Fonts.heading(size: 16))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white.opacity(0.4))
                        .font(.system(size: 14, weight: .semibold))
                }
            }
            
            if isExpanded {
                Text(answer)
                    .font(DesignSystem.Fonts.body(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.leading, 32)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

// MARK: - Previews
struct LoginHelpView_Previews: PreviewProvider {
    static var previews: some View {
        LoginHelpView()
    }
}

struct RollingNumberView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            RollingNumberView()
        }
    }
}
