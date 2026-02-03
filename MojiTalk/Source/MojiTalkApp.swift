import SwiftUI

@main
struct MojiTalkApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}

class AppState: ObservableObject {
    // 基础全局状态管理
    @Published var isUserLoggedIn: Bool = false
}
