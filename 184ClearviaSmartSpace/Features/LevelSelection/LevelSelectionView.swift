import SwiftUI

struct LevelSelectionView: View {
    let activity: ActivityDefinition
    @EnvironmentObject private var progress: ProgressStore
    @State private var selectedDifficulty: Difficulty = .easy
    @State private var practiceMode = false
    @State private var showTutorial = false
    @State private var selectedLevelConfig: GameSessionConfig?
    @State private var showSpeedRun = false

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    private var availableDifficulties: [Difficulty] {
        Difficulty.availableCases(expertUnlocked: progress.isExpertUnlocked(for: activity.id))
    }

    var body: some View {
        ZStack {
            BackgroundPatternView()
            ScrollView {
                VStack(spacing: 18) {
                    activityHeader
                    ModeToggleCell(
                        isOn: $practiceMode,
                        title: "Practice Mode",
                        subtitle: "Learn freely — stars are not saved",
                        icon: "figure.walk"
                    )
                    difficultySection
                    mapSection
                    levelsSection
                    AppButton(title: "Speed Run — All 5 Levels", icon: "timer") {
                        HapticService.mediumTap()
                        showSpeedRun = true
                    }
                    AppButton(title: "Replay Tutorial", icon: "book.fill", style: .secondary) {
                        showTutorial = true
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle(activity.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if !progress.hasCompletedTutorial(for: activity.id) {
                showTutorial = true
            }
            if !availableDifficulties.contains(selectedDifficulty) {
                selectedDifficulty = .easy
            }
        }
        .fullScreenCover(isPresented: $showTutorial) {
            ActivityTutorialView(activity: activity) {
                progress.markTutorialCompleted(for: activity.id)
                showTutorial = false
            }
        }
        .navigationDestination(item: $selectedLevelConfig) { config in
            ActivityGameHost(config: config)
        }
        .navigationDestination(isPresented: $showSpeedRun) {
            SpeedRunView(activity: activity, difficulty: selectedDifficulty)
        }
    }

    private var activityHeader: some View {
        SurfaceCard(accentBorder: true) {
            HStack(spacing: 14) {
                IconBadgeView(systemName: activity.iconName, size: 52, iconSize: 22)
                VStack(alignment: .leading, spacing: 6) {
                    Text(activity.title)
                        .font(.headline.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text(activity.subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                    HStack(spacing: 8) {
                        StatusPillView(
                            text: "\(progress.totalStars(for: activity.id)) stars",
                            style: .accent
                        )
                        if progress.isExpertUnlocked(for: activity.id) {
                            StatusPillView(text: "Expert", style: .success)
                        }
                    }
                }
            }
        }
    }

    private var difficultySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(title: "Difficulty", iconName: "slider.horizontal.3")
            DifficultyPickerView(selection: $selectedDifficulty, options: availableDifficulties)
        }
    }

    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(title: "Progress Map", subtitle: "Clear levels to advance", iconName: "map.fill")
            SurfaceCard {
                LevelMapView(activityId: activity.id, difficulty: selectedDifficulty)
            }
        }
    }

    private var levelsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(title: "Levels", subtitle: "Tap an unlocked level to play", iconName: "square.grid.3x3.fill")
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(0..<5, id: \.self) { level in
                    levelCell(level: level)
                }
            }
        }
    }

    @ViewBuilder
    private func levelCell(level: Int) -> some View {
        let unlocked = progress.isLevelUnlocked(
            activityId: activity.id,
            difficulty: selectedDifficulty.storageKey,
            level: level
        ) || practiceMode
        let stars = progress.stars(
            for: activity.id,
            difficulty: selectedDifficulty.storageKey,
            level: level
        )
        let best = progress.personalBest(for: activity.id, difficulty: selectedDifficulty, level: level)

        LevelCell(
            level: level,
            stars: stars,
            unlocked: unlocked,
            bestAccuracy: best?.bestAccuracy,
            isPractice: practiceMode
        ) {
            selectedLevelConfig = GameSessionConfig(
                activityId: activity.id,
                difficulty: selectedDifficulty,
                level: level,
                mode: practiceMode ? .practice : .standard
            )
        }
    }
}

extension GameSessionConfig: Identifiable {
    var id: String { "\(activityId)_\(difficulty.storageKey)_\(level)_\(mode.rawValue)" }
}
