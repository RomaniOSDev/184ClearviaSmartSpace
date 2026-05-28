import Foundation

enum WeeklyEventGenerator {
    struct Event: Equatable {
        let activityId: String
        let difficulty: Difficulty
        let level: Int
        let weekToken: String
        let title: String
        let bonusStars: Int
    }

    static func current(for date: Date = Date()) -> Event {
        let calendar = Calendar.current
        let week = calendar.component(.weekOfYear, from: date)
        let year = calendar.component(.yearForWeekOfYear, from: date)
        let activities = ActivityCatalog.all
        let difficulties: [Difficulty] = [.normal, .hard, .expert, .easy]
        let activity = activities[week % activities.count]
        let difficulty = difficulties[(week / activities.count) % difficulties.count]
        let level = week % GameContent.levelsPerDifficulty
        let track = TrackCatalog.track(activityId: activity.id, level: level)
        return Event(
            activityId: activity.id,
            difficulty: difficulty,
            level: level,
            weekToken: "\(year)-W\(week)",
            title: "Weekly Spotlight: \(track.title)",
            bonusStars: 2
        )
    }
}
