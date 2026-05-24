import SwiftUI

struct AppButton: View {
    let title: String
    var icon: String?
    var style: Style = .primary
    var action: () -> Void

    enum Style {
        case primary
        case secondary
        case destructive
    }

    @State private var isPressed = false

    var body: some View {
        Button {
            HapticService.lightTap()
            action()
        } label: {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.subheadline.bold())
                }
                Text(title)
                    .font(.headline.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(buttonBackground)
            .appElevationShadow(
                radius: style == .primary ? 10 : 6,
                y: style == .primary ? 5 : 3
            )
            .scaleEffect(isPressed ? 0.96 : 1)
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeInOut(duration: 0.12)) { isPressed = true } }
                .onEnded { _ in withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { isPressed = false } }
        )
    }

    @ViewBuilder
    private var buttonBackground: some View {
        switch style {
        case .primary:
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppGradients.primaryButton)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(AppGradients.topHighlight, lineWidth: 1)
                )
        case .secondary:
            ElevatedSurfaceBackground(cornerRadius: 14, accentBorder: true)
        case .destructive:
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color("AppTextSecondary").opacity(0.42),
                            Color("AppTextSecondary").opacity(0.28)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }

    private var foregroundColor: Color {
        Color("AppTextPrimary")
    }
}
