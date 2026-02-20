import Foundation
import SwiftUI
import Combine

// MARK: - Supported Languages

enum AppLanguage: String, CaseIterable, Identifiable {
    case system   = "system"
    case chinese  = "zh-Hans"
    case english  = "en"
    case japanese = "ja"
    case korean   = "ko"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .system:   return "跟随系统"
        case .chinese:  return "简体中文"
        case .english:  return "English"
        case .japanese: return "日本語"
        case .korean:   return "한국어"
        }
    }
    
    var flag: String {
        switch self {
        case .system:   return "🌐"
        case .chinese:  return "🇨🇳"
        case .english:  return "🇺🇸"
        case .japanese: return "🇯🇵"
        case .korean:   return "🇰🇷"
        }
    }
    
    /// Returns the language code to use for translation lookup.
    /// For `.system`, resolves to the current system language.
    var resolvedCode: String {
        switch self {
        case .system:
            let preferred = Locale.preferredLanguages.first ?? "zh-Hans"
            if preferred.hasPrefix("en") { return "en" }
            if preferred.hasPrefix("ja") { return "ja" }
            if preferred.hasPrefix("ko") { return "ko" }
            if preferred.hasPrefix("zh") { return "zh-Hans" }
            return "zh-Hans" // default fallback
        default:
            return self.rawValue
        }
    }
}

// MARK: - Language Manager

/// Manages app-wide language selection with real-time SwiftUI updates.
///
/// Uses an embedded translation dictionary — no .lproj files required.
/// Changes take effect immediately without restarting the app.
///
/// Usage:
///   @ObservedObject var langManager = LanguageManager.shared
///   Text(L("login.button.getCode", "获取验证码"))
final class LanguageManager: ObservableObject {
    
    static let shared = LanguageManager()
    
    private let userDefaultsKey = "app_selected_language"
    
    /// Currently selected language. Changing this triggers UI refresh.
    @Published private(set) var currentLanguage: AppLanguage
    
    /// The resolved language code currently in use
    private(set) var activeCode: String
    
    private init() {
        let saved = UserDefaults.standard.string(forKey: "app_selected_language") ?? "system"
        let lang = AppLanguage(rawValue: saved) ?? .system
        self.currentLanguage = lang
        self.activeCode = lang.resolvedCode
    }
    
    // MARK: - Public API
    
    /// Switch to a new language. All views observing LanguageManager will update instantly.
    func setLanguage(_ language: AppLanguage) {
        guard language != currentLanguage else { return }
        currentLanguage = language
        activeCode = language.resolvedCode
        UserDefaults.standard.set(language.rawValue, forKey: userDefaultsKey)
        
        // Force SwiftUI to re-render all views
        objectWillChange.send()
    }
    
    /// Localize a string key using the built-in translation dictionary.
    func string(_ key: String, default defaultValue: String) -> String {
        // Look up in the embedded translations
        if let langDict = TranslationDictionary.translations[activeCode],
           let value = langDict[key] {
            return value
        }
        // Fallback: try zh-Hans
        if let zhDict = TranslationDictionary.translations["zh-Hans"],
           let value = zhDict[key] {
            return value
        }
        // Ultimate fallback: use the provided default
        return defaultValue
    }
}

// MARK: - Convenience Global Function

/// Shorthand for `LanguageManager.shared.string(_:default:)`.
/// Usage: `Text(L("login.title", "OpenTalk"))`
func L(_ key: String, _ defaultValue: String) -> String {
    LanguageManager.shared.string(key, default: defaultValue)
}

// MARK: - SwiftUI Environment Key

private struct LanguageManagerKey: EnvironmentKey {
    static let defaultValue: LanguageManager = .shared
}

extension EnvironmentValues {
    var languageManager: LanguageManager {
        get { self[LanguageManagerKey.self] }
        set { self[LanguageManagerKey.self] = newValue }
    }
}

// MARK: - Embedded Translation Dictionary

/// All translations stored in code — no .lproj files needed.
/// This ensures language switching works reliably regardless of Xcode build configuration.
enum TranslationDictionary {
    
    static let translations: [String: [String: String]] = [
        "zh-Hans": zhHans,
        "en": en,
        "ja": ja,
        "ko": ko,
    ]
    
    // MARK: - 简体中文
    static let zhHans: [String: String] = [
        // Login
        "login.title": "OpenTalk",
        "login.subtitle": "沉浸式日语口语对话",
        "login.email.placeholder": "请输入注册邮箱",
        "login.otp.placeholder": "请输入 6 位验证码",
        "login.button.getCode": "获取验证码",
        "login.button.verify": "验证并登录",
        "login.button.back": "返回输入邮箱",
        "login.divider.or": "或",
        "login.terms.agree": "登录即代表您已同意",
        "login.terms.service": "《用户协议》",
        "login.terms.and": "与",
        "login.terms.privacy": "《隐私政策》",
        "login.error.title": "登录失败",
        "login.error.unknown": "发生未知错误",
        "login.error.otpExpired": "验证码错误或已过期",
        "login.stats.prefix": "已累计产生",
        "login.stats.suffix": "次练习",
        "login.welcome.1": "Ready to learn!",
        "login.welcome.2": "欢迎使用OpenTalk！",
        "login.welcome.3": "日本語を話しましょう！",
        "login.welcome.4": "Let's practice together!",
        "login.welcome.5": "一緒に頑張りましょう！",
        
        // Login Help
        "loginHelp.title": "登录帮助",
        "loginHelp.subtitle": "遇到登录问题？查看以下常见解决方案",
        "loginHelp.stillNeedHelp": "仍需帮助？",
        "loginHelp.contactSupport": "联系客服",
        "loginHelp.faq1.question": "收不到验证码怎么办？",
        "loginHelp.faq1.answer": "1. 请检查邮箱地址是否正确\n2. 查看垃圾邮件文件夹\n3. 等待 1-2 分钟后重试\n4. 如仍未收到，请联系客服",
        "loginHelp.faq2.question": "Apple 登录失败？",
        "loginHelp.faq2.answer": "1. 确保您的设备已登录 Apple ID\n2. 检查网络连接是否正常\n3. 在设置中允许 OpenTalk 使用 Apple 登录\n4. 重启应用后重试",
        "loginHelp.faq3.question": "验证码过期了？",
        "loginHelp.faq3.answer": "验证码有效期为 10 分钟。如果过期，请返回登录页重新获取新的验证码。",
        "loginHelp.faq4.question": "如何切换账号？",
        "loginHelp.faq4.answer": "在个人中心点击\"退出登录\"，然后使用新的邮箱或 Apple ID 登录即可。",
        "loginHelp.faq5.question": "忘记注册邮箱？",
        "loginHelp.faq5.answer": "如果您使用 Apple 登录，可以在 Apple ID 设置中查看关联的邮箱。如果使用邮箱注册，请尝试常用邮箱地址。",
        
        // Chat
        "chat.input.placeholder": "输入消息...",
        "chat.input.recording": "正在录音...",
        "chat.loading": "召唤中...",
        "chat.menu.translate": "翻译",
        "chat.menu.analyze": "语法精讲",
        "chat.menu.report": "举报",
        "chat.menu.retry": "重试",
        "chat.menu.copy": "复制",
        "chat.detailedAnalysis": "查看详细解析",
        "chat.grammarTitle": "语法精讲",
        
        // Profile
        "profile.title": "个人中心",
        "profile.autoPlayTTS": "自动播放 TTS",
        "profile.autoPlayTTS.desc": "收到 AI 回复后自动朗读内容",
        "profile.language": "语言 / Language",
        "profile.logout": "退出登录",
        "profile.deleteAccount": "永久注销账户",
        "profile.delete.confirm.title": "确认注销账户",
        "profile.delete.confirm.message": "此操作将永久删除您的账号及所有对话记录，且无法恢复。确定要继续吗？",
        "profile.delete.confirm.button": "确认注销",
        "profile.version": "OpenTalk MVP v0.2",
        "profile.poweredBy": "PRO VERSION | Powered by Supabase",
        
        // Onboarding
        "onboarding.step1.title": "点击消息播放语音",
        "onboarding.step1.desc": "轻触任意消息气泡，即可听到 AI 老师的真人发音",
        "onboarding.step2.title": "长按查看翻译和语法",
        "onboarding.step2.desc": "长按消息气泡，可以查看中文翻译和详细的语法解析",
        "onboarding.step3.title": "语音输入练习口语",
        "onboarding.step3.desc": "点击麦克风按钮，说出日语句子进行口语练习",
        "onboarding.step4.title": "与 Live2D 老师互动",
        "onboarding.step4.desc": "AI 说话时，消息列表会自动收起，让您看到老师的表情和口型",
        "onboarding.button.previous": "上一步",
        "onboarding.button.next": "下一步",
        "onboarding.button.start": "开始使用",
        "onboarding.button.skip": "跳过引导",
        
        // Language Picker
        "language.title": "语言 / Language",
        "language.subtitle": "选择语言后立即生效，无需重启应用",
        "language.systemDesc": "跟随 iOS 系统语言设置",
        
        // Support
        "support.title": "联系我们",
        "support.subtitle": "我们通常在 24 小时内回复",
        "support.loginIssue": "登录问题",
        "support.loginIssueDesc": "无法登录、收不到验证码等",
        "support.bugReport": "问题反馈",
        "support.bugReportDesc": "应用崩溃、功能异常等",
        "support.suggestion": "功能建议",
        "support.suggestionDesc": "希望增加的功能或改进建议",
        "support.directEmail": "或直接发送邮件至",
        
        // Common
        "common.ok": "确定",
        "common.cancel": "取消",
        "common.close": "关闭",
        "common.loading": "加载中...",
        "common.error": "错误",
    ]
    
    // MARK: - English
    static let en: [String: String] = [
        // Login
        "login.title": "OpenTalk",
        "login.subtitle": "Immersive Japanese Conversation",
        "login.email.placeholder": "Enter your email",
        "login.otp.placeholder": "Enter 6-digit code",
        "login.button.getCode": "Get Code",
        "login.button.verify": "Verify & Login",
        "login.button.back": "Back to Email",
        "login.divider.or": "or",
        "login.terms.agree": "By logging in, you agree to our",
        "login.terms.service": "Terms of Service",
        "login.terms.and": "and",
        "login.terms.privacy": "Privacy Policy",
        "login.error.title": "Login Failed",
        "login.error.unknown": "An unknown error occurred",
        "login.error.otpExpired": "Code is incorrect or expired",
        "login.stats.prefix": "Total practice sessions:",
        "login.stats.suffix": "",
        "login.welcome.1": "Ready to learn!",
        "login.welcome.2": "Welcome to OpenTalk!",
        "login.welcome.3": "Let's speak Japanese!",
        "login.welcome.4": "Let's practice together!",
        "login.welcome.5": "Let's do our best!",
        
        // Login Help
        "loginHelp.title": "Login Help",
        "loginHelp.subtitle": "Having trouble logging in? Check out these common solutions",
        "loginHelp.stillNeedHelp": "Still need help?",
        "loginHelp.contactSupport": "Contact Support",
        "loginHelp.faq1.question": "Not receiving the verification code?",
        "loginHelp.faq1.answer": "1. Check if your email address is correct\n2. Check your spam folder\n3. Wait 1-2 minutes and try again\n4. If still not received, contact support",
        "loginHelp.faq2.question": "Apple login failed?",
        "loginHelp.faq2.answer": "1. Make sure you're signed into your Apple ID\n2. Check your network connection\n3. Allow OpenTalk to use Apple Sign-In in Settings\n4. Restart the app and try again",
        "loginHelp.faq3.question": "Code expired?",
        "loginHelp.faq3.answer": "The code is valid for 10 minutes. If expired, go back to the login page and request a new one.",
        "loginHelp.faq4.question": "How to switch accounts?",
        "loginHelp.faq4.answer": "Tap \"Logout\" in your profile, then sign in with a different email or Apple ID.",
        "loginHelp.faq5.question": "Forgot your registered email?",
        "loginHelp.faq5.answer": "If you used Apple Sign-In, check your linked email in Apple ID settings. If you registered with email, try your commonly used email addresses.",
        
        // Chat
        "chat.input.placeholder": "Type a message...",
        "chat.input.recording": "Recording...",
        "chat.loading": "Loading...",
        "chat.menu.translate": "Translate",
        "chat.menu.analyze": "Grammar Analysis",
        "chat.menu.report": "Report",
        "chat.menu.retry": "Retry",
        "chat.menu.copy": "Copy",
        "chat.detailedAnalysis": "View Detailed Analysis",
        "chat.grammarTitle": "Grammar Analysis",
        
        // Profile
        "profile.title": "Profile",
        "profile.autoPlayTTS": "Auto Play TTS",
        "profile.autoPlayTTS.desc": "Automatically read AI replies aloud",
        "profile.language": "Language",
        "profile.logout": "Logout",
        "profile.deleteAccount": "Delete Account Permanently",
        "profile.delete.confirm.title": "Confirm Account Deletion",
        "profile.delete.confirm.message": "This will permanently delete your account and all conversation history. This cannot be undone. Continue?",
        "profile.delete.confirm.button": "Confirm Delete",
        "profile.version": "OpenTalk MVP v0.2",
        "profile.poweredBy": "PRO VERSION | Powered by Supabase",
        
        // Onboarding
        "onboarding.step1.title": "Tap Messages to Play Audio",
        "onboarding.step1.desc": "Tap any message bubble to hear the AI teacher's pronunciation",
        "onboarding.step2.title": "Long Press for Translation & Grammar",
        "onboarding.step2.desc": "Long press a message to see translation and detailed grammar analysis",
        "onboarding.step3.title": "Voice Input Practice",
        "onboarding.step3.desc": "Tap the microphone to practice speaking Japanese",
        "onboarding.step4.title": "Interact with Live2D Teacher",
        "onboarding.step4.desc": "When AI speaks, message list auto-collapses to show teacher's expressions and lip sync",
        "onboarding.button.previous": "Previous",
        "onboarding.button.next": "Next",
        "onboarding.button.start": "Get Started",
        "onboarding.button.skip": "Skip",
        
        // Language Picker
        "language.title": "Language",
        "language.subtitle": "Changes take effect immediately, no restart needed",
        "language.systemDesc": "Follow iOS system language",
        
        // Support
        "support.title": "Contact Us",
        "support.subtitle": "We usually respond within 24 hours",
        "support.loginIssue": "Login Issue",
        "support.loginIssueDesc": "Can't login, not receiving codes, etc.",
        "support.bugReport": "Bug Report",
        "support.bugReportDesc": "App crashes, feature not working, etc.",
        "support.suggestion": "Feature Suggestion",
        "support.suggestionDesc": "Features you'd like to see or improvements",
        "support.directEmail": "Or email us directly at",
        
        // Common
        "common.ok": "OK",
        "common.cancel": "Cancel",
        "common.close": "Close",
        "common.loading": "Loading...",
        "common.error": "Error",
    ]
    
    // MARK: - 日本語
    static let ja: [String: String] = [
        // Login
        "login.title": "OpenTalk",
        "login.subtitle": "没入型日本語会話",
        "login.email.placeholder": "メールアドレスを入力",
        "login.otp.placeholder": "6桁のコードを入力",
        "login.button.getCode": "コードを取得",
        "login.button.verify": "確認してログイン",
        "login.button.back": "メール入力に戻る",
        "login.divider.or": "または",
        "login.terms.agree": "ログインすることで、以下に同意したことになります",
        "login.terms.service": "利用規約",
        "login.terms.and": "と",
        "login.terms.privacy": "プライバシーポリシー",
        "login.error.title": "ログイン失敗",
        "login.error.unknown": "不明なエラーが発生しました",
        "login.error.otpExpired": "コードが正しくないか、期限切れです",
        "login.stats.prefix": "累計練習回数：",
        "login.stats.suffix": "回",
        "login.welcome.1": "Ready to learn!",
        "login.welcome.2": "OpenTalkへようこそ！",
        "login.welcome.3": "日本語を話しましょう！",
        "login.welcome.4": "一緒に練習しましょう！",
        "login.welcome.5": "一緒に頑張りましょう！",
        
        // Login Help
        "loginHelp.title": "ログインヘルプ",
        "loginHelp.subtitle": "ログインに問題がありますか？よくある解決策をご覧ください",
        "loginHelp.stillNeedHelp": "まだお困りですか？",
        "loginHelp.contactSupport": "サポートに連絡",
        "loginHelp.faq1.question": "確認コードが届かない場合は？",
        "loginHelp.faq1.answer": "1. メールアドレスが正しいか確認してください\n2. 迷惑メールフォルダを確認してください\n3. 1〜2分待ってから再試行してください\n4. それでも届かない場合は、サポートにお問い合わせください",
        "loginHelp.faq2.question": "Appleログインに失敗しましたか？",
        "loginHelp.faq2.answer": "1. Apple IDにサインインしていることを確認してください\n2. ネットワーク接続を確認してください\n3. 設定でOpenTalkがAppleサインインを使用することを許可してください\n4. アプリを再起動して再試行してください",
        "loginHelp.faq3.question": "コードの有効期限が切れましたか？",
        "loginHelp.faq3.answer": "コードは10分間有効です。期限が切れた場合は、ログインページに戻って新しいコードをリクエストしてください。",
        "loginHelp.faq4.question": "アカウントを切り替えるには？",
        "loginHelp.faq4.answer": "プロフィールで「ログアウト」をタップし、別のメールまたはApple IDでサインインしてください。",
        "loginHelp.faq5.question": "登録メールを忘れましたか？",
        "loginHelp.faq5.answer": "Appleサインインを使用した場合は、Apple ID設定で関連メールを確認できます。メールで登録した場合は、よく使うメールアドレスを試してください。",
        
        // Chat
        "chat.input.placeholder": "メッセージを入力...",
        "chat.input.recording": "録音中...",
        "chat.loading": "読み込み中...",
        "chat.menu.translate": "翻訳",
        "chat.menu.analyze": "文法解説",
        "chat.menu.report": "報告",
        "chat.menu.retry": "再試行",
        "chat.menu.copy": "コピー",
        "chat.detailedAnalysis": "詳細な解析を見る",
        "chat.grammarTitle": "文法解説",
        
        // Profile
        "profile.title": "プロフィール",
        "profile.autoPlayTTS": "TTS自動再生",
        "profile.autoPlayTTS.desc": "AI返信を自動的に読み上げ",
        "profile.language": "言語 / Language",
        "profile.logout": "ログアウト",
        "profile.deleteAccount": "アカウントを完全に削除",
        "profile.delete.confirm.title": "アカウント削除の確認",
        "profile.delete.confirm.message": "この操作により、アカウントとすべての会話履歴が完全に削除されます。元に戻すことはできません。続行しますか？",
        "profile.delete.confirm.button": "削除を確認",
        "profile.version": "OpenTalk MVP v0.2",
        "profile.poweredBy": "PRO VERSION | Powered by Supabase",
        
        // Onboarding
        "onboarding.step1.title": "メッセージをタップして音声再生",
        "onboarding.step1.desc": "メッセージバブルをタップすると、AI先生の発音が聞けます",
        "onboarding.step2.title": "長押しで翻訳と文法を表示",
        "onboarding.step2.desc": "メッセージバブルを長押しすると、翻訳と詳細な文法解説が見られます",
        "onboarding.step3.title": "音声入力で会話練習",
        "onboarding.step3.desc": "マイクボタンをタップして、日本語の文を話して練習しましょう",
        "onboarding.step4.title": "Live2Dティーチャーと対話",
        "onboarding.step4.desc": "AIが話すとき、メッセージリストが自動的に折りたたまれ、先生の表情と口の動きが見えます",
        "onboarding.button.previous": "前へ",
        "onboarding.button.next": "次へ",
        "onboarding.button.start": "始めましょう",
        "onboarding.button.skip": "スキップ",
        
        // Language Picker
        "language.title": "言語 / Language",
        "language.subtitle": "変更はすぐに反映されます。再起動は不要です",
        "language.systemDesc": "iOSシステム言語に従う",
        
        // Support
        "support.title": "お問い合わせ",
        "support.subtitle": "通常24時間以内にご返信いたします",
        "support.loginIssue": "ログインの問題",
        "support.loginIssueDesc": "ログインできない、コードが届かないなど",
        "support.bugReport": "不具合の報告",
        "support.bugReportDesc": "アプリのクラッシュ、機能の問題など",
        "support.suggestion": "機能の提案",
        "support.suggestionDesc": "追加してほしい機能や改善案",
        "support.directEmail": "または直接メールを送信",
        
        // Common
        "common.ok": "OK",
        "common.cancel": "キャンセル",
        "common.close": "閉じる",
        "common.loading": "読み込み中...",
        "common.error": "エラー",
    ]
    
    // MARK: - 한국어
    static let ko: [String: String] = [
        // Login
        "login.title": "OpenTalk",
        "login.subtitle": "몰입형 일본어 회화",
        "login.email.placeholder": "이메일을 입력하세요",
        "login.otp.placeholder": "6자리 코드 입력",
        "login.button.getCode": "코드 받기",
        "login.button.verify": "확인 및 로그인",
        "login.button.back": "이메일 입력으로 돌아가기",
        "login.divider.or": "또는",
        "login.terms.agree": "로그인하면 다음에 동의하게 됩니다",
        "login.terms.service": "이용약관",
        "login.terms.and": "및",
        "login.terms.privacy": "개인정보 처리방침",
        "login.error.title": "로그인 실패",
        "login.error.unknown": "알 수 없는 오류가 발생했습니다",
        "login.error.otpExpired": "코드가 올바르지 않거나 만료되었습니다",
        "login.stats.prefix": "누적 연습 횟수:",
        "login.stats.suffix": "회",
        "login.welcome.1": "Ready to learn!",
        "login.welcome.2": "OpenTalk에 오신 것을 환영합니다!",
        "login.welcome.3": "일본어를 말해봅시다!",
        "login.welcome.4": "함께 연습합시다!",
        "login.welcome.5": "함께 힘내봅시다!",
        
        // Login Help
        "loginHelp.title": "로그인 도움말",
        "loginHelp.subtitle": "로그인에 문제가 있으신가요? 일반적인 해결 방법을 확인하세요",
        "loginHelp.stillNeedHelp": "아직 도움이 필요하신가요?",
        "loginHelp.contactSupport": "고객지원 연락",
        "loginHelp.faq1.question": "인증 코드를 받지 못하셨나요?",
        "loginHelp.faq1.answer": "1. 이메일 주소가 올바른지 확인하세요\n2. 스팸 폴더를 확인하세요\n3. 1-2분 기다린 후 다시 시도하세요\n4. 그래도 받지 못하면 고객지원에 문의하세요",
        "loginHelp.faq2.question": "Apple 로그인 실패?",
        "loginHelp.faq2.answer": "1. Apple ID에 로그인되어 있는지 확인하세요\n2. 네트워크 연결을 확인하세요\n3. 설정에서 OpenTalk의 Apple 로그인을 허용하세요\n4. 앱을 재시작한 후 다시 시도하세요",
        "loginHelp.faq3.question": "코드가 만료되었나요?",
        "loginHelp.faq3.answer": "코드는 10분간 유효합니다. 만료된 경우 로그인 페이지로 돌아가 새 코드를 요청하세요.",
        "loginHelp.faq4.question": "계정을 전환하려면?",
        "loginHelp.faq4.answer": "프로필에서 \"로그아웃\"을 탭한 후 다른 이메일 또는 Apple ID로 로그인하세요.",
        "loginHelp.faq5.question": "등록 이메일을 잊으셨나요?",
        "loginHelp.faq5.answer": "Apple 로그인을 사용한 경우 Apple ID 설정에서 연결된 이메일을 확인할 수 있습니다. 이메일로 등록한 경우 자주 사용하는 이메일 주소를 시도해 보세요.",
        
        // Chat
        "chat.input.placeholder": "메시지 입력...",
        "chat.input.recording": "녹음 중...",
        "chat.loading": "로딩 중...",
        "chat.menu.translate": "번역",
        "chat.menu.analyze": "문법 분석",
        "chat.menu.report": "신고",
        "chat.menu.retry": "재시도",
        "chat.menu.copy": "복사",
        "chat.detailedAnalysis": "상세 분석 보기",
        "chat.grammarTitle": "문법 분석",
        
        // Profile
        "profile.title": "프로필",
        "profile.autoPlayTTS": "TTS 자동 재생",
        "profile.autoPlayTTS.desc": "AI 답변을 자동으로 읽어줍니다",
        "profile.language": "언어 / Language",
        "profile.logout": "로그아웃",
        "profile.deleteAccount": "계정 영구 삭제",
        "profile.delete.confirm.title": "계정 삭제 확인",
        "profile.delete.confirm.message": "이 작업은 계정과 모든 대화 기록을 영구적으로 삭제합니다. 취소할 수 없습니다. 계속하시겠습니까?",
        "profile.delete.confirm.button": "삭제 확인",
        "profile.version": "OpenTalk MVP v0.2",
        "profile.poweredBy": "PRO VERSION | Powered by Supabase",
        
        // Onboarding
        "onboarding.step1.title": "메시지를 탭하여 음성 재생",
        "onboarding.step1.desc": "메시지 버블을 탭하면 AI 선생님의 발음을 들을 수 있습니다",
        "onboarding.step2.title": "길게 눌러 번역 및 문법 보기",
        "onboarding.step2.desc": "메시지 버블을 길게 누르면 번역과 상세한 문법 해설을 볼 수 있습니다",
        "onboarding.step3.title": "음성 입력으로 회화 연습",
        "onboarding.step3.desc": "마이크 버튼을 탭하여 일본어 문장을 말하고 연습하세요",
        "onboarding.step4.title": "Live2D 선생님과 상호작용",
        "onboarding.step4.desc": "AI가 말할 때 메시지 목록이 자동으로 접혀 선생님의 표정과 입 모양을 볼 수 있습니다",
        "onboarding.button.previous": "이전",
        "onboarding.button.next": "다음",
        "onboarding.button.start": "시작하기",
        "onboarding.button.skip": "건너뛰기",
        
        // Language Picker
        "language.title": "언어 / Language",
        "language.subtitle": "변경사항이 즉시 적용됩니다. 재시작 필요 없음",
        "language.systemDesc": "iOS 시스템 언어 따르기",
        
        // Support
        "support.title": "문의하기",
        "support.subtitle": "보통 24시간 이내에 답변드립니다",
        "support.loginIssue": "로그인 문제",
        "support.loginIssueDesc": "로그인 불가, 코드 미수신 등",
        "support.bugReport": "버그 신고",
        "support.bugReportDesc": "앱 충돌, 기능 오류 등",
        "support.suggestion": "기능 제안",
        "support.suggestionDesc": "추가했으면 하는 기능이나 개선 사항",
        "support.directEmail": "또는 직접 이메일 보내기",
        
        // Common
        "common.ok": "확인",
        "common.cancel": "취소",
        "common.close": "닫기",
        "common.loading": "로딩 중...",
        "common.error": "오류",
    ]
}
