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
    
    /// The Bundle language code to use for loading strings
    var bundleCode: String? {
        switch self {
        case .system:  return nil
        case .chinese: return "zh-Hans"
        case .english: return "en"
        case .japanese: return "ja"
        case .korean:  return "ko"
        }
    }
}

// MARK: - Language Manager

/// Manages app-wide language selection with real-time SwiftUI updates.
///
/// Usage:
///   @ObservedObject var langManager = LanguageManager.shared
///   Text(langManager.string("login.button.getCode", default: "获取验证码"))
///
/// Or use the convenience wrapper:
///   Text(L("login.button.getCode", "获取验证码"))
final class LanguageManager: ObservableObject {
    
    static let shared = LanguageManager()
    
    private let userDefaultsKey = "app_selected_language"
    
    /// Currently selected language. Changing this triggers UI refresh.
    @Published private(set) var currentLanguage: AppLanguage
    
    /// The Bundle used to load localized strings
    private var localizedBundle: Bundle
    
    private init() {
        let saved = UserDefaults.standard.string(forKey: "app_selected_language") ?? "system"
        let lang = AppLanguage(rawValue: saved) ?? .system
        self.currentLanguage = lang
        self.localizedBundle = LanguageManager.makeBundle(for: lang)
    }
    
    // MARK: - Public API
    
    /// Switch to a new language. All views using `LanguageManager` will update instantly.
    func setLanguage(_ language: AppLanguage) {
        guard language != currentLanguage else { return }
        currentLanguage = language
        localizedBundle = LanguageManager.makeBundle(for: language)
        UserDefaults.standard.set(language.rawValue, forKey: userDefaultsKey)
        
        // Force SwiftUI to re-render all views
        objectWillChange.send()
    }
    
    /// Localize a string key with a fallback default value.
    func string(_ key: String, default defaultValue: String, comment: String = "") -> String {
        let result = localizedBundle.localizedString(forKey: key, value: nil, table: nil)
        // If the bundle returns the key itself, it means no translation found — use default
        return result == key ? defaultValue : result
    }
    
    // MARK: - Private Helpers
    
    private static func makeBundle(for language: AppLanguage) -> Bundle {
        guard let code = language.bundleCode else {
            // "system" — use the default main bundle (follows system language)
            return Bundle.main
        }
        
        // Try to find the .lproj folder for the requested language
        if let path = Bundle.main.path(forResource: code, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        
        // Fallback to main bundle
        return Bundle.main
    }
}

// MARK: - Convenience Global Function

/// Shorthand for `LanguageManager.shared.string(_:default:)`.
/// Usage: `Text(L("login.title", "MOJiTalk"))`
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

// MARK: - LocalizedString (Dynamic Version)
// These computed properties replace the static ones in LocalizedString.swift
// They read from LanguageManager so they update when language changes.

extension LocalizedString {
    
    enum Dynamic {
        private static var lm: LanguageManager { LanguageManager.shared }
        
        // MARK: Login
        enum Login {
            static var title:            String { L("login.title",              "MOJiTalk") }
            static var subtitle:         String { L("login.subtitle",           "沉浸式日语口语对话") }
            static var emailPlaceholder: String { L("login.email.placeholder",  "请输入注册邮箱") }
            static var otpPlaceholder:   String { L("login.otp.placeholder",    "请输入 6 位验证码") }
            static var getCode:          String { L("login.button.getCode",     "获取验证码") }
            static var verify:           String { L("login.button.verify",      "验证并登录") }
            static var back:             String { L("login.button.back",        "返回输入邮箱") }
            static var dividerOr:        String { L("login.divider.or",         "或") }
            static var termsAgree:       String { L("login.terms.agree",        "登录即代表您已同意") }
            static var termsService:     String { L("login.terms.service",      "《用户协议》") }
            static var termsAnd:         String { L("login.terms.and",          "与") }
            static var termsPrivacy:     String { L("login.terms.privacy",      "《隐私政策》") }
            static var errorTitle:       String { L("login.error.title",        "登录失败") }
            static var errorUnknown:     String { L("login.error.unknown",      "发生未知错误") }
            static var statsPrefix:      String { L("login.stats.prefix",       "已累计产生") }
            static var statsSuffix:      String { L("login.stats.suffix",       "次练习") }
            static var welcome1:         String { L("login.welcome.1",          "Ready to learn!") }
            static var welcome2:         String { L("login.welcome.2",          "欢迎使用可呆口语！") }
            static var welcome3:         String { L("login.welcome.3",          "日本語を話しましょう！") }
            static var welcome4:         String { L("login.welcome.4",          "Let's practice together!") }
            static var welcome5:         String { L("login.welcome.5",          "一緒に頑張りましょう！") }
        }
        
        // MARK: Chat
        enum Chat {
            static var inputPlaceholder: String { L("chat.input.placeholder",   "输入消息...") }
            static var loading:          String { L("chat.loading",             "召唤中...") }
            static var menuTranslate:    String { L("chat.menu.translate",      "翻译") }
            static var menuAnalyze:      String { L("chat.menu.analyze",        "语法精讲") }
            static var menuReport:       String { L("chat.menu.report",         "举报") }
        }
        
        // MARK: Profile
        enum Profile {
            static var autoPlayTTS:         String { L("profile.autoPlayTTS",              "自动播放 TTS") }
            static var logout:              String { L("profile.logout",                   "退出登录") }
            static var deleteAccount:       String { L("profile.deleteAccount",            "永久注销账户") }
            static var deleteConfirmTitle:  String { L("profile.delete.confirm.title",     "确认注销账户") }
            static var deleteConfirmMsg:    String { L("profile.delete.confirm.message",   "此操作将永久删除您的账号及所有对话记录，且无法恢复。确定要继续吗？") }
            static var deleteConfirmButton: String { L("profile.delete.confirm.button",    "确认注销") }
            static var cancel:              String { L("common.cancel",                    "取消") }
        }
        
        // MARK: Onboarding
        enum Onboarding {
            static var step1Title: String { L("onboarding.step1.title", "点击消息播放语音") }
            static var step1Desc:  String { L("onboarding.step1.desc",  "轻触任意消息气泡，即可听到 AI 老师的真人发音") }
            static var step2Title: String { L("onboarding.step2.title", "长按查看翻译和语法") }
            static var step2Desc:  String { L("onboarding.step2.desc",  "长按消息气泡，可以查看中文翻译和详细的语法解析") }
            static var step3Title: String { L("onboarding.step3.title", "语音输入练习口语") }
            static var step3Desc:  String { L("onboarding.step3.desc",  "点击麦克风按钮，说出日语句子进行口语练习") }
            static var step4Title: String { L("onboarding.step4.title", "与 Live2D 老师互动") }
            static var step4Desc:  String { L("onboarding.step4.desc",  "AI 说话时，消息列表会自动收起，让您看到老师的表情和口型") }
            static var previous:   String { L("onboarding.button.previous", "上一步") }
            static var next:       String { L("onboarding.button.next",     "下一步") }
            static var start:      String { L("onboarding.button.start",    "开始使用") }
            static var skip:       String { L("onboarding.button.skip",     "跳过引导") }
        }
    }
}
