import SwiftUI

struct TrackLibraryView: View {
    let activity: ActivityDefinition
    @EnvironmentObject private var progress: ProgressStore
    @State private var selectedDifficulty: Difficulty = .easy
    @State private var selectedConfig: GameSessionConfig?

    private var availableDifficulties: [Difficulty] {
        Difficulty.availableCases(expertUnlocked: progress.isExpertUnlocked(for: activity.id))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(
                title: "Track Library",
                subtitle: "\(GameContent.levelsPerDifficulty) songs with unique patterns",
                iconName: "music.note.list"
            )
            DifficultyPickerView(selection: $selectedDifficulty, options: availableDifficulties)

            VStack(spacing: 10) {
                ForEach(TrackCatalog.tracks(for: activity.id)) { track in
                    trackRow(track)
                }
            }
        }
        .navigationDestination(item: $selectedConfig) { config in
            ActivityGameHost(config: config)
        }
        .onChange(of: selectedDifficulty) { difficulty in
            if !availableDifficulties.contains(difficulty) {
                selectedDifficulty = .easy
            }
        }
    }

    private func trackRow(_ track: TrackDefinition) -> some View {
        let unlocked = progress.isLevelUnlocked(
            activityId: activity.id,
            difficulty: selectedDifficulty.storageKey,
            level: track.levelIndex
        )
        let stars = progress.stars(
            for: activity.id,
            difficulty: selectedDifficulty.storageKey,
            level: track.levelIndex
        )

        return Button {
            guard unlocked else { return }
            HapticService.mediumTap()
            selectedConfig = GameSessionConfig(
                activityId: activity.id,
                difficulty: selectedDifficulty,
                level: track.levelIndex,
                mode: .standard
            )
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AppGradients.surfaceInset)
                        .frame(width: 48, height: 48)
                    Image(systemName: track.previewIcon)
                        .font(.title3)
                        .foregroundStyle(Color("AppAccent"))
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(track.title)
                        .font(.subheadline.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(track.displaySubtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Spacer()
                StarRatingView(count: stars, size: 10)
                if !unlocked {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            .padding(12)
            .background(ElevatedSurfaceBackground(cornerRadius: 16, accentBorder: stars >= 3))
            .appSoftShadow(radius: 3, y: 1)
            .opacity(unlocked ? 1 : 0.6)
        }
        .buttonStyle(.plain)
    }
}
