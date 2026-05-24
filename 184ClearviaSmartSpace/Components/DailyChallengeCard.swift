import SwiftUI

struct DailyChallengeCard: View {
    @EnvironmentObject private var progress: ProgressStore
    let onPlay: (GameSessionConfig) -> Void

    private var challenge: DailyChallengeGenerator.Challenge {
        DailyChallengeGenerator.challenge()
    }

    var body: some View {
        let activity = ActivityCatalog.find(id: challenge.activityId)
        let completed = progress.dailyChallengeCompleted

        SurfaceCard(accentBorder: !completed) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    IconBadgeView(systemName: "sun.max.fill", size: 40, iconSize: 18)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Daily Challenge")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text("Refreshes every day")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    Spacer()
                    if completed {
                        StatusPillView(text: "Completed", style: .success)
                    } else {
                        StatusPillView(text: "+1 Bonus Star", style: .accent)
                    }
                }

                if let activity {
                    HStack(spacing: 8) {
                        Label(activity.title, systemImage: activity.iconName)
                        Text("•")
                        Text(challenge.difficulty.rawValue)
                        Text("•")
                        Text("Lv.\(challenge.level + 1)")
                    }
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                }

                if !completed, activity != nil {
                    AppButton(title: "Play Daily Challenge", icon: "play.fill") {
                        HapticService.mediumTap()
                        onPlay(GameSessionConfig(
                            activityId: challenge.activityId,
                            difficulty: challenge.difficulty,
                            level: challenge.level,
                            mode: .dailyChallenge
                        ))
                    }
                }
            }
        }
    }
}
