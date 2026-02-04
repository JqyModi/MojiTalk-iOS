import Foundation
import Combine

class AccountManager: ObservableObject {
    static let shared = AccountManager()
    
    @Published var isLoggedIn: Bool = false
    @Published var currentUserToken: String?
    @Published var tokenExpirationDate: Date?
    
    private init() {
        // Check for existing session and expiration on launch
        if let token = UserDefaults.standard.string(forKey: "user_token"),
           let expiration = UserDefaults.standard.object(forKey: "token_expiration") as? Date {
            
            if expiration > Date() {
                self.currentUserToken = token
                self.tokenExpirationDate = expiration
                self.isLoggedIn = true
                print("Session resumed. Expires at: \(expiration)")
            } else {
                logout()
                print("Session expired")
            }
        }
    }
    
    func login(account: String = "TestUser") {
        isLoggedIn = false // Show loading if needed in UI
        
        // Simulate real network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let mockToken = "MTK_" + UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(16).lowercased()
            let expiration = Date().addingTimeInterval(3600 * 24 * 7) // 7 days expiration
            
            self.currentUserToken = mockToken
            self.tokenExpirationDate = expiration
            self.isLoggedIn = true
            
            UserDefaults.standard.set(mockToken, forKey: "user_token")
            UserDefaults.standard.set(expiration, forKey: "token_expiration")
            
            print("User Logged In: \(account), Token: \(mockToken)")
        }
    }
    
    func logout() {
        isLoggedIn = false
        currentUserToken = nil
        tokenExpirationDate = nil
        UserDefaults.standard.removeObject(forKey: "user_token")
        UserDefaults.standard.removeObject(forKey: "token_expiration")
        MessageStorage.shared.clearHistory() // Optional: clear history on logout for privacy
        print("User Logged Out")
    }
}
