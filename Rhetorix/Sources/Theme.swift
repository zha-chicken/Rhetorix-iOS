import SwiftUI

enum RhetorixColors {
    static let background = Color(red: 0.075, green: 0.141, blue: 0.169)
    static let backgroundDeep = Color(red: 0.055, green: 0.102, blue: 0.125)
    static let glass = Color.white.opacity(0.085)
    static let glassStrong = Color.white.opacity(0.145)
    static let border = Color.white.opacity(0.14)
    static let textPrimary = Color.white.opacity(0.94)
    static let textSecondary = Color.white.opacity(0.66)
    static let textTertiary = Color.white.opacity(0.44)
    static let cyan = Color(red: 0.54, green: 0.88, blue: 0.89)
    static let amber = Color(red: 0.96, green: 0.68, blue: 0.46)
    static let peach = Color(red: 0.95, green: 0.55, blue: 0.48)
    static let green = Color(red: 0.62, green: 0.76, blue: 0.69)
    static let salmon = Color(red: 0.90, green: 0.45, blue: 0.42)
}

struct AppBackdrop: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [RhetorixColors.backgroundDeep, RhetorixColors.background],
                startPoint: .top,
                endPoint: .bottom
            )
            RadialGradient(
                colors: [RhetorixColors.cyan.opacity(0.18), .clear],
                center: .topLeading,
                startRadius: 20,
                endRadius: 360
            )
            RadialGradient(
                colors: [RhetorixColors.amber.opacity(0.14), .clear],
                center: .topTrailing,
                startRadius: 30,
                endRadius: 420
            )
        }
        .ignoresSafeArea()
    }
}

struct GlassCard<Content: View>: View {
    var accent: Color = RhetorixColors.cyan
    var padding: CGFloat = 14
    var content: Content

    init(accent: Color = RhetorixColors.cyan, padding: CGFloat = 14, @ViewBuilder content: () -> Content) {
        self.accent = accent
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(RhetorixColors.glass)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(LinearGradient(colors: [accent.opacity(0.38), RhetorixColors.border], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
            )
    }
}

struct SectionTitle: View {
    var text: String
    var body: some View {
        Text(text)
            .font(.headline)
            .foregroundStyle(RhetorixColors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct AIDisclaimer: View {
    var color: Color = RhetorixColors.textTertiary
    var body: some View {
        Text(aiDisclaimer)
            .font(.caption2)
            .italic()
            .foregroundStyle(color)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension View {
    func appScreen() -> some View {
        self
            .foregroundStyle(RhetorixColors.textPrimary)
            .background(AppBackdrop())
            .scrollContentBackground(.hidden)
    }
}

