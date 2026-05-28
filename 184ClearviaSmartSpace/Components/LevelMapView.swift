import SwiftUI

struct LevelMapView: View {
    let activityId: String
    let difficulty: Difficulty
    @EnvironmentObject private var progress: ProgressStore

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(0..<GameContent.levelsPerDifficulty, id: \.self) { level in
                    HStack(spacing: 0) {
                        levelNode(level: level)
                        if level < GameContent.levelsPerDifficulty - 1 {
                            connector(filled: progress.stars(
                                for: activityId,
                                difficulty: difficulty.storageKey,
                                level: level
                            ) >= 1)
                        }
                    }
                }
            }
            .padding(.vertical, 6)
        }
    }

    private func levelNode(level: Int) -> some View {
        let unlocked = progress.isLevelUnlocked(
            activityId: activityId,
            difficulty: difficulty.storageKey,
            level: level
        )
        let stars = progress.stars(
            for: activityId,
            difficulty: difficulty.storageKey,
            level: level
        )
        let isCurrent = unlocked && stars == 0 && (level == 0 || progress.stars(
            for: activityId,
            difficulty: difficulty.storageKey,
            level: level - 1
        ) >= 1)

        return VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(unlocked ? Color("AppPrimary").opacity(isCurrent ? 0.45 : 0.25) : Color("AppBackground").opacity(0.6))
                    .frame(width: 46, height: 46)
                Circle()
                    .stroke(
                        isCurrent ? Color("AppAccent") : Color("AppAccent").opacity(unlocked ? 0.35 : 0.15),
                        lineWidth: isCurrent ? 2.5 : 1
                    )
                    .frame(width: 46, height: 46)
                if unlocked {
                    Text("\(level + 1)")
                        .font(.headline.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                } else {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            StarRatingView(count: stars, size: 10)
        }
        .frame(width: 58)
    }

    private func connector(filled: Bool) -> some View {
        ZStack {
            Capsule()
                .fill(Color("AppBackground").opacity(0.8))
                .frame(width: 32, height: 6)
            Capsule()
                .fill(filled ? Color("AppAccent") : Color("AppSurface"))
                .frame(width: 32, height: 4)
        }
        .padding(.bottom, 16)
    }
}
