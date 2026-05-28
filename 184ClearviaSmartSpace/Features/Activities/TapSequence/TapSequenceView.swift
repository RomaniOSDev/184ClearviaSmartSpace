import SwiftUI

struct TapSequenceView: View {
    let config: GameSessionConfig

    @EnvironmentObject private var progress: ProgressStore
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: TapSequenceViewModel
    @State private var showResult = false
    @State private var achievementSnapshot: AchievementSnapshot?
    @State private var newlyUnlocked: [AchievementDefinition] = []

    init(config: GameSessionConfig) {
        self.config = config
        _viewModel = StateObject(wrappedValue: TapSequenceViewModel(
            activityId: config.activityId,
            difficulty: config.difficulty,
            level: config.effectiveLevel,
            isPractice: config.mode == .practice,
            mode: config.mode,
            customPattern: config.customPatternNotes
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
        .navigationTitle(config.track.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { achievementSnapshot = progress.achievementSnapshot() }
        .onChange(of: viewModel.phase) { phase in
            if phase == .success { finishLevel(success: true) }
            if phase == .failed, config.mode == .endless || config.mode == .speedRun {
                finishLevel(success: false)
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
            HStack {
                Text(config.track.title)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                Spacer()
                ComboCounterView(combo: viewModel.combo)
            }
            .padding(.horizontal, 20)

            Text(phaseLabel)
                .font(.subheadline)
                .foregroundStyle(Color("AppTextSecondary"))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(0..<6, id: \.self) { index in
                    noteButton(index: index)
                }
            }
            .padding(.horizontal, 24)

            if let best = progress.personalBest(for: config.activityId, difficulty: config.difficulty, level: config.level),
               best.bestAccuracy > 0 {
                Text("Best: \(Int(best.bestAccuracy * 100))% • \(best.bestCombo) combo")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }

            Spacer()
        }
        .padding(.top, 8)
    }

    private var phaseLabel: String {
        switch viewModel.phase {
        case .showing: "Watch the sequence…"
        case .input: "Your turn — repeat the pattern"
        case .success: "Perfect!"
        case .failed: "Try again"
        }
    }

    private func noteButton(index: Int) -> some View {
        let isHighlighted = viewModel.highlightedIndex == index
        return Button {
            viewModel.tap(noteIndex: index)
        } label: {
            Text(viewModel.notes[index])
                .font(.title2.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(isHighlighted ? Color("AppAccent") : Color("AppSurface"))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isHighlighted ? Color("AppPrimary") : Color.clear, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
        .disabled(viewModel.phase == .showing)
    }

    private var failOverlay: some View {
        ZStack {
            Color("AppTextSecondary").opacity(0.35).ignoresSafeArea()
            VStack(spacing: 16) {
                Text("Wrong Note")
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
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
            isSuccess: true,
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

    private func finishLevel(success: Bool = true) {
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
