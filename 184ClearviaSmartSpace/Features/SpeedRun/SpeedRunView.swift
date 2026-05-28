import SwiftUI

struct SpeedRunView: View {
    let activity: ActivityDefinition
    let difficulty: Difficulty

    @EnvironmentObject private var progress: ProgressStore
    @Environment(\.dismiss) private var dismiss
    @State private var currentLevel = 0
    @State private var runStart = Date()
    @State private var showSummary = false
    @State private var completedLevels = 0

    var body: some View {
        ZStack {
            BackgroundPatternView()
            if showSummary {
                summaryView
            } else {
                VStack(spacing: 12) {
                    speedRunHeader
                    ActivityGameHost(config: GameSessionConfig(
                        activityId: activity.id,
                        difficulty: difficulty,
                        level: currentLevel,
                        mode: .speedRun
                    ))
                    .id(currentLevel)
                }
            }
        }
        .navigationTitle("Speed Run")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { runStart = Date() }
        .onReceive(NotificationCenter.default.publisher(for: .speedRunLevelComplete)) { notification in
            handleLevelComplete(notification)
        }
    }

    private var speedRunHeader: some View {
        SurfaceCard {
            HStack {
                Label("Level \(currentLevel + 1)/\(GameContent.speedRunLevelCount)", systemImage: "flag.checkered")
                Spacer()
                Label(elapsedFormatted, systemImage: "timer")
            }
            .font(.caption.bold())
            .foregroundStyle(Color("AppTextSecondary"))
        }
        .padding(.horizontal, 16)
    }

    private var elapsedFormatted: String {
        ProgressStore.formattedPlayTime(seconds: max(0, Int(Date().timeIntervalSince(runStart))))
    }

    private var summaryView: some View {
        ScrollView {
            VStack(spacing: 22) {
                IconBadgeView(systemName: "timer", size: 72, iconSize: 30)
                Text("Speed Run Complete!")
                    .font(.title.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                SurfaceCard(accentBorder: true) {
                    VStack(spacing: 6) {
                        Text(elapsedFormatted)
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundStyle(Color("AppAccent"))
                        Text("\(completedLevels)/\(GameContent.speedRunLevelCount) levels cleared")
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    .frame(maxWidth: .infinity)
                }
                if let best = progress.speedRunBests[activity.id] {
                    Text("Personal Best: \(ProgressStore.formattedPlayTime(seconds: best))")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                AppButton(title: "Back to Levels", icon: "arrow.left") { dismiss() }
                    .padding(.horizontal, 24)
            }
            .padding(24)
        }
    }

    private func handleLevelComplete(_ notification: Notification) {
        guard let success = notification.userInfo?["success"] as? Bool else { return }
        if success {
            completedLevels += 1
            if currentLevel >= GameContent.speedRunLevelCount - 1 {
                progress.recordSpeedRun(activityId: activity.id, totalSeconds: max(0, Int(Date().timeIntervalSince(runStart))), completed: true)
                showSummary = true
            } else {
                currentLevel += 1
            }
        } else {
            progress.recordSpeedRun(activityId: activity.id, totalSeconds: max(0, Int(Date().timeIntervalSince(runStart))), completed: false)
            showSummary = true
        }
    }
}
