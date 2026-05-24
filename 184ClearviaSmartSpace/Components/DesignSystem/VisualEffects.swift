import SwiftUI

enum AppGradients {
    static var surface: LinearGradient {
        LinearGradient(
            colors: [Color("AppSurface"), Color("AppSurface").opacity(0.86)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var surfaceInset: LinearGradient {
        LinearGradient(
            colors: [Color("AppBackground").opacity(0.72), Color("AppBackground").opacity(0.48)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var primaryButton: LinearGradient {
        LinearGradient(
            colors: [Color("AppPrimary"), Color("AppPrimary").opacity(0.78)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var accentBorder: LinearGradient {
        LinearGradient(
            colors: [Color("AppAccent").opacity(0.55), Color("AppAccent").opacity(0.15)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var subtleBorder: LinearGradient {
        LinearGradient(
            colors: [Color("AppTextPrimary").opacity(0.1), Color("AppTextPrimary").opacity(0.03)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var topHighlight: LinearGradient {
        LinearGradient(
            colors: [Color.white.opacity(0.1), Color.clear],
            startPoint: .top,
            endPoint: .center
        )
    }

    static func screenBase(background: String, surface: String) -> LinearGradient {
        LinearGradient(
            colors: [Color(background), Color(surface).opacity(0.92)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct ElevatedSurfaceBackground: View {
    var cornerRadius: CGFloat = 18
    var accentBorder: Bool = false
    var inset: Bool = false

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(inset ? AppGradients.surfaceInset : AppGradients.surface)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        accentBorder ? AppGradients.accentBorder : AppGradients.subtleBorder,
                        lineWidth: accentBorder ? 1.5 : 1
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AppGradients.topHighlight, lineWidth: 1)
            )
    }
}

struct AmbientGlowLayer: View {
    @Environment(\.themePalette) private var palette

    var body: some View {
        ZStack {
            glowBlob(
                color: Color(palette.primary),
                size: 300,
                opacity: 0.2,
                offset: CGSize(width: -90, height: -160)
            )
            glowBlob(
                color: Color(palette.accent),
                size: 240,
                opacity: 0.14,
                offset: CGSize(width: 130, height: 120)
            )
            glowBlob(
                color: Color(palette.accent),
                size: 180,
                opacity: 0.1,
                offset: CGSize(width: -60, height: 320)
            )
        }
        .allowsHitTesting(false)
    }

    private func glowBlob(color: Color, size: CGFloat, opacity: Double, offset: CGSize) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [color.opacity(opacity), color.opacity(0)],
                    center: .center,
                    startRadius: 0,
                    endRadius: size * 0.5
                )
            )
            .frame(width: size, height: size)
            .offset(offset)
    }
}

extension View {
    func appElevationShadow(radius: CGFloat = 10, y: CGFloat = 5) -> some View {
        compositingGroup()
            .shadow(color: Color("AppBackground").opacity(0.55), radius: radius, y: y)
    }

    func appSoftShadow(radius: CGFloat = 6, y: CGFloat = 3) -> some View {
        compositingGroup()
            .shadow(color: Color("AppBackground").opacity(0.35), radius: radius, y: y)
    }
}
