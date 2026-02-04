import SwiftUI

struct LoginView: View {
    @StateObject private var accountManager = AccountManager.shared
    @State private var account = ""
    @State private var password = ""
    @State private var isLoggingIn = false
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.primary
                .ignoresSafeArea()
            
            // Background Decorative Element
            Circle()
                .fill(DesignSystem.Colors.accent.opacity(0.1))
                .frame(width: 400, height: 400)
                .offset(x: 150, y: -250)
            
            VStack {
                Spacer()
                
                // Logo Section
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(DesignSystem.Colors.accent.opacity(0.2))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 45))
                            .foregroundColor(DesignSystem.Colors.accent)
                    }
                    
                    Text("MOJiTalk")
                        .font(DesignSystem.Fonts.heading(size: 36))
                        .foregroundColor(.white)
                    
                    Text("沉浸式日语口语对话")
                        .font(DesignSystem.Fonts.body(size: 16))
                        .foregroundColor(.gray)
                }
                .offset(y: isAnimating ? 0 : 30)
                .opacity(isAnimating ? 1 : 0)
                
                Spacer().frame(height: 60)
                
                // Input Fields
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                        TextField("", text: $account, prompt: Text("请输入账号").foregroundColor(.gray.opacity(0.5)))
                            .submitLabel(.next)
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                    
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                        SecureField("", text: $password, prompt: Text("请输入密码").foregroundColor(.gray.opacity(0.5)))
                            .submitLabel(.done)
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .foregroundColor(.white)
                .offset(y: isAnimating ? 0 : 30)
                .opacity(isAnimating ? 1 : 0)
                
                Spacer().frame(height: 40)
                
                // Login Button
                Button(action: {
                    guard !account.isEmpty else { return }
                    isLoggingIn = true
                    accountManager.login(account: account)
                }) {
                    HStack {
                        if isLoggingIn {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: DesignSystem.Colors.primary))
                                .padding(.right, 10)
                        }
                        
                        Text(isLoggingIn ? "正在登录..." : "登 录")
                    }
                    .font(DesignSystem.Fonts.heading(size: 18))
                    .foregroundColor(DesignSystem.Colors.primary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(DesignSystem.Colors.accent)
                    .cornerRadius(30)
                    .shadow(color: DesignSystem.Colors.accent.opacity(0.4), radius: 10, x: 0, y: 5)
                }
                .disabled(account.isEmpty || isLoggingIn)
                .padding(.horizontal, 40)
                .offset(y: isAnimating ? 0 : 30)
                .opacity(isAnimating ? 1 : 0)
                
                Spacer()
                
                Text("MVP v0.2 | Secure Storage Enabled")
                    .font(.caption2)
                    .foregroundColor(.gray.opacity(0.4))
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
