import SwiftUI

struct ActivityCard: View {
    let activity: ActivityDefinition
    var stars: Int = 0
    var sessions: Int = 0
    var action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            HapticService.mediumTap()
            action()
        } label: {
            HStack(spacing: 14) {
                IconBadgeView(systemName: activity.iconName, size: 54, iconSize: 24)

                VStack(alignment: .leading, spacing: 6) {
                    Text(activity.title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(activity.subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                    HStack(spacing: 10) {
                        Label("\(stars)", systemImage: "star.fill")
                        Label("\(sessions)", systemImage: "play.fill")
                    }
                    .font(.caption2.bold())
                    .foregroundStyle(Color("AppAccent"))
                }

                Spacer(minLength: 0)

                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color("AppPrimary"))
            }
            .padding(16)
            .background(ElevatedSurfaceBackground(cornerRadius: 18, accentBorder: true))
            .appElevationShadow()
            .scaleEffect(isPressed ? 0.97 : 1)
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeInOut(duration: 0.12)) { isPressed = true } }
                .onEnded { _ in withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { isPressed = false } }
        )
    }
}
