import Foundation

enum GameContent {
    static let levelsPerDifficulty = 18
    static let speedRunLevelCount = 10
    static let expertHardThreeStarLevelsRequired = 12
    static let campaignWorldCount = 4
}

struct TrackDefinition: Identifiable, Hashable {
    let id: String
    let activityId: String
    let levelIndex: Int
    let title: String
    let artist: String
    let bpm: Int
    let previewIcon: String
    let patternSeed: Int

    var displaySubtitle: String {
        "\(artist) • \(bpm) BPM"
    }
}

struct CampaignWorld: Identifiable, Hashable {
    let id: Int
    let title: String
    let subtitle: String
    let story: String
    let activityId: String
    let iconName: String
    let requiredStarsToUnlock: Int

    var unlockWorldIndex: Int { id }
}
