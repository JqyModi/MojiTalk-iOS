#!/usr/bin/env python3
"""
Generate Localizable.xcstrings file with all translations
"""

import json

# Define all translations
translations = {
    # Login
    "login.title": {
        "zh-Hans": "MOJiTalk",
        "en": "MOJiTalk",
        "ja": "MOJiTalk",
        "ko": "MOJiTalk"
    },
    "login.subtitle": {
        "zh-Hans": "沉浸式日语口语对话",
        "en": "Immersive Japanese Conversation",
        "ja": "没入型日本語会話",
        "ko": "몰입형 일본어 회화"
    },
    "login.email.placeholder": {
        "zh-Hans": "请输入注册邮箱",
        "en": "Enter your email",
        "ja": "メールアドレスを入力",
        "ko": "이메일을 입력하세요"
    },
    "login.otp.placeholder": {
        "zh-Hans": "请输入 6 位验证码",
        "en": "Enter 6-digit code",
        "ja": "6桁のコードを入力",
        "ko": "6자리 코드 입력"
    },
    "login.button.getCode": {
        "zh-Hans": "获取验证码",
        "en": "Get Code",
        "ja": "コードを取得",
        "ko": "코드 받기"
    },
    "login.button.verify": {
        "zh-Hans": "验证并登录",
        "en": "Verify & Login",
        "ja": "確認してログイン",
        "ko": "확인 및 로그인"
    },
    "login.button.back": {
        "zh-Hans": "返回输入邮箱",
        "en": "Back to Email",
        "ja": "メール入力に戻る",
        "ko": "이메일 입력으로 돌아가기"
    },
    "login.divider.or": {
        "zh-Hans": "或",
        "en": "or",
        "ja": "または",
        "ko": "또는"
    },
    "login.terms.agree": {
        "zh-Hans": "登录即代表您已同意",
        "en": "By logging in, you agree to our",
        "ja": "ログインすることで、以下に同意したことになります",
        "ko": "로그인하면 다음에 동의하게 됩니다"
    },
    "login.terms.service": {
        "zh-Hans": "《用户协议》",
        "en": "Terms of Service",
        "ja": "利用規約",
        "ko": "이용약관"
    },
    "login.terms.and": {
        "zh-Hans": "与",
        "en": "and",
        "ja": "と",
        "ko": "및"
    },
    "login.terms.privacy": {
        "zh-Hans": "《隐私政策》",
        "en": "Privacy Policy",
        "ja": "プライバシーポリシー",
        "ko": "개인정보 처리방침"
    },
    "login.error.title": {
        "zh-Hans": "登录失败",
        "en": "Login Failed",
        "ja": "ログイン失敗",
        "ko": "로그인 실패"
    },
    "login.error.unknown": {
        "zh-Hans": "发生未知错误",
        "en": "An unknown error occurred",
        "ja": "不明なエラーが発生しました",
        "ko": "알 수 없는 오류가 발생했습니다"
    },
    "login.stats.prefix": {
        "zh-Hans": "已累计产生",
        "en": "Total practice sessions:",
        "ja": "累計練習回数：",
        "ko": "누적 연습 횟수:"
    },
    "login.stats.suffix": {
        "zh-Hans": "次练习",
        "en": "",
        "ja": "回",
        "ko": "회"
    },
    "login.welcome.1": {
        "zh-Hans": "Ready to learn!",
        "en": "Ready to learn!",
        "ja": "学習を始めましょう！",
        "ko": "학습을 시작하세요!"
    },
    "login.welcome.2": {
        "zh-Hans": "欢迎使用可呆口语！",
        "en": "Welcome to MOJiTalk!",
        "ja": "MOJiTalkへようこそ！",
        "ko": "MOJiTalk에 오신 것을 환영합니다!"
    },
    "login.welcome.3": {
        "zh-Hans": "日本語を話しましょう！",
        "en": "Let's speak Japanese!",
        "ja": "日本語を話しましょう！",
        "ko": "일본어를 말해봅시다!"
    },
    "login.welcome.4": {
        "zh-Hans": "Let's practice together!",
        "en": "Let's practice together!",
        "ja": "一緒に練習しましょう！",
        "ko": "함께 연습해요!"
    },
    "login.welcome.5": {
        "zh-Hans": "一緒に頑張りましょう！",
        "en": "Let's do our best!",
        "ja": "一緒に頑張りましょう！",
        "ko": "함께 힘내요!"
    },
    
    # Login Help
    "loginHelp.title": {
        "zh-Hans": "登录帮助",
        "en": "Login Help",
        "ja": "ログインヘルプ",
        "ko": "로그인 도움말"
    },
    "loginHelp.subtitle": {
        "zh-Hans": "遇到登录问题？查看以下常见解决方案",
        "en": "Having trouble logging in? Check these common solutions",
        "ja": "ログインに問題がありますか？よくある解決策をご確認ください",
        "ko": "로그인에 문제가 있나요? 일반적인 해결 방법을 확인하세요"
    },
    "loginHelp.stillNeedHelp": {
        "zh-Hans": "仍需帮助？",
        "en": "Still need help?",
        "ja": "まだサポートが必要ですか？",
        "ko": "여전히 도움이 필요하신가요?"
    },
    "loginHelp.contactSupport": {
        "zh-Hans": "联系客服",
        "en": "Contact Support",
        "ja": "サポートに連絡",
        "ko": "고객 지원 문의"
    },
    "loginHelp.faq1.question": {
        "zh-Hans": "收不到验证码怎么办？",
        "en": "Not receiving verification code?",
        "ja": "確認コードが届きませんか？",
        "ko": "인증 코드를 받지 못했나요?"
    },
    "loginHelp.faq1.answer": {
        "zh-Hans": "1. 请检查邮箱地址是否正确\n2. 查看垃圾邮件文件夹\n3. 等待 1-2 分钟后重试\n4. 如仍未收到，请联系客服",
        "en": "1. Check if email address is correct\n2. Check spam folder\n3. Wait 1-2 minutes and retry\n4. Contact support if still not received",
        "ja": "1. メールアドレスが正しいか確認してください\n2. 迷惑メールフォルダを確認してください\n3. 1〜2分待ってから再試行してください\n4. それでも届かない場合はサポートにお問い合わせください",
        "ko": "1. 이메일 주소가 올바른지 확인하세요\n2. 스팸 폴더를 확인하세요\n3. 1-2분 기다린 후 다시 시도하세요\n4. 여전히 받지 못한 경우 고객 지원에 문의하세요"
    },
    "loginHelp.faq2.question": {
        "zh-Hans": "Apple 登录失败？",
        "en": "Apple Sign In failed?",
        "ja": "Appleサインインに失敗しましたか？",
        "ko": "Apple 로그인 실패?"
    },
    "loginHelp.faq2.answer": {
        "zh-Hans": "1. 确保您的设备已登录 Apple ID\n2. 检查网络连接是否正常\n3. 在设置中允许 MOJiTalk 使用 Apple 登录\n4. 重启应用后重试",
        "en": "1. Ensure your device is signed in with Apple ID\n2. Check network connection\n3. Allow MOJiTalk to use Apple Sign In in Settings\n4. Restart app and retry",
        "ja": "1. デバイスがApple IDでサインインしていることを確認してください\n2. ネットワーク接続を確認してください\n3. 設定でMOJiTalkがAppleサインインを使用することを許可してください\n4. アプリを再起動して再試行してください",
        "ko": "1. 기기가 Apple ID로 로그인되어 있는지 확인하세요\n2. 네트워크 연결을 확인하세요\n3. 설정에서 MOJiTalk의 Apple 로그인 사용을 허용하세요\n4. 앱을 재시작한 후 다시 시도하세요"
    },
    "loginHelp.faq3.question": {
        "zh-Hans": "验证码过期了？",
        "en": "Verification code expired?",
        "ja": "確認コードの有効期限が切れましたか？",
        "ko": "인증 코드가 만료되었나요?"
    },
    "loginHelp.faq3.answer": {
        "zh-Hans": "验证码有效期为 10 分钟。如果过期，请返回登录页重新获取新的验证码。",
        "en": "Verification codes are valid for 10 minutes. If expired, return to login page and request a new code.",
        "ja": "確認コードの有効期限は10分です。期限切れの場合は、ログインページに戻って新しいコードを取得してください。",
        "ko": "인증 코드는 10분 동안 유효합니다. 만료된 경우 로그인 페이지로 돌아가 새 코드를 요청하세요."
    },
    "loginHelp.faq4.question": {
        "zh-Hans": "如何切换账号？",
        "en": "How to switch accounts?",
        "ja": "アカウントを切り替えるには？",
        "ko": "계정을 전환하는 방법은?"
    },
    "loginHelp.faq4.answer": {
        "zh-Hans": "在个人中心点击\"退出登录\"，然后使用新的邮箱或 Apple ID 登录即可。",
        "en": "Tap \"Logout\" in Profile, then login with a new email or Apple ID.",
        "ja": "プロフィールで「ログアウト」をタップし、新しいメールまたはApple IDでログインしてください。",
        "ko": "프로필에서 \"로그아웃\"을 탭한 다음 새 이메일 또는 Apple ID로 로그인하세요."
    },
    "loginHelp.faq5.question": {
        "zh-Hans": "忘记注册邮箱？",
        "en": "Forgot registered email?",
        "ja": "登録したメールアドレスを忘れましたか？",
        "ko": "등록한 이메일을 잊어버렸나요?"
    },
    "loginHelp.faq5.answer": {
        "zh-Hans": "如果您使用 Apple 登录，可以在 Apple ID 设置中查看关联的邮箱。如果使用邮箱注册，请尝试常用邮箱地址。",
        "en": "If you used Apple Sign In, check associated email in Apple ID settings. If registered with email, try your commonly used addresses.",
        "ja": "Appleサインインを使用した場合は、Apple ID設定で関連付けられたメールを確認してください。メールで登録した場合は、よく使用するメールアドレスを試してください。",
        "ko": "Apple 로그인을 사용한 경우 Apple ID 설정에서 연결된 이메일을 확인하세요. 이메일로 등록한 경우 자주 사용하는 이메일 주소를 시도하세요."
    },
    
    # Onboarding
    "onboarding.step1.title": {
        "zh-Hans": "点击消息播放语音",
        "en": "Tap to Play Audio",
        "ja": "メッセージをタップして音声を再生",
        "ko": "메시지를 탭하여 오디오 재생"
    },
    "onboarding.step1.desc": {
        "zh-Hans": "轻触任意消息气泡，即可听到 AI 老师的真人发音",
        "en": "Tap any message bubble to hear AI teacher's native pronunciation",
        "ja": "メッセージバブルをタップすると、AIティーチャーのネイティブ発音が聞けます",
        "ko": "메시지 버블을 탭하면 AI 선생님의 원어민 발음을 들을 수 있습니다"
    },
    "onboarding.step2.title": {
        "zh-Hans": "长按查看翻译和语法",
        "en": "Long Press for Translation",
        "ja": "長押しで翻訳と文法を表示",
        "ko": "길게 눌러 번역 보기"
    },
    "onboarding.step2.desc": {
        "zh-Hans": "长按消息气泡，可以查看中文翻译和详细的语法解析",
        "en": "Long press message bubble to view translation and detailed grammar analysis",
        "ja": "メッセージバブルを長押しすると、翻訳と詳細な文法解析が表示されます",
        "ko": "메시지 버블을 길게 누르면 번역 및 상세한 문법 분석을 볼 수 있습니다"
    },
    "onboarding.step3.title": {
        "zh-Hans": "语音输入练习口语",
        "en": "Voice Input Practice",
        "ja": "音声入力で会話練習",
        "ko": "음성 입력으로 회화 연습"
    },
    "onboarding.step3.desc": {
        "zh-Hans": "点击麦克风按钮，说出日语句子进行口语练习",
        "en": "Tap microphone button and speak Japanese sentences for speaking practice",
        "ja": "マイクボタンをタップして日本語の文章を話し、会話練習をしましょう",
        "ko": "마이크 버튼을 탭하고 일본어 문장을 말하여 회화 연습을 하세요"
    },
    "onboarding.step4.title": {
        "zh-Hans": "与 Live2D 老师互动",
        "en": "Interact with Live2D Teacher",
        "ja": "Live2Dティーチャーと対話",
        "ko": "Live2D 선생님과 상호작용"
    },
    "onboarding.step4.desc": {
        "zh-Hans": "AI 说话时，消息列表会自动收起，让您看到老师的表情和口型",
        "en": "When AI speaks, message list auto-collapses to show teacher's expressions and lip sync",
        "ja": "AIが話すとき、メッセージリストが自動的に折りたたまれ、先生の表情と口の動きが見えます",
        "ko": "AI가 말할 때 메시지 목록이 자동으로 접혀 선생님의 표정과 입 모양을 볼 수 있습니다"
    },
    "onboarding.button.previous": {
        "zh-Hans": "上一步",
        "en": "Previous",
        "ja": "前へ",
        "ko": "이전"
    },
    "onboarding.button.next": {
        "zh-Hans": "下一步",
        "en": "Next",
        "ja": "次へ",
        "ko": "다음"
    },
    "onboarding.button.start": {
        "zh-Hans": "开始使用",
        "en": "Get Started",
        "ja": "始める",
        "ko": "시작하기"
    },
    "onboarding.button.skip": {
        "zh-Hans": "跳过引导",
        "en": "Skip",
        "ja": "スキップ",
        "ko": "건너뛰기"
    },
    
    # Chat
    "chat.input.placeholder": {
        "zh-Hans": "输入消息...",
        "en": "Type a message...",
        "ja": "メッセージを入力...",
        "ko": "메시지 입력..."
    },
    "chat.loading": {
        "zh-Hans": "召唤中...",
        "en": "Loading...",
        "ja": "読み込み中...",
        "ko": "로딩 중..."
    },
    "chat.menu.translate": {
        "zh-Hans": "翻译",
        "en": "Translate",
        "ja": "翻訳",
        "ko": "번역"
    },
    "chat.menu.analyze": {
        "zh-Hans": "语法精讲",
        "en": "Grammar Analysis",
        "ja": "文法解説",
        "ko": "문법 분석"
    },
    "chat.menu.report": {
        "zh-Hans": "举报",
        "en": "Report",
        "ja": "報告",
        "ko": "신고"
    },
    "chat.menu.retry": {
        "zh-Hans": "重试",
        "en": "Retry",
        "ja": "再試行",
        "ko": "재시도"
    },
    
    # Profile
    "profile.title": {
        "zh-Hans": "个人中心",
        "en": "Profile",
        "ja": "プロフィール",
        "ko": "프로필"
    },
    "profile.autoPlayTTS": {
        "zh-Hans": "自动播放 TTS",
        "en": "Auto Play TTS",
        "ja": "TTS自動再生",
        "ko": "TTS 자동 재생"
    },
    "profile.logout": {
        "zh-Hans": "退出登录",
        "en": "Logout",
        "ja": "ログアウト",
        "ko": "로그아웃"
    },
    "profile.deleteAccount": {
        "zh-Hans": "永久注销账户",
        "en": "Delete Account Permanently",
        "ja": "アカウントを完全に削除",
        "ko": "계정 영구 삭제"
    },
    "profile.delete.confirm.title": {
        "zh-Hans": "确认注销账户",
        "en": "Confirm Account Deletion",
        "ja": "アカウント削除の確認",
        "ko": "계정 삭제 확인"
    },
    "profile.delete.confirm.message": {
        "zh-Hans": "此操作将永久删除您的账号及所有对话记录，且无法恢复。确定要继续吗？",
        "en": "This will permanently delete your account and all conversation history. This cannot be undone. Continue?",
        "ja": "この操作により、アカウントとすべての会話履歴が完全に削除されます。元に戻すことはできません。続行しますか？",
        "ko": "이 작업은 계정과 모든 대화 기록을 영구적으로 삭제합니다. 취소할 수 없습니다. 계속하시겠습니까?"
    },
    "profile.delete.confirm.button": {
        "zh-Hans": "确认注销",
        "en": "Confirm Delete",
        "ja": "削除を確認",
        "ko": "삭제 확인"
    },
    
    # Common
    "common.ok": {
        "zh-Hans": "确定",
        "en": "OK",
        "ja": "OK",
        "ko": "확인"
    },
    "common.cancel": {
        "zh-Hans": "取消",
        "en": "Cancel",
        "ja": "キャンセル",
        "ko": "취소"
    },
    "common.close": {
        "zh-Hans": "关闭",
        "en": "Close",
        "ja": "閉じる",
        "ko": "닫기"
    },
    "common.loading": {
        "zh-Hans": "加载中...",
        "en": "Loading...",
        "ja": "読み込み中...",
        "ko": "로딩 중..."
    },
    "common.error": {
        "zh-Hans": "错误",
        "en": "Error",
        "ja": "エラー",
        "ko": "오류"
    }
}

# Generate xcstrings structure
xcstrings = {
    "sourceLanguage": "zh-Hans",
    "strings": {},
    "version": "1.0"
}

for key, langs in translations.items():
    xcstrings["strings"][key] = {
        "extractionState": "manual",
        "localizations": {}
    }
    
    for lang, value in langs.items():
        xcstrings["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": value
            }
        }

# Write to file
output_path = "/Users/modi/ai_completion/MojiTalk-iOS/MojiTalk/Resources/Localizable.xcstrings"
with open(output_path, 'w', encoding='utf-8') as f:
    json.dump(xcstrings, f, ensure_ascii=False, indent=2)

print(f"✅ Generated {output_path}")
print(f"📊 Total strings: {len(translations)}")
print(f"🌍 Languages: zh-Hans, en, ja, ko")
