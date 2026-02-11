import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @StateObject private var accountManager = AccountManager.shared
    @State private var email = ""
    @State private var otpCode = ""
    @State private var isLoggingIn = false
    @State private var isAnimating = false
    @State private var showingOTPInput = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.primary
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { hideKeyboard() }
            
            // Background Decorative Element
            Circle()
                .fill(DesignSystem.Colors.accent.opacity(0.1))
                .frame(width: 400, height: 400)
                .offset(x: 150, y: -250)
            
            VStack(spacing: 0) {
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
                    if !showingOTPInput {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.gray)
                            TextField("", text: $email, prompt: Text("请输入注册邮箱").foregroundColor(.gray.opacity(0.5)))
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .submitLabel(.done)
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                    } else {
                        HStack {
                            Image(systemName: "number")
                                .foregroundColor(.gray)
                            TextField("", text: $otpCode, prompt: Text("请输入 6 位验证码").foregroundColor(.gray.opacity(0.5)))
                                .keyboardType(.numberPad)
                                .submitLabel(.done)
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 40)
                .foregroundColor(.white)
                .offset(y: isAnimating ? 0 : 30)
                .opacity(isAnimating ? 1 : 0)
                
                Spacer().frame(height: 40)
                
                // Multi-Login Buttons
                VStack(spacing: 16) {
                    // 1. Primary Action (Send OTP / Login OTP)
                    Button(action: {
                        if !showingOTPInput {
                            handleSendOTP()
                        } else {
                            handleVerifyOTP()
                        }
                    }) {
                        HStack(spacing: 12) {
                            if isLoggingIn {
                                LiquidLoadingView(color: DesignSystem.Colors.primary)
                            }
                            Text(showingOTPInput ? "验证并登录" : "获取验证码")
                                .font(DesignSystem.Fonts.heading(size: 18))
                        }
                        .foregroundColor(DesignSystem.Colors.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(DesignSystem.Colors.accent)
                        .cornerRadius(30)
                        .shadow(color: DesignSystem.Colors.accent.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .disabled(email.isEmpty || isLoggingIn)
                    
                    if showingOTPInput {
                        Button(action: { showingOTPInput = false }) {
                            Text("返回输入邮箱")
                                .font(DesignSystem.Fonts.body(size: 14))
                                .foregroundColor(DesignSystem.Colors.accent)
                        }
                    }
                    
                    // 2. OR Divider
                    if !showingOTPInput {
                        HStack {
                            VStack { Divider().background(Color.white.opacity(0.2)) }
                            Text("或")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 8)
                            VStack { Divider().background(Color.white.opacity(0.2)) }
                        }
                        .padding(.vertical, 10)
                        
                        // 3. Apple Login
                        SignInWithAppleButton(.signIn) { request in
                            request.requestedScopes = [.fullName, .email]
                        } onCompletion: { result in
                            handleAppleLogin(result: result)
                        }
                        .signInWithAppleButtonStyle(.white)
                        .frame(height: 56)
                        .cornerRadius(30)
                    }
                }
                .padding(.horizontal, 40)
                .offset(y: isAnimating ? 0 : 30)
                .opacity(isAnimating ? 1 : 0)
                
                Spacer()
                
                legalTermsView
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
        }
        .alert("登录失败", isPresented: $showError) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "发生未知错误")
        }
        .preferredColorScheme(.dark)
    }
    
    private var legalTermsView: some View {
        VStack(spacing: 12) {
            VStack(spacing: 4) {
                Text("登录即代表您已同意")
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                HStack(spacing: 4) {
                    Link("《用户协议》", destination: URL(string: "https://www.mojikaiwa.com/terms")!)
                    Text("与")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Link("《隐私政策》", destination: URL(string: "https://www.mojikaiwa.com/privacy")!)
                }
            }
            
            Text("PRO VERSION | Powered by Supabase")
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.2))
        }
        .font(.caption2)
        .foregroundColor(DesignSystem.Colors.accent)
        .padding(.bottom, 60)
        .offset(y: isAnimating ? 0 : 30)
        .opacity(isAnimating ? 1 : 0)
    }
    
    // MARK: - Handlers
    
    private func handleSendOTP() {
        isLoggingIn = true
        Task {
            do {
                try await accountManager.sendOTP(email: email)
                await MainActor.run {
                    isLoggingIn = false
                    showingOTPInput = true
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isLoggingIn = false
                }
            }
        }
    }
    
    private func handleVerifyOTP() {
        isLoggingIn = true
        Task {
            do {
                try await accountManager.verifyOTP(email: email, token: otpCode)
                // Success is handled by listener in AccountManager
            } catch {
                await MainActor.run {
                    errorMessage = "验证码错误或已过期"
                    showError = true
                    isLoggingIn = false
                }
            }
        }
    }
    
    private func handleAppleLogin(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let appleIDCredential = auth.credential as? ASAuthorizationAppleIDCredential,
               let idTokenData = appleIDCredential.identityToken,
               let idToken = String(data: idTokenData, encoding: .utf8) {
                
                Task {
                    do {
                        try await accountManager.signInWithApple(idToken: idToken, nonce: nil)
                    } catch {
                        await MainActor.run {
                            errorMessage = error.localizedDescription
                            showError = true
                        }
                    }
                }
            }
        case .failure(let error):
            print("Apple Login Failed: \(error.localizedDescription)")
            // User likely cancelled
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
