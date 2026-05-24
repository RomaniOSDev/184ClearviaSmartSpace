import Foundation

struct ActivityDefinition: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let iconName: String
}

enum ActivityCatalog {
    static let all: [ActivityDefinition] = [
        ActivityDefinition(
            id: "harmony_pulse",
            title: "Harmony Pulse",
            subtitle: "Tap nodes to sync wave pulses",
            iconName: "waveform.circle.fill"
        ),
        ActivityDefinition(
            id: "melody_glide",
            title: "Melody Glide",
            subtitle: "Drag notes onto matching paths",
            iconName: "arrow.right.circle.fill"
        ),
        ActivityDefinition(
            id: "melody_hold",
            title: "Melody Glide 3",
            subtitle: "Hold notes for perfect timing",
            iconName: "hand.tap.fill"
        ),
        ActivityDefinition(
            id: "tap_sequence",
            title: "Tap Sequence",
            subtitle: "Repeat the note pattern shown",
            iconName: "list.number"
        )
    ]

    static func find(id: String) -> ActivityDefinition? {
        all.first { $0.id == id }
    }
}

enum Difficulty: String, CaseIterable, Identifiable {
    case easy = "Easy"
    case normal = "Normal"
    case hard = "Hard"
    case expert = "Expert"

    var id: String { rawValue }

    var storageKey: String { rawValue.lowercased() }

    static var standardCases: [Difficulty] {
        [.easy, .normal, .hard]
    }

    static func availableCases(expertUnlocked: Bool) -> [Difficulty] {
        expertUnlocked ? allCases : standardCases
    }
}

struct LevelConfig: Identifiable {
    let index: Int
    var id: Int { index }
}
