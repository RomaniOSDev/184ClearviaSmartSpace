import SwiftUI

struct AchievementDetailView: View {
    let achievement: AchievementDefinition
    @EnvironmentObject private var progress: ProgressStore
    @Environment(\.dismiss) private var dismiss

    private var unlocked: Bool { achievement.isUnlocked(progress) }
    private var achievementProgress: AchievementProgress { achievement.progress(progress) }

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundPatternView()
                ScrollView {
                    VStack(spacing: 22) {
                        SurfaceCard(accentBorder: unlocked) {
                            VStack(spacing: 16) {
                                IconBadgeView(
                                    systemName: achievement.isHidden && !unlocked ? "questionmark" : achievement.iconName,
                                    size: 88,
                                    iconSize: 36,
                                    highlighted: unlocked
                                )
                                Text(achievement.displayTitle(unlocked: unlocked))
                                    .font(.title2.bold())
                                    .foregroundStyle(Color("AppTextPrimary"))
                                    .multilineTextAlignment(.center)
                                Text(achievement.displayDescription(unlocked: unlocked))
                                    .font(.body)
                                    .foregroundStyle(Color("AppTextSecondary"))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                        }

                        SurfaceCard {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Progress")
                                        .font(.subheadline.bold())
                                        .foregroundStyle(Color("AppTextPrimary"))
                                    Spacer()
                                    Text(achievementProgress.label)
                                        .font(.subheadline.bold())
                                        .foregroundStyle(Color("AppAccent"))
                                }
                                ProgressBarView(fraction: achievementProgress.fraction)
                            }
                        }

                        if achievement.isHidden && !unlocked {
                            StatusPillView(text: "Hidden Achievement", style: .muted)
                        } else if unlocked {
                            StatusPillView(text: "Unlocked", style: .success)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Achievement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        HapticService.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
    }
}
