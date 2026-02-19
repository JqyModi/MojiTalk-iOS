import SwiftUI

// MARK: - Legal Document Viewer

/// In-app viewer for legal documents (Terms of Service, Privacy Policy).
/// Renders Markdown content in a styled sheet — no external links needed.
struct LegalDocumentView: View {
    let title: String
    let markdownContent: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.Colors.primary.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Render each line of the markdown
                        ForEach(Array(parseMarkdown().enumerated()), id: \.offset) { _, item in
                            item.view
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Markdown Parsing
    
    private struct MarkdownItem {
        let view: AnyView
    }
    
    private func parseMarkdown() -> [MarkdownItem] {
        let lines = markdownContent.components(separatedBy: "\n")
        var items: [MarkdownItem] = []
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if trimmed.isEmpty {
                // Spacer between paragraphs
                items.append(MarkdownItem(view: AnyView(Spacer().frame(height: 4))))
            } else if trimmed.hasPrefix("# ") {
                // H1 Title
                let text = String(trimmed.dropFirst(2))
                items.append(MarkdownItem(view: AnyView(
                    Text(text)
                        .font(DesignSystem.Fonts.heading(size: 24))
                        .foregroundColor(.white)
                        .padding(.bottom, 4)
                )))
            } else if trimmed.hasPrefix("## ") {
                // H2 Section Header
                let text = String(trimmed.dropFirst(3))
                items.append(MarkdownItem(view: AnyView(
                    Text(text)
                        .font(DesignSystem.Fonts.heading(size: 18))
                        .foregroundColor(DesignSystem.Colors.accent)
                        .padding(.top, 8)
                )))
            } else if trimmed.hasPrefix("**") && trimmed.hasSuffix("**") {
                // Bold line (like dates)
                let text = trimmed.replacingOccurrences(of: "**", with: "")
                items.append(MarkdownItem(view: AnyView(
                    Text(text)
                        .font(DesignSystem.Fonts.body(size: 13))
                        .foregroundColor(.white.opacity(0.5))
                        .italic()
                )))
            } else if trimmed.hasPrefix("- ") {
                // Bullet point
                let text = String(trimmed.dropFirst(2))
                items.append(MarkdownItem(view: AnyView(
                    HStack(alignment: .top, spacing: 10) {
                        Text("•")
                            .font(DesignSystem.Fonts.body(size: 14))
                            .foregroundColor(DesignSystem.Colors.accent)
                        parseBoldText(text)
                            .font(DesignSystem.Fonts.body(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.leading, 8)
                )))
            } else {
                // Regular paragraph
                items.append(MarkdownItem(view: AnyView(
                    parseBoldText(trimmed)
                        .font(DesignSystem.Fonts.body(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                )))
            }
        }
        
        return items
    }
    
    /// Parse inline **bold** text within a line
    private func parseBoldText(_ text: String) -> Text {
        let parts = text.components(separatedBy: "**")
        var result = Text("")
        for (index, part) in parts.enumerated() {
            if index % 2 == 1 {
                // Bold part
                result = result + Text(part).bold().foregroundColor(.white)
            } else {
                result = result + Text(part)
            }
        }
        return result
    }
}

// MARK: - Preloaded Legal Content

enum LegalContent {
    
    static let userAgreement: String = """
# MOJiTalk 用户协议

**最后更新：2026年2月6日**

使用 MOJiTalk 即表示您同意以下条款和条件。

## 1. 接受条款
访问或使用 MOJiTalk，即表示您同意受本协议和我们的隐私政策约束。

## 2. 服务说明
MOJiTalk 是一款基于 AI 的日语学习助手。服务包括基于聊天的互动、Live2D 角色可视化、翻译和语法分析。

## 3. 用户行为规范
- 您同意不将本服务用于任何非法或未经授权的目的。
- 您不得试图中断服务或绕过任何安全功能。
- 您有责任维护您账户的机密性。

## 4. AI 内容免责声明
MOJiTalk 使用人工智能生成回复。虽然我们力求准确，但 AI 生成的内容可能包含错误或不准确之处。我们不对基于 AI 输出所做的任何决定承担责任。

## 5. 终止
如果您违反本协议，我们保留暂停或终止您账户的权利。

## 6. 责任限制
MOJiTalk 按"原样"提供，不附带任何保证。我们不对因您使用本服务而产生的任何间接或附带损害承担责任。

## 7. 协议变更
我们可能会不时更新本协议。您在变更后继续使用本应用即表示接受新条款。

## 8. 适用法律
本协议受开发者所在司法管辖区的法律管辖。
"""
    
    static let userAgreementEN: String = """
# MOJiTalk User Agreement

**Last Updated: February 6, 2026**

By using MOJiTalk, you agree to the following terms and conditions.

## 1. Acceptance of Terms
By accessing or using MOJiTalk, you agree to be bound by this Agreement and our Privacy Policy.

## 2. Description of Service
MOJiTalk is an AI-powered Japanese language learning assistant. The service includes chat-based interaction, Live2D character visualization, translation, and grammar analysis.

## 3. User Conduct
- You agree not to use the service for any illegal or unauthorized purpose.
- You must not attempt to disrupt the service or bypass any security features.
- You are responsible for maintaining the confidentiality of your account.

## 4. AI Content Disclaimer
MOJiTalk uses artificial intelligence to generate responses. While we strive for accuracy, AI-generated content may contain errors or inaccuracies. We are not responsible for any decisions made based on AI output.

## 5. Termination
We reserve the right to suspend or terminate your account if you violate this Agreement.

## 6. Limitation of Liability
MOJiTalk is provided "as is" without any warranties. We are not liable for any indirect or consequential damages arising from your use of the service.

## 7. Changes to Agreement
We may update this Agreement from time to time. Your continued use of the app after changes constitutes acceptance of the new terms.

## 8. Governing Law
This Agreement is governed by the laws of the jurisdiction in which the developer is located.
"""
    
    static let privacyPolicy: String = """
# MOJiTalk 隐私政策

**生效日期：2026年2月6日**

欢迎使用 MOJiTalk。我们致力于保护您的隐私。本隐私政策说明了我们在您使用本应用时如何收集、使用和保护您的信息。

## 1. 我们收集的信息
- **账户信息**：当您登录时，我们存储您的用户名和认证令牌以提供会话连续性。
- **消息内容**：我们处理您的消息和语音输入以生成 AI 回复。此数据通过我们安全的 AI 合作伙伴处理。
- **语音数据**：如果您使用语音消息，我们会临时处理音频以将其转换为文字。
- **本地存储**：我们在您的设备上本地存储您的聊天记录，以方便您使用。

## 2. 我们如何使用信息
- 提供 AI 对话和语言学习功能。
- 改进我们的翻译和语法分析工具。
- 确保符合 App Store 指南（例如内容举报）。

## 3. 数据共享
我们不会出售您的个人数据。您的消息内容仅为了生成回复而发送给我们的 AI 服务提供商。

## 4. 您的权利
- **访问和导出**：您可以在应用内查看您的聊天记录。
- **删除**：您可以随时通过应用中的"注销账户"功能删除您的账户和所有相关本地数据。

## 5. 安全性
我们采用行业标准安全措施来保护您的数据在传输和存储过程中的安全。

## 6. 联系我们
如果您对本隐私政策有任何疑问，请通过以下方式联系我们：jqy.tieniu@gmail.com
"""
    
    static let privacyPolicyEN: String = """
# MOJiTalk Privacy Policy

**Effective Date: February 6, 2026**

Welcome to MOJiTalk. We are committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our application.

## 1. Information We Collect
- **Account Information**: When you log in, we store your username and authentication tokens to provide session continuity.
- **Message Content**: We process your messages and voice inputs to generate AI responses. This data is handled through our secure AI partner.
- **Voice Data**: If you use voice messaging, we temporarily process the audio to convert it to text.
- **Local Storage**: We store your chat history locally on your device for your convenience.

## 2. How We Use Information
- To provide the AI conversation and language learning features.
- To improve our translation and grammar analysis tools.
- To ensure compliance with App Store guidelines (e.g., content reporting).

## 3. Data Sharing
We do not sell your personal data. Your message content is sent to our AI service provider solely for the purpose of generating responses.

## 4. Your Rights
- **Access and Export**: You can view your chat history within the app.
- **Deletion**: You can delete your account and all associated local data at any time through the "Delete Account" feature in the app.

## 5. Security
We implement industry-standard security measures to protect your data during transmission and storage.

## 6. Contact Us
If you have any questions about this Privacy Policy, please contact us at: jqy.tieniu@gmail.com
"""
    
    /// Get the user agreement based on current language
    static var currentUserAgreement: String {
        let code = LanguageManager.shared.activeCode
        return code == "en" ? userAgreementEN : userAgreement
    }
    
    /// Get the privacy policy based on current language
    static var currentPrivacyPolicy: String {
        let code = LanguageManager.shared.activeCode
        return code == "en" ? privacyPolicyEN : privacyPolicy
    }
}

// MARK: - Contact Support View

/// A styled "contact us" sheet with pre-filled email options
struct ContactSupportView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let supportEmail = "jqy.tieniu@gmail.com"
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.Colors.primary.ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Illustration
                    VStack(spacing: 16) {
                        Image(systemName: "headphones.circle.fill")
                            .font(.system(size: 72))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [DesignSystem.Colors.accent, DesignSystem.Colors.accent.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text(L("support.title", "联系我们"))
                            .font(DesignSystem.Fonts.heading(size: 24))
                            .foregroundColor(.white)
                        
                        Text(L("support.subtitle", "我们通常在 24 小时内回复"))
                            .font(DesignSystem.Fonts.body(size: 14))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.top, 40)
                    
                    // Email option cards
                    VStack(spacing: 12) {
                        // Login help email
                        supportOptionCard(
                            icon: "key.fill",
                            title: L("support.loginIssue", "登录问题"),
                            subtitle: L("support.loginIssueDesc", "无法登录、收不到验证码等"),
                            subject: "MOJiTalk 登录问题"
                        )
                        
                        // Bug report
                        supportOptionCard(
                            icon: "ladybug.fill",
                            title: L("support.bugReport", "问题反馈"),
                            subtitle: L("support.bugReportDesc", "应用崩溃、功能异常等"),
                            subject: "MOJiTalk 问题反馈"
                        )
                        
                        // Feature request / Other
                        supportOptionCard(
                            icon: "lightbulb.fill",
                            title: L("support.suggestion", "功能建议"),
                            subtitle: L("support.suggestionDesc", "希望增加的功能或改进建议"),
                            subject: "MOJiTalk 功能建议"
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // Email directly
                    VStack(spacing: 8) {
                        Text(L("support.directEmail", "或直接发送邮件至"))
                            .font(DesignSystem.Fonts.body(size: 12))
                            .foregroundColor(.white.opacity(0.4))
                        
                        Button(action: { openMail(subject: "MOJiTalk Feedback") }) {
                            Text(supportEmail)
                                .font(DesignSystem.Fonts.body(size: 14))
                                .foregroundColor(DesignSystem.Colors.accent)
                                .underline()
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    @ViewBuilder
    private func supportOptionCard(icon: String, title: String, subtitle: String, subject: String) -> some View {
        Button(action: { openMail(subject: subject) }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(DesignSystem.Colors.accent)
                    .frame(width: 44, height: 44)
                    .background(DesignSystem.Colors.accent.opacity(0.15))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(DesignSystem.Fonts.heading(size: 16))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(DesignSystem.Fonts.body(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Spacer()
                
                Image(systemName: "envelope.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(16)
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
    
    private func openMail(subject: String) {
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? subject
        if let url = URL(string: "mailto:\(supportEmail)?subject=\(encodedSubject)") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Previews

#Preview("Legal Document") {
    LegalDocumentView(
        title: "用户协议",
        markdownContent: LegalContent.userAgreement
    )
}

#Preview("Contact Support") {
    ContactSupportView()
}
