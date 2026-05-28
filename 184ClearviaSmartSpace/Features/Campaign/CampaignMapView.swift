import SwiftUI

struct CampaignMapView: View {
    @EnvironmentObject private var progress: ProgressStore
    @State private var selectedActivity: ActivityDefinition?

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundPatternView()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        SectionHeaderView(
                            title: "Rhythm Campaign",
                            subtitle: "Four worlds, 72 tracks, one journey",
                            iconName: "map.fill"
                        )

                        ForEach(CampaignCatalog.worlds) { world in
                            worldCard(world)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Campaign")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(item: $selectedActivity) { activity in
                LevelSelectionView(activity: activity)
            }
        }
    }

    private func worldCard(_ world: CampaignWorld) -> some View {
        let unlocked = CampaignCatalog.isWorldUnlocked(world, progress: progress)
        let stars = CampaignCatalog.starsInWorld(world, progress: progress)
        let tracks = TrackCatalog.tracks(for: world.activityId)
        let cleared = tracks.filter { progress.stars(for: world.activityId, difficulty: Difficulty.easy.storageKey, level: $0.levelIndex) >= 1 }.count

        return Button {
            guard unlocked, let activity = ActivityCatalog.find(id: world.activityId) else { return }
            HapticService.mediumTap()
            selectedActivity = activity
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    IconBadgeView(systemName: world.iconName, size: 48, iconSize: 20, highlighted: unlocked)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(world.title)
                            .font(.headline.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text(world.subtitle)
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .lineLimit(2)
                            .minimumScaleFactor(0.7)
                    }
                    Spacer()
                    if unlocked {
                        StatusPillView(text: "\(stars)★", style: .accent)
                    } else {
                        StatusPillView(text: "Locked", style: .muted)
                    }
                }

                Text(world.story)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(3)
                    .minimumScaleFactor(0.7)

                ProgressBarView(
                    fraction: Double(cleared) / Double(GameContent.levelsPerDifficulty),
                    height: 6
                )

                HStack {
                    Text("\(cleared)/\(GameContent.levelsPerDifficulty) tracks cleared")
                        .font(.caption2.bold())
                        .foregroundStyle(Color("AppTextSecondary"))
                    Spacer()
                    if !unlocked {
                        Text("Requires \(world.requiredStarsToUnlock) total stars")
                            .font(.caption2)
                            .foregroundStyle(Color("AppAccent"))
                    }
                }
            }
            .padding(16)
            .background(ElevatedSurfaceBackground(cornerRadius: 20, accentBorder: unlocked))
            .appSoftShadow()
            .opacity(unlocked ? 1 : 0.72)
        }
        .buttonStyle(.plain)
        .disabled(!unlocked)
    }
}
