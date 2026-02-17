import Foundation

/// Centralized localization manager for the app
enum LocalizedString {
    // MARK: - Login
    enum Login {
        static let title = NSLocalizedString("login.title", value: "MOJiTalk", comment: "App title on login screen")
        static let subtitle = NSLocalizedString("login.subtitle", value: "沉浸式日语口语对话", comment: "App subtitle")
        static let emailPlaceholder = NSLocalizedString("login.email.placeholder", value: "请输入注册邮箱", comment: "Email input placeholder")
        static let otpPlaceholder = NSLocalizedString("login.otp.placeholder", value: "请输入 6 位验证码", comment: "OTP input placeholder")
        static let getCode = NSLocalizedString("login.button.getCode", value: "获取验证码", comment: "Get verification code button")
        static let verify = NSLocalizedString("login.button.verify", value: "验证并登录", comment: "Verify and login button")
        static let back = NSLocalizedString("login.button.back", value: "返回输入邮箱", comment: "Back to email button")
        static let dividerOr = NSLocalizedString("login.divider.or", value: "或", comment: "Or divider text")
        static let termsAgree = NSLocalizedString("login.terms.agree", value: "登录即代表您已同意", comment: "Terms agreement prefix")
        static let termsService = NSLocalizedString("login.terms.service", value: "《用户协议》", comment: "Terms of service")
        static let termsAnd = NSLocalizedString("login.terms.and", value: "与", comment: "And connector")
        static let termsPrivacy = NSLocalizedString("login.terms.privacy", value: "《隐私政策》", comment: "Privacy policy")
        static let errorTitle = NSLocalizedString("login.error.title", value: "登录失败", comment: "Login error alert title")
        static let errorUnknown = NSLocalizedString("login.error.unknown", value: "发生未知错误", comment: "Unknown error message")
        static let statsPrefix = NSLocalizedString("login.stats.prefix", value: "已累计产生", comment: "Stats prefix text")
        static let statsSuffix = NSLocalizedString("login.stats.suffix", value: "次练习", comment: "Stats suffix text")
        
        // Welcome messages
        static let welcome1 = NSLocalizedString("login.welcome.1", value: "Ready to learn!", comment: "Welcome message 1")
        static let welcome2 = NSLocalizedString("login.welcome.2", value: "欢迎使用可呆口语！", comment: "Welcome message 2")
        static let welcome3 = NSLocalizedString("login.welcome.3", value: "日本語を話しましょう！", comment: "Welcome message 3")
        static let welcome4 = NSLocalizedString("login.welcome.4", value: "Let's practice together!", comment: "Welcome message 4")
        static let welcome5 = NSLocalizedString("login.welcome.5", value: "一緒に頑張りましょう！", comment: "Welcome message 5")
    }
    
    // MARK: - Login Help
    enum LoginHelp {
        static let title = NSLocalizedString("loginHelp.title", value: "登录帮助", comment: "Login help title")
        static let subtitle = NSLocalizedString("loginHelp.subtitle", value: "遇到登录问题？查看以下常见解决方案", comment: "Login help subtitle")
        static let stillNeedHelp = NSLocalizedString("loginHelp.stillNeedHelp", value: "仍需帮助？", comment: "Still need help")
        static let contactSupport = NSLocalizedString("loginHelp.contactSupport", value: "联系客服", comment: "Contact support button")
        
        // FAQ Questions
        static let faq1Question = NSLocalizedString("loginHelp.faq1.question", value: "收不到验证码怎么办？", comment: "FAQ 1 question")
        static let faq1Answer = NSLocalizedString("loginHelp.faq1.answer", value: "1. 请检查邮箱地址是否正确\n2. 查看垃圾邮件文件夹\n3. 等待 1-2 分钟后重试\n4. 如仍未收到，请联系客服", comment: "FAQ 1 answer")
        
        static let faq2Question = NSLocalizedString("loginHelp.faq2.question", value: "Apple 登录失败？", comment: "FAQ 2 question")
        static let faq2Answer = NSLocalizedString("loginHelp.faq2.answer", value: "1. 确保您的设备已登录 Apple ID\n2. 检查网络连接是否正常\n3. 在设置中允许 MOJiTalk 使用 Apple 登录\n4. 重启应用后重试", comment: "FAQ 2 answer")
        
        static let faq3Question = NSLocalizedString("loginHelp.faq3.question", value: "验证码过期了？", comment: "FAQ 3 question")
        static let faq3Answer = NSLocalizedString("loginHelp.faq3.answer", value: "验证码有效期为 10 分钟。如果过期，请返回登录页重新获取新的验证码。", comment: "FAQ 3 answer")
        
        static let faq4Question = NSLocalizedString("loginHelp.faq4.question", value: "如何切换账号？", comment: "FAQ 4 question")
        static let faq4Answer = NSLocalizedString("loginHelp.faq4.answer", value: "在个人中心点击\"退出登录\"，然后使用新的邮箱或 Apple ID 登录即可。", comment: "FAQ 4 answer")
        
        static let faq5Question = NSLocalizedString("loginHelp.faq5.question", value: "忘记注册邮箱？", comment: "FAQ 5 question")
        static let faq5Answer = NSLocalizedString("loginHelp.faq5.answer", value: "如果您使用 Apple 登录，可以在 Apple ID 设置中查看关联的邮箱。如果使用邮箱注册，请尝试常用邮箱地址。", comment: "FAQ 5 answer")
    }
    
    // MARK: - Onboarding
    enum Onboarding {
        static let step1Title = NSLocalizedString("onboarding.step1.title", value: "点击消息播放语音", comment: "Onboarding step 1 title")
        static let step1Desc = NSLocalizedString("onboarding.step1.desc", value: "轻触任意消息气泡，即可听到 AI 老师的真人发音", comment: "Onboarding step 1 description")
        
        static let step2Title = NSLocalizedString("onboarding.step2.title", value: "长按查看翻译和语法", comment: "Onboarding step 2 title")
        static let step2Desc = NSLocalizedString("onboarding.step2.desc", value: "长按消息气泡，可以查看中文翻译和详细的语法解析", comment: "Onboarding step 2 description")
        
        static let step3Title = NSLocalizedString("onboarding.step3.title", value: "语音输入练习口语", comment: "Onboarding step 3 title")
        static let step3Desc = NSLocalizedString("onboarding.step3.desc", value: "点击麦克风按钮，说出日语句子进行口语练习", comment: "Onboarding step 3 description")
        
        static let step4Title = NSLocalizedString("onboarding.step4.title", value: "与 Live2D 老师互动", comment: "Onboarding step 4 title")
        static let step4Desc = NSLocalizedString("onboarding.step4.desc", value: "AI 说话时，消息列表会自动收起，让您看到老师的表情和口型", comment: "Onboarding step 4 description")
        
        static let previous = NSLocalizedString("onboarding.button.previous", value: "上一步", comment: "Previous button")
        static let next = NSLocalizedString("onboarding.button.next", value: "下一步", comment: "Next button")
        static let start = NSLocalizedString("onboarding.button.start", value: "开始使用", comment: "Start button")
        static let skip = NSLocalizedString("onboarding.button.skip", value: "跳过引导", comment: "Skip button")
    }
    
    // MARK: - Chat
    enum Chat {
        static let inputPlaceholder = NSLocalizedString("chat.input.placeholder", value: "输入消息...", comment: "Chat input placeholder")
        static let loading = NSLocalizedString("chat.loading", value: "召唤中...", comment: "Loading Live2D")
        
        // Context menu
        static let menuTranslate = NSLocalizedString("chat.menu.translate", value: "翻译", comment: "Translate menu item")
        static let menuAnalyze = NSLocalizedString("chat.menu.analyze", value: "语法精讲", comment: "Grammar analysis menu item")
        static let menuReport = NSLocalizedString("chat.menu.report", value: "举报", comment: "Report menu item")
        static let menuRetry = NSLocalizedString("chat.menu.retry", value: "重试", comment: "Retry menu item")
    }
    
    // MARK: - Profile
    enum Profile {
        static let title = NSLocalizedString("profile.title", value: "个人中心", comment: "Profile title")
        static let autoPlayTTS = NSLocalizedString("profile.autoPlayTTS", value: "自动播放 TTS", comment: "Auto play TTS setting")
        static let logout = NSLocalizedString("profile.logout", value: "退出登录", comment: "Logout button")
        static let deleteAccount = NSLocalizedString("profile.deleteAccount", value: "永久注销账户", comment: "Delete account button")
        
        // Delete confirmation
        static let deleteConfirmTitle = NSLocalizedString("profile.delete.confirm.title", value: "确认注销账户", comment: "Delete confirmation title")
        static let deleteConfirmMessage = NSLocalizedString("profile.delete.confirm.message", value: "此操作将永久删除您的账号及所有对话记录，且无法恢复。确定要继续吗？", comment: "Delete confirmation message")
        static let deleteConfirmButton = NSLocalizedString("profile.delete.confirm.button", value: "确认注销", comment: "Confirm delete button")
        static let cancel = NSLocalizedString("common.cancel", value: "取消", comment: "Cancel button")
    }
    
    // MARK: - Common
    enum Common {
        static let ok = NSLocalizedString("common.ok", value: "确定", comment: "OK button")
        static let cancel = NSLocalizedString("common.cancel", value: "取消", comment: "Cancel button")
        static let close = NSLocalizedString("common.close", value: "关闭", comment: "Close button")
        static let loading = NSLocalizedString("common.loading", value: "加载中...", comment: "Loading text")
        static let error = NSLocalizedString("common.error", value: "错误", comment: "Error title")
    }
}
