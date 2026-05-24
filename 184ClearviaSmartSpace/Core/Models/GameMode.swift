import Foundation

enum GameMode: String, Hashable, Codable {
    case standard
    case practice
    case speedRun
    case dailyChallenge

    var awardsStars: Bool { self != .practice }
    var recordsProgress: Bool { self != .practice }
    var countsAsSession: Bool { self != .practice }
}

struct GameSessionConfig: Hashable {
    let activityId: String
    let difficulty: Difficulty
    let level: Int
    let mode: GameMode

    var recordsProgress: Bool { mode.recordsProgress }
    var awardsStars: Bool { mode.awardsStars }
    var countsAsSession: Bool { mode.countsAsSession }

    var activity: ActivityDefinition? {
        ActivityCatalog.find(id: activityId)
    }
}

enum LevelKey {
    static func make(activityId: String, difficulty: String, level: Int) -> String {
        "\(activityId)_\(difficulty)_\(level)"
    }

    static func make(activityId: String, difficulty: Difficulty, level: Int) -> String {
        make(activityId: activityId, difficulty: difficulty.storageKey, level: level)
    }
}
