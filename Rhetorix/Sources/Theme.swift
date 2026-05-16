import SwiftUI
import UIKit

enum RhetorixColors {
    static let background = adaptive(
        light: UIColor(red: 1.00, green: 0.965, blue: 0.972, alpha: 1.0),
        dark: UIColor(red: 0.075, green: 0.141, blue: 0.169, alpha: 1.0)
    )
    static let backgroundDeep = adaptive(
        light: UIColor(red: 1.00, green: 0.988, blue: 0.980, alpha: 1.0),
        dark: UIColor(red: 0.055, green: 0.102, blue: 0.125, alpha: 1.0)
    )
    static let glass = adaptive(
        light: UIColor(red: 1.00, green: 0.925, blue: 0.945, alpha: 0.66),
        dark: UIColor(white: 1.0, alpha: 0.085)
    )
    static let glassStrong = adaptive(
        light: UIColor(red: 1.00, green: 0.875, blue: 0.905, alpha: 0.78),
        dark: UIColor(white: 1.0, alpha: 0.145)
    )
    static let border = adaptive(
        light: UIColor(red: 0.95, green: 0.47, blue: 0.62, alpha: 0.18),
        dark: UIColor(white: 1.0, alpha: 0.14)
    )
    static let textPrimary = adaptive(
        light: UIColor(red: 0.135, green: 0.105, blue: 0.115, alpha: 0.96),
        dark: UIColor(white: 1.0, alpha: 0.94)
    )
    static let textSecondary = adaptive(
        light: UIColor(red: 0.36, green: 0.30, blue: 0.33, alpha: 0.76),
        dark: UIColor(white: 1.0, alpha: 0.66)
    )
    static let textTertiary = adaptive(
        light: UIColor(red: 0.54, green: 0.45, blue: 0.49, alpha: 0.64),
        dark: UIColor(white: 1.0, alpha: 0.44)
    )
    static let cyan = adaptive(
        light: UIColor(red: 0.94, green: 0.25, blue: 0.47, alpha: 1.0),
        dark: UIColor(red: 0.54, green: 0.88, blue: 0.89, alpha: 1.0)
    )
    static let amber = adaptive(
        light: UIColor(red: 0.96, green: 0.54, blue: 0.26, alpha: 1.0),
        dark: UIColor(red: 0.96, green: 0.68, blue: 0.46, alpha: 1.0)
    )
    static let peach = adaptive(
        light: UIColor(red: 0.96, green: 0.36, blue: 0.50, alpha: 1.0),
        dark: UIColor(red: 0.95, green: 0.55, blue: 0.48, alpha: 1.0)
    )
    static let green = adaptive(
        light: UIColor(red: 0.19, green: 0.66, blue: 0.58, alpha: 1.0),
        dark: UIColor(red: 0.62, green: 0.76, blue: 0.69, alpha: 1.0)
    )
    static let salmon = adaptive(
        light: UIColor(red: 0.92, green: 0.28, blue: 0.42, alpha: 1.0),
        dark: UIColor(red: 0.90, green: 0.45, blue: 0.42, alpha: 1.0)
    )
    static func adaptive(light: UIColor, dark: UIColor) -> Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .light ? light : dark
        })
    }
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
                colors: [RhetorixColors.peach.opacity(0.14), .clear],
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
