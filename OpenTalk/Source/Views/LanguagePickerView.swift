import SwiftUI

// MARK: - Language Picker View

/// A sheet-style language selector that can be embedded in UserProfileView.
/// Changing language takes effect instantly without restarting the app.
struct LanguagePickerView: View {
    @ObservedObject private var langManager = LanguageManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.Colors.primary.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header description
                    Text(LocalizedString.Language.subtitle)
                        .font(DesignSystem.Fonts.body(size: 13))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Language list
                    VStack(spacing: 1) {
                        ForEach(AppLanguage.allCases) { language in
                            LanguageRow(
                                language: language,
                                isSelected: langManager.currentLanguage == language
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    langManager.setLanguage(language)
                                }
                                // Dismiss after a short delay so user sees the selection
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    dismiss()
                                }
                            }
                        }
                    }
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(16)
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
            }
            .navigationTitle(LocalizedString.Language.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Language Row

private struct LanguageRow: View {
    let language: AppLanguage
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Text(language.flag)
                    .font(.system(size: 28))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(language.displayName)
                        .font(DesignSystem.Fonts.heading(size: 16))
                        .foregroundColor(.white)
                    
                    if language == .system {
                        Text(LocalizedString.Language.systemDesc)
                            .font(DesignSystem.Fonts.body(size: 12))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(DesignSystem.Colors.accent)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Compact Language Button (for embedding in Profile)

/// A compact row for embedding in UserProfileView settings list.
struct LanguageSettingRow: View {
    @ObservedObject private var langManager = LanguageManager.shared
    @State private var showPicker = false
    
    var body: some View {
        Button(action: { showPicker = true }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizedString.Profile.language)
                        .font(DesignSystem.Fonts.heading(size: 16))
                        .foregroundColor(.white)
                    Text(langManager.currentLanguage.flag + " " + langManager.currentLanguage.displayName)
                        .font(DesignSystem.Fonts.body(size: 12))
                        .foregroundColor(.white.opacity(0.4))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding()
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showPicker) {
            LanguagePickerView()
        }
    }
}

// MARK: - Preview

#Preview {
    LanguagePickerView()
}
