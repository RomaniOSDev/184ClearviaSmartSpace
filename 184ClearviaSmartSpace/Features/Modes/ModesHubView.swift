import SwiftUI

struct ModesHubView: View {
    let activity: ActivityDefinition

    @EnvironmentObject private var progress: ProgressStore
    @State private var selectedDifficulty: Difficulty = .easy
    @State private var showEndless = false
    @State private var showDuel = false
    @State private var showEditor = false
    @State private var showWeekly = false
    @State private var showLeaderboards = false

    private var availableDifficulties: [Difficulty] {
        Difficulty.availableCases(expertUnlocked: progress.isExpertUnlocked(for: activity.id))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeaderView(title: "Special Modes", subtitle: "Extra ways to play", iconName: "gamecontroller.fill")
            DifficultyPickerView(selection: $selectedDifficulty, options: availableDifficulties)

            VStack(spacing: 10) {
                modeCell(
                    title: "Endless",
                    subtitle: "Survive escalating waves",
                    icon: "infinity",
                    action: { showEndless = true }
                )
                modeCell(
                    title: "Weekly Spotlight",
                    subtitle: progress.isWeeklyEventAvailable() ? "Bonus stars available" : "Completed this week",
                    icon: "sparkles",
                    action: { showWeekly = true }
                )
                if activity.id == "tap_sequence" {
                    modeCell(
                        title: "Pattern Studio",
                        subtitle: "Create and play custom patterns",
                        icon: "slider.horizontal.3",
                        action: { showEditor = true }
                    )
                }
                modeCell(
                    title: "Local Duel",
                    subtitle: "Two players, one device",
                    icon: "person.2.fill",
                    action: { showDuel = true }
                )
                modeCell(
                    title: "Leaderboards",
                    subtitle: "Game Center rankings",
                    icon: "list.number",
                    action: {
                        Task { @MainActor in
                            GameCenterManager.shared.presentLeaderboards()
                        }
                    }
                )
            }
        }
        .navigationDestination(isPresented: $showEndless) {
            EndlessModeView(activity: activity, difficulty: selectedDifficulty)
        }
        .navigationDestination(isPresented: $showDuel) {
            DuelModeView()
        }
        .navigationDestination(isPresented: $showEditor) {
            PatternEditorView(activity: activity)
        }
        .navigationDestination(isPresented: $showWeekly) {
            WeeklyEventView()
        }
    }

    private func modeCell(title: String, subtitle: String, icon: String, action: @escaping () -> Void) -> some View {
        SettingsCell(title: title, icon: icon, subtitle: subtitle, action: action)
    }
}
