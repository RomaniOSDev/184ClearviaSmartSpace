import StoreKit
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var progress: ProgressStore
    @EnvironmentObject private var themeStore: ThemeStore
    @State private var showResetAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundPatternView()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        statsSection
                        StreakCalendarView()
                        breakdownSection
                        themeSection
                        legalSection
                        actionsSection
                        Text("Version \(appVersion)")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .frame(maxWidth: .infinity)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    Color.clear.frame(height: 12)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Reset All Progress?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    HapticService.error()
                    progress.resetAllProgress()
                    themeStore.theme = .classic
                }
            } message: {
                Text("This will erase all stars, levels, and statistics. This action cannot be undone.")
            }
        }
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeaderView(title: "Statistics", subtitle: "Your overall progress", iconName: "chart.bar.fill")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                StatChipView(icon: "play.fill", value: "\(progress.totalActivitiesPlayed)", label: "Sessions")
                StatChipView(icon: "star.fill", value: "\(progress.totalStarsEarned)", label: "Stars")
                StatChipView(icon: "clock.fill", value: ProgressStore.formattedPlayTime(seconds: progress.totalPlayTimeSeconds), label: "Play Time")
                StatChipView(icon: "bolt.fill", value: "\(progress.bestComboOverall)", label: "Best Combo")
            }
            SurfaceCard {
                HStack {
                    Text("Daily Challenges")
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                    Spacer()
                    Text("\(progress.totalDailyChallengesCompleted)")
                        .font(.headline.bold())
                        .foregroundStyle(Color("AppAccent"))
                }
            }
        }
    }

    private var breakdownSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeaderView(title: "Activity Breakdown", iconName: "list.bullet.rectangle.fill")
            SurfaceCard {
                VStack(spacing: 10) {
                    ForEach(progress.activityBreakdown()) { stat in
                        ActivityStatCell(stat: stat, iconName: iconForActivity(stat.id))
                    }
                }
            }
        }
    }

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeaderView(title: "Theme", subtitle: "Customize your look", iconName: "paintbrush.fill")
            HStack(spacing: 10) {
                ForEach(AppTheme.allCases) { theme in
                    ThemeOptionCell(theme: theme, selected: themeStore.theme == theme) {
                        themeStore.theme = theme
                        progress.selectedThemeRaw = theme.rawValue
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private var legalSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeaderView(title: "Legal & Feedback", iconName: "doc.text.fill")
            VStack(spacing: 12) {
                SettingsCell(title: "Rate Us", icon: "star.bubble.fill", subtitle: "Enjoying the app? Leave a review") {
                    HapticService.lightTap()
                    rateApp()
                }
                SettingsCell(title: AppLink.privacyPolicy.title, icon: "lock.shield.fill", subtitle: "Read how data is handled") {
                    HapticService.lightTap()
                    openPrivacyPolicy()
                }
                SettingsCell(title: AppLink.termsOfUse.title, icon: "doc.plaintext.fill", subtitle: "Terms and conditions") {
                    HapticService.lightTap()
                    openTermsOfUse()
                }
            }
        }
    }

    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeaderView(title: "Support", iconName: "lifepreserver.fill")
            VStack(spacing: 12) {
                SettingsCell(title: "Contact Support", icon: "envelope.fill", subtitle: "support@example.com") {
                    openSupportEmail()
                }
                SettingsCell(title: "Reset All Progress", icon: "arrow.counterclockwise", subtitle: "Clear stars and stats", destructive: true) {
                    showResetAlert = true
                }
            }
        }
    }

    private func iconForActivity(_ id: String) -> String {
        ActivityCatalog.find(id: id)?.iconName ?? "music.note"
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private func openPrivacyPolicy() {
        if let url = AppLink.privacyPolicy.url {
            UIApplication.shared.open(url)
        }
    }

    private func openTermsOfUse() {
        if let url = AppLink.termsOfUse.url {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    private func openSupportEmail() {
        if let url = URL(string: "mailto:support@example.com") {
            UIApplication.shared.open(url)
        }
    }
}
