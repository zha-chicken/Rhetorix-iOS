import SwiftUI
import UIKit

enum RhetorixColors {
    // Chrome. Dark is a neutral near-black where cards read as elevated
    // surfaces (lighter fills, hairline borders) rather than tinted glass;
    // light is a cool paper-white sharing the same teal identity.
    static let background = adaptive(
        light: UIColor(red: 0.972, green: 0.980, blue: 0.984, alpha: 1.0),
        dark: UIColor(red: 0.055, green: 0.063, blue: 0.075, alpha: 1.0)
    )
    static let backgroundDeep = adaptive(
        light: UIColor(red: 0.988, green: 0.992, blue: 0.994, alpha: 1.0),
        dark: UIColor(red: 0.043, green: 0.051, blue: 0.063, alpha: 1.0)
    )
    static let glass = adaptive(
        light: UIColor(red: 0.955, green: 0.972, blue: 0.978, alpha: 0.72),
        dark: UIColor(red: 0.098, green: 0.106, blue: 0.125, alpha: 1.0)
    )
    static let glassStrong = adaptive(
        light: UIColor(red: 0.920, green: 0.950, blue: 0.960, alpha: 0.85),
        dark: UIColor(red: 0.133, green: 0.145, blue: 0.169, alpha: 1.0)
    )
    static let border = adaptive(
        light: UIColor(red: 0.16, green: 0.34, blue: 0.38, alpha: 0.16),
        dark: UIColor(white: 1.0, alpha: 0.08)
    )
    static let textPrimary = adaptive(
        light: UIColor(red: 0.10, green: 0.14, blue: 0.16, alpha: 0.96),
        dark: UIColor(white: 1.0, alpha: 0.94)
    )
    static let textSecondary = adaptive(
        light: UIColor(red: 0.30, green: 0.38, blue: 0.41, alpha: 0.78),
        dark: UIColor(white: 1.0, alpha: 0.66)
    )
    static let textTertiary = adaptive(
        light: UIColor(red: 0.42, green: 0.50, blue: 0.53, alpha: 0.62),
        dark: UIColor(white: 1.0, alpha: 0.44)
    )

    // Roles: one brand accent plus three quiet semantic colors. Both themes
    // resolve each role to the same hue so the product has one identity.
    static let brand = adaptive(
        light: UIColor(red: 0.03, green: 0.49, blue: 0.55, alpha: 1.0),
        dark: UIColor(red: 0.33, green: 0.76, blue: 0.81, alpha: 1.0)
    )
    static let success = adaptive(
        light: UIColor(red: 0.12, green: 0.58, blue: 0.42, alpha: 1.0),
        dark: UIColor(red: 0.42, green: 0.78, blue: 0.60, alpha: 1.0)
    )
    static let warning = adaptive(
        light: UIColor(red: 0.80, green: 0.50, blue: 0.13, alpha: 1.0),
        dark: UIColor(red: 0.94, green: 0.70, blue: 0.42, alpha: 1.0)
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
        light: UIColor(red: 0.02, green: 0.38, blue: 0.44, alpha: 1.0),
        dark: UIColor(red: 0.20, green: 0.58, blue: 0.63, alpha: 1.0)
    )
    static let primaryActionForeground = adaptive(
        light: UIColor.white,
        dark: UIColor(red: 0.03, green: 0.10, blue: 0.11, alpha: 1.0)
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
                .font(.system(size: 17, weight: .semibold))

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
                .opacity(0.55)
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
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(RhetorixColors.brand)
            )
            .shadow(
                color: .black.opacity(configuration.isPressed ? 0.08 : 0.16),
                radius: configuration.isPressed ? 3 : 8,
                y: configuration.isPressed ? 1 : 3
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
