import Foundation

struct PersonalBestRecord: Codable, Equatable {
    var bestAccuracy: Double
    var bestTimeSeconds: Int
    var bestCombo: Int

    static let empty = PersonalBestRecord(bestAccuracy: 0, bestTimeSeconds: Int.max, bestCombo: 0)
}

struct ActivityBreakdownStat: Identifiable {
    let id: String
    let title: String
    let sessions: Int
    let averageAccuracy: Double
    let totalStars: Int
}

struct AchievementProgress {
    let current: Int
    let target: Int

    var fraction: Double {
        guard target > 0 else { return 0 }
        return min(1.0, Double(current) / Double(target))
    }

    var label: String {
        "\(min(current, target))/\(target)"
    }
}
