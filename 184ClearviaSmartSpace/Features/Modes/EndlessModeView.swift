import SwiftUI

struct EndlessModeView: View {
    let activity: ActivityDefinition
    let difficulty: Difficulty

    @EnvironmentObject private var progress: ProgressStore
    @Environment(\.dismiss) private var dismiss
    @State private var wave = 0
    @State private var showSummary = false
    @State private var isPlaying = true

  private var best: Int {
        progress.endlessBestScores[activity.id] ?? 0
    }

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()
            if showSummary {
                summaryView
            } else if isPlaying {
                VStack(spacing: 8) {
                    endlessHeader
                    ActivityGameHost(config: GameSessionConfig(
                        activityId: activity.id,
                        difficulty: difficulty,
                        level: min(wave, GameContent.levelsPerDifficulty - 1),
                        mode: .endless,
                        endlessWave: wave
                    ))
                    .id(wave)
                }
            }
        }
        .navigationTitle("Endless")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(NotificationCenter.default.publisher(for: .endlessWaveComplete)) { note in
            handleWave(note)
        }
    }

    private var endlessHeader: some View {
        SurfaceCard(accentBorder: true) {
            HStack {
                Label("Wave \(wave + 1)", systemImage: "infinity")
                Spacer()
                Label("Best: \(best)", systemImage: "trophy.fill")
            }
            .font(.caption.bold())
            .foregroundStyle(Color("AppTextSecondary"))
        }
        .padding(.horizontal, 16)
    }

    private var summaryView: some View {
        ScrollView {
            VStack(spacing: 20) {
                IconBadgeView(systemName: "infinity", size: 72, iconSize: 30)
                Text("Endless Complete")
                    .font(.title.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                SurfaceCard(accentBorder: true) {
                    VStack(spacing: 6) {
                        Text("\(wave)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(Color("AppAccent"))
                        Text("Waves survived")
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    .frame(maxWidth: .infinity)
                }
                if wave >= best {
                    StatusPillView(text: "New Personal Best!", style: .success)
                }
                AppButton(title: "Try Again", icon: "arrow.clockwise") {
                    wave = 0
                    showSummary = false
                    isPlaying = true
                }
                AppButton(title: "Back", icon: "arrow.left", style: .secondary) { dismiss() }
            }
            .padding(24)
        }
    }

    private func handleWave(_ notification: Notification) {
        guard let success = notification.userInfo?["success"] as? Bool else { return }
        if success {
            wave += 1
            progress.recordEndlessWave(activityId: activity.id, wave: wave)
        } else {
            progress.recordEndlessWave(activityId: activity.id, wave: wave)
            showSummary = true
            isPlaying = false
        }
    }
}
