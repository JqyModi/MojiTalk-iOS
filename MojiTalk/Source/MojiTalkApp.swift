import SwiftUI
import Combine
import MojiLive2D

@main
struct MojiTalkApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var accountManager = AccountManager.shared

    init() {
        // Initialize Live2D Framework
        L2DCubism.setup()
        // Unzip models to Documents directory
        MOJiL2DFileManager.unzipL2DFilesIfNeeded()
    }

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
