import Foundation

/// Centralized localization keys for the app.
/// All properties are computed (dynamic) so they respond to runtime language changes.
enum LocalizedString {
    // MARK: - Login
    enum Login {
        static var title: String { L("login.title", "OpenTalk") }
        static var subtitle: String { L("login.subtitle", "沉浸式日语口语对话") }
        static var emailPlaceholder: String { L("login.email.placeholder", "请输入注册邮箱") }
        static var otpPlaceholder: String { L("login.otp.placeholder", "请输入 6 位验证码") }
        static var getCode: String { L("login.button.getCode", "获取验证码") }
        static var verify: String { L("login.button.verify", "验证并登录") }
        static var back: String { L("login.button.back", "返回输入邮箱") }
        static var dividerOr: String { L("login.divider.or", "或") }
        static var termsAgree: String { L("login.terms.agree", "登录即代表您已同意") }
        static var termsService: String { L("login.terms.service", "《用户协议》") }
        static var termsAnd: String { L("login.terms.and", "与") }
        static var termsPrivacy: String { L("login.terms.privacy", "《隐私政策》") }
        static var errorTitle: String { L("login.error.title", "登录失败") }
        static var errorUnknown: String { L("login.error.unknown", "发生未知错误") }
        static var errorOtpExpired: String { L("login.error.otpExpired", "验证码错误或已过期") }
        static var statsPrefix: String { L("login.stats.prefix", "已累计产生") }
        static var statsSuffix: String { L("login.stats.suffix", "次练习") }
        
        // Welcome messages
        static var welcome1: String { L("login.welcome.1", "Ready to learn!") }
        static var welcome2: String { L("login.welcome.2", "欢迎使用OpenTalk！") }
        static var welcome3: String { L("login.welcome.3", "日本語を話しましょう！") }
        static var welcome4: String { L("login.welcome.4", "Let's practice together!") }
        static var welcome5: String { L("login.welcome.5", "一緒に頑張りましょう！") }
    }
    
    // MARK: - Login Help
    enum LoginHelp {
        static var title: String { L("loginHelp.title", "登录帮助") }
        static var subtitle: String { L("loginHelp.subtitle", "遇到登录问题？查看以下常见解决方案") }
        static var stillNeedHelp: String { L("loginHelp.stillNeedHelp", "仍需帮助？") }
        static var contactSupport: String { L("loginHelp.contactSupport", "联系客服") }
        
        // FAQ Questions
        static var faq1Question: String { L("loginHelp.faq1.question", "收不到验证码怎么办？") }
        static var faq1Answer: String { L("loginHelp.faq1.answer", "1. 请检查邮箱地址是否正确\n2. 查看垃圾邮件文件夹\n3. 等待 1-2 分钟后重试\n4. 如仍未收到，请联系客服") }
        
        static var faq2Question: String { L("loginHelp.faq2.question", "Apple 登录失败？") }
        static var faq2Answer: String { L("loginHelp.faq2.answer", "1. 确保您的设备已登录 Apple ID\n2. 检查网络连接是否正常\n3. 在设置中允许 OpenTalk 使用 Apple 登录\n4. 重启应用后重试") }
        
        static var faq3Question: String { L("loginHelp.faq3.question", "验证码过期了？") }
        static var faq3Answer: String { L("loginHelp.faq3.answer", "验证码有效期为 10 分钟。如果过期，请返回登录页重新获取新的验证码。") }
        
        static var faq4Question: String { L("loginHelp.faq4.question", "如何切换账号？") }
        static var faq4Answer: String { L("loginHelp.faq4.answer", "在个人中心点击\"退出登录\"，然后使用新的邮箱或 Apple ID 登录即可。") }
        
        static var faq5Question: String { L("loginHelp.faq5.question", "忘记注册邮箱？") }
        static var faq5Answer: String { L("loginHelp.faq5.answer", "如果您使用 Apple 登录，可以在 Apple ID 设置中查看关联的邮箱。如果使用邮箱注册，请尝试常用邮箱地址。") }
    }
    
    // MARK: - Onboarding
    enum Onboarding {
        static var step1Title: String { L("onboarding.step1.title", "点击消息播放语音") }
        static var step1Desc: String { L("onboarding.step1.desc", "轻触任意消息气泡，即可听到 AI 老师的真人发音") }
        
        static var step2Title: String { L("onboarding.step2.title", "长按查看翻译和语法") }
        static var step2Desc: String { L("onboarding.step2.desc", "长按消息气泡，可以查看中文翻译和详细的语法解析") }
        
        static var step3Title: String { L("onboarding.step3.title", "语音输入练习口语") }
        static var step3Desc: String { L("onboarding.step3.desc", "点击麦克风按钮，说出日语句子进行口语练习") }
        
        static var step4Title: String { L("onboarding.step4.title", "与 Live2D 老师互动") }
        static var step4Desc: String { L("onboarding.step4.desc", "AI 说话时，消息列表会自动收起，让您看到老师的表情和口型") }
        
        static var previous: String { L("onboarding.button.previous", "上一步") }
        static var next: String { L("onboarding.button.next", "下一步") }
        static var start: String { L("onboarding.button.start", "开始使用") }
        static var skip: String { L("onboarding.button.skip", "跳过引导") }
    }
    
    // MARK: - Chat
    enum Chat {
        static var inputPlaceholder: String { L("chat.input.placeholder", "输入消息...") }
        static var inputRecording: String { L("chat.input.recording", "正在录音...") }
        static var loading: String { L("chat.loading", "召唤中...") }
        
        // Context menu
        static var menuTranslate: String { L("chat.menu.translate", "翻译") }
        static var menuAnalyze: String { L("chat.menu.analyze", "语法精讲") }
        static var menuReport: String { L("chat.menu.report", "举报") }
        static var menuRetry: String { L("chat.menu.retry", "重试") }
        static var menuCopy: String { L("chat.menu.copy", "复制") }
        static var detailedAnalysis: String { L("chat.detailedAnalysis", "查看详细解析") }
        static var grammarTitle: String { L("chat.grammarTitle", "语法精讲") }
    }
    
    // MARK: - Profile
    enum Profile {
        static var title: String { L("profile.title", "个人中心") }
        static var autoPlayTTS: String { L("profile.autoPlayTTS", "自动播放 TTS") }
        static var autoPlayTTSDesc: String { L("profile.autoPlayTTS.desc", "收到 AI 回复后自动朗读内容") }
        static var language: String { L("profile.language", "语言 / Language") }
        static var logout: String { L("profile.logout", "退出登录") }
        static var deleteAccount: String { L("profile.deleteAccount", "永久注销账户") }
        
        // Delete confirmation
        static var deleteConfirmTitle: String { L("profile.delete.confirm.title", "确认注销账户") }
        static var deleteConfirmMessage: String { L("profile.delete.confirm.message", "此操作将永久删除您的账号及所有对话记录，且无法恢复。确定要继续吗？") }
        static var deleteConfirmButton: String { L("profile.delete.confirm.button", "确认注销") }
        static var cancel: String { L("common.cancel", "取消") }
        static var version: String { L("profile.version", "OpenTalk MVP v0.2") }
        static var poweredBy: String { L("profile.poweredBy", "PRO VERSION | Powered by Supabase") }
    }
    
    // MARK: - Language Picker
    enum Language {
        static var title: String { L("language.title", "语言 / Language") }
        static var subtitle: String { L("language.subtitle", "选择语言后立即生效，无需重启应用") }
        static var systemDesc: String { L("language.systemDesc", "跟随 iOS 系统语言设置") }
    }
    
    // MARK: - Common
    enum Common {
        static var ok: String { L("common.ok", "确定") }
        static var cancel: String { L("common.cancel", "取消") }
        static var close: String { L("common.close", "关闭") }
        static var loading: String { L("common.loading", "加载中...") }
        static var error: String { L("common.error", "错误") }
    }
}
