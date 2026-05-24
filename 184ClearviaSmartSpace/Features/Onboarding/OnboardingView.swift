import SwiftUI

private struct OnboardingPage {
    let headline: String
    let subtitle: String
    let icon: String
    let pill: String
    let artwork: ActivityArtworkStyle
}

struct OnboardingView: View {
    @EnvironmentObject private var progress: ProgressStore
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            headline: "Master the Rhythm",
            subtitle: "Four musical activities — tap beats, glide notes, hold timing, and repeat patterns.",
            icon: "waveform.circle.fill",
            pill: "Activities",
            artwork: .harmonyPulse
        ),
        OnboardingPage(
            headline: "Earn Stars",
            subtitle: "Complete levels with skill to collect up to 3 stars and unlock Expert difficulty.",
            icon: "star.fill",
            pill: "Progress",
            artwork: .tapSequence
        ),
        OnboardingPage(
            headline: "Build Your Streak",
            subtitle: "Play daily challenges, grow streaks, and unlock achievements as you improve.",
            icon: "flame.fill",
            pill: "Motivation",
            artwork: .hero
        )
    ]

    var body: some View {
        ZStack {
            BackgroundPatternView()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        onboardingPage(index: index, page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)

                bottomPanel
            }
        }
    }

    private var bottomPanel: some View {
        VStack(spacing: 18) {
            pageIndicator

            AppButton(
                title: buttonTitle,
                icon: currentPage < pages.count - 1 ? "arrow.right" : "checkmark"
            ) {
                if currentPage < pages.count - 1 {
                    withAnimation(.easeInOut(duration: 0.3)) { currentPage += 1 }
                } else {
                    HapticService.mediumTap()
                    progress.hasSeenOnboarding = true
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 32)
        .background(
            LinearGradient(
                colors: [
                    Color("AppBackground").opacity(0),
                    Color("AppBackground").opacity(0.88),
                    Color("AppBackground").opacity(0.96)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .bottom)
        )
    }

    private var buttonTitle: String {
        currentPage < pages.count - 1 ? "Next" : "Get Started"
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Capsule()
                    .fill(
                        index == currentPage
                            ? AppGradients.primaryButton
                            : LinearGradient(
                                colors: [Color("AppTextSecondary").opacity(0.28), Color("AppTextSecondary").opacity(0.18)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                    )
                    .frame(width: index == currentPage ? 28 : 8, height: 8)
                    .overlay(
                        Capsule()
                            .stroke(
                                index == currentPage ? AppGradients.topHighlight : LinearGradient(colors: [.clear], startPoint: .top, endPoint: .bottom),
                                lineWidth: 1
                            )
                    )
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
            }
        }
    }

    private func onboardingPage(index: Int, page: OnboardingPage) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                Spacer(minLength: 28)

                StatusPillView(text: "Step \(index + 1) of \(pages.count)", style: .accent)

                heroCard(page: page)

                VStack(spacing: 12) {
                    HStack(spacing: 10) {
                        IconBadgeView(systemName: page.icon, size: 44, iconSize: 18)
                        Text(page.pill)
                            .font(.caption.bold())
                            .foregroundStyle(Color("AppAccent"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(AppGradients.surfaceInset)
                                    .overlay(Capsule().stroke(AppGradients.subtleBorder, lineWidth: 1))
                            )
                        Spacer()
                    }

                    Text(page.headline)
                        .font(.title.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)

                    Text(page.subtitle)
                        .font(.body)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(18)
                .background(ElevatedSurfaceBackground(cornerRadius: 20))
                .appSoftShadow()

                featureChips(for: index)

                Spacer(minLength: 120)
            }
            .padding(.horizontal, 24)
        }
    }

    private func heroCard(page: OnboardingPage) -> some View {
        ZStack(alignment: .bottomLeading) {
            ElevatedSurfaceBackground(cornerRadius: 24, accentBorder: true)

            ActivityArtworkView(style: page.artwork, animate: true)
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            LinearGradient(
                colors: [Color("AppBackground").opacity(0.15), Color("AppBackground").opacity(0.72)],
                startPoint: .top,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            HStack(spacing: 8) {
                IconBadgeView(systemName: page.icon, size: 52, iconSize: 22)
                VStack(alignment: .leading, spacing: 4) {
                    Text(page.pill)
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppAccent"))
                    Text(page.headline)
                        .font(.headline.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
            }
            .padding(18)
        }
        .frame(height: 240)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .appElevationShadow(radius: 14, y: 7)
    }

    @ViewBuilder
    private func featureChips(for index: Int) -> some View {
        let chips: [(String, String)] = {
            switch index {
            case 0:
                return [
                    ("hand.tap.fill", "Tap Beats"),
                    ("arrow.right.circle.fill", "Glide Notes"),
                    ("flame.fill", "Hold Timing")
                ]
            case 1:
                return [
                    ("star.fill", "3 Stars"),
                    ("lock.open.fill", "Unlock Levels"),
                    ("bolt.fill", "Expert Mode")
                ]
            default:
                return [
                    ("sun.max.fill", "Daily Challenge"),
                    ("calendar", "Streaks"),
                    ("trophy.fill", "Achievements")
                ]
            }
        }()

        HStack(spacing: 8) {
            ForEach(chips, id: \.1) { chip in
                HStack(spacing: 5) {
                    Image(systemName: chip.0)
                        .font(.caption2.bold())
                    Text(chip.1)
                        .font(.caption2.bold())
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .foregroundStyle(Color("AppTextPrimary"))
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(ElevatedSurfaceBackground(cornerRadius: 12, inset: true))
            }
        }
    }
}
