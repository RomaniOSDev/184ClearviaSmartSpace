import Combine
import SwiftUI

struct MelodyGlideView: View {
    let config: GameSessionConfig

    @EnvironmentObject private var progress: ProgressStore
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: MelodyGlideViewModel
    @State private var showResult = false
    @State private var achievementSnapshot: AchievementSnapshot?
    @State private var newlyUnlocked: [AchievementDefinition] = []

    init(config: GameSessionConfig) {
        self.config = config
        _viewModel = StateObject(wrappedValue: MelodyGlideViewModel(
            difficulty: config.difficulty,
            level: config.level,
            isPractice: config.mode == .practice
        ))
    }

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()
            if showResult { resultView } else { gameContent }
        }
        .navigationBarBackButtonHidden(showResult)
        .onAppear { achievementSnapshot = progress.achievementSnapshot() }
        .onChange(of: viewModel.phase) { phase in
            if phase == .success { finishLevel(success: true) }
            if phase == .failed && config.mode == .speedRun { finishLevel(success: false) }
        }
        .overlay {
            if viewModel.showFailModal && !showResult { failOverlay }
        }
    }

    private var gameContent: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Notes: \(viewModel.completedNotes)/\(viewModel.totalNotes)")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                Spacer()
                ComboCounterView(combo: viewModel.combo)
            }
            .padding(.horizontal, 20)

            GeometryReader { geo in
                Canvas { context, size in
                    drawLanes(context: context, size: size)
                    drawNotes(context: context, size: size)
                }
                .gesture(dragGesture(in: geo.size))
            }
            .padding(.horizontal, 16)

            if let best = progress.personalBest(for: config.activityId, difficulty: config.difficulty, level: config.level),
               best.bestAccuracy > 0 {
                Text("Best: \(Int(best.bestAccuracy * 100))% • \(ProgressStore.formattedPlayTime(seconds: best.bestTimeSeconds))")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .onReceive(Timer.publish(every: 1.0 / 30.0, on: .main, in: .common).autoconnect()) { _ in
            viewModel.updateGlides()
        }
    }

    private func drawLanes(context: GraphicsContext, size: CGSize) {
        for lane in viewModel.lanes {
            let y = lane.yFraction * size.height
            var path = Path()
            path.move(to: CGPoint(x: 16, y: y))
            path.addLine(to: CGPoint(x: size.width - 16, y: y))
            context.stroke(path, with: .color(viewModel.laneColor(lane.colorIndex)), style: StrokeStyle(lineWidth: 4, lineCap: .round))
        }
    }

    private func drawNotes(context: GraphicsContext, size: CGSize) {
        for note in viewModel.notes {
            let point = CGPoint(x: note.position.x * size.width, y: note.position.y * size.height)
            let rect = CGRect(x: point.x - 18, y: point.y - 18, width: 36, height: 36)
            context.fill(Path(ellipseIn: rect), with: .color(viewModel.laneColor(note.colorIndex)))
            context.draw(Text("♪").font(.body.bold()).foregroundColor(Color("AppTextPrimary")), at: point)
        }
    }

    private func dragGesture(in size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 1)
            .onChanged { value in
                if viewModel.draggingNoteId == nil, let noteId = noteAt(value.startLocation, in: size) {
                    viewModel.startDrag(noteId: noteId)
                }
                if let noteId = viewModel.draggingNoteId {
                    viewModel.updateDrag(noteId: noteId, location: value.location, canvasSize: size)
                }
            }
            .onEnded { _ in
                if let noteId = viewModel.draggingNoteId {
                    viewModel.endDrag(noteId: noteId, canvasSize: size)
                }
            }
    }

    private func noteAt(_ point: CGPoint, in size: CGSize) -> Int? {
        for note in viewModel.notes where !note.isGliding {
            let np = CGPoint(x: note.position.x * size.width, y: note.position.y * size.height)
            if hypot(point.x - np.x, point.y - np.y) < 24 { return note.id }
        }
        return nil
    }

    private var failOverlay: some View {
        ZStack {
            Color("AppTextSecondary").opacity(0.35).ignoresSafeArea()
            VStack(spacing: 16) {
                Text("Too Many Misses").font(.title2.bold()).foregroundStyle(Color("AppTextPrimary"))
                AppButton(title: "Try Again") { viewModel.retryAfterFail() }
                AppButton(title: "Back to Levels", style: .secondary) { dismiss() }
            }
            .padding(24).background(Color("AppSurface")).clipShape(RoundedRectangle(cornerRadius: 16)).padding(24)
        }
    }

    private var resultView: some View {
        GameResultView(
            isSuccess: viewModel.phase == .success,
            stars: config.mode == .practice ? 0 : viewModel.earnedStars,
            primaryMetric: "\(Int(viewModel.accuracy * 100))%",
            metricLabel: config.mode == .practice ? "Practice Complete" : "Accuracy",
            showNextLevel: config.mode == .standard && config.level < 4,
            newlyUnlocked: newlyUnlocked,
            onNextLevel: { dismiss() },
            onRetry: { showResult = false; viewModel.setupLevel() },
            onBackToLevels: { dismiss() }
        )
    }

    private func finishLevel(success: Bool) {
        if config.mode == .speedRun {
            NotificationCenter.default.post(name: .speedRunLevelComplete, object: nil, userInfo: ["success": success])
            return
        }
        guard success, !showResult else { return }
        let snapshot = achievementSnapshot ?? progress.achievementSnapshot()
        if config.recordsProgress {
            progress.recordLevelResult(
                activityId: config.activityId,
                difficulty: config.difficulty.storageKey,
                level: config.level,
                stars: viewModel.earnedStars,
                playTimeSeconds: viewModel.elapsedSecondsSinceSessionStart,
                accuracy: viewModel.accuracy,
                combo: viewModel.maxCombo,
                mode: config.mode
            )
            newlyUnlocked = progress.newlyUnlockedAchievements(before: snapshot)
        }
        showResult = true
        viewModel.showFailModal = false
    }
}
