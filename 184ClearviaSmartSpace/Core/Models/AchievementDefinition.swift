import Foundation

struct AchievementDefinition: Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let isHidden: Bool
    let isUnlocked: (ProgressStore) -> Bool
    let progress: (ProgressStore) -> AchievementProgress

    func displayTitle(unlocked: Bool) -> String {
        isHidden && !unlocked ? "???" : title
    }

    func displayDescription(unlocked: Bool) -> String {
        isHidden && !unlocked ? "Keep playing to reveal this badge." : description
    }
}

enum AchievementCatalog {
    static let all: [AchievementDefinition] = [
        AchievementDefinition(
            id: "first_star",
            title: "First Star",
            description: "Earned your first STAR.",
            iconName: "star.fill",
            isHidden: false,
            isUnlocked: { $0.totalStarsEarned >= 1 },
            progress: { AchievementProgress(current: $0.totalStarsEarned, target: 1) }
        ),
        AchievementDefinition(
            id: "rising_star",
            title: "Rising Star",
            description: "Earned 50 STARS.",
            iconName: "star.circle.fill",
            isHidden: false,
            isUnlocked: { $0.totalStarsEarned >= 50 },
            progress: { AchievementProgress(current: $0.totalStarsEarned, target: 50) }
        ),
        AchievementDefinition(
            id: "star_collector",
            title: "Star Collector",
            description: "Earned 25 stars total.",
            iconName: "sparkles",
            isHidden: false,
            isUnlocked: { $0.totalStarsEarned >= 25 },
            progress: { AchievementProgress(current: $0.totalStarsEarned, target: 25) }
        ),
        AchievementDefinition(
            id: "star_master",
            title: "Star Master",
            description: "Earned 75 stars total.",
            iconName: "crown.fill",
            isHidden: false,
            isUnlocked: { $0.totalStarsEarned >= 75 },
            progress: { AchievementProgress(current: $0.totalStarsEarned, target: 75) }
        ),
        AchievementDefinition(
            id: "active_player",
            title: "Active Player",
            description: "Completed 25 activity sessions.",
            iconName: "figure.run",
            isHidden: false,
            isUnlocked: { $0.totalActivitiesPlayed >= 25 },
            progress: { AchievementProgress(current: $0.totalActivitiesPlayed, target: 25) }
        ),
        AchievementDefinition(
            id: "hundred_plays",
            title: "Hundred Plays",
            description: "Completed 100 activity sessions.",
            iconName: "repeat.circle.fill",
            isHidden: false,
            isUnlocked: { $0.totalActivitiesPlayed >= 100 },
            progress: { AchievementProgress(current: $0.totalActivitiesPlayed, target: 100) }
        ),
        AchievementDefinition(
            id: "perfectionist",
            title: "Perfectionist",
            description: "Earned 3 stars on any single level.",
            iconName: "checkmark.seal.fill",
            isHidden: false,
            isUnlocked: { $0.hasAnyThreeStarLevel },
            progress: { store in
                let best = store.bestSingleLevelStars
                return AchievementProgress(current: best, target: 3)
            }
        ),
        AchievementDefinition(
            id: "activity_master",
            title: "Activity Master",
            description: "Got 3 stars on every level of one activity.",
            iconName: "medal.fill",
            isHidden: false,
            isUnlocked: { $0.hasFullActivityThreeStars },
            progress: { store in
                AchievementProgress(current: store.maxPerfectLevelsInOneActivity, target: 5)
            }
        ),
        AchievementDefinition(
            id: "streak_seeker",
            title: "Streak Seeker",
            description: "Played 7 days in a row.",
            iconName: "flame.fill",
            isHidden: true,
            isUnlocked: { $0.playStreakDays >= 7 },
            progress: { AchievementProgress(current: $0.playStreakDays, target: 7) }
        ),
        AchievementDefinition(
            id: "daily_devotee",
            title: "Daily Devotee",
            description: "Completed 5 daily challenges.",
            iconName: "sun.max.fill",
            isHidden: true,
            isUnlocked: { $0.totalDailyChallengesCompleted >= 5 },
            progress: { AchievementProgress(current: $0.totalDailyChallengesCompleted, target: 5) }
        ),
        AchievementDefinition(
            id: "combo_king",
            title: "Combo King",
            description: "Reached a combo of 10 in any activity.",
            iconName: "bolt.fill",
            isHidden: true,
            isUnlocked: { $0.bestComboOverall >= 10 },
            progress: { AchievementProgress(current: $0.bestComboOverall, target: 10) }
        )
    ]
}
