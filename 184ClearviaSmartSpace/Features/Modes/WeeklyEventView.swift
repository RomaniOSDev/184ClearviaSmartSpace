import SwiftUI

struct WeeklyEventView: View {
    @EnvironmentObject private var progress: ProgressStore
    @State private var playConfig: GameSessionConfig?

    private var event: WeeklyEventGenerator.Event {
        WeeklyEventGenerator.current()
    }

    var body: some View {
        ZStack {
            BackgroundPatternView()
            ScrollView {
                VStack(spacing: 18) {
                    SectionHeaderView(
                        title: "Weekly Spotlight",
                        subtitle: "Refreshes every Monday",
                        iconName: "sparkles"
                    )

                    let track = TrackCatalog.track(activityId: event.activityId, level: event.level)
                    let activity = ActivityCatalog.find(id: event.activityId)

                    SurfaceCard(accentBorder: true) {
                        VStack(alignment: .leading, spacing: 12) {
                            if let activity {
                                HStack(spacing: 12) {
                                    IconBadgeView(systemName: activity.iconName, size: 48, iconSize: 20)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(event.title)
                                            .font(.headline.bold())
                                            .foregroundStyle(Color("AppTextPrimary"))
                                        Text(track.displaySubtitle)
                                            .font(.caption)
                                            .foregroundStyle(Color("AppTextSecondary"))
                                    }
                                }
                            }
                            Text("Clear this spotlight track to earn +\(event.bonusStars) bonus stars. One reward per week.")
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                            if progress.isWeeklyEventAvailable() {
                                StatusPillView(text: "Available Now", style: .accent)
                            } else {
                                StatusPillView(text: "Completed This Week", style: .success)
                            }
                        }
                    }

                    if progress.isWeeklyEventAvailable(), activity != nil {
                        AppButton(title: "Play Weekly Spotlight", icon: "play.fill") {
                            playConfig = GameSessionConfig(
                                activityId: event.activityId,
                                difficulty: event.difficulty,
                                level: event.level,
                                mode: .weeklyEvent
                            )
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Weekly Event")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $playConfig) { config in
            ActivityGameHost(config: config)
        }
    }
}
