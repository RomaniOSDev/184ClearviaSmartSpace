import Combine
import SwiftUI

struct MelodyHoldView: View {
    let config: GameSessionConfig

    @EnvironmentObject private var progress: ProgressStore
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: MelodyHoldViewModel
    @State private var showResult = false
    @State private var achievementSnapshot: AchievementSnapshot?
    @State private var newlyUnlocked: [AchievementDefinition] = []
    @State private var shakeOffset: CGFloat = 0

    init(config: GameSessionConfig) {
        self.config = config
        _viewModel = StateObject(wrappedValue: MelodyHoldViewModel(
            difficulty: config.difficulty,
            level: config.effectiveLevel,
            isPractice: config.mode == .practice
        ))
    }

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()
            if showResult {
                resultView
            } else {
                gameContent
                    .offset(x: shakeOffset)
            }
        }
        .navigationBarBackButtonHidden(showResult)
        .navigationTitle(config.track.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            achievementSnapshot = progress.achievementSnapshot()
        }
        .onChange(of: viewModel.phase) { phase in
            if phase == .success { finishLevel(success: true) }
            else if phase == .failed {
                triggerShake()
                if config.mode == .endless || config.mode == .speedRun {
                    finishLevel(success: false)
                }
            }
        }
        .overlay {
            if viewModel.showFailModal && !showResult && config.mode != .endless {
                failOverlay
            }
        }
    }

    private var gameContent: some View {
        VStack(spacing: 12) {
            InGameHintBar(text: ActivityHintProvider.hint(activityId: config.activityId, mode: config.mode))
            statusBar
            GeometryReader { geo in
                ZStack {
                    pathCanvas(size: geo.size)
                    ForEach(viewModel.notes.filter { !$0.landed }) { note in
                        holdNoteView(note: note, canvasSize: geo.size)
                    }
                }
            }
            .padding(.horizontal, 16)

            if viewModel.harmonyMode {
                Text("Harmony Mode — Double Points!")
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppAccent"))
            }

            holdProgressBar
        }
        .onReceive(Timer.publish(every: 1.0 / 30.0, on: .main, in: .common).autoconnect()) { _ in
            viewModel.tick()
        }
    }

    private var statusBar: some View {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Landings: \(viewModel.successfulLandings)/\(viewModel.targetLandings)")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("Streak: \(viewModel.streak)")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Spacer()
                Text("\(viewModel.timeRemaining)s")
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(Color("AppAccent"))
                ComboCounterView(combo: viewModel.streak, label: "Streak")
            }
        .padding(.horizontal, 20)
    }

    private var holdProgressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color("AppSurface"))
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color("AppPrimary"))
                    .frame(width: geo.size.width * viewModel.holdProgress)
            }
        }
        .frame(height: 6)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }

    private func pathCanvas(size: CGSize) -> some View {
        Canvas { context, canvasSize in
            for i in 0..<3 {
                let x = canvasSize.width * (0.2 + CGFloat(i) * 0.3)
                var path = Path()
                path.move(to: CGPoint(x: x, y: 20))
                path.addLine(to: CGPoint(x: x, y: canvasSize.height - 20))
                context.stroke(
                    path,
                    with: .color(viewModel.pathColor(i)),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
            }
        }
    }

    private func holdNoteView(note: HoldNote, canvasSize: CGSize) -> some View {
        let x = note.xFraction * canvasSize.width
        let y: CGFloat = note.isReleased ? canvasSize.height * 0.88 : 36

        return HoldNoteControl(
            note: note,
            pathColor: viewModel.pathColor(note.pathIndex),
            isActive: viewModel.holdingNoteId == note.id,
            onPressStart: { viewModel.beginHold(noteId: note.id) },
            onPressEnd: { viewModel.endHold(noteId: note.id) }
        )
        .position(x: x, y: y)
        .animation(note.isReleased ? .easeInOut(duration: 0.8) : .default, value: note.isReleased)
    }

    private var failOverlay: some View {
        ZStack {
            Color("AppTextSecondary").opacity(0.35).ignoresSafeArea()
            VStack(spacing: 16) {
                Text("Game Over")
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                AppButton(title: "Try Again") {
                    viewModel.retry()
                }
                AppButton(title: "Back to Levels", style: .secondary) {
                    dismiss()
                }
            }
            .padding(24)
            .background(Color("AppSurface"))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(24)
        }
    }

    private var resultView: some View {
        GameResultView(
            isSuccess: viewModel.phase == .success,
            stars: config.mode == .practice ? 0 : viewModel.earnedStars,
            primaryMetric: "\(viewModel.successfulLandings)",
            metricLabel: config.mode == .practice ? "Practice Complete" : "Perfect Landings",
            showNextLevel: config.mode == .standard && config.level < GameContent.levelsPerDifficulty - 1 && viewModel.phase == .success,
            newlyUnlocked: newlyUnlocked,
            onNextLevel: { dismiss() },
            onRetry: {
                showResult = false
                viewModel.setupLevel()
            },
            onBackToLevels: { dismiss() }
        )
    }

    private func finishLevel(success: Bool) {
        if GameSessionCoordinator.reportCompletion(config: config, success: success) { return }
        guard success, !showResult else { return }
        let snapshot = achievementSnapshot ?? progress.achievementSnapshot()
        if config.recordsProgress {
            progress.recordLevelResult(
                activityId: config.activityId,
                difficulty: config.difficulty.storageKey,
                level: config.level,
                stars: viewModel.earnedStars,
                playTimeSeconds: viewModel.elapsedSeconds,
                accuracy: viewModel.accuracy,
                combo: viewModel.maxCombo,
                mode: config.mode
            )
            newlyUnlocked = progress.newlyUnlockedAchievements(before: snapshot)
        }
        showResult = true
        viewModel.showFailModal = false
    }

    private func triggerShake() {
        withAnimation(.default) { shakeOffset = 10 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.default) { shakeOffset = -10 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.default) { shakeOffset = 0 }
        }
    }
}

private struct HoldNoteControl: View {
    let note: HoldNote
    let pathColor: Color
    let isActive: Bool
    let onPressStart: () -> Void
    let onPressEnd: () -> Void

    @State private var isPressing = false

    var body: some View {
        ZStack {
            Circle()
                .fill(pathColor)
                .frame(width: 44, height: 44)
                .overlay(
                    Circle()
                        .stroke(Color("AppTextPrimary").opacity(isActive ? 0.8 : 0), lineWidth: 2)
                )
            Text("♪")
                .font(.body.bold())
                .foregroundStyle(Color("AppTextPrimary"))
        }
        .frame(minWidth: 44, minHeight: 44)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressing {
                        isPressing = true
                        onPressStart()
                    }
                }
                .onEnded { _ in
                    if isPressing {
                        isPressing = false
                        onPressEnd()
                    }
                }
        )
    }
}
