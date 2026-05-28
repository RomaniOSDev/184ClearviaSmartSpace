import Foundation

enum DailyChallengeGenerator {
    struct Challenge: Equatable {
        let activityId: String
        let difficulty: Difficulty
        let level: Int
        let dayToken: String
    }

    static func challenge(for date: Date = Date()) -> Challenge {
        let calendar = Calendar.current
        let day = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let year = calendar.component(.year, from: date)
        let activities = ActivityCatalog.all
        let baseDifficulties: [Difficulty] = [.easy, .normal, .hard]
        let activity = activities[day % activities.count]
        let difficulty = baseDifficulties[day % baseDifficulties.count]
        let level = day % GameContent.levelsPerDifficulty
        return Challenge(
            activityId: activity.id,
            difficulty: difficulty,
            level: level,
            dayToken: "\(year)-\(day)"
        )
    }
}
