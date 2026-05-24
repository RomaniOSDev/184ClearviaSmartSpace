import Combine
import Foundation
import SwiftUI

struct HoldNote: Identifiable {
    let id: Int
    let pathIndex: Int
    let spawnTime: Date
    var xFraction: CGFloat
    var isHeld: Bool
    var holdStart: Date?
    var isReleased: Bool
    var landed: Bool
}

enum PathColor: Int, CaseIterable {
    case green = 0
    case blue = 1
    case red = 2

    var requiredHold: TimeInterval {
        switch self {
        case .green: 1.0
        case .blue: 2.0
        case .red: 3.0
        }
    }

    var tolerance: TimeInterval {
        switch self {
        case .green: 0.5
        case .blue: 0.4
        case .red: 0.3
        }
    }
}

enum MelodyHoldPhase {
    case playing
    case success
    case failed
}

@MainActor
final class MelodyHoldViewModel: ObservableObject {
    @Published var notes: [HoldNote] = []
    @Published var streak = 0
    @Published var harmonyMode = false
    @Published var successfulLandings = 0
    @Published var totalAttempts = 0
    @Published var consecutiveSetBreaks = 0
    @Published var failCount = 0
    @Published var phase: MelodyHoldPhase = .playing
    @Published var showFailModal = false
    @Published var elapsedSeconds = 0
    @Published var holdingNoteId: Int?
    @Published var holdProgress: CGFloat = 0
    @Published var timeRemaining: Int = 90
    @Published var maxCombo = 0

    let difficulty: Difficulty
    let level: Int
    let isPractice: Bool
    let targetLandings = 10
    let maxSetBreaks = 2
    let maxFails = 3

    private var sessionStart = Date()
    private var lastSpawnTime = Date()
    private var noteCounter = 0
    private var spawnInterval: TimeInterval = 2.0

    var accuracy: Double {
        guard totalAttempts > 0 else { return 0 }
        return Double(successfulLandings) / Double(totalAttempts)
    }

    var earnedStars: Int {
        StarCalculator.stars(for: accuracy)
    }

    init(difficulty: Difficulty, level: Int, isPractice: Bool = false) {
        self.difficulty = difficulty
        self.level = level
        self.isPractice = isPractice
        switch difficulty {
        case .easy: spawnInterval = 2.0
        case .normal: spawnInterval = 1.7
        case .hard: spawnInterval = max(1.2, 2.0 - Double(level) * 0.15)
        case .expert: spawnInterval = max(1.0, 1.6 - Double(level) * 0.12)
        }
        setupLevel()
    }

    func setupLevel() {
        sessionStart = Date()
        lastSpawnTime = Date()
        notes = []
        streak = 0
        harmonyMode = false
        successfulLandings = 0
        totalAttempts = 0
        consecutiveSetBreaks = 0
        failCount = 0
        phase = .playing
        showFailModal = false
        holdingNoteId = nil
        holdProgress = 0
        noteCounter = 0
        timeRemaining = 90 - level * 5
    }

    func tick() {
        elapsedSeconds = Int(Date().timeIntervalSince(sessionStart))
        timeRemaining = max(0, (90 - level * 5) - elapsedSeconds)

        if Date().timeIntervalSince(lastSpawnTime) >= spawnInterval {
            spawnNote()
            lastSpawnTime = Date()
        }

        if holdingNoteId != nil {
            updateHoldProgress()
        }

        if successfulLandings >= targetLandings {
            phase = .success
            HapticService.success()
            SoundService.playSuccess()
        } else if timeRemaining <= 0 && accuracy >= 0.7 {
            phase = .success
            HapticService.success()
            SoundService.playSuccess()
        } else if timeRemaining <= 0 {
            triggerFail()
        }
    }

    func beginHold(noteId: Int) {
        guard phase == .playing,
              let index = notes.firstIndex(where: { $0.id == noteId }),
              !notes[index].isReleased else { return }
        holdingNoteId = noteId
        notes[index].isHeld = true
        notes[index].holdStart = Date()
        HapticService.mediumTap()
    }

    func endHold(noteId: Int) {
        guard let index = notes.firstIndex(where: { $0.id == noteId }),
              let holdStart = notes[index].holdStart else { return }

        holdingNoteId = nil
        holdProgress = 0
        notes[index].isHeld = false
        notes[index].isReleased = true

        let path = PathColor(rawValue: notes[index].pathIndex % 3) ?? .green
        let holdDuration = Date().timeIntervalSince(holdStart)
        let delta = abs(holdDuration - path.requiredHold)
        totalAttempts += 1

        let effectiveTolerance: TimeInterval
        switch difficulty {
        case .easy: effectiveTolerance = 0.5
        case .normal: effectiveTolerance = 0.4
        case .hard: effectiveTolerance = 0.3
        case .expert: effectiveTolerance = 0.2
        }

        if delta <= min(path.tolerance, effectiveTolerance) {
            notes[index].landed = true
            successfulLandings += 1
            streak += 1
            maxCombo = max(maxCombo, streak)
            if streak >= 5 { harmonyMode = true }
            HapticService.mediumTap()
            SoundService.playSuccess()
            consecutiveSetBreaks = 0
        } else {
            streak = 0
            harmonyMode = false
            failCount += 1
            consecutiveSetBreaks += 1
            HapticService.error()
            SoundService.playFail()
            if failCount >= maxFails || consecutiveSetBreaks >= 2 {
                if isPractice {
                    failCount = 0
                    consecutiveSetBreaks = 0
                    streak = 0
                    return
                }
                triggerFail()
            }
        }

        notes.removeAll { $0.landed || ($0.isReleased && !$0.landed && Date().timeIntervalSince($0.spawnTime) > 4) }
    }

    private func spawnNote() {
        let pathIndex = Int.random(in: 0..<3)
        noteCounter += 1
        notes.append(HoldNote(
            id: noteCounter,
            pathIndex: pathIndex,
            spawnTime: Date(),
            xFraction: 0.15 + CGFloat.random(in: 0...0.7),
            isHeld: false,
            holdStart: nil,
            isReleased: false,
            landed: false
        ))
        if notes.count > 6 {
            notes.removeFirst()
        }
    }

    private func updateHoldProgress() {
        guard let noteId = holdingNoteId,
              let index = notes.firstIndex(where: { $0.id == noteId }),
              let holdStart = notes[index].holdStart else { return }
        let path = PathColor(rawValue: notes[index].pathIndex % 3) ?? .green
        holdProgress = min(1.0, CGFloat(Date().timeIntervalSince(holdStart) / path.requiredHold))
    }

    private func triggerFail() {
        phase = .failed
        showFailModal = true
        HapticService.error()
        SoundService.playFail()
    }

    func pathColor(_ index: Int) -> Color {
        switch PathColor(rawValue: index % 3) ?? .green {
        case .green: Color("AppPrimary")
        case .blue: Color("AppAccent")
        case .red: Color("AppTextSecondary")
        }
    }

    func retry() {
        setupLevel()
    }
}
