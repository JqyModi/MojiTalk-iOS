import SwiftUI

/// Onboarding overlay view to guide first-time users through chat features
struct OnboardingOverlayView: View {
    @Binding var isPresented: Bool
    @State private var currentStep = 0
    
    private let steps: [OnboardingStep] = [
        OnboardingStep(
            title: LocalizedString.Onboarding.step1Title,
            description: LocalizedString.Onboarding.step1Desc,
            icon: "play.circle.fill",
            highlightArea: .messageBubble
        ),
        OnboardingStep(
            title: LocalizedString.Onboarding.step2Title,
            description: LocalizedString.Onboarding.step2Desc,
            icon: "text.magnifyingglass",
            highlightArea: .messageBubble
        ),
        OnboardingStep(
            title: LocalizedString.Onboarding.step3Title,
            description: LocalizedString.Onboarding.step3Desc,
            icon: "mic.circle.fill",
            highlightArea: .voiceButton
        ),
        OnboardingStep(
            title: LocalizedString.Onboarding.step4Title,
            description: LocalizedString.Onboarding.step4Desc,
            icon: "person.wave.2.fill",
            highlightArea: .live2dCharacter
        )
    ]
    
    var body: some View {
        ZStack {
            // Semi-transparent overlay
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture {
                    // Tap to skip
                    if currentStep < steps.count - 1 {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            currentStep += 1
                        }
                    } else {
                        dismissOnboarding()
                    }
                }
            
            VStack(spacing: 0) {
                Spacer()
                
                // Highlight indicator (visual cue for where to look)
                highlightIndicator(for: steps[currentStep].highlightArea)
                
                Spacer()
                
                // Instruction card
                VStack(spacing: 20) {
                    // Icon
                    Image(systemName: steps[currentStep].icon)
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(DesignSystem.Colors.accent)
                    
                    // Title
                    Text(steps[currentStep].title)
                        .font(DesignSystem.Fonts.heading(size: 22))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    // Description
                    Text(steps[currentStep].description)
                        .font(DesignSystem.Fonts.body(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    // Progress dots
                    HStack(spacing: 8) {
                        ForEach(0..<steps.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentStep ? DesignSystem.Colors.accent : Color.white.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.top, 12)
                    
                    // Action buttons
                    HStack(spacing: 16) {
                        if currentStep > 0 {
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    currentStep -= 1
                                }
                            }) {
                                Text(LocalizedString.Onboarding.previous)
                                    .font(DesignSystem.Fonts.body(size: 16))
                                    .foregroundColor(.white.opacity(0.6))
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(12)
                            }
                        }
                        
                        Button(action: {
                            if currentStep < steps.count - 1 {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    currentStep += 1
                                }
                            } else {
                                dismissOnboarding()
                            }
                        }) {
                            Text(currentStep < steps.count - 1 ? LocalizedString.Onboarding.next : LocalizedString.Onboarding.start)
                                .font(DesignSystem.Fonts.heading(size: 16))
                                .foregroundColor(DesignSystem.Colors.primary)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 12)
                                .background(DesignSystem.Colors.accent)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.top, 8)
                    
                    // Skip button
                    Button(action: dismissOnboarding) {
                        Text(LocalizedString.Onboarding.skip)
                            .font(DesignSystem.Fonts.body(size: 14))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .padding(.top, 12)
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(DesignSystem.Colors.primary.opacity(0.95))
                        .shadow(color: .black.opacity(0.3), radius: 20)
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 60)
            }
        }
        .transition(.opacity)
    }
    
    @ViewBuilder
    private func highlightIndicator(for area: HighlightArea) -> some View {
        switch area {
        case .messageBubble:
            VStack {
                Spacer()
                    .frame(height: 200)
                HStack {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(DesignSystem.Colors.accent, lineWidth: 3)
                        .frame(width: 250, height: 80)
                        .padding(.leading, 40)
                    Spacer()
                }
                Spacer()
            }
            
        case .voiceButton:
            VStack {
                Spacer()
                Circle()
                    .stroke(DesignSystem.Colors.accent, lineWidth: 3)
                    .frame(width: 60, height: 60)
                    .padding(.bottom, 100)
            }
            
        case .live2dCharacter:
            VStack {
                Circle()
                    .stroke(DesignSystem.Colors.accent, lineWidth: 3)
                    .frame(width: 200, height: 200)
                    .padding(.top, 150)
                Spacer()
            }
        }
    }
    
    private func dismissOnboarding() {
        withAnimation(.easeOut(duration: 0.3)) {
            isPresented = false
        }
        // Mark as completed in UserDefaults
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
    }
}

// MARK: - Supporting Types
struct OnboardingStep {
    let title: String
    let description: String
    let icon: String
    let highlightArea: HighlightArea
}

enum HighlightArea {
    case messageBubble
    case voiceButton
    case live2dCharacter
}

// MARK: - Preview
struct OnboardingOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.ignoresSafeArea()
            OnboardingOverlayView(isPresented: .constant(true))
        }
    }
}
