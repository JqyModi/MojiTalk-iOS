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
            Text(LocalizedString.Login.statsPrefix)
                .font(DesignSystem.Fonts.body(size: 18))
                .foregroundColor(.white.opacity(0.6))
            
            Text(formattedNumber)
                .font(DesignSystem.Fonts.heading(size: 20))
                .foregroundColor(DesignSystem.Colors.accent)
                .monospacedDigit() // Ensures consistent width for smooth animation
                .contentTransition(.numericText())
            
            Text(LocalizedString.Login.statsSuffix)
                .font(DesignSystem.Fonts.body(size: 18))
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
        LocalizedString.Login.welcome1,
        LocalizedString.Login.welcome2,
        LocalizedString.Login.welcome3,
        LocalizedString.Login.welcome4,
        LocalizedString.Login.welcome5
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
    @State private var showContactSupport = false
    
    private let faqs: [(question: String, answer: String)] = [
        (
            question: LocalizedString.LoginHelp.faq1Question,
            answer: LocalizedString.LoginHelp.faq1Answer
        ),
        (
            question: LocalizedString.LoginHelp.faq2Question,
            answer: LocalizedString.LoginHelp.faq2Answer
        ),
        (
            question: LocalizedString.LoginHelp.faq3Question,
            answer: LocalizedString.LoginHelp.faq3Answer
        ),
        (
            question: LocalizedString.LoginHelp.faq4Question,
            answer: LocalizedString.LoginHelp.faq4Answer
        ),
        (
            question: LocalizedString.LoginHelp.faq5Question,
            answer: LocalizedString.LoginHelp.faq5Answer
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
                            Text(LocalizedString.LoginHelp.title)
                                .font(DesignSystem.Fonts.heading(size: 28))
                                .foregroundColor(.white)
                            
                            Text(LocalizedString.LoginHelp.subtitle)
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
                                Text(LocalizedString.LoginHelp.stillNeedHelp)
                                    .font(DesignSystem.Fonts.heading(size: 18))
                                    .foregroundColor(.white)
                                
                                Button(action: { showContactSupport = true }) {
                                    HStack {
                                        Image(systemName: "envelope.fill")
                                        Text(LocalizedString.LoginHelp.contactSupport)
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
            .sheet(isPresented: $showContactSupport) {
                ContactSupportView()
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
