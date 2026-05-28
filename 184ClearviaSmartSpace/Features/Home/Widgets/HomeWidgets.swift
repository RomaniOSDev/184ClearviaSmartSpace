import SwiftUI

struct HomeHeroBanner: View {
    let stars: Int
    let streak: Int
    let sessions: Int

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ElevatedSurfaceBackground(cornerRadius: 22, accentBorder: true)

            ActivityArtworkView(style: .hero, animate: true)
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .opacity(0.95)

            LinearGradient(
                colors: [Color("AppBackground").opacity(0.85), Color("AppBackground").opacity(0.15)],
                startPoint: .bottom,
                endPoint: .top
            )
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

            VStack(alignment: .leading, spacing: 10) {
                StatusPillView(text: greeting, style: .accent)
                Text("Your Musical Hub")
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                Text("Play daily challenges, grow streaks, unlock Expert")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                HStack(spacing: 8) {
                    miniStat(icon: "star.fill", value: "\(stars)")
                    miniStat(icon: "flame.fill", value: "\(streak)d")
                    miniStat(icon: "play.fill", value: "\(sessions)")
                }
            }
            .padding(18)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .appElevationShadow(radius: 14, y: 7)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Good Night"
        }
    }

    private func miniStat(icon: String, value: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2.bold())
            Text(value)
                .font(.caption.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .foregroundStyle(Color("AppTextPrimary"))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule().fill(
                LinearGradient(
                    colors: [Color("AppPrimary").opacity(0.42), Color("AppPrimary").opacity(0.24)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        )
    }
}

struct HomeWidgetGrid: View {
    @EnvironmentObject private var progress: ProgressStore

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            HomeMiniWidget(
                title: "Total Stars",
                value: "\(progress.totalStarsEarned)",
                icon: "star.fill",
                accent: true
            )
            HomeMiniWidget(
                title: "Day Streak",
                value: "\(progress.playStreakDays)",
                icon: "flame.fill",
                accent: false
            )
            HomeMiniWidget(
                title: "Play Time",
                value: ProgressStore.formattedPlayTime(seconds: progress.totalPlayTimeSeconds),
                icon: "clock.fill",
                accent: false
            )
            HomeMiniWidget(
                title: "Best Combo",
                value: "\(progress.bestComboOverall)",
                icon: "bolt.fill",
                accent: true
            )
        }
    }
}

struct HomeMiniWidget: View {
    let title: String
    let value: String
    let icon: String
    let accent: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                IconBadgeView(systemName: icon, size: 34, iconSize: 14, highlighted: accent)
                Spacer()
            }
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(title)
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .leading)
        .background(ElevatedSurfaceBackground(cornerRadius: 18, accentBorder: accent))
        .appSoftShadow()
    }
}

struct HomeDailyWidget: View {
    @EnvironmentObject private var progress: ProgressStore
    let onPlay: (GameSessionConfig) -> Void

    private var challenge: DailyChallengeGenerator.Challenge {
        DailyChallengeGenerator.challenge()
    }

    var body: some View {
        let activity = ActivityCatalog.find(id: challenge.activityId)
        let completed = progress.dailyChallengeCompleted

        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                if let activity {
                    ActivityArtworkView(style: ActivityArtworkStyle(activityId: activity.id), animate: !completed)
                        .frame(height: 120)
                }
                if completed {
                    StatusPillView(text: "Done", style: .success)
                        .padding(12)
                } else {
                    StatusPillView(text: "+1 Star", style: .accent)
                        .padding(12)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                SectionHeaderView(
                    title: "Daily Challenge",
                    subtitle: completed ? "Come back tomorrow" : "Bonus star waiting",
                    iconName: "sun.max.fill"
                )
                if let activity {
                    Text("\(activity.title) • \(challenge.difficulty.rawValue) • Level \(challenge.level + 1)")
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                if !completed, activity != nil {
                    AppButton(title: "Play Now", icon: "play.fill") {
                        HapticService.mediumTap()
                        onPlay(GameSessionConfig(
                            activityId: challenge.activityId,
                            difficulty: challenge.difficulty,
                            level: challenge.level,
                            mode: .dailyChallenge
                        ))
                    }
                }
            }
            .padding(16)
        }
        .background(ElevatedSurfaceBackground(cornerRadius: 20, accentBorder: true))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .appElevationShadow()
    }
}

struct HomeWeeklyEventWidget: View {
    @EnvironmentObject private var progress: ProgressStore
    let onPlay: (GameSessionConfig) -> Void

    private var event: WeeklyEventGenerator.Event {
        WeeklyEventGenerator.current()
    }

    var body: some View {
        let completed = !progress.isWeeklyEventAvailable()
        let track = TrackCatalog.track(activityId: event.activityId, level: event.level)

        VStack(spacing: 0) {
            ActivityArtworkView(style: ActivityArtworkStyle(activityId: event.activityId), animate: !completed)
                .frame(height: 100)

            VStack(alignment: .leading, spacing: 12) {
                SectionHeaderView(title: "Weekly Spotlight", subtitle: event.title, iconName: "sparkles")
                Text("\(track.title) • \(event.difficulty.rawValue) • +\(event.bonusStars) bonus stars")
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                if !completed {
                    AppButton(title: "Play Weekly Event", icon: "play.fill") {
                        onPlay(GameSessionConfig(
                            activityId: event.activityId,
                            difficulty: event.difficulty,
                            level: event.level,
                            mode: .weeklyEvent
                        ))
                    }
                } else {
                    StatusPillView(text: "Completed This Week", style: .success)
                }
            }
            .padding(16)
        }
        .background(ElevatedSurfaceBackground(cornerRadius: 20, accentBorder: true))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .appElevationShadow()
    }
}

struct HomeStreakWidget: View {
    @EnvironmentObject private var progress: ProgressStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Weekly Rhythm", subtitle: "Keep your streak alive", iconName: "calendar")
            HStack(spacing: 8) {
                ForEach(progress.recentPlayDayTokens(limit: 7), id: \.self) { day in
                    let played = progress.playedOnDay(day)
                    VStack(spacing: 4) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(
                                    played
                                        ? AppGradients.primaryButton
                                        : AppGradients.surfaceInset
                                )
                                .frame(height: 36)
                            if played {
                                Image(systemName: "music.note")
                                    .font(.caption.bold())
                                    .foregroundStyle(Color("AppTextPrimary"))
                            }
                        }
                        Text(day.suffix(2).description)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .background(ElevatedSurfaceBackground(cornerRadius: 18))
        .appSoftShadow()
    }
}

struct HomeContinueWidget: View {
    let activity: ActivityDefinition
    let difficulty: Difficulty
    let level: Int
    let stars: Int
    let action: () -> Void

    var body: some View {
        Button {
            HapticService.mediumTap()
            action()
        } label: {
            HStack(spacing: 0) {
                ActivityArtworkView(style: ActivityArtworkStyle(activityId: activity.id), animate: true)
                    .frame(width: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 6) {
                    StatusPillView(text: "Continue Playing", style: .accent)
                    Text(activity.title)
                        .font(.headline.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text("\(difficulty.rawValue) • Level \(level + 1)")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                    StarRatingView(count: stars, size: 12)
                }
                .padding(14)

                Spacer(minLength: 0)

                Image(systemName: "play.circle.fill")
                    .font(.title)
                    .foregroundStyle(Color("AppPrimary"))
                    .padding(.trailing, 14)
            }
            .background(ElevatedSurfaceBackground(cornerRadius: 18, accentBorder: true))
            .appElevationShadow()
        }
        .buttonStyle(.plain)
    }
}

struct HomeAchievementsWidget: View {
    @EnvironmentObject private var progress: ProgressStore
    @Environment(\.mainTabSelection) private var tabSelection

    private var unlocked: Int {
        AchievementCatalog.all.filter { $0.isUnlocked(progress) }.count
    }

    var body: some View {
        Button {
            HapticService.lightTap()
            tabSelection?.wrappedValue = .achievements
        } label: {
            achievementsContent
        }
        .buttonStyle(.plain)
    }

    private var achievementsContent: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(Color("AppAccent").opacity(0.3), lineWidth: 6)
                    .frame(width: 52, height: 52)
                Circle()
                    .trim(from: 0, to: CGFloat(unlocked) / CGFloat(max(AchievementCatalog.all.count, 1)))
                    .stroke(Color("AppPrimary"), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 52, height: 52)
                    .rotationEffect(.degrees(-90))
                Text("\(unlocked)")
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Achievements")
                    .font(.subheadline.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                Text("\(unlocked) of \(AchievementCatalog.all.count) unlocked")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .padding(16)
        .background(ElevatedSurfaceBackground(cornerRadius: 18, accentBorder: true))
        .appSoftShadow()
    }
}
