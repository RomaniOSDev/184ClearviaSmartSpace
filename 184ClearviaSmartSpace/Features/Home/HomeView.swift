import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var progress: ProgressStore
    @State private var navigationPath = NavigationPath()
    @State private var dailyChallengeConfig: GameSessionConfig?
    @State private var weeklyEventConfig: GameSessionConfig?
    @State private var continueConfig: GameSessionConfig?

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                BackgroundPatternView()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        HomeHeroBanner(
                            stars: progress.totalStarsEarned,
                            streak: progress.playStreakDays,
                            sessions: progress.totalActivitiesPlayed
                        )

                        Text("\(TrackCatalog.allTracks().count) tracks • \(GameContent.campaignWorldCount) worlds")
                            .font(.caption.bold())
                            .foregroundStyle(Color("AppAccent"))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HomeWidgetGrid()

                        HomeDailyWidget { config in
                            dailyChallengeConfig = config
                        }

                        HomeWeeklyEventWidget { config in
                            weeklyEventConfig = config
                        }

                        if let suggestion = continueSuggestion {
                            HomeContinueWidget(
                                activity: suggestion.activity,
                                difficulty: suggestion.difficulty,
                                level: suggestion.level,
                                stars: suggestion.stars
                            ) {
                                continueConfig = suggestion.config
                            }
                        }

                        HomeStreakWidget()

                        HomeAchievementsWidget()

                        SectionHeaderView(
                            title: "Explore Activities",
                            subtitle: "Tap a card to choose levels",
                            iconName: "square.grid.2x2.fill"
                        )
                        .padding(.top, 4)

                        ForEach(ActivityCatalog.all) { activity in
                            HomeActivityShowcaseCard(
                                activity: activity,
                                stars: progress.totalStars(for: activity.id),
                                sessions: progress.activitySessions[activity.id] ?? 0,
                                bestAccuracy: bestAccuracy(for: activity.id)
                            ) {
                                navigationPath.append(activity)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: ActivityDefinition.self) { activity in
                LevelSelectionView(activity: activity)
            }
            .navigationDestination(item: $dailyChallengeConfig) { config in
                ActivityGameHost(config: config)
            }
            .navigationDestination(item: $weeklyEventConfig) { config in
                ActivityGameHost(config: config)
            }
            .navigationDestination(item: $continueConfig) { config in
                ActivityGameHost(config: config)
            }
        }
    }

    private var continueSuggestion: ContinueSuggestion? {
        var best: ContinueSuggestion?

        for activity in ActivityCatalog.all {
            for difficulty in Difficulty.standardCases {
                let highest = progress.highestUnlockedLevel(activityId: activity.id, difficulty: difficulty.storageKey)
                let level = min(highest, GameContent.levelsPerDifficulty - 1)
                let stars = progress.stars(for: activity.id, difficulty: difficulty.storageKey, level: level)
                if stars < 3 {
                    let suggestion = ContinueSuggestion(
                        activity: activity,
                        difficulty: difficulty,
                        level: level,
                        stars: stars,
                        config: GameSessionConfig(
                            activityId: activity.id,
                            difficulty: difficulty,
                            level: level,
                            mode: .standard
                        )
                    )
                    if best == nil || stars < best!.stars {
                        best = suggestion
                    }
                }
            }
        }

        if best == nil, let activity = ActivityCatalog.all.first {
            return ContinueSuggestion(
                activity: activity,
                difficulty: .easy,
                level: 0,
                stars: 0,
                config: GameSessionConfig(activityId: activity.id, difficulty: .easy, level: 0, mode: .standard)
            )
        }
        return best
    }

    private func bestAccuracy(for activityId: String) -> Double {
        var best = 0.0
        for difficulty in Difficulty.allCases {
            for level in 0..<GameContent.levelsPerDifficulty {
                if let record = progress.personalBest(for: activityId, difficulty: difficulty, level: level) {
                    best = max(best, record.bestAccuracy)
                }
            }
        }
        return best
    }
}

private struct ContinueSuggestion {
    let activity: ActivityDefinition
    let difficulty: Difficulty
    let level: Int
    let stars: Int
    let config: GameSessionConfig
}
