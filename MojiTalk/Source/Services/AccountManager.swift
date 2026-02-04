import Foundation
import Combine

class AccountManager: ObservableObject {
    static let shared = AccountManager()
    
    @Published var isLoggedIn: Bool = false
    @Published var currentUserToken: String?
    
    private init() {
        // Check for existing session on launch
        if let token = UserDefaults.standard.string(forKey: "user_token") {
            self.currentUserToken = token
            self.isLoggedIn = true
        }
    }
    
    func login() {
        // Simulate network login
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let mockToken = UUID().uuidString
            self.currentUserToken = mockToken
            self.isLoggedIn = true
            UserDefaults.standard.set(mockToken, forKey: "user_token")
            print("User Logged In")
        }
    }
    
    func logout() {
        isLoggedIn = false
        currentUserToken = nil
        UserDefaults.standard.removeObject(forKey: "user_token")
        print("User Logged Out")
    }
}
