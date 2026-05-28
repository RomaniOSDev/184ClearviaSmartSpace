import SwiftUI

struct PatternEditorView: View {
    let activity: ActivityDefinition

    @EnvironmentObject private var progress: ProgressStore
    @Environment(\.dismiss) private var dismiss
    @State private var pattern: [Int] = []
    @State private var playConfig: GameSessionConfig?

    private let notes = ["C", "D", "E", "F", "G", "A"]
    private let maxLength = 8

    var body: some View {
        ZStack {
            BackgroundPatternView()
            ScrollView {
                VStack(spacing: 18) {
                    SectionHeaderView(
                        title: "Pattern Studio",
                        subtitle: "Build a custom Tap Sequence pattern",
                        iconName: "slider.horizontal.3"
                    )

                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Your pattern")
                                .font(.subheadline.bold())
                                .foregroundStyle(Color("AppTextPrimary"))
                            if pattern.isEmpty {
                                Text("Tap notes below to add steps")
                                    .font(.caption)
                                    .foregroundStyle(Color("AppTextSecondary"))
                            } else {
                                HStack(spacing: 6) {
                                    ForEach(pattern.indices, id: \.self) { i in
                                        Text(notes[pattern[i]])
                                            .font(.caption.bold())
                                            .foregroundStyle(Color("AppTextPrimary"))
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(Capsule().fill(Color("AppPrimary").opacity(0.35)))
                                    }
                                }
                            }
                        }
                    }

                    SurfaceCard {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(notes.indices, id: \.self) { index in
                                Button {
                                    addNote(index)
                                } label: {
                                    Text(notes[index])
                                        .font(.headline.bold())
                                        .foregroundStyle(Color("AppTextPrimary"))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(ElevatedSurfaceBackground(cornerRadius: 12, inset: true))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    HStack(spacing: 10) {
                        AppButton(title: "Undo", icon: "delete.backward", style: .secondary) {
                            if !pattern.isEmpty { pattern.removeLast() }
                        }
                        AppButton(title: "Clear", icon: "trash", style: .secondary) {
                            pattern = []
                        }
                    }

                    AppButton(title: "Save Pattern", icon: "square.and.arrow.down") {
                        progress.saveCustomTapPattern(pattern)
                        HapticService.success()
                    }

                    AppButton(title: "Play Pattern", icon: "play.fill") {
                        progress.saveCustomTapPattern(pattern)
                        playConfig = GameSessionConfig(
                            activityId: "tap_sequence",
                            difficulty: .easy,
                            level: 0,
                            mode: .customPattern,
                            customPatternNotes: pattern
                        )
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Pattern Studio")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            pattern = progress.customTapPattern
        }
        .navigationDestination(item: $playConfig) { config in
            ActivityGameHost(config: config)
        }
    }

    private func addNote(_ index: Int) {
        guard pattern.count < maxLength else { return }
        HapticService.lightTap()
        pattern.append(index)
    }
}
