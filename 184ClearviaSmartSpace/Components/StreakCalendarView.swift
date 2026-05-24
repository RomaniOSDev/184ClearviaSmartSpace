import SwiftUI

struct StreakCalendarView: View {
    @EnvironmentObject private var progress: ProgressStore
    var compact: Bool = false

    private var dayTokens: [String] {
        progress.recentPlayDayTokens(limit: compact ? 7 : 14)
    }

    private var circleSize: CGFloat {
        if compact { return 26 }
        return dayTokens.count > 7 ? 22 : 32
    }

    private var daySpacing: CGFloat {
        compact ? 6 : (dayTokens.count > 7 ? 4 : 8)
    }

    var body: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .center, spacing: 8) {
                    SectionHeaderView(
                        title: "Play Streak",
                        subtitle: compact ? nil : "Keep your rhythm going",
                        iconName: "flame.fill"
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)

                    StatusPillView(text: "\(progress.playStreakDays) days", style: .accent)
                        .fixedSize()
                }

                HStack(spacing: daySpacing) {
                    ForEach(dayTokens, id: \.self) { day in
                        streakDayCell(day)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }

    private func streakDayCell(_ day: String) -> some View {
        let played = progress.playedOnDay(day)
        return VStack(spacing: compact ? 2 : 3) {
            ZStack {
                Circle()
                    .fill(played ? Color("AppPrimary") : Color("AppBackground").opacity(0.65))
                    .frame(width: circleSize, height: circleSize)
                if played {
                    Image(systemName: "checkmark")
                        .font(.system(size: max(8, circleSize * 0.34), weight: .bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                }
            }
            .overlay(
                Circle()
                    .stroke(Color("AppAccent").opacity(played ? 0.6 : 0.25), lineWidth: 1.5)
            )
            if !compact {
                Text(shortDay(day))
                    .font(.system(size: dayTokens.count > 7 ? 8 : 9, weight: .medium))
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
    }

    private func shortDay(_ token: String) -> String {
        token.suffix(2).description
    }
}
