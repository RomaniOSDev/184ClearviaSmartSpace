import Combine
import Foundation
import SwiftUI

struct GlideNote: Identifiable {
    let id: Int
    var laneIndex: Int
    var colorIndex: Int
    var position: CGPoint
    var isGliding: Bool
    var glideProgress: CGFloat
}

struct GlideLane: Identifiable {
    let id: Int
    let colorIndex: Int
    let yFraction: CGFloat
}

enum MelodyGlidePhase {
    case playing
    case success
    case failed
}

@MainActor
final class MelodyGlideViewModel: ObservableObject {
    @Published var lanes: [GlideLane] = []
    @Published var notes: [GlideNote] = []
    @Published var missedCount = 0
    @Published var completedNotes = 0
    @Published var totalNotes = 0
    @Published var phase: MelodyGlidePhase = .playing
    @Published var showFailModal = false
    @Published var draggingNoteId: Int?
    @Published var combo = 0
    @Published var maxCombo = 0
    var sessionStart = Date()

    let difficulty: Difficulty
    let level: Int
    let isPractice: Bool
    let maxMisses = 3

    private var glideSpeed: CGFloat = 0.018
    private var hardSpeedBoostApplied = false

    var noteCount: Int {
        switch difficulty {
        case .easy: 3
        case .normal: 4
        case .hard: 5
        case .expert: 6
        }
    }

    var accuracy: Double {
        guard totalNotes > 0 else { return 0 }
        return Double(completedNotes) / Double(totalNotes)
    }

    var earnedStars: Int {
        StarCalculator.stars(for: accuracy)
    }

    var elapsedSecondsSinceSessionStart: Int {
        max(0, Int(Date().timeIntervalSince(sessionStart)))
    }

    init(difficulty: Difficulty, level: Int, isPractice: Bool = false) {
        self.difficulty = difficulty
        self.level = level
        self.isPractice = isPractice
        if difficulty == .hard || difficulty == .expert { glideSpeed = 0.024 }
        if difficulty == .expert { glideSpeed = 0.032 }
        setupLevel()
    }

    func setupLevel() {
        sessionStart = Date()
        combo = 0
        maxCombo = 0
        missedCount = 0
        completedNotes = 0
        phase = .playing
        showFailModal = false
        draggingNoteId = nil
        hardSpeedBoostApplied = false
        totalNotes = noteCount

        lanes = (0..<5).map { i in
            GlideLane(id: i, colorIndex: i % 4, yFraction: 0.24 + CGFloat(i) * 0.12)
        }

        notes = (0..<noteCount).map { i in
            let laneIndex = i % 5
            return GlideNote(
                id: i,
                laneIndex: laneIndex,
                colorIndex: laneIndex % 4,
                position: CGPoint(x: 0.1 + CGFloat(i) * 0.04, y: 0.1),
                isGliding: false,
                glideProgress: 0
            )
        }
    }

    func startDrag(noteId: Int) {
        draggingNoteId = noteId
        HapticService.mediumTap()
    }

    func updateDrag(noteId: Int, location: CGPoint, canvasSize: CGSize) {
        guard let index = notes.firstIndex(where: { $0.id == noteId }) else { return }
        notes[index].position = CGPoint(
            x: max(0.02, min(0.96, location.x / canvasSize.width)),
            y: max(0.02, min(0.96, location.y / canvasSize.height))
        )
    }

    func endDrag(noteId: Int, canvasSize: CGSize) {
        draggingNoteId = nil
        guard let index = notes.firstIndex(where: { $0.id == noteId }),
              !notes[index].isGliding else { return }

        let lane = lanes[notes[index].laneIndex]
        let laneY = lane.yFraction

        guard notes[index].colorIndex == lane.colorIndex else {
            registerMiss()
            resetNote(at: index)
            return
        }

        let distY = abs(notes[index].position.y - laneY)
        if distY < 0.038 && notes[index].position.x <= 0.38 {
            let lanePoint = CGPoint(x: notes[index].position.x, y: laneY)
            notes[index].position = lanePoint
            notes[index].isGliding = true
            HapticService.mediumTap()
            SoundService.playSuccess()
            applyHardSpeedBoostIfNeeded()
        } else {
            registerMiss()
            resetNote(at: index)
        }
    }

    func updateGlides() {
        for i in notes.indices {
            guard notes[i].isGliding else { continue }
            let previousProgress = notes[i].glideProgress
            notes[i].glideProgress += glideSpeed
            notes[i].position.x = 0.15 + notes[i].glideProgress * 0.78
            if previousProgress < 1.0, notes[i].glideProgress >= 1.0 {
                notes[i].glideProgress = 1.0
                notes[i].position.x = 0.9
                completedNotes += 1
                combo += 1
                maxCombo = max(maxCombo, combo)
            }
        }
        guard phase == .playing else { return }
        if completedNotes >= totalNotes, totalNotes > 0 {
            phase = .success
            HapticService.success()
            SoundService.playSuccess()
        }
    }

    func retryAfterFail() {
        showFailModal = false
        phase = .playing
        setupLevel()
    }

    private func applyHardSpeedBoostIfNeeded() {
        guard difficulty == .hard else { return }
        if !hardSpeedBoostApplied {
            guard completedNotes >= 1 else { return }
        }
        if completedNotes >= 1, !hardSpeedBoostApplied {
            glideSpeed *= 2
            hardSpeedBoostApplied = true
        }
    }

    private func resetNote(at index: Int) {
        let laneIndex = notes[index].laneIndex
        notes[index].position = CGPoint(x: 0.1 + CGFloat(index) * 0.04, y: 0.1)
        notes[index].isGliding = false
        notes[index].glideProgress = 0
        notes[index].laneIndex = laneIndex
        HapticService.error()
        SoundService.playFail()
    }

    private func registerMiss() {
        combo = 0
        missedCount += 1
        if missedCount >= maxMisses {
            if isPractice {
                missedCount = 0
                setupLevel()
                return
            }
            phase = .failed
            showFailModal = true
            HapticService.error()
            SoundService.playFail()
        }
    }

    func laneColor(_ index: Int) -> Color {
        switch index % 4 {
        case 0: Color("AppPrimary")
        case 1: Color("AppAccent")
        case 2: Color("AppSurface")
        default: Color("AppTextSecondary")
        }
    }
}
