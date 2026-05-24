import SwiftUI

struct HomeActivityShowcaseCard: View {
    let activity: ActivityDefinition
    let stars: Int
    let sessions: Int
    let bestAccuracy: Double
    var action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button {
            HapticService.mediumTap()
            action()
        } label: {
            VStack(spacing: 0) {
                ZStack(alignment: .bottomLeading) {
                    ActivityArtworkView(style: ActivityArtworkStyle(activityId: activity.id), animate: true)
                        .frame(height: 130)

                    LinearGradient(
                        colors: [.clear, Color("AppBackground").opacity(0.75)],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    HStack(spacing: 8) {
                        IconBadgeView(systemName: activity.iconName, size: 36, iconSize: 16)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(activity.title)
                                .font(.headline.bold())
                                .foregroundStyle(Color("AppTextPrimary"))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            Text(activity.subtitle)
                                .font(.caption2)
                                .foregroundStyle(Color("AppTextSecondary"))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                    }
                    .padding(12)
                }

                HStack {
                    Label("\(stars)", systemImage: "star.fill")
                    Label("\(sessions)", systemImage: "play.fill")
                    if bestAccuracy > 0 {
                        Text("Best \(Int(bestAccuracy * 100))%")
                    }
                    Spacer()
                    Text("Play")
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppAccent"))
                    Image(systemName: "arrow.right")
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppAccent"))
                }
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            }
            .background(ElevatedSurfaceBackground(cornerRadius: 20, accentBorder: true))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .scaleEffect(pressed ? 0.98 : 1)
            .appElevationShadow()
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeInOut(duration: 0.12)) { pressed = true } }
                .onEnded { _ in withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { pressed = false } }
        )
    }
}
