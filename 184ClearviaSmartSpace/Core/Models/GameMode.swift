import Foundation

enum GameMode: String, Hashable, Codable {
    case standard
    case practice
    case speedRun
    case dailyChallenge
    case endless
    case weeklyEvent
    case duel
    case customPattern

    var awardsStars: Bool {
        switch self {
        case .practice, .duel, .endless, .customPattern: false
        default: true
        }
    }

    var recordsProgress: Bool {
        switch self {
        case .practice, .duel: false
        default: true
        }
    }

    var countsAsSession: Bool {
        switch self {
        case .practice, .duel: false
        default: true
        }
    }
}

struct GameSessionConfig: Hashable {
    let activityId: String
    let difficulty: Difficulty
    let level: Int
    let mode: GameMode
    var endlessWave: Int = 0
    var customPatternNotes: [Int] = []

    var recordsProgress: Bool { mode.recordsProgress }
    var awardsStars: Bool { mode.awardsStars }
    var countsAsSession: Bool { mode.countsAsSession }

    var track: TrackDefinition {
        TrackCatalog.track(activityId: activityId, level: level)
    }

    var activity: ActivityDefinition? {
        ActivityCatalog.find(id: activityId)
    }

    var effectiveLevel: Int {
        if mode == .endless {
            return min(GameContent.levelsPerDifficulty - 1, endlessWave)
        }
        return level
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
