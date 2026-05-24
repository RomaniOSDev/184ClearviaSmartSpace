import SwiftUI

struct PlayTabView: View {
    @EnvironmentObject private var progress: ProgressStore
    @State private var navigationPath = NavigationPath()
    @State private var dailyChallengeConfig: GameSessionConfig?

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                BackgroundPatternView()
                AnimatedPlayBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        heroHeader
                        quickStatsRow
                        StreakCalendarView(compact: true)
                        DailyChallengeCard { config in
                            dailyChallengeConfig = config
                        }
                        SectionHeaderView(
                            title: "Activities",
                            subtitle: "Pick a mode and earn stars",
                            iconName: "music.note.list"
                        )
                        ForEach(ActivityCatalog.all) { activity in
                            ActivityCard(
                                activity: activity,
                                stars: progress.totalStars(for: activity.id),
                                sessions: progress.activitySessions[activity.id] ?? 0
                            ) {
                                navigationPath.append(activity)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 28)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: ActivityDefinition.self) { activity in
                LevelSelectionView(activity: activity)
            }
            .navigationDestination(item: $dailyChallengeConfig) { config in
                ActivityGameHost(config: config)
            }
        }
    }

    private var heroHeader: some View {
        SurfaceCard(accentBorder: true) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Choose Your Challenge")
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                Text("Master melodies, build streaks, unlock Expert")
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
        }
    }

    private var quickStatsRow: some View {
        HStack(spacing: 10) {
            StatChipView(icon: "star.fill", value: "\(progress.totalStarsEarned)", label: "Total Stars")
            StatChipView(
                icon: "flame.fill",
                value: "\(progress.playStreakDays)",
                label: "Day Streak"
            )
            StatChipView(
                icon: "clock.fill",
                value: ProgressStore.formattedPlayTime(seconds: progress.totalPlayTimeSeconds),
                label: "Play Time"
            )
        }
    }
}
