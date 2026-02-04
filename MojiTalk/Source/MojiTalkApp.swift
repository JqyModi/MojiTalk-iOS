import SwiftUI
import Combine

@main
struct MojiTalkApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var accountManager = AccountManager.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if accountManager.isLoggedIn {
                    ChatView()
                        .transition(.opacity)
                } else {
                    LoginView()
                        .transition(.opacity)
                }
            }
            .preferredColorScheme(.dark)
            .environmentObject(appState)
            .animation(.easeInOut, value: accountManager.isLoggedIn)
        }
    }
}

class AppState: ObservableObject {
    // 基础全局状态管理
    @Published var isUserLoggedIn: Bool = false
}
