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
    static let primaryActionEnd = adaptive(
        light: UIColor(red: 0.86, green: 0.14, blue: 0.34, alpha: 1.0),
        dark: UIColor(red: 0.35, green: 0.73, blue: 0.76, alpha: 1.0)
    )
    static let primaryActionForeground = adaptive(
        light: UIColor.white,
        dark: UIColor(red: 0.035, green: 0.12, blue: 0.14, alpha: 1.0)
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

struct PrimaryActionLabel: View {
    var title: String
    var detail: String
    var systemImage: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .bold))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(RhetorixColors.primaryActionForeground.opacity(0.12))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .lineLimit(1)
                Text(detail)
                    .font(.caption)
                    .fontWeight(.medium)
                    .opacity(0.72)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .frame(width: 30, height: 30)
                .background(
                    Circle()
                        .fill(RhetorixColors.primaryActionForeground.opacity(0.10))
                )
        }
        .foregroundStyle(RhetorixColors.primaryActionForeground)
        .multilineTextAlignment(.leading)
    }
}

struct RhetorixPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, minHeight: 64)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [RhetorixColors.cyan, RhetorixColors.primaryActionEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.22), lineWidth: 1)
            }
            .shadow(
                color: RhetorixColors.cyan.opacity(configuration.isPressed ? 0.10 : 0.24),
                radius: configuration.isPressed ? 5 : 14,
                y: configuration.isPressed ? 2 : 7
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .opacity(isEnabled ? 1 : 0.42)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == RhetorixPrimaryButtonStyle {
    static var rhetorixPrimary: RhetorixPrimaryButtonStyle { RhetorixPrimaryButtonStyle() }
}

extension View {
    func appScreen() -> some View {
        self
            .foregroundStyle(RhetorixColors.textPrimary)
            .background(AppBackdrop())
            .scrollContentBackground(.hidden)
    }
}
