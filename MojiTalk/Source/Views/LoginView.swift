import SwiftUI

struct LoginView: View {
    @StateObject private var accountManager = AccountManager.shared
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.primary
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Logo / Brand
                VStack(spacing: 16) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 60))
                        .foregroundColor(DesignSystem.Colors.accent)
                    
                    Text("MOJiTalk")
                        .font(DesignSystem.Fonts.heading(size: 32))
                        .foregroundColor(.white)
                    
                    Text("沉浸式日语口语对话")
                        .font(DesignSystem.Fonts.body(size: 16))
                        .foregroundColor(.gray)
                }
                .offset(y: isAnimating ? 0 : 20)
                .opacity(isAnimating ? 1 : 0)
                
                Spacer()
                
                // Login Button
                Button(action: {
                    withAnimation {
                        accountManager.login()
                    }
                }) {
                    Text("开始体验 (Login)")
                        .font(DesignSystem.Fonts.heading(size: 18))
                        .foregroundColor(DesignSystem.Colors.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(DesignSystem.Colors.accent)
                        .cornerRadius(30)
                        .shadow(color: DesignSystem.Colors.accent.opacity(0.4), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 40)
                .offset(y: isAnimating ? 0 : 20)
                .opacity(isAnimating ? 1 : 0)
                
                Text("MVP v0.1")
                    .font(.caption)
                    .foregroundColor(.gray.opacity(0.5))
                    .padding(.bottom, 20)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
