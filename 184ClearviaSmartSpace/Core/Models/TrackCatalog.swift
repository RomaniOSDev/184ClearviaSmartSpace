import Foundation

enum TrackCatalog {
    private static let harmonyTitles = [
        "Neon Pulse", "Starlit Echo", "Midnight Loop", "Crystal Beam", "Solar Drift",
        "Aurora Gate", "Velvet Wave", "Silver Tide", "Moonlit Arc", "Gravity Spark",
        "Horizon Tap", "Cloud Runner", "Prism Field", "Echo Harbor", "Night Bloom",
        "Radiant Path", "Cosmic Step", "Final Chorus"
    ]
    private static let glideTitles = [
        "Paper Wings", "River Slide", "Glass Garden", "Soft Current", "Wind Lane",
        "Misty Trail", "Golden Glide", "Petal Stream", "Blue Compass", "Quiet Motion",
        "Frost Line", "Ember Path", "Dawn Curve", "Willow Run", "Sky Thread",
        "Hidden Route", "Crystal Lane", "Last Horizon"
    ]
    private static let holdTitles = [
        "Deep Anchor", "Slow Ember", "Hold the Light", "Gravity Well", "Still Water",
        "Iron Bloom", "Long Breath", "Stone Halo", "Muted Flame", "Echo Chamber",
        "Frozen Note", "Copper Sky", "Velvet Hold", "Night Anchor", "Pulse Core",
        "Silent Ring", "Amber Lock", "Final Sustain"
    ]
    private static let sequenceTitles = [
        "Cipher One", "Pattern Lock", "Code Runner", "Signal Dance", "Logic Rain",
        "Byte March", "Neon Steps", "Grid Memory", "Pulse Code", "Mirror Line",
        "Spark Array", "Rhythm Key", "Phase Lock", "Echo Grid", "Prime Loop",
        "Data Song", "Chain Reaction", "Master Sequence"
    ]

    private static let artists = [
        "Studio Wave", "Luna Audio", "Arc Ensemble", "Night Shift", "Clear Tone"
    ]

    static func track(activityId: String, level: Int) -> TrackDefinition {
        let index = max(0, min(level, GameContent.levelsPerDifficulty - 1))
        let titles = titles(for: activityId)
        let title = titles[index]
        let artist = artists[index % artists.count]
        let bpm = 84 + (index * 3) + activitySeed(activityId)
        return TrackDefinition(
            id: "\(activityId)_\(index)",
            activityId: activityId,
            levelIndex: index,
            title: title,
            artist: artist,
            bpm: bpm,
            previewIcon: previewIcon(for: activityId),
            patternSeed: patternSeed(activityId: activityId, level: index)
        )
    }

    static func tracks(for activityId: String) -> [TrackDefinition] {
        (0..<GameContent.levelsPerDifficulty).map { track(activityId: activityId, level: $0) }
    }

    static func allTracks() -> [TrackDefinition] {
        ActivityCatalog.all.flatMap { tracks(for: $0.id) }
    }

    private static func titles(for activityId: String) -> [String] {
        switch activityId {
        case "harmony_pulse": harmonyTitles
        case "melody_glide": glideTitles
        case "melody_hold": holdTitles
        case "tap_sequence": sequenceTitles
        default: harmonyTitles
        }
    }

    private static func previewIcon(for activityId: String) -> String {
        ActivityCatalog.find(id: activityId)?.iconName ?? "music.note"
    }

    private static func activitySeed(_ activityId: String) -> Int {
        switch activityId {
        case "harmony_pulse": 0
        case "melody_glide": 2
        case "melody_hold": 4
        case "tap_sequence": 6
        default: 0
        }
    }

    static func patternSeed(activityId: String, level: Int) -> Int {
        let base = activityId.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return base &+ (level &* 97) &+ 13
    }
}

enum CampaignCatalog {
    static let worlds: [CampaignWorld] = [
        CampaignWorld(
            id: 0,
            title: "Nova Station",
            subtitle: "Pulse the beat across the neon grid",
            story: "Commander Lyra activates the station rhythm core. Sync every pulse to restore power to the outer rings.",
            activityId: "harmony_pulse",
            iconName: "waveform.circle.fill",
            requiredStarsToUnlock: 0
        ),
        CampaignWorld(
            id: 1,
            title: "Glide Gardens",
            subtitle: "Guide melodies through living pathways",
            story: "The garden paths shift at sunset. Glide each note onto its lane before the petals fade.",
            activityId: "melody_glide",
            iconName: "arrow.right.circle.fill",
            requiredStarsToUnlock: 24
        ),
        CampaignWorld(
            id: 2,
            title: "Hold Harbor",
            subtitle: "Sustain tones through the misty docks",
            story: "Ship horns echo across the harbor. Hold each tone until the lighthouse beam aligns.",
            activityId: "melody_hold",
            iconName: "hand.tap.fill",
            requiredStarsToUnlock: 48
        ),
        CampaignWorld(
            id: 3,
            title: "Sequence City",
            subtitle: "Decode patterns in the skyline",
            story: "The city grid speaks in patterns. Memorize and replay every sequence to unlock the central tower.",
            activityId: "tap_sequence",
            iconName: "list.number",
            requiredStarsToUnlock: 72
        )
    ]

    static func world(id: Int) -> CampaignWorld? {
        worlds.first { $0.id == id }
    }

    static func isWorldUnlocked(_ world: CampaignWorld, progress: ProgressStore) -> Bool {
        if world.requiredStarsToUnlock == 0 { return true }
        return progress.totalStarsEarned >= world.requiredStarsToUnlock
    }

    static func starsInWorld(_ world: CampaignWorld, progress: ProgressStore) -> Int {
        progress.totalStars(for: world.activityId)
    }
}
