import SwiftUI

struct SurfaceCard<Content: View>: View {
    var accentBorder: Bool = false
    var cornerRadius: CGFloat = 18
    var padding: CGFloat = 16
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                ElevatedSurfaceBackground(cornerRadius: cornerRadius, accentBorder: accentBorder)
            )
            .appElevationShadow(radius: accentBorder ? 12 : 10, y: accentBorder ? 6 : 5)
    }
}

struct SectionHeaderView: View {
    let title: String
    var subtitle: String?
    var iconName: String?

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if let iconName {
                IconBadgeView(systemName: iconName, size: 36, iconSize: 16)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                }
            }
            Spacer(minLength: 0)
        }
    }
}

struct StatChipView: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppAccent"))
                Text(value)
                    .font(.title3.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ElevatedSurfaceBackground(cornerRadius: 14, inset: true)
        )
        .appSoftShadow()
    }
}

struct IconBadgeView: View {
    let systemName: String
    var size: CGFloat = 48
    var iconSize: CGFloat = 22
    var highlighted: Bool = true

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    highlighted
                        ? LinearGradient(
                            colors: [
                                Color("AppPrimary").opacity(0.32),
                                Color("AppPrimary").opacity(0.18)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : AppGradients.surfaceInset
                )
                .frame(width: size, height: size)
            Circle()
                .stroke(
                    highlighted ? AppGradients.accentBorder : AppGradients.subtleBorder,
                    lineWidth: 1.5
                )
                .frame(width: size, height: size)
            Circle()
                .stroke(AppGradients.topHighlight, lineWidth: 1)
                .frame(width: size, height: size)
            Image(systemName: systemName)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(highlighted ? Color("AppAccent") : Color("AppTextSecondary"))
        }
        .appSoftShadow(radius: highlighted ? 5 : 3, y: highlighted ? 2 : 1)
    }
}

struct StatusPillView: View {
    let text: String
    var style: PillStyle = .accent

    enum PillStyle {
        case accent, success, muted
    }

    var body: some View {
        Text(text)
            .font(.caption2.bold())
            .foregroundStyle(foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(backgroundGradient)
                    .overlay(Capsule().stroke(foreground.opacity(0.25), lineWidth: 1))
            )
            .appSoftShadow(radius: 3, y: 1)
    }

    private var foreground: Color {
        switch style {
        case .accent: Color("AppAccent")
        case .success: Color("AppPrimary")
        case .muted: Color("AppTextSecondary")
        }
    }

    private var backgroundGradient: LinearGradient {
        switch style {
        case .accent:
            LinearGradient(
                colors: [Color("AppAccent").opacity(0.24), Color("AppAccent").opacity(0.12)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .success:
            LinearGradient(
                colors: [Color("AppPrimary").opacity(0.28), Color("AppPrimary").opacity(0.14)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .muted:
            AppGradients.surfaceInset
        }
    }
}
