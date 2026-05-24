import Combine
import Foundation
import SwiftUI

struct PulseNode: Identifiable {
    let id: Int
    let note: String
    let position: CGPoint
}

struct RhythmCheckpoint: Identifiable {
    let id: Int
    let position: CGPoint
    let nodeId: Int
}

enum HarmonyPulsePhase {
    case playing
    case success
    case failed
}

@MainActor
final class HarmonyPulseViewModel: ObservableObject {
    @Published var nodes: [PulseNode] = []
    @Published var checkpoints: [RhythmCheckpoint] = []
    @Published var activeWaves: [(nodeId: Int, startTime: Date, origin: CGPoint, maxRadius: CGFloat)] = []
    @Published var perfectStreak = 0
    @Published var totalAttempts = 0
    @Published var successfulAttempts = 0
    @Published var phase: HarmonyPulsePhase = .playing
    @Published var showFailModal = false
    @Published var syncProgress: Double = 0
    @Published var maxCombo = 0

    var sessionStart = Date()

    let requiredStreak = 5
    let difficulty: Difficulty
    let level: Int
    let isPractice: Bool

    private var beatStartTime = Date()
    private let waveSpeedPointsPerSecond: CGFloat = 280
    private let hitWindowStart = 0.78
    private let hitWindowEnd = 1.12

    var tolerance: TimeInterval {
        switch difficulty {
        case .easy: 0.5
        case .normal: 0.3
        case .hard: 0.1
        case .expert: 0.05
        }
    }

    /// How long one beat cycle lasts before the tap window closes.
    private var beatDuration: TimeInterval {
        let base: TimeInterval
        switch difficulty {
        case .easy: base = 2.8
        case .normal: base = 2.2
        case .hard: base = 1.8
        case .expert: base = 1.4
        }
        return max(1.4, base - Double(level) * 0.08)
    }

    /// Extra time after the beat ends before counting a miss.
    private var missGraceDuration: TimeInterval {
        tolerance + 0.25
    }

    var activeNodeId: Int? {
        guard phase == .playing,
              perfectStreak < checkpoints.count else { return nil }
        return checkpoints[perfectStreak].nodeId
    }

    var activeNodeNote: String? {
        guard let id = activeNodeId else { return nil }
        return nodes.first(where: { $0.id == id })?.note
    }

    var isInHitWindow: Bool {
        syncProgress >= hitWindowStart && syncProgress <= hitWindowEnd
    }

    var accuracy: Double {
        guard totalAttempts > 0 else { return 0 }
        return Double(successfulAttempts) / Double(totalAttempts)
    }

    var earnedStars: Int {
        StarCalculator.stars(for: accuracy)
    }

    init(difficulty: Difficulty, level: Int, isPractice: Bool = false) {
        self.difficulty = difficulty
        self.level = level
        self.isPractice = isPractice
        setupLevel()
    }

    func setupLevel() {
        sessionStart = Date()
        perfectStreak = 0
        maxCombo = 0
        totalAttempts = 0
        successfulAttempts = 0
        phase = .playing
        showFailModal = false
        activeWaves = []
        syncProgress = 0
        beatStartTime = Date()
        configureNodesAndCheckpoints()
    }

    func tapNode(_ nodeId: Int, canvasSize: CGSize) {
        guard phase == .playing else { return }
        guard perfectStreak < checkpoints.count,
              checkpoints[perfectStreak].nodeId == nodeId else {
            notifyWrongNode()
            return
        }

        HapticService.mediumTap()
        totalAttempts += 1

        guard let node = nodes.first(where: { $0.id == nodeId }) else { return }
        let checkpoint = checkpoints[perfectStreak]
        let origin = scaledPoint(node.position, in: canvasSize)
        let target = scaledPoint(checkpoint.position, in: canvasSize)
        let travelDistance = hypot(target.x - origin.x, target.y - origin.y)

        if isInHitWindow {
            successfulAttempts += 1
            perfectStreak += 1
            maxCombo = max(maxCombo, perfectStreak)
            SoundService.playSuccess()
            activeWaves.append((
                nodeId: nodeId,
                startTime: Date(),
                origin: origin,
                maxRadius: max(travelDistance, 40)
            ))
            startNextBeat()
            if perfectStreak >= requiredStreak {
                phase = .success
                HapticService.success()
                SoundService.playSuccess()
            }
        } else {
            SoundService.playFail()
            handleFailAlignment()
        }
    }

    func updateTimer(now: Date = Date()) {
        let elapsed = now.timeIntervalSince(beatStartTime)
        syncProgress = elapsed / beatDuration

        activeWaves.removeAll { now.timeIntervalSince($0.startTime) > 1.8 }

        guard phase == .playing, !showFailModal else { return }

        if elapsed > beatDuration + missGraceDuration {
            totalAttempts += 1
            SoundService.playFail()
            handleFailAlignment()
        }
    }

    func waveRadius(at time: Date, startTime: Date, maxRadius: CGFloat) -> CGFloat {
        min(maxRadius, CGFloat(time.timeIntervalSince(startTime)) * waveSpeedPointsPerSecond)
    }

    func guideRingRadius(in size: CGSize) -> CGFloat {
        guard let activeId = activeNodeId,
              let node = nodes.first(where: { $0.id == activeId }),
              perfectStreak < checkpoints.count else { return 0 }

        let origin = scaledPoint(node.position, in: size)
        let target = scaledPoint(checkpoints[perfectStreak].position, in: size)
        let maxRadius = hypot(target.x - origin.x, target.y - origin.y)
        return max(36, CGFloat(syncProgress) * max(maxRadius, 60))
    }

    func retryAfterFail() {
        showFailModal = false
        phase = .playing
        activeWaves = []
        syncProgress = 0
        beatStartTime = Date()
    }

    private func startNextBeat() {
        syncProgress = 0
        beatStartTime = Date()
    }

    private func notifyWrongNode() {
        totalAttempts += 1
        SoundService.playFail()
        handleFailAlignment()
    }

    private func handleFailAlignment() {
        perfectStreak = 0
        if isPractice {
            phase = .playing
            showFailModal = false
            activeWaves = []
            syncProgress = 0
            beatStartTime = Date()
            return
        }
        phase = .failed
        showFailModal = true
        HapticService.error()
        activeWaves = []
        syncProgress = 0
        beatStartTime = Date()
    }

    private func configureNodesAndCheckpoints() {
        let noteLetters = ["A", "B", "C", "D", "E"]
        nodes = noteLetters.enumerated().map { index, letter in
            let angle = Double(index) * 2 * .pi / 5 - .pi / 2
            return PulseNode(
                id: index,
                note: letter,
                position: CGPoint(
                    x: 0.5 + cos(angle) * 0.28,
                    y: 0.48 + sin(angle) * 0.24
                )
            )
        }

        checkpoints = (0..<requiredStreak).map { index in
            let node = nodes[index % nodes.count]
            let angle = Double(index % nodes.count) * 2 * .pi / 5 - .pi / 2
            return RhythmCheckpoint(
                id: index,
                position: CGPoint(
                    x: 0.5 + cos(angle) * 0.14,
                    y: 0.48 + sin(angle) * 0.12
                ),
                nodeId: node.id
            )
        }
    }

    func scaledPoint(_ normalized: CGPoint, in size: CGSize) -> CGPoint {
        CGPoint(x: normalized.x * size.width, y: normalized.y * size.height)
    }
}
