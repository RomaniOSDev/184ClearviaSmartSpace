import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var progress: ProgressStore
    @State private var animateUnlocks: Set<String> = []
    @State private var selectedAchievement: AchievementDefinition?
    @State private var showUnlockedOnly = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var filteredAchievements: [AchievementDefinition] {
        if showUnlockedOnly {
            return AchievementCatalog.all.filter { $0.isUnlocked(progress) }
        }
        return AchievementCatalog.all
    }

    private var unlockedCount: Int {
        AchievementCatalog.all.filter { $0.isUnlocked(progress) }.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundPatternView()
                ScrollView {
                    VStack(spacing: 16) {
                        summaryCard
                        filterBar
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(filteredAchievements) { achievement in
                                AchievementCell(
                                    achievement: achievement,
                                    unlocked: achievement.isUnlocked(progress),
                                    progress: achievement.progress(progress),
                                    animated: animateUnlocks.contains(achievement.id)
                                ) {
                                    selectedAchievement = achievement
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedAchievement) { achievement in
                AchievementDetailView(achievement: achievement)
            }
        }
        .onAppear { checkNewUnlocks() }
        .onChange(of: progress.totalStarsEarned) { _ in checkNewUnlocks() }
        .onChange(of: progress.totalActivitiesPlayed) { _ in checkNewUnlocks() }
        .onReceive(NotificationCenter.default.publisher(for: .progressReset)) { _ in
            animateUnlocks.removeAll()
        }
    }

    private var summaryCard: some View {
        SurfaceCard(accentBorder: true) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Collection Progress")
                        .font(.headline.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("\(unlockedCount) of \(AchievementCatalog.all.count) unlocked")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Spacer()
                Text("\(Int(Double(unlockedCount) / Double(AchievementCatalog.all.count) * 100))%")
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppAccent"))
            }
            ProgressBarView(
                fraction: Double(unlockedCount) / Double(max(AchievementCatalog.all.count, 1))
            )
            .padding(.top, 4)
        }
    }

    private var filterBar: some View {
        HStack(spacing: 10) {
            filterChip(title: "All", active: !showUnlockedOnly) { showUnlockedOnly = false }
            filterChip(title: "Unlocked", active: showUnlockedOnly) { showUnlockedOnly = true }
        }
    }

    private func filterChip(title: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button {
            HapticService.lightTap()
            withAnimation(.easeInOut(duration: 0.2)) { action() }
        } label: {
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(active ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(active ? Color("AppPrimary") : Color("AppSurface"))
                )
        }
        .buttonStyle(.plain)
    }

    private func checkNewUnlocks() {
        for achievement in AchievementCatalog.all where achievement.isUnlocked(progress) {
            if !animateUnlocks.contains(achievement.id) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    animateUnlocks.insert(achievement.id)
                }
            }
        }
    }
}

extension AchievementDefinition: Hashable {
    static func == (lhs: AchievementDefinition, rhs: AchievementDefinition) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
