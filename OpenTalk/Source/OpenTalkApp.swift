import SwiftUI
import Combine
import OpenLive2D

@main
struct OpenTalkApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var accountManager = AccountManager.shared
    @ObservedObject private var langManager = LanguageManager.shared

    init() {
        // Initialize Live2D Framework
        L2DCubism.setup()
        // Unzip models to Documents directory
        OpenL2DFileManager.unzipL2DFilesIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if accountManager.isInitializing {
                    // Initializing state: show a blank dark background or splash
                    DesignSystem.Colors.primary
                        .ignoresSafeArea()
                } else if accountManager.isLoggedIn {
                    ChatView()
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.95)),
                            removal: .opacity.combined(with: .scale(scale: 1.05))
                        ))
                        .zIndex(1)
                } else {
                    LoginView()
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 1.05)),
                            removal: .opacity.combined(with: .scale(scale: 0.95))
                        ))
                        .zIndex(0)
                }
            }
            .preferredColorScheme(.dark)
            .environmentObject(appState)
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: accountManager.isLoggedIn)
            .animation(.easeInOut, value: accountManager.isInitializing)
            .id(langManager.currentLanguage) // Force entire view hierarchy rebuild on language change
        }
    }
}

class AppState: ObservableObject {
    // 基础全局状态管理
    @Published var isUserLoggedIn: Bool = false
}
