import SwiftUI
import UIKit

enum RhetorixColors {
    // Chrome. Dark is a deep navy that matches the classical app icon;
    // light is a warm paper-white sharing the same identity.
    static let background = adaptive(
        light: UIColor(red: 0.984, green: 0.976, blue: 0.958, alpha: 1.0),
        dark: UIColor(red: 0.075, green: 0.106, blue: 0.157, alpha: 1.0)
    )
    static let backgroundDeep = adaptive(
        light: UIColor(red: 0.992, green: 0.988, blue: 0.976, alpha: 1.0),
        dark: UIColor(red: 0.051, green: 0.075, blue: 0.118, alpha: 1.0)
    )
    static let glass = adaptive(
        light: UIColor(red: 0.972, green: 0.960, blue: 0.930, alpha: 0.72),
        dark: UIColor(white: 1.0, alpha: 0.085)
    )
    static let glassStrong = adaptive(
        light: UIColor(red: 0.955, green: 0.935, blue: 0.885, alpha: 0.85),
        dark: UIColor(white: 1.0, alpha: 0.145)
    )
    static let border = adaptive(
        light: UIColor(red: 0.45, green: 0.36, blue: 0.16, alpha: 0.18),
        dark: UIColor(white: 1.0, alpha: 0.14)
    )
    static let textPrimary = adaptive(
        light: UIColor(red: 0.15, green: 0.13, blue: 0.09, alpha: 0.96),
        dark: UIColor(white: 1.0, alpha: 0.94)
    )
    static let textSecondary = adaptive(
        light: UIColor(red: 0.38, green: 0.34, blue: 0.26, alpha: 0.78),
        dark: UIColor(white: 1.0, alpha: 0.66)
    )
    static let textTertiary = adaptive(
        light: UIColor(red: 0.52, green: 0.47, blue: 0.38, alpha: 0.62),
        dark: UIColor(white: 1.0, alpha: 0.44)
    )

    // Roles: one brand accent plus three quiet semantic colors. Both themes
    // resolve each role to the same hue so the product has one identity.
    static let brand = adaptive(
        light: UIColor(red: 0.58, green: 0.42, blue: 0.12, alpha: 1.0),
        dark: UIColor(red: 0.90, green: 0.75, blue: 0.44, alpha: 1.0)
    )
    static let success = adaptive(
        light: UIColor(red: 0.12, green: 0.58, blue: 0.42, alpha: 1.0),
        dark: UIColor(red: 0.42, green: 0.78, blue: 0.60, alpha: 1.0)
    )
    // Warning leans terracotta so it keeps clear distance from the gold brand.
    static let warning = adaptive(
        light: UIColor(red: 0.78, green: 0.42, blue: 0.18, alpha: 1.0),
        dark: UIColor(red: 0.93, green: 0.60, blue: 0.36, alpha: 1.0)
    )
    static let danger = adaptive(
        light: UIColor(red: 0.78, green: 0.24, blue: 0.27, alpha: 1.0),
        dark: UIColor(red: 0.92, green: 0.49, blue: 0.45, alpha: 1.0)
    )

    // Legacy hue names used across screens; they resolve to the role tokens
    // above so no surface can drift off-palette.
    static let cyan = brand
    static let amber = warning
    static let peach = warning
    static let green = success
    static let salmon = danger

    static let primaryActionEnd = adaptive(
        light: UIColor(red: 0.47, green: 0.33, blue: 0.08, alpha: 1.0),
        dark: UIColor(red: 0.76, green: 0.58, blue: 0.28, alpha: 1.0)
    )
    static let primaryActionForeground = adaptive(
        light: UIColor.white,
        dark: UIColor(red: 0.12, green: 0.09, blue: 0.03, alpha: 1.0)
    )
    static func adaptive(light: UIColor, dark: UIColor) -> Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .light ? light : dark
        })
    }
}

// The ambient glow is reserved for the live debate screen so atmosphere
// signals round tension; every other screen keeps the flat gradient.
struct AppBackdrop: View {
    var isLive: Bool = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [RhetorixColors.backgroundDeep, RhetorixColors.background],
                startPoint: .top,
                endPoint: .bottom
            )
            if isLive {
                RadialGradient(
                    colors: [RhetorixColors.brand.opacity(0.16), .clear],
                    center: .top,
                    startRadius: 24,
                    endRadius: 420
                )
            }
        }
        .ignoresSafeArea()
    }
}

// Cards are neutral by default; the tinted accent border is an emphasis
// state reserved for the few surfaces that carry live round pressure.
struct GlassCard<Content: View>: View {
    var accent: Color = RhetorixColors.brand
    var emphasized: Bool = false
    var padding: CGFloat = 14
    var content: Content

    init(accent: Color = RhetorixColors.brand, emphasized: Bool = false, padding: CGFloat = 14, @ViewBuilder content: () -> Content) {
        self.accent = accent
        self.emphasized = emphasized
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
                    .stroke(borderStyle, lineWidth: 1)
            )
    }

    private var borderStyle: AnyShapeStyle {
        if emphasized {
            return AnyShapeStyle(LinearGradient(colors: [accent.opacity(0.45), RhetorixColors.border], startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        return AnyShapeStyle(RhetorixColors.border)
    }
}

struct AIMarkdownText: View {
    var content: String

    init(_ content: String) {
        self.content = content
    }

    var body: some View {
        Text(Self.attributed(from: content))
    }

    static func attributed(from raw: String) -> AttributedString {
        let normalized = normalizeBlocks(raw)
        if let parsed = try? AttributedString(
            markdown: normalized,
            options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        ) {
            return parsed
        }
        return AttributedString(raw)
    }

    // Inline-only markdown keeps newlines but drops block syntax, so headings
    // and bullets are rewritten into inline equivalents before parsing.
    private static func normalizeBlocks(_ text: String) -> String {
        text.components(separatedBy: "\n").map { line -> String in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if let match = trimmed.range(of: "^#{1,6}\\s+", options: .regularExpression) {
                return "**\(trimmed[match.upperBound...])**"
            }
            if let match = trimmed.range(of: "^[-*+]\\s+", options: .regularExpression) {
                return "• \(trimmed[match.upperBound...])"
            }
            return line
        }.joined(separator: "\n")
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

struct RhetorixChoiceChip: View {
    var label: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline.weight(isSelected ? .bold : .medium))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .foregroundStyle(isSelected ? RhetorixColors.textPrimary : RhetorixColors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .padding(.horizontal, 6)
                .background(
                    Capsule().fill(isSelected ? RhetorixColors.glassStrong : RhetorixColors.glass)
                )
                .overlay(
                    Capsule().stroke(
                        isSelected ? RhetorixColors.cyan.opacity(0.55) : RhetorixColors.border,
                        lineWidth: isSelected ? 1.5 : 1
                    )
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .animation(.easeOut(duration: 0.15), value: isSelected)
    }
}

struct RhetorixChoiceChips<SelectionValue: Hashable>: View {
    var title: String?
    var options: [(value: SelectionValue, label: String)]
    @Binding var selection: SelectionValue

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title {
                Text(title)
                    .font(.caption.bold())
                    .foregroundStyle(RhetorixColors.textTertiary)
            }
            HStack(spacing: 8) {
                ForEach(Array(options.enumerated()), id: \.offset) { _, option in
                    RhetorixChoiceChip(label: option.label, isSelected: option.value == selection) {
                        selection = option.value
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct RhetorixChoiceList<SelectionValue: Hashable>: View {
    var options: [(value: SelectionValue, label: String)]
    @Binding var selection: SelectionValue

    var body: some View {
        VStack(spacing: 8) {
            ForEach(Array(options.enumerated()), id: \.offset) { _, option in
                let isSelected = option.value == selection
                Button {
                    selection = option.value
                } label: {
                    HStack {
                        Text(option.label)
                            .font(.subheadline.weight(isSelected ? .bold : .medium))
                            .foregroundStyle(isSelected ? RhetorixColors.textPrimary : RhetorixColors.textSecondary)
                        Spacer()
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(isSelected ? RhetorixColors.cyan : RhetorixColors.textTertiary)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(isSelected ? RhetorixColors.glassStrong : RhetorixColors.glass)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(
                                isSelected ? RhetorixColors.cyan.opacity(0.55) : RhetorixColors.border,
                                lineWidth: isSelected ? 1.5 : 1
                            )
                    )
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
                .animation(.easeOut(duration: 0.15), value: isSelected)
            }
        }
    }
}

struct RhetorixFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(RhetorixColors.glassStrong)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(RhetorixColors.border, lineWidth: 1)
            )
    }
}

struct RhetorixMenuField<SelectionValue: Hashable>: View {
    var title: String
    var options: [(value: SelectionValue, label: String)]
    @Binding var selection: SelectionValue

    private var selectedLabel: String {
        options.first { $0.value == selection }?.label ?? ""
    }

    var body: some View {
        Menu {
            Picker(title, selection: $selection) {
                ForEach(Array(options.enumerated()), id: \.offset) { _, option in
                    Text(option.label).tag(option.value)
                }
            }
        } label: {
            HStack(spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(RhetorixColors.textSecondary)
                Spacer(minLength: 12)
                Text(selectedLabel)
                    .font(.subheadline.bold())
                    .foregroundStyle(RhetorixColors.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption2.bold())
                    .foregroundStyle(RhetorixColors.textTertiary)
            }
            .rhetorixField()
        }
    }
}

extension View {
    func rhetorixField() -> some View {
        modifier(RhetorixFieldStyle())
    }

    func appScreen(live: Bool = false) -> some View {
        self
            .foregroundStyle(RhetorixColors.textPrimary)
            .background(AppBackdrop(isLive: live))
            .scrollContentBackground(.hidden)
    }
}
