import Combine
import SwiftUI

struct HarmonyPulseView: View {
    let config: GameSessionConfig

    @EnvironmentObject private var progress: ProgressStore
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: HarmonyPulseViewModel
    @State private var showResult = false
    @State private var achievementSnapshot: AchievementSnapshot?
    @State private var newlyUnlocked: [AchievementDefinition] = []

    init(config: GameSessionConfig) {
        self.config = config
        _viewModel = StateObject(wrappedValue: HarmonyPulseViewModel(
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
            }
        }
        .navigationBarBackButtonHidden(showResult)
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { achievementSnapshot = progress.achievementSnapshot() }
        .onChange(of: viewModel.phase) { phase in
            if phase == .success { finishLevel(success: true) }
            if phase == .failed {
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

    private var navigationTitle: String {
        let track = config.track
        switch config.mode {
        case .practice: return "Practice • \(track.title)"
        case .speedRun: return "Speed Run L\(config.level + 1)"
        case .dailyChallenge: return "Daily • \(track.title)"
        case .weeklyEvent: return "Weekly • \(track.title)"
        case .endless: return "Endless • Wave \(config.endlessWave + 1)"
        default: return track.title
        }
    }

    private var gameContent: some View {
        VStack(spacing: 12) {
            InGameHintBar(text: ActivityHintProvider.hint(activityId: config.activityId, mode: config.mode))
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Streak: \(viewModel.perfectStreak)/\(viewModel.requiredStreak)")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("Accuracy: \(Int(viewModel.accuracy * 100))%")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Spacer()
                ComboCounterView(combo: viewModel.perfectStreak)
            }
            .padding(.horizontal, 20)
            instructionBar
            GeometryReader { geo in
                TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                    Canvas { context, size in
                        drawGame(context: context, size: size, date: timeline.date)
                    }
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { value in
                                handleTap(at: value.location, in: geo.size)
                            }
                    )
                }
            }
            .padding(.horizontal, 16)
            progressBar
            personalBestFooter
        }
        .onReceive(Timer.publish(every: 1.0 / 30.0, on: .main, in: .common).autoconnect()) { _ in
            viewModel.updateTimer()
        }
    }

    private var instructionBar: some View {
        VStack(spacing: 4) {
            if let note = viewModel.activeNodeNote {
                Text("Tap note \(note) when the ring reaches the center")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                Text(viewModel.isInHitWindow ? "NOW!" : "Wait for the pulse…")
                    .font(.caption.bold())
                    .foregroundStyle(viewModel.isInHitWindow ? Color("AppAccent") : Color("AppTextSecondary"))
            }
        }
        .padding(.horizontal, 20)
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4).fill(Color("AppSurface"))
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color("AppAccent"))
                    .frame(width: geo.size.width * CGFloat(viewModel.perfectStreak) / CGFloat(viewModel.requiredStreak))
            }
        }
        .frame(height: 8)
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private var personalBestFooter: some View {
        if let best = progress.personalBest(for: config.activityId, difficulty: config.difficulty, level: config.level),
           best.bestAccuracy > 0 {
            Text("Best: \(Int(best.bestAccuracy * 100))% • \(best.bestCombo) combo")
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
                .padding(.bottom, 12)
        }
    }

    private func drawGame(context: GraphicsContext, size: CGSize, date: Date) {
        if viewModel.perfectStreak < viewModel.checkpoints.count,
           let activeId = viewModel.activeNodeId,
           let node = viewModel.nodes.first(where: { $0.id == activeId }) {
            let nodePoint = viewModel.scaledPoint(node.position, in: size)
            let guideRadius = viewModel.guideRingRadius(in: size)
            let guideRect = CGRect(
                x: nodePoint.x - guideRadius,
                y: nodePoint.y - guideRadius,
                width: guideRadius * 2,
                height: guideRadius * 2
            )
            context.stroke(
                Path(ellipseIn: guideRect),
                with: .color(viewModel.isInHitWindow ? Color("AppAccent").opacity(0.95) : Color("AppAccent").opacity(0.45)),
                lineWidth: viewModel.isInHitWindow ? 4 : 2
            )
        }

        for wave in viewModel.activeWaves {
            let radius = viewModel.waveRadius(at: date, startTime: wave.startTime, maxRadius: wave.maxRadius)
            let rect = CGRect(x: wave.origin.x - radius, y: wave.origin.y - radius, width: radius * 2, height: radius * 2)
            context.stroke(Path(ellipseIn: rect), with: .color(Color("AppPrimary").opacity(0.7)), lineWidth: 2)
        }

        for node in viewModel.nodes {
            let point = viewModel.scaledPoint(node.position, in: size)
            let isActive = node.id == viewModel.activeNodeId
            let rect = CGRect(x: point.x - 28, y: point.y - 28, width: 56, height: 56)
            if isActive {
                context.stroke(Path(ellipseIn: rect.insetBy(dx: -6, dy: -6)), with: .color(Color("AppAccent")), lineWidth: 3)
            }
            context.fill(Path(ellipseIn: rect), with: .color(isActive ? Color("AppPrimary") : Color("AppSurface")))
            context.draw(Text(node.note).font(.title2.bold()).foregroundColor(Color("AppTextPrimary")), at: point)
        }
    }

    private func handleTap(at location: CGPoint, in size: CGSize) {
        for node in viewModel.nodes {
            let point = viewModel.scaledPoint(node.position, in: size)
            if hypot(location.x - point.x, location.y - point.y) < 36 {
                viewModel.tapNode(node.id, canvasSize: size)
                return
            }
        }
    }

    private var failOverlay: some View {
        ZStack {
            Color("AppTextSecondary").opacity(0.35).ignoresSafeArea()
            VStack(spacing: 16) {
                Text("Sequence Reset")
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                Text("Tap the highlighted note when the ring closes in.")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                AppButton(title: "Try Again") { viewModel.retryAfterFail() }
                AppButton(title: "Back to Levels", style: .secondary) { dismiss() }
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
            primaryMetric: "\(Int(viewModel.accuracy * 100))%",
            metricLabel: config.mode == .practice ? "Practice Complete" : "Accuracy",
            showNextLevel: config.mode == .standard && config.level < GameContent.levelsPerDifficulty - 1,
            newlyUnlocked: newlyUnlocked,
            onNextLevel: { dismiss() },
            onRetry: { showResult = false; viewModel.setupLevel() },
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
                playTimeSeconds: max(0, Int(Date().timeIntervalSince(viewModel.sessionStart))),
                accuracy: viewModel.accuracy,
                combo: viewModel.maxCombo,
                mode: config.mode
            )
            newlyUnlocked = progress.newlyUnlockedAchievements(before: snapshot)
        }
        showResult = true
    }
}
