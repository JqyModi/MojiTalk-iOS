import SwiftUI

/// OpenTalk Design System - Liquid Glass Style
enum DesignSystem {
    
    enum Colors {
        static let primary = Color(hex: "1C1917") // Premium Black
        static let secondary = Color(hex: "44403C") // Stone
        static let accent = Color(hex: "CA8A04") // Flowing Gold
        static let surface = Color(hex: "FAFAF9").opacity(0.8) // Porcelain + Opacity
        static let contrast = Color(hex: "0C0A09") // Ink Black
        
        static let textPrimary = Color("1C1917")
        static let textSecondary = Color("44403C")
    }
    
    enum Fonts {
        // Fallback to system fonts if custom ones aren't available yet
        static func heading(size: CGFloat) -> Font {
            .custom("NotoSerifJP-Bold", size: size).weight(.bold)
        }
        
        static func body(size: CGFloat) -> Font {
            .custom("NotoSansJP-Medium", size: size)
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct LiquidLoadingView: View {
    @State private var isAnimating = false
    private let color: Color
    
    init(color: Color = DesignSystem.Colors.accent) {
        self.color = color
    }
    
    public var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                    .opacity(isAnimating ? 1.0 : 0.4)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever(autoreverses: true)
                        .delay(0.15 * Double(index)),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - View Extensions for Keyboard Handling
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    /// Adds tap to dismiss and interactive scroll dismissal (if applicable)
    func unifiedKeyboardDismiss() -> some View {
        self.onTapGesture {
            hideKeyboard()
        }
    }
}
