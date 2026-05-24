import Combine
import Foundation
import SwiftUI

enum TapSequencePhase {
    case showing
    case input
    case success
    case failed
}

@MainActor
final class TapSequenceViewModel: ObservableObject {
    @Published var notes = ["C", "D", "E", "F", "G", "A"]
    @Published var sequence: [Int] = []
    @Published var inputIndex = 0
    @Published var highlightedIndex: Int?
    @Published var phase: TapSequencePhase = .showing
    @Published var showFailModal = false
    @Published var combo = 0
    @Published var maxCombo = 0
    @Published var totalSteps = 0
    @Published var correctSteps = 0

    var sessionStart = Date()

    let difficulty: Difficulty
    let level: Int
    let isPractice: Bool

    private var sequenceLength: Int {
        let base: Int
        switch difficulty {
        case .easy: base = 3
        case .normal: base = 4
        case .hard: base = 5
        case .expert: base = 6
        }
        return min(8, base + level / 2)
    }

    var accuracy: Double {
        guard totalSteps > 0 else { return 0 }
        return Double(correctSteps) / Double(totalSteps)
    }

    var earnedStars: Int {
        StarCalculator.stars(for: accuracy)
    }

    init(difficulty: Difficulty, level: Int, isPractice: Bool) {
        self.difficulty = difficulty
        self.level = level
        self.isPractice = isPractice
        setupLevel()
    }

    func setupLevel() {
        sessionStart = Date()
        combo = 0
        maxCombo = 0
        totalSteps = 0
        correctSteps = 0
        inputIndex = 0
        showFailModal = false
        phase = .showing
        sequence = (0..<sequenceLength).map { _ in Int.random(in: 0..<6) }
        playSequence()
    }

    func playSequence() {
        phase = .showing
        inputIndex = 0
        Task {
            try? await Task.sleep(nanoseconds: 400_000_000)
            for (i, note) in sequence.enumerated() {
                highlightedIndex = note
                try? await Task.sleep(nanoseconds: UInt64(displayDuration * 1_000_000_000))
                if i == sequence.count - 1 {
                    highlightedIndex = nil
                }
            }
            try? await Task.sleep(nanoseconds: 300_000_000)
            highlightedIndex = nil
            phase = .input
        }
    }

    func tap(noteIndex: Int) {
        guard phase == .input else { return }
        HapticService.mediumTap()
        totalSteps += 1

        if sequence[inputIndex] == noteIndex {
            correctSteps += 1
            combo += 1
            maxCombo = max(maxCombo, combo)
            inputIndex += 1
            SoundService.playSuccess()
            if inputIndex >= sequence.count {
                phase = .success
                HapticService.success()
            }
        } else {
            combo = 0
            SoundService.playFail()
            if isPractice {
                inputIndex = 0
                phase = .input
            } else {
                phase = .failed
                showFailModal = true
                HapticService.error()
            }
        }
    }

    private var displayDuration: TimeInterval {
        switch difficulty {
        case .easy: 0.75
        case .normal: 0.6
        case .hard: 0.5
        case .expert: 0.4
        }
    }

    func retryAfterFail() {
        showFailModal = false
        phase = .showing
        setupLevel()
    }
}
