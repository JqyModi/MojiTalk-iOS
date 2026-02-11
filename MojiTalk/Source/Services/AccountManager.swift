import Foundation
import Combine
import Supabase

class AccountManager: ObservableObject {
    static let shared = AccountManager()
    
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?
    @Published var profile: Profile?
    @Published var isInitializing: Bool = true
    
    private let client = SupabaseClient(
        supabaseURL: SupabaseConfig.url,
        supabaseKey: SupabaseConfig.anonKey
    )
    
    private var authSubscription: Task<Void, Never>?
    
    struct Profile: Codable {
        let id: UUID
        var username: String?
        var fullName: String?
        var avatarUrl: String?
        var email: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case username
            case fullName = "full_name"
            case avatarUrl = "avatar_url"
            case email
        }
    }
    
    private init() {
        // 1. Initial check
        Task {
            if let session = try? await client.auth.session {
                await MainActor.run {
                    self.currentUser = session.user
                    self.isLoggedIn = true
                    self.fetchProfile()
                    self.isInitializing = false
                }
            } else {
                await MainActor.run {
                    self.isInitializing = false
                }
            }
        }
        
        // 2. Listen for auth changes
        authSubscription = Task { [weak self] in
            guard let self = self else { return }
            for await (event, session) in self.client.auth.authStateChanges {
                await MainActor.run { [weak self] in
                    print("Auth Event: \(event)")
                    self?.currentUser = session?.user
                    self?.isLoggedIn = session != nil
                    
                    if event == .signedIn {
                        self?.fetchProfile()
                    } else if event == .signedOut {
                        self?.profile = nil
                    }
                }
            }
        }
    }
    
    deinit {
        authSubscription?.cancel()
    }
    
    @MainActor
    func signInWithApple(idToken: String, nonce: String?) async throws {
        _ = try await client.auth.signInWithIdToken(
            credentials: .init(
                provider: .apple,
                idToken: idToken,
                nonce: nonce
            )
        )
    }
    
    @MainActor
    func sendOTP(email: String) async throws {
        try await client.auth.signInWithOTP(
            email: email,
            redirectTo: nil,
            shouldCreateUser: true
        )
    }
    
    @MainActor
    func verifyOTP(email: String, token: String) async throws {
        // For 6-digit numeric codes:
        // If the user is existing, Supabase sends a 'login' OTP.
        // If the user is new, Supabase sends a 'signup' OTP.
        // We try login first, then signup as a fallback.
        do {
            try await client.auth.verifyOTP(
                email: email,
                token: token,
                type: .magiclink
            )
        } catch {
            try await client.auth.verifyOTP(
                email: email,
                token: token,
                type: .signup
            )
        }
    }
    
    @MainActor
    func fetchProfile() {
        guard let userId = currentUser?.id else { return }
        
        Task {
            do {
                let profile: Profile = try await client
                    .from("profiles")
                    .select()
                    .eq("id", value: userId)
                    .single()
                    .execute()
                    .value
                
                await MainActor.run {
                    self.profile = profile
                    // If no avatar, assign a random one (logic to be implemented)
                    if profile.avatarUrl == nil {
                        self.assignRandomAvatar()
                    }
                }
            } catch {
                print("Error fetching profile: \(error)")
            }
        }
    }
    
    @MainActor
    private func assignRandomAvatar() {
        guard let userId = currentUser?.id else { return }
        let avatars = ["avatar_1", "avatar_2", "avatar_3", "avatar_4", "avatar_5"]
        let randomAvatar = avatars.randomElement() ?? "avatar_1"
        
        Task {
            do {
                try await client
                    .from("profiles")
                    .update(["avatar_url": randomAvatar])
                    .eq("id", value: userId)
                    .execute()
                
                await MainActor.run {
                    self.profile?.avatarUrl = randomAvatar
                }
            } catch {
                print("Error assigning random avatar: \(error)")
            }
        }
    }
    
    func logout() {
        Task {
            try? await client.auth.signOut()
        }
    }
    
    func deleteAccount() async throws {
        // AI Compliance: Guideline 5.1.1(v) - Account Deletion
        // Integration with Supabase Edge Functions or RPC would go here.
        // For now, we sign out and let the ViewModel handle local data wipe.
        try await client.auth.signOut()
    }
}
