import SwiftUI

struct GameResultView: View {
    let isSuccess: Bool
    let stars: Int
    let primaryMetric: String
    let metricLabel: String
    let showNextLevel: Bool
    let newlyUnlocked: [AchievementDefinition]
    var onNextLevel: () -> Void
    var onRetry: () -> Void
    var onBackToLevels: () -> Void

    @State private var visibleStars = 0
    @State private var showAchievementBanner = false
    @State private var redFlashOpacity: Double = 0

    var body: some View {
        ZStack {
            BackgroundPatternView()

            if !isSuccess {
                Color("AppTextSecondary").opacity(redFlashOpacity).ignoresSafeArea()
            }

            ScrollView {
                VStack(spacing: 22) {
                    if showAchievementBanner, let achievement = newlyUnlocked.first {
                        achievementBanner(achievement)
                    }

                    Spacer(minLength: 16)

                    IconBadgeView(
                        systemName: isSuccess ? "checkmark.seal.fill" : "arrow.counterclockwise",
                        size: 72,
                        iconSize: 30,
                        highlighted: isSuccess
                    )

                    Text(isSuccess ? "Level Complete!" : "Try Again")
                        .font(.largeTitle.bold())
                        .foregroundStyle(Color("AppTextPrimary"))

                    StarRatingView(
                        count: stars,
                        size: 28,
                        animated: isSuccess,
                        visibleCount: isSuccess ? visibleStars : 0
                    )

                    SurfaceCard(accentBorder: isSuccess) {
                        VStack(spacing: 6) {
                            Text(primaryMetric)
                                .font(.system(size: 46, weight: .bold, design: .rounded))
                                .foregroundStyle(Color("AppAccent"))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            Text(metricLabel)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 4)

                    VStack(spacing: 12) {
                        if isSuccess && showNextLevel {
                            AppButton(title: "Next Level", icon: "arrow.right") {
                                HapticService.mediumTap()
                                onNextLevel()
                            }
                        }
                        AppButton(title: "Retry", icon: "arrow.clockwise", style: isSuccess ? .secondary : .primary) {
                            onRetry()
                        }
                        AppButton(title: "Back to Levels", icon: "square.grid.2x2.fill", style: .secondary) {
                            onBackToLevels()
                        }
                    }

                    Spacer(minLength: 16)
                }
                .padding(24)
            }
        }
        .onAppear { handleAppear() }
    }

    private func achievementBanner(_ achievement: AchievementDefinition) -> some View {
        SurfaceCard(accentBorder: true) {
            HStack(spacing: 12) {
                IconBadgeView(systemName: achievement.iconName, size: 44, iconSize: 18)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Achievement Unlocked!")
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppAccent"))
                    Text(achievement.title)
                        .font(.subheadline.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                }
                Spacer()
            }
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    private func handleAppear() {
        if isSuccess {
            HapticService.success()
            SoundService.playSuccess()
            animateStars()
            if !newlyUnlocked.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.3)) { showAchievementBanner = true }
                }
            }
        } else {
            HapticService.error()
            SoundService.playFail()
            animateRedFlash()
        }
    }

    private func animateStars() {
        for i in 1...stars {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { visibleStars = i }
            }
        }
    }

    private func animateRedFlash() {
        withAnimation(.easeInOut(duration: 0.15)) { redFlashOpacity = 0.6 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeInOut(duration: 0.15)) { redFlashOpacity = 0 }
        }
    }
}
